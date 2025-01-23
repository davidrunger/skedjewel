# v0.0.14 - 2025-01-22
- Change deprecated `sleep(Number)` to `sleep(Time::Span)`.
- Change `sleep` padding from 100 ms to 1 ms.

# v0.0.11 - 2024-02-06
- Only log and exit once (#45)

# v0.0.10 - 2023-10-18

## Added
- Log PID and epoch time when exiting

# v0.0.9 - 2023-10-18

## Added
- Handle TERM signal (in addition to INT)
