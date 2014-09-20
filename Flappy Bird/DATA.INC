
;Compressed game data

ENABLELZ77 = 1								;Set to 1 to enable LZ77 data

	SECTION	TEXT

;----------------------------------
;Uncompress LZ77 data to BSS section
datauncompress
	IFGT ENABLELZ77
	lea		datalz77,a0						;Compressed source
	lea		data,a1							;BSS destination
	bsr		lz77uncompress
	ENDC
	rts

;----------------------------------

	SECTION	DATA

datalz77
	INCBIN	"\SRC\DATA\DATA.LZ"				;Compressed 23026 bytes to 6937 bytes
	EVEN

	IFEQ ENABLELZ77

skydayimg
	INCBIN	"\SRC\DATA\SKYDAY.DAT"
skynightimg
	INCBIN	"\SRC\DATA\SKYNIGHT.DAT"
flooranimimg
	INCBIN	"\SRC\DATA\FLORANIM.DAT"
pipetopimg
	INCBIN	"\SRC\DATA\PIPETOP.DAT"
pipebottomimg
	INCBIN	"\SRC\DATA\PIPEBOT.DAT"
pipecapspr
	INCBIN	"\SRC\DATA\PIPECAP.DAT"
pipeskyspr
	INCBIN	"\SRC\DATA\PIPESKY.DAT"
birdanimspr
	INCBIN	"\SRC\DATA\BIRDANIM.DAT"
scorelargespr
	INCBIN	"\SRC\DATA\SCORELRG.DAT"
scoresmallspr
	INCBIN	"\SRC\DATA\SCORESML.DAT"
flappybirdimg
	INCBIN	"\SRC\DATA\FLPYBIRD.DAT"
getreadyimg
	INCBIN	"\SRC\DATA\GETREADY.DAT"
medalsimg
	INCBIN	"\SRC\DATA\MEDALS.DAT"
medalscoreimg
	INCBIN	"\SRC\DATA\MEDALSCR.DAT"
medalbestimg
	INCBIN	"\SRC\DATA\MEDALBST.DAT"
sparklespr
	INCBIN	"\SRC\DATA\SPARKLE.DAT"
tickerimg
	INCBIN	"\SRC\DATA\TICKER.DAT"
tickermsg
	INCBIN	"\SRC\DATA\MSG.DAT"
	EVEN

	ENDC

;----------------------------------

	SECTION	BSS

	IFGT ENABLELZ77

data
skydayimg		ds.b	5200
skynightimg		ds.b	5200
flooranimimg	ds.b	720
pipetopimg		ds.b	144
pipebottomimg	ds.b	120
pipecapspr		ds.b	180
pipeskyspr		ds.b	36
birdanimspr		ds.b	1632
scorelargespr	ds.b	720
scoresmallspr	ds.b	400
flappybirdimg	ds.b	1024
getreadyimg		ds.b	2720
medalsimg		ds.b	1840
medalscoreimg	ds.b	192
medalbestimg	ds.b	336
sparklespr		ds.b	120
tickerimg		ds.b	1536
tickermsg		ds.b	906
	EVEN

	ENDC
