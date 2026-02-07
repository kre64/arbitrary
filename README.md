# Arbitrary Scripts

A collection of focused automation scripts for various tasks.

## Prerequisites

**C scripts:**
- GCC or Clang compiler
- Platform-specific dependencies:
  - macOS: Xcode Command Line Tools
  - Linux: libx11-dev, libxtst-dev
  - Windows: MinGW or MSVC

**Ruby scripts:**
- Ruby 2.7+ installed
- Bundler gem manager

**Go scripts:**
- Go 1.21+ installed

## Setup

### C

Install platform dependencies:
```bash
# macOS
xcode-select --install

# Linux
sudo apt-get install libx11-dev libxtst-dev

# Windows
# Use MinGW or MSVC
```

Build with `make` in the script directory.

### Ruby

1. Install Bundler:
   ```bash
   gem install bundler
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

### Go

1. Install dependencies:
   ```bash
   go mod download
   ```

2. Build:
   ```bash
   go build
   ```
