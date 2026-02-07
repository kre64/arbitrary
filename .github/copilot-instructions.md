# Copilot Instructions

## Project Overview
This project contains a collection of arbitrary scripts and tools for various purposes. Your job is to assist in maintaining and improving these scripts while adhering to the established code style and architecture. Each script is designed to be simple, focused, operating system agnostic, and efficient for its specific task. When making changes, ensure that you understand the purpose of the script and the context in which it operates.

## Code Style
- Use Ruby standard conventions (snake_case for methods/variables)
- Keep the `frozen_string_literal: true` magic comment
- Use `ENV` for configuration values that should be externalized
- Command-line arguments via `ARGV` for time-sensitive parameters
- Include clear usage instructions in error messages
- Use helper methods for common tasks (e.g., time formatting, sleep intervals)
- Avoid unnecessary dependencies; prefer built-in libraries when possible
- Avoid writing verbose comments; code should be self-explanatory with clear method names
- The top of the file should include a brief overview of the script's purpose and any important details about its operation
- env.sample should be provided with example values and instructions for users to create their own .env file
- Use consistent logging format for all output, including timestamps and relevant information about the script's actions

## Testing
- Create tests for new scripts or significant changes to existing scripts
- Use a testing framework like RSpec for Ruby scripts
- Test edge cases and error handling to ensure robustness

## When Making Changes
- Keep it simple and focused on the specific task at hand
- Ensure that any new code adheres to the established code style and architecture
- Add or update tests to cover new functionality or changes
- Update documentation and usage instructions as needed
- Avoid DRY (Don't Repeat Yourself) principles by refactoring common code into helper methods or modules when appropriate

## Dependencies
- `dotenv` gem for loading `.env` configuration
- `rspec` gem for testing
- Avoid adding unnecessary dependencies; prefer built-in libraries when possible