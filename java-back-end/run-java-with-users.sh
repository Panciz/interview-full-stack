#!/bin/bash

# Script to run Java Spring Boot application and generate users
# Usage: ./run-java-with-users.sh

# Configuration
NUM_USERS=10
API_URL="http://localhost:8080/api/users"
MAX_WAIT=60  # Maximum seconds to wait for API to be ready

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Spring Boot Startup & User Generator${NC}"
echo -e "${BLUE}========================================${NC}\n"



# Check if Maven wrapper exists
if [ ! -f "./mvnw" ]; then
    echo -e "${RED}Error: Maven wrapper (mvnw) not found${NC}"
    exit 1
fi

# Clean and build the application
echo -e "${YELLOW}Building Spring Boot application...${NC}"
./mvnw clean package -DskipTests
if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed! Please check the errors above.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Build successful!${NC}\n"

# Check if application is already running
if curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep -q "200\|400\|405"; then
    echo -e "${YELLOW}Application is already running on port 8080${NC}"
    echo -e "${YELLOW}Skipping startup...${NC}\n"
else
    # Start the Spring Boot application in the background
    echo -e "${YELLOW}Starting Spring Boot application...${NC}"
    ./mvnw spring-boot:run > app.log 2>&1 &
    APP_PID=$!
    
    echo -e "${GREEN}Application started with PID: $APP_PID${NC}"
    echo -e "${YELLOW}Waiting for application to be ready...${NC}"
    
    # Wait for the application to be ready
    COUNTER=0
    while [ $COUNTER -lt $MAX_WAIT ]; do
        if curl -s -o /dev/null -w "%{http_code}" "$API_URL" | grep -q "200\|400\|405"; then
            echo -e "${GREEN}✓ Application is ready!${NC}\n"
            break
        fi
        
        echo -n "."
        sleep 1
        COUNTER=$((COUNTER + 1))
        
        # Check if the process is still running
        if ! kill -0 $APP_PID 2>/dev/null; then
            echo -e "\n${RED}Application process died. Check app.log for errors:${NC}"
            tail -n 20 app.log
            exit 1
        fi
    done
    
    if [ $COUNTER -eq $MAX_WAIT ]; then
        echo -e "\n${RED}Timeout waiting for application to start${NC}"
        echo -e "${YELLOW}Last 20 lines from app.log:${NC}"
        tail -n 20 app.log
        kill $APP_PID 2>/dev/null
        exit 1
    fi
fi

# Wait a bit more to ensure everything is fully initialized
sleep 2

# Run the user generator script
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Generating Users${NC}"
echo -e "${BLUE}========================================${NC}\n"

if [ ! -f "./generate-users.sh" ]; then
    echo -e "${RED}Error: generate-users.sh script not found${NC}"
    exit 1
fi

chmod +x ./generate-users.sh
./generate-users.sh $NUM_USERS

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if we started the app (APP_PID is set)
if [ -n "$APP_PID" ]; then
    echo -e "${YELLOW}Spring Boot application is running with PID: $APP_PID${NC}"
    echo -e "${YELLOW}API URL: ${API_URL}${NC}"
    echo -e "${YELLOW}Logs: ${JAVA_DIR}/app.log${NC}\n"
    
    echo -e "${YELLOW}To view logs in real-time:${NC}"
    echo -e "  tail -f ${JAVA_DIR}/app.log\n"
    
    echo -e "${YELLOW}To stop the application:${NC}"
    echo -e "  kill $APP_PID${NC}"
    echo -e "  or press Ctrl+C if running in foreground\n"
    
    # Save PID to file for easy cleanup
    echo $APP_PID > app.pid
    echo -e "${GREEN}PID saved to ${JAVA_DIR}/app.pid${NC}\n"
    
    # Ask user if they want to keep the app running
    echo -e "${YELLOW}Press Enter to stop the application, or Ctrl+C to keep it running...${NC}"
    read -r
    
    echo -e "${YELLOW}Stopping Spring Boot application (PID: $APP_PID)...${NC}"
    kill $APP_PID 2>/dev/null
    
    # Wait for the process to terminate
    sleep 2
    if kill -0 $APP_PID 2>/dev/null; then
        echo -e "${YELLOW}Force killing application...${NC}"
        kill -9 $APP_PID 2>/dev/null
    fi
    
    rm -f app.pid
    echo -e "${GREEN}Application stopped${NC}"
else
    echo -e "${GREEN}Users generated successfully!${NC}"
    echo -e "${YELLOW}Application is still running. Stop it manually if needed.${NC}"
fi
