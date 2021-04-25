* CaseConvert By Carl Sandy 10/9/89
* This program was written with HiSofts Devpac2
gdos	MACRO
	move.w		#\1,-(a7)
	trap		#1
	lea		\2(a7),a7
	ENDM

	OUTPUT		CASE.ACC
	opt 		x-,o+,d-		dump long labels for debugging
	include		gemmacro.s
start	move.l		#mystack,a7		must have a stack!
	appl_init
	move.w		d0,ap_id		store the application id
	menu_register	ap_id,#mymenu

waitforevent
	evnt_mesag	#messagebuf
	move.l		#messagebuf,a0
	move.w		(a0),d0			message type
	cmp.w		#40,d0
	beq		open_acc
	bra.s		waitforevent

open_acc
	clr.l		d6
	movea.l		#pname,a5
	movea.l		#path,a6
	bsr		copy_with_null		Get path

	form_alert	#3,#case_alert		Draw alert box
	move.w		int_out,d6
	move.w		d6,case_flag		Save selection
	cmpi.w		#3,int_out		Cancelled?
	beq.s		waitforevent		Yes, abort

	fsel_input	#path,#fname
	cmpi.w		#0,int_out+2		Cancelled?
	beq		waitforevent		Yes, aboort
	cmpi.w		#1,int_out+2
	bne		waitforevent

	move.l		#path,a3
	addq.l		#2,a3			Ignore drive, we're interested in the path
	move.l		a3,-(a7)
	gdos		$3B,6			Set path

	move.l		#dta,-(a7)
	gdos		$1A,6			Set dta address
	clr.w		-(a7)
	move.l		#fname,-(a7)
	gdos		$4E,8			Search for file
	tst.w		d0			Found?
	bmi		file_nfound		No, display error and abort

	movea.l		#dta,a5
	move.l		26(a5),d7		Get file size and save it
	move.l		26(a5),d6		Get file size and save to d6
	subi.w		#1,d6
	cmpi.l		#51200,d7		File too large?
	bgt		mem_error		Yes, display error

	clr.w		-(a7)
	move.l		#fname,-(a7)
	gdos		$3D,8			Open file for reading
	move.w		d0,d_handle		Save file handle
	move.l		#workspace,-(a7)
	move.l		d7,-(a7)
	move.w		d_handle,-(a7)
	gdos		$3F,12			Read file into memory
	move.w		d_handle,-(a7)
	gdos		$3E,4			Close file

	cmpi.w		#1,case_flag		Uppercase selected?
	beq		uppercase		Yes, convert file to uppercase
	cmpi.w		#2,case_flag		Lower case?
	beq		lowercase		Yes, convert file to lowercase

finish	bsr		backup
	clr.w		-(a7)
	move.l		#fname,-(a7)
	gdos		$3C,8			Open new file for writing
	move.w		d0,d_handle
	move.l		#workspace,-(a7)
	move.l		d7,-(a7)
	move.w		d_handle,-(a7)
	gdos		$40,12			Write to file
	move.w		d_handle,-(a7)
	gdos		$3E,4			Close file
	bra		waitforevent		Abort program

** MISCELLANEOUS ROUTINES
copy	cmpi.b		#0,(a5)
	beq.s		.exit
	move.b		(a5)+,(a6)+
	bra.s		copy
.exit	rts

copy_with_null
	cmpi.b		#0,(a5)
	beq.s		.exit
	move.b		(a5)+,(a6)+
	bra.s		copy_with_null
.exit	clr.b		(a6)
	rts

uppercase
	move.l		#workspace,a5
.loop	cmpi.b		#'A',(a5)	ignore characters less than A
	ble.s		.next
	cmpi.b		#'Z',(a5)	ignore characters less than B
	ble.s		.next
	cmpi.b		#'{',(a5)	ignore characters greater than {
	bhs.s		.next
	cmpi.b		#'[',(a5)	have we encountered: [,\,],^,_, and `
	bls.s		.next
	cmpi.b		#96,(a5)	ignore characters greater than `
	bls.s		.next
	subi.b		#32,(a5)
.next	addq.w		#1,a5
	dbra		d6,.loop
	bra		finish

lowercase
	move.l		#workspace,a5
.loop	cmpi.b		#'A',(a5)
	blt.s		.next
	cmpi.b		#'Z',(a5)
	bgt.s		.next
	addi.b		#32,(a5)
.next	addq.w		#1,a5
	dbra		d6,.loop
	bra		finish

file_nfound
	move.l		#blank,a5
	move.l		#filen,a6
	bsr.s		copy
	move.l		#fname,a5
	move.l		#filen,a6
	bsr		copy
	form_alert	#1,#nfound_alert
	bra		waitforevent

mem_error
	form_alert	#1,#mem_alert
	bra		waitforevent

* fname  = filename
* fname2 = filename with .bak extension
backup	move.l		#blank,a5
	move.l		#bakname,a6
	bsr		copy			Copy blank string to alert box
	move.l		#fname,a5
	move.l		#bakname,a6
	bsr		copy			Copy filename string to alert box
	form_alert	#2,#backup_alert	Draw alert box
	cmpi.w		#2,int_out		Did you select no?
	beq		.leave			Yes, abort
	move.l		#fname,a5
	move.l		#fname2,a6
	bsr		copy_with_null		Copy filename for later use!

	move.l		#fname2,a6
.loop	cmpi.b		#0,(a6)
	beq.s		.exitl
	cmpi.b		#'.',(a6)
	beq.s		.exitl
	addq		#1,a6
	bra.s		.loop

.exitl	move.l		#bak_extension,a5
	bsr		copy_with_null

	move.l		#fname2,-(a7)
	gdos		$41,6			Delete .BAK file
	move.l		#fname2,-(a7)
	move.l		#fname,-(a7)
	clr.w		-(a7)
	gdos		$56,12			Rename file as .BAK
	rts
.leave	move.l		#fname,-(a7)
	gdos		$41,6			
	rts

	SECTION	DATA
mymenu		dc.b	'  CaseConvert',191,0
pname		dc.b	'A:\*.*',0
case_alert	dc.b	'[0][What case would you like your|'
		dc.b	'text file to be converted to ?|'
		dc.b	'Please click on appropriate|'
		dc.b	'radio button to do so.| ]'
		dc.b	'[Upper|Lower|Cancel]',0
blank		dc.b	'              |',0
nfound_alert	dc.b	'[2]['
filen		dc.b	'              |'
		dc.b	'Cannot be found]'
		dc.b	'[ Ok ]',0
mem_alert	dc.b	'[1][Insufficient memory|'
		dc.b	'Your file cannot cannot|'
		dc.b	'have its case changed.]'
		dc.b	'[ Ok ]',0
backup_alert	dc.b	'[2][Would you like|'
bakname		dc.b	'              |'
		dc.b	'to be renamed as a|'
		dc.b	'backup file ?]'
		dc.b	'[ Yes | No ]',0
bak_extension	dc.b	'.BAK',0

	SECTION	BSS
ap_id		ds.w	1
messagebuf	ds.b 	16
		ds.l	100
mystack		ds.w	1
d_handle	ds.w	1
fname		ds.b	13
fname2		ds.b	13
path		ds.b	64
case_flag	ds.w	1
workspace	ds.b	51201
		even
dta		ds.b	44

	IFEQ	__LK
	include	aeslib.s
	ENDC