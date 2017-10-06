* program to analyse program headers
* by James Ingram, 1993


labels	equ	1
;link	equ	1

	ifd	labels
	opt	x+
	endc

	opt	o+,ow-
	
	ifd	link
	OPT	GST,CASE
	XREF	file_selector,load_a_file
	XREF	print_mes,print_num,conin_no_echo,rel_mem
	endc


	include	lens.i
	include	aes_defs.i
	
	include	proghead.s


loop:
	lea	select(pc),a0
	bsr	print_mes
	
	lea	star(pc),a0
	bsr	file_selector
	tst.w	d0
	beq.s	.ok

	clr.w	-(a7)
	trap	#1

.ok:
	bsr	load_a_file
	tst.l	d0
	bmi.s	loop

	move.l	d0,file_addr
	move.l	d1,file_len

	move.l	d0,a6
	cmp.w	#$601a,(a6)+
	beq.s	.is_prog

* not a program!
	move.l	a0,a6

	lea	clr(pc),a0
	bsr	print_mes
	move.l	a6,a0
	bsr	print_mes


	lea	not_prog(pc),a0
	bsr	print_mes
	bsr	conin_no_echo
	bra	finished

.is_prog:
	pea	(a0)
	lea	clr(pc),a0
	bsr	print_mes
	move.l	(a7)+,a0
	bsr	print_mes

	lea	proglen(pc),a0
	bsr	print_mes

	move.l	file_len,d0
	bsr	print_num

	lea	textlen(pc),a0
	bsr	print_mes
	move.l	(a6),d0
	bsr	print_num

	lea	datalen(pc),a0
	bsr	print_mes
	move.l	4(a6),d0
	bsr	print_num

	lea	bsslen(pc),a0
	bsr	print_mes
	move.l	8(a6),d0
	bsr	print_num

	lea	memlen(pc),a0
	bsr	print_mes
	move.l	(a6),d0
	add.l	4(a6),d0
	add.l	8(a6),d0
	bsr	print_num

	lea	extra(pc),a0
	bsr	print_mes
	move.l	file_len,d0
	sub.l	#28,d0
	sub.l	(a6),d0
	sub.l	4(a6),d0

	move.l	d0,d6

	bsr	print_num

* show len of symbol table
	lea	sym(pc),a0
	bsr	print_mes

	move.l	12(a6),d0
	bsr	print_num

* now show reloc table len
	lea	reloc_len(pc),a0
	bsr	print_mes

	move.l	file_addr,a0
	lea	$1c(a0),a0	; past header
	add.l	(a6),a0
	add.l	4(a6),a0	; get end of data section - start of reloc table

	moveq	#4,d0
	tst.l	(a0)+
	beq.s	end_reloc

.getlen:
	addq.l	#1,d0
	tst.b	(a0)+
	bne.s	.getlen

end_reloc:
	move.l	d0,d7

	bsr	print_num

	sub.l	d7,d6
	sub.l	12(a6),d6

	lea	more(pc),a0
	bsr	print_mes
	move.l	d6,d0
	bsr	print_num


	bsr	conin_no_echo


finished:
	move.l	file_addr,d0
	bsr	rel_mem
	bra	loop



	ifnd	link
	include	maths.s
	include	files.s
	include	bits.s
	include	gem_shel.s
	include	aes_shel.s
	endc


	section	data

select:
	dc.b	27,"EPlease select program to analyse...",0
clr:
	dc.b	27,"E",0

not_prog:
	dc.b	" is not a program file!",0
star:
	dc.b	"*.*",0
proglen	dc.b	10,13,10,"Program length = ",0
textlen	dc.b	10,10,13,"Text section   = ",0
datalen	dc.b	10,13,"Data section   = ",0
bsslen	dc.b	10,13,"Bss section    = ",0

memlen	dc.b	10,13,10
	dc.b	"Memory used    = ",0

extra	dc.b	10,13,10
	dc.b	"Extra file data = ",0

sym	dc.b	10,13,10
	dc.b	"Symbol table    = ",0

reloc_len	dc.b	10,13
	dc.b	"Relocation table = ",0

more	dc.b	10,13,10
	dc.b	"Unaccounted for  = ",0


	even



	section	bss

file_addr	ds.l	1
file_len	ds.l	1


	ds.b	4000
stack:
