;Source by Roland Spatzenegger
;Freeware
;Komplett neue Routine, morphing im dsp !
ERROR		equ	-1
OKAY		equ	0
TRUE		equ	-1
FALSE		equ	0
ANZ_STARS	equ	28*64
main:
	move.l	4(a7),a3		base page
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp

	pea     prg(pc)
	move.w  #38,-(sp)
	trap    #14
	addq.l  #6,sp
	clr	-(sp)
	trap	#1
;****************************************************************
prg:
	jsr	init_dsp
	tst.w	d0
	beq.s	.leave
	jsr	open_screen
	cmp.w	#ERROR,d0
	beq.s	.leave
	jsr	make_zufall
	jsr	transfer_dots
.mainloop:
	jsr	Vsync
	jsr	make_script
	tst.w	fertig
	bmi.s	.fertig
	move.l	$466.w,-(sp)
	jsr	make_dots
	move.l	(sp)+,d0
	cmp.l	$466.w,d0
	bne.s	.not
	move.l	ScreenAdr,a0
	eor.l	#-1,(a0)+
	eor.l	#-1,(a0)+
	eor.l	#-1,(a0)+
	eor.l	#-1,(a0)+
.not:
	cmp.b	#57,$fffffc02.w
	bne.s	.mainloop
.fertig:
	jsr	close_screen
	jsr	close_dsp
.leave:
	rts
;****************************************************************
transfer_dots:
	lea	koor_list,a0
	move.w	#ANZ_STARS*6-1,d7
.loop:
	move.w	(a0)+,d0
	ext.l	d0
	jsr	dsp_send
	dbra	d7,.loop
	rts
;****************************************************************
make_dots:
	lea	winkel,a0
	moveq	#0,d0
	moveq	#3-1,d1
.winkel:
	move.l	(a0)+,d0
	jsr	dsp_send
	dbra	d1,.winkel
	moveq	#3-1,d1
.translate:
	move.l	(a0)+,d0
	jsr	dsp_send
	dbra	d1,.translate
	
	jsr	send_next
	move	#ANZ_STARS-1,d7
	lea	$ffffa202.w,a4
	lea	old_pos,a5
	move.l	ScreenAdr,a6
	
.sloop:
	move.l	a6,a1
	move.l	(a5),a2
	sub.w	#$0840*10,(a2)
.dsp_read:
	btst 	#0,(a4)         ;DSP send ?
	beq.s	.dsp_read
	add.l	$ffffa204.w,a1
	add.w	#$0840*10,(a1)
	move.l	a1,(a5)+
	dbra	d7,.sloop
	
	rts
winkel:	dc.l	0,0,0
translate:dc.l	0,-640,1000
count:	dc.w	63
;****************************************************************
send_next:
	move	count,d0
	addq	#1,count
	and.w	#$3f,d0
	bne.s	.no_last
.no_last:
	move.l	trans_this,a0
	mulu	#6*28*2,d0
	lea	0(a0,d0.l),a0
	move.w	#28*6-1,d7
.loop
	move.w	(a0)+,d0
	ext.l	d0
	jsr	dsp_send
	dbra	d7,.loop
	rts
;****************************************************************
open_screen:
;0:Reserviert
;f:Interlace
;s:ST-Kompatibel
;o:Overscan
;p:50hz=1
;v:vga-switch
;8:640 Punkte
;nnn:Farbebenen:1,2,4,8,16/0,1,2,3,4

;First get Screen Memory in st ram !
;Mxalloc
	move.w	#0,-(sp)
	move.l	#320*240*2+10000,-(sp)
	move.w	#68,-(sp)
	trap	#1
	lea	8(sp),sp
	cmp.l	#0,d0
	bgt.s	.found_mem
	move.l	#320*240*2+10000,-(sp)
	move.w	#72,-(sp)
	trap	#1
	lea	6(sp),sp
	cmp.l	#0,d0
	ble	.error
	
.found_mem:

	move.l	d0,my_screen

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphyscreen

	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldlogscreen

	move.w  #-1,-(sp)
	move.l	my_screen,d0
	and.l	#$fffffff0,d0
	add.l	#$10,d0
	move.l	d0,Screen1
	move.l	d0,ScreenAdr
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.w  #-1,-(sp)
	move.w  #88,-(sp)
	trap    #14
	addq.l  #4,sp
	move.w	d0,oldmode
	move.w	d0,d7
	and.w	#$fff8,d7
	;	  0000000fsopv8nnn
	and.w	#%0111111000000000,d7
	or.w	#%1000000000000100,d7
	move.w  #89,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.w	#2,d0
	bne.s	.no_VGA
	or.w	#%100010000,d7
.no_VGA:
	move.w	d7,-(sp)
	move.w  #88,-(sp)
	trap    #14
	addq.l  #4,sp 
	jsr	cls_screen
	move	#OKAY,d0
	rts
.error:
	move	#ERROR,d0
	rts
;****************************************************************
close_screen:
	move.w	oldmode,-(sp)
	move.w  #88,-(sp)
   	trap    #14
	addq.l  #4,sp 
	move.w	#-1,-(sp)
	move.l	oldphyscreen,-(sp)
	move.l	oldlogscreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
;****************************************************************
cls_screen:
	movem.l	d1-d2/a0,-(sp)
	move.l	ScreenAdr,a0
	move.l	#240*320/2,d1
	moveq	#0,d2
.cls_loop:
	move.l	d2,(a0)+
	subq	#1,d1
	bne	.cls_loop
	movem.l	(sp)+,d1-d2/a0
	rts
;****************************************************************
Vsync:	
	move.l	d0,-(sp)
	move.l	$466.w,d0
.vsync_loop:
	cmp.l	$466.w,d0
	beq.s	.vsync_loop
	move.l	(sp)+,d0
	rts
;****************************************************************
init_dsp:
	move.w	#104,-(sp)
	trap	#14
	addq.l	#2,sp	;Dsp_Lock
	tst.w	d0
	bmi.s	.forget_it
	pea	dsp_puffer
	clr.w	-(sp)
	pea	lod_name
	move.w	#108,-(sp)
	trap	#14		;dsp_load_prg
	add.l	#12,sp
	tst.w	d0
	bmi.s	.forget_it
	moveq	#TRUE,d0
	rts
.forget_it:
	moveq	#FALSE,d0
	rts
close_dsp:
	move.w	#105,-(sp)
	trap	#14		;dsp_unlock
	addq.l	#2,sp	;Dsp_Lock
	rts
;*********************************************************
dsp_read:
	btst 	#0,$ffffa202.w         ;DSP send ?
	beq.s	dsp_read
	move.l	$ffffa204.w,d0
	rts
dsp_send:
	btst 	#1,$ffffa202.w         ;DSP ready
	beq.s	dsp_send
	move.l	d0,$ffffa204.w
	rts
 
;****************************************************************
make_zufall:
	lea	old_pos,a5
	move	#ANZ_STARS-1,d0
.cls_loop:	
	move.l	#dummy,(a5)+
	dbra	d0,.cls_loop


	lea	script,a6
	moveq	#0,d7
	moveq	#-1,d6		;last one
.make_figs:
	move.l	7*2(a6),d4		;get figure
	
	lea	figures_3d,a0
	move.l	0(a0,d4.l*4),a0		;get figure adr

	move.w	d7,d0
	mulu	#ANZ_STARS*2*6,d0
	lea	koor_list,a1
	add.l	d0,a1
	move.l	a1,7*2(a6)		;save adr of points
	
	cmp.l	d4,d6			;same fig ?
	bne.s	.no_same
	move.l	#ANZ_STARS*6-1,d0
	move.l	-4(a6),a0
.copy:	
	move.w	(a0)+,(a1)+
	dbra	d0,.copy
	bra.s	.ready
.no_same:	
	
	movem.l	d0-a6,-(sp)
	move.l	#ANZ_STARS-1,d7
	jsr	make_3d_fig
	movem.l	(sp)+,d0-a6
.ready:	move.l	d4,d6
	addq	#1,d7
	lea	7*2+4(a6),a6
	tst.w	(a6)
	bpl.s	.make_figs
	
	lea	koor_list,a0
.make_trans:
	lea	ANZ_STARS*6*2(a0),a1
	tst	d7
	bne.s	.ok
	lea	koor_list,a1
.ok:
	movem.l	d0-a6,-(sp)
	jsr	make_trans
	movem.l	(sp)+,d0-a6
	lea	ANZ_STARS*6*2(a0),a0
	dbra	d7,.make_trans
	rts

;****************************************************************
make_trans:
;a0=source
;a1=dest
	move.w	#ANZ_STARS*3-1,d0
.loop:
	moveq	#0,d1
	moveq	#0,d2
	move.w	2(a1),d1
	ext.l	d1
	asl.l	#8,d1
	move.w	2(a0),d2
	ext.l	d2
	asl.l	#8,d2
	sub.l	d2,d1
	asr.l	#6,d1
;	clr.w	d1
	move.w	d1,(a0)
	addq.l	#4,a0
	addq.l	#4,a1
	dbra	d0,.loop
	rts
;****************************************************************
trans_this:	dc.l	0
make_script:
	move.l	script_pos,a0
	subq	#1,(a0)
	bne.s	.next
	lea	7*2+4(a0),a0
	tst	(a0)
	bmi.s	.fertig
	move.l	a0,script_pos
.next:
	lea	translate,a1
	movem.w	2(a0),d0-d2
	add.l	d0,(a1)+
	add.l	d1,(a1)+
	add.l	d2,(a1)+
	lea	winkel,a1
	movem.w	8(a0),d0-d2
	add.l	d0,(a1)
	and.l	#$ff,(a1)+
	add.l	d1,(a1)
	and.l	#$ff,(a1)+
	add.l	d2,(a1)
	and.l	#$ff,(a1)+
	move.l	7*2(a0),trans_this
	rts
.fertig:
	move.w	#-1,fertig
	rts
;****************************************************************
;a0=3d bitmap
;a1=dest
;d7=Anzahal stars
make_3d_fig:
	move.l	ScreenAdr,a5
.mega_loop:
	jsr	GetRandom
	move.b	d0,d2
	lsr.l	#8,d0
	move.b	d0,d1
	lsr.l	#8,d0
	and.l	#$ff,d0
	and.l	#$ff,d1
	and.l	#$ff,d2		;Felxsize=64/16*2
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d5
	lsr	#2,d3		;x
	lsr	#2,d4		;y
	lsr	#2,d5		;z
	lea	(a0,d4.w*8),a2	;yx
	bfextu	(a2){d3:1},d6
	beq.s	.mega_loop
	lea	65*8(a0),a3
	lea	(a3,d5.w*8),a2	;zx
	bfextu	(a2){d3:1},d6
	beq.s	.mega_loop
	lea	2*65*8(a0),a3
	lea	(a3,d4.w*8),a2	;zy
	bfextu	(a2){d5:1},d6
	beq.s	.mega_loop
	sub.l	#128,d0
	sub.l	#128,d1
	sub.l	#128,d2
	clr.w	(a1)+
	move.w	d0,(a1)+
	clr.w	(a1)+
	move.w	d1,(a1)+
	clr.w	(a1)+
	move.w	d2,(a1)+
	add.w	#$8000,(a5)+
	dbra	d7,.mega_loop
	rts
;****************************************************************
GetRandom:
	movem.l	d1/a0-a1,-(sp)
	lea	RandomPointer(pc),a1
	move.l	(a1),a0
	jmp	(a0)
RandomFkt1:
	move.l	#RandomFkt2,(a1)
	lea	Random(pc),a1
	move.l	(a1),d0
	move.l	d0,d1
	swap	d0
	muls	#$ABCD,d0
	add.l	$466.w,d0
	add.l	d1,d0
	move.l	d0,(a1)
	movem.l	(sp)+,d1/a0-a1
	rts
RandomFkt2:
	move.l	#RandomFkt1,(a1)
	lea	Random(pc),a1
	move.l	(a1),d0
	muls	#$8234,d0
	add.l	$466.w,d0
	swap	d0
	eor.l	d0,(a1)
	movem.l	(sp)+,d1/a0-a1
	rts
RandomPointer:	dc.l	RandomFkt1
Random:		dc.l	$3141542A

;****************************************************************
	section	data
script_pos:	dc.l	script
;Anzahl der vbls,x,y,z Translate,alpha,beta,gamma,figure adr !
		dc.l	-1
script:		dc.w	1,0,0,0,1,1,1
		dc.l	1
		dc.w	64,0,10,0,1,1,0
		dc.l	0
		dc.w	64,0,0,0,1,1,0
		dc.l	0
		dc.w	64*3,0,0,0,0,1,0
		dc.l	1
		dc.w	64,0,0,0,1,0,1
		dc.l	1
		dc.w	64*3,0,0,0,1,1,1
		dc.l	2
		dc.w	64,0,0,0,1,1,1
		dc.l	2
		dc.w	64*3,0,0,0,2,1,1
		dc.l	3
		dc.w	64,0,0,0,1,1,2
		dc.l	3
		dc.w	64*3,0,0,0,2,1,1
		dc.l	4
		dc.w	64,0,0,0,1,1,1
		dc.l	4
		dc.w	64*3,0,0,0,2,1,0
		dc.l	5
		dc.w	64,0,0,0,2,1,0
		dc.l	5
		dc.w	64*3,0,0,0,0,1,1
		dc.l	6
		dc.w	64,0,0,0,0,1,1
		dc.l	6
		dc.w	64,0,-10,0,1,1,1
		dc.l	0
		dc.l	-1
fertig:		dc.w	0
lod_name:	dc.b	"rotate5.lod",0
figures_3d:	dc.l	bl1,bl2,bl3,bl4,bl5,bl6,bl7,-1
bl1:		include	"copyb1.m"
bl2:		include	"copyb2.m"
bl3:		include	"copyb3.m"
bl4:		include	"copyb4.m"
bl5:		include	"copyb5.m"
bl6:		include	"copyb6.m"
bl7:		include	"copyb7.m"

	even
;****************************************************************
	section	bss
my_screen:	ds.l	1
Screen1:	ds.l	1	;prepare Screen
ScreenAdr:	ds.l	1
oldphyscreen:	ds.l	1
oldlogscreen:	ds.l	1
oldmode:	ds.w	1
dsp_puffer:	ds.l	10000
old_pos:	ds.l	ANZ_STARS
koor_list:	ds.w	ANZ_STARS*6*20
dummy		ds.l	1