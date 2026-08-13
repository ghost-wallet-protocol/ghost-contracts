.PHONY: help build test clean lint fmt install-tools
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Ghost Protocol - Build & Development Commands'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-tools: ## Install Rust and required tools
	@echo "Installing Rust..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	rustup target add wasm32-unknown-unknown
	cargo install soroban-cli --locked

build: ## Build all contracts and SDKs
	@chmod +x scripts/build.sh
	@./scripts/build.sh

test-contracts: ## Run contract unit tests
	@cd contracts && cargo test && cd ..

test-sdk: ## Run SDK tests
	@cd sdk && npm test && cd ..

test: test-contracts test-sdk ## Run all tests

lint: ## Run linters
	@echo "Linting Rust code..."
	@cd contracts && cargo clippy --all-targets && cd ..
	@echo "Linting TypeScript..."
	@cd sdk && npm run lint && cd ..
	@cd relayer && npm run lint && cd ..

fmt: ## Format all code
	@echo "Formatting Rust..."
	@cd contracts && cargo fmt && cd ..
	@echo "Formatting TypeScript..."
	@cd sdk && npx prettier --write src && cd ..
	@cd relayer && npx prettier --write src && cd ..
	@cd frontend && npx prettier --write src && cd ..

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@cd contracts && cargo clean && cd ..
	@rm -rf sdk/dist sdk/node_modules
	@rm -rf relayer/dist relayer/node_modules
	@rm -rf frontend/build frontend/node_modules

dev-sdk: ## Development mode for SDK
	@cd sdk && npm link && npm run build -- --watch

dev-relayer: ## Development mode for Relayer
	@cd relayer && npm run dev

dev-frontend: ## Development mode for Frontend
	@cd frontend && npm start

# Deployment targets
deploy-testnet: build ## Deploy contracts to testnet
	@chmod +x scripts/deploy.sh
	@./scripts/deploy.sh testnet

deploy-mainnet: build ## Deploy contracts to mainnet
	@chmod +x scripts/deploy.sh
	@./scripts/deploy.sh mainnet

# Documentation
docs: ## Generate documentation
	@cd contracts && cargo doc --no-deps --open && cd ..

# Check everything
check: lint test ## Run linters and tests
	@echo "✅ All checks passed!"
