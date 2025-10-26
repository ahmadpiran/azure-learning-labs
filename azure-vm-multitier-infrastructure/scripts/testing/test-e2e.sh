#!/bin/bash

# End-to-End Testing Script
# Tests complete 3-tier architecture flow

set -e

echo "=========================================="
echo "  End-to-End Architecture Testing"
echo "=========================================="
echo ""

# Get public IP
WEB_IP=$(cd terraform && terraform output -raw public_ip_address)

echo "Testing against: http://$WEB_IP"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

test_count=0
pass_count=0
fail_count=0

run_test() {
  local test_name=$1
  local expected="${@: -1}"
  local command="${@:2:$(($#-2))}"

  test_count=$((test_count + 1))   # safer increment
  echo -n "[$test_count] $test_name... "

  result=$(eval "$command" 2>&1)

  if echo "$result" | grep -q "$expected"; then
    echo -e "${GREEN}✓ PASS${NC}"
    pass_count=$((pass_count + 1))
  else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  Expected: $expected"
    echo "  Got: $result"
    fail_count=$((fail_count + 1))
  fi
}


echo "=========================================="
echo "  Static Content Tests"
echo "=========================================="

run_test "Homepage loads" \
  "curl -s http://$WEB_IP/" \
  "Task Manager"

run_test "404 page works" \
  "curl -s http://$WEB_IP/nonexistent" \
  "404"

echo ""
echo "=========================================="
echo "  Health Check Tests"
echo "=========================================="

run_test "Health endpoint accessible" \
  "curl -s http://$WEB_IP/health" \
  "ok"

run_test "Health returns JSON" \
  "curl -s http://$WEB_IP/health" \
  "task-manager-api"

echo ""
echo "=========================================="
echo "  API Tests (via Web Tier Proxy)"
echo "=========================================="

run_test "GET /api/tasks returns data" \
  "curl -s http://$WEB_IP/api/tasks" \
  "success"

run_test "GET /api/tasks returns array" \
  "curl -s http://$WEB_IP/api/tasks" \
  "data"

run_test "GET /api/tasks/1 returns single task" \
  "curl -s http://$WEB_IP/api/tasks/1" \
  "title"

run_test "POST /api/tasks creates task" \
  "curl -s -X POST http://$WEB_IP/api/tasks -H 'Content-Type: application/json' -d '{\"title\":\"E2E Test\"}'" \
  "success"

run_test "GET non-existent task returns 404" \
  "curl -s http://$WEB_IP/api/tasks/9999" \
  "not found"

echo ""
echo "=========================================="
echo "  Performance Tests"
echo "=========================================="

# Measure response time
response_time=$(curl -s -w "%{time_total}" -o /dev/null http://$WEB_IP/api/tasks)
echo -n "[$(($test_count + 1))] API response time < 2 seconds... "
((test_count++))

if (( $(echo "$response_time < 2.0" | bc -l) )); then
  echo -e "${GREEN}✓ PASS${NC} (${response_time}s)"
  ((pass_count++))
else
  echo -e "${YELLOW}⚠ SLOW${NC} (${response_time}s)"
  ((fail_count++))
fi

echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo "Total Tests: $test_count"
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
  echo -e "${GREEN}All tests passed! ✓${NC}"
  echo ""
  echo "Your 3-tier architecture is working correctly!"
  echo ""
  echo "Access your application:"
  echo "  http://$WEB_IP/"
  exit 0
else
  echo -e "${RED}Some tests failed!${NC}"
  echo ""
  echo "Troubleshooting steps:"
  echo "1. Check if all VMs are running"
  echo "2. Check PM2 status on app VM"
  echo "3. Check Nginx logs on web VM"
  echo "4. Check PostgreSQL on database VM"
  exit 1
fi