{
  lib,
  writeShellApplication,
  git-cliff,
  git,
  bat ? null,
}:
writeShellApplication {
  name = "preview";

  runtimeInputs =
    [
      git-cliff
      git
    ]
    ++ lib.optional (bat != null) bat;

  text = ''
    set -euo pipefail

    echo "📖 Unreleased changes preview:"
    echo "================================"

    CHANGES=$(git cliff --unreleased --strip all)

    if [ -z "$CHANGES" ] || [ "$CHANGES" = "" ]; then
      echo "❌ No unreleased changes found"
      exit 0
    fi

    if command -v bat >/dev/null 2>&1; then
      echo "$CHANGES" | bat --language markdown --style plain
    else
      echo "$CHANGES"
    fi

    echo ""
    echo "📊 Commit count since last release: $(git rev-list --count "$(git describe --tags --abbrev=0 2>/dev/null || echo 'HEAD')"..HEAD 2>/dev/null || echo '0')"
  '';

  meta = with lib; {
    description = "Preview unreleased changes for docs repository";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
