
;Flappybird for the Atari ST

	INCLUDE	"\SRC\BOOT.INC"
	INCLUDE	"\SRC\RASTERS.INC"
	INCLUDE	"\SRC\FONT.INC"
	INCLUDE	"\SRC\IKBD.INC"
	INCLUDE	"\SRC\SOUND.INC"
	INCLUDE	"\SRC\LZ77.INC"
	INCLUDE	"\SRC\LOG.INC"
	INCLUDE	"\SRC\ERROR.INC"
	INCLUDE	"\SRC\UTIL.INC"

	INCLUDE	"\SRC\GAME.INC"
	INCLUDE	"\SRC\TITLE.INC"
	INCLUDE	"\SRC\GETREADY.INC"
	INCLUDE	"\SRC\MEDAL.INC"
	INCLUDE	"\SRC\BIRD.INC"
	INCLUDE	"\SRC\PIPE.INC"
	INCLUDE	"\SRC\SCORELRG.INC"
	INCLUDE	"\SRC\SCORESML.INC"
	INCLUDE	"\SRC\FLOOR.INC"
	INCLUDE	"\SRC\SKY.INC"
	INCLUDE	"\SRC\TICKER.INC"
	INCLUDE	"\SRC\PRESHIFT.INC"
	INCLUDE	"\SRC\HISCORE.INC"
	INCLUDE	"\SRC\DATA.INC"

	;See textsize, datasize and bsssize in listing file(.LST) for game memory sizes
	SECTION	TEXT
textsize
	SECTION	DATA
datasize
	SECTION	BSS
bsssize

;INCLUDE filename
;INCBIN filename
;EVEN
;SECTION TEXT
;SECTION DATA
;SECTION BSS
;.label
;dc.b,dc.w,dc.l
;ds.b <size>,ds.w <size>,ds.l <size>
;name EQU <value>
;name = <value>
;name SET <value> (you can then do set again to change the value)
;RSRESET
;RSSET <offset>
;label1 rs.b 1
;label2 rs.w 1
;label MACRO
;.label\@
;move.w \1,d0
;move.w \2,d1
;ENDM
;ie MARCO 12,3
;REPT <count> (to repeat section 'n' times, DO NOT USE IN MACRO)
;ENDR
;ie REPT 32
;move.l (a0)+,(a1)+
;ENDR
;IFEQ,IFNE,IFGT,IFLT,IFLE,IFGE (all compare to 0, MUST indent directive)
;ENDC
;DEBUG = 1
;ie IFGT DEBUG
;<do debug>
;ENDC
