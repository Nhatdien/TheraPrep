# 🚀 Deploying Tranquara to Render

## Architecture on Render

```
┌─────────────────────────────────────────────────────────┐
│                    Render Platform                       │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Frontend    │  │ Core Service │  │  AI Service   │  │
│  │   (Nuxt 3)   │  │    (Go)      │  │  (FastAPI)    │  │
│  │  Web Service  │  │ Web Service  │  │ Web Service   │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                  │          │
│         │          ┌──────┴───────┐          │          │
│         │          │  PostgreSQL  │          │          │
│         │          │  (Managed)   │          │          │
│         │          └──────────────┘          │          │
│         │                                    │          │
│  ┌──────┴────────────────────────────────────┴──────┐   │
│  │              Keycloak (Web Service)               │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   ┌────────────┐ ┌────────────┐ ┌────────────┐
   │ CloudAMQP  │ │Qdrant Cloud│ │   (SMTP)   │
   │ (RabbitMQ) │ │  (Vectors) │ │ Mailtrap   │
   │  External  │ │  External  │ │  External  │
   └────────────┘ └────────────┘ └────────────┘
```

## Prerequisites

Before deploying, you need accounts on these external services:

| Service | Purpose | Free Tier | Sign Up |
|---------|---------|-----------|---------|
| **Render** | Hosting platform | Yes (with limits) | [render.com](https://render.com) |
| **CloudAMQP** | Managed RabbitMQ | Yes (Little Lemur) | [cloudamqp.com](https://www.cloudamqp.com/) |
| **Qdrant Cloud** | Managed vector DB | Yes (1GB free) | [cloud.qdrant.io](https://cloud.qdrant.io/) |
| **OpenAI** | GPT API for AI features | Pay-as-you-go | [platform.openai.com](https://platform.openai.com/) |

## Step-by-Step Deployment

### Step 1: Set Up External Services

#### 1a. CloudAMQP (RabbitMQ)

1. Go to [cloudamqp.com](https://www.cloudamqp.com/) → Create account
2. Create a new instance → Select **Little Lemur (Free)**
3. Choose a region close to your Render region (e.g., **AWS ap-southeast-1** for Singapore)
4. After creation, copy the **AMQP URL** from the instance details
   - It looks like: `amqps://username:password@sparrow.rmq.cloudamqp.com/username`
5. Note down:
   - `RABBITMQ_URL` = the full AMQP URL (for Core Service)
   - `RABBITMQ_HOST` = the hostname (e.g., `sparrow.rmq.cloudamqp.com`)
   - `RABBITMQ_USER` = the username
   - `RABBITMQ_PASSWORD` = the password

#### 1b. Qdrant Cloud (Vector Database)

1. Go to [cloud.qdrant.io](https://cloud.qdrant.io/) → Create account
2. Create a new cluster → Select **Free tier (1GB)**
3. Choose a region close to your Render region
4. After creation, note down:
   - `QDRANT_HOST` = cluster URL (e.g., `abc123.us-east4-0.gcp.cloud.qdrant.io`)
   - `QDRANT_PORT` = `6333`
   - `QDRANT_API_KEY` = the API key from the cluster dashboard

#### 1c. OpenAI API Key

1. Go to [platform.openai.com](https://platform.openai.com/)
2. Navigate to **API Keys** → Create new secret key
3. Note down: `OPENAI_API_KEY` = `sk-...`

### Step 2: Push Code to GitHub

```bash
# Make sure all changes are committed
git add -A
git commit -m "chore: add Render deployment configuration"
git push origin main
```

Your repository must contain the `render.yaml` file at the root.

### Step 3: Create Blueprint on Render

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click **+ New** → **Blueprint**
3. Connect your GitHub repository
4. Render will detect the `render.yaml` file
5. You'll be prompted for all `sync: false` values:

| Variable | Service | Value to Enter |
|----------|---------|----------------|
| `NUXT_PUBLIC_WEBSOCKET_URL` | Frontend | `wss://tranquara-core.onrender.com` |
| `NUXT_PUBLIC_KEYCLOAK_URL` | Frontend | `https://tranquara-keycloak.onrender.com` |
| `NUXT_PUBLIC_KEYCLOAK_CLIENT_SECRET` | Frontend | (from Keycloak after setup) |
| `RABBITMQ_URL` | Core | CloudAMQP AMQP URL |
| `ALLOWED_ORIGINS` | Core | `https://tranquara-frontend.onrender.com` |
| `SMTP_HOST` | Core | Your SMTP host |
| `SMTP_USERNAME` | Core | Your SMTP username |
| `SMTP_PASSWORD` | Core | Your SMTP password |
| `SMTP_SENDER` | Core | `Tranquara <no-reply@yourdomain.com>` |
| `OPENAI_API_KEY` | AI | Your OpenAI key |
| `RABBITMQ_HOST` | AI | CloudAMQP hostname |
| `RABBITMQ_USER` | AI | CloudAMQP username |
| `RABBITMQ_PASSWORD` | AI | CloudAMQP password |
| `QDRANT_HOST` | AI | Qdrant Cloud cluster URL |
| `QDRANT_API_KEY` | AI | Qdrant Cloud API key |
| `ALLOWED_ORIGINS` | AI | `https://tranquara-frontend.onrender.com` |
| `KC_BOOTSTRAP_ADMIN_PASSWORD` | Keycloak | Strong password |
| `KC_DB_URL` | Keycloak | (see below) |

6. Click **Apply** → Render deploys everything

### Step 4: Configure Keycloak DB URL

After the Blueprint creates the PostgreSQL database, you need to get the JDBC URL:

1. Go to Render Dashboard → **tranquara-db** (PostgreSQL)
2. Copy the **Internal Database URL** (looks like `postgresql://tranquara:password@host:5432/tranquara_core`)
3. Convert to JDBC format: `jdbc:postgresql://host:5432/tranquara_core`
4. Go to **tranquara-keycloak** service → **Environment** → Set `KC_DB_URL`

### Step 5: Run Database Migrations

Render doesn't run the `migrate` container from docker-compose. You need to run migrations manually:

1. Go to Render Dashboard → **tranquara-core** service
2. Click **Shell** tab
3. Run the migration (the binary is at `/app/main`, but you need the migrate tool):

**Option A — Pre-deploy command (recommended):**
Add this in the Render dashboard under the Core Service settings:
```
# Pre-Deploy Command (in Render service settings)
wget -qO /tmp/migrate https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz && \
tar -xzf /tmp/migrate -C /tmp && \
/tmp/migrate -path=/app/migrations -database="${TRANQUARA_DB_DSN}" up
```

**Option B — Run migrations from your local machine:**
```bash
# Install golang-migrate locally, then:
migrate -path ./tranquara_core_service/migrations \
  -database "YOUR_RENDER_EXTERNAL_DB_URL" up
```

### Step 6: Configure Keycloak Realm

1. Open `https://tranquara-keycloak.onrender.com`
2. Log in with `admin` / (your KC_BOOTSTRAP_ADMIN_PASSWORD)
3. Create realm: `tranquara_auth`
4. Create client: `tranquara_client`
   - Client authentication: ON
   - Valid redirect URIs: `https://tranquara-frontend.onrender.com/*`
   - Web origins: `https://tranquara-frontend.onrender.com`
5. Copy the client secret → Update `NUXT_PUBLIC_KEYCLOAK_CLIENT_SECRET` on the Frontend service

### Step 7: Verify Deployment

Check each service:

```
✅ Frontend:  https://tranquara-frontend.onrender.com
✅ Core API:  https://tranquara-core.onrender.com/v1/healthcheck
✅ AI Service: https://tranquara-ai.onrender.com/healthcheck
✅ Keycloak:  https://tranquara-keycloak.onrender.com
```

## Cost Estimate (Render)

| Service | Plan | Monthly Cost |
|---------|------|-------------|
| Frontend | Starter | $7/mo |
| Core Service | Starter | $7/mo |
| AI Service | Starter | $7/mo |
| Keycloak | Starter | $7/mo |
| PostgreSQL | Starter | $7/mo |
| **Total Render** | | **~$35/mo** |
| CloudAMQP | Little Lemur | Free |
| Qdrant Cloud | Free tier | Free |
| OpenAI API | Pay-as-you-go | ~$1-5/mo |
| **Total** | | **~$36-40/mo** |

> 💡 **Tip:** You can use Render's Free tier for initial testing, but free services spin down after inactivity and have limited resources.

## Environment Variables Reference

### Shared (via env group)
| Variable | Description |
|----------|-------------|
| `INTERNAL_API_KEY` | Auto-generated, shared between Core ↔ AI |

### Core Service
| Variable | Source | Description |
|----------|--------|-------------|
| `TRANQUARA_DB_DSN` | Render DB | Auto-injected from `render.yaml` |
| `RABBITMQ_URL` | CloudAMQP | Full AMQP connection URL |
| `ALLOWED_ORIGINS` | Manual | Frontend URL for CORS |
| `ENVIRONMENT` | Fixed | `production` |

### AI Service
| Variable | Source | Description |
|----------|--------|-------------|
| `OPENAI_API_KEY` | OpenAI | GPT API key |
| `QDRANT_HOST` | Qdrant Cloud | Vector DB host |
| `QDRANT_API_KEY` | Qdrant Cloud | Vector DB auth |
| `RABBITMQ_URL` | CloudAMQP | Message queue URL |
| `CORE_SERVICE_URL` | Render (auto) | Internal URL to Core Service |

### Frontend
| Variable | Source | Description |
|----------|--------|-------------|
| `NUXT_PUBLIC_BASE_URL` | Render (auto) | Core Service URL |
| `NUXT_PUBLIC_KEYCLOAK_URL` | Manual | Keycloak URL |
| `NUXT_PUBLIC_KEYCLOAK_REALM` | Fixed | `tranquara_auth` |

## Troubleshooting

### Service won't start
- Check **Logs** tab in Render Dashboard
- Ensure all env vars are set (especially `sync: false` ones)
- Verify external services (CloudAMQP, Qdrant) are reachable

### Database connection fails
- Ensure `TRANQUARA_DB_DSN` is set (auto-injected by Blueprint)
- Check that sslmode is not set to `disable` (Render requires TLS)
- The code auto-defaults to `sslmode=require` in production

### RabbitMQ connection fails
- CloudAMQP uses `amqps://` (TLS) — ensure the URL starts with `amqps://`
- Check CloudAMQP dashboard for connection limits (free tier = 1 concurrent connection)

### Keycloak not starting
- Ensure `KC_DB_URL` is set with the correct JDBC URL
- Keycloak needs ~30-60s to start on Render Starter plan

### CORS errors
- Update `ALLOWED_ORIGINS` on Core and AI services to match your frontend URL exactly
- Include the protocol: `https://tranquara-frontend.onrender.com` (no trailing slash)
