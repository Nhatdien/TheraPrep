#!/bin/bash

# Test User Registration Endpoint
echo "========================================="
echo "Testing Registration Endpoint"
echo "========================================="
echo ""

# Test data
EMAIL="testuser@example.com"
PASSWORD="SecurePassword123!"
USERNAME="testuser123"

echo "Registering user with:"
echo "  Email: $EMAIL"
echo "  Username: $USERNAME"
echo ""

# Call registration endpoint
response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://localhost:4000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\",
    \"username\": \"$USERNAME\"
  }")

# Extract response body and status
http_body=$(echo "$response" | sed -e 's/HTTP_STATUS\:.*//g')
http_status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')

echo "Response Status: $http_status"
echo "Response Body:"
echo "$http_body" | jq '.' 2>/dev/null || echo "$http_body"
echo ""

if [ "$http_status" -eq 201 ]; then
    echo "✅ Registration successful!"
    echo ""
    echo "========================================="
    echo "Testing Login (Direct Grant Flow)"
    echo "========================================="
    echo ""
    
    # Test login with Direct Grant
    token_response=$(curl -s -X POST http://localhost:4200/realms/tranquara_auth/protocol/openid-connect/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=password" \
      -d "client_id=tranquara_auth_client" \
      -d "username=$EMAIL" \
      -d "password=$PASSWORD" \
      -d "scope=openid email profile")
    
    echo "Login Response:"
    echo "$token_response" | jq '.' 2>/dev/null || echo "$token_response"
    echo ""
    
    # Extract access token
    access_token=$(echo "$token_response" | jq -r '.access_token' 2>/dev/null)
    
    if [ "$access_token" != "null" ] && [ -n "$access_token" ]; then
        echo "✅ Login successful!"
        echo ""
        echo "========================================="
        echo "Testing User Sync Endpoint"
        echo "========================================="
        echo ""
        
        # Test sync endpoint
        sync_response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://localhost:4000/v1/users/sync \
          -H "Authorization: Bearer $access_token" \
          -H "Content-Type: application/json" \
          -d "{
            \"email\": \"$EMAIL\",
            \"username\": \"$USERNAME\",
            \"oauth_provider\": \"email\"
          }")
        
        sync_body=$(echo "$sync_response" | sed -e 's/HTTP_STATUS\:.*//g')
        sync_status=$(echo "$sync_response" | tr -d '\n' | sed -e 's/.*HTTP_STATUS://')
        
        echo "Sync Status: $sync_status"
        echo "Sync Response:"
        echo "$sync_body" | jq '.' 2>/dev/null || echo "$sync_body"
        echo ""
        
        if [ "$sync_status" -eq 201 ] || [ "$sync_status" -eq 200 ]; then
            echo "✅ User sync successful!"
        else
            echo "❌ User sync failed"
        fi
    else
        echo "❌ Login failed"
    fi
else
    echo "❌ Registration failed"
fi
