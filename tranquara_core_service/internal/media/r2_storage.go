package media

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// R2Storage handles Cloudflare R2 operations (S3-compatible)
type R2Storage struct {
	client    *s3.Client
	presigner *s3.PresignClient
	bucket    string
	publicURL string
}

// NewR2Storage creates a new R2 storage client
func NewR2Storage(accountID, accessKeyID, secretAccessKey, bucketName, publicURL string) (*R2Storage, error) {
	r2Resolver := aws.EndpointResolverWithOptionsFunc(func(service, region string, opts ...interface{}) (aws.Endpoint, error) {
		return aws.Endpoint{
			URL: fmt.Sprintf("https://%s.r2.cloudflarestorage.com", accountID),
		}, nil
	})

	cfg, err := config.LoadDefaultConfig(context.Background(),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(accessKeyID, secretAccessKey, "")),
		config.WithEndpointResolverWithOptions(r2Resolver),
		config.WithRegion("auto"),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to load R2 config: %w", err)
	}

	client := s3.NewFromConfig(cfg)
	presigner := s3.NewPresignClient(client)

	return &R2Storage{
		client:    client,
		presigner: presigner,
		bucket:    bucketName,
		publicURL: publicURL,
	}, nil
}

// PresignedUploadResult contains the presigned URL and related data
type PresignedUploadResult struct {
	MediaID     string    `json:"media_id"`
	UploadURL   string    `json:"upload_url"`
	DownloadURL string    `json:"download_url"`
	R2Key       string    `json:"r2_key"`
	ExpiresAt   time.Time `json:"expires_at"`
}

// GeneratePresignedUploadURL creates a presigned PUT URL for direct upload
func (r *R2Storage) GeneratePresignedUploadURL(ctx context.Context, userID, mediaID, filename, contentType string) (*PresignedUploadResult, error) {
	r2Key := fmt.Sprintf("media/users/%s/%s_%s", userID, mediaID, sanitizeFilename(filename))
	downloadURL := fmt.Sprintf("%s/%s", r.publicURL, r2Key)

	presignResult, err := r.presigner.PresignPutObject(ctx, &s3.PutObjectInput{
		Bucket:      aws.String(r.bucket),
		Key:         aws.String(r2Key),
		ContentType: aws.String(contentType),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = 15 * time.Minute
	})
	if err != nil {
		return nil, fmt.Errorf("failed to generate presigned URL: %w", err)
	}

	return &PresignedUploadResult{
		MediaID:     mediaID,
		UploadURL:   presignResult.URL,
		DownloadURL: downloadURL,
		R2Key:       r2Key,
		ExpiresAt:   time.Now().Add(15 * time.Minute),
	}, nil
}

// GeneratePresignedDownloadURL creates a temporary GET URL for private access
func (r *R2Storage) GeneratePresignedDownloadURL(ctx context.Context, r2Key string, expiry time.Duration) (string, error) {
	presignResult, err := r.presigner.PresignGetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(r.bucket),
		Key:    aws.String(r2Key),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = expiry
	})
	if err != nil {
		return "", fmt.Errorf("failed to generate download URL: %w", err)
	}
	return presignResult.URL, nil
}

// DeleteObject removes a file from R2
func (r *R2Storage) DeleteObject(ctx context.Context, r2Key string) error {
	_, err := r.client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(r.bucket),
		Key:    aws.String(r2Key),
	})
	if err != nil {
		return fmt.Errorf("failed to delete R2 object: %w", err)
	}
	return nil
}

// sanitizeFilename removes unsafe characters from filename
func sanitizeFilename(name string) string {
	safe := make([]byte, 0, len(name))
	for i := 0; i < len(name); i++ {
		c := name[i]
		if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '.' || c == '-' || c == '_' {
			safe = append(safe, c)
		}
	}
	if len(safe) == 0 {
		return "file"
	}
	return string(safe)
}