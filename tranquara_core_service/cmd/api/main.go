package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"

	_ "github.com/lib/pq"
	amqp "github.com/rabbitmq/amqp091-go"
	"tranquara.net/internal/data"
	"tranquara.net/internal/jsonlog"
	"tranquara.net/internal/mailer"
	"tranquara.net/internal/pubsub"
)

type envolope map[string]any

const version = "1.0.0"

type config struct {
	port int
	env  string
	db   struct {
		dsn          string
		maxOpenConns int
		maxIdleConns int
		maxIdleTime  string
	}
	limiter struct {
		rps     float64
		burst   int
		enabled bool
	}
	smtp struct {
		host     string
		port     int
		username string
		password string
		sender   string
	}
}

type application struct {
	config        config
	logger        *jsonlog.Logger
	rabbitchannel *amqp.Channel
	models        data.Models
	mailer        mailer.Mailer
	wg            sync.WaitGroup
}

func main() {
	var cfg config

	// get the arg from cmd
	flag.IntVar(&cfg.port, "port", 4000, "API server port")
	flag.StringVar(&cfg.env, "environment", "development", "Environment (development|staging|production)")

	flag.StringVar(&cfg.db.dsn, "db-dsn", os.Getenv("TRANQUARA_DB_DSN"), "postgres dsn")

	flag.IntVar(&cfg.db.maxOpenConns, "db-max-open-conns", 25, "Postgres max open connection")
	flag.IntVar(&cfg.db.maxIdleConns, "db-max-idle-conns", 25, "Postgres max idle connection")
	flag.StringVar(&cfg.db.maxIdleTime, "db-max-idle-time", "15m", "Postgres conn max idle time")

	flag.Float64Var(&cfg.limiter.rps, "limiter-rps", 2, "Rate limiter maximum requests per second")
	flag.IntVar(&cfg.limiter.burst, "limiter-burst", 4, "Rate limiter maximum burst")
	flag.BoolVar(&cfg.limiter.enabled, "limiter-enabled", true, "Enable rate limiter")

	flag.StringVar(&cfg.smtp.host, "smtp-host", os.Getenv("SMTP_HOST"), "SMTP host")
	flag.IntVar(&cfg.smtp.port, "smtp-port", 587, "SMTP port")
	flag.StringVar(&cfg.smtp.username, "smtp-username", os.Getenv("SMTP_USERNAME"), "SMTP username")
	flag.StringVar(&cfg.smtp.password, "smtp-password", os.Getenv("SMTP_PASSWORD"), "SMTP password")
	flag.StringVar(&cfg.smtp.sender, "smtp-sender", os.Getenv("SMTP_SENDER"), "SMTP sender")

	flag.Parse()

	logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)

	db, err := openDB(cfg)
	if err != nil {
		logger.PrintFatal(err, nil)
	}

	defer db.Close()

	logger.PrintInfo("connect to db successfully", nil)

	models := data.NewModels(db)

	// Connect to RabbitMQ with retry logic
	var channel *amqp.Channel
	var conn *amqp.Connection
	maxRetries := 10
	retryDelay := 5 * time.Second

	for i := 0; i < maxRetries; i++ {
		channel, conn, err = pubsub.Serve(&models)
		if err == nil {
			logger.PrintInfo("Successfully connected to RabbitMQ", nil)
			break
		}

		logger.PrintError(err, map[string]string{
			"attempt": fmt.Sprintf("%d/%d", i+1, maxRetries),
		})

		if i < maxRetries-1 {
			logger.PrintInfo("Retrying RabbitMQ connection...", map[string]string{
				"delay": retryDelay.String(),
			})
			time.Sleep(retryDelay)
		}
	}

	if err != nil {
		logger.PrintError(err, map[string]string{
			"message": "Failed to connect to RabbitMQ after all retries",
		})
		// Continue without RabbitMQ - service can still handle HTTP requests
		logger.PrintInfo("Starting service without RabbitMQ connection", nil)
	} else {
		defer channel.Close()
		defer conn.Close()
		logger.PrintInfo("Waiting for messages", nil)
	}

	app := &application{
		config:        cfg,
		logger:        logger,
		rabbitchannel: channel,
		models:        models,
		mailer:        mailer.New(cfg.smtp.host, cfg.smtp.port, cfg.smtp.username, cfg.smtp.password, cfg.smtp.sender),
	}

	err = app.serve()
	logger.PrintFatal(err, nil)
}

func openDB(cfg config) (*sql.DB, error) {
	dsn := cfg.db.dsn
	if dsn == "" {
		return nil, fmt.Errorf("TRANQUARA_DB_DSN environment variable is required")
	}

	// If sslmode is not specified in the DSN, default based on environment:
	//   - development: sslmode=disable (local Docker Postgres without TLS)
	//   - production/staging: sslmode=require (managed Postgres like Render)
	if !strings.Contains(strings.ToLower(dsn), "sslmode=") {
		parsedDSN, err := url.Parse(dsn)
		if err == nil {
			query := parsedDSN.Query()
			if cfg.env == "development" {
				query.Set("sslmode", "disable")
			} else {
				query.Set("sslmode", "require")
			}
			parsedDSN.RawQuery = query.Encode()
			dsn = parsedDSN.String()
		}
	}

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(cfg.db.maxOpenConns)
	db.SetMaxIdleConns(cfg.db.maxIdleConns)

	idleTime, err := time.ParseDuration(cfg.db.maxIdleTime)

	if err != nil {
		return nil, err
	}

	db.SetConnMaxIdleTime(idleTime)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}
	return db, nil
}
