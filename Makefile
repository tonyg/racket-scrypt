ifeq ($(shell uname -s),Darwin)
SHEXT=dylib
else
SHEXT=so
endif

SHAREDLIB=scrypt.$(SHEXT)
SCRYPTVERSION=1.1.6
SCRYPTUNPACKED=scrypt-$(SCRYPTVERSION)

all: $(SHAREDLIB)

$(SHAREDLIB): $(SCRYPTUNPACKED)
	raco ctool \
		++ldf "-O3" ++ldf "-fomit-frame-pointer" ++ldf "-funroll-loops" \
		++ldf "-DHAVE_CONFIG_H" \
		++ldf "-I" ++ldf "$(SCRYPTUNPACKED)" \
		++ldf "-I" ++ldf "$(SCRYPTUNPACKED)/lib/util" \
		--ld $@ \
		`find $(SCRYPTUNPACKED)/lib/crypto -name '*.c'` \
		-lssl -lcrypto

clean:
	rm -f $(SHAREDLIB)
	rm -rf $(SCRYPTUNPACKED)

$(SCRYPTUNPACKED): $(SCRYPTUNPACKED).tgz
	tar -zxvf $<
	cp config.h $(SCRYPTUNPACKED)
	rm $(SCRYPTUNPACKED)/lib/crypto/crypto_scrypt-nosse.c
	rm $(SCRYPTUNPACKED)/lib/crypto/crypto_scrypt-sse.c
