# Demo User Manager


## Getting Started

```
./run-java-with-users.sh
```

### Build and Run

```bash
# Build the project
./mvnw clean package

# Run the application
./mvnw spring-boot:run

# Or run the JAR directly
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

The application will start on `http://localhost:8080`.

### H2 Console

Access the H2 database console at `http://localhost:8080/h2-console`:
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (leave empty)

x

### Example Request

```bash
# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'

# Get all users
curl http://localhost:8080/api/users

# Get user by ID
curl http://localhost:8080/api/users/1
```

## Testing

```bash
# Run all tests
./mvnw test

# Run a specific test class
./mvnw test -Dtest=UserControllerTest

```
