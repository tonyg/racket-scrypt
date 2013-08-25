COLLECTION=scrypt

all: setup

clean:
	find . -name compiled -type d | xargs rm -rf

setup:
	raco setup $(COLLECTION)

link:
	raco pkg install --link -n $(COLLECTION) $$(pwd)

unlink:
	raco pkg remove $$(basename $$(pwd))
