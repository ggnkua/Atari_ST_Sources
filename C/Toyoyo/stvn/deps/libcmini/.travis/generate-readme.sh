#!/bin/bash -eu
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.

# See .travis/fix_travis_commit_range.sh for details about the commit range.

# The argument for GitHub /compare/ requires 3 dots.
COMPARE_ARG=$(echo $FIXED_TRAVIS_COMMIT_RANGE | sed 's/\.\./.../')

echo "These binaries have been produced by"
echo "[Travis CI Build #$TRAVIS_BUILD_NUMBER](https://travis-ci.org/firebee-org/BaS_gcc/builds/$TRAVIS_BUILD_ID)"
echo "for commits [$FIXED_TRAVIS_COMMIT_RANGE](https://github.com/firebee-org/BaS_gcc/compare/$COMPARE_ARG)."
echo

# Generate log as preformatted text with hyperlinks
git log --name-status $FIXED_TRAVIS_COMMIT_RANGE -- | sed \
  -e 's|.*|``&``  |' \
  -e 's|[a-z]\+://[^ `]*|``\[&\](&)``|g' \
  -e 's|commit \([0-9a-f]\+\)|commit`` \[\1\](https://github.com/firebee-org/BaS_gcc/commit/\1) ``|g' \
  -e 's|````||g'
