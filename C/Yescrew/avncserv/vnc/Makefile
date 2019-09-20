CC = gcc
CCCF = /home/usr/local/bin/gcc
LD = ld
RM = rm
STRIP = strip
STACK = stack
AR = ar rc
AR2 = ranlib
DEL = rm
STACKSIZE = 64k
CFLAGS = -m68020-60 -O2 -fomit-frame-pointer -Wno-multichar
CFLAGSCF = -mcfv4e -O2 -fomit-frame-pointer -fno-strict-aliasing -fno-inline-small-functions -Wno-multichar -DCOLDFIRE
SRCDIR = ./
OBJDIR = ./obj
OBJDIRCF = ./obj_cf

LIBOBJECTS = $(OBJDIR)/main.o $(OBJDIR)/rfbserver.o $(OBJDIR)/rfbregion.o \
	$(OBJDIR)/auth.o $(OBJDIR)/sockets.o $(OBJDIR)/websockets.o \
	$(OBJDIR)/rfbcrypto_included.o $(OBJDIR)/md5.o $(OBJDIR)/sha1.o $(OBJDIR)/rfbssl_none.o \
	$(OBJDIR)/rfbssl_openssl.o $(OBJDIR)/rfbcrypto_openssl.o $(OBJDIR)/rfbssl_gnutls.o \
	$(OBJDIR)/rfbcrypto_gnutls.o $(OBJDIR)/stats.o $(OBJDIR)/corre.o $(OBJDIR)/hextile.o $(OBJDIR)/rre.o $(OBJDIR)/translate.o \
	$(OBJDIR)/cutpaste.o $(OBJDIR)/httpd.o $(OBJDIR)/cursor.o $(OBJDIR)/font.o $(OBJDIR)/draw.o $(OBJDIR)/selbox.o \
	$(OBJDIR)/d3des.o $(OBJDIR)/vncauth.o $(OBJDIR)/cargs.o $(OBJDIR)/minilzo.o $(OBJDIR)/ultra.o $(OBJDIR)/scale.o $(OBJDIR)/zlib.o $(OBJDIR)/zrle.o \
	$(OBJDIR)/zrleoutstream.o $(OBJDIR)/zrlepalettehelper.o $(OBJDIR)/zywrletemplate.o \
	$(OBJDIR)/tight.o $(OBJDIR)/turbojpeg.o $(OBJDIR)/rfbtightserver.o \
	$(OBJDIR)/handlefiletransferrequest.o $(OBJDIR)/filetransfermsg.o $(OBJDIR)/filelistinfo.o

LIBOBJECTSCF = $(OBJDIRCF)/main.o $(OBJDIRCF)/rfbserver.o $(OBJDIRCF)/rfbregion.o \
	$(OBJDIRCF)/auth.o $(OBJDIRCF)/sockets.o $(OBJDIRCF)/websockets.o \
	$(OBJDIRCF)/rfbcrypto_included.o $(OBJDIRCF)/md5.o $(OBJDIRCF)/sha1.o $(OBJDIRCF)/rfbssl_none.o \
	$(OBJDIRCF)/rfbssl_openssl.o $(OBJDIRCF)/rfbcrypto_openssl.o $(OBJDIRCF)/rfbssl_gnutls.o \
	$(OBJDIRCF)/rfbcrypto_gnutls.o $(OBJDIRCF)/stats.o $(OBJDIRCF)/corre.o $(OBJDIRCF)/hextile.o $(OBJDIRCF)/rre.o $(OBJDIRCF)/translate.o \
	$(OBJDIRCF)/cutpaste.o $(OBJDIRCF)/httpd.o $(OBJDIRCF)/cursor.o $(OBJDIRCF)/font.o $(OBJDIRCF)/draw.o $(OBJDIRCF)/selbox.o \
	$(OBJDIRCF)/d3des.o $(OBJDIRCF)/vncauth.o $(OBJDIRCF)/cargs.o $(OBJDIRCF)/minilzo.o $(OBJDIRCF)/ultra.o $(OBJDIRCF)/scale.o $(OBJDIRCF)/zlib.o $(OBJDIRCF)/zrle.o \
	$(OBJDIRCF)/zrleoutstream.o $(OBJDIRCF)/zrlepalettehelper.o $(OBJDIRCF)/zywrletemplate.o \
	$(OBJDIRCF)/tight.o $(OBJDIRCF)/turbojpeg.o $(OBJDIRCF)/rfbtightserver.o \
	$(OBJDIRCF)/handlefiletransferrequest.o $(OBJDIRCF)/filetransfermsg.o $(OBJDIRCF)/filelistinfo.o

all: libvnc.a libvnccf.a aVNCServ aVNCServCF

libvnc.a: $(LIBOBJECTS)
	$(AR) libvnc.a $(LIBOBJECTS)
	$(AR2) libvnc.a

libvnccf.a: $(LIBOBJECTSCF)
	$(AR) libvnccf.a $(LIBOBJECTSCF)
	$(AR2) libvnccf.a

aVNCServ: $(OBJDIR)/fbvncserver.o $(OBJDIR)/callback.o libvnc.a
	$(CC) $(CFLAGS) -o aVNCServ $(OBJDIR)/fbvncserver.o $(OBJDIR)/callback.o -Xlinker -Map=aVNCServ.map -L. -lvnc -ljpeg -lpng -lz -lpthread -lsocket
	$(STRIP) aVNCServ
	$(STACK) -S $(STACKSIZE) aVNCServ

aVNCServCF: $(OBJDIRCF)/fbvncserver.o $(OBJDIRCF)/callback.o libvnccf.a
	$(CCCF) $(CFLAGSCF) -o aVNCServCF $(OBJDIRCF)/fbvncserver.o $(OBJDIRCF)/callback.o -Xlinker -Map=aVNCServCF.map -L. -lvnccf -ljpeg -lpng -lz -lpthread -lsocket
	$(STRIP) aVNCServCF
	$(STACK) -S $(STACKSIZE) aVNCServCF

clean:
	$(DEL) -f *.a *.ttp $(LIBOBJECTS) $(LIBOBJECTSCF)

define CREATEOBJDIRS
	@for d in $(OBJDIR); do \
		if [ ! -d $$d ] ; then \
			mkdir $$d ; \
		fi ; \
	done
endef

define CREATEOBJDIRSCF
	@for d in $(OBJDIRCF); do \
		if [ ! -d $$d ] ; then \
			mkdir $$d ; \
		fi ; \
	done
endef

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CREATEOBJDIRS)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/%.o: $(SRCDIR)/%.c
	$(CREATEOBJDIRSCF)
	$(CCCF) $(CFLAGSCF) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.S
	$(CREATEOBJDIRS)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIRCF)/%.o: $(SRCDIR)/%.S
	$(CREATEOBJDIRSCF)
	$(CCCF) $(CFLAGSCF) -c $< -o $@
