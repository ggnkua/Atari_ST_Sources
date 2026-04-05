#!/bin/bash -eu
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.

# This installs an SSH private/public key pair on the build system,
# so ssh can connect to remote servers without password.
# Important: for passwordless connection to succeed, our public key must be
# manually authorized on the remote server.

# Our private key is the critical security component, it must remain secret.
# We store it in the SSH_ID environment variable in Travis CI project settings.
# As environment variables can only contain text, our key files are transformed
# like this: tar, xz, base64. Then then can be decoded here. This is safe as
# Travis CI never shows the contents of secure variables.

# To generate the contents of the SSH_ID variable:
# Be sure to be in an empty, temporary directory.
#
# mkdir .ssh
# ssh-keygen -t rsa -b 4096 -C travis-ci.org/firebee-org/BaS_gcc -N '' -f .ssh/id_rsa
# tar Jcvf id_firebee-org_BaS_gcc.tar.xz .ssh
# base64 -w 0 id_firebee-org_BaS_gcc.tar.xz
#
# Select the resulting encoded text (several lines) to copy it to the clipboard.
# Then go to the Travis CI project settings:
# https://travis-ci.org/firebee-org/BaS_gcc/settings
# Create a new environment variable named SSH_ID, and paste the value.
# The script below will recreate the key files from that variable contents.

if [ -z ${SSH_ID+x} ]
then
  echo "error: SSH_ID is undefined" >&2
  exit 1
fi

echo $SSH_ID | base64 -d | tar -C ~ -Jx
ls -l ~/.ssh
