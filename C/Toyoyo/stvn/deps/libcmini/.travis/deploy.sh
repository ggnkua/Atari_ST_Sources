#!/bin/bash -e
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.

if [ "${TRAVIS_PULL_REQUEST}" = "false" -a "${GITHUB_OATH_TOKEN}" != "" ]
then
#
# trigger a rebuild of COPS & hypview
#
body='{
"request": {
"branch":"master"
}}'

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token ${GITHUB_OATH_TOKEN}" \
   -d "$body" \
   https://api.travis-ci.org/repo/freemint%2Fcops/requests

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token ${GITHUB_OATH_TOKEN}" \
   -d "$body" \
   https://api.travis-ci.org/repo/freemint%2Fhypview/requests

fi
