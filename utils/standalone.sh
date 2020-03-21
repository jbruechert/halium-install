#!/bin/bash -e

LOCATION="$(dirname "$(readlink -f "$0")")/../"
echo $LOCATION

if ! [ -d bin ]; then mkdir bin; fi
cp halium-install bin/halium-install-standalone.sh

insert_file() {
	PATTERN=$1
	FILE=$2

	sed -i "/.*${PATTERN}/ r ${FILE}" bin/halium-install-standalone.sh
	sed -i "s/.*${PATTERN}//g" bin/halium-install-standalone.sh

	# No idea why sed randomly started to insert ". Anyway, let's fix it.
	sed -i '/^"$/d' bin/halium-install-standalone.sh
}

# Insert included files directly to make the script work standalone
insert_file misc.sh ${LOCATION}/functions/misc.sh
insert_file distributions.sh ${LOCATION}/functions/distributions.sh
insert_file core.sh ${LOCATION}/functions/core.sh

# Fail if result is broken
bash -n bin/halium-install-standalone.sh
