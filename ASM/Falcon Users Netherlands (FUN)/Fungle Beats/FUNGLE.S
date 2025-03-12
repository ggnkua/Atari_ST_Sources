******** ASM OPTIONS AND PATHS ********

	COMMENT HEAD=%111
	OPT	D-

******** GLOBAL MACROS *********

LONGEVEN	MACRO
.adr:
	IFD	.adr/4*4
	DS.W	1
	ENDC
	ENDM

******** INCLUDES ********

	bra	START

	INCLUDE	MKSIN3.I
	TEXT
	INCLUDE	IO.S
	TEXT

******** GLOBAL EQUS ********

scrxbytes	equ	640
scrxbytes4b	equ	160
scrlines	equ	200
maxscrsize	equ	scrxbytes*scrlines

******** INITIALISING ********

START:	move.l	4(sp),a5		* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$1000,d0
	add.l	#$100,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1		* even address
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
* mxalloc - Reserve stram ONLY for screens.
	move.w	#0,-(sp)
	move.l	#maxscrsize*3+256,-(sp)	* size of screens..
	move.w	#$44,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0			* Check if there is ST-RAM enough.
	bgt.s	.ramok
* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1
* Initialize screenaddresses..
.ramok	lea	scr,a0
	addq.l	#4,d0				* / long even
	andi.b	#%11111100,d0			* \ address..
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
	addi.l	#maxscrsize,d0
	move.l	d0,(a0)+
* Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp
	move.l	#ustk,sp			* Install own stack..
* Save old screenaddress..
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldscr
* Falcon check..
	move.l	$5a0.w,a0
	tst.l	a0
	beq	E_EXIT
.fndmch	cmpi.l	#"_MCH",(a0)
	beq.s	.found
	addq	#8,a0
	bra.s	.fndmch
.found	cmpi.w	#3,4(a0)
	bne	E_EXIT
* Centurbo check..
	move.l	$05a0.w,a0
.fndct2:
	move.l	(a0),d0
	beq.s	.noct2
	cmpi.l	#"_CT2",d0
	beq.s	.ct2found
	addq	#8,a0
	bra.s	.fndct2
.noct2:	clr.w	centurbofound
	bra.w	.endct2check
.ct2found:
	move.w	#1,centurbofound
.endct2check:
* Save falcon-pallette..
	bsr	SAVE_FALCPAL
* Save resolution..
	bsr	SAVE_FV
* Install own vbl-routine..
	move	#$2700,sr
	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w
	move.l	$118.w,old118
	move.l	#NEW118,$118.w
	move	#$2300,sr

	move.l	$4ba.w,starttime

	not.l	$ffff9800.w

hush	cmpi.b	#$39,$fffffc02.w
	beq	OUT
	move.l	actpartadr,a0
	tst.l	a0
	beq.s	.do
	move.l	(a0),a1
	jsr	(a1)
.do	bsr	DO_DEMOEVENTS
	bra.s	hush

******** MAIN LOOP ********

intropic_tbl:
	DC.L	INTROMAINLOOP
	DC.L	INIT_INTRO
	DC.L	DEINIT_MOD

INIT_INTRO:
	moveq	#1,d0
	lea	fungle_mod,a0
	bsr	PLAY_MODULE

	move.l	scr+8,d0
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w

	move.l	$466.w,d0
.466lop	cmp.l	$466.w,d0
	beq.s	.466lop
	lea	r322485_fv,a0
	bsr	CHANGE_FVFAST

	lea	fun_pic+2,a1
	bsr	SET_2FALCPAL

	lea	fun_pic+514,a1
	move.l	scr,a0
	move.w	#320*240/32-1,d7
.loop	movem.l	(a1)+,d0-d6/a2
	movem.l	d0-d6/a2,(a0)
	lea	32(a0),a0
	dbra	d7,.loop

	move.l	scr,d0
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

DEINIT_MOD:
	moveq	#0,d0
	bsr	PLAY_MODULE
	rts

INTROMAINLOOP:

	rts

	DATA

fun_pic:
	INCBIN	BONUS1.PI8

	TEXT

bumppic_tbl:
	DC.L	BUMPPICMAINLOOP
	DC.L	INIT_BUMPPICFX
	DC.L	SET_BUMPPICFUN
	DC.L	SET_BUMPPICBEATS
	DC.L	SET_BUMPPICRES
	DC.L	START_BUMPPIC

BUMPPICMAINLOOP:
	move.l	zoomstarttime,d0
	sub.l	$4ba.w,d0
	andi.l	#$000000ff,d0
	movea.l	pbumproutadr,a0
	jsr	(a0)
	move.l	d0,d1
	bsr	PLOT_FUNZOOM

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

INIT_BUMPPICFX:
	rts

SET_BUMPPICFUN:
	move.l	#CALC_BUMPFUN,pbumproutadr
	rts

SET_BUMPPICBEATS:
	move.l	#CALC_BUMPBEATS,pbumproutadr
	rts

CALC_BUMPFUN:
	subi.w	#10,d0				* For "FUN" and "gle"
	lea	funglebeats_pic+1280*64+640,a1	* Center of "FUN"
	rts

CALC_BUMPBEATS:
	subi.w	#10,d0				* For "BEATS"
	lea	funglebeats_pic+1280*183+640,a1	* Center of "BEATS"
	rts

SET_BUMPPICRES:
	move.l	$466.w,d0
.466lop	cmp.l	$466.w,d0
	beq.s	.466lop
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

START_BUMPPIC
	move.l	$4ba.w,d0
	subq.l	#1,d0
	move.l	d0,zoomstarttime
	rts

	DATA

zoomstarttime:
	DC.L	0
pbumproutadr:
	DC.L	CALC_BUMPFUN
funglebeats_pic:
	INCBIN	FUNGLEBD.RAW

	TEXT

kub16_tbl:
	DC.L	KUBMAINLOOP
	DC.L	RESET_KUB16
	DC.L	MOVE_KUB16FORWARD
	DC.L	STOP_KUB16
	DC.L	ADD_KUB16LOGOS
	DC.L	BUMP_KUB16FWD
	DC.L	BUMP_KUB16BCK
	DC.L	SET_KUB16RES
	
KUBMAINLOOP:
	tst.w	dologos
	beq.s	.clr
	bsr	FADEIN_FUNLOGOS
	bsr	ADD_LOGOSTOMESH

.clr	move.l	scr,a0
	bsr	CLEAR_32204BSCREEN

	lea	kubus_rot,a2
	addq.w	#8,(a2)
	subi.w	#11,2(a2)
	lea	kubus_ini,a1
	bsr	ROTATE_PIECE
	moveq	#0,d0
	moveq	#0,d1
	lea	funkubz,a0
	move.w	(a0),d2
	tst.w	domove
	beq.s	.skpadd
	addi.w	#10,d2
	move.w	d2,(a0)
.skpadd	bsr	POSITION_PIECE
	bsr	PERSPECTIVATE_PIECE
	bsr	ADD_TO_POLYMESH
	bsr	ZSORT_POLYMESH
	bsr	PLOT_POLYMESH

	move.w	$468.w,d0
.tst466	cmp.w	$468.w,d0
	beq.s	.tst466

	lea	$ffff9800.w,a0
	lea	funlogos_pal,a1
	REPT	7
	move.l	(a1)+,(a0)+
	ENDR
	addq	#8,a1
	addq	#8,a0
	REPT	6
	move.l	(a1)+,(a0)+
	ENDR

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

RESET_KUB16
	bsr	INIT_FUNLOGOS
	lea	$ffff9800.w,a0
	clr.l	7*4(a0)
	clr.l	8*4(a0)
	clr.l	15*4(a0)
	move.w	#-1530,funkubz
	moveq	#0,d0
	move.w	d0,domove
	move.w	d0,dologos
	rts

MOVE_KUB16FORWARD
	move.w	#1,domove
	rts

ADD_KUB16LOGOS
	move.w	#1,dologos
	rts

STOP_KUB16
	clr.w	domove
	rts

BUMP_KUB16FWD
	addi.w	#40,funkubz
	rts

BUMP_KUB16BCK
	subi.w	#40,funkubz
	rts

SET_KUB16RES
	movea.l	scr,a0
	bsr	CLEAR_32204BSCREEN
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w

	movea.l	scr,a0
	bsr	CLEAR_32204BSCREEN
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w

	movea.l	scr,a0
	bsr	CLEAR_32204BSCREEN

	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	$ffff9800.w,a0
	moveq	#0,d0
	REPT	16
	move.l	d0,(a0)+
	ENDR
	lea	r322045_fv,a0
	bsr	CHANGE_FVFAST
	rts

	DATA

funlogos_pi1
	INCBIN	FUN_BIG2.PI1

logos3d_pos
	DC.W	0,0,170
	DC.W	161,0,53
	DC.W	100,0,-138
	DC.W	-100,0,-138
	DC.W	-162,0,53

kubus_ini
	DC.W	8
	DC.W	-90,-90,-90
	DC.W	90,-90,-90
	DC.W	90,90,-90
	DC.W	-90,90,-90
	DC.W	-90,-90,90
	DC.W	90,-90,90
	DC.W	90,90,90
	DC.W	-90,90,90

	DC.W	6
	DC.W	1,4,1
	DC.W	0,1,2,3
	DC.W	1,4,2
	DC.W	0,4,5,1
	DC.W	1,4,0
	DC.W	6,2,1,5
	DC.W	1,4,2
	DC.W	3,2,6,7
	DC.W	1,4,0
	DC.W	0,3,7,4
	DC.W	1,4,1
	DC.W	7,6,5,4

	BSS

* funkube shit
*rotation crap
roty	ds.w	1
fasex	ds.w	1
domove	ds.w	1
dologos	ds.w	1

*position of logos
bonus_pos
	ds.w	3
wingleader_pos
	ds.w	3
thematch_pos
	ds.w	3
otm_pos	ds.w	3
earx_pos
	ds.w	3

*logo-buffers
bonus_spr
	ds.w	6*16
	ds.w	24*16
wingleader_spr
	ds.w	6*16
	ds.w	24*16
thematch_spr
	ds.w	6*16
	ds.w	24*16
otm_spr	ds.w	6*16
	ds.w	24*16
earx_spr
	ds.w	6*16
	ds.w	24*16

funlogos_pal
	ds.l	16

kubus_rot
	ds.w	2
funkubz	ds.w	1

	TEXT

firefx_tbl
	DC.L	FIREMAINLOOP
	DC.L	INIT_FIRE
	DC.L	BLAST_FIRE
	DC.L	SET_FIRECNTMODE
	DC.L	SET_FIRETRIGMODE
	DC.L	PUT_FIREFUN
	DC.L	PUT_FIREGLE
	DC.L	PUT_FIREBEATS

FIREMAINLOOP
	bsr	PLOT_FIRECIRC

	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

INIT_FIRE
	move.l	scr,a0
	bsr	CLEAR_3210TSCREEN
	move.l	scr+4,a0
	bsr	CLEAR_3210TSCREEN
	move.l	scr+8,a0
	bsr	CLEAR_3210TSCREEN

	move.l	$466.w,d0
.466lop	cmp.l	$466.w,d0
	beq.s	.466lop
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST

	move.w	$466.w,d0
	swap	d0
	move.w	$4ba.w,d0
	move.l	d0,random

	bsr	INIT_FIRECIRC
	lea	flowtable,a1
	lea	truepal,a0
	bsr	MAKE_COLORFLOW
	rts

BLAST_FIRE
	lea	firebuf+(160*(firelines-3)),a1
	bsr	ADD_FIRELAYER
	lea	firebuf+(160*(firelines-2)),a1
	bsr	ADD_FIRELAYER
	lea	firebuf+(160*(firelines-1)),a1
	bsr	ADD_FIRELAYER
	lea	firebuf+(160*(firelines-0)),a1
	bsr	ADD_FIRELAYER
	rts

SET_FIRECNTMODE
	move.w	#1,firefxtrig
	rts

SET_FIRETRIGMODE
	clr.w	firefxtrig
	rts

PUT_FIREFUN
	lea	firebuf+((firelines-32)*160)+32,a0
	lea	firebitmap_pic,a1
	moveq	#32-1,d7

.yloop	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-a6/a2-a6,(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,48(a0)
	lea	160(a0),a0
	lea	320-64(a1),a1
	dbra	d7,.yloop
	rts

PUT_FIREGLE
	lea	firebuf+((firelines-32)*160)+98,a0
	lea	firebitmap_pic+66,a1
	moveq	#32-1,d7

.yloop	movem.l	(a1)+,d0-d6/a2
	movem.l	d0-a6/a2,(a0)
	lea	160(a0),a0
	lea	320-32(a1),a1
	dbra	d7,.yloop
	rts

PUT_FIREBEATS
	lea	firebuf+((firelines-32)*160),a0
	lea	firebitmap_pic+102,a1
	moveq	#32-1,d7

.yloop	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-a6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,144(a0)
	lea	160(a0),a0
	lea	320-160(a1),a1
	dbra	d7,.yloop
	rts

	DATA

flowtable
	DC.W	16
	DC.W	4
	DC.L	$00000000	;DC.L	$00000000
	DC.L	$3f000000	;DC.L	$003f0000
	DC.L	$7f000000	;DC.L	$007f0000
	DC.L	$ff1f0000	;DC.L	$3fdf0000
	DC.L	$ff3f0000	;DC.L	$7fff0000
	DC.L	$ff7f0000	;DC.L	$dfff0000
	DC.L	$ffbf0000	;DC.L	$ffff0000
	DC.L	$ffff0000	;DC.L	$ffff003f
	DC.L	$ffff0000	;DC.L	$ffff007f
	DC.L	$ffff003f	;DC.L	$ffff00bf
	DC.L	$ffff007f	;DC.L	$ffff00ff
	DC.L	$ffff00bf	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff
	DC.L	$ffff00ff	;DC.L	$ffff00ff

firefxtrig
	DC.W	0				* 0=triggermode, 1=continuous

;	DS.W	1				* Put on long edge!!
	LONGEVEN
firebitmap_pic
	INCBIN	FUNGFIRE.PC8
	EVEN

	BSS

;	DS.W	1				* Put on long edge!!
	LONGEVEN
realpal	DS.W	256
fire_pal
	DS.L	256*2*256			* Optimised lookup table!
truepal	DS.L	256+1
firebuf	DS.B	160*100				* put on LONG EDGE for optimal results!

	TEXT

blobradi	equ	54
blobrad		equ	50/4*4
numblobs	equ	4

blobfx_tbl:
	DC.L	BLOBMAINLOOP
	DC.L	INIT_SCALBLOB
	DC.L	INVERT_BLOBMOVEMENT
	DC.L	SET_SCALBLOBRES

BLOBMAINLOOP:
	move.w	strblobinv,d1
	bsr	CALC_BLOBTRAJECTS
	bsr	PLOT_SLOW4BLOBS

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

INIT_SCALBLOB:
	bsr	INIT_SHADETAB
	bsr	PRECALC_BLOBBUFFERS

	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

INVERT_BLOBMOVEMENT:
	lea	strblobinv,a0
	move.w	(a0),d0
	bchg	#0,d0
	move.w	d0,(a0)
	rts

SET_SCALBLOBRES:
	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

	DATA

strblobinv:
	DC.W	0

	BSS

*blob shit!
colorflow_tbl:
	ds.w	65536
blobpos_tbl:
	ds.w	2*20			x,y
blob_pic:
	ds.w	54*2*54*2
blobdens_tbl:
	ds.w	54*2*54*2

	ds.w	320*100			;ds.w	320*200
blobbasin_buf:
	ds.w	320*100			;ds.w	320*200
	ds.w	320*100			;ds.w	320*200

	TEXT

wire50_tbl:
	DC.L	WIRE50MAINLOOP
	DC.L	INIT_WIRE50
	DC.L	MOVE_WIREFWD
	DC.L	SET_WIREMORPH
	DC.L	SET_WIREBUMP
	DC.L	SET_WIRECHG
	DC.L	SET_WIREINC
	DC.L	SET_WIREDEC
	DC.L	SET_WIRENULL
	DC.L	SET_WIRESTOP
	DC.L	SET_WIRE50RES

WIRE50MAINLOOP:
	moveq	#0,d6
	move.l	scr,a0
	move.l	buf3d_adr+(4*6),a2
	tst.l	(a2)
	beq.s	.nodrw
	bsr	PLOT_3DBUF
.nodrw	move.w	#%0101001010001010,d6
	move.l	scr,a0
	move.l	buf3d_adr+(4*4),a2
	tst.l	(a2)
	beq.s	.nodrw2
	bsr	PLOT_3DBUF
.nodrw2	move.w	#%1010110101010101,d6
	move.l	scr,a0
	move.l	buf3d_adr+(4*2),a2
	tst.l	(a2)
	beq.s	.nodraw
	bsr	PLOT_3DBUF
.nodraw	movea.l	wireobjadr,a1
	lea	rot_tbl,a2
	addi.w	#22,(a2)
	addi.w	#17,2(a2)
	move.l	buf3d_adr,a0
	bsr	ROTATE_3DBUF
	move.l	buf3d_adr,a0
	moveq	#0,d0
	moveq	#0,d1
	move.w	pos_z,d2
	bsr	POSITION_3DBUF
	move.l	buf3d_adr,a0
	bsr	PERSPECT_3DBUF
	moveq	#$ffffffff,d6
	move.l	scr,a0
	move.l	buf3d_adr,a2
	bsr	PLOT_3DBUF

* Rotate buffer-addresses
	lea	buf3d_adr,a0
	lea	(a0),a6
	movem.l	(a0)+,d0-d5
	move.l	(a0)+,(a6)+
	movem.l	d0-d5,(a6)

	move.l	$466.w,d0
.tst	cmp.l	$466.w,d0
	beq.s	.tst

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0),-(a0)
	move.l	d0,4(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

INIT_WIRE50:
	lea	wire50_buf,a1
	lea	buf3d_adr,a0
	REPT	7
	move.l	a1,(a0)+
	lea	500*2(a1),a1
	ENDR
	move.l	#funlogo_ini,wireobjadr
	move.w	#-150,pos_z
	rts

MOVE_WIREFWD:
	rts

SET_WIREMORPH:
	rts

SET_WIREBUMP:
	rts

SET_WIRECHG:
	move.l	#fuji_ini,wireobjadr
	move.w	#-80,pos_z
	rts
	
SET_WIREINC:
	rts

SET_WIREDEC:
	rts

SET_WIRENULL:
	rts

SET_WIRESTOP:
	rts

SET_WIRE50RES:
	movea.l	scr,a0
	bsr	CLEAR_SCR3220T
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w

	movea.l	scr,a0
	bsr	CLEAR_SCR3220T
	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w

	movea.l	scr,a0
	bsr	CLEAR_SCR3220T

	move.l	$466.w,d0
.466lop	cmp.l	$466.w,d0
	beq.s	.466lop
	lea	r3220t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

	DATA

* Looks best at z_pos=-150
funlogo_ini:
	DC.W	56

	DC.W	-120,-60,20
	DC.W	-60,-60,20
	DC.W	-60,-40,20
	DC.W	-100,-40,20
	DC.W	-100,-20,20
	DC.W	-80,-20,20
	DC.W	-80,0,20
	DC.W	-100,0,20
	DC.W	-100,40,20
	DC.W	-120,40,20
	DC.W	-120,-60,-20
	DC.W	-60,-60,-20
	DC.W	-60,-40,-20
	DC.W	-100,-40,-20
	DC.W	-100,-20,-20
	DC.W	-80,-20,-20
	DC.W	-80,0,-20
	DC.W	-100,0,-20
	DC.W	-100,40,-20
	DC.W	-120,40,-20

	DC.W	-40,-60,20
	DC.W	-20,-60,20
	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-60,20
	DC.W	40,-60,20
	DC.W	40,40,20
	DC.W	-40,40,20
	DC.W	-40,-60,-20
	DC.W	-20,-60,-20
	DC.W	-20,20,-20
	DC.W	20,20,-20
	DC.W	20,-60,-20
	DC.W	40,-60,-20
	DC.W	40,40,-20
	DC.W	-40,40,-20

	DC.W	60,-60,20
	DC.W	80,-60,20
	DC.W	110,10,20
	DC.W	110,-60,20
	DC.W	130,-60,20
	DC.W	130,40,20
	DC.W	110,40,20
	DC.W	80,-30,20
	DC.W	80,40,20
	DC.W	60,40,20
	DC.W	60,-60,-20
	DC.W	80,-60,-20
	DC.W	110,10,-20
	DC.W	110,-60,-20
	DC.W	130,-60,-20
	DC.W	130,40,-20
	DC.W	110,40,-20
	DC.W	80,-30,-20
	DC.W	80,40,-20
	DC.W	60,40,-20

	DC.W	84

	DC.W	0,1
	DC.W	1,2
	DC.W	2,3
	DC.W	3,4
	DC.W	4,5
	DC.W	5,6
	DC.W	6,7
	DC.W	7,8
	DC.W	8,9
	DC.W	9,0
	DC.W	0,10
	DC.W	1,11
	DC.W	2,12
	DC.W	3,13
	DC.W	4,14
	DC.W	5,15
	DC.W	6,16
	DC.W	7,17
	DC.W	8,18
	DC.W	9,19
	DC.W	10,11
	DC.W	11,12
	DC.W	12,13
	DC.W	13,14
	DC.W	14,15
	DC.W	15,16
	DC.W	16,17
	DC.W	17,18
	DC.W	18,19
	DC.W	19,10

	DC.W	20,21
	DC.W	21,22
	DC.W	22,23
	DC.W	23,24
	DC.W	24,25
	DC.W	25,26
	DC.W	26,27
	DC.W	27,20
	DC.W	20,28
	DC.W	21,29
	DC.W	22,30
	DC.W	23,31
	DC.W	24,32
	DC.W	25,33
	DC.W	26,34
	DC.W	27,35
	DC.W	28,29
	DC.W	29,30
	DC.W	30,31
	DC.W	31,32
	DC.W	32,33
	DC.W	33,34
	DC.W	34,35
	DC.W	35,28

	DC.W	36,37
	DC.W	37,38
	DC.W	38,39
	DC.W	39,40
	DC.W	40,41
	DC.W	41,42
	DC.W	42,43
	DC.W	43,44
	DC.W	44,45
	DC.W	45,36
	DC.W	36,46
	DC.W	37,47
	DC.W	38,48
	DC.W	39,49
	DC.W	40,50
	DC.W	41,51
	DC.W	42,52
	DC.W	43,53
	DC.W	44,54
	DC.W	45,55
	DC.W	46,47
	DC.W	47,48
	DC.W	48,49
	DC.W	49,50
	DC.W	50,51
	DC.W	51,52
	DC.W	52,53
	DC.W	53,54
	DC.W	54,55
	DC.W	55,46

fuji_ini:
	DC.W	44			Number of points in Fuji

	DC.W	-50,-60,10		0
	DC.W	-57,0,10
	DC.W	-70,30,10
	DC.W	-95,38,10		3

	DC.W	-10,-60,10		4
	DC.W	-10,60,10		5

	DC.W	50,-60,10		6
	DC.W	57,0,10
	DC.W	70,30,10
	DC.W	95,38,10		9

	DC.W	-30,-60,10		10
	DC.W	-35,0,10
	DC.W	-50,40,10
	DC.W	-65,52,10
	DC.W	-95,60,10		14

	DC.W	10,-60,10		15
	DC.W	10,60,10		16

	DC.W	30,-60,10		17
	DC.W	35,0,10
	DC.W	50,40,10
	DC.W	65,52,10
	DC.W	95,60,10		21

	DC.W	-50,-60,-10
	DC.W	-57,0,-10
	DC.W	-70,30,-10
	DC.W	-95,38,-10

	DC.W	-10,-60,-10
	DC.W	-10,60,-10

	DC.W	50,-60,-10
	DC.W	57,0,-10
	DC.W	70,30,-10
	DC.W	95,38,-10

	DC.W	-30,-60,-10
	DC.W	-35,0,-10
	DC.W	-50,40,-10
	DC.W	-65,52,-10
	DC.W	-95,60,-10

	DC.W	10,-60,-10
	DC.W	10,60,-10

	DC.W	30,-60,-10
	DC.W	35,0,-10
	DC.W	50,40,-10
	DC.W	65,52,-10
	DC.W	95,60,-10

	DC.W	56			number lines in Fuji

	DC.W	0,1
	DC.W	1,2
	DC.W	2,3

	DC.W	4,5

	DC.W	10,11
	DC.W	11,12
	DC.W	12,13
	DC.W	13,14

	DC.W	6,7
	DC.W	7,8
	DC.W	8,9

	DC.W	15,16

	DC.W	17,18
	DC.W	18,19
	DC.W	19,20
	DC.W	20,21

	DC.W	22+0,22+1
	DC.W	22+1,22+2
	DC.W	22+2,22+3

	DC.W	22+4,22+5

	DC.W	22+10,22+11
	DC.W	22+11,22+12
	DC.W	22+12,22+13
	DC.W	22+13,22+14

	DC.W	22+6,22+7
	DC.W	22+7,22+8
	DC.W	22+8,22+9

	DC.W	22+15,22+16

	DC.W	22+17,22+18
	DC.W	22+18,22+19
	DC.W	22+19,22+20
	DC.W	22+20,22+21

	DC.W	4,15
	DC.W	5,16
	DC.W	22+4,22+15
	DC.W	22+5,22+16
	DC.W	4,22+4
	DC.W	5,22+5
	DC.W	15,22+15
	DC.W	16,22+16

	DC.W	0,10
	DC.W	22+0,22+10
	DC.W	0,22+0
	DC.W	10,22+10
	DC.W	3,14
	DC.W	22+3,22+14
	DC.W	3,22+3
	DC.W	14,22+14

	DC.W	6,17
	DC.W	22+6,22+17
	DC.W	6,22+6
	DC.W	17,22+17
	DC.W	9,21
	DC.W	9+22,21+22
	DC.W	9,22+9
	DC.W	21,22+21

	BSS

* Pos. + rot. shit
rot_tbl:
	ds.w	3
pos_z:	ds.w	1
* Address of current object
wireobjadr:
	ds.l	1
* Wireframe buffers
buf3d_adr:
	ds.l	7
wire50_buf:
	ds.w	500*7

	TEXT

distrot_tbl:
	DC.L	DISTROTMAINLOOP
	DC.L	INIT_DISTROT
	DC.L	INVERT_ROTMOVEMENT
	DC.L	TOGGLE_DISTSTYLE

DISTROTMAINLOOP:
	move.w	$468.w,.old468

	bsr	PLOT_INTERGFX

* Increase or decrease rotation.
	move.w	$4bc.w,d0
	sub.w	starttime+2,d0
	move.w	d0,rotowi

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	move.w	.old468(pc),d0
.tst468:
	cmp.w	$468.w,d0
	beq.s	.tst468
	rts

.old468:
	DS.W	1

INIT_DISTROT:
	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

INVERT_ROTMOVEMENT:
	not.w	invroto
	rts

TOGGLE_DISTSTYLE:
	not.w	distrotplottype
	rts

	DATA

	DS.W	1				* Put on long edge!!
gfx_pic:
	INCBIN	PLASMAD.RAW
tan_tbl:
	INCBIN	TAN.BIN
	EVEN

	BSS

invroto:
	DS.W	1
rotowi:	DS.W	1
rotdist:
	DS.W	100				* scrlines
distrotplottype:
	DS.W	1

	TEXT

tunnel_tbl:
	DC.L	TUNNELMAINLOOP
	DC.L	INIT_TUNNEL
	DC.L	SET_TUNNELRES

TUNNELMAINLOOP:
	move.w	$468.w,.old468

	moveq	#0,d0
	moveq	#0,d1
	move.w	$4bc.w,d1
	andi.w	#64-1,d1
	move.w	$4bc.w,d2
	Do_SinModulo	d2
	Get_Sin	sine_tbl,d2,d0
	asr.w	#8,d0
	andi.w	#64-1,d0
	add.l	d0,d0
	lsl.l	#7,d1
	add.l	d0,d1
	lea	(tunnel_pic,d1.l*4),a2
	lea	tunnelofs_tbl,a1
	bsr	PLOT_TUNNEL

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	move.w	.old468(pc),d0
.tst468:
	cmp.w	$468.w,d0
	beq.s	.tst468

	rts

.old468:
	DS.W	1

INIT_TUNNEL:
	rts

SET_TUNNELRES:
	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

	DATA

tunnel_pic:
	INCBIN	256128.RAW
tunnelofs_tbl:
	INCBIN	TUNNEL.DAT

	TEXT

kaasblok_tbl:

* Radius of a blob-element. Must be > 0 and < 64. Or else it's
* assembler-error or runtime-error city!
sunblobradi:	equ	48
sunblobrad:	equ	sunblobradi/4*4
* Number of blobs to calculate/display. Can NOT be 0 or lower!!
sunnumblobs:	equ	4

sunblob_tbl:
	DC.L	SUNBLOBMAINLOOP
	DC.L	INIT_SUNBLOB
	DC.L	SET_SUNBLOBRES

SUNBLOBMAINLOOP:
	bsr	CALC_SUNBLOBTRAJECTS
	bsr	PLOT_OPT4BLOBS
	lea	credits_txt,a3
	move.w	(a3),d0
	move.w	$4bc.w,d1
	move.w	d1,d2
	sub.w	lasttxtchg,d1
	cmpi.w	#200,d1
	blt.s	.mul
.chg:	move.w	d2,lasttxtchg
	move.l	random,d2
	move.l	d2,d3
	mulu.w	d3,d3
	sub.l	d3,d2
	swap	d2
	eor.l	d2,d3
	move.l	d3,random
	addq.w	#1,d0
	cmp.w	2(a3),d0
	bne.s	.mul
	moveq	#0,d0
.mul:	move.w	d0,(a3)
	mulu.w	#20,d0
	lea	4(a3,d0.l),a3
	bsr	PLOT_CREDITS

	lea	scrclr_tbl,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

INIT_SUNBLOB:
	bsr	INIT_SUNSHADETAB
	bsr	PRECALC_SUNBLOBBUFFERS
	bsr	INIT_PALMSCREEN
	move.l	#$fe2347fc,random
	move.w	$4bc.w,lasttxtchg
	rts

SET_SUNBLOBRES:
	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	r3220t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

	DATA

credits_txt:
	DC.W	0
	DC.W	(.end-.start)/20
.start:	DC.B	"      Credits:      "
	DC.B	"                    "
	DC.B	"       Music:       "
	DC.B	"   Comp7/Bassment   "
	DC.B	"      Graphics:     "
	DC.B	"  Bonus & TheMatch  "
	DC.B	"        Code:       "
	DC.B	"        earx        "
	DC.B	"     LoST/Inter     "
	DC.B	"      Modplayer:    "
	DC.B	"    Bitmaster/TCE   "
	DC.B	"                    "
	DC.B	"       Gr3eTZ:      "
	DC.B	"Dead Hackers Society"
	DC.B	"        Grey/MB     "
	DC.B	"   Poets of Decay   "
	DC.B	"       Tat/Avena    "
	DC.B	"  ST-Survivor/Loud  "
	DC.B	"   Jace/ST-knights  "
	DC.B	"       Sentry       "
	DC.B	"     Phoenix/Vex    "
	DC.B	"   Reservoir Gods   "
	DC.B	"     Maggie Team    "
	DC.B	"     LoST/Inter     "
	DC.B	"    Senior Dads     "
	DC.B	"     Checkpoint     "
	DC.B	"       Escape       "
	DC.B	"      New Beat      "
	DC.B	"       Nature       "
	DC.B	"      Aggression    "
	DC.B	"   Comp7 & HoneyR   "
	DC.B	"  Rest of bassment  "
	DC.B	"   Foundation Two   "
	DC.B	"        Yoyo        "
	DC.B	"      TOS Crew      "
	DC.B	"      Paranoid      "
	DC.B	"       #ATARI       "
	DC.B	"     #ATARISCNE     "
	DC.B	"                    "
.end:
	EVEN
palms_pic:
	INCBIN	PALM.RAW
atari_fnt:
	INCBIN	ATARI.FNT

	BSS

* for text stuffs..
scrclr_tbl:
	ds.l	3
lasttxtchg:
	ds.w	1

	TEXT

* Voxel controlling values
raylength	equ	64			* The bigger, the further the view stretches.
tunnelvision	equ	40			* The lower, the wider the view.

voxel_tbl:
	DC.L	VOXELMAINLOOP
	DC.L	INIT_VOXEL
	DC.L	SET_VOXELRES

VOXELMAINLOOP:
	bsr	UPDATE_OBSERVER
	lea	color_pic,a1
	lea	height_pic,a2
	lea	cloud_pic,a3
	bsr	PLOT_VOXEL

	lea	scr,a0
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0),-4(a0)
	move.l	d0,(a0)
	move.l	d1,-8(a0)
	swap	d0
	move.b	d0,$ffff8201.w
	rol.l	#8,d0
	move.b	d0,$ffff8203.w
	rol.l	#8,d0
	move.b	d0,$ffff820d.w
	rts

INIT_VOXEL:
	moveq	#-1,d0
	lea	height_pic,a1
	lea	heigthpicname_txt,a0
	bsr	load
	moveq	#-1,d0
	lea	color_pic,a1
	lea	colorpicname_txt,a0
	bsr	load
	moveq	#-1,d0
	lea	cloud_pic,a1
	lea	cloudpicname_txt,a0
	bsr	load

	bsr	CALC_PERSPTABLES
	bsr	CALC_DISTTABLE
	rts

SET_VOXELRES:
	move.l	$466.w,d0
.tst466	cmp.l	$466.w,d0
	beq.s	.tst466
	lea	r3210t5_fv,a0
	bsr	CHANGE_FVFAST
	rts

	DATA

* View Variables
playerx:
	DC.W	0				* Viewer's coordinates
playery:
	DC.W	0
playerangle:
	DC.W	0				* Viewer's direction
elevation:
	DC.W	16000
raydistance:
	DC.W	64				* Length of rays
cloudx: DC.W	0				* Cloud position
eyedistance:
	DC.W	1				* Changes perspective
tiltx:	DC.W	0				* Amount of tilt
roll:	DC.W	50
* General graphics info
;heigth_pic:
;	INCBIN	HEIGHT.PC8			* Ground_image
heigthpicname_txt:
	DC.B	"DATA\HEIGHT.PC8",0
;color_pic:
;	INCBIN	GROUNDD.RAW			* Color_image
colorpicname_txt:
	DC.B	"DATA\GROUNDD.RAW",0
;cloud_pic:
;	INCBIN	CLOUD.RAW			* Background clouds bitmap
cloudpicname_txt:
	DC.B	"DATA\CLOUD.RAW",0
	EVEN

	BSS

height_pic:
	DS.B	256*256
color_pic:
	DS.L	256*256
cloud_pic:
	DS.W	320*200

* Heightfield tables
persp_tbl:
	DS.W	raylength
zheight_tbl:
	DS.W	raylength*$100
xanglestep_tbl:
	DS.W	sintbllen
yanglestep_tbl:
	DS.W	sintbllen

	TEXT

******** REINITIALISING ********

OUT	moveq	#0,d0
	bsr	PLAY_MODULE
	bsr	RESTORE_FV
	bsr	RESTORE_FALCPAL

	move.l	old118,$118.w
	move.l	oldvbl,$70.w

	move.l	oldscr,d7
	swap	d7
	move.b	d7,$ffff8201.w
	rol.l	#8,d7
	move.b	d7,$ffff8203.w
	rol.l	#8,d7
	andi.b	#%11111100,d7
	move.b	d7,$ffff820d.w

E_EXIT	move.l	oldsp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

******** SUBROUTINES ********

SAVE_FV	lea	fvbuf,a1
	move.l	#'FVD2',(a1)+	4 bytes header
	move.b	$ffff8006.w,(a1)+	monitor type
	move.b	$ffff820a.w,(a1)+	sync
	move.l	$ffff820e.w,(a1)+	offset & vwrap
	move.w	$ffff8266.w,(a1)+	spshift
	move.l	#$ff8282,a0	horizontal control registers
.loop1	move	(a0)+,(a1)+
	cmp.l	#$ff8292,a0
	bne	.loop1
	move.l	#$ff82a2,a0	vertical control registers
.loop2	move	(a0)+,(a1)+
	cmp.l	#$ff82ae,a0
	bne	.loop2
	move	$ffff82c2.w,(a1)+	video control
	move	$ffff82c0.w,(a1)+	video clock
	move.b	$ffff8260.w,(a1)+	shifter resolution
	move.b	$ffff820a.w,(a1)+	video sync mode
	rts

RESTORE_FV
	move.l	#fvbuf,a0
	bsr	CHANGE_FVFAST
	rts

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
	addq	#6,a0				* Skip header + monitortype
	lea	(a0),a6

	move.l	(a0)+,$ffff820e.w		* offset & vwrap
	move.w	(a0)+,$ffff8266.w		* spshift
	lea	$ffff8282.w,a1			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w		* video control
	tst.w	centurbofound
	bne.s	.extclock
.normalclock:
	move.w	(a0)+,$ffff82c0.w		* video clock
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.stres
	addq	#1,a0				* st res
	bra.s	.fres
.stres:	move.b	(a0)+,$ffff8260.w		* st res
.fres:	move.b	(a0)+,$ffff820a.w		* video sync mode
	rts
* Special shit for external clock. %-( Dumb CenTurbo shit!
.extclock:
	move.w	(a0)+,d0
	btst	#2,d0
	seq.b	d1
	move.w	d0,$ffff82c0.w
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.xstres
	addq	#1,a0				* st res
	bra.s	.xfres
.xstres:
	move.b	(a0)+,$ffff8260.w		* st res
.xfres:	move.b	(a0)+,d0
	tst.b	d1
	beq.s	.25mhz
	bset	#0,d0
.25mhz:	move.b	d0,$ffff820a.w			* video sync mode
	rts

* INPUT: a0: address of module
*        d0.w: action: 0=off
*                      1=on
PLAY_MODULE:
	tst.w	.init(pc)
	bne.s	.done
	tst.w	d0
	beq.s	.rts
	movem.l	d0/a0,-(sp)
	lea	.player079(pc),a0
	bsr.s	.reloziere079
	movem.l	(sp)+,d0/a0
	move.w	#1,.init
.done	tst.w	d0
	beq.s	.stop
	move	#$2700,sr
	move.l	#.player079+28+8,vbl_music
	moveq	#1,d0
	bsr	.player079+28+0			* On
	bclr	#4,$fffffa15.w
	move.b	#%01101000,$fffffa09.w
	move	#$2300,sr
	rts
.stop	tst.w	.off(pc)
	bne.s	.rts
	move	#$2700,sr
	move.l	#rts,vbl_music
	bsr.s	.player079+28+4     		* Off
	move.w	#1,.off
	bclr	#4,$fffffa15.w
	move.b	#%01101000,$fffffa09.w
	move	#$2300,sr
.rts	rts

.init:	DC.W	0				* Modplayer already relocated?
.off	DC.W	0				* Modplayer already turned off?

.reloziere079:
	move.l  2(a0),d0
	add.l   6(a0),d0
	add.l   14(a0),d0
	adda.l  #$1c,a0
	move.l  a0,d1
	movea.l a0,a1
	movea.l a1,a2
	adda.l  d0,a1
	move.l  (a1)+,d0
	adda.l  d0,a2
	add.l   d1,(a2)
	moveq	#0,d0
.L000A:	move.b  (a1)+,d0
	beq.s	.L000C
	cmp.b   #1,d0
	beq.s	.L000B
	adda.l  d0,a2
	add.l   d1,(a2)
	bra.s	.L000A
.L000B:	lea	$fe(a2),a2
	bra.s	.L000A
.L000C:	rts

.player079:
	INCBIN	DSP.BSW

	EVEN

* INPUT: a0: screenaddress
CLEAR_3210TSCREEN:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#61-1,d7
	movea.l	d0,a1
	movea.l	d1,a2
	movea.l	d2,a3
	movea.l	d3,a4
	movea.l	d4,a5
	movea.l	d5,a6
	adda.l	#320*100*2,a0
.loop	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	REPT	10
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d6/a1-a3,-(a0)
	rts

DO_DEMOEVENTS:
	lea	funevent_tbl(pc),a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmp.w	d0,d1
	beq	OUT
	mulu.w	#6,d1
	adda.l	d1,a0
	move.l	(a0)+,d0
	move.l	$4ba.w,d1
	sub.l	starttime,d1
	cmp.l	d0,d1
	blt.s	.rts
	move.w	(a0)+,d1
	beq	OUT
	move.w	d1,d0
	lsr.w	#8,d0
	andi.w	#$00ff,d1
	bne.s	.intern
	move.l	(eventpart_tbl.w,pc,d0.w*4),actpartadr
	bra.s	.out
.intern	move.l	(eventpart_tbl.w,pc,d0.w*4),a0
	move.l	(a0,d1.w*4),a0
	jsr	(a0)
.out	addq.w	#1,funevent_tbl+2
.rts	rts

funevent_tbl:
	INCLUDE	FUNINRTB.S

eventpart_tbl:
	DC.L	OUT
	DC.L	intropic_tbl
	DC.L	bumppic_tbl
	DC.L	kub16_tbl
	DC.L	firefx_tbl
	DC.L	blobfx_tbl
	DC.L	distrot_tbl
	DC.L	wire50_tbl
	DC.L	tunnel_tbl
	DC.L	kaasblok_tbl
	DC.L	sunblob_tbl
	DC.L	voxel_tbl

actpartadr:
	ds.l	1

SAVE_FALCPAL:
	lea	falcsave_pal,a0
	lea	$ffff9800.w,a1
	moveq	#128-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

RESTORE_FALCPAL
	lea	falcsave_pal,a1
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

* INPUT: a1: source-pallette (words)
SET_2FALCPAL
	lea	$ffff9800.w,a0
	move.w	#256-1,d7
.loop	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a1)+,d1			* R
	move.w	d1,d2				* G
	move.w	d1,d3				* B
	andi.w	#$0f00,d1
	lsl.w	#4,d1
	swap	d1
	or.l	d1,d0
	andi.w	#$00f0,d2
	swap	d2
	or.l	d2,d0
	andi.w	#$000f,d3
	lsl.w	#4,d3
	or.l	d3,d0
	move.l	d0,(a0)+
	dbra	d7,.loop
	rts

INIT_FUNLOGOS
	lea	funlogos_pi1+2,a1
	lea	$ffff9800.w,a0
	lea	funlogos_pal,a2
	moveq	#16-1,d7
.pallop	move.w	(a1)+,d0
	moveq	#0,d3
	move.w	d0,d1
	move.w	d0,d2
	andi.w	#$0700,d0
	andi.w	#$0070,d1
	andi.w	#$0007,d2
	lsl.w	#5,d0
	add.w	d1,d1
	lsl.w	#5,d2
	or.w	d0,d3
	or.w	d1,d3
	swap	d3
	or.w	d2,d3
	move.l	d3,(a0)+
	move.l	d3,(a2)+
	dbra	d7,.pallop

	move.l	a1,a6

	lea	96(a1),a1
	lea	bonus_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop1
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop1

	lea	wingleader_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop2
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop2

	lea	thematch_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop3
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop3

	lea	otm_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop4
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop4

	lea	earx_spr,a2
	lea	12*16(a2),a0
	moveq	#16-1,d7
.iconcoplop5
	REPT	6
	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	not.w	d0
	move.w	d0,(a2)+
	ENDR
	lea	-48(a1),a1
	REPT	6
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	ENDR
	lea	160-48(a1),a1
	dbra	d7,.iconcoplop5
	rts

* Routine that clears a 320*200 4bitplane screen
* INPUT: a0: screenaddress
CLEAR_32204BSCREEN
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6

	move	#152,d0
	add.l	#32000,a0
.cl2	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	dbra	d0,.cl2
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d5,-(a0)
	rts

FADEIN_FUNLOGOS
	lea	funlogos_pal,a1
	lea	$ffff9800.w,a0
	lea	7*4(a1),a1
	lea	7*4(a0),a0
	move.l	(a1)+,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	(a0),d3
	move.b	d3,d5
	swap	d3
	move.b	d3,d4
	lsr.w	#8,d3
	cmp.b	d0,d3
	beq.s	.noadd1
	addq.b	#4,d3
.noadd1	cmp.b	d1,d4
	beq.s	.noadd2
	addq.b	#4,d4
.noadd2	cmp.b	d2,d5
	beq.s	.noadd3
	addq.b	#4,d5
.noadd3	lsl.w	#8,d3
	move.b	d4,d3
	swap	d3
	move.b	d5,d3
	move.l	d3,(a0)+
	move.l	(a1)+,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	(a0),d3
	move.b	d3,d5
	swap	d3
	move.b	d3,d4
	lsr.w	#8,d3
	cmp.b	d0,d3
	beq.s	.noadd4
	addq.b	#4,d3
.noadd4	cmp.b	d1,d4
	beq.s	.noadd5
	addq.b	#4,d4
.noadd5	cmp.b	d2,d5
	beq.s	.noadd6
	addq.b	#4,d5
.noadd6	lsl.w	#8,d3
	move.b	d4,d3
	swap	d3
	move.b	d5,d3
	move.l	d3,(a0)+
	lea	6*4(a0),a0
	lea	6*4(a1),a1
	move.l	(a1)+,d0
	move.b	d0,d2
	swap	d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	(a0),d3
	move.b	d3,d5
	swap	d3
	move.b	d3,d4
	lsr.w	#8,d3
	cmp.b	d0,d3
	beq.s	.noadd7
	addq.b	#4,d3
.noadd7	cmp.b	d1,d4
	beq.s	.noadd8
	addq.b	#4,d4
.noadd8	cmp.b	d2,d5
	beq.s	.noadd9
	addq.b	#4,d5
.noadd9	lsl.w	#8,d3
	move.b	d4,d3
	swap	d3
	move.b	d5,d3
	move.l	d3,(a0)+	
	rts

ADD_LOGOSTOMESH
	lea	sine_tbl,a0
	move.w	fasex,d0
	addq.w	#4,d0
	Do_SinModulo	d0
	move.w	d0,fasex
	Get_Sin	a0,d0,d0
	asr.w	#8,d0
	Do_SinModulo	d0
	Get_SinCos	a0,d0,d1,d2	* /
	add.l	d1,d1			* | d1.l:=sin(x)
	add.l	d2,d2			* \ d2.l:=cos(x)
	move.w	roty,d0
	addq.w	#7,d0
	Do_SinModulo	d0
	move.w	d0,roty
	Get_SinCos	a0,d0,d3,d4	* /
	add.l	d3,d3			* | d3.l:=sin(y)
	add.l	d4,d4			* \ d4.l:=cos(y)
* PX = X*cos(y)        + 0        - Z*sin(y)
* PY = X*sin(x)*sin(y) + Y*cos(x) + Z*sin(x)*cos(y)
* PZ = X*cos(x)*sin(y) - Y*sin(x) + Z*cos(x)*cos(y)
* PX = X*d4            + 0        - Z*d3
* PY = X*d1*d3         + Y*d2     + Z*d1*d4
* PZ = X*d2*d3         - Y*d1     + Z*d2*d4
	moveq	#5-1,d7
	lea	logos3d_pos,a1
	lea	bonus_pos,a0
.xloop	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	addq	#2,a1
	move.w	(a1)+,d5
	ext.l	d5
	muls.l	d3,d5
	sub.l	d5,d0
	swap	d0
	move.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.xloop

	moveq	#5-1,d7
	move.l	d3,a3
	move.l	d4,a4
	muls.l	d1,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d1,d5:d4
	move.w	d5,d4
	swap	d4
	lea	logos3d_pos,a1
	lea	bonus_pos+2,a0
.yloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d2,d6
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.yloop
	move.l	a3,d3
	move.l	a4,d4

	muls.l	d2,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d2,d5:d4
	move.w	d5,d4
	swap	d4
	moveq	#5-1,d7
	lea	logos3d_pos,a1
	lea	bonus_pos+4,a0
.zloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d1,d6
	sub.l	d6,d5
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.zloop
* Position the logos in 3d space.
	moveq	#5-1,d7
	lea	bonus_pos+4,a0
	move.w	funkubz,d0
.poslop	add.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.poslop
* Perspectivate the center-points of the logos.
	moveq	#5-1,d7
	lea	bonus_pos,a0
	move.l	#scrxbytes4b,d3
	move.l	#scrlines/2,d4
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			d0.w: scale factor
	movem.w	(a0),d1-d2
	asl.l	#8,d1
	asl.l	#8,d2
	divs.w	d0,d1			scale x-coordinate
	add.w	d3,d1			center x-coordinate
	move.w	d1,(a0)+
	divs.w	d0,d2			scale y-coordinate
	add.w	d4,d2			center y-coordinate
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
* Add the logos to the polymesh.
	lea	bonus_pos,a1
	move.l	#polymesh+2,a0
	move.l	(a0)+,d0
	add.l	d0,a0
	moveq	#5,d7
	add.w	d7,polymesh
	moveq	#0,d0
	subq.w	#1,d7
.backlp	move.w	#0,(a0)+
	move.w	#1,(a0)+
	move.w	d0,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	addq.w	#1,d0
	dbra	d7,.backlp
	move.l	a0,d0
	sub.l	#polymesh+6,d0
	move.l	#polymesh+2,a0
	move.l	d0,(a0)
	rts

* Routine that plots a 4 bitplane 96*16 sprite to screen.
* Shifting is done realtime. Onscreen detection implemented and vertical
* clipping too :) (no horizontal clipping :( )
* Optimised.. Where the mask is all 1's, the entire 16 pixel block is
* skipped :))))
* INPUT: a1: startaddress of sprite-data
*        d0.w: x-middle position of sprite
*        d1.w: y-middle position of sprite
PLOT_4B9616SPRITE
	subi.w	#48,d0
	cmpi.w	#(scrxbytes4b*2)-96,d0
	blo.s	.posx
	rts
.posx	subq.w	#8,d1
	cmpi.w	#scrlines-16,d1
	blo.s	.posy
	bpl.s	.high
	cmpi.w	#-16,d1
	bgt.s	.cliplow
	rts
.cliplow
	moveq	#16-1,d7
	add.w	d1,d7
	move.w	d0,d5
	andi.b	#$f0,d0
	sub.w	d0,d5
	lsr.w	#1,d0
	move.l	scr,a0
	add.w	d0,a0
	neg.w	d1
	lea	12*16(a1),a2
	mulu.w	#12,d1
	add.l	d1,a1
	lsl.l	#2,d1
	add.l	d1,a2
	bra.s	.yloop
.high	cmpi.w	#scrlines,d1
	blt.s	.highclip
	rts
.highclip
	move.w	#scrlines-1,d7
	sub.w	d1,d7
	move.l	scr,a0
	move.w	d0,d5
	andi.b	#$f0,d0
	sub.w	d0,d5
	lsr.w	#1,d0
	mulu.w	#scrxbytes4b,d1
	add.w	d0,a0
	add.l	d1,a0
	lea	12*16(a1),a2
	bra.s	.yloop
.posy	move.l	scr,a0
	move.w	d0,d5
	andi.b	#$f0,d0
	sub.w	d0,d5
	lsr.w	#1,d0
	mulu.w	#scrxbytes4b,d1
	add.w	d0,a0
	add.l	d1,a0
	lea	12*16(a1),a2
	moveq	#16-1,d7
.yloop	moveq	#6-1,d6
.blklop	moveq	#$ffffffff,d0
	move.w	(a1)+,d0
	cmpi.w	#$ffff,d0
	bne.s	.normal
	addq	#8,a2
	addq	#8,a0
	bra.s	.dbrad6
.normal	ror.l	d5,d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	swap	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	lea	-16(a0),a0
	REPT	4
	moveq	#0,d0
	move.w	(a2)+,d0
	ror.l	d5,d0
	or.w	d0,(a0)+
	swap	d0
	or.w	d0,6(a0)
	ENDR
.dbrad6	dbra	d6,.blklop	
	lea	scrxbytes4b-48(a0),a0
	dbra	d7,.yloop
.rts	rts

TRANSFER_PIECE
	lea	piece_tbl,a0
	move.w	(a1)+,d7
	move.w	d7,d0
	mulu.w	#6,d0
	lea	(a1,d0.l),a2
	move.l	a2,(a0)+
	move.w	d7,(a0)+
	subq.w	#1,d7
.lp	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	dbra	d7,.lp
	rts

* calculate sin and cos values for current angles
INIT_SINROT
	lea	sine_tbl,a1
	Do_SinModulo	(a0)
	move.w	(a0)+,d0
	Get_SinCos	a1,d0,d0,d1
	add.l	d0,d0
	add.l	d1,d1
	move.l	d0,sin_x
	move.l	d1,cos_x
	Do_SinModulo	(a0)
	move.w	(a0)+,d0
	Get_SinCos	a1,d0,d0,d1
	add.l	d0,d0
	add.l	d1,d1
	move.l	d0,sin_y
	move.l	d1,cos_y
	rts

* This routine is just a easy to calculate sinus-matrix thingy
* rotates around the z-axis and then around the y-axis.
* makes a rotated copy of the original...
* INPUT: a1: address of source objectbuffer
*        a2: address of rotation-array
ROTATE_PIECE
* Get sine-values..
	lea	sine_tbl,a0
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a0,d0,d1,d2
	add.l	d1,d1
	add.l	d2,d2
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a0,d0,d3,d4
	add.l	d3,d3
	add.l	d4,d4
	lea	piece_tbl,a0
	move.l	a0,a6
	addq	#4,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	movea.w	d7,a5
	move.l	a1,a2
* Calculate the x-coordinates..
.xloop	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	addq	#2,a1
	move.w	(a1)+,d5
	ext.l	d5
	muls.l	d3,d5
	sub.l	d5,d0
	swap	d0
	move.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.xloop
* Calculate the y-coordinates..
	lea	6+2(a6),a0			* Get address of first y-coord
	move.l	d3,a3				* Backup
	move.l	d4,a4				* Backup
	muls.l	d1,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d1,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.yloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d2,d6
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.yloop
* Calculate the z-coordinates..
	lea	6+4(a6),a0			* Get address of first z-coord
	move.l	a3,d3
	move.l	a4,d4
	muls.l	d2,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d2,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.zloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d1,d6
	sub.l	d6,d5
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.zloop
	move.l	a1,(a6)				* Store address of object-polydata
	rts

POSITION_PIECE
	lea	piece_tbl+4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

.2loop	add.w	d0,(a0)+
	add.w	d1,(a0)+
	add.w	d2,(a0)+
	dbra	d7,.2loop
	rts

PERSPECTIVATE_PIECE
	lea	piece_tbl+4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

	move.l	#scrxbytes4b,d3
	move.l	#200/2,d4
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			d0.w: scale factor

	movem.w	(a0),d1-d2
	asl.l	#8,d1
	asl.l	#8,d2
	divs.w	d0,d1			scale x-coordinate
	add.w	d3,d1			center x-coordinate
	move.w	d1,(a0)+
	divs.w	d0,d2			scale y-coordinate
	add.w	d4,d2			center y-coordinate
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
	rts

ADD_TO_POLYMESH
	lea	piece_tbl,a1
* Put all visible objectpoly's in the polymesh.
	move.l	(a1)+,a2
	move.l	#polymesh,a0
	addq.l	#2,a0
	move.l	(a0)+,d0
	add.l	d0,a0
	addq.l	#2,a1
	move.w	(a2)+,d7
	subq.w	#1,d7
	bpl.s	.backlp
	rts

.backlp	move.l	(a2)+,d6
	move.l	d6,(a0)+
	move.w	(a2)+,(a0)+
	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),(a0)
	move.w	4(a1,d0.l),4(a0)
	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),6(a0)
	move.w	4(a1,d0.l),10(a0)
	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),12(a0)
	move.w	4(a1,d0.l),16(a0)
	move.w	(a0)+,d0
	move.w	(a0)+,d4
	addq.l	#2,a0
	move.w	(a0)+,d1
	move.w	(a0)+,d3
	addq.l	#2,a0
	move.w	(a0)+,d5
	move.w	(a0)+,d2
	addq.l	#2,a0
* d0=x1 d1=x2 d2=y3 d3=y2 d4=y1 d5=x3 (allemaal words)
	sub.w	d1,d0
	sub.w	d3,d2
	sub.w	d3,d4
	sub.w	d1,d5
	muls.w	d0,d2
	muls.w	d4,d5
	cmp.w	d5,d2
	bpl.s	.okido
	lea	-24(a0),a0
	subq.w	#4,d6
	bmi.s	.eolp
.mflp	addq.l	#2,a2
	dbra	d6,.mflp
	bra.s	.eolp
.okido	addq.w	#1,polymesh
	subq.w	#4,d6
	bmi.s	.eolp
.mvlp	move.w	(a2)+,d0
	mulu.w	#6,d0
	move.l	(a1,d0.l),(a0)+
	move.w	4(a1,d0.l),(a0)+
	dbra	d6,.mvlp
.eolp	dbra	d7,.backlp
	move.l	a0,d0
	sub.l	#polymesh+6,d0
	move.l	#polymesh+2,a0
	move.l	d0,(a0)
	rts

ZSORT_POLYMESH
* stap1 : polymesh -> rij met per entry offset en afstand.
* stap2 : rij sorteren
* stap3 : gesorteerde rij -> nieuwe polymesh (polymesh2)
* stap 1
	move.l	#polymesh,a0
	move.l	#sorter_tbl,a1
	move.w	(a0)+,d7
	move.w	d7,(a1)+
	subq.w	#1,d7
	bgt.s	.1_g
	move.l	a0,a1
	move.l	#polymesh2,a0
	move.w	-2(a1),(a0)+
	beq.s	.rts
	addq	#4,a1
	move.l	(a1)+,d7
	move.l	d7,(a0)+
	move.w	(a1)+,(a0)+
	subq.w	#1,d7
.cplp	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	dbra	d7,.cplp
.rts	rts
.1_g	addq.l	#4,a0
	moveq	#0,d1
	clr.w	(a1)+
.midlop	move.w	2(a0),d0
	addq	#6,a0
	move.w	d0,d6
	mulu.w	#6,d0
	addq.w	#6,d0
	add.w	d0,d1
	move.w	d6,d5
	subq.w	#1,d6
	moveq	#0,d0
.aflp	addq.l	#4,a0
	add.w	(a0)+,d0
	dbra	d6,.aflp
	ext.l	d0
	divs.w	d5,d0
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbra	d7,.midlop
* stap 2
	move.l	#sorter_tbl,a1
	move.w	(a1)+,d7
	move.l	a1,a0
	subq.w	#1,d7
	move.l	a1,a3
	move.w	d7,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	d0,a3
	addq.l	#4,a3
	move.l	a3,a2
	subq.w	#1,d7
	move.w	d7,d6
	moveq	#0,d5
.sortlp	move.l	(a1)+,d0
	cmp.w	2(a1),d0
	ble.s	.rlp
	bset	#0,d5
	move.l	(a1),-4(a1)
	move.l	d0,(a1)
.rlp	move.l	-(a3),d0
	cmp.w	6(a3),d0
	ble.s	.rlp2
	bset	#0,d5
	move.l	4(a3),(a3)
	move.l	d0,4(a3)
.rlp2	dbra	d7,.sortlp
	btst	#0,d5
	beq.s	.rbld
	moveq	#0,d5
	move.w	d6,d7
	move.l	a0,a1
	move.l	a2,a3
	bra.s	.sortlp
* stap 3
.rbld	move.l	#sorter_tbl,a1
	move.l	#polymesh+6,a2
	move.l	#polymesh2,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
.rclp	move.w	(a1)+,d0
	lea	(a2,d0.w),a3
	move.l	(a3)+,d0
	move.w	d0,d6
	move.l	d0,(a0)+
	move.w	(a3)+,(a0)+
	subq.w	#1,d6
.mlp	move.l	(a3)+,(a0)+
	move.w	(a3)+,(a0)+
	dbra	d6,.mlp
	addq.l	#2,a1
	dbra	d7,.rclp	
	rts

PLOT_POLYMESH
	move.l	#polymesh2,a1
	move.w	(a1)+,d7
	subq.w	#1,d7
	bmi.s	.end
.biglop	movem.l	d7/a1,-(sp)
	tst.w	(a1)
	bne.s	.poly
	move.w	4(a1),d2
	mulu.w	#(12*16)+(48*16),d2
	movem.w	6(a1),d0-d1
	lea	bonus_spr,a1
	add.l	d2,a1
	bsr	PLOT_4B9616SPRITE
	bra.s	.endplt
.poly	bsr	PLOT_GLENZPOLYGON4B
.endplt	movem.l	(sp)+,d7/a1
	move.l	(a1)+,d6
	subq.w	#1,d6
	addq	#2,a1
.addlp	addq	#6,a1
	dbra	d6,.addlp
	dbra	d7,.biglop
* Make it clear that the polymesh can be used anew.
.end	clr.w	polymesh
	clr.l	polymesh+2
	rts

PLOT_POLYGONPOINTS4B
	move.l	scr,a0
	move.l	a0,a6

	move.l	(a1)+,d7
	subq.w	#1,d7
	addq.l	#2,a1
.lp	move.l	a6,a0
	movem.w	(a1)+,d0-d1
	tst.w	d0
	bmi.s	.dbra
	tst.w	d1
	bmi.s	.dbra
	move.l	d0,d2
	andi.b	#$f0,d0
	sub.w	d0,d2
	sub.b	#16,d2
	neg.b	d2
	moveq	#0,d3
	bset	d2,d3
	lsr.w	#1,d0
	mulu.w	#scrxbytes4b,d1
	add.l	d0,a0
	add.l	d1,a0
	or.w	d3,(a0)+
	or.w	d3,(a0)+
	or.w	d3,(a0)+
	or.w	d3,(a0)+
.dbra	addq.l	#2,a1
	dbra	d7,.lp
	rts

PLOT_GLENZPOLYGON4B
	move.l	(a1)+,d7
	subq.w	#1,d7
	move.w	(a1)+,-(sp)
	move.w	d7,d6
	move.l	a1,a6
	move.l	a1,a5
	move.w	2(a1),d0
	lea	6(a1),a1
	subq.w	#1,d7
	moveq	#0,d1
.fndlop	cmp.w	2(a1),d0
	blt.s	.skip
	bne.s	.nocnt
	addq.w	#1,d1
.nocnt	move.w	2(a1),d0
	move.l	a1,a5
.skip	lea	6(a1),a1
	dbra	d7,.fndlop
	cmpi.b	#3,d1
	blt.s	.wrong
	addq	#2,sp
	rts
.wrong	move.l	scr,a0
	move.w	d0,d4
	mulu.w	#scrxbytes4b,d0
	add.l	d0,a0
	move.w	(a5),-(sp)
	move.l	a0,-(sp)
* Fill the scripttable entries.
	moveq	#0,d5
	move.l	a6,a1
	move.l	a5,a6
	lea	txtpolyscript_buf+2,a0
	move.w	d6,d7
.makescriptloop
	bsr	.getnextpointaclock
	bsr	.getnextpointclock
	move.w	2(a5),d0
	cmp.w	2(a3),d0
	bgt	.scriptend
	move.w	2(a6),d0
	cmp.w	2(a4),d0
	bgt.s	.scriptend
	moveq	#0,d0
	move.w	(a3),d0
	sub.w	(a5),d0
	swap	d0
	moveq	#0,d1
	move.w	2(a3),d1
	sub.w	2(a5),d1
	bne.s	.diva
	move.l	d0,(a0)+
	moveq	#0,d0
	move.l	d0,(a0)+
	move.w	d0,(a0)+
	move.l	a3,a5
	bra.s	.eol
.diva	divs.l	d1,d0
	move.l	d0,(a0)+
	moveq	#0,d0
	move.w	(a4),d0
	sub.w	(a6),d0
	swap	d0
	moveq	#0,d1
	move.w	2(a4),d1
	sub.w	2(a6),d1
	bne.s	.divc
	move.l	d0,(a0)+
	moveq	#0,d0
	move.l	d0,-8(a0)
	move.w	d0,(a0)+
	move.l	a4,a6
	bra.s	.eol
.divc	divs.l	d1,d0
	move.l	d0,(a0)+
	move.w	2(a3),d0
	cmp.w	2(a4),d0
	bpl.s	.else
	move.w	d0,d1
	sub.w	d4,d0
	move.w	d0,(a0)+
	move.w	d1,d4
	move.l	a3,a5
	bra.s	.eol
.else	move.w	2(a4),d2
	move.w	d2,d1
	sub.w	d4,d2
	move.w	d2,(a0)+
	move.w	d1,d4
	move.l	a4,a6
	cmp.w	d0,d1
	bne.s	.eol
	move.l	a3,a5
.eol	addq.w	#1,d5
	bra	.makescriptloop
.scriptend
	lea	txtpolyscript_buf,a0
	move.w	d5,(a0)+
* If needed, swap the sides.
	move.l	(a0),d0
	cmp.l	4(a0),d0
	blt.s	.endswap
	subq.w	#1,d5
.swaplp	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	lea	10(a0),a0
	dbra	d5,.swaplp
.endswap
* PART II:
	move.l	(sp)+,a0
	moveq	#0,d0
	move.w	(sp)+,d0
	swap	d0
	move.l	d0,d1
	lea	txtpolyscript_buf,a1
	move.w	(a1)+,d7
	move.l	a0,a6
	subq.w	#1,d7
	bmi	.rts
	moveq	#$ffffffff,d5
	move.l	d5,a5
	lea	polyedges_tbl,a2
	move.w	(sp)+,d5
	beq.s	.entryloop
	cmpi.w	#1,d5
	beq	.entryloop2
	bne	.entryloop3
.entryloop
	move.l	(a1)+,a3
	move.l	(a1)+,a4
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.lineloop
	add.l	a3,d0
	add.l	a4,d1
	bra.s	.d7dbf
.lineloop
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	andi.b	#$f0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	add.w	d2,d2
	andi.b	#$f0,d3
	sub.w	d2,d4
	sub.w	d3,d5
	cmp.w	d2,d3
	bne.s	.toobad
	move.w	(a2,d4.w*2),d4
	and.w	32(a2,d5.w*2),d4
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	bra.s	.yehyeh
.toobad	move.w	(a2,d4.w*2),d4
	or.w	d4,(a0)+
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	sub.w	d2,d3
	asr.w	#4,d3
	subq.w	#2,d3
	bmi.s	.ahyeh
.blklop	move.l	a5,(a0)+
	clr.l	(a0)+
	dbra	d3,.blklop
.ahyeh	move.w	32(a2,d5.w*2),d5
	or.w	d5,(a0)+
	or.w	d5,(a0)+
	not.w	d5
	and.w	d5,(a0)+
	and.w	d5,(a0)+
.yehyeh	swap	d0
	swap	d1
	add.l	a3,d0
	add.l	a4,d1
	lea	scrxbytes4b(a6),a6
	move.l	a6,a0
	dbra	d6,.lineloop
.d7dbf	dbra	d7,.entryloop
	bra	.rts

.entryloop2
	move.l	(a1)+,a3
	move.l	(a1)+,a4
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.lineloop2
	add.l	a3,d0
	add.l	a4,d1
	bra.s	.d7dbf2
.lineloop2
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	andi.b	#$f0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	add.w	d2,d2
	andi.b	#$f0,d3
	sub.w	d2,d4
	sub.w	d3,d5
	cmp.w	d2,d3
	bne.s	.toobad2
	move.w	(a2,d4.w*2),d4
	and.w	32(a2,d5.w*2),d4
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	bra.s	.yehyeh2
.toobad2
	move.w	(a2,d4.w*2),d4
	or.w	d4,(a0)+
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	sub.w	d2,d3
	asr.w	#4,d3
	subq.w	#2,d3
	bmi.s	.ahyeh2
.blklop2
	move.w	a5,(a0)+
	clr.l	(a0)+
	clr.w	(a0)+
	dbra	d3,.blklop2
.ahyeh2	move.w	32(a2,d5.w*2),d5
	or.w	d5,(a0)+
	not.w	d5
	and.w	d5,(a0)+
	and.w	d5,(a0)+
	and.w	d5,(a0)+
.yehyeh2
	swap	d0
	swap	d1
	add.l	a3,d0
	add.l	a4,d1
	lea	scrxbytes4b(a6),a6
	move.l	a6,a0
	dbra	d6,.lineloop2
.d7dbf2	dbra	d7,.entryloop2
	bra	.rts

.entryloop3
	move.l	(a1)+,a3
	move.l	(a1)+,a4
	move.w	(a1)+,d6
	subq.w	#1,d6
	bpl.s	.lineloop3
	add.l	a3,d0
	add.l	a4,d1
	bra	.d7dbf3
.lineloop3
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	andi.b	#$f0,d2
	lsr.w	#1,d2
	add.w	d2,a0
	add.w	d2,d2
	andi.b	#$f0,d3
	sub.w	d2,d4
	sub.w	d3,d5
	cmp.w	d2,d3
	bne.s	.toobad3
	move.w	(a2,d4.w*2),d4
	and.w	32(a2,d5.w*2),d4
	or.w	d4,4(a0)
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	addq	#2,a0
	and.w	d4,(a0)+
	bra.s	.yehyeh3
.toobad3
	move.w	(a2,d4.w*2),d4
	or.w	d4,4(a0)
	not.w	d4
	and.w	d4,(a0)+
	and.w	d4,(a0)+
	addq	#2,a0
	and.w	d4,(a0)+
	sub.w	d2,d3
	asr.w	#4,d3
	subq.w	#2,d3
	bmi.s	.ahyeh3
.blklop3
	clr.l	(a0)+
	move.w	a5,(a0)+
	clr.w	(a0)+
	dbra	d3,.blklop3
.ahyeh3	move.w	32(a2,d5.w*2),d5
	or.w	d5,4(a0)
	not.w	d5
	and.w	d5,(a0)+
	and.w	d5,(a0)+
	addq	#2,a0
	and.w	d5,(a0)+
.yehyeh3
	swap	d0
	swap	d1
	add.l	a3,d0
	add.l	a4,d1
	lea	scrxbytes4b(a6),a6
	move.l	a6,a0
	dbra	d6,.lineloop3
.d7dbf3	dbra	d7,.entryloop3
.rts	rts

* Subroutine that finds the next texturepoly point in a texturepoly.
* Searches anti-clockwise.
* INPUT: a1: address of first texturepoly point
*        a5: address of actual texturepolypoint
*        d7: number of points in texturepoly
* OUTPUT: a3: address of found point
.getnextpointaclock
	lea	-6(a5),a3
	cmpa.l	a1,a3
	bpl.s	.ok
	move.w	d7,d0
	mulu.w	#6,d0
	lea	(a1,d0.l),a3
.ok	rts

* Subroutine that finds the next lowest texturepoly point in a texturepoly.
* Searches clockwise
* INPUT: a1: address of first texturepoly point
*        a6: address of current point
*        d7: number of points in texturepoly
* OUTPUT: a4: address of found point
.getnextpointclock
	lea	6(a6),a4
	move.l	a4,d0
	sub.l	a1,d0
	move.w	d7,d1
	mulu.w	#6,d1
	cmp.l	d0,d1
	bpl.s	.okido
	move.l	a1,a4
.okido	rts

* INPUT: a1: address of colorflow source table
*        a0: address of destination 24-bit color buffer
MAKE_COLORFLOW
	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#1,d6
	lsl.w	d0,d6
	move.w	d7,d5
	mulu.w	d6,d5
	move.w	d5,(a0)+
	subq.w	#1,d6
	move.w	d6,d5
	subq.w	#1,d7

.biglop	move.l	(a1)+,d1
	move.l	(a1),d2
	moveq.l	#0,d3
	move.l	d3,d4
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
	move.l	a0,a6
.lop1	swap	d3
	move.b	d3,3(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop1
	move.w	d5,d6
	move.l	a6,a0
	moveq	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop2	swap	d3
	move.b	d3,1(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop2
	move.l	a6,a0
	move.w	d5,d6
	moveq.l	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	rol.l	#8,d1
	rol.l	#8,d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop3	swap	d3
	move.b	d3,(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop3
	move.w	d5,d6
	dbra	d7,.biglop

	move.l	#truepal,a1
	move.l	#realpal,a0
	move.w	(a1)+,d7

.loop	moveq	#0,d0
	move.b	(a1)+,d0
	andi.b	#%11111000,d0
	lsl.w	#8,d0
	moveq	#0,d1
	move.b	(a1)+,d1
	andi.b	#%11111100,d1
	lsl.w	#3,d1
	moveq	#0,d2
	addq.l	#1,a1
	move.b	(a1)+,d2
	lsr.w	#3,d2
	or.w	d2,d0
	or.w	d1,d0
	move.w	d0,(a0)+
	dbra	d7,.loop

	lea	realpal,a1
	lea	fire_pal+4,a0
	move.w	#256-1,d7
.bcplop	move.w	#256-1,d6
.icplop	move.w	(a1),(a0)+
	move.w	(a1)+,(a0)+
	addq	#4,a0
	dbra	d6,.icplop
	lea	-256*2(a1),a1
	dbra	d7,.bcplop

	lea	realpal,a1
	lea	fire_pal,a0
	move.w	#256-1,d7
.bcplp2	move.w	(a1)+,d0
	move.w	d0,d1
	swap	d0
	move.w	d1,d0
	move.w	#256-1,d6
.icplp2	move.l	d0,(a0)
	addq	#8,a0
	dbra	d6,.icplp2	
	dbra	d7,.bcplp2
	rts

INIT_FIRECIRC
	move.l	$4ba.w,d0
	move.l	d0,d1
	swap	d1
	sub.l	d0,d1
	or.l	$466.w,d1
	move.l	d1,random
	rts

firelines	equ	60

PLOT_FIRECIRC
	lea	firebuf+160,a1
	lea	fire_pal,a4
	lea	-160(a1),a2
	lea	160(a1),a3
	move.l	scr,a0
	adda.l	#scrxbytes*(100-firelines-1),a0
	moveq	#firelines-1,d7

	move.l	#%11111100111111001111110011111100,d5
.biglop	moveq	#40-1,d6
.lp	move.l	(a3)+,d1
	add.l	d1,d1
	add.l	(a2)+,d1
	add.l	-3(a3),d1
	and.l	d5,d1
	lsr.l	#2,d1
	move.l	d1,(a1)+
	move.l	d1,d2
	swap	d2
	move.l	(a4,d2.w*8),(a0)+
	move.l	4(a4,d2.w*8),(a0)+
	move.l	(a4,d1.w*8),(a0)+
	move.l	4(a4,d1.w*8),(a0)+
	dbra	d6,.lp
	dbra	d7,.biglop
	rts

ADD_FIRELAYER
* Calculate new baseline of fire..
	moveq	#40-1,d7
	move.l	random,d3

.intlop	move.l	d3,d0
	move.l	d0,d1
	mulu.w	d1,d1
	sub.l	d0,d1
	swap	d0
	eor.l	d0,d1
	move.l	d1,d3
	move.l	d1,(a1)+
	dbra	d7,.intlop

	move.l	d3,random
	rts

* Clears 320*100 words.
* INPUT: a0: startaddress of buffer to be cleared.
CLEAR_SCR3210T
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#61-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	add.l	#320*100*2,a0
.loop	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	REPT	10
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d6/a1-a3,-(a0)
	rts

* Clears 320*200 words.
* INPUT: a0: bufferaddress
CLEAR_SCR3220T
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#123-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	add.l	#320*200*2,a0
.loop	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	rts

* Routine that creates a simple color-flow and puts it in a table.
INIT_SHADETAB
	move.w	#%0000000000000001,d0
	move.w	#%0000000000000000,d1
	lea	colorflow_tbl,a0
	moveq	#32-1,d7
.lp	move.w	#128-1,d6
.inlp	move.w	d1,(a0)+
	dbra	d6,.inlp
	add.w	d0,d1
	dbra	d7,.lp

	move.w	#%0000000000011111,d1
	moveq	#32-1,d7
.lp2	move.w	#128-1,d6
.inlp2	move.w	d1,(a0)+
	dbra	d6,.inlp2
	subi.w	#%0000000000000001,d1
	addi.w	#%0000000000100000,d1
	dbra	d7,.lp2

	move.w	#%0000001111100000,d0
	moveq	#32-1,d7
.lp3	move.w	#128-1,d6
.inlp3	move.w	d0,(a0)+
	dbra	d6,.inlp3
	addi.w	#%0000000000100000,d0
	dbra	d7,.lp3

	move.w	#%0000011111100000,d0
	moveq	#32-1,d7
.lp4	move.w	#128-1,d6
.inlp4	move.w	d0,(a0)+
	dbra	d6,.inlp4
	addi.w	#%0000100000000000,d0
	dbra	d7,.lp4

	move.w	#%1111111111100000,d0
	moveq	#32-1,d7
.lp5	move.w	#128-1,d6
.inlp5	move.w	d0,(a0)+
	dbra	d6,.inlp5
	subi.w	#%0000000000100000,d0
	dbra	d7,.lp5

	move.w	#%1111110000000000,d0
	moveq	#32-1,d7
.lp6	move.w	#128-1,d6
.inlp6	move.w	d0,(a0)+
	dbra	d6,.inlp6
	addi.w	#%0000000000000001,d0
	dbra	d7,.lp6

	move.w	#%1111110000011111,d0
	moveq	#32-1,d7
.lp7	move.w	#256-1,d6
.inlp7	move.w	d0,(a0)+
	dbra	d6,.inlp7
	addi.w	#%0000000000100000,d0
	dbra	d7,.lp7

	moveq	#$ffffffff,d0
	move.w	#(8192+16384)-1,d7
.lp8	move.w	d0,(a0)+
	dbra	d7,.lp8

	rts

* Routine that precalculates the plottable picture of a blob-element and
* also the density-buffer for an element.
PRECALC_BLOBBUFFERS
* Calculate the density buffer..
	lea	blobdens_tbl+(blobrad*2*blobrad*2*2),a0
	moveq	#(blobrad*2)-1,d7

.yloop	moveq	#(blobrad*2)-1,d6
.xloop	move.w	d6,d0
	move.w	d7,d1
	subi.w	#blobrad,d0
	subi.w	#blobrad,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmpi.l	#blobrad*blobrad,d1
	blt.s	.in
	move.l	#$ffff,d0
	bra.s	.calc
.in	moveq	#0,d0
	divu.l	#(blobrad*blobrad),d1:d0
	eor.w	d0,d0
	swap	d0
.calc	move.l	#$ffff,d2
	sub.l	d0,d2
	mulu.w	d2,d2
	swap	d2
;	mulu.w	d2,d2
;	eor.w	d2,d2
;	swap	d2
	andi.l	#$ffff,d2
	divu.w	#numblobs,d2
	move.w	d2,-(a0)
	dbra	d6,.xloop
	dbra	d7,.yloop

* Calculate the highcolor-buffer out of the density-buffer.
	move.w	#(blobrad*2)-1,d7
	lea	blobdens_tbl,a1
	lea	colorflow_tbl,a2
	lea	blob_pic,a0
	moveq	#0,d1
.cnvlp	move.w	#(blobrad*2)-1,d6
.cxloop	move.w	(a1)+,d1
	move.w	(a2,d1.l*2),(a0)+
	dbra	d6,.cxloop
	dbra	d7,.cnvlp
	rts

* Update the circular-movement of the blobs.
* INPUT: d1.w: 0=positive movement
*              1=negative movement
CALC_BLOBTRAJECTS
	lea	blobpos_tbl,a0
	lea	sine_tbl,a1
	move.l	$4ba.w,d0
	sub.l	starttime,d0
	asr.l	#1,d0
	tst.w	d1
	bne.s	.do_it
	neg.w	d0
.do_it
* Blob 1..
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#2,d1
	asr.w	#1,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 2..
	mulu.w	#5,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#1,d1
	asr.w	#1,d2
	move.w	d1,d6
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 3..
	neg.w	d0
	addi.w	#500,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#1,d1
	asr.w	#2,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 4..
	addi.w	#700,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#1,d1
	asr.w	#1,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+

	lea	blobpos_tbl,a0
	lea	4*4(a0),a1
	lea	(a0),a6
	REPT	6
	movem.w	(a0)+,d0-d1
	addi.w	#100/2-blobrad,d0
	addi.w	#(scrxbytes/4)-blobrad,d1
	move.w	d1,(a1)+
	move.w	d0,(a1)+
	ENDR
	REPT	4
	addi.w	#(scrxbytes/4)-blobrad,(a6)+
	addi.w	#100/2-blobrad,(a6)+
	ENDR
	rts

PLOT_SLOW4BLOBS
	lea	blobbasin_buf,a0
	bsr	CLEAR_SCR3210T

	lea	blobpos_tbl,a5
	moveq	#numblobs-1,d7

.biglop	swap	d7
	lea	blobdens_tbl,a1
	lea	blobbasin_buf,a0
	movem.w	(a5)+,d0-d1
	muls.w	#640,d1
	add.l	d0,d0
	add.l	d1,a0
	add.l	d0,a0
	lea	(a0),a2
	adda.l	#((blobrad*2)-1)*640,a2
	lea	blobrad*4(a0),a3
	lea	blobrad*4(a2),a4
	move.w	#blobrad-1,d7
.loop1	moveq	#(blobrad/4)-1,d6
.iloop1	movem.l	(a1)+,d0-d3
	add.l	d0,(a0)+
	add.l	d1,(a0)+
	add.l	d2,(a0)+
	add.l	d3,(a0)+
	add.l	d0,(a2)+
	add.l	d1,(a2)+
	add.l	d2,(a2)+
	add.l	d3,(a2)+
	dbra	d6,.iloop1
	lea	640-(blobrad*4)(a0),a0
	lea	-640-(blobrad*4)(a2),a2
	dbra	d7,.loop1
	swap	d7
	dbra	d7,.biglop

	bra	PLOT_HEIGHTFIELD

	lea	blobbasin_buf,a1
	lea	colorflow_tbl,a2
	lea	sine_tbl,a0
	moveq	#0,d0
	move.w	$4bc.w,d0
	sub.w	starttime+2,d0
	move.w	d0,d1
	lsl.w	#2,d0
	Do_SinModulo	d0
	lsr.w	#1,d0
	Get_Sin		a0,d0,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	addi.w	#$0040,d0
	mulu.w	#3,d1
	lsr.l	#1,d1
	Do_SinModulo	d1
	Get_SinCos	a0,d1,d6,d7
	asr.w	#8,d6
	asr.w	#1,d6	
	asr.w	#8,d7
	asr.w	#3,d7
	move.l	d0,d1
	neg.l	d1
	addi.l	#$00e0,d1
	move.l	#$0100,d0			* Voor 2*2 pix testen..
	move.l	#$0100,d1
	bra	PLOT_SCALEHEIGHTFIELD

PLOT_HEIGHTFIELD
	move.l	scr,a0
	lea	blobbasin_buf+160,a1
	lea	colorflow_tbl,a2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#100-1,d7
.yloop	move.w	#(scrxbytes/16)-1,d6
.xloop	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	move.w	(a1)+,d3
	move.l	(a2,d0.l*2),(a0)+
	move.l	(a2,d1.l*2),(a0)+
	move.l	(a2,d2.l*2),(a0)+
	move.l	(a2,d3.l*2),(a0)+
	dbra	d6,.xloop
	lea	320(a1),a1
	dbra	d7,.yloop
	rts

* Ongeoptimaliseerde scaler voor een heightfield (bijvoorbeeld voor blob-
* basin).
* INPUT: d0.l: 8.8 X-scalefactor
*        d1.l: 8.8 Y-scalefactor
*        d6.w: x-offset from center
*        d7.w: y-offset from center
*        a1: address of heightfield (word-entries)
*        a2: address of colortable (65536 highcolor words)
PLOT_SCALEHEIGHTFIELD
	move.l	#640,d5				* d5=offset to next line
	move.w	d0,d2
	mulu.w	#scrxbytes,d2
	lsr.l	#8,d2
	move.l	d5,d4
	sub.l	d2,d4
	lsr.l	#2,d4
	add.w	d6,d4
	add.l	d4,d4
	add.l	d4,a1
	moveq	#0,d3
	move.w	d1,d2
	move.w	#scrlines,d3
	mulu.w	d3,d2
	lsr.l	#8,d2
	sub.l	d2,d3
	lsr.l	#1,d3
	add.w	d7,d3
	mulu.w	#scrxbytes,d3
	add.l	d3,a1
        ror.l   #8,d0                           * d0=xx0000XX
	add.w	d1,d1
	ror.l	#8,d1				* d1=yy0000YY
        move.l  scr,a0
        move.w  #scrlines-2,d7

	move.w  #(scrxbytes/16)-1,d6
	moveq	#0,d3
	moveq	#0,d4
        add.l   d0,d3
.pxloop	REPT	4
	move.w  (a1,d3.w*2),d4
        move.l  (a2,d4.l*2),(a0)+
        addx.l  d0,d3
	ENDR
        dbra    d6,.pxloop

.yloop	add.l	d1,d2
	bcc.s	.copy
	lea	640(a1),a1
	move.w  #(scrxbytes/16)-1,d6
	moveq	#0,d3
	moveq	#0,d4
        add.l   d0,d3
.xloop	REPT	4
	move.w  (a1,d3.w*2),d4
        move.l  (a2,d4.l*2),(a0)+
        addx.l  d0,d3
	ENDR
	dbra    d6,.xloop
	bra	.dbra
.copy	lea	-scrxbytes(a0),a0
.coplop	REPT	20
	movem.l	(a0)+,d3-d6/a3-a6
	movem.l	d3-d6/a3-a6,scrxbytes-(8*4)(a0)
	ENDR
	lea	scrxbytes(a0),a0
.dbra	dbra    d7,.yloop
        rts

* INPUT: a1: address of bitmap point to be zoomed into
*        d0.l: 8.8 X-scale
*        d1.l: 8.8 Y-scale
PLOT_FUNZOOM:
* Initialize upperleft source-address..
	move.w	#scrxbytes*2,d5
	move.w	d0,d2
	mulu.w	#scrxbytes/4,d2
	lsr.l	#8,d2
	lsl.l	#2,d2
	suba.l	d2,a1
	move.w	d1,d2
	mulu.w	#100/2,d2			* scrlines/2
	lsr.l	#8,d2
	mulu.w	d5,d2	
	suba.l	d2,a1
* Do the plot-loop..
	lea	(a1),a2
	ror.l	#7,d0
	moveq	#0,d3
	movea.l	scr,a0
	moveq	#100-1,d7			* scrlines-1
.yloop:	moveq	#0,d2
	moveq	#scrxbytes/128-1,d6
	add.l	d0,d2
.xloop:	REPT	32
	move.l	(a1,d2.w*4),(a0)+
	addx.l	d0,d2
	ENDR
	dbra	d6,.xloop
	add.w	d1,d3
	move.w	d3,d4
	lsr.w	#8,d4
	mulu.w	d5,d4
	lea	(a2,d4.l),a1
	dbra	d7,.yloop
	rts

* This routine is just a easy to calculate sinus-matrix thingy
* rotates around the z-axis and then around the y-axis.
* makes a rotated copy of the original...
* INPUT: a0: address of destination objectbuffer
*        a1: address of source objectbuffer
*        a2: address of rotation-array
ROTATE_3DBUF
* Get sine-values..
	lea	sine_tbl,a3
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a3,d0,d1,d2
	add.l	d1,d1
	add.l	d2,d2
	Do_SinModulo	(a2)
	move.w	(a2)+,d0
	Get_SinCos	a3,d0,d3,d4
	add.l	d3,d3
	add.l	d4,d4
	move.l	a0,a6
	addq	#4,a0
	move.w	(a1)+,d7
	move.w	d7,(a0)+
	subq.w	#1,d7
	movea.w	d7,a5
	move.l	a1,a2
* Calculate the x-coordinates..
.xloop	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	addq	#2,a1
	move.w	(a1)+,d5
	ext.l	d5
	muls.l	d3,d5
	sub.l	d5,d0
	swap	d0
	move.w	d0,(a0)
	addq	#6,a0
	dbra	d7,.xloop
* Calculate the y-coordinates..
	lea	6+2(a6),a0			* Get address of first y-coord
	move.l	d3,a3				* Backup
	move.l	d4,a4				* Backup
	muls.l	d1,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d1,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.yloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d2,d6
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	add.l	d6,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.yloop
* Calculate the z-coordinates..
	lea	6+4(a6),a0			* Get address of first z-coord
	move.l	a3,d3
	move.l	a4,d4
	muls.l	d2,d5:d3
	move.w	d5,d3
	swap	d3
	muls.l	d2,d5:d4
	move.w	d5,d4
	swap	d4
	move.l	a2,a1
	move.w	a5,d7
.zloop	movem.w	(a1)+,d5-d6
	muls.l	d3,d5
	muls.l	d1,d6
	sub.l	d6,d5
	move.w	(a1)+,d0
	ext.l	d0
	muls.l	d4,d0
	add.l	d0,d5
	swap	d5
	move.w	d5,(a0)
	addq	#6,a0
	dbra	d7,.zloop
	move.l	a1,(a6)				* Store address of object-polydata
	rts

* INPUT: a0: address of objectbuffer
POSITION_3DBUF
	addq	#4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

.2loop	add.w	d0,(a0)+
	add.w	d1,(a0)+
	add.w	d2,(a0)+
	dbra	d7,.2loop
	rts

* INPUT: a0: address of objectbuffer
PERSPECT_3DBUF
	addq	#4,a0
	move.w	(a0)+,d7
	subq.w	#1,d7

	move.l	#scrxbytes/4,d3
	move.l	#200/2,d4		* d4.l: scrlines/2
	move.w	#$0100,d5
.prslp2	move.w	4(a0),d0
	neg.w	d0
	add.w	d5,d0			* d0.w: scale factor

	movem.w	(a0),d1-d2
	asl.l	#8,d1
	asl.l	#8,d2
	divs.w	d0,d1			* Scale x-coordinate.
	add.w	d3,d1			* Center x-coordinate.
	move.w	d1,(a0)+
	divs.w	d0,d2			* Scale y-coordinate.
	add.w	d4,d2			* Center y-coordinate.
	move.w	d2,(a0)+
	addq.l	#2,a0
	dbra	d7,.prslp2
	rts

* INPUT: a0: screenaddress
*        a2: objectaddress
*        d6.w: color
PLOT_3DBUF
	move.l	a0,a6
	move.l	(a2)+,a1
	addq.l	#2,a2
	move.l	a0,a6
	move.w	(a1)+,d7
	subq.w	#1,d7
	bpl.s	PLOT_LINES
	rts

* The lineroutine has NO CLIPPING!!!
* The only real possible optimisations are using dedicated loops for certain
* angles(moving two pixels(longword) in one go) and drawing the line from
* both sides.
* The average speed is now 850.000 pix/sec.
* INPUT: d6.w: color of line
*        d7.w: number of lines - 1
*        a0: screenaddress
*        a1: startaddress of line-buffer
*        a2: startaddress of points
PLOT_LINES
.plotlp	movem.w	(a1)+,d0/d2
	add.l	d0,d0
	move.l	d0,d1				* /
	add.l	d0,d0				* | mulu.w #6,d0
	add.l	d1,d0				* \
	add.l	d2,d2				* /
	move.l	d2,d3				* | mulu.w #6,d2
	add.l	d2,d2				* \
	add.l	d3,d2
	movem.w	(a2,d0.l),d0-d1
	movem.w	(a2,d2.l),d2-d3
	move.l	d2,d4
	move.l	d3,d5
	sub.w	d0,d2
	bpl.s	.ok
	neg.w	d2
.ok	sub.w	d1,d3
	bpl.s	.ok2
	neg.w	d3
.ok2	cmp.w	d2,d3
	bhi.s	.ver
	cmp.w	d0,d4
	bhs.s	.do2
	exg	d0,d4
	exg	d1,d5
.do2	moveq	#80,d2			\put #640
	lsl.w	#3,d2			/in d2.l
	sub.w	d0,d4
	sub.w	d1,d5
	bpl.s	.shit
	neg.w	d5
	neg.l	d2
.shit	add.l	d0,d0
	add.l	d0,a0
	mulu.w	#640,d1
	add.l	d1,a0
	swap	d5
	addq.w	#1,d4
	divu.w	d4,d5
	moveq	#0,d0
	subq.w	#1,d4
.lp2	add.w	d5,d0
	bcc.s	.mov
	adda.l	d2,a0
.mov	move.w	d6,(a0)+
	dbra	d4,.lp2
	bra.s	.toend

.ver	cmp.w	d0,d4
	bhs.s	.do
	exg	d0,d4
	exg	d1,d5
.do	moveq	#80,d2			\put #640
	lsl.w	#3,d2			/in d2.l
	sub.w	d0,d4
	sub.w	d1,d5
	bpl.s	.shitt
	neg.w	d5
	neg.l	d2
.shitt	add.l	d0,d0
	add.l	d0,a0
	mulu.w	#640,d1
	add.l	d1,a0
	swap	d4
	addq.w	#1,d5
	divu.w	d5,d4
	moveq	#0,d0
	subq.w	#1,d5
	swap	d4
	eor.w	d4,d4
	add.l	d4,d0
.lp	move.w	d6,(a0,d0.w*2)
	addx.l	d4,d0
	adda.l	d2,a0
	dbra	d5,.lp

.toend	lea	(a6),a0
	dbra	d7,.plotlp
	rts

* INPUT: d2.l: spline_y
*        d3.w: spline_x
gen_rotdist:
.w4	swap	d2
	moveq	#0,D1
	move.w	d3,d1
	move.l	#10<<16<<4,D0
	ext.l	D1
	bmi.s	gen_rotdist_m
	cmpi.w	#0100,d1
	ble.s	.w0
	move.w	#$0100,D1
.w0:	lsl.l	#8,d1
	lsl.l	#3,d1
	lea	rotdist,A0
	lea	tan_tbl,A1
	moveq	#100-1,D3			* scrlines-1
.l0:	move.l	D2,D4
	move.l	D0,D5
	swap	D5
	divu.w	2(A1,D5.w*4),D4
	move.w	D4,(A0)+
	add.l	D1,D0
	dbra	D3,.l0
	rts

gen_rotdist_m:
	neg.l	D1
	cmpi.w	#$0100,d1
	ble.s	.w1
	move.w	#$0100,d1
.w1:	lsl.l	#8,d1
	lsl.l	#3,d1
	lea	rotdist,a0
	lea	tan_tbl,A1
	moveq	#100-1,D3			* scrlines-1
.l1:	move.l	D2,D4
	move.l	D0,D5
	swap	D5
	divu.w	2(A1,D5.w*4),D4
	move.w	d4,(a0)+
	add.l	D1,D0
	dbra	d3,.l1
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; a0.l  Zeiger auf Spline-Block
; d0.l  t (0-$ffff)
; Rckgabe: d1.w
spline:	move.l	d2,-(sp)
	move.l	(a0),d1
	muls.l	d0,d2:d1
	move.w	d2,d1
	swap	d1
	add.l	4(a0),d1
	muls.l	d0,d2:d1
	move.w	d2,d1
	swap	d1
	add.l	8(a0),d1
	muls.l	d0,d2:d1
	move.w	d2,d1
	swap	d1
	add.l	12(a0),d1
	swap	d1
	move.l	(sp)+,d2
	rts

PLOT_INTERGFX:
	addi.l	#$300,.spline_timer
	tst.w	.spline_timer(pc)
	beq.s	.ws0
	clr.w	.spline_timer
	subq.w	#1,.spline_counter
	bpl.s	.ws1
	move.w	.spline_anz_pts(pc),.spline_counter
	subq.w	#1,.spline_counter
	lea	.spline_pts(pc),a0
	bra.s	.ws2
.ws1:	move.l	.spline_adr(pc),a0
	lea	32(a0),a0
.ws2:	move.l	a0,.spline_adr
.ws0	move.l	.spline_adr(pc),a0
	moveq	#0,d0
	move.w	.spline_timer+2(pc),d0
	bsr	spline
	neg.w	d1
	asr.w	#1,d1
	move.w	d1,.spline_x
	lea	16(a0),a0
	bsr	spline
	neg.w	d1
	asr.w	#1,d1
	move.w	d1,.spline_y

	addi.l	#$500,.mspline_timer
	tst.w	.mspline_timer(pc)
	beq.s	.wms0
	clr.w	.mspline_timer
	subq.w	#1,.mspline_counter
	bpl.s	.wms1
	move.w	.mspline_anz_pts(pc),.mspline_counter
	subq.w	#1,.mspline_counter
	lea	.mspline_pts(pc),a0
	bra.s	.wms2
.wms1:	move.l	.mspline_adr(pc),a0
	lea	32(a0),a0
.wms2:	move.l	a0,.mspline_adr
.wms0	move.l	.mspline_adr(pc),a0
	moveq	#0,d0
	move.w	.mspline_timer+2(pc),d0
	bsr	spline
	neg.w	d1
	move.w	d1,.mspline_x
	lea	16(a0),a0
	bsr	spline
	neg.w	d1
	move.w	d1,.mspline_y

	move.w	rotowi,d0
	Do_SinModulo	d0
	moveq	#0,d2
	move.w	(sine_tbl,d0.w*4),d2
	addi.w	#$8000,d2
	ror.l	#8,d2
	ror.l	#3,d2
	addq.w	#1,d2
	move.w	.spline_x(pc),d3
;	moveq	#10,d2
;	moveq	#30,d3
	bsr	gen_rotdist

	lea	sine_tbl,a0
	move.w	rotowi,d0
	tst.w	invroto
	beq.s	.skip
	neg.w	d0
.skip:	add.w	d0,d0
	Do_SinModulo	d0
	Get_SinCos	a0,d0,d0,d2
	move.w	d0,.si
	move.w	d2,.co
	lea	gfx_pic,a0
	add.l	#128*1024,a0
	movea.l scr,A1
	lea	rotdist,a4
	moveq	#0,d5				* / for 
	movea.l	#$80000007,a6			* \ distorsion
	move.w	#-50,.ypos

.rotator_next_y:
	move.w	(a4)+,d6
;¯xstart%=(-50*faktor%) DIV 256
	moveq	#-80,D3
	muls.w	D6,D3
	asr.l	#8,D3
;¯ystart%=(y%*faktor%) DIV 256
	move.w	.ypos(pc),D4
;	addi.w	#70-20,D4
	add.w	.mspline_x(pc),d4
	muls.w	D6,D4
	asr.l	#8,D4
;¯xpos%=xstart%*si%+ystart%*co%
;¯ypos%=ystart%*si%-xstart%*co%
	move.l	D3,D0
	move.l	D4,D1
	muls.w	.si(pc),D0
	muls.w	.co(pc),D4
	add.l	D4,D0
	muls.w	.si(pc),D1
	muls.w	.co(pc),D3
	sub.l	D3,D1
;¯xofs%=(si%*faktor%) DIV 256
	move.w	.si(pc),D2
	muls.w	D6,D2
	eor.w	D2,d2
	swap	D2
;¯yofs%=-(co%*faktor%) DIV 256
	move.w	.co(pc),D3
	muls.w	D6,D3
	asr.l	#8,D3
	neg.l	D3
	lsr.l	#8,D0
	swap	D1
	swap	D3
	move.l	D1,D7
	eor.w	d7,d7
	add.l	D7,D0
	move.l	D3,D7
	eor.w	d7,d7
	add.l	D7,D2
	moveq	#16-1,D7
	tst.w	distrotplottype
	bne	.special
.normal:
.normal_next_x:
;¯WORD{scrcntr%+(ypos% DIV 65536)*640+(xpos% DIV 65536)*2}=-1
* d0 xpos  yn|00|xv|xn
* d1 ypos  00|00|00|yv
* d2 xofs  yn|00|xv|xn
* d3 yofs  00|00|00|yv
	REPT	10
	move.w	d0,d4
	move.b	d1,d4
	move.l	0(a0,d4.w*4),(A1)+
	add.l	d2,d0
	addx.b	d3,d1
	ENDR
	dbra	d7,.normal_next_x
	bra	.endx

.special:
.special_next_x:
;¯WORD{scrcntr%+(ypos% DIV 65536)*640+(xpos% DIV 65536)*2}=-1
* d0 xpos  yn|00|xv|xn
* d1 ypos  00|00|00|yv
* d2 xofs  yn|00|xv|xn
* d3 yofs  00|00|00|yv
	REPT	10
	move.w	d0,d4
	move.b	d1,d4
	move.l	0(a0,d4.w*4),(A1)+
	add.l	d2,d0
	addx.b	d3,d1
	ENDR
* Distort it up!! 
	add.l	a6,d2
	addx.b	d5,d3
	dbra	d7,.special_next_x

.endx:	addq.w	#1,.ypos
	cmpi.w	#50,.ypos
	bne	.rotator_next_y
	rts

.si:	DS.W	1
.co:	DS.W	1
.ypos:	DS.W	1

.spline_x:
	DS.W	1
.spline_y:
	DS.W	1
.spline_timer:
	DC.L	$10000
.spline_adr:
	DC.L	.spline_pts-32
.spline_counter:
	DC.W	0
.spline_pts=*+2
.spline_anz_pts:
	INCBIN	RSPLINE1.DAT

.mspline_x:
	DS.W	1
.mspline_y:
	DS.W	1
.mspline_timer:
	DC.L	$10000
.mspline_adr:
	DC.L	.mspline_pts-32
.mspline_counter:
	DC.W	0
.mspline_pts=*+2
.mspline_anz_pts:
	INCBIN	RSPLINE2.DAT

* Routine that creates a simple color-flow and puts it in a table.
INIT_SUNSHADETAB:
	move.w	#%0011100111011111,d1
	lea	colorflow_tbl,a0
	moveq	#32-1,d7
.lp	move.w	#128-1,d6
.inlp	move.w	d1,(a0)+
	dbra	d6,.inlp
	dbra	d7,.lp

	move.w	#%0011100111111111,d1
	moveq	#24-1,d7
.lp2	move.w	#128-1,d6
.inlp2	move.w	d1,(a0)+
	dbra	d6,.inlp2
	subi.w	#%0000000000000001,d1
	addi.w	#%0000100000100000,d1
	dbra	d7,.lp2

	move.w	#%1111101111100000,d0
	moveq	#32-1,d7
.lp3	move.w	#128-1,d6
.inlp3	move.w	d0,(a0)+
	dbra	d6,.inlp3
	addi.w	#%0000000000100000,d0
	dbra	d7,.lp3

	move.w	#%1111111111100000,d0
	moveq	#32-1,d7
.lp4	move.w	#256-1,d6
.inlp4	move.w	d0,(a0)+
	dbra	d6,.inlp4
	addi.w	#%0000000000000001,d0
	dbra	d7,.lp4

	move.w	#%1111111111111111,d0
	moveq	#32-1,d7
.lp5	move.w	#256-1,d6
.inlp5	move.w	d0,(a0)+
	dbra	d6,.inlp5
	subi.w	#%0000000000000001,d0
	dbra	d7,.lp5

	move.w	#%1111111111100000,d0
	moveq	#32-1,d7
.lp6	move.w	#128-1,d6
.inlp6	move.w	d0,(a0)+
	dbra	d6,.inlp6
;	subi.w	#%0000000001000000,d0
	addi.w	#%0000000000000001,d0
	dbra	d7,.lp6

	move.w	#%1111111111111111,d0
	moveq	#32-1,d7
.lp7	move.w	#128-1,d6
.inlp7	move.w	d0,(a0)+
	dbra	d6,.inlp7
;	addi.w	#%0000000001000000,d0
	dbra	d7,.lp7

	moveq	#$ffffffff,d0
	move.w	#(8192+16384)-1,d7
.lp8	move.w	d0,(a0)+
	dbra	d7,.lp8

	rts

* Routine that precalculates the plottable picture of a blob-element and
* also the density-buffer for an element.
PRECALC_SUNBLOBBUFFERS:
* Calculate the density buffer..
	lea	blobdens_tbl+(sunblobrad*2*sunblobrad*2*2),a0
	moveq	#(sunblobrad*2)-1,d7

.yloop	moveq	#(sunblobrad*2)-1,d6
.xloop	move.w	d6,d0
	move.w	d7,d1
	subi.w	#sunblobrad,d0
	subi.w	#sunblobrad,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmpi.l	#sunblobrad*sunblobrad,d1
	blt.s	.in
	move.l	#$ffff,d0
	bra.s	.calc
.in	moveq	#0,d0
	divu.l	#(sunblobrad*sunblobrad),d1:d0
	eor.w	d0,d0
	swap	d0
.calc	move.l	#$0000ffff,d2
	sub.l	d0,d2
	mulu.w	d2,d2
	swap	d2
;	mulu.w	d2,d2
;	eor.w	d2,d2
;	swap	d2
	andi.l	#$ffff,d2
	divu.w	#sunnumblobs,d2
	move.w	d2,-(a0)
	dbra	d6,.xloop
	dbra	d7,.yloop

* Calculate the highcolor-buffer out of the density-buffer.
	move.w	#(sunblobrad*2)-1,d7
	lea	blobdens_tbl,a1
	lea	colorflow_tbl,a2
	lea	blob_pic,a0
	moveq	#0,d1
.cnvlp	move.w	#(sunblobrad*2)-1,d6
.cxloop	move.w	(a1)+,d1
	move.w	(a2,d1.l*2),(a0)+
	dbra	d6,.cxloop
	dbra	d7,.cnvlp
	rts

INIT_PALMSCREEN:
	move.l	#%00111001110111110011100111011111,d0
	move.l	scr,a0
	bsr	COLOR_TRUESCREEN
	move.l	scr,a0
	bsr	PLOT_PALM
	move.l	#%00111001110111110011100111011111,d0
	move.l	scr+4,a0
	bsr	COLOR_TRUESCREEN
	move.l	scr+4,a0
	bsr	PLOT_PALM
	move.l	#%00111001110111110011100111011111,d0
	move.l	scr+8,a0
	bsr	COLOR_TRUESCREEN
	move.l	scr+8,a0
	bsr	PLOT_PALM
	rts

* INPUT: a0: screenaddress
PLOT_PALM:
	lea	palms_pic,a1
	lea	162*2(a0),a0
	move.w	#200-1,d7			* scrlines-1
.yloop	move.w	#(158/2)-1,d6
.xloop	move.l	(a1)+,(a0)+
	dbra	d6,.xloop
	lea	(320-158)*2(a0),a0
	dbra	d7,.yloop
	rts

* Update the circular-movement of the blobs and the plane they are in.
CALC_SUNBLOBTRAJECTS:
	lea	blobpos_tbl,a0
	lea	sine_tbl,a1
	move.l	$4ba.w,d0
	sub.l	starttime,d0
	asr.l	#1,d0
* Blob 1..
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#3,d1
	asr.w	#2,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 2..
 	mulu.w	#5,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#2,d1
	asr.w	#2,d2
	move.w	d1,d6
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 3..
	neg.w	d0
	addi.w	#500,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#2,d1
	asr.w	#3,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+
* Blob 4..
	addi.w	#700,d0
	Do_SinModulo	d0
	Get_SinCos	a1,d0,d1,d2
	asr.w	#8,d1
	asr.w	#8,d2
	asr.w	#2,d1
	asr.w	#2,d2
	move.w	d1,(a0)+
	move.w	d2,(a0)+

	lea	blobpos_tbl,a0
	lea	4*4(a0),a1
	lea	(a0),a6
	REPT	6
	movem.w	(a0)+,d0-d1
	addi.w	#(200/2)-sunblobrad,d0
	addi.w	#(scrxbytes/8)-sunblobrad,d1
	move.w	d1,(a1)+
	move.w	d0,(a1)+
	ENDR
	REPT	4
	addi.w	#(scrxbytes/8)-sunblobrad,(a6)+
	addi.w	#(200/2)-sunblobrad,(a6)+
	ENDR
	rts

PLOT_OPT4BLOBS:
	lea	blobpos_tbl,a0
	moveq	#0,d7

.loop	movem.w	(a0)+,d0-d1			* Get coords and goto next pos.
	move.l	a0,-(sp)			* Save next coord-address.
	move.w	d7,vnum				* Save counter.
	move.w	d0,d2
	move.w	d1,d3
	addi.w	#sunblobrad*2,d2
	addi.w	#sunblobrad*2,d3
	movem.w	d0-d3,-(sp)			* Push X1, Y1, X2, Y2
	bsr.s	REC_WINDOW
	addq	#8,sp
	move.w	vnum(pc),d7			* Restore counter.
	move.l	(sp)+,a0			* Restore address.
	addq.w	#1,d7
	cmpi.w	#sunnumblobs,d7
	bne.s	.loop
	rts

vnum:	DS.W	1

	RSRESET
* Format of local stackrecord:
	RS.W	1
i	RS.W	1
flag	RS.W	1
ex1	RS.W	1
ey1	RS.W	1
ex2	RS.W	1
ey2	RS.W	1
* Format of pushed stackrecord:
	RS.W	3
x1	RS.W	1
y1	RS.W	1
x2	RS.W	1
y2	RS.W	1

REC_WINDOW
	link	a0,#-6*2			* Make stackrecord.
	move.w	#sunnumblobs-1,-i(a0)		* i:=Number of blobs-1
	clr.w	-flag(a0)			* Flag:=false;
	move.w	-i(a0),d7
loop	move.w	d7,-i(a0)
* Initialize window to compare with.
	movem.w	(blobpos_tbl,d7.w*4),d0-d1	* Get address of window to compare
	move.w	d0,-ex1(a0)
	move.w	d1,-ey1(a0)
	addi.w	#sunblobrad*2,d0
	addi.w	#sunblobrad*2,d1
	move.w	d0,-ex2(a0)
	move.w	d1,-ey2(a0)
* Get type of overlap in current window..
* IF ((ex2 > x1) and (ex2 < x2) and (ey2 > y1) and (ey2 < y2)) THEN
quadrant1
	move.w	-ex2(a0),d0
	cmp.w	x1(sp),d0
	ble	endcase
	cmp.w	x2(sp),d0
	bhs.s	quadrant2
	move.w	-ey2(a0),d0
	cmp.w	y1(sp),d0
	ble	endcase
	cmp.w	y2(sp),d0
	bhs	quadrant4
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, y1, ex2, ey2);
* RecWindow(ex2, y1, x2, ey2);
* RecWindow(x1, ey2, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q1_rw2
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex2(a0),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q1_rw2	move.w	-ex2(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	x1(sp),d0
	move.w	-ey2(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  IF ((ex1 > x1) and (ex1 < x2) and (ey2 > y1) and (ey2 < y2)) THEN
quadrant2
	move.w	-ex1(a0),d0
	cmp.w	x1(sp),d0
	ble	upper_half
	cmp.w	x2(sp),d0
	bhs	endcase
	move.w	-ey2(a0),d0
	cmp.w	y1(sp),d0
	ble	endcase
	cmp.w	y2(sp),d0
	bhs.s	quadrant3
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(ex1, y1, x2, ey2);
* RecWindow(x1, y1, ex1, ey2);
* RecWindow(x1, ey2, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q2_rw2
	move.w	-ex1(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q2_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex1(a0),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	x1(sp),d0
	move.w	-ey2(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
* IF ((ex1 > x1) and (ex1 < x2) and (ey1 > y1) and (ey1 < y2)) THEN
quadrant3
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	ble	left_half
	cmp.w	y2(sp),d0
	bhs	left_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(ex1, ey1, x2, y2);
* RecWindow(x1, y1, x2, ey1);
* RecWindow(x1, ey1, ex1, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q3_rw2
	move.w	-ex1(a0),d0
	move.w	-ey1(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q3_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey1(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	x1(sp),d0
	move.w	-ey1(a0),d1
	move.w	-ex1(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
* IF ((ex2 > x1) and (ex2 < x2) and (ey1 > y1) and (ey1 < y2)) THEN
quadrant4
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	ble	right_half
	cmp.w	y2(sp),d0
	bhs	right_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, ey1, ex2, y2);
* RecWindow(x1, y1, x2, ey1);
* RecWindow(ex2, ey1, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.q4_rw2
	move.w	x1(sp),d0
	move.w	-ey1(a0),d1
	move.w	-ex2(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.q4_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey1(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	move.w	-ex2(a0),d0
	move.w	-ey1(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  if ((ex1 > x1) and (ex1 < x2) and (ey1 < y1) and (ey2 > y2)) then
left_half
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	bhi	upper_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(ex1, y1, x2, y2);
* RecWindow(x1, y1, ex1, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.lh_rw2
	move.w	-ex1(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.lh_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex1(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  if ((ex2 > x1) and (ex2 < x2) and (ey1 < y1) and (ey2 > y2)) then
right_half
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	bhi.s	upper_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, y1, ex2, y2);
* RecWindow(ex2, y1, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.rh_rw2
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	-ex2(a0),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.rh_rw2	move.w	-ex2(a0),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra	endfor
*  if ((ex1 < x1) and (ex2 > x2) and (ey1 > y1) and (ey1 < y2)) then
upper_half
	move.w	-ey1(a0),d0
	cmp.w	y1(sp),d0
	ble.s	lower_half
	cmp.w	y2(sp),d0
	bhs.s	lower_half
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, ey1, x2, y2);
* RecWindow(x1, y1, x2, ey1);
	cmp.w	vnum(pc),d0
	bhs.s	.uh_rw2
	move.w	x1(sp),d0
	move.w	-ey1(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.uh_rw2	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey1(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra.s	endfor
*  if ((ex1 < x1) and (ex2 > x2) and (ey2 > y1) and (ey2 < y2)) then
lower_half
	move.w	-ey2(a0),d0
	cmp.w	y1(sp),d0
	ble.s	no_overlap
	cmp.w	y2(sp),d0
	bhs.s	no_overlap
	move.w	#1,-flag(a0)
	move.w	-i(a0),d0
* RecWindow(x1, y1, x2, ey2);
* RecWindow(x1, ey2, x2, y2);
	cmp.w	vnum(pc),d0
	bhs.s	.dh_rw2
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	move.w	x2(sp),d2
	move.w	-ey2(a0),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
.dh_rw2	move.w	x1(sp),d0
	move.w	-ey2(a0),d1
	move.w	x2(sp),d2
	move.w	y2(sp),d3
	movem.w	d0-d3,-(sp)
	bsr	REC_WINDOW
	addq	#8,sp
	bra.s	endfor
no_overlap
;	nop
endcase
	move.w	-i(a0),d7
	dbra	d7,loop
endfor	tst.w	-flag(a0)
	beq.s	.plot_window
	unlk	a0
	rts

.plot_window
	move.w	x1(sp),d0
	move.w	y1(sp),d1
	lea	blobpos_tbl,a1
	lea	.adr_tbl(pc),a2
	lea	blobdens_tbl,a3
	ext.l	d0
	ext.l	d1
	moveq	#0,d6
	moveq	#sunnumblobs-1,d7
.findloop
	move.l	d0,d4
	move.l	d1,d5
	movem.w	(a1)+,d2-d3
	sub.w	d2,d4
	bmi.s	.nope
	sub.w	d3,d5
	bmi.s	.nope
	cmpi.w	#sunblobrad*2,d4
	bhs.s	.nope
	cmpi.w	#sunblobrad*2,d5
	bhs.s	.nope
	add.l	d4,d4
	mulu.w	#sunblobrad*4,d5
	add.l	d4,d5
	lea	(a3,d5.l),a4
	move.l	a4,(a2)+
	addq.w	#1,d6
.nope	dbra	d7,.findloop
	
	move.w	x1(sp),d0
	move.w	x2(sp),d1
	move.w	y1(sp),d2
	move.w	y2(sp),d3
	sub.w	d0,d1
	subq.w	#1,d1
	bmi.s	.unlk
	sub.w	d2,d3
	subq.w	#1,d3
	bmi.s	.unlk
	move.l	a0,-(sp)
	moveq	#sunblobrad*2,d7
	sub.w	d1,d7
	add.w	d7,d7
	subq.l	#2,d7
	move.l	scr,a0
	ext.l	d0
	mulu.w	#scrxbytes,d2
	add.l	d0,d0
	add.l	d2,a0
	add.l	d0,a0
	lea	(a0),a6
	move.w	d1,d0
	moveq	#0,d2
	cmpi.w	#1,d6
	beq.s	.plot1
	cmpi.w	#2,d6
	beq.s	.plot2
	cmpi.w	#3,d6
	beq	.plot3
	cmpi.w	#4,d6
	beq	.plot4
.endplot
	move.l	(sp)+,a0
.unlk	unlk	a0
	rts

.plot1	move.l	.adr_tbl(pc),d4
	sub.l	#blobdens_tbl,d4
	lea	(blob_pic,d4.l),a1
	addq.w	#1,d1
	move.w	d1,d2
	andi.b	#%11111100,d2
	sub.w	d2,d1
	lsr.w	#2,d2
	subq.w	#1,d2
	move.w	d2,d0
	subq.w	#1,d1
	move.w	d1,d4
.yloop	tst.w	d2
	bmi.s	.x1
.xloop	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d2,.xloop
.x1	tst.w	d1
	bmi.s	.skip1
.x1loop	move.w	(a1)+,(a0)+
	dbra	d1,.x1loop
.skip1	move.w	d4,d1
	move.w	d0,d2
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a1
	dbra	d3,.yloop
	bra.s	.endplot

.plot2	lea	colorflow_tbl,a1
	lea	.adr_tbl(pc),a5
	move.l	(a5)+,a2
	move.l	(a5)+,a3
.yloop2
.xloop2	move.w	(a2)+,d2
	add.w	(a3)+,d2
	move.w	(a1,d2.l*2),(a0)+
	dbra	d1,.xloop2
	move.w	d0,d1
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a2
	adda.l	d7,a3
	dbra	d3,.yloop2
	bra.s	.endplot

.plot3	lea	colorflow_tbl,a1
	lea	.adr_tbl(pc),a5
	move.l	(a5)+,a2
	move.l	(a5)+,a3
	move.l	(a5)+,a4
	addq.w	#1,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	move.w	d1,d5
	move.w	d0,d1
	moveq	#0,d4
	andi.b	#%00000001,d5
.yloop3
.xloop3	tst.w	d0
	bmi.s	.x3
	move.w	(a2)+,d2
	move.w	(a2)+,d4
	add.w	(a3)+,d2
	add.w	(a3)+,d4
	add.w	(a4)+,d2
	add.w	(a4)+,d4
	move.w	(a1,d2.l*2),(a0)+
	move.w	(a1,d4.l*2),(a0)+
	dbra	d1,.xloop3
.x3	tst.b	d5
	bne.s	.skip3
	move.w	(a2)+,d2
	add.w	(a3)+,d2
	add.w	(a4)+,d2
	move.w	(a1,d2.l*2),(a0)+
.skip3	move.w	d0,d1
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a2
	adda.l	d7,a3
	adda.l	d7,a4
	dbra	d3,.yloop3
	bra	.endplot

.plot4	lea	colorflow_tbl,a1
	lea	.adr_tbl(pc),a5
	move.l	(a5)+,a2
	move.l	(a5)+,a3
	move.l	(a5)+,a4
	move.l	(a5)+,a5
.yloop4
.xloop4	move.w	(a2)+,d2
	add.w	(a3)+,d2
	add.w	(a4)+,d2
	add.w	(a5)+,d2
	move.w	(a1,d2.l*2),(a0)+
	dbra	d1,.xloop4
	move.w	d0,d1
	lea	scrxbytes(a6),a6
	lea	(a6),a0
	adda.l	d7,a2
	adda.l	d7,a3
	adda.l	d7,a4
	adda.l	d7,a5
	dbra	d3,.yloop4
	bra	.endplot

.adr_tbl
	ds.l	sunnumblobs

* Sets 320*200 highcolor pixels.
* INPUT: a0: startaddress of buffer to be cleared.
*        d0.l: longword containing two highcolor words
COLOR_TRUESCREEN
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#123-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	add.l	#320*200*2,a0
.loop	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	rts

PLOT_CREDITS
	movea.l	scr,a0
	lea	320(a0),a0
	lea	palms_pic,a1
	movem.l	a0/a3,-(sp)
	move.l	scrclr_tbl,d0
	move.l	d0,d1
	mulu.w	#scrxbytes,d0
	adda.l	d0,a0
	mulu.w	#158*2,d1
	adda.l	d1,a1
	moveq	#8-1,d7

.resloop:
	move.l	#%00111001110111110011100111011111,(a0)+
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,144(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,192(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,240(a0)
	movem.l	(a1)+,d0-d6
	movem.l	d0-d6,288(a0)
	lea	scrxbytes-4(a0),a0
	dbra	d7,.resloop

	moveq	#0,d1
	move.w	random+2,d1
	divu.w	#25,d1
	eor.w	d1,d1
	swap	d1
	lsl.w	#3,d1
	move.l	d1,scrclr_tbl
	mulu.w	#scrxbytes,d1
	movem.l	(sp)+,a0/a3
	adda.l	d1,a0
	lea	atari_fnt,a1
	moveq	#$ffffffff,d1
	moveq	#20-1,d5

.charloop:
	moveq	#0,d0
	move.b	(a3)+,d0
	lea	(a1,d0.l*8),a2
	moveq	#8-1,d7

.yloop:	move.b	(a2)+,d0
	moveq	#8-1,d6
.xloop:	btst	d6,d0
	beq.s	.skip
	move.w	d1,(a0)
.skip:	addq	#2,a0
	dbra	d6,.xloop
	lea	scrxbytes-16(a0),a0
	dbra	d7,.yloop
	lea	(-scrxbytes*8)+16(a0),a0
	dbra	d5,.charloop
	rts

* INPUT: a1: address of tunnel-offset-table
*        a2: address of tunnel picture
PLOT_TUNNEL
	movea.l	scr,a0
	lea	(a0),a3
	adda.l	#640*100,a3
	moveq	#50-1,d7

.lp	moveq	#40-1,d6
.inlop	movem.w	(a1)+,d0-d3
	move.l	(a2,d0.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	move.l	(a2,d1.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	move.l	(a2,d2.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	move.l	(a2,d3.l*2),d4
	move.l	d4,(a0)+
	move.l	d4,-(a3)
	dbra	d6,.inlop
	dbra	d7,.lp
	rts

UPDATE_OBSERVER
	tst.w	.first(pc)
	bne.s	.do_it
	move.l	$4ba.w,.starttime
	not.w	.first
	clr.w	.traject_tbl+2
.do_it:	lea	.traject_tbl(pc),a0
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	cmp.w	d0,d1
	bne.s	.go_on
	rts
.go_on:	mulu.w	#6,d1
	adda.l	d1,a0
	move.l	$4ba.w,d0
	sub.l	.starttime(pc),d0
	cmp.l	(a0)+,d0
	blt.s	.atarirulez
	addq.w	#1,.traject_tbl+2
.atarirulez:
	move.w	(a0)+,d0
.fwd:	cmpi.b	#$48,d0
	bne.s	.bwd
	addq.w	#1,.speed
	subq.w	#1,roll
	bra.s	.pos
.bwd:	cmpi.b	#$50,d0
	bne.s	.left
	subq.w	#1,.speed
	addq.w	#1,roll
	bra.s	.pos
.left:	cmpi.b	#$4b,d0
	bne.s	.right
	subi.w	#16,playerangle
	bra.s	.pos
.right:	cmpi.b	#$4d,d0
	bne.s	.up
	addi.w	#16,playerangle
	bra.s	.pos
.up:	cmpi.b	#$4e,d0
	bne.s	.down
	addi.w	#128,elevation
	bra.s	.pos
.down:	cmpi.b	#$4a,d0
	bne.s	.pos
	subi.w	#128,elevation
.pos:	move.w	.speed(pc),d3
	move.l	$4ba.w,d1
	move.l	d1,d2
	sub.l	.last4ba(pc),d1
	move.l	d2,.last4ba
	mulu.w	d1,d3
	lsr.w	#4,d3
	move.w	playerangle,d0
	Do_SinModulo	d0
	move.w	(xanglestep_tbl,d0.w*2),d1
	move.w	(yanglestep_tbl,d0.w*2),d2
	muls.w	d3,d1
	muls.w	d3,d2
	asr.w	#4,d1
	asr.w	#4,d2
	add.w	d1,playerx
	add.w	d2,playery
	rts

.speed:	DC.W	0
.first:	DC.W	0
.last4ba:
	DC.L	0
.starttime:
	DC.L	0
.traject_tbl:
	INCBIN	TRAJECT.DAT

CALC_PERSPTABLES:
* Calculate conventional 1/Z-table first.
	lea	persp_tbl,a0
	move.l	#1024,d1
	moveq	#1,d7
	move.w	#raylength,d6
.loop	move.l	d1,d0
	divu.w	d7,d0
	move.w	d0,(a0)+
	addq.w	#1,d7
	cmp.w	d6,d7
	bls.s	.loop
* Then calculate precalced 2d-height for the 256 3d-heights at every Z
* point.
	lea	persp_tbl,a1
	lea	zheight_tbl,a0
	move.w	#raylength-1,d7
.loop2:	move.w	(a1)+,d0
	move.w	d0,d3
	moveq	#0,d2
.inloop2:
	move.w	d3,d0
	mulu.w	d2,d0
	lsr.l	#5,d0
	move.w	d0,(a0)+
	addq.w	#1,d2
	cmpi.w	#$0100,d2
	bne.s	.inloop2
	dbra	d7,.loop2
	rts

CALC_DISTTABLE:
	lea	xanglestep_tbl,a0
	lea	yanglestep_tbl,a1
	lea	sine_tbl,a2
	move.w	eyedistance,d2
	move.w	raydistance,d3
	move.w	#tunnelvision,d6
	move.w	#sintbllen-1,d7
.loop	movem.w	(a2)+,d0-d1			* Get next sin and cos.
	move.w	d0,d4
	move.w	d1,d5
	muls.w	d2,d4
	muls.w	d2,d5
	muls.w	d3,d0
	muls.w	d3,d1
	sub.l	d4,d0
	sub.l	d5,d1
	asr.l	#8,d0
	divs.w	d6,d0
	move.w	d0,(a1)+
	asr.l	#8,d1
	divs.w	d6,d1
	move.w	d1,(a0)+
	dbra	d7,.loop
	rts

* INPUT: a1: address of color-field
*        a2: address of height-field
*        a3: address of sky-picture
PLOT_VOXEL:
* Initialize drawing stuffs..
	lea	persp_tbl,a4
	lea	.persp_tbl(pc),a0
	move.w	#raylength,d7
	moveq	#12,d2
	move.w	roll,d3
	subq.w	#1,d7
	move.w	elevation,d1
.plop:	move.w	(a4)+,d0
	mulu.w	d1,d0
	lsr.l	d2,d0
	add.w	d3,d0
	move.w	d0,(a0)+
	dbra	d7,.plop

	movem.l	a1-a2,-(sp)
* Initialize angle of first ray..
	moveq	#0,d1
	move.w	playerangle,d1
	subi.w	#480,d1
	Do_SinModulo	d1
	move.w	d1,.rayangle
* Plot the sky..
	lsr.w	#2,d1
;	divu.w	#320,d1
;	swap	d1
	andi.w	#$00ff,d1
	lea	(a3,d1.w*2),a1
	movea.l	scr,a0
	move.w	d0,d7
	move.l	#((raylength-1)<<8)+50,d1	* Index to lowest 2d-height
	sub.w	(zheight_tbl,d1.l*2),d7
	cmpi.w	#100-1,d7			* scrlines-1
	bls.s	.nchk
	moveq	#100-1,d7			* scrlines-1
.nchk:	tst.w	d7
	bmi	.endsky
.cplop:	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*2(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*3(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*4(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*5(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*6(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*7(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*8(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*9(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*10(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*11(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48*12(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,48*13(a0)
	lea	scrxbytes(a0),a0
	lea	-(320-256)*2(a1),a1
	dbra	d7,.cplop
.endsky:
	movem.l	(sp)+,a1-a2
* Draw the Voxel itself.
	movea.l	scr,a0
	adda.l	#scrxbytes*(100-1),a0
	move.w	#scrxbytes/4-1,d7
	lea	(a0),a6
	moveq	#0,d5
	move.w	.rayangle(pc),d0

.xloop:
	move.w	playerx,d1
	move.w	playery,d2
	move.w	(xanglestep_tbl,d0.w*2),.gxstep
	move.w	(yanglestep_tbl,d0.w*2),.gystep
;	move.w	d7,d6
;	subi.w	#160,d6
;	muls.w	tiltx,d6
;	move.w	d6,.tiltfactor
	moveq	#100,d0				* topmountain:=scrlines
	lea	zheight_tbl,a3
	lea	.persp_tbl(pc),a4
	move.w	#raylength-1,d6			* Number of steps in ray..

.rayloop:
	move.w	d2,d5
	ror.w	#8,d1
	move.b	d1,d5
	rol.w	#8,d1				* d5.l: position in map
	moveq	#0,d4
	move.b	(a2,d5.l),d4			* d4.l: height
	move.w	(a4)+,d3
	move.w	(a3,d4.l*2),d4			* Optimised multiply and shift.
	lea	$100*2(a3),a3			* Move to next multiply-table.
	sub.w	d4,d3				* Get onscreen height of current point.
;	add.w	.tiltfactor(pc),d3
.cmp:	move.w	d0,d4
	sub.w	d3,d4
	ble.s	.endl
	move.l	(a1,d5.l*4),a5			* a5.l: color
	subq.w	#1,d4
	tst.w	d3				* / For clipping off
	bmi.s	.rest				* \ the mountains.
.pixlp:	move.l	a5,(a0)
	lea	-scrxbytes(a0),a0		* Go up one screenline.
	dbra	d4,.pixlp
	move.w	d3,d0				* topmountain:=newpos
.endl:	add.w	.gxstep(pc),d1			* / Move to next map-
	add.w	.gystep(pc),d2			* \ position in ray.
	dbra	d6,.rayloop
	bra.s	.nxt

.rest:	subq.w	#1,d0
	bmi.s	.nxt
.pixlp2:
	move.l	a5,(a0)
	lea	-scrxbytes(a0),a0		* Go up one screenline.
	dbra	d0,.pixlp2

* Increase angle..
.nxt:	move.w	.rayangle(pc),d0
	addq.w	#6,d0
	Do_SinModulo	d0
	move.w	d0,.rayangle
* Kick in next vertical screenline and loop..
	addq	#4,a6
	lea	(a6),a0
	dbra	d7,.xloop
	rts

.rayangle:
	DS.W	1				* Angle of current ray
.gxstep:
	DS.W	1
.gystep:
	DS.W	1				* Fixed point step value of ray
.tiltfactor:
	DS.W	1
.persp_tbl:
	DS.W	raylength
.sky_tbl
	DS.W	1
	DS.W	320

******** INTERRUPTS ********

NEWVBL:	addq.l	#1,$466.w
	movem.l	d0-a6,-(sp)
	move.l	vbl_music(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_music:
	DC.L	rts

rts:	rts

NEW118:	move.w	d0,-(sp)
.keylop:
	move.b	$fffffc02.w,d0
	bclr    #6,$FFFFFA11    ;isrb
	btst    #4,$FFFFFA01.w  ;gpip
	beq.s   .keylop
	move.w	(sp)+,d0
	rte

******** DATA + RESERVES ********

	DATA

r3210t5_fv:
	INCBIN	R3210W.FV
r3220t5_fv:
	INCBIN	R3220W.FV
r322045_fv:
	INCBIN	R3220_45.FV
r3224t5_fv:
	INCBIN	R3224_T5.FV
r322485_fv:
	INCBIN	R3224_85.FV

sine_tbl:
	INCLUDE	SINUS.S

polyedges_tbl:
	DC.W	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	DC.W	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001
	DC.W	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	DC.W	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

fungle_mod:
	INCBIN	FUNGLE.MOD
	EVEN

******** RESERVES ********

	BSS
	EVEN

* Init-data
	DS.L	256
ustk:	DS.L	1
oldsp:	DS.L	1
oldscr:	DS.L	1
oldvbl:	DS.L	1
old118:	DS.L	1
fvbuf:	DS.W	24
falcsave_pal:
	DS.L	256
centurbofound:	
	DS.W	1

* Timer stuffs
starttime:
	DS.L	1

* Random longword
random:	DS.L	1

* Standard 3d stuffs
sin_x:	DS.L	1
cos_x:	DS.L	1
sin_y:	DS.L	1
cos_y:	DS.L	1
sin_z:	DS.L	1
cos_z:	DS.L	1

piece_tbl:
	DS.L	100
sorter_tbl:
	DS.W	1
	DS.L	2000
polymesh:
	DS.W	10000
polymesh2:
	DS.W	10000

txtpolyscript_buf:
	DS.W	1
	DS.W	5*20			20 rc-changes max!

* Scr-stuff
scr	DS.L	3