package main

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/google/uuid"
	"golang.org/x/time/rate"
)

func (app *application) recoverPanic(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				w.Header().Set("Connection", "close")
				app.serverErrorResponse(w, r, fmt.Errorf("%s", err))
			}
		}()
		next.ServeHTTP(w, r)
	})
}

func (app *application) rateLimit(next http.Handler) http.Handler {
	type client struct {
		limiter  *rate.Limiter
		lastSeen time.Time
	}
	var (
		mu      sync.Mutex
		clients = make(map[string]*client)
	)

	// Default limits (can override via config)
	rps := float64(50)
	burst := 100

	go func() {
		for {
			time.Sleep(time.Minute)
			mu.Lock()
			for key, client := range clients {
				if time.Since(client.lastSeen) > 3*time.Minute {
					delete(clients, key)
				}
			}
			mu.Unlock()
		}
	}()

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		key := ""
		isWrite := r.Method != http.MethodGet && r.Method != http.MethodHead

		authHeader := r.Header.Get("Authorization")
		if strings.HasPrefix(authHeader, "Bearer ") {
			key = "user:" + authHeader[len("Bearer "):]
			if len(key) > 100 {
				key = key[:100]
			}
			// Authenticated users get higher limits
			if isWrite {
				rps = 25
				burst = 50
			} else {
				rps = 50
				burst = 100
			}
		}

		if key == "" {
			ip, _, err := net.SplitHostPort(r.RemoteAddr)
			if err != nil {
				app.serverErrorResponse(w, r, err)
				return
			}
			key = "ip:" + ip
			// Anonymous users get stricter limits
			if isWrite {
				rps = 5
				burst = 10
			} else {
				rps = 20
				burst = 30
			}
		}

		mu.Lock()
		if _, found := clients[key]; !found {
			clients[key] = &client{
				limiter:  rate.NewLimiter(rate.Limit(rps), burst),
				lastSeen: time.Now(),
			}
		}

		clients[key].lastSeen = time.Now()
		clients[key].limiter.SetLimit(rate.Limit(rps))
		clients[key].limiter.SetBurst(burst)

		if !clients[key].limiter.Allow() {
			mu.Unlock()
			app.rateLimitExceedResponse(w, r)
			return
		}
		mu.Unlock()
		next.ServeHTTP(w, r)
	})
}

func (app *application) testPostMiddleWare(previous http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		previous.ServeHTTP(w, r)
		app.logger.PrintInfo("post-middleware called", nil)
	})
}

const userCtxKey = "user"

func (app *application) authMiddleWare(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		pubKeyPath := os.Getenv("PUBLIC_KEY_PATH")
		if pubKeyPath == "" {
			pubKeyPath = "/app/publicKey.pem"
		}
		pubKey, err := app.loadPublicKey(pubKeyPath)
		if err != nil {
			app.logger.PrintError(err, nil)
			return
		}

		token, err := jwt.Parse(strings.TrimPrefix(authHeader, "Bearer "), func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodRSA); !ok {
				return nil, fmt.Errorf("error with signing method")
			}
			return pubKey, nil
		})

		if err != nil || !token.Valid {
			app.errorResponse(w, r, http.StatusUnauthorized, "Invalid token")
			return
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			ctx := context.WithValue(r.Context(), userCtxKey, claims)
			next.ServeHTTP(w, r.WithContext(ctx))
			return
		}

		app.errorResponse(w, r, http.StatusUnauthorized, "Error when get claims")
	})
}

func (app *application) GetUserFromContext(ctx context.Context) jwt.MapClaims {
	claims, ok := ctx.Value(userCtxKey).(jwt.MapClaims)
	if !ok {
		return nil
	}
	return claims
}

func (app *application) GetUserUUIDFromContext(ctx context.Context) (uuid.UUID, error) {
	claims := ctx.Value(userCtxKey).(jwt.MapClaims)
	return uuid.Parse(claims["sub"].(string))
}

func (app *application) adminMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return app.authMiddleWare(func(w http.ResponseWriter, r *http.Request) {
		userID, err := app.GetUserUUIDFromContext(r.Context())
		if err != nil {
			app.errorResponse(w, r, http.StatusForbidden, "Forbidden")
			return
		}

		adminUsersEnv := os.Getenv("ADMIN_USERS")
		if adminUsersEnv == "" {
			app.errorResponse(w, r, http.StatusForbidden, "Forbidden")
			return
		}

		adminUUIDs := strings.Split(adminUsersEnv, ",")
		for _, adminUUID := range adminUUIDs {
			if strings.TrimSpace(adminUUID) == userID.String() {
				next.ServeHTTP(w, r)
				return
			}
		}

		app.errorResponse(w, r, http.StatusForbidden, "Forbidden")
	})
}