#!/bin/bash

# Test Task Manager API
# Run this from app VM or web VM

set -e

API_URL="${1:-http://localhost:8080}"

echo "=========================================="
echo "  API Testing Script"
echo "=========================================="
echo "Testing API at: $API_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

test_endpoint() {
  local method=$1
  local endpoint=$2
  local data=$3
  local description=$4
  local expected_code=$5
  
  echo -n "Testing: $description... "
  
  if [ -z "$data" ]; then
    response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint")
  else
    response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
      -H "Content-Type: application/json" \
      -d "$data")
  fi
  
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')
  
  if [ "$http_code" -eq "$expected_code" ]; then
    echo -e "${GREEN}✓ PASS${NC} ($http_code)"
  else
    echo -e "${RED}✗ FAIL${NC} (expected $expected_code, got $http_code)"
    echo "Response: $body"
  fi
}

# Run tests
test_endpoint "GET" "/health" "" "Health check" 200
test_endpoint "GET" "/" "" "Root endpoint" 200
test_endpoint "GET" "/api/tasks" "" "Get all tasks" 200
test_endpoint "GET" "/api/tasks/1" "" "Get task by ID" 200
test_endpoint "POST" "/api/tasks" '{"title":"Test Task","description":"API Test"}' "Create task" 201
test_endpoint "PUT" "/api/tasks/1" '{"completed":true}' "Update task" 200
test_endpoint "GET" "/api/tasks/999" "" "Get non-existent task (should 404)" 404

echo ""
echo "=========================================="
echo "  Tests Complete"
echo "=========================================="
