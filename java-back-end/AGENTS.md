# Agent Guidelines for This Repository

This file provides coding agents with essential information about build commands, code style, and development practices.

## Project Type

**Spring Boot 3.2.2** REST API with Maven, Java 17, and H2 in-memory database.

## Build, Test, and Lint Commands

### Setup
```bash
# Maven will automatically download dependencies on first build
./mvnw clean install    # Download dependencies and build
```

### Build Commands
```bash
./mvnw clean            # Clean build artifacts
./mvnw compile          # Compile the project
./mvnw package          # Build JAR file (target/demo-0.0.1-SNAPSHOT.jar)
./mvnw spring-boot:run  # Run the application directly
java -jar target/demo-0.0.1-SNAPSHOT.jar  # Run the built JAR
```

### Testing
```bash
# Run all tests
./mvnw test

# Run a single test class
./mvnw test -Dtest=UserControllerTest

# Run a specific test method
./mvnw test -Dtest=UserControllerTest#getAllUsers_ShouldReturnUserList

# Run tests with coverage (using JaCoCo)
./mvnw test jacoco:report

# Skip tests during build
./mvnw package -DskipTests
```

### Linting and Formatting
```bash
# Format code with Maven plugins (if configured)
./mvnw spotless:apply   # Auto-format code (requires spotless plugin)
./mvnw spotless:check   # Check formatting

# Static analysis with Checkstyle (if configured)
./mvnw checkstyle:check

# Verify code quality
./mvnw verify
```

## Code Style Guidelines

### Import Organization (Java)
1. **Group imports** in the following order:
   - Java standard library imports (`java.*`)
   - Java extension imports (`javax.*`, `jakarta.*`)
   - Third-party library imports (Spring, Hibernate, etc.)
   - Internal project imports (`com.example.demo.*`)
2. **Sort alphabetically** within each group
3. **Separate groups** with blank lines
4. **Avoid wildcard imports** (`import com.example.*`) - use explicit imports

```java
// Example (Java/Spring Boot)
import java.util.List;
import java.util.Optional;

import jakarta.persistence.Entity;
import jakarta.validation.constraints.NotBlank;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.model.User;
import com.example.demo.repository.UserRepository;
```

### Formatting
- **Indentation**: 4 spaces (no tabs) for Java
- **Line length**: Max 120 characters
- **Braces**: Opening brace on same line (K&R style)
- **One statement per line**: Avoid multiple statements on one line
- **Blank lines**: Use to separate logical sections within methods

### Type Annotations and Validation
- **Use Jakarta Bean Validation**: `@NotBlank`, `@Email`, `@Size`, etc.
- **Explicit types**: Always declare types for variables and return values
- **Generics**: Use proper generic types for collections (`List<User>`, not raw `List`)
- **Optional**: Use `Optional<T>` for return types that may be null

```java
// Good
@NotBlank(message = "Email is required")
@Email(message = "Email should be valid")
private String email;

public Optional<User> getUserById(Long id) {
    return userRepository.findById(id);
}

// Avoid
private String email;  // No validation

public User getUserById(Long id) {  // May return null
    return userRepository.findById(id).orElse(null);
}
```

### Naming Conventions
- **Packages**: lowercase, separated by dots (`com.example.demo.service`)
- **Classes/Interfaces**: PascalCase (`UserService`, `UserRepository`)
- **Methods/Variables**: camelCase (`getUserById`, `userList`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`, `API_BASE_URL`)
- **Entity tables**: Plural, lowercase with underscores (`@Table(name = "users")`)
- **Boolean methods**: Prefix with `is`, `has`, `can` (`isActive`, `hasPermission`)

### Error Handling
- **Use appropriate exceptions**: `IllegalArgumentException` for validation, custom exceptions for domain logic
- **Fail fast**: Validate inputs at service layer before processing
- **Provide context**: Include relevant details in exception messages
- **Let Spring handle exceptions**: Use `@ControllerAdvice` for global exception handling
- **Never swallow exceptions**: Always log or rethrow

```java
// Good
public User createUser(User user) {
    if (userRepository.existsByEmail(user.getEmail())) {
        throw new IllegalArgumentException("User with email " + user.getEmail() + " already exists");
    }
    return userRepository.save(user);
}

// Controller error handling
@PostMapping
public ResponseEntity<?> createUser(@Valid @RequestBody User user) {
    try {
        User createdUser = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    } catch (IllegalArgumentException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(e.getMessage()));
    }
}
```

### Comments and Documentation
- **Javadoc for public APIs**: All public classes, methods, and interfaces
- **Explain why, not what**: Code should be self-explanatory
- **Keep comments updated**: Outdated comments are worse than no comments
- **TODO comments**: Include issue number or context (`// TODO: Implement caching (#123)`)

```java
/**
 * Creates a new user in the system.
 *
 * @param user the user to create
 * @return the created user with generated ID
 * @throws IllegalArgumentException if email already exists
 */
public User createUser(User user) {
    // implementation
}
```

## Testing Guidelines
- **Test files**: Place next to source files or in `__tests__` directory
- **Naming**: `*.spec.ts`, `*.test.ts`, `test_*.py`, `*_spec.rb`
- **Coverage**: Aim for 80%+ coverage on business logic
- **Test structure**: Arrange-Act-Assert pattern
- **Mock external dependencies**: Network calls, databases, file system
- **Descriptive test names**: `should return user when id exists`

## Git Commit Guidelines
- **Format**: `type(scope): description`
- **Types**: feat, fix, docs, style, refactor, test, chore
- **Description**: Imperative mood, lowercase, no period
- **Example**: `feat(auth): add JWT token validation`

## Additional Notes
- Run tests before committing code
- Ensure all linting and type checks pass
- Update tests when modifying functionality
- Keep functions small and focused (max 50 lines)
- Prefer composition over inheritance
- Use dependency injection for testability
