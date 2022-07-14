|
| Tables for multiplying and dividing 8bit x 8bit numbers
|
| The tables are organized such that signed indexed addressing works.
| The lower half covers 128..255 x 0..255.
| The upper half covers   0..127 x 0..255.
|

| ( buffer -- ) generate table into a buffer of 0x20000 bytes
CODE_XT genmul8x8tab
	move.l d4,a0 ; POPD  | a0: buffer for 256x256 words

.MACRO GENMULTAB_256x128 y_start
	move.l  #\y_start,d1 | d1: y
	move.w  #127,d3      | d3: y-loop count
1:	moveq   #0,d0        | d0: v
	move.w  #255,d2      | d2: x-loop count
2:	move.w  d0,(a0)+
	add.w   d1,d0        | d0: x*v
	dbf     d2,2b
	addq.l  #1,d1
	dbf     d3,1b
.ENDM
	GENMULTAB_256x128 128
	GENMULTAB_256x128 0
	NEXT

| ( buffer -- ) generate 16-bit 8x8 table for dividing 8-bit by 8-bit numbers
CODE_XT gendiv8x8tab
	move.l d4,a0         | a0: buffer for 256x256 words

.MACRO GENDIVTAB_256x128 y_start
	move.l  #\y_start,d1 | d1: y
	move.w  #127,d3      | d3: y-loop count
1:	moveq   #0,d0        | d0: v
	move.w  #255,d2      | d2: x-loop count
2:	move.l  d0,d4
	beq.s   3f
	lsl.l   #8,d4
	divs.w  d1,d4        | d4.w: (v*256)/y
3:	move.w  d4,(a0)+
	addq.l  #1,d0
	dbf     d2,2b
	addq.l  #1,d1
	dbf     d3,1b
.ENDM
	GENDIVTAB_256x128 128
	GENDIVTAB_256x128 0
	POPD
	NEXT

| ( a b 8x8tab -- element ) read element from 16-bit organized 8x8 table
CODE_XT at8x8
	move.l d4,a0 ; POPD     | a0: table of 8x8 16-bit words
	move.l d4,d0 ; POPD     | d0: b (0..255)
	                        | d4: a (0..256)
	lea 0x10000(a0),a0      | adjust for signed indexed access
	lsl.w  #8,d0
	move.b d4,d0
	move.w (a0,d0.w*2),d4   | d4: element
	NEXT

DENTRIES genmul8x8tab gendiv8x8tab
DENTRY   "@8x8" at8x8

| vim: set ts=16:
