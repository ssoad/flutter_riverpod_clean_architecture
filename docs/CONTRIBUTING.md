# Contributing to Flutter Riverpod Clean Architecture

Thank you for your interest in contributing to the Flutter Riverpod Clean Architecture project! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to foster an inclusive and respectful community.

## How to Contribute

### Reporting Bugs

If you find a bug in the project, please create an issue on our GitHub repository with the following information:

- A clear, descriptive title
- Detailed steps to reproduce the bug
- Expected behavior and what actually happened
- Screenshots if applicable
- Environment details (Flutter version, device/emulator info, etc.)

### Suggesting Features

We welcome feature suggestions! Please create an issue with:

- A clear description of the feature
- The rationale for adding this feature
- If possible, outline how the feature might be implemented
- Examples of how the feature would be used

### Pull Requests

We actively welcome your pull requests:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

#### For pull requests, please ensure:

- Your code follows the project's style guidelines
- You've added tests for new functionality
- Your commits are well-formatted and descriptive
- You've updated documentation as needed
- The PR description clearly describes the changes

## Development Setup

1. Fork and clone the repository
2. Install Flutter SDK (version 3.7.0 or higher)
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run tests to ensure everything is set up correctly:
   ```bash
   flutter test
   ```

## Style Guidelines

- Follow the [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable and function names
- Document public APIs
- Keep functions small and focused
- Format code using `flutter format`

## Testing

All new features and bug fixes should include tests:

```bash
# Run all tests
flutter test

# Run tests for a specific feature
flutter test test/features/auth
```

## Documentation

Update documentation when making changes:

- Update relevant markdown files in the `docs` directory
- Include inline comments for complex code
- Update example code if relevant

## Versioning

We use [SemVer](http://semver.org/) for versioning:

- MAJOR version for incompatible API changes
- MINOR version for backward-compatible functionality additions
- PATCH version for backward-compatible bug fixes

## License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).

## Questions?

Feel free to contact the project maintainers if you have any questions or need help.
