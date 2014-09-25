
;Log file used for debugging

ENABLELOG = 0								;Set to 1 to enable log file

	SECTION	TEXT

;----------------------------------
;Create log file
loginit
	IFGT ENABLELOG
	move.w	#0,-(sp)						;Read-Write
	move.l	#logfilename,-(sp)				;Filename, ie dc.b "LOG.TXT",0
	move.w	#$3c,-(sp)						;Fcreate
	trap	#1
	addq.w	#8,sp
	tst.w	d0								;Test for error code
	bmi		errorfileopen
	move.w	d0,logfilehandle				;Store file handle
	ENDC
	rts

;----------------------------------
;Close log file
logcleanup
	IFGT ENABLELOG
	move.w	logfilehandle,-(sp)
	move.w	#$3e,-(sp)						;Fclose
	trap	#1
	addq.w	#4,sp
	tst.w	d0								;Test for error code
	bmi		errorfileclose
	ENDC
	rts

;----------------------------------
;Write string in a0.l to log file
logstring
	IFGT ENABLELOG
	movem.l	d0-d7/a0-a6,-(sp)
	bsr		logfindstringlength				;d0.l is length of string a0
	bsr		logwrite						;Write data at a0 for length d0.l
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC
	rts

;----------------------------------
;Write value in d0.w to log file as HEX string
logword
	IFGT ENABLELOG
	movem.l	d0-d7/a0-a6,-(sp)
	lea		textword,a0						;Buffer to write digits
	bsr		utilword2text					;Convert d0.w to text string
	lea		textword,a0
	moveq.l	#4,d0
	bsr		logwrite						;Write data at a0 for length d0
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC
	rts

;----------------------------------
;Write value in d0.l to log file as HEX string
loglong
	IFGT ENABLELOG
	movem.l	d0-d7/a0-a6,-(sp)
	lea		textlong,a0						;Buffer to write digits
	bsr		utillong2text					;Convert d0.l to text string
	lea		textlong,a0
	moveq.l	#8,d0
	bsr		logwrite						;Write data at a0 for length d0
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC
	rts

;----------------------------------
;Write newline to log file
lognewline
	IFGT ENABLELOG
	movem.l	d0-d7/a0-a6,-(sp)
	lea		logmsgnewline,a0
	moveq.l	#2,d0
	bsr		logwrite						;Write data at a0 for length d0
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC
	rts

;----------------------------------
;Write line break to log file
loglinebreak
	IFGT ENABLELOG
	movem.l	d0-d7/a0-a6,-(sp)
	lea		logmsglinebreak,a0
	moveq.l	#12,d0
	bsr		logwrite						;Write data at a0 for length d0
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC
	rts

;----------------------------------
;Return length of string, pass string in a0.l, return length in d0.l
logfindstringlength
	IFGT ENABLELOG
	moveq.l	#0,d0
.loop
	tst.b	(a0)+							;Loop and count characters in string
	beq.s	.done
	addq.l	#1,d0
	bra.s	.loop
.done
	suba.l	d0,a0							;Restore a0 back to start of string
	subq.w	#1,a0
	ENDC
	rts

;----------------------------------
;Write data to log file, pass buffer in a0.l and length in d0.l	
logwrite
	IFGT ENABLELOG
	move.l	a0,-(sp)						;Buffer
	move.l	d0,-(sp)						;Length
	move.w	logfilehandle,-(sp)
	move.w	#$40,-(sp)						;Fwrite
	trap	#1
	adda.w	#12,sp
	tst.l	d0								;Test for error code
	bmi		errorfileread
	ENDC
	rts

;----------------------------------

	SECTION	DATA

	IFGT ENABLELOG
logfilename			dc.b	"LOG.TXT",0
logmsgnewline		dc.b	$d,$a,0
logmsglinebreak		dc.b	"----------",$d,$a,0
	EVEN
	ENDC

;----------------------------------

	SECTION	BSS

	IFGT ENABLELOG
logfilehandle		ds.w	1				;Log file handle
	ENDC
