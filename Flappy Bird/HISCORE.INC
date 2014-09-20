
;Read/Write high-score value to file using GEMDOS for compatibility
;The high-score is encrypted within a larger buffer and a CRC ensures the
;file cannot be tampered with (loaded values are also checked they are valid BCD)
;The GEMDOS error handler has been redirected to an empty function so file errors
;do not bring up GEMDOS dialogs during the game allowing silent errors

ENABLEHIGHSCORE = 1							;Set to 1 to enable high-score saving
HISCOREBUFSIZE = 128						;Size of high-score buffer
HISCOREOFFSET =	28							;Offset into buffer to store high-score value

	SECTION	TEXT

;----------------------------------
;Initialise high-score
highscoreinit
	move.w	#-1,hiscorefilehandle			;Default to error code (ie <0)
	bra		highscoreread					;Read high-score (does RTS)

	IFGT ENABLEHIGHSCORE
	
;----------------------------------
;Fill high-score buffer with data
highscorefilldata
	lea		datalz77+$1700,a0				;Fill data to copy from
	lea		hiscorebuffer,a1
	bsr		utilrandbyte					;Get random value in d0.b

	moveq.w	#HISCOREBUFSIZE-1,d1
.loop
	add.b	(a0)+,d0
	move.b	d0,(a1)+
	dbra.w	d1,.loop
	rts

;----------------------------------
;Encrypt high-score buffer, pass d0.b as encrypt value
highscoreencryptdata
	lea		hiscorebuffer,a0
	
	moveq.w	#(HISCOREBUFSIZE-2)-1,d1
.loop
	add.b	d0,(a0)+						;Encrypt value with data
	ror.b	#1,d0
	dbra.w	d1,.loop
	rts

;----------------------------------
;Decrypt high-score buffer, pass d0.b as decrypt value
highscoredecryptdata
	lea		hiscorebuffer,a0

	moveq.w	#(HISCOREBUFSIZE-2)-1,d1
.loop
	sub.b	d0,(a0)+						;Decrypt value with data
	ror.b	#1,d0
	dbra.w	d1,.loop
	rts

;----------------------------------
;Calculate CRC and return in d0.w, with end of buffer in a0.l
highscorecalccrc
	lea		hiscorebuffer,a0
	moveq.l	#0,d0							;CRC sum values
	moveq.l	#0,d1
	
	moveq.w	#(HISCOREBUFSIZE-2)-1,d3
.loop
	move.b	(a0)+,d2						;Data byte
	add.b	d2,d0
	add.b	d0,d1
	dbra.w	d3,.loop
	
	lsl.w	#8,d1							;Combine CRC sum values
	or.w	d1,d0							;d0.w is 16-bit CRC
	rts

;----------------------------------
;Check d0.l is a valid BCD value and return -1 if not, 0 if OK
highscorecheckbcd
	move.l	d0,d1							;Don't corrupt d0
	moveq.w	#8-1,d3							;Check all digits
.loop
	move.l	d1,d2							;Check digit is 0...9
	and.w	#$f,d2
	cmp.w	#9,d2
	bgt.s	.error							;Error if outside range
	lsr.l	#4,d1							;Check next digit
	dbra.w	d3,.loop	
	moveq.w	#0,d1							;Return OK
	rts

.error
	moveq.w	#-1,d1							;Return error
	rts
			
;----------------------------------
;Create high-score file
highscorecreatefile
	move.w	#0,-(sp)						;Read-Write
	move.l	#hiscorefilename,-(sp)			;Filename, ie dc.b "FLAPPYBD._HI",0
	move.w	#$3c,-(sp)						;Fcreate
	trap	#1
	addq.w	#8,sp
	move.w	d0,hiscorefilehandle			;Store file handle (-ve on error)
	rts

;----------------------------------
;Open high-score file
highscoreopenfile
	move.w	#2,-(sp)						;Read-Write
	move.l	#hiscorefilename,-(sp)
	move.w	#$3d,-(sp)						;Fopen
	trap	#1
	addq.w	#8,sp
	move.w	d0,hiscorefilehandle			;Store file handle (-ve on error)
	rts

;----------------------------------
;Close high-score file
highscoreclosefile
	move.w	hiscorefilehandle,-(sp)
	move.w	#$3e,-(sp)						;Fclose
	trap	#1
	addq.w	#4,sp							;Ignore error code in d0.w
	move.w	#-1,hiscorefilehandle			;Default to error code (ie <0)
	rts

	ENDC

;----------------------------------
;Read data from high-score file
highscoreread
	IFGT ENABLEHIGHSCORE
	bsr		highscoreopenfile				;Attempt to open file
	bmi.s	.error

	move.l	#hiscorebuffer,-(sp)			;Buffer
	move.l	#HISCOREBUFSIZE,-(sp)			;Length
	move.w	hiscorefilehandle,-(sp)
	move.w	#$3f,-(sp)						;Fread
	trap	#1
	adda.w	#12,sp
	tst.l	d0								;Test for error code
	bmi.s	.error

	lea		hiscorebuffer+HISCOREBUFSIZE,a0	;Read CRC value from buffer
	move.w	-(a0),d0
	move.w	d0,-(sp)
	bsr		highscoredecryptdata			;Decrypt buffer using CRC
	bsr		highscorecalccrc				;Calculate CRC in d0.w
	move.w	(sp)+,d1
	cmp.w	d0,d1							;Do CRC values match?
	bne.s	.error							;No
		
	lea		hiscorebuffer+HISCOREOFFSET,a0	;Read score from buffer
	move.l	(a0),d0
	bsr		highscorecheckbcd				;Check if valid BCD
	bne.s	.error
	move.l	d0,bcdhighscore					;Copy score to game
	
	bsr		highscoreclosefile
.error
	ENDC
	rts

;----------------------------------
;Write data to high-score file
highscorewrite
	IFGT ENABLEHIGHSCORE
	bsr		highscoreopenfile				;Attempt to open file
	bpl.s	.openfile						;If fails, try to create file
	bsr		highscorecreatefile
.openfile
	bmi.s	.error

	bsr		highscorefilldata				;Fill buffer with random data
	lea		hiscorebuffer+HISCOREOFFSET,a0	;Store score in buffer
	move.l	bcdhighscore,(a0)
	bsr		highscorecalccrc				;Calculate CRC
	move.w	d0,(a0)							;Store CRC at end of buffer
	bsr		highscoreencryptdata			;Encrypt buffer using CRC
	
	move.l	#hiscorebuffer,-(sp)			;Buffer
	move.l	#HISCOREBUFSIZE,-(sp)			;Length
	move.w	hiscorefilehandle,-(sp)
	move.w	#$40,-(sp)						;Fwrite
	trap	#1
	adda.w	#12,sp
	tst.l	d0								;Test for error code
	bmi.s	.error

	bsr		highscoreclosefile
.error
	ENDC
	rts

;----------------------------------

	SECTION	DATA

hiscorefilename
	dc.b	"FLAPPYBD._HI",0
	EVEN

;----------------------------------

	SECTION	BSS

hiscorefilehandle	ds.w	1				;File handle
hiscorebuffer		ds.b	HISCOREBUFSIZE	;Buffer to read/write which holds encrypted score
