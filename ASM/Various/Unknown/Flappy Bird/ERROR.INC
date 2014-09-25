
;Display run-time errors, including exceptions, to screen
;Also displays PC, SR and PC offset (ie address found in Devpac .LST file) on exceptions
;Test exceptions with;
;	movea.w	#$8200,a0						;Bus error test
;	movep.w	(a0),d0
;	move.l	#10,$1001						;Address error test
;	dc.w	15								;Illegal instruction test
;	divu	#0,d0							;Divide by zero test

	SECTION	TEXT

;----------------------------------
;Set exception vector handlers (ie bus error, address error etc...)
errorsetexceptions
	move.l	#errorbuserror,$8.w
	move.l	#erroraddresserror,$c.w
	move.l	#errorillegalins,$10.w
	move.l	#errordivzero,$14.w
	rts

;----------------------------------
;Read current video address and store
errorreadvideoaddress
	lea		$ffff8201.w,a0					;Video Base Address
	moveq.l	#0,d0
	movep.w	(a0),d0							;Read High+Mid value
	lsl.l	#8,d0							;Low byte is always 0
	move.l	d0,errorscrbse
	rts

;----------------------------------
;Set palette for errors
errorsetpalette
	move.l	#$0f000f00,d0					;RGB Red as long
	lea		$ffff8240.w,a0					;Address of palette
	move.w	#0,(a0)+						;Write full palette as black+reds
	move.w	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)
	rts

;----------------------------------
;Report exception error
errorreportexception
	move.w	#$2700,sr						;Disable interrupts
	
	bsr		errorreadvideoaddress			;Clear current screen
	move.l	errorscrbse,a0
	bsr		utilclearscreen
	bsr		errorsetpalette	

	move.l	errorscrbse,a1					;Show exception text
	lea		errtextexceptionstart,a0
	bsr		fontdraw
	move.l	exceptiontext,a0
	bsr		fontdraw
	lea		errtextend,a0
	bsr		fontdraw

	move.l	exceptionpc,d0					;Write PC, SR and PC offset as hex strings
	lea		errtextpcsr+3,a0
	bsr		utillong2text
	move.w	exceptionsr,d0
	lea		errtextpcsr+16,a0
	bsr		utilword2text
	move.l	exceptionpcoffset,d0
	lea		errtextpcoffset+10,a0
	bsr		utillong2text

	move.l	errorscrbse,a1					;Show PC, SR and PC offset text
	add.l	#16*160,a1
	lea		errtextpcsr,a0
	bsr		fontdraw
	move.l	errorscrbse,a1
	add.l	#24*160,a1
	lea		errtextpcoffset,a0
	bsr		fontdraw

	cmp.w	#0,locationvalid				;Show access location text (on address error)
	beq.s	.nolocation
	move.l	exceptionlocation,d0
	lea		errtextlocation+16,a0
	bsr		utillong2text
	move.l	errorscrbse,a1
	add.l	#32*160,a1
	lea		errtextlocation,a0
	bsr		fontdraw
.nolocation

.loop
	bra.s	.loop
		
;----------------------------------
;Exception vector handlers
errorbuserror
	move.l	#errtextbuserror,exceptiontext
	move.w	#0,locationvalid
	bra.s	errorgroup0
erroraddresserror
	move.l	#errtextaddresserror,exceptiontext
	move.l	2(sp),exceptionlocation			;Read and store access location
	move.w	#1,locationvalid				;Set to show with error report
errorgroup0
	move.w	8(sp),exceptionsr				;Read and store SR, PC and PC offset from start of program
	move.l	10(sp),d0
	move.l	d0,exceptionpc
	sub.l	#start,d0
	move.l	d0,exceptionpcoffset			;Store PC offset from zero (to match .LST file)
	bra		errorreportexception

errorillegalins
	move.l	#errtextillegalinserror,exceptiontext
	bra.s	errorgroup1or2
errordivzero
	move.l	#errtextdivzeroerror,exceptiontext	
errorgroup1or2
	move.w	#0,locationvalid
	move.w	(sp),exceptionsr				;Read and store SR, PC and PC offset from start of program
	move.l	2(sp),d0
	move.l	d0,exceptionpc
	sub.l	#start,d0
	move.l	d0,exceptionpcoffset
	bra		errorreportexception

;----------------------------------
;Report fatal error, pass a0.l as error string to display
errorreport
	move.w	#$2700,sr						;Disable interrupts
	move.l	a0,-(sp)						;Store error to display

	bsr		errorreadvideoaddress			;Clear current screen
	move.l	errorscrbse,a0
	bsr		utilclearscreen
	bsr		errorsetpalette	

	move.l	errorscrbse,a1					;Show error text
	lea		errtextstart,a0
	bsr		fontdraw
	move.l	(sp)+,a0						;Restore error
	bsr		fontdraw
	lea		errtextend,a0
	bsr		fontdraw

.loop
	bra.s	.loop
	
;----------------------------------
;Report fatal error
REPORTERROR	MACRO
	lea		\1,a0
	bra		errorreport
	ENDM

;----------------------------------
;Handle fatal errors
errorfileopen			REPORTERROR	errtextfileopen
errorfileclose			REPORTERROR	errtextfileclose
errorfileseek			REPORTERROR	errtextfileseek
errorfileread			REPORTERROR	errtextfileread
errormemoryalignment	REPORTERROR	errtextmemoryalignment
erroroutofmemory		REPORTERROR	errtextoutofmemory
erroroutoffileslots		REPORTERROR	errtextoutoffileslots
errortailsentinel		REPORTERROR	errtexttailsentinel
errorlz77sizemismatch	REPORTERROR	errtextlz77sizemismatch
errorlz77checksumfail	REPORTERROR	errtextlz77checksumfail
errorikbdpacket			REPORTERROR	errtextikbdpacket
errorsprclearoverlow	REPORTERROR	errtextsprclearoverlow

;----------------------------------

	SECTION	DATA

errtextexceptionstart		dc.b	"??? EXCEPTION - ",0
errtextstart				dc.b	"??? ERROR - ",0
errtextend					dc.b	" ???",0

;Error messages
errtextfileopen				dc.b	"FILE OPEN",0
errtextfileclose			dc.b	"FILE CLOSE",0
errtextfileseek				dc.b	"FILE SEEK",0
errtextfileread				dc.b	"FILE READ",0
errtextmemoryalignment		dc.b	"MEMORY ALIGNMENT",0
errtextoutofmemory			dc.b	"OUT OF MEMORY",0
errtextoutoffileslots		dc.b	"OUT OF FILESLOTS",0
errtexttailsentinel			dc.b	"TAIL SENTINEL",0
errtextlz77sizemismatch		dc.b	"LZ77 SIZE MISMATCH",0
errtextlz77checksumfail		dc.b	"LZ77 CHECKSUM FAIL",0
errtextikbdpacket			dc.b	"IKBD PACKET",0
errtextsprclearoverlow		dc.b	"SPRITE CLEAR OVERLFLOW",0

;Exception messages
errtextbuserror				dc.b	"BUS ERROR",0
errtextaddresserror			dc.b	"ADDRESS ERROR",0
errtextillegalinserror		dc.b	"ILLEGAL INSTRUCTION",0
errtextdivzeroerror			dc.b	"DIVIDE BY ZERO",0
errtextpcsr					dc.b	"PC xxxxxxxx  SR xxxx",0
errtextpcoffset				dc.b	"PC OFFSET xxxxxxxx",0
errtextlocation				dc.b	"ACCESS LOCATION xxxxxxxx",0
	EVEN

;----------------------------------

	SECTION	BSS

exceptiontext			ds.l		1		;Message to display on exception
exceptionsr				ds.w		1		;SR on exception
exceptionpc				ds.l		1		;PC on exception
exceptionpcoffset		ds.l		1		;PC offset from zero on exception (to match .LST)
exceptionlocation		ds.l		1		;Access location on address error exception
locationvalid			ds.w		1		;!=0 when above address is valid
errorscrbse				ds.l		1		;Screen address during error
