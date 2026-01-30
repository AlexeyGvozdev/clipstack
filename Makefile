# Makefile for ClipStack

.PHONY: help build clean test lint format run install

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the project
	@echo "Building ClipStack..."
	swift build

clean: ## Clean build artifacts
	@echo "Cleaning..."
	swift package clean
	rm -rf .build
	rm -rf DerivedData

test: ## Run tests
	@echo "Running tests..."
	swift test

lint: ## Run SwiftLint
	@echo "Running SwiftLint..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint; \
	else \
		echo "SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

format: ## Format code with SwiftLint
	@echo "Formatting code..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint --fix; \
	else \
		echo "SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

run: ## Run the application
	@echo "Running ClipStack..."
	swift run

install: ## Install dependencies
	@echo "Installing dependencies..."
	@if ! command -v swiftlint >/dev/null 2>&1; then \
		echo "Installing SwiftLint..."; \
		brew install swiftlint; \
	fi
	@echo "Dependencies installed!"

setup: install ## Setup development environment
	@echo "Setting up development environment..."
	@echo "✅ Development environment ready!"