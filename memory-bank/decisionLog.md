# Decision Log

This file records architectural and implementation decisions...

*
## Architectural Decisions

[2025-12-31 16:42:19] - **2025-12-31**: Separated ID registries for authors and books. Previously, there was a single global ID registry handling both author and book ID pairs. This could lead to potential conflicts if ID codes overlapped between authors and books. Created separate AbstractAuthorIdRegistryService and AbstractBookIdRegistryService interfaces, with corresponding implementations AuthorIdRegistryService and BookIdRegistryService. Updated all repositories, validation services, and usecases to use the appropriate registry. Removed the old combined AbstractIdRegistryService. All tests pass.
