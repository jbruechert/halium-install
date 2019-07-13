#!/usr/bin/make

standalone:
	bash utils/standalone.sh

test:
	bash tests/test_install.sh

clean:
	if [ -d bin ]; then rm bin -r; fi
