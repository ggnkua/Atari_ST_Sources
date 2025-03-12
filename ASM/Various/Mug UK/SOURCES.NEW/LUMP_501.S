;+-------------------------------------------------------+
;| Lump/Chunk Loader for Automation Packer v5.01         |
;|                                                       |
;| Re-assembled for a readable source listing by IWWWTTI |
;|                                                       |
;| Update no. 3 - 7th-9th October 1991                   |
;+-------------------------------------------------------+
;
; When I first got hold of this source it was a disassembly
; of a lump/chunk loader - so I patched the v5.01 depack
; routine in with the old lump-chunk routine for v2.51 !!!
;
; I've also added a few conditional assembly bits just to show
; off my limited 68000 knowledge !!!
;
; Improvemnts on original v5.01 lump/chunk routine;

; 1) The source listing is readable !!
; 2) Text ON/OFF
; 3) Wait for key ON/OFF
; 4) Set Low resolution ON/OFF
; 5) Restore TRAP #1 original address after quitting (no bombs !!)
;    Ideal for GEM-based programs !!
; 6) Colour Flash ON/OFF (also 3 different flashes - oo-er!!)
;
; If you don't want to do a lump file, set the 'lump' equ to
; be no and change the 'chunk' equ to be yes - or vice versa.
;

	opt	o+,ow-

yes	equ	1
no	equ	0

buff_len	equ	4096	; put chunk size used or 0
maxfiles	equ	10
buffdhead	equ	"AU5$"
normlhead	equ	"AU5!"
chnkhead	equ	"AU5C"

;
; Conditional Assembly Bits - change to 'yes' or 'no'
;

lump	equ	yes	; lump depack files
chunk	equ	no	; chunk depack files only

text_on	equ	yes	; print text ??
wait_on	equ	yes	; wait for key ??
low_res	equ	no	; low resolution
restore84	equ	no	; upon quit $84 is restored ??
flash	equ	yes	; colour flashes while depacking

; If you look at the 'flash' section, you will find three F/X options
; and two of them are REMmed out.  Use your own or one of these
; three pre-prepared ones - it's up to you !!!!

	bra	main

; The following table SHOULD contain all the possible lump files
; on a disk.  Eg. if you have a two disk game, and both disks are
; in seperate files, then enter each filename here.  Make sure that
; they are exactly 16 characters in length !!
;

	ifne	lump
srchs	dc.b	"lumpfile.lmp",0,0,0,0 		; lump files
	endc

	ifne	chunk
srchs	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; chunk files
	endc

endsrch	dc.w	0

;
; The original loader goes in here
;
execfile dc.b "loader.exe",0
	even
;
; Text message
;
	ifne text_on
		;1234567890123456789012345678901234567890 - 40 chars

text	dc.b	27,"E",27,"f",27,"w"	
	dc.b	"A GAME",13,10,10
	dc.b	"LUMPY-CHUNKY v5.01 PACKED !!",13,10
	dc.b	"ENHANCED LOADER by IWWWTTI !!",13,10,10
	dc.b 0
	endc
	
main	movea.l	4(a7),a5
	move.l $c(a5),d0
	add.l $14(a5),d0
	add.l $1c(a5),d0
	add.l #$200,d0
	add.l #buff_len,d0	;add buffer length
				;take out if absolute address
				;buffer

	move.l d0,-(sp)
	move.l a5,-(sp)
	move.l #$4a0000,-(sp)
	trap #1			;mshrink
	lea $c(a7),a7

	ifne	low_res		; low resolution ???
	clr.w	-(a7)
	pea	-1
	pea	-1
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	endc

	ifne	text_on
	dc.w	$a00a
	pea	text
	move.w	#9,-(a7)
	trap	#1		;text print
	dc.w	$a009
	endc

	ifne	wait_on
	move.w	#7,-(a7)
	trap	#1		;wait for key
	addq.l	#8,a7
	endc

cont	move.l	#buff_start,buff_add	;set buffer start address
					;change buff_start to absolute
					;address if needed
	move.l	#srchs,ftablestrt
	move.l	#endsrch,ftableend

	bsr.s	super
	move.l	$84.w,tr1		;save old trap1 address
	move.l	#T1,$84.w		;set trap1 to my code
	bsr.s	user

stkk	clr.l	in_use			;so first read gets file
	move.l	#stkk,a7		;so back to gem O.K.
	move.l	#srchs,file_found
	move.l	#-22,file_locn
	clr.l 	$60000
	pea	$60000
	move.l (a7),-(sp)
	move.l 	#execfile,-(sp)
	move.l 	#$4b0000,-(sp)
	trap 	#1			;run next program
	lea 16(a7),a7
;
; Ensure programs do not bomb out when you quit them !!
; eg. GEM-based programs/utilities etc. by turning the 'restore84'
; flag to 'yes', else leave it at 'no' if the program does not
; have a quit feature - other than the reset-button !!
;

	ifne	restore84	; Yes we want to restore $84
	bsr.s	super
	move.l	tr1(pc),$84.w	; reinstall old $84 vector
	bsr.s	user
	endc

	clr.w 	-(sp)		; back to desktop
	trap 	#1

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,ssp
	rts

user	move.l ssp,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	rts

;multi file read 1st October 1989
;fix 11th October 1989 for decode from odd address
;bastard bug to find

T1		tst.w	inside		;check if called from inside trap1
		bne	bye		;yes then exit
		MOVEM.L A0-A6/d0-d7,reg	
		movea.l	a7,a1
		addq.l 	#6,a1
		move.w 	(a7),d0
		btst 	#$d,d0		;check for which stack data
		bne.s 	ok1		;is in. if no then its in super
		move.l 	usp,a1		;else its the user stack

ok1		cmpi.w 	#$3d,(a1)	;file open
		beq	openup

		cmpi.w	#$3b,(A1)
		beq	nofolders

		cmpi.w	#$3f,(a1)	;file read
		beq	read

		cmpi.w	#$3e,(a1)	;file close
		beq	close

		cmpi.w	#$3c,(a1)	;file create
		beq	create

		cmpi.w	#$40,(a1)	;file write
		beq	write

		cmpi.w	#$42,(a1)	;file seek
		beq	seek

		cmpi.w	#$4e,(a1)	;f_first
		beq	ffirst

		cmpi.w	#$4f,(a1)
		beq	fnext		;guess!!

		cmpi.w	#$45,(a1)	;f_dup
		beq	fdup

		cmpi.w	#$46,(a1)	;f_force
		beq	fforce

open		movem.l 	reg(pc),a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0
nofolders	movem.l reg(pc),a0-a6/d0-d7
		clr.l d0
		rte
openup		move.w	#1,inside	;do normal traps
		bsr	emptyone
;d0=my pretend file handle

		move.l	d0,d7		;save handle
		move.l	d0,d6		;ditto
		move.l	a0,a5		;save location of empty slot
		move.l	2(a1),a6	;save file name address

;open file
		move.w	6(a1),-(a7)	;bastard bug for standards
		move.l	a6,-(a7)
		move.w	#$3d,-(a7)
		trap	#1		;f_open
		addq.l	#8,a7

		tst.l	d0
		bpl	what_error	;in case file not there
******************************************************************
*insert for lumpy
*input	d7=fake handle
*	a6=filename
*trashes almost everything
*output	d0=error or fake filehandle
*lets rockkkkkkkkkkkkkkkkkkkkkkkkkkkkkk!
******************************************************************
		clr.l	d6
		move.l	a6,a0		;get filename
		move.l	ftablestrt,a4	;set up for full file search
		bsr	find_it_if_pos
		tst.l	d0		;did we find it
		bmi	error		;no so error
		lea	real_hand,a1	;save real handle
		move.l	d7,d6		;get fake handle
		lsl.l	#2,d6
		move.l	d0,(a1,d6.w)
		lea	so_read,a1	;show none read so far
		clr.l	(a1,d6.w)
		lea	chunked,a1
		move.l	a4,(a1,d6.w)	;show its chunked
		lea	f_lengths,a1	;save length
		move.l	14(a0),(a1,d6.w)
		lea	offsets,a1
		move.l	18(a0),(a1,d6.w);save init offset
		clr.l	d0
		move.l	buff_add,a0
		move.w	200(a0),d0
		mulu	#22,d0
		addq.l	#2,d0
		and.l	#$ffff,d0
		add.l	d0,(a1,d6.w)	;add header offset
		move.l	d7,d6		;save fake fname for exit
		lsl.l	#5,d7		;times 32
		lea	f_names,a0
		add.l	d7,a0		;add offset to right place
		move.l	a6,a2
dackdos		move.b	(a2)+,(a0)+
		bne.s	dackdos		;copy till zero
		bra	not_good

what_error	move.l	d0,d4		;save real handle

** insert 1 for uncom file read

		clr.l	i_buff		;clear buffer
		pea	i_buff
		move.l	#8,-(a7)	;number of bytes=8
		move.w	d4,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;f_read
		lea	12(a7),a7
		clr.w	-(a7)		;type 0 (absolute)
		move.w	d4,-(a7)	;file handle
		clr.l	-(a7)		;start of file
		move.w	#$42,-(a7)
		trap	#1		;f_seek
		lea	10(a7),a7

;copy filename
		move.l	a6,a4		;save address of name
		moveq.l	#31,d0
c_loop		move.b	(a6)+,(a5)+
		dbra	d0,c_loop

		lsl.l	#2,d7		;times4
		lea	so_read,a0
		move.l	#0,(a0,d7.w)	;clear amount read so far
		lea	offsets,a0
		move.l	#0,(a0,d7.w)	;clear file offset as normal at start

		cmp.l	#buffdhead,i_buff ;check if file buff/compacted
		beq.s	nermal		;yes so set up correct handler
stn_file	lea	real_hand,a0	;start of real handles array
		move.l	d4,(a0,d7.w)	;save real handle
		lea	chunked,a0
		move.l	#0,(a0,d7.w)	;show file not chunked
		cmp.l	#chnkhead,i_buff	;check if file chunked
		bne	not_good
		move.l	#-1,(a0,d7.w)	;set chunked flag to true
		lea	f_lengths,a0
		move.l	i_len,(a0,d7.w)		;save file length in array
		bra	chk_same	;check if same file loaded


;copy file name to storage

nermal		lea	f_lengths,a0
		move.l	i_len,(a0,d7.w)		;save file length in array
		lea	real_hand,a0
		move.l	#-1,(a0,d7.w)		;show handle is fake by setting to -1
		lea	chunked,a0
		move.l	#0,(a0,d7.w)		;show its not chunked

;close file as finished

		move.w	d4,-(a7)
		move.w	#$3e,-(a7)
		trap	#1		;f_close
		addq.l	#4,a7

;already loaded file check

chk_same	lea	file_loaded_name,a5	;get saved files name
still_same	tst.b	(a4)			;check if end of new f_name
		beq.s	same_file		;yes then maybe files same
		cmp.b	(a4)+,(a5)+		;check name against saved one
		beq.s	still_same		;same so check next byte
		bra.s	not_good		;different so dont worry
same_file	tst.b	(a5)			;check eofname in saved name
		bne.s	not_good		;different so dont worry
		move.l	d6,in_use		;same name so save handle

not_good	clr.w	inside		;my traps again
		move.l	d6,-(a7)	;d6 contains fake file handle
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;give back my handle
		rte

read		clr.l	d0
		move.w	2(a1),d0	;get handle
		tst.w	d0
		bmi.s	stan_f
		move.w	d0,d1
		lsl.l	#2,d1		;*4
		lea	real_hand,a0
		move.l	(a0,d1.w),d2	;get real handle
		cmp.w	#$ffff,d2	;is file compacted?
		beq	cor_blimy	;yes so buffered read
		lea	chunked,a0
		move.l	(a0,d1.w),d3	;check if chunked
		tst.l	d3
		bne	sodding_chunk
stan_f		move.w	#1,inside	;my traps out d window
		move.l	8(a1),d7	;get whereto
		move.l	d7,-(a7)	;whereto
		move.l	4(a1),-(a7)	;number of bytes
		move.w	d2,-(a7)	;file handle
		move.w	#$3f,-(a7)
		trap	#1		;f_read
		lea	12(a7),a7
		move.l	d0,d5		;save count of bytes read
		move.l	d7,a0		;whereto
		clr.l	d0
		move.b	(a0),d0
		lsl.w	#8,d0
		move.b	1(a0),d0
		swap	d0
		move.b	2(a0),d0
		lsl.w	#8,d0
		move.b	3(a0),d0	;gets 4 bytes from a0
		cmp.l	#normlhead,d0	;check for nonbuff pack
		bne	titter1		;normal file
		lea	-200(a0),a1	;destination
		move.l	a1,a2
		lea	tmp_sav,a3
		move.l	#199,d1
firk1		move.b	(a2)+,(a3)+
		dbra	d1,firk1	;save 200 bytes below
firk2		move.b	(a0)+,(a1)+
		subq.l	#1,d5
		bne.s	firk2		;copy down
		move.l	a2,a1
		lea	-200(a1),a0
		move.l	a0,-(a7)	;save start
		bsr	ice_depack
		move.l	(a7)+,a0
		lea	tmp_sav,a1
		move.l	#199,d1
firk3		move.b	(a1)+,(a0)+
		dbra	d1,firk3	;copy bytes back
		bra	titter1		;get out

cor_blimy	cmp.l	in_use,d0
		beq	all_in
		move.l	a1,a5		;preserve stack
		move.w	#1,inside	;normal trap code
		move.l	d0,in_use	;tell system this file is in use
		lsl.l	#5,d0		;d0=d0*60
		lea	f_names,a0
		add.l	d0,a0		;get correct filename
		move.l	a0,a1		;preserve value
		lea	file_loaded_name,a2
		moveq.w	#31,d0
save_name	move.b	(a1)+,(a2)+
		dbra	d0,save_name

		clr.w	-(a7)
		move.l	a0,-(a7)
		move.w	#$3d,-(a7)
		trap	#1		;f_open
		addq.l	#8,a7
		move.w	d0,d6		;save handle
		move.l	buff_add,-(a7)
		move.l	#buff_len,-(a7)
		move.w	d0,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;f_read file into buffer
		lea	12(a7),a7
		move.w	d6,-(a7)
		move.w	#$3e,-(a7)
		trap	#1		;f_close
		addq.l	#4,a7
		clr.w	inside		;my traps again
		move.l	buff_add,a0	;source of depack
		lea	200(a0),a1	;=source +200
		move.l	4(a0),d7	;length
		bsr	ice_depack
read_in		move.l	a5,a1		;put stack back in a1
all_in		move.l	4(a1),d0	;bytes to move
		move.l	d0,d5
		move.l	8(a1),a0	;whereto
		move.l	in_use,d1
		lsl.l	#2,d1		;*4
		lea	so_read,a2
		lea	f_lengths,a3
		move.l	(a2,d1.w),d2	;current offset
		move.l	(a3,d1.w),d3	;length of this file
		move.l	buff_add,a1	;get buffer start
		lea	200(a1),a1	;add depack offset
		add.l	d2,a1		;add current offset
do_it		move.b	(a1)+,(a0)+	;move a byte
		addq.l	#1,d2
		cmp.l	d2,d3		;check if past end of file
		blt.s	past_end
		subq.l	#1,d0		;number left to copy -1
		bne.s	do_it		;have we copied all?
		bra.s	wibble
past_end	move.l	d3,d2		;if past end then offset=end
wibble		move.l	d2,(a2,d1.w)	;save new offset
		sub.l	d0,d5		;get number of bytes read
		bra	titter1

sodding_chunk	move.w	#1,inside
		cmp.l	in_use,d0
		beq	all_in2
		move.l	d0,in_use
		lea	chunked,a0
		move.l	(a0,d1.w),a5
		cmp.l	file_loaded_name,a5
		beq	all_in2
		move.l	a1,a5		;preserve stack
		lsl.l	#5,d0		;*60
		lea	f_names,a1
		add.l	d0,a1		;get this files name
		lea	file_loaded_name,a2
		moveq.w	#31,d0
save_name2	move.b	(a1)+,(a2)+	;save filename
		dbra	d0,save_name2
		move.l	d2,d7		;save real handle
*d2=real handle
		clr.w	-(a7)		;type 0 (absolute)
		move.w	d7,-(a7)	;file handle
		clr.l	-(a7)		;start of file
		move.w	#$42,-(a7)
		trap	#1		;f_seek
		lea	10(a7),a7
*get header
		pea	i_buff
		move.l	#1024,-(a7)
		move.w	d7,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;f_read file into buffer
		lea	12(a7),a7

		move.l	i_len,d0
		move.l	chnksize,d2
		subq.l	#1,d2
		eor.l	#-1,d2
		and.l	d2,d0
		move.l	d0,numb_chnk

		move.l	#-1,mini
		move.l	a5,a1		;restore stack
		move.l	d7,d2		;restore real handle
		move.l	in_use,d0	;restore file handle
		move.l	d0,d1
		lsl.l	#2,d1		;restore 4* handle
all_in2		lea so_read,a0
		move.l	(a0,d1.w),d4	;get current offset
		move.l	4(a1),d5	;number of bytes
		move.l	d4,d7
		add.l	d5,d7		;calculate final offset
		cmp.l	d4,d7		;check for -ve bytes to read
		blt.s	nicensafe
		lea	f_lengths,a0
		cmp.l	(a0,d1.w),d7	;check if past end of file
		blt	no_clip
nicensafe	move.l	(a0,d1.w),d7
no_clip		sub.l	d4,d7
		move.l	d7,d5		;now contains #of bytes to xfer
		move.l	8(a1),a4	;whereto
		move.l	a4,a5
		add.l	d5,a5		;end locn
		sub.l	#1,a5
		tst.l	d5
		beq	titter1		;if no bytes to read
		lea	so_read,a0
		lea	offsets,a1
		move.l	(a1,d1.w),d0
		add.l	d0,(a0,d1.w)
startxfer	move.w	d2,tmp_read
		move.l	d5,d2
		lea	so_read,a0
		move.l	(a0,d1.w),d0
		move.l	d0,a2
		move.l	a2,a3
		move.l	chnksize,d3
		subq.l	#1,d3
		and.l	d3,d0
		move.l	d3,d7
		move.l	d0,d6
		eor.l	#-1,d3
		move.l	a2,d0
		and.l	d3,d0
		move.l	d0,d4
		add.l	d5,a3
		move.l	a3,d5
		and.l	d7,d5
		move.l	a3,d0
		and.l	d3,d0
		move.l	d0,d3
		sub.l	d4,d0
		move.l	chnksize,d7
		divu	d7,d0
		move.l	d0,d7
**********
*will dis work?
**********
		move.l	d4,d0
		move.l	chnksize,d2
		lea	restofbuff,a0
		cmp.l	numb_chnk,d0
		bne.s	not_last
		divu	d2,d0
		lsl.l	#2,d0
		move.l	i_len,d1
		bra.s	clipped_it
not_last	divu	d2,d0
		lsl.l	#2,d0
		move.l	4(a0,d0.w),d1
clipped_it	move.l	(a0,d0.w),d2
		move.l	d1,d0
		sub.l	d2,d0

* d0=number of bytes to read
* d1=offset of next chunk
* d2=offset of chunk

		cmp.l	mini,d4
		beq	bit_in
		move.l	d4,mini
		clr.w	-(a7)
		move.w	tmp_read,-(a7)
		move.l	d2,-(a7)
		move.l	d0,d2		;save #of bytes
		move.w	#$42,-(a7)
		trap	#1
		lea	10(a7),a7

		move.l	buff_add,-(a7)
		move.l	d2,-(a7)
		move.w	tmp_read,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		move.l	buff_add,a0
		lea	200(a0),a1
		bsr	chuck_up
		bra.s	you_what
bit_in		tst.l	d7
		beq	no_middle	;incase last chunk

		clr.w	-(a7)
		move.w	tmp_read,-(a7)
		move.l	d1,-(a7)
		move.w	#$42,-(a7)
		trap	#1
		lea	10(a7),a7

*check if less than two chunks

you_what	cmp.l	#1,d7
		ble	no_middle
		move.l	d7,-(a7)	;why not
		lsl.l	#2,d7		;times 4 (d7 not needed again)
		move.l	d4,d0
		move.l	chnksize,d2
		lea	restofbuff,a0
		divu	d2,d0
		lsl.l	#2,d0
		move.l	4(a0,d0.w),d1	;next chunk offset
		add.l	d7,a0
		move.l	(a0,d0.w),d2	;last offset
		move.l	d2,d0
		sub.l	d1,d0		;give #of bytes
		move.l	a4,a6
		add.l	chnksize,a6
		sub.l	d6,a6		;get load position of midle
		lea	-200(a6),a3
		move.l	a3,d7
		move.l	#199,d1
		btst	#0,d7		;odd?
		beq.s	no_199
		addq.l	#1,a3		;quicker loading
		subq.l	#1,d1
no_199		move.l	(a7),d7		;get d7 back
		move.l	d6,-(a7)
		move.l	chnksize,d6
		mulu	d6,d7
		move.l	(a7)+,d6
		add.l	d7,a6		;get dest
		move.l	(a7)+,d7	;get d7 back
		lea	tmp_sav,a0
		move.l	a3,a1
		move.l	d1,d2		;number of bytes to save
sav_a_bit	move.b	(a1)+,(a0)+
		dbra	d1,sav_a_bit	;saves 199 or 200 bytes
		move.l	a3,-(a7)	;where
		move.l	d0,-(a7)	;hownmany
		move.w	tmp_read,-(a7)	;handle
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7

		lea	restofbuff,a2
		move.l	d4,d0
		move.l	d6,-(a7)
		move.l	chnksize,d6
		divu	d6,d0
		move.l	(a7)+,d6
		lsl.l	#2,d0
		addq.l	#4,d0		;next chunk
		add.l	d0,a2		;calc init chunk offset
		move.l	d7,-(a7)
		lsl.l	#2,d7		;final chunk offset
		subq.l	#4,d7

**now must depack BACKWARDS!!!
		sub.l	chnksize,a6
dis_bits	sub.l	chnksize,a6	;back a chunk
		subq.l	#4,d7		;back a chunk
		move.l	a3,a0		;base load
		move.l	(a2,d7.w),d0	;calc offset
		sub.l	(a2),d0		;from start
		add.l	d0,a0		;data to depack start
		move.l	a6,a1		;destination
		bsr	chuck_up	;depack and copy if neces
		tst.w	d7
		bne.s	dis_bits
		move.l	(a7)+,d7

*that should work but then so should the poll tax

		lea	tmp_sav,a0
		move.l	a3,a1
		move.l	d2,d1		;number of bytes to save
bit_back	move.b	(a0)+,(a1)+
		dbra	d1,bit_back	;restores 199 or 200 bytes


*now copy first sector info

no_middle	move.l	buff_add,a0
		lea	200(a0),a0
		addq.l	#1,a5
		add.l	d6,a0
		move.l	a4,a1
do_the_copy	cmp.l	a1,a5
		beq.s	fnshed
		cmp.l	chnksize,d6
		beq.s	fnshed
		move.b	(a0)+,(a1)+
		addq.l	#1,d6
		bra.s	do_the_copy

fnshed		subq.l	#1,a5
		tst.l	d7
		beq.s	christknows
		tst.l	d5
		beq.s	christknows
		move.l	d3,mini
		move.l	chnksize,d3
		mulu	d3,d7
		move.l	mini,d3
		move.l	buff_add,-(a7)
		move.l	chnksize,-(a7)
		move.w	tmp_read,-(a7)
		move.w	#$3f,-(a7)
		trap	#1
		lea	12(a7),a7
		move.l	buff_add,a0
		lea	200(a0),a1
		bsr	chuck_up
		move.l	buff_add,a0
		lea	200(a0),a0
		move.l	a5,a1
		addq.l	#1,a1
		sub.l	d5,a1
		subq.l	#1,d5
morecrap	move.b	(a0)+,(a1)+
		dbra	d5,morecrap
		
christknows	sub.l	a4,a5		;# of bytes
		addq.l	#1,a5
		move.l	a5,d5
		move.l	in_use,d0
		lsl.l	#2,d0
		lea	offsets,a0
		move.l	(a0,d0.w),d1
		lea	so_read,a0
		sub.l	d1,(a0,d0.w)
		add.l	d5,(a0,d0.w)
titter1		clr.w	inside
		move.l	d5,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return #bytes read
		rte

close		clr.l	d0
		clr.l	d7
		move.w	2(a1),d7	;get handle
		move.l	d7,d6		;copy it
		move.l	d7,d5		;in case its a standard one
		move.l	d7,d4
		lsl.l	#2,d6
		lea	real_hand,a5
		tst.w	d7		;check if handle negative
		bmi.s	stn_stnt	;yes so handle it as a standard file
		lsl.l	#5,d4		;offset into name array
		lea	f_names,a4
		tst.b	(a4,d4.w)	;file created/open?
		bne.s	fileisok
		move.l	#$ffffffdb,d0	;illegal handle error
		bra	out_we_go
fileisok	move.l	(a5,d6.w),d5	;else get real handle from list
		cmp.l	#-1,d5		;is file buffered (=-1)
		beq.s	buffallclosed	;yes so its already closed
stn_stnt	move.w	#1,inside	;close the file for real
		move.w	d5,-(a7)	;use either real handle
		move.w	#$3e,-(a7)
		trap	#1		;f_close
		addq.l	#4,a7
		clr.w	inside		;my traps again
		tst.l	d0		;erred?
		bmi.s	out_we_go	;yes do dont close rest
buffallclosed	tst.w	d7		;check for STNDRD file
		bmi.s	out_we_go
		cmp.l	in_use,d7	;closing file currently loaded
		bne.s	lucky
		move.l	#-1,in_use	;make it invalid
lucky		clr.w	d5		;check for FDUP on this file
		swap	d5		;move top bit of REAL_HAND to bottom
		tst.w	d5		;is it 0 (not FDUPED)
		beq.s	not_duped
		cmp.w	#$ffff,d5	;is it an unbuffered load?
		beq.s	not_duped
		move.l	d5,(a5,d6.w)	;its FDUPED so save next handle to use
		bra	out_we_go
not_duped	lsl.l	#5,d7		;get offset into name array
		lea	f_names,a5
		move.b	#0,(a5,d7.w)	;set bytes to 0/shows slot empty
out_we_go	move.l	d0,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	
		rte

seek		lea	so_read,a2
		lea	f_lengths,a3
		clr.l	d0
		move.w	6(a1),d0	;file handle
		lsl.l	#2,d0		;*4
		clr.l	d1
		move.w	8(a1),d1	;type of seek
		move.l	2(a1),d2	;offset

com_seek	tst.w	d1		;type 0?
		bne.s	one_two

;absolute move=type 0

		move.l	d2,d3		;offset = new offset
		bra.s	same_end
one_two		cmp.w	#1,d1
		bne.s	mustbe2

;type 1=from current place

		move.l	(a2,d0.w),d3
		add.l	d2,d3		;add new offset to current
		bra.s	same_end

mustbe2		tst.l	d2
		bpl.s	no_flippy
		neg.l	d2
no_flippy	move.l	(a3,d0.w),d3
		sub.l	d2,d3		;sub new offset from length

;type 2=from end

same_end	move.l	(a3,d0.w),d4	;get length
		cmp.l	d3,d4
		bgt.s	ok_so_far	;not past end
		move.l	d4,d3		;else offset = end
ok_so_far	tst.l	d3
		bgt.s	still_ok	;not before start
		clr.l	d3		;else offset = start
still_ok	move.l	d3,(a2,d0.w)	;save new offset
		lea	real_hand,a0
		move.l	(a0,d0.w),d4
		cmp.l	#-1,d4		;check if buffered compacted file
		beq.s	sodit1		;yes then my routine
		lea	chunked,a0
		move.l	(a0,d0.w),d5	;get if chunked flag
		tst.l	d5		;is is chunked
		bne.s	sodit1		;yes then my routine
		move.w	#1,inside	;no so have to do it for real
		move.w	d1,-(a7)	;type
		move.w	d4,-(a7)	;handle
		move.l	d2,-(a7)	;offset
		move.w	#$42,-(a7)
		trap	#1		;f_seek
		lea	10(a7),a7
		move.l	d0,d3		;save new offset for returning
		clr.w	inside

sodit1		move.l	d3,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return new offset
		rte

error		clr.w	inside		;clear traps
		move.l	d0,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return error
		rte	

create		move.w	#1,inside	;do normal traps
		bsr	emptyone
		move.l	d0,d7		;save it
		move.l	a0,a5		;save slot start
		move.w	6(a1),-(a7)
		move.l	2(a1),-(a7)
		move.w	#$3c,-(a7)
		trap	#1		;f_create
		addq.l	#8,a7

;d0=what real handle should be

		tst.w	d0
		bmi	no_way_create	;check for error
dup2		move.b	#"I",(a5)	;mark slot as used
		lea	real_hand,a0
		move.l	d7,d6		;preserve my handle
		lsl.l	#2,d7		;fake *4 = place in array
		move.l	d0,(a0,d7.w)	;save real handle
		move.l	d6,d0		;give back my handle


no_way_create	clr.w	inside
		move.l	d0,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0	;return either my file handle or error
		rte		

write		clr.l	d0
		move.w	2(a1),d0	;get fake handle
		tst.w	d0
		bmi	open
		lsl.l	#2,d0
		lea	real_hand,a0
		move.l	(a0,d0.w),d1	;get real handle
		move.w	d1,2(a1)	;change it (assume it has been created!)
		bra	open		;do normal trap#1

ffirst		move.l	2(a1),d5
		move.w	6(a1),d6
		move.w	#1,inside

		lea	file_mask,a0
		move.l	d5,a1
		move.l	#13,d0
save_mask	move.b	(a1)+,(a0)+
		dbra	d0,save_mask
		move.l	#-22,file_locn
		move.l	#srchs,file_found

		move.w	d6,-(a7)
		move.l	d5,-(a7)
		move.w	#$4e,-(a7)
		trap	#1		;f_first
		addq.l	#8,a7

		clr.l	d6

		tst.w	d0
		beq.s	spank_me

no_find_me_2	move.l	d5,a0		;in right space
		move.l	ftablestrt,a4
fnext_too	bsr	find_it_if_pos	;check all the normal files
		tst.w	d0
		bmi	exit_route
		move.l	a4,file_found
		lea	-202(a0),a6
		sub.l	buff_add,a6
		move.l	a6,file_locn
		move.l	a0,a6

		move.w	d0,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7

		move.w	#$2f,-(a7)
		trap	#1
		addq.l	#2,a7

		move.l	d0,a0
		lea	26(a0),a0
		move.l	14(a6),(a0)+
		moveq.l	#13,d0
smash_file	move.b	(a6)+,(a0)+
		dbra	d0,smash_file
		moveq.l	#0,d0
		bra	exit_route

spank_me	move.w	#$2f,-(a7)
		trap	#1		;get bpb address in d0
		addq.l	#2,a7
		move.l	d0,d7		;save bpb address
		add.l	#$1e,d0
		move.l	d0,a0
		move.l	d0,d4

		lea	srchs,a1	;start of search
		lea	endsrch,a2	;end of search
		addq.l	#1,a1		;skip /
		addq.l	#1,a2
out_loop	clr.l	d0
out_loop2	move.b	(a1,d0.w),d1
		cmp.b	(a0,d0.w),d1
		bne.s	not_equal
		addq.l	#1,d0
		tst.b	d1
		bne.s	out_loop2
		move.l	#-33,d0
		tst.l	d6
		bra	fnext
not_equal	lea	16(a1),a1
		cmp.l	a2,a1
		bne.s	out_loop

		clr.w	-(a7)
		move.l	d4,-(a7)
		move.w	#$3d,-(a7)
		trap	#1		;f_open
		addq.l	#8,a7
		tst.l	d0
		bmi.s	doont
		move.w	d0,d6
		clr.l	tmp_read
		pea	tmp_read
		move.l	#8,-(a7)
		move.w	d0,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;read 8 bytes
		lea	12(a7),a7
		move.w	d6,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
		lea	tmp_read,a0
		cmp.l	#buffdhead,(a0)	;check if compacted
		beq.s	doont1
		cmp.l	#normlhead,(a0)	;check buffered
		bne.s	doont
doont1		move.l	d7,a1
		move.l	4(a0),26(a1)	;yes so change length to
					;uncompacted length (in case sneaky)
doont		clr.l	d0		;show file found
exit_route	clr.w	inside
		move.l	d0,-(a7)
		movem.l	reg,a0-a6/d0-d7
		move.l	(a7)+,d0
		rte

fnext		move.w	#1,inside

		move.l	file_locn,d6
		add.l	#22,d6		;for next location

		move.w	#$4f,-(a7)
		trap	#1		;fnext
		addq.l	#2,a7

		tst.l	d0
		beq	spank_me

no_find_me	lea	file_mask,a0
		move.l	file_found,a4
		bra	fnext_too

fdup		move.w	#1,inside	;do normal traps
		bsr	emptyone

		move.l	d0,d7		;save it
		move.l	a0,a5		;save slot start
		move.w	2(a1),d5
		move.w	d5,-(a7)

		move.w	#$45,-(a7)
		trap	#1		;f_dup
		addq.l	#4,a7
		tst.w	d0		;only word test
		bmi	error
		neg.l	d5		;turns STNDRD name into file handle
		swap	d5		;move handle into top word
		move.w	d0,d5		;get FDUP handle
		move.l	d5,d0		;put both handles into perspective
		bra	dup2		;same as create code

fforce		clr.l	d0
		move.w	4(a1),d0	;get spook handle
		lea	real_hand,a5
		tst.w	d0
		bmi.s	sod_stan
		lsl.l	#2,d0		;*4
		move.l	(a5,d0.w),d0	;get real handle
		move.w	d0,4(a1)	;change fake handle to real one
sod_stan	clr.l	d1
		move.w	2(a1),d1
		lsl.l	#2,d1
		move.l	d0,(a5,d1.w)	;save handle in my list
		bra	open		;do normal trap 1

emptyone	lea	f_names,a0
		lea	160(a0),a0
		move.l	#5,d0
s_loop		addq.l	#1,d0
		lea	32(a0),a0
		tst.b	(a0)
		bne.s	s_loop		;search for empty slot
					;i.e. one with first byte
					;set to 0
		rts
******************************************************************
*searches the filelist at the start of prog for filename
*entry	a0=filename to find
*	d0=file error
*	d7=fake file handle
*trashes everything at some time or another
*return	a0=position filename found
*	a4=name of file found
*	d0=filehandle if succesfull or -ve if error
*	d6=position file found at
******************************************************************

find_it_if_pos	move.l	d0,d5		;save error
		bsr	preproc		;get filename
		move.l	a0,a6		;keep safe
		move.l	ftableend,a5
searchme	cmp.l	a4,a5
		beq	the_end_is_nigh	;end of table

still_here_folk	bsr	openafile
		move.l	d0,d4		;save handle
		tst.l	d0
		bmi	file_not_here

		pea	i_buff
		move.l	#1024,-(a7)
		move.w	d4,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;f_read header file into buffer
		lea	12(a7),a7

		move.l	#-1,mini	;show buffer screwed
		move.l	a4,file_loaded_name
		move.l	i_len,d0
		move.l	chnksize,d2
		subq.l	#1,d2
		eor.l	#-1,d2
		and.l	d2,d0
		move.l	d0,numb_chnk
		
		clr.w	-(a7)		;type 0 (absolute)
		move.w	d4,-(a7)	;file handle
		move.l	restofbuff,-(a7);right place (first pos of data)
		move.w	#$42,-(a7)
		trap	#1		;f_seek
		lea	10(a7),a7

		move.l	buff_add,-(a7)
		move.l	chnksize,-(a7)
		move.w	d4,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;f_read fileblock into buffer
		lea	12(a7),a7

		move.l	buff_add,a0
		lea	200(a0),a1
		bsr	chuck_up	;depack it

		bsr	quicky		;search for the farger
		tst.l	d0		;found it?
		bmi.s	file_not_here
		move.l	d0,a0		;return address of filename
		move.l	d4,d0		;return real handle
		rts

openafile	clr.w	-(a7)
		move.l	a4,-(a7)
		move.w	#$3d,-(a7)
		trap	#1		;f_open
		addq.l	#8,a7
		rts
		
quicky		move.l	a6,a0		;search name
		clr.l	d0
		move.w	(a1),d0		;get number of files
		mulu	#22,d0		;get size
		addq.l	#2,a1		;skip numberoffiles variable
		move.l	a1,a2	
		add.l	d0,a2		;calc end of search area

		add.l	d6,a1		;offset for fnext bit

		bsr	do_search	;search for the farger
		rts

the_end_is_nigh	cmp.l	#endsrch,a5		;check for wrap
		bne.s	total_firkup		;not here
		cmp.l	#srchs,ftablestrt
		beq.s	total_firkup		;already wrapped
		move.l	ftablestrt,a5
		move.l	#srchs,a4
		bra	still_here_folk

total_firkup	move.l	d5,d0
		rts

file_not_here	tst.w	d4
		bmi.s	major_error
		move.w	d4,-(a7)
		move.w	#$3e,-(a7)
		trap	#1
		addq.l	#4,a7
major_error	lea	16(a4),a4		;next name
		bra	searchme


******************************************************************
*takes a drive\directory(s)\filename and changes it to
*filename only
*pass 	a0 as start of filespec
*	a1 trashed
*return a0 as start of filename only
******************************************************************

preproc		cmp.b	#":",1(a0)
		bne.s	no_drive	;drive in path?
		addq.l	#2,a0
no_drive	move.l	a0,a1
do_parse	cmp.b	#"\",(a1)+
		bne.s	no_slash
		move.l	a1,a0		;save slash start
no_slash	tst.b	(a1)
		bne.s	do_parse	;until zero found
		rts

******************************************************************
*search a block of memory for a filename which may include
*wildcards (*) and any_chars (?). Assumes it is valid and that
*it has been preprocessed by preproc.
* case dependent!
*pass	a0 as start of file to find
*	a1 as start of search area (even boundary)
*	a2 as end of search area   (ditto)
*trash	d0&d1&d2&a0&a1&a2
*return d0 as start position of found name
* 	d0=-1 if error/not found
******************************************************************
do_search	clr.w	d1
		clr.w	d2
main_srch	move.b	(a0,d1.w),d0
		cmp.b	#"a",d0
		blt.s	turkey
		cmp.b	#"z",d0
		bgt.s	turkey
		and.b	#%11011111,d0
turkey		cmp.b	#"?",d0		;is it any char
		bne.s	not_any
		tst.b	(a1,d2.w)
		beq.s	no_match
		cmp.b	#".",(a1,d2.w)
		beq.s	no_match
		bra.s	any_char
not_any		cmp.b	(a1,d2.w),d0	;are they the same
		bne.s	search_next
null_chk	tst.b	d0		;have we finished
		beq.s	all_the_same
any_char	addq.b	#1,d1		;check next char
		addq.b	#1,d2
		bra.s	main_srch
search_next	cmp.b	#"*",d0
		bne.s	no_match	;is it wildcard char
		addq.b	#1,d1
		move.b	(a0,d1.w),d0	;get next char
		cmp.b	#"a",d0
		blt.s	turkey2
		cmp.b	#"z",d0
		bgt.s	turkey2
		and.b	#%11011111,d0
turkey2		tst.b	d0
		beq.s	chk_rest	;end of this name?
chk_next	addq.b	#1,d2
		cmp.b	(a1,d2.w),d0	;found next char yet
		beq.s	null_chk	;yes so end of searching
		cmp.b	#".",(a1,d2.w)	;dot in filename?
		beq.s	null_chk
		tst.b	(a1,d2.w)	;end of check name
		bne.s	chk_next
		bra.s	no_match	;filename not this one
chk_rest	addq.b	#1,d2
		cmp.b	#".",(a1,d2.w)	;found dot?
		beq.s	no_match	;yes then invalid name
		tst.b	(a1,d2.w)
		bne.s	chk_rest	;not eof yet
		bra.s	all_the_same	;match
no_match	lea	22(a1),a1	;next filename to check
		cmp.l	a1,a2		;any more to check
		bgt	do_search	;yes so go again
		move.l	#-1,a1		;no so show error
all_the_same	move.l	a1,d0		;return found or error
		rts
******************************************************************

******************************************************************
*depacks a file if it is packed to a1
*if unpacked then copies CHNKSIZE bytes
*to a1 (assume a1>a0)
*what goes in comes out
*a0=source
*a1=dest
******************************************************************

chuck_up	movem.l	d0-d7/a0-a6,-(a7)
		clr.l	d0
		move.b	(a0),d0
		lsl.w	#8,d0
		move.b	1(a0),d0
		swap	d0
		move.b	2(a0),d0
		lsl.w	#8,d0
		move.b	3(a0),d0	;gets 4 bytes from a0
		cmp.l	#normlhead,d0	;check for nonbuff pack
		beq	throw1		;normal file
		cmp.l	#buffdhead,d0
		bne	throw
throw1		bsr	ice_depack
		bra	get_out
throw		move.l	chnksize,d0
		add.l	d0,a0
		add.l	d0,a1
		subq.l	#1,d0
do_loop		move.b	-(a0),-(a1)
		dbra	d0,do_loop
get_out		movem.l	(a7)+,d0-d7/a0-a6
		rts
;
;---------------------------------------
; Ice Depacker Routine by Axe of Delight
;---------------------------------------
;
ice_depack
	move.w	$ffff8240.w,-(a7)
	bsr.s	getinfo		; ein Langwort holen
	cmpi.l	#'AU5!',d0	; Kennung gefunden?
	bne	not_packed	; nein: nicht gepackt
	bsr.s	getinfo		; gepackte LÑnge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	getinfo		; ungepackte LÑnge holen (original)
;	move.l	d0,(sp)		; OriginallÑnge: spÑter nach d0
	move.l	a1,a4		; a4 = Zielpuffer
	move.l	a1,a6
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken fÅr Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr	normal_bytes

	bsr	get_1_bit 	;; Picture decrunch!
	bcc.s	not_packed	;; These marked lines may be
	move.w	#$0f9f,d7 	;; removed in your own sources
ice_00:	moveq	#3,d6		;; if you do not use the
ice_01:	move.w	-(a3),d4		;; additional algorithm.
	moveq	#3,d5		;;
ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,ice_02 	;;
	dbra	d6,ice_01 	;;
	movem.w	d0-d3,(a3)	;;
	dbra	d7,ice_00 	;;

not_packed:
	rts

getinfo:	moveq	#3,d1		; ein Langwort vom Anfang
getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	get_1_bit
	bcc.s	copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,nextgb 	; ja: dann weiter Bits lesen
no_more:	add.l	20(a1),d1 	; Anzahl der zu Åbertragenen Bytes
copy_direkt:	

	ifne	flash		; flash colours if required !!
	move.w	d0,$ff8240	; Standard Auto v5.01 flash
;	move.b	(a6),$ff8240	; Medway Boys F/X
;	eori.w	#$201,$ff8240	; Dream Warriors F/X 
	endc

	move.b	-(a5),-(a6)	; Daten direkt kopieren
	dbf	d1,copy_direkt	; noch ein Byte
test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	strings		; Weiter wenn Ende nicht erreicht
	move.l	d7,d5
	move.l	(a7)+,d0
	move.w	(a7)+,$ffff8240.w
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schluû

get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	bitfound		; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
bitfound:	rts	

get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		; und Åbernimm es
	dbf	d0,hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


strings:	lea.l	length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit	; nÑchstes Bit holen
no_length_bit:	
	moveq.l	#0,d4		; d4 = öberschuû-LÑnge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	no_Åber		; kein öberschuû nîtig
get_Åber: bsr.s	get_d0_bits
no_Åber:	move.b	6(a1,d2.w),d4	; Standard-LÑnge zu öberschuû add.
	add.w	d1,d4		; d4 = String-LÑnge-2
	beq.s	get_offset_2	; LÑnge = 2: Spezielle Offset-Routine


	lea.l	more_offset(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
getoffs:	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		; Offset-öberschuû
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu öberschuû add.
	bpl.s	depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	depack_bytes


get_offset_2:	
	moveq.l	#0,d1		; öberschuû-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	get_1_bit
	bcc.s	less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
less_40:	bsr.s	get_d0_bits
	add.w	d2,d1		; Standard-Offset + öber-Offset

depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,dep_b	; und noch ein Mal
	bra	normal_bytes	; Jetzt kommen wieder normale Bytes


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

length_tab:
	dc.b 9,1,0,-1,-1	; Bits lesen
	dc.b 8,4,2,1,0		; Standard-LÑnge - 2 (!!!)

more_offset:
	dc.b	  11,4,7,0	; Bits lesen
	dc.w	$11f,-1,$1f	; Standard Offset
	dc.b	0

real_hand	dc.l	0,1,2,3,4,5

		section bss

		ds.l	8


ssp		Ds.L	1
file_mask	ds.b	14
file_locn	ds.l	1
file_found	ds.l	1
ftablestrt	ds.l	1
ftableend	ds.l	1
in_use		ds.l	1
inside		ds.w	1
buff_add	ds.l	1
mini		ds.l	1
reg		ds.l	16
tmp_read	ds.l	4
crunpos		ds.l	1
file_loaded_name ds.b	32
so_read		ds.l	8
f_lengths	ds.l	8
f_names		rept	maxfiles
		ds.b	8
		ds.b	8
		ds.b	8
		ds.b	8
		endr
offsets		ds.l	8
chunked		ds.l	8
tmp_sav		ds.b	200
numb_chnk	ds.l	1
i_buff		ds.l	1
i_len		ds.l	1
chnksize	ds.l	1
restofbuff	ds.l	253
buff_start	ds.l	1	;start of buffer space

	
***********************************************************
**							 **
** Instructions						 **
**							 **
** Read the accompanying INSTRUX.501, which were typed   **
** by 'I Wonder Who Wrote This Trash Industries'.        **
**							 **
** This is the third update that I've done to this code  **
** and although my additions are mostly superficial      **
** please credit me, and don't forget that the workhorse **
** part of this code was done by DACK and the Automation **
** Packer v5.01 was done by EGB.  So don't forget to     **
** credit them also !!                                   **
**                                                       **
** Bye - IWWWTTI, 7th October 1991                       **
***********************************************************
