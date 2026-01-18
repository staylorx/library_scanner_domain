# System Patterns

This file documents recurring architectural and implementation patterns used throughout the library_scanner_domain project.

## Architectural Patterns

### Clean Architecture Layers
- **Domain Layer** (`lib/src/domain/`): Contains pure business logic with entities, value objects, repository interfaces, service interfaces, and use cases. No external dependencies.
- **Data Layer** (`lib/src/data/`): Contains repository implementations, data sources, external service integrations, and data models. Handles persistence and external APIs.
- **Presentation Layer** (`lib/` root providers): Contains Riverpod providers for state management and dependency injection.

### Repository Pattern
- Repository interfaces defined in domain layer with Either<Failure, T> return types.
- Implementations in data layer using TaskEither for async operations.
- Dependency injection via constructor parameters in use cases.

### Unit of Work Pattern
- Implemented with Sembast for database transactions.
- Ensures atomicity of multiple database operations.
- Used in repository implementations for complex operations involving multiple entities.

## Functional Programming Patterns

### Either/Result Handling
- All repository methods return `Either<Failure, T>`.
- Use cases handle Either with `fold` or `match` for error/success branching.
- Failure types defined in `lib/src/utils/failure.dart`.

### Async Operations
- `TaskEither` used for async operations that may fail.
- `TaskEither.tryCatch` wraps exceptions from external services (HTTP, database).
- No try-catch blocks; exceptions converted to Failures.

### Option Types
- `Option<T>` used for nullable values where appropriate.
- Avoids null checks in favor of functional handling.

## Dependency Injection Patterns

### Provider Pattern
- Riverpod `Provider` used for all dependency injection.
- External providers throw `UnimplementedError` and must be overridden by consumers.
- Internal providers automatically wire domain layer once external dependencies are provided.
- Providers defined in `lib/providers.dart`.

## ID Management Patterns

### ID Registry Pattern
- Separate registries for authors and books to prevent ID conflicts.
- UUID-based IDs for tags, author IDs, and book IDs.
- Registry services handle ID generation and validation.

### Projection Handles
- Used in repository implementations for efficient data access.
- Not stored in domain entities; kept in repository layer.

## Validation Patterns

### Validation Services
- Separate validation services for books and authors.
- Validate business rules and data integrity.
- Return Either<Failure, Unit> for validation results.

## Testing Patterns

### Mocktail for Mocks
- Used instead of Mockito for test doubles.
- Mocks created for external dependencies in unit tests.
- Integration tests use real implementations where possible.

### Test Organization
- Unit tests in `test/unit/` for isolated components.
- Integration tests in `test/integration/` for end-to-end flows.
- Benchmark tests in `test/benchmark/` for performance validation.

## Code Organization Patterns

### File Naming
- Interfaces prefixed with abstract (e.g., `AbstractBookRepository`).
- Implementations suffixed with `Impl` (e.g., `BookRepositoryImpl`).
- Use cases named as `VerbNounUsecase` (e.g., `AddBookUsecase`).

### Import Organization
- Relative imports within the package.
- No unused imports; enforced by lints.

### Line Endings
- All files use LF line endings, never CRLF.
- Enforced across Windows development environment.