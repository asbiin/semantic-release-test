#!/bin/bash

SELF_PATH=$(cd -P -- "$(dirname -- "$0")" && /bin/pwd -P)

set -eo pipefail

version=$1
if [ "$version" == "" ]; then
  echo "Version parameter is mandatory" >&2
  exit 1
fi

set -v

echo "$version" | tee .version
git log --pretty="%h" -n1 HEAD | tee .release
git log --pretty="%H" -n1 HEAD | tee .commit

# PACKAGE
package=semantic-release-test-$version
mkdir -p $package
ln -s $SELF_PATH/CHANGELOG.md $package/
ln -s $SELF_PATH/README.md $package/
ln -s $SELF_PATH/file.md $package/

tar chfj $package.tar.bz2 --exclude .gitignore --exclude .gitkeep $package

echo "::set-output name=package::$package.tar.bz2"
