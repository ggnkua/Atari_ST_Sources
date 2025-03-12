  	*******************************************************
	*   This is the -The Explorer¿- made 91' by AN COOL   *
	*						      *
	*   This version contains:			      *
	*						      *
	*   THE DEBUGGER                                      *
	*   ------------                                      *
	*						      *
	*-----------------------------------------------------*
	*						      *
	*   a=window start				      *
	*   b=install preakpont				      *
	*   c=copy activated wind. pos. to not activated wind.*
	*   d=initialize exeptions			      *
	*   e=edit data					      *
	*   f=find					      *
	*   g=go to address				      *
	*   h=trace					      *
	*   i=save activated window position		      *
	*   j=trace code whithout entering traps, jsr etc.    *
	*   k=kill all preakpoints			      *
	*   l=load (DMA)				      *
	*   m=music ripper (mad max, cz ,tcb)		      *
	*   n=find next					      *
	*   o=restore the saved value (saved with 'i')	      *
	*   p=find previous				      *
	*   q=monitor activated screen			      *
	*   r=grafix ripper				      *
	*   s=save (DMA)				      *
	*   t=enter grafix ripper at the address *w1 is       *
	*   u=set register				      *
	*   v=toggle super pc on/off			      *
	*   w=set DMA					      *
	*   x=use go until code #			      *
	*   y=enter grafix ripper at the address *w2 is       *
	*   z=go until					      *

	*   tab=change activated window			      *
	*   esc=escape current command (restore rez)	      *
	*   help=enter info screen			      *
	*   +=save data with information		      *
	*   <=trace (jumps to te command and puts a illegal   *
	*   after					      *
	*   1=set VBI at address (dozent use $70)	      *
	*   2=fill					      *
	*   3=copy					      *
	*   4=set variable 1 at address			      *
	*   5=set variable 2 at address			      *
	*   6=set grabber screen at address		      *
	*   7=set spectrum palette at address		      *
	*   8=skip command				      *
	*   9=uppdate activated window			      *
	*   0=set I/O data                                    *

	*   f1=sound chan 1 2 3 off			      *
	*   f2=toggel font				      *
	*   f3=windw slave (the not activated *w follows)     *
	*   f4=restore the eplorer pallete		      *
	*   f5=toggle 50/60 Hz				      *
	*   f6=Spectrum 512 mode on/off			      *
	*   f7=Move the explorer to address		      *
	*   f8=Sample editor				      *
	*   f9=Magnify *w2				      *
	*   f10=Trap illegal memory			      *

	*   =*w1 sub. 2 bytes. sub. 4 bytes *w2	      *
	*   =*w1 down one instruct. *w2 add 4 bytes 	      *
	*   =*w1 subtract 2 bytes *w2 1 byte                 *
	*   =*w1 add 2 bytes *w2 1 byte		      *
	*						      *
	*-----------------------------------------------------*
	*						      *
	*   THE RIPPER                                        *
	*   ----------                                        *
	*						      *
	*   1=turn bitplane 1 on/off			      *
	*   2=turn bitplane 2 on/off			      *
	*   3=turn bitplane 3 on/off			      *
	*   4=turn bitplane 4 on/off			      *
	*   5=add byte grapix to scanline		      *
	*   6=sub byte grapix to scanline		      *
	*-----------------------------------------------------*


	* settings and flags


ver	equ	"0.28"	;version no.
test	equ	0	;1=smart_find 0=$300000 (4 meg)
cart	equ	0	;1=cart on 0=internal test
picc	equ	0	;1=pic. on 0=pic. off
	
;	opt	o+

topp	macro
		;--------------------
 	dc.b	"** -THE EXPLORER- v."
	dc.l	ver
		;--------------------------------------------------------
	dc.b	" Made by Anders Nilsson 1990-1992 for Seabear Studios **"
	endm

	ifne	cart=1
	org	$fa0000
	dc.l	$fa52235f
	endc

	***********************************************************
	***********************************************************
	* code code code code code code code  code code code code *
	***********************************************************
	***********************************************************

x:
	jmp	main
	jmp	otto_run
otto_run:
	*move.l	a1,a6
	*move.l	a0,a7
	lea	$300000,a7
	move.l	#-1,a6

	lea	$fc(a7),a7
	lea	32008(a7),a6
	move.l	a7,126(a6)
	sub.l	#$80,126(a6)
	lea	66(a6),a0
	moveq	#14,d0
.loop:
	clr.l	(a0)+
	dbra	d0,.loop
	bra	explorer_start2
code:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	move.l	d0,a7
	addq.l	#1,d1
	addq.l	#1,d2
	addq.l	#1,d3
	addq.l	#1,d4
	addq.l	#1,d5
	addq.l	#1,d6
	addq.l	#1,d7
	addq.l	#1,a0
	addq.l	#1,a1
	addq.l	#1,a2
	addq.l	#1,a3
	addq.l	#1,a4
	addq.l	#1,a5
	addq.l	#1,a6
	addq.l	#1,a7
	move.l	a7,usp
num	set	0
	rept	255
	dc.b	num
num	set	num+1
	endr
	even

***************************************************************
****************** TA BORT!!!!!!! *****************************
***************************************************************

init_resse:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,resolution

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,phys_base

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,log_base

	lea	$fffa01,a0
	lea	save_mfp,a1
	moveq	#15,d0
save_mfp_loop:
	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,save_mfp_loop

	lea	$28,a0
	lea	save_tex,a1
	move.l	#$200-1,d0
save_tex_loop:
	move.l	(a0)+,(a1)+
	dbra	d0,save_tex_loop

	move.l	#retvars,$42a
	move.l	#$31415926,$426
	rts
retvars:
	lea	nullstk,a7

	move.w	#$700,$ff8240

	lea	$28,a0
	lea	save_tex,a1
	move.l	#$200-1,d0
ret_tex_loop:
	move.l	(a1)+,(a0)+
	dbra	d0,ret_tex_loop

	move.w	#$030,$ff8240

	lea	$fffa01,a0
	lea	save_mfp,a1
	moveq	#15,d0
ret_mfp:
	move.b	(a1)+,(a0)
	addq.l	#2,a0
	dbra	d0,ret_mfp
	move.w	#$770,$ff8240

	move.l	#retvars,$42a
	move.l	#$31415926,$426

	move.w	#$070,$ff8240
	move.b	#2,$ff820a
	move.w	#$007,$ff8240

	move.w	#$770,$ff8240

	move.w	resolution,-(sp)
	move.l	phys_base,-(sp)
	move.l	log_base,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#$707,$ff8240

	move.l	#$707ffff,$ffff8800.w

	move.w	#$777,$ff8240

	dc.w	$a000

	move.w	#$444,$ff8240

	move.w	#1,d0
	andi.w	#3,d0
	lea	skumtab,a1
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a1,d0.w),(a0)
	move.b	#3,$fffffc04.w
	move.b	#$95,$fffffc04.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
	move.w	#$c8,d0
tima	nop
	dbra	d0,tima

	move.w	#$000,$ff8240
	move.w	#$666,$ff8242
	move.w	#$666,$ff8244
	move.w	#$666,$ff8246
	move.w	#$666,$ff8248

	move.w	#$777,$ff8240
	move.w	#$2300,sr
	move.w	#$000,$ff8240
	move.w	#$666,$ff8242
	move.w	#$666,$ff8244
	move.w	#$666,$ff8246
	move.w	#$666,$ff8248

	move.w	#0,$ff8900

	clr.w	-(sp)
	trap	#1
save_stk:
	dc.l	0

skumtab:
	dc.w	$0004,$00a0
	dc.w	$0002,$00a0
	dc.w	$0001,$0050
	dc.w	$0001,$0050
	dc.w	$8001,$1214

save_mfp:
	ds.b	24
	even
resolution:
	dc.w	0
phys_base:
	dc.l	0
log_base:
	dc.l	0
save_tex:
	ds.l	$300
	ds.l	100
nullstk:

***************************************************************
***************************************************************
***************************************************************





decode:	
	moveq	#0,d0
	move.l	d0,(a6)
	move.l	d0,4(a6)

	cmp.w	#0,546(a6)
	beq.s	no_trap
	move.l	sp,240(a6)
	jsr	test_berr(pc)
	tst.l	d0
	bmi.s	super_super_mega_berr
no_trap:

	jsr	test_operation(pc)
	jsr	(a2)	;hoppa till fack
	tst.l	d0
	bmi.s	word_out

	jsr	do_the_f_berr(pc)

	move.b	#" ",(a0)+
	moveq	#0,d0
	add.w	2(a6),d0
	add.w	4(a6),d0
	addq.w	#2,d0
	move.w	d0,6(a6)
	rts
do_the_f_berr:
	cmp.w	#0,546(a6)
	beq.s	.no_trap2
	jsr	no_more_berr(pc)
.no_trap2:
	rts

super_super_mega_berr:
	move.b	#"d",(a0)+
	move.b	#"c",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.b	#"$",(a0)+
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	move.w	#2,6(a6)
	jsr	do_the_f_berr(pc)
	rts
super_super_mega_berr2:
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	move.w	#2,6(a6)
	jsr	do_the_f_berr(pc)
	rts
word_out:
	move.b	#"d",(a0)+
	move.b	#"c",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.b	#"$",(a0)+
	move.w	(a1),d1
	jsr	proc_word(pc)
	move.w	#2,6(a6)
	jsr	do_the_f_berr(pc)
	rts
test_operation:
	move.b	(a1),d0
	and.w	#$00f0,d0
	lsr.b	#2,d0
	lea	operation_map(pc),a2
	move.l	(a2,d0.w),a2
	rts
test_berr:
	move.l	$8.w,244(a6)
	move.l	#mega_super_berr,$8.w
	move.w	(a1),d0
	move.l	#other_berr,$8.w
	rts
mega_super_berr:
	moveq	#-1,d0
	add.l	#14,sp
	move.l	244(a6),$8.w
	rts
other_berr:
	move.l	240(a6),sp
	move.l	244(a6),$8.w
	bra	super_super_mega_berr2
no_more_berr:
	move.l	244(a6),$8.w
	rts
****************************************************
* bit manul grejs **********************************
****************************************************
dynamic_bit:
	move.b	#"b",(a0)+
	jsr	get_type(pc)
	jsr	tab(pc)
	jsr	get_data_reg(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts	
static_bit:
	move.b	#"b",(a0)+
	jsr	get_type(pc)
	jsr	tab(pc)
	move.b	#"#",(a0)+
	jsr	byte(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts	
moveperal:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#"p",(a0)+
	move.b	#".",(a0)+
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	cmp.w	#%0000000100000000,d0
	beq.s	wordmtod
	cmp.w	#%0000000101000000,d0
	beq.s	longmtod
	cmp.w	#%0000000110000000,d0
	beq.s	worddtom
	cmp.w	#%0000000111000000,d0
	beq.s	longdtom
	move.b	#"?",(a0)+
	jsr	tab(pc)
	move.b	#"?",(a0)+
	move.b	#",",(a0)+
	move.b	#"?",(a0)+
	rts
wordmtod:
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.b	#"$",(a0)+
	jsr	word(pc)
	jsr	addr_reg_indir(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
longmtod:
	move.b	#"l",(a0)+
	jsr	tab(pc)
	move.b	#"$",(a0)+
	jsr	word(pc)
	jsr	addr_reg_indir(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
worddtom:
	move.b	#"w",(a0)+
	jsr	tab(pc)
	jsr	get_data_reg(pc)
	move.b	#",",(a0)+
	move.b	#"$",(a0)+
	jsr	word(pc)
	jsr	addr_reg_indir(pc)
	rts
longdtom:
	move.b	#"l",(a0)+
	jsr	tab(pc)
	jsr	get_data_reg(pc)
	move.b	#",",(a0)+
	move.b	#"$",(a0)+
	jsr	word(pc)
	jsr	addr_reg_indir(pc)
	rts
or_imed:
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize(pc)
	jsr	tab(pc)
	jsr	get_imediate(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
or_imed_ccr:
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	move.b	#"b",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	byte(pc)
	move.b	#",",(a0)+
	move.b	#"c",(a0)+
	move.b	#"c",(a0)+
	move.b	#"r",(a0)+
	rts
or_imed_sr:
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	word(pc)
	move.b	#",",(a0)+
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	rts
and_imed:
	move.b	#"a",(a0)+
	move.b	#"n",(a0)+
	move.b	#"d",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize(pc)
	jsr	tab(pc)
	jsr	get_imediate(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
and_imed_ccr:
	move.b	#"a",(a0)+
	move.b	#"n",(a0)+
	move.b	#"d",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	move.b	#"b",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	byte(pc)
	move.b	#",",(a0)+
	move.b	#"c",(a0)+
	move.b	#"c",(a0)+
	move.b	#"r",(a0)+
	rts
and_imed_sr:
	move.b	#"a",(a0)+
	move.b	#"n",(a0)+
	move.b	#"d",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	word(pc)
	move.b	#",",(a0)+
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	rts
sub_imed:
	move.b	#"s",(a0)+
	move.b	#"u",(a0)+
	move.b	#"b",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize(pc)
	jsr	tab(pc)
	jsr	get_imediate(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
add_imed:
	move.b	#"a",(a0)+
	move.b	#"d",(a0)+
	move.b	#"d",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize(pc)
	jsr	tab(pc)
	jsr	get_imediate(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
eor_imed:
	move.b	#"e",(a0)+
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize(pc)
	jsr	tab(pc)
	jsr	get_imediate(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
eor_imed_ccr:
	move.b	#"e",(a0)+
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	move.b	#"b",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	byte(pc)
	move.b	#",",(a0)+
	move.b	#"c",(a0)+
	move.b	#"c",(a0)+
	move.b	#"r",(a0)+
	rts
eor_imed_sr:
	move.b	#"e",(a0)+
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	move.b	#"b",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	word(pc)
	move.b	#",",(a0)+
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	rts
tab:
	lea	372+9(a6),a2
tab2:
	move.b	#" ",(a0)+
	cmp.l	a2,a0
	ble.s	tab2
	rts
cmp_imed:
	move.b	#"c",(a0)+
	move.b	#"m",(a0)+
	move.b	#"p",(a0)+
	move.b	#"i",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize(pc)
	jsr	tab(pc)
	jsr	get_imediate(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
get_type:
	move.w	(a1),d0
	and.w	#%0000000011000000,d0
	lsr.w	#6,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	types(pc),a2
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	move.b	2(a2,d0.w),(a0)+
	rts
***************************************************
* sm† rutiner som anv„nds lite d† o d† ************
***************************************************
getdire:
	move.w	(a1),d0
	and.w	#%0000000100000000,d0
	cmp.w	#0,d0
	beq.s	right
	move.b	#"l",(a0)+
	rts
right:
	move.b	#"r",(a0)+
	rts
get_shift_type2:
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#%0000000000011000,d0
	lsr.w	#3,d0
	bra.s	oops_sikken_lamer_du_„r
get_shift_type:
	moveq	#0,d0
	move.w	(a1),d0
	and.w	#%0000011000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
oops_sikken_lamer_du_„r:
	add.w	d0,d0
	add.w	d0,d0
	lea	shift_type(pc),a2
	add.l	d0,a2
	moveq	#3,d1
.loop:
	move.b	(a2)+,d2
	cmp.b	#$20,d2
	beq.s	no_more_gruff
	move.b	d2,(a0)+
	dbra	d1,.loop
no_more_gruff:
	rts
data_registers:
	jsr	data_reg(pc)
	move.b	#",",(a0)+
	jsr	data_reg2(pc)
	rts	
this_is_addreggs
	jsr	addr_reg_indir_pred(pc)
	move.b	#",",(a0)+
	jsr	addr_reg_indir_pred2(pc)
	rts	
get_length:
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	cmp.w	#%0000000011000000,d0
	beq.s	word_bj„ffs
	move.b	#"l",(a0)+
	move.w	#2,(a6)
	rts
word_bj„ffs:
	move.b	#"w",(a0)+
	move.w	#1,(a6)
	rts
get_length_type:
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	lsr.w	#6,d0
	lea	logic_tab(pc),a2
	move.b	(a2,d0.w),(a0)+
	rts
get_dmtype:
	move.w	(a1),d0
	and.w	#%0000000100000000,d0
	cmp.w	#0,d0
	beq.s	unsign
	move.b	#"s",(a0)+
	rts
unsign:
	move.b	#"u",(a0)+
	rts
get_condition:
	move.w	(a1),d0
	and.w	#%0000111100000000,d0
	lsr.w	#8,d0
	add.w	d0,d0
	lea	cond_tab(pc),a2
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	rts
get_quick_shit:
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	cmp.w	#0,d0
	bne.s	no_spezzare
	move.w	#8,d0
no_spezzare:
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	lea	hex_tab(pc),a2
	move.b	(a2,d0.w),(a0)+
	rts
get_trap_no:
	move.w	(a1),d0
	and.w	#$000f,d0
	lea	hex_tab(pc),a2
	move.b	(a2,d0.w),(a0)+
	rts
get_zize4:
	move.w	(a1),d0
	and.w	#%0000000001000000,d0
	cmp.w	#%0000000001000000,d0
	beq.s	longtrans
	move.b	#"w",(a0)+
	rts
longtrans:
	move.b	#"l",(a0)+
	rts
get_zize5:
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	cmp.w	#%0000000100000000,d0
	beq.s	yes_byt
	cmp.w	#%0000000101000000,d0
	beq.s	yes_wor
	move.b	#"l",(a0)+
	rts
yes_byt:
	move.b	#"b",(a0)+
	rts
yes_wor:
	move.b	#"w",(a0)+
	rts
get_registers:
	move.w	2(a1),d1
	moveq	#0,d3
	moveq	#15,d0
.loop:
	move.w	d1,d2
	and.w	#$0001,d2
	add.w	d3,d3
	or.w	d2,d3
	lsr.w	#1,d1
	dbra	d0,.loop
	move.w	d3,d1
jupp:
	lea	reg_tab(pc),a2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#15,d0
loup:
	move.w	d1,d2
	lsr.w	d0,d2
	and.w	#1,d2
	cmp.w	#1,d2
	beq.s	yes_found
	tst.w	d3
	beq.s	gullan2
	cmp.w	#1,d5
	ble.s	gullan2
	move.b	#"-",(a0)+
	move.b	-2(a2),(a0)+
	move.b	-1(a2),(a0)+
gullan2:
	moveq	#0,d3
	moveq	#0,d5
ghost_is_near_the_final_damage:
	addq.l	#2,a2
	dbra	d0,loup
	rts
yes_found:
	addq.w	#1,d5
	tst.w	d3
	bmi.s	no_new_ghost
	moveq	#-1,d3
	tst.w	d4
	beq.s	gullan
	move.b	#"\",(a0)+
gullan:
	moveq	#-1,d4
	move.b	(a2),(a0)+
	move.b	1(a2),(a0)+
no_new_ghost:
	bra.s	ghost_is_near_the_final_damage
get_data_reg:
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lea	reg_tab(pc),a2
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	rts
get_addr_reg:
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lea	reg_tab2(pc),a2
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	rts
get_zize:
	move.w	(a1),d0
	and.w	#%0000000011000000,d0
	lsr.w	#6,d0
	lea	size(pc),a2
	move.b	(a2,d0.w),(a0)+
	move.w	d0,(a6)
	lea	lame_tab(pc),a2
	add.w	d0,d0
	move.w	(a2,d0.w),2(a6)
	rts
************************************************
* When there are no source and dest just dest **
************************************************
get_zize2:
	move.w	(a1),d0
	and.w	#%0000000011000000,d0
	lsr.w	#6,d0
	lea	size(pc),a2
	move.b	(a2,d0.w),(a0)+
	rts
get_zize3:
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	cmp.w	#%0000000010000000,d0
	beq.s	extw
	move.b	#"l",(a0)+
	rts
extw:
	move.b	#"w",(a0)+
	rts
************************************************
* olika addreserings modes *********************
************************************************
get_destmode:
	move.w	(a1),d0
	and.w	#%0000000000111000,d0
	lsr.w	#3,d0
	cmp.w	#%0000000000000000,d0
	beq	data_reg
	cmp.w	#%0000000000000001,d0
	beq	addr_reg
	cmp.w	#%0000000000000010,d0
	beq	addr_reg_indir
	cmp.w	#%0000000000000011,d0
	beq	addr_reg_indir_post
	cmp.w	#%0000000000000100,d0
	beq	addr_reg_indir_pred
	cmp.w	#%0000000000000101,d0
	beq	addr_reg_indir_displace
	cmp.w	#%0000000000000110,d0
	beq	addr_reg_indir_index
	move.w	(a1),d0
	and.w	#%0000000000111111,d0
	cmp.w	#%0000000000111000,d0
	beq	word_shit
	cmp.w	#%0000000000111001,d0
	beq	long_shit
	cmp.w	#%0000000000111010,d0
	beq	pc_offs_shit
	cmp.w	#%0000000000111011,d0
	beq	pc_offs_shit_index
	cmp.w	#%0000000000111100,d0
	beq	get_imediate
	move.b	#"?",(a0)+
	rts
get_destmode2:
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	lsr.w	#6,d0
	cmp.w	#%0000000000000000,d0
	beq.s	data_reg2
	cmp.w	#%0000000000000001,d0
	beq	addr_reg2
	cmp.w	#%0000000000000010,d0
	beq	addr_reg_indir2
	cmp.w	#%0000000000000011,d0
	beq	addr_reg_indir_post2
	cmp.w	#%0000000000000100,d0
	beq	addr_reg_indir_pred2
	cmp.w	#%0000000000000101,d0
	beq	addr_reg_indir_displace2
	cmp.w	#%0000000000000110,d0
	beq	addr_reg_indir_index2
	move.w	(a1),d0
	and.w	#%0000111111000000,d0
	cmp.w	#%0000000111000000,d0
	beq	word_shit2
	cmp.w	#%0000001111000000,d0
	beq	long_shit2
	move.b	#"?",(a0)+
	rts
data_reg:
	add.w	#0,2(a6)
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"d",(a0)+
	move.b	(a2,d0.w),(a0)+
	rts
data_reg2:
	move.w	#0,4(a6)
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"d",(a0)+
	move.b	(a2,d0.w),(a0)+
	rts
addr_reg:
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	rts
addr_reg2:
	move.w	#0,4(a6)
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	rts
addr_reg_indir:
	add.w	#0,2(a6)
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir2:
	move.w	#0,4(a6)
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir_post:
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	move.b	#"+",(a0)+
	rts
addr_reg_indir_post2:
	move.w	#0,4(a6)
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	move.b	#"+",(a0)+
	rts
addr_reg_indir_pred:
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"-",(a0)+
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir_pred2:
	move.w	#0,4(a6)
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"-",(a0)+
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir_displace:
	move.b	#"$",(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	addq.w	#2,2(a6)
	jsr	proc_word(pc)
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	rts
pc_offs_shit:
	move.b	#"$",(a0)+
	moveq	#0,d0
	moveq	#0,d1
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	addq.w	#2,2(a6)
	ext.l	d1
	add.l	a1,d1
	add.l	d0,d1
	addq.l	#2,d1
	jsr	proc_long(pc)
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"p",(a0)+
	move.b	#"c",(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir_displace2:
	move.w	#2,4(a6)
	move.b	#"$",(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	jsr	proc_word(pc)
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"(",(a0)+
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir_index:
	move.b	#"$",(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	jsr	proc_byte(pc)
	move.b	#"(",(a0)+
	move.w	(a1),d0
	and.w	#%0000000000000111,d0
	lea	hex_tab(pc),a2
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#",",(a0)+
	lea	reg_tab(pc),a2
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	add.w	d0,d0
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d0
	addq.w	#2,2(a6)
	and.w	#$0f00,d0
	cmp.w	#0,d0
	beq	word_siz
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	move.b	#")",(a0)+
	rts
addr_reg_indir_index2:
	move.w	#2,4(a6)
	move.b	#"$",(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	jsr	proc_byte(pc)
	move.b	#"(",(a0)+
	move.w	(a1),d0
	and.w	#%0000111000000000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	lea	hex_tab(pc),a2
	move.b	#"a",(a0)+
	move.b	(a2,d0.w),(a0)+
	move.b	#",",(a0)+
	lea	reg_tab(pc),a2
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	add.w	d0,d0
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d0
	and.w	#$0f00,d0
	cmp.w	#0,d0
	beq.s	word_siz
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	move.b	#")",(a0)+
	rts
word_siz:
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	move.b	#")",(a0)+
	rts
pc_offs_shit_index:
	move.b	#"$",(a0)+
	moveq	#0,d0
	moveq	#0,d1
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	ext.w	d1
	ext.l	d1
	add.l	a1,d1
	add.l	d0,d1
	addq.l	#2,d1
	jsr	proc_long(pc)
	move.b	#"(",(a0)+
	move.b	#"p",(a0)+
	move.b	#"c",(a0)+
	move.b	#",",(a0)+
	lea	reg_tab(pc),a2
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	add.w	d0,d0
	move.b	(a2,d0.w),(a0)+
	move.b	1(a2,d0.w),(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d0
	addq.w	#2,2(a6)
	and.w	#$0f00,d0
	cmp.w	#0,d0
	beq.s	word_siz
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	move.b	#")",(a0)+
	rts
word_shit:
	move.b	#"$",(a0)+
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	addq.w	#2,2(a6)
	tst.w	d1
	bpl.s	no_extend
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
no_extend:
	jsr	proc_word(pc)
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	rts
word_shit2:
	move.b	#"$",(a0)+
	move.w	#2,4(a6)
	move.w	2(a6),d0
	move.w	2(a1,d0.w),d1
	tst.w	d1
	bpl.s	no_extend2
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
no_extend2:
	jsr	proc_word(pc)
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	rts
long_shit:
	move.b	#"$",(a0)+
	move.w	2(a6),d0
	move.l	2(a1,d0.w),d1
	addq.w	#4,2(a6)
	jsr	proc_long(pc)
	rts
long_shit2:
	move.b	#"$",(a0)+
	move.w	#4,4(a6)
	move.w	2(a6),d0
	move.l	2(a1,d0.w),d1
	jsr	proc_long(pc)
	rts
get_imediate:
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	cmp.w	#2,(a6)
	beq.s	long
	cmp.w	#1,(a6)
	beq.s	word
	cmp.w	#0,(a6)
	beq.s	byte
	move.b	#"?",(a0)+
	rts
long:
	move.l	2(a1),d1
	jsr	proc_long(pc)
	move.w	#4,2(a6)
	rts
word:
	move.w	2(a1),d1
	jsr	proc_word(pc)
	move.w	#2,2(a6)
	rts
byte:
	move.w	2(a1),d1
	jsr	proc_byte(pc)
	move.w	#2,2(a6)
	rts
proc_long:
	lea	hex_tab(pc),a2
	moveq	#7,d0
.loop:
	move.l	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.l	d3,d2
	and.l	#$0000000f,d2
	cmp.l	#0,d2
	bne.s	foundl
	dbra	d0,.loop
	move.b	#"0",(a0)+
	bra	no_num
foundl:
.loop:
	move.l	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.l	d3,d2
	and.w	#$000f,d2
	move.b	(a2,d2.w),(a0)+
	dbra	d0,.loop
	rts
real_long:
	lea	hex_tab(pc),a2
	moveq	#7,d0
.loop:
	move.l	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.l	d3,d2
	and.w	#$000f,d2
	move.b	(a2,d2.w),(a0)+
	dbra	d0,.loop
	rts
real_word:
	lea	hex_tab(pc),a2
	moveq	#3,d0
.loop:
	move.l	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.l	d3,d2
	and.w	#$000f,d2
	move.b	(a2,d2.w),(a0)+
	dbra	d0,.loop
	rts
real_byte:
	lea	hex_tab(pc),a2
	moveq	#1,d0
.loop:
	move.l	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.l	d3,d2
	and.w	#$000f,d2
	move.b	(a2,d2.w),(a0)+
	dbra	d0,.loop
	rts
proc_word:
	lea	hex_tab(pc),a2
	moveq	#3,d0
.loop:
	move.w	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.w	d3,d2
	and.w	#$000f,d2
	cmp.w	#0,d2
	bne.s	foundw
	dbra	d0,.loop
	move.b	#"0",(a0)+
	bra.s	no_num
foundw:
.loop:
	move.w	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.w	d3,d2
	and.w	#$000f,d2
	move.b	(a2,d2.w),(a0)+
	dbra	d0,.loop
	rts
proc_byte:
	lea	hex_tab(pc),a2
	moveq	#1,d0
.loop:
	move.w	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.w	d3,d2
	and.w	#$000f,d2
	cmp.w	#0,d2
	bne.s	foundb
	dbra	d0,.loop
	move.b	#"0",(a0)+
	bra.s	no_num
foundb:
.loop:
	move.w	d1,d2
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,d3
	lsr.w	d3,d2
	and.w	#$000f,d2
	move.b	(a2,d2.w),(a0)+
	dbra	d0,.loop
no_num:
	rts
*********************************************************
* olika k†d typer ***************************************
*********************************************************
bit_manul:
	move.w	(a1),d0
	cmp.w	#%0000000000111100,d0
	beq	or_imed_ccr
	cmp.w	#%0000000001111100,d0
	beq	or_imed_sr
	and.w	#%1111111100000000,d0
	cmp.w	#0,d0
	beq	or_imed
	move.w	(a1),d0
	cmp.w	#%0000001000111100,d0
	beq	and_imed_ccr
	cmp.w	#%0000001001111100,d0
	beq	and_imed_sr
	and.w	#%1111111100000000,d0
	cmp.w	#%0000001000000000,d0
	beq	and_imed
	cmp.w	#%0000010000000000,d0
	beq	sub_imed
	cmp.w	#%0000011000000000,d0
	beq	add_imed
	move.w	(a1),d0
	cmp.w	#%0000101000111100,d0
	beq	eor_imed_ccr
	cmp.w	#%0000101001111100,d0
	beq	eor_imed_sr
	and.w	#%1111111100000000,d0
	cmp.w	#%0000101000000000,d0
	beq	eor_imed
	cmp.w	#%0000110000000000,d0
	beq	cmp_imed
	cmp.w	#%0000100000000000,d0
	beq	static_bit
	move.w	(a1),d0
	and.w	#%1111000000111000,d0
	cmp.w	#%0000000000001000,d0
	beq	moveperal
	move.w	(a1),d0
	and.w	#%1111000100000000,d0
	cmp.w	#%0000000100000000,d0
	beq	dynamic_bit
	moveq	#-1,d0
	rts
moveb:
	move.w	#0,(a6)
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"b",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_destmode2(pc)
	rts
movel:
	move.w	#2,(a6)
	move.w	(a1),d0
	and.w	#%1111000111000000,d0
	cmp.w	#%0010000001000000,d0
	beq.s	moveaddress
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_destmode2(pc)
	rts
moveaddress:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#"a",(a0)+
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_addr_reg(pc)
	rts
movew:
	move.w	#1,(a6)
	move.w	(a1),d0
	and.w	#%1111000111000000,d0
	cmp.w	#%0011000001000000,d0
	beq.s	moveaddressw
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_destmode2(pc)
	rts
moveaddressw:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#"a",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_addr_reg(pc)
	rts
miscellaneous:
	move.w	(a1),d0
	cmp.w	#%0100101011111100,d0
	beq	codillegal
	cmp.w	#%0100111001110000,d0
	beq	codreset
	cmp.w	#%0100111001110001,d0
	beq	codnop
	cmp.w	#%0100111001110010,d0
	beq	codstop
	cmp.w	#%0100111001110011,d0
	beq	codrte
	cmp.w	#%0100111001110101,d0
	beq	codrts
	cmp.w	#%0100111001110110,d0
	beq	codtrapv
	cmp.w	#%0100111001110111,d0
	beq	codrtr
	move.w	(a1),d0
	and.w	#%1111111111111000,d0
	cmp.w	#%0100100001000000,d0
	beq	codswap
	cmp.w	#%0100111001010000,d0
	beq	codlink
	cmp.w	#%0100111001011000,d0
	beq	codunlk
	cmp.w	#%0100111001100000,d0
	beq	codmovtousp
	cmp.w	#%0100111001101000,d0
	beq	codmovfromusp
	move.w	(a1),d0
	and.w	#%1111111111000000,d0
	cmp.w	#%0100000011000000,d0
	beq	codmovfromsr
	cmp.w	#%0100010011000000,d0
	beq	codmovtoccr
	cmp.w	#%0100011011000000,d0
	beq	codmovtosr
	cmp.w	#%0100100001000000,d0
	beq	codpea
	cmp.w	#%0100100000000000,d0
	beq	codnbcd
	cmp.w	#%0100101011000000,d0
	beq	codtas
	cmp.w	#%0100111010000000,d0
	beq	codjsr
	cmp.w	#%0100111011000000,d0
	beq	codjmp
	move.w	(a1),d0
	and.w	#%1111111100000000,d0
	cmp.w	#%0100000000000000,d0
	beq.s	codnegx
	cmp.w	#%0100001000000000,d0
	beq	codclr
	cmp.w	#%0100010000000000,d0
	beq	codneg
	cmp.w	#%0100011000000000,d0
	beq	codnot
	cmp.w	#%0100101000000000,d0
	beq	codtst
	move.w	(a1),d0
	and.w	#%1111000111000000,d0
	cmp.w	#%0100000111000000,d0
	beq	codlea
	cmp.w	#%0100000110000000,d0
	beq	codchk
	move.w	(a1),d0
	and.w	#%1111111000111000,d0
	cmp.w	#%0100100000000000,d0
	beq	codext
	move.w	(a1),d0
	and.w	#%1111111110000000,d0
	cmp.w	#%0100100010000000,d0
	beq	codmomrea
	cmp.w	#%0100110010000000,d0
	beq	codmomrear
	move.w	(a1),d0
	and.w	#%1111111111110000,d0
	cmp.w	#%0100111001000000,d0
	beq	codtrap
	moveq	#-1,d0
	rts
codnegx:
	move.b	#"n",(a0)+
	move.b	#"e",(a0)+
	move.b	#"g",(a0)+
	move.b	#"x",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codmovfromsr:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
codchk:
	move.b	#"c",(a0)+
	move.b	#"h",(a0)+
	move.b	#"k",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codlea:
	move.b	#"l",(a0)+
	move.b	#"e",(a0)+
	move.b	#"a",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_addr_reg(pc)
	rts
codclr:
	move.b	#"c",(a0)+
	move.b	#"l",(a0)+
	move.b	#"r",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codneg:
	move.b	#"n",(a0)+
	move.b	#"e",(a0)+
	move.b	#"g",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codmovtoccr:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"b",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	move.b	#"c",(a0)+
	move.b	#"c",(a0)+
	move.b	#"r",(a0)+
	rts
codnot:
	move.b	#"n",(a0)+
	move.b	#"o",(a0)+
	move.b	#"t",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codmovtosr:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"w",(a0)+
	jsr	tab(pc)
	move.w	#1,(a6)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	rts
codnbcd:
	move.b	#"n",(a0)+
	move.b	#"b",(a0)+
	move.b	#"c",(a0)+
	move.b	#"d",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codswap:
	move.b	#"s",(a0)+
	move.b	#"w",(a0)+
	move.b	#"a",(a0)+
	move.b	#"p",(a0)+
	jsr	tab(pc)
	jsr	data_reg(pc)
	rts
codpea:
	move.b	#"p",(a0)+
	move.b	#"e",(a0)+
	move.b	#"a",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codext:
	move.b	#"e",(a0)+
	move.b	#"x",(a0)+
	move.b	#"t",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize3(pc)
	jsr	tab(pc)
	jsr	data_reg(pc)
	rts
codmomrea:
	move.w	#1,(a6)
	move.w	#2,2(a6)
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#"m",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize4(pc)
	jsr	tab(pc)
	jsr	get_registers(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
codtst:
	move.b	#"t",(a0)+
	move.b	#"s",(a0)+
	move.b	#"t",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codtas:
	move.b	#"t",(a0)+
	move.b	#"a",(a0)+
	move.b	#"s",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codillegal:
	move.b	#"i",(a0)+
	move.b	#"l",(a0)+
	move.b	#"l",(a0)+
	move.b	#"e",(a0)+
	move.b	#"g",(a0)+
	move.b	#"a",(a0)+
	move.b	#"l",(a0)+
	rts
codmomrear:
	move.w	#1,(a6)
	move.w	#2,2(a6)
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#"m",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize4(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_registers(pc)
	rts
codtrap:
	move.b	#"t",(a0)+
	move.b	#"r",(a0)+
	move.b	#"a",(a0)+
	move.b	#"p",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	jsr	get_trap_no(pc)
	rts
codlink:
	move.b	#"l",(a0)+
	move.b	#"i",(a0)+
	move.b	#"n",(a0)+
	move.b	#"k",(a0)+
	jsr	tab(pc)
	jsr	addr_reg(pc)
	move.b	#",",(a0)+
	move.w	#1,(a6)
	jsr	get_imediate(pc)
	rts
codunlk:
	move.b	#"u",(a0)+
	move.b	#"n",(a0)+
	move.b	#"l",(a0)+
	move.b	#"k",(a0)+
	jsr	tab(pc)
	jsr	addr_reg(pc)
	rts
codmovfromusp:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	jsr	tab(pc)
	move.b	#"u",(a0)+
	move.b	#"s",(a0)+
	move.b	#"p",(a0)+
	move.b	#",",(a0)+
	jsr	addr_reg(pc)
	rts
codmovtousp:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#".",(a0)+
	move.b	#"l",(a0)+
	jsr	tab(pc)
	jsr	addr_reg(pc)
	move.b	#",",(a0)+
	move.b	#"u",(a0)+
	move.b	#"s",(a0)+
	move.b	#"p",(a0)+
	rts
codreset:
	move.b	#"r",(a0)+
	move.b	#"e",(a0)+
	move.b	#"s",(a0)+
	move.b	#"e",(a0)+
	move.b	#"t",(a0)+
	rts
codnop:
	move.b	#"n",(a0)+
	move.b	#"o",(a0)+
	move.b	#"p",(a0)+
	rts
codstop:
	move.b	#"s",(a0)+
	move.b	#"t",(a0)+
	move.b	#"o",(a0)+
	move.b	#"p",(a0)+
	jsr	tab(pc)
	move.w	#1,(a6)
	jsr	get_imediate(pc)
	rts
codrte:
	move.b	#"r",(a0)+
	move.b	#"t",(a0)+
	move.b	#"e",(a0)+
	rts
codrts:
	move.b	#"r",(a0)+
	move.b	#"t",(a0)+
	move.b	#"s",(a0)+
	rts
codtrapv:
	move.b	#"t",(a0)+
	move.b	#"r",(a0)+
	move.b	#"a",(a0)+
	move.b	#"p",(a0)+
	move.b	#"v",(a0)+
	rts
codrtr:
	move.b	#"r",(a0)+
	move.b	#"t",(a0)+
	move.b	#"r",(a0)+
	rts
codjsr:
	move.b	#"j",(a0)+
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codjmp:
	move.b	#"j",(a0)+
	move.b	#"m",(a0)+
	move.b	#"p",(a0)+
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
quickcond:
	move.w	(a1),d0
	and.w	#%1111000011111000,d0
	cmp.w	#%0101000011001000,d0
	beq.s	coddbcc
	move.w	(a1),d0
	and.w	#%0101000011000000,d0
	cmp.w	#%0101000011000000,d0
	beq.s	codscc
	move.w	(a1),d0
	and.w	#%1111000100000000,d0
	cmp.w	#%0101000000000000,d0
	beq.s	codaddq
	cmp.w	#%0101000100000000,d0
	beq.s	codsubq
	moveq	#-1,d0
	rts
coddbcc:
	move.b	#"d",(a0)+
	move.b	#"b",(a0)+
	jsr	get_condition(pc)
	jsr	tab(pc)
	jsr	data_reg(pc)
	move.b	#",",(a0)+
	moveq	#0,d1
	move.l	a1,d1
	move.w	2(a1),d0
	ext.l	d0
	addq.l	#2,d0
	add.l	d0,d1
	move.b	#"$",(a0)+
	jsr	proc_long(pc)
	move.w	#2,2(a6)
	rts
codscc:
	move.b	#"s",(a0)+
	jsr	get_condition(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codaddq:
	move.b	#"a",(a0)+
	move.b	#"d",(a0)+
	move.b	#"d",(a0)+
	move.b	#"q",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_quick_shit(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
codsubq:
	move.b	#"s",(a0)+
	move.b	#"u",(a0)+
	move.b	#"b",(a0)+
	move.b	#"q",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_quick_shit(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
subrout:
	move.w	(a1),d0
	and.w	#%1111111100000000,d0
	cmp.w	#%0110000000000000,d0
	beq.s	codbra
	cmp.w	#%0110000100000000,d0
	beq.s	codbsr
	bra.s	codbcc
codbra:
	move.b	#"b",(a0)+
	move.b	#"r",(a0)+
	move.b	#"a",(a0)+
	jsr	test_for_short(pc)
	rts
codbsr:
	move.b	#"b",(a0)+
	move.b	#"s",(a0)+
	move.b	#"r",(a0)+
	jsr	test_for_short(pc)
	rts
codbcc:
	move.b	#"b",(a0)+
	jsr	get_condition(pc)
	jsr	test_for_short(pc)
	rts

test_for_short:
	move.w	(a1),d0
	and.w	#%0000000011111111,d0
	cmp.w	#0,d0
	beq.s	no_short
	move.b	#".",(a0)+
	move.b	#"s",(a0)+
	jsr	tab(pc)
	moveq	#0,d1
	move.l	a1,d1
	ext.w	d0
	ext.l	d0
	addq.l	#2,d0
	add.l	d0,d1
	move.b	#"$",(a0)+
	jsr	proc_long(pc)
	rts
no_short:
	move.w	#2,2(a6)
	jsr	tab(pc)
	moveq	#0,d1
	move.l	a1,d1
	move.w	2(a1),d0
	ext.l	d0
	addq.l	#2,d0
	add.l	d0,d1
	move.b	#"$",(a0)+
	jsr	proc_long(pc)
	rts
moveq:
	move.b	#"m",(a0)+
	move.b	#"o",(a0)+
	move.b	#"v",(a0)+
	move.b	#"e",(a0)+
	move.b	#"q",(a0)+
	jsr	tab(pc)
	move.b	#"#",(a0)+
	move.b	#"$",(a0)+
	move.w	(a1),d1
	jsr	proc_byte(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
logic:
	move.w	(a1),d0
	and.w	#%1111000111110000,d0
	cmp.w	#%1000000100000000,d0
	beq.s	codsbcd
	move.w	(a1),d0
	and.w	#%1111000011000000,d0
	cmp.w	#%1000000011000000,d0
	beq.s	coddiv
	bra.s	codor
coddiv:
	move.w	#1,(a6)
	move.b	#"d",(a0)+
	move.b	#"i",(a0)+
	move.b	#"v",(a0)+
	jsr	get_dmtype(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codsbcd:
	move.b	#"s",(a0)+
	move.b	#"b",(a0)+
	move.b	#"c",(a0)+
	move.b	#"d",(a0)+
	jsr	tab(pc)
	move.w	(a1),d0
	and.w	#%0000000000001000,d0
	cmp.w	#%0000000000001000,d0
	beq	this_is_addreggs
	jsr	data_registers(pc)
	rts
codor:
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#".",(a0)+
	jsr	get_length_type(pc)
	and.w	#%0000000000000100,d0
	cmp.w	#0,d0
	bne.s	other_way
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
other_way:
	jsr	tab(pc)
	jsr	get_data_reg(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts	
subs:
	move.w	(a1),d0
	and.w	#%0000000111000000,d0
	cmp.w	#%0000000011000000,d0
	beq.s	codsuba
	cmp.w	#%0000000111000000,d0
	beq.s	codsuba
	move.w	(a1),d0
	and.w	#%0000000100110000,d0
	cmp.w	#%0000000100000000,d0
	beq.s	codsubx
codsub:
	move.b	#"s",(a0)+
	move.b	#"u",(a0)+
	move.b	#"b",(a0)+
	move.b	#".",(a0)+
	jsr	get_length_type(pc)
	and.w	#%0000000000000100,d0
	cmp.w	#0,d0
	bne.s	other_way
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codsuba:
	move.b	#"s",(a0)+
	move.b	#"u",(a0)+
	move.b	#"b",(a0)+
	move.b	#"a",(a0)+
	move.b	#".",(a0)+
	jsr	get_length(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_addr_reg(pc)
	rts
codsubx:
	move.b	#"s",(a0)+
	move.b	#"u",(a0)+
	move.b	#"b",(a0)+
	move.b	#"x",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	move.w	(a1),d0
	and.w	#%0000000000001000,d0
	cmp.w	#%0000000000001000,d0
	beq	this_is_addreggs
	jsr	data_registers(pc)
	rts
reserved:
	moveq	#-1,d0
	rts
compare:
	move.w	(a1),d0
	and.w	#%1111000111000000,d0
	cmp.w	#%1011000100000000,d0
	beq.s	codeor
	cmp.w	#%1011000101000000,d0
	beq.s	codeor
	cmp.w	#%1011000110000000,d0
	beq.s	codeor
	cmp.w	#%1011000011000000,d0
	beq.s	codcmpa
	cmp.w	#%1011000111000000,d0
	beq.s	codcmpa
	move.w	(a1),d0
	and.w	#%1111000100111000,d0
	cmp.w	#%1011000100001000,d0
	beq.s	codcmpm
codcmp:
	move.b	#"c",(a0)+
	move.b	#"m",(a0)+
	move.b	#"p",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codcmpa:
	move.b	#"c",(a0)+
	move.b	#"m",(a0)+
	move.b	#"p",(a0)+
	move.b	#"a",(a0)+
	move.b	#".",(a0)+
	jsr	get_length(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_addr_reg(pc)
	rts	
codeor:
	move.b	#"e",(a0)+
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize5(pc)
	jsr	tab(pc)
	jsr	get_data_reg(pc)
	move.b	#",",(a0)+
	jsr	get_destmode(pc)
	rts
codcmpm:
	move.b	#"c",(a0)+
	move.b	#"m",(a0)+
	move.b	#"p",(a0)+
	move.b	#"m",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	addr_reg_indir_post(pc)
	move.b	#",",(a0)+
	jsr	addr_reg_indir_post2(pc)
	rts
multiply:
	move.w	(a1),d0
	and.w	#%1111000111111000,d0
	cmp.w	#%1100000110001000,d0
	beq	codexgda
	cmp.w	#%1100000101001000,d0
	beq	codexgaa
	cmp.w	#%1100000101000000,d0
	beq	codexgdd
	move.w	(a1),d0
	and.w	#%1111000111110000,d0
	cmp.w	#%1100000100000000,d0
	beq.s	codabcd
	move.w	(a1),d0
	and.w	#%1111000011000000,d0
	cmp.w	#%1100000011000000,d0
	beq.s	codmul
	bra.s	codand
	rts
codand:
	move.b	#"a",(a0)+
	move.b	#"n",(a0)+
	move.b	#"d",(a0)+
	move.b	#".",(a0)+
	jsr	get_length_type(pc)
	and.w	#%0000000000000100,d0
	cmp.w	#0,d0
	bne	other_way
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codmul:
	move.b	#"m",(a0)+
	move.b	#"u",(a0)+
	move.b	#"l",(a0)+
	jsr	get_dmtype(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codabcd:
	move.b	#"a",(a0)+
	move.b	#"b",(a0)+
	move.b	#"c",(a0)+
	move.b	#"d",(a0)+
	jsr	tab(pc)
	move.w	(a1),d0
	and.w	#%0000000000001000,d0
	cmp.w	#%0000000000001000,d0
	beq	this_is_addreggs
	jsr	data_registers(pc)
	rts	
codexgda:
	move.b	#"e",(a0)+
	move.b	#"x",(a0)+
	move.b	#"g",(a0)+
	jsr	tab(pc)
	jsr	data_reg2(pc)
	move.b	#",",(a0)+
	jsr	addr_reg(pc)
	rts
codexgaa:
	move.b	#"e",(a0)+
	move.b	#"x",(a0)+
	move.b	#"g",(a0)+
	jsr	tab(pc)
	jsr	addr_reg(pc)
	move.b	#",",(a0)+
	jsr	addr_reg2(pc)
	rts
codexgdd:
	move.b	#"e",(a0)+
	move.b	#"x",(a0)+
	move.b	#"g",(a0)+
	jsr	tab(pc)
	jsr	data_reg2(pc)
	move.b	#",",(a0)+
	jsr	data_reg(pc)
	rts
adds:
	move.w	(a1),d0
	and.w	#%1111000111000000,d0
	cmp.w	#%1101000011000000,d0
	beq.s	codadda
	cmp.w	#%1101000111000000,d0
	beq.s	codadda
	move.w	(a1),d0
	and.w	#%1111000100110000,d0
	cmp.w	#%1101000100000000,d0
	beq.s	codaddx
codadd:
	move.b	#"a",(a0)+
	move.b	#"d",(a0)+
	move.b	#"d",(a0)+
	move.b	#".",(a0)+
	jsr	get_length_type(pc)
	and.w	#%0000000000000100,d0
	cmp.w	#0,d0
	bne	other_way
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_data_reg(pc)
	rts
codadda:
	move.b	#"a",(a0)+
	move.b	#"d",(a0)+
	move.b	#"d",(a0)+
	move.b	#"a",(a0)+
	move.b	#".",(a0)+
	jsr	get_length(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	move.b	#",",(a0)+
	jsr	get_addr_reg(pc)
	rts	
codaddx:
	move.b	#"a",(a0)+
	move.b	#"d",(a0)+
	move.b	#"d",(a0)+
	move.b	#"x",(a0)+
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	move.w	(a1),d0
	and.w	#%0000000000001000,d0
	cmp.w	#%0000000000001000,d0
	beq	this_is_addreggs
	jsr	data_registers(pc)
	rts
rotate:
	move.w	(a1),d0
	and.w	#%1111100011000000,d0
	cmp.w	#%1110000011000000,d0
	beq.s	codshiftmem
	bra.s	codshiftdata
codshiftmem:
	jsr	get_shift_type(pc)
	jsr	getdire(pc)
	jsr	tab(pc)
	jsr	get_destmode(pc)
	rts
codshiftdata:
	jsr	get_shift_type2(pc)
	jsr	getdire(pc)
	move.b	#".",(a0)+
	jsr	get_zize2(pc)
	jsr	tab(pc)
	jsr	get_shift_lamers(pc)
	move.b	#",",(a0)+
	jsr	data_reg(pc)
	rts	
get_shift_lamers:
	move.w	(a1),d0
	and.w	#%0000000000100000,d0
	cmp.w	#0,d0
	beq	get_quick_shit
	bra	data_reg2
coprocessor:
	move.b	#"C",(a0)+
	move.b	#"o",(a0)+
	move.b	#"p",(a0)+
	move.b	#"r",(a0)+
	move.b	#"o",(a0)+
	move.b	#"c",(a0)+
	move.b	#"e",(a0)+
	move.b	#"s",(a0)+
	move.b	#"s",(a0)+
	move.b	#"o",(a0)+
	move.b	#"r",(a0)+
	move.b	#" ",(a0)+
	move.b	#"i",(a0)+
	move.b	#"n",(a0)+
	move.b	#"t",(a0)+
	move.b	#"e",(a0)+
	move.b	#"r",(a0)+
	move.b	#"f",(a0)+
	move.b	#"a",(a0)+
	move.b	#"c",(a0)+
	move.b	#"e",(a0)+
	move.b	#" ",(a0)+
	move.b	#"(",(a0)+
	move.b	#"$",(a0)+
	move.b	#"f",(a0)+
	move.b	#"x",(a0)+
	move.b	#"x",(a0)+
	move.b	#"x",(a0)+
	move.b	#")",(a0)+
	move.w	#2,6(a6)
	rts
start_print:
	lea	372(a6),a2
huj_print:
	move.w	14(a6),d2
	mulu	#160*8,d2
print:
	move.l	526(a6),a1
	moveq	#0,d0
	moveq	#0,d1
	move.l	26(a6),a0
	move.w	12(a6),d0
	move.w	d0,d1
	and.w	#1,d0
	lsr.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	add.w	d0,a0
	add.w	d2,a0
	moveq	#0,d0
	move.b	(a2)+,d0
	tst.b	d0
	beq.s	end_print
	lsl.w	#3,d0
	add.w	d0,a1
	move.b	(a1)+,(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.b	(a1),160*7(a0)
	addq.w	#1,12(a6)
	cmp.w	#80,12(a6)
	beq.s	andy
	bra.s	print
end_print:
	jsr	clear_text(pc)
	rts
andy:
	addq.w	#1,14(a6)
	move.w	#0,12(a6)
	move.w	14(a6),d2
	mulu	#160*8,d2
	bra.s	print
start_print2:
	lea	372(a6),a2
print2:
	move.l	526(a6),a1
	moveq	#0,d0
	moveq	#0,d1
	move.l	26(a6),a0
	move.w	12(a6),d0
	move.w	d0,d1
	and.w	#1,d0
	lsr.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	add.l	d0,a0
	move.w	14(a6),d0
	mulu	#160*8,d0
	add.w	d0,a0
	moveq	#0,d0
	move.b	(a2)+,d0
	tst.b	d0
	beq.s	end_print2
	lsl.w	#3,d0
	add.l	d0,a1
	move.b	(a1)+,(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.b	(a1),160*7(a0)
	addq.w	#1,12(a6)
	cmp.w	#52,12(a6)
	beq.s	end_print
	bra.s	print2
end_print2:
	moveq	#0,d2
	move.b	d2,(a0)
	move.b	d2,160*1(a0)
	move.b	d2,160*2(a0)
	move.b	d2,160*3(a0)
	move.b	d2,160*4(a0)
	move.b	d2,160*5(a0)
	move.b	d2,160*6(a0)
	move.b	d2,160*7(a0)
	addq.w	#1,12(a6)
	cmp.w	#52,12(a6)
	beq	end_print
print3:
	moveq	#0,d0
	moveq	#0,d1
	move.l	26(a6),a0
	move.w	12(a6),d0
	move.w	d0,d1
	and.w	#1,d0
	lsr.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	add.l	d0,a0
	move.w	14(a6),d0
	mulu	#160*8,d0
	add.w	d0,a0
	move.b	d2,(a0)
	move.b	d2,160*1(a0)
	move.b	d2,160*2(a0)
	move.b	d2,160*3(a0)
	move.b	d2,160*4(a0)
	move.b	d2,160*5(a0)
	move.b	d2,160*6(a0)
	move.b	d2,160*7(a0)
	addq.w	#1,12(a6)
	cmp.w	#52,12(a6)
	beq	end_print
	bra.s	print3
clear_text:
	lea	372(a6),a2
	moveq	#0,d1
	moveq	#99,d0
.loop:
	move.b	d1,(a2)+
	dbra	d0,.loop
	rts
print_pos:
	movem.l	d0-d7/a0-a5,-(sp)
	move.l	a1,d1
	and.l	#$00ffffff,d1
	jsr	real_long(pc)
	jsr	start_print(pc)
	movem.l	(sp)+,d0-d7/a0-a5
	rts
x_bomb:
	move.w	#-1,240(a6)
	jmp	fix_berr(pc)
x_bomb2:
	move.w	#-1,242(a6)
	jmp	fix_berr(pc)
x_bomb3:
	move.w	#-1,244(a6)
	jmp	fix_berr(pc)
x_bomb4:
	move.w	#-1,246(a6)
fix_berr:
	move.b	#"*",d1
	move.l	10(sp),a2
	add.l	#14,sp
	jmp	(a2)
no_trap3:
	move.l	a1,-(sp)
	move.b	(a1)+,d1
	lsl.w	#8,d1
	move.b	(a1)+,d1
	lsl.l	#8,d1
	move.b	(a1)+,d1
	lsl.l	#8,d1
	move.b	(a1),d1
	bra.s	olvast56
print_pos2:
	movem.l	d0-d7/a0-a5,-(sp)
	cmp.w	#0,546(a6)
	beq.s	no_trap3

	move.l	$8.w,-(sp)
	move.l	a1,-(sp)
	move.w	#0,240(a6)
	move.w	#0,242(a6)
	move.w	#0,244(a6)
	move.w	#0,246(a6)
	move.l	#x_bomb,$8.w

	move.b	(a1)+,d1
	lsl.w	#8,d1

	move.l	#x_bomb2,$8.w

	move.b	(a1)+,d1
	lsl.l	#8,d1

	move.l	#x_bomb3,$8.w

	move.b	(a1)+,d1
	lsl.l	#8,d1

	move.l	#x_bomb4,$8.w

	move.b	(a1),d1
olvast56:
	jsr	real_long(pc)
	jsr	fix_rackare(pc)
	jsr	start_print(pc)
	move.l	(sp)+,a1

	lea	372(a6),a0
	move.b	#$20,(a0)+

	move.b	(a1)+,d1
	tst.b	d1
	bne.s	luring
	move.b	#" ",d1
luring:
	move.b	d1,(a0)+

	move.b	(a1)+,d1
	tst.b	d1
	bne.s	luring2
	move.b	#" ",d1
luring2:
	move.b	d1,(a0)+

	move.b	(a1)+,d1
	tst.b	d1
	bne.s	luring3
	move.b	#" ",d1
luring3:
	move.b	d1,(a0)+

	move.b	(a1),d1
	tst.b	d1
	bne.s	luring4
	move.b	#" ",d1
luring4:
	move.b	d1,(a0)+
	jsr	start_print(pc)	
	cmp.w	#0,546(a6)
	beq.s	no_trap4
	move.l	(sp)+,$8.w
no_trap4:
	movem.l	(sp)+,d0-d7/a0-a5
	rts
fix_rackare:
	lea	372(a6),a0
	tst.w	240(a6)
	beq.s	.x_no_fix
	move.b	#"*",(a0)
	move.b	#"*",1(a0)
.x_no_fix:
	tst.w	242(a6)
	beq.s	.x_no_fix2
	move.b	#"*",2(a0)
	move.b	#"*",3(a0)
.x_no_fix2:
	tst.w	244(a6)
	beq.s	.x_no_fix3
	move.b	#"*",4(a0)
	move.b	#"*",5(a0)
.x_no_fix3:
	tst.w	246(a6)
	beq.s	.x_no_fix4
	move.b	#"*",6(a0)
	move.b	#"*",7(a0)
.x_no_fix4:
	rts
print_decoding:
	lea	372(a6),a0
	move.l	42(a6),a1
	move.w	#0,12(a6)
	move.w	#7,14(a6)
	jsr	print_pos(pc)
	move.l	a1,-(sp)
	jsr	decode(pc)
	move.l	(sp)+,a1
	jsr	fix_bpkt(pc)
	move.w	#9,12(a6)
	jsr	start_print2(pc)
	moveq	#0,d0
	move.w	6(a6),d0
	move.l	d0,30(a6)
	move.l	d0,38(a6)
	moveq	#15,d0
.loop
	move.w	d0,-(sp)
	lea	372(a6),a0
	move.l	42(a6),a1
	add.l	38(a6),a1
	move.w	#0,12(a6)
	addq.w	#1,14(a6)
	jsr	print_pos(pc)
	move.l	a1,-(sp)
	jsr	decode(pc)
	move.l	(sp)+,a1
	jsr	fix_bpkt(pc)
	move.w	#9,12(a6)
	jsr	start_print2(pc)
	moveq	#0,d0
	move.w	6(a6),d0
	add.l	d0,38(a6)
	move.w	(sp)+,d0
	dbra	d0,.loop
	move.l	38(a6),34(a6)
	rts
print_data:
	lea	372(a6),a0
	move.l	50(a6),a1
	move.l	#0,46(a6)
	move.w	#53,12(a6)
	move.w	#7,14(a6)
	moveq	#16,d0
.loop
	move.w	d0,-(sp)
	lea	372(a6),a0
	move.l	50(a6),a1
	add.l	46(a6),a1
	move.w	#53,12(a6)
	jsr	print_pos(pc)
	move.w	#62,12(a6)
	jsr	print_pos2(pc)
	addq.w	#1,14(a6)
	addq.l	#4,46(a6)
	move.w	(sp)+,d0
	dbra	d0,.loop
	rts
koll_data_slave:
	cmp.w	#1,536(a6)
	bne.s	.no_mega_slave
	move.l	50(a6),d0
	and.b	#$fe,d0
	move.l	d0,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
.no_mega_slave:
	rts
koll_code_slave:
	cmp.w	#1,536(a6)
	bne.s	.no_mega_slave
	move.l	42(a6),50(a6)
	jsr	print_data(pc)
.no_mega_slave:
	rts
data_down:
	addq.l	#4,50(a6)
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again
data_up:
	subq.l	#4,50(a6)
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again
data_left:
	subq.l	#1,50(a6)
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again
data_right:
	addq.l	#1,50(a6)
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again
megadata_down:
	add.l	#4*17,50(a6)
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again
megadata_upp:
	sub.l	#4*17,50(a6)
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again
super_pc_acc:
	cmp.w	#0,210(a6)
	beq.s	no_super_pc
	move.l	42(a6),206(a6)
	move.l	206(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#72,12(a6)
	move.w	#3,14(a6)
	jsr	start_print(pc)
no_super_pc:
	rts
mega_pil_down:
	cmp.w	#0,18(a6)
	beq.s	megadata_down
	move.l	34(a6),d0
	add.l	d0,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
mega_pil_upp:
	cmp.w	#0,18(a6)
	beq.s	megadata_upp
	sub.l	#2*17,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
pil_down:
	cmp.w	#0,18(a6)
	beq	data_down
	move.l	30(a6),d0
	add.l	d0,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
pil_upp:
	cmp.w	#0,18(a6)
	beq	data_up
	subq.l	#2,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
pil_left:
	cmp.w	#0,18(a6)
	beq	data_left
	subq.l	#2,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
pil_rigt:
	cmp.w	#0,18(a6)
	beq	data_right
	addq.l	#2,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
initt_screen:
	move.w	#0,12(a6)
	move.w	#0,14(a6)
	move.l	526(a6),a1
	lea	data_layout(pc),a2
	jsr	huj_print(pc)
	rts
print_moj„ng:
	move.l	166(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#58,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	move.l	170(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#72,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	move.l	58(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#58,12(a6)
	move.w	#3,14(a6)
	jsr	start_print(pc)
	move.w	174(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#58,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.l	130(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#58,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.l	206(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#72,12(a6)
	move.w	#3,14(a6)
	jsr	start_print(pc)
	move.l	490(a6),a0
	move.l	(a0),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#72,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.l	494(a6),a0
	move.l	(a0),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#72,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)

	move.w	174(a6),d1
	lea	372(a6),a0
	btst	#4,d1
	beq.s	no_x
	move.b	#"x",(a0)+
	bra.s	yes_x
no_x:
	move.b	#" ",(a0)+
yes_x:
	btst	#3,d1
	beq.s	no_n
	move.b	#"n",(a0)+
	bra.s	yes_n
no_n:
	move.b	#" ",(a0)+
yes_n:
	btst	#2,d1
	beq.s	no_z
	move.b	#"z",(a0)+
	bra.s	yes_z
no_z:
	move.b	#" ",(a0)+
yes_z:
	btst	#1,d1
	beq.s	no_v
	move.b	#"v",(a0)+
	bra.s	yes_v
no_v:
	move.b	#" ",(a0)+
yes_v:
	btst	#0,d1
	beq.s	no_c
	move.b	#"c",(a0)+
	bra.s	yes_c
no_c:
	move.b	#" ",(a0)+
yes_c:
	move.w	#62,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	rts
print_regs:
	lea	66(a6),a3
	lea	data_pos(pc),a4
	moveq	#7,d0
.loop:
	move.w	d0,-(sp)
	move.l	(a3)+,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	(a4)+,12(a6)
	move.w	(a4)+,14(a6)
	jsr	start_print(pc)
	move.w	(sp)+,d0
	dbra	d0,.loop

	lea	98(a6),a3
	lea	addr_pos(pc),a4
	moveq	#7,d0
.loop2:
	move.w	d0,-(sp)
	move.l	(a3)+,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	(a4)+,12(a6)
	move.w	(a4)+,14(a6)
	jsr	start_print(pc)
	move.w	(sp)+,d0
	dbra	d0,.loop2
	rts
leftwind:
	moveq	#-1,d2
	moveq	#0,d3
	bra.s	do_stuff
rightwind:
	moveq	#0,d2
	moveq	#-1,d3
	bra.s	do_stuff
put_curr_window:
	cmp.w	#0,18(a6)
	beq.s	leftwind
	cmp.w	#1,18(a6)
	beq.s	rightwind
	rts
do_stuff:
	move.l	26(a6),a0
	add.l	#(160*56)+2,a0
	moveq	#67,d1
.loop2:
	move.l	a0,a1
	moveq	#25,d0
.loop:
	move.w	d2,(a1)
	addq.l	#4,a1
	dbra	d0,.loop
 	lea	160(a0),a0
	move.l	a0,a1
	moveq	#25,d0
.loop3:
	move.w	d2,(a1)
	addq.l	#4,a1
	dbra	d0,.loop3
	lea	160(a0),a0
	dbra	d1,.loop2

	move.l	26(a6),a0
	add.l	#(160*56)+2+(4*26),a0
	moveq	#67,d1
.loop4:
	move.l	a0,a1
	moveq	#11,d0
.loop5:
	move.w	d3,(a1)
	addq.l	#4,a1
	dbra	d0,.loop5
	lea	160(a0),a0
	move.l	a0,a1
	moveq	#11,d0
.loop6:
	move.w	d3,(a1)
	addq.l	#4,a1
	dbra	d0,.loop6
	lea	160(a0),a0
	dbra	d1,.loop4
	rts
put_promt2:
	lea	372(a6),a1
.loop:
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	end_promt
	move.b	d0,(a1)+
	bra.s	.loop
end_promt:
	moveq	#0,d0
	move.b	(a0),d0
	move.w	d0,16(a6)
	move.w	#1,12(a6)
	move.w	#24,14(a6)
	jsr	start_print(pc)
.loop:
	jsr	get_key(pc)
	cmp.b	#28,d0
	bne.s	.loop
	rts
put_promt:
	lea	372(a6),a1
.loop:
	move.b	(a0)+,d0
	tst.b	d0
	beq.s	end_promt2
	move.b	d0,(a1)+
	bra.s	.loop
end_promt2:
	moveq	#0,d0
	move.b	(a0),d0
	move.w	d0,16(a6)
	move.w	#1,12(a6)
	move.w	#24,14(a6)
	jsr	start_print(pc)
	jsr	get_shit(pc)
	tst.w	d0
	bmi.s	nothing_about
	rts
nothing_about:
	move.b	#-1,292(a6)
	rts
make_text_data:
	lea	292(a6),a0
	cmp.b	#-1,(a0)
	beq.s	end_glod
	cmp.b	#"*",(a0)
	beq.s	super_edit
	moveq	#7,d0
	moveq	#0,d1
.loop:
	move.b	(a0)+,d2
	cmp.b	#0,d2
	beq.s	end_th
	cmp.b	#$20,d2
	beq.s	end_th
	lsl.l	#4,d1
	lea	conv_hex(pc),a1
.loop2:
	move.b	(a1),d3
	cmp.b	#-1,d3
	beq.s	end_glod
	cmp.b	d2,d3
	beq.s	.found
	addq.l	#2,a1
	bra.s	.loop2
.found:
	or.b	1(a1),d1
	dbra	d0,.loop
end_th:
	moveq	#0,d0
	rts
end_glod:
	moveq	#-1,d0
	rts
super_edit:
	lea	super_conv_tab(pc),a0
	lea	293(a6),a1
	moveq	#0,d0
super_loop:
	cmp.b	#-2,(a0)
	beq.s	super_not_found
	move.b	(a0),d1	
	cmp.b	(a1),d1
	bne.s	next_super
	move.b	1(a0),d1	
	cmp.b	1(a1),d1
	bne.s	next_super
	move.b	2(a0),d1
	cmp.b	#-1,d1
	beq.s	found_super
	cmp.b	2(a1),d1
	bne.s	next_super
	bra.s	found_super
next_super:
	addq.l	#8,a0
	bra.s	super_loop
super_not_found:
	moveq	#-1,d0
	rts
found_super:
	move.l	4(a0),a0
	jmp	(a0)
rega0:
	move.l	98(a6),d1
	rts
rega1:
	move.l	102(a6),d1
	rts
rega2:
	move.l	106(a6),d1
	rts
rega3:
	move.l	110(a6),d1
	rts
rega4:
	move.l	114(a6),d1
	rts
rega5:
	move.l	118(a6),d1
	rts
rega6:
	move.l	122(a6),d1
	rts
rega7:
	move.l	126(a6),d1
	rts
regd0:
	move.l	66(a6),d1
	rts
regd1:
	move.l	70(a6),d1
	rts
regd2:
	move.l	74(a6),d1
	rts
regd3:
	move.l	78(a6),d1
	rts
regd4:
	move.l	82(a6),d1
	rts
regd5:
	move.l	86(a6),d1
	rts
regd6:
	move.l	90(a6),d1
	rts
regd7:
	move.l	94(a6),d1
	rts
regusp:
	move.l	130(a6),d1
	rts
regcwp:
	move.l	166(a6),d1
	rts
regdwp:
	move.l	170(a6),d1
	rts
regrp:
	move.l	58(a6),d1
	rts
regpc:
	move.l	206(a6),d1
	rts
regw1:
	move.l	42(a6),d1
	rts
regw2:
	move.l	50(a6),d1
	rts
regbp1:
	cmp.l	#0,188(a6)
	beq	super_not_found
	move.l	188(a6),d1
	rts
regbp2:
	cmp.l	#0,192(a6)
	beq	super_not_found
	move.l	192(a6),d1
	rts
regbp3:
	cmp.l	#0,196(a6)
	beq	super_not_found
	move.l	196(a6),d1
	rts
regbp4:
	cmp.l	#0,200(a6)
	beq	super_not_found
	move.l	200(a6),d1
	rts
regva1:
	move.l	490(a6),d1
	rts
regva2:
	move.l	494(a6),d1
	rts
get_shit:
	jsr	get_key3(pc)
	cmp.b	#1,d0
	beq.s	end_get_promt2
	cmp.b	#28,d0
	beq.s	end_get_promt
	cmp.b	#14,d0
	beq.s	back_promt
	lea	key_tab(pc),a0
.loop:
	cmp.b	#-1,(a0)
	beq.s	get_shit
	cmp.b	(a0),d0
	beq.s	key_found
	addq.l	#2,a0
	bra.s	.loop
key_found:
	move.l	288(a6),a1
	moveq	#0,d0
	move.w	#79,d0
	sub.w	16(a6),d0
	add.l	a6,d0
	add.l	#292,d0
	cmp.l	a1,d0
	bne.s	not_end
	subq.l	#1,a1
not_end:
	move.b	1(a0),(a1)+
	move.l	a1,288(a6)
	lea	292(a6),a2
	move.w	16(a6),12(a6)
	move.w	#24,14(a6)
	jsr	huj_print(pc)
	bra.s	get_shit
end_get_promt:
	moveq	#0,d0
	rts
end_get_promt2:
	moveq	#-1,d0
	rts
back_promt:
	move.l	288(a6),a1
	subq.l	#1,a1
	move.l	a6,d0
	add.l	#291,d0
	cmp.l	d0,a1
	beq.s	get_shit
	move.b	#$20,(a1)
	move.l	a1,288(a6)
	lea	292(a6),a2
	move.w	16(a6),12(a6)
	move.w	#24,14(a6)
	jsr	huj_print(pc)
	bra	get_shit
change_window:
	eor.w	#1,18(a6)
	jsr	put_curr_window(pc)
	bra	get_key_again 
other:
	move.l	50(a6),d0
	and.b	#$fe,d0
	move.l	d0,42(a6)
	jsr	print_decoding(pc)
	bra	get_key_again 
set_same:
	cmp.w	#0,18(a6)
	beq.s	other
	move.l	42(a6),50(a6)
	jsr	print_data(pc)
	bra	get_key_again 
wind_pos:
	lea	text1(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi.s	nofing
	and.l	#$00ffffff,d1
	cmp.w	#0,18(a6)
	beq.s	gg
	and.b	#$fe,d1
	move.l	d1,42(a6)
	bra.s	nofing
gg:
	move.l	d1,50(a6)
nofing:
	jsr	fix_promt(pc)
	bra	get_key_again
fix_promt:
	lea	292(a6),a0
	moveq	#79,d0
.loop:
	clr.b	(a0)+
	dbra	d0,.loop
	lea	292(a6),a0
	move.l	a0,288(a6)
	jsr	init_screen(pc)
	rts
go:
	lea	text2(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi.s	nofing
	cmp.l	#0,d1
	bne.s	no_pc
	move.l	206(a6),d1
no_pc:
	move.l	d1,-(sp)
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	fix_promt(pc)
	jsr	bpkt_on(pc)
	move.l	(sp)+,d1
	and.l	#$00fffffe,d1
	move.l	d1,d2
	move.l	66(a6),d0
	move.l	70(a6),d1
	move.l	$24.w,66(a6)
	move.l	$30.w,70(a6)
	move.l	a6,-(sp)
	move.l	a7,$30.w
	move.l	126(a6),a7
	move.l	d2,-(sp)
	move.l	130(a6),a0
	move.l	a0,usp

	*dumm
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	472(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)

	move.w	174(a6),sr
	movem.l	74(a6),d2-d7/a0-a6
	rts

search_next:
	cmp.b	#-1,480(a6)
	beq.s	lamer
	cmp.b	#0,480(a6)
	bne.s	not_byte
	move.l	62(a6),d1
	jsr	fix_curr(pc)
	addq.l	#1,a0
	bra	cont_byte
not_byte:
	cmp.b	#1,480(a6)
	bne.s	not_word
	move.l	62(a6),d1
	jsr	fix_curr(pc)
	addq.l	#1,a0
	bra	cont_word
not_word:
	move.l	62(a6),d1
	jsr	fix_curr(pc)
	addq.l	#1,a0
	bra	cont_long
lamer:
	jsr	colerr(pc)
	bra	get_key_again 
search_prev:
	cmp.b	#-1,480(a6)
	beq.s	lamer
	cmp.b	#0,480(a6)
	bne.s	not_byte2
	move.l	62(a6),d1
	jsr	fix_curr(pc)
	addq.l	#1,a0
	bra.s	cont_byte2
not_byte2:
	cmp.b	#1,480(a6)
	bne.s	not_word2
	move.l	62(a6),d1
	jsr	fix_curr(pc)
	addq.l	#1,a0
	bra.s	cont_word2
not_word2:
	move.l	62(a6),d1
	jsr	fix_curr(pc)
	addq.l	#1,a0
	bra.s	cont_long2
cont_byte2:
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq	kallebajsare
	eor.w	#$770,$ffff8242.w
	subq.l	#1,a0
	cmp.l	#0,a0
	beq	endkallebajsare
	cmp.b	(a0),d1
	bne.s	.loop
	bra	kallebajsare
cont_word2:
	move.b	d1,d2
	lsr.w	#8,d1
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq	kallebajsare
	subq.l	#1,a0
	cmp.l	#0,a0
	beq	endkallebajsare
	cmp.b	(a0),d1
	bne.s	.loop
	eor.w	#$770,$ffff8242.w
	cmp.b	1(a0),d2
	bne.s	.loop
	bra	kallebajsare
cont_long2:
	move.b	d1,d2
	lsr.l	#8,d1
	move.b	d1,d3
	lsr.l	#8,d1
	move.b	d1,d4
	lsr.l	#8,d1
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq	kallebajsare
	subq.l	#1,a0
	cmp.l	#0,a0
	beq	endkallebajsare
	cmp.b	(a0),d1
	bne.s	.loop
	eor.w	#$770,$ffff8242.w
	cmp.b	1(a0),d4
	bne.s	.loop
	cmp.b	2(a0),d3
	bne.s	.loop
	cmp.b	3(a0),d2
	bne.s	.loop
	bra	kallebajsare

find:
	lea	text3(pc),a0
	jsr	put_promt(pc)
	cmp.b	#"b",292(a6)
	beq.s	byte_search
	cmp.b	#"w",292(a6)
	beq	word_search
	cmp.b	#"l",292(a6)
	beq	long_search
	bra	nofing
fix_curr2:
	cmp.w	#0,18(a6)
	beq.s	.loop
	move.l	a0,d1
	and.l	#$00fffffe,d1
	move.l	d1,42(a6)
	bra.s	.loop2
.loop:
	move.l	a0,50(a6)
.loop2:
	rts
fix_curr:
	cmp.w	#0,18(a6)
	beq.s	.loop
	move.l	42(a6),a0
	bra.s	.loop2
.loop:
	move.l	50(a6),a0
.loop2:
	rts
byte_search:
	jsr	get_end_val(pc)
	jsr	fix_promt(pc)
	lea	text4(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.b	#0,480(a6)
	move.l	d1,62(a6)
	jsr	fix_curr(pc)
cont_byte:
	move.l	54(a6),a1
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq.s	kallebajsare
	eor.w	#$770,$ffff8242.w
	addq.l	#1,a0
	cmp.l	a1,a0
	bge.s	endkallebajsare
	cmp.b	(a0),d1
	bne.s	.loop
kallebajsare:
	move.w	#$777,$ffff8242.w
	jsr	fix_curr2(pc)
	bra	nofing
endkallebajsare:
	move.w	#$777,$ffff8242.w
	move.b	#-1,480(a6)
	jsr	fix_curr2(pc)
	bra	nofing
word_search:
	jsr	get_end_val(pc)
	jsr	fix_promt(pc)
	lea	text4(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.b	#1,480(a6)
	move.l	d1,62(a6)
	jsr	fix_curr(pc)
cont_word:
	move.l	54(a6),a1
	move.b	d1,d2
	lsr.w	#8,d1
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq.s	kallebajsare
	addq.l	#1,a0
	cmp.l	a1,a0
	bge.s	endkallebajsare
	cmp.b	(a0),d1
	bne.s	.loop
	eor.w	#$770,$ffff8242.w
	cmp.b	1(a0),d2
	bne.s	.loop
	bra.s	kallebajsare
long_search:
	jsr	get_end_val(pc)
	jsr	fix_promt(pc)
	lea	text4(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.b	#2,480(a6)
	move.l	d1,62(a6)
	jsr	fix_curr(pc)
cont_long:
	move.l	54(a6),a1
	move.b	d1,d2
	lsr.l	#8,d1
	move.b	d1,d3
	lsr.l	#8,d1
	move.b	d1,d4
	lsr.l	#8,d1
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq	kallebajsare
	addq.l	#1,a0
	cmp.l	a1,a0
	bge	endkallebajsare
	cmp.b	(a0),d1
	bne.s	.loop
	eor.w	#$770,$ffff8242.w
	cmp.b	1(a0),d4
	bne.s	.loop
	cmp.b	2(a0),d3
	bne.s	.loop
	cmp.b	3(a0),d2
	bne.s	.loop
	bra	kallebajsare
get_key:
	move.b	$fffffc02.w,d0
	cmp.b	8(a6),d0
	beq.s	.not_new
	move.b	d0,8(a6)
	move.w	#4500,10(a6)
	rts
.not_new:
	cmp.w	#0,10(a6)
	beq.s	.no_repet
	subq.w	#1,10(a6)
	moveq	#0,d0
.no_repet:
	rts
get_key4:
	move.b	$fffffc02.w,d0
	cmp.b	8(a6),d0
	beq.s	.not_new
	move.b	d0,8(a6)
	move.w	#20,10(a6)
	rts
.not_new:
	cmp.w	#0,10(a6)
	beq.s	.no_repet
	subq.w	#1,10(a6)
	moveq	#0,d0
.no_repet:
	rts

get_key3:
	move.b	$fffffc02.w,d0
	cmp.b	8(a6),d0
	beq.s	not_new3
	move.b	d0,8(a6)
	move.w	#1200,10(a6)
	rts
no_repet3:
	move.w	#100,10(a6)
	rts
not_new3:
	cmp.w	#0,10(a6)
	beq.s	no_repet3
	subq.w	#1,10(a6)
	moveq	#0,d0
	rts
init_screen:
	jsr	initt_screen(pc)
	jsr	print_regs(pc)
	jsr	print_moj„ng(pc)
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	jsr	put_curr_window(pc)
;	move.w	#1,18(a6)
;	beq.s	yano
;	jsr	koll_code_slave(pc)
;	bra.s 	no_yano
;yano:
;	jsr	koll_data_slave(pc)
;no_yano:
	rts
set_reg:
	lea	text6(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,-(sp)
	jsr	fix_promt(pc)
	lea	text7(pc),a0
	jsr	put_promt(pc)
	bra.s	test_regs
no_sussi:
	lea	292(a6),a0
	cmp.b	#"d",(a0)
	beq	data
	cmp.b	#"a",(a0)
	beq	not_data
	bra	nofing
test_regs:
	lea	hip_tab(pc),a0
	lea	292(a6),a1
	moveq	#0,d0
super_loop2:
	cmp.b	#-2,(a0)
	beq.s	no_sussi
	move.b	(a0),d1	
	cmp.b	(a1),d1
	bne.s	next_super2
	move.b	1(a0),d1	
	cmp.b	1(a1),d1
	bne.s	next_super2
	move.b	2(a0),d1
	cmp.b	#-1,d1
	beq.s	found_super2
	cmp.b	2(a1),d1
	bne.s	next_super2
	bra.s	found_super2
next_super2:
	addq.l	#8,a0
	bra.s	super_loop2
found_super2:
	move.l	(sp)+,d1
	move.l	4(a0),a0
	jmp	(a0)
yes_pc:
	move.l	d1,206(a6)
	bra	nofing
yes_sr:
	move.w	d1,174(a6)
	bra	nofing
yes_rp:
	move.l	d1,58(a6)
	bra	nofing
yes_cwp:
	move.l	d1,166(a6)
	bra	nofing
yes_dwp:
	move.l	d1,170(a6)
	bra	nofing
yes_usp:
	move.l	d1,130(a6)
	bra	nofing
yes_va1:
	move.l	d1,490(a6)
	bra	nofing
yes_va2:
	move.l	d1,494(a6)
	bra	nofing
data:
	lea	66(a6),a1
	bra.s	jump_addr
not_data:
	lea	98(a6),a1
jump_addr:
	moveq	#0,d0
	move.b	1(a0),d0
	sub.b	#$30,d0
	cmp.b	#8,d0
	bge.s	nuffin
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	move.l	(sp)+,d1
	move.l	d1,(a1)
	jsr	fix_promt(pc)
	bra	get_key_again
nuffin:
	move.l	(sp)+,d1
	jsr	fix_promt(pc)
	bra	get_key_again
music_ripp:
	lea	text8(pc),a0
	jsr	put_promt(pc)
	lea	292(a6),a0
	cmp.b	#"m",(a0)
	beq.s	ripp_mad
	cmp.b	#"t",(a0)
	beq.s	ripp_tcb
	cmp.b	#"c",(a0)
	beq	ripp_countzero
	bra	nofing
ripp_tcb:
	jsr	get_end_val(pc)
	move.l	d1,a1
	jsr	fix_curr(pc)
	subq.l	#1,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq	endkallebajsare2
	eor.w	#$770,$ffff8242.w
	addq.l	#1,a0
	cmp.l	a1,a0
	bge.s	endkallebajsare2
	cmp.b	#"A",(a0)
	bne.s	.loop
	cmp.b	#"N",1(a0)
	bne.s	.loop
	cmp.b	#" ",2(a0)
	bne.s	.loop
	cmp.b	#"C",3(a0)
	bne.s	.loop
	cmp.b	#"O",4(a0)
	bne.s	.loop
	cmp.b	#"O",5(a0)
	bne.s	.loop
	cmp.b	#"L",6(a0)
	bne.s	.loop
	cmp.b	#".",7(a0)
	bne.s	.loop
	bra.s	endkallebajsare2
ripp_mad:
	jsr	get_end_val(pc)
	move.l	d1,a1
	jsr	fix_curr(pc)
	subq.l	#2,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq.s	endkallebajsare2
	eor.w	#$770,$ffff8242.w
	addq.l	#2,a0
	cmp.l	a1,a0
	bge.s	endkallebajsare2
	cmp.w	#$6000,(a0)
	bne.s	.loop
	cmp.w	#$6000,4(a0)
	bne.s	.loop
	cmp.w	#$6000,8(a0)
	bne.s	.loop
endkallebajsare2:
	jsr	fix_curr2(pc)
	move.w	#$777,$ffff8242.w
	bra	nofing
ripp_countzero:
	jsr	get_end_val(pc)
	move.l	d1,a1
	jsr	fix_curr(pc)
	subq.l	#2,a0
.loop:
	cmp.b	#1,$fffffc02.w
	beq.s	endkallebajsare2
	eor.w	#$770,$ffff8242.w
	addq.l	#2,a0
	cmp.l	a1,a0
	bge.s	endkallebajsare2
	cmp.b	#$60,(a0)
	bne.s	.loop
	cmp.w	#$6000,2(a0)
	bne.s	.loop
	cmp.w	#$6000,6(a0)
	bne.s	.loop
	bra.s	endkallebajsare2
get_end_val:
	jsr	fix_promt(pc)
	lea	text5(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	cmp.l	#0,d1
	beq.s	no_new_end_val
	move.l	d1,54(a6)
	rts
no_new_end_val:
	move.l	54(a6),d1
	rts
************** ripper part ********************************
org_pal:
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bra	qul_loop
system_pal:
	movem.l	sys_pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bra	qul_loop
rprint:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.b	(a0)+,d6	;x
	move.b	(a0)+,d7	;y
	mulu	#160,d7
	mulu	#8,d7
.loop:
	move.l	d6,d1
	move.l	d7,d0
	move.l	d1,d2
	and.w	#1,d1
	lsr.l	#1,d2
	lsl.l	#3,d2
	add.l	d1,d2
	add.l	d2,d0
	add.l	26(a6),d0
	move.l	d0,a1
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	endit
	lsl.w	#3,d0
	move.l	526(a6),a3
	add.l	d0,a3
	move.b	(a3)+,(a1)
	move.b	(a3)+,160*1(a1)
	move.b	(a3)+,160*2(a1)
	move.b	(a3)+,160*3(a1)
	move.b	(a3)+,160*4(a1)
	move.b	(a3)+,160*5(a1)
	move.b	(a3)+,160*6(a1)
	addq.l	#1,d6	
	bra.s	.loop
endit:
	rts
hexer:
	moveq	#0,d1
	move.l	a0,a5
	move.l	d0,d5
	subq.l	#1,d5
.loop:
	lea	hextab(pc),a3
	moveq	#0,d0
	move.b	(a5)+,d0
	move.b	d0,d1
	and.b	#$0f,d0
	and.b	#$f0,d1
	lsr.b	#4,d1
	move.b	(a3,d1.w),484(a6)
	move.b	(a3,d0.w),485(a6)
	lea	482(a6),a0
	jsr	rprint(pc)
	addq.b	#2,482(a6)
	subq.l	#1,d5
	bpl.s	.loop
	rts
hexer2:
	move.w	#"00",484(a6)
	move.w	488(a6),d1

	btst	#3,d1
	beq.s	.no_bit0
	move.b	#"1",484(a6)
.no_bit0:
	btst	#2,d1
	beq.s	.no_bit1
	move.b	#"1",485(a6)
.no_bit1:
	
	lea	482(a6),a0
	jsr	rprint(pc)

	addq.b	#2,482(a6)
	move.w	#"00",484(a6)
	move.w	488(a6),d1
	
	btst	#1,d1
	beq.s	.no_bit2
	move.b	#"1",484(a6)
.no_bit2:
	btst	#0,d1
	beq.s	.no_bit3
	move.b	#"1",485(a6)
.no_bit3:
	lea	482(a6),a0
	jsr	rprint(pc)
	rts

smal:
	subq.w	#1,24(a6)
	cmp.w	#-2,24(a6)
	bne.s	rajraj
	move.w	#-1,24(a6)
rajraj:
	move.b	#5,482(a6)
	move.b	#24,483(a6)
	lea	25(a6),a0
	moveq	#1,d0
	addq.w	#1,24(a6)
	jsr	hexer(pc)
	subq.w	#1,24(a6)

	jsr	ut_med_screen(pc)
	bra	qul_loop
bred:
	addq.w	#1,24(a6)
	cmp.w	#40,24(a6)
	bne.s	rajraj2
	move.w	#39,24(a6)
rajraj2:
	move.b	#5,482(a6)
	move.b	#24,483(a6)
	lea	25(a6),a0
	moveq	#1,d0
	addq.w	#1,24(a6)
	jsr	hexer(pc)
	subq.w	#1,24(a6)
	jsr	ut_med_screen(pc)
	bra	qul_loop
ut_med_screen:
	move.b	#16,482(a6)
	move.b	#23,483(a6)
	move.l	58(a6),d0
	and.l	#$00ffffff,d0
	move.l	d0,58(a6)
	lea	58(a6),a0
	moveq	#4,d0
	jsr	hexer(pc)

	lea	byte_blatt(pc),a4
	moveq	#0,d3
	move.w	498(a6),d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a4,d3.w),a4

	lea	bit_planes(pc),a0
	move.w	488(a6),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a3
	move.l	58(a6),a0
	move.l	26(a6),a1
	moveq	#0,d2
	move.w	#182,d0
jloop:
	move.l	a1,a2
	move.w	24(a6),d1
	bmi.s	ollalla
	cmp.w	#19,d1
	ble.s	.loop2
	move.w	24(a6),d2
	sub.w	#19,d2
	move.w	20(a6),d1
	add.w	d1,d1
	mulu	d1,d2
	move.w	#19,d1
.loop2:
	jsr	(a3)
	dbra	d1,.loop2
ollalla:
	cmp.w	#19,24(a6)
	bge.s	.nono
	jsr	(a4)
	cmp.w	#18,24(a6)
	bge.s	.nono
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	lea	160(a1),a1
	add.w	d2,a0
	dbra	d0,jloop
	rts
.nono:
	lea	160(a1),a1
	add.w	d2,a0
	add.w	498(a6),a0
	dbra	d0,jloop
	rts
byte0:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
byte1:
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
byte2:
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
byte3:
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
byte4:
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	rts
byte5:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	rts
byte6:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	rts
byte7:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	rts
bit0:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit1:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit2:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit3:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit4:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit5:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit6:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit7:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	rts
bit8:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit9:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit10:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit11:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit12:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit13:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit14:
	move.b	#0,(a2)+
	move.b	#0,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
bit15:
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	rts
get_total:
	moveq	#0,d0
	move.w	488(a6),d1
	btst	#0,d1
	beq.s	.no_bit0
	addq.w	#1,d0
.no_bit0:
	btst	#1,d1
	beq.s	.no_bit1
	addq.w	#1,d0
.no_bit1:
	btst	#2,d1
	beq.s	.no_bit2
	addq.w	#1,d0
.no_bit2:
	btst	#3,d1
	beq.s	.no_bit3
	addq.w	#1,d0
.no_bit3:
	rts
bitplane_onoff:
	eor.w	d0,488(a6)
	jsr	get_total(pc)
	move.w	d0,20(a6)
	move.b	#35,482(a6)
	move.b	#23,483(a6)
	lea	489(a6),a0
	moveq	#1,d0
	jsr	hexer2(pc)
	jsr	ut_med_screen(pc)
	bra	qul_loop
ono:
	moveq	#8,d0
	bra.s	bitplane_onoff
dozo:
	moveq	#4,d0
	bra.s	bitplane_onoff
trezo:
	moveq	#2,d0
	bra.s	bitplane_onoff
quatorzo:
	moveq	#1,d0
	bra.s	bitplane_onoff

an_spez:
	addq.l	#2,58(a6)
	jsr	ut_med_screen(pc)
	bra	qul_loop	
ner:
	cmp.w	#0,22(a6)
	beq.s	an_spez
	moveq	#0,d0
	move.w	24(a6),d0
	addq.w	#1,d0
	move.w	20(a6),d1
	add.w	d0,d0
	mulu	d1,d0
	add.w	498(a6),d0
	cmp.w	#2,22(a6)
	bne.s	no_speed2
	mulu	#50,d0
no_speed2:
	cmp.w	#3,22(a6)
	bne.s	no_speed3
	mulu	#200,d0
no_speed3:
	add.l	d0,58(a6)
	jsr	ut_med_screen(pc)
	bra	qul_loop	
an_spez2:
	subq.l	#2,58(a6)
	bpl.s	hoho_i_skogenx
	move.l	#0,58(a6)
hoho_i_skogenx:
	jsr	ut_med_screen(pc)
	bra	qul_loop	
upp:
	cmp.w	#0,22(a6)
	beq.s	an_spez2
	moveq	#0,d0
	move.w	24(a6),d0
	addq.w	#1,d0
	move.w	20(a6),d1
	add.w	d0,d0
	mulu	d1,d0
	add.w	498(a6),d0
	cmp.w	#2,22(a6)
	bne.s	no_speedx2
	mulu	#50,d0
no_speedx2:
	cmp.w	#3,22(a6)
	bne.s	no_speedx3
	mulu	#200,d0
no_speedx3:
	sub.l	d0,58(a6)
	jsr	ut_med_screen(pc)
	bra	qul_loop	
slow:
	clr.w	22(a6)
	bra	qul_loop
med:
	move.w	#1,22(a6)
	bra	qul_loop
fast:
	move.w	#2,22(a6)
	bra	qul_loop
turbo:
	move.w	#3,22(a6)
	bra	qul_loop
wipe_screen:
	move.l	26(a6),a0
	move.w	#7999,d0
.loop:
	clr.l	(a0)+
	dbra	d0,.loop
	rts
whole:
	jsr	wipe_screen(pc)
	lea	byte_blatt(pc),a4
	moveq	#0,d3
	move.w	498(a6),d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a4,d3.w),a4

	lea	bit_planes(pc),a0
	move.w	488(a6),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a3
	move.l	58(a6),a0
	move.l	26(a6),a1
	moveq	#0,d2
	move.w	#199,d0
	jsr	jloop(pc)
.loop:
	cmp.w	#0,534(a6)
	beq.s	.no_spec
	jsr	vsync2(pc)
	jsr	show_spectrum(pc)
.no_spec:
	jsr	get_key(pc)
	cmp.b	#1,d0
	bne.s	.loop
	bra	do_ripp2

byte_inc:
	addq.w	#1,498(a6)
	cmp.w	#8,498(a6)
	bne.s	no_inc
	move.w	#7,498(a6)
no_inc:
	move.b	#14,482(a6)
	move.b	#24,483(a6)
	lea	499(a6),a0
	moveq	#1,d0
	jsr	hexer(pc)
	jsr	ut_med_screen(pc)
	bra	qul_loop
byte_dec:
	subq.w	#1,498(a6)
	bpl.s	no_dec
	move.w	#0,498(a6)
no_dec:
	move.b	#14,482(a6)
	move.b	#24,483(a6)
	lea	499(a6),a0
	moveq	#1,d0
	jsr	hexer(pc)
	jsr	ut_med_screen(pc)
	bra	qul_loop
rf6:
	eor.w	#1,534(a6)
	moveq	#10,d0
.loop:
	move.l	d0,-(sp)
	jsr	vsync(pc)
	jsr	vsync2(pc)
	move.l	(sp)+,d0
	dbra	d0,.loop
	cmp.w	#0,534(a6)
	bne	qul_loop
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bra	qul_loop
other_left:
	subq.w	#8,504(a6)
	move.w	504(a6),d0
	cmp.w	500(a6),d0
	bge.s	.no_left
	move.w	500(a6),504(a6)
.no_left:
	bra	grabber_loop
other_right:
	addq.w	#8,504(a6)
	cmp.w	#160,504(a6)
	bne.s	.no_right
	move.w	#152,504(a6)
.no_right:
	bra	grabber_loop
other_down:
	add.w	#160,506(a6)
	cmp.w	#160*(200-5),506(a6)
	bne.s	.no_dwn
	move.w	#160*(200-6),506(a6)
.no_dwn:
	bra	grabber_loop
other_upp:
	sub.w	#160,506(a6)
	move.w	502(a6),d0
	add.w	#160*11,d0
	cmp.w	506(a6),d0
	ble.s	.no_upp
	move.w	502(a6),d0
	add.w	#160*10,d0
	move.w	d0,506(a6)
.no_upp:
	bra	grabber_loop

xcopy_left:
	jsr	xcode1(pc)
	bra	grabber_loop
xcopy_right:
	jsr	xcode2(pc)
	bra	grabber_loop
xcopy_down:
	jsr	xcode3(pc)
	bra	grabber_loop
xcopy_upp:
	jsr	xcode4(pc)
	bra	grabber_loop


left:
	cmp.w	#1,508(a6)
	beq	other_left
	cmp.w	#2,508(a6)
	beq.s	xcopy_left
	subq.w	#8,500(a6)
	bpl.s	no_left
	move.w	#0,500(a6)
no_left:
	bra	grabber_loop
do_right:
	cmp.w	#1,508(a6)
	beq	other_right
	cmp.w	#2,508(a6)
	beq.s	xcopy_right
	addq.w	#8,500(a6)
	cmp.w	#160,500(a6)
	bne.s	no_right
	move.w	#152,500(a6)
no_right:
	bra	grabber_loop
dwn:
	cmp.w	#1,508(a6)
	beq	other_down
	cmp.w	#2,508(a6)
	beq.s	xcopy_down
	add.w	#160,502(a6)
	cmp.w	#160*(200-15),502(a6)
	bne.s	no_dwn
	move.w	#160*(200-16),502(a6)
no_dwn:
	bra	grabber_loop
angelic_upp:
	cmp.w	#1,508(a6)
	beq	other_upp
	cmp.w	#2,508(a6)
	beq	xcopy_upp
	sub.w	#160,502(a6)
	bpl.s	no_upp
	move.w	#0,502(a6)
no_upp:
	bra	grabber_loop
mark:
	move.w	#1,508(a6)
	bra	grabber_loop
lamer_no_screen:
	moveq	#-1,d0
	move.w	$ffff8240.w,d1
.loop:
	move.w	#$700,$ffff8240.w
	dbra	d0,.loop
	move.w	d1,$ffff8240.w
	bra	grabber_loop
copy_left:
	jsr	xcode1(pc)
	bra	copy_blk_loop
copy_right:
	jsr	xcode2(pc)
	bra	copy_blk_loop
copy_down:
	jsr	xcode3(pc)
	bra	copy_blk_loop
copy_upp:
	jsr	xcode4(pc)
	bra	copy_blk_loop
xcode1:
	cmp.w	#0,500(a6)
	beq.s	.no_left
	subq.w	#8,500(a6)
	subq.w	#8,504(a6)
.no_left:
	rts
xcode2:
	cmp.w	#152,504(a6)
	beq.s	.no_right
	addq.w	#8,500(a6)
	addq.w	#8,504(a6)
.no_right:
	rts
xcode3:
	cmp.w	#160*(200-6),506(a6)
	beq.s	.no_down
	add.w	#160,502(a6)
	add.w	#160,506(a6)
.no_down:
	rts
xcode4:
	cmp.w	#0,502(a6)
	beq.s	.no_upp
	sub.w	#160,502(a6)
	sub.w	#160,506(a6)
.no_upp:
	rts
paste_marked_blk:
	move.l	26(a6),a0
	add.w	514(a6),a0
	add.w	516(a6),a0
	move.l	510(a6),a1
	add.w	500(a6),a1
	add.w	502(a6),a1
	move.w	520(a6),d0
.loop:
	move.l	a0,a2
	move.l	a1,a3
	move.w	518(a6),d1
.loop2:
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	dbra	d1,.loop2
	lea	160(a0),a0
	lea	160(a1),a1
	dbra	d0,.loop
	bra.s	copy_blk_loop
wipe_grabber_screen:
	move.l	510(a6),a0
	move.l	#7999,d0
.loop:
	clr.l	(a0)+
	dbra	d0,.loop
	bra.s	copy_blk_loop
copy_blk:
	cmp.l	#0,510(a6)
	beq	lamer_no_screen
	move.w	500(a6),260(a6)
	move.w	502(a6),262(a6)
	move.w	504(a6),264(a6)
	move.w	506(a6),266(a6)

	move.w	500(a6),514(a6)
	move.w	502(a6),516(a6)
	move.w	504(a6),d1
	sub.w	500(a6),d1
	ext.l	d1
	divu	#8,d1
	move.w	d1,518(a6)

	move.w	506(a6),d1
	sub.w	502(a6),d1
	ext.l	d1
	divu	#160,d1
	addq.w	#5,d1
	move.w	d1,520(a6)
;	move.w	520(a6),$200000-4	*things that makes you go "humm"
	move.l	510(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)
copy_blk_loop:
	move.l	510(a6),a2
	jsr	cursor(pc)
	jsr	get_key4(pc)
	cmp.b	#75,d0
	beq	copy_left
	cmp.b	#77,d0
	beq	copy_right
	cmp.b	#80,d0
	beq	copy_down
	cmp.b	#72,d0
	beq	copy_upp
	cmp.b	#57,d0
	beq	paste_marked_blk
	cmp.b	#1,d0
	beq.s	x_copy
	cmp.b	#17,d0
	beq	wipe_grabber_screen
	bra.s	copy_blk_loop
x_copy:
	move.l	26(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)
	move.w	#2,508(a6)
	move.w	260(a6),500(a6)
	move.w	262(a6),502(a6)
	move.w	264(a6),504(a6)
	move.w	266(a6),506(a6)
	bra.s	grabber_loop
gf6:
	eor.w	#1,534(a6)
	cmp.w	#0,534(a6)
	bne.s	grabber_loop
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	bra.s	grabber_loop
grabber:
	jsr	wipe_screen(pc)
	lea	byte_blatt(pc),a4
	moveq	#0,d3
	move.w	498(a6),d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a4,d3.w),a4

	lea	bit_planes(pc),a0
	move.w	488(a6),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a3
	move.l	58(a6),a0
	move.l	26(a6),a1
	moveq	#0,d2
	move.w	#199,d0
	jsr	jloop(pc)
	clr.w	508(a6)
grabber_loop:
	cmp.w	#0,508(a6)
	bne.s	no_slave
	move.w	500(a6),d0
	move.w	d0,504(a6)
	move.w	502(a6),d0
	add.w	#160*10,d0
	move.w	d0,506(a6)
no_slave:
	move.l	26(a6),a2
	jsr	cursor(pc)
	jsr	get_key4(pc)
	cmp.b	#1,d0
	beq	xdo_ripp2
	cmp.b	#75,d0
	beq	left
	cmp.b	#77,d0
	beq	do_right
	cmp.b	#80,d0
	beq	dwn
	cmp.b	#72,d0
	beq	angelic_upp
	cmp.b	#50,d0
	beq	mark
	cmp.b	#46,d0
	beq	copy_blk
	cmp.b	#64,d0
	beq	gf6
	bra.s	grabber_loop
xdo_ripp2
	cmp.b	#1,$fffffc02.w
	beq.s	xdo_ripp2
	bra	do_ripp2
cursor:
	move.l	a2,a0
	add.w	500(a6),a0
	add.w	502(a6),a0
	lea	212(a6),a1
	rept	6
	move.b	(a0),(a1)+
	move.b	2(a0),(a1)+
	move.b	4(a0),(a1)+
	move.b	6(a0),(a1)+
	lea	160(a0),a0
	endr	
	move.l	a2,a0
	add.w	500(a6),a0
	add.w	502(a6),a0
	move.b	#%11111100,d0
	move.b	#%10000000,d1
	eor.b	d0,(a0)
	eor.b	d0,2(a0)
	eor.b	d0,4(a0)
	eor.b	d0,6(a0)
	lea	160(a0),a0
	rept	5
	eor.b	d1,(a0)
	eor.b	d1,2(a0)
	eor.b	d1,4(a0)
	eor.b	d1,6(a0)
	lea	160(a0),a0
	endr

**********************************************
	move.l	a2,a0
	add.w	504(a6),a0
	add.w	506(a6),a0
	lea	236(a6),a1
	rept	6
	move.b	1(a0),(a1)+
	move.b	3(a0),(a1)+
	move.b	5(a0),(a1)+
	move.b	7(a0),(a1)+
	lea	160(a0),a0
	endr	

	move.l	a2,a0
	add.w	504(a6),a0
	add.w	506(a6),a0
	move.b	#%00000001,d0
	move.b	#%00111111,d1
	rept	5
	eor.b	d0,1(a0)
	eor.b	d0,3(a0)
	eor.b	d0,5(a0)
	eor.b	d0,7(a0)
	lea	160(a0),a0
	endr
	eor.b	d1,1(a0)
	eor.b	d1,3(a0)
	eor.b	d1,5(a0)
	eor.b	d1,7(a0)
***************************************************
	move.l	a2,-(sp)
	cmp.w	#0,534(a6)
	beq.s	.no_spec
	jsr	vsync2(pc)
	jsr	show_spectrum(pc)
	bra.s	.no_fast_key
.no_spec:
	jsr	vsync(pc)
	jsr	vsync2(pc)
.no_fast_key

	move.l	(sp)+,a2
****************************************************
	move.l	a2,a0
	add.w	504(a6),a0
	add.w	506(a6),a0
	lea	236(a6),a1
	rept	6
	move.b	(a1)+,1(a0)
	move.b	(a1)+,3(a0)
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)
	lea	160(a0),a0
	endr	
****************************************************
	move.l	a2,a0
	add.w	500(a6),a0
	add.w	502(a6),a0
	lea	212(a6),a1
	rept	6
	move.b	(a1)+,(a0)
	move.b	(a1)+,2(a0)
	move.b	(a1)+,4(a0)
	move.b	(a1)+,6(a0)
	lea	160(a0),a0
	endr	
	rts
ripper_berr:
	clr.b	(a2)+
	lea	10(sp),sp
	rts
sripp1:
	move.l	42(a6),58(a6)
	bra.s	do_ripp
sripp2:
	move.l	50(a6),d0
	and.b	#$fe,d0
	move.l	d0,58(a6)
do_ripp:

	*dumm

	jsr	vsync2(pc)
	
	move.b	#0,$ffff8260.w
	move.l	26(a6),d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)


do_ripp2:
	cmp.w	#0,546(a6)
	beq.s	no_trap5
	move.l	$8.w,-(sp)
	move.l	#ripper_berr,$8.w
no_trap5:

	jsr	wipe_screen(pc)
	lea	text(pc),a0
	jsr	rprint(pc)
	lea	rtext2(pc),a0
	jsr	rprint(pc)
	lea	rtext3(pc),a0
	jsr	rprint(pc)
	lea	rtext4(pc),a0
	jsr	rprint(pc)
	move.b	#35,482(a6)
	move.b	#23,483(a6)
	lea	489(a6),a0
	moveq	#1,d0
	jsr	hexer2(pc)
	move.b	#5,482(a6)
	move.b	#24,483(a6)
	lea	25(a6),a0
	moveq	#1,d0
	addq.w	#1,24(a6)
	jsr	hexer(pc)
	subq.w	#1,24(a6)
	move.b	#14,482(a6)
	move.b	#24,483(a6)
	lea	499(a6),a0
	moveq	#1,d0
	jsr	hexer(pc)
	jsr	ut_med_screen(pc)
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
qul_loop:
	cmp.w	#0,534(a6)
	beq.s	no_spec2
	jsr	vsync2(pc)
	jsr	show_spectrum(pc)
	jsr	get_key4(pc)
	bra.s	no_fast_key2
no_spec2:
	jsr	get_key(pc)
no_fast_key2:
	cmp.b	#1,d0
	beq	exit_ripp
	cmp.b	#20,d0
	beq	copy_exit_ripp
	cmp.b	#21,d0
	beq	copy_exit_ripp2
	cmp.b	#2,d0
	beq	ono
	cmp.b	#3,d0
	beq	dozo
	cmp.b	#4,d0
	beq	trezo
	cmp.b	#5,d0
	beq	quatorzo
	cmp.b	#31,d0
	beq	slow
	cmp.b	#50,d0
	beq	med
	cmp.b	#33,d0
	beq	fast
	cmp.b	#35,d0
	beq	turbo
	cmp.b	#75,d0
	beq	smal
	cmp.b	#77,d0
	beq	bred
	cmp.b	#80,d0
	beq	ner
	cmp.b	#72,d0
	beq	upp
	cmp.b	#17,d0
	beq	whole
	cmp.b	#24,d0
	beq	org_pal
	cmp.b	#25,d0
	beq	system_pal
	cmp.b	#6,d0
	beq	byte_inc
	cmp.b	#7,d0
	beq	byte_dec
	cmp.b	#34,d0
	beq	grabber
	cmp.b	#64,d0
	beq	rf6
	bra	qul_loop
exit_ripp:
	cmp.w	#0,546(a6)
	beq.s	no_trap6
	move.l	(sp)+,$8.w
no_trap6:
	*dumm
	jsr	vsync2(pc)
	move.b	#1,$ffff8260.w
	jsr	wipe_screen(pc)
	move.w	#$000,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$000,$ffff8244.w
	move.w	#$444,$ffff8246.w
	jsr	init_screen(pc)
	bra	get_key_again
copy_exit_ripp:
	move.l	58(a6),42(a6)
	bra.s	exit_ripp
copy_exit_ripp2:
	move.l	58(a6),50(a6)
	bra.s	exit_ripp

	ifne	test=1
smart_find:
	lea	$200000,a7
.loop:
	cmp.b	#4,$ffff8001.w
	bne.s	.no_512
	cmp.l	#$80000-33280,a7	*512k
	bge	this_is_the_kloop
	bra	.guttaperka
.no_512:
	cmp.b	#10,$ffff8001.w
	bne.s	.no_4
	cmp.l	#$400000-33280,a7	*4 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_4:
	cmp.b	#9,$ffff8001.w
	bne.s	.no_25
	cmp.l	#$280000-33280,a7	*2.5 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_25:
	cmp.b	#8,$ffff8001.w
	bne.s	.no_2
	cmp.l	#$200000-33280,a7	*2 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_2:
	cmp.b	#5,$ffff8001.w
	bne.s	.no_1
	cmp.l	#$100000-33280,a7	*1 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_1:
	cmp.l	#$400000-33280,a7	*?????? meg
	bge	this_is_the_kloop
.guttaperka:
	tst.l	(a7)+
	bne.s	.loop
	tst.l	(a7)+
	bne.s	.loop
	subq.l	#8,a7
	move.l	a6,(a7)
	move.l	d0,4(a7)
	move.l	a7,a6
	addq.l	#8,a7
	move.l	#8311,d0
.loop2:
	tst.l	(a7)+
	bne.s	.xloop
	subq.l	#1,d0
	bpl.s	.loop2
	move.l	a6,a7
	move.l	(a7),a6
	move.l	4(a7),d0
	clr.l	(a7)
	clr.l	4(a7)
	bra	back_normal
.xloop:
	cmp.l	#8310,d0
	bge.s	.xloop2
	sub.l	#12,a7
	move.l	(a6),(a7)
	move.l	4(a6),4(a7)
	clr.l	(a6)+
	clr.l	(a6)+
	move.l	(a7),a6
	move.l	4(a7),d0
	clr.l	(a7)+
	clr.l	(a7)+
	addq.l	#4,a7
	bra	.loop
.xloop2:
	move.l	a6,a7
	move.l	(a7),a6
	move.l	4(a7),d0
	clr.l	(a7)+
	clr.l	(a7)+
	addq.l	#4,a7
	bra	.loop
	
graf_find:
	lea	$200.w,a7
find_hoppla:
	cmp.b	#4,$ffff8001.w
	bne.s	.no_512
	cmp.l	#$80000-33280,a7	*512k
	bge	this_is_the_kloop
	bra	.guttaperka
.no_512:
	cmp.b	#10,$ffff8001.w
	bne.s	.no_4
	cmp.l	#$400000-33280,a7	*4 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_4:
	cmp.b	#9,$ffff8001.w
	bne.s	.no_25
	cmp.l	#$280000-33280,a7	*2.5 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_25:
	cmp.b	#8,$ffff8001.w
	bne.s	.no_2
	cmp.l	#$200000-33280,a7	*2 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_2:
	cmp.b	#5,$ffff8001.w
	bne.s	.no_1
	cmp.l	#$100000-33280,a7	*1 meg
	bge	this_is_the_kloop
	bra	.guttaperka
.no_1:
	cmp.l	#$400000-33280,a7	*?????? meg
	bge	this_is_the_kloop
.guttaperka:
	tst.l	(a7)+
	bne.s	find_hoppla
	tst.l	(a7)+
	bne.s	find_hoppla
	tst.l	(a7)+
	bne	find_hoppla
	tst.l	(a7)+
	bne	find_hoppla
	sub.l	#16,a7
	move.l	d0,(a7)
	move.l	d1,4(a7)
	move.l	d2,8(a7)
	move.l	a0,12(a7)

	lea	$1000,a0
	moveq	#0,d1
	moveq	#0,d2
hio:
	eor.w	#$007,$ff8240
	eor.w	#$007,$ff8240
	move.l	a0,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w

	move.b	$fffffc02.w,d0
	cmp.b	d1,d0
	beq.s	not_new2
	move.b	d0,d1
	move.l	#8500,d2
	bra.s	go_on_man
no_repet2:
	move.l	#500,d2
	bra.s	go_on_man
not_new2:
	cmp.l	#0,d2
	beq.s	no_repet2
	subq.l	#1,d2
	moveq	#0,d0
go_on_man:
	cmp.b	#80,d0
	beq.s	down
	cmp.b	#72,d0
	beq.s	upp2
	cmp.b	#57,d0
	beq	yes
	bra.s	hio
yes:
	move.l	(a7),(a0)
	move.l	4(a7),4(a0)
	move.l	8(a7),8(a0)
	move.l	12(a7),12(a0)
	clr.l	(a7)+
	clr.l	(a7)+
	clr.l	(a7)+
	clr.l	(a7)+
	move.l	a0,a7
	move.l	(a7),d0
	move.l	4(a7),d1
	move.l	8(a7),d2
	move.l	12(a7),a0
	clr.l	(a7)
	clr.l	4(a7)
	clr.l	8(a7)
	clr.l	12(a7)
	beq	back_normal
	
down:
	lea	$100(a0),a0
	bra	hio
upp2:
	lea	-$100(a0),a0
	bra	hio
set_70000:
	lea	$70000,a7
	bra	back_normal
set_f0000:
	lea	$f0000,a7
	bra	back_normal
set_1f0000:
	lea	$1f0000,a7
	bra	back_normal
set_270000:
	lea	$270000,a7
	bra	back_normal
set_3f0000:
	lea	$3f0000,a7
	bra	back_normal
	endc

save_pos:
	cmp.w	#0,18(a6)
	beq.s	.loop
	move.l	42(a6),166(a6)
	bra.s	.loop2
.loop:
	move.l	50(a6),170(a6)
.loop2:
	jsr	print_moj„ng(pc)
	bra	get_key_again
restore_pos:
	cmp.w	#0,18(a6)
	beq.s	.loop
	move.l	166(a6),42(a6)
	bra.s	.loop2
.loop:
	move.l	170(a6),50(a6)
.loop2:
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	bra	get_key_again
trace:
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	206(a6),42(a6)
	jsr	bpkt_on(pc)
	move.l	66(a6),d0
	move.l	70(a6),d1
	move.l	$24.w,66(a6)
	move.l	$30.w,70(a6)
	move.l	a6,-(sp)
	move.l	#sune,$24.w
	move.l	a7,$30.w
	move.l	126(a6),a7
	move.l	42(a6),-(sp)
	move.w	174(a6),d2
	move.w	d2,sr
	or.w	#$8000,d2
	move.w	d2,-(sp)
	move.l	130(a6),a0
	move.l	a0,usp

	*dumm
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	472(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)

	movem.l	74(a6),d2-d7/a0-a6
	rte
sune:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
	movem.l	d2-d7/a0-a5,74(a6)
	move.l	$24.w,a0
	move.l	66(a6),$24.w
	move.l	70(a6),$30.w
	move.l	d0,66(a6)
	move.l	d1,70(a6)
	move.w	(a0)+,d0
	and.w	#$7fff,d0
	move.w	d0,174(a6)	*sr
	move.l	(a0),42(a6)	*pc
	move.l	(a0)+,206(a6)	*pc
	move.l	a0,126(a6)	*a7
	move.l	usp,a0
	move.l	a0,130(a6)	*usp
	move.l	(sp)+,122(a6)	*a6
	addq.l	#4,sp
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,134(a6)
	lea	$ffff8201.w,a0
	movep.w	(a0),d2
	lsl.l	#8,d2
	move.l	d2,472(a6)
	move.b	$ffff8260.w,476(a6)
	jsr	ikbd(pc)
	jsr	restore_bluffs2(pc)
	jsr	bpkt_off(pc)
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	jsr	print_regs(pc)
	jsr	print_moj„ng(pc)
	bra	get_key_again
trace2:
	move.l	206(a6),42(a6)
	move.l	42(a6),a0
	move.w	(a0),d0
	move.w	d0,d1
	and.w	#%1111111111000000,d1	*jsr
	cmp.w	#%0100111010000000,d1
	beq.s	real_trace2
	move.w	d0,d1
	and.w	#%1111000011111000,d1	*dbcc
	cmp.w	#%0101000011001000,d1
	beq.s	real_trace2
	move.w	d0,d1
	and.w	#%1111000000000000,d1	*bsr/bcc/bra
	cmp.w	#%0110000000000000,d1
	beq.s	real_trace2
	move.w	d0,d1
	and.w	#%1111111111110000,d1	*trap
	cmp.w	#%0100111001000000,d1
	beq.s	real_trace2
	bra	trace
real_trace2:
	move.w	#0,204(a6)
	lea	372(a6),a0
	move.l	42(a6),a1
	jsr	decode(pc)
	jsr	clear_text(pc)

	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	bpkt_on(pc)

	moveq	#0,d0
	move.w	6(a6),d0
	move.l	206(a6),a0
	add.l	d0,a0

	move.l	$24.w,-(sp)
	move.l	$30.w,-(sp)
	move.l	(a0),-(sp)
	move.w	4(a0),-(sp)
	move.l	a0,542(a6)
	move.w	#$4ef9,(a0)
	lea	back_trace2(pc),a1
	move.l	a1,2(a0)	
	move.l	a6,-(sp)
	move.l	a7,$30.w
	move.l	126(a6),a7
	move.l	42(a6),-(sp)	
	move.l	130(a6),a0
	move.l	a0,usp

	*dumm
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	472(a6),d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)

	move.w	174(a6),sr
	movem.l	66(a6),d0-d7/a0-a6
	rts

back_trace2:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
mega_sun:
	movem.l	d0-d7/a0-a5,66(a6)
	move.l	$24.w,126(a6)	*a7
	move.l	(sp)+,122(a6)	*a6
	addq.l	#4,sp

	move.l	542(a6),a0
	clr.l	542(a6)
	move.w	(sp)+,4(a0)
	move.l	(sp)+,(a0)
	move.l	(sp)+,$30.w
	move.l	(sp)+,$24.w
	move.l	a0,42(a6)
	move.l	42(a6),206(a6)
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,134(a6)
	lea	$ffff8201.w,a0
	movep.w	(a0),d2
	lsl.l	#8,d2
	move.l	d2,472(a6)
	move.b	$ffff8260.w,476(a6)
	jsr	ikbd(pc)
	jsr	restore_bluffs2(pc)
	jsr	bpkt_off(pc)
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	jsr	print_regs(pc)
	jsr	print_moj„ng(pc)
	cmp.w	#1,204(a6)
	beq	status_berr
	cmp.w	#2,204(a6)
	beq	status_aerr
	cmp.w	#3,204(a6)
	beq	status_ill
	bra	get_key_again

trace3:
	lea	372(a6),a0
	move.l	42(a6),a1
	jsr	decode(pc)
	jsr	clear_text(pc)
	moveq	#0,d0
	move.w	6(a6),d0
	move.l	206(a6),a0
	add.l	d0,a0
	move.w	(a0),216(a6)
	move.w	#$4afc,(a0)
	move.l	a0,218(a6)
	move.l	$10.w,212(a6)
	move.l	#illeg2,$10.w
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	206(a6),42(a6)
	jsr	bpkt_on(pc)

	move.l	66(a6),d0
	move.l	70(a6),d1
	move.l	$24.w,66(a6)
	move.l	$30.w,70(a6)
	move.l	a6,-(sp)
	move.l	a7,$30.w
	move.l	126(a6),a7
	move.l	42(a6),-(sp)
	move.l	130(a6),a0
	move.l	a0,usp

	*dumm
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	472(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)

	move.w	174(a6),sr
	movem.l	74(a6),d2-d7/a0-a6
	rts
illeg2:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
	movem.l	d2-d7/a0-a5,74(a6)
	move.l	218(a6),a1
	move.w	216(a6),(a1)
 	move.l	212(a6),$10.w
	move.l	$24.w,a0
	move.l	66(a6),$24.w
	move.l	70(a6),$30.w
	move.l	d0,66(a6)
	move.l	d1,70(a6)
	move.w	(a0)+,d0
	and.w	#$7fff,d0
	move.w	d0,174(a6)	*sr
	move.l	(a0),42(a6)	*pc
	move.l	(a0)+,206(a6)	*pc
	clr.w	212(a6)
	cmp.l	206(a6),a1
	beq.s	no_il_sign
	move.w	#1,212(a6)
no_il_sign:
	move.l	a0,126(a6)	*a7
	move.l	usp,a0
	move.l	a0,130(a6)	*usp
	move.l	(sp)+,122(a6)	*a6
	addq.l	#4,sp
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,134(a6)
	lea	$ffff8201.w,a0
	movep.w	(a0),d2
	lsl.l	#8,d2
	move.l	d2,472(a6)
	move.b	$ffff8260.w,476(a6)
	jsr	ikbd(pc)
	jsr	bpkt_off(pc)
	jsr	restore_bluffs(pc)
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	jsr	print_regs(pc)
	cmp.w	#1,212(a6)
	beq	status_ill
	bra	get_key_again

code1:
	lea	make_code,a1
	moveq	#10,d0
.loop:
	move.w	(a1)+,(a0)+
	dbra	d0,.loop
	move.l	(sp)+,214(a6)
	move.l	#back_slow,230(a6)
	bra.s	back_code
code2:
	lea	make_code2,a1
	moveq	#14,d0
.loop:
	move.w	(a1)+,(a0)+
	dbra	d0,.loop
	move.l	(sp)+,222(a6)
	move.l	#back_slow,238(a6)
	bra.s	back_code
make_code2:
	cmp.b	#1,$fffffc02.w		;6
	beq.s	not_another		;2
make_code:
	cmp.l	#$12345678,2(a7)	;8
	beq.s	not_another		;2
	bset	#7,(a7)			;4
	rte				;2
not_another:
	jmp	$12345678		;6
trace_until:
	lea	text15(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	cmp.l	206(a6),d1
	beq	nofing
	move.l	d1,-(sp)
	jsr	fix_promt(pc)
	lea	212(a6),a0
	cmp.w	#0,268(a6)
	beq	code1
	cmp.w	#1,268(a6)
	beq.s	code2
	bra.s	code2
back_code:
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	206(a6),42(a6)
	jsr	bpkt_on(pc)
	move.l	66(a6),d0
	move.l	70(a6),d1
	move.l	$24.w,66(a6)
	move.l	$30.w,70(a6)
	move.l	a6,-(sp)
	lea	212(a6),a0
	move.l	a0,$24.w
	move.l	a7,$30.w
	move.l	126(a6),a7
	move.l	42(a6),-(sp)
	move.w	174(a6),d3
	move.w	d3,sr
	or.w	#$8000,d3
	move.w	d3,-(sp)
	move.l	130(a6),a0
	move.l	a0,usp

	*dumm
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	472(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)

	movem.l	74(a6),d2-d7/a0-a6
	rte
back_slow:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
	movem.l	d2-d7/a0-a5,74(a6)
	move.l	$24.w,a0
	move.l	66(a6),$24.w
	move.l	70(a6),$30.w
	move.l	d0,66(a6)
	move.l	d1,70(a6)
	move.w	(a0)+,d0
	and.w	#$7fff,d0
	move.w	d0,174(a6)	*sr
	move.l	(a0),42(a6)	*pc
	move.l	(a0)+,206(a6)	*pc
	move.l	a0,126(a6)	*a7
	move.l	usp,a0
	move.l	a0,130(a6)	*usp
	move.l	(sp)+,122(a6)	*a6
	addq.l	#4,sp
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,134(a6)
	lea	$ffff8201.w,a0
	movep.w	(a0),d2
	lsl.l	#8,d2
	move.l	d2,472(a6)
	move.b	$ffff8260.w,476(a6)
	jsr	ikbd(pc)
	jsr	restore_bluffs(pc)
	jsr	bpkt_off(pc)
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	jsr	print_regs(pc)
	jsr	print_moj„ng(pc)
	bra	get_key_again
breakpoint:
	lea	text9(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi.s	nofing2
	jsr	set_bpkt(pc)
	jsr	print_decoding(pc)
nofing2:
	jsr	fix_promt(pc)
	bra	get_key_again
set_bpkt:
	lea	188(a6),a1
	moveq	#3,d0	
bpkt_loop:
	cmp.l	#0,(a1)
	beq.s	set_bpkt2
	cmp.l	(a1),d1
	beq.s	remover
	addq.l	#4,a1
	dbra	d0,bpkt_loop
	jsr	colerr(pc)
	bra.s	nofing2
set_bpkt2:
	move.l	d1,(a1)
	bra.s	nofing2
remover:
	clr.l	(a1)
	bra.s	nofing2
fix_bpkt:
	cmp.l	206(a6),a1
	beq.s	pc_mark
hoho:
	cmp.l	188(a6),a1
	beq.s	bpkt1
	cmp.l	192(a6),a1
	beq.s	bpkt2
	cmp.l	196(a6),a1
	beq.s	bpkt3
	cmp.l	200(a6),a1
	beq.s	bpkt4
empty:
	rts
pc_mark:
	move.b	#"[",(a0)+
	move.b	#"p",(a0)+
	move.b	#"c",(a0)+
	move.b	#"]",(a0)+
	move.b	#" ",(a0)+
	bra.s	hoho
bpkt1:
	tst.l	188(a6)
	beq.s	empty
	move.b	#"[",(a0)+
	move.b	#"1",(a0)+
	move.b	#"]",(a0)+
	rts
bpkt2:
	tst.l	192(a6)
	beq.s	empty
	move.b	#"[",(a0)+
	move.b	#"2",(a0)+
	move.b	#"]",(a0)+
	rts
bpkt3:
	tst.l	196(a6)
	beq.s	empty
	move.b	#"[",(a0)+
	move.b	#"3",(a0)+
	move.b	#"]",(a0)+
	rts
bpkt4:
	tst.l	200(a6)
	beq.s	empty
	move.b	#"[",(a0)+
	move.b	#"4",(a0)+
	move.b	#"]",(a0)+
	rts
colerr:
	move.w	#$700,$ffff8240.w
	move.w	#$700,$ffff8244.w
	move.w	#-1,d0
.loop:
	nop
	nop
	dbra	d0,.loop
	move.w	#0,$ffff8240.w
	move.w	#0,$ffff8244.w
	rts
kill_bpkts:
	lea	text10(pc),a0
	jsr	put_promt(pc)
	lea	292(a6),a0
	cmp.b	#"y",(a0)
	beq.s	kill_all_bpkts
	bra	nofing
kill_all_bpkts:
	clr.l	188(a6)
	clr.l	192(a6)
	clr.l	196(a6)
	clr.l	200(a6)
	bra	nofing
bpkt_on:
	move.l	188(a6),a0
	cmp.l	#0,a0
	beq.s	nbp
	move.w	(a0),180(a6)
	move.w	#$4afc,(a0)
nbp:
	move.l	192(a6),a0
	cmp.l	#0,a0
	beq.s	nbp2
	move.w	(a0),182(a6)
	move.w	#$4afc,(a0)
nbp2:
	move.l	196(a6),a0
	cmp.l	#0,a0
	beq.s	nbp3
	move.w	(a0),184(a6)
	move.w	#$4afc,(a0)
nbp3:
	move.l	200(a6),a0
	cmp.l	#0,a0
	beq.s	nbp4
	move.w	(a0),186(a6)
	move.w	#$4afc,(a0)
nbp4:
	rts
bpkt_off:
	move.l	188(a6),a0
	cmp.l	#0,a0
	beq.s	xnbp
	move.w	180(a6),(a0)
xnbp:
	move.l	192(a6),a0
	cmp.l	#0,a0
	beq.s	xnbp2
	move.w	182(a6),(a0)
xnbp2:
	move.l	196(a6),a0
	cmp.l	#0,a0
	beq.s	xnbp3
	move.w	184(a6),(a0)
xnbp3:
	move.l	200(a6),a0
	cmp.l	#0,a0
	beq.s	xnbp4
	move.w	186(a6),(a0)
xnbp4:
	rts

berr:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
	move.w	#1,204(a6)
	addq.l	#8,$24.w
	tst.l	542(a6)
	bne	mega_sun
go_sune:
	movem.l	d2-d7/a0-a5,74(a6)
	move.l	$24.w,a0
	move.l	66(a6),$24.w
	move.l	70(a6),$30.w
	move.l	d0,66(a6)
	move.l	d1,70(a6)
	move.w	(a0)+,d0
	and.w	#$7fff,d0
	move.w	d0,174(a6)	*sr
	move.l	(a0),42(a6)	*pc
	move.l	(a0)+,206(a6)	*pc
	move.l	a0,126(a6)	*a7
	move.l	usp,a0
	move.l	a0,130(a6)	*usp
	move.l	(sp)+,122(a6)	*a6
	addq.l	#4,sp
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,134(a6)
	lea	$ffff8201.w,a0
	movep.w	(a0),d2
	lsl.l	#8,d2
	move.l	d2,472(a6)
	move.b	$ffff8260.w,476(a6)
	jsr	ikbd(pc)
	jsr	bpkt_off(pc)
	jsr	restore_bluffs(pc)
	jsr	print_decoding(pc)
	jsr	print_data(pc)
	jsr	print_regs(pc)
	cmp.w	#1,204(a6)
	beq.s	status_berr
	cmp.w	#2,204(a6)
	beq.s	status_aerr
	cmp.w	#3,204(a6)
	beq.s	status_ill
	bra	get_key_again
ikbd:	
;	btst	#1,$fffffc00.w
;	beq.s	ikbd
;	move.b	#$11,$fffffc02.w
	rts
status_berr:
	lea	text11(pc),a0
go_break:
	jsr	put_promt2(pc)
	bra	nofing
status_aerr:
	lea	text12(pc),a0
	bra.s	go_break
status_ill:
	jsr	test_breakpoint(pc)
	lea	text13(pc),a0
	bra.s	go_break
test_breakpoint:
	lea	text14(pc),a0
	move.l	42(a6),d1
	cmp.l	188(a6),d1
	beq.s	breakpoint1
	cmp.l	192(a6),d1
	beq.s	breakpoint2
	cmp.l	196(a6),d1
	beq.s	breakpoint3
	cmp.l	200(a6),d1
	beq.s	breakpoint4
	rts
breakpoint1:
	clr.l	188(a6)
	bra.s	go_break
breakpoint2:
	clr.l	192(a6)
	bra.s	go_break
breakpoint3:
	clr.l	196(a6)
	bra.s	go_break
breakpoint4:
	clr.l	200(a6)
	bra.s	go_break
	
addrerr:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
	move.w	#2,204(a6)
	addq.l	#8,$24.w
	tst.l	542(a6)
	bne	mega_sun
	bra	go_sune
illeg:
	move.l	a7,$24.w
	move.l	$30.w,a7
	move.l	a6,-(sp)
	move.l	4(sp),a6
	move.w	#3,204(a6)
	tst.l	542(a6)
	bne	mega_sun
	bra	go_sune
super_pc:
	eor.w	#1,210(a6)
	move.l	42(a6),206(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	bra	get_key_again
restore_bluffs:
	*dumm
	jsr	vsync2(pc)
	move.b	#1,$ffff8260.w
	move.l	26(a6),d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	move.w	#$000,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$000,$ffff8244.w
	move.w	#$444,$ffff8246.w
	rts
restore_bluffs2:
	*dumm
	jsr	vsync2(pc)
	move.b	#1,$ffff8260.w
 	move.l	26(a6),d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)
	move.w	#$000,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$000,$ffff8244.w
	move.w	#$444,$ffff8246.w
	rts
set_code:
	lea	text16(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,268(a6)
	bra	nofing
activate_traps:
	lea	text17(pc),a0
	jsr	put_promt(pc)
	cmp.b	#"y",292(a6)
	bne	nofing	
	move.l	#berr,$8.w
	move.l	#addrerr,$c.w
	move.l	#illeg,$10.w
	bra	nofing

***************************************************************
***************************************************************
* Dma Dma Dma Dma Dma Dma Dma Dma Dma Dma Dma Dma Dma Dma Dma *
***************************************************************
***************************************************************

dma_shit:
	btst	#1,$fffffc00.w	
	beq.s	dma_shit
	move.b	#$13,$fffffc02.w	
	
	move.w	sr,d5
	move.w	#$2700,sr			
	move.b	$fffffa07.w,d6
	lsl.w	#8,d6
	move.b	$fffffa09.w,d6
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	tst.w	270(a6)
	beq.s	drivea_side0
	cmp.w	#1,270(a6)
	beq.s	drivea_side1
	cmp.w	#3,270(a6)
	beq.s	driveb_side1
	move.l	#$0e0e0303,$ffff8800.w
	bra.s	endrive
driveb_side1:
	move.l	#$0e0e0202,$ffff8800.w
	bra.s	endrive
drivea_side0:
	move.l	#$0e0e0505,$ffff8800.w
	bra.s	endrive
drivea_side1:
	move.l	#$0e0e0404,$ffff8800.w
endrive:
	lea	$ffff8604.w,a0
	move.l	282(a6),-(sp)
	move.b	3(sp),$ffff860d.w
	move.b	2(sp),$ffff860b.w
	move.b	1(sp),$ffff8609.w
	addq.l	#4,sp
	
	bsr	reset

	move.l	#$40000,d3
	moveq	#$4,d4
	bsr	restore
	tst.l	d3
	bmi.s	dma_fail2

	move.w	278(a6),d0
	move.w	276(a6),d1
	move.w	274(a6),d7
	bra.s	forbi
load_loop:
	tst.w	272(a6)
	beq	do_load
	bra	do_save
back_loop:
	addq.w	#1,d0
	cmp.w	280(a6),d0
	ble.s	no_notnow
	moveq	#1,d0
	addq.w	#1,d1
forbi:
	move.l	#$40000,d3
	moveq	#$4,d4
	bsr	seek_track
	tst.l	d3
	bmi.s	dma_fail2
no_notnow:
	dbf	d7,load_loop
	bsr.s	restore_ikbd
	rts
;	bra	get_key_again
dma_fail2:
	bsr.s	restore_ikbd
	lea	text24(pc),a0
	jsr	put_promt2(pc)
	jsr	fix_promt(pc)
	rts
;	bra	nofing
restore_ikbd:
	move.w	d5,sr
	move.b	d6,$fffffa09.w
	lsr.w	#8,d6
	move.b	d6,$fffffa07.w
.loop:
	btst	#1,$fffffc00.w
	beq.s	.loop
	move.b	#$11,$fffffc02.w
	jsr	init_screen(pc)
	moveq	#0,d1
	move.b	$ffff8609.w,d1
	lsl.l	#8,d1
	move.b	$ffff860b.w,d1
	lsl.l	#8,d1
	move.b	$ffff860d.w,d1
	lea	372(a6),a0
	move.l	#"DMA:",(a0)+
	jsr	real_long(pc)
	move.w	#1,12(a6)
	move.w	#24,14(a6)
	jsr	start_print(pc)
.loop2:
	jsr	get_key(pc)
	cmp.b	#1,d0
	bne.s	.loop2
	jsr	init_screen(pc)
	rts
do_load:
	move.l	#$40000,d3
	moveq	#$4,d4
	bsr	load_sec
	tst.l	d3
	bmi.s	dma_fail2
	bra	back_loop
do_save:
	move.l	#$40000,d3
	moveq	#$4,d4
	bsr.s	save_sec
	tst.l	d3
	bmi	dma_fail2
	bra	back_loop

**********************************************************
* reset fdc shit *****************************************
**********************************************************

reset:
;	move.w	#$d0,(a0)	
;	bsr	big_wat
	rts

**********************************************************
* restore track ******************************************
**********************************************************

restore:
	tst.l	d4
	bmi	dma_fail
	move.w	#$80,2(a0)
	nop
	nop
	move.w	#3,(a0)
	bsr	big_wat
wat4:
	tst.l	d3
	bmi	dma_fail
	subq.l	#1,d3
	btst	#5,$fffffa01.w
	bne.s	wat4
	subq.l	#1,d4
	moveq	#$10,d2
	and.w	(a0),d2
	bne.s	restore
	rts

**********************************************************
* save sector ********************************************
**********************************************************

save_sec:
	tst.l	d4
	bmi	dma_fail
	move.w	#$184,2(a0)
	nop
	nop
	move.w	d0,(a0)
	nop
	nop
	move.w	#$190,2(a0)
	move.w	#$90,2(a0)
	move.w	#$190,2(a0)
	nop
	nop
	move.w	#1,(a0)
	nop
	nop
	move.w	#$180,2(a0)
	nop
	nop
	move.w	#$a0,(a0)
	bsr	big_wat
wat3:
	tst.l	d3
	bmi	dma_fail
	subq.l	#1,d3
	btst	#5,$fffffa01.w
	bne.s	wat3
	subq.l	#1,d4
	moveq	#$58,d2
	and.w	(a0),d2
	bne.s	save_sec
	rts

**********************************************************
* load sector ********************************************
**********************************************************

load_sec:
	tst.l	d4
	bmi	dma_fail
	move.w	#$84,2(a0)
	nop
	nop
	move.w	d0,(a0)
	nop
	nop
	move.w	#$90,2(a0)
	move.w	#$190,2(a0)
	move.w	#$90,2(a0)
	nop
	nop
	move.w	#1,(a0)
	nop
	nop
	move.w	#$80,2(a0)
	nop
	nop
	move.w	#$80,(a0)
	bsr.s	big_wat
wat:
	tst.l	d3
	bmi.s	dma_fail
	subq.l	#1,d3
	btst	#5,$fffffa01.w
	bne.s	wat
	subq.l	#1,d4
	moveq	#$18,d2
	and.w	(a0),d2
	bne.s	load_sec
	rts

**********************************************************
* seek track *********************************************
**********************************************************

seek_track:
	tst.l	d4
	bmi.s	dma_fail
	move.w	#$86,2(a0)
	nop
	nop
	move.w	d1,(a0)
	nop
	nop
	move.w	#$80,2(a0)
	nop
	nop
	move.w	#$13,(a0)
	bsr.s	big_wat
wat2:
	tst.l	d3
	bmi.s	dma_fail
	subq.l	#1,d3
	btst	#5,$fffffa01.w
	bne.s	wat2
	subq.l	#1,d4
	moveq	#$10,d2
	and.w	(a0),d2
	bne.s	seek_track
	rts

**********************************************************
* big wait ***********************************************
**********************************************************

big_wat:
	moveq	#$20,d2
.loop:
	dbf	d2,.loop
	rts

**********************************************************
* Error! *************************************************
**********************************************************

dma_fail:
	moveq	#-1,d3
	rts

***********************************************************
***********************************************************
* End Dma End Dma End Dma End Dma End Dma End Dma End Dma *
***********************************************************
***********************************************************

set_dma:
	lea	text18(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,276(a6)
	jsr	fix_promt(pc)
	lea	text19(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,278(a6)
	jsr	fix_promt(pc)
	lea	text20(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,280(a6)
	bra	nofing
load:
	move.w	#0,272(a6)
	bra.s	set_rest
save:
	move.w	#1,272(a6)
set_rest:
	lea	text21(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,270(a6)
	jsr	fix_promt(pc)
	lea	text22(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,274(a6)
	jsr	fix_promt(pc)
	lea	text23(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,282(a6)
	jsr	fix_promt(pc)
	jsr	dma_shit
	bra	get_key_again
set_vbi:
	lea	text25(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	and.l	#$00fffffe,d1
	move.l	d1,-(sp)
	jsr	fix_promt(pc)
	lea	text35(pc),a0
	jsr	put_promt(pc)
	cmp.b	#"s",292(a6)
	beq.s	returns	
	cmp.b	#"e",292(a6)
	beq.s	returne
returns:
	moveq	#0,d0
	bra.s	wait_vync	
returne:
	moveq	#-1,d0
wait_vync:	
	move.l	d0,-(sp)
	jsr	fix_promt(pc)
	lea	text36(pc),a0
	jsr	put_promt(pc)
	move.l	(sp)+,d0
	move.l	(sp)+,a5
	cmp.b	#"1",292(a6)
	beq.s	real_vbi
wait_vsync:
	move.l	a6,-(sp)
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	jsr	vsync(pc)
	move.l	(sp),a5
	move.l	4(sp),d0
	tst.l	d0
	beq.s	no_rts_blurg
	pea	yes_jojo(pc)
	move.w	sr,-(sp)
	move.w	#$007,$ffff8240.w
	jmp	(a5)
no_rts_blurg:
	move.w	#$700,$ffff8240.w
	jsr	(a5)
yes_jojo:
	move.w	#$0,$ffff8240.w
	move.l	(sp)+,a5
	move.l	(sp)+,d0
	move.l	(sp)+,a6

	cmp.b	#1,$fffffc02.w
	bne.s	wait_vsync
	jsr	fix_promt(pc)
	bra	get_key_again
fix_vbi:
	move.l	#dummy,$70.w
	bra	nofing
real_vbi:
	cmp.l	#0,a5
	beq.s	fix_vbi
	tst.l	d0
	bmi.s	no_rts_vbi
	move.l	a5,538(a6)
	move.l	#exp_vbi,$70.w
	bra	nofing
no_rts_vbi:
	move.l	a5,538(a6)
	move.l	#exp_vbi2,$70.w
	bra	nofing
exp_vbi:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	538(a6),a0
	move.w	$ffff8240.w,-(sp)
	move.w	#$700,$ffff8240.w
	jsr	(a0)
	move.w	(sp)+,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
dummy:
	rte
exp_vbi2:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	538(a6),a0
	move.w	$ffff8240.w,-(sp)
	move.w	#$007,$ffff8240.w	
	pea	yes_jojo2(pc)
	move.w	sr,-(sp)
	jmp	(a0)
yes_jojo2:
	move.w	(sp)+,$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte
	
fill_mem:
	lea	text26(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,212(a6)
	jsr	fix_promt(pc)
	lea	text5(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,216(a6)
	jsr	fix_promt(pc)
	lea	text4(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	212(a6),a0
	move.l	216(a6),a1
	move.b	d1,d4
	lsr.l	#8,d1
	move.b	d1,d5
	lsr.l	#8,d1
	move.b	d1,d6
	lsr.l	#8,d1
	move.b	d1,d7
.loop:
	cmp.l	a1,a0
	bge.s	endfillare
	move.b	d7,(a0)+
	cmp.l	a1,a0
	bge.s	endfillare
	move.b	d6,(a0)+
	cmp.l	a1,a0
	bge.s	endfillare
	move.b	d5,(a0)+
	cmp.l	a1,a0
	bge.s	endfillare
	move.b	d4,(a0)+
	bra.s	.loop
endfillare:
	jsr	fix_promt(pc)
	bra	get_key_again
copy_mem:
	lea	text27(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,212(a6)
	jsr	fix_promt(pc)
	lea	text28(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,216(a6)
	jsr	fix_promt(pc)
	lea	text29(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	212(a6),a0
	move.l	216(a6),a1
	move.l	d1,a2
.loop:
	cmp.l	a1,a0
	bge.s	endcopy
	move.b	(a0)+,(a2)+
	bra.s	.loop
endcopy:
	jsr	fix_promt(pc)
	bra	get_key_again

toggle_screen:
	movem.l	134(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w

	*dumm
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	472(a6),d2
	lsr.l	#8,d2
	lea	$ffff8201.w,a0
	movep.w	d2,(a0)
.no_rezee:
	cmp.w	#0,534(a6)
	beq.s	.no_spec
	jsr	vsync2(pc)
	jsr	show_spectrum(pc)
.no_spec:
	jsr	get_key(pc)
	cmp.b	#1,d0
	bne.s	.no_rezee
	jsr	restore_bluffs(pc)
	jsr	init_screen(pc) 

	bra	get_key_again
set_var1:
	lea	text30(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	and.b	#%11111110,d1
	move.l	d1,490(a6)
	jsr	fix_promt(pc)
	bra	get_key_again
set_var2:
	lea	text31(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	and.b	#%11111110,d1
	move.l	d1,494(a6)
	jsr	fix_promt(pc)
	bra	get_key_again
vsync:
	move.b	$ffff8209.w,d7
	move.w	#100,d6
.loop:
	dbra	d6,.loop
	cmp.b	$ffff8209.w,d7
	bne.s	vsync
	lea	$ffff8209.w,a5
	moveq	#0,d6
.wait:	move.b	(a5),d6
	beq.s	.wait
	not.w	d6
	lsr.w	d6,d6
	rts
vsync2:
	move.b	$ffff8209.w,d7
	move.w	#100,d6
.loop:
	dbra	d6,.loop
	cmp.b	$ffff8209.w,d7
	bne.s	vsync2
	rts
set_grbber_pos:
	lea	text32(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	and.b	#0,d1
	move.l	d1,510(a6)
	jsr	fix_promt(pc)
	bra	get_key_again
f1:
	move.b	#8,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#9,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#10,$ffff8800.w
	move.b	#0,$ffff8802.w
	bra	get_key_again
f2:
	cmp.l	#font,526(a6)
	beq.s	other_font
	move.l	#font,526(a6)
	jsr	init_screen(pc)
	bra	get_key_again
other_font:
	move.l	#font2,526(a6)
	jsr	init_screen(pc)
	bra	get_key_again
f3:
	eor.w	#1,536(a6)
	bra	get_key_again
f4:
	move.w	#$000,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$000,$ffff8244.w
	move.w	#$444,$ffff8246.w
	bra	get_key_again
f5:
	eor.b	#2,$ffff820a.w
	bra	get_key_again
f6:
	eor.w	#1,534(a6)
	bra	get_key_again

write_berr_on:
	move.l	$8.w,240(a6)
	move.l	#psyko_berr,$8.w
	rts
write_berr_off:
	move.l	240(a6),$8.w
	rts
psyko_berr:
	add.l	#10,sp
	rts
start_edit_data:
	cmp.w	#0,18(a6)
	bne	get_key_again

	move.l	50(a6),a0
	moveq	#0,d0

	cmp.w	#0,546(a6)
	beq.s	no_trap7
	jsr	write_berr_on
no_trap7:
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0),d0
	cmp.w	#0,546(a6)
	beq.s	no_trap8
	jsr	write_berr_off
no_trap8:
	lea	224(a6),a0
	lea	conv_hex(pc),a1
	moveq	#7,d1
.loop:
	move.l	d0,d2
	and.l	#$f,d2
	add.w	d2,d2
	move.b	(a1,d2.w),-(a0)
	lsr.l	#4,d0
	dbra	d1,.loop
	lea	224(a6),a0
	clr.l	(a0)+
	lea	216(a6),a0
	move.l	a0,212(a6)

	move.w	#62,16(a6)
	move.w	#7,228(a6)
	lea	216(a6),a2
	move.w	16(a6),12(a6)
	move.w	228(a6),14(a6)
	jsr	huj_print(pc)

edit_data:
	jsr	mega_cursor(pc)
	jsr	get_key4(pc)
	cmp.b	#1,d0
	beq	.end_get_promt2
	cmp.b	#28,d0
	beq	.end_get_promt
	cmp.b	#14,d0
	beq	.back_promt
	cmp.b	#80,d0
	beq	.edit_down
	cmp.b	#72,d0
	beq	.edit_upp
	cmp.b	#75,d0
	beq	.edit_left
	cmp.b	#77,d0
	beq	.edit_right
	lea	key_tab2(pc),a0
.loop:
	cmp.b	#-1,(a0)
	beq.s	edit_data
	cmp.b	(a0),d0
	beq.s	.key_found
	addq.l	#2,a0
	bra.s	.loop
.key_found:
	move.l	212(a6),a1
	moveq	#0,d0
	move.w	#69,d0
	sub.w	16(a6),d0
	ext.l	d0
	add.l	a6,d0
	add.l	#217,d0
	cmp.l	a1,d0
	beq.s	.not_end
	move.b	1(a0),(a1)+
	move.l	a1,212(a6)
	lea	216(a6),a2
	move.w	16(a6),12(a6)
	move.w	228(a6),14(a6)
	jsr	huj_print(pc)
	jsr	print_edit_text(pc)
	bra	edit_data
.not_end:
	move.b	1(a0),-1(a1)
	lea	216(a6),a2
	move.w	16(a6),12(a6)
	move.w	228(a6),14(a6)
	jsr	huj_print(pc)
	jsr	print_edit_text(pc)
	bra	edit_data
.edit_down:
	cmp.w	#23,228(a6)
	beq.s	.no_edit_down
	addq.w	#1,228(a6)
	jsr	.fix_shit(pc)
	jsr	print_data(pc)
.no_edit_down:
	bra	edit_data
.edit_upp:
	cmp.w	#7,228(a6)
	beq.s	.no_edit_upp
	subq.w	#1,228(a6)
	jsr	.fix_shit(pc)
	jsr	print_data(pc)
.no_edit_upp:
	bra	edit_data
.edit_left:
	move.l	212(a6),a1
	subq.l	#1,a1
	move.l	a6,d0
	add.l	#215,d0
	cmp.l	d0,a1
	beq	edit_data
	subq.l	#1,212(a6)
	bra	edit_data
.edit_right:
	move.l	212(a6),a1
	moveq	#0,d0
	move.w	#69,d0
	sub.w	16(a6),d0
	ext.l	d0
	add.l	a6,d0
	add.l	#216,d0
	cmp.l	a1,d0
	beq	edit_data
	addq.l	#1,212(a6)
	bra	edit_data

.fix_shit:
	move.w	228(a6),d0
	subq.w	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	50(a6),a0
	add.w	d0,a0
	moveq	#0,d0
	cmp.w	#0,546(a6)
	beq.s	.no_trap9
	jsr	write_berr_on
.no_trap9:
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0)+,d0
	lsl.l	#8,d0
	move.b	(a0),d0
	cmp.w	#0,546(a6)
	beq.s	.no_trap10
	jsr	write_berr_off
.no_trap10:
	lea	224(a6),a0
	lea	conv_hex(pc),a1
	moveq	#7,d1
.loop2:
	move.l	d0,d2
	and.l	#$f,d2
	add.w	d2,d2
	move.b	(a1,d2.w),-(a0)
	lsr.l	#4,d0
	dbra	d1,.loop2
	lea	224(a6),a0
	clr.l	(a0)+

	lea	216(a6),a2
	move.w	16(a6),12(a6)
	move.w	228(a6),14(a6)
	jsr	huj_print(pc)
	rts
.end_get_promt:
	jsr	get_edit_num
	move.w	228(a6),d0
	subq.w	#7,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	50(a6),a0
	add.w	d0,a0
	cmp.w	#0,546(a6)
	beq.s	.no_trap11
	jsr	write_berr_on
.no_trap11:
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	addq.l	#1,a1
	addq.l	#2,a2
	addq.l	#3,a3
	move.b	d1,d2
	lsr.l	#8,d1
	move.b	d1,d3
	lsr.l	#8,d1
	move.b	d1,d4
	lsr.l	#8,d1

	move.b	d1,(a0)
	move.b	d4,(a1)
	move.b	d3,(a2)
	move.b	d2,(a3)

	cmp.w	#0,546(a6)
	beq.s	.no_trap12
	jsr	write_berr_off
.no_trap12:
	move.l	a6,d0
	add.l	#216,d0
	move.l	d0,212(a6)
	jsr	print_decoding(pc)
	bra	.edit_down
.end_get_promt2:
	bra	get_key_again
.back_promt:
	move.l	212(a6),a1
	subq.l	#1,a1
	move.l	a6,d0
	add.l	#215,d0
	cmp.l	d0,a1
	beq	edit_data
	move.b	#"0",(a1)
	move.l	a1,212(a6)
	lea	216(a6),a2
	move.w	16(a6),12(a6)
	move.w	228(a6),14(a6)
	jsr	huj_print(pc)
	jsr	print_edit_text(pc)
	bra	edit_data
mega_cursor:
	jsr	vsync(pc)
	move.l	212(a6),d0
	sub.l	a6,d0
	sub.l	#216,d0
	cmp.l	#8,d0
	bne.s	no_fuki_over
	move.w	#7,d0
no_fuki_over:
	move.w	16(a6),d1
	ext.l	d1
	add.l	d1,d0
	move.l	26(a6),a0
	move.w	d0,d1
	and.w	#1,d0
	lsr.w	#1,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d0
	add.l	d0,a0
	move.w	228(a6),d0
	mulu	#160*8,d0
	add.w	d0,a0
	moveq	#-1,d0
	eor.b	d0,(a0)
	eor.b	d0,160*1(a0)
	eor.b	d0,160*2(a0)
	eor.b	d0,160*3(a0)
	eor.b	d0,160*4(a0)
	eor.b	d0,160*5(a0)
	eor.b	d0,160*6(a0)
	eor.b	d0,160*7(a0)
	move.l	a0,-(sp)
	jsr	vsync2(pc)
	move.l	(sp)+,a0
	eor.b	d0,(a0)
	eor.b	d0,160*1(a0)
	eor.b	d0,160*2(a0)
	eor.b	d0,160*3(a0)
	eor.b	d0,160*4(a0)
	eor.b	d0,160*5(a0)
	eor.b	d0,160*6(a0)
	eor.b	d0,160*7(a0)
	rts
get_edit_num:
	lea	216(a6),a0
	moveq	#7,d0
	moveq	#0,d1
.loop:
	move.b	(a0)+,d2
	cmp.b	#0,d2
	beq.s	.end_th
	lsl.l	#4,d1
	lea	conv_hex(pc),a1
.loop2:
	move.b	(a1),d3
	cmp.b	d2,d3
	beq.s	.found
	addq.l	#2,a1
	bra.s	.loop2
.found:
	or.b	1(a1),d1
	dbra	d0,.loop
.end_th:
	moveq	#0,d0
	rts
print_edit_text:
	jsr	get_edit_num(pc)
	move.l	d1,232(a6)
	lea	232(a6),a0
	lea	232(a6),a1
	move.b	(a1),d1
	tst.b	d1
	bne.s	.luring
	move.b	#" ",d1
.luring:
	move.b	d1,(a0)+
	move.b	1(a1),d1
	tst.b	d1
	bne.s	.luring2
	move.b	#" ",d1
.luring2:
	move.b	d1,(a0)+
	move.b	2(a1),d1
	tst.b	d1
	bne.s	.luring3
	move.b	#" ",d1
.luring3:
	move.b	d1,(a0)+
	move.b	3(a1),d1
	tst.b	d1
	bne.s	.luring4
	move.b	#" ",d1
.luring4:
	move.b	d1,(a0)+
	clr.l	(a0)+
	lea	232(a6),a2
	move.w	#71,12(a6)
	move.w	228(a6),14(a6)
	jsr	huj_print(pc)
	rts

	ifne	picc=1
ice_unpack:
	move.w	#7999,d0
.loop:
	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts
show_piccy:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	movem.l	d0-d7,$ffff8240.w
	lea	piccy(pc),a0
	move.l	26(a6),a1
	jsr	ice_unpack(pc)
	move.l	#0,a2
.loop2:
	jsr	vsync
	move.w	#4370+(800),d0
.loop3:
	dbra	d0,.loop3
	movem.l	166+32(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#510,d0
.loop4:
	dbra	d0,.loop4
	movem.l	166+64(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	vsync2
	movem.l	166(a6),d0-d7
	movem.l	d0-d7,$ffff8240.w
	cmp.w	#4,a2
	bne.s	.no_fuki_fade
	move.l	#0,a2
	lea	pal1,a0
	lea	166(a6),a1
	moveq	#47,d0
.cloop:
	move.w	(a1),d1
	cmp.w	(a0),d1
	beq.s	.no_fix
	move.w	(a0),d2
	and.w	#$00f,d1
	and.w	#$00f,d2
	cmp.w	d1,d2
	beq.s	.no_blue
	addq.w	#$001,d1
	move.w	(a1),d2
	and.w	#$ff0,d2
	or.w	d1,d2
	move.w	d2,(a1)
.no_blue:
	move.w	(a1),d1
	move.w	(a0),d2
	and.w	#$0f0,d1
	and.w	#$0f0,d2
	cmp.w	d1,d2
	beq.s	.no_green
	add.w	#$010,d1
	move.w	(a1),d2
	and.w	#$f0f,d2
	or.w	d1,d2
	move.w	d2,(a1)
.no_green:
	move.w	(a1),d1
	move.w	(a0),d2
	and.w	#$f00,d1
	and.w	#$f00,d2
	cmp.w	d1,d2
	beq.s	.no_fix
	add.w	#$100,d1
	move.w	(a1),d2
	and.w	#$0ff,d2
	or.w	d1,d2
	move.w	d2,(a1)
.no_fix:
	addq.w	#2,a0
	addq.w	#2,a1
	dbra	d0,.cloop
.no_fuki_fade:
	addq.w	#1,a2
	cmp.b	#185,$fffc02
	bne	.loop2
	rts
	endc

info_print:
	jsr	wipe_screen(pc)

	move.w	#0,12(a6)
	move.w	#0,14(a6)
	move.l	526(a6),a1
	lea	svenne_info(pc),a2
	jsr	huj_print(pc)

	move.l	472(a6),d1	*currpicadd
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#16,12(a6)
	move.w	#9,14(a6)
	jsr	start_print(pc)

	move.l	510(a6),d1	*grabber
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#42,12(a6)
	move.w	#9,14(a6)
	jsr	start_print(pc)

	move.l	188(a6),d1	*bp1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#5,12(a6)
	move.w	#7,14(a6)
	jsr	start_print(pc)
	move.l	192(a6),d1	*bp2
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#19,12(a6)
	move.w	#7,14(a6)
	jsr	start_print(pc)
	move.l	196(a6),d1	*bp3
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#33,12(a6)
	move.w	#7,14(a6)
	jsr	start_print(pc)
	move.l	200(a6),d1	*bp4
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#47,12(a6)
	move.w	#7,14(a6)
	jsr	start_print(pc)

	move.l	a6,d1		*explorer start
	sub.l	#$100+32000,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#31,12(a6)
	move.w	#11,14(a6)
	jsr	start_print(pc)

	move.l	a6,d1		*explorer end
	add.l	#1024,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#44,12(a6)
	move.w	#11,14(a6)
	jsr	start_print(pc)

	move.w	#15,12(a6)	*mem_ziz
	move.w	#13,14(a6)
	move.l	526(a6),a1

	cmp.b	#10,$ffff8001.w
	bne.s	no_4
	lea	mb(pc),a2
	bra.s	yes_go_4_it
no_4:
	cmp.b	#9,$ffff8001.w
	bne.s	no_25
	lea	mb1(pc),a2
	bra.s	yes_go_4_it
no_25:
	cmp.b	#8,$ffff8001.w
	bne.s	no_2
	lea	mb2(pc),a2
	bra.s	yes_go_4_it
no_2:
	cmp.b	#5,$ffff8001.w
	bne.s	no_1
	lea	mb3(pc),a2
	bra.s	yes_go_4_it
no_1:
	lea	mb4(pc),a2
yes_go_4_it:
	jsr	huj_print(pc)

	cmp.b	#$e0,$5.w
	bne.s	ojba
	move.w	#$0fff,212(a6)
	bra.s	ojba2
ojba:
	move.w	#$0777,212(a6)
ojba2:

	move.w	134(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#11,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	136(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#16,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	138(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#21,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	140(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#26,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	142(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#31,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	144(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#36,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	146(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#41,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	148(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#46,12(a6)
	move.w	#4,14(a6)
	jsr	start_print(pc)
	move.w	150(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#11,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	152(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#16,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	154(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#21,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	156(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#26,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	158(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#31,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	160(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#36,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	162(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#41,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
	move.w	164(a6),d1
	and.w	212(a6),d1
	lea	372(a6),a0
	jsr	real_word(pc)
	move.w	#46,12(a6)
	move.w	#5,14(a6)
	jsr	start_print(pc)
 
	move.b	$ffff8001.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#5,12(a6)
	move.w	#17,14(a6)
	jsr	start_print(pc)
	move.b	$ffff8201.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#13,12(a6)
	move.w	#17,14(a6)
	jsr	start_print(pc)
	move.b	$ffff8203.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#21,12(a6)
	move.w	#17,14(a6)
	jsr	start_print(pc)
	move.b	$ffff820a.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#29,12(a6)
	move.w	#17,14(a6)
	jsr	start_print(pc)
	move.b	476(a6),d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#37,12(a6)
	move.w	#17,14(a6)
	jsr	start_print(pc)

	move.b	$fffffa01.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#5,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa03.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#13,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa05.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#21,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa07.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#29,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa09.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#37,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa0b.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#45,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa0d.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#53,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa0f.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#61,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa11.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#69,12(a6)
	move.w	#18,14(a6)
	jsr	start_print(pc)

	move.b	$fffffa13.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#5,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa15.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#13,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa17.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#21,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa19.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#29,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa1b.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#37,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa1d.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#45,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa1f.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#53,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa21.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#61,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa23.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#69,12(a6)
	move.w	#19,14(a6)
	jsr	start_print(pc)

	move.b	$fffffa25.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#5,12(a6)
	move.w	#20,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa27.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#13,12(a6)
	move.w	#20,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa29.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#21,12(a6)
	move.w	#20,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa2b.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#29,12(a6)
	move.w	#20,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa2d.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#37,12(a6)
	move.w	#20,14(a6)
	jsr	start_print(pc)
	move.b	$fffffa2f.w,d1
	lea	372(a6),a0
	jsr	real_byte(pc)
	move.w	#45,12(a6)
	move.w	#20,14(a6)
	jsr	start_print(pc)
	
.loop:
	jsr	get_key(pc)
	cmp.b	#1,d0
	bne.s	.loop
	jsr	wipe_screen(pc)
	jsr	init_screen(pc)
	bra	get_key_again
mb:
	dc.b	"4.0",0
mb1:
	dc.b	"2.5",0
mb2:
	dc.b	"2.0",0
mb3:
	dc.b	"1.0",0
mb4:
	dc.b	"0.5",0
	even
show_spectrum:
	lea	$ffff8240.w,a5
	move.l	530(a6),a4
	move.w	#$c5,d7
	lea	$ffff8209.w,a3
	moveq	#0,d0
	moveq	#$10,d1
sync_loop:	
	move.b	(a3),d0
	beq.s	sync_loop
	sub.b	d0,d1
	lsr.w	d1,d0
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
l2000b0	nop
	lea	2(a5),a0
	move.l	a5,a1
	move.l	a5,a2
	lea	2(a4),a4
	move.w	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a0)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a1)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	move.l	(a4)+,(a2)+
	dbf	d7,l2000b0
	rts
spec:
	lea	text34(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	and.w	#$fffe,d1
	move.l	d1,530(a6)
	jsr	fix_promt(pc)
	bra	get_key_again
skip:
	cmp.w	#0,18(a6)
	beq	get_key_again
	lea	372(a6),a0
	move.l	206(a6),a1
	jsr	decode(pc)
	jsr	clear_text(pc)
	move.l	206(a6),a0
	add.w	6(a6),a0
	move.l	a0,206(a6)
	move.l	a0,42(a6)
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	move.l	206(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#72,12(a6)
	move.w	#3,14(a6)
	jsr	start_print(pc)
	bra	get_key_again
updatewindows:
	cmp.w	#0,18(a6)
	beq.s	updatedata
	jsr	super_pc_acc(pc)
	jsr	print_decoding(pc)
	jsr	koll_code_slave(pc)
	bra	get_key_again
updatedata:
	jsr	print_data(pc)
	jsr	koll_data_slave(pc)
	bra	get_key_again

set_io_data:
	lea	text37(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,212(a6)
	jsr	fix_promt(pc)
	lea	text4(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,214(a6)
	jsr	fix_promt(pc)

	lea	text38(pc),a0
	jsr	put_promt(pc)
	cmp.b	#"b",292(a6)
	beq.s	byte_move
	cmp.b	#"w",292(a6)
	beq.s	word_move
	cmp.b	#"l",292(a6)
	beq.s	long_move
	bra	get_key_again
byte_move:
	moveq	#-1,d2
	move.w	212(a6),d2
	move.l	214(a6),d1
	move.l	d2,a0
	move.b	d1,(a0)
	jsr	fix_promt(pc)
	bra	get_key_again
word_move:
	moveq	#-1,d2
	move.w	212(a6),d2
	move.l	214(a6),d1
	move.l	d2,a0
	move.w	d1,(a0)
	jsr	fix_promt(pc)
	bra	get_key_again
long_move:
	moveq	#-1,d2
	move.w	212(a6),d2
	move.l	214(a6),d1
	move.l	d2,a0
	move.l	d1,(a0)
	jsr	fix_promt(pc)
	bra	get_key_again

f7:
	lea	text39(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,212(a6)
	jsr	fix_promt(pc)
	
	move.l	212(a6),a0
	lea	$100(a0),a7
	move.l	26(a6),a1
	move.l	522(a6),a6

	sub.l	#$100,a1
	move.w	#8319,d0
.loop:
	clr.l	(a1)+
	dbra	d0,.loop
	bra	explor_start
f8:
	jsr	wipe_screen(pc)

	move.w	#0,12(a6)
	move.w	#0,14(a6)
	move.l	526(a6),a1
	lea	sam_info(pc),a2
	jsr	huj_print(pc)

	cmp.b	#10,$ffff8001.w
	bne.s	.no_4
	move.l	#$3fffff,216(a6)
	bra.s	.yes_go_4_it
.no_4:
	cmp.b	#9,$ffff8001.w
	bne.s	.no_25
	move.l	#$27ffff,216(a6)
	bra.s	.yes_go_4_it
.no_25:
	cmp.b	#8,$ffff8001.w
	bne.s	.no_2
	move.l	#$1fffff,216(a6)
	bra.s	.yes_go_4_it
.no_2:
	cmp.b	#5,$ffff8001.w
	bne.s	.no_1
	move.l	#$fffff,216(a6)
	bra.s	.yes_go_4_it
.no_1:
	move.l	#$7ffff,216(a6)
.yes_go_4_it:
	move.l	216(a6),234(a6)
	clr.l	212(a6)
	clr.w	220(a6)
	clr.w	228(a6)
	move.w	#639,230(a6)
	move.w	#1,232(a6)
	move.l	#hz10,224(a6)

	move.l	212(a6),d1	*sam_start
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#14,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)

	move.l	216(a6),d1	*sam_end
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#35,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)


	jsr	get_sam_offs
	jsr	plot_data
	move.w	#0,d3
	jsr	mofo_eor
	move.w	#639,d3
	jsr	mofo_eor
sam_loop:
	jsr	get_key(pc)
	cmp.b	#59,d0
	beq	sam_f1
	cmp.b	#60,d0
	beq	sam_f2
	cmp.b	#61,d0
	beq	sam_f3
	cmp.b	#62,d0
	beq	sam_f4
	cmp.b	#63,d0
	beq	sam_f5
	cmp.b	#64,d0
	beq	sam_f6
	cmp.b	#65,d0
	beq.s	sam_f7
	cmp.b	#66,d0
	beq	sam_f8
	cmp.b	#80,d0
	beq.s	sam_pil_down
	cmp.b	#72,d0
	beq	sam_pil_upp
	cmp.b	#75,d0
	beq	sam_pil_left
	cmp.b	#77,d0
	beq	sam_pil_rigt
	cmp.b	#68,d0
	beq	sam_f10
	cmp.b	#1,d0
	beq.s	exit_sam
	bra.s	sam_loop
exit_sam:
	jsr	wipe_screen(pc)
	jsr	init_screen(pc)
	bra	get_key_again
sam_f7:
	move.l	26(a6),a0
	add.l	#160*100,a0
	move.w	#(160*64)-1,d0
.loop:
	clr.b	(a0)+
	dbra	d0,.loop
	clr.w	228(a6)
	move.w	#639,230(a6)
	jsr	get_sam_offs
	jsr	plot_data
	bra	sam_loop
	
sam_pil_down:
	move.w	228(a6),d0
	move.w	d0,d3
	jsr	mofo_eor
	add.w	232(a6),d0
	cmp.w	230(a6),d0
	bge.s	set_pointer
back_in_bizz:

	move.w	d0,228(a6)
	move.w	d0,d3
	jsr	mofo_eor
	mulu	222(a6),d0
	move.l	d0,212(a6)
	move.l	d0,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#14,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
set_pointer:
	move.w	230(a6),d0
	subq.w	#1,d0
	bra.s	back_in_bizz
sam_pil_upp:
	move.w	228(a6),d0
	move.w	d0,d3
	jsr	mofo_eor
	sub.w	232(a6),d0
	cmp.w	#0,d0
	ble.s	set_pointer2
back_in_bizz2:

	move.w	d0,228(a6)
	move.w	d0,d3
	jsr	mofo_eor
	mulu	222(a6),d0
	move.l	d0,212(a6)
	move.l	d0,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#14,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
set_pointer2:
	moveq	#0,d0
	bra.s	back_in_bizz2
sam_pil_left:
	move.w	230(a6),d0
	move.w	d0,d3
	jsr	mofo_eor
	sub.w	232(a6),d0
	cmp.w	228(a6),d0
	ble.s	set_pointer3
back_in_bizz3:
	move.w	d0,230(a6)
	move.w	d0,d3
	jsr	mofo_eor
	mulu	222(a6),d0
	move.l	d0,216(a6)
	move.l	d0,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#35,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
set_pointer3:
	move.w	228(a6),d0
	addq.w	#1,d0
	bra.s	back_in_bizz3
sam_pil_rigt:
	move.w	230(a6),d0
	move.w	d0,d3
	jsr	mofo_eor
	add.w	232(a6),d0
	cmp.w	#639,d0
	bge.s	set_pointer4
	move.w	d0,230(a6)
	move.w	d0,d3
	jsr	mofo_eor
	mulu	222(a6),d0
	move.l	d0,216(a6)
	move.l	d0,d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#35,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
set_pointer4:
	move.w	#639,230(a6)
	move.w	#639,d0
	move.w	d0,d3
	jsr	mofo_eor
	move.l	234(a6),216(a6)
	move.l	234(a6),d1
	lea	372(a6),a0
	jsr	real_long(pc)
	move.w	#35,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
mofo_eor:
	move.l	26(a6),a0
	add.l	#160*100,a0

	move.w	d3,d4
	and.w	#15,d3
	move.w	#$8000,d6
	lsr.w	d3,d6
	and.w	#$fff0,d4
	lsr.w	#2,d4
	add.w	d4,a0
	move.w	#63,d1
.loop:
	eor.w	d6,(a0)
	lea	160(a0),a0
	dbra	d1,.loop
	rts
get_sam_offs:
	move.l	216(a6),d0
	sub.l	212(a6),d0
	add.l	d0,d0
	addq.l	#1,d0
	divu	#640*2,d0
	swap	d0
	clr.w	d0
	swap	d0
	move.w	d0,222(a6)	
	rts
plot_data:
	move.w	222(a6),d0
	move.l	212(a6),a1
	move.w	#639,d1
	moveq	#0,d5
.loop:
	move.l	26(a6),a0
	add.l	#160*100,a0

	moveq	#0,d2
	move.b	(a1),d2
	add.b	#$80,d2
	move.w	d2,d7
	lsr.b	#2,d2

	move.w	d5,d3
	move.w	d3,d4
	and.w	#15,d3
	move.w	#$8000,d6
	lsr.w	d3,d6
	and.w	#$fff0,d4
	lsr.w	#2,d4
	add.w	d4,a0
	jsr 	line

	add.l	d0,a1
	addq.w	#1,d5
	dbra	d1,.loop
	rts
line:
	tst.b	d7
	bmi.s	neg_line

	move.w	#$007f,d4
	sub.b	d7,d4
	lsr.b	#2,d4
	addq.b	#1,d4

	mulu	#160,d2
	add.w	d2,a0
.loop:
	or.w	d6,(a0)
	lea	160(a0),a0
	dbra	d4,.loop
	rts
neg_line:
	add.b	#$80,d7
	lsr.b	#2,d7
	mulu	#160,d2
	add.w	d2,a0
.loop:
	or.w	d6,(a0)
	lea	-160(a0),a0
	dbra	d7,.loop
	rts
sam_f10:
	moveq	#10,d0
setregs:
	move.b	d0,$fff8800
	clr.b	$fff8802
	dbf	d0,setregs
	clr.b	$fff8800
	clr.b	$fff8802
	move.b	#7,$fff8800
	move.b	#$ff,$fff8802

	lea	$ff8800,a0
	move.l	212(a6),a1
	lea	imptab,a2
	move.l	224(a6),a3
replay:
	moveq	#0,d7
	move.b	(a1)+,d7
	cmp.l	216(a6),a1
	bge.s	no_more
	lsl.w	#3,d7
	move.l	(a2,d7.w),d0
	move.w	4(a2,d7.w),d1
	movep.l	d0,(a0)
	movep.w	d1,(a0)
	jsr	(a3)
	cmp.b	#1,$fffffc02.w
	bne.s	replay
	bra	xsam_loop
xsam_loop:
	cmp.b	#1,$fffffc02.w
	beq.s	xsam_loop
	bra	sam_loop
	
hz5:
	move.w	#117,d1
.loop:
	dbra	d1,.loop
	rts
hz7_5:
	move.w	#69,d1
.loop:
	dbra	d1,.loop
	rts
hz10:
	move.w	#51,d1
.loop:
	dbra	d1,.loop
	rts
hz15:
	move.w	#25,d1
.loop:
	dbra	d1,.loop
	rts
hz20:
	move.w	#14,d1
.loop:
	dbra	d1,.loop
	nop
	rts
hz31:
	move.w	#2,d1
.loop:
	dbra	d1,.loop
	nop
	rts
no_more:
	cmp.w	#1,220(a6)
	beq.s	loop_on
	bra	sam_loop
loop_on:
	move.l	212(a6),a1
	bra	replay

sam_f1:
	move.l	#hz5,224(a6)
	lea	372(a6),a0
	move.b	#"5",(a0)+
	move.b	#".",(a0)+
	move.b	#"0",(a0)+
	move.w	#55,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
sam_f2:
	move.l	#hz7_5,224(a6)
	lea	372(a6),a0
	move.b	#"7",(a0)+
	move.b	#".",(a0)+
	move.b	#"5",(a0)+
	move.w	#55,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
sam_f3:
	move.l	#hz10,224(a6)
	lea	372(a6),a0
	move.b	#"1",(a0)+
	move.b	#"0",(a0)+
	move.b	#" ",(a0)+
	move.w	#55,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
sam_f4:
	move.l	#hz15,224(a6)
	lea	372(a6),a0
	move.b	#"1",(a0)+
	move.b	#"5",(a0)+
	move.b	#" ",(a0)+
	move.w	#55,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
sam_f5:
	move.l	#hz20,224(a6)
	lea	372(a6),a0
	move.b	#"2",(a0)+
	move.b	#"0",(a0)+
	move.b	#" ",(a0)+
	move.w	#55,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
sam_f6:
	move.l	#hz31,224(a6)
	lea	372(a6),a0
	move.b	#"3",(a0)+
	move.b	#"1",(a0)+
	move.b	#" ",(a0)+
	move.w	#55,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
sam_f8:
	eor.w	#1,220(a6)
	lea	372(a6),a0
	cmp.w	#1,220(a6)
	bne.s	no_no
	move.b	#"O",(a0)+
	move.b	#"n",(a0)+
	move.b	#" ",(a0)+
	bra.s	no_no_no
no_no:
	move.b	#"O",(a0)+
	move.b	#"f",(a0)+
	move.b	#"f",(a0)+
no_no_no:
	move.w	#68,12(a6)
	move.w	#2,14(a6)
	jsr	start_print(pc)
	bra	sam_loop
f9:
	move.w	#0,12(a6)
	move.w	#6,14(a6)
	move.l	526(a6),a1
	lea	hard_core(pc),a2
	jsr	huj_print(pc)
	move.l	26(a6),a0
	move.w	#7999,d0
	moveq	#0,d1
.loop:	
	move.w	d1,2(a0)
	addq.l	#4,a0
	dbra	d0,.loop
	jsr	print_mega_data(pc)
f9_key_loop:
	jsr	get_key(pc)
	cmp.b	#1,d0
	beq	mega_exit
	cmp.b	#111,d0
	beq	mega_mega_pil_down
	cmp.b	#105,d0
	beq	mega_mega_pil_upp
	cmp.b	#80,d0
	beq	mega_data_down
	cmp.b	#72,d0
	beq.s	mega_data_upp
	cmp.b	#75,d0
	beq	mega_pil_left
	cmp.b	#77,d0
	beq	mega_pil_rigt
	cmp.b	#30,d0
	beq.s	mega_wind_pos
	cmp.b	#10,d0
	beq.s	mega_updatewindows
	bra.s	f9_key_loop
mega_updatewindows:
	jsr	print_mega_data(pc)
	bra.s	f9_key_loop
mega_wind_pos:
	lea	text1(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi.s	mega_nofing
	and.l	#$00ffffff,d1
	move.l	d1,50(a6)
mega_nofing:
	lea	292(a6),a0
	moveq	#79,d0
.loop:
	clr.b	(a0)+
	dbra	d0,.loop
	lea	292(a6),a0
	move.l	a0,288(a6)
	jsr	print_mega_data(pc)
	move.w	#0,12(a6)
	move.w	#24,14(a6)
	move.l	526(a6),a1
	lea	hard_core2(pc),a2
	jsr	huj_print(pc)
	bra	f9_key_loop
mega_exit:
	jsr	init_screen(pc)
	bra	get_key_again
mega_data_upp:
	sub.l	#71,50(a6)
	jsr	print_mega_data(pc)
	bra	f9_key_loop
mega_data_down:
	add.l	#71,50(a6)
	jsr	print_mega_data(pc)
	bra	f9_key_loop
mega_mega_pil_upp:
	sub.l	#71*17,50(a6)
	jsr	print_mega_data(pc)
	bra	f9_key_loop
mega_mega_pil_down:
	add.l	#71*17,50(a6)
	jsr	print_mega_data(pc)
	bra	f9_key_loop
mega_pil_left:
	subq.l	#1,50(a6)
	jsr	print_mega_data(pc)
	bra	f9_key_loop
mega_pil_rigt:
	addq.l	#1,50(a6)
	jsr	print_mega_data(pc)
	bra	f9_key_loop
print_mega_data:
	lea	372(a6),a0
	move.l	50(a6),a1
	move.l	#0,46(a6)
	move.w	#53,12(a6)
	move.w	#7,14(a6)
	moveq	#16,d0
.loop
	move.w	d0,-(sp)
	lea	372(a6),a0
	move.l	50(a6),a1
	add.l	46(a6),a1
	clr.w	12(a6)
	jsr	print_pos(pc)
	move.w	#9,12(a6)
	jsr	print_pos3(pc)
	addq.w	#1,14(a6)
	add.l	#71,46(a6)
	move.w	(sp)+,d0
	dbra	d0,.loop
	rts
print_pos3:
	movem.l	d0-d7/a0-a5,-(sp)
	cmp.w	#0,546(a6)
	beq.s	no_trap14
	move.l	$8.w,-(sp)
	move.l	#turbo_berr,$8.w
no_trap14:
	move.l	a1,a2
	move.w	14(a6),d2
	mulu	#160*8,d2
	move.l	526(a6),d6
	move.l	26(a6),a0
	add.w	#16,a0
	add.w	d2,a0
	moveq	#3,d3
	moveq	#3,d2
	move.w	#%0000000000000010,d1
	move.b	#%00111000,d5
	move.b	#%11111110,d4
	moveq	#70,d7
mega_print:
	move.l	d6,a1
	eor.w	d1,d3
	add.w	d3,a0
	moveq	#0,d0
	move.b	(a2)+,d0
	lsl.w	d2,d0
	add.w	d0,a1
	move.b	(a1)+,(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.b	(a1),160*7(a0)
	dbra	d7,mega_print
	cmp.w	#0,546(a6)
	beq.s	no_trap13
	move.l	(sp)+,$8.w
no_trap13:
	movem.l	(sp)+,d0-d7/a0-a5
	rts
turbo_berr:
	move.b	d5,(a0)
	move.b	d5,160*1(a0)
	move.b	d4,160*2(a0)
	move.b	d5,160*3(a0)
	move.b	d5,160*4(a0)
	move.b	d5,160*5(a0)
	move.b	d5,160*6(a0)
	clr.b	160*7(a0)
	lea	14(sp),sp
	dbra	d7,mega_print
	move.l	(sp)+,$8.w
	movem.l	(sp)+,d0-d7/a0-a5
	rts
super_save:
	move.w	#1,272(a6)
	lea	text21(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.w	d1,270(a6)
	jsr	fix_promt(pc)

	lea	text40(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,260(a6)
	jsr	fix_promt(pc)

	lea	text41(pc),a0
	jsr	put_promt(pc)
	jsr	make_text_data(pc)
	tst.w	d0
	bmi	nofing
	move.l	d1,264(a6)
	jsr	fix_promt(pc)

	move.l	260(a6),d0
	move.l	264(a6),d1
	sub.l	d0,d1
	bmi.s	no_save

	move.w	#0,276(a6)
	move.w	#1,278(a6)
	move.w	#1,274(a6)
	move.l	a6,282(a6)
	jsr	dma_shit

	move.w	#0,276(a6)
	move.w	#2,278(a6)

	move.l	260(a6),d0
	move.l	264(a6),d1
	sub.l	d0,d1

	divu	#512,d1
	swap	d1
	tst.w	d1
	beq.s	no_add
	swap	d1
	addq.w	#1,d1
	swap	d1
no_add:
	swap	d1
	move.w	d1,274(a6)
	move.l	260(a6),282(a6)

	jsr	dma_shit
no_save:
	bra	get_key_again
f10:
	lea	text42(pc),a0
	jsr	put_promt(pc)
	cmp.b	#"y",292(a6)
	beq.s	yes_trap_berr
	move.w	#0,546(a6)
	bra	nofing
yes_trap_berr:
	move.w	#1,546(a6)
	bra	nofing
fade_in:
	lea	ghothol,a0
	moveq	#6,d0
.loop:
	move.l	a0,-(sp)
	move.w	d0,-(sp)
	jsr	hot_vsync(pc)
	move.w	(sp)+,d0
	move.l	(sp)+,a0
	move.w	(a0)+,$ff8242
	move.w	(a0)+,$ff8246
	dbra	d0,.loop
	rts
ghothol:
	dc.w	$111,$111,$222,$111,$333,$222
	dc.w	$444,$333,$555,$333,$666,$444
	dc.w	$777,$444
hot_vsync:
	jsr	vsync(pc)
	jsr	vsync(pc)
	jsr	vsync(pc)
	rts
***************************************************************
*MAIN! MAIN! MAIN! MAIN! MAIN! MAIN! MAIN! MAIN! MAIN! MAIN! *
***************************************************************
main:
	ifne	cart=0
	movem.l	d0-d7/a0-a6,-(sp)
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	jsr	init_resse
	
	bclr	#0,$484.w
	
	*dumm
	jsr	vsync2(pc)
	move.b	#0,$ffff8260.w
	endc

	moveq	#1,d0
	moveq	#2,d1
	moveq	#3,d2
	moveq	#4,d3
	moveq	#5,d4
	moveq	#6,d5
	moveq	#7,d6
	moveq	#8,d7
	move.w	#9,a0
	move.w	#$a,a1
	move.w	#$b,a2
	move.w	#$c,a3
	move.w	#$d,a4
	move.w	#$e,a5
	move.w	#$f,a6
	*	move.w	#0,a7	*hostile
	movem.l	(sp)+,d0-d7/a0-a6

;	move.b	$fffa07,mfp1
;	move.b	$fffa09,mfp2
;	clr.b	$fffa07
;	clr.b	$fffa09
;	move.w	#$2700,sr

	* 60 to 50 hz

	ifne	cart=1
	eor.b	#2,$ffff820a.w

	* init mmu

	move.w	$400000-2,a7
	move.b	#1,$3fffff
	cmp.b	#1,$3fffff
	beq.s	four_meg
	move.w	$280000-2,a7
	move.b	#1,$27ffff
	cmp.b	#1,$27ffff
	beq.s	two_half_meg
	move.w	$200000-2,a7
	move.b	#1,$1fffff
	cmp.b	#1,$1fffff
	beq.s	two_meg
	move.w	$100000-2,a7
	move.b	#1,$fffff
	cmp.b	#1,$fffff
	beq.s	one_meg
;	lea	$80000-33280,a1
	move.b	#4,$ff8001
	bra.s	fix_meg
four_meg:
;	lea	$400000-33280,a1
	move.w	a7,$400000-2
	move.b	#10,$ff8001
	bra.s	fix_meg
two_half_meg:
;	lea	$280000-33280,a1
	move.w	a7,$280000-2
	move.b	#9,$ff8001
	bra.s	fix_meg
two_meg:
;	lea	$200000-33280,a1
	move.w	a7,$200000-2
	move.b	#8,$ff8001
	bra.s	fix_meg
one_meg:
;	lea	$100000-33280,a1
	move.w	a7,$100000-2
	move.b	#5,$ff8001
fix_meg:
	endc

	* init ikbd

	move.b	#3,$fffffc04.w
	move.b	#$95,$fffffc04.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
	
	* init psg

	move.b	#$7,$ffff8800.w
	move.b	#$c0,$ffff8802.w
	move.b	#$e,$ffff8800.w
	move.b	#$7,$ffff8802.w


	ifne	test=1
this_is_the_kloop:
	eor.w	#$777,$ff8240
	eor.w	#$777,$ff8240
	cmp.b	#59,$fffffc02.w	*f1
	beq	smart_find
	cmp.b	#60,$fffffc02.w	*f2
	beq	graf_find
	cmp.b	#61,$fffffc02.w	*f3
	beq	set_70000
	cmp.b	#62,$fffffc02.w	*f4
	beq	set_f0000
	cmp.b	#63,$fffffc02.w	*f5
	beq	set_1f0000
	cmp.b	#64,$fffffc02.w	*f6
	beq	set_270000
	cmp.b	#65,$fffffc02.w	*f7
	beq	set_3f0000
	bra	this_is_the_kloop
back_normal:
	elseif
	lea	$300000,a7	*st 4 meg
	endc
explor_start:
	lea	$fc(a7),a7
	move.l	a6,-(sp)
	lea	32008(a7),a6
	movem.l	d0-d7/a0-a5,66(a6)
	move.l	(sp)+,122(a6)
	move.l	122(a6),522(a6)
	move.l	a7,126(a6)
	sub.l	#$80,126(a6)
explorer_start2:

	move.l	a7,26(a6)
	addq.l	#4,26(a6)

	moveq	#0,d0
	lea	$ffff8201.w,a1
	movep.w	(a1),d0
	lsl.l	#8,d0
	move.l	d0,472(a6)

	move.l	26(a6),d0
	lsr.l	#8,d0
	lea	$ffff8201.w,a0
	movep.w	d0,(a0)

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,134(a6)

	lea	166(a6),a0
	moveq	#95,d0
.floop:
	clr.b	(a0)+
	dbra	d0,.floop

	ifne	picc=1
	jsr	show_piccy(pc)
	endc

	clr.w	(a6)		;curr_sizze
	clr.w	2(a6)		;   -"-2
	clr.w	4(a6)		;   -"-3
	clr.w	6(a6)		;cod_zize
	clr.w	8(a6)		;old_key
	clr.w	10(a6)		;repet
	clr.w	12(a6)		;xpos
	clr.w	14(a6)		;ypos
	clr.w	16(a6)		;save_xpos
	move.w	#1,18(a6)	;curr_window
	move.w	#4,20(a6)	;bit_active
	move.w	#2,22(a6)	;speed
	move.w	#19,24(a6)	;rsize
;	clr.l	26(a6)		;currpicadd
	clr.l	30(a6)		;start_next
	clr.l	34(a6)		;start_next_long
	clr.l	38(a6)		;curr_code_offs
	ifne	test=1
	move.l	$4,42(a6)	;real_code_start
	elseif
	move.l	#code,42(a6)	;real_code_start
	endc
	clr.l	46(a6)		;curr_data_offs
	move.l	$4.w,50(a6)	;real_data_start
	move.l	#$100000,54(a6)	;
;	clr.l	54(a6)		;end_val
	clr.l	58(a6)		;mega_pek
	clr.l	62(a6)		;search_val
;	clr.l	66(a6)		;d0
;	clr.l	70(a6)		;d1
;	clr.l	74(a6)		;d2
;	clr.l	78(a6)		;d3
;	clr.l	82(a6)		;d4
;	clr.l	86(a6)		;d5
;	clr.l	90(a6)		;d6
;	clr.l	94(a6)		;d7
;	clr.l	98(a6)		;a0
;	clr.l	102(a6)		;a1
;	clr.l	106(a6)		;a2
;	clr.l	110(a6)		;a3
;	clr.l	114(a6)		;a4
;	clr.l	118(a6)		;a5
;	clr.l	122(a6)		;a6
;	clr.l	126(a6)		;a7
;	clr.l	130(a6)		;usp (a7')
;	clr.w	134(a6)		;color0
;	clr.w	136(a6)		;color1
;	clr.w	138(a6)		;color2
;	clr.w	140(a6)		;color3
;	clr.w	142(a6)		;color4
;	clr.w	144(a6)		;color5
;	clr.w	146(a6)		;color6
;	clr.w	148(a6)		;color7
;	clr.w	150(a6)		;color8
;	clr.w	152(a6)		;color9
;	clr.w	154(a6)		;color10
;	clr.w	156(a6)		;color11
;	clr.w	158(a6)		;color12
;	clr.w	160(a6)		;color13
;	clr.w	162(a6)		;color14
;	clr.w	164(a6)		;color15
	clr.l	166(a6)		;cwp=code window pos.
	clr.l	170(a6)		;dwp=code window pos.
	clr.w	174(a6)		;sr
	clr.l	176(a6)		;save_a6
	clr.w	180(a6)		;bpkt data1
	clr.w	182(a6)		;bpkt data2
	clr.w	194(a6)		;bpkt data3
	clr.w	196(a6)		;bpkt data4
	clr.l	188(a6)		;bpkt pos1
	clr.l	192(a6)		;bpkt pos2
	clr.l	196(a6)		;bpkt pos3
	clr.l	200(a6)		;bpkt pos4
	clr.w	204(a6)		;error kind
	move.l	4,206(a6)	;pc
	clr.w	210(a6)		;super pc
	clr.l	212(a6)		;code 1 ;edit_pek ;edit_valid
	clr.l	216(a6)		;code 2	;0123
	clr.l	220(a6)		;code 3	;4567
	clr.l	224(a6)		;code 4	;epty
	clr.l	228(a6)		;code 5 ;edit_yval
	clr.l	232(a6)		;code 6	;text1 text2 text3 text4
	clr.l	236(a6)		;code 7	;empyt
	clr.l	240(a6)		;code 8
	clr.l	244(a6)		;code 9
	clr.l	248(a6)		;code 10
	clr.l	252(a6)		;code 11
	clr.l	256(a6)		;code 12
	clr.l	260(a6)		;code 13
	clr.l	264(a6)		;code 14
	clr.w	268(a6)		;curr slow code

	clr.w	270(a6)		;drive (0=a:0 1=a:1 2=b:0 3=b:1)
	clr.w	272(a6)		;load_save (0=load 1=save)
	clr.w	274(a6)		;nosec (number of sectors to load/save)
	clr.w	276(a6)		;starttrk (start load/save at track)
	clr.w	278(a6)		;startsec (start load/save at sector)
	clr.w	280(a6)		;maxsec (max number of sectors per track)
	clr.l	282(a6)		;loadaddr (load/save data begining at address)
	clr.w	286(a6)		;??????????????? use now!!!!
	lea	292(a6),a0
	move.l	a0,288(a6)	;edit_pek
	moveq	#79,d0
.loop:
	clr.b	(a0)+
	dbra	d0,.loop
	lea	372(a6),a0
	moveq	#99,d0
.loop2:
	clr.b	(a0)+
	dbra	d0,.loop2
;	clr.l	472(a6)		;the code currpicadd
	clr.w	476(a6)		;the current_rez
	clr.w	478(a6)		;1 if breakpoint then go. else 0
	move.w	#-1,480(a6)	;search_status
	clr.w	482(a6)		;0
	clr.w	484(a6)		;0
	move.w	#-1,486(a6)	;-1
	move.w	#$000f,488(a6)	;bitplanes active
	clr.l	490(a6)		;var1 addr.
	clr.l	494(a6)		;var2 addr.
	clr.w	498(a6)		;nu. bytes extra in ripper
	clr.w	500(a6)		;grabber 1 x
	clr.w	502(a6)		;grabber 1 y
	clr.w	504(a6)		;grabber 2 x
	clr.w	506(a6)		;grabber 2 y
	clr.w	508(a6)		;grabber type	
	ifne	test=1
	clr.l	510(a6)		;grabber screen pos.
	elseif
	move.l	#$200000,510(a6)	;only when testing
	endc
	clr.w	514(a6)		;s†s x
	clr.w	516(a6)		;s†s y
	clr.w	518(a6)		;dbra x
	clr.w	520(a6)		;dbra y
;	clr.l	522(a6)		;return_adress
	move.l	#font,526(a6)	;font_ptr
	clr.l	530(a6)		;spectrum 512 pal. pointer
	clr.w	534(a6)		;spectrum 512 1=on 0=off
	clr.w	536(a6)		;mega-slave
	clr.l	538(a6)		;vbi addr.
	clr.l	542(a6)		;jump_on
	move.w	#1,546(a6)	;trap berr on/off
	clr.w	548(a6)		;esc flag
	moveq	#0,d0
	move.b	$ffff8001.w,d0
	move.l	usp,a0
	move.l	a0,130(a6)	
	move.w	sr,d0
	move.w	d0,174(a6)
	move.b	$ffff8260.w,476(a6)
	
	move.l	#$000,$ffff8240.w
	move.l	#$000,$ffff8244.w

	*dumm
	jsr	vsync2(pc)
	move.b	#1,$ffff8260.w
	jsr	wipe_screen(pc)
	jsr	init_screen(pc)
	jsr	fade_in(pc)

get_key_again:
	jsr	get_key(pc)
	cmp.b	#57,d0
	beq	exit
	cmp.b	#111,d0
	beq	mega_pil_down
	cmp.b	#105,d0
	beq	mega_pil_upp
	cmp.b	#30,d0
	beq	wind_pos
	cmp.b	#18,d0
	beq	start_edit_data
	cmp.b	#37,d0
	beq	kill_bpkts
	cmp.b	#44,d0
	beq	trace_until
	cmp.b	#45,d0
	beq	set_code
	cmp.b	#38,d0
	beq	load
	cmp.b	#31,d0
	beq	save
	cmp.b	#15,d0
	beq	change_window
	cmp.b	#19,d0
	beq	do_ripp
	cmp.b	#17,d0
	beq	set_dma
	cmp.b	#49,d0
	beq	search_next
	cmp.b	#25,d0
	beq	search_prev
	cmp.b	#32,d0
	beq	activate_traps
	cmp.b	#22,d0
	beq	set_reg
	cmp.b	#50,d0
	beq	music_ripp
	cmp.b	#33,d0
	beq	find
	cmp.b	#35,d0
	beq	trace
	cmp.b	#36,d0
	beq	trace2
	cmp.b	#47,d0
	beq	super_pc
	cmp.b	#48,d0
	beq	breakpoint
	cmp.b	#20,d0
	beq	sripp1
	cmp.b	#21,d0
	beq	sripp2
	cmp.b	#23,d0
	beq	save_pos
	cmp.b	#24,d0
	beq	restore_pos
	cmp.b	#34,d0
	beq	go
	cmp.b	#46,d0
	beq	set_same
	cmp.b	#16,d0
	beq	toggle_screen
	cmp.b	#80,d0
	beq	pil_down
	cmp.b	#72,d0
	beq	pil_upp
	cmp.b	#75,d0
	beq	pil_left
	cmp.b	#77,d0
	beq	pil_rigt
	cmp.b	#2,d0
	beq	set_vbi
	cmp.b	#3,d0
	beq	fill_mem
	cmp.b	#4,d0
	beq	copy_mem
	cmp.b	#5,d0
	beq	set_var1
	cmp.b	#6,d0
	beq	set_var2
	cmp.b	#7,d0
	beq	set_grbber_pos
	cmp.b	#8,d0
	beq	spec
	cmp.b	#9,d0
	beq	skip
	cmp.b	#10,d0
	beq	updatewindows
	cmp.b	#11,d0
	beq	set_io_data
	cmp.b	#12,d0
	beq	super_save
	cmp.b	#59,d0
	beq	f1
	cmp.b	#60,d0
	beq	f2
	cmp.b	#61,d0
	beq	f3
	cmp.b	#63,d0
	beq	f5
	cmp.b	#64,d0
	beq	f6
	cmp.b	#65,d0
	beq	f7
	cmp.b	#66,d0
	beq	f8
	cmp.b	#67,d0
	beq	f9
	cmp.b	#68,d0
	beq	f10
	cmp.b	#98,d0
	beq	info_print
	cmp.b	#96,d0
	beq	trace3
	bra	get_key_again
exit:
	ifne	test=1
	lea	text33(pc),a0
	jsr	put_promt(pc)
	cmp.b	#"y",292(a6)
	beq.s	yes_exit
	bra	nofing
yes_exit:
	jsr	vsync2(pc)
	move.b	476(a6),$ffff8260.w
	move.l	522(a6),a0
	jmp	(a0)
	elseif
	move.l	26(a6),a0
	sub.l	#$100,a0
	move.w	#8319,d0
.loop:
	clr.l	(a0)+
	dbra	d0,.loop

;	move.b	mfp1,$fffa07
;	move.b	mfp2,$fffa09
;	move.w	#$2300,sr

	move.w	#$000,$ffff8240.w
	move.w	#$777,$ffff8242.w
	move.w	#$777,$ffff8244.w
	move.w	#$777,$ffff8246.w
	illegal
	endc

mfp1:	dc.b	0
mfp2:	dc.b	0
****************************************************
* tabeller till decodningen ************************
****************************************************
data_layout:
	topp
	dc.b	"<Registers>------------------------------------------<Info>---------------------"
	dc.b	"d0:         d4:            a0:         a4:          | cwp:          dwp:        "
	dc.b	"d1:         d5:            a1:         a5:          | rp :          pc :        "
	dc.b	"d2:         d6:            a2:         a6:          | sr :          va1:        "
	dc.b	"d3:         d7:            a3:         a7:          | usp:          va2:        "
	dc.b	"<Code>-----------------------------------------------<Data>---------------------"
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
	dc.b	"                                                    |                           "
hard_core2:
	dc.b	">                                                                               "
	dc.b	0
	even
hard_core:
	dc.b	"<Data>--------------------------------------------------------------------------"
	dc.b	0
	even
svenne_info:
	topp
	dc.b	"                                                                                "
	dc.b	"This is 'The Explorer-info' screen.                                             "
	dc.b	"                                                                                "
	dc.b	"Colors: 0. xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx                              "
	dc.b	"        8. xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx                              "
	dc.b	"                                                                                "
	dc.b	"Bb1: xxxxxxxx Bp2: xxxxxxxx Bp3: xxxxxxxx Bp4: xxxxxxxx                         "
	dc.b	"                                                                                "
	dc.b	"Screen address: xxxxxxxx Grabber address: xxxxxxxx (32Kb)                       "
	dc.b	"                                                                                "
	dc.b	"The Explorer uses memory from: xxxxxxxx to: xxxxxxxx                            "
	dc.b	"                                                                                "
	dc.b	"Computer size: xxx megabyte(s)                                                  "	
	dc.b	"                                                                                "
	dc.b	"I/O Registers:                                                                  "
	dc.b	"                                                                                "
	dc.b	"8001:xx 8201:xx 8203:xx 820a:xx 8260:xx                                         "
	dc.b	"fa01:xx fa03:xx fa05:xx fa07:xx fa09:xx fa0b:xx fa0d:xx fa0f:xx fa11:xx         "
	dc.b	"fa13:xx fa15:xx fa17:xx fa19:xx fa1b:xx fa1d:xx fa1f:xx fa21:xx fa23:xx         "
	dc.b	"fa25:xx fa27:xx fa29:xx fa2b:xx fa2d:xx fa2f:xx                                 "
	dc.b	"                                                                                "
	dc.b	"To continue please press (Esc)....                                              "
	dc.b	0
	even	
sam_info:
	topp
	dc.b	"                                                                                "
	dc.b	"Sample start: xxxxxxxx Sample end: xxxxxxxx Frequency: 10 KHz LOOP: Off         "
	dc.b	0
	even
super_conv_tab:
	dc.b	"a0",-1,0
	dc.l	rega0
	dc.b	"a1",-1,0
	dc.l	rega1
	dc.b	"a2",-1,0
	dc.l	rega2
	dc.b	"a3",-1,0
	dc.l	rega3
	dc.b	"a4",-1,0
	dc.l	rega4
	dc.b	"a5",-1,0
	dc.l	rega5
	dc.b	"a6",-1,0
	dc.l	rega6
	dc.b	"a7",-1,0
	dc.l	rega7
	dc.b	"d0",-1,0
	dc.l	regd0
	dc.b	"d1",-1,0
	dc.l	regd1
	dc.b	"d2",-1,0
	dc.l	regd2
	dc.b	"d3",-1,0
	dc.l	regd3
	dc.b	"d4",-1,0
	dc.l	regd4
	dc.b	"d5",-1,0
	dc.l	regd5
	dc.b	"d6",-1,0
	dc.l	regd6
	dc.b	"d7",-1,0
	dc.l	regd7
	dc.b	"usp",-1
	dc.l	regusp
	dc.b	"cwp",-1
	dc.l	regcwp
	dc.b	"dwp",-1
	dc.l	regdwp
	dc.b	"rp",-1,0
	dc.l	regrp
	dc.b	"pc",-1,0
	dc.l	regpc
	dc.b	"w1",-1,0
	dc.l	regw1
	dc.b	"w2",-1,0
	dc.l	regw2
	dc.b	"bp1",-1
	dc.l	regbp1
	dc.b	"bp2",-1
	dc.l	regbp2
	dc.b	"bp3",-1
	dc.l	regbp3
	dc.b	"bp4",-1
	dc.l	regbp4
	dc.b	"va1",-1
	dc.l	regva1
	dc.b	"va2",-1
	dc.l	regva2
	dc.b	-2,0
hip_tab:
	dc.b	"pc",-1,0
	dc.l	yes_pc
	dc.b	"sr",-1,0
	dc.l	yes_sr
	dc.b	"rp",-1,0
	dc.l	yes_rp
	dc.b	"cwp",-1
	dc.l	yes_cwp
	dc.b	"dwp",-1
	dc.l	yes_dwp
	dc.b	"usp",-1
	dc.l	yes_usp
	dc.b	"va1",-1
	dc.l	yes_va1
	dc.b	"va2",-1
	dc.l	yes_va2
	dc.b	-2,0
bit_planes:
	dc.l	bit0
	dc.l	bit1
	dc.l	bit2
	dc.l	bit3
	dc.l	bit4
	dc.l	bit5
	dc.l	bit6
	dc.l	bit7
	dc.l	bit8
	dc.l	bit9
	dc.l	bit10
	dc.l	bit11
	dc.l	bit12
	dc.l	bit13
	dc.l	bit14
	dc.l	bit15
conv_hex:
	dc.b	"0",0
	dc.b	"1",1
	dc.b	"2",2
	dc.b	"3",3
	dc.b	"4",4
	dc.b	"5",5
	dc.b	"6",6
	dc.b	"7",7
	dc.b	"8",8
	dc.b	"9",9
	dc.b	"a",10
	dc.b	"b",11
	dc.b	"c",12
	dc.b	"d",13
	dc.b	"e",14
	dc.b	"f",15
	dc.b	-1,-1
byte_blatt:
	dc.l	byte0
	dc.l	byte1
	dc.l	byte2
	dc.l	byte3
	dc.l	byte4
	dc.l	byte5
	dc.l	byte6
	dc.l	byte7
sys_pal:
	DC.W	$FFF,$000,$0F0,$000
	DC.W	$FFF,$F00,$0F0,$FF0
	DC.W	$00F,$F0F,$0FF,$555
	DC.W	$333,$F33,$3F3,$FF3
data_pos:
	dc.w	3,2,3,3,3,4,3,5
	dc.w	15,2,15,3,15,4,15,5
addr_pos:
	dc.w	30,2,30,3,30,4,30,5
	dc.w	42,2,42,3,42,4,42,5
types:
	dc.b	"tst "
	dc.b	"chg "
	dc.b	"clr "
	dc.b	"set "
lame_tab:
	dc.w	2,2,4,2
reg_tab:
	dc.b	"d0"
	dc.b	"d1"
	dc.b	"d2"
	dc.b	"d3"
	dc.b	"d4"
	dc.b	"d5"
	dc.b	"d6"
	dc.b	"d7"
reg_tab2:
	dc.b	"a0"
	dc.b	"a1"
	dc.b	"a2"
	dc.b	"a3"
	dc.b	"a4"
	dc.b	"a5"
	dc.b	"a6"
	dc.b	"a7"
hex_tab:
	dc.b	"0123456789abcdef"
	even
size:
	dc.b	"bwl?"
	even
operation_map:
	dc.l	bit_manul
	dc.l	moveb
	dc.l	movel
	dc.l	movew
	dc.l	miscellaneous
	dc.l	quickcond
	dc.l	subrout
	dc.l	moveq
	dc.l	logic
	dc.l	subs
	dc.l	reserved
	dc.l	compare
	dc.l	multiply
	dc.l	adds
	dc.l	rotate
	dc.l	coprocessor
cond_tab:
	dc.b	"t "
	dc.b	"f "
	dc.b	"hi"
	dc.b	"ls"
	dc.b	"cc"
	dc.b	"cs"
	dc.b	"ne"
	dc.b	"eq"
	dc.b	"vc"
	dc.b	"vs"
	dc.b	"pl"
	dc.b	"mi"
	dc.b	"ge"
	dc.b	"lt"
	dc.b	"gt"
	dc.b	"le"
logic_tab:
	dc.b	"bwl "
	dc.b	"bwl "
	even
shift_type:
	dc.b	"as  "
	dc.b	"ls  "
	dc.b	"rox "
	dc.b	"ro  "
key_tab:
	dc.b	30,"a"
	dc.b	48,"b"
	dc.b	46,"c"
	dc.b	32,"d"
	dc.b	18,"e"
	dc.b	33,"f"
	dc.b	34,"g"
	dc.b	35,"h"
	dc.b	23,"i"
	dc.b	36,"j"
	dc.b	37,"k"
	dc.b	38,"l"
	dc.b	50,"m"
	dc.b	49,"n"
	dc.b	24,"o"
	dc.b	25,"p"
	dc.b	16,"q"
	dc.b	19,"r"
	dc.b	31,"s"
	dc.b	20,"t"
	dc.b	22,"u"
	dc.b	47,"v"
	dc.b	17,"w"
	dc.b	45,"x"
	dc.b	21,"y"
	dc.b	44,"z"
	dc.b	11,"0"
	dc.b	2,"1"
	dc.b	3,"2"
	dc.b	4,"3"
	dc.b	5,"4"
	dc.b	6,"5"
	dc.b	7,"6"
	dc.b	8,"7"
	dc.b	9,"8"
	dc.b	10,"9"
	dc.b	102,"*"
	dc.b	-1,-1
key_tab2:
	dc.b	11,"0"
	dc.b	2,"1"
	dc.b	3,"2"
	dc.b	4,"3"
	dc.b	5,"4"
	dc.b	6,"5"
	dc.b	7,"6"
	dc.b	8,"7"
	dc.b	9,"8"
	dc.b	10,"9"
	dc.b	30,"a"
	dc.b	48,"b"
	dc.b	46,"c"
	dc.b	32,"d"
	dc.b	18,"e"
	dc.b	33,"f"
	dc.b	-1,-1

text1:	dc.b	"Window start:",0,14,0
text2:	dc.b	"Go to address:",0,15,0
text3:	dc.b	"find (b/w/l):",0,14,0
text4:	dc.b	"Enter data:",0,12,0
text5:	dc.b	"End command at address:",0,24,0
text6:	dc.b	"Enter register value:",0,22,0
text7:	dc.b	"register:",0,10,0
text8:	dc.b	"Find music (m/t/c):",0,20,0
text9:	dc.b	"Put breakpoint att address:",0,28,0
text10:	dc.b	"Kill all breakpoints (y/n):",0,28,0
text11:	dc.b	"Bus Error!",0,11,0
text12:	dc.b	"Address Error!",0,15,0
text13:	dc.b	"Illegal Instruction!",0,21,0
text14:	dc.b	"Breakpoint",0,11,0
text15:	dc.b	"Go until [pc]=",0,15,0
text16:	dc.b	"Use code #",0,11,0
text17:	dc.b	"Initialize Exeptions (y/n):",0,28,0
text18:	dc.b	"Start load/save at track:",0,26,0
text19:	dc.b	"Start load/save at sector:",0,27,0
text20:	dc.b	"Max sectors per track:",0,23,0
text21:	dc.b	"Drive/Side 0=a/0 1=a/1 2=b/0 3=b/1:",0,36,0
text22:	dc.b	"Number of sectors:",0,19,0
text23:	dc.b	"Address:",0,9,0
text24:	dc.b	"DMA Error!",0,11,0
text25:	dc.b	"VBI at address:",0,16,0
text26:	dc.b	"Start fill at address:",0,23,0
text27:	dc.b	"Copy start:",0,12,0
text28:	dc.b	"Copy end:",0,10,0
text29:	dc.b	"Destination:",0,13,0
text30:	dc.b	"Set variable 1 at address:",0,27,0
text31:	dc.b	"Set variable 2 at address:",0,27,0
text32:	dc.b	"Set grabber screen (32000 bytes):",0,34,0
text33:	dc.b	"Exit (y/n):",0,12,0
text34:	dc.b	"Set spectrum 512 palette at address:",0,37,0
text35:	dc.b	"Return from RT(E) or RT(S):",0,28,0
text36:	dc.b	"0=fake-VBI 1=$70-VBI:",0,22,0
text37:	dc.b	"Set I/O Register $ffff",0,23,0
text38:	dc.b	"(b/w/l):",0,9,0
text39:	dc.b	"Move 'The Explorer' to address:",0,32,0
text40:	dc.b	"Start save at address:",0,23,0
text41:	dc.b	"End save at address:",0,21,0
text42:	dc.b	"Trap illegal memory (y/n):",0,27,0
	even
hextab:
	dc.b	"0123456789ABCDEF"
text:
	dc.b	0,23,"MEMORY POSITION",-1
	even
rtext2:
	dc.b	25,23,"BITPLANES",-1
	even
rtext3:
	dc.b	0,24,"SIZE",-1
rtext4:
	dc.b	8,24,"BYTES",-1
	even
******************************************
* ”vriga tabeller ************************
******************************************
;save_a7:
;	dc.l	0
font:
	DC.W	0,0,0,0
	DC.W	$183C,$66C3,$E724,$243C
	DC.W	$3C24,$24E7,$C366,$3C18
	DC.W	$181C,$F683,$83F6,$1C18
	DC.W	$1838,$6FC1,$C16F,$3818
	DC.W	$FF81,$BDA5,$A5BD,$81FF
	DC.W	$F88F,$89F9,$4141,$7F00
	DC.W	$FF89,$89F9,$8181,$81FF
	DC.W	$103,$68C,$D870,$2000
	DC.W	$7EC3,$D3D3,$DBC3,$C37E
	DC.W	$183C,$3C3C,$7E10,$3810
	DC.W	$181C,$1610,$1070,$F060
	DC.W	$F0C0,$FED8,$DE18,$1800
	DC.W	$F0C0,$DFDB,$FF1E,$1B00
	DC.W	$505,$50D,$D19,$7971
	DC.W	$A0A0,$A0B0,$B098,$9E8E
	DC.W	$7CC6,$C600,$C6C6,$7C00
	DC.W	$606,$600,$606,$600
	DC.W	$7C06,$67C,$C0C0,$7C00
	DC.W	$7C06,$67C,$606,$7C00
	DC.W	$C6C6,$C67C,$606,$600
	DC.W	$7CC0,$C07C,$606,$7C00
	DC.W	$7CC0,$C07C,$C6C6,$7C00
	DC.W	$7C06,$600,$606,$600
	DC.W	$7CC6,$C67C,$C6C6,$7C00
	DC.W	$7CC6,$C67C,$606,$7C00
	DC.W	0,$3C06,$7E66,$3C00
	DC.W	$7860,$7860,$7E18,$1E00
	DC.W	$70F,$1F18,$1810,$1E17
	DC.W	$F0F8,$EC04,$404,$3C54
	DC.W	$110B,$D06,$72E,$3938
	DC.W	$428,$D828,$D010,$E000
	DC.W	0,0,0,0
	DC.W	$1818,$1818,$1800,$1800
	DC.W	$6666,$6600,0,0
	DC.W	$6C,$FE6C,$6CFE,$6C00
	DC.W	$287E,$A87C,$2AFC,$2800
	DC.W	$6396,$6C18,$3669,$C600
	DC.W	$78CC,$61CE,$CCCC,$7800
	DC.W	$1818,$1000,0,0
	DC.W	$408,$1818,$1808,$400
	DC.W	$2010,$1818,$1810,$2000
	DC.W	$1054,$38FE,$3854,$1000
	DC.W	$18,$187E,$1818,0
	DC.W	0,0,$30,$3020
	DC.W	0,$7E,0,0
	DC.W	0,0,$18,$1800
	DC.W	$206,$C18,$3060,$4000
	DC.W	$3C66,$6E76,$6666,$3C00
	DC.W	$1838,$1818,$1818,$1800
	DC.W	$3C66,$60C,$1830,$7E00
	DC.W	$7E0C,$180C,$666,$3C00
	DC.W	$C1C,$3C6C,$7E0C,$C00
	DC.W	$7E60,$7C06,$666,$3C00
	DC.W	$3C60,$607C,$6666,$3C00
	DC.W	$7E06,$C18,$3030,$3000
	DC.W	$3C66,$663C,$6666,$3C00
	DC.W	$3C66,$663E,$60C,$3800
	DC.W	$18,$1800,$1818,0
	DC.W	$18,$1800,$1818,$1000
	DC.W	$60C,$1830,$180C,$600
	DC.W	0,$7E00,$7E,0
	DC.W	$6030,$180C,$1830,$6000
	DC.W	$3C66,$60C,$1800,$1800
	DC.W	$3C66,$6E6A,$6E60,$3E00
	DC.W	$3C66,$667E,$6666,$6600
	DC.W	$7C66,$667C,$6666,$7C00
	DC.W	$3C62,$6060,$6062,$3C00
	DC.W	$7C66,$6666,$6666,$7C00
	DC.W	$7E60,$607C,$6060,$7E00
	DC.W	$7E60,$607C,$6060,$6000
	DC.W	$3C62,$606E,$6666,$3E00
	DC.W	$6666,$667E,$6666,$6600
	DC.W	$1818,$1818,$1818,$1800
	DC.W	$606,$606,$646,$3C00
	DC.W	$666C,$7870,$786C,$6600
	DC.W	$6060,$6060,$6060,$7E00
	DC.W	$FEDB,$DBDB,$DBDB,$DB00
	DC.W	$6676,$7E7E,$6E66,$6600
	DC.W	$3C66,$6666,$6666,$3C00
	DC.W	$7C66,$667C,$6060,$6000
	DC.W	$3C66,$6666,$6666,$3C06
	DC.W	$7C66,$667C,$6666,$6600
	DC.W	$3C62,$703C,$E46,$3C00
	DC.W	$7E18,$1818,$1818,$1800
	DC.W	$6666,$6666,$6666,$3C00
	DC.W	$6666,$6666,$666C,$7800
	DC.W	$DBDB,$DBDB,$DBDA,$FC00
	DC.W	$6666,$663C,$6666,$6600
	DC.W	$6666,$663C,$1818,$1800
	DC.W	$7E06,$C18,$3060,$7E00
	DC.W	$1E18,$1818,$1818,$1E00
	DC.W	$4060,$3018,$C06,$200
	DC.W	$7818,$1818,$1818,$7800
	DC.W	$1038,$6CC6,0,0
	DC.W	0,0,0,$FE00
	DC.W	$C0,$6030,0,0
	DC.W	0,$3C46,$3E66,$3E00
	DC.W	$6060,$7C66,$6666,$7C00
	DC.W	0,$3C60,$6060,$3C00
	DC.W	$606,$3E66,$6666,$3E00
	DC.W	0,$3C66,$7E60,$3C00
	DC.W	$1E30,$7C30,$3030,$3000
	DC.W	0,$3E66,$663E,$463C
	DC.W	$6060,$7C66,$6666,$6600
	DC.W	$1800,$1818,$1818,$1800
	DC.W	$C00,$C0C,$C0C,$4C38
	DC.W	$6060,$666C,$786C,$6600
	DC.W	$3030,$3030,$3030,$3000
	DC.W	0,$FEDB,$DBDB,$DB00
	DC.W	0,$7C66,$6666,$6600
	DC.W	0,$3C66,$6666,$3C00
	DC.W	0,$7C66,$6666,$7C60
	DC.W	0,$3E66,$6666,$3E06
	DC.W	0,$6C70,$6060,$6000
	DC.W	0,$3E60,$3C06,$7C00
	DC.W	$18,$3C18,$1818,$C00
	DC.W	0,$6666,$6666,$3E00
	DC.W	0,$6666,$6664,$7800
	DC.W	0,$DBDB,$DBDA,$FC00
	DC.W	0,$6666,$3C66,$6600
	DC.W	0,$6666,$663E,$463C
	DC.W	0,$7E0C,$1830,$7E00
	DC.W	$E18,$1830,$1818,$E00
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$7018,$180C,$1818,$7000
	DC.W	$60,$F29E,$C00,0
	DC.W	$18,$1834,$3462,$7E00
	DC.W	$3C,$6660,$663C,$838
	DC.W	$6600,$66,$6666,$3E00
	DC.W	$C18,$3C,$7E60,$3C00
	DC.W	$1866,$3C,$67E,$3E00
	DC.W	$6600,$3C06,$3E66,$3E00
	DC.W	$3018,$3C,$67E,$3E00
	DC.W	$1818,$3C,$67E,$3E00
	DC.W	0,$3C60,$603C,$818
	DC.W	$1866,$3C,$7E60,$3C00
	DC.W	$6600,$3C66,$7E60,$3C00
	DC.W	$3018,$3C,$7E60,$3C00
	DC.W	$6600,$38,$1818,$3C00
	DC.W	$1866,$38,$1818,$3C00
	DC.W	$6030,$38,$1818,$3C00
	DC.W	$6600,$183C,$667E,$6600
	DC.W	$1800,$183C,$667E,$6600
	DC.W	$C18,$7E60,$7C60,$7E00
	DC.W	0,$7E1B,$7FD8,$7E00
	DC.W	$3F78,$D8DE,$F8D8,$DF00
	DC.W	$1866,$3C,$6666,$3C00
	DC.W	$6600,$3C,$6666,$3C00
	DC.W	$3018,$3C,$6666,$3C00
	DC.W	$1866,$66,$6666,$3E00
	DC.W	$3018,$66,$6666,$3E00
	DC.W	$6600,$6666,$663E,$67C
	DC.W	$6600,$3C66,$6666,$3C00
	DC.W	$6600,$6666,$6666,$3E00
	DC.W	$1818,$3C60,$603C,$1818
	DC.W	$1C3A,$307C,$3030,$7E00
	DC.W	$6666,$3C18,$3C18,$1800
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$C18,$3C,$67E,$3E00
	DC.W	$C18,$38,$1818,$3C00
	DC.W	$C18,$3C,$6666,$3C00
	DC.W	$C18,$66,$6666,$3E00
	DC.W	$3458,$7C,$6666,$6600
	DC.W	$3458,$66,$766E,$6600
	DC.W	$3C,$63E,$663E,$3C
	DC.W	$3C,$6666,$663C,$3C
	DC.W	$18,$18,$3060,$663C
	DC.W	0,$3E,$3030,$3000
	DC.W	0,$7C,$C0C,$C00
	DC.W	$C6CC,$D836,$6BC3,$860F
	DC.W	$C6CC,$D836,$6ED6,$9F06
	DC.W	$18,$18,$1818,$1818
	DC.W	$1B36,$6CD8,$6C36,$1B00
	DC.W	$D86C,$361B,$366C,$D800
	DC.W	$3458,$3C,$67E,$3E00
	DC.W	$3458,$3C,$6666,$3C00
	DC.W	$23C,$666E,$7666,$3C40
	DC.W	2,$3C6E,$7666,$3C40
	DC.W	$1818,$1818,$F818,$1818
	DC.W	$1818,$F818,$F818,$1818
	DC.W	$3636,$3636,$F636,$3636
	DC.W	0,$FE6C,$6C6C,$6C00
	DC.W	0,$F818,$F818,$1818
	DC.W	$3636,$F606,$F636,$3636
	DC.W	$3636,$3636,$3636,$3636
	DC.W	0,$FE06,$F636,$3636
	DC.W	$3636,$F606,$FE00,0
	DC.W	$1818,$F818,$F800,0
	DC.W	$1818,$F818,$F800,0
	DC.W	0,0,$F818,$1818
	DC.W	$1818,$1818,$1F00,0
	DC.W	$1818,$1818,$FF00,0
	DC.W	0,0,$FF18,$1818
	DC.W	$1818,$1818,$1F18,$1818
	DC.W	0,0,$FF00,0
	DC.W	$1818,$1818,$FF18,$1818
	DC.W	$1818,$1F18,$1F18,$1818
	DC.W	$3636,$3636,$3736,$3636
	DC.W	$3636,$3730,$3F00,0
	DC.W	0,$3F30,$3736,$3636
	DC.W	$3636,$F700,$FF00,0
	DC.W	0,$FF00,$F736,$3636
	DC.W	$3636,$3730,$3736,$3636
	DC.W	0,$FF00,$FF00,0
	DC.W	$3636,$F700,$F736,$3636
	DC.W	$1818,$FF00,$FF00,0
	DC.W	$3636,$3636,$FF00,0
	DC.W	0,$FF00,$FF18,$1818
	DC.W	0,0,$FF36,$3636
	DC.W	$3636,$3636,$3F00,0
	DC.W	$3030,$3F30,$3F00,0
	DC.W	0,$3F30,$3F30,$3030
	DC.W	0,0,$7F6C,$6C6C
	DC.W	$3636,$3636,$FF36,$3636
	DC.W	$1818,$FF18,$FF18,$1818
	DC.W	$1818,$1818,$F800,0
	DC.W	0,0,$1F18,$1818
	DC.W	$FF,$FFFF,$FFFF,$FF00
	DC.W	0,0,$FFFF,$FF00
	DC.W	$E1B,$3C66,$663C,$D870
	DC.W	$10,$386C,$C682,0
	DC.W	$66F7,$9999,$EF66,0
	DC.W	0,$76DC,$C8DC,$7600
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$FE,$6662,$6060,$60F8
	DC.W	0,$FE6C,$6C6C,$6C48
	DC.W	$FE66,$3018,$3066,$FE00
	DC.W	$1E,$386C,$6C6C,$3800
	DC.W	0,$6C6C,$6C6C,$7FC0
	DC.W	0,$7E18,$1818,$1810
	DC.W	$3C18,$3C66,$663C,$183C
	DC.W	$3C,$667E,$6666,$3C00
	DC.W	$3C,$6666,$6624,$6600
	DC.W	$1C36,$78DC,$CCEC,$7800
	DC.W	$C18,$3854,$5438,$3060
	DC.W	$10,$7CD6,$D6D6,$7C10
	DC.W	$3E70,$607E,$6070,$3E00
	DC.W	$3C66,$6666,$6666,$6600
	DC.W	$7E,$7E,$7E,0
	DC.W	$1818,$7E18,$1800,$7E00
	DC.W	$3018,$C18,$3000,$7E00
	DC.W	$C18,$3018,$C00,$7E00
	DC.W	$E,$1B1B,$1818,$1818
	DC.W	$1818,$1818,$D8D8,$7000
	DC.W	$1818,$7E,$18,$1800
	DC.W	$32,$4C00,$324C,0
	DC.W	$386C,$3800,0,0
	DC.W	$387C,$3800,0,0
	DC.W	0,0,$1818,0
	DC.W	0,$F18,$D870,$3000
	DC.W	$386C,$6C6C,$6C00,0
	DC.W	$386C,$1830,$7C00,0
	DC.W	$780C,$380C,$7800,0
	DC.W	$FE,0,0,0
font2:
	DC.W	0,0,0,0
	DC.W	$183C,$66C3,$E724,$243C
	DC.W	$3C24,$24E7,$C366,$3C18
	DC.W	$181C,$F683,$83F6,$1C18
	DC.W	$1838,$6FC1,$C16F,$3818
	DC.W	$3C99,$C3E7,$C399,$3C00
	DC.W	$FFFF,$FEFC,$F9F3,$E700
	DC.W	$E7C3,$993C,$99C3,$E700
	DC.W	$103,$68C,$D870,$2000
	DC.W	$7EC3,$D3D3,$DBC3,$C37E
	DC.W	$183C,$3C3C,$7E10,$3810
	DC.W	$181C,$1610,$1070,$F060
	DC.W	$F0C0,$FED8,$DE18,$1800
	DC.W	$F0C0,$DFDB,$FF1E,$1B00
	DC.W	$505,$50D,$D19,$7971
	DC.W	$A0A0,$A0B0,$B098,$9E8E
	DC.W	$7CC6,$C600,$C6C6,$7C00
	DC.W	$606,$600,$606,$600
	DC.W	$7C06,$67C,$C0C0,$7C00
	DC.W	$7C06,$67C,$606,$7C00
	DC.W	$C6C6,$C67C,$606,$600
	DC.W	$7CC0,$C07C,$606,$7C00
	DC.W	$7CC0,$C07C,$C6C6,$7C00
	DC.W	$7C06,$600,$606,$600
	DC.W	$7CC6,$C67C,$C6C6,$7C00
	DC.W	$7CC6,$C67C,$606,$7C00
	DC.W	0,$3C06,$7E66,$3C00
	DC.W	$7860,$7860,$7E18,$1E00
	DC.W	$70F,$1F18,$1810,$1E17
	DC.W	$F0F8,$EC04,$404,$3C54
	DC.W	$110B,$D06,$72E,$3938
	DC.W	$428,$D828,$D010,$E000
	DC.W	0,0,0,0
	DC.W	$1818,$1818,$1800,$1800
	DC.W	$6666,$6600,0,0
	DC.W	$6C,$FE6C,$6CFE,$6C00
	DC.W	$183E,$603C,$67C,$1800
	DC.W	$66,$6C18,$3066,$4600
	DC.W	$386C,$3870,$DECC,$7600
	DC.W	$1818,$1800,0,0
	DC.W	$E1C,$1818,$181C,$E00
	DC.W	$7038,$1818,$1838,$7000
	DC.W	$66,$3CFF,$3C66,0
	DC.W	$18,$187E,$1818,0
	DC.W	0,0,$30,$3060
	DC.W	0,$7E,0,0
	DC.W	0,0,$18,$1800
	DC.W	$206,$C18,$3060,$4000
	DC.W	$3C66,$6E76,$6666,$3C00
	DC.W	$1838,$1818,$1818,$7E00
	DC.W	$3C66,$60C,$1830,$7E00
	DC.W	$7E0C,$180C,$666,$3C00
	DC.W	$C1C,$3C6C,$7E0C,$C00
	DC.W	$7E60,$7C06,$666,$3C00
	DC.W	$3C60,$607C,$6666,$3C00
	DC.W	$7E06,$C18,$3030,$3000
	DC.W	$3C66,$663C,$6666,$3C00
	DC.W	$3C66,$663E,$60C,$3800
	DC.W	$18,$1800,$1818,0
	DC.W	$18,$1800,$1818,$3000
	DC.W	$60C,$1830,$180C,$600
	DC.W	0,$7E00,$7E,0
	DC.W	$6030,$180C,$1830,$6000
	DC.W	$3C66,$60C,$1800,$1800
	DC.W	$3C66,$6E6A,$6E60,$3E00
	DC.W	$183C,$6666,$7E66,$6600
	DC.W	$7C66,$667C,$6666,$7C00
	DC.W	$3C66,$6060,$6066,$3C00
	DC.W	$786C,$6666,$666C,$7800
	DC.W	$7E60,$607C,$6060,$7E00
	DC.W	$7E60,$607C,$6060,$6000
	DC.W	$3E60,$606E,$6666,$3E00
	DC.W	$6666,$667E,$6666,$6600
	DC.W	$3C18,$1818,$1818,$3C00
	DC.W	$606,$606,$666,$3C00
	DC.W	$666C,$7870,$786C,$6600
	DC.W	$6060,$6060,$6060,$7E00
	DC.W	$C6EE,$FED6,$C6C6,$C600
	DC.W	$6676,$7E7E,$6E66,$6600
	DC.W	$3C66,$6666,$6666,$3C00
	DC.W	$7C66,$667C,$6060,$6000
	DC.W	$3C66,$6666,$766C,$3600
	DC.W	$7C66,$667C,$6C66,$6600
	DC.W	$3C66,$603C,$666,$3C00
	DC.W	$7E18,$1818,$1818,$1800
	DC.W	$6666,$6666,$6666,$3E00
	DC.W	$6666,$6666,$663C,$1800
	DC.W	$C6C6,$C6D6,$FEEE,$C600
	DC.W	$6666,$3C18,$3C66,$6600
	DC.W	$6666,$663C,$1818,$1800
	DC.W	$7E06,$C18,$3060,$7E00
	DC.W	$1E18,$1818,$1818,$1E00
	DC.W	$4060,$3018,$C06,$200
	DC.W	$7818,$1818,$1818,$7800
	DC.W	$1038,$6CC6,0,0
	DC.W	0,0,0,$FE00
	DC.W	$C0,$6030,0,0
	DC.W	0,$3C06,$3E66,$3E00
	DC.W	$6060,$7C66,$6666,$7C00
	DC.W	0,$3C60,$6060,$3C00
	DC.W	$606,$3E66,$6666,$3E00
	DC.W	0,$3C66,$7E60,$3C00
	DC.W	$1C30,$7C30,$3030,$3000
	DC.W	0,$3E66,$663E,$67C
	DC.W	$6060,$7C66,$6666,$6600
	DC.W	$1800,$3818,$1818,$3C00
	DC.W	$1800,$1818,$1818,$1870
	DC.W	$6060,$666C,$786C,$6600
	DC.W	$3818,$1818,$1818,$3C00
	DC.W	0,$ECFE,$D6C6,$C600
	DC.W	0,$7C66,$6666,$6600
	DC.W	0,$3C66,$6666,$3C00
	DC.W	0,$7C66,$6666,$7C60
	DC.W	0,$3E66,$6666,$3E06
	DC.W	0,$7C66,$6060,$6000
	DC.W	0,$3E60,$3C06,$7C00
	DC.W	$18,$7E18,$1818,$E00
	DC.W	0,$6666,$6666,$3E00
	DC.W	0,$6666,$663C,$1800
	DC.W	0,$C6C6,$D67C,$6C00
	DC.W	0,$663C,$183C,$6600
	DC.W	0,$6666,$663E,$67C
	DC.W	0,$7E0C,$1830,$7E00
	DC.W	$E18,$1830,$1818,$E00
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$7018,$180C,$1818,$7000
	DC.W	$60,$F29E,$C00,0
	DC.W	$18,$1834,$3462,$7E00
	DC.W	$3C,$6660,$663C,$838
	DC.W	$6600,$66,$6666,$3E00
	DC.W	$C18,$3C,$7E60,$3C00
	DC.W	$1866,$3C,$67E,$3E00
	DC.W	$6600,$3C06,$3E66,$3E00
	DC.W	$3018,$3C,$67E,$3E00
	DC.W	$1818,$3C,$67E,$3E00
	DC.W	0,$3C60,$603C,$818
	DC.W	$1866,$3C,$7E60,$3C00
	DC.W	$6600,$3C66,$7E60,$3C00
	DC.W	$3018,$3C,$7E60,$3C00
	DC.W	$6600,$38,$1818,$3C00
	DC.W	$1866,$38,$1818,$3C00
	DC.W	$6030,$38,$1818,$3C00
	DC.W	$6600,$183C,$667E,$6600
	DC.W	$1800,$183C,$667E,$6600
	DC.W	$C18,$7E60,$7C60,$7E00
	DC.W	0,$7E1B,$7FD8,$7E00
	DC.W	$3F78,$D8DE,$F8D8,$DF00
	DC.W	$1866,$3C,$6666,$3C00
	DC.W	$6600,$3C,$6666,$3C00
	DC.W	$3018,$3C,$6666,$3C00
	DC.W	$1866,$66,$6666,$3E00
	DC.W	$3018,$66,$6666,$3E00
	DC.W	$6600,$6666,$663E,$67C
	DC.W	$6600,$3C66,$6666,$3C00
	DC.W	$6600,$6666,$6666,$3E00
	DC.W	$1818,$3C60,$603C,$1818
	DC.W	$1C3A,$307C,$3030,$7E00
	DC.W	$6666,$3C18,$3C18,$1800
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$1E30,$7C30,$3030,$6000
	DC.W	$C18,$3C,$67E,$3E00
	DC.W	$C18,$38,$1818,$3C00
	DC.W	$C18,$3C,$6666,$3C00
	DC.W	$C18,$66,$6666,$3E00
	DC.W	$3458,$7C,$6666,$6600
	DC.W	$3458,$66,$766E,$6600
	DC.W	$3C,$63E,$663E,$3C
	DC.W	$3C,$6666,$663C,$3C
	DC.W	$18,$18,$3060,$663C
	DC.W	0,$3E,$3030,$3000
	DC.W	0,$7C,$C0C,$C00
	DC.W	$C6CC,$D836,$6BC3,$860F
	DC.W	$C6CC,$D836,$6ED6,$9F06
	DC.W	$18,$18,$1818,$1818
	DC.W	$1B36,$6CD8,$6C36,$1B00
	DC.W	$D86C,$361B,$366C,$D800
	DC.W	$3458,$3C,$67E,$3E00
	DC.W	$3458,$3C,$6666,$3C00
	DC.W	$23C,$666E,$7666,$3C40
	DC.W	2,$3C6E,$7666,$3C40
	DC.W	0,$7EDB,$DFD8,$7E00
	DC.W	$7FD8,$D8DE,$D8D8,$7F00
	DC.W	$3018,$18,$3C66,$7E66
	DC.W	$3458,$18,$3C66,$7E66
	DC.W	$3458,$3C66,$6666,$663C
	DC.W	$6600,0,0,0
	DC.W	$C18,$3000,0,0
	DC.W	$10,$3810,$1010,0
	DC.W	$7ACA,$CACA,$7A0A,$A0A
	DC.W	$7EC3,$BDB1,$B1BD,$C37E
	DC.W	$7EC3,$BDA5,$B9AD,$C37E
	DC.W	$F15B,$5F55,$5100,0
	DC.W	$6600,$E666,$66F6,$61C
	DC.W	$F666,$6666,$66F6,$61C
	DC.W	$66,$763C,$6E66,0
	DC.W	$7C,$C0C,$C7E,0
	DC.W	$1E,$60E,$1E36,0
	DC.W	$7E,$C0C,$C0C,0
	DC.W	$7C,$666,$6666,0
	DC.W	$1C,$C0C,$C0C,0
	DC.W	$1E,$C06,$606,0
	DC.W	$7E,$3636,$3636,0
	DC.W	$606E,$6666,$667E,0
	DC.W	$3C,$C0C,0,0
	DC.W	$3E,$606,$63E,0
	DC.W	$607E,$606,$60E,0
	DC.W	$6C,$3E66,$666E,0
	DC.W	$1C,$C0C,$C3C,0
	DC.W	$3E,$3636,$361C,0
	DC.W	$36,$3636,$367E,0
	DC.W	$7E,$6676,$67E,0
	DC.W	$66,$663C,$E7E,0
	DC.W	$3E,$636,$3634,$3000
	DC.W	$78,$C0C,$C0C,0
	DC.W	$D6,$D6D6,$D6FE,0
	DC.W	$7C,$6C6C,$6CEC,0
	DC.W	$1C,$C0C,$C0C,$C00
	DC.W	$3E,$606,$606,$600
	DC.W	$FE,$6666,$667E,0
	DC.W	$7E,$6676,$606,$600
	DC.W	$36,$361C,$C0C,$C00
	DC.W	$E1B,$3C66,$663C,$D870
	DC.W	$10,$386C,$C682,0
	DC.W	$66F7,$9999,$EF66,0
	DC.W	0,$76DC,$C8DC,$7600
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$FE,$6662,$6060,$60F8
	DC.W	0,$FE6C,$6C6C,$6C48
	DC.W	$FE66,$3018,$3066,$FE00
	DC.W	$1E,$386C,$6C6C,$3800
	DC.W	0,$6C6C,$6C6C,$7FC0
	DC.W	0,$7E18,$1818,$1810
	DC.W	$3C18,$3C66,$663C,$183C
	DC.W	$3C,$667E,$6666,$3C00
	DC.W	$3C,$6666,$6624,$6600
	DC.W	$1C36,$78DC,$CCEC,$7800
	DC.W	$C18,$3854,$5438,$3060
	DC.W	$10,$7CD6,$D6D6,$7C10
	DC.W	$3E70,$607E,$6070,$3E00
	DC.W	$3C66,$6666,$6666,$6600
	DC.W	$7E,$7E,$7E,0
	DC.W	$1818,$7E18,$1800,$7E00
	DC.W	$3018,$C18,$3000,$7E00
	DC.W	$C18,$3018,$C00,$7E00
	DC.W	$E,$1B1B,$1818,$1818
	DC.W	$1818,$1818,$D8D8,$7000
	DC.W	$1818,$7E,$18,$1800
	DC.W	$32,$4C00,$324C,0
	DC.W	$386C,$3800,0,0
	DC.W	$387C,$3800,0,0
	DC.W	0,0,$1818,0
	DC.W	0,$F18,$D870,$3000
	DC.W	$386C,$6C6C,$6C00,0
	DC.W	$386C,$1830,$7C00,0
	DC.W	$780C,$380C,$7800,0
	DC.W	$FE,0,0,0
pal1:
	dc.w	$000,$200,$310,$420,$530,$640,$750,$760
	dc.w	$770,$775,$777,$211,$322,$433,$544,$655
	dc.w	$000,$200,$310,$420,$530,$640,$122,$233
	dc.w	$344,$766,$777,$211,$322,$433,$544,$655
	dc.w	$000,$201,$312,$423,$534,$645,$756,$766
	dc.w	$346,$655,$777,$211,$322,$433,$544,$777

imptab: 	 ;this is the output from "IMPACT" it's not our own
 dc.w $80E,$90D,$A0C,$0,$80F,$903,$A00,$0,$80F,$903,$A00,$0,$80F,$903,$A00,0
 dc.w $80F,$903,$A00,$0,$80F,$903,$A00,$0,$80F,$903,$A00,$0,$80E,$90D,$A0B,0
 dc.w $80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0B,0
 dc.w $80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0A,$0,$80E,$90D,$A0A,0
 dc.w $80E,$90D,$A0A,$0,$80E,$90D,$A0A,$0,$80E,$90C,$A0C,$0,$80E,$90D,$A00,0
 dc.w $80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80D,$90D,$A0D,0
 dc.w $80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,0
 dc.w $80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,0
 dc.w $80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0A,$0,$80E,$90C,$A0A,0
 dc.w $80E,$90C,$A0A,$0,$80E,$90C,$A0A,$0,$80D,$90D,$A0C,$0,$80D,$90D,$A0C,0
 dc.w $80E,$90C,$A09,$0,$80E,$90C,$A09,$0,$80E,$90C,$A05,$0,$80E,$90C,$A00,0
 dc.w $80E,$90C,$A00,$0,$80E,$90B,$A0B,$0,$80E,$90B,$A0B,$0,$80E,$90B,$A0B,0
 dc.w $80E,$90B,$A0B,$0,$80E,$90B,$A0A,$0,$80E,$90B,$A0A,$0,$80E,$90B,$A0A,0
 dc.w $80D,$90D,$A0B,$0,$80D,$90D,$A0B,$0,$80D,$90D,$A0B,$0,$80E,$90B,$A09,0
 dc.w $80E,$90B,$A09,$0,$80E,$90B,$A09,$0,$80D,$90C,$A0C,$0,$80D,$90D,$A0A,0
 dc.w $80E,$90B,$A07,$0,$80E,$90B,$A00,$0,$80E,$90B,$A00,$0,$80D,$90D,$A09,0
 dc.w $80D,$90D,$A09,$0,$80E,$90A,$A09,$0,$80D,$90D,$A08,$0,$80D,$90D,$A07,0
 dc.w $80D,$90D,$A04,$0,$80D,$90D,$A00,$0,$80E,$90A,$A04,$0,$80E,$909,$A09,0
 dc.w $80E,$909,$A09,$0,$80D,$90C,$A0B,$0,$80E,$909,$A08,$0,$80E,$909,$A08,0
 dc.w $80E,$909,$A07,$0,$80E,$908,$A08,$0,$80E,$909,$A01,$0,$80C,$90C,$A0C,0
 dc.w $80D,$90C,$A0A,$0,$80E,$908,$A06,$0,$80E,$907,$A07,$0,$80E,$908,$A00,0
 dc.w $80E,$907,$A05,$0,$80E,$906,$A06,$0,$80D,$90C,$A09,$0,$80E,$905,$A05,0
 dc.w $80E,$904,$A04,$0,$80D,$90C,$A08,$0,$80D,$90B,$A0B,$0,$80E,$900,$A00,0
 dc.w $80D,$90C,$A06,$0,$80D,$90C,$A05,$0,$80D,$90C,$A02,$0,$80C,$90C,$A0B,0
 dc.w $80C,$90C,$A0B,$0,$80D,$90B,$A0A,$0,$80D,$90B,$A0A,$0,$80D,$90B,$A0A,0
 dc.w $80D,$90B,$A0A,$0,$80C,$90C,$A0A,$0,$80C,$90C,$A0A,$0,$80C,$90C,$A0A,0
 dc.w $80D,$90B,$A09,$0,$80D,$90B,$A09,$0,$80D,$90A,$A0A,$0,$80D,$90A,$A0A,0
 dc.w $80D,$90A,$A0A,$0,$80C,$90C,$A09,$0,$80C,$90C,$A09,$0,$80C,$90C,$A09,0
 dc.w $80D,$90B,$A06,$0,$80C,$90B,$A0B,$0,$80C,$90C,$A08,$0,$80D,$90B,$A00,0
 dc.w $80D,$90B,$A00,$0,$80C,$90C,$A07,$0,$80C,$90C,$A06,$0,$80C,$90C,$A05,0
 dc.w $80C,$90C,$A03,$0,$80C,$90C,$A01,$0,$80C,$90B,$A0A,$0,$80D,$90A,$A05,0
 dc.w $80D,$90A,$A04,$0,$80D,$90A,$A02,$0,$80D,$909,$A08,$0,$80D,$909,$A08,0
 dc.w $80C,$90B,$A09,$0,$80C,$90B,$A09,$0,$80D,$908,$A08,$0,$80B,$90B,$A0B,0
 dc.w $80D,$909,$A05,$0,$80C,$90B,$A08,$0,$80D,$909,$A02,$0,$80D,$908,$A06,0
 dc.w $80C,$90B,$A07,$0,$80D,$907,$A07,$0,$80C,$90B,$A06,$0,$80C,$90A,$A09,0
 dc.w $80B,$90B,$A0A,$0,$80C,$90B,$A02,$0,$80C,$90B,$A00,$0,$80C,$90A,$A08,0
 dc.w $80D,$906,$A04,$0,$80D,$905,$A05,$0,$80D,$905,$A04,$0,$80C,$909,$A09,0
 dc.w $80D,$904,$A03,$0,$80B,$90B,$A09,$0,$80C,$90A,$A05,$0,$80B,$90A,$A0A,0
 dc.w $80C,$909,$A08,$0,$80B,$90B,$A08,$0,$80C,$90A,$A00,$0,$80C,$90A,$A00,0
 dc.w $80C,$909,$A07,$0,$80B,$90B,$A07,$0,$80C,$909,$A06,$0,$80B,$90B,$A06,0
 dc.w $80B,$90A,$A09,$0,$80B,$90B,$A05,$0,$80A,$90A,$A0A,$0,$80B,$90B,$A02,0
 dc.w $80B,$90A,$A08,$0,$80C,$907,$A07,$0,$80C,$908,$A04,$0,$80C,$907,$A06,0
 dc.w $80B,$909,$A09,$0,$80C,$906,$A06,$0,$80A,$90A,$A09,$0,$80C,$907,$A03,0
 dc.w $80B,$90A,$A05,$0,$80B,$909,$A08,$0,$80B,$90A,$A03,$0,$80A,$90A,$A08,0
 dc.w $80B,$90A,$A00,$0,$80B,$909,$A07,$0,$80B,$908,$A08,$0,$80A,$90A,$A07,0
 dc.w $80A,$909,$A09,$0,$80C,$901,$A01,$0,$80A,$90A,$A06,$0,$80B,$908,$A07,0
 dc.w $80A,$90A,$A05,$0,$80A,$909,$A08,$0,$80A,$90A,$A02,$0,$80A,$90A,$A01,0
 dc.w $80A,$90A,$A00,$0,$809,$909,$A09,$0,$80A,$908,$A08,$0,$80B,$908,$A01,0
 dc.w $80A,$909,$A06,$0,$80B,$907,$A04,$0,$80A,$909,$A05,$0,$809,$909,$A08,0
 dc.w $80A,$909,$A03,$0,$80A,$908,$A06,$0,$80A,$909,$A00,$0,$809,$909,$A07,0
 dc.w $809,$908,$A08,$0,$80A,$908,$A04,$0,$809,$909,$A06,$0,$80A,$908,$A01,0
 dc.w $809,$909,$A05,$0,$809,$908,$A07,$0,$808,$908,$A08,$0,$809,$909,$A02,0
 dc.w $809,$908,$A06,$0,$809,$909,$A00,$0,$809,$907,$A07,$0,$808,$908,$A07,0
 dc.w $809,$907,$A06,$0,$809,$908,$A02,$0,$808,$908,$A06,$0,$809,$906,$A06,0
 dc.w $808,$907,$A07,$0,$808,$908,$A04,$0,$808,$907,$A06,$0,$808,$908,$A02,0
 dc.w $807,$907,$A07,$0,$808,$906,$A06,$0,$808,$907,$A04,$0,$807,$907,$A06,0
 dc.w $808,$906,$A05,$0,$808,$906,$A04,$0,$807,$906,$A06,$0,$807,$907,$A04,0
 dc.w $808,$905,$A04,$0,$806,$906,$A06,$0,$807,$906,$A04,$0,$807,$905,$A05,0
 dc.w $806,$906,$A05,$0,$806,$906,$A04,$0,$806,$905,$A05,$0,$806,$906,$A02,0
 dc.w $806,$905,$A04,$0,$805,$905,$A05,$0,$806,$905,$A02,$0,$805,$905,$A04,0
 dc.w $805,$904,$A04,$0,$805,$905,$A02,$0,$804,$904,$A04,$0,$804,$904,$A03,0
 dc.w $804,$904,$A02,$0,$804,$903,$A03,$0,$803,$903,$A03,$0,$803,$903,$A02,0
 dc.w $803,$902,$A02,$0,$802,$902,$A02,$0,$802,$902,$A01,$0,$801,$901,$A01,0
 dc.w $802,$901,$A00,$0,$801,$901,$A00,$0,$801,$900,$A00,$0,$800,$900,$A00,0


	ifne	picc=1
piccy:
	incbin	e:\exp.pic
	endc

endwi:
;sam:
;	incbin	d:\organmin.spl
;sam_end:
;	even
