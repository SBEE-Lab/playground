default:
    @just --list

# Documentation commands
build-docs:
    @echo "🔨 Building documentation..."
    mdbook build docs/
    @echo "✅ Documentation built successfully!"

serve-docs:
    @echo "🌐 Serving documentation locally..."
    mdbook serve docs/ --open

clean-docs:
    @echo "🧹 Cleaning documentation build..."
    rm -rf docs/book

init-docs:
    @echo "📖 Initializing new documentation..."
    mdbook init docs/
