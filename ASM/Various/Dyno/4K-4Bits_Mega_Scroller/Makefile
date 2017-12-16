#--------------------------------------------------------------------
# Parameters
#--------------------------------------------------------------------

# Demo Engine
ENGINE = /acme/demo/atari/Megademo

# Imagemagick
# Do not store time of creation into EXIF headers
IMPRM = -define png:exclude-chunk=tIME

#--------------------------------------------------------------------
# Generate include files
#--------------------------------------------------------------------

all: clean palette text tile entropy assemble

clean:
	@echo =======[ CLEAN ]=======
	rm -f ./*.DAT ./*.PRG ./*.BIN

palette:
	@echo =======[ PALETTE ]=======
	php -f ./PHP/palette.php

tile: tile_small tile_medium_gen tile_medium tile_large
tile_large:
	@echo =======[ TILE_LARGE ]=======
	rm -f /tmp/tiles_*.png
	convert ./PHP/text_tile_large.png -crop 16x16 +repage +adjoin /tmp/tiles_%02d.png
	montage ./PHP/tile_bg.png /tmp/tiles_*.png $(IMPRM) -tile 1x -geometry 16x16 -texture ./PHP/tile_bg.png ./INC/lgtile.png
	$(ENGINE)/TOOLS/convertImage.php ./INC/lgtile.png ./INC/LGTILE.RAW 000000
tile_medium_gen:
	php ./PHP/gen_tile.php
tile_medium:
	@echo =======[ TILE_MEDIUM ]=======
	rm -f /tmp/tiles_*.png
	convert ./PHP/text_tile_medium.png -crop 16x16 +repage +adjoin /tmp/tiles_%02d.png
	rm /tmp/tiles_1[789].png
	montage ./PHP/tile_bg.png /tmp/tiles_*.png $(IMPRM) -tile 1x -geometry 16x16 -texture ./PHP/tile_bg.png ./INC/mdtile.png
	$(ENGINE)/TOOLS/convertImage.php ./INC/mdtile.png ./INC/MDTILE.RAW 220000
tile_small:
	@echo =======[ TILE_SMALL ]=======
	rm -f /tmp/tiles_*.png
	convert ./PHP/text_tile_small.png -crop 16x16 +repage +adjoin /tmp/tiles_%02d.png
	montage ./PHP/tile_bg.png /tmp/tiles_*.png $(IMPRM) -tile 1x -geometry 16x16 -texture ./PHP/tile_bg.png ./INC/smtile.png
	$(ENGINE)/TOOLS/convertImage.php ./INC/smtile.png ./INC/SMTILE.RAW 000000

text: text_small text_medium text_large
text_large:
	@echo =======[ TEXT_LARGE ]=======
	php -f ./PHP/text.php large
text_medium:
	@echo =======[ TEXT_MEDIUM ]=======
	php -f ./PHP/text.php medium
text_small:
	@echo =======[ TEXT_SMALL ]=======
	php -f ./PHP/text.php small

entropy:
	@echo =======[ ENTROPY ]=======
	php -f ./PHP/entropy.php

assemble:
	@echo =======[ ASSEMBLE ]=======
	$(ENGINE)/TOOLS/GENST/assemble.php $(ENGINE)/SCREENS/BIGSCROL/SCROLL4B.S

#--------------------------------------------------------------------
# Release version
#--------------------------------------------------------------------

release: assemble
	@echo =======[ RELEASE ]=======
	tail -c+29 SCROLL4B.BIN > /tmp/SCROLL4B.nohead
	head -c-4 /tmp/SCROLL4B.nohead > /tmp/SCROLL4B.truncated
	$(ENGINE)/TOOLS/shrinkler -i 9 -d /tmp/SCROLL4B.truncated FINAL.DAT
	$(ENGINE)/TOOLS/GENST/assemble.php $(ENGINE)/SCREENS/BIGSCROL/FINAL.S

#--------------------------------------------------------------------
# Release ZIP file
#--------------------------------------------------------------------

zip: all release
	@echo =======[ ZIP ]=======
	rm -f release.zip
	zip -r release.zip Makefile README.TXT *.S FINAL.* SCROLL4B.* screenshot.png ASM/* INC/*.RAW INC/*.BIN INC/*.SND PHP/*
