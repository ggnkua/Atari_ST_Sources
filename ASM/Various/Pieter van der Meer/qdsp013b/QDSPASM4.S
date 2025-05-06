;	QUICK DSP ASSEMBLER (v0.13b)
;
;	by G.Audoly
;
;       revision by Pieter van der Meer
;
; version that uses hash table (for labels), works quite a bit faster.
;
;  P56 format:
;
;  adr size  discr. (size: dsp word)
;    0    1  memory (0=P, 1=X, 2=Y)
;    1    1  block start adress
;    2    1  block size (N)
;    3    N  data
;  N+3    1  memory (0=P, 1=X, 2=Y)
;  ...
;

QDSP:						; qdsp is in da house!

	COMMENT	HEAD=%111
	OPT	D-

	OUTPUT	H:\CODING\QDSP\QDSP013B.TTP

	bra	START
	INCLUDE	INCLUDE\GEMDOS.S
	INCLUDE	HASH.S
	TEXT

******** GLOBAL EQUATES ********

WARNSTALL:	=	1

page_size:	EQU	$10000			; Memory for label/macro-tables.

* Labeltypes.
pmemtype:	EQU	0
xmemtype:	EQU	1
ymemtype:	EQU	2
lmemtype:	EQU	3
equtype:	EQU	4

* Sourcefilestack format:
		RSRESET
stackentrysadr:	RS.L	1
stackentryreal:	RS.L	1
stackentrysize:	RS.B	0

******** GLOBAL MACROS ********

until:	MACRO	;#char_to_search
	move.w	\1,d0
	bsr	until
	ENDM

eror:	MACRO
	move.l	\1,-(sp)
	bsr	p_error
	addq.w	#4,sp
	ENDM

error2:	MACRO
	pea.l	\1
	tst.l	text_err(pc)
	beq.s	.ok\@
	move.l	text_err(pc),(sp)
	clr.l	text_err
.ok\@:	bsr	p_error
	addq.w	#4,sp
	ENDM

warning:MACRO
	pea	\1
	bsr	p_warn
	addq	#4,sp
	ENDM

******** MAIN CODE ********

START:	movea.l	4(sp),a6
	move.l	12(a6),d0
	add.l	20(a6),d0
	add.l	28(a6),d0
	addi.l	#256,d0
	Mshrink a6,d0
	
	lea	$80(a6),a6
	tst.b	(a6)+				; d7.w=#chars in cmdline
	bne.s	.cmdline_filled
	Cconws2	usage_txt(pc)
	bra	fin

.cmdline_filled:
	clr.l	source
	clr.l	errors_adr
	clr.l	struct_adr
	
	move.w	(a6),d0
	ori.b	#32,d0
	cmpi.w	#'-m',d0			; Used for DSPDIT!
	bne.s	not_kitdsp
	st.b	m_opt
	movea.l	2(a6),a0
	suba.l	#$11111111,a0
	move.l	a0,struct_adr
	move.l	(a0)+,source
	move.l	(a0)+,errors_adr
	movea.l	(a0)+,a6			; a6: cmdline

; test messages, disabled..
	IFNE	0
	move.l	a6,d0
	lea	shit(pc),a0
	bsr	long2hex
	move.w	#$0D0A,(a0)+
	clr.b	(a0)+
	Cconws2	shit(pc)			; test
	movea.l	source(pc),a0
	Cconws2	(a0)
	move.l	#$0A0D0000,shit
	Cconws2	shit(pc)
	ENDC

not_kitdsp:
; a6: commandline

; Get size of cmdline..
	movea.l	a6,a5
.count:	tst.b	(a5)+
	bne.s	.count
	suba.l	a6,a5
	move.w	a5,d7				; d7.w=cmdline size
.find_filename:
	move.w	d7,d5
	subq.w	#1,d7
	movea.l	a6,a4
	moveq	#-1,d6
.nospace:
	cmpi.b	#" ",(a6)+
	dbeq	d7,.nospace
	tst.w	d7
	bmi.s	.spaces_parsed
	move.w	d7,d6				; d7<0, means no space found
	bra.s	.nospace
.spaces_parsed:
	tst.w	d6
	bmi.s	.no_options
	sub.w	d6,d5
	lea	(a4,d5.w),a6
	bra.s	.end_find_filename
; only one word, so it's the filename and no options..
.no_options:
	movea.l	a4,a6				; filename
	tst.b	m_opt
	beq	opt_end				; only one word and no dspdit -> this means no options! 
.end_find_filename:
; d5.w=options size
; a4: options (null terminated)
; a6: source filename (possibly ;))

options:subq.w	#1,d5
	beq.s	opt_end
	move.b	(a4)+,d0
	beq.s	opt_end
	cmp.b	#' ',d0
	beq.s	options
	cmp.b	#'-',d0
	beq.s	options
	or.b	#$20,d0
opt_o:	cmp.b	#'o',d0
	bne.s	opt_l
	tst.b	m_opt
	beq	opt_end				; no dspdit -> don't modify filename addy!
	move.l	a4,a6				; we definitely found the source filename!
.sh:	tst.b	(a4)
	beq.s	opt_end
	cmp.b	#' ',(a4)+
	bne.s	.sh
	subq.w	#1,a4
	bra.s	options

opt_l:	cmp.b	#'l',d0
	bne.s	opt_n
	st.b	l_opt
	bra.s	options
	
opt_n:	cmp.b	#'n',d0
	bne.s	opt_w
	st.b	n_opt
	bra.s	options

opt_w:	cmpi.b	#'w',d0
	bne.s	opt_
	st.b	w_opt
	bra.s	options

opt_:	bra.s	options
opt_end:

; copy filename and store it's address
; a6: filename
	lea	savename_txt(pc),a0
	move.l	a0,filename_adr
	move.l	a0,a1
.copyname_loop:
	move.b	(a6)+,d0
	cmpi.b	#" ",d0
	beq.s	.end_copy
	move.b	d0,(a0)+
	bne.s	.copyname_loop
.end_copy:
	clr.b	(a0)

; set the filepath using the filename
	move.l	a4,-(sp)
	bsr	SET_FILEPATH
	movea.l	(sp)+,a4
	tst.l	d0
	bpl.s	.end_set_path
	Cconws2	usage_txt(pc)
	bra	fin
.end_set_path:

* Allocate memory for label-table.
	Malloc	#page_size+4
	tst.l	d0
	blt	err_mem
	move.l	d0,a0
	move.l	d0,lbl0
	clr.l	(a0)+
	move.l	a0,lbl_pt
	move.l	lbl_pt(pc),lbl
	subq.l	#4,lbl
	move.l	#lbl_pt,lbl_pt0
	move.w	#page_size/4,d7
	moveq	#0,d0
.clrloop:
	move.l	d0,(a0)+
	dbra	d7,.clrloop

* Allocate memory for macro-table.
	Malloc	#page_size+4
	tst.l	d0
	blt	err_mem
	move.l	d0,a0
	move.l	d0,mac0
	clr.l	(a0)+
	move.l	a0,mac_pt
	move.l	mac_pt(pc),mac
	subq.l	#4,mac
	move.l	#mac_pt,mac_pt0

	Malloc	#$18000
	tst.l	d0
	blt	err_mem
	move.l	d0,a6
	move.l	a6,dest

	clr.l	apc

	Cconws2	t_intro(pc)

	move.l	a6,dest2
	clr.b	pass				; Set to pass 1.

	bsr	Hash.init			; Initialise hash table.
	tst.l	d0
	bmi	fin

new_pass:
	move.l	dest2(pc),a6
	move.b	pass(pc),tpass0
	add.b	#'1',tpass0
	Cconws2	tpass(pc)

	move.l	#dest0+3,dest0
	clr.w	line
	clr.b	lbel
	clr.w	mac_mode
	clr.w	mac_def
	clr.w	mac_no
	clr.l	mac_adr
	clr.w	dont_asm
	move.l	#ldont_asm,adont_asm

asm_newfile:
	tst.b	m_opt(pc)
	bne.s	.no_sourceload
	tst.b	pass(pc)
	bne.s	.pass2
	move.l	a6,-(sp)			* Save destination.
	movea.l	filename_adr,a6
* a6: filename
	movea.l	source(pc),a5
	move.l	a6,afich
	move.l	a6,-(sp)
	bsr	load
	addq	#4,sp
	movea.l	(sp)+,a6			* Restore destination.
	tst.l	d0
	bpl.s	.okido
	Cconws2	usage_txt(pc)
	bra	fin
.okido:	move.l	#$0d0a0000,(a0,d0.l)		* Add file-end!!
	movea.l	a0,a5
	move.l	a5,source
	move.l	a5,source2			* Make a backup of the sourceaddress.
	move.w	sourcefilestackdepth(pc),d0
	addq.w	#1,d0
	mulu.w	#stackentrysize,d0
	lea	(sourcefilestack_tbl,d0.l),a0
	move.l	a5,stackentrysadr(a0)
	bra.s	.end_fileinit
.pass2:	move.w	sourcefilestackdepth(pc),d0
	addq.w	#1,d0
	mulu.w	#stackentrysize,d0
	lea	(sourcefilestack_tbl,d0.l),a0
	move.l	stackentrysadr(a0),source
.no_sourceload:
	move.l	source(pc),source2
.end_fileinit:

	move.l	source2(pc),real_source
	lea	line_buff(pc),a5

new_one:clr.l	text_err
	sub.l	#line_buff,a5
	add.l	real_source(pc),a5
	
; You can output the line to screen here..

	move.l	a5,real_source
	lea	line_buff(pc),a0
	move.l	a0,left_line
	move.l	-4(a5),-4(a0)
	tst.l	mac_adr(pc)
	beq.s	.copy
.copy2:			;if we are using a macro
	move.b	(a5)+,d0
	cmp.b	#'\',d0
	bne.s	.not_par
	move.b	(a5)+,d0
	sub.b	#'1',d0
	cmp.b	#9,d0
	blo.s	.cool
	error2	terr_macro_par(pc)
	bra	ins_end
.cool:	ext.w	d0
	asl.w	#6,d0	;*64
	lea	(mac_par.w,pc,d0.w),a4	;get the parameter
.copy_par:				;and copy it
	move.b	(a4)+,d0
	move.b	d0,(a0)+
	bne.s	.copy_par
	subq.l	#1,a0
	bra.s	.copy2
.not_par:
	move.b	d0,(a0)+
	cmp.b	#13,d0
	beq.s	.copyf
	tst.b	d0
	bne.s	.copy2
	bra.s	.copyf
.copy:	move.b	(a5)+,d0
	beq.s	.last
	cmpi.b	#13,d0
	beq.s	.last
	move.b	d0,(a0)+
	bra.s	.copy
.last:	move.b	d0,(a0)+
.copyf:	move.l	(a5),(a0)
	move.l	a5,d1
	sub.l	real_source(pc),d1
	lea	line_buff(pc),a5
	move.l	a0,d0
	sub.l	a5,d0
	sub.l	d1,d0
	sub.l	d0,real_source	;to adjust line size. (if macro, it's not the same)
	
	tst.l	mac_adr(pc)	;do not count when we're using a macro
	bne.s	.macro
	addq.w	#1,line
.macro:	move.b	(a5)+,d6
	beq.s	.br0
	cmp.b	#13,d6
	bne.s	.br1
.br0:	subq.w	#1,a5
	bra	ins_end
.br1:	cmp.b	#' ',d6
	beq	instruc0
	cmp.b	#9,d6
	beq	instruc0
	cmp.b	#';',d6
	beq	ins_end
	tst.w	dont_asm(pc)
	bne	instruc00
	move.b	mac_def(pc),d0
	bne	ins_end
	lea	-1(a5),a4

;- label handlers ----------------------------------------------------------
;
; this means macros, equates, program labels, anything really..

label:	move.b	(a5)+,d6
	beq.s	labl
	cmp.b	#':',d6
	beq.s	labl
	cmp.b	#9,d6
	beq.s	labl
	cmp.b	#'=',d6
	beq	equ
	cmp.b	#10,d6
	beq.s	labl
	cmp.b	#13,d6
	beq.s	labl
	cmp.b	#' ',d6
	bne.s	label

labl:	tst.b	dont_asm(pc)
	bne	instruc0
	move.l	a5,a0	
.br1b:	move.b	(a0)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq	labll
	tst.b	d0
	beq	labll
	or.b	#$20,d0
	cmp.b	#'m',d0
	bne	labll
	move.l	(a0),d0
	or.l	#$20202020,d0
	cmp.l	#'acro',d0
	bne	labll

; macro searching crap..
; todo:
; damn, this rout is almost the same as that of program one.
; i should combine both first and replace that with has stuff..
; hhhmmm, or maybe leave this cos there are much fewer macros than labels.
	;lea	4(a0),a3
	sub.l	#line_buff,a0
	add.l	real_source(pc),a0
	move.l	a0,mac_adr0
	addq.l	#4,mac_adr0
	
	move.l	a5,d0
	sub.l	a4,d0
	addq.w	#7,d0

; this is the place where it starts to look like program label stuff..
	;sub.w	d0,d7
	move.l	mac_pt(pc),a3
	move.l	mac_pt0(pc),a0
	move.l	a3,(a0)
	move.l	a3,mac_pt0
	clr.l	(a3)+
	sub.w	#9,d0

	movem.l	d0/d5/d6/a0/a1/a5,-(sp)
	move.w	d0,d5
	move.l	a4,a0
	
	move.l	mac(pc),d6
	addq.l	#4,d6
.loop0:	cmp.l	mac_pt(pc),d6
	bhs.s	.oops
	tst.l	d6
	beq.s	.oops
	move.l	d6,a1
	move.l	a0,a5
	move.l	(a1)+,d6
	move.w	d5,d0
.loop1:	cmpm.b	(a5)+,(a1)+
	dbne	d0,.loop1
	tst.w	d0
	bge.s	.loop0
	addq.w	#4,a1
	cmp.l	mac_pt(pc),a1
	beq.s	.ici0
	cmp.l	d6,a1
	bne.s	.loop0
.ici0:	subq.w	#4,a1
	move.l	a1,a3
	movem.l	(sp)+,d0/d5/d6/a0/a1/a5
	;add.w	d0,a4
	;addq.w	#1,a4
	bra.s	copy_macf
.oops:	movem.l	(sp)+,d0/d5/d6/a0/a1/a5

copy_mac:	
	move.b	(a4)+,(a3)+
	dbra	d0,copy_mac
	move.l	a3,mac_pt
	addq.l	#4,mac_pt
copy_macf:	
	move.l	mac_adr0(pc),a5
	move.l	a5,(a3)
	add.l	#line_buff,a5
	sub.l	real_source(pc),a5
	st.b	mac_def

.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	sub.l	#line_buff,a5
	add.l	real_source(pc),a5
	move.l	a5,(a3)
	add.l	#line_buff,a5
	sub.l	real_source(pc),a5
	bra	ins_end0

;- program label handler -
labll:	move.l	a5,d0
	sub.l	a4,d0
	addq.w	#7,d0
	cmp.w	#'__',(a4)
	bne.s	nomloc
	
; Output number in label to keep it unique.
	move.l	a4,a2
	lea	lbel(pc),a3
	lea	lbel0(pc),a4
	move.w	d0,d6
	sub.w	#9,d6
	move.w	mac_no(pc),-(sp)
	bsr	mkhex4
	addq.w	#4,d0
.copy0:	move.b	(a2)+,(a4)+
	dbra	d6,.copy0
	clr.b	(a4)
	lea	lbel0(pc),a4
	bra.s	noloc2
nomloc:	cmp.b	#'_',(a4)
	bne.s	noloc
	
	move.l	a4,a2
	lea	lbel(pc),a3
	lea	lbel0(pc),a4
	move.w	d0,d6
	sub.w	#9,d6
.copy:	addq.w	#1,d0
	move.b	(a3)+,(a4)+
	bne.s	.copy
	subq.w	#1,d0
	subq.w	#1,a4
.copy0:	move.b	(a2)+,(a4)+
	dbf	d6,.copy0
	clr.b	(a4)
	lea	lbel0(pc),a4
	bra.s	noloc2

noloc:
; copy this label to 'global' label.
	move.l	a4,a2
	lea	lbel(pc),a3
	move.w	d0,d6
	sub.w	#9,d6
.copy0:	move.b	(a2)+,(a3)+
	dbra	d6,.copy0
	clr.b	(a3)
	lea	lbel(pc),a4

; global program label (or equate).
noloc2:	move.l	a5,a0				; a0: end of string
.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	tst.b	d0
	beq	asm_end
	cmp.b	#13,d0
	seq	d7				; Set eol.
	beq.s	.program_label

; If it's an equate, change address/memtype data..
	moveq	#0,d0
	move.b	-1(a5),d0
	lsl.w	#8,d0
	or.b	(a5)+,d0
	lsl.l	#8,d0
	or.b	(a5)+,d0
	move.l	d0,d1
	or.l	#$202020,d1
	cmp.l	#'equ',d1
	beq.s	equ
	subq.w	#2,a5
	swap	d0
	cmp.b	#'=',d0
	beq.s	equ
	lea	-1(a0),a5
; It's a program label, put it in the hashtable..

.program_label:
	movea.l	a4,a0
	move.l	apc(pc),d1
	swap	d1
	not.b	d1
	lsl.w	#8,d1
	swap	d1				; d1.l=data
	bsr	addString0
	tst.l	d0
	bmi	err_mem
	tst.w	Hash.wasFound(pc)
	beq.s	.no_error
	tst.b	pass(pc)
	beq	err_symboltwice
.no_error:
	tst.b	d7				; eol reached?
	beq	instruc0			; no -> get instruction
	bra	ins_end0			; yes -> next line
	
equ:	
.br1b:	cmp.b	#' ',(a5)+
	beq.s	.br1b
	cmp.b	#9,-1(a5)
	beq.s	.br1b
	cmp.b	#13,d0
	bne.s	.br1c
	error2	terr_equ(pc)
	bra	ins_end
.br1c:	tst.b	d0
	bne.s	.br1d
	error2	terr_equ(pc)
	bra	asm_end
.br1d:	subq.w	#1,a5
	bsr	get_value
	tst.w	d5
	bge.s	.br2
.err:	error2	terr_val(pc)
	bra	ins_end
.br2:	move.l	d6,d1
	swap	d1
	move.w	#equtype<<8,d1
	swap	d1				; d1.l=data
	lea	lbel(pc),a0			; a0: search string
	bsr	addString0
	tst.l	d0
	bmi	err_mem
	tst.w	Hash.wasFound(pc)
	beq.s	.no_error
	tst.b	pass(pc)
	beq	err_symboltwice
.no_error:
	bra	ins_end

;- instruction handlers ----------------------------------------------------

entire:	MACRO	;#car,#adr
	cmp.b	#9,\1
	beq.s	.\@1
	cmp.b	#' ',\1
	beq.s	.\@1
	tst.b	\1
	beq.s	.\@1
	cmp.b	#13,\1
	bne	\2
.\@1:	
	ENDM

nowh2:	MACRO
.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq	\1
	tst.b	d0
	beq	asm_end
.br1d:	
	ENDM

nowh:	MACRO
.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	bne.s	.br1c
.br1e:	error2	terr_op_miss(pc)
	bra	ins_end
.br1c:	tst.b	d0
	bne.s	.br1d
	error2	terr_op_miss(pc)
	bra	asm_end
.br1d:	
	ENDM
	
instruc00:	
	nowh
	subq.l	#1,a5
instruc0:	
	cmp.b	#':',(a5)
	bne.s	.ici
	addq.w	#1,a5
.ici:	move.b	(a5)+,d0
	cmp.b	#';',d0
	beq	ins_end
	cmp.b	#' ',d0
	beq.s	instruc0
	cmp.b	#9,d0
	beq.s	instruc0
	cmp.b	#13,d0
	beq	ins_end0
	tst.b	d0
	beq	asm_end
	subq.w	#1,a5

	tst.w	dont_asm(pc)
	bne	do_directives
	tst.b	mac_def(pc)
	bne	endm

* >>> Handling of actual DSP-instuctions begins here!
* Store last register-usage information and reset new one.
	lea	userx_tbl(pc),a0
	move.b	(a0)+,(a0)
	clr.b	-(a0)
	lea	usenx_tbl(pc),a0
	move.b	(a0)+,(a0)
	clr.b	-(a0)

movem:	move.l	a5,a0
	move.l	a5,a2
	move.l	a6,a4
	move.l	apc(pc),d4
	
	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'move',d0
	bne	nomove
	move.b	4(a5),d0
	or.b	#$20,d0
	cmp.b	#'m',d0
	beq	movem0
	cmp.b	#'p',d0
	beq	movep
	addq.w	#4,a5
	cmp.b	#'c',d0
	beq	movec0
	nowh
	subq.w	#1,a5
	move.w	(a5),d0
	or.w	#$2000,d0
	cmp.w	#'p:',d0
	beq	movem1
	move.l	a5,a1
.ici:	move.b	(a1)+,d0
	beq	nomovem
	cmp.b	#13,d0
	beq	nomovem
	cmp.b	#10,d0
	beq	nomovem
	cmp.b	#' ',d0
	beq	nomovem
	cmp.b	#9,d0
	beq	nomovem
	cmp.b	#',',d0
	bne.s	.ici
	move.w	(a1),d0
	or.w	#$2000,d0
	cmp.w	#'p:',d0
	beq.s	movem1
	lea	4(a0),a5
	bra	nomovem
	
movem0:	addq.w	#5,a5
	nowh
	subq.w	#1,a5
movem1:	move.w	(a5),d0
	or.w	#$2000,d0
	cmp.w	#'p:',d0
	bne.s	r2p
	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_op
	
	cmp.b	#',',(a5)+
	bne	op_miss
	move.w	d0,d3
	bsr	get_destreg			* Get dest. reg.
	tst.w	d0
	blt	err_op
	
	addq.w	#1,apc+2
	move.w	#$0780,(a6)+
	or.b	d3,-1(a6)
	cmp.b	#$40,d3
	blo.s	.ici
	or.b	#$80,d0
.ici:	move.b	d0,(a6)+
	tst.w	d2
	beq	ins_end0
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+	

	bsr	untilwh
	bra	noparal_move

r2p:	bsr	get_srcreg			* Get src. reg.
	tst.w	d0
	blt	err_op
	cmp.b	#',',(a5)+
	bne	op_miss
	move.w	d0,d3
	move.w	(a5)+,d0
	or.w	#$2000,d0
	cmp.w	#'p:',d0
	bne	err_movem
	bsr	ea
	tst.w	d0
	blt	err_op

	addq.w	#1,apc+2
	move.w	#$0700,(a6)+
	or.b	d0,-1(a6)
	cmp.b	#$40,d0
	blo.s	.ici
	or.b	#$80,d3
.ici:	move.b	d3,(a6)+
	tst.w	d2
	beq	ins_end0
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+	

	bsr	untilwh
	bra	noparal_move

movep:	addq.w	#5,a5
	nowh
	subq.w	#1,a5
	move.l	a5,a1
	move.l	a6,a2
	move.l	apc(pc),d3
	cmp.b	#':',1(a5)
	bne	nomvpea
	
	move.b	(a5),d0
io2:	or.b	#$20,d0
	moveq	#8,d1
	cmp.b	#'x',d0
	beq.s	.ici
	moveq	#9,d1
	cmp.b	#'y',d0
	bne	p2io		;bne	err_vmem
.ici:	movea.l	a5,a4
	addq.w	#2,a5
	bsr	get_value
	tst.w	d5
	blt.s	.notio
	cmp.w	#$ffc0,d6
	bhs.s	.is_io
.notio:	movea.l	a4,a5
	bra	noio
.is_io:	addq.w	#1,apc+2
	move.b	d1,(a6)+
	move.b	#$80,(a6)+
	and.w	#$3f,d6
	move.b	d6,(a6)+
	cmp.b	#',',(a5)+
	bne	op_miss
	cmp.b	#':',1(a5)
	bne	io2r
	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'p',d0
	bne	io2x
io2p:	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_val
	
	cmp.b	#$40,d0
	bhs.s	.noshort
	moveq	#0,d6
	move.b	d0,d6
	moveq	#$70,d0
.noshort:	
	move.b	d0,-2(a6)
	or.b	#$40,-1(a6)
	cmp.b	#$70,d0
	bne.s	.noadr
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.noadr:	
	bsr	untilwh
	bra	noparal_move
	
io2x:	move.b	(a5),d0
	or.b	#$20,d0
	moveq	#$80-$100,d1
	cmp.b	#'x',d0
	beq.s	.ici
	moveq	#$c0-$100,d1
	cmp.b	#'y',d0
	bne	err_vmem
.ici:	addq.w	#2,a5
	cmpi.b	#"<",(a5)
	beq	err_range
	bsr	ea
	tst.w	d0
	blt	err_val
	
	cmp.b	#$40,d0
	bhs.s	.noshort
	moveq	#0,d6
	move.b	d0,d6
	moveq	#$70,d0
.noshort:	
	move.b	d0,-2(a6)
	or.b	d1,-1(a6)
	cmp.b	#$70,d0
	bne.s	.noadr
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.noadr:	
	bsr	untilwh
	bra	noparal_move

io2r:	bsr	get_destreg			* Get dest. reg?
	tst.w	d0
	blt	err_op
	or.b	#$40,d0
	move.b	d0,-2(a6)
	bsr	untilwh
	bra	noparal_move
noio:	

p2io:	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'p',d0
	bne.s	x2io
	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_val
	
	cmp.b	#$40,d0
	bhs.s	.noshort
	moveq	#0,d6
	move.b	d0,d6
	moveq	#$70,d0
.noshort:	
	or.b	#$80,d0
	move.l	a6,a0
	addq.w	#1,apc+2
	move.b	#8,(a6)+
	move.b	d0,(a6)+
	move.b	#$40,(a6)+
	cmp.b	#$f0,d0
	bne.s	.noadr
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.noadr:	bra	toio
	
x2io:	moveq	#$80-$100,d1
	cmp.b	#'x',d0
	beq.s	.ici
	moveq	#$c0-$100,d1
	cmp.b	#'y',d0
	bne	err_vmem
.ici:	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_val
	
	cmp.b	#$40,d0
	bhs.s	.noshort
	moveq	#0,d6
	move.b	d0,d6
	moveq	#$70,d0
.noshort:	
	or.b	#$80,d0
	move.l	a6,a0
	addq.w	#1,apc+2
	move.b	#8,(a6)+
	move.b	d0,(a6)+
	move.b	d1,(a6)+
	cmp.b	#$f0,d0
	bne.s	.noadr
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.noadr:	bra	toio
nomvpea:	

	cmp.b	#'#',(a5)
	beq.s	i2io
r2io:	bsr	get_srcreg			* Get scr. reg.
	tst.w	d0
	blt	err_op
	or.b	#$c0,d0
	addq.w	#1,apc+2
	move.l	a6,a0
	move.b	#8,(a6)+
	move.b	d0,(a6)+
	clr.b	(a6)+
	bra	toio
	
i2io:	addq.w	#1,a5
	cmp.b	#'>',(a5)
	bne.s	.ici
	addq	#1,a5
	bra.s	.ici2
.ici:	cmpi.b	#'<',(a5)
	bne.s	.ici2
	addq	#1,a5
	cmpi.b	#'<',(a5)
	bne	err_range
	addq	#1,a5
.ici2:	bsr	get_value
	tst.w	d5
	blt	err_val
	addq.w	#2,apc+2
	move.l	a6,a0
	move.w	#$08f4,(a6)+
	move.b	#$80,(a6)+
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	
toio:	cmp.b	#',',(a5)+
	bne	op_miss
	cmp.b	#':',1(a5)
	bne	no2io
	move.b	(a5),d0
	or.b	#$20,d0
	addq.w	#2,a5
	moveq	#8,d1
	cmp.b	#'x',d0
	beq.s	.ici
	moveq	#9,d1
	cmp.b	#'y',d0
	bne	err_vmem
.ici:	cmp.b	#'<',(a5)
	bne.s	.ici2
	addq.w	#1,a5				* PROBLEM!
	bra.s	.ici
.ici2:	bsr	get_value			* PROBLEM! (bsr	ea?)
	tst.w	d5				* PROBLEM!
	blt	err_val				* PROBLEM!
	cmp.w	#$ffc0,d6			* 
	blo	err_range

;	tst.w	d0
;	blt	err_val
;	cmp.b	#$40,d0
;	bhs	err_range
;	or.b	d0,2(a0)
;	move.b	d1,

	move.b	d1,(a0)
	and.b	#$3f,d6
	or.b	d6,2(a0)
	bsr	untilwh
	bra	ins_end

no2io:	cmp.b	#':',1(a1)
	bne	err_op
	move.l	a1,a5
	move.b	(a5),d0
	subq.w	#2,a5
	move.l	a2,a6
	move.l	d3,apc
	bra	ins_end		;bra	io2

movec0:	addq.w	#1,a5
nomovem:
movec:	nowh
	subq.w	#1,a5
	cmp.b	#':',1(a5)
	bne	c2
x2c:	moveq	#$20,d1
	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'x',d0
	beq.s	.ici
	moveq	#$60,d1
	cmp.b	#'y',d0
	bne	c2
.ici:	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_op
	addq.w	#1,apc+2
	move.b	#$5,(a6)+
	or.b	#$80,d0
	move.b	d0,(a6)+
	move.b	d1,(a6)+
	move.l	a6,a3
	cmp.b	#$f0,d0
	bne.s	toc
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
toc:	cmp.b	#',',(a5)+
	bne	op_miss
	move.l	a5,a0
	bsr	regc
	tst.w	d0
	blt	err_rc
	or.b	d0,-1(a3)
	bsr	untilwh
	bra	noparal_move

c2:	move.l	a5,a0
	bsr	regc
	tst.w	d0
	blt	r2c
	cmp.b	#',',(a5)+
	bne	op_miss
	cmp.b	#':',1(a5)
	bne	c2r
c2x:	move.b	d0,d2
	moveq	#$20,d1
	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'x',d0
	beq.s	.ici
	moveq	#$60,d1
	cmp.b	#'y',d0
	bne	err_vmem
.ici:	addq.w	#1,apc+2
	move.b	#5,(a6)+
	;move.b	#$40,(a6)+
	clr.b	(a6)+
	or.b	d1,d2
	move.b	d2,(a6)+
	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_op
	
	or.b	d0,-2(a6)
	cmp.b	#$70,d0
	bne.s	.noadr
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.noadr:	bsr	untilwh
	bra	ins_end
	
c2r:	addq.w	#1,apc+2
	move.b	#4,(a6)+
	move.b	#$40,(a6)+
	or.b	#$a0,d0
	move.b	d0,(a6)+
	move.l	a5,a0
	bsr	get_destreg			* Get dest. reg.
	tst.w	d0
	blt	err_op
	or.b	d0,-2(a6)
	bsr	untilwh
	bra	ins_end
	
r2c:	move.l	a5,a0
	bsr	get_srcreg			* Get src. reg.
	tst.w	d0
	blt	i2c
	cmp.b	#',',(a5)
	bne	i2c
	addq.w	#1,apc+2
	move.b	#4,(a6)+
	or.b	#$C0,d0
	move.b	d0,(a6)+
	move.b	#$A0,(a6)+
	move.l	a6,a3
	bra	toc
	
i2c:	cmp.b	#'#',(a5)+
	bne	err_rc
	cmp.b	#'>',(a5)
	beq.s	clong
	cmp.b	#'<',(a5)
	bne.s	clong1
	addq.w	#1,a5
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.w	#$100,d6
	bge	err_range
	cmp.w	#-$80,d6
	blt	err_range
	addq.w	#1,apc+2
	move.b	#5,(a6)+
	move.b	d6,(a6)+
	move.b	#$a0,(a6)+
	move.l	a6,a3
	bra	toc
	
clong:	addq.w	#1,a5
clong1:	bsr	get_value
	tst.w	d5
	blt	err_val
clong0:	addq.w	#2,apc+2
	move.w	#$5f4,(a6)+
	move.b	#$20,(a6)+
	move.l	a6,a3
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	bra	toc
	
err_rc:
move:			;MOVE ?,?
	lea	4(a2),a5
	move.l	a4,a6
	move.l	d4,apc
	
	addq.w	#1,apc+2
	move.w	#$2000,(a6)+
	clr.b	(a6)+
	bra	paral_move
nomove:

jcc:	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'j',d0
	bne	nojcc
	
	move.w	1(a5),d0
	or.w	#$2020,d0

	lea	cc-1(pc),a1
.next_one:
	addq.w	#1,a1
	tst.b	(a1)
	beq	nojcc
	move.l	a5,a0
.next0:	cmp.w	(a1)+,d0
	bne.s	.next_one
	move.b	(a1)+,d4
	or.b	#$a0,d4
	entire	3(a5),nojcc
	addq.w	#3,a5
	nowh
	subq.w	#1,a5
	moveq	#0,d3
	cmp.b	#'>',(a5)+
	beq.s	jcclong
	cmp.b	#'<',-1(a5)
	beq.s	.ici
	subq.w	#1,a5
	moveq	#-1,d3
.ici:	move.l	a5,a0
	bsr	get_value
	move.l	a5,a1
	move.l	a0,a5
	tst.w	d5
	blt.s	jcclong0
	tst.w	d3
	bge.s	.short
	cmp.w	apc+2(pc),d6
	bhi.s	jcclong0
	cmp.w	#$1000,d6
	bhs.s	jcclong0
.short:	cmp.w	#$1000,d6
	bhs	err_range
	move.l	a1,a5
	addq.w	#1,apc+2
	move.b	#$e,(a6)+
	lsl.b	#4,d4
	move.w	d6,d0
	ror.w	#8,d0
	or.b	d0,d4
	move.b	d4,(a6)+
	rol.w	#8,d0
	move.b	d0,(a6)+

	bsr	untilwh
	bra	noparal_move

jcclong:	
	subq.w	#1,a5
	bra.s	jcclong00
jcclong0:	
	cmp.b	#'>',(a5)+
	beq.s	.ici0
	subq.w	#1,a5
.ici0:	
jcclong00:	
	bsr	ea
	tst.w	d0
	blt	err_op
	
	or.b	#$a0,d4
	addq.w	#1,apc+2
	move.b	#$a,(a6)+
	move.b	#$80,(a6)
	or.b	d0,(a6)+
	move.b	d4,(a6)+
	cmp.b	#$70,d0
	bne	.ici
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.ici:	bsr	untilwh
	bra	noparal_move
nojcc:	
jscc:	move.w	(a5),d0
	or.w	#$2020,d0
	cmp.w	#'js',d0
	bne	nojscc
	
	move.w	2(a5),d0
	or.w	#$2020,d0

	lea	cc-1(pc),a1
.next_one:
	addq.w	#1,a1
	tst.b	(a1)
	beq	nojscc
	move.l	a5,a0
.next0:	cmp.w	(a1)+,d0
	bne.s	.next_one
	move.b	(a1)+,d4
	or.b	#$a0,d4
	entire	4(a5),nojscc
	addq.w	#4,a5
	nowh
	subq.w	#1,a5
	move.l	a5,a0
	bsr	ea
	tst.w	d0
	blt	err_op
	
	ext.w	d0
	addq.w	#1,apc+2
	move.b	#$b,(a6)+
	move.b	#$80,(a6)
	or.b	d0,(a6)+
	move.b	d4,(a6)+
	cmp.b	#'<',(a0)
	beq.s	jsshort1
	cmp.w	#$40,d0
	blt.s	jsshort0
jslong0:
	tst.w	d2
	beq.s	.ici
	cmp.w	apc+2(pc),d6
	bhi.s	.ici0
	cmp.w	#$1000,d6
	bhs.s	.ici0
	move.w	d6,d0
	bra.s	jsshort
.ici0:	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.ici:	bsr	untilwh
	bra	noparal_move
	
jsshort1:	
	move.w	d6,d0
	bra.s	jsshort
jsshort0:	
	cmp.w	apc+2(pc),d6
	bls.s	jsshort
	moveq	#0,d6
	move.w	d0,d6
	move.b	#$70,d0
	moveq	#-1,d2
	bra.s	jslong0
jsshort:	
	move.b	#$f,-3(a6)
	lsl.b	#4,d4
	ror.w	#8,d0
	or.b	d0,d4
	move.b	d4,-2(a6)
	rol.w	#8,d0
	move.b	d0,-1(a6)
	bsr	untilwh
	bra	noparal_move
nojscc:

twoop:			;2 op intructions
	lea	ins2(pc),a1
.next_one:
	tst.b	(a1)
	beq	notwoop
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#2,a1
	bra.s	.next_one
.found:	entire	(a0),notwoop
	move.l	a0,a5
	
	nowh

	addq.w	#1,a1
	move.w	#$2000,(a6)+
	move.b	(a1)+,(a6)+
	addq.w	#1,apc+2

	lea	1(a5),a4
	cmp.b	#',',(a4)
	bne.s	.short
	addq.w	#1,a4
.short:	move.b	(a4)+,d0
	or.b	#$20,d0
	move.b	d0,d3
	subq.b	#1,d3	;"a"->"b"  ,  "b"->"a"
	eor.b	#1,d3
	addq.b	#1,d3

	cmpi.b	#'a',d0
	beq.s	.pasb
	cmp.b	#'b',d0
	bne	err_op
	or.b	#$8,-1(a6)
.pasb:	move.b	-1(a5),d0
	or.b	#$20,d0
	move.b	(a1)+,d1
	bne.s	mode1
	cmp.b	#'x',d0
	beq	modef
	cmp.b	#'y',d0
	bne	err_op
	or.b	#$10,-1(a6)
	bra	modef

mode1:	cmp.b	#1,d1
	bne.s	mode2
	
	moveq	#$20,d2
	cmp.b	#'x',d0
	beq.s	mode1c
	cmp.b	#'y',d0
	beq.s	mode1b
	
	cmp.b	d0,d3
	bne	err_op
	or.b	#$10,-1(a6)
	bra	modef
mode1b:	moveq	#$30,d2
mode1c:	cmp.b	#',',(a5)
	beq.s	mode1f
	add.b	#$40,d2
	cmp.b	#'1',(a5)
	beq.s	mode1f
	cmp.b	#'0',(a5)
	bne	err_op
	sub.b	#$20,d2
	
mode1f:	or.b	d2,-1(a6)
	bra	modef
mode2:	cmp.b	#2,d1
	bne.s	mode3
	cmp.b	d3,d0
	bne	err_op
	bra	modef
	
mode3:	cmp.b	#3,d1
	bne.s	mode4
	
	moveq	#$20,d2
	cmp.b	#'x',d0
	beq.s	mode3c
	cmp.b	#'y',d0
	bne	err_op
	moveq	#$30,d2
mode3c:	cmp.b	#'1',(a5)+
	beq.s	mode3f
	cmp.b	#'0',-1(a5)
	bne	err_op
	sub.b	#$20,d2
mode3f:	or.b	d2,-1(a6)
	bra.s	modef

mode4:	cmp.b	#4,d1
	bne.s	modef
	moveq	#$40,d2
	cmp.b	#'x',d0
	beq.s	mode4c
	cmp.b	#'y',d0
	bne.s	mode4d
	moveq	#$50,d2
mode4c:	cmp.b	#'0',(a5)
	beq.s	mode4f
	cmp.b	#'1',(a5)
	bne	err_op
	add.b	#$20,d2
	bra.s	mode4f
mode4d:	cmp.b	d3,d0
	bne	err_op
	clr.b	d2
mode4f:	or.b	d2,-1(a6)

modef:	bsr	untilwh
	;move.l	a4,a5
	bra	paral_move
notwoop:

jmp:	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	moveq	#0,d4
	cmp.l	#'jmp',d0
	beq	.ok
	moveq	#1,d4
	cmp.l	#'jsr',d0
	bne	nojmp
.ok:	entire	3(a5),nojmp
	addq.w	#3,a5
	nowh
	subq.w	#1,a5
	moveq	#0,d3
	cmp.b	#'>',(a5)+
	beq.s	jmplong
	cmp.b	#'<',-1(a5)
	beq.s	.ici
	subq.w	#1,a5
	moveq	#-1,d3
.ici:	move.l	a5,a0
	bsr	get_value
	move.l	a5,a1
	move.l	a0,a5
	tst.w	d5
	blt.s	jmplong0
	tst.w	d3
	bge.s	.short
	cmp.w	apc+2(pc),d6
	bhi.s	jmplong0
	cmp.w	#$1000,d6
	bhs.s	jmplong0
.short:	cmp.w	#$1000,d6
	bhs	err_range
	move.l	a1,a5
	or.b	#$c,d4
	addq.w	#1,apc+2
	move.b	d4,(a6)+
	move.w	d6,(a6)+
	bsr	untilwh
	bra	noparal_move

jmplong:	
	subq.w	#1,a5
	bra.s	jmplong00
jmplong0:	
	cmp.b	#'>',(a5)+
	beq.s	.ici0
	subq.w	#1,a5
.ici0:	
jmplong00:	
	bsr	ea
	tst.w	d0
	blt	err_op
	
	or.b	#$a,d4
	addq.w	#1,apc+2
	move.b	d4,(a6)+
	or.b	#$c0,d0
	move.b	d0,(a6)+
	move.b	#$80,(a6)+
	cmp.b	#$f0,d0
	bne	.ici
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.ici:	bsr	untilwh
	bra	noparal_move
nojmp:

do:	move.w	(a5),d0
	or.w	#$2020,d0
	cmp.w	#'do',d0
	bne	nodo
	entire	2(a5),nodo
	addq.w	#2,a5
	nowh
	subq.w	#1,a5
	move.w	(a5),d0
	or.w	#$2000,d0
	moveq	#00,d4
	cmp.w	#'x:',d0
	beq.s	.ici
	moveq	#$40,d4
	cmp.w	#'y:',d0
	bne.s	nodoea
.ici:	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_op
	
	cmp.w	#$70,d0
	beq	err_range
	addq.w	#1,apc+2
	move.b	#$6,(a6)+
	move.b	d0,(a6)+
	move.b	d4,(a6)+
	bra.s	do2

nodoea:	
doi:	cmp.b	#'#',(a5)
	bne.s	nodoi
	addq.w	#1,a5
	cmp.b	#'<',(a5)
	bne.s	.ici
	addq.l	#1,a5
	bra.s	.ici2
.ici:	cmp.b	#'>',(a5)
	bne.s	.ici2
	addq.l	#1,a5
.ici2:	bsr	get_value
	tst.b	pass(pc)
	beq.s	.pass1
	tst.w	d5
	blt	err_val
	cmp.w	#$1000,d6
	bhs	err_range
.pass1:	addq.w	#1,apc+2
	move.b	#6,(a6)+
	move.b	d6,(a6)+
	lsr.w	#8,d6
	or.b	#$80,d6
	move.b	d6,(a6)+
	bra.s	do2
	
nodoi:	bsr	get_srcreg			* Get src. reg.
	tst.w	d0
	blt	err_op
	addq.w	#1,apc+2
	move.b	#$6,(a6)+
	or.b	#$c0,d0
	move.b	d0,(a6)+
	clr.b	(a6)+
do2:	cmp.b	#',',(a5)+
	bne	op_miss
	cmp.b	#'<',(a5)
	bne.s	.ici
	addq.w	#1,a5
.ici:	cmp.b	#'>',(a5)
	bne.s	.la
	addq.w	#1,a5
.la:	bsr	get_value
	tst.w	d5
	blt	err_val
	addq.w	#1,apc+2
	subq.w	#1,d6
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	bsr	untilwh
	bra	noparal_move
nodo:

jclr:	move.l	(a5),d0
	or.l	#$20202020,d0
	moveq	#1,d3
	cmp.l	#'jscl',d0
	bne.s	.jsclr0
	entire	5(a5),nojclr
	moveq	#0,d4
	bra	.jclr
.jsclr0:	
	cmp.l	#'jsse',d0
	bne.s	.jsclr1
	entire	5(a5),nojclr
	moveq	#$20,d4
	bra.s	.jclr
.jsclr1:	
	moveq	#0,d3
	moveq	#0,d4
	cmp.l	#'jclr',d0
	beq.s	.jclr
	entire	4(a5),nojclr
	moveq	#$20,d4
	cmp.l	#'jset',d0
	bne	nojclr
	entire	4(a5),nojclr
.jclr:	tst.b	pass(pc)
	bne.s	.pass2				*
	addq.w	#2,apc+2			* TESTSHIT!!
	addq	#6,a6				*
	bra	ins_end				*
.pass2:	addq.w	#4,a5
	add.w	d3,a5
	nowh
	cmp.b	#'#',-1(a5)
	bne	err_immed
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.w	#63,d6
	bhi	err_range
	move.w	#$a00,(a6)+
	add.b	d3,-2(a6)
	or.b	d4,d6
	move.b	d6,(a6)+
	cmp.b	#',',(a5)+
	bne	op_miss
	
	cmp.b	#':',1(a5)
	bne	nojclrea
	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'x',d0
	bne.s	.ici
	or.b	#$80,-1(a6)
	bra.s	.ici2
.ici:	cmp.b	#'y',d0
	bne	err_vmem
	or.b	#$c0,-1(a6)
.ici2:	move.l	a5,.crapstore			* TESTHIT!!
	addq.w	#2,a5
	cmp.b	#'<',1(a5)
	beq.s	jclrio
	bsr	ea
	tst.w	d0
	blt	err_val
	cmpi.b	#$70,d0
	bne.s	.ok	;beq	err_range	* TESTSHIT!!
	movea.l	.crapstore(pc),a5		* TESTSHIT!!
	bra.s	jclrio
.ok:	move.b	d0,-2(a6)
	bra.s	jclradr

.crapstore:
	DC.L	0

jclrio:	addq	#2,a5
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.w	#$ffc0,d6
	blo	err_range
	and.w	#%10111111,d6
	move.b	d6,-2(a6)
	bra.s	jclradr

nojclrea:		
	bsr	get_srcreg			* Get src. reg.
	tst.w	d0
	blt	err_op
	
	or.b	#$c0,d0
	move.b	d0,-2(a6)

jclradr:	
	cmp.b	#',',(a5)+
	bne	err_op
	cmp.b	#'>',(a5)
	bne.s	.ici
	addq	#1,a5
.ici:	bsr	get_value
	tst.w	d5
	blt	err_val
	addq.w	#2,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	bsr	untilwh
	bra	noparal_move
nojclr:

threeop:		;3 op instructions
	lea	ins3(pc),a1
.next_one:
	tst.b	(a1)
	beq	nothreeop
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	entire	(a0),nothreeop
	move.l	a0,a5
	
	nowh

	addq.w	#1,a1
	move.w	#$2000,(a6)+
	move.b	(a1)+,(a6)+
	addq.w	#1,apc+2

	lea	-1(a5),a0
	move.b	(a0),d0
	cmp.b	#'+',d0
	beq.s	pos
	cmp.b	#'-',d0
	bne.s	noneg
	or.b	#$4,-1(a6)
pos:	addq.w	#1,a0
noneg:	cmp.b	#',',5(a0)
	beq	no_err_op
err_op:	error2	terr_op(pc)
	bra	ins_end0
err_val:	error2	terr_val(pc)
	clr.w	nb_par
	bra	ins_end
err_range:	error2	terr_range(pc)
	bra	ins_end
err_Nx:	error2	terr_Nx(pc)
	bra	ins_end
;err_garb:
;	error2	garbfollow_txt(pc)
;	bra	ins_end
err_file:
	error2	filenotfound_txt(pc)
	bra	fin
err_para:
	error2	paraerror_txt(pc)
	bra	ins_end
warn_rnmstall:
	warning	stallwarning_txt(pc)
	rts

no_err_op:	
	move.b	6(a0),d1
	or.b	#$20,d1
	cmp.b	#'b',d1
	bne.s	.no_b
	or.b	#$8,-1(a6)
.no_b:	move.w	(a0),d0
	or.w	#$2000,d0
	move.w	d0,d1
	swap	d0
	move.w	3(a0),d0
	or.w	#$2000,d0
	cmp.w	d1,d0
	bhs.s	.ok
	swap	d0
.ok:	lea	op3(pc),a0
threeop0:	
	move.l	(a0)+,d1
	beq	err_op
	addq.w	#1,a0
	cmp.l	d1,d0
	bne.s	threeop0
	
	move.b	-1(a0),d1
	or.b	d1,-1(a6)
	bsr	untilwh
	bra	paral_move
nothreeop:

tcc:	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'t',d0
	bne	notcc

	move.w	1(a5),d0
	or.w	#$2020,d0
	lea	cc-1(pc),a1
.next_one:
	addq.w	#1,a1
	tst.b	(a1)
	beq	notcc
	move.l	a5,a0
.next0:	cmp.w	(a1)+,d0
	bne.s	.next_one
	entire	3(a5),notcc
	move.b	(a1)+,d4
	lsl.b	#4,d4
	addq.w	#4,a5
	nowh
	moveq	#0,d3
	;move.b	-1(a5),d0
	or.b	#$20,d0
	cmp.b	#'a',d0
	beq.s	tcca
	cmp.b	#'b',d0
	bne.s	tccx
tcca:	cmp.b	#',',(a5)+
	bne	op_miss
	move.b	(a5)+,d3
	or.b	#$20,d3
	cmp.b	d0,d3
	beq	err_op
	sub.b	#'a',d3
	bra	tcc3
tccx:	cmp.b	#'x',d0
	bne	tccy
	moveq	#8,d3
	bra.s	tccx0
tccy:	cmp.b	#'y',d0
	bne	err_op
	moveq	#10,d3
tccx0:	move.b	(a5)+,d0
	cmp.b	#'0',d0
	beq.s	tcc2
	cmp.b	#'1',d0
	bne	err_op
	addq.b	#4,d3
tcc2:	cmp.b	#',',(a5)+
	bne	op_miss
	move.b	(a5)+,d0
	or.b	#$20,d0
	sub.b	#'a',d0
	blt	err_op
	cmp.b	#1,d0
	bhi	err_op
	or.b	d0,d3
tcc3:	lsl.b	#3,d3
	addq.w	#1,apc+2
	move.b	#2,(a6)+
	move.b	d4,(a6)+
	move.b	d3,(a6)+

.br1b:	move.b	(a5)+,d0
	beq	ins_end0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq	ins_end0
	cmpi.b	#";",d0
	beq	ins_end0
.br1d:	or.b	#$20,d0
	cmp.b	#'r',d0
	bne	err_op
	move.b	(a5)+,d0
	sub.b	#'0',d0
	blt	err_op
	cmp.b	#7,d0
	bhi	err_op
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1(pc)			* Check if r-register wasn't used in prev. inst.
	beq.s	.nostall
	bsr	warn_rnmstall
.nostall:
	ENDC
	move.b	#3,-3(a6)
	or.b	d0,-2(a6)
	cmp.b	#',',(a5)+
	bne	op_miss
	move.b	(a5)+,d0
	or.b	#$20,d0
	cmp.b	#'r',d0
	bne	err_op
	move.b	(a5)+,d0
	sub.b	#'0',d0
	blt	err_op
	cmp.b	#7,d0
	bhi	err_op
	bset	d0,userx_tbl			* Mark r-register as used in destination-field.
	or.b	d0,-1(a6)
	bsr	untilwh
	bra	noparal_move
notcc:

oneop:			;1 op instructions
	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	lea	ins1(pc),a0
oneop0:	move.l	(a0)+,d1
	beq	nooneop
	lsr.l	#8,d1
	cmp.l	d1,d0
	bne.s	oneop0
	entire	3(a5),nooneop
	move.b	-1(a0),d1
	addq.w	#3,a5
	
	nowh
* Check if operand is ok (can only be accu A or B)..
	move.b	-1(a5),d2
	or.b	#$20,d2
	moveq	#0,d0
	cmpi.b	#'a',d2
	beq.s	.pasb
	cmpi.b	#'b',d2
	bne	err_op
	moveq	#8,d0
.pasb:	or.b	d0,d1
	move.w	#$2000,(a6)+
	move.b	d1,(a6)+
	addq.w	#1,apc+2
	bra	paral_move
	bra	ins_end
nooneop:

* Instructions with 0 parameters..
zeroop:	lea	ins0(pc),a1
.next_one:
	tst.b	(a1)
	beq.s	nozeroop
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	entire	(a0),nozeroop
	move.l	a0,a5
	clr.w	(a6)+
	move.b	1(a1),(a6)+
	addq.w	#1,apc+2
	bra	noparal_move
nozeroop:	

andi:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'andi',d0
	bne.s	ori
	entire	4(a5),noori
	clr.w	(a6)+
	move.b	#$b8,(a6)+
	addq.w	#4,a5
	bra.s	ori2
ori:	lsr.L	#8,d0
	cmp.l	#'ori',d0
	bne	noori
	entire	3(a5),noori
	clr.w	(a6)+
	move.b	#$f8,(a6)+
	addq.w	#3,a5
ori2:	addq.w	#1,apc+2

	nowh
	
	cmp.b	#'#',-1(a5)
	bne.s	.br1e
	
	cmp.b	#'>',(a5)
	bne.s	.ici
	addq.l	#1,a5
	bra.s	.ici2
.ici:	cmp.b	#'<',(a5)
	bne.s	.ici2
	addq.l	#1,a5
.ici2:	bsr	get_value

	cmp.b	#',',(a5)+
	bne.s	.br1e
	
	move.b	d6,-2(a6)
	
	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	addq.w	#2,a5
	cmp.l	#'ccr',d0
	bne.s	ori0
	addq.w	#1,a5
	or.b	#1,-1(a6)
	bra.s	ori1
ori0:	cmp.l	#'omr',d0
	bne.s	ori1
	addq.w	#1,a5
	or.b	#2,-1(a6)
ori1:	bra	noparal_move
noori:

norm:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'norm',d0
	bne	nonorm
	entire	4(a5),nonorm
	addq.w	#4,a5
	
	nowh
	
	move.b	-1(a5),d0
	or.b	#$20,d0
	cmp.b	#'r',d0
	beq.s	.no_err_op
.err_op:
	error2	terr_op(pc)
	bra	ins_end
.no_err_op:	
	move.b	(a5)+,d0
	cmp.b	#'0',d0
	blo.s	.err_op
	cmp.b	#'7',d0
	bhi.s	.err_op
	cmp.b	#',',(a5)+
	bne	.br1e
	
	sub.b	#'0',d0
	move.b	d0,d1
	addq.w	#1,apc+2
	move.b	#1,(a6)+
	move.b	#$d8,(a6)
	or.b	d0,(a6)+
	move.b	#$15,(a6)+
	
	move.b	(a5),d0
	or.b	#$20,d0
	cmpi.b	#'a',d0
	beq.s	.pasb
	cmp.b	#'b',d0
	bne	err_op
	or.b	#8,-1(a6)
.pasb:
	IFNE	WARNSTALL
	btst	d1,userx_tbl+1(pc)		* Check if r-register wasn't used in prev. inst.
	beq.s	.nostall
	bsr	warn_rnmstall
.nostall:
	ENDC
	bsr	untilwh
	bra	noparal_move
nonorm:

div:	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	cmp.l	#'div',d0
	bne	nodiv
	
	entire	3(a5),nodiv
	addq.w	#3,a5
	nowh
* Check 2nd parameter.	
	cmp.b	#',',1(a5)
	bne.s	.br1e
	addq.w	#1,apc+2
	move.w	#$180,(a6)+
	move.b	#$40,(a6)+
	move.b	2(a5),d0
	or.b	#$20,d0
	cmpi.b	#'a',d0
	beq.s	.pasb
	cmpi.b	#'b',d0
	bne	err_op
	or.b	#8,-1(a6)
.pasb:	
* Check 1st parameter..
	moveq	#0,d2
	move.b	-1(a5),d0
	or.b	#$20,d0
	cmpi.b	#'x',d0
	beq.s	.pasy
	cmpi.b	#'y',d0
	bne	err_op
	moveq	#$10,d2
.pasy:	cmpi.b	#'0',(a5)
	beq.s	.pas1
	cmpi.b	#'1',(a5)+
	bne	err_op
	add.b	#$20,d2
.pas1:	or.b	d2,-1(a6)
	
	bsr	untilwh
	bra	noparal_move
nodiv:

lua:	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	cmp.l	#'lua',d0
	bne	nolua
	entire	3(a5),nolua
	addq.w	#3,a5
	nowh
	subq.w	#1,a5
	move.w	(a5)+,d0
	or.w	#$20,d0
	cmp.w	#'(r',d0
	bne	err_op
	moveq	#0,d3
	move.b	(a5)+,d3
	move.b	d3,d2
	sub.b	#'0',d3
	blt	err_op
	cmp.b	#7,d3
	bhi	err_op
	move.b	d3,d4
	cmp.b	#')',(a5)+
	bne	err_op
	move.b	(a5)+,d0
	or.b	#$10,d3
	cmp.b	#'-',d0
	beq.s	.ici
	or.b	#$8,d3
	cmp.b	#'+',d0
	bne	err_op
.ici:
	IFNE	WARNSTALL
	btst	d4,userx_tbl+1
	beq.s	.nostall
	bsr	warn_rnmstall
.nostall:
	ENDC
	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'n',d0
	bne.s	lua2
	move.b	1(a5),d0
	cmpi.b	#'0',d0
	blt	err_range
	cmpi.b	#'7',d0
	bhi	err_range
	cmp.b	d0,d2
	bne	err_Nx				* Nx not conformable
	subi.b	#'0',d0
	IFNE	WARNSTALL
	btst	d0,usenx_tbl+1
	beq.s	.nostalln
	bsr	warn_rnmstall
.nostalln:
	ENDC
	addq	#2,a5
	and.w	#$ffef,d3
lua2:	cmp.b	#',',(a5)+
	bne	op_miss
	move.b	(a5)+,d0
	or.b	#$20,d0
	moveq	#0,d4
	move.b	d0,d1
	cmp.b	#'r',d0
	beq.s	.do_r
	moveq	#8,d4
	cmp.b	#'n',d0
	bne	err_op
	move.b	(a5)+,d0
	sub.b	#'0',d0
	blt	err_op
	cmp.b	#7,d0
	bhi	err_op
	bset	d0,usenx_tbl			* Mark n-register as used in destination-field.
	bra.s	.or
.do_r:	move.b	(a5)+,d0
	sub.b	#'0',d0
	blt	err_op
	cmp.b	#7,d0
	bhi	err_op
	bset	d0,userx_tbl			* Mark r-register as used in destination-field.
.or	or.b	d0,d4
	addq.w	#1,apc+2
	move.b	#$4,(a6)+
	or.b	#$40,d3
	move.b	d3,(a6)+
	or.b	#$10,d4
	move.b	d4,(a6)+
	bsr	untilwh
	bra	noparal_move
nolua:

dc:	move.w	(a5),d0
	or.w	#$2020,d0
	cmp.w	#'dc',d0
	bne	nodc
	entire	2(a5),nodc
	addq.w	#2,a5
	nowh
	subq.w	#1,a5
.ici:	bsr	get_value
	tst.w	d5
	blt	err_val
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	cmp.b	#',',(a5)+
	beq.s	.ici
	subq.w	#1,a5
	bsr	untilwh
	bra	ins_end
nodc:

rep:	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	cmp.l	#'rep',d0
	bne	norep
	entire	3(a5),norep
	addq.w	#3,a5
	nowh
	subq.w	#1,a5
	move.w	(a5),d0
	or.w	#$2000,d0
	moveq	#$20,d4
	cmp.w	#'x:',d0
	beq.s	.ici
	moveq	#$60,d4
	cmp.w	#'y:',d0
	bne.s	norepea
.ici:	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt	err_op
	
	cmp.w	#$70,d0
	beq	err_op
	addq.w	#1,apc+2
	move.b	#$6,(a6)+
	move.b	d0,(a6)+
	move.b	d4,(a6)+
	bsr	untilwh
	bra	noparal_move
norepea:

repi:	cmp.b	#'#',(a5)
	bne.s	norepi
	addq.w	#1,a5
	cmp.b	#'<',(a5)
	bne.s	.ici
	addq.l	#1,a5
	bra.s	.ici2
.ici:	cmp.b	#'>',(a5)
	bne.s	.ici2
	addq.l	#1,a5
.ici2:	bsr	get_value
	tst.b	pass(pc)
	beq.s	.pass1
	tst.w	d5
	blt	err_val
	cmp.w	#$1000,d6
	bhs	err_range
.pass1:	addq.w	#1,apc+2
	move.b	#6,(a6)+
	move.b	d6,(a6)+
	lsr.w	#8,d6
	or.b	#$a0,d6
	move.b	d6,(a6)+
	bsr	untilwh
	bra	noparal_move
	
norepi:	bsr	get_srcreg			* Get src. reg.
	tst.w	d0
	blt	err_op
	addq.w	#1,apc+2
	move.b	#$6,(a6)+
	or.b	#$c0,d0
	move.b	d0,(a6)+
	move.b	#$20,(a6)+
	bsr	untilwh
	bra	noparal_move
norep:

bchg:	move.l	(a5),d0
	or.l	#$20202020,d0
	moveq	#11,d3
	moveq	#0,d4
	cmp.l	#'bchg',d0
	beq.s	.ok
	moveq	#10,d3
	cmp.l	#'bclr',d0
	beq.s	.ok
	moveq	#$20,d4
	cmp.l	#'bset',d0
	beq.s	.ok
	moveq	#11,d3
	cmp.l	#'btst',d0
	bne	nobchg
.ok:	entire	4(a5),nobchg
	addq.w	#4,a5
	nowh
	cmp.b	#'#',d0
	bne	err_op
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.w	#31,d6
	bhi	err_range
	cmp.b	#',',(a5)+
	bne	op_miss
	or.b	d6,d4
	
	cmp.b	#':',1(a5)
	beq.s	bchgea
	bsr	get_destreg			* Get dest. reg.
	tst.w	d0
	blt	err_op
	addq.w	#1,apc+2
	move.b	d3,(a6)+
	or.b	#$c0,d0
	move.b	d0,(a6)+
	or.b	#$40,d4
	move.b	d4,(a6)+
	bsr	untilwh
	bra	noparal_move
	
bchgea:	move.b	(a5),d0
	moveq	#0,d5
	or.b	#$20,d0
	cmp.b	#'x',d0
	beq.s	.ok
	moveq	#$40,d5
	cmp.b	#'y',d0
	bne	err_vmem
.ok:	addq.w	#2,a5
	move.w	(a5),d0
	or.w	#$2020,d0
	cmp.w	#'<<',d0
	beq.s	bchgio
	move.w	d5,-(sp)
	bsr	ea
	move.w	(sp)+,d5
	tst.w	d0
	blt	err_op
	
	cmp.b	#$40,d0
	bhs.s	.ici
	cmp.w	apc+2(pc),d0
	bls.s	.ici
	moveq	#0,d6
	move.b	d0,d6
	move.b	#$70,D0
.ici:	addq.w	#1,apc+2
	move.b	d3,(a6)+
	move.b	d0,(a6)+
	or.w	d5,d4
	move.b	d4,(a6)+
	cmp.b	#$70,d0
	bne.s	.noadr
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.noadr:	bsr	untilwh
	bra	noparal_move

bchgio:	addq.w	#2,a5
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.w	#$ffc0,d6
	blo	err_range
	addq.w	#1,apc+2
	move.b	d3,(a6)+
	and.b	#%10111111,d6
	move.b	d6,(a6)+
	move.b	d4,(a6)+
	bsr	untilwh
	bra	noparal_move
nobchg:

do_directives:
endif:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'endi',d0
	bne.s	noendif
	move.b	4(a5),d0
	or.b	#$20,d0
	cmp.b	#'f',d0
	bne	noendif
	entire	5(a5),noendif
	bra.s	endc0
noendif:
endc:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'endc',d0
	bne.s	noendc
	entire	4(a5),noendc
endc0:	move.l	adont_asm(pc),a0
	cmp.l	#ldont_asm,a0
	bls	err_endc_not_expected
	move.w	-(a0),dont_asm
	move.l	a0,adont_asm
	bra	ins_end
noendc:
else:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'else',d0
	bne.s	noelse
	move.w	4(a5),d0
	or.w	#$2020,d0
	cmp.w	#'if',d0
	bne.s	.ici
	entire	6(a5),noelse
	not.b	dont_asm+1
	bra	ins_end
.ici:	entire	4(a5),noelse
	not.b	dont_asm+1
	bra	ins_end
noelse:	tst.w	dont_asm(pc)
	bne	ins_end

ifne:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'ifne',d0
	bne	noifne
	entire	4(a5),noifne
	addq.l	#4,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	seq	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noifne:
if:	move.w	(a5),d0
	or.w	#$2020,d0
	cmp.w	#'if',d0
	bne	noif
	entire	2(a5),noif
	addq.l	#2,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	seq	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noif:
ifeq:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'ifeq',d0
	bne	noifeq
	entire	4(a5),noifeq
	addq.l	#4,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	sne	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noifeq:
ifle:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'ifle',d0
	bne	noifle
	entire	4(a5),noifle
	addq.l	#4,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	sgt	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noifle:
iflt:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'iflt',d0
	bne	noiflt
	entire	4(a5),noiflt
	addq.l	#4,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	sge	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noiflt:
ifge:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'ifge',d0
	bne	noifge
	entire	4(a5),noifge
	addq.l	#4,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	slt	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noifge:
ifgt:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'ifgt',d0
	bne	noifgt
	entire	4(a5),noifgt
	addq.l	#4,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op
	moveq	#0,d0
	tst.l	d6
	sle	d0
	move.l	adont_asm(pc),a0
	move.w	dont_asm(pc),(a0)+
	move.l	a0,adont_asm
	move.w	d0,dont_asm
	bra	ins_end
noifgt:

include:
	move.l	(a5),d0
	ori.l	#$20202020,d0
	cmpi.l	#"incl",d0
	bne	noinclude
	move.l	4(a5),d0
	ori.l	#$20202020,d0
	move.b	#" ",d0
	cmpi.l	#"ude ",d0
	bne.s	noinclude
	addq	#7,a5
.find_name_loop:
	move.b	(a5)+,d0
	cmpi.b	#" ",d0
	beq.s	.find_name_loop
	cmpi.b	#9,d0
	beq.s	.find_name_loop
	subq	#1,a5
	lea	filename_txt,a0
	move.l	a0,filename_adr
.copy_name_loop:
	move.b	(a5)+,d0
	move.b	d0,(a0)+
	cmpi.b	#32,d0
	bhs.s	.copy_name_loop
	clr.b	-(a0)
	until	#0
	move.l	a5,d0
	sub.l	#line_buff,d0
	add.l	d0,real_source
	move.w	sourcefilestackdepth(pc),d0
	move.w	d0,d1
	mulu.w	#stackentrysize,d0
	lea	(sourcefilestack_tbl,d0.l),a0
	move.l	source(pc),stackentrysadr(a0)
	move.l	real_source(pc),stackentryreal(a0)
	addq.w	#1,d1
	move.w	d1,sourcefilestackdepth
	bra	asm_newfile
noinclude:

incbin:	move.l	(a5),d0
	ori.l	#$20202020,d0
	cmpi.l	#"incb",d0
	bne	no_incbin
	move.w	4(a5),d0
	ori.w	#$2020,d0
	cmpi.w	#"in",d0
	bne.s	no_incbin
	addq	#6,a5
.find_name_loop:
	move.b	(a5)+,d0
	cmpi.b	#" ",d0
	beq.s	.find_name_loop
	cmpi.b	#9,d0
	beq.s	.find_name_loop
	subq	#1,a5
	lea	filename_txt,a0
.copy_name_loop:
	move.b	(a5)+,d0
	move.b	d0,(a0)+
	cmpi.b	#32,d0
	bhs.s	.copy_name_loop
	clr.b	-(a0)
	subq	#1,a5
* Inefficient: file is loaded both passes.
	move.l	a6,-(sp)
	pea	filename_txt
	bsr	fload
	addq	#8,sp
	tst.l	d0
	bmi	err_file
	divu.w	#3,d0
	add.w	d0,apc+2
	move.l	d0,d1
	swap	d1
	tst.w	d1
	beq.s	.no_add
	addq.w	#1,d0
.no_add:
	mulu.w	#3,d0
	adda.l	d0,a6
	bra	ins_end
no_incbin:

printval:
	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'prin',d0
	bne	noprintval
	move.l	4(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'tval',d0
	bne	noprintval
	entire	8(a5),noprintval
	addq.l	#8,a5
	nowh
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op

	move.l	a4,-(sp)
	lea	tprintval0(pc),a4
	move.l	d6,-(sp)
	bsr	mkhex6
	move.l	(sp)+,a4
	move.l	#'line',terr
	move.w	#$2000,terr+4
	error2	tprintval(pc)
	subq.w	#1,nb_err
	move.l	#'****',terr
	move.w	#' e',terr+4
	bra	ins_end
noprintval:
pass1val:
	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'pass',d0
	bne	nopass1val
	move.l	4(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'1val',d0
	bne	nopass1val
	entire	8(a5),nopass1val
	addq.l	#8,a5
	nowh
	tst.b	pass(pc)
	bne	ins_end
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op

	move.l	a4,-(sp)
	lea	tprintval0(pc),a4
	move.l	d6,-(sp)
	bsr	mkhex6
	move.l	(sp)+,a4
	move.l	#'line',terr
	move.w	#$2000,terr+4
	error2	tprintval(pc)
	subq.w	#1,nb_err
	move.l	#'****',terr
	move.w	#' e',terr+4
	bra	ins_end
nopass1val:
pass2val:
	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'pass',d0
	bne	nopass2val
	move.l	4(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'2val',d0
	bne	nopass2val
	entire	8(a5),nopass2val
	addq.l	#8,a5
	nowh
	cmp.b	#1,pass
	bne	ins_end
	subq.l	#1,a5
	bsr.l	get_value
	tst.l	d5
	blt	err_op

	move.l	a4,-(sp)
	lea	tprintval0(pc),a4
	move.l	d6,-(sp)
	bsr	mkhex6
	move.l	(sp)+,a4
	move.l	#'line',terr
	move.w	#$2000,terr+4
	error2	tprintval(pc)
	subq.w	#1,nb_err
	move.l	#'****',terr
	move.w	#' e',terr+4
	bra	ins_end
nopass2val:
fail:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'fail',d0
	bne	nofail
	entire	4(a5),nofail
	addq.l	#4,a5
	nowh
	
	error2	terr_fail(pc)
	bra	ins_end
nofail:

endm:	move.l	(a5),d0
	or.l	#$20202020,d0
	cmp.l	#'endm',d0
	bne	noendm
	entire	4(a5),noendm
	move.b	mac_def(pc),d0	;am I defining a macro ?
	beq.s	.use
	addq.w	#4,a5
	clr.w	mac_def
	bra	ins_end
.use:	tst.l	mac_adr(pc)
	beq	err_endm_not_expected
	
	move.l	mac_adr(pc),a5
	move.l	mac_adr2(pc),mac_adr
	clr.l	mac_adr2
	
	lea	mac_par2(pc),a0
	lea	mac_par(pc),a4
	move.w	#64*10/4-1,d0
.copy_par:	
	move.l	(a0),(a4)+
	clr.l	(a0)+
	dbra	d0,.copy_par

	move.l	a5,real_source
	lea	line_buff(pc),a0
	move.l	a0,left_line
	move.l	-4(a5),-4(a0)
.copy:	move.b	(a5)+,d0
	move.b	d0,(a0)+
	cmp.b	#13,d0
	beq.s	.copyf
	tst.b	d0
	bne.s	.copy
.copyf:	move.l	(a5),(a0)
	lea	line_buff(pc),a5
	bra	ins_end
noendm:	tst.b	mac_def(pc)
	bne	ins_end

end:	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	cmp.l	#'end',d0
	bne	noend
	entire	3(a5),noend
	move.b	3(a5),d0
	beq	asm_end
	cmp.b	#13,d0
	beq	asm_end
	cmp.b	#10,d0
	beq	asm_end
	cmp.b	#' ',d0
	beq	asm_end
	cmp.b	#9,d0
	beq	asm_end
noend:

org:			;ORG ?:$?
	move.l	(a5),d0
	lsr.l	#8,d0
	or.l	#$202020,d0
	cmp.l	#'org',d0
	bne	noorg
	entire	3(a5),noorg
	
	addq.w	#3,a5

	nowh
	
	moveq	#-1,d5
	move.b	-1(a5),d0
	or.b	#$20,d0
	
	cmp.b	#'x',d0
	bne.s	.pasx
	moveq	#-xmemtype-1,d5
.pasx:	cmp.b	#'y',d0
	bne.s	.pasy
	moveq	#-ymemtype-1,d5
.pasy:	move.b	(a5)+,d0
	cmp.b	#':',d0
	beq.s	.ok
.err:	error2	terr_org(pc)
	bra	ins_end0
.ok:	move.w	d5,apc
	movea.l	dest0(pc),a0
	move.l	a6,d0
	sub.l	a0,d0
	bne.s	.snul
	lea	-9(a6),a6
.snul:	divu.l	#3,d0
	move.w	d0,-2(a0)
	swap	d0
	move.b	d0,-3(a0)
	bsr	get_value
	tst.w	d5
	blt.s	.err
	move.w	d6,apc+2
	clr.b	(a6)+
	move.w	apc(pc),(a6)
	not.w	(a6)+
	clr.b	(a6)+
	move.w	apc+2(pc),(a6)+
	clr.b	(a6)+
	clr.w	(a6)+
	move.l	a6,dest0
	bra	ins_end0
noorg:

ds:	move.w	(a5),d0
	or.w	#$2020,d0
	cmp.w	#'ds',d0
	bne	nods
	entire	2(a5),nods
	addq.w	#2,a5
	nowh
	subq.w	#1,a5
	bsr	get_value
	tst.w	d5
	blt	err_val

	add.w	d6,apc+2
	movea.l	dest0(pc),a0
	move.l	a6,d0
	sub.l	a0,d0
	divu.l	#3,d0
	move.w	d0,-2(a0)
	swap	d0
	move.b	d0,-3(a0)
	tst.l	d0
	bne.s	.ici
	lea	-9(a6),a6
	nop
.ici:	clr.b	(a6)+
	move.w	apc(pc),(a6)
	not.w	(a6)+
	clr.b	(a6)+
	move.w	apc+2(pc),(a6)+
	clr.b	(a6)+
	clr.w	(a6)+
	move.l	a6,dest0
	bsr	untilwh
	bra	ins_end
nods:

dsm:	;bra	nodsm				* INACTIVE => CODE UNDER CONSTUCTION!
	move.l	(a5),d0
	lsr.l	#8,d0
	ori.l	#$00202020,d0
	cmpi.l	#"dsm",d0
	bne	nodsm
	entire	3(a5),nodsm
	addq.w	#3,a5
	nowh
	subq.w	#1,a5
	bsr	get_value
	tst.w	d5
	blt	err_val

	move.w	d6,d0
	moveq	#0,d7
.get_bits:
	tst.w	d0
	beq.s	.end
	lsr.w	#1,d0
	addq.w	#1,d7
	bra.s	.get_bits
.end:	moveq	#1,d0
	lsl.w	d7,d0
	move.w	apc+2(pc),d1
	move.w	d1,d2
	bne.s	.normal
	moveq	#0,d0
	move.w	d6,apc+2
	bra.s	.rest
.normal:
	lsr.w	d7,d1
	lsl.w	d7,d1
	add.w	d0,d1
	add.w	d6,d1
	move.w	d1,apc+2

.rest:	move.l	dest0(pc),a0
	clr.b	-6(a0)				* / Kick modified address
	move.w	d0,-5(a0)			* \ in last block.

	move.l	lbl(pc),a1
	addq	#4,a1
.adrloop:
	movea.l	(a1)+,a2
.chlop:	tst.b	(a1)+
	bne.s	.chlop
	cmp.w	1(a1),d2
	beq.s	.found
	tst.l	a2
	beq.s	.nope
	lea	(a2),a1
	bra.s	.adrloop
.found:	move.w	d0,1(a1)			* Kick modified address in labelentry.
.nope:
	move.l	a6,d0
	sub.l	a0,d0
	divu.l	#3,d0
	move.w	d0,-2(a0)
	swap	d0
	move.b	d0,-3(a0)
	tst.l	d0
	bne.s	.ici
	lea	-9(a6),a6
.ici:
* Make new position.
	clr.b	(a6)+
	move.w	apc(pc),(a6)
	not.w	(a6)+
	clr.b	(a6)+
	move.w	apc+2(pc),(a6)+
	clr.b	(a6)+
	clr.w	(a6)+
	move.l	a6,dest0
	bsr	untilwh
	bra	ins_end
nodsm:

list:	move.l	(a5),d0
	ori.l	#$20202020,d0
	cmpi.l	#'list',d0
	bne.s	nolist
* Handling for 'LIST'-command goes in here..
	bsr	untilwh
	bra	ins_end

nolist:	movem.l	(a5),d0-d1
	ori.l	#$20202020,d0
	cmpi.l	#'noli',d0
	bne.s	nonolist
	swap	d1
	ori.w	#$2020,d1
	cmpi.w	#'st',d1
	bne.s	nonolist
* Handling for 'NOLIST'-command goes in here..
	bsr	untilwh
	bra	ins_end
nonolist:

* If it isn't a directive or a asm-opcode then check if it is a macro..
macro:	movem.l	d6/a0/a1/a5,-(sp)
	move.l	a5,a0
	moveq	#0,d5
.ici:	move.b	(a5)+,d0
	beq	.fin
	cmp.b	#13,d0
	beq	.fin
	cmp.b	#',',d0
	beq	.fin
	cmp.b	#' ',d0
	beq	.fin
	cmp.b	#9,d0
	beq	.fin
	addq.w	#1,d5
	bra.s	.ici
.fin:	subq.w	#1,d5
	subq.w	#1,a5
	move.w	(a5),-(sp)
	clr.b	(a5)
	move.l	a5,-(sp)

	move.l	mac(pc),d6
	addq.l	#4,d6
.loop0:	cmp.l	mac_pt(pc),d6
	bhs	.oops
	tst.l	d6
	beq	.oops
	move.l	d6,a1
	move.l	a0,a5
	move.l	(a1)+,d6
	move.w	d5,d0
.loop1:	cmpm.b	(a5)+,(a1)+
	dbne	d0,.loop1
	tst.w	d0
	bge.s	.loop0
	addq.w	#4,a1
	cmp.l	mac_pt(pc),a1
	beq.s	.ici1
	cmp.l	d6,a1
	bne.s	.loop0
.ici1:	subq.w	#4,a1
	move.l	(a1),d5
	moveq	#0,d0
	move.l	a5,a4
	move.l	(sp)+,a5
	move.w	(sp)+,(a5)
	movem.l	(sp)+,d6/a0/a1/a5
	
	move.l	mac_adr2(pc),d0
	bne	err_macroi
	move.l	mac_adr(pc),mac_adr2

	sub.l	#line_buff,a5
	add.l	real_source(pc),a5
	move.l	a5,mac_adr
	lea	mac_par(pc),a0
	lea	mac_par2(pc),a5
	move.w	#64*10/4-1,d0	;on sauve les anciens paramätres
.copy_par:
	move.l	(a0),(a5)+
	clr.l	(a0)+
	dbra	d0,.copy_par
	
	move.l	a4,a5
.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq.s	.last_par	;means there's no parameter
	tst.b	d0
	beq.s	.last_par
	
	subq.l	#1,a5
	lea	mac_par(pc),a4
	move.l	a4,a0
.read_par:	
	move.b	(a5)+,d0
	cmp.b	#13,d0
	beq.s	.last_par
	cmp.b	#10,d0
	beq.s	.last_par
	cmp.b	#9,d0
	beq.s	.last_par
	cmp.b	#' ',d0
	beq.s	.last_par
	cmp.b	#',',d0
	bne.s	.still_same
	clr.b	(a0)+
	add.w	#64,a4
	move.l	a4,a0
	bra.s	.read_par
.still_same:
	move.b	d0,(a0)+
	bra.s	.read_par
.last_par:
	move.l	d5,a5

	move.l	a5,real_source
	lea	line_buff(pc),a0
	move.l	a0,left_line
	move.l	-4(a5),-4(a0)
.copy:	move.b	(a5)+,d0
	move.b	d0,(a0)+
	cmp.b	#13,d0
	beq.s	.copyf
	tst.b	d0
	bne.s	.copy
.copyf:	move.l	(a5),(a0)
	lea	line_buff(pc),a5

	addq.w	#1,mac_no
	bra	ins_end0
	
.oops:	move.l	(sp)+,a5
	move.w	(sp)+,(a5)
	movem.l	(sp)+,d6/a0/a1/a5
	bra	err_ins

err_ins:error2	terr_ins(pc)
	move.l	left_line(pc),a5
	bra	ins_end

* Checks if no illegal parallel instructions are found..
noparal_move:
.br1b:	move.b	(a5)+,d0
	beq	ins_end0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq	ins_end0
.br1d:	cmp.b	#';',d0
	beq	ins_end0
	bra	err_para

* Handles parallel instructions (and the main one too!! goddamn spagetti code!)
paral_move:
.br1b:	move.b	(a5)+,d0
	beq	ins_end0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq	ins_end0
.br1d:	cmp.b	#';',d0
	beq	ins_end0

double:	move.l	a5,a4
	move.l	apc(pc),d7
	move.l	a6,a3
	move.l	-3(a6),mem_double
	;bra	nodouble
	move.w	#$1000,-3(a3)
	bsr	doublex1
	tst.w	d0
	blt.s	double2

	entire	(a5),nodouble
	nowh2	double2
	bsr	doublex2
	tst.w	d0
	bge	ins_end
	
double2:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$1000,-3(a3)
	bsr	doublex2
	tst.w	d0
	blt.s	double3

	entire	(a5),nodouble
	nowh2	double3
	bsr	doublex1
	tst.w	d0
	bge	ins_end
	
double3:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$800,-3(a3)
	bsr	doublex3
	tst.w	d0
	blt.s	double4

	move.b	d0,d4
	entire	(a5),nodouble
	nowh2	double4
	bsr	doublex4
	tst.w	d0
	blt.s	double4
	cmp.b	d0,d4
	beq	ins_end
	bra	err_same_r
	
double4:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$800,-3(a3)
	bsr	doublex4
	tst.w	d0
	blt.s	double5

	move.b	d0,d4
	entire	(a5),nodouble
	nowh2	double5
	bsr	doublex3
	tst.w	d0
	blt.s	double5
	cmp.b	d0,d4
	beq	ins_end
	bra	err_same_r

double5:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$1000,-3(a3)
	bsr	doubley1
	tst.w	d0
	blt.s	double6

	entire	(a5),nodouble
	nowh2	double6
	bsr	doubley2
	tst.w	d0
	bge	ins_end
	
double6:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$1000,-3(a3)
	bsr	doubley2
	tst.w	d0
	blt.s	double7

	entire	(a5),nodouble
	nowh2	double7
	bsr	doubley1
	tst.w	d0
	bge	ins_end
	
double7:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$800,-3(a3)
	bsr	doubley3
	tst.w	d0
	blt.s	double8

	move.b	d0,d4
	entire	(a5),nodouble
	nowh2	double8
	bsr	doubley4
	tst.w	d0
	blt.s	double8
	cmp.b	d0,d4
	beq	ins_end
	bra	err_same_r

double8:
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$800,-3(a3)
	bsr	doubley4
	tst.w	d0
	blt.s	double9

	move.b	d0,d4
	entire	(a5),nodouble
	nowh2	double9
	bsr	doubley3
	tst.w	d0
	blt.s	double9
	cmp.b	d0,d4
	beq	ins_end
	bra	err_same_r

double9:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$8000,-3(a3)
	bsr	doublex
	tst.w	d0
	blt.s	double10

	move.b	d0,d4
	entire	(a5),nodouble
	nowh2	double10
	bsr	doubley
	tst.w	d0
	blt.s	double10
	cmp.b	d0,d4
	bne	ins_end
	bra	err_same_r

double10:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.b	-1(a5),d0
	move.w	#$8000,-3(a3)
	bsr	doubley
	tst.w	d0
	blt.s	double11

	move.b	d0,d4
	entire	(a5),nodouble
	nowh2	double11
	bsr	doublex
	tst.w	d0
	blt.s	double11
	cmp.b	d0,d4
	bne	ins_end
	bra	err_same_r

double11:	
nodouble:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.l	mem_double(pc),-3(a6)
movel:	move.l	a5,a4
	move.l	apc(pc),d7
	move.l	a6,a3
	move.l	-3(a6),mem_double
	
	cmp.b	#':',(a5)
	bne	r2l
	move.w	-1(a5),d0
	or.w	#$2000,d0
	cmp.w	#'l:',d0
	bne	nomovel
	addq.l	#1,a5
	bsr	ea
	tst.w	d0
	blt	err_op	;nodx1
	
	move.w	#$4080,-3(a3)
	or.b	d0,-2(a3)
	cmp.b	#$70,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	
	cmp.b	#',',(a5)+
	bne	op_miss
	bsr	regl
	tst.w	d0
	blt	err_op
	or.b	d0,-3(a3)
	bra	ins_end

r2l:	subq.l	#1,a5
	bsr	regl
	tst.w	d0
	blt.s	nomovel
	cmp.b	#',',(a5)+
	bne	nomovel
	or.b	#$40,d0
	move.b	d0,-3(a3)
	move.w	(a5)+,d0
	or.w	#$2000,d0
	cmp.w	#'l:',d0
	bne.s	nomovel
	bsr	ea
	tst.w	d0
	blt	err_op	;nodx1
	
	move.b	d0,-2(a3)
	cmp.b	#$70,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	
	bra	ins_end
	
nomovel:	
	move.l	a4,a5
	move.l	d7,apc
	move.l	a3,a6
	move.l	mem_double(pc),-3(a6)

	;sub.w	apc+2(pc),d7
	;add.w	d7,a6
	;add.w	d7,a6
	;add.w	d7,a6
	;add.w	d7,apc+2
	
immed:	move.b	-1(a5),d0
	cmp.b	#'#',d0
	bne	noimmed
	cmp.b	#'>',(a5)
	beq.s	immedlong
	cmp.b	#'<',(a5)
	bne.s	immedlong0
	addq	#1,a5
.ok:	bsr	get_value
	tst.b	pass(pc)
	beq.s	.pass1
	tst.w	d5
	bne	op_miss
;	cmp.w	apc+2(pc),d6			* / What the hell is
;	bhi	err_range			* \ the use of this?
	cmp.w	#$ff,d6
	bgt	err_range
	cmp.w	#$ff80,d6
	blt	err_range
.pass1:	blt	err_val
	cmp.b	#',',(a5)+
	move.b	d6,-2(a6)
	bsr	get_destreg			* Get dest. reg.
	;tst.w	d0
	;blt	err_op
	cmp.w	#$20,d0
	bhs	err_op
	or.b	d0,-3(a6)
	bra	par_end

immedlong:	
	addq.w	#1,a5
immedlong0:
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.b	#',',(a5)+
	bne.s	op_miss
immedlong1:
	move.w	#$40f4,-3(a6)
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	bsr	get_destreg			* Get dest. reg.
	;tst.w	d0
	;blt	err_op
	cmp.w	#$20,d0
	bhs	err_op
	move.w	d0,d3
	and.w	#$18,d3
	and.w	#$7,d0
	add.w	d3,d3
	or.w	d3,d0
	or.b	d0,-6(a6)
	bra	par_end

op_miss:	
	error2	terr_op_miss(pc)
	bra	ins_end0

err_movem:	
	error2	terr_movem(pc)
	bra	ins_end0

err_immed:	
	error2	terr_immed(pc)
	bra	ins_end0

err_vmem:	
	error2	terr_vmem(pc)
	bra	ins_end0

err_macroi:	
	error2	terr_macroi(pc)
	bra	ins_end0

err_double:	
	error2	terr_double(pc)
	bra	ins_end0

err_endc_not_expected:	
	error2	terr_endc_not_expected(pc)
	bra	ins_end0

err_endm_not_expected:	
	error2	terr_endm_not_expected(pc)
	bra	ins_end0

err_same_r:
	error2	terr_same_r(pc)
	bra	ins_end0

err_symboltwice:
	error2	symboltwice_txt(pc)
	bra	ins_end0

noimmed:	
update:	cmp.b	#'(',d0
	bne	noupdate
	move.b	(a5)+,d0
	or.b	#$20,d0
	cmp.b	#'r',d0
	bne	err_op
	move.b	(a5)+,d0
	sub.b	#'0',d0
	blt	err_op
	cmp.b	#7,d0
	bgt	err_op
	cmp.b	#')',(a5)+
	bne	err_op
	moveq	#$10,d2
	cmp.b	#'-',(a5)+
	beq.s	.neg
	moveq	#$18,d2
	cmp.b	#'+',-1(a5)
	bne	err_op
.neg:
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1(pc)		* If rx used as dest. in last inst..
	beq.s	.nostall
	bsr	warn_rnmstall
.nostall:
	ENDC
	move.b	d0,d1
	move.b	#$40,-2(a6)
	or.b	d0,-2(a6)
	move.b	(a5),d0
	or.b	#$20,d0
	cmp.b	#'n',d0
	bne	.classic
	IFNE	WARNSTALL
	btst	d1,usenx_tbl+1(pc)		* If nx used as dest. in last inst..
	beq.s	.nostalln
	bsr	warn_rnmstall
.nostalln:
	ENDC
	sub.b	#$10,d2
.classic:	
	or.b	d2,-2(a6)
	bra	par_end0

noupdate:	
regi:	subq.w	#1,a5

	bsr	get_srcreg			* Get src. reg.
	cmp.w	#-1,d0
	beq	no_reg
	cmp.w	#$20,d0
	bhs	err_op
	cmp.b	#',',(a5)+
	bne	op_miss
	move.w	d0,d3
	
reg_2:	bsr	get_destreg			* Get dest. reg.
	cmp.w	#-1,d0
	beq.s	no_reg_2
	cmp.w	#$20,d0
	bhs	err_op
	lsl.w	#5,d3
	or.w	d3,-3(a6)
	move.b	1(a1),d0
	or.b	d0,-2(a6)
	bra	par_end0

no_reg_2:	
xmove2:	cmp.b	#':',1(a5)
	bne.s	no_xmove2
	move.b	(a5),d0
	or.b	#$20,d0
	move.w	#$4000,d4
	cmp.b	#'x',d0
	beq.s	r2x
	move.w	#$4800,d4
	cmp.b	#'y',d0
	bne	pmove2
r2x:	addq.w	#2,a5
	bsr	ea
	
	tst.w	d0
	blt.s	no_r2x
	
	move.w	d4,-3(a6)
	or.b	d0,-2(a6)
	move.b	d3,d0
	and.w	#$18,d3
	and.w	#$7,d0
	add.w	d3,d3
	or.w	d3,d0
	or.b	d0,-3(a6)
	tst.w	d2
	beq	par_end0
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+	
	bra	par_end0

no_r2x:	
no_xmove2:	
no_reg:		

xmove:	cmp.b	#':',1(a5)
	bne	no_xmove
	move.b	(a5),d0
	or.b	#$20,d0
	move.w	#$4080,d4
	cmp.b	#'x',d0
	beq.s	x2r
	move.w	#$4880,d4
	cmp.b	#'y',d0
	bne	pmove2
x2r:	addq.w	#2,a5
	bsr	ea
	tst.w	d0
	blt.s	no_x2r
	cmp.b	#',',(a5)+
	bne	op_miss
	move.w	d0,d3
	bsr	get_destreg			* Get dest. reg.
	tst.w	d0
	blt.s	no_reg2
	cmp.w	#$20,d0
	bhs	err_op
	move.w	d4,-3(a6)
	or.b	d3,-2(a6)
	move.b	d0,d3
	and.w	#$18,d3
	and.w	#$7,d0
	add.w	d3,d3
	or.w	d3,d0
	or.b	d0,-3(a6)
	tst.w	d2
	beq	par_end0
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+	
	bra	par_end0

no_reg2:
pmove2:
no_xmove:
* Source field register-handling..
no_x2r:	bra	oops
	subq.w	#1,a5
	lea	opimmed(pc),a1
.next_one:
	tst.b	(a1)
	beq	no_reg
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	move.l	a0,a5
	
	cmp.b	#',',(a5)+
	bne	op_miss
	move.b	-2(a1),d0
	cmpi.b	#'r',d0
	bne.s	.chk_n
	move.b	-1(a1),d0
	subi.b	#'0',d0
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1(pc)			* Check last rx.
	beq.s	.nostallr
	bsr	warn_rnmstall
.nostallr:
	ENDC
	bra.s	.rest
.chk_n:	cmpi.b	#'n',d0
	bne.s	.rest
	move.b	-1(a1),d0
	subi.b	#'0',d0
	IFNE	WARNSTALL
	btst	d0,usenx_tbl+1(pc)			* Check last nx.
	beq.s	.nostalln
	bsr	warn_rnmstall
.nostalln:
	ENDC
.rest:	moveq	#0,d0
	move.b	1(a1),d0
	lsl.w	#5,d0
	or.w	d0,-3(a6)
	
oops:	error2	terr_ins(pc)
	move.l	left_line(pc),a5
	bra	ins_end

doublex1:
	move.l	(sp)+,dret
dimmed:	cmp.b	#'#',d0
	bne.s	dnoimmed
	cmp.b	#'>',(a5)
	beq.s	dimmedlong
	cmp.b	#'<',(a5)
	beq	nodx1
	subq.w	#1,a5
dimmedlong:
	addq.w	#1,a5
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.b	#',',(a5)+
	bne	nodx1
dimmedlong1:
	move.b	#$b4,-2(a3)
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	move.b	(a5)+,d0
	or.b	#$20,d0
	cmp.b	#'y',d0
	beq	nodx1
	cmp.b	#'x',d0
	bne.s	.pasx
	move.b	(a5)+,d0
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	nodx1
	lsl.b	#2,d0
	or.b	d0,-3(a3)
	bra	dx1f
.pasx:	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nodx1
	lsl.b	#2,d0
	or.b	#%1000,d0
	or.b	d0,-3(a3)
	bra	dx1f
	
dnoimmed:	
	cmp.b	#':',(a5)
	bne	dnoea
dxea:	move.b	-1(a5),d0
	or.b	#$20,d0
	cmp.b	#'x',d0
	bne	nodx1
	addq.w	#1,a5
	bsr	ea
	tst.w	d0
	blt	nodx1
	
	btst.l	#6,d0
	beq	nodx1
	and.b	#$3f,d0
	move.b	#$80,-2(a3)
	or.b	d0,-2(a3)
	cmp.b	#$30,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	
	cmp.b	#',',(a5)+
	bne	nodx1
	move.b	(a5)+,d0
	or.b	#$20,d0
	cmp.b	#'y',d0
	beq	nodx1
	cmp.b	#'x',d0
	bne.s	.nox
	move.b	(a5)+,d0
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	nodx1
	lsl.b	#2,d0
	bra.s	.ok
.nox:	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nodx1
	lsl.b	#2,d0
	or.b	#%1000,d0
.ok:	or.b	d0,-3(a3)
	bra	dx1f
	
dnoea:	or.b	#$20,d0
	cmp.b	#'y',d0
	beq	nodx1
	cmp.b	#'x',d0
	bne.s	.notx
	move.b	(a5)+,d0
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	nodx1
	lsl.b	#2,d0
	bra.s	.ok
.notx:	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nodx1
	lsl.b	#2,d0
	or.b	#%1000,d0
.ok:	cmp.b	#',',(a5)+
	bne	nodx1
	cmp.b	#':',1(a5)
	bne	nodx1
	move.b	(a5),d1
	or.b	#$20,d1
	cmp.b	#'x',d1
	bne	nodx1
	or.b	d0,-3(a3)
	addq.l	#2,a5
	bsr	ea
	tst.w	d0
	blt	nodx1
	
	btst.l	#6,d0
	beq	nodx1
	and.b	#$3f,d0
	or.b	d0,-2(a3)
	cmp.b	#$30,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	
	bra	dx1f

dx1f:	moveq	#0,d0
	move.l	dret(pc),-(sp)
	rts

nodx1:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doublex2:	
	move.l	(sp)+,dret
	
	or.b	#$20,d0
	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nodx2
	
	cmp.b	#',',(a5)+
	bne	nodx2
	
	move.b	(a5)+,d1
	or.b	#$20,d1
	;cmp.b	#'x',d1
	;beq	nodx2
	cmp.b	#'y',d1
	bne	nodx2
	move.b	(a5)+,d1
	sub.b	#'0',d1
	cmp.b	#1,d1
	bhi	nodx2
	add.w	d0,d0
	or.b	d0,d1
	or.b	d1,-3(a3)
	bra	dx2f
	
dx2f:	moveq	#0,d0
	move.l	dret(pc),-(sp)
	rts

nodx2:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doublex3:	
	move.l	(sp)+,dret
	or.b	#$20,d0
	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi.s	nodx3
	cmp.b	#',',(a5)+
	bne.s	nodx3
	or.b	d0,-3(a3)
	move.w	(a5)+,d0
	or.w	#$2000,d0
	cmp.w	#'x:',d0
	bne.s	nodx3
	bsr	ea
	tst.w	d0
	blt.s	nodx3
	
	btst	#6,d0
	beq.s	nodx3
	and.b	#$3f,d0
	move.b	d0,-2(a3)
	cmp.b	#$30,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	

dx3f:	move.b	-3(a3),d0
	and.w	#1,d0
	move.l	dret(pc),-(sp)
	rts
	
nodx3:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doublex4:	
	move.l	(sp)+,dret
	move.w	-1(a5),d0
	or.w	#$2000,d0
	cmp.w	#'x0',d0
	bne.s	nodx4
	addq.l	#1,a5
	cmp.b	#',',(a5)+
	bne.s	nodx4
	move.b	(a5)+,d0
	or.b	#$20,d0
	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi.s	nodx4
	or.b	d0,-3(a3)
dx4f:	and.w	#1,d0
	move.l	dret(pc),-(sp)
	rts
	
nodx4:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doubley1:	
	move.l	(sp)+,dret
dyimmed:	
	cmp.b	#'#',d0
	bne	dynoimmed
	cmp.b	#'>',(a5)
	beq	dyimmedlong
	cmp.b	#'<',(a5)
	beq	nody1
	subq.w	#1,a5
dyimmedlong:	
	addq.w	#1,a5
	bsr	get_value
	tst.w	d5
	blt	err_val
	cmp.b	#',',(a5)+
	bne	nody1
dyimmedlong1:
	move.b	#$f4,-2(a3)
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
	move.b	(a5)+,d0
	or.b	#$20,d0
	cmp.b	#'y',d0
	bne.s	.notx
	move.b	(a5)+,d0
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	nody1
	or.b	d0,-3(a3)
	bra	dy1f
.notx:	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nody1
	or.b	#%10,d0
	or.b	d0,-3(a3)
	bra	dy1f
	
dynoimmed:	
	cmp.b	#':',(a5)
	bne	dynoea

	move.b	-1(a5),d0
	or.b	#$20,d0
	cmp.b	#'y',d0
	bne	nody1
	addq.w	#1,a5
	bsr	ea
	tst.w	d0
	blt	nody1
	
	btst.l	#6,d0
	beq	nody1
	and.b	#$3f,d0
	move.b	#$c0,-2(a3)
	or.b	d0,-2(a3)
	cmp.b	#$30,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	
	cmp.b	#',',(a5)+
	bne	nody1
	move.b	(a5)+,d0
	or.b	#$20,d0
	cmp.b	#'y',d0
	bne.s	.nox
	move.b	(a5)+,d0
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	nody1
	bra.s	.ok
.nox:	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nody1
	or.b	#%10,d0
.ok:	or.b	d0,-3(a3)
	bra	dy1f
	
dynoea:	or.b	#$20,d0
	cmp.b	#'y',d0
	bne.s	.notx
	move.b	(a5)+,d0
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	nody1
	bra.s	.ok
.notx:	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nody1
	or.b	#%10,d0
.ok:	cmp.b	#',',(a5)+
	bne	nody1
	cmp.b	#':',1(a5)
	bne	nody1
	move.b	(a5),d1
	or.b	#$20,d1
	cmp.b	#'y',d1
	bne	nody1
	or.b	d0,-3(a3)
	addq.l	#2,a5
	bsr	ea
	tst.w	d0
	blt	nody1
	
	btst.l	#6,d0
	beq.s	nody1
	or.b	d0,-2(a3)
	and.b	#$3F,d0
	;or.b	#$40,d0				; todo: is this correct?
	cmp.b	#$30,d0
	bne.s	.nolong
	addq.w	#1,apc+2			; long instruction..
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:;bra	dy1f

dy1f:	moveq	#0,d0
	move.l	dret(pc),-(sp)
	rts

nody1:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doubley2:	
	move.l	(sp)+,dret
	
	or.b	#$20,d0
	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi	nody2
	
	cmp.b	#',',(a5)+
	bne	nody2
	
	move.b	(a5)+,d1
	or.b	#$20,d1
	cmp.b	#'x',d1
	bne	nody2
	move.b	(a5)+,d1
	sub.b	#'0',d1
	cmp.b	#1,d1
	bhi	nody2
	add.w	d0,d0
	or.b	d0,d1
	lsl.b	#2,d1
	or.b	d1,-3(a3)
	bra	dy2f
	
dy2f:	moveq	#0,d0
	move.l	dret(pc),-(sp)
	rts

nody2:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doubley3:	
	move.l	(sp)+,dret
	or.b	#$20,d0
	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi.s	nody3
	cmp.b	#',',(a5)+
	bne.s	nody3
	or.b	d0,-3(a3)
	move.w	(a5)+,d0
	or.w	#$2000,d0
	cmp.w	#'y:',d0
	bne.s	nody3
	bsr	ea
	tst.w	d0
	blt.s	nody3
	
	btst	#6,d0
	beq.s	nody3
	and.b	#$3f,d0
	or.b	#$80,d0
	move.b	d0,-2(a3)
	and.b	#$3f,d0				; todo: is this correct??
	cmp.b	#$30,d0
	bne.s	.nolong
	addq.w	#1,apc+2
	swap	d6
	move.b	d6,(a6)+
	swap	d6
	move.w	d6,(a6)+
.nolong:	

dy3f:	move.b	-3(a3),d0
	and.w	#1,d0
	move.l	dret(pc),-(sp)
	rts
	
nody3:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doubley4:	
	move.l	(sp)+,dret
	move.w	-1(a5),d0
	or.w	#$2000,d0
	cmp.w	#'y0',d0
	bne.s	nody4
	addq.l	#1,a5
	cmp.b	#',',(a5)+
	bne.s	nody4
	move.b	(a5)+,d0
	or.b	#$20,d0
	sub.b	#'a',d0
	cmp.b	#1,d0
	bhi.s	nody4
	or.b	d0,-3(a3)
dy4f:	and.w	#1,d0
	move.l	dret(pc),-(sp)
	rts
	
nody4:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doublex:	
	move.l	(sp)+,dret
	move.w	-1(a5),d0
	or.w	#$2000,d0
	cmp.w	#'x:',d0
	bne.s	d2x
	addq.l	#1,a5
	bsr	eea
	tst.w	d0
	blt	nodx
	cmp.b	#',',(a5)+
	bne	nodx
	move.b	(a5)+,d1
	or.b	#$20,d1
	cmp.b	#'x',d1
	bne	.notx
	move.b	(a5)+,d1
	sub.b	#'0',d1
	cmp.b	#1,d1
	bhi	nodx
	bra.s	.ok
.notx:	sub.b	#'a',d1
	cmp.b	#1,d1
	bhi	nodx
	or.b	#%10,d1
.ok:	lsl.b	#2,d1
	or.b	d1,-3(a3)
	or.b	d0,-2(a3)
	or.b	#$80,-2(a3)
	and.b	#$4,d0
	bra.s	dxf

d2x:	move.b	-1(a5),d1
	or.b	#$20,d1
	cmp.b	#'x',d1
	bne.s	.notx
	move.b	(a5)+,d1
	sub.b	#'0',d1
	cmp.b	#1,d1
	bhi.s	nodx
	bra.s	.ok
.notx:	sub.b	#'a',d1
	cmp.b	#1,d1
	bhi.s	nodx
	or.b	#%10,d1
.ok:	lsl.b	#2,d1
	or.b	d1,-3(a3)
	cmp.b	#',',(a5)+
	bne.s	nodx

	move.w	(a5)+,d0
	or.w	#$2000,d0
	cmp.w	#'x:',d0
	bne.s	nodx
	bsr	eea
	tst.w	d0
	blt.s	nodx
	or.b	d0,-2(a3)
	and.b	#$4,d0
	;bra.s	dxf
	
dxf:	move.l	dret(pc),-(sp)
	rts

nodx:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

doubley:move.l	(sp)+,dret
	move.w	-1(a5),d0
	or.w	#$2000,d0
	cmp.w	#'y:',d0
	bne.s	d2y
	addq.l	#1,a5
	bsr	eea
	tst.w	d0
	blt	nody
	cmp.b	#',',(a5)+
	bne	nody
	move.b	(a5)+,d1
	or.b	#$20,d1
	cmp.b	#'y',d1
	bne.s	.noty
	move.b	(a5)+,d1
	sub.b	#'0',d1
	cmp.b	#1,d1
	bhi	nody
	bra.s	.ok
.noty:	sub.b	#'a',d1
	cmp.b	#1,d1
	bhi	nody
	or.b	#%10,d1
.ok:	or.b	d1,-3(a3)
	
	move.b	d0,d3
	and.b	#$4,d3
	move.b	d0,d1
	and.b	#$3,d1
	lsl.b	#5,d1
	or.b	d1,-2(a3)
	lsl.b	#1,d0
	and.b	#%110000,d0
	or.b	d0,-3(a3)
	or.b	#%1000000,-3(a3)
	bra.s	dyf

d2y:	move.b	-1(a5),d1
	or.b	#$20,d1
	cmp.b	#'y',d1
	bne.s	.noty
	move.b	(a5)+,d1
	sub.b	#'0',d1
	cmp.b	#1,d1
	bhi.s	nody
	bra.s	.ok
.noty:	sub.b	#'a',d1
	cmp.b	#1,d1
	bhi.s	nody
	or.b	#%10,d1
.ok:	or.b	d1,-3(a3)
	cmp.b	#',',(a5)+
	bne.s	nody

	move.w	(a5)+,d0
	or.w	#$2000,d0
	cmp.w	#'y:',d0
	bne.s	nody
	bsr	eea
	tst.w	d0
	blt.s	nody
	
	move.b	d0,d3
	and.b	#$4,d3
	move.b	d0,d1
	and.b	#$3,d1
	lsl.b	#5,d1
	or.b	d1,-2(a3)
	lsl.b	#1,d0
	and.b	#%110000,d0
	or.b	d0,-3(a3)
	;bra.s	dyf
	
dyf:	move.b	d3,d0
	move.l	dret(pc),-(sp)
	rts

nody:	moveq	#-1,d0
	move.l	dret(pc),-(sp)
	rts

* Subroutine that searches a table to find a SOURCEFIELD DSP-register.
* INPUT: a0: stringsource address
get_srcreg:
	lea	opimmed(pc),a1
.next_one:
	tst.b	(a1)
	beq	.no_reg
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	move.b	-2(a1),d0
	cmpi.b	#'r',d0
	bne.s	.chk_n
	move.b	-1(a1),d0
	subi.b	#'0',d0
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1(pc)		* Check if rx value set in last inst.
	beq.s	.nostallr
	bsr	warn_rnmstall
.nostallr:
	ENDC
	bra.s	.rest
.chk_n:	cmpi.b	#'n',d0
	bne.s	.rest
	move.b	-1(a1),d0
	subi.b	#'0',d0
	IFNE	WARNSTALL
	btst	d0,usenx_tbl+1(pc)		* Check if nx value set in last inst.
	beq.s	.nostalln
	bsr	warn_rnmstall
.nostalln:
	ENDC
.rest:	move.l	a0,a5
	moveq	#0,d0
	move.b	1(a1),d0
	rts
.no_reg:moveq	#-1,d0
	rts

* Subroutine that searches a table to find a DESTINATIONFIELD DSP-register.
* INPUT: a0: stringsource address
get_destreg:
	lea	opimmed(pc),a1
.next_one:
	tst.b	(a1)
	beq	.no_reg
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	move.b	-2(a1),d0
	cmpi.b	#'r',d0
	bne.s	.chk_n
	move.b	-1(a1),d0
	subi.b	#'0',d0
	bset	d0,userx_tbl			* Mark rx as used.
	bra.s	.rest
.chk_n:	cmpi.b	#'n',d0
	bne.s	.rest
	move.b	-1(a1),d0
	subi.b	#'0',d0
	bset	d0,usenx_tbl			* Mark nx as used.
.rest:	move.l	a0,a5
	moveq	#0,d0
	move.b	1(a1),d0
	rts
.no_reg:moveq	#-1,d0
	rts

regc:	lea	opctrl(pc),a1
.next_one:
	tst.b	(a1)
	beq	.no_reg
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	move.l	a0,a5
	moveq	#0,d0
	move.b	1(a1),d0
	rts

.no_reg:	
	moveq	#-1,d0
	rts

regl:	lea	opl(pc),a1
.next_one:
	tst.b	(a1)
	beq	.no_reg
	move.l	a5,a0
.next0:	tst.b	(a1)
	beq.s	.found
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	(a1)+,d0
	beq.s	.next0
.notthis:	
	tst.b	(a1)+
	bne.s	.notthis
	addq.w	#1,a1
	bra.s	.next_one
.found:	move.l	a0,a5
	moveq	#0,d0
	move.b	1(a1),d0
	rts
.no_reg:	
	moveq	#-1,d0
	rts

ea:	movem.l	d1/d3,-(sp)
	moveq	#0,d2
	move.l	(a5),d0
	lsr.l	#8,d0
	or.w	#$20,d0
	cmp.l	#'-(r',d0
	bne.s	ea2
	addq.w	#3,a5
	moveq	#0,d0
	move.b	(a5)+,d0
	sub.b	#'0',d0
	blt	err_ea
	cmp.b	#7,d0
	bhi	err_ea
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1
	beq.s	.nostall
	bsr	warn_rnmstall
.nostall:
	ENDC
	or.w	#$78,d0
	cmp.b	#')',(a5)+
	bne	err_ea
	movem.l	(sp)+,d1/d3
	rts

ea2:	move.l	a5,a0
	move.w	(a0)+,d0
	or.w	#$20,d0
	cmp.w	#'(r',d0
	bne	ea4
	moveq	#0,d0
	move.b	(a0)+,d0
	move.b	d0,d3
	sub.b	#'0',d0
	blt	err_ea
	cmp.b	#7,d0
	bhi	err_ea
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1
	beq.s	.nostallr
	bsr	warn_rnmstall
.nostallr:
	ENDC
	or.w	#$40,d0
	cmp.b	#'+',(a0)
	bne.s	ea3
	move.l	(a0),d1
	and.l	#$df00ff,d1
	cmp.l	#$4e0029,d1	;"N )"
	bne	err_ea
	cmp.b	2(a0),d3
	bne	err_ea2
	subi.b	#'0',d3
	IFNE	WARNSTALL
	btst	d3,usenx_tbl+1
	beq.s	.nostalln
	bsr	warn_rnmstall
.nostalln:
	ENDC
	or.w	#$28,d0
	lea	4(a0),a5
	movem.l	(sp)+,d1/d3
	rts

ea3:	cmp.b	#')',(a0)+
	bne	err_ea
	or.w	#$10,d0
	cmp.b	#'-',(a0)
	beq.s	.ici
	and.w	#$47,d0
	or.w	#$20,d0
	cmp.b	#'+',(a0)
	bne.s	fin_ea
	and.w	#$47,d0
	or.w	#$18,d0
.ici:	addq.w	#1,a0
	move.w	(a0),d1
	and.w	#$dff8,d1
	cmp.w	#'N0',d1
	bne.s	fin_ea
	cmp.b	1(a0),d3
	bne	err_ea2
	and.w	#$4f,d0
	addq.w	#2,a0
fin_ea:	move.l	a0,a5
	movem.l	(sp)+,d1/d3
	rts

ea4:	move.l	a5,a0
;	cmp.b	#'>',(a5)
;	bne.s	ea_short
;	addq.w	#1,a5
;	bra.s	.mode
.mode2:	cmp.b	#'<',(a5)
	beq.s	ea_short
	cmp.b	#'>',(a5)+
	beq.s	.mode
	subq.w	#1,a5
.mode:	bsr	get_value
	tst.w	d5
	blt.s	err_ea
ea_long:
	moveq	#-1,d2
	move.w	#$70,d0
	movem.l	(sp)+,d1/d3
	rts

ea_short:
	move.l	a5,a0
	cmp.b	#'<',(a5)
	bne.s	.ici
	addq	#1,a5
	bsr	get_value
	tst.w	d5
	blt.s	err_ea
	
	cmp.w	#$3f,d6
	bhi	err_ea
	move.w	d6,d0
	and.w	#$3f,d0
	movem.l	(sp)+,d1/d3
	rts

.ici:	bsr	get_value
	tst.w	d5
	blt.s	err_ea
	
	move.w	apc+2(pc),d3
	cmp.w	d3,d6
	bhi.s	ea_long
	cmp.w	#$3f,d6
	bhi.s	err_ea
	move.w	d6,d0
	and.w	#$3f,d0
	movem.l	(sp)+,d1/d3
	rts

no_ea:	moveq	#-1,d0
	movem.l	(sp)+,d1/d3
	rts

err_ea:	moveq	#-2,d0
	move.l	#terr_range,text_err
	movem.l	(sp)+,d1/d3
	rts

err_ea2:	
	moveq	#-2,d0
	move.l	#terr_Nx,text_err
	movem.l	(sp)+,d1/d3
	rts

eea:	movem.l	d1/d3,-(sp)
	moveq	#0,d2
	move.l	(a5),d0
	lsr.l	#8,d0
	or.w	#$20,d0
	move.l	a5,a0
	move.w	(a0)+,d0
	or.w	#$20,d0
	cmp.w	#'(r',d0
	bne	err_eea
	moveq	#0,d0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	blt	err_eea
	cmp.b	#7,d0
	bhi	err_eea
	IFNE	WARNSTALL
	btst	d0,userx_tbl+1
	beq.s	.nostallr
	bsr	warn_rnmstall
.nostallr:
	ENDC
	or.w	#$40,d0
	cmp.b	#')',(a0)+
	bne	err_eea
	or.w	#$10,d0
	cmp.b	#'-',(a0)
	beq.s	.ici
	and.w	#$47,d0
	or.w	#$20,d0
	cmp.b	#'+',(a0)
	bne.s	fin_eea
	and.w	#$47,d0
	or.w	#$18,d0
.ici:	addq.w	#1,a0
	move.w	(a0),d1
	and.w	#$dff8,d1
	cmp.w	#'N0',d1
	bne.s	fin_eea
	move.b	1(a0),d1
	subi.b	#'0',d1
	IFNE	WARNSTALL
	btst	d1,usenx_tbl+1
	beq.s	.nostalln
	bsr	warn_rnmstall
.nostalln:
	ENDC
	;cmp.b	#'+',-2(a0)
	;bne.s	err_eea
	and.w	#$4f,d0
	addq.w	#2,a0
fin_eea:	
	and.b	#$1f,d0
	move.l	a0,a5
	movem.l	(sp)+,d1/d3
	rts

no_eea:	moveq	#-1,d0
	movem.l	(sp)+,d1/d3
	rts

err_eea:	
	moveq	#-2,d0
	movem.l	(sp)+,d1/d3
	rts

par_end0:
par_end:	
	subq.w	#2,a5

.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1d
	cmp.b	#9,d0
	beq.s	.br1d
	cmp.b	#13,d0
	beq.s	.br1d
	tst.b	d0
	beq	asm_end
	bra.s	.br1b
.br1d:	subq.l	#1,a5
par_end2:		
.br1b:	move.b	(a5)+,d0
	cmp.b	#' ',d0
	beq.s	.br1b
	cmp.b	#9,d0
	beq.s	.br1b
	cmp.b	#13,d0
	beq.s	ins_end0
	tst.b	d0
	beq	asm_end
.br1d:	cmp.b	#';',d0
	bne	err_double

ins_end0:
	subq.w	#1,a5
ins_end:until	#0
	tst.w	d0
	bne	new_one

asm_end:		
	move.w	sourcefilestackdepth(pc),d0
	beq.s	.filestacklvl0
	subq.w	#1,d0
	move.w	d0,sourcefilestackdepth
	mulu.w	#stackentrysize,d0
	lea	(sourcefilestack_tbl,d0.l),a0
	move.l	stackentrysadr(a0),source
	move.l	stackentryreal(a0),real_source
	move.l	source(pc),source2
	lea	line_buff(pc),a5
	bra	new_one
.filestacklvl0:
	tst.w	nb_err(pc)
	bne.s	.ici
	move.l	mema6(pc),a0
	move.l	a6,mema6
	addq.b	#1,pass
	cmp.b	#1,pass
	beq	new_pass
	cmp.l	a0,a6
	beq.s	.ici
* To check if the programcounter is ok or not!! If one instruction is say:
* assembled into one word and the programcounter is increased with 2 this
* happens!
	Cconws2	tscode(pc)

.ici:	move.l	dest0(pc),a0
	move.l	a6,d0
	sub.l	a0,d0
	bne.s	.ici0
	lea	-9(a6),a6
.ici0:	divu.l	#3,d0
	move.w	d0,-2(a0)
	swap	d0
	move.b	d0,-3(a0)
	
	tst.b	n_opt(pc)
	bne	no_file

;	Cconws2	p56active_txt(pc)

	tst.w	nb_err(pc)
	bne	no_file
	lea	savename_txt(pc),a5
.shend:	move.b	(a5)+,d0
	beq.s	.end
	cmp.b	#' ',d0
	bne.s	.shend
.end:
.sh:	cmp.b	#'.',-(a5)
	bne.s	.sh
	addq	#1,a5
	move.l	#"P56 "&$ffffff00,(a5)+
	
; Output the p56.
	Fcreate	#savename_txt,#0
	tst.w	d0
	bge.s	createok
err_fcreate:
	error2	terr_fcreate(pc)
	Cconws	#savename_txt
	Cconws2	tcr(pc)
	bra.s	endcreate
createok:	
	move.w	d0,d7
	move.l	dest(pc),a0
	move.l	a6,d6
	sub.l	a0,d6
	Fwrite	d7,d6,a0
	tst.l	d0
	blt.s	err_fcreate
	Fclose	d7
endcreate:	

no_file:
	tst.b	l_opt(pc)
	beq	endcreat
	tst.w	nb_err(pc)
	bne	endcreat

	Malloc	#page_size
	move.l	d0,lodbufadr
	beq	err_fcreat
	move.l	d0,a4

; Output lod.
	bsr	make_lod
	lea	savename_txt(pc),a5
.shend:	move.b	(a5)+,d0
	beq.s	.end
	cmp.b	#' ',d0
	bne.s	.shend
.end:
.sh:	cmp.b	#'.',-(a5)
	bne.s	.sh
	addq.w	#1,a5
	move.l	#"LOD "&$ffffff00,(a5)+
	
	Fcreate	#savename_txt,#0
	tst.w	d0
	bge.s	creatok
err_fcreat:
	error2	terr_fcreate(pc)
	Cconws	#savename_txt
	Cconws2	tcr(pc)
	bra.s	endcreat
creatok:	
	move.w	d0,d7
	movea.l	lodbufadr(pc),a0
	move.l	a4,d6
	sub.l	a0,d6
	Fwrite	d7,d6,a0
	tst.l	d0
	blt.s	err_fcreat
	Fclose	d7
endcreat:	

	move.l	errors_adr(pc),d0
	beq.s	.boaf
	move.l	d0,a0
	move.w	#-1,(a0)+
.boaf:	Cconws2	t_res0(pc)

	move.w	nb_err(pc),-(sp)
	bsr	afdeci
	addq.w	#2,sp
	Cconws2	terrors(pc)
	move.w	nb_warn(pc),-(sp)
	bsr	afdeci
	addq.w	#2,sp
	Cconws2	twarnings(pc)

	move.w	line(pc),-(sp)
	bsr	afdeci
	addq.w	#2,sp
	Cconws2	t_res1(pc)
	
fin:	
fini0:	move.b	m_opt(pc),d0
	or.b	w_opt(pc),d0
	beq.s	.dontwait
* Print presskey message..
	Cconws2	presskey_txt(pc)
* Wait for a keypress..
	move.w	#7,-(sp)
	trap	#1
	addq	#2,sp
;	move.w	#2,-(sp)
;	move.w	#2,-(sp)
;	trap	#13
;	addq	#4,sp
.dontwait:
	Pterm	#0


err_mem:move.w	d0,d7
	error2	terr_mem(pc)
	Crawcin
	Pterm	d7

; INPUT:
; 4(sp): warning msg
p_warn:	movem.l	d0-a6,-(sp)

	tst.b	pass(pc)			; only in pass 1..
	bne.s	.end

	addq.w	#1,nb_warn

	Cconws2	warn_txt(pc)
	move.w	line(pc),-(sp)
	bsr	afdeci
	addq.w	#2,sp

	move.l	16*4(sp),-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp

	move.l	left_line(pc),a5
	movea.l	a5,a6
	subq	#1,d6
.find:	addq	#1,a6
	cmpi.b	#13,(a6)
	beq.s	.found
	cmpi.b	#10,(a6)
	bne.s	.find
.found:	move.b	(a6),d7
	clr.b	(a6)
	Cconws	left_line(pc)
	move.b	d7,(a6)
	Cconws2	tcr(pc)

;	move.l	warnings_adr,d0
;	beq.s	.no_buff_errors
;	cmpi.l	#'****',warn_txt
;	bne.s	.no_buff_errors			; only needed when shell is active (dspdit)
;	movea.l	d0,a0
;	move.l	4+8(sp),a1
;	move.w	-2(a1),(a0)+
;	move.w	line(pc),(a0)+
;	move.l	a0,errors_adr
;.no_buff_errors:

.end:	movem.l	(sp)+,d0-a6
	rts

p_error:addq.w	#1,nb_err
	Cconws2	terr(pc)
	move.w	line(pc),-(sp)
	bsr	afdeci
	addq.w	#2,sp
	move.l	4(sp),-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.w	#6,sp
	
	movem.l	a5/d7,-(sp)
	move.l	left_line(pc),a5
	until	#0
	move.b	(a5),d7
	clr.b	(a5)
	Cconws	left_line(pc)
	move.b	d7,(a5)
	tst.b	-1(a5)
	bne.s	.pascr
	Cconws2	tcr(pc)
.pascr:	move.l	errors_adr,d0
	beq.s	.no_buff_errors
	cmp.l	#'****',terr
	bne.s	.no_buff_errors			; only needed when shell is active (dspdit)
	move.l	d0,a0
	move.l	4+8(sp),a1
	move.w	-2(a1),(a0)+
	move.w	line(pc),(a0)+
	move.l	a0,errors_adr
.no_buff_errors:
	movem.l	(sp)+,a5/d7
	rts

* INPUT: d0.b: char to search for
until:
.br1:	cmp.b	(a5),d0
	beq.s	.found
	cmp.b	#13,(a5)+
	bne.s	.br1
	moveq	#-1,d0
	cmp.b	#10,(a5)+
	bne.s	.br
	rts
.br:	subq.w	#1,a5
	rts
.found:	moveq	#0,d0
	addq.w	#1,d6
	rts

untilwh:	
.br1:	move.b	(a5)+,d0
	cmp.b	#" ",d0
	beq.s	.found
	cmp.b	#9,d0
	beq.s	.found
	cmp.b	#13,d0
	bne.s	.br1
	subq	#1,a5
	moveq	#-1,d0
	rts
.found:	subq	#1,a5
	moveq	#0,d0
	addq.w	#1,d6
	rts

get_quick:
	DS.W	1
get_value_:	
	addq.l	#1,a5
get_value:	
	cmp.b	#'<',(a5)
	beq.s	get_value_
	cmp.b	#'>',(a5)
	beq.s	get_value_
	cmp.b	#'<',-1(a5)
	seq.b	get_quick
	bsr.s	get_valueb
	tst.w	nb_par(pc)
	beq.s	.ici
	moveq	#-1,d5
.ici:	
	rts

get_valueb:	
	movem.l	d0/d2-d4/d7,-(sp)
;	tst.w	nb_par
;	bne.s	.ici
;	cmp.b	#'<',-1(a5)
;	seq.b	get_quick
;.ici:	
	moveq	#-1,d5
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d6
	moveq	#0,d7
	bsr	get_val
	moveq	#1,d6
	muls.l	d5,d7:d6
* Check on arithmetic in expression, if so calculate it's value.	
gsign:	move.b	(a5)+,d2
gshl:	cmp.w	#'>>',-1(a5)
	bne.s	gshr
	addq.l	#1,a5
	bsr	get_val
	neg.w	d5
	bgt.s	gshr0
gshl0:	neg.w	d5
	subq.w	#1,d5
	cmp.w	#31,d5
	bhi.s	gsign
.loop:	asr.l	d7
	roxr.l	d6
	dbra	d5,.loop
	bra.s	gsign
gshr:	cmp.w	#'<<',-1(a5)
	bne.s	gmul
	addq.l	#1,a5
	bsr	get_val
	tst.w	d5
	blt.s	gshl0
gshr0:	subq.w	#1,d5
	cmp.w	#31,d5
	bhi.s	gsign
.loop:	add.l	d6,d6
	addx.l	d7,d7
	dbra	d5,.loop
	bra.s	gsign
gmul:	cmp.b	#'*',d2
	bne.s	gdiv
	bsr	get_val
	muls.l	d5,d7:d6
	bra.s	gsign
gdiv:	cmp.b	#'/',d2
	bne.s	gplus
	bsr	get_val
	divs.l	d5,d7:d6
	moveq	#1,d5
	muls.l	d5,d7:d6
	bra.s	gsign
gplus:	cmp.b	#'+',d2
	bne.s	gmoins
gplus0:	add.l	d3,d6
	addx.l	d4,d7
	move.l	d7,d4
	move.l	d6,d3
	bsr	get_val
	moveq	#1,d6
	muls.l	d5,d7:d6
	bra	gsign
	
gmoins:	cmp.b	#'-',d2
	bne.s	gmoins0
	subq.w	#1,a5
	bra.s	gplus0
gmoins0:	
gparf:	cmp.b	#')',d2
	bne.s	gparf0
	subq.w	#1,nb_par
	addq.l	#1,a5
	bra.s	gfin
gparf0:	cmp.b	#13,d2
	beq.s	gfin
	cmp.b	#',',d2
	beq.s	gfin
	cmp.b	#' ',d2
	beq.s	gfin
	cmp.b	#9,d2
	bne.s	gf
gfin:	add.l	d3,d6
	addx.l	d4,d7
	subq.w	#1,a5
	move.l	d0,d5
;	tst.w	nb_par
;	beq.s	.ici
;	moveq	#-1,d5
;.ici:	
	movem.l	(sp)+,d0/d2-d4/d7
	rts
gf:	subq.w	#1,a5
	moveq	#-1,d5
	movem.l	(sp)+,d0/d2-d4/d7
	rts

get_val:move.w	d1,-(sp)
	clr.w	d1
	moveq	#0,d0
	moveq	#0,d5
.ici:	move.b	(a5)+,d5
	cmp.b	#'+',d5
	bne.s	.ici0
	clr.w	d1
	bra.s	.ici
.ici0:	cmp.b	#'-',d5
	bne.s	.ici1
	not.w	d1
	bra.s	.ici
.ici1:
.gparo:	cmp.b	#'(',d5
	bne.s	.gparo0
	addq.w	#1,nb_par
	move.l	d6,-(sp)
	bsr	get_valueb
	tst.l	d5
	blt	.err_get0
	move.l	d6,d5
	move.l	(sp)+,d6
	bra.s	decif0
.err_get0:	
	move.l	(sp)+,d6
	bra	err_get
.gparo0:cmpi.b	#'$',d5
	beq	hex
	cmpi.b	#'*',d5
	beq	get_pc
	cmpi.b	#"'",d5
	beq	asciis
	cmpi.b	#'"',d5
	beq	asciid
	cmpi.b	#'%',d5
	beq	bin
	cmpi.b	#'.',d5
	beq.s	fdeci
	addq.l	#1,a5
	cmp.w	#'0.',-2(a5)
	beq.s	fdeci
	subq.l	#1,a5
	sub.b	#'0',d5
	cmp.b	#9,d5
	bhi	not_val
deci:	move.b	(a5)+,d0
	beq.s	decif
	sub.b	#'0',d0
	blt	decif
	cmp.b	#9,d0
	bhi	decif
	mulu.l	#10,d5
	add.l	d0,d5
	bra.s	deci
decif:	subq.w	#1,a5
decif0:	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.w	(sp)+,d1
	rts
fdeci:	move.l	d2,-(sp)
	moveq	#1,d2
	clr.l	d5
fdeci0:	move.b	(a5)+,d0
	beq.s	fdecif
	sub.b	#'0',d0
	cmp.b	#9,d0
	bhi	fdecif
	cmp.l	#10000000,d2
	bhs.s	fdeci0
	mulu.l	#10,d2
	mulu.l	#10,d5
	add.l	d0,d5
	bra.s	fdeci0
fdecif:	mulu.l	#$800000,d0:d5
	divu.l	d2,d0:d5
	subq.w	#1,a5
fdecif0:	
	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.l	(sp)+,d2
	move.w	(sp)+,d1
	rts

hex:	moveq	#0,d5
	move.b	(a5)+,d0
	beq.s	hexf
	cmp.b	#'.',d0
	beq.s	fhex
	addq.l	#1,a5
	cmp.w	#'0.',-2(a5)
	beq.s	fhex
	subq.l	#1,a5
	cmp.b	#'9',d0
	bls.s	.br1
	or.b	#$20,d0
	add.b	#'9'-'a'+1,d0
.br1:	sub.b	#'0',d0
	blt	err_get
	cmp.b	#15,d0
	bhi	err_get
	add.l	d0,d5

hex0:	move.b	(a5)+,d0
	beq.s	hexf
	cmp.b	#'9',d0
	bls.s	.br1
	or.b	#$20,d0
	add.b	#'9'-'a'+1,d0
.br1:	sub.b	#'0',d0
	blt	hexf
	cmp.b	#15,d0
	bhi	hexf
	asl.l	#4,d5
	add.l	d0,d5
	bra.s	hex0
hexf:	subq.w	#1,a5
	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.w	(sp)+,d1
	rts

fhex:	move.l	d2,-(sp)
	moveq	#1,d2
	clr.l	d5
fhex0:	move.b	(a5)+,d0
	beq.s	fhexf
	cmp.b	#'9',d0
	bls.s	.br1
	or.b	#$20,d0
	add.b	#'9'-'a'+1,d0
.br1:	sub.b	#'0',d0
	blt	fhexf
	cmp.b	#15,d0
	bhi	fhexf
	cmp.l	#$1000000,d2
	bhi.s	fhex0
	asl.l	#4,d2
	asl.l	#4,d5
	add.l	d0,d5
	bra.s	fhex0
fhexf:	mulu.l	#$800000,d0:d5
	divu.l	d2,d0:d5
	subq.w	#1,a5
	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.l	(sp)+,d2
	move.w	(sp)+,d1
	rts

* Fetch ascii data's between single quotes..
asciis:	moveq	#0,d5
	move.b	(a5)+,d0
.loop	lsl.l	#8,d5
	move.b	d0,d5
	move.b	(a5)+,d0
	cmpi.b	#"'",d0
	bne.s	.loop
	move.w	(sp)+,d1
	rts

* Fetch ascii data between double quotes..
asciid:	moveq	#0,d5
	move.b	(a5)+,d0
.loop	lsl.l	#8,d5
	move.b	d0,d5
	move.b	(a5)+,d0
	cmpi.b	#'"',d0
	bne.s	.loop
	move.w	(sp)+,d1
	rts

bin:	moveq	#0,d5
	move.b	(a5)+,d0
	beq.s	binf
	cmp.b	#'.',d0
	beq.s	fbin
	addq.l	#1,a5
	cmp.w	#'0.',-2(a5)
	beq.s	fbin
	subq.l	#1,a5
	sub.b	#'0',d0
	cmp.b	#1,d0
	bhi	err_get
	asl.l	d5
	add.l	d0,d5
bin0:	move.b	(a5)+,d0
	beq.s	binf
	sub.b	#'0',d0
	blt	binf
	cmp.b	#1,d0
	bhi	binf
	asl.l	d5
	add.l	d0,d5
	bra.s	bin0
binf:	subq.w	#1,a5
	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.w	(sp)+,d1
	rts

fbin:	move.l	d2,-(sp)
	moveq	#1,d2
	clr.l	d5
fbin0:	move.b	(a5)+,d0
	beq.s	fbinf
	sub.b	#'0',d0
	blt	fbinf
	cmp.b	#1,d0
	bhi	fbinf
	cmp.l	#$1000000,d2
	bhi.s	fbin0
	asl.l	d2
	asl.l	d5
	add.l	d0,d5
	bra.s	fbin0
fbinf:	mulu.l	#$800000,d0:d5
	divu.l	d2,d0:d5
	subq.w	#1,a5
	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.l	(sp)+,d2
	move.w	(sp)+,d1
	rts
	
get_pc:	moveq	#0,d5
	move.w	apc+2(pc),d5
	moveq	#0,d0
	tst.w	d1
	bge.s	.ici
	neg.l	d5
.ici:	move.w	(sp)+,d1
	rts
	
; Not a value, so it must be either a label/equate or crap.
not_val:movem.l	d6/a0-a2,-(sp)
	lea	-1(a5),a0
	move.l	a0,a2
	moveq	#0,d5
.ici:	move.b	(a5)+,d0
	beq.s	.fin
	cmp.b	#13,d0
	beq.s	.fin
	cmp.b	#',',d0
	beq.s	.fin
	cmp.b	#' ',d0
	beq.s	.fin
	cmp.b	#9,d0
	beq.s	.fin
	cmp.b	#'*',d0
	beq.s	.fin
	cmp.b	#'-',d0
	beq.s	.fin
	cmp.b	#'/',d0
	beq.s	.fin
	cmp.b	#'+',d0
	beq.s	.fin
	cmp.b	#')',d0
	beq.s	.fin
	addq.w	#1,d5
	bra.s	.ici
.fin:	subq	#1,a5
	move.l	a5,-(sp)

	cmp.w	#'__',(a0)
	bne.s	.nomloc

	move.l	a0,a5
	lea	lbel(pc),a1
	lea	lbel0(pc),a0
	move.w	d5,d6
	move.l	a4,-(sp)
	move.l	a0,a4
	move.w	mac_no(pc),-(sp)
	bsr	mkhex4
	move.l	a4,a0
	addq.w	#4,d5
	move.l	(sp)+,a4
.mcopy0:move.b	(a5)+,(a0)+
	dbf	d6,.mcopy0
	clr.b	(a0)
	lea	lbel0(pc),a0
	bra.s	.noloc
.nomloc:cmp.b	#'_',(a0)
	bne.s	.noloc

; new shit
	move.l	a0,a5
	lea	lbel(pc),a1
	lea	lbel0(pc),a0
	move.w	d5,d6
.copy:	addq.w	#1,d5
	move.b	(a1)+,(a0)+
	bne.s	.copy
	subq.w	#1,d5
	subq	#1,a0
.copy0:	move.b	(a5)+,(a0)+
	dbra	d6,.copy0
	clr.b	(a0)
	lea	lbel0(pc),a0
.noloc:	move.w	d5,d0
	addq.w	#1,d0
	move.w	d1,-(sp)			; Save sign.
	bsr	Hash.get
	move.l	d1,d5
	move.w	(sp)+,d1			; Restore sign.
	tst.w	Hash.wasFound(pc)
	beq.s	.oops

	andi.l	#$00FFFFFF,d5				; todo!! whatda fak, clear labeltype

	moveq	#0,d0
	move.l	(sp)+,a5
	movem.l	(sp)+,d6/a0-a2
	tst.w	d1
	bge.s	.ici0
	neg.l	d5
.ici0:	move.w	(sp)+,d1
	rts
.oops:	move.l	(sp)+,a5
	move.w	(a2),d0
	ori.w	#$2007,d0
	cmpi.w	#'r7',d0
	bne.s	.cool000
* Jezus! This suxx! But it works..
	move.b	2(a2),d6
	cmpi.b	#9,d6
	beq.s	.is_rn
	cmpi.b	#" ",d6
	beq.s	.is_rn
	cmpi.b	#")",d6
	beq.s	.is_rn
	cmpi.b	#",",d6
	bne.s	.cool000
.is_rn:
	movem.l	(sp)+,d6/a0-a2
	bra.s	err_get
.cool000:
	movem.l	(sp)+,d6/a0-a2
	tst.w	pass(pc)
	bne.s	err_get
	;clr.w	nb_par			; what a crap! Why clear number of parenthesis when a label is not found??!?!?
	moveq	#0,d0
	moveq	#0,d5
	tst.b	get_quick(pc)
	bne.s	.la
	move.l	#$1000,d5
.la:	move.w	(sp)+,d1
	rts
err_get:	
	moveq	#-1,d0
	clr.w	nb_par
	move.w	(sp)+,d1
	rts

afdeci:	movem.l	d5-d7,-(sp)
	clr.b	zerodeci
	move.w	16(sp),d7
	ext.l	d7
	move.l	#10000,d5
deci1:	move.l	d7,d6
	divu.w	d5,d6
	beq.s	.br1
	st.b	zerodeci
	bra.s	.br2
.br1:	tst.b	zerodeci(pc)
	beq.s	.br3
.br2:	add.b	#'0',d6
	move.w	d6,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
.br3:	swap	d6
	move.w	d6,d7
	ext.l	d7
	divu.w	#10,d5
	ext.l	d5
	bne.s	deci1
	tst.b	zerodeci(pc)
	bne.s	.br4
	move.w	#'0',-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
.br4:	movem.l	(sp)+,d5-d7
rts:	rts
zerodeci:	ds.w	1


; INPUT:
; d0.l=number
; a0: dst string
long2hex:
	moveq	#8-1,d5
.hex1:	rol.l	#4,d0
	move.w	d0,d6
	and.w	#$f,d6
	add.b	#'0',d6
	cmp.b	#'9',d6
	bls.s	.br1
	addq.b	#'A'-'9'-1,d6
.br1:	move.b	d6,(a0)+
	dbf	d5,.hex1
	rts

mkhex6:	movem.l	d5-d7,-(sp)
	move.l	16(sp),d7
	moveq	#5,d5
	rol.l	#8,d7
.hex1:	rol.l	#4,d7
	move.w	d7,d6
	and.w	#$f,d6
	add.b	#'0',d6
	cmp.b	#'9',d6
	bls.s	.br1
	addq.b	#'A'-'9'-1,d6
.br1:	move.b	d6,(a4)+
	dbra	d5,.hex1
	movem.l	(sp)+,d5-d7
	rtd	#4

mkhex4:	movem.l	d5-d7,-(sp)
	move.w	16(sp),d7
	moveq	#3,d5
.hex1:	rol.w	#4,d7
	move.w	d7,d6
	and.w	#$f,d6
	add.b	#'0',d6
	cmp.b	#'9',d6
	bls.s	.br1
	addq.b	#'A'-'9'-1,d6
.br1:	move.b	d6,(a4)+
	dbra	d5,.hex1
	movem.l	(sp)+,d5-d7
	rtd	#2

mkc:	move.l	a0,-(sp)
	move.l	8(sp),a0
.br1:	move.b	(a0)+,d0
	move.b	d0,(a4)+
	cmpi.b	#equtype,d0
	bhi.s	.br1
	subq	#1,a4
	movea.l	(sp)+,a0
	rtd	#4

first_sec:	ds.w	1
make_lod:
; Put in header.. (name, assemblername, etc..)
	pea.l	tstart(pc)
	bsr.s	mkc
	move.b	#' ',(a4)+
	move.l	#savename_txt,-(sp)
	bsr.s	mkc
	subq.w	#4,a4
	move.b	#' ',(a4)+
	pea.l	tname(pc)
	bsr.s	mkc

; Put in DATA-blocks.	
	move.l	dest(pc),a0
	move.w	4(a0),first_sec
new_sec:	
	pea.l	tdata(pc)
	bsr.s	mkc
	addq.w	#2,a0
	move.b	(a0)+,d0
	bne.s	.x
	move.b	#'P',(a4)+
	bra.s	.ok
.x:	cmp.b	#xmemtype,d0
	bne.s	.y
	move.b	#'X',(a4)+
	bra.s	.ok
.y:	cmp.b	#ymemtype,d0
	bne.s	.i
	move.b	#'Y',(a4)+
	bra.s	.ok
.i:	move.b	#'?',(a4)+
.ok:	move.b	#' ',(a4)+
	
	addq.w	#1,a0
	move.w	(a0)+,-(sp)
	bsr	mkhex4
	pea.l	tcr(pc)
	bsr	mkc
	addq.w	#1,a0
	moveq	#0,d5
	move.w	(a0)+,d7
	subq.w	#1,d7
new_val:move.b	(a0)+,d6
	swap	d6
	move.w	(a0)+,d6
	move.l	d6,-(sp)
	bsr	mkhex6
	move.b	#' ',(a4)+
	addq.w	#1,d5
	move.b	d5,d6
	and.b	#$7,d6
	bne.s	.br1
	pea.l	tcr(pc)
	bsr	mkc
.br1:	dbra	d7,new_val
	
	cmp.l	a6,a0
	blo.s	new_sec

	pea.l	tcr(pc)
	bsr	mkc
	
; Put in P-symbols..
putpsymbol:
	movea.l	Hash.bufferAdr,a0
	movea.l	Hash.nextStringAdr,a6
	cmpa.l	a0,a6
	beq.s	.end_p_symbol
.firstloop:
	tst.b	(a0)
	beq.s	.found
	movea.l	a0,a1
	addq	#4,a0
.strloop:
	tst.b	(a0)+
	bne.s	.strloop
	bra.s	.firstloop
.found:	pea.l	psymbol_txt(pc)
	bsr	mkc

.loop:	cmpa.l	a0,a6
	beq.s	.end_p_symbol
	tst.b	(a0)
	beq.s	.found2
.cont:	movea.l	a0,a1
	addq	#4,a0
.strloop2:
	tst.b	(a0)+
	bne.s	.strloop2
	bra.s	.loop
.found2:pea.l	4(a0)
	bsr	mkc
	move.l	#"  I ",(a4)+
	moveq	#0,d0
	move.w	2(a0),d0
	move.l	d0,-(sp)
	bsr	mkhex6
	pea.l	tcr(pc)
	bsr	mkc
	bra.s	.cont
.end_p_symbol:

; Put in X-symbols..
putxsymbol:
	movea.l	Hash.bufferAdr,a0
	movea.l	Hash.nextStringAdr,a6
	cmpa.l	a0,a6
	beq.s	.end_x_symbol
.firstloop:
	cmpi.b	#xmemtype,(a0)
	beq.s	.found
	movea.l	a0,a1
	addq	#4,a0
.strloop:
	tst.b	(a0)+
	bne.s	.strloop
	bra.s	.firstloop
.found:	pea.l	xsymbol_txt(pc)
	bsr	mkc

.loop:	cmpa.l	a0,a6
	beq.s	.end_x_symbol
	cmpi.b	#xmemtype,(a0)
	beq.s	.found2
.cont:	movea.l	a0,a1
	addq	#4,a0
.strloop2:
	tst.b	(a0)+
	bne.s	.strloop2
	bra.s	.loop
.found2:pea.l	4(a0)
	bsr	mkc
	move.l	#"  I ",(a4)+
	moveq	#0,d0
	move.w	2(a0),d0
	move.l	d0,-(sp)
	bsr	mkhex6
	pea.l	tcr(pc)
	bsr	mkc
	bra.s	.cont
.end_x_symbol:

; Put in Y-symbols..
putysymbol:
	movea.l	Hash.bufferAdr,a0
	movea.l	Hash.nextStringAdr,a6
	cmpa.l	a0,a6
	beq.s	.end_y_symbol
.firstloop:
	cmpi.b	#ymemtype,(a0)
	beq.s	.found
	movea.l	a0,a1
	addq	#4,a0
.strloop:
	tst.b	(a0)+
	bne.s	.strloop
	bra.s	.firstloop
.found:	pea.l	ysymbol_txt(pc)
	bsr	mkc

.loop:	cmpa.l	a0,a6
	beq.s	.end_y_symbol
	cmpi.b	#ymemtype,(a0)
	beq.s	.found2
.cont:	movea.l	a0,a1
	addq	#4,a0
.strloop2:
	tst.b	(a0)+
	bne.s	.strloop2
	bra.s	.loop
.found2:pea.l	4(a0)
	bsr	mkc
	move.l	#"  I ",(a4)+
	moveq	#0,d0
	move.w	2(a0),d0
	move.l	d0,-(sp)
	bsr	mkhex6
	pea.l	tcr(pc)
	bsr	mkc
	bra.s	.cont
.end_y_symbol:

; Put in tail (_END & address)
	pea.l	tend(pc)
	bsr	mkc
	move.w	first_sec,-(sp)
	bsr	mkhex4
	pea.l	tcr(pc)
	bsr	mkc
	rts

* File access subroutines..

* INPUT: a1: filename (Can be both space- and null-terminated)
* OUTPUT: d0.l: 0=success
*               -1=failure
SET_FILEPATH:
	movea.l	a1,a2
.floop:	move.b	(a2)+,d0
	beq.s	.pathset
	cmpi.b	#" ",d0
	beq.s	.pathset
	cmpi.b	#"\",d0
	bne.s	.floop

	movea.l	a1,a2
	lea	.pathname_txt,a0
.copyloop:
	move.b	(a2)+,d0
	beq.s	.end_copyloop
	cmpi.b	#" ",d0
	beq.s	.end_copyloop
	move.b	d0,(a0)+
	bra.s	.copyloop
.end_copyloop:	

.backtrack_loop:
	cmpi.b	#"\",-(a0)
	bne.s	.backtrack_loop
	clr.b	(a0)

	cmpi.b	#":",1(a1)
	bne.s	.nodrive
	move.b	(a1),d0
	andi.w	#%11011111,d0
	subi.w	#"A",d0
	bpl.s	.on
	addq	#4,sp
	bra	.error

.on:	pea	.pathname_txt+2

	move.w	d0,-(sp)			* Dsetdrive
	move.w	#$e,-(sp)
	trap	#1
	addq.w	#4,sp
	
	movea.l	(sp)+,a0
.nodrive:

	move.l	a0,-(sp)
	move.w	#$3b,-(sp)
	trap	#1
	addq.w	#6,sp
	tst.l	d0
	bmi.s	.error
.pathset:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

	BSS

.pathname_txt:
	DS.B	256

	TEXT

fsize:	;*fname.L
	movem.l	d1-a6,-(sp)
	lea	56+4(sp),a6
	Fsetdta2	fdta(pc)
	Fsfirst	(a6),#0
	tst.l	d0
	bmi.s	.fin
	move.l	fdta+26(pc),d0
.fin:	movem.l	(sp)+,d1-a6
	rts		;d0=size
fdta:	ds.l	12
	
fload:	;*fname.L,*buff.L
	movem.l	d1-a6,-(sp)
	lea	56+4(sp),a6
	Fopen	(a6),#0
	tst.l	d0
	blt.s	.fin
	move.l	d0,d6
	Fread	d6,#20000000,4(a6)
	move.l	d0,d7
	Fclose	d6
	move.l	d7,d0
.fin:	movem.l	(sp)+,d1-a6
	rts		;d0=size

load:	;*fname.L
	movem.l	d1-d7/a1-a6,-(sp)
	lea	52+4(sp),a6

	move.l	(a6),-(sp)
	bsr	fsize
	addq.w	#4,sp
	tst.l	d0
	bmi.s	.fin
	addq.l	#4,d0
	Malloc	d0
	tst.l	d0
	blt.s	.fin
	move.l	d0,a0
	move.l	a0,-(sp)
	move.l	(a6),-(sp)
	bsr	fload
	addq.w	#8,sp

.fin:	movem.l	(sp)+,d1-d7/a1-a6
	rts		;d0=size	a0=adr

	DATA
	
usage_txt:
	dc.b	"Usage:",13,10
	dc.b	"QDSP_ASM.TTP [n] [l] [w] [oFILE.P56] [pFILE] FILE.ASM",13,10
	dc.b	13,10
	dc.b	"example:",13,10
	dc.b	"l otest.p56 test.asm",13,10
	dc.b	13,10
	dc.b	"n:        Don't create '.P56' output file",13,10
	dc.b	"l:        Make a LOD output file as well",13,10
	dc.b	"oFILE.P56 Define an other name for output file (don't forget the extension)",13,10
	dc.b	"w:        Wait for additional keypress",13,10
	dc.b	0
t_intro:
	dc.b	13,"Quick DSP assembler by G.Audoly. (oct 95)",13,10
	dc.b	"All rights reserved to G.Audoly, A.Settelmeier, and A.John",13,10
	dc.b	"v0.13b: Additions by Pieter van der Meer (2003)",13,10
	dc.b	10,0
presskey_txt
	dc.b	"Press any key to exit.",13,10,0
	EVEN

	dc.w	0
terr:	dc.b	"**** error at line ",0
	EVEN
	dc.w	1
terr_mem:
	dc.b	": NOT ENOUGH MEMORY.",13,10,0
	EVEN
	dc.w	2
terr_equ:
	dc.b	": EQU needs a value.",13,10,0
	EVEN
	dc.w	3
terr_val:
	dc.b	": I can't evaluate expression.",13,10,0
	EVEN
	dc.w	4
terr_range:
	dc.b	": value is out of range.",13,10,0
	EVEN
	dc.w	5
terr_org:
	dc.b	": ORG error.",13,10,0
	EVEN
	dc.w	6
terr_movem:
	dc.b	": movem only moves to/from p: !!",13,10,0
	EVEN
	dc.w	7
terr_op:
	dc.b	": operand error.",13,10,0
	EVEN
	dc.w	8
terr_op_miss:
	dc.b	": operand missing.",13,10,0
	EVEN
	dc.w	9
terr_ins:
	dc.b	": unknown instruction.",13,10,0
	EVEN
	dc.w	10
terr_immed:
	dc.b	": only immediate value allowed.",13,10,0
	EVEN
	dc.w	11
terr_vmem:
	dc.b	": invalid memory space.",13,10,0
	EVEN
	dc.w	12
terr_macroi:
	dc.b	": only 1 recursive macro call allowed.",13,10,0
	EVEN
	dc.w	13
terr_double:
	dc.b	": error about double parallel move.",13,10,0
	EVEN
	dc.w	14
terr_endc_not_expected:
	dc.b	": ENDC/ENDIF not expected.",13,10,0
	EVEN
	dc.w	15
terr_fcreate:
	dc.b	": cannot create binary file ",13,10,0
	EVEN
	dc.w	16
terr_macro_par:
	dc.b	": MACRO parameter number must be between 1 and 9.",13,10,0
	EVEN
	dc.w	17
terr_endm_not_expected:
	dc.b	": ENDM not expected.",13,10,0
	EVEN
	dc.w	18
terr_Nx:
	dc.b	": Nx not conformable.",13,10,0
	EVEN
	dc.w	19
terr_same_r:
	dc.b	": Only one Rx in 0-3 and one in 4-7 allowed.",13,10,0
	EVEN
	dc.w	20
terr_fail:
	dc.b	": user fail error.",13,10,0
	EVEN
	dc.w	21
paraerror_txt:
	dc.b	": parallel instruction not allowed.",13,10,0
	EVEN
	dc.w	22
symboltwice_txt:
	dc.b	": symbol defined twice.",13,10,0
	EVEN
	dc.w	23
garbfollow_txt:
	dc.b	": garbage following instruction.",13,10,0
	EVEN
	dc.w	24
filenotfound_txt:
	dc.b	": file not found.",13,10,0

warn_txt:
	dc.b	"**** warning at line ",0
stallwarning_txt:
	dc.b	": r/n/m register stall.",13,10,0

tprintval:
	dc.b	": USER MESSAGE. value: $"
tprintval0:
	dc.b	"123456.",13,10,0

tcr:
t_res0:	dc.b	13,10,0
t_res1:	dc.b	" lines assembled.",13,10,0
tsame:	dc.b	" code ok.",13,10,0
tscode:	dc.b	" **!** fatal error. (my assembler has a bug. please report it) **!** ",13,10,0
terrors:
	dc.b	" error(s).",13,10,0
twarnings:
	dc.b	" warning(s).",13,10,0
tpass:	dc.b	13,"(pass "
tpass0:	dc.b	"1)",13,10,0

tstart:	dc.b	"_START ",0
tname:	dc.b	" 0000 0000 0000  - QUICK DSP ASSEMBLER V0.13b -",13,10,0
tdata:	dc.b	13,10,"_DATA ",0
tend:	dc.b	"_END ",0
psymbol_txt:
	dc.b	"_SYMBOL P",13,10,0
xsymbol_txt:
	dc.b	"_SYMBOL X",13,10,0
ysymbol_txt:
	dc.b	"_SYMBOL Y",13,10,0

ins0:	dc.b	"enddo",0,$8c
	dc.b	"illegal",0,$5
	dc.b	"nop",0,$0
	dc.b	"reset",0,$84
	dc.b	"rti",0,$4
	dc.b	"rts",0,$c
	dc.b	"stop",0,$87
	dc.b	"swi",0,$6
	dc.b	"wait",0,$86
	dc.b	0

; ins A/B
ins1:	dc.b	"abs",$26
	dc.b	"asl",$32
	dc.b	"asr",$22
	dc.b	"clr",$13
	dc.b	"lsl",$33
	dc.b	"lsr",$23
	dc.b	"neg",$36
	dc.b	"not",$17
	dc.b	"rnd",$11
	dc.b	"rol",$37
	dc.b	"ror",$27
	dc.b	"tst",$03
	dc.l	0

ins2:	dc.b	"adc",0,$21,0	;mode0: x=>0 y=>1
	dc.b	"addl",0,$12,2
	dc.b	"addr",0,$2,2
	dc.b	"add",0,$0,1
	dc.b	"and",0,$46,3
	dc.b	"cmpm",0,$07,4
	dc.b	"cmp",0,$05,4
	dc.b	"eor",0,$43,3
	dc.b	"or",0,$42,3
	dc.b	"sbc",0,$25,0
	dc.b	"subl",0,$16,2
	dc.b	"subr",0,$06,2
	dc.b	"sub",0,$4,1
	dc.b	"tfr",0,$1,4
	dc.b	0

ins3:	dc.b	"macr",0,$83
	dc.b	"mac",0,$82
	dc.b	"mpyr",0,$81
	dc.b	"mpy",0,$80
	dc.b	0

op3:	dc.b	"x0x0",$00
	dc.b	"y0y0",$10
	dc.b	"x0x1",$20
	dc.b	"y0y1",$30
	dc.b	"x0y1",$40
	dc.b	"x0y0",$50
	dc.b	"x1y0",$60
	dc.b	"x1y1",$70
	dc.l	0

opimmed:dc.b	"x0",0,$4
	dc.b	"x1",0,$5
	dc.b	"y0",0,$6
	dc.b	"y1",0,$7
	dc.b	"a0",0,$8
	dc.b	"b0",0,$9
	dc.b	"a2",0,$a
	dc.b	"b2",0,$b
	dc.b	"a1",0,$c
	dc.b	"b1",0,$d
	dc.b	"a",0,$e
	dc.b	"b",0,$f
	dc.b	"r0",0,$10
	dc.b	"r1",0,$11
	dc.b	"r2",0,$12
	dc.b	"r3",0,$13
	dc.b	"r4",0,$14
	dc.b	"r5",0,$15
	dc.b	"r6",0,$16
	dc.b	"r7",0,$17
	dc.b	"n0",0,$18
	dc.b	"n1",0,$19
	dc.b	"n2",0,$1a
	dc.b	"n3",0,$1b
	dc.b	"n4",0,$1c
	dc.b	"n5",0,$1d
	dc.b	"n6",0,$1e
	dc.b	"n7",0,$1f
	dc.b	"m0",0,$20
	dc.b	"m1",0,$21
	dc.b	"m2",0,$22
	dc.b	"m3",0,$23
	dc.b	"m4",0,$24
	dc.b	"m5",0,$25
	dc.b	"m6",0,$26
	dc.b	"m7",0,$27
	dc.b	"sr",0,$39
	dc.b	"omr",0,$3a
	dc.b	"sp",0,$3b
	dc.b	"ssh",0,$3c
	dc.b	"ssl",0,$3d
	dc.b	"la",0,$3e
	dc.b	"lc",0,$3f
	dc.b	0

opctrl:	dc.b	"m0",0,$0
	dc.b	"m1",0,$1
	dc.b	"m2",0,$2
	dc.b	"m3",0,$3
	dc.b	"m4",0,$4
	dc.b	"m5",0,$5
	dc.b	"m6",0,$6
	dc.b	"m7",0,$7
	dc.b	"sr",0,$19
	dc.b	"omr",0,$1a
	dc.b	"sp",0,$1b
	dc.b	"ssh",0,$1c
	dc.b	"ssl",0,$1d
	dc.b	"la",0,$1e
	dc.b	"lc",0,$1f
	dc.b	0

opl:	dc.b	"a10",0,0
	dc.b	"b10",0,1
	dc.b	"ab",0,10
	dc.b	"ba",0,11
	dc.b	"x",0,2
	dc.b	"y",0,3
	dc.b	"a",0,8
	dc.b	"b",0,9
	dc.b	0
	
cc:	dc.b	"cc",0
	dc.b	"hs",0
	dc.b	"ge",1
	dc.b	"ne",2
	dc.b	"pl",3
	dc.b	"nn",4
	dc.b	"ec",5
	dc.b	"lc",6
	dc.b	"gt",7
	dc.b	"cs",8
	dc.b	"lo",8
	dc.b	"lt",9
	dc.b	"eq",10
	dc.b	"mi",11
	dc.b	"nr",12
	dc.b	"es",13
	dc.b	"ls",14
	dc.b	"le",15
	dc.w	0

;p56active_txt:
;	dc.b	"p56 active",$A,$D,0

	EVEN
	
dest0:	dc.l	dest0+3

	BSS
	
text_err:
	ds.l	1
filename_adr:
	ds.l	1
filename_txt:
	ds.b	256
savename_txt:
	ds.b	256

mema6:	ds.l	1
cmp1:	ds.l	1
cmp2:	ds.l	1

dret:	ds.l	1
mem_double:
	ds.l	1

userx_tbl:
	ds.b	2				* Table for pipeline clash checks
usenx_tbl:
	ds.b	2				* Table for pipeline clash checks

m_opt:	ds.b	1
l_opt:	ds.b	1
n_opt:	ds.b	1
w_opt:	ds.b	1
	EVEN

nb_par:	ds.w	1				* nb de parenthäses(+/- ouv/ferm)
afich:	ds.l	1
source:	ds.l	1				* startaddress of current sourcecode
dest:	ds.l	1				* address of destination buffer (P56 data)
source2:ds.l	1				* backup of sourceaddress
dest2:	ds.l	1
errors_adr:
	ds.l	1
struct_adr:
	ds.l	1
pass:	ds.w	1

lbel:	ds.l	80/4
lbel0:	ds.l	80/4
lbl:	ds.l	1
lbl0:	ds.l	1
lbl_nb:	ds.l	1
lbl_pt:	ds.l	1
lbl_pt0:ds.l	1

lodbufadr:
	ds.l	1
mac:	ds.l	1
mac0:	ds.l	1
mac_nb:	ds.l	1
mac_pt:	ds.l	1
mac_pt0:
	ds.l	1
mac_adr:
	ds.l	1
mac_adr2:
	ds.l	1
mac_adr0:
	ds.l	1
mac_mode:
	ds.w	1
mac_def:
	ds.w	1
mac_no:	ds.w	1

dont_asm:
	ds.w	1
adont_asm:
	ds.l	1					* address of stacktop
ldont_asm:
	ds.w	100					* 100 conditions to stack

apc:	ds.l	1					* mem.W|adr.W

mac_par:ds.b	64*10
mac_par2:
	ds.b	64*10

	ds.b	4
line_buff:
	ds.b	300
line_buff0:
	ds.b	300					* to modify it
real_source:
	ds.l	1					* Used for macro's.
left_line:
	ds.l	1

line:	ds.w	1
time:	ds.l	1
nb_err:	ds.w	1	
nb_warn:ds.w	1	
	ds.l	1

sourcefilestack_tbl:
	ds.l	stackentrysize*16			* 16 recursive includes max!
sourcefilestackdepth:
	ds.w	1

	END

;page:
;adr size  ?
;  0    4  next page (0=last one)
;  4 pg_sz datas

;labels:
;
;adr size  ?
;  0    4  next
;  4    n  string
; 4+n   8  value  (abs.L ou dec.L) or (adr.L)

; 6+n   4  next
;...
