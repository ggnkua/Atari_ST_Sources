		opt c+,d-,o+,w-
**********************************************************
** ultraload/megaload/whatever its called now		**
** is a product of Dackco Industries. Instructions	**
** for use are included right at the end of the		**
** code.						**
**********************************************************

** fixed 10/2/90 for standard file create bug
** fixed 16/2/90 for FDUP  (who uses this???)
** fixed 19/2/90 for standard handles
** fixed 19/2/90 for F_FORCE (what???)
** fixed 21/2/90 for non bufferd reads
** fixed 21/2/90 for correct handling of PRN: etc
** fixed 25/2/90 for buggy version of FDUP as used by AUTOROUTE
** fixed 25/2/90 for closing already closed file
** fixed 22/4/90 for repeated opening and closing of same buffered
** 		 file
** fixed 22/4/90 for opening of standard handled file
** major upgrade 28/5/90-31/5/90 for EGBs chunk packer
** (hard bit is mine though!!!)

buff_len	equ	16400		;set higher than chunk size
maxfiles	equ	32
buffdhead	equ	"LSD$"
normlhead	equ	"LSD!"
chnkhead	equ	"LSDC"

	bra	main

gam		dc.b "load.prg",0
		even

text	DC.B 27,"E"
	dc.b	"MAC SYS DATA!",13,10
	DC.B 00,00

	EVEN

	
main
	MOVEA.L	4(A7),A5
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

	move.l	#stackend,sp
	dc.w	$a00a
	pea	text
	move.w	#9,-(a7)
	trap	#1		;text print
	addq.l	#6,a7
	dc.w	$a009

;	move.w	#7,-(a7)
;	trap	#1		;wait for key
;	addq.l	#2,a7

	move.l	#buff_start,buff_add	;set buffer start address
					;change buff_start to absolute
					;address if needed

CHEAT	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01			;supervisor
	ADDQ.L	#6,A7
	LEA	SUPERLNG(PC),A6
	MOVE.L	D0,(A6)			;save old stack address
	MOVE.L	$84,tr1			;save old trap1 address
	MOVE.L	#T1,$84			;set trap1 to my code
	MOVE.L	SUPERLNG(PC),-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#$01			;usermode
	ADDQ.L	#6,A7
stkk	clr.l	in_use			;so first read gets file
	clr.l 	$60000
	pea 	$60000
	pea	$60000
	move.l 	#gam,-(sp)
	move.l 	#$4b0000,-(sp)
	trap 	#1			;run next program
	lea 16(a7),a7
	clr.w 	-(sp)
	trap 	#1			;back to desktop


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
		cmpi.w	#$4e,(a1)	;f_next
		beq	ffirst
		cmpi.w	#$45,(a1)	;f_dup
		beq	fdup
		cmpi.w	#$46,(a1)	;f_force
		beq	fforce
		cmpi.w	#0,(a1)		;exit
		bne.s	open
		move.l	tr1,$84		;old trap1 back
open		movem.l 	reg(pc),a0-a6/d0-d7
bye		dc.w 	$4ef9
tr1		dc.l 	$0

openup		move.w	#1,inside	;do normal traps
		lea	f_names,a0
		lea	300(a0),a0
		move.l	#5,d0
s_loop		addq.l	#1,d0
		lea	60(a0),a0
		tst.b	(a0)
		bne.s	s_loop		;search for empty slot
					;i.e. one with first byte
					;set to 0

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
		bmi	error		;in case file not there

		move.l	d0,d4		;save real handle

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
		move.l	a6,a4			;save address of name
		move.l	#59,d0
c_loop		move.b	(a6)+,(a5)+
		dbra	d0,c_loop

		lsl.l	#2,d7			;times4
		lea	so_read,a0
		move.l	#0,(a0,d7.w)		;clear amount read so far

		cmp.l	#buffdhead,i_buff 	;check if file buff/compacted
		beq.s	nermal			;yes so set up correct handler
stn_file	lea	real_hand,a0		;start of real handles array
		move.l	d4,(a0,d7.w)		;save real handle
		lea	chunked,a0
		move.l	#0,(a0,d7.w)		;show file not chunked
		cmp.l	#chnkhead,i_buff	;check if file chunked
		bne	not_good
		move.l	#-1,(a0,d7.w)		;set chunked flag to true
		lea	f_lengths,a0
		move.l	i_len,(a0,d7.w)		;save file length in array
		bra	chk_same		;check if same file loaded


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
		trap	#1			;f_close
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
		bmi	stan_f
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
		clr.w	inside		;my traps again
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
		bne	titter		;normal file
		lea	-$200(a0),a1	;destination
		move.l	a1,a2
		lea	tmp_sav,a3
		move.l	#$1ff,d1
firk1		move.b	(a2)+,(a3)+
		dbra	d1,firk1	;save 200 bytes below
firk2		move.b	(a0)+,(a1)+
		subq.l	#1,d5
		bne.s	firk2		;copy down
		move.l	a2,a1
		lea	-$200(a1),a0
		move.l	a0,-(a7)	;save start
		bsr	DEPACK
		move.l	(a7)+,a0
		lea	tmp_sav,a1
		move.l	#$1ff,d1
firk3		move.b	(a1)+,(a0)+
		dbra	d1,firk3	;copy bytes back
		bra	titter		;get out

cor_blimy	cmp.l	in_use,d0
		beq	all_in
		move.l	a1,a5		;preserve stack
		move.w	#1,inside	;normal trap code
		move.l	d0,in_use	;tell system this file is in use
		mulu	#60,d0		;d0=d0*60
		lea	f_names,a0
		add.l	d0,a0		;get correct filename
		move.l	a0,a1		;preserve value
		lea	file_loaded_name,a2
		move.w	#59,d0
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
		move.l	a0,a1		;destination of depack
		add.l	#200,a1		;=source +200
		move.l	4(a0),d7	;length
		bsr	DEPACK
		move.l	buff_add,a0	;copy file back 200 bytes
		move.l	a0,a1
		add.l	#200,a1
m2_back		move.b	(a1)+,(a0)+
		subq.l	#1,d7
		bne.s	m2_back
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
		bra	titter

sodding_chunk	cmp.l	in_use,d0
		beq	all_in2
		move.l	a1,a5		;preserve stack
		move.w	#1,inside	;normal trap code
		move.l	d0,in_use	;tell system this file is in use
		mulu	#60,d0		;*60
		lea	f_names,a1
		add.l	d0,a1		;get this files name
		lea	file_loaded_name,a2
		move.w	#59,d0
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
		beq	titter		;if no bytes to read
startxfer	lea so_read,a0
		move.l	(a0,d1.w),d0	;get offset
		move.l	d0,d4		;save it
		move.l	chnksize,d3	;get chunksize
		subq.l	#1,d3		;create mask
		and.l	d3,d0		;perform mod operation on offset
 		move.l	d3,d7		;save mask
		eor.l	#-1,d3		;change mask for div-mod
		and.l	d3,d4		;d4 nov contains int(offset/chnksize)*chnksize
		cmp.l	mini,d4		;check if already loaded chunk
		beq	all_in3		;yes
		move.l	d4,mini		;save block i.d.
		movem.l	d0-d7/a0-a6,-(a7);save registers
		move.l	d2,d7		;save file handle
		move.w	#1,inside	;my traps
		move.l	chnksize,d6
		divu	d6,d4		;get correct table offset
		lsl.l	#2,d4
		lea	restofbuff,a0	;get table
		clr.w	-(a7)		;type 0 (absolute)
		move.w	d7,-(a7)	;file handle
		move.l	(a0,d4.w),-(a7)	;position of chunk
		move.w	#$42,-(a7)
		trap	#1		;f_seek
		lea	10(a7),a7

		move.l	buff_add,-(a7)
		move.l	chnksize,-(a7)
		move.w	d7,-(a7)
		move.w	#$3f,-(a7)
		trap	#1		;f_read file into buffer
		lea	12(a7),a7
		clr.w	inside		;my traps again
		move.l	buff_add,a0
		cmp.l	#buffdhead,(a0)	;check if compacted
		beq.s	squit
		cmp.l	#normlhead,(a0)	;check buffered
		bne.s	squity

squit		move.l	buff_add,a0	;source of depack
		lea	200(a0),a1	;=source +200
		move.l	4(a0),d7	;length
		bsr	DEPACK
		move.l	buff_add,a0	;copy file back 200 bytes
		lea	200(a0),a1	;=source +200
m2_back4	move.b	(a1)+,(a0)+
		subq.l	#1,d7
		bne.s	m2_back4


squity		movem.l	(a7)+,d0-d7/a0-a6;restore regs
all_in3		move.l	buff_add,a0
copy_next_b	move.b	(a0,d0.w),(a4)+	;copy a byte
		addq.l	#1,d0
		cmp.l	a5,a4		;reached end	
		bgt.s	christknows
		and.l	d7,d0		;restrict range 0 to cnhksize-1	
		bne.s	copy_next_b	;chnk not finished
		add.l	chnksize,d4	;get next block
		lea	so_read,a0
		move.l	d4,(a0,d1.w)	;save offset
		bra	startxfer
christknows	add.l	d0,d4		;final offset
		lea	so_read,a0
		move.l	d4,(a0,d1.w)	;save offset

titter		move.l	d5,-(a7)
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
		mulu	#60,d4		;offset into name array
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
not_duped	mulu	#60,d7		;get offset into name array
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
mustbe2		move.l	(a3,d0.w),d3
		sub.l	d2,d3		;sub new offset from length

;type 2=from end

same_end	move.l	(a3,d0.w),d4	;get length
		cmp.l	d3,d4
		bgt.s	ok_so_far	;not past end
		move.l	d4,d3		;else offset = end
ok_so_far	cmp.l	#0,d3
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
		lea	f_names,a0
		add.l	#300,a0
		move.l	#5,d0
sc_loop		addq.l	#1,d0
		add.l	#60,a0
		tst.b	(a0)
		bne.s	sc_loop		;search for empty slot
					;i.e. one with first byte
					;set to 0

;d0=my pretend file handle

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
		move.w	d6,-(a7)
		move.l	d5,-(a7)
		move.w	#$4e,-(a7)
		trap	#1		;f_first
		addq.l	#8,a7
		tst.w	d0
		bne	exit_route
		move.w	#$2f,-(a7)
		trap	#1		;get bpb address in d0
		addq.l	#2,a7
		move.l	d0,d7		;save bpb address
		add.l	#$1e,d0
		clr.w	-(a7)
		move.l	d0,-(a7)
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

fdup		move.w	#1,inside	;do normal traps
		lea	f_names,a0
		add.l	#300,a0
		move.l	#5,d0
sc_loop2	addq.l	#1,d0
		add.l	#60,a0
		tst.b	(a0)
		bne.s	sc_loop2	;search for empty slot
					;i.e. one with first byte
					;set to 0

;d0=my pretend file handle

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

reg		ds.l	16
tmp_read	ds.l	4
crunpos		dc.l 0

;should now be capable of decoding from odd to odd addresses
;11th October 1989

DEPACK		adda.l #4,a0
		move.w $ffff8240.w,-(sp)
		lea	crunpos(pc),a6
		move.l a0,(a6)		;save crunch position
		move.b (a0)+,d5
		lsl.w 	#8,d5
		move.b	(a0)+,d5
		swap	d5
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		adda.l d5,a1
		move.b	(a0),d0
		lsl.w	#8,d0
		move.b	1(a0),d0
		swap	d0
		move.b	2(a0),d0
		lsl.w	#8,d0
		move.b	3(a0),d0
		adda.l 	d0,a0
		subq.l #4,a0
		move.b	-2(a0),d0
		lsl.w	#8,d0
		move.b	-1(a0),d0
		subq.l	#2,a0
		tst.w	d0
		bpl.s L_1
		subq.l #1,a0
L_1		move.b -(a0),d0
L_2		lsl.b #1,d0
		bne.s L_3
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_3		BCC.S	L_10
		CLR.W	D1
		LSL.B	#1,D0
		BNE.S	L_4
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_4		BCC.S	L_9
		LEA	NUMS(PC),A3
		MOVEQ	#3,D3
L_5		CLR.W	D1
		MOVE.B	0(A3,D3.W),D2
		EXT.W	D2
		MOVEQ	#-1,D4
		LSL.W	D2,D4
		NOT.W	D4
		SUBQ.W	#1,D2
L_6		LSL.B	#1,D0
		BNE.S	L_7
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_7		ROXL.W	#1,D1
		DBF	D2,L_6
		TST.W	D3
		BEQ.S	L_8
		CMP.W	D1,D4
		DBNE	D3,L_5
L_8		MOVE.B	4(A3,D3.W),D2
		EXT.W	D2
		ADD.W	D2,D1
		BRA	L_9

NUMS		DC.B	$0A,$03,$02,$02,$0E,$07,$04,$01

L_9		MOVE.B	-(A0),-(A1)
		DBF	D1,L_9
L_10		MOVE.L	crunpos(pc),A3		;get crunch position
		ADDQ.L	#$8,A3
		CMPA.L	A3,A0
		BLE	BYENOW
		LEA	NUMS2(PC),A3
		MOVEQ	#3,D2
L_11		LSL.B	#1,D0
		BNE.S	L_12
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_12		BCC.S	L_13
		DBF	D2,L_11
L_13		CLR.W	D1
		ADDQ.W	#1,D2
		MOVE.B	0(A3,D2.W),D3
		BEQ.S	L_16
		EXT.W	D3
		SUBQ.W	#1,D3
L_14		LSL.B	#1,D0
		BNE.S	L_15
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_15		ROXL.W	#1,D1
		DBF	D3,L_14
L_16		MOVE.B	5(A3,D2.W),D3
		EXT.W	D3
		ADD.W	D3,D1
		BRA	L_161

NUMS2		DC.B	$0A,$02,$01,$00,$00,$0A,$06,$04,$03,$02

L_161		CMPI.W	#2,D1
		BEQ.S	L_22
		LEA	NUMS3(PC),A3
		MOVEQ	#1,D3
L_17		LSL.B	#1,D0
		BNE.S	L_18
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_18		BCC.S	L_19
		DBF	D3,L_17
L_19		ADDQ.W	#1,D3
		CLR.W	D2
		MOVE.B	0(A3,D3.W),D4
		EXT.W	D4
L_20		LSL.B	#1,D0
		BNE.S	L_21
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_21		ROXL.W	#1,D2
		DBF	D4,L_20
		LSL.W	#1,D3
		ADD.W	4(A3,D3.W),D2
		BRA.S	L_26

NUMS3		DC.B	$0B,$04,$07,$00,$01,$20,$00,$00
		DC.B	$00,$20,$00,$00

L_22		CLR.W	D2
		MOVEQ	#5,D3
		CLR.W	D4
		LSL.b	#1,D0
		BNE.S	L_23
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_23		BCC.S	L_24
		MOVEQ	#8,D3
		MOVEQ	#$40,D4
L_24		LSL.B	#1,D0
		BNE.S	L_25
		MOVE.B	-(A0),D0
		ROXL.B	#1,D0
L_25		ROXL.W	#1,D2
		DBF	D3,L_24
		ADD.W	D4,D2
L_26		LEA	0(A1,D2.W),A2
		EXT.L	D1
		ADDA.L	D1,A2
		SUBQ.W	#1,D1
L_27		MOVE.B	-(A2),-(A1)
	move.w	d5,-(sp)
	move.b	(a2),d5
	and.w	#$007,d5
	move.w	d5,$ffff8240.w
	move.w	(sp)+,d5
		DBF	D1,L_27
		BRA	L_2
BYENOW		move.w (a7)+,$ffff8240.w
		RTS

		dcb.l	maxfiles,0


SUPERLNG	ds.L	1
in_use		ds.l	1
inside		ds.w	1
buff_add	ds.l	1
mini		ds.l	1
file_loaded_name ds.b	60
so_read		dcb.l	maxfiles,0
f_lengths	dcb.l	maxfiles,0
f_names		rept	maxfiles
		dcb.b	60,0
		endr
real_hand	dc.l	0,1,2,3,4,5
		dcb.l	maxfiles,0
offsets		dcb.l	maxfiles,0
chunked		dcb.l	maxfiles,0

		section bss

	ds.l	500
stackend	ds.l	1
tmp_sav		ds.b	200
numb_chnk	ds.l	1
i_buff		ds.l	1
i_len		ds.l	1
chnksize	ds.l	1
restofbuff	ds.l	253
buff_start	ds.l	1	;start of buffer space

**********************************************************
** O.K. Here it is. The low calorie lemon and lime 	**
** flavoured ultraload (tm) with added chunky bits. 	**
** This came about because of Alien and E.G.B.-whoops   **
** I got them both in the same breath- Alien because of **
** the slagging off of Autoroute (about to be redone)	**
** and E.G.B. cos he could be bothered to rewrite the	**
** packer to chunk pack fuck-off-nasty-size files in an	**
** interesting and somehow seductive way................**
**							**
** Instructions						**
** 1)Pack all the files using packer 2.5		**
** 2)set buff_len=to max size of chunk used (4/8/16k)	**
** (i.e. 4096,8192,16384)				**
** 3)if all files can load using offset packing or load **
**   directly then you can set it equal to 0		**
** 4)set maxfiles =to maxfiles that are open at once+6  **
** 5)set buffhead etc to the values you've used to pack **
**   the files. Defaults are LSDC for chunked, LSD! for **
**   straight loaders, LSD$ for buffered files.		**
** 6)change gam=to program name to run			**
** 7)assemble this damn code. (use GENST2 2.02 as other **
**   versions do not produce correct code.............)	**
**							**
** Problems						**
** 1)FNEXT is not supported...but it  works anyhow      **
** 2)Resource file loading is not supported (its TRAP2) **
** 3)My girlfriend has just left me.................... **
**							**
** Updates						**
** The next version will have the above problems solved **
** by next time (except number 3 probably)		**
**							**
**		DACK (Depressed And Crazy Kid) 1990	**
**********************************************************