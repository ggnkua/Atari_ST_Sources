		modul '\f68k\SLOADER.TOS'
		OPT k+,d+
*************************************************************************
*									*
*	loader for F68K 						*
*									*
*	for Atari ST							*
*									*
*************************************************************************
*									*
* Warning!!!								*
*									*
* This loader uses a protocol which is not supported by the actual      *
* version of F68K. 							*
* Please refer to the manual to make this old loader run again!!	*
*									*
*************************************************************************



		TEXT
TIBlength	EQU $1000	;space between TIB and R0
sys_size	EQU $010000	;total place for code
data_size	EQU $020000	;total place for data

* standard ST program header, free memory etc.
		move.l	#0,-(SP)
		move.w	#$20,-(SP)
		trap	#1		;supervisor mode
		addq.l	#6,SP

		movea.l SP,A5
		movea.l 4(A5),A5
		move.l	$0C(A5),D0
		add.l	$14(A5),D0
		add.l	$1C(A5),D0	;programm length

		move.l	D0,D1
		add.l	A5,D1
		and.l	#-2,D1
		movea.l D1,SP		;set returnstack

		move.l	D0,-(SP)
		move.l	A5,-(SP)
		clr.w	-(SP)
		move.w	#$4A,-(SP)
		trap	#1		;mshrink
		adda.l	#12,SP
***************************************************************


		clr.w	-(SP)
		move.l	#file,-(SP)
		move.w	#$3D,-(SP)
		trap	#1		;open F68K image-file
		addq.l	#8,SP
		move.w	D0,handle

		move.l	#fileheader,-(SP)
		move.l	#28,-(SP)
		move.w	handle,-(SP)
		move.w	#$3F,-(SP)
		trap	#1		;load header into buffer
		lea	$0C(SP),SP


		move.l	#codeseg,-(SP)
		movea.l #fileheader,A0
		move.l	2(A0),-(SP)	;length of textsegment
		move.w	handle,-(SP)
		move.w	#$3F,-(SP)
		trap	#1		;load textsegment into buffer
		lea	$0C(SP),SP

		move.l	#dataseg,-(SP)
		movea.l #fileheader,A0
		move.l	6(A0),-(SP)	;length of datasegment
		move.w	handle,-(SP)
		move.w	#$3F,-(SP)
		trap	#1		;load datasegment into buffer
		lea	$0C(SP),SP


*****************************************************************
*	ask user for file, which is used as second device	*
*****************************************************************
ask_name:	move.l	#msg,-(SP)
		move.w	#9,-(SP)
		trap	#1		;show message
		addq.l	#6,SP

		move.l	#scrfile-2,-(SP)
		move.w	#10,-(SP)
		trap	#1		;ask filename
		addq.l	#6,SP
		movea.l #scrfile-2,A0
		tst.b	1(A0)		;nothing given in
		beq	defaultsource	;use default
		addq.l	#1,A0
		clr.l	D0
		move.b	(A0)+,D0
		move.b	#0,0(A0,D0.w)	;set NULL

defaultsource:	move.l	#crlf,-(SP)
		move.w	#9,-(SP)
		trap	#1		;new line
		addq.l	#6,SP


open_source:	clr.w	-(SP)
		move.l	#scrfile,-(SP)
		move.w	#$3D,-(SP)
		trap	#1		;open F68K.SCR source-file
		addq.l	#8,SP
		move.w	D0,handle

		move.l	SP,ret		;save returnstackpointer


*********************************************************************
* push memory description
		move.l	#dataseg,D1	;start of data segment
		addi.l	#data_size,D1	;end of data segment

		move.l	D1,-(SP)	;F68K shall use that address as returnstack
* push I/O-Adresses
		move.l	#roottable,-(SP)
		move.l	#writesys,-(SP)
		move.l	#readsys,-(SP)
		move.l	#r_wtable,-(SP)
		move.l	#key_questtable,-(SP)
		move.l	#keytable,-(SP)
		move.l	#emittable,-(SP)

		subi.l	#TIBlength,D1
		move.l	D1,-(SP)	;this is the TIB
		move.l	D1,-(SP)	;same as data-stack base
		move.l	#data_size,-(SP)
		move.l	#sys_size,-(SP)
		move.l	#dataseg,-(SP)	;databot
		move.l	#codeseg,-(SP)	;sysbot

		movea.l #codeseg,A0
		jsr	(A0)		;let the fun begin

		movea.l ret,SP		;restore returnstack

		move.w	outhandle,-(SP)
		move.w	#$3E,-(SP)	;GEMDO: FCLOSE	outfile
		trap	#1
		addq.l	#4,SP
		clr.w	-(SP)
		trap	#1		;back to GEMDOS


*************************************************************************
*	I/O-routines							*
*************************************************************************
* 1.) KEY ( -- char )
key:		move.w	#2,-(SP)	;device
		move.w	#2,-(SP)	;Fkt.: Bconin
		trap	#13		;Bios
		addq.l	#4,SP	
		rts			;character in D0

* 2.) EMIT ( char -- )
emit:		move.w	6(a7),-(sp)	     
		move.w	#2,-(SP)	;Device
		move.w	#3,-(SP)	;Fkt.: Bconout
		trap	#13		;Bios
		addq.l	#6,SP
		rts

* 3.) KEY? ( -- flag )
key_quest:	move.w	#2,-(SP)
		move.w	#1,-(SP)
		trap	#13
		addq.l	#4,SP
		rts


* 4.) R/W ( addr block r/w-flag -- flag )
* offsets:  4(sp) 8(sp) $c(sp)	    d0
r_w:		move.l	8(sp),D0
		cmp.l	#320,D0 	;R/W from/to floppy?
		bmi	r_w_floppy
		subi.l	#320,D0 	;block 320 is block 0 in file
		mulu	#2048,D0	;offset into file

		move.l	D0,-(SP)	;save d0 on stack
		clr.w	-(SP)		;seekmode: from beginning
		move.w	handle,-(SP)
		move.l	D0,-(SP)	;offset
		move.w	#$42,-(SP)	;GEMDOS: Fseek
		trap	#1		;call GEMDOS
		lea	$0A(SP),SP	;empty stack
		cmp.l	(SP)+,D0
		bne	harderr

		move.l	4(sp),-(SP)	;buffer    *offset +4
		move.l	#2048,-(SP)	;count	   *	   +8
		move.w	handle,-(SP)	;handle    *	   +a
		tst.l	($c+$a)(A6)
		beq	read_hard
		move.w	#$40,-(SP)	;GEMDOS: Fwrite
		bra	do_r_w_hard
read_hard:	move.w	#$3F,-(SP)	;GEMDOS: Fread
do_r_w_hard:	trap	#1		;call GEMDOS
		lea	$0C(SP),SP
		cmp.l	#2048,D0	;read/written?
		bne	harderr
*		 lea	 $0C(A6),A6
		move.l	#-1,d0		;true
		rts
harderr:	
*		lea	$0C(A6),A6	;clear stack
		clr.l	d0	     ;false
		rts

r_w_floppy:	move.w	#4,-(SP)	;number of blocks to be read *+2
		clr.w	-(SP)		;side 0 as default	     *+4
		move.w	(6+$A)(sp),D0	;blocknumber
		lsl.l	#2,D0		;* 4
		andi.l	#$FFFF,D0
		divu	#16,D0
		move.w	D0,D1		;this is the track
		swap	D0
		btst	#3,D0		;>= or < as 8
		beq	side0
		addq.w	#1,(SP) 	;switch to side1
side0:		move.w	D1,-(SP)	;the track		     *+6
		andi.l	#7,D0		;mask sector number	     
		addq.l	#1,D0		;sector count starts with 1
		move.w	D0,-(SP)	;push sector		     *+8
		clr.w	-(SP)		;device:  floppy A:	     *+a
		clr.l	-(SP)		;not used		     *+e
		move.l	($e+4)(sp),-(SP);buffer 		     *+12
		tst.l	($c+$12)(sp)	;test r/w-flag
		beq	read_flop
		move.w	#9,-(SP)	;Xbios: Flopwr
		bra	flopr_w
read_flop:	move.w	#8,-(SP)
flopr_w:	trap	#14
		lea	$14(SP),SP
*		addq.l	#8,A6		;clear datastack
		addq.l	#1,D0
*		move.l	D0,-(A6)
		rts

* 5.) READSYS ( addr count -- flag )
readsys:	*addq.l  #8,A6		 ;to be implemented
		moveq.l  #0,d0
		rts

* 6.) WRITESYS ( addr count -- flag )
* offsets:	 4(sp) 8(sp)	d0
writesys:	tst.w	first		;writing first time?
		bne	nocreate	;file has not to be created
		clr.w	-(SP)
		pea	f68kout
		move.w	#$3C,-(SP)	;GEMDOS: FCREATE
		trap	#1
		addq.l	#8,SP
		move.w	D0,outhandle
		move.w	#-1,first
nocreate:	move.l	(sp),-(SP)	;addr		*+4
		move.l	(4+8)(sp),-(SP) ;count
		move.w	outhandle,-(SP)
		move.w	#$40,-(SP)	;GEMDOS: FWRITE
		trap	#1
		lea	$0C(SP),SP
		move.l	8(sp),D1
		cmp.l	D0,D1		;compare and drop count
		beq	good
		clr.l	d0	      ;FALSE-flag
		rts
good:		move.l	#-1,d0	      ;TRUE-flag
		rts







		DATA

roottable:	DC.L 2		;2 devices exist
		DC.L 320	;device 0 starts with block 320
		DC.L 500	;and has 500 blocks
		DC.L 0		;device 1 starts with block 0
		DC.L 320	;and has 320 blocks

keytable:	DC.L 1
		DC.L key

emittable:	DC.L 1
		DC.L emit

key_questtable: DC.L 1
		DC.L key_quest

r_wtable:	DC.L 1
		DC.L r_w

file:		DC.B 'f68k.img',0
		EVEN
f68kout:	DC.B 'f68k.out',0
		EVEN
msg:		DC.B 'Enter source file for device #0.',13,10
		DC.B 'Default is DEVICE0.SCR : ',0
		EVEN
crlf:		DC.B 13,10,0
		EVEN
		DC.B 128,0	;place for string info
scrfile:	DC.B 'device0.scr',0
		DS.B 116

first:		DC.W 0		;flag for F68K system-write


		BSS
ret:		DS.L 1		;returnstack
handle: 	DS.W 1		;filehandle of F68K file
outhandle:	DS.W 1		;filehandlr for F68K system-write
fileheader:	DS.B 28 	;standard GEMDOS program header
codeseg:	DS.B sys_size
dataseg:	DS.B data_size
		DS.L 10 	;place for returnstack
		END
