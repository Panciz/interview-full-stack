#!/bin/bash

# Script to generate random users using the localhost API
# Usage: ./generate-users.sh [number_of_users]

# Configuration
API_URL="http://localhost:8080/api/users"
NUM_USERS=${1:-10}  # Default to 10 users if not specified

# Arrays for generating random data
FIRST_NAMES=("John" "Jane" "Michael" "Sarah" "David" "Emily" "Robert" "Lisa" "James" "Mary" 
             "William" "Patricia" "Richard" "Jennifer" "Charles" "Linda" "Joseph" "Elizabeth" 
             "Thomas" "Barbara" "Christopher" "Susan" "Daniel" "Jessica" "Matthew" "Karen" 
             "Anthony" "Nancy" "Mark" "Betty" "Donald" "Helen" "Steven" "Sandra" "Paul" "Donna")

LAST_NAMES=("Smith" "Johnson" "Williams" "Brown" "Jones" "Garcia" "Miller" "Davis" "Rodriguez" 
            "Martinez" "Hernandez" "Lopez" "Gonzalez" "Wilson" "Anderson" "Thomas" "Taylor" 
            "Moore" "Jackson" "Martin" "Lee" "Perez" "Thompson" "White" "Harris" "Sanchez" 
            "Clark" "Ramirez" "Lewis" "Robinson" "Walker" "Young" "Allen" "King" "Wright")

DOMAINS=("gmail.com" "yahoo.com" "outlook.com" "hotmail.com" "example.com" "mail.com")

# Function to generate a random element from an array
random_element() {
    local array=("$@")
    local index=$((RANDOM % ${#array[@]}))
    echo "${array[$index]}"
}

# Function to generate a random phone number
generate_phone() {
    echo "+1-$(($RANDOM % 900 + 100))-$(($RANDOM % 900 + 100))-$(($RANDOM % 9000 + 1000))"
}

# Function to generate a random username
generate_username() {
    local first=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local last=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    local num=$((RANDOM % 100))
    echo "${first}${last}${num}"
}

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if the API is reachable
echo -e "${YELLOW}Checking if API is reachable at ${API_URL}...${NC}"
if ! curl -s -o /dev/null -w "%{http_code}" "${API_URL}" | grep -q "200\|400\|405"; then
    echo -e "${RED}Error: Cannot reach API at ${API_URL}${NC}"
    echo -e "${YELLOW}Make sure the Spring Boot application is running on port 8080${NC}"
    exit 1
fi

echo -e "${GREEN}API is reachable!${NC}\n"

# Generate and create users
echo -e "${YELLOW}Generating ${NUM_USERS} random users...${NC}\n"

SUCCESS_COUNT=0
FAIL_COUNT=0

for i in $(seq 1 "$NUM_USERS"); do
    # Generate random user data
    FIRST_NAME=$(random_element "${FIRST_NAMES[@]}")
    LAST_NAME=$(random_element "${LAST_NAMES[@]}")
    FULL_NAME="${FIRST_NAME} ${LAST_NAME}"
    
    USERNAME=$(generate_username "$FIRST_NAME" "$LAST_NAME")
    EMAIL="${USERNAME}@$(random_element "${DOMAINS[@]}")"
    PHONE=$(generate_phone)
    
    # Create JSON payload
    JSON_PAYLOAD=$(cat <<EOF
{
  "name": "${FULL_NAME}",
  "email": "${EMAIL}",
  "username": "${USERNAME}",
  "phone": "${PHONE}"
}
EOF
)
    
    echo -e "${YELLOW}Creating user ${i}/${NUM_USERS}: ${FULL_NAME}${NC}"
    
    # Make POST request
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "${JSON_PAYLOAD}" \
        "${API_URL}")
    
    # Extract HTTP status code (last line)
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    # Check response
    if [ "$HTTP_CODE" -eq 201 ]; then
        echo -e "${GREEN}✓ Success: ${FULL_NAME} (${EMAIL})${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗ Failed: ${FULL_NAME} - HTTP ${HTTP_CODE}${NC}"
        echo -e "${RED}  Response: ${BODY}${NC}"
        ((FAIL_COUNT++))
    fi
    
    echo ""
    
    # Small delay to avoid overwhelming the API
    sleep 0.1
done

# Summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}Successfully created: ${SUCCESS_COUNT} users${NC}"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "${RED}Failed: ${FAIL_COUNT} users${NC}"
fi
echo -e "${YELLOW}========================================${NC}"

# Show all users
echo -e "\n${YELLOW}Fetching all users from API...${NC}\n"
curl -s -X GET "${API_URL}" | python3 -m json.tool 2>/dev/null || curl -s -X GET "${API_URL}"
