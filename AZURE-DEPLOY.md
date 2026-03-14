# ☁️ Deploying Tranquara to Microsoft Azure

## Architecture on Azure

```
┌──────────────────────────────────────────────────────────────┐
│                  Azure Container Apps Environment            │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐      │
│  │   Frontend    │  │ Core Service │  │  AI Service    │      │
│  │   (Nuxt 3)   │  │    (Go)      │  │  (FastAPI)     │      │
│  │ Container App │  │ Container App│  │ Container App  │      │
│  └──────┬───────┘  └──────┬───────┘  └───────┬───────┘      │
│         │                 │                   │              │
│  ┌──────┴─────────────────┴───────────────────┴──────┐       │
│  │            Azure Container Apps Ingress            │       │
│  │         (Auto HTTPS, Load Balancing, DNS)          │       │
│  └───────────────────────────────────────────────────┘       │
│                                                              │
│  ┌──────────────┐                                            │
│  │   Keycloak    │                                           │
│  │ Container App │                                           │
│  └──────────────┘                                            │
└──────────────────────────────────────────────────────────────┘
          │                    │                    │
   ┌──────┴──────┐     ┌──────┴──────┐     ┌──────┴──────┐
   │ Azure DB    │     │  RabbitMQ   │     │Qdrant Cloud │
   │ PostgreSQL  │     │ (Container  │     │  (External) │
   │ Flexible    │     │  or AMQP)   │     │             │
   └─────────────┘     └─────────────┘     └─────────────┘
         │
   ┌─────┴───────┐
   │  Azure      │
   │ Container   │
   │ Registry    │
   └─────────────┘
```

## Why Azure Container Apps?

| Feature | Benefit |
|---------|---------|
| **Docker Compose support** | Deploy your existing `docker-compose.yml` directly |
| **Auto HTTPS/TLS** | Free managed certificates on all endpoints |
| **Scale to zero** | Pay nothing when services are idle |
| **Built-in ingress** | No need for Nginx/Traefik reverse proxy |
| **Managed identity** | Passwordless auth to Azure services |
| **Southeast Asia region** | Low latency from Vietnam |

## Prerequisites

| Tool | Installation |
|------|-------------|
| **Azure CLI** | [Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| **Docker Desktop** | [Install](https://docs.docker.com/desktop/) |
| **Azure subscription** | [Free trial](https://azure.microsoft.com/free/) ($200 credit) |

### External Services (free tiers)

| Service | Purpose | Free Tier | Sign Up |
|---------|---------|-----------|---------|
| **[Qdrant Cloud](https://cloud.qdrant.io/)** | Vector database (RAG) | 1GB free | [cloud.qdrant.io](https://cloud.qdrant.io/) |
| **[OpenAI](https://platform.openai.com/)** | GPT-4o-mini API | Pay-as-you-go | [platform.openai.com](https://platform.openai.com/) |

> **Note**: RabbitMQ runs as a container inside Azure Container Apps (no external service needed).

---

## Step-by-Step Deployment

### Step 1: Install Azure CLI & Login

```bash
# Install Azure CLI (if not installed)
# Windows: winget install -e --id Microsoft.AzureCLI
# macOS:   brew install azure-cli
# Linux:   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Install the containerapp extension
az extension add --name containerapp --upgrade
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights
```

### Step 2: Create Azure Resource Group

```bash
# Variables — customize these
RESOURCE_GROUP="tranquara-rg"
LOCATION="southeastasia"    # Close to Vietnam
ACR_NAME="tranquaraacr"     # Must be globally unique, lowercase, no dashes

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION
```

### Step 3: Create Azure Container Registry (ACR)

```bash
# Create container registry to store your Docker images
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Login to ACR
az acr login --name $ACR_NAME
```

### Step 4: Build & Push Images to ACR

```bash
ACR_SERVER="$ACR_NAME.azurecr.io"

# Build and push Frontend
docker build -t $ACR_SERVER/tranquara-frontend:latest \
  -f tranquara_frontend/Dockerfile.yml tranquara_frontend/
docker push $ACR_SERVER/tranquara-frontend:latest

# Build and push Core Service
docker build -t $ACR_SERVER/tranquara-core:latest \
  -f tranquara_core_service/Dockerfile tranquara_core_service/
docker push $ACR_SERVER/tranquara-core:latest

# Build and push AI Service
docker build -t $ACR_SERVER/tranquara-ai:latest \
  -f tranquara_ai_service/Dockerfile tranquara_ai_service/
docker push $ACR_SERVER/tranquara-ai:latest
```

### Step 5: Create Azure Database for PostgreSQL

```bash
DB_SERVER_NAME="tranquara-db"       # Must be globally unique
DB_ADMIN_USER="tranquara_admin"
DB_ADMIN_PASSWORD="$(openssl rand -base64 24)"  # Save this!
DB_NAME="tranquara_core"

echo "⚠️  Save this DB password: $DB_ADMIN_PASSWORD"

# Create PostgreSQL Flexible Server
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --location $LOCATION \
  --admin-user $DB_ADMIN_USER \
  --admin-password "$DB_ADMIN_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 16 \
  --yes

# Create the database
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER_NAME \
  --database-name $DB_NAME

# Allow Azure services to connect
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Get the connection string
DB_HOST="$DB_SERVER_NAME.postgres.database.azure.com"
DB_DSN="postgres://$DB_ADMIN_USER:$DB_ADMIN_PASSWORD@$DB_HOST:5432/$DB_NAME?sslmode=require"
echo "DB_DSN: $DB_DSN"
```

### Step 6: Run Database Migrations

```bash
# Option A: Run from local machine (requires golang-migrate)
migrate -path ./tranquara_core_service/migrations \
  -database "$DB_DSN" up

# Option B: Run from a temporary container
docker run --rm -v $(pwd)/tranquara_core_service/migrations:/migrations \
  migrate/migrate \
  -path=/migrations \
  -database="$DB_DSN" up
```

### Step 7: Create Container Apps Environment

```bash
ENVIRONMENT_NAME="tranquara-env"

az containerapp env create \
  --name $ENVIRONMENT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
```

### Step 8: Deploy RabbitMQ as a Container App

RabbitMQ runs as an internal-only container (no public ingress):

```bash
az containerapp create \
  --name rabbitmq \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image rabbitmq:3-management-alpine \
  --min-replicas 1 \
  --max-replicas 1 \
  --cpu 0.5 \
  --memory 1.0Gi \
  --env-vars \
    RABBITMQ_DEFAULT_USER=rabbitmq \
    RABBITMQ_DEFAULT_PASS=<YOUR_RABBITMQ_PASSWORD> \
  --ingress internal \
  --target-port 5672 \
  --transport tcp

# Get internal FQDN for other services to connect
RABBITMQ_FQDN=$(az containerapp show \
  --name rabbitmq \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.fqdn" -o tsv)
echo "RabbitMQ internal FQDN: $RABBITMQ_FQDN"
```

### Step 9: Deploy Keycloak

```bash
KC_ADMIN_PASSWORD="$(openssl rand -base64 16)"
echo "⚠️  Save Keycloak admin password: $KC_ADMIN_PASSWORD"

az containerapp create \
  --name keycloak \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image quay.io/keycloak/keycloak:26.0.6 \
  --cpu 1.0 \
  --memory 2.0Gi \
  --min-replicas 1 \
  --max-replicas 1 \
  --ingress external \
  --target-port 8080 \
  --env-vars \
    KC_BOOTSTRAP_ADMIN_USERNAME=admin \
    KC_BOOTSTRAP_ADMIN_PASSWORD="$KC_ADMIN_PASSWORD" \
    KC_DB=postgres \
    KC_DB_URL="jdbc:postgresql://$DB_HOST:5432/$DB_NAME" \
    KC_DB_USERNAME=$DB_ADMIN_USER \
    KC_DB_PASSWORD="$DB_ADMIN_PASSWORD" \
    KC_HOSTNAME_STRICT=false \
    KC_PROXY_HEADERS=xforwarded \
  --command "start" "--hostname-strict=false" "--proxy-headers=xforwarded"

KEYCLOAK_URL=$(az containerapp show \
  --name keycloak \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.fqdn" -o tsv)
echo "Keycloak URL: https://$KEYCLOAK_URL"
```

### Step 10: Deploy Core Service

```bash
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
INTERNAL_API_KEY="$(openssl rand -hex 32)"

az containerapp create \
  --name tranquara-core \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image $ACR_SERVER/tranquara-core:latest \
  --registry-server $ACR_SERVER \
  --registry-username $ACR_NAME \
  --registry-password "$ACR_PASSWORD" \
  --cpu 0.5 \
  --memory 1.0Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --ingress external \
  --target-port 4000 \
  --env-vars \
    ENVIRONMENT=production \
    TRANQUARA_DB_DSN="$DB_DSN" \
    RABBITMQ_URL="amqp://rabbitmq:<RABBITMQ_PASSWORD>@$RABBITMQ_FQDN:5672/" \
    INTERNAL_API_KEY="$INTERNAL_API_KEY" \
    ALLOWED_ORIGINS="https://<FRONTEND_FQDN>" \
    PUBLIC_KEY_PATH="/app/publicKey.pem" \
    SMTP_HOST="<YOUR_SMTP_HOST>" \
    SMTP_USERNAME="<YOUR_SMTP_USER>" \
    SMTP_PASSWORD="<YOUR_SMTP_PASS>" \
    SMTP_SENDER="Tranquara <no-reply@yourdomain.com>"

CORE_URL=$(az containerapp show \
  --name tranquara-core \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.fqdn" -o tsv)
echo "Core Service URL: https://$CORE_URL"
```

### Step 11: Deploy AI Service

```bash
az containerapp create \
  --name tranquara-ai \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image $ACR_SERVER/tranquara-ai:latest \
  --registry-server $ACR_SERVER \
  --registry-username $ACR_NAME \
  --registry-password "$ACR_PASSWORD" \
  --cpu 0.5 \
  --memory 1.0Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --ingress external \
  --target-port 8000 \
  --env-vars \
    ENVIRONMENT=production \
    OPENAI_API_KEY="<YOUR_OPENAI_KEY>" \
    RABBITMQ_HOST="$RABBITMQ_FQDN" \
    RABBITMQ_PORT=5672 \
    RABBITMQ_USER=rabbitmq \
    RABBITMQ_PASSWORD="<RABBITMQ_PASSWORD>" \
    QDRANT_HOST="<YOUR_QDRANT_CLOUD_HOST>" \
    QDRANT_PORT=6333 \
    QDRANT_API_KEY="<YOUR_QDRANT_API_KEY>" \
    CORE_SERVICE_URL="https://$CORE_URL" \
    INTERNAL_API_KEY="$INTERNAL_API_KEY" \
    ALLOWED_ORIGINS="https://<FRONTEND_FQDN>" \
    MEMORY_INTERVAL_HOURS=12

AI_URL=$(az containerapp show \
  --name tranquara-ai \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.fqdn" -o tsv)
echo "AI Service URL: https://$AI_URL"
```

### Step 12: Deploy Frontend

```bash
az containerapp create \
  --name tranquara-frontend \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --image $ACR_SERVER/tranquara-frontend:latest \
  --registry-server $ACR_SERVER \
  --registry-username $ACR_NAME \
  --registry-password "$ACR_PASSWORD" \
  --cpu 0.25 \
  --memory 0.5Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --ingress external \
  --target-port 3000 \
  --env-vars \
    NODE_ENV=production \
    NUXT_PUBLIC_BASE_URL="https://$CORE_URL" \
    NUXT_PUBLIC_BASE_FRONTEND_URL="https://<FRONTEND_FQDN>" \
    NUXT_PUBLIC_WEBSOCKET_URL="wss://$CORE_URL" \
    NUXT_PUBLIC_KEYCLOAK_URL="https://$KEYCLOAK_URL" \
    NUXT_PUBLIC_KEYCLOAK_REALM=tranquara_auth \
    NUXT_PUBLIC_KEYCLOAK_CLIENT_ID=tranquara_client \
    NUXT_PUBLIC_KEYCLOAK_CLIENT_SECRET="<FROM_KEYCLOAK_SETUP>"

FRONTEND_URL=$(az containerapp show \
  --name tranquara-frontend \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.fqdn" -o tsv)
echo "Frontend URL: https://$FRONTEND_URL"
```

### Step 13: Update CORS Origins

Now that you have the Frontend URL, update CORS on Core and AI services:

```bash
# Update Core Service ALLOWED_ORIGINS
az containerapp update \
  --name tranquara-core \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars ALLOWED_ORIGINS="https://$FRONTEND_URL"

# Update AI Service ALLOWED_ORIGINS
az containerapp update \
  --name tranquara-ai \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars ALLOWED_ORIGINS="https://$FRONTEND_URL"

# Update Frontend self-reference
az containerapp update \
  --name tranquara-frontend \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars NUXT_PUBLIC_BASE_FRONTEND_URL="https://$FRONTEND_URL"
```

### Step 14: Configure Keycloak Realm

1. Open `https://<KEYCLOAK_FQDN>` in your browser
2. Login with `admin` / your `KC_ADMIN_PASSWORD`
3. **Create Realm**: `tranquara_auth`
4. **Create Client**: `tranquara_client`
   - Client authentication: **ON**
   - Valid redirect URIs: `https://<FRONTEND_FQDN>/*`
   - Web origins: `https://<FRONTEND_FQDN>`
5. Copy the **Client Secret** → Update Frontend env var:

```bash
az containerapp update \
  --name tranquara-frontend \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars NUXT_PUBLIC_KEYCLOAK_CLIENT_SECRET="<CLIENT_SECRET>"
```

### Step 15: Verify Deployment ✅

```bash
# Check all services are running
az containerapp list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name, Status:properties.runningStatus, URL:properties.configuration.ingress.fqdn}" \
  -o table
```

| Service | URL | Expected |
|---------|-----|----------|
| Frontend | `https://<frontend-fqdn>` | Login page loads |
| Core API | `https://<core-fqdn>/v1/healthcheck` | `200 OK` |
| AI Service | `https://<ai-fqdn>/healthcheck` | `200 OK` |
| Keycloak | `https://<keycloak-fqdn>` | Admin console |

---

## Alternative: One-Command Docker Compose Deploy

Azure Container Apps supports deploying directly from `docker-compose.yml`:

```bash
# This converts your compose file into Container Apps automatically
az containerapp compose create \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT_NAME \
  --compose-file-path docker-compose.yml \
  --registry-server $ACR_SERVER \
  --registry-username $ACR_NAME \
  --registry-password "$ACR_PASSWORD"
```

> ⚠️ **Limitations of compose create**: Not all Docker Compose features are supported.
> The `depends_on`, `healthcheck`, `networks`, and `volumes` directives are partially
> supported or ignored. For production, the step-by-step approach above gives more control.
> See [Azure docs](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-docker-compose).

---

## Updating Services

After code changes, rebuild and redeploy:

```bash
# Rebuild + push a specific service (e.g., core)
docker build -t $ACR_SERVER/tranquara-core:latest \
  -f tranquara_core_service/Dockerfile tranquara_core_service/
docker push $ACR_SERVER/tranquara-core:latest

# Update the container app to pull the new image
az containerapp update \
  --name tranquara-core \
  --resource-group $RESOURCE_GROUP \
  --image $ACR_SERVER/tranquara-core:latest
```

### Enable CI/CD with GitHub Actions

You can automate this with GitHub Actions. Add a workflow at `.github/workflows/deploy.yml`:

```yaml
# See: https://learn.microsoft.com/en-us/azure/container-apps/github-actions
name: Deploy to Azure Container Apps
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - uses: azure/container-apps-deploy-action@v2
        with:
          resourceGroup: tranquara-rg
          containerAppName: tranquara-core
          imageToDeploy: tranquaraacr.azurecr.io/tranquara-core:${{ github.sha }}
```

---

## Cost Estimate

| Resource | SKU | Monthly Cost (est.) |
|----------|-----|-------------------|
| **Container Apps** (4 apps) | Consumption plan | ~$10-25/mo (pay per use, scale to zero) |
| **Azure DB for PostgreSQL** | Burstable B1ms | ~$13/mo |
| **Container Registry** | Basic | ~$5/mo |
| **Total Azure** | | **~$28-43/mo** |
| Qdrant Cloud | Free tier | Free |
| OpenAI API | Pay-as-you-go | ~$1-5/mo |
| **Grand Total** | | **~$29-48/mo** |

> 💡 **Azure Free Trial**: New accounts get **$200 free credit** for 30 days + 12 months of free services.
> Container Apps consumption plan includes **2 million free requests/month**.

---

## Scaling Configuration

Azure Container Apps auto-scale based on HTTP traffic:

```bash
# Set scaling rules for Core Service
az containerapp update \
  --name tranquara-core \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 0 \
  --max-replicas 5 \
  --scale-rule-name http-scaling \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50
```

---

## Custom Domain & SSL

```bash
# Add custom domain
az containerapp hostname add \
  --name tranquara-frontend \
  --resource-group $RESOURCE_GROUP \
  --hostname app.yourdomain.com

# Bind managed certificate (free!)
az containerapp hostname bind \
  --name tranquara-frontend \
  --resource-group $RESOURCE_GROUP \
  --hostname app.yourdomain.com \
  --environment $ENVIRONMENT_NAME \
  --validation-method CNAME
```

---

## Monitoring & Logs

```bash
# View real-time logs
az containerapp logs show \
  --name tranquara-core \
  --resource-group $RESOURCE_GROUP \
  --follow

# View specific container logs
az containerapp logs show \
  --name tranquara-ai \
  --resource-group $RESOURCE_GROUP \
  --tail 100
```

Azure also provides built-in **Application Insights** and **Log Analytics** for monitoring.

---

## Troubleshooting

### Service won't start
```bash
# Check logs for errors
az containerapp logs show --name <service-name> -g $RESOURCE_GROUP --tail 50

# Check revision status
az containerapp revision list -n <service-name> -g $RESOURCE_GROUP -o table
```

### Database connection fails
- Ensure Azure Postgres firewall allows Azure services (`0.0.0.0` rule)
- Connection string must use `sslmode=require` (code auto-detects this in production)
- Verify the database exists: `az postgres flexible-server db list`

### RabbitMQ connection fails
- RabbitMQ container is internal-only — services must use the internal FQDN
- Check RabbitMQ logs: `az containerapp logs show --name rabbitmq -g $RESOURCE_GROUP`

### Keycloak slow to start
- Keycloak needs ~60-90s on first start (DB initialization)
- Allocate at least 1 CPU / 2GB RAM for Keycloak

### CORS errors
- Ensure `ALLOWED_ORIGINS` on Core and AI exactly matches the frontend URL
- Include the protocol: `https://tranquara-frontend.<hash>.azurecontainerapps.io`
- No trailing slash

---

## Cleanup (Delete Everything)

```bash
# ⚠️ This deletes ALL resources in the resource group!
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

## Reference Links

- [Azure Container Apps docs](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Container Apps + Docker Compose](https://learn.microsoft.com/en-us/azure/container-apps/quickstart-docker-compose)
- [Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Container Apps scaling](https://learn.microsoft.com/en-us/azure/container-apps/scale-app)
- [Custom domains & certificates](https://learn.microsoft.com/en-us/azure/container-apps/custom-domains-managed-certificates)
