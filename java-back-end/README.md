# Spring Boot REST API Demo

A simple REST API built with Spring Boot 3.2.2, demonstrating CRUD operations with an H2 in-memory database.

## Features

- RESTful API endpoints for user management
- Spring Data JPA with H2 in-memory database
- Bean validation with Jakarta Validation
- Exception handling
- Unit tests with MockMvc

## Prerequisites

- Java 17 or higher
- Maven 3.6+ (or use the included Maven wrapper)

## Getting Started

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

## API Endpoints

### Users

- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `GET /api/users/email/{email}` - Get user by email
- `POST /api/users` - Create a new user
- `PUT /api/users/{id}` - Update a user
- `DELETE /api/users/{id}` - Delete a user

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

# Run a specific test method
./mvnw test -Dtest=UserControllerTest#getAllUsers_ShouldReturnUserList
```

## Project Structure

```
src/
├── main/
│   ├── java/com/example/demo/
│   │   ├── controller/      # REST controllers
│   │   ├── model/           # Entity classes
│   │   ├── repository/      # JPA repositories
│   │   ├── service/         # Business logic
│   │   └── DemoApplication.java
│   └── resources/
│       └── application.properties
└── test/
    └── java/com/example/demo/
        └── controller/      # Controller tests
```

## Technologies Used

- Spring Boot 3.2.2
- Spring Data JPA
- Spring Web
- H2 Database
- Jakarta Validation
- JUnit 5
- Mockito
