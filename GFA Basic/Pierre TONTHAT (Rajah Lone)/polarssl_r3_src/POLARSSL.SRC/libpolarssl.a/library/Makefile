
CROSSPREFIX=/opt/cross-mint/bin/m68k-atari-mint-
PATH = /opt/cross-mint/m68k-atari-mint/bin:/opt/cross-mint/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
LD_LIBRARY_PATH=/opt/cross-mint/lib:/opt/cross-mint/m68k-atari-mint/lib:$LD_LIBRARY_PATH
DESTDIR=/opt/cross-mint/m68k-atari-mint

CC = $(CROSSPREFIX)gcc
AS = $(CC)
AR = $(CROSSPREFIX)ar
RANLIB = $(CROSSPREFIX)ranlib
STRIP = $(CROSSPREFIX)strip
FLAGS = $(CROSSPREFIX)flags

CFLAGS	= -I../include -W -Wdeclaration-after-statement
OFLAGS	= -Wall -O2 -fomit-frame-pointer

OBJS=	aes.o aesni.o arc4.o asn1parse.o asn1write.o base64.o bignum.o blowfish.o camellia.o ccm.o certs.o cipher.o cipher_wrap.o ctr_drbg.o debug.o des.o dhm.o \
      ecdh.o ecdsa.o ecp.o ecp_curves.o entropy.o entropy_poll.o error.o gcm.o havege.o hmac_drbg.o md.o md_wrap.o md2.o md4.o md5.o memory_buffer_alloc.o net.o \
     oid.o padlock.o pbkdf2.o pem.o pkcs5.o pkcs11.o pkcs12.o pk.o pk_wrap.o pkparse.o pkwrite.o platform.o ripemd160.o rsa.o sha1.o sha256.o sha512.o \
     ssl_cache.o ssl_cli.o ssl_srv.o ssl_ciphersuites.o ssl_tls.o threading.o timing.o version.o version_features.o \
     x509.o x509_create.o x509_crl.o x509_crt.o x509_csr.o x509write_crt.o x509write_csr.o xtea.o

libpolarssl.a: $(OBJS)
	$(AR) -rcs $@ $(OBJS)
	$(AR) s $@
	cp libpolarssl.a $(DESTDIR)/lib/libpolarssl.a
	#cp libpolarssl.a $(DESTDIR)/lib/m68020-60/libpolarssl.a
	#cp libpolarssl.a $(DESTDIR)/lib/m5475/libpolarssl.a
	rm -f *.o libpolarssl.*

.c.o:
	$(CC) $(CFLAGS) -m68000 $(OFLAGS) -c $<
	#$(CC) $(CFLAGS) -m68020-60 $(OFLAGS) -c $<
	#$(CC) $(CFLAGS) -mcpu=5475 $(OFLAGS) -c $<

clean:
	rm -f *.o libpolarssl.*
