package pubsub

import (
	"fmt"
	"os"

	amqp "github.com/rabbitmq/amqp091-go"
	"tranquara.net/internal/data"
)

func Serve(models *data.Models) (*amqp.Channel, *amqp.Connection, error) {
	conUrl := os.Getenv("RABBITMQ_URL")
	if conUrl == "" {
		return nil, nil, fmt.Errorf("RABBITMQ_URL environment variable is required")
	}

	conn, err := amqp.Dial(conUrl)
	if err != nil {
		return nil, nil, err
	}

	channel, err := conn.Channel()
	if err != nil {
		return nil, nil, err
	}

	err = setupUnits(channel, models)

	return channel, conn, err
}
