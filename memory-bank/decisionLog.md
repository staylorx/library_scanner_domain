# Decision Log

This file records architectural and implementation decisions...

*
## Architectural Decisions

[2025-12-31 16:42:19] - **2025-12-31**: Separated ID registries for authors and books. Previously, there was a single global ID registry handling both author and book ID pairs. This could lead to potential conflicts if ID codes overlapped between authors and books. Created separate AbstractAuthorIdRegistryService and AbstractBookIdRegistryService interfaces, with corresponding implementations AuthorIdRegistryService and BookIdRegistryService. Updated all repositories, validation services, and usecases to use the appropriate registry. Removed the old combined AbstractIdRegistryService. All tests pass.

[2026-01-01 19:41:14] - 2026-01-01: Analyzed codebase for sync/async patterns per Clean Architecture principle. Confirmed that pure business rules (sorting, filtering) are synchronous, while external interactions (repositories, APIs, registries) are asynchronous. No refactoring needed as the codebase already complies.
[2026-01-17 17:38:42] - Added AuthorFilteringService and BookFilteringService providers to maintain Clean Architecture consistency. Filtering services now follow the same provider pattern as repositories, ensuring dependency inversion and proper abstraction layering.
[2026-01-17 17:40:31] - Extended provider setup to include all domain services with implementations: AuthorFilteringService, BookFilteringService, AuthorIdRegistryService, BookIdRegistryService, AuthorValidationService, and BookValidationService. This ensures consistent dependency injection and Clean Architecture compliance across all services.

[2026-01-17 19:40:55] - 2026-01-17 - Fixed update tag usecase bug: TagModel.toMap() was incorrectly mapping 'id': name instead of 'id': id, causing updates to create new records instead of updating existing ones. Changed to 'id': id to match other model implementations.

[2026-01-17 19:43:58] - 2026-01-17 - Fixed book integration test issues: Similar to tag issue, addBook and addTag methods were generating new IDs instead of using provided IDs, causing update operations to create duplicates. Fixed addBook and addTag to use provided IDs when available.

[2026-01-18 17:57:05] - Confirmed strict adherence to Clean Architecture principles: domain and data layers contain no state management or dependency injection frameworks. Riverpod is used exclusively in the presentation layer for provider definitions. Fpdart is used consistently across all layers for functional programming constructs (Either, TaskEither, etc.). Mocktail chosen over Mockito for testing due to alignment with project package preferences. No build_runner or code generation tools used, maintaining manual control over generated code. Unit of work pattern implemented with Sembast for transaction management and atomicity.
