# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +======================================================================+
# | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
# +----------------------------------------------------------------------+
# | This program is free software: you can redistribute it and/or modify |
# | it under the terms of the GNU General Public License as published by |
# | the Free Software Foundation, either version 3 of the License, or    |
# | (at your option) any later version.                                  |
# |                                                                      |
# | This program is distributed in the hope that it will be useful,      |
# | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
# | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
# | GNU General Public License for more details.                         |
# |                                                                      |
# | You should have received a copy of the GNU General Public License    |
# | along with this program. If not, see <http://www.gnu.org/licenses/>. |
# +======================================================================+

#--------------------------------------------------------------------
# SOX Parameters
#--------------------------------------------------------------------

# Repeatable, 1 channel, 8-bit unsigned
SOXPRM = -R -c 1 -e unsigned-integer -b 8

# Boost bass & treble, High-pass & low-pass filter, 8.35 Khz
SOXEFF = bass +4 140 treble +12 4175 highpass 150 lowpass 3000 rate -b 74 -p 100 8354

#--------------------------------------------------------------------
# Generate include files
#--------------------------------------------------------------------

all: tile text curve bounce palette sound sample

tile:
	php -f ./PHP/TILE.PHP
text:
	php -f ./PHP/TEXT.PHP
curve:
	php -f ./PHP/CURVE.PHP
bounce:
	php -f ./PHP/BOUNCE.PHP
palette:
	php -f ./PHP/PALETTE.PHP
sound:
	php -f ./PHP/SOUND.PHP
sample:
	@# Generate WAV
	for N in 1 2 3 4 5 6 7 8; do \
	  sox --norm ./SOUND/source$$N.wav $(SOXPRM) -t wav ./SOUND/SAMPLE$$N.WAV  $(SOXEFF); \
	done
	@# Pack/Unpack samples with delta-compression algorithm
	php -f ./PHP/PACKSPL.PHP
	@# Extract RAW data
	for N in 1 2 3 4 5 6 7 8; do \
	  tail -c +45 ./SOUND/SAMPLE$$N.WAV > ./SOUND/SAMPLE$$N.SPL; \
	done

#--------------------------------------------------------------------
# Release
#--------------------------------------------------------------------

release:
	zip release.zip Makefile *.TXT *.S LOAD_520.PRG INC/*.BIN INC/TEXT*.S INC/CURVE/*.BIN PHP/* SOUND/SAMPLE*.SPL
