#!/bin/bash

# Complete authentication flow test: Register → Login → Sync

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
API_URL="http://localhost:4000"
KEYCLOAK_URL="http://localhost:4200"
REALM="tranquara_auth"
CLIENT_ID="tranquara_auth_client"
CLIENT_SECRET="JWUXybAZ4Qrm99KaRMF0wWM5DI8X1j5m"

# Generate unique test user
RANDOM_ID=$(date +%s)
TEST_EMAIL="testuser${RANDOM_ID}@example.com"
TEST_USERNAME="testuser${RANDOM_ID}"
TEST_PASSWORD="TestPass999"

echo -e "${YELLOW}=== TheraPrep Authentication Flow Test ===${NC}\n"

# Step 1: Register User
echo -e "${YELLOW}Step 1: Registering user...${NC}"
echo "Email: $TEST_EMAIL"
echo "Username: $TEST_USERNAME"
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/v1/auth/register" \
  -H "Content-Type: application/json" \
  --data-raw "{\"email\":\"$TEST_EMAIL\",\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}")

if echo "$REGISTER_RESPONSE" | grep -q "success"; then
  echo -e "${GREEN}✓ Registration successful${NC}"
  echo "$REGISTER_RESPONSE"
else
  echo -e "${RED}✗ Registration failed${NC}"
  echo "$REGISTER_RESPONSE"
  exit 1
fi

# Step 2: Login
echo -e "\n${YELLOW}Step 2: Logging in...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$TEST_USERNAME&password=$TEST_PASSWORD")

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
  echo -e "${GREEN}✓ Login successful${NC}"
  ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"refresh_token":"[^"]*' | cut -d'"' -f4)
  echo "Access Token: ${ACCESS_TOKEN:0:50}..."
  echo "Refresh Token: ${REFRESH_TOKEN:0:50}..."
else
  echo -e "${RED}✗ Login failed${NC}"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

# Step 3: Sync to Database
echo -e "\n${YELLOW}Step 3: Syncing user to PostgreSQL...${NC}"
SYNC_RESPONSE=$(curl -s -X POST "$API_URL/v1/users/sync" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  --data-raw "{\"email\":\"$TEST_EMAIL\",\"username\":\"$TEST_USERNAME\",\"oauth_provider\":\"email\"}")

if echo "$SYNC_RESPONSE" | grep -q "user_id"; then
  echo -e "${GREEN}✓ Sync successful${NC}"
  echo "$SYNC_RESPONSE"
  USER_UUID=$(echo "$SYNC_RESPONSE" | grep -o '"user_id":"[^"]*' | cut -d'"' -f4)
else
  echo -e "${RED}✗ Sync failed${NC}"
  echo "$SYNC_RESPONSE"
  exit 1
fi

# Summary
echo -e "\n${GREEN}=== All tests passed! ===${NC}"
echo -e "\n${YELLOW}Test Summary:${NC}"
echo "Email: $TEST_EMAIL"
echo "Username: $TEST_USERNAME"
echo "User UUID: $USER_UUID"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "- User is created in Keycloak (realm: $REALM)"
echo "- User is synced to PostgreSQL (table: user_informations)"
echo "- User can now access authenticated endpoints"
