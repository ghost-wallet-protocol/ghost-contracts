.PHONY: help build test clean lint fmt install-tools
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Ghost Protocol Contracts - Build & Development Commands'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-tools: ## Install Rust and required tools
	@echo "Installing Rust..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	rustup target add wasm32-unknown-unknown
	cargo install soroban-cli --locked

build: ## Build contracts
	@cd contracts && cargo build --release --target wasm32-unknown-unknown && cd ..

test: ## Run contract tests
	@cd contracts && cargo test && cd ..

lint: ## Run linters
	@echo "Linting Rust code..."
	@cd contracts && cargo clippy --all-targets && cd ..

fmt: ## Format code
	@echo "Formatting Rust..."
	@cd contracts && cargo fmt && cd ..

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@cd contracts && cargo clean && cd ..

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
