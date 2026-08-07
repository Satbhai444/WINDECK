# Contributing to WinDeck

## Development Workflow

1. Create a feature branch from `master`
2. Make your changes
3. Test on both PC and Mobile
4. Commit with descriptive messages
5. Push and create a Pull Request

## Commit Message Format

Use the following format:
```
<type>: <description>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: UI/styling changes
- refactor: Code refactoring
- build: Build system changes
- chore: Maintenance tasks
```

Examples:
```
feat: add QR code pairing for instant connection
fix: resolve OneDrive file locking during build
docs: add API reference documentation
```

## Code Style

### JavaScript (Server)
- Use `const`/`let`, never `var`
- Use ES6+ features (arrow functions, template literals)
- Add JSDoc comments for public functions
- Handle errors with try/catch, never ignore silently

### Dart (Mobile)
- Follow official Dart style guide
- Use Provider for state management
- Keep widgets small and reusable
- Use named parameters for clarity

## Testing Checklist

Before submitting:
- [ ] PC server starts without errors
- [ ] Mobile app builds and runs
- [ ] Connection and authentication works
- [ ] All existing features still work
- [ ] Version numbers are synchronized

## File Organization

- Server modules go in `server/modules/`
- Flutter screens go in `android/lib/screens/`
- Flutter services go in `android/lib/services/`
- Flutter models go in `android/lib/models/`
- Flutter widgets go in `android/lib/widgets/`
- Documentation goes in `docs/`
