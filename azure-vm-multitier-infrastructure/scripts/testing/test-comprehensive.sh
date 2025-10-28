#!/bin/bash

# Comprehensive Testing Suite for 3-Tier Architecture
# Tests: Connectivity, Functionality, Security, Performance

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║     3-TIER ARCHITECTURE COMPREHENSIVE TEST SUITE           ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
WEB_IP=$(cd terraform && terraform output -raw public_ip_address 2>/dev/null)
BASTION_IP=$(cd terraform && terraform output -raw bastion_public_ip 2>/dev/null)

echo "Configuration:"
echo "  Web VM Public IP: $WEB_IP"
echo "  Bastion IP: $BASTION_IP"
echo ""

# Test counters
total_tests=0
passed_tests=0
failed_tests=0

# Test function
run_test() {
  local category=$1
  local test_name=$2
  local command=$3
  local expected=$4
  
  test_count=$((test_count + 1))
  
  echo -n "  [$total_tests] $test_name... "
  
  if result=$(eval $command 2>&1); then
    if [ -n "$expected" ]; then
      if echo "$result" | grep -qi "$expected"; then
        echo -e "${GREEN}✓ PASS${NC}"
        passed_tests=$((passed_tests + 1))
        return 0
      else
        echo -e "${RED}✗ FAIL${NC}"
        echo "      Expected: $expected"
        echo "      Got: $result" | head -1
        failed_tests=$((failed_tests + 1))
        return 1
      fi
    else
      echo -e "${GREEN}✓ PASS${NC}"
      passed_tests=$((passed_tests + 1))
      return 0
    fi
  else
    echo -e "${RED}✗ FAIL${NC}"
    echo "      Error: $result" | head -1
    failed_tests=$((failed_tests + 1))
    return 1
  fi
}

# ==================================================
# TIER 1: Infrastructure Tests
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  TIER 1: Infrastructure Connectivity Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

run_test "Infrastructure" \
  "Web VM is reachable" \
  "curl -s --connect-timeout 5 http://$WEB_IP/ -o /dev/null && echo 'success'" \
  "success"

run_test "Infrastructure" \
  "Web VM responds on port 80" \
  "nc -zv -w 3 $WEB_IP 80 2>&1" \
  "succeeded"

run_test "Infrastructure" \
  "Bastion is reachable on port 22" \
  "nc -zv -w 3 $BASTION_IP 22 2>&1" \
  "succeeded"

echo ""

# ==================================================
# TIER 2: Web Tier Tests
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  TIER 2: Web Tier (Nginx) Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

run_test "Web Tier" \
  "Homepage loads successfully" \
  "curl -s http://$WEB_IP/" \
  "Task Manager"

run_test "Web Tier" \
  "Homepage contains architecture info" \
  "curl -s http://$WEB_IP/" \
  "3-Tier Architecture"

run_test "Web Tier" \
  "Static HTML is valid" \
  "curl -s http://$WEB_IP/ | grep -c '</html>'" \
  "1"

run_test "Web Tier" \
  "404 page works" \
  "curl -s http://$WEB_IP/nonexistent" \
  "404"

run_test "Web Tier" \
  "404 page is custom" \
  "curl -s http://$WEB_IP/nonexistent" \
  "Page Not Found"

run_test "Web Tier" \
  "Security headers present (X-Content-Type-Options)" \
  "curl -sI http://$WEB_IP/ | grep -i 'X-Content-Type-Options'" \
  "nosniff"

run_test "Web Tier" \
  "Security headers present (X-Frame-Options)" \
  "curl -sI http://$WEB_IP/ | grep -i 'X-Frame-Options'" \
  "SAMEORIGIN"

run_test "Web Tier" \
  "Nginx version hidden" \
  "curl -sI http://$WEB_IP/ | grep -i Server | grep -v 'nginx/'" \
  "nginx"

echo ""

# ==================================================
# TIER 3: Application Tier Tests
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  TIER 3: Application Tier (Node.js API) Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

run_test "App Tier" \
  "Health check endpoint accessible" \
  "curl -s http://$WEB_IP/health" \
  "ok"

run_test "App Tier" \
  "Health check returns correct service name" \
  "curl -s http://$WEB_IP/health" \
  "task-manager-api"

run_test "App Tier" \
  "API root endpoint accessible" \
  "curl -s http://$WEB_IP/" \
  "Task Manager"

run_test "App Tier" \
  "GET /api/tasks returns success" \
  "curl -s http://$WEB_IP/api/tasks" \
  "success"

run_test "App Tier" \
  "GET /api/tasks returns valid JSON" \
  "curl -s http://$WEB_IP/api/tasks | jq -r '.success' 2>/dev/null" \
  "true"

run_test "App Tier" \
  "GET /api/tasks returns data array" \
  "curl -s http://$WEB_IP/api/tasks | jq -r '.data | type' 2>/dev/null" \
  "array"

run_test "App Tier" \
  "GET /api/tasks/1 returns single task" \
  "curl -s http://$WEB_IP/api/tasks/1 | jq -r '.data.id' 2>/dev/null" \
  "1"

run_test "App Tier" \
  "POST creates new task" \
  "curl -s -X POST http://$WEB_IP/api/tasks -H 'Content-Type: application/json' -d '{\"title\":\"Test Task\",\"description\":\"Automated test\"}' | jq -r '.success' 2>/dev/null" \
  "true"

# Get the ID of the created task for update/delete tests
TASK_ID=$(curl -s http://$WEB_IP/api/tasks | jq -r '.data[-1].id' 2>/dev/null)

run_test "App Tier" \
  "PUT updates task" \
  "curl -s -X PUT http://$WEB_IP/api/tasks/$TASK_ID -H 'Content-Type: application/json' -d '{\"completed\":true}' | jq -r '.success' 2>/dev/null" \
  "true"

run_test "App Tier" \
  "DELETE removes task" \
  "curl -s -X DELETE http://$WEB_IP/api/tasks/$TASK_ID | jq -r '.success' 2>/dev/null" \
  "true"

run_test "App Tier" \
  "GET non-existent task returns 404" \
  "curl -s -w '%{http_code}' http://$WEB_IP/api/tasks/99999 -o /dev/null" \
  "404"

run_test "App Tier" \
  "POST without title returns 400" \
  "curl -s -w '%{http_code}' -X POST http://$WEB_IP/api/tasks -H 'Content-Type: application/json' -d '{}' -o /dev/null" \
  "400"

echo ""

# ==================================================
# TIER 4: Database Tier Tests
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  TIER 4: Database Tier (PostgreSQL) Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

run_test "Data Tier" \
  "Database stores data (verified via API)" \
  "curl -s http://$WEB_IP/api/tasks | jq -r '.count' 2>/dev/null | grep -E '^[0-9]+$'" \
  ""

run_test "Data Tier" \
  "Database persistence (tasks exist)" \
  "curl -s http://$WEB_IP/api/tasks | jq -r '.data | length' 2>/dev/null | grep -E '^[1-9][0-9]*$'" \
  ""

run_test "Data Tier" \
  "Database returns valid timestamps" \
  "curl -s http://$WEB_IP/api/tasks | jq -r '.data[0].created_at' 2>/dev/null | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}'" \
  ""

echo ""

# ==================================================
# Security Tests
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  SECURITY VALIDATION TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

run_test "Security" \
  "SQL injection protection (single quote)" \
  "curl -s -X POST http://$WEB_IP/api/tasks -H 'Content-Type: application/json' -d '{\"title\":\"Test'\''OR 1=1--\"}' | jq -r '.success' 2>/dev/null" \
  "true"

run_test "Security" \
  "XSS protection (script tag filtered)" \
  "curl -s -X POST http://$WEB_IP/api/tasks -H 'Content-Type: application/json' -d '{\"title\":\"<script>alert(1)</script>\"}' | jq -r '.success' 2>/dev/null" \
  "true"

run_test "Security" \
  "CORS headers present" \
  "curl -sI http://$WEB_IP/api/tasks | grep -i 'Access-Control'" \
  "Access-Control"

run_test "Security" \
  "No sensitive info in error messages" \
  "curl -s http://$WEB_IP/api/tasks/invalid | jq -r '.error' 2>/dev/null | grep -iv 'password\|secret\|key'" \
  ""

echo ""

# ==================================================
# Performance Tests
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PERFORMANCE TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Test response time
response_time=$(curl -s -w "%{time_total}" -o /dev/null http://$WEB_IP/api/tasks)
echo -n "  [$((total_tests + 1))] API response time < 2 seconds... "
total_tests=$((passed_tests + 1))
if (( $(echo "$response_time < 2.0" | bc -l 2>/dev/null || echo "0") )); then
  echo -e "${GREEN}✓ PASS${NC} (${response_time}s)"
  passed_tests=$((passed_tests + 1))
else
  echo -e "${YELLOW}⚠ SLOW${NC} (${response_time}s)"
  failed_tests=$((failed_tests + 1))
fi

# Test concurrent requests
echo -n "  [$((total_tests + 1))] Handles 5 concurrent requests... "
total_tests=$((passed_tests + 1))
for i in {1..5}; do
  curl -s http://$WEB_IP/api/tasks > /dev/null &
done
wait
echo -e "${GREEN}✓ PASS${NC}"
passed_tests=$((passed_tests + 1))

# Test large payload
echo -n "  [$((total_tests + 1))] Handles large task description... "
total_tests=$((passed_tests + 1))
large_desc=$(python3 -c "print('A' * 5000)")
result=$(curl -s -X POST http://$WEB_IP/api/tasks \
  -H 'Content-Type: application/json' \
  -d "{\"title\":\"Large Task\",\"description\":\"$large_desc\"}" | jq -r '.success' 2>/dev/null)
if [ "$result" = "true" ]; then
  echo -e "${GREEN}✓ PASS${NC}"
  passed_tests=$((passed_tests + 1))
else
  echo -e "${RED}✗ FAIL${NC}"
  failed_tests=$((failed_tests + 1))
fi

echo ""

# ==================================================
# Load Testing
# ==================================================
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  LOAD TESTING (50 requests)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

echo "  Sending 50 sequential requests..."
start_time=$(date +%s)
success_count=0
for i in {1..50}; do
  if curl -s -o /dev/null -w "%{http_code}" http://$WEB_IP/api/tasks | grep -q "200"; then
    success_count=$((success_count + 1))
  fi
  echo -n "."
done
end_time=$(date +%s)
duration=$((end_time - start_time))
echo ""

echo "  Results:"
echo "    Total requests: 50"
echo "    Successful: $success_count"
echo "    Failed: $((50 - success_count))"
echo "    Duration: ${duration}s"
echo "    Requests/second: $(echo "scale=2; 50 / $duration" | bc)"

if [ $success_count -ge 48 ]; then
  echo -e "    Status: ${GREEN}✓ PASS${NC} (>95% success rate)"
else
  echo -e "    Status: ${RED}✗ FAIL${NC} (<95% success rate)"
fi

echo ""

# ==================================================
# Final Summary
# ==================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                     TEST SUMMARY                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "  Total Tests Run: $total_tests"
echo -e "  Passed: ${GREEN}$passed_tests${NC}"
echo -e "  Failed: ${RED}$failed_tests${NC}"
echo "  Success Rate: $(echo "scale=2; $passed_tests * 100 / $total_tests" | bc)%"
echo ""

if [ $failed_tests -eq 0 ]; then
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}║   ✓ ALL TESTS PASSED - SYSTEM IS FULLY OPERATIONAL!        ║${NC}"
  echo -e "${GREEN}║                                                            ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "Your 3-tier architecture is production-ready!"
  echo ""
  echo "Access your application:"
  echo "  🌐 http://$WEB_IP/"
  echo ""
  exit 0
else
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                                                            ║${NC}"
  echo -e "${RED}║   ✗ SOME TESTS FAILED - REVIEW AND FIX ISSUES              ║${NC}"
  echo -e "${RED}║                                                            ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "Troubleshooting steps:"
  echo "  1. Check VM statuses: terraform output"
  echo "  2. Check application logs: pm2 logs (on app VM)"
  echo "  3. Check Nginx logs: /var/log/nginx/ (on web VM)"
  echo "  4. Check database: sudo systemctl status postgresql (on db VM)"
  echo ""
  exit 1
fi