{
  lib,
  writeShellApplication,
  git,
  git-cliff,
  coreutils,
  gnused,
  gnugrep,
}:
writeShellApplication {
  name = "release";

  runtimeInputs = [
    git
    git-cliff
    coreutils
    gnused
    gnugrep
  ];

  text = ''
    set -euo pipefail

    TODAY=$(date +%y.%m.%d)
    VERSION="v$TODAY"

    echo "🚀 Starting release process for date: $TODAY"

    # Check changes
    if ! git cliff --unreleased --strip all | grep -q "^- "; then
      echo "❌ No changes found since last release"
      exit 1
    fi

    echo "✅ Changes detected, proceeding with release"

    # Add patch number when releasing same day
    if git tag -l | grep -q "^$VERSION$"; then
      PATCH_NUM=1
      while git tag -l | grep -q "^$VERSION\\.$PATCH_NUM$"; do
        PATCH_NUM=$((PATCH_NUM + 1))
      done
      VERSION="$VERSION.$PATCH_NUM"
    fi

    echo "📦 New release version: $VERSION"

    # Create changelog
    echo "📝 Generating changelog..."
    git cliff --tag "$VERSION" > CHANGELOG.md

    # commits and tag
    echo "💾 Committing and tagging..."
    git add CHANGELOG.md
    git commit -m "chore: release $VERSION" --no-verify
    git tag "$VERSION"

    echo "🎉 Release $VERSION completed!"
    echo "📤 Run 'git push origin main && git push origin $VERSION' to publish"

    # print release info
    echo ""
    echo "📋 Release Summary:"
    echo "Version: $VERSION"
    echo "Commit: $(git rev-parse HEAD)"
    echo "Tag: $VERSION"

    # set version in env vars (for GitHub Actions)
    if [ -n "''${GITHUB_ENV:-}" ]; then
      echo "RELEASE_VERSION=$VERSION" >> "$GITHUB_ENV"
      echo "RELEASE_TAG=$VERSION" >> "$GITHUB_ENV"
    fi
  '';

  meta = with lib; {
    description = "Date-based release script for docs repository";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
