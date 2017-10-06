* program to make SPEED packed files
* stand-alone!


labels	equ	1
;link	equ	1

	ifd	labels
	opt	x+
	endc

	opt	o+,ow-

	ifd	link
	OPT	GST,CASE
	XREF	load_a_file,save_a_file
	XREF	file_selector,rel_mem,aes
	XREF	print_mes
	XREF	create_some,save_some,close_some,seek_start
	endc


	include	lens.i
	include	aes_defs.i



	include	proghead.s

loop:
	lea	intro(pc),a0
	bsr	print_mes

	lea	star(pc),a0
	bsr	file_selector

	tst.w	d0
	beq.s	.no_error

	clr.w	-(a7)
	trap	#1

.no_error:
	bsr	load_a_file
	tst.l	d0
	bpl.s	.noerr2
	bra.s	loop

.noerr2:
	move.l	d0,addr
	move.l	d1,len

	move.l	addr,a0
	cmp.l	#"SPv3",(a0)
	bne	not_data

	sf	is_data
	bra	got_type

* packed as data!
not_data:
	st	is_data

	cmp.l	#$4e417633,28(a0)
	beq	got_type		; branch if a Speed-packed proggy

* it isn't SPEED packed data or prog - is it one of mine???
	move.w	#"AD",type		; alone data type

	cmp.l	#"SPv3",$fe(a0)
	beq.s	.alone_dat


	move.w	#"AP",type		; alone PRG typ
	cmp.l	#"SPv3",$da(a0)
	bne	not_mine

* show to_prg alert
	alert	#1,to_prg
	cmp.w	#1,d0
	bne	free_loop
	bra.s	.yes

.alone_dat:
* show to_dat alert
	alert	#1,to_dat
	cmp.w	#1,d0
	bne	free_loop

.yes:
* put it back into Speed packed file only!
	lea	save_as(pc),a0
	bsr	print_mes
	
	lea	star(pc),a0
	bsr	file_selector
	tst.w	d0
	bmi	free_loop

	move.l	a0,name

* different rotuines for the different data types...
	cmp.w	#"AP",type
	beq.s	un_program

* it used to be a simple data file!
	bsr	create_some
	tst.w	d0
	bmi	free_loop

	move.l	addr,a1
	move.l	#code_len,d6		; get len of depacking code
	add.l	#$1c,d6			; plus prog header & reloc table

	move.l	len,d0
	sub.l	d6,d0
	subq.l	#4,d0			; don't save reloc table

	add.l	d6,a1
	bsr	save_some

	bsr	close_some
	bra	free_loop

un_program:
* used to be a Speed program... more complex!

	bsr	create_some
	tst.w	d0
	bmi	free_loop

	move.l	addr,a1
	moveq	#$1c,d0
	bsr	save_some	; save out the header as it is (for time being)
	tst.w	d0
	bmi	.sav_err

	move.l	addr,a1
	moveq	#$1c,d6
	add.l	#code2_len+depack_len,d6

	add.l	d6,a1		; goto speed packed data
	move.w	#$4e41,(a1)	; put in "trap #1"

	move.l	len,d0
	sub.l	d6,d0		; save out right amount...
	subq.l	#8,d0		; take off the extra LW at file end
				; (put in by my save routine)
				; also leave off original reloc table
	pea	(a1)
	bsr	save_some
	move.l	(a7)+,a1
	tst.w	d0
	bmi	.sav_err

	pea	(a1)

* now save out a null LW for reloc table...
	lea	zero(pc),a1
	moveq	#4,d0
	bsr	save_some

* now put the old header back in!
* complicated, this bit is!
* have to work it out from original prog length
* found at end of un-packed file!

	move.l	(a7)+,a0
	move.w	#"SP",(a0)	; put flag back in

	pea	do_depack(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7		; unpack the program!

	add.l	d0,a0		; go to end of program
	move.l	addr,a1
	addq.l	#2,a1		; a1 points to file header data

* get original file length...
	move.l	-(a0),d0
	add.l	-(a0),d0
	add.l	-(a0),d0

* and take away the file length I have right now...
	move.l	len,d1
	sub.l	#code2_len+depack_len+$1c+8,d1
	sub.l	d1,d0


* leaving the amount of bss I need...
	move.l	addr,a0		; go to header addr
	lea	2(a0),a1

	move.l	d1,(a1)+	; amount of text
	clr.l	(a1)+		; no data
	move.l	d0,(a1)+	; len of bss

	pea	(a0)		; keep addr of header safe

	moveq	#0,d1
	bsr	seek_start	; go to start of file

	move.l	(a7)+,a1
	moveq	#$1c,d0
	bsr	save_some	; save out new header!

.sav_err:
	bsr	close_some
	bra	free_loop


not_mine:
	alert	#1,not_speed
	bra	free_loop

got_type:
* get save name
* is it data type???
	tst.b	is_data
	bne.s	.no

	alert	#1,data_type
	cmp.w	#1,d0
	bne	free_loop

.no:
	lea	save_as(pc),a0
	bsr	print_mes
	
	lea	star(pc),a0
	bsr	file_selector
	tst.w	d0
	bmi	free_loop


	move.l	a0,name

* go to correct routine...
	tst.b	is_data
	beq	do_as_data

* do it as a prog type!
	move.l	addr,a0
	lea	28(a0),a0
	move.l	a0,addr

	sub.l	#28,len

	move.w	#"SP",(a0)	; complete the flag

	move.l	#code2_len+depack_len,d0
	add.l	len,d0

	move.l	d0,new_prog

* how much BSS space will I need to de-pack the file?
	clr.l	new_bss

	move.l	addr,a0

	move.l	12(a0),d0	; get de-packed length
	sub.l	8(a0),d0	; minus the packed length
	bmi.s	.none_needed

	move.l	d0,new_bss

.none_needed:
* now I can save out the new header, my bit, and old bit...

	move.l	name,a0
	bsr	create_some
	tst.w	d0
	bmi	free_loop

	lea	new_header(pc),a1
	moveq	#$1c,d0
	bsr	save_some
	tst.w	d0
	bmi	sav_err2

	lea	prog_depack(pc),a1
	move.l	#code2_len,d0
	bsr	save_some	; save the depacking bit
	tst.w	d0
	bmi	sav_err2

	lea	depack_code(pc),a1
	move.l	#depack_len,d0
	bsr	save_some	; save the depacker code
	tst.w	d0
	bmi	sav_err2

	move.l	addr,a1
	move.l	len,d0
	bsr	save_some	; and the original program
	tst.w	d0
	bmi	sav_err2

	lea	zero(pc),a1
	moveq	#4,d0
	bsr	save_some	; and a null symbol table

sav_err2:
	bsr	close_some


	bra	finished

do_as_data:
* how long is the prog section going to be?
	move.l	#code_len,d0
	add.l	len,d0

	move.l	d0,new_prog

* how much BSS space will I need to de-pack the file?
	clr.l	new_bss

	move.l	addr,a0
	move.l	12(a0),d0	; get de-packed length
	sub.l	8(a0),d0	; minus the packed length
	bmi.s	.none_needed

	move.l	d0,new_bss

.none_needed:
* now I can save out the new header, my bit, and old bit...

	move.l	name,a0
	bsr	create_some
	tst.w	d0
	bmi	free_loop

	lea	new_header(pc),a1
	moveq	#$1c,d0
	bsr	save_some
	tst.w	d0
	bmi	sav_err

	lea	data_depack(pc),a1
	move.l	#code_len,d0
	bsr	save_some	; save the depacking bit
	tst.w	d0
	bmi	sav_err

	move.l	addr,a1
	move.l	len,d0
	bsr	save_some	; and the original program
	tst.w	d0
	bmi	sav_err

	lea	zero(pc),a1
	moveq	#4,d0
	bsr	save_some	; and a null symbol table

sav_err:
	bsr	close_some

finished:
free_loop:
	move.l	addr,d0
	bsr	rel_mem
	bra	loop


prog_depack:
* depack it as program
	pea	proggy(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

* is now de-packed.
* the data for the BP is at the end!
	move.l	a0,a1
	add.l	d0,a1		; go to end of data

	move.l	d0,d4

	move.l	4(a7),a2	; get BP addr

	move.l	-(a1),d1	; get text len
	move.l	d1,$c(a2)	; into BP
	move.l	d1,d3		; keep value

	add.l	8(a2),d1	; get addr of start of data section
	move.l	d1,$10(a2)	; into BP

	move.l	-(a1),d2	; get len of data sec
	move.l	d2,$14(a2)	; into BP
	add.l	d2,d3		; add len of data section

	add.l	d2,d1		; get addr of start of bss
	move.l	d1,$18(a2)	; into BP
	move.l	d1,a3		; keep for later wiping...

	move.l	-(a1),d2	; get len of bss
	move.l	d2,$1c(a2)	; into BP

* get addr of reloc table
	move.l	a0,a1
	add.l	d3,a1

* and start addr of prog is in a0
	lea	prog_depack(pc),a2
	move.l	a2,d1		; get addr to use for relocating

	move.l	a0,a2

	move.l	(a1)+,d0
	beq.s	.dun_reloc

	add.l	d0,a2
	add.l	d1,(a2)

* now do byte segments
.reloc:
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	.dun_reloc

	cmp.b	#1,d0
	bne.s	.not_add

	lea	254(a2),a2
	bra.s	.reloc

.not_add:
	add.l	d0,a2
	add.l	d1,(a2)
	bra.s	.reloc

.dun_reloc:
* done basepage and relocation!

	move.l	d1,a1

* a0 = addr of prog
* a1 = addr to go to
* a3 = addr of bss
* d4 = len of prog
* d2 = len of bss

* now copy my routine to stack...
	lea	prog_rout+rout_len(pc),a2
	moveq	#rout_len/2-1,d0

.copy:
	move.w	-(a2),-(a7)
	dbra	d0,.copy

	jmp	(a7)


*** routine to place prog in correct place + wipe bss
*** will be placed on the stack...
prog_rout:
	move.l	a1,a2

	move.l	d4,d0
	lsr.l	#2,d0
	tst.l	d0
	beq.s	.dun_longs

.prog_l:
	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.prog_l

.dun_longs:
	and.w	#3,d4
	tst.w	d4
	beq.s	.dun_short



.prog_s:
	move.b	(a0)+,(a1)+
	subq.w	#1,d4
	bne.s	.prog_s

.dun_short:
* now wipe the bss!

	tst.l	d2
	beq.s	.dun_wipe

.wipe:
	clr.b	(a3)+
	subq.l	#1,d2
	bne.s	.wipe

.dun_wipe:
	lea	rout_len(a7),a7
	jmp	(a2)
rout_len	equ	*-prog_rout


proggy:
	lea	end_prog_bit+depack_len(pc),a0
	bsr	end_prog_bit
	rts

end_prog_bit:
code2_len	equ	*-prog_depack


data_depack:
* depack it as data...

	pea	do_depack(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

	move.l	d0,d2		; keep len of unpacked data

	pea	(a0)

	lea	$1c(a0),a1	; get start of prog
	move.l	a1,d1		; as addr to use to add on to

	add.l	2(a0),d1	; get len of program seg
	add.l	6(a0),d1	; add len of data seg
	add.l	14(a0),d1	; add len of symbol table
	move.l	a1,a0


* now we have addr of reloc table!

	lea	data_depack(pc),a1	; get addr to relocate with...
	move.l	a1,d3

	move.l	d1,a2

	move.l	(a2)+,d0
	beq	.dun_reloc

	add.l	d0,a0
	add.l	d3,(a0)

.reloc:
	moveq	#0,d0
	move.b	(a2)+,d0
	beq	.dun_reloc

	cmp.b	#1,d0
	bne.s	.not1

	lea	254(a0),a0
	bra.s	.reloc

.not1:
	add.l	d0,a0
	add.l	d3,(a0)
	bra.s	.reloc

.dun_reloc:
* done the relocation
* so now we have to alter the basepage addrs

	move.l	(a7),a0		; get prog start addr
	addq.l	#2,a0		; past "bra.s"

	move.l	8(a7),a1	; and addr of BP

	move.l	(a0)+,d0	; get prog len

	move.l	8(a1),d1	; and prog start addr
	move.l	d0,$c(a1)	; store new len

	add.l	d1,d0		; end of program area
	move.l	d0,$10(a1)	; new start of data area

	move.l	(a0)+,d1	; get data len
	move.l	d1,$14(a1)	; keep new data len

	add.l	d1,d0
	move.l	d0,$18(a1)	; new bss start addr

	move.l	(a0)+,$1c(a1)	; new bss len

* BP has now been altered.  We now have to re-position the code
* copy routine to do it onto the stack...

	move.l	(a7)+,a1	; get prog start addr
	lea	$1c(a1),a1	; past data stuff...
	lea	data_depack(pc),a2	; get addr to put it in at

	move.l	4(a7),a3	; get BP addr

	lea	.end_copy(pc),a0
	moveq	#copy_len/2-1,d0

.copy:
	move.w	-(a0),-(a7)
	dbra	d0,.copy

	jmp	(a7)		; jump to copy routine

.ccc:
	move.l	d2,d0
	lsr.l	#2,d0		; divide by 8

	move.l	a2,a0		; keep addr to jump to...

	tst.l	d0
	beq.s	.fin

.ccc2:
	move.l	(a1)+,(a2)+
	subq.l	#1,d0
	bne.s	.ccc2

.fin:
* now do any loose bytes...
	and.w	#3,d2
	tst.w	d2
	beq.s	.fin2

.ccc3:
	move.b	(a1)+,(a2)+
	subq.w	#1,d2
	bne.s	.ccc3

.fin2:

* now clear the bss section...
	move.l	$18(a3),a1
	move.l	$1c(a3),d0

.clr:
	tst.l	d0
	beq.s	.dun
	clr.b	(a1)+
	subq.l	#1,d0
	bra.s	.clr

.dun:
	lea	copy_len(a7),a7
	jmp	(a0)

.end_copy:

copy_len	equ	*-.ccc

do_depack:
	lea	data_here(pc),a0	; get addr of data to depack
	bsr	depack_code
	rts



depack_code:
	include	unpack3.s
depack_len	equ	*-depack_code

data_here:
code_len	equ	*-data_depack



	ifnd	link
	include	files.s
	include	gem_shel.s
	include	aes_shel.s
	include	bits.s
	endc

	section	data

intro:
	dc.b	7,27,"EPlease select SPEED packed file... ",0
star:
	dc.b	"*.*",0
not_speed:
	exclam
	dc.b	"[This is not a SPEED packed program. ]"
	dc.b	"[ Oh ]",0

to_prg:
	exclam
	dc.b	"[This is a Speed-packed  |"
	dc.b	"stand-alone program.|"
	dc.b	"Convert to normal Speed-packed|"
	dc.b	"program?]"
	dc.b	"[To Normal|Cancel]",0


to_dat:
	exclam
	dc.b	"[This is a Speed-packed  |"
	dc.b	"DATA FILE which has been|"
	dc.b	"converted to a program.]"
	dc.b	"[To Data|Cancel]",0


data_type:
	exclam
	dc.b	"[This is a Speed-packed file.  |"
	dc.b	"It has been packed as DATA!|"
	dc.b	"Do you wish to make it run|"
	dc.b	"as a program anyway?]"
	dc.b	"[Program|Cancel]",0


save_as:
	dc.b	10,13,"Please select name to save file as:",0


	even

new_header:
	bra.s	past_it
new_prog	dc.l	0
new_data	dc.l	0
new_bss		dc.l	0
	dcb.b	14,0
past_it:

zero	dc.l	0


	section	bss

is_data	ds.b	1
	even

addr	ds.l	1
len	ds.l	1
name	ds.l	1
type	ds.w	1

	ds.b	3000
stack:






