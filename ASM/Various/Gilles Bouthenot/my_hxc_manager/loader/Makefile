
ARCH=cygwin

VASM=../build-tools/vbcc/bin-$(ARCH)/vasmm68k_mot
VASMOPT=-Fbin -showopt -quiet
NRV2B=../build-tools/nrv2b/nrv2b-$(ARCH)
NRV2BOPT=

.PHONY: all clean

all: OUT.ST

clean:
	rm -f temp/packed.n2b temp/stage1.bin temp/stage2.bin atari/equates.s temp/depack.prg temp/depack_bp OUT.ST

push-mina: OUT.ST
	rsync --perms $< Gilles@mina.openvpn:/cygdrive/c/users/Gilles/Desktop

push-gbo-dsi: OUT.ST
	rsync --perms $< gbouthen@gbo-dsi.openvpn:/cygdrive/c/users/gbouthen/Desktop

push-gbo-pc: OUT.ST
	rsync --perms $< gbouthenot@gbo-pc.openvpn:/cygdrive/c/users/gbouthenot/Desktop

temp/packed.n2b: ../hxcfemng/HXCFEMNG.PRG
	cp ../hxcfemng/HXCFEMNG.PRG temp/depack.prg
	m68k-atari-mint-strip -s temp/depack.prg
	# create the file to be packed
	# first, create the basepage (256 0x00 bytes):
	dd if=/dev/zero of=temp/depack_bp bs=256 count=1
	# then add the unpacked file, minus the first 28 bytes:
	tail --bytes=+29 temp/depack.prg >>temp/depack_bp
	# pack this file
	$(NRV2B) $(NRVOPT) temp/depack_bp temp/packed.n2b

temp/stage2.bin: atari/stage2.s atari/equates.s atari/const.s atari/n2bd.s
	cd atari && ../$(VASM) $(VASMOPT) -pic -o ../$@ stage2.s
	perl gen-equates.pl > atari/equates.s
	touch $@

atari/equates.s: temp/packed.n2b
	perl gen-equates.pl >atari/equates.s

temp/stage1.bin: atari/stage1.s atari/equates.s atari/const.s atari/autoload.s temp/stage2.bin
	cd atari && ../$(VASM) $(VASMOPT) -pic -o ../$@ stage1.s

OUT.ST: temp/stage1.bin temp/stage2.bin temp/packed.n2b
	perl link.pl
