#
# computes SHA of the dependencies to install
# we assume if SHA is different, dependencies must be reinstalled
# prefer using shrinkwrap if it exists
#

echo "All CLI arguments" $@
# take only arguments that are existing files
EXISTING_FILES=""
for arg in "$@"
do
  if [ -f $arg ]; then
    EXISTING_FILES="$EXISTING_FILES $arg"
  fi
done

if [ "$EXISTING_FILES" == "" ]; then
  if [ -f npm-shrinkwrap.json ]; then
    echo "Computing SHA from npm-shrinkwrap.json"
    SHASUM=$(shasum npm-shrinkwrap.json)
  else
    echo "Computing SHA from package.json"
    SHASUM=$(shasum package.json)
  fi
else
  echo "Computing SHA from files $EXISTING_FILES"
  SHASUM=$(cat $EXISTING_FILES | shasum)
fi

PACKAGE_SHA=($SHASUM)
echo "$NAME package dependencies file SHA: $PACKAGE_SHA"
