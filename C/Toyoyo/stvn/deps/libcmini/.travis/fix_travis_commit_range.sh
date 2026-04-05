# This script fragment must be sourced by the main script file
# in order to define the FIXED_TRAVIS_COMMIT_RANGE variable
# . .travis/fix_travis_commit_range.sh

# TRAVIS_COMMIT_RANGE uses triple-dot syntax to specify which commits have
# triggered the build. This is wrong. In case of forced push, the previous
# commit is not an ancestor of the last commit, so it is not present in the
# cloned repository. And also, the range contains unrelated commits.
# https://docs.travis-ci.com/user/environment-variables/
# https://git-scm.com/book/tr/v2/Git-Tools-Revision-Selection
# https://github.com/travis-ci/travis-ci/issues/4596
#
# The solution is to use double-dot syntax instead.
# In case of forced push, we can't know the previous commit. So we just use
# the parent commit as previous one.

echo TRAVIS_COMMIT_RANGE=$TRAVIS_COMMIT_RANGE

PREVIOUS_COMMIT=$(echo $TRAVIS_COMMIT_RANGE | sed 's/\.\.\..*//')
CURRENT_COMMIT=$TRAVIS_COMMIT

if ! git merge-base --is-ancestor $PREVIOUS_COMMIT $CURRENT_COMMIT 2>/dev/null
then
  # Forced push: use parent commit as previous commit
  PREVIOUS_COMMIT=$CURRENT_COMMIT~
fi

# Normalize commits
PREVIOUS_COMMIT=$(git rev-parse --short $PREVIOUS_COMMIT)
CURRENT_COMMIT=$(git rev-parse --short $CURRENT_COMMIT)

export FIXED_TRAVIS_COMMIT_RANGE=$PREVIOUS_COMMIT..$CURRENT_COMMIT
echo FIXED_TRAVIS_COMMIT_RANGE=$FIXED_TRAVIS_COMMIT_RANGE

unset PREVIOUS_COMMIT CURRENT_COMMIT
