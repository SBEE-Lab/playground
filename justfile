# show available commands
_default:
    @just --list

# serve documentation on localhost
read-docs:
    @echo "🌐 Serving documentation locally..."
    mdbook serve docs/ --open
