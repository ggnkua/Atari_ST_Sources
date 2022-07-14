.include "../forth/app.s"
.include "../lib/replay.s"
.include "../lib/mapb2b.s"
.include "../lib/cells.s"
.include "../lib/muldiv8x8.s"
.include "../lib/cimage.s"
.include "../lib/tex_at_xy.s"
.include "../lib/voxel.s"
.include "../lib/xyosci.s"
.include "../lib/font_8x16.s"


|
| Title screen
|

.TEXT

CONST_XT messages _messages

DENTRIES messages

.MACRO MSG string
.DATA
DPOS = .
.TEXT
	.dc.l DPOS
.DATA
	.string "\string"
.TEXT
.ENDM

_messages:
	MSG "ESCAPE"
	MSG "is back"
	MSG "at Sommarhack"

	MSG "celebrating"
	MSG "high-resolution"
	MSG "monochrome"

	MSG "display"
	MSG "technology"
	MSG "on the Atari TT"

	MSG "- MONSCAPE -"

	MSG "Music              "
	MSG "Music           505"
	MSG "Replay             "
	MSG "Replay    Lance,Ray"
	MSG "Code               "
	MSG "Code             NO"


|
| Greetings screen
|

CONST_XT greetings _greetings

DENTRIES greetings

_greetings:
	MSG " "
	MSG " "
	MSG " "
	MSG "Dead Hackers Society"
	MSG "New Beat"
	MSG "Evolution"
	MSG "Tom"
	MSG "Satantronic"
	MSG "tSCc"
	MSG "Maggie"
	MSG "TNB"
	MSG "Avena"
	MSG "Alive"
	MSG "D-BUG"
	MSG "EKO"
	MSG "The Black Lotus"
	MSG "EXA"
	MSG "Oxygene"
	MSG "Cream"
	MSG "Reboot"
	MSG "SMFX"
	MSG "LineOut"
	MSG "Extream"
	MSG "Dekadence"
	MSG "YesCREW"
	MSG "Reservoir Gods"
	MSG "Aggression"
	MSG "FUN Industries"
	MSG "David Galvez"
	MSG "Genode Labs"
	MSG "dml"
	MSG "Paradox"
	MSG "PeP"
	MSG "Dune"
	MSG "Impulse"
	MSG "Newline"
	MSG "Cruor"
	MSG "Teenage"
	MSG "P.H.F."
	MSG "Hatari Team"
	MSG "Therapy"
	MSG "GGN"
	MSG "Nature"
	MSG "Checkpoint"
	MSG "Jaysoft"
	MSG "MJJ"
	MSG "Excellence in Art"
	MSG "Mystic Bytes"
	MSG "Ephidrena"
	MSG "Lazer"
	MSG "T.O.Y.S."
	MSG "MiKRO"
	MSG "Thadoss"
	MSG "Sector One"
	MSG "Exocet"
	MSG ""


|
| Voxel data
|

.DATA

CONST_XT hmap _hmap
CONST_XT tmap _tmap

DENTRIES hmap tmap

_hmap:	.incbin "hmap.dat"
_tmap:	.incbin "tmap.dat"


| vim: set ts=16:
