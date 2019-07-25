*************************************************
*
* Falcon Extension for STOS, Graphics sub-system
*
* V1.4
*
*

	OUTPUT	D:\STOS\STOS\FGRAPHIC.EXX

* Condition for registered / shareware
* 0 = un-registered

unregistered	equ	1

* Jump header

*	even
	bra	INIT

***********************************************
*
* Header
*

* Start of token list

	dc.b	128

TOKENS	dc.b	"set video",128
	dc.b	"cookie",129
	dc.b	"init goraud",130
	dc.b	"jagpad",131
	dc.b	"falc plot",132
	dc.b	"monitor",133
	dc.b	"df video",134
	dc.b	"quick fade",135
	dc.b	"cycle",136
	dc.b	"os version",137
	dc.b	"tc sprite",138
	dc.b	"tc point",139
	dc.b	"falc cls",140
	dc.b	"tc fade",141
	dc.b	"set fv",142
	dc.b	"scr size",143
	dc.b	"fpal",144
	dc.b	"tc scrn fade",145
	dc.b	"init virtual",146
	dc.b	"falc x mouse",147
	dc.b	"virtual",148
	dc.b	"falc y mouse",149
	dc.b	"falc bar",150
	dc.b	"falc mkey",151
	dc.b	"falc box",152
	dc.b	"falc zone",153
	dc.b	"tc copy",154
	dc.b	"cache",155
	dc.b	"set fpal",156
	dc.b	"xres",157
	dc.b	"goraud",158
	dc.b	"yres",159
	dc.b	"falc mouse on",160
	dc.b	"dummyadj",161
	dc.b	"falc mouse off",162
	dc.b	"planes",163
	dc.b	"falc set zone",164
	dc.b	"tga width",165
	dc.b	"falc set mouse",166
	dc.b	"tga height",167
	dc.b	"falc ink",168
	dc.b	"tc collide",169
	dc.b	"st compat",170
	dc.b	"fli frame",171
	dc.b	"set cache",172
	dc.b	"dummyadj",173
	dc.b	"falc colour",174
	dc.b	"dummyadj",175
	dc.b	"tga decode",176
	dc.b	"dummyadj",177
	dc.b	"tga encode",178
	dc.b	"dummyadj",179
	dc.b	"tc text",180
	dc.b	"dummyadj",181
	dc.b	"falc draw",182
	dc.b	"dummyadj",183
	dc.b	"gdos font",184
	dc.b	"dummyadj",185
	dc.b	"fli init",186
	dc.b	"dummyadj",187
	dc.b	"fli do frame",188
	dc.b	"dummyadj",189
	dc.b	"tc alpha",190
	dc.b	"dummyadj",191
	dc.b	"lfalc help",192
	dc.b	"dummyadj",193
	dc.b	"falc help",194


* The end of the token list

	dc.b	0

	even

* Now the jump table

JUMPS	dc.w	67
	dc.l	set_video
	dc.l	cookie		
	dc.l	initgoraud
	dc.l	jagpad		
	dc.l	tc_plot
	dc.l	monitor
	dc.l	dfvideo
	dc.l	newfade
	dc.l	cycle
	dc.l	os_ver		
	dc.l	tc_sprite
	dc.l	tc_point
	dc.l	falc_cls
	dc.l	tc_fade
	dc.l	set_fv
	dc.l	scrnsize
	dc.l	get_fpal
	dc.l	tc_scrnfde
	dc.l	init_virtual
	dc.l	xmouse
	dc.l	virtual
	dc.l	ymouse
	dc.l	tc_bar
	dc.l	mkey
	dc.l	tc_box
	dc.l	zone
	dc.l	tc_copy
	dc.l	cache
	dc.l	set_fpal
	dc.l	xres_fun
	dc.l	goraud
	dc.l	yres_fun
	dc.l	init_mouse
	dc.l	dummy
	dc.l	mouse_off
	dc.l	planes_fun
	dc.l	set_zone
	dc.l	tga_width
	dc.l	set_mouse
	dc.l	tga_height
	dc.l	falc_ink
	dc.l	tc_collide
	dc.l	st_compat
	dc.l	fli_frame
	dc.l	set_cache
	dc.l	dummy
	dc.l	falc_colour
	dc.l	dummy
	dc.l	tga_decode
	dc.l	dummy
	dc.l	tga_encode
	dc.l	dummy
	dc.l	tc_text
	dc.l	dummy
	dc.l	falc_draw
	dc.l	dummy
	dc.l	gdos_font
	dc.l	dummy
	dc.l	FLI_init
	dc.l	dummy
	dc.l	FLI_do_frame
	dc.l	dummy
	dc.l	TC_alpha
	dc.l	dummy
	dc.l	lfalc_help
	dc.l	dummy
	dc.l	falc_help

* The welcome mesages in English and French

WELCOME	dc.b	10,13,"                          The Falcon Extension V1.4"
	IFEQ	unregistered
	dc.b	10,13
	dc.b	10,13,"                             Un-registered version."
	dc.b	10,13,"                         To register, send 5 pounds to:"
	dc.b	10,13,"                        Anthony Jacques, 70 West Avenue,"
	dc.b	10,13,"                             Bath, England. BA2 3QD."
	dc.b	10,13
	ENDC
	dc.b	10,13,"                         Graphics sub-system installed.",0
	dc.b	10,13,"                           le Extension Falcon V1.4"
	IFEQ	unregistered
	dc.b	10,13
	dc.b	10,13,"                             Un-registered version."
	dc.b	10,13,"                         To register, send 5 pounds to:"
	dc.b	10,13,"                        Anthony Jacques, 70 West Avenue,"
	dc.b	10,13,"                             Bath, England. BA2 3QD."
	dc.b	10,13
	ENDC
	dc.b	10,13,"                         sub-system graphic est active.",0
	dc.b	0
	even

* Reserve return and system address space

SYSTEM	dc.l	0
RETURN	dc.l	0	


* The routine that is called on start-up

INIT	lea	END,a0
	lea	COLDST,a1
	rts

COLDST	move.l	a0,SYSTEM

	move.l	$4f2,a0		; get OS version
	move.w	2(a0),d1
	cmpi.w	#$400,d1
	blt	gmminit		; if not F030 then skip this stuff

	clr.l	$4d2		; disable cursor

	move.b	#%1000101,$ff8007
	move.w	#12561,d0
	movec	d0,cacr

	move.w	#-1,-(sp)	; get current mode
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	d0,d7		; store it
	move.w	d0,d4

	move.w	#89,-(sp)	; get monitor type
	trap	#14
	addq.l	#2,sp

	cmpi.b	#2,d0		; if not VGA goto starttv
	bne	starttv
	
	andi.w	#%100000000,d7	; if Hi rez (jump)
	tst.w	d7
	bne	gmminit

	move.w	#%10011000,d2	; set hirez
	move.l	#0,$ff9804
	bra	doit

starttv	andi.w	#%100000000,d7	; test whether hi rez
	tst.w	d7
	beq	gmminit

	move.w	#%110101000,d2	; yes, so go to hi.
	move.l	#0,$ff9804

doit	move.w	d2,d4

	move.w	d2,-(sp)	; set the mode
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	andi.b	#%111,d2
	beq.s	.mcol

	cmpi.b	#1,d2
	beq.s	.fcol

	cmpi.b	#2,d2
	beq.s	.scol

	cmpi.b	#3,d2
	beq.s	.tcol

	move.w	#16,planes
	bra.s	.svcont

.mcol	move.w	#1,planes
	bra.s	.svcont

.fcol	move.w	#2,planes
	bra.s	.svcont

.scol	move.w	#4,planes
	bra.s	.svcont

.tcol	move.w	#8,planes

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
	move.w	d0,yres

	move.w	$ff8210,d0	; d0=number of words in a line
	move.w	d0,d1
	lsl.w	#1,d1
	move.w	d1,xresb
	move.w	planes,d1
	divu	d1,d0
	mulu	#16,d0
	move.w	d0,xres
.svfin


gmminit	move.w	d4,videomodes
	move.w	#0,mflag

	lea	WELCOME,a0	; vital stuff
	lea	WARMST,a1
	lea	TOKENS,a2
	lea	JUMPS,a3
	rts

* Executed on UNDO in editor

WARMST	tst.w	mflag
	beq.s	.cont

	movem.l	d0/a0,-(sp)

	move.w	#$22,-(sp)		;Kbdvbase()
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0

.wait_drvstat2:
	tst.w	36(a0)
	bne	.wait_drvstat2

	move.l	mvec,16(a0)
	move.w	#0,mflag	

	movem.l	(sp)+,d0/a0
.cont	rts

************************************************
*
* My instructions / functions
*

* function returns the value of the given cookie
cookie	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bpl	ILLEGAL

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

	clr.l	d2
	move.l	d1,d3

	move.l	RETURN,a0
	jmp	(a0)

* else, error message - Search failed
.no_cook
	moveq	#5,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)


* function returns the current values of jagpad
jagpad	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	cmpi.l	#1,d3
	bgt	ntdne

	move.l	d3,-(sp)

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

	clr.l	d2
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)


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
	move.l	#0,c1numpad
	move.l	#0,c2numpad

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
	move.w	d0,c1numpad

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.w	d0,c2numpad

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
	or.l	d0,c1numpad

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	or.l	d0,c2numpad

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
	or.l	d0,c1numpad

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#4,d0
	or.l	d0,c2numpad

	lsl.l	#7,d3	; d3 contains xxxx,c1midbuts,c1firebuts,c1joypad
	lsl.l	#4,d4
	or.l	d4,d3
	or.l	d5,d3	

	lsl.l	#7,d6	; d6 = xxxx,c2midbuts,c2firebuts,c2joypad
	lsl.l	#4,d7
	or.l	d7,d6
	move.l	a0,d2
	or.l	d2,d6

	move.l	c1numpad,d2	; d2 = c1numpad
	lsl.l	#5,d2
	move.l	c2numpad,d5	; d5 = c2numpad
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

* instruction sets the video mode.
set_video
	move.l	(sp)+,RETURN

*  Read parameter - 1 int

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	lsl.l	d3
	move.l	#videomodes,a0
	add.l	d3,a0
	move.w	(a0),d3

	move.w	d3,-(sp)	call XBIOS 88 (setmode)
	move.w	#88,-(sp)
	trap	#14
	add.l	#4,sp

	andi.b	#%111,d3
	beq.s	.mcol

	cmpi.b	#1,d3
	beq.s	.fcol

	cmpi.b	#2,d3
	beq.s	.scol

	cmpi.b	#3,d3
	beq.s	.tcol

	move.w	#16,planes
	bra.s	.svcont

.mcol	move.w	#1,planes
	bra.s	.svcont

.fcol	move.w	#2,planes
	bra.s	.svcont

.scol	move.w	#4,planes
	bra.s	.svcont

.tcol	move.w	#8,planes

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
	move.w	d0,yres

	move.w	$ff8210,d0	; d0=number of words in a line
	move.w	d0,d1
	lsl.w	d1
	move.w	d1,xresb
	move.w	planes,d1
	divu	d1,d0
	mulu	#16,d0
	move.w	d0,xres
.svfin
	lea	planes,a1		***** Pass screenres data to other extensions
	move.l	#'FALC',d2
	move.l	#1,d0
	trap	#5

	move.l	RETURN,a0
	jmp	(a0)



* instruction defines a video mode.

dfvideo	move.l	(sp)+,RETURN

	cmpi	#8,d0
	bne	SYNTAX

	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	movea.l	#0,a0
	movea.l	#0,a1
	movea.l	#0,a2


	movem.l	(sp)+,d2-d4	; get no. colours
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get 80 column
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get VGA
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get PAL
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	; get Overscan
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	; get ST compat.
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get vertflag
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a1

	movem.l	(sp)+,d2-d4	; get mode number
	tst.b	d2
	bne	TYPEMIS
	tst.l	d3
	ble	ntdne		; test valid no.
	cmpi.l	#10,d3
	bge	ntdne
	lsl.l	#1,d3
	move.l	#videomodes,a2
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

	move.l	RETURN,a0
	jmp	(a0)


* function returns the monitor type

monitor	move.l	(sp)+,RETURN
	
	tst	d0
	bne	SYNTAX

	move.w	#89,-(sp)		call XBIOS 89 (mon_type)
	trap	#14
	addq.l	#2,sp

	clr.l	d3
	move.w	d0,d3
	clr.l	d2
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)


* instruction initialises the goraud routine.
initgoraud
	move.l	(sp)+,RETURN

	movem.l	a3/a5/a6,-(sp)
	bsr	@initgoraud
	movem.l	(sp)+,a3/a5/a6

	move.l	RETURN,a0
	jmp	(a0)


* instruction draws a TC goraud shaded polygon.
*goraud	move.l	(sp)+,RETURN
*	cmp	#11,d0
*	blt	SYNTAX
*
*	andi.l	#$ffff,d0
*
*	subq.l	#2,d0
*
*	divs	#3,d0
*	move.l	d0,d1
*
**	andi.w	#$ff,d1
**	tst.w	d1
**	bne	SYNTAX
*
*	swap	d0		; d0.low = no_of_points
*	move.w	d0,d6
*
*	lea.l	new_crds,a0
*
*.gptlp	movem.l	(sp)+,d2-d4	; get intensity
*	tst.b	d2
*	bne	TYPEMIS
*	move.w	d3,4(a0)
*
*	movem.l	(sp)+,d2-d4	; get y
*	tst.b	d2
*	bne	TYPEMIS
*	move.w	d3,2(a0)
*
*	movem.l	(sp)+,d2-d4	; get x
*	tst.b	d2
*	bne	TYPEMIS
*	move.w	d3,(a0)
*
*	add.l	#6,a0
*	subq.w	#3,d0
*	bgt.s	.gptlp
*
*	movem.l	(sp)+,d2-d4	; get colour
*	tst.b	d2
*	bne	TYPEMIS
*	move.l	d3,d1
*
*	movem.l	(sp)+,d2-d4	; get screen
*	tst.b	d2
*	bne	TYPEMIS
*	move.l	d3,a1
*
*	cmpi.l	#0,d1
*	bne.s	.ggrn
*	move.l	#g_lightred,a2
*	bra.s	.pts
*.ggrn	cmpi.l	#1,d1
*	bne.s	.gwht
*	move.l	#g_green,a2
*	bra.s	.pts
*.gwht	cmpi.l	#2,d1
*	bne.s	.gbrn
*	move.l	#g_white,a2
*	bra.s	.pts
*.gbrn	cmpi.l	#3,d1
*	bne.s	.gadr
*	move.l	#g_brown,a2
*	bra.s	.pts
*.gadr	move.l	d1,a2
*.pts
*	movem.l	a0-a6,-(sp)
*	bsr	@goraud
**	movem.l	(sp)+,a0-a6
*
*	move.l	RETURN,a0
*	jmp	(a0)
*

goraud	move.l	(sp)+,RETURN
	cmpi	#11,d0
	bne	SYNTAX

	lea	new_crds,a0

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,16(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,14(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,12(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,10(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,8(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,6(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,4(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,2(a0)

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,(a0)

	movem.l	(sp)+,d2-d4	; get colour
	tst.b	d2
*	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
*	bne	TYPEMIS
	move.l	d3,a1

	cmpi.l	#0,d1
	bne.s	.ggrn
	move.l	#g_lightred,a2
	bra.s	.pts
.ggrn	cmpi.l	#1,d1
	bne.s	.gwht
	move.l	#g_green,a2
	bra.s	.pts
.gwht	cmpi.l	#2,d1
	bne.s	.gbrn
	move.l	#g_white,a2
	bra.s	.pts
.gbrn	cmpi.l	#3,d1
	bne.s	.gadr
	move.l	#g_brown,a2
	bra.s	.pts
.gadr	move.l	d1,a2
.pts
	move.w	#3,d6

	movem.l	a0-a6,-(sp)
	bsr	@goraud
	movem.l	(sp)+,a0-a6

	move.l	RETURN,a0
	jmp	(a0)


* function returns the OS version number.

os_ver	move.l	(sp)+,RETURN
	
	tst	d0
	bne	SYNTAX

	clr.l	d3
	move.l	$4f2,a0
	move.w	2(a0),d3
	clr.l	d2
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)


* function returns the RGB value at x,y on screen

tc_point
	move.l	(sp)+,RETURN

	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	get y
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	cmpi	#0,d7
	blt	ntdne

	cmp	yres,d7
	bgt	ntdne


	movem.l	(sp)+,d2-d4	; get x
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	cmpi	#0,d6
	blt	ntdne

	cmp	xres,d6
	bgt	ntdne

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	cmpi.w	#16,planes
	bne.s	.bp_point

	lsl.l	#1,d6
	add.l	d6,a0

	mulu	xresb,d7
	add.l	d7,a0

	moveq.l	#0,d3
	move.w	(a0),d3
	moveq.l	#0,d2

	move.l	RETURN,a0
	jmp	(a0)

.bp_point

	moveq.l	#0,d2
	moveq.l	#0,d3

	move.l	RETURN,a0
	jmp	(a0)

* instruction plots the point x,y with the colour RGB on screen
tc_plot	move.l	(sp)+,RETURN

	cmpi	#3,d0
	bne	SYNTAX

	move.l	ink,d5

	movem.l	(sp)+,d2-d4	; get y
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1
	blt	ntdne

	cmp	yres,d1
	bgt	ntdne

	movem.l	(sp)+,d2-d4	; get x
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0
	blt	ntdne

*	cmp	xres,d0
*	bgt	ntdne

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	cmpi	#16,planes
	bne.s	.bp_plot

	lsl.l	#1,d0
	add.l	d0,a0

	mulu	xresb,d1
	add.l	d1,a0

	move.w	d5,(a0)

	move.l	RETURN,a0
	jmp	(a0)

* a0=screen addr.
* d0=x
* d1=y
* d5=colour

.bp_plot
	move.w	planes,d7	; d7 = number of planes

	mulu	xresb,d1
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
	move.l	RETURN,a0
	jmp	(a0)

.bpst	or.w	d1,d2
	move.w	d2,(a0)+
	bra.s	.bplp


* Function performs 1 level of a fade on a TC screen

tc_fade	move.l	(sp)+,RETURN

	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get address of screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get length
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	move.l	ink,d1

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
.bye	adda.l	#2,a0
.byeaj
	subq.l	#2,d5
	bgt.S	.fdlp

	moveq.l	#0,d2
	move.l	d6,d3
	moveq.l	#0,d4

	move.l	RETURN,a0
	jmp	(a0)


* function performs 1 level of a 256 colour fade

newfade	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	clr.l	d0
	move.l	d3,d1
	and.l	#$3f000,d1	; isolate R bits
	lsl.l	#8,d1
	lsl.l	#6,d1
	move.l	d3,d2

	and.l	#$fc0,d3	; isolate G bits
	lsl.l	#8,d3
	lsl.l	#4,d3
	or.l	d3,d1

	and.l	#$3f,d2
	lsl.l	#2,d2
	or.l	d2,d1

	move.l	#$ffff9800,a0
	move.w	#256,d5
	
.fd256l	bsr	@fade256
	subq.w	#1,d5
	tst.w	d5
	bne.s	.fd256l

	clr.l	d2
	clr.l	d3
	move.b	d0,d3
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

@fade256
.red
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
.bok	move.l	d2,(a0)+		Put changed pixel in palette.
	addq.l	#1,d0
	rts
.bye	addq.l	#4,a0
	rts



* function returns the size of a screen in a given mode

scrnsize
	move.l	(sp)+,RETURN

	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	lsl.l	#1,d3
	move.l	#videomodes,a0
	add.l	d3,a0
	move.w	(a0),d3

	move.w	d3,-(sp)
	move.w	#91,-(sp)
	trap	#14
	addq.l	#4,sp

	clr.l	d2
	clr.l	d4
	move.l	d0,d3

	move.l	RETURN,a0
	jmp	(a0)


* Function fades one TC screen to another

tc_scrnfde
	move.l	(sp)+,RETURN

	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get length
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get start(screen 2)
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a1

	movem.l	(sp)+,d2-d4	; get start(screen 1)
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	moveq.l	#0,d6
.sfdlp	moveq.l	#0,d1
.red
	move	(a1)+,d1		Get target pixel
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

	moveq.l	#0,d2
	move.l	d6,d3
	moveq.l	#0,d4

	move.l	RETURN,a0
	jmp	(a0)



* Instruction draws a "Spooky Sprites" sprite

tc_sprite
	move.l	(sp)+,RETURN

	cmpi	#5,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get address of sprite bank
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get address of screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a1

	movem.l	(sp)+,d2-d4	; get sprite no.
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get y
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get x
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	move.l	d5,d2

	move.b	#0,colflag

	movem.l	a3/a5/a6,-(sp)
	
	tst.b	alpha_flag
	bne	true_alpha
	bsr	@truespr

	movem.l	(sp)+,a3/a5/a6

	move.l	RETURN,a0
	jmp	(a0)

true_alpha

	bsr	@truealpha
	movem.l	(sp)+,a3/a5/a6
	move.l	RETURN,a0
	jmp	(a0)


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
                cmp     xres,d3
                bgt     .plusx
                moveq   #0,d3
                move.b  1(a0),d3
                add     d2,d3
                cmp     yres,d3
                bgt     .plusy

.noclip
                mulu    xresb,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1

                move.l  6(a0),a2
                tst.l   a2
                beq     .unpacked


.packed         add.l   a3,a2
                move    (a2)+,d3
                moveq.l #0,d4
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
                move.w  xresb,d7
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
.col		bset.b	#0,colflag
                move    d6,(a1)+
                dbra    d5,.loop
                add.l   d7,a1
                dbra    d3,.loopen
                rts

.minusy         move.l  6(a0),a2
                tst.l   a2              Is it unpacked?
                bne     .exit           No!
                moveq.l #0,d3
                move.b  1(a0),d3        d3 sprite height
                add.l   d2,d3           d3 clipped sprite height
                ble     .exit           nothing visible!
                subq    #1,d3

                moveq   #0,d4
                move.b  (a0),d4
                move.l  d4,d5
		moveq.l	#0,d7
                move.w  xresb,d7
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

                sub     yres,d3
                move.l  d3,d5
                moveq   #0,d3
                move.b  1(a0),d3        d3 sprite height
                sub.l   d5,d3           d3 clipped sprite height
                ble     .exit

                mulu    xresb,d2
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
                cmp     xres,d3
                bgt     .aplusx
                moveq   #0,d3
                move.b  1(a0),d3
                add     d2,d3
                cmp     yres,d3
                bgt     .aplusy

.anoclip
                mulu    xresb,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1

                move.l  6(a0),a2
                tst.l   a2
                beq     .aunpacked


.apacked        add.l   a3,a2
                move    (a2)+,d3
                moveq.l #0,d4
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
                move.w  xresb,d7
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
		and.w	alpha_nand,d6
		move.w	d6,(a1)
		swap.w	d6
		and.w	alpha_and,d6
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
.acol		bset.b	#0,colflag
		swap.w	d6
		move.w	(a1),d6
		and.w	alpha_nand,d6
		move.w	d6,(a1)
		swap.w	d6
		and.w	alpha_and,d6
                or.w    d6,(a1)+
                dbra    d5,.aloop
                add.l   d7,a1
                dbra    d3,.aloopen
                rts

.aminusy        move.l  6(a0),a2
                tst.l   a2              Is it unpacked?
                bne     .aexit           No!
                moveq.l #0,d3
                move.b  1(a0),d3        d3 sprite height
                add.l   d2,d3           d3 clipped sprite height
                ble     .aexit           nothing visible!
                subq    #1,d3

                moveq   #0,d4
                move.b  (a0),d4
                move.l  d4,d5
		moveq.l	#0,d7
                move.w  xresb,d7
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

                sub     yres,d3
                move.l  d3,d5
                moveq   #0,d3
                move.b  1(a0),d3        d3 sprite height
                sub.l   d5,d3           d3 clipped sprite height
                ble     .aexit

                mulu    xresb,d2
                add.l   d2,a1

                add.l   d1,a1
                add.l   d1,a1
                bra     .aunp2

.aminusx         rts
.aplusx          rts

* Instruction cycles part of the 256 colour palette 1 step

cycle	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get no. of colours to cycle
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get start colour
	tst.b	d2
	bne	TYPEMIS

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

	move.l	RETURN,a0
	jmp	(a0)


* instruction initializes a virtual screen of rez x,y pixels

init_virtual
	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get y rez.
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0
	move.w	d0,yres

	movem.l	(sp)+,d2-d4	; get x rez.
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,xres
	move.w	d3,d2

	lsl.w	d2
	move.w	d2,xresb

	move.w	$ff8210,d0

	sub.w	d0,d3
	move.w	d3,$ff820e

	clr.b	$ff8265

	lea	planes,a1		***** Pass screenres data to other extensions
	move.l	#'FALC',d2
	move.l	#1,d0
	trap	#5

	move.l	RETURN,a0
	jmp	(a0)


* Instruction locates a virtual screen at X,Y on SCREEN

virtual	move.l	(sp)+,RETURN
	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get y
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0
	blt	ntdne

	movem.l	(sp)+,d2-d4	; get x
	tst.b	d2
	bne	TYPEMIS
	tst	d3
	blt	ntdne
	
	cmp	#16,planes
	bne.s	.bpvir

	lsl.l	d3
	add.l	d3,a0

	mulu	xresb,d0
	add.l	d0,a0

.viret	move.l	a0,d0
	move.l	d0,d1
	lsr.l	#8,d0
	move.b	d0,$ff8203	middle byte
	lsr.l	#8,d0
	move.b	d0,$ff8201	high byte
	move.b	d1,$ff820d	low byte

	move.l	RETURN,a0
	jmp	(a0)

.bpvir	move.w	planes,d7
	mulu	xresb,d0
	add.l	d0,a0		; a0 = addr of horiz. line		

	move.w	d3,d4
	and.w	#$f,d3		; d3 = shift value
	move.b	d3,$ff8265	hscroll

	move.w	d7,d2
	move.w	#%1000,d3
.bp16b	lsr.w	d3
	lsr.w	d2
	bne.s	.bp16b

	andi.w	#$fff0,d4
	lsr.w	d3,d4		; d4 = offset to 16-pix boundary
	
	add.w	d4,a0		; a0=addr of 16 pix boundary
	bra.s	.viret


* Instruction draws a solid bar on a TC screen, in given colour

tc_bar	move.l	(sp)+,RETURN
	cmpi	#5,d0
	bne	TYPEMIS

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get y2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	; get x2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6


	movem.l	(sp)+,d2-d4	; get y1
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5


	movem.l	(sp)+,d2-d4	; get x1
	tst.b	d2
	bne	TYPEMIS

	cmpi.w	#16,planes
	bne.s	.bpbar

	lsl.l	#1,d6

	sub.l	d5,d7
	mulu	xresb,d5
	add.l	d5,a0

	lsl.l	#1,d3
	move.l	d3,d5

	cmp	#0,d5
	bgt.s	.cl	
	move	#0,d5

.cl	sub.l	d5,d6

	move.l	ink,d3

	clr.l	d0
	move.w	xresb,d0

.ylp	move.l	a0,a1		;copy address of screen+ycoord       <--\
	add.l	d5,a1		;add x (a1=address of 1st point on line)|
	move.l	d6,d4		;save x count                           |
.xlp	move.w	d3,(a1)+	;place pixel           <-\              |
	subq.l	#2,d4		;decrement x count       |              |
	bne.s	.xlp		;loop if not finished x -/              |
	add.l	d0,a0		;add 1 line to start coord              |
	dblt	d7,.ylp		;loop if not finished y             ----/

	move.l	RETURN,a0
	jmp	(a0)

* a0=address of screen
* d7=y2
* d6=x2
* d5=y1
* d3=x1

.bpbar
	moveq.l	#0,d1
	move.w	xresb,d1
	sub.l	d5,d7
	mulu	d1,d5
	add.l	d5,a0		; a0 = addr of horiz. line		

*	sub.l	d3,d6		; d6=number horizontally, d7=number vertically
*	move.l	d6,d5		; store num. horiz. for later
*	move.l	a0,a1		; store address for later
*
*.brlp	movem.l	d1/d5-d7,-(sp)
*	move.l	ink,d5
*	move.w	planes,d7
*	bsr	.subpl
*	movem.l	(sp)+,d1/d5-d7
*	addq.b	#1,d4
*	btst	#4,d4
*	beq.s	.bndinc
*.brt	move.l	a1,a0
*	dblt	d6,.brlp
*	move.w	d5,d6
*	add.l	d1,a0
*	move.l	a0,a1
*	dblt	d7,.brlp
*
	move.l	d3,d0
	move.l	d6,d2
	move.l	d7,d3
	move.l	d0,d4		; store x for later
	move.w	planes,d7
	move.l	ink,d5

.bpbxlp	movem.l	d0-d4/a0,-(sp)
	bsr	.bp_plt
	movem.l	(sp)+,d0-d4/a0
	addq.l	#1,d0
	cmp.l	d2,d0
	ble.s	.bpbxlp
.bpsdlp	adda.l	d1,a0
	move.l	d4,d0
	dble	d3,.bpbxlp

	move.l	RETURN,a0
	jmp	(a0)

.bndinc	bclr	#4,d4
*	bra.s	.brt


.bp_plt

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

* a0=addr. 16 pix boundary
* d4=shift value
* d5=ink
* d7=planes
* corrupts d0,d1,d2,d6,a0
.subpl
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

* Instruction draws a box in true colour mode

tc_box	move.l	(sp)+,RETURN
	cmpi	#5,d0
	bne	TYPEMIS

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get y2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	; get x2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	; get y1
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get x1
	tst.b	d2
	bne	TYPEMIS

	cmpi.w	#16,planes
	bne.s	.bpbox
	lsl.l	d3

	sub.l	d5,d7
	mulu	xresb,d5
	add.l	d5,a0

	lsl.l	d6
	move.l	d3,d5
	sub.l	d5,d6

	move.l	ink,d3

	clr.l	d0
	move.w	xresb,d0
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


	move.l	RETURN,a0
	jmp	(a0)

.bpbox	move.l	d3,d0
	move.l	d5,d1
	move.l	d6,d2
	move.l	d7,d3
	move.l	d0,d4		; store x for later
	move.w	planes,d7
	move.l	ink,d5
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

	move.l	RETURN,a0
	jmp	(a0)	

* a0=screen addr. d0=x, d1=y, d5=colour, d7=number of planes
* corrupts all d-regs (except d5 and d7) and a0

.bp_plt
	mulu	xresb,d1
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

* Instruction copies a part of a true colour screen

tc_copy	move.l	(sp)+,RETURN
	cmpi	#8,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get y2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	; get x2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get scr2
	tst.b	d2
	bne	TYPEMIS

	lsl.l	d5		; calculate dest. address
	add.l	d5,d3
	mulu	xresb,d6
	add.l	d6,d3
	move.l	d3,a2		; set destination address

	movem.l	(sp)+,d2-d4	; get h
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	; get w
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,d6
	lsl.l	d3
	moveq.l	#0,d0
	move.w	xresb,d0
	sub.l	d3,d0		d0= line increment

	movem.l	(sp)+,d2-d4	; get y
	tst.b	d2
	bne	TYPEMIS
	mulu	xresb,d3
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get x
	tst.b	d2
	bne	TYPEMIS
	lsl.l	d3
	adda.l	d3,a0

	movem.l	(sp)+,d2-d4	; get source
	tst.b	d2
	bne	TYPEMIS
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

	move.l	RETURN,a0
	jmp	(a0)


* Function sets the falcon's 256 colour palette

set_fpal
	move.l	(sp)+,RETURN
	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	get no. to change
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	;get start no.
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	;get address
	tst.b	d2
	bne	TYPEMIS

	move.l	d3,-(sp)
	move.w	d6,-(sp)
	move.w	d5,-(sp)
	move.w	#93,-(sp)
	trap	#14
	add.l	#10,sp

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the Falcons 256 colour palette

get_fpal
	move.l	(sp)+,RETURN
	cmpi	#3,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	get no. to get
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	;get start no.
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	;get address
	tst.b	d2
	bne	TYPEMIS

	move.l	d3,-(sp)
	move.w	d6,-(sp)
	move.w	d5,-(sp)
	move.w	#94,-(sp)
	trap	#14
	add.l	#10,sp

	move.l	RETURN,a0
	jmp	(a0)



* Function sets screen to that defined by a .FV file

set_fv	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	bsr	@setfv

	tst	d0
	bne	ntdne

	move.w	$ff8266,d0	work out the number of colours
	btst	#8,d0
	bne.s	.fv16
	btst	#10,d0
	bne.w	.fv1
	btst	#4,d0
	bne.w	.fv8

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

.fvwid	move.w	d0,planes

	moveq.l	#0,d0
	movec	CACR,d1
	movec	d0,CACR
.zero	move.w	$ff8210,d0	; d0=number of words in a line
	tst.w	d0
	beq.s	.zero		**** For some reason, sometime=0 - Invalid!!!
	movec	d1,CACR

	move.w	d0,d1
	lsl.w	#1,d1
	move.w	d1,xresb
	move.w	planes,d0
	divu	d0,d1		
	lsl.l	#3,d1
	move.w	d1,xres		xres= (xresb)*8 / planes

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

.styrs	move.w	d0,yres

	lea	planes,a1
	move.l	#'FALC',d2
	moveq.l	#1,d0
	trap	#5

	move.l	RETURN,a0
	jmp	(a0)


* Instruction clears a Falcon screen

falc_cls
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	a0=screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

** BLiTTER version
*	move.w	xresb,d3
*	lsl.w	#1,d3
*	lea.l	$ff8a00,a1
*	clr.b	59(a1)
*	move.l	#-1,40(a1)
*	move.w	#-1,44(a1)
*	move.l	#$20002,46(a1)
*	move.w	#1,56(a1)
*	move.l	a0,50(a1)
*	move.w	d3,54(a1)
*	move.w	yres,56(a1)
*	move.b	#192,60(a1)	; GO!!	
*
* CPU version - only rez's mod 32 bytes in size.

	move.w	xresb,d0
	lsr.w	#2,d0
	mulu.w	yres,d0

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

	move.l	RETURN,a0
	jmp	(a0)


* Instruction installs Falcon mouse driver
init_mouse
	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	tst.w	mflag
	bne.s	mcont

	move.w	#$ffff,mflag

	move.w	#20,mouse_x
	move.w	#40,mouse_y
	clr.w	mbut

	lea.l	pblk,a0
	adda.l	#4,a0
	move.w	xres,(a0)+
	move.w	yres,(a0)+

	move.w	#$22,-(sp)		;Kbdvbase()
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0

	move.l	16(a0),old_mousevec
wait_drvstat:
	tst.w	36(a0)
	bne	wait_drvstat

*	move.l	#mousevec,16(a0)

	move.l	#mousevec,-(sp)
	move.l	#pblk,-(sp)
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	trap	#14
	lea	12(sp),sp	

;	move.l	$70,old_vbl_int		;install for sprite update
;	move.l	#vbl_interrupt,$70

mcont	move.l	RETURN,a0
	jmp	(a0)

pblk	dc.b	0,0,1,1
	dc.w	320,200,10,10

		dc.l	'XBRA'
		dc.l	'MOUS'
old_mousevec:	ds.l	1
mousevec:
		movem.l	d0-d2,-(sp)
		move.w	xres,d1
		move.w	yres,d2
		move.b	1(a0),d0
		ext.w	d0
		add.w	mouse_x,d0
		bge	cont_mv1
		clr.w	d0
cont_mv1:	cmp.w	d1,d0
		blt	cont_mv2
		move.w	d1,d0
		subq.w	#1,d0
cont_mv2:	move.w	d0,mouse_x
		move.b	2(a0),d0
		ext.w	d0
		add.w	mouse_y,d0
		bge	cont_mv3
		clr.w	d0
cont_mv3:	cmp.w	d2,d0
		blt	cont_mv4
		move.w	d2,d0
		subq.w	#1,d0
cont_mv4:	move.w	d0,mouse_y
		move.b	(a0),d0
		and.w	#3,d0
		move.w	d0,mbut
		movem.l	(sp)+,d0-d2
		rts


* Instruction switches off my mouse routine.

mouse_off
	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	tst.w	mflag
	beq	ntdne

;	move.l	old_vbl_int,$70		; Install for sprite update

	move.w	#$22,-(sp)		;Kbdvbase()
	trap	#14
	addq.l	#2,sp
	move.l	d0,a0

wait_drvstat2:
	tst.w	36(a0)
	bne	wait_drvstat2

	move.l	old_mousevec,16(a0)
	move.w	#0,mflag	
	
	move.l	RETURN,a0
	jmp	(a0)



* Function returns the x mouse coordinate
xmouse	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	clr.l	d2
	clr.l	d4
	clr.l	d3
	move.w	mouse_x,d3

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the y mouse coordinate
ymouse	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	clr.l	d2
	clr.l	d3
	clr.l	d4
	move.w	mouse_y,d3

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the state of the mouse buttons

mkey	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	clr.l	d2
	clr.l	d3
	clr.l	d4
	move.w	mbut,d3

	move.l	RETURN,a0
	jmp	(a0)


* Function returns whether the mouse in in the given zone
zone	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	cmpi	#128,d3
	bge	ntdne

	lsl.l	#3,d3
	lea.l	zones,a0

	move.w	0(a0,d3),d0
	move.w	2(a0,d3),d1
	move.w	4(a0,d3),d2
	move.w	6(a0,d3),d4

	move.l	#0,d3

	cmp	mouse_x,d0
	bgt	notinzone
	cmp	mouse_x,d2
	blt	notinzone

	cmp	mouse_y,d1
	bgt	notinzone
	cmp	mouse_y,d4
	blt	notinzone

	move.l	#-1,d3

notinzone
	clr.l	d2
	clr.l	d4
	move.l	RETURN,a0
	jmp	(a0)


* Instruction defines a zone
set_zone
	move.l	(sp)+,RETURN
	cmpi	#5,d0
	bne	SYNTAX

 	movem.l	(sp)+,d2-d4	; get y2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	; get x2
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	; get y1
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get x1
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get zone number
	tst.b	d2
	bne	TYPEMIS
	

	lsl.l	#3,d3
	lea.l	zones,a0

	move.w	d0,0(a0,d3)
	move.w	d1,2(a0,d3)
	move.w	d5,4(a0,d3)
	move.w	d6,6(a0,d3)

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sets the current mouse coo-rdinates
set_mouse
	move.l	(sp)+,RETURN
	cmp	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,mouse_y

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,mouse_x

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sets the current ink colour
falc_ink
	move.l	(sp)+,RETURN
	cmpi	#3,d0
	beq.s	.rgbink
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	move.l	d3,ink
	move.w	d3,txtcol

	move.l	RETURN,a0
	jmp	(a0)

.rgbink	cmp	#16,planes
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get blue
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get green
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get red
	tst.b	d2
	bne	TYPEMIS

	andi.l	#$3e,d3
	andi.l	#$3f,d1
	andi.l	#$3e,d0
	lsr.l	d0
	lsl.l	#5,d1
	lsl.l	#5,d3
	lsl.l	#5,d3

	or.l	d3,d0
	or.l	d1,d0

	move.l	d0,ink
	move.w	d0,txtcol

	move.l	RETURN,a0
	jmp	(a0)
	

* instruction sets the mode to the given ST compatible mode (on ST as well)
st_compat
	move.l	(sp)+,RETURN
	cmpi.w	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.w	d3,d5		; store for later

	move.l	$4f2,a0		; get OS version
	move.w	2(a0),d1
	cmpi.w	#$400,d1
	bge.s	.lowmed

	cmpi.w	#2,d3
	blt.s	.lowmed

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
	move.w	#640,xres
	move.w	#400,yres
	move.w	#80,xresb
	move.w	#1,planes
	bra.s	.stcmpend

.nthigh	cmpi	#1,d5
	bne.s	.low
	move.w	#640,xres
	move.w	#200,yres
	move.w	#160,xresb
	move.w	#2,planes
	bra.s	.stcmpend

.low	move.w	#320,xres
	move.w	#200,yres
	move.w	#160,xresb
	move.w	#4,planes
.stcmpend
	move.l	$4f2,a0		; get OS version
	move.w	2(a0),d1
	cmpi.w	#$400,d1
	blt.s	.st

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,videomodes

	lea	planes,a1
	move.l	#'FALC',d2
	moveq.l	#1,d0
	trap	#5

.st	move.l	RETURN,a0
	jmp	(a0)


* Function returns the Cache status

cache	move.l	(sp)+,RETURN
	tst	d0
	bne	SYNTAX

	movec	CACR,d3
	clr.l	d2
	clr.l	d4
	movem.l	d2-d4,-(sp)

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sets the cache

set_cache
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	movec	d3,CACR

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the xres
xres_fun
	move.l	(sp)+,RETURN

	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	xres,d3

	move.l	RETURN,a0
	jmp	(a0)


* Function returns the yres
yres_fun
	move.l	(sp)+,RETURN

	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	yres,d3

	move.l	RETURN,a0
	jmp	(a0)

* Function returns the xres
planes_fun
	move.l	(sp)+,RETURN

	moveq.l	#0,d2
	moveq.l	#0,d3
	move.w	planes,d3

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sets the the given colour int the 256 colour palette
falc_colour
	move.l	(sp)+,RETURN
	cmpi	#4,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	get Blue
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	get Green
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

 	movem.l	(sp)+,d2-d4	get Red
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d5

	movem.l	(sp)+,d2-d4	get index
	tst.b	d2
	bne	TYPEMIS

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

	move.l	RETURN,a0
	jmp	(a0)

* Function returns the width in pixels of a .TGA file

tga_width
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	move.w	12(a0),d3
	move.w	d3,d2
	andi.l	#$ff00,d3
	andi.l	#$ff,d2
	lsl.l	#8,d2
	lsr.l	#8,d3
	or.w	d2,d3

	clr.l	d2
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)



* Function returns the height in pixels of a .TGA file

tga_height
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	move.w	14(a0),d3
	move.w	d3,d2
	andi.l	#$ff00,d3
	andi.w	#$ff,d2
	lsl.l	#8,d2
	lsr.l	#8,d3
	or.w	d2,d3

	clr.l	d2
	clr.l	d4

	move.l	RETURN,a0
	jmp	(a0)

* Instruction decodes a .TGA file into screen-format

tga_decode
	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get screen address
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a1

	movem.l	(sp)+,d2-d4	; get TGA address
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

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
	tst.b	d4
	adda.l	d4,a1
	dbra	d3,.tglp
	suba.l	d4,a1
	adda.l	d5,a1
	move.l	d7,d3
	dbra	d6,.tglp

	move.l	RETURN,a0
	jmp	(a0)

tgaplns
	cmpi.b	#15,d5
	bne.s	.nttg15
	lea	tga15,a2	
	rts
.nttg15	cmpi.b	#16,d5
	bne.s	.nttg16
	lea	tga16,a2
	rts
.nttg16	cmpi.b	#24,d5
	bne.s	.nttg24
	lea	tga24,a2
	rts
.nttg24	cmpi.b	#32,d5
	bne	ntdne
	lea	tga32,a2
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

tga_encode
	move.l	(sp)+,RETURN
	cmpi	#4,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get height
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	; get width
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	; get dest.
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a1

	movem.l	(sp)+,d2-d4	; Get source
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

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

	move.l	RETURN,a0
	jmp	(a0)


* Function returns whether or not a collision occured in the last sprite plot
tc_collide
	move.l	(sp)+,RETURN
	tst	d0
	bne	TYPEMIS

	moveq.l	#0,d2
	moveq.l	#0,d3
	move.b	colflag,d3

	move.l	RETURN,a0
	jmp	(a0)

* Instruction prints a line of text on a true colour screen

* Parameters - SCREEN,x,y,string

tc_text	move.l	(sp)+,RETURN
	cmpi	#4,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	; get string (STOS format)
	cmpi.b	#$80,d2
	bne	TYPEMIS
	move.l	d3,a0

	movem.l	(sp)+,d2-d4	; get y
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	; get x
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	; get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a2

	movem.l	a3/a5,-(sp)

	tst.w	(a0)
	beq	txtend

	clr.l	d3
	move.w	xresb,d3
	move.l	d3,xresbl

	move.l	gfont,a1

* a2=screen address
* a1=gfont address
* a0=string (STOS)
* d7=y
* d6=x

	move.l	d7,d0			m=physbase()+(y-font.top+font.bottom)*_scrwid+x
*	sub.w	40(a1),d0
*	add.w	48(a1),d0
	mulu.w	xresb,d0
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
	move.w	txtcol,(a5)		line[j]=_textcol
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

txtend	movem.l	(sp)+,a3/a5

	move.l	RETURN,a0
	jmp	(a0)


xresbl	ds.w	1

* Instruction displays the parameters of all of the instructions.
falc_help
	move.l	(sp)+,RETURN
	tst.b	d0
	bne	SYNTAX

	lea.l	help,a0
	move.l	#1,d7
	trap	#3

	lea.l	cont,a0
	move.l	#1,d7
	trap	#3

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	lea.l	help2,a0
	move.l	#1,d7
	trap	#3

	lea.l	cont,a0
	move.l	#1,d7
	trap	#3

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	lea.l	help3,a0
	move.l	#1,d7
	trap	#3

	lea.l	cont,a0
	move.l	#1,d7
	trap	#3

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	lea.l	help4,a0
	move.l	#1,d7
	trap	#3

	lea.l	cont,a0
	move.l	#1,d7
	trap	#3

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	lea.l	help5,a0
	move.l	#1,d7
	trap	#3

	move.l	RETURN,a0
	jmp	(a0)

* Instruction draws a line on screen
falc_draw
	move.l	(sp)+,RETURN
	cmpi	#5,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	get y1
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d7

	movem.l	(sp)+,d2-d4	get x1
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d6

	movem.l	(sp)+,d2-d4	get y0
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d1

	movem.l	(sp)+,d2-d4	get x0
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,d0

	movem.l	(sp)+,d2-d4	get screen
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

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

	move.l	RETURN,a0
	jmp	(a0)


.vert
*	cmp	d1,d7
*	blt	.noswtchv
*
*	move.l	d7,d2		switch vertical entries
*	move.l	d1,d7
*	move.l	d2,d1

.noswtchv
	moveq.l	#0,d2
	move.w	xresb,d2

	move.l	ink,d4

	move.l	d2,d3
	mulu	d1,d3
	add.l	d3,a0
	add.l	d0,a0
	add.l	d0,a0		calculate start of line

	sub.l	d1,d7
.vlp	move.w	d4,(a0)
	add.l	d2,a0
	dbra	d7,.vlp

	move.l	RETURN,a0
	jmp	(a0)

.horiz	mulu	xresb,d1
	add.l	d1,a0
	add.l	d0,a0
	add.l	d0,a0		calculate start of line

	move.l	ink,d4

	sub.l	d0,d6
.hlp	move.w	d4,(a0)+
	dbra	d6,.hlp

	move.l	RETURN,a0
	jmp	(a0)


* GDOS font - sets address of the font used for tc text
gdos_font
	move.l	(sp)+,RETURN
	cmpi	#2,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0
*	bne.s	.gdsnm
*
*	move.l	gfont,a0
	
.gdsnm	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

.fntlp	subq.b	#1,d3
	blt.s	.gotit

	move.l	84(a0),a0

	bra.s	.fntlp
.gotit
	move.l	a0,gfont

	move.l	RETURN,a0
	jmp	(a0)


* Instruction sends the help screen to the printer....

lfalc_help
	move.l	(sp)+,RETURN
	tst.b	d0
	bne	SYNTAX

	lea.l	help,a6
	bsr	prnt

	lea.l	help2,a6
	bsr	prnt

	lea.l	help3,a6	
	bsr	prnt

	lea.l	help4,a6
	bsr	prnt

	lea.l	help5,a6
	bsr	prnt

	move.l	RETURN,a0
	jmp	(a0)

prnt	move.w	#0,-(sp)
	move.w	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	tst.w	d0
	beq	ntdne

.nxtchr	move.b	(a6)+,d2
	beq.s	.dne
	ext.w	d2

	move.w	d2,-(sp)
	move.w	#0,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	bra.s	.nxtchr
.dne	rts



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
* Intel -> Motorola format conversion macros

motoold	macro	intel		* intel -> motorola convertion macro
	move.w	\1,d4		* uses d4. Result stored in given dreg
	andi.w	#$ff00,\1
	andi.w	#$ff,d4
	lsr.w	#8,\1
	lsl.w	#8,d4
	or.w	d4,\1
	endm

moto	macro	intel		* Bloody obvious!!! Why did I not think of
	ror.w	#8,\1		* this before...
	endm


* FLI Frame - function simply returns the next frame...
fli_frame
	move.l	(sp)+,RETURN

	clr.l	d2
	clr.l	d3
	clr.l	d4
	move.w	FLI_frm_cnt,d3

	move.l	RETURN,a0
	jmp	(a0)


* Instruction initialises the FLI player routine
FLI_init
	move.l	(sp)+,RETURN
	cmp.b	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	* FLI address
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	cmpi.w	#_hd_magic_val,_hd_magic(a0)
	beq	.itsfli

	cmpi.w	#_hd_magic_FLC,_hd_magic(a0)
	bne	ntdne
	
.itsfli	move.w	_hd_frames(a0),d0
	moto	d0
	move.w	d0,FLI_lst_frm
	move.w	#1,FLI_frm_cnt

	add.l	#_hd_length,a0
	move.l	a0,FLI_frm_addr
	move.l	a0,FLI_frst_frm

	move.l	RETURN,a0
	jmp	(a0)

	

* Instruction displays the next frame of an FLI animation
FLI_do_frame
	move.l	(sp)+,RETURN
	cmpi.b	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4	* get screen address
	tst.b	d2
	bne	TYPEMIS
	move.l	d3,a0

	move.l	FLI_frm_addr,a1
	move.l	#FLI_pal,a2
	
	move.w	FLI_lst_frm,d3
	cmp.w	FLI_frm_cnt,d3
	bne.s	.ntlst

	move.l	FLI_frst_frm,a1
	move.w	#0,FLI_frm_cnt

.ntlst	add.w	#1,FLI_frm_cnt
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
	move.l	a4,FLI_frm_addr

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
	move.l	RETURN,a0
	jmp	(a0)



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

	move.l	RETURN,a0
	jmp	(a0)


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

	move.l	RETURN,a0
	jmp	(a0)



* handle a 'Line Compressed data' chunk
do_cmp_line
		add.l	#_chk_length,a1

                move.l  #320,D6       ; Fli_Widht
                move.l  #200,D7       ; Fli_Height
                move.w  xresb,D5       ; Scr_Width

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

	move.l	RETURN,a0
	jmp	(a0)



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

	move.l	RETURN,a0
	jmp	(a0)


* handle a BRUN Bytewise RLE compressed chunk
do_cmp_scr
		add.l	#_chk_length,a1

                move.l  #320,D6       ; Fli_Widht
                move.w  #200,D7       ; Fli_Height
		moveq.l	#0,d5
                move.w  xresb,D5       ; Scr_Width

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

	move.l	RETURN,a0
	jmp	(a0)



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

	move.l	RETURN,a0
	jmp	(a0)

* handle an compressed line type 2 chunk
do_cmp_line2
	addq.l	#_chk_length,a1
	movem.l	d0-d4,-(sp)

		move.w  #320,D6       ; Fli_Widht
                move.w  #200,D7       ; Fli_Height
		moveq.l	#0,d5
                move.w  xresb,D5       ; Scr_Width

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
;               move.w  (0,A2,D0.w*2),(A0)+ ; Pixel setzen
                DC.W $30F2,$0200        ; 68020-Code

                move.b  (A1)+,D0        ; HighByte holen
;               move.w  (0,A2,D0.w*2),(A0)+ ; Pixel setzen
                DC.W $30F2,$0200        ; 68020-Code

                dbra    D2,fli_lc2_copy ; NEXT i
                bra.s   fli_lc2_endif

fli_lc2_else:   neg.b   D2              ; 256-Packet_Type
                subq.w  #1,D2           ; wegen DBRA

                moveq   #0,D0
                moveq   #0,D1
                move.b  (A1)+,D1        ; HighPixel

;               move.w  (0,A2,D1.w*2),D0 ; HighPixel holen
                DC.W $3032,$1200        ; 68020-Code
                swap    D0              ; ins obere Wort damit

                move.b  (A1)+,D0        ; LowPixel
;               move.w  (0,A2,D0.w*2),D0 ; LowPixel holen
                DC.W $3032,$0200        ; 68020-Code

fli_lc2_brun:   move.l  D0,(A0)+        ; LowPixel/HighPixel schreiben
                dbra    D2,fli_lc2_brun ; NEXT i

fli_lc2_nop:
fli_lc2_endif:  dbra    D3,fli_lc2_packetlp ; NEXT p

fli_lc2_nopacket:move.l A4,D0           ; Last_Byte holen
                tst.b   D0
                beq.s   fli_lc2_nolast  ; Last Byte vorhanden?
                swap    D0              ; Farbindex holen
;               move.w  (0,A2,D0.w*2),(A0)+ ; Pixel setzen
                DC.W $30F2,$0200        ; 68020-Code

fli_lc2_nolast: lea     0(A3,D5.w),A0   ; Frame=Old_Frame+Scr_Width

                dbra    D4,fli_lc2_line_lp ; NEXT line_no

fli_lc2_ende
	movem.l	(sp)+,d0-d4
	dbra	d1,dochnk

* Finished frame...

	move.l	RETURN,a0
	jmp	(a0)




* Intstruction sets the mask for alpha channelling
TC_alpha
	move.l	(sp)+,RETURN
	cmpi	#1,d0
	bne	SYNTAX

	movem.l	(sp)+,d2-d4
	tst.b	d2
	bne	TYPEMIS

	cmpi.w	#$ffff,d3
	beq.s	.noalpha

	move.b	#-1,alpha_flag
	move.w	d3,alpha_and
	not.w	d3
	move.w	d3,alpha_nand

	move.l	RETURN,a0
	jmp	(a0)

.noalpha
	move.b	#0,alpha_flag
	move.w	#-1,alpha_and
	move.w	#-1,alpha_nand
	
	move.l	RETURN,a0
	jmp	(a0)


***************************************************
* Help data

cont	dc.b	13,10,'Press any key to continue...',13,10,0

help	dc.b	'Displayed below is the syntax of each command contained in the Falcon Extension.',13,10
	dc.b	'General:',13,10
	dc.b	'X=cache',13,10
	dc.b	'X=cookie(ID$)',13,10
	dc.b	'X=jagpad(PORT)',13,10
	dc.b	'X=monitor',13,10
      	dc.b	'X=os version',13,10
      	dc.b	'set cache VAL',13,10,13,10
    	dc.b	'Graphics:',13,10
	dc.b	'cycle INDEX,COUNT',13,10
      	dc.b	'df video N,H,S,O,P,V,8,C',13,10
	dc.b	'falc bar X1,Y1,X2,Y2,SCRN',13,10
	dc.b	'falc box X1,Y1,X2,Y2,SCRN',13,10
	dc.b	'falc cls SCRN',13,10
	dc.b	'falc colour INDEX,RED,GREEN,BLUE',13,10
	dc.b	'falc draw SCRN,X1,Y1,X2,Y2',13,10
	dc.b	'falc ink INDEX',13,10
	dc.b	'X=falc mkey',13,10,0
help2	dc.b	'falc mouse off',13,10
	dc.b	'falc mouse on',13,10
	dc.b	'falc plot SCREEN,X,Y',13,10
	dc.b	'falc set mouse X,Y',13,10
	dc.b	'falc set zone N,X1,Y1,X2,Y2',13,10
	dc.b	'X=falc x mouse',13,10
	dc.b	'Y=falc y mouse',13,10
	dc.b	'X=falc zone(NUMBER)',13,10
	dc.b	'fpal ADR,INDEX,COUNT',13,10
	dc.b	'fli do frame SCREEN',13,10
	dc.b	'X=fli frame FLI_ADDR',13,10
	dc.b	'fli init FLI_ADDR',13,10
	dc.b	'gdos font N,ADDR',13,10
	dc.b	'goraud SCR,COL,X1,Y1,I1,X2,Y2,I2,X3,Y3,I3',13,10
	dc.b	'init goraud',13,10
	dc.b	'init virtual XRES,YRES',13,10
	dc.b	'P=planes',13,10
 	dc.b	'X=quick fade(COLOUR)',13,10
	dc.b	'X=scrsize(MODE)',13,10
	dc.b	'set fpal ADDR,INDEX,COUNT',13,10,0
help3	dc.b	'set fv ADDRESS',13,10
	dc.b	'set video MODE',13,10
	dc.b	'st compat MODE',13,10
	dc.b	'tc alpha MASK',13,10
	dc.b	'tc copy SCR1,X,Y,W,H,SCR2,X2,Y2',13,10
	dc.b	'X=tc fade(LENGTH,ADDRESS)',13,10
	dc.b	'X=tc point(SCRN,X,Y)',13,10
	dc.b	'tc scrn fade SCRN1,SCRN2,LENGTH',13,10
	dc.b	'tc sprite X,Y,N,SCRN,SPR',13,10
	dc.b	'tc text SCRN,X,Y,TEXT$',13,10
	dc.b	'tga decode SOURCE,DEST',13,10
	dc.b	'tga encode SOURCE,DEST,WIDTH,HEIGHT',13,10
	dc.b	'X=tga height(ADDR)',13,10
	dc.b	'X=tga width(ADDR)',13,10
	dc.b	'virtual X,Y,SCRN',13,10,13,10
	dc.b	'X=xres',13,10
	dc.b	'Y=yres',13,10
	dc.b	'Sound:',13,10
	dc.b	'dsp clear',13,10
	dc.b	'dsp play MOD',13,10
help4	dc.b	'dsp process FILE$,BUFFER,MODE',13,10,0
	dc.b	'dsp stop',13,10
	dc.b	'X$=dtm inst(NUMBER,ADDR)',13,10
	dc.b	'X$=dtm name(ADDR)',13,10
	dc.b	'dtm play DTMADDR,LENGTH',13,10
	dc.b	'dtm stop',13,10
	dc.b	'X=dtm voices(ADDR)',13,10
	dc.b	'falc freq VALUE',13,10
	dc.b	'falc mic thru',13,10
	dc.b	'falc sammde MODE',13,10
	dc.b	'falc sam play START,END,LOOP',13,10
	dc.b	'falc sample START,END',13,10
	dc.b	'X=falc sampos(MODE)',13,10
	dc.b	'falc samstop',13,10
	dc.b	'set gain LEFT,RIGHT',13,10
	dc.b	'X=lgain',13,10
	dc.b	'X=rgain',13,10
	dc.b	'set volume LEFT,RIGHT',13,10
	dc.b	'X=lvolume',13,10
	dc.b	'X=rvolume',13,10
help5	dc.b	'speaker on',13,10,0
	dc.b	'speaker off',13,10
	dc.b	'X$=tracker inst(NUMBER,ADDR)',13,10
	dc.b	'X$=tracker name(ADDR)',13,10
	dc.b	0

***********************************
* General stuff (error messages etc)

dummy	move.l	(sp)+,RETURN
	bra	SYNTAX

		
SYNTAX	moveq	#12,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

TYPEMIS	moveq	#19,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

ILLEGAL	moveq	#82,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

ntdne	moveq	#0,d0
	move.l	SYSTEM,a0
	move.l	$14(a0),a0
	jsr	(a0)

@setfv		cmp.l	#'FVD2',(a0)+	4 bytes header
		bne	.error
		
.ready		addq.l	#2,a0
		move.l	$70,-(sp)
		move	sr,-(sp)
		move.l	#.vbl,$70
		move	#$2300,sr
		
		move.l	$466,d0
.wait		cmp.l	$466,d0
		beq	.wait
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne	.loop1
		move.l	#$ff82a2,a1	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne	.loop2
		move	(a0)+,$ff82c2	video control
		move	(a0)+,$ff82c0	video clock
		addq.l	#1,a0
		move.b	(a0)+,$ff820a	video sync mode

		move.l	$466,d0
.wt		cmp.l	$466,d0
		beq	.wt

		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		rts
.error		moveq	#-1,d0
		rts
.wrongmon	moveq	#-2,d0
		rts
.sm124		cmp.b	#0,(a0)
		bne	.wrongmon
		bra	.ready
.vga		cmp.b	#2,(a0)
		bne	.wrongmon
		bra	.ready
.vbl		addq.l	#1,$466
		rte
		

@savefv		lea	FVbuffer1298,a1
		move.l	#'FVD2',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	.loop2
		move	$ff82c2,(a1)+	video control
		move	$ff82c0,(a1)+	video clock
		move.b	$ff8260,(a1)+	shifter resolution
		move.b	$ff820a,(a1)+	video sync mode
		rts
		
@restorefv	move.l	#FVbuffer1298,a0
		bsr	@setfv
		rts


FVbuffer1298	ds.w	24


	include 'goraud.s'

even

 TEXT

c1numpad	ds.l	1
c2numpad	ds.l	1	
	
new_crds	ds.w	9
videomodes	ds.w	10
planes		ds.w	1
xresb		ds.w	1
xres		ds.w	1
yres		ds.w	1
mouse_x		ds.w	1
mouse_y		ds.w	1
mbut		ds.w	1
mvec		ds.l	1
mflag		dc.w	0
zones		ds.w	512 
ink		ds.l	1
colflag		ds.b	1
txtcol		ds.w	1
gfont		dc.l	$e4b6c8

FLI_pal		ds.w	256
FLI_frm_addr	ds.l	1
FLI_frst_frm	ds.l	1
FLI_frm_cnt	ds.w	1
FLI_lst_frm	ds.w	1

alpha_and	ds.w	1
alpha_nand	ds.w	1
alpha_flag	dc.b	0

**************************************************
*
* End of code

	dc.l	0
END


