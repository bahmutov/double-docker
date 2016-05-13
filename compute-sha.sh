#
# computes SHA of the dependencies to install
# we assume if SHA is different, dependencies must be reinstalled
# prefer using shrinkwrap if it exists
if [ -f npm-shrinkwrap.json ]; then
  SHASUM=$(shasum npm-shrinkwrap.json)
else
  SHASUM=$(shasum package.json)
fi
PACKAGE_SHA=($SHASUM)
echo "$NAME package dependencies file SHA: $PACKAGE_SHA"
