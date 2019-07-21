#--------------------------------------------------------------------
# Parameters
#--------------------------------------------------------------------

# Demo Engine
ENGINE = /acme/demo/atari/Megademo

# Imagemagick
# Do not store time of creation into EXIF headers
IMPRM = -define png:exclude-chunk=tIME

#--------------------------------------------------------------------
# Rules
#--------------------------------------------------------------------

all: clean bubbles font logo assemble

clean:
	@echo =======[ CLEAN ]=======
	rm -f ./*.DAT ./*.PRG ./*.BIN

bubbles:
	@echo =======[ BUBBLES ]=======
	$(ENGINE)/TOOLS/convertImage.php ./bubbles.png /tmp/BUBBLES 000000
	tail -c+35 /tmp/BUBBLES > ./BUBBLES.RAW

font:
	@echo =======[ FONT ]=======
	rm -f /tmp/font_*.png
	convert ./font_src.png -crop 16x16 +repage +adjoin /tmp/font_%02d.png
	montage /tmp/font_*.png $(IMPRM) -tile 1x -geometry 16x16 -background transparent ./font.png
	$(ENGINE)/TOOLS/convertImage.php ./font.png /tmp/FONT transparent
	tail -c+35 /tmp/FONT > ./FONT.RAW

logo:
	@echo =======[ LOGO ]=======
	$(ENGINE)/TOOLS/convertImage.php ./logo.png /tmp/LOGO transparent
	tail -c+35 /tmp/LOGO > ./LOGO.RAW

assemble:
	@echo =======[ ASSEMBLE ]=======
	$(ENGINE)/TOOLS/GENST/assemble.php $(ENGINE)/SCREENS/CRACKTRO/CRACKTRO.S

release: all
	@echo =======[ RELEASE ]=======
	/usr/bin/upx CRACKTRO.PRG

#--------------------------------------------------------------------
# Release ZIP file
#--------------------------------------------------------------------
# Also add into the archive the "INCLUDES" directory

zip: release
	@echo =======[ ZIP ]=======
	rm -f /tmp/release.zip
	zip -r /tmp/release.zip *.PRG *.S *.png *.RAW Makefile
	cd /acme/demo/atari/Megademo/ && zip -r /tmp/release.zip INCLUDES/ --exclude "INCLUDES/.hg/*"
	mv /tmp/release.zip .
