* Devpac 3 patch program...

labels	equ	1
;link	equ	1

	ifd	labels
	opt	x+
	endc
	
	opt	o+,ow-

	ifd	link
	OPT	GST,CASE
	XREF	file_selector
	XREF	print_mes,aes
	XREF	create_some,seek_some,open_some,save_some,close_some
	XREF	read_some,load_a_file
	endc

	include	aes_defs.i
	include	lens.i


	include	proghead.s

	lea	variables(pc),a6

loop:
	lea	_intro(a6),a0
	bsr	print_mes

	lea	_devpac(a6),a0
	bsr	file_selector

	tst.l	d0
	beq.s	.ok
	
	clr.w	-(a7)
	trap	#1

.ok:
	pea	(a0)	; keep filename!

* is it devpac V3???
	bsr	open_some
	tst.w	d7
	bpl.s	.got_one

* cannot open!
	addq.l	#4,a7
	bra	loop

.got_one:
	moveq	#40,d1		; go 40 bytes in
	moveq	#0,d0		; from start
	bsr	seek_some

* now read in version number
	lea	buffer(pc),a0
	pea	(a0)

	moveq	#4,d0
	bsr	read_some

	move.l	(a7)+,a0
	move.l	(a0),d0
	clr.l	(a0)
	sub.l	#"3.01",d0
	beq.s	.got_it

* isn't devpac 3.01!
	addq.l	#4,a7
	alert	#1,notdev
	bra	loop

.got_it:
* we have V3.01!
* so install the patch...
* first we have to load it all in...
	bsr	close_some

	move.l	(a7),a0		; get file name
	bsr	load_a_file	; load it ALL in...
	tst.l	d0
	bpl.s	.loaded

* not loaded!
	addq.l	#4,a7
	bra	loop

.loaded:
	move.l	d0,_addr(a6)
	move.l	d1,_len(a6)

* now we have to re-arrange some stuff...


* find the relocation table...
	move.l	d0,a0

* store the old values
	move.l	2(a0),old_text
	move.l	6(a0),old_data

	move.l	2(a0),a1
	add.l	6(a0),a1	; go to end of data...

	move.l	a1,reloc_offset	; store it in my routine

* a1 is offset from start of prog
	lea	$1c(a1),a1	; ignore header
	add.l	a0,a1		; get actual address

	moveq	#4,d5		; len of 4 so far...
	
	tst.l	(a1)+
	beq.s	end_reloc

.reloc_loop:
	addq.l	#1,d5
	tst.b	(a1)+
	bne.s	.reloc_loop

end_reloc:
* found end of relocation table!
* add this to the length of the data area...
	addq.l	#1,d5
	bclr	#0,d5		; ensure even length!
	add.l	d5,6(a0)

* add on length of my routine to the text section length
	add.l	#rout_len,2(a0)

* now save out the new header
	addq.l	#4,a7


	lea	_outmes(a6),a0
	bsr	print_mes

	lea	_star(a6),a0
	bsr	file_selector
	tst.l	d0
	bmi	loop

* ok clicked!
	bsr	create_some
	tst.w	d0
	bmi	loop

	move.l	_addr(a6),a1

	moveq	#$1c,d0
	bsr	save_some	; save header
	tst.w	d0
	bmi.s	.sav_err

	lea	my_rout(pc),a1
	move.l	#rout_len,d0
	bsr	save_some
	tst.w	d0
	bmi.s	.sav_err

	move.l	_addr(a6),a1
	lea	$1c(a1),a1
	move.l	_len(a6),d0
	sub.l	#$1c,d0
	addq.l	#1,d0
	bclr	#0,d0		; ensure even no
	bsr	save_some	; save original program
	tst.w	d0
	bmi.s	.sav_err

	lea	buffer(pc),a1
	moveq	#4,d0
	bsr	save_some	; save 0.L as new reloc table!

.sav_err:
	bsr	close_some
	bra	loop


my_rout:
* this is called when Devpac is run!

	lea	patch(pc),a0
	bsr	p_mes		; intro

* get the file...
	clr.w	-(a7)
	pea	file(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7
	bpl.s	.openok

	lea	error(pc),a0
	bsr	p_mes
	bra	end_install


.openok:
* opened the file OK!
	pea	buffer(pc)
	move.l	#20,-(a7)	; length
	move.w	d7,-(a7)	; handle
	move.w	#$3f,-(a7)
	trap	#1		; read in file!
	lea	12(a7),a7

* close it!
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7

* now get the number in the buffer --> binary!

	moveq	#0,d0
	lea	buffer(pc),a0

.num:
	moveq	#0,d1
	move.b	(a0)+,d1
	beq.s	.got_num

* multiply by 10 for LW
	move.l	d0,d2
	add.l	d2,d2
	move.l	d2,d0
	add.l	d2,d2
	add.l	d2,d2
	add.l	d2,d0


* add in new number
	sub.b	#"0",d1
	add.l	d1,d0
	bra.s	.num

.got_num:
* now put the number into devpac!
	lea	end_my_rout(pc),a0
	add.l	#37770,a0
	move.l	d0,(a0)

	lea	dun(pc),a0
	bsr	p_mes
	lea	buffer(pc),a0
	bsr	p_mes


end_install:
* relocate the program
	lea	end_my_rout(pc),a0	; get start addr
	lea	my_rout(pc),a2
	move.l	a2,d2			; addr to use to relocate with

	move.l	reloc_offset(pc),d0	; get offset

	move.l	a0,a1
	add.l	d0,a1		; get addr of reloc table


* do the relocation... and wipe the table at the same time...
	move.l	(a1)+,d0
	beq.s	.dun

	clr.l	-4(a1)

	add.l	d0,a0
	add.l	d2,(a0)

	moveq	#0,d0
.loo:
	move.b	(a1),d0
	clr.b	(a1)+

	tst.b	d0
	beq.s	.dun

	cmp.b	#1,d0
	bne.s	.add

	lea	254(a0),a0
	bra.s	.loo

.add:
	add.l	d0,a0
	add.l	d2,(a0)
	bra.s	.loo

.dun:
* finished relocation!

* now I have to re-arrange the BP...
	lea	my_rout-$100(pc),a0	; get addr of BP
	move.l	old_text(pc),d0		; get text len

	move.l	d0,$c(a0)
	add.l	8(a0),d0	; get end of text addr

	move.l	d0,$10(a0)	; start of data

	move.l	old_data(pc),d1
	move.l	d1,$14(a0)	; len of data

	add.l	d1,d0		; start of bss
	move.l	d0,$18(a0)

* BP re-arranged...
* copy last routine onto stack:

	lea	end_copy_rout(pc),a0
	moveq	#copy_len/2-1,d0

.copy:
	move.w	-(a0),-(a7)
	dbra	d0,.copy

	lea	my_rout(pc),a1
	lea	end_my_rout(pc),a0
	move.l	old_text(pc),d0
	add.l	old_data(pc),d0

	jmp	(a7)



copy_rout:
* routine to do final copying

* a0 = start of program (real)
* a1 = start of progam (where it should be)
* d0 = length to copy

	move.l	a1,a2

	move.l	d0,d1
	lsr.l	#3,d0		; divide by 8

.long:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.long

	and.w	#7,d1
	beq.s	.noshort
.short:
	move.b	(a0)+,(a1)+
	subq.w	#1,d1
	bne.s	.short

.noshort:
* now clear the start of the BSS!
	move.w	#rout_len-1,d0

.clr:
	clr.b	(a1)+
	dbra	d0,.clr

	lea	copy_len(a7),a7
	jmp	(a2)
end_copy_rout:
copy_len	equ	*-copy_rout

	
p_mes:
	pea	(a0)
	move.w	#9,-(a7)
	dc.w	$a00a
	trap	#1
	dc.w	$a009
	addq.l	#6,a7
	rts


reloc_offset	ds.l	1
old_text	ds.l	1
old_data	ds.l	1

buffer:
	ds.b	20

patch:
	dc.b	27,"H",27,"pDevpac Patch",27,"q",10,13
	dc.b	"Reading DEVPAC.LEN",10,13,10,0
error:
	dc.b	7,"Cannot read DEVPAC.LEN!",0
dun:
	dc.b	"Buffer set to ",0

file:
	dc.b	"devpac.len",0
	even


end_my_rout:
rout_len	equ	*-my_rout



	ifnd	link
	include	files.s
	include	gem_shel.s
	include	bits.s
	include	aes_shel.s
	endc



	section	data
notdev:
	stopp
	dc.b	"[This is not Devpac V3.01!  ]"
	dc.b	"[Cancel]",0
	even


variables:
	rsreset

intro	dc.b	27,"EDevpac 3 patch program",10,13
	dc.b	"by James Ingram, January 1994",10,13,10
	dc.b	"Select Devpac!",0
_intro	rs.b	*-intro

devpac	dc.b	"DEVPAC.PRG",0
_devpac	rs.b	*-devpac

outmes	dc.b	10,13,10
	dc.b	"select save name:",0
_outmes	rs.b	*-outmes

star	dc.b	"*.*",0
_star	rs.b	*-star

	even



	section	bss

addr	ds.l	1
_addr	rs.l	1

len	ds.l	1
_len	rs.l	1


	ds.b	1000
stack:
