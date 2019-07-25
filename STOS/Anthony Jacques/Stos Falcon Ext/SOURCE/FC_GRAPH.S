**************************************************
*
* Falcon Extension for STOS, Graphics sub-system
*
* V1.4
*
* Compiler version
*

	OUTPUT	D:\STOS\COMPILER\FGRAPHIC.ECX

* Condition for registered / shareware
* 0 = un-registered

unregistered	equ	1

* Offsets to parts of the extension

START	dc.l	PARA-START
	dc.l	DATA-START
	dc.l	LIB1-START

* here is the library catalogue - ie length of each routine

CATALOG	dc.w	LIB2-LIB1	; I have 57 routines (inc. 8 dummy's)
	dc.w	LIB3-LIB2
	dc.w	LIB4-LIB3
	dc.w	LIB5-LIB4
	dc.w	LIB6-LIB5
	dc.w	LIB7-LIB6
	dc.w	LIB8-LIB7
	dc.w	LIB9-LIB8
	dc.w	LIB10-LIB9
	dc.w	LIB11-LIB10
	dc.w	LIB12-LIB11
	dc.w	LIB13-LIB12
	dc.w	LIB14-LIB13
	dc.w	LIB15-LIB14
	dc.w	LIB16-LIB15
	dc.w	LIB17-LIB16
	dc.w	LIB18-LIB17
	dc.w	LIB19-LIB18
	dc.w	LIB20-LIB19
	dc.w	LIB21-LIB20
	dc.w	LIB22-LIB21
	dc.w	LIB23-LIB22
	dc.w	LIB24-LIB23
	dc.w	LIB25-LIB24
	dc.w	LIB26-LIB25
	dc.w	LIB27-LIB26
	dc.w	LIB28-LIB27
	dc.w	LIB29-LIB28
	dc.w	LIB30-LIB29
	dc.w	LIB31-LIB30
	dc.w	LIB32-LIB31
	dc.w	LIB33-LIB32
	dc.w	LIB34-LIB33
	dc.w	LIB35-LIB34
	dc.w	LIB36-LIB35
	dc.w	LIB37-LIB36
	dc.w	LIB38-LIB37
	dc.w	LIB39-LIB38
	dc.w	LIB40-LIB39
	dc.w	LIB41-LIB40
	dc.w	LIB42-LIB41
	dc.w	LIB43-LIB42
	dc.w	LIB44-LIB43
	dc.w	LIB45-LIB44
	dc.w	LIB46-LIB45
	dc.w	LIB47-LIB46
	dc.w	LIB48-LIB47
	dc.w	LIB49-LIB48
	dc.w	LIB50-LIB49
	dc.w	LIB51-LIB50
	dc.w	LIB52-LIB51
	dc.w	LIB53-LIB52
	dc.w	LIB54-LIB53
	dc.w	LIB55-LIB54
	dc.w	LIB56-LIB55
	dc.w	LIB57-LIB56
	dc.w	LIB58-LIB57
	dc.w	LIB59-LIB58
	dc.w	LIB60-LIB59
	dc.w	LIB61-LIB60
	dc.w	LIB62-LIB61
	dc.w	LIB63-LIB62
	dc.w	LIBEX-LIB63
	
* Here is the parameter table header

PARA	dc.w	63,63
	dc.w	pset_video-PARA
	dc.w	pcookie-PARA
	dc.w	pinitgoraud-PARA
	dc.w	pjagpad-PARA
	dc.w	ptc_plot-PARA
	dc.w	pmonitor-PARA
	dc.w	pdfvideo-PARA
	dc.w	pnewfade-PARA
	dc.w	pcycle-PARA
	dc.w	pos_ver-PARA
	dc.w	ptc_sprite-PARA
	dc.w	ptc_point-PARA
	dc.w	pfalc_cls-PARA
	dc.w	ptc_fade-PARA
	dc.w	pset_fv-PARA
	dc.w	pscrnsize-PARA
	dc.w	pget_fpal-PARA
	dc.w	ptc_scrnfde-PARA
	dc.w	pinit_virtual-PARA
	dc.w	pxmouse-PARA
	dc.w	pvirtual-PARA
	dc.w	pymouse-PARA
	dc.w	ptc_bar-PARA
	dc.w	pmkey-PARA
	dc.w	ptc_box-PARA
	dc.w	pzone-PARA
	dc.w	ptc_copy-PARA
	dc.w	pcache-PARA
	dc.w	pset_fpal-PARA
	dc.w	pxres-PARA
	dc.w	pgoraud-PARA
	dc.w	pyres-PARA
	dc.w	pinit_mouse-PARA
	dc.w	pdummy-PARA
	dc.w	pmouse_off-PARA
	dc.w	pplanes-PARA
	dc.w	pset_zone-PARA
	dc.w	ptga_width-PARA
	dc.w	pset_mouse-PARA
	dc.w	ptga_height-PARA
	dc.w	pink-PARA
	dc.w	ptc_collide-PARA
	dc.w	pstcompat-PARA
	dc.w	pfli_frame-PARA
	dc.w	pset_cache-PARA
	dc.w	pdummy-PARA
	dc.w	pfalc_colour-PARA
	dc.w	pdummy-PARA
	dc.w	ptga_decode-PARA
	dc.w	pdummy-PARA
	dc.w	ptga_encode-PARA
	dc.w	pdummy-PARA
	dc.w	ptc_text-PARA
	dc.w	pdummy-PARA
	dc.w	pfalc_draw-PARA
	dc.w	pdummy-PARA
	dc.w	pgdos_font-PARA
	dc.w	pdummy-PARA
	dc.w	pfli_init-PARA
	dc.w	pdummy-PARA
	dc.w	pfli_do_frame-PARA
	dc.w	pdummy-PARA
	dc.w	ptc_alpha-PARA

* Here are the actual parameter definitions

pset_video	dc.b	0,0,1,1,0
pcookie		dc.b	0,$80,1,1,0
pjagpad		dc.b	0,0,1,1,0
pmonitor	dc.b	0,1,1,0
pnewfade	dc.b	0,1,1,0
pos_ver		dc.b	0,1,1,0
pinitgoraud	dc.b	0,1,1,0
ptc_point	dc.b	0,0,",",0,",",0,1,1,0
ptc_plot	dc.b	0,0,",",0,",",0,1,1,0
pdfvideo	dc.b	0,0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,1,1,0
pcycle		dc.b	0,0,",",0,1,1,0
ptc_fade	dc.b	0,0,",",0,1,1,0
pscrnsize	dc.b	0,0,1,1,0
ptc_scrnfde	dc.b	0,0,",",0,",",0,1,1,0
ptc_sprite	dc.b	0,0,",",0,",",0,",",0,",",0,1,1,0
pinit_virtual	dc.b	0,0,",",0,1,1,0
pvirtual	dc.b	0,0,",",0,",",0,1,1,0
pgoraud		dc.b	0,0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,1,1,0
ptc_bar		dc.b	0,0,",",0,",",0,",",0,",",0,1,1,0
ptc_box		dc.b	0,0,",",0,",",0,",",0,",",0,1,1,0
ptc_copy	dc.b	0,0,",",0,",",0,",",0,",",0,",",0,",",0,",",0,1,1,0
pset_fpal	dc.b	0,0,",",0,",",0,1,1,0
pget_fpal	dc.b	0,0,",",0,",",0,1,1,0
pset_fv		dc.b	0,0,1,1,0
pfalc_cls	dc.b	0,0,1,1,0
pxmouse		dc.b	0,1,1,0
pymouse		dc.b	0,1,1,0
pmkey		dc.b	0,1,1,0
pzone		dc.b	0,0,1,1,0
pinit_mouse	dc.b	0,1,1,0
pmouse_off	dc.b	0,1,1,0
pset_zone	dc.b	0,0,",",0,",",0,",",0,",",0,1,1,0
pset_mouse	dc.b	0,0,",",0,1,1,0
pink		dc.b	0,0,1				
		dc.b	0,",",0,",",0,1,1,0		
pstcompat	dc.b	0,0,1,1,0
pcache		dc.b	0,1,1,0
pset_cache	dc.b	0,0,1,1,0
pfalc_colour	dc.b	0,0,",",0,",",0,",",0,1,1,0
pxres		dc.b	0,1,1,0
pyres		dc.b	0,1,1,0
pplanes		dc.b	0,1,1,0
ptga_width	dc.b	0,0,1,1,0
ptga_height	dc.b	0,0,1,1,0
ptga_decode	dc.b	0,0,",",0,1,1,0
ptga_encode	dc.b	0,0,",",0,",",0,",",0,1,1,0
ptc_collide	dc.b	0,1,1,0
ptc_text	dc.b	0,0,",",0,",",0,",",$80,1,1,0
pgdos_font	dc.b	0,0,",",0,1,1,0
pfalc_draw	dc.b	0,",",0,",",0,",",0,",",0,1,1,0
pfli_init	dc.b	0,0,1,1,0
pfli_do_frame	dc.b	0,0,1,1,0
pfli_frame	dc.b	0,1,1,0
ptc_alpha	dc.b	0,0,1,1,0

pdummy		dc.b	0,1,1,0

* Here is the data space

	EVEN

DATA	bra	COLDST

c1numpad	ds.l	1
c2numpad	ds.l	1	

videomodes	ds.w	11
planes		ds.w	1
xresb		ds.w	1
xres		ds.w	1
yres		ds.w	1
old_mousevec:	ds.l	1
mouse_x		ds.w	1
mouse_y		ds.w	1
mbut		ds.w	1
zones		ds.w	512 
ink		ds.l	1
colflag		ds.b	1
txtcol		ds.w	1
gfont		dc.l	$e4b6c8

alpha_and	ds.w	1
alpha_nand	ds.w	1
alpha_flag	dc.b	0

FLI_frm_addr	ds.l	1
FLI_frst_frm	ds.l	1
FLI_frm_cnt	ds.w	1
FLI_lst_frm	ds.w	1
FLI_pal		ds.w	256

grad_table	ds.w 642


************
*
* FLI Header equates.

_hd_length	equ	128

_hd_size	equ	0
_hd_magic	equ	4
_hd_frames	equ	6
_hd_speed	equ	12


_frm_length	equ	16

_frm_size	equ	0
_frm_magic	equ	4
_frm_no_chunks	equ	6


_chk_length	equ	6

_chk_size	equ	0
_chk_type	equ	4


_hd_magic_val	equ	$11af
_hd_magic_FLC	equ	$12af
_frm_magic_val	equ	$faf1


*******
* Chunk types

_cmp_pal_256	equ	4	* handled
_cmp_line2	equ	7	* handled
_cmp_pal	equ	11	* handled
_cmp_line	equ	12	* handled 
_blank		equ	13	* handled
_cmp_scr	equ	15	* handled 
_uncmp_scr	equ	16	* handled


*********
*
* Intel -> Motorola format conversion macro

moto	macro	intel		* Bloody obvious!!! Why did I not think of
	ror.w	#8,\1		* this before...
	endm

* Initialisation code

COLDST	lea	END(pc),a2


	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	movem.l	d0-d7/a0-a6,-(sp)

	move.l	$4f2,a2		; get OS version
	move.w	2(a2),d1
	cmpi.w	#$400,d1
	blt	gmminit		; if not F030 then skip this stuff

	move.b	#%1000101,$ff8007	; Falcon bus, 16Mhz blitter/CPU

	move.w	#12561,d0	; cache on
	movec	d0,CACR

	move.w	#-1,-(sp)	; get current mode
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	d0,d1		; store it
	move.w	d0,d7

	move.w	d0,d2		*********
	move.w	d0,d3		*********
	move.w	d0,d4		*********

	lea.l	videomodes(pc),a2
	move.w	d0,20(a2)

	move.w	#89,-(sp)	; get monitor type
	trap	#14
	addq.l	#2,sp

	cmpi.b	#2,d0		; if not VGA goto starttv
	bne	starttv
	
	btst	#8,d7		; if hires, then jump
	beq	sthi
	andi.w	#%111011111,d7
	ori.w	#%000010000,d7
	move.w	d7,d2
	bra	doit

sthi	move.w	#%10011000,d2	; set hirez
	move.l	#0,$ff9804

	move.w	d2,-(sp)	; set the mode
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	bra	doit

starttv	btst	#8,d1		; test whether hi rez
	bne	tvhi
	andi.w	#%111101111,d7
	move.w	d7,d2	
	bra	doit

tvhi	move.w	#%110001000,d2	; yes, so go to hi.
	move.l	#0,$ff9804

	move.w	d2,d3
	move.w	d2,d4
	move.w	d2,-(sp)	; set the mode
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

doit	lea.l	planes(pc),a0
	andi.b	#%111,d3
	beq.s	.mcol
	cmpi.b	#1,d3
	beq.s	.fcol
	cmpi.b	#2,d3
	beq.s	.scol
	cmpi.b	#3,d3
	beq.s	.tcol
	move.w	#16,(a0)
	bra.s	.svcont

.mcol	move.w	#1,(a0)
	bra.s	.svcont

.fcol	move.w	#2,(a0)
	bra.s	.svcont

.scol	move.w	#4,(a0)
	bra.s	.svcont

.tcol	move.w	#8,(a0)

.svcont	move.w	$ff82aa,d0
	sub.w	$ff82a8,d0
	lsr.w	#1,d0

	move.w	$ff82c2,d1
	move.w	d1,d2
	andi.b	#%10,d2
	tst.b	d2
	beq.s	.tstdl
	lsl.w	#1,d0
.tstdl	andi.b	#%1,d1
	tst.b	d1
	beq.s	.setyres
	lsr.w	#1,d0

.setyres
	lea.l	yres(pc),a0
	move.w	d0,(a0)

	move.w	$ff8210,d0	; d0=number of words in a line
	move.w	d0,d1
	lsl.w	#1,d1
	lea	xresb(pc),a0
	move.w	d1,(a0)
	lea	planes(pc),a0
	move.w	(a0),d1
	divu	d1,d0
	mulu	#16,d0
	lea	xres(pc),a0
	move.w	d0,(a0)

	lea	videomodes(pc),a0
	move.w	d4,(a0)

	movem.l	(sp)+,d0-d7/a0-a6


gmminit	

* If unregistered, display startup-text
	IFEQ	unregistered

	movem.l	d0-d7/a0-a6,-(sp)

	move.l	$9a0(a5),a3
	move.l	0(a3,d1.w),a3
	move.l	(a3),d1
	tst	d1
	bne	basic

	move.l	$4f2,a2		; get OS version
	move.w	2(a2),d1
	cmpi.w	#$400,d1
	blt	basic

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,-(sp)

	move.w	#89,-(sp)
	trap	#14
	addq.l	#2,sp

	cmpi	#2,d0
	bne.s	.prot_rgb

	move.w	#%010011000,-(sp)
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea.l	14(sp),sp
	bra.s	.prot_cont

.prot_rgb
	move.w	#%110101000,-(sp)
	move.w	#5,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea.l	14(sp),sp

.prot_cont
	move.l	#0,$ff9804
	move.l	#$ffffffff,$ff9800
	move.l	#$ffff0000,$ff8240

	move.l	#10,d7
	trap	#3

	lea.l	mess(pc),a0
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea.l	14(sp),sp

	move.l	#10,d7
	trap	#3
basic
	movem.l	(sp)+,d0-d7/a0-a6
	ENDC

	clr.l	d0

	rts

END	lea.l	videomodes(pc),a2
	move.w	20(a2),-(sp)

	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	rts

	IFEQ	unregistered
mess	dc.b	'Warning!!',13,10,13,10

	dc.b	'This software  has been compiled  with an un-registered version  of the  STOS',13,10
	dc.b	'Falcon Extension.',13,10
	dc.b	'As the program has reached compilation stage, the programmer should have been',13,10
	dc.b	'honest enough to pay me the money that I am owed.',13,10,13,10

	dc.b	'If you  are the  programmer, then please  send me the  money (at the  address',13,10
	dc.b	'below) as  there are  many benefits to both  you and me (including removal of',13,10
	dc.b	'this message!)',13,10,13,10

	dc.b	'If you are not the programmer, contact me, so that I am aware that the author',13,10
	dc.b	'is distributing  programs writen  with an un-registered  version. Contact me,',13,10
	dc.b	'Anthony Jacques at :-',13,10
	dc.b	'       email: jacquesa@cs.man.ac.uk',13,10
	dc.b	'  snail mail: 70 West Avenue,',13,10
	dc.b	'              Bath,',13,10
	dc.b	'              Avon,',13,10
	dc.b	'              BA2 3QD',13,10
	dc.b	'              (England.)',13,10,13,10

	dc.b	'Press any key to continue...',13,10,0
	ENDC




************************************************
*
* My instructions / functions
*

* set video 
LIB1	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3

	lsl.l	d3
	lea.l	videomodes-DATA(a3),a0
	add.l	d3,a0
	move.w	(a0),d3

	move.w	d3,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	andi.b	#%111,d3
	beq.s	.mcol

	cmpi.b	#1,d3
	beq.s	.fcol

	cmpi.b	#2,d3
	beq.s	.scol

	cmpi.b	#3,d3
	beq.s	.tcol

	move.w	#16,planes-DATA(a3)
	bra.s	.svcont

.mcol	move.w	#1,planes-DATA(a3)
	bra.s	.svcont

.fcol	move.w	#2,planes-DATA(a3)
	bra.s	.svcont

.scol	move.w	#4,planes-DATA(a3)
	bra.s	.svcont

.tcol	move.w	#8,planes-DATA(a3)

.svcont	move.w	$ff82aa,d0
	sub.w	$ff82a8,d0
	lsr.w	d0

	move.w	$ff82c2,d1
	move.w	d1,d2
	andi.b	#%10,d2
	tst.b	d2
	beq.s	.tstdl
	lsl.w	d0
.tstdl	andi.b	#%1,d1
	tst.b	d1
	beq.s	.setyres
	lsr.w	d0

.setyres
	move.w	d0,yres-DATA(a3)

	move.w	$ff8210,d0	; d0=number of words in a line
	move.w	d0,d1
	lsl.w	d1
	move.w	d1,xresb-DATA(a3)
	move.w	planes-DATA(a3),d1
	divu	d1,d0
	mulu	#16,d0
	move.w	d0,xres-DATA(a3)
.svfin
	lea	planes-DATA(a3),a1	*** Tell everyone the new resolution
	move.l	#'FALC',d2
	move.l	#1,d0
	trap	#5

	rts

* Cookie
LIB2	dc.w	0

	move.l	(a6)+,d3

* make a1 = address of cookie ID
	move.l	d3,a1
	addq.l	#2,a1
	move.l	(a1),d2

	move.l	$5a0,a0				address of cookie jar
	beq	.no_cook 			if 0 no cookie jar

* now loop round reading each pair of longwords until
* the empty longword is reached

.loop	move.l	(a0)+,d0			cookie name
	move.l	(a0)+,d1			cookie value 
	cmp.l	#0,d0				check for empty longword
	beq	.no_cook			if empty finished

	cmp.l	d2,d0			check for cookie
	bne.s	.loop				get next cookie

* Return the cookies value, if found

	move.l	d1,-(a6)
	rts

* else, error message - Search failed
.no_cook
	moveq	#5,d0
	move.l	$93c(a5),a0
	jmp	(a0)


* init goraud
LIB3	dc.w	0


	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3


@initgoraud	LEA grad_table-DATA(a3),A0
		MOVE #-320,D0
.lp1		MOVE.L #32768,D1
		DIVS D0,D1
		MOVE.W D1,(A0)+
		ADDQ #1,D0
		CMP #-1,D0
		BNE.S .lp1
		MOVE.W #-32768,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #32767,(A0)+
		MOVEQ #2,D0
.lp2		MOVE.L #32768,D1
		DIVS D0,D1
		MOVE.W D1,(A0)+
		ADDQ #1,D0
		CMP #321,D0
		BNE.S .lp2
		RTS		


* Jagpad
LIB4	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,-(sp)

	bsr	jpd

	move.l	(sp)+,d0

	tst.l	d0
	beq	prt0

	move.l	d6,d3
prt0	move.l	d3,d4
	andi.l	#%1111000000000000000000000,d4
	lsr.l	#4,d4
	andi.l	#%11111111111111111,d3
	or.l	d4,d3

	move.l	d3,-(a6)

	rts


*** JAGPAD code - I have sussed it out!!!!
* Function performs joypad read.
* Returns :-
* d3.l contains c1numpad,c1midbuts,c1firebuts,c1joypad
* d6.l = c2numpad,c2midbuts,c2firebuts,c2joypad


jpd	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	#0,a0
	move.l	#0,c1numpad-DATA(a3)
	move.l	#0,c2numpad-DATA(a3)

* read row 1

	move.w	#$ffee,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#1,d0
	move.b	d0,d3

	move.w	d1,d0
	andi.w	#2,d0
	lsr.w	#1,d0
	move.b	d0,d4

	move.w	d1,d0
	andi.w	#4,d0
	lsr.w	#2,d0
	move.b	d0,d6

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#3,d0
	move.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#8,d0
	move.b	d0,d5

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.l	d0,a0

* read row 2

	move.w	#$ffdd,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	or.b	d0,d4

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#2,d0
	or.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#8,d0
	move.w	d0,c1numpad-DATA(a3)

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.w	d0,c2numpad-DATA(a3)

* read row 3

	move.w	#$ffbb,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	lsl.w	#1,d0
	or.b	d0,d4

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#1,d0
	or.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#4,d0
	or.l	d0,c1numpad-DATA(a3)

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	or.l	d0,c2numpad-DATA(a3)

* read row 4

	move.w	#$ff77,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	or.b	d0,d3

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#2,d0
	or.b	d0,d6

	move.w	d2,d0
	andi.w	#$f00,d0
	or.l	d0,c1numpad-DATA(a3)

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#4,d0
	or.l	d0,c2numpad-DATA(a3)

	lsl.l	#7,d3	; d3 contains xxxx,c1midbuts,c1firebuts,c1joypad
	lsl.l	#4,d4
	or.l	d4,d3
	or.l	d5,d3	

	lsl.l	#7,d6	; d6 = xxxx,c2midbuts,c2firebuts,c2joypad
	lsl.l	#4,d7
	or.l	d7,d6
	move.l	a0,d2
	or.l	d2,d6

	move.l	c1numpad-DATA(a3),d2	; d2 = c1numpad
	lsl.l	#5,d2
	move.l	c2numpad-DATA(a3),d5	; d5 = c2numpad
	lsl.l	#5,d5

	or.l	d2,d3
	or.l	d5,d6

	rts

read_controller
	move.w	d0,$ff9202
	move.w	$ff9200,d1
	move.w	$ff9202,d2

	andi.w	#$f,d1
	andi.w	#$ff00,d2

	not.w	d1
	not.w	d2

	rts


* TC plot
LIB5	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	ink-DATA(a3),d5
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	move.l	(a6)+,a0

	move.w	planes-DATA(a3),d4
	cmpi.w	#16,d4
	bne.s	.bp_plot

	lsl.l	#1,d0
	add.l	d0,a0

	move	xresb-DATA(a3),d0
	mulu	d0,d1
	add.l	d1,a0

	move.w	d5,(a0)
	rts

.bp_plot
	move.w	planes-DATA(a3),d7	; d7 = number of planes

	move.w	xresb-DATA(a3),d4
	mulu	d4,d1
	add.l	d1,a0		; a0 = addr of horiz. line		

	move.w	d0,d4
	and.w	#$f,d0		; d0 = shift value

	move.w	d7,d2
	move.w	#%1000,d3
.bp16b	lsr.w	d3
	lsr.w	d2
	bne.s	.bp16b

	andi.w	#$fff0,d4
	lsr.w	d3,d4		; d4 = offset to 16-pix boundary
	
	add.w	d4,a0		; a0=addr of 16 pix boundary

	move.w	#$8000,d1
	lsr.w	d0,d1		; d1= or mask (set bit)
	move.w	d1,d0
	not.w	d0		; d0= and mask (clear bit)
 	
	move.w	#-1,d6
.bplp	addq.w	#1,d6
	cmp.w	d6,d7
	ble.s	.bpend
	move.w	(a0),d2	
	btst	d6,d5
	bne.s	.bpst
	and.w	d0,d2
	move.w	d2,(a0)+
	bra.s	.bplp
.bpend
	rts

.bpst	or.w	d1,d2
	move.w	d2,(a0)+
	bra.s	.bplp


* monitor
LIB6	dc.w	0
	move.w	#89,-(sp)		call XBIOS 89 (mon_type)
	trap	#14
	addq.l	#2,sp

	clr.l	d3
	move.w	d0,d3
	move.l	d3,-(a6)

	rts


* df video
LIB7	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d0
	move.l	(a6)+,d1
	move.l	(a6)+,d5
	move.l	(a6)+,d6
	move.l	(a6)+,d7
	move.l	(a6)+,a0
	move.l	(a6)+,a1
	move.l	(a6)+,d3

	lsl.l	#1,d3
	lea.l	videomodes-DATA(a3),a2
	add.l	d3,a2

	move.l	a0,d4
	move.l	a1,d3
	clr.l	d2
	tst	d3
	beq.s	.stcomp
	move.l	#%100000000,d2
.stcomp	tst.l	d4
	beq.s	.ovsn
	ori.w	#%10000000,d2
.ovsn	tst.l	d7
	beq.s	.pal
	ori.w	#%1000000,d2
.pal	tst.l	d6
	beq.s	.vga
	ori.w	#%100000,d2
.vga	tst.l	d5
	beq.s	.c80
	ori.w	#%10000,d2
.c80	tst.l	d1
	beq.s	.colr
	ori.w	#%1000,d2
.colr	cmpi.l	#65536,d0
	bne.s	.c256
	ori.w	#%100,d2
.c256	cmpi.l	#256,d0
	bne.s	.c16
	ori.w	#%11,d2
.c16	cmpi.l	#16,d0
	bne.s	.c4
	ori.w	#%10,d2
.c4	cmpi.l	#4,d0
	bne.s	.c2
	ori.w	#%1,d2
.c2
	move.w	d2,(a2)

	rts


* Quick fade
LIB8	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	clr.l	d3
	move.l	ink-DATA(a3),d3

	clr.l	d0
	move.l	d3,d1
	move.l	#$ffff9800,a0
	move.w	#256,d5
	
.fd256l	bsr	@fade256
	subq.w	#1,d5
	bgt.s	.fd256l

	clr.l	d2
	move.b	d0,d2
	move.l	d2,-(a6)

	rts

@fade256
.red
*	move.l	(a1)+,d1		Get target colour
	move.l	(a0),d2			Get colour to change
	cmp.l	d1,d2			Is colour the same?
	beq.s	.bye			 If so, don't bother- we've finished!

	move.l	d1,d3			{
	move.l	d2,d4			{ --- Isolate R bits
	andi.l	#$fc000000,d3		{
	andi.l	#$fc000000,d4		{
	cmp.l	d3,d4			Are the R bits the same?
	beq.s	.rok			 If so, try the G bits.
	bhi.s	.rsub			 If the target pixel has smaller amount of red-|
.radd	addi.l	#$4000000,d2    	Otherwise add an element of red.	       |
	bra.s	.rok								       |
.rsub	subi.l	#$4000000,d2	 	... take away an element of red. <------------|
.rok
.green	move.l	d1,d3			{
	move.l	d2,d4			{ --- Isolate G bits
	andi.l	#$fc0000,d3		{
	andi.l	#$fc0000,d4		{
	cmp.l	d3,d4			Are the G bits the same?
	beq.s	.gok			 If so, try the B bits.
	bhi.s	.gsub			 If the target has smaller amount of green-----|
.gadd	add.l	#$40000,d2	 	Otherwise add an element of green.	       |
	bra.s	.gok								       |
.gsub	subi.l	#$40000,d2	 	... take away an element of green. <----------|
.gok
.blue	move.l	d1,d3			{
	move.l	d2,d4			{ --- Isolate B bits
	andi.l	#$fc,d3			{
	andi.l	#$fc,d4			{
	cmp.l	d3,d4			Are the B bits the same?
	beq.s	.bok			 If so, finish.
	bhi.s	.bsub			 If the target has smaller amounts of blue-----|
.badd	addq.l	#4,d2			 Otherwise add an element of blue.	       |
	bra.s	.bok								       |
.bsub	subq.l	#4,d2			 ... take away an element of blue. <-----------|
.bok	move.l	d2,(a0)+		Put changed pixel on screen.
	addq.l	#1,d0
	rts
.bye	addq.l	#4,a0
	rts


* cycle
LIB9	dc.w	0
	move.l	(a6)+,d0
	move.l	(a6)+,d3

	cmpi	#2,d0
	blt	ntdne

	move.l	#$ffff9800,a0
	lsl.l	#2,d3
	add.l	d3,a0

	subq.l	#1,d0

	move.l	(a0)+,d1
	subq.l	#1,d0
	
cylp	move.l	(a0),-(a0)
	add.l	#8,a0
	dbra	d0,cylp

	move.l	d1,-(a0)
ntdne	rts


* OS version
LIB10	dc.w	0
	clr.l	d3
	move.l	$4f2,a0
	move.w	2(a0),d3
	move.l	d3,-(a6)
	rts


* TC sprite
LIB11	dc.w	0

	move.l	$92c(a5),a4
	move.l	0(a4,d1.w),a4

	move.l	(a6)+,a0
	move.l	(a6)+,a1
	move.l	(a6)+,d0
	move.l	(a6)+,d5
	move.l	(a6)+,d1

	move.l	d5,d2

	tst.b	alpha_flag-DATA(a4)
	bne	@truealpha

*
* This routine draws a true colour sprite. It draws both
* packed and unpacked sprites. Clipping is only supported for unpacked
* sprites against the top and the bottom of the screen.
* The sprite must be created using the Spooky Sprites sprite creator.
*
* Made by Johan Karlsson (d92jk@efd.lth.se)
*

@truespr        move.l  a0,a3
                add.l   #10,a0
                move    d0,d3
                asl     #3,d0
                add     d3,d0
                add     d3,d0
                add.l   d0,a0           a0.l=adr of current sprite location chunk

                tst     d2
                blt     .minusy
                tst     d1
                blt     .minusx
                moveq   #0,d3
                move.b  (a0),d3
                add     d1,d3
                cmp     xres-DATA(a4),d3
                bgt     .plusx
                moveq   #0,d3
                move.b  1(a0),d3
                add     d2,d3
                cmp     yres-DATA(a4),d3
                bgt     .plusy

.noclip
		move.w	xresb-DATA(a4),d3
                mulu    d3,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1

                move.l  6(a0),a2
                tst.l   a2
                beq     .unpacked


.packed         add.l   a3,a2
                move    (a2)+,d3
                moveq   #0,d4
.loop1          move    (a2)+,d4
                add.l   d4,a1
                move    (a2)+,d5
.loop2          move    (a2)+,(a1)+
                dbra    d5,.loop2
                dbra    d3,.loop1
                rts


.unpacked
                moveq   #0,d3
                move.b  1(a0),d3
.unp2           subq    #1,d3           d3 sprite height-1
                moveq   #0,d4
                move.b  (a0),d4
		moveq.l	#0,d7
                move.w  xresb-DATA(a4),d7
                sub     d4,d7
                sub     d4,d7           d7.l offset after each line
                sub     #1,d4           d4 sprite width-1
                move.l  2(a0),a2
                add.l   a3,a2           a2.l start of raw data
.loopen
                move    d4,d5
.loop           move    (a2)+,d6
                beq     .tran
		btst.b	#5,1(a1)
		bne.s	.col
                move    d6,(a1)+
                dbra    d5,.loop
                add.l   d7,a1
                dbra    d3,.loopen
                rts
.tran           addq.l  #2,a1
                dbra    d5,.loop
                add.l   d7,a1
                dbra    d3,.loopen
.exit           rts
.col		bset.b	#0,colflag-DATA(a4)
		move	d6,(a1)+
		dbra	d5,.loop
		add.l	d7,a1
		dbra	d3,.loopen
		rts


.minusy         move.l  6(a0),a2
                tst.l   a2              Is it unpacked?
                bne     .exit           No!
                moveq   #0,d3
                move.b  1(a0),d3        d3 sprite height
                add.l   d2,d3           d3 clipped sprite height
                ble     .exit           nothing visible!
                subq    #1,d3

                moveq   #0,d4
                move.b  (a0),d4
                move.l  d4,d5
		moveq.l	#0,d7
                move.w  xresb-DATA(a4),d7
                sub     d4,d7
                sub     d4,d7           d7.l offset after each line
                subq    #1,d4           d4 sprite width-1
                move.l  2(a0),a2
                add.l   a3,a2           a2.l start of raw data
                add.l   d5,d5
                neg     d2
                mulu    d2,d5
                add.l   d5,a2           a2.l start of clipped raw data
                add.l   d1,a1
                add.l   d1,a1           a1.l screen adr
                bra     .loopen

.plusy          move.l  6(a0),a2
                tst.l   a2              Is it unpacked?
                bne     .exit           No!

                sub     yres-DATA(a4),d3
                move.l  d3,d5
                moveq   #0,d3
                move.b  1(a0),d3        d3 sprite height
                sub.l   d5,d3           d3 clipped sprite height
                ble     .exit

		move.w	xresb-DATA(a4),d4
                mulu    d4,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1
                bra     .unp2

.minusx         rts
.plusx          rts



*
* This routine draws a true colour sprite with alpha channeling. It draws both
* packed and unpacked sprites. Clipping is only supported for unpacked
* sprites against the top and the bottom of the screen.
* The sprite must be created using the Spooky Sprites sprite creator.
*
* Made by Johan Karlsson (d92jk@efd.lth.se)
*

@truealpha      move.l  a0,a3
                add.l   #10,a0
                move    d0,d3
                asl     #3,d0
                add     d3,d0
                add     d3,d0
                add.l   d0,a0           a0.l=adr of current sprite location chunk

                tst     d2
                blt     .aminusy
                tst     d1
                blt     .aminusx
                moveq   #0,d3
                move.b  (a0),d3
                add     d1,d3
                cmp     xres-DATA(a4),d3
                bgt     .aplusx
                moveq   #0,d3
                move.b  1(a0),d3
                add     d2,d3
                cmp     yres-DATA(a4),d3
                bgt     .aplusy

.anoclip
		move.w	xresb-DATA(a4),d3
                mulu    d3,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1

                move.l  6(a0),a2
                tst.l   a2
                beq     .aunpacked


.apacked        add.l   a3,a2
                move    (a2)+,d3
                moveq   #0,d4
.aloop1         move    (a2)+,d4
                add.l   d4,a1
                move    (a2)+,d5
.aloop2         move    (a2)+,(a1)+
                dbra    d5,.aloop2
                dbra    d3,.aloop1
                rts


.aunpacked
                moveq   #0,d3
                move.b  1(a0),d3
.aunp2          subq    #1,d3           d3 sprite height-1
                moveq   #0,d4
                move.b  (a0),d4
		moveq.l	#0,d7
                move.w  xresb-DATA(a4),d7
                sub     d4,d7
                sub     d4,d7           d7.l offset after each line
                sub     #1,d4           d4 sprite width-1
                move.l  2(a0),a2
                add.l   a3,a2           a2.l start of raw data
.aloopen
                move    d4,d5
.aloop          move    (a2)+,d6
                beq     .atran
		btst.b	#5,1(a1)
		bne.s	.acol
		swap.w	d6
		move.w	(a1),d6
		and.w	alpha_nand-DATA(a4),d6
		move.w	d6,(a1)
		swap.w	d6
		and.w	alpha_and-DATA(a4),d6
                or.w    d6,(a1)+
                dbra    d5,.aloop
                add.l   d7,a1
                dbra    d3,.aloopen
                rts
.atran          addq.l  #2,a1
                dbra    d5,.aloop
                add.l   d7,a1
                dbra    d3,.aloopen
.aexit          rts
.acol		bset.b	#0,colflag-DATA(a4)
		swap.w	d6
		move.w	(a1),d6
		and.w	alpha_nand-DATA(a4),d6
		move.w	d6,(a1)
		swap.w	d6
		and.w	alpha_and-DATA(a4),d6
		or.w	d6,(a1)+
		dbra	d5,.aloop
		add.l	d7,a1
		dbra	d3,.aloopen
		rts


.aminusy        move.l  6(a0),a2
                tst.l   a2              Is it unpacked?
                bne     .aexit           No!
                moveq   #0,d3
                move.b  1(a0),d3        d3 sprite height
                add.l   d2,d3           d3 clipped sprite height
                ble     .aexit           nothing visible!
                subq    #1,d3

                moveq   #0,d4
                move.b  (a0),d4
                move.l  d4,d5
		moveq.l	#0,d7
                move.w  xresb-DATA(a4),d7
                sub     d4,d7
                sub     d4,d7           d7.l offset after each line
                subq    #1,d4           d4 sprite width-1
                move.l  2(a0),a2
                add.l   a3,a2           a2.l start of raw data
                add.l   d5,d5
                neg     d2
                mulu    d2,d5
                add.l   d5,a2           a2.l start of clipped raw data
                add.l   d1,a1
                add.l   d1,a1           a1.l screen adr
                bra     .aloopen

.aplusy         move.l  6(a0),a2
                tst.l   a2              Is it unpacked?
                bne     .aexit           No!

                sub     yres-DATA(a4),d3
                move.l  d3,d5
                moveq   #0,d3
                move.b  1(a0),d3        d3 sprite height
                sub.l   d5,d3           d3 clipped sprite height
                ble     .aexit

		move.w	xresb-DATA(a4),d4
                mulu    d4,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1
                bra     .aunp2

.aminusx        rts
.aplusx         rts



* TC point
LIB12	dc.w	0
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,a0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	lsl.l	#1,d6
	add.l	d6,a0

	move.w	xresb-DATA(a3),d6
	mulu	d6,d7
	add.l	d7,a0

	clr.l	d3
	move.w	(a0),d3
	move.l	d3,-(a6)

	rts

* Falc cls
LIB13	dc.w	0
*	movem.l	d4-d7/a0-a2,-(sp)
	move.l	(a6)+,a0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.w	xresb-DATA(a3),d0
	lsr.w	#2,d0
	mulu.w	yres-DATA(a3),d0

	moveq	#0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,d6
	move.l	d2,d7
	move.l	d2,a1
	move.l	d2,a2
	moveq	#127,d1
	and.l	d0,d1
	bra.s	.strt
.long	move.l	d2,(a0)+
.strt	dbra	d1,.long
	lsr.l	#7,d0
	move.l	d0,d1
	lsl.l	#8,d1		; *256
	lsl.l	#1,d1		; *2	=  *512
	add.l	d1,a0
	bra.s	.next
.clr	movem.l	d2-d7/a1-a2,-(a0)		; 4*8*16 = 512
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
	movem.l	d2-d7/a1-a2,-(a0)
.next	dbra	d0,.clr
*	movem.l	(sp)+,d4-d7/a0-a2
	rts


* TC fade
LIB14	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	move.l	(a6)+,d5
	move.l	ink-DATA(a3),d1

	moveq.l	#0,d6
.fdlp	move	(a0),d2			Get pixel to change
	cmp	d1,d2			Is pixel colour the same?
	beq.s	.bye			 If so, don't bother- we've finished!

	move	d1,d3			{
	move	d2,d4			{ --- Isolate R bits
	andi	#%1111100000000000,d3	{
	andi	#%1111100000000000,d4	{
	cmp	d3,d4			Are the R bits the same?
	beq.s	.rok			 If so, try the G bits.
	bhi.s	.rsub			 If the target pixel has smaller amount of red-|
.radd	addi	#%0000100000000000,d2    Otherwise add an element of red.	       |
	bra.s	.rok								       |
.rsub	subi	#%0000100000000000,d2	 ... take away an element of red. <------------|
.rok
.green	move	d1,d3			{
	move	d2,d4			{ --- Isolate G bits
	andi	#%11111000000,d3	{
	andi	#%11111000000,d4	{
	cmp	d3,d4			Are the G bits the same?
	beq.s	.gok			 If so, try the B bits.
	bhi.s	.gsub			 If the target has smaller amount of green-----|
.gadd	add	#%00001000000,d2	 Otherwise add an element of green.	       |
	bra.s	.gok								       |
.gsub	subi	#%00001000000,d2	 ... take away an element of green. <----------|
.gok
.blue	move	d1,d3			{
	move	d2,d4			{ --- Isolate B bits
	andi	#%11111,d3		{
	andi	#%11111,d4		{
	cmp	d3,d4			Are the B bits the same?
	beq.s	.bok			 If so, finish.
	bhi.s	.bsub			 If the target has smaller amounts of blue-----|
.badd	addq.l	#1,d2			 Otherwise add an element of blue.	       |
	bra.s	.bok								       |
.bsub	subq.l	#1,d2			 ... take away an element of blue. <-----------|
.bok	move	d1,d3			{
	andi	#%100000,d3		{ Isolate the X bit
	tst	d3
	beq.s	.xcl
	ori	#%100000,d2		If target X set, then set pixels X bit
	beq.s	.xok
.xcl	andi	#%1111111111011111,d2	else clear it.
.xok	move	d2,(a0)+		Put changed pixel on screen.
	addq.l	#1,d6
	bra.s	.byeaj
.bye	addq.l	#2,a0
.byeaj
	subq.l	#2,d5
	bgt.s	.fdlp

	move.l	d6,-(a6)
	rts



* Set FV
LIB15	dc.w	0
	move.l	(a6)+,a0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	bsr	@setfv

*	tst	d0
*	bne	ntdne


	move.w	$ff8260,d0
	andi.b	#$3,d0
	beq.s	.fv4
	cmpi.b	#1,d0
	bne.s	.fv2

.fv8	move.w	#8,d0
	bra.s	.fvwid
.fv1	move.w	#1,d0
	bra.s	.fvwid
.fv2	move.w	#2,d0
	bra.s	.fvwid
.fv4	move.w	#4,d0
	bra.s	.fvwid
.fv16	move.w	#16,d0

.fvwid	move.w	d0,planes-DATA(a3)

	moveq.l	#0,d0
	movec	CACR,d1
	movec	d0,CACR
.zero	move.w	$ff8210,d0	; d0=number of words in a line
	tst.w	d0
	beq.s	.zero
	movec	d1,CACR

	move.w	d0,d1
	lsl.w	#1,d1
	move.w	d1,xresb-DATA(a3)
	move.w	planes-DATA(a3),d0
	divu	d0,d1
	lsl.l	#3,d1
	move.w	d1,xres-DATA(a3)

	move.w	$ff82aa,d0
	sub.w	$ff82a8,d0
	lsr.w	#1,d0

	move.w	$ff82c2,d1
	move.w	d1,d2
	andi.b	#%10,d2
	tst.b	d2
	beq.s	.tdl
	lsl.w	#1,d0
.tdl	andi.b	#%1,d1
	tst.b	d1
	beq.s	.styrs
	lsr.w	#1,d0

.styrs	move.w	d0,yres-DATA(a3)

	lea	planes-DATA(a3),a1	*** Tell everyone the new resolution
	move.l	#'FALC',d2
	move.l	#1,d0
	trap	#5

	rts


@setfv	cmp.l	#'FVD2',(a0)+	4 bytes header
	bne	.error

.ready	addq.l	#2,a0
*	move.l	$70,-(sp)
*	move	sr,-(sp)
*	move.l	#.vbl,$70
*	move	#$2300,sr
*		
*	move.l	$466,d0
*.wait	cmp.l	$466,d0
*	beq	.wait
		
	move.l	(a0)+,$ff820e	offset & vwrap
	move.w	(a0)+,$ff8266	spshift
	move.l	#$ff8282,a1	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a1
	bne	.loop1
	move.l	#$ff82a2,a1	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a1
	bne	.loop2
	move	(a0)+,$ff82c2	video control
	move	(a0)+,$ff82c0	video clock
	addq.l	#1,a0
	move.b	(a0)+,$ff820a	video sync mode
*	move	(sp)+,sr
*	move.l	(sp)+,$70
	moveq	#0,d0
	rts
.error	moveq	#-1,d0
	rts
.wrongmon	moveq	#-2,d0
		rts
.sm124	cmp.b	#0,(a0)
	bne	.wrongmon
	bra	.ready
.vga	cmp.b	#2,(a0)
	bne	.wrongmon
	bra	.ready
.vbl	addq.l	#1,$466
	rte



* scrn size
LIB16	dc.w	0
	move.l	(a6)+,d3

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	lsl.l	#1,d3
	lea.l	videomodes-DATA(a3),a0
	add.l	d3,a0
	move.w	(a0),d3

	move.w	d3,-(sp)
	move.w	#91,-(sp)
	trap	#14
	addq.l	#4,sp

	move.l	d0,-(a6)
	rts


* get_fpal
LIB17	dc.w	0
	move.l	(a6)+,d6
	move.l	(a6)+,d5

	move.l	(a6)+,-(sp)
	move.w	d6,-(sp)
	move.w	d5,-(sp)
	move.w	#94,-(sp)
	trap	#14
	add.l	#10,sp

	rts


* TC scrn fade
LIB18	dc.w	0

	move.l	(a6)+,d5
	move.l	(a6)+,a1
	move.l	(a6)+,a0

	moveq.l	#0,d6
.sfdlp	moveq.l	#0,d1
	move.w	(a1)+,d1
	move	(a0),d2			Get pixel to change
	cmp	d1,d2			Is pixel colour the same?
	beq.s	.bye			 If so, don't bother- we've finished!

	move	d1,d3			{
	move	d2,d4			{ --- Isolate R bits
	andi	#%1111100000000000,d3	{
	andi	#%1111100000000000,d4	{
	cmp	d3,d4			Are the R bits the same?
	beq.s	.rok			 If so, try the G bits.
	bhi.s	.rsub			 If the target pixel has smaller amount of red-|
.radd	addi	#%0000100000000000,d2    Otherwise add an element of red.	       |
	bra.s	.rok								       |
.rsub	subi	#%0000100000000000,d2	 ... take away an element of red. <------------|
.rok
.green	move	d1,d3			{
	move	d2,d4			{ --- Isolate G bits
	andi	#%11111000000,d3	{
	andi	#%11111000000,d4	{
	cmp	d3,d4			Are the G bits the same?
	beq.s	.gok			 If so, try the B bits.
	bhi.s	.gsub			 If the target has smaller amount of green-----|
.gadd	add	#%00001000000,d2	 Otherwise add an element of green.	       |
	bra.s	.gok								       |
.gsub	subi	#%00001000000,d2	 ... take away an element of green. <----------|
.gok
.blue	move	d1,d3			{
	move	d2,d4			{ --- Isolate B bits
	andi	#%11111,d3		{
	andi	#%11111,d4		{
	cmp	d3,d4			Are the B bits the same?
	beq.s	.bok			 If so, finish.
	bhi.s	.bsub			 If the target has smaller amounts of blue-----|
.badd	addq.l	#1,d2			 Otherwise add an element of blue.	       |
	bra.s	.bok								       |
.bsub	subq.l	#1,d2			 ... take away an element of blue. <-----------|
.bok	move	d1,d3			{
	andi	#%100000,d3		{ Isolate the X bit
	tst	d3
	beq.s	.xcl
	ori	#%100000,d2		If target X set, then set pixels X bit
	beq.s	.xok
.xcl	andi	#%1111111111011111,d2	else clear it.
.xok	move	d2,(a0)+		Put changed pixel on screen.
	addq.l	#1,d6
	bra.s	.byeaj
.bye	addq.l	#2,a0
.byeaj
	subq.l	#2,d5
	bgt.s	.sfdlp

	move.l	d6,-(a6)
	rts


* init virtual
LIB19	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d0
	move.w	d0,yres-DATA(a3)

	move.l	(a6)+,d3
	move.w	d3,xres-DATA(a3)
	move.w	d3,d2

	lsl.w	d2
	move.w	d2,xresb-DATA(a3)

	move.w	$ff8210,d0

	sub.w	d0,d3
	move.w	d3,$ff820e

	clr.b	$ff8265

	lea	planes-DATA(a3),a1	*** Tell everyone the new resolution
	move.l	#'FALC',d2
	move.l	#1,d0
	trap	#5

	rts


* xmouse
LIB20	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	clr.l	d3
	move.w	mouse_x-DATA(a3),d3

	move.l	d3,-(a6)
	rts

* virtual
LIB21	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	move.l	(a6)+,d0
	blt	.ntdne

	move.l	(a6)+,d3
	blt	.ntdne
	
	lsl.l	d3
	add.l	d3,a0

	mulu	xresb-DATA(a3),d0
	add.l	d0,a0

	move.l	a0,d0
	move.l	d0,d1
	lsr.l	#8,d0
	move.b	d0,$ff8203	middle byte
	lsr.l	#8,d0
	move.b	d0,$ff8201	high byte
	move.b	d1,$ff820d	low byte

.ntdne	rts


* ymouse
LIB22	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	clr.l	d3
	move.w	mouse_y-DATA(a3),d3

	move.l	d3,-(a6)
	rts


* TC bar
LIB23	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,d5
	move.l	(a6)+,d3

	cmpi.w	#16,planes-DATA(a3)
	bne.s	.bpbar

	lsl.l	#1,d6
	sub.l	d5,d7
	lea	xresb-DATA(a3),a2
	mulu	(a2),d5
	add.l	d5,a0

	lsl.l	#1,d3
	move.l	d3,d5
	sub.l	d5,d6

	move.l	ink-DATA(a3),d3

	clr.l	d0
	move.w	(a2),d0

	subq.l	#1,d7
.ylp	move.l	a0,a1		;copy address of screen+ycoord       <--\
	add.l	d5,a1		;add x (a1=address of 1st point on line)|
	move.l	d6,d4		;save x count                           |
.xlp	move.w	d3,(a1)+	;place pixel           <-\              |
	subq.l	#2,d4		;decrement x count       |              |
	bne.s	.xlp		;loop if not finished x -/              |
	add.l	d0,a0		;add 1 line to start coord              |
	subq.l	#1,d7		;decrement y count                      |
	bne.s	.ylp		;loop if not finished y             ----/
	rts

.bpbar	move.l	d3,d0
	move.l	d5,d1
	move.l	d6,d2
	move.l	d7,d3
	move.l	d0,d4		; store x for later
	move.w	planes-DATA(a3),d7
	move.l	ink-DATA(a3),d5
.bpbxlp	movem.l	d0-d4/d6/a0,-(sp)
	bsr	.bp_plt
	movem.l	(sp)+,d0-d4/d6/a0
	addq.l	#1,d0
	cmp.l	d2,d0
	ble.s	.bpbxlp
.bpsdlp	addq.l	#1,d1
	move.l	d4,d0
	cmp	d3,d1
	ble.s	.bpbxlp
	rts

.bp_plt
	move.w	xresb-DATA(a3),d4
	mulu	d4,d1
	add.l	d1,a0		; a0 = addr of horiz. line		

	move.w	d0,d4
	and.w	#$f,d0		; d0 = shift value

	move.w	d7,d2
	move.w	#%1000,d3
.bp16b	lsr.w	d3
	lsr.w	d2
	bne.s	.bp16b

	andi.w	#$fff0,d4
	lsr.w	d3,d4		; d4 = offset to 16-pix boundary
	
	add.w	d4,a0		; a0=addr of 16 pix boundary

	move.w	#$8000,d1
	lsr.w	d0,d1		; d1= or mask (set bit)
	move.w	d1,d0
	not.w	d0		; d0= and mask (clear bit)
 	
	move.w	#-1,d6
.bplp	addq.w	#1,d6
	cmp.w	d6,d7
	ble.s	.bpend
	move.w	(a0),d2	
	btst	d6,d5
	bne.s	.bpst
	and.w	d0,d2
	move.w	d2,(a0)+
	bra.s	.bplp
.bpend	rts

.bpst	or.w	d1,d2
	move.w	d2,(a0)+
	bra.s	.bplp



* falc mkey
LIB24	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	clr.l	d3
	move.w	mbut-DATA(a3),d3

	move.l	d3,-(a6)

	rts

* TC box
LIB25	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,d5
	move.l	(a6)+,d3

	cmpi.w	#16,planes-DATA(a3)
	bne.s	.bpbox

	lsl.l	#1,d6

	sub.l	d5,d7
	move.w	xresb-DATA(a3),d2
	mulu	d2,d5
	add.l	d5,a0

	lsl.l	#1,d3
	move.l	d3,d5
	sub.l	d5,d6

	move.l	ink-DATA(a3),d3

	clr.l	d0
	move.w	xresb-DATA(a3),d0

	subq.l	#1,d7
				;top line of box
	move.l	a0,a1		;copy address of screen+ycoord       
	add.l	d5,a1		;add x (a1=address of 1st point on line)
	move.l	d6,d4		;save x count                           
.txlp	move.w	d3,(a1)+	;place pixel           <-\              
	subq.l	#2,d4		;decrement x count       |              
	bge.s	.txlp		;loop if not finished x -/              
	add.l	d0,a0		;add 1 line to start coord              
	subq.l	#1,d7		;decrement y count                  
.ylpbx	move.l	a0,a1
	add.l	d5,a1
	move.w	d3,(a1)
	add.l	d6,a1
	move.w	d3,(a1)
	add.l	d0,a0
	subq.l	#1,d7
	bpl.s	.ylpbx		;loop if not finished y             
	move.l	a0,a1
	add.l	d5,a1
	move.l	d6,d4
.bxlp	move.w	d3,(a1)+	;place pixel           <-\              
	subq.l	#2,d4		;decrement x count       |              
	bge.s	.bxlp		;loop if not finished x -/              
	rts

.bpbox	move.l	d3,d0
	move.l	d5,d1
	move.l	d6,d2
	move.l	d7,d3
	move.l	d0,d4		; store x for later
	move.w	planes-DATA(a3),d7
	move.l	ink-DATA(a3),d5
.bpbxlp	movem.l	d0-d4/d6/a0,-(sp)
	bsr	.bp_plt
	movem.l	(sp)+,d0-d4/d6/a0
	addq.l	#1,d0
	cmp.l	d2,d0
	ble.s	.bpbxlp
.bpsdlp	addq.l	#1,d1
	move.l	d4,d0
	movem.l	d0-d4/d6/a0,-(sp)
	bsr	.bp_plt
	movem.l	(sp)+,d0-d4/d6/a0
	move.l	d6,d0
	movem.l	d0-d4/d6/a0,-(sp)
	bsr	.bp_plt
	movem.l	(sp)+,d0-d4/d6/a0
	cmp.l	d3,d1
	blt.s	.bpsdlp
	move.l	d4,d0
.bbx	movem.l	d0-d4/d6/a0,-(sp)
	bsr	.bp_plt
	movem.l	(sp)+,d0-d4/d6/a0
	addq.l	#1,d0
	cmp.l	d2,d0
	ble.s	.bbx
	rts

* a0=screen addr. d0=x, d1=y, d5=colour, d7=number of planes
* corrupts all d-regs (except d5 and d7) and a0

.bp_plt
	move.w	xresb-DATA(a3),d4
	mulu	d4,d1
	add.l	d1,a0		; a0 = addr of horiz. line		

	move.w	d0,d4
	and.w	#$f,d0		; d0 = shift value

	move.w	d7,d2
	move.w	#%1000,d3
.bp16b	lsr.w	d3
	lsr.w	d2
	bne.s	.bp16b

	andi.w	#$fff0,d4
	lsr.w	d3,d4		; d4 = offset to 16-pix boundary
	
	add.w	d4,a0		; a0=addr of 16 pix boundary

	move.w	#$8000,d1
	lsr.w	d0,d1		; d1= or mask (set bit)
	move.w	d1,d0
	not.w	d0		; d0= and mask (clear bit)
 	
	move.w	#-1,d6
.bplp	addq.w	#1,d6
	cmp.w	d6,d7
	ble.s	.bpend
	move.w	(a0),d2	
	btst	d6,d5
	bne.s	.bpst
	and.w	d0,d2
	move.w	d2,(a0)+
	bra.s	.bplp
.bpend	rts

.bpst	or.w	d1,d2
	move.w	d2,(a0)+
	bra.s	.bplp

* Falc zone
LIB26	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3
	cmpi	#128,d3
	bge	notinzone

	lsl.l	#3,d3
	lea.l	zones-DATA(a3),a0

	move.w	0(a0,d3),d0
	move.w	2(a0,d3),d1
	move.w	4(a0,d3),d2
	move.w	6(a0,d3),d4

	move.l	#0,d3

	cmp	mouse_x-DATA(a3),d0
	bgt	notinzone
	cmp	mouse_x-DATA(a3),d2
	blt	notinzone

	cmp	mouse_y-DATA(a3),d1
	bgt	notinzone
	cmp	mouse_y-DATA(a3),d4
	blt	notinzone

	move.l	#-1,d3

notinzone
	move.l	d3,-(a6)
	rts

* tc_copy
LIB27	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d6	; get y2
	move.l	(a6)+,d5	; get x2

	move.l	(a6)+,d3	; get scr2
	lsl.l	d5		; calculate dest. address
	add.l	d5,d3
	mulu	xresb-DATA(a3),d6
	add.l	d6,d3
	move.l	d3,a2		; set destination address

	move.l	(a6)+,d7	; get h
	move.l	(a6)+,d3	; get w
	move.w	d3,d6
	lsl.l	d3
	moveq.l	#0,d0
	move.w	xresb-DATA(A3),d0
	sub.l	d3,d0		d0= line increment

	move.l	(a6)+,d3	; get y
	mulu	xresb-DATA(a3),d3
	move.l	d3,a0

	move.l	(a6)+,d3	; get x
	lsl.l	d3
	adda.l	d3,a0

	move.l	(a6)+,d3	; get source
	adda.l	d3,a0

*a0=source+x*2+y2*xresb, a2=dest+x2+y2*xresb
*d6=width, d7=height
*d0=line inc

.ylp	move.w	d6,d4		;save x count                       <---\
.xlp	move.w	(a0)+,d3	;                      <-\              |
	move.w	d3,(a2)+	;place pixel             |              |
	subq	#1,d4		
	bgt	.xlp		;loop if not finished x -/              |
	adda.l	d0,a0		;add 1 line to source address           |
	adda.l	d0,a2		;add 1 line to destination address      |
	subq	#1,d7
	bgt	.ylp		;loop if not finished y             ----/
	rts

* cache
LIB28	dc.w	0
	moveq.l	#0,d3
	movec	CACR,d3
	move.l	d3,-(a6)
	rts

* set_fpal
LIB29	dc.w	0
	move.l	(a6)+,d6
	move.l	(a6)+,d5
	
	move.l	(a6)+,-(sp)
	move.w	d6,-(sp)
	move.w	d5,-(sp)
	move.w	#93,-(sp)
	trap	#14
	add.l	#10,sp

	rts

* xres
LIB30	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	moveq.l	#0,d3
	move.w	xres-DATA(a3),d3
	move.l	d3,-(a6)

	rts

* goraud
LIB31	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	lea	new_crds(pc),a0

	move.l	(a6)+,d3
	move.w	d3,16(a0)
	move.l	(a6)+,d3
	move.w	d3,14(a0)
	move.l	(a6)+,d3
	move.w	d3,12(a0)
	move.l	(a6)+,d3
	move.w	d3,10(a0)
	move.l	(a6)+,d3
	move.w	d3,8(a0)
	move.l	(a6)+,d3
	move.w	d3,6(a0)
	move.l	(a6)+,d3
	move.w	d3,4(a0)
	move.l	(a6)+,d3
	move.w	d3,2(a0)
	move.l	(a6)+,d3
	move.w	d3,(a0)
	move.l	d3,d1
	move.l	d3,a1

	cmpi.l	#0,d1
	bne.s	.ggrn
	lea.l	g_lightred(pc),a2
	bra.s	.pts
.ggrn	cmpi.l	#1,d1
	bne.s	.gwht
	lea.l	g_green(pc),a2
	bra.s	.pts
.gwht	cmpi.l	#2,d1
	bne.s	.gbrn
	lea.l	g_white(pc),a2
	bra.s	.pts
.gbrn	cmpi.l	#3,d1
	bne.s	.gadr
	lea.l	g_brown(pc),a2
	bra.s	.pts
.gadr	move.l	d1,a2
.pts
	move.w	#3,d6

	movem.l	a0-a6,-(sp)
	bsr	@goraud
	movem.l	(sp)+,a0-a6

	rts

new_crds	ds.w	9

@goraud
		lea	offsets(pc),a0
		lea	workscr2354(pc),a4
		move.l	a1,(a4)
		lea	colouradr2354(pc),a4
		move.l	a2,(a4)
		bsr	GDraw_Poly
		rts

		
colouradr2354	ds.l	1
offsets		dc.w	0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,100


;-----------------------------------------------------------------------;
;                 Gouraud Shaded Polygon Routine.			;
; A0 -> D6 coords (offsets into 'new_crds' in form X,Y,INTENSITY CONST) ;
;-----------------------------------------------------------------------;

GDraw_Poly	LEA trans_crds(pc),A1 
		LEA new_crds(pc),A6
		MOVE D6,D0
		ADD D6,D6
		ADD D0,D6
		ADD D6,D6		6*d6
		MOVE.L A1,A5
		ADDA.W D6,A5
		MOVE.L A5,A2
		ADDA.W D6,A2
Init_coords	SUBQ #2,D0
		MOVE.W (A0)+,D7
		MOVE.W 4(A6,D7),D5
		MOVE.L (A6,D7),D7
		MOVE D7,D2
		MOVE.L A5,A4
		MOVE.L D7,(A1)+		; dup first coord
		MOVE.W D5,(A1)+
		MOVE.L D7,(A2)+
		MOVE.W D5,(A2)+
		MOVE.L D7,(A5)+
		MOVE.W D5,(A5)+
.coord_lp	MOVE.W (A0)+,D3
		MOVE.W 4(A6,D3),D5
		MOVE.L (A6,D3),D3
		CMP D2,D3
		BGE.S .not_top
		MOVE D3,D2
		MOVE.L A5,A4
.not_top	CMP D3,D7
		BGE.S .not_bot
		MOVE D3,D7	
.not_bot	MOVE.L D3,(A1)+		; dup for rest
		MOVE.W D5,(A1)+
		MOVE.L D3,(A2)+
		MOVE.W D5,(A2)+
		MOVE.L D3,(A5)+
		MOVE.W D5,(A5)+
		DBF D0,.coord_lp
		MOVE.L A0,USP
		MOVE.L A4,A5
		SUB D2,D7		;d2 - lowest y  d7 - greatest y
		BEQ polydone
		MOVE D2,-(SP)
		MOVE D7,-(SP)

CALCS		LEA grad_table-DATA(a3),a0
		adda.l	#640,a0
; Calc x's down left side of poly
Do_left		LEA LEFTJMP(PC),A2
		LEA x1s(PC),A3
Left_lp 	SUBQ #6,A4
		MOVEM.W (A4),D1-D2		;x1,y1
		MOVEM.W 4(A4),D0/D3-D5		;I2,x2,y2,I1
		SUB D4,D2			;dy
		SUB D3,D1			;dx
		SUB D2,D7			;remaining lines-dy
		SUB D5,D0			;DI
		EXT.L D0
		DIVS D2,D0	
		ADD.W D2,D2		
		MULS (A0,D2),D1
		ADD.L D1,D1
		MOVE.W D1,D4			; frac part
		SWAP D1				; whole part
		MOVE.W D2,D6
		ADD D2,D2
		ADD D2,D2
		ADD D6,D2			; *10
		NEG D2
		CLR.W D6
		JMP (A2,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADD.W D4,D6
		ADDX.W D1,D3
		MOVE.W D5,(A3)+
		ADD.W D0,D5
		ENDR
LEFTJMP		TST D7
		BGT Left_lp

; Calc x's down right side of poly

Do_right	MOVE.W (SP),D7
		LEA RIGHTJMP(PC),A2
		LEA x2s(PC),A3
Right_lp	MOVEM.W (A5)+,D1-D2/D5		;x1,y1,I2
		MOVEM.W (A5),D3-D4/D6		;x2,y2,I1
		SUB D2,D4			;dy
		SUB D1,D3			;dx
		SUB D4,D7			;remaining lines-dy
		SUB D5,D6			;DI
		EXT.L D6
		DIVS D4,D6	
		ADD.W D4,D4			
		MULS (A0,D4),D3
		ADD.L D3,D3
		MOVE.W D3,D2			; frac part	
		SWAP D3				; whole part
		MOVE.W D4,D0
		ADD D4,D4
		ADD D4,D4
		ADD D0,D4			; *10
		NEG D4
		CLR.W D0
		JMP (A2,D4)
		REPT 200
		MOVE.W D1,(A3)+
		ADD.W D2,D0
		ADDX.W D3,D1
		MOVE.W D5,(A3)+
		ADD.W D6,D5
		ENDR
RIGHTJMP	TST D7
		BGT Right_lp

; Now draw on screen

.gofordraw 	MOVE (SP)+,D7		; DY
		MOVE (SP)+,D0		; MIN Y
		SUBQ #1,D7
		lea.l	colouradr2354(pc),a5
		move.l	(a5),a5
		MOVE.L workscr2354(PC),A6
		
		MULU xresb-DATA(a3),D0 		; MODIFIED
		ADDA.L D0,A6 
		LEA x1s(PC),A1
		LEA x2s(PC),A2
		MOVEQ #16-6,D3
		MOVE.W xresb-DATA(a3),D4		; MODIFIED
		MOVEQ #0,D5
Gdraw_lp    	MOVE.W (A1)+,D0		; x1
		MOVE.W (A2)+,D6		; x2
		MOVE.W (A1)+,D1	 	; Intensity 1
		MOVE.W (A2)+,D2		; Intensity 2
		EXT.L D1
		EXT.L D2
		LEA (A6,D0.W*2),A0
		SUB.W D0,D6 
		BLE DS2 
		SUB.L D1,D2 		
		EXT.L D6
		SWAP D2
		DIVS.L D6,D2
		ASR.L D3,d2
		ASL.L #6,D1
		SWAP D1
		SWAP D2
		MOVEQ #31,D0
		AND.W D6,D0
		LSR.W #5,D6
		MOVE D5,CCR
		lea	jmptab(pc),a5
		JMP ([a5,D0.W*4])
Glp		
		REPT 32
		MOVE.W (A5,D1*2),(A0)+
		ADDX.L D2,D1
		ENDR
g_jmp		DBF D6,Glp
DS2      	ADD.W D4,A6
		DBF D7,Gdraw_lp

polydone	RTS 


i		SET 0
jmptab		
		REPT 32
		DC.L g_jmp+i
i		SET i-6
		ENDR 
		DS.W 16

x1s		DS.L 201
x2s		DS.L 201

trans_crds    	DS.W 200

workscr2354	ds.l	1


g_lightred
i		set	0
		rept	32
		dc.w	(31*32*64)+(i*64)+(i)
i		set	i+1
		endr
		ds.w	16

g_green
i		set	0
		rept	32
		dc.w	(1*32*64)+(i*64)+(1)
i		set	i+1
		endr
		ds.w	16

g_white
i		set	0
		rept	32
		dc.w	(i*32*64)+(i*64)+(i)
i		set	i+1
		endr
		ds.w	16

g_brown
i		set	0
		rept	32
		dc.w	(i*32*64)+((i/2)*64)+(2)
i		set	i+1
		endr
		ds.w	16


* yres
LIB32	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	moveq.l	#0,d3
	move.w	yres-DATA(a3),d3
	move.l	d3,-(a6)
	rts

* falc mouse on
LIB33	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	movem.l	a0-a6,-(sp)

	lea.l	mouse_x-DATA(a3),a0
	lea.l	mousaddr(pc),a1
	move.l	a0,(a1)

	move.w	#20,mouse_x-DATA(a3)
	move.w	#40,mouse_y-DATA(a3)
	clr.w	mbut-DATA(a3)

	lea.l	pblk(pc),a0
	adda.l	#4,a0
	move.w	xres-DATA(a3),(a0)+
	move.w	yres-DATA(a3),(a0)+

	move.w	#$22,-(sp)		;Kbdvbase()
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0

	move.l	16(a0),old_mousevec-DATA(a3)
	lea	old_mousvec(pc),a1
	move.l	old_mousevec-DATA(a3),(a1)
wait_drvstat
	tst.w	36(a0)
	bne	wait_drvstat

*	lea	mousevec(pc),a1
*	move.l	a1,16(a0)

*	lea.l	mousaddr(pc),a0
*	lea.l	mouse_x-DATA(a3),a1
*	move.l	a1,(a0)

	lea.l	mousevec(pc),a1
	move.l	a1,-(sp)
	lea.l	pblk(pc),a1
	move.l	a1,-(sp)
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	trap	#14
	lea	12(sp),sp	


;	move.l	$70,old_vbl_int-DATA(a3)	;install for sprite update
;	move.l	#vbl_interrupt-DATA(a3),$70

	movem.l	(sp)+,a0-a6
	rts

pblk	dc.b	0,0,1,1
	dc.w	320,200,10,10

mousaddr	ds.l	1
		dc.l	'XBRA'
		dc.l	'MOUS'
old_mousvec:	ds.l	1

mousevec:
		movem.l	d0-d2/a3,-(sp)
		lea.l	mousaddr(pc),a3
		move.l	(a3),a3
		move.w	-8(a3),d1
		move.w	-6(a3),d2

		move.b	1(a0),d0
		ext.w	d0
		add.w	(a3),d0
		bge	cont_mv1
		clr.w	d0
cont_mv1:	cmp.w	d1,d0
		blt	cont_mv2
		move.w	d1,d0
		subq.w	#1,d0
cont_mv2:	move.w	d0,(a3)
		move.b	2(a0),d0
		ext.w	d0
		add.w	2(a3),d0
		bge	cont_mv3
		clr.w	d0
cont_mv3:	cmp.w	d2,d0
		blt	cont_mv4
		move.w	d2,d0
		subq.w	#1,d0
cont_mv4:	move.w	d0,2(a3)
		move.b	(a0),d0
		and.w	#3,d0
		move.w	d0,4(a3)
		movem.l	(sp)+,d0-d2/a3
		rts

* dummy
LIB34	dc.w	0
	rts

* falc mouse off
LIB35	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.w	#$22,-(sp)		;Kbdvbase()
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0

wait_drvstat2:
	tst.w	36(a0)
	bne	wait_drvstat2

	move.l	old_mousevec-DATA(a3),16(a0)
	rts

* planes
LIB36	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	moveq.l	#0,d3
	move.w	planes-DATA(a3),d3
	move.l	d3,-(a6)
	rts


* falc set zone
LIB37	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d6
	move.l	(a6)+,d5
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	move.l	(a6)+,d3	

	lsl.l	#3,d3
	lea.l	zones-DATA(a3),a0

	move.w	d0,0(a0,d3)
	move.w	d1,2(a0,d3)
	move.w	d5,4(a0,d3)
	move.w	d6,6(a0,d3)

	rts


* tga width
LIB38	dc.w	0
	move.l	(a6)+,a0

	move.w	12(a0),d3
	move.w	d3,d2
	andi.l	#$ff00,d3
	andi.l	#$ff,d2
	lsl.l	#8,d2
	lsr.l	#8,d3
	or.w	d2,d3
	move.l	d3,-(a6)
	rts


* falc set mouse
LIB39	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3
	move.w	d3,mouse_y-DATA(a3)

	move.l	(a6)+,d3
	move.w	d3,mouse_x-DATA(a3)

	rts


* tga height
LIB40	dc.w	0
	move.l	(a6)+,a0

	move.w	14(a0),d3
	move.w	d3,d2
	andi.l	#$ff00,d3
	andi.w	#$ff,d2
	lsl.l	#8,d2
	lsr.l	#8,d3
	or.w	d2,d3
	move.l	d3,-(a6)
	rts


* falc ink
LIB41	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3
	cmpi.b	#1,d0
	bne.s	.rgbink

	move.l	(a6)+,d3	
	move.l	d3,ink-DATA(a3)
	move.w	d3,txtcol-DATA(a3)
	rts

.rgbink	move.l	(a6)+,d0
	move.l	(a6)+,d1
	move.l	(a6)+,d3

	andi.l	#$3e,d3
	andi.l	#$3f,d1
	andi.l	#$3e,d0
	lsr.l	d0
	lsl.l	#5,d1
	lsl.l	#5,d3
	lsl.l	#5,d3

	or.l	d3,d0
	or.l	d1,d0

	move.l	d0,ink-DATA(a3)
	move.w	d0,txtcol-DATA(a3)
	rts

* tc collide
LIB42	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	moveq.l	#0,d3
	move.b	colflag-DATA(a3),d3
	move.l	d3,-(a6)
	rts

* st compat
LIB43	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d5		; store for later
	move.w	d5,d3

	cmpi.w	#2,d3
	bne.s	.lowmed

	move.l	$4f2,a0		; get OS version
	move.w	2(a0),d1
	cmpi.w	#$400,d1
	bge.s	.lowmed

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	cmpi.b	#2,d0
	beq.s	.dne
	bra	ntdne		; real ST in high...

.lowmed	move.w	d3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	moveq.l	#10,d7
	trap	#3

	moveq.l	#0,d7
	trap	#5

.dne	cmpi	#2,d5
	bne.s	.nthigh
	move.w	#640,xres-DATA(a3)
	move.w	#400,yres-DATA(a3)
	move.w	#80,xresb-DATA(a3)
	move.w	#1,planes-DATA(a3)
	bra.s	.stcmpend

.nthigh	cmpi	#1,d5
	bne.s	.low
	move.w	#640,xres-DATA(a3)
	move.w	#200,yres-DATA(a3)
	move.w	#160,xresb-DATA(a3)
	move.w	#2,planes-DATA(a3)
	bra.s	.stcmpend

.low	move.w	#320,xres-DATA(a3)
	move.w	#200,yres-DATA(a3)
	move.w	#160,xresb-DATA(a3)
	move.w	#4,planes-DATA(a3)
.stcmpend
	move.l	$4f2,a0		; get OS version
	move.w	2(a0),d1
	cmpi.w	#$400,d1
	blt.s	.st

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,videomodes-DATA(a3)

	lea	planes-DATA(a3),a1	*** Tell everyone the new resolution
	move.l	#'FALC',d2
	move.l	#1,d0
	trap	#5

.st	rts

* FLI Frame
LIB44	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	moveq.l	#0,d3
	move.w	FLI_frm_cnt-DATA(a3),d3
	move.l	d3,-(a6)
	rts

* set cache
LIB45	dc.w	0
	move.l	(a6)+,d3
	movec	d3,CACR
	rts

*dummy
LIB46	dc.w	0
	rts

* falc colour
LIB47	dc.w	0
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,d5
	move.l	(a6)+,d3

	move.l	#$ff9800,a0
	lsl.l	#2,d3
	lea	0(a0,d3),a0

	lsl.l	#8,d5
	lsl.l	#8,d5
	lsl.l	#8,d5
	lsl.l	#2,d5
	lsl.l	#8,d6
	lsl.l	#8,d6
	lsl.l	#2,d6
	lsl.l	#2,d7

	or.l	d5,d6
	or.l	d6,d7

	move.l	d7,(a0)

	rts

*dummy
LIB48	dc.w	0
	rts

* tga decode
LIB49	dc.w	0

	move.l	(a6)+,a1

	move.l	(a6)+,a0

	move.b	1(a0),d3
	tst.b	d3
*	bne	ntdne		; not maptype 0

	move.b	2(a0),d3
	cmpi.b	#2,d3
*	bne	ntdne		; not imgtype 2

	move.w	12(a0),d3
	move.w	d3,d2
	andi.l	#$ff00,d3
	andi.l	#$ff,d2
	lsl.l	#8,d2
	lsr.l	#8,d3
	or.w	d2,d3
	move.l	d3,d7		; d7 = width

	move.w	14(a0),d3
	move.w	d3,d2
	andi.l	#$ff00,d3
	andi.l	#$ff,d2
	lsl.l	#8,d2
	lsr.l	#8,d3
	or.w	d2,d3
	move.l	d3,d6		; d6 = height

	moveq.l	#0,d5
	move.b	16(a0),d5	
	bsr	tgaplns		; (a2) = addr of conversion routine

	moveq.l	#0,d4
	move.b	17(a0),d4	; d4 = imgdesc
        andi.b  #$f0,d4
	tst.b	d4
	beq.s	.ltorbtot
	cmpi.b	#$20,d4
	beq.s	.ltorttob
	cmpi.b	#$30,d4
	beq.s	.rtolttob	

.rtolbtot
	move.l	d6,d4
	mulu	d7,d4
	andi.l	#$ffffffff,d4
	lsl.l	d4
	adda.l	d4,a1
	move.l	#-2,d4
	move.l	#-2,d5
	bra.s	.tgcont
.ltorttob
	move.l	#2,d4
	move.l	#2,d5
	bra.s	.tgcont
.rtolttob
	move.l	d7,d5
	lsl.l	d5
	adda.l	d5,a1
	lsl.l	d5
	subq.l	#2,d5
	move.l	#-2,d4
	bra.s	.tgcont
.ltorbtot
	move.l	d6,d4
	subq.l	#1,d4
	mulu	d7,d4
	andi.l	#$ffffffff,d4
	lsl.l	d4
	adda.l	d4,a1

	move.l	d7,d5
	lsl.l	#2,d5
	neg.l	d5
	addq.l	#2,d5

	moveq.l	#2,d4
	
.tgcont
	subq.l	#1,d7
	subq.l	#1,d6

	adda.l	#18,a0

	move.l	d7,d3
.tglp	jsr	(a2)
	adda.l	d4,a1
	dbra	d3,.tglp
	suba.l	d4,a1
	adda.l	d5,a1
	move.l	d7,d3
	dbra	d6,.tglp

	rts

tgaplns
	cmpi.b	#15,d5
	bne.s	.nttg15
	lea	tga15(pc),a2	
	rts
.nttg15	cmpi.b	#16,d5
	bne.s	.nttg16
	lea	tga16(pc),a2
	rts
.nttg16	cmpi.b	#24,d5
	bne.s	.nttg24
	lea	tga24(pc),a2
	rts
.nttg24	cmpi.b	#32,d5
	bne	ntdne
	lea	tga32(pc),a2
	rts

tga15	move.w	(a0)+,d0
        ror.w   #8,d0      intel -> moto
	move.w	d0,d1

	andi.w	#$7fe0,d0  ARRR RRGG GGGB BBBB -> RRRR RGGGG G0BB BBBB
	lsl.w	#1,d0
	andi.w	#$1f,d1
	or.w	d0,d1

	move.w	d1,(a1)
	rts

tga16	move.w	(a0)+,d0
        ror.w   #8,d0      intel -> moto
	move.w	d0,d1
	move.w	d0,d2
	andi.w	#$7fe0,d0  ARRR RRGG GGGB BBBB -> RRRR RGGG GGABB BBBB
	lsl.w	#1,d0
	andi.w	#$1f,d1
	andi.w	#$8000,d2
	lsr.w	#8,d2
	lsr.w	#2,d2
	or.w	d0,d1
	or.w	d2,d1

	move.w	d1,(a1)
	rts


tga24	move.l	(a0),d0
	adda.l	#3,a0

	lsr.l	#8,d0
	move.l	d0,d1
	move.l	d1,d2

	andi.l	#$f8,d2
	lsl.l	#8,d2

	andi.l	#$fc00,d1
	lsr.l	#5,d1

	andi.l	#$f80000,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	lsr.l	#3,d0

	or.l	d2,d0
	or.l	d1,d0
	move.w	d0,(a1)
	rts

tga32	move.l	(a0)+,d0
	move.l	d0,d1
	move.l	d1,d2

	andi.l	#$f800000,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	lsr.l	#8,d0
	lsr.l	#3,d0

	andi.l	#$fc000,d1
	lsr.l	#8,d1
	lsr.l	#5,d1

	andi.l	#$f80,d2

	or.l	d2,d0
	or.l	d1,d0

	move.w	d0,(a0)
	rts


*dummy
LIB50	dc.w	0
	rts

* tga encode
LIB51	dc.w	0
	move.l	(a6)+,d1	; get height
	move.l	(a6)+,d0	; get width
	move.l	(a6)+,a1	; get dest.
	move.l	(a6)+,a0	; Get source

	move.l	#0,(a1)
	move.l	#0,4(a1)
	move.l	#0,8(a1)
	move.l	#0,12(a1)
	move.l	#0,16(a1)
	move.w	#0,18(a1)

	move.b	#2,2(a1)

	move.w	d0,d2
	ror.w	#8,d2
	move.w	d2,12(a1)	Width and Height must be INTEL format

	move.w	d1,d2
	ror.w	#8,d2
	move.w	d2,14(a1)

	move.b	#16,16(a1)
	move.b	#$21,17(a1)	Left to Right, Top to Bottom 1-alpha

	adda.l	#18,a1

	subq.l	#1,d0
	subq.l	#1,d1
	move.l	d0,d3
.enclp	move.w	(a0)+,d4
	move.w	d4,d5
	move.w	d4,d6
	andi.w	#$ffc0,d5	RRRR RGGG GG
	lsr.w	d5
	andi.w	#$1f,d4		             B BBBB
	andi.w	#$20,d6		            A0 0000
	lsl.w	#8,d6
	lsl.w	#2,d6
	or.w	d5,d4
	or.w	d6,d4

	ror.w	#8,d4		moto -> intel

	move.w	d4,(a1)+
	dbra	d3,.enclp
	move.l	d0,d3
	dbra	d1,.enclp	
	rts

* dummy
LIB52	dc.w	0
	rts

* tc text
LIB53	dc.w	0

	move.l	(a6)+,a0
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,a2

	movem.l	a0-a6,-(sp)
	tst.w	(a0)
	beq	txtend

	move.l	$92c(a5),a6
	move.l	0(a6,d1.w),a6

	clr.l	d3
	move.w	xresb-DATA(a6),d3
	move.l	d3,xresbl

	move.l	gfont-DATA(a6),a1

* a2=screen address
* a1=gfont address
* a0=string (STOS)
* d7=y
* d6=x

	move.l	d7,d0			m=physbase()+(y-font.top+font.bottom)*_scrwid+x
*	sub.w	40(a1),d0
*	add.w	48(a1),d0
	mulu.w	xresbl+2,d0
	add.l	d6,d0
	add.l	d6,d0
	add.l	d0,a2			* a2=m

	moveq.l	#0,d7
	move.w	(a0)+,d7		while (*text)
	subq.w	#1,d7
whltxt

	moveq.l	#0,d0
	move.b	(a0)+,d0		letter=*text-font.first_ade
	sub.w	36(a1),d0
	blt	ntdne			if (letter<0) return

	lsl.l	d0
	move.l	72(a1),a3		start=font.coff_base[letter]
*	add.l	a1,a3
	add.l	d0,a3
	move.w	(a3)+,d0		* d0=start

	move.w	(a3),d1			length=font.coff_base[letter+1]-start
	sub.w	d0,d1			* d1=length

	move.w	#7,d2			bits=7-(start&7)
	and.w	d0,d2
	move.w	#7,d3
	sub.w	d2,d3			* d3=bits

	move.l	a2,a3			line=m

	lsr.l	#3,d0			whole=(char *)font.form_base+(start>>3)
	add.l	76(a1),d0		* d0=whole
*	add.l	a1,d0

	moveq.l	#0,d6
	move.w	82(a1),d6		while (i<font.form_height)
whlehgt	move.l	d0,a4			mover=whole
	move.w	d3,d4			k=bits	

	moveq.l	#0,d5
whlngth
	btst.b	d4,(a4)			if ((*mover&1<<k))
	beq.s	.nopix

	movea.l	a3,a5
	add.l	d5,a5
	add.l	d5,a5
	move.w	txtcol-DATA(a6),(a5)		line[j]=_textcol
.nopix
	subq.b	#1,d4			if ((--k)<0)
	bge.s	.cont

	move.b	#7,d4			k=7
	addq.l	#1,a4			mover++
.cont
	
	addq.w	#1,d5			j++
	cmp.w	d1,d5
	blt	whlngth	

	add.w	80(a1),d0		whole+=form_width
	add.l	xresbl,a3		line+=_scrwid

	dbra	d6,whlehgt		i++

	add.w	d1,a2			m+=length
	add.w	d1,a2

	dbge	d7,whltxt		text++

txtend	movem.l	(sp)+,a0-a6
	rts

xresbl	ds.w	1


* dummy
LIB54	dc.w	0
	rts

* falc draw
LIB55	dc.w	0

	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	move.l	(a6)+,a0

	cmp.l	d6,d0
	beq.s	.vert
	blt.s	.noswtch

	move.l	d6,d3		switch x0 and x1
	move.l	d0,d6
	move.l	d3,d0

	move.l	d7,d3
	move.l	d1,d7
	move.l	d3,d1

.noswtch
	cmp.l	d7,d1
	beq.s	.horiz

* Line is always in quadrant 1 or 4
* 
*    2 | 1
*   ---+---
*    3 | 4
*
	rts


.vert
*	cmp	d1,d7
*	blt	.noswtchv
*
*	move.l	d7,d2		switch vertical entries
*	move.l	d1,d7
*	move.l	d2,d1

.noswtchv
	moveq.l	#0,d2
	move.w	xresb-DATA(a3),d2

	move.l	ink-DATA(a3),d4

	move.l	d2,d3
	mulu	d1,d3
	add.l	d3,a0
	add.l	d0,a0
	add.l	d0,a0		calculate start of line

	sub.l	d1,d7
.vlp	move.w	d4,(a0)
	add.l	d2,a0
	dbra	d7,.vlp
	rts

.horiz	move.w	xresb-DATA(a3),d4
	mulu	d4,d1
	add.l	d1,a0
	add.l	d0,a0
	add.l	d0,a0		calculate start of line

	move.l	ink-DATA(a3),d4

	sub.l	d0,d6
.hlp	move.w	d4,(a0)+
	dbra	d6,.hlp
	rts

* dummy
LIB56	dc.w	0
	rts

* gdos font
LIB57	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0
	bne.s	.gdsnm

	move.l	gfont-DATA(a3),a0
	
.gdsnm	move.l	(a6)+,d3

.fntlp	subq.b	#1,d3
	blt.s	.gotit

	move.l	84(a0),a0
	bra.s	.fntlp
.gotit
	move.l	a0,gfont-DATA(a3)
	rts

* dummy
LIB58	dc.w	0
	rts

* FLI Init
LIB59	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,a0

	cmpi.w	#_hd_magic_val,_hd_magic(a0)
	beq	.itsfli
	
	cmpi.w	#_hd_magic_FLC,_hd_magic(a0)
	bne	.ntinit

.itsfli	move.w	_hd_frames(a0),d0
	moto	d0
	move.w	d0,FLI_lst_frm-DATA(a3)
	move.w	#1,FLI_frm_cnt-DATA(a3)

	add.l	#_hd_length,a0
	move.l	a0,FLI_frm_addr-DATA(a3)
	move.l	a0,FLI_frst_frm-DATA(a3)

.ntinit	rts

* dummy
LIB60	dc.w	0
	rts

* FLI Frame
LIB61	dc.w	0
	movem.l	a0-a5,-(sp)

	move.l	$92c(a5),a5
	move.l	0(a5,d1.w),a5

	move.l	(a6)+,a0

	move.l	FLI_frm_addr-DATA(a5),a1
	lea.l	FLI_pal-DATA(a5),a2
	
	move.w	FLI_lst_frm-DATA(a5),d3
	cmp.w	FLI_frm_cnt-DATA(a5),d3
	bne.s	.ntlst

	move.l	FLI_frst_frm-DATA(a5),a1
	move.w	#0,FLI_frm_cnt-DATA(a5)

.ntlst	add.w	#1,FLI_frm_cnt-DATA(a5)
	moveq.l	#0,d2

* d2=number of first colour to change
* a0=address of 320x200xTC screen
* a1=address of next frame
* a2=address of pseudo pallette

	cmpi.w	#_frm_magic_val,_frm_magic(a1)
	bne	ntdne

	move.l	a1,a4
	move.l	_frm_size(a1),d1
	moto	d1
	swap	d1
	moto	d1
	add.l	d1,a4
	move.l	a4,FLI_frm_addr-DATA(a5)

	move.w	_frm_no_chunks(a1),d1
	moto	d1
	subq.w	#1,d1
	bmi.s	nochks
	add.l	#_frm_length,a1

* Chunk loop
dochnk
	moveq.w	#0,d0
	move.b	_chk_type(a1),d0

	cmpi.w	#_cmp_pal,d0		jump to relevent chunk decoder
	beq	do_cmp_pal
	cmpi.w	#_cmp_line,d0
	beq	do_cmp_line
	cmpi.w	#_blank,d0
	beq	do_blank
	cmpi.w	#_cmp_scr,d0
	beq	do_cmp_scr
	cmpi.w	#_uncmp_scr,d0
	beq	do_uncmp_scr	

	cmpi.w	#_cmp_pal_256,d0	FLC chunks
	beq	do_cmp_pal_256
	cmpi.w	#_cmp_line2,d0
	beq	do_cmp_line2

** Unrecognized chunk - so skip it...

	move.l	(a1),d7
	moto	d7
	swap	d7
	moto	d7
	add.l	d7,a1
	dble	d1,dochnk

* Finished frame...
nochks
	movem.l	(sp)+,a0-a5
	rts


***** Chunk decoders....
* d1=number of chunks remaining
* d2=index of current colour into palette (for cmp_pal)
* a0=address of next line (assumed first line by _blank / _uncmp_scr)
* a1=address of current chunk
* a2=address of pseudo pallette


* handle a 256 cmpressed pallette chunk (corrupts d5-d7) (FLC only!!)
do_cmp_pal_256
	addq.l	#_chk_length,a1

	move.w	(a1)+,d7
	moto	d7
	add.w	d7,d2
	subq.w	#1,d2

	cmpi.w	#256,d2
	blt.s	.nolpbk

	moveq.w	#0,d2
.nolpbk
	move.w	(a1)+,d7
	moto	d7
	tst.w	d7
	bgt.s	.dorgb

	move.w	#256,d7

.dorgb	move.b	(a1)+,d6
	andi.w	#$f8,d6
	lsl.w	#8,d6
	move.b	(a1)+,d5
	andi.w	#$fc,d5
	lsl.w	#3,d5
	or.w	d5,d6
	move.b	(a1)+,d5
	andi.b	#$f8,d5
	lsr.w	#3,d5
	or.l	d5,d6
	move.w	d6,0(a2,d2*2)
	addq.w	#1,d2
	subq.w	#1,d7
	bgt.s	.dorgb

	dbra	d1,dochnk

* Finished frame...
	movem.l	(sp)+,a0-a5
	rts


* handle a cmpressed pallette chunk (corrupts d5-d7)
do_cmp_pal
	addq.l	#_chk_length,a1

	move.w	(a1)+,d7
	moto	d7
	add.w	d7,d2
	subq.w	#1,d2

	cmpi.w	#256,d2
	blt.s	.nolpbk

	moveq.w	#0,d2
.nolpbk
	move.w	(a1)+,d7
	moto	d7
	tst.w	d7
	bgt.s	.dorgb

	move.w	#256,d7

.dorgb	move.b	(a1)+,d6
	andi.w	#$3e,d6
	lsl.w	#8,d6
	lsl.w	#2,d6
	move.b	(a1)+,d5
	andi.w	#$3f,d5
	lsl.w	#5,d5
	or.w	d5,d6
	move.b	(a1)+,d5
	andi.w	#$3e,d5
	lsr.w	d5
	or.w	d5,d6
	move.w	d6,0(a2,d2*2)
	addq.w	#1,d2
	subq.w	#1,d7
	bgt.s	.dorgb

	dbra	d1,dochnk

* Finished frame...
	movem.l	(sp)+,a0-a5
	rts



* handle a 'Line Compressed data' chunk
do_cmp_line
		add.l	#_chk_length,a1

                move.l  #320,D6       ; Fli_Widht
                move.l  #200,D7       ; Fli_Height
                move.w  xresb-DATA(a5),D5       ; Scr_Width

		move.l	a0,a4

		movem.l	d0-d4/a3,-(sp)

fli_lc:         move.w  (A1)+,D0        ; Ystart
                ror.w   #8,D0           ; schon haben wir ein Motorola Wort

                move.w  (A1)+,D1        ; Changelines
                ror.w   #8,D1           ; schon haben wir ein Motorola Wort

                mulu    D5,D0           ; Scr_Width*Ystart
                adda.l  D0,A0           ; Frame+=Scr_Width*Ystart

                subq.w  #1,D1           ; wegen DBRA

fli_lc_y_lp:    movea.l A0,A3           ; Frame2=Frame

                moveq   #0,D3
                move.b  (A1)+,D3        ; Anzahl der Pakete
                beq.s   fli_lc_no_paket ; keine Pakete!
                subq.w  #1,D3           ; wegen DBRA

fli_lc_p_lp:    moveq   #0,D0
                move.b  (A1)+,D0        ; Skipbyte holen
                add.w   D0,D0           ; *2
                adda.l  D0,A0           ; Frame+=SkipByte SHL 1

                moveq   #0,D0
                moveq   #0,D2
                move.b  (A1)+,D2        ; TypeSize Byte
                bmi.s   fli_lc_else     ; TypeSize < 128
                beq.s   fli_lc_nop      ; TypeSize = 0 !
                subq.w  #1,D2           ; wegen DBRA

fli_lc_i_lp:    move.b  (A1)+,D0        ; Pixel holen
               move.w  (0,A2,D0.w*2),(A0)+ ; und in richtiger Farbe setzen
;                DC.W $30F2,$0200        ; 68020-Code
                dbra    D2,fli_lc_i_lp  ; NEXT i
                bra.s   fli_lc_endif

fli_lc_else:    neg.b   D2
                subq.w  #1,D2           ; wegen DBRA
                move.b  (A1)+,D0        ; Pixel holen
               move.w  (0,A2,D0.w*2),D0 ; Farbe holen
;                DC.W $3032,$0200        ; 68020-Code
fli_lc_j_lp:    move.w  D0,(A0)+        ; Pixel setzen
                dbra    D2,fli_lc_j_lp  ; NEXT j

fli_lc_nop:
fli_lc_endif:   dbra    D3,fli_lc_p_lp  ; NEXT p

fli_lc_no_paket:lea     0(A3,D5.w),A0   ; Frame=Frame2+Scr_Width

                dbra    D1,fli_lc_y_lp  ; NEXT y


	movem.l	(sp)+,d0-d4/a3
	move.l	a4,a0
	dbra	d1,dochnk	

* Finished frame...
	movem.l	(sp)+,a0-a5
	rts



* handle a blank screen chunk
do_blank
	addq.l	#_chk_length,a1
	move.w	#320,d7
	move.w	#200,d6
	move.w	(a2),d5
.blnklp	move.w	d5,(a0)+
	dblt	d7,.blnklp
	move.w	#320,d7
	dblt	d6,.blnklp

	dbra	d1,dochnk

* Finished frame...
	movem.l	(sp)+,a0-a5
	rts


* handle a BRUN Bytewise RLE compressed chunk
do_cmp_scr
		add.l	#_chk_length,a1

                move.l  #320,D6       ; Fli_Widht
                move.w  #200,D7       ; Fli_Height
                move.l  #640,D5       ; Scr_Width

		movem.l	d0-d4,-(sp)

fli_brun:       add.l   D6,D6           ; Fli_Width * 2
                sub.l   D6,D5           ; von Scr_Width ein wenig abziehen und schwupp haben wir Scr_Offset

                subq.w  #1,D7           ; Hoehe-=1, wegen DBRA

fli_brun_y_lp:  addq.l  #1,A1           ; Anzahl der Pakete wird ignoriert
                move.l  A0,D3           ; Zeiger auf Bildschirm
                add.l   D6,D3           ; Zeiger auf Zeilenende

fli_brun_x_lp:  moveq   #0,D2
                moveq   #0,D0
                move.b  (A1)+,D2        ; TypeSize Byte
                bpl.s   fli_brun_else   ; TypeSize < 128
                beq.s   fli_brun_nop    ; TypeSize=0 !
                neg.b   D2              ; 256-TypeSize
                subq.w  #1,D2           ; wegen DBRA

fli_brun_i_lp:  move.b  (A1)+,D0        ; Pixel holen
;               move.w  (0,A2,D0.w*2),(A0)+ ; und in richtiger Farbe setzen
                DC.W $30F2,$0200        ; 68020-Code
                cmpa.l  D3,A0           ; Zeilenende erreicht?
                bge.s   fli_brun_end_paket ; ja, raus hier!
                dbra    D2,fli_brun_i_lp ; NEXT i
                bra.s   fli_brun_endif

fli_brun_else:  subq.w  #1,D2           ; wegen DBRA
                move.b  (A1)+,D0        ; Pixel holen
;               move.w  (0,A2,D0.w*2),D0 ; Farbe holen
                DC.W $3032,$0200        ; 68020-Code
fli_brun_j_lp:  move.w  D0,(A0)+        ; Pixel setzen
                cmpa.l  D3,A0           ; Zeilenende erreicht?
                bge.s   fli_brun_end_paket ; ja, raus hier!
                dbra    D2,fli_brun_j_lp ; NEXT j

fli_brun_nop:
fli_brun_endif: cmpa.l  D3,A0           ; Frame >= Oldframe +(2 * Fli_Width)
                blt.s   fli_brun_x_lp   ; NEXT x

fli_brun_end_paket:adda.l D5,A0         ; Offset zur nÑchsten Zeile

                dbra    D7,fli_brun_y_lp ; NEXT y

	movem.l	(sp)+,d0-d4
	dbra	d1,dochnk	
	movem.l	(sp)+,a0-a5
	rts



* handle an uncompressed screen chunk
do_uncmp_scr
	addq.l	#_chk_length,a1
	move.w	#320,d7
	move.w	#200,d6

.uncplp	move.b	(a1)+,d5
	move.w	0(a2,d5*2),(a0)+
	dblt	d7,.uncplp
	move.w	#320,d7
	dblt	d6,.uncplp	

	dbra	d1,dochnk

* Finished frame...
	movem.l	(sp)+,a0-a5
	rts


* handle an compressed line type 2 chunk
do_cmp_line2
	addq.l	#_chk_length,a1
	movem.l	d0-d4,-(sp)

		move.w  #320,D6       ; Fli_Widht
                move.w  #200,D7       ; Fli_Height
		moveq.l	#0,d0
                move.w  xresb-DATA(a5),D5       ; Scr_Width

fli_lc2:        move.w  (A1)+,D4        ; Changelines holen
                beq     fli_lc2_ende    ; Null? Dann nix zu tun
                ror.w   #8,D4           ; eben noch intel, jetzt Motorola
                subq.w  #1,D4           ; wegen DBRA

fli_lc2_line_lp:moveq   #0,D3           ; use_last_byte=0

fli_lc2_rd_word:move.w  (A1)+,D0        ; Word holen
                ror.w   #8,D0           ; wandeln
                tst.w   D0
                bpl.s   fli_lc2_pcfound ; Packet_Count gefunden

                btst    #14,D0          ; Line_Skip oder Last_Byte?
                beq.s   fli_lc2_last_b  ; Last_Byte auswerten

                neg.w   D0              ; Line_Skip auswerten
                mulu    D5,D0           ; muû wohl sein ...
                adda.l  D0,A0           ; Frame+=Line_Skip*Scr_Width
                bra.s   fli_lc2_rd_word ; nÑchstes Word lesen

fli_lc2_last_b: move.b  D0,D3           ; LowByte eintragen
                swap    D3
                eor.b   D3,D3           ; unterstes Byte auf $FF
                bra.s   fli_lc2_rd_word ; nÑchstes Word lesen

fli_lc2_pcfound:movea.l D3,A4           ; Last_Byte auslagern
                move.w  D0,D3           ; Packet_Count
                beq.s   fli_lc2_nopacket ; Null, nichts tun!
                subq.w  #1,D3           ; wegen DBRA
                movea.l A0,A3           ; Old_Frame=Frame

fli_lc2_packetlp:moveq  #0,D0
                move.b  (A1)+,D0        ; Column_Skip holen
                add.w   D0,D0           ; *2
                adda.l  D0,A0           ; Frame+=Column_Skip SHL 1

                moveq   #0,D2
                move.b  (A1)+,D2        ; Packet_Type holen
                bmi.s   fli_lc2_else    ; Brun dekodieren
                beq.s   fli_lc2_nop     ; Packet_Type=0!
                subq.w  #1,D2           ; wegen DBRA

                moveq   #0,D0           ; schon fÅr die Schleife lîschen

fli_lc2_copy:   move.b  (A1)+,D0        ; LowByte holen
                move.w  (0,A2,D0.w*2),(A0)+ ; Pixel setzen

                move.b  (A1)+,D0        ; HighByte holen
                move.w  (0,A2,D0.w*2),(A0)+ ; Pixel setzen

                dbra    D2,fli_lc2_copy ; NEXT i
                bra.s   fli_lc2_endif

fli_lc2_else:   neg.b   D2              ; 256-Packet_Type
                subq.w  #1,D2           ; wegen DBRA

                moveq   #0,D0
                moveq   #0,D1
                move.b  (A1)+,D1        ; HighPixel

                move.w  (0,A2,D1.w*2),D0 ; HighPixel holen
                swap    D0              ; ins obere Wort damit

                move.b  (A1)+,D0        ; LowPixel
                move.w  (0,A2,D0.w*2),D0 ; LowPixel holen

fli_lc2_brun:   move.l  D0,(A0)+        ; LowPixel/HighPixel schreiben
                dbra    D2,fli_lc2_brun ; NEXT i

fli_lc2_nop:
fli_lc2_endif:  dbra    D3,fli_lc2_packetlp ; NEXT p

fli_lc2_nopacket:move.l A4,D0           ; Last_Byte holen
                tst.b   D0
                beq.s   fli_lc2_nolast  ; Last Byte vorhanden?
                swap    D0              ; Farbindex holen
                move.w  (0,A2,D0.w*2),(A0)+ ; Pixel setzen

fli_lc2_nolast: lea     0(A3,D5.w),A0   ; Frame=Old_Frame+Scr_Width

                dbra    D4,fli_lc2_line_lp ; NEXT line_no

fli_lc2_ende
	movem.l	(sp)+,d0-d4
	dbra	d1,dochnk

* Finished frame...
	movem.l	(sp)+,a0-a5
	rts

* dummy
LIB62	dc.w	0
	rts

* TC alpha
LIB63	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3

	move.l	(a6)+,d3

	cmpi.w	#$ffff,d3
	beq.s	.noalpha

	move.b	#-1,alpha_flag-DATA(a3)
	move.w	d3,alpha_and-DATA(a3)
	not.w	d3
	move.w	d3,alpha_nand-DATA(a3)
	rts

.noalpha
	move.b	#0,alpha_flag-DATA(a3)
	move.w	#-1,alpha_and-DATA(a3)
	move.w	#-1,alpha_nand-DATA(a3)
	rts

*** The end.....

LIBEX	dc.w	0