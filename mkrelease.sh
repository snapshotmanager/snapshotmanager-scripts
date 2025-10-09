#!/bin/bash
set -euo pipefail

log () {
    echo "$@" 1>&2
}

OLDVERSION="$1"
NEWVERSION="$2" 
log "OLDVERSION: $OLDVERSION"
log "NEWVERSION: $NEWVERSION" 1>&2
log all args: $@ 1>&2
# Hack: make sure we obtain 'boom' rather than 'boom-boot':
PROJECT=$(ls man/man8/*.8 | sed -e 's/man\/man8\///' -e 's/\.8//')
log "Set PROJECT=${PROJECT}"

# Formal project name (used for .spec)
DIST_PROJECT=$(basename $PWD)
log "Set DIST_PROJECT=${DIST_PROJECT}"

git tag | grep v &>/dev/null && TAG_PREFIX="v" || TAG_PREFIX=""
log "Using tag prefix: $TAG_PREFIX" 1>&2

START_TAG="${TAG_PREFIX}${OLDVERSION}"
log "Start tag: $START_TAG" 1>&2

git show "${TAG_PREFIX}${NEWVERSION}" &>/dev/null && END_TAG="${TAG_PREFIX}${NEWVERSION}" || END_TAG="HEAD"
log "End tag: $END_TAG" 1>&2

log "Release prep for ${PROJECT}-$NEWVERSION (previouly $OLDVERSION)" 1>&2

SHORTOLDVERSION=$(echo $OLDVERSION| sed 's/\.[0-9]*$//')
SHORTNEWVERSION=$(echo $NEWVERSION| sed 's/\.[0-9]*$//')
log "Generated short versions: OLD=$SHORTOLDVERSION NEW=$SHORTNEWVERSION" 1>&2

SIMPLE_FILES="doc/conf.py $PROJECT/__init__.py"

log "Handling simple files... $SIMPLE_FILES" 1>&2
for FILE in $SIMPLE_FILES; do
	sed -i "s/$OLDVERSION/$NEWVERSION/" $FILE
done

log "Checking if pyproject.toml needs version update..."
if grep "version = \"${OLDVERSION}\"" pyproject.toml &>/dev/null; then
    log "YES"
    sed -i "s/$OLDVERSION/$NEWVERSION/" pyproject.toml
fi

log "Updating doc/conf.py file SHORTVERSION=${SHORTNEWVERSION}" 1>&2
sed -i "s/$SHORTOLDVERSION/$SHORTNEWVERSION/" doc/conf.py

log "Updating RPM ${PROJECT} ${PROJECT}.spec file" 1>&2

sed -i "s/Version:\t$OLDVERSION/Version:\t$NEWVERSION/" $DIST_PROJECT.spec

CL_HEADER="* $(date +"%a %b %d %Y") Bryn M. Reeves <bmr@redhat.com> - ${NEWVERSION}-1"
CL_PATH=$(mktemp)
log "Writing ChangeLog header: $CL_HEADER"
echo "$CL_HEADER" > "$CL_PATH"
log "Generating %changelog entries from v$OLDVERSION..v$NEWVERSION" 1>&2
git log --oneline ${START_TAG}..${END_TAG} | sed  -e 's/^[a-f0-9]* /- /' -e 's/%//' >> "$CL_PATH"
echo >> "$CL_PATH"
log "Patching  $DIST_PROJECT.spec ChangeLog..."
sed -i "/%changelog/ r $CL_PATH" "$DIST_PROJECT.spec"
