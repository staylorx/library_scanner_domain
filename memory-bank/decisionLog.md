# Decision Log

This file records architectural and implementation decisions...

*
## Architectural Decisions

[2025-12-31 16:42:19] - **2025-12-31**: Separated ID registries for authors and books. Previously, there was a single global ID registry handling both author and book ID pairs. This could lead to potential conflicts if ID codes overlapped between authors and books. Created separate AbstractAuthorIdRegistryService and AbstractBookIdRegistryService interfaces, with corresponding implementations AuthorIdRegistryService and BookIdRegistryService. Updated all repositories, validation services, and usecases to use the appropriate registry. Removed the old combined AbstractIdRegistryService. All tests pass.

[2026-01-01 19:41:14] - 2026-01-01: Analyzed codebase for sync/async patterns per Clean Architecture principle. Confirmed that pure business rules (sorting, filtering) are synchronous, while external interactions (repositories, APIs, registries) are asynchronous. No refactoring needed as the codebase already complies.
[2026-01-17 17:38:42] - Added factory methods for AuthorFilteringService and BookFilteringService to LibraryFactory to maintain Clean Architecture consistency. Filtering services now follow the same factory pattern as repositories, ensuring dependency inversion and proper abstraction layering.
[2026-01-17 17:40:31] - Extended LibraryFactory to include factory methods for all domain services with implementations: AuthorFilteringService, BookFilteringService, AuthorIdRegistryService, BookIdRegistryService, AuthorValidationService, and BookValidationService. This ensures consistent dependency injection and Clean Architecture compliance across all services.
