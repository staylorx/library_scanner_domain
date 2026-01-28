# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test/Lint Commands

```bash
dart pub get                          # Install dependencies
dart test                             # Run all tests
dart test --name "pattern"            # Run tests matching pattern
dart test test/unit/                  # Run unit tests only
dart test test/integration/           # Run integration tests
dart format .                         # Format code (auto-runs on commit via husky)
dart analyze                          # Run static analysis
dart doc .                            # Generate API documentation
```

## Architecture

This is a **domain layer package** for a library scanner app implementing Clean Architecture with functional programming (fpdart).

### Layer Structure

```
lib/src/
├── domain/           # Pure business logic, no external dependencies
│   ├── entities/     # Book, Author, Tag, Library
│   ├── repositories/ # Interface contracts (Either-based)
│   ├── usecases/     # 31 business logic usecases (TaskEither-based)
│   └── ports/        # FileLoader/FileWriter interfaces
└── data/             # Implementations
    ├── sembast/      # Sembast database (datasources, unit_of_work)
    ├── file/         # YAML file I/O
    └── id_registry/  # Author/Book ID management
```

### Entry Points

- **LibraryDomainFactory.create()** - Main factory that wires all dependencies
- **LibraryDomain** - Facade providing access to all usecases

## Code Conventions

### Functional Programming (fpdart)

- All async operations return `TaskEither<Failure, T>`
- Repositories return `Either<Failure, T>` for sync operations
- Use `TaskEither.tryCatch()` instead of try-catch blocks
- Chain with `.map()`, `.flatMap()`, `.fold()`
- Return `Unit` instead of `void` where appropriate

### Naming

- Repository interfaces: `AbstractXxxRepository`
- Implementations: `XxxRepositoryImpl`
- Usecases: `VerbNounUsecase` (e.g., `AddBookUsecase`)

### Testing

- Use **mocktail** for mocks (NOT Mockito)
- Call `.run()` on TaskEither in tests to unwrap to Either
- Unit tests in `test/unit/`, integration tests in `test/integration/`

### Style

- All public methods use named parameters
- LF line endings only (no CRLF)
- No code generation tools (no build_runner)

## Key Dependencies

- **fpdart** - Functional programming (Either, TaskEither)
- **sembast** - NoSQL local database
- **yaml/yaml_writer** - YAML parsing/writing
- **equatable** - Value equality for entities
