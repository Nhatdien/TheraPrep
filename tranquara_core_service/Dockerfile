FROM golang:1.23-alpine AS builder

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o main ./cmd/api

# --- Production stage ---
FROM alpine:latest

# Install necessary tools for wait-for-it script, healthcheck, and SSL certificates
RUN apk --no-cache add ca-certificates netcat-openbsd wget

# Create non-root user
RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

COPY --from=builder /build/main /app/main
COPY --from=builder /build/publicKey.pem /app/publicKey.pem
COPY --from=builder /build/wait-for-it.sh /app/wait-for-it.sh

RUN chmod +x /app/wait-for-it.sh /app/main
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 4000

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:4000/v1/healthcheck || exit 1

# Default: start directly. Override with wait-for-it.sh in docker-compose if needed.
CMD ["/app/main"]
