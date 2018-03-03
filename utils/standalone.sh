#!/bin/bash

if ! [ -d bin ]; then mkdir bin; fi
cp halium-install bin/halium-install-standalone.sh

# Insert included files directly to make the script work standalone
sed -i '/.*misc.sh/ r functions/misc.sh' bin/halium-install-standalone.sh
sed -i '/.*distributions.sh/ r functions/distributions.sh' bin/halium-install-standalone.sh
sed -i '/.*core.sh/ r functions/core.sh' bin/halium-install-standalone.sh

sed -i 's/.*misc.sh//g' bin/halium-install-standalone.sh
sed -i 's/.*distributions.sh//g' bin/halium-install-standalone.sh
sed -i 's/.*core.sh//g' bin/halium-install-standalone.sh
