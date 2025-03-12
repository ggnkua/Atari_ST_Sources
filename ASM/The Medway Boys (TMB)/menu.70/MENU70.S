
; MEDWAY BOYS MENU NUMBER 70 - DISASEMBLED 21:10:90 BY CND.

	movea.l	a7,a5				;  header
	movea.l	4(a5),a5
	movea.l	#$7FFF0,a7
	move.l	#$200,-(a7)
	move.l	a5,-(a7)
	move.w	#0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	adda.l	#$C,a7
	
	move.w	#2,-(a7)			; phy screen
	trap	#14
	addq.l	#2,a7
	move.l	d0,phy_scn
	
	move.l	#$70000,def_scn			; save default screen

	move.w	#0,-(a7)			; set low rez
	pea	$70000
	pea	$70000
	move.w	#5,-(a7)
	trap	#14
	adda.l	#$c,a7

	lea	$60000,a0			; reserve space 
clr_scn	clr.l	(a0)+
	cmpa.l	#$7FF00,a0
	ble.s	clr_scn	

	clr.l	-(a7)				; supr mode on
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,spr_stk

	move.b	#2,$FF820A			; set 50 HTZ


	move.l #(music+$86e),(music+$1aa)	; relocate
	move.l #(music+$86f),(music+$828)	; music
	move.l #(music+$86e),(music+$83c)	; to
	move.l #(music+$c4e),(music+$c3e)	; play
	move.l #(music+$2cfa),(music+$c42)	; at
	move.l #(music+$356a),(music+$c46)	; this
	move.l #(music+$416c),(music+$c4a)	; address

	move.l	#rst_vec,$42a			; new reset vector
	move.l	#$31415926,$426			; magic ok - warm reset

	move.b	$FF820A,st_htz			; htz but not sure

	move.w	#$12,-(a7)			; kill mouse
	move.w	#4,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7

*	MOVE.W	#$FFFF,D0			; not known yet
*	EXT.L	D0				; probably to do 	
*	ADDI.L	#$503,D0			; with alt-help?
*	MOVEA.L	D0,A0				
*	MOVE.L	#$FC0020,D0
*	MOVE.L	D0,(A0)
*	MOVE.L	D0,4(A0)
*	MOVE.L	D0,8(A0)

	clr.w	hz_flag

	MOVE.L	$70,old_70			; save vbl
	MOVE.L	$120,old_120			; save timer b

	andi.b	#$fc,$484			; no click

	clr.w	bars_on

	move.l	#$70000,def_scn			; done this once ??

	move.w	#0,-(a7)			; and this ??
	pea	$70000
	pea	$70000
	move.w	#5,-(a7)
	trap	#14
	adda.l	#$C,a7

	bsr	rast_on				; turn rasters on


	clr.l d0				init
	jsr (music+8)				mfp etc
	moveq #1,d0				music #1
	jsr (music)				call music

	move.l	#new_70,$70			; install new vbl

	move.w	#1,bars_on
	move.w	#3,srl_spd			; scroll speed
	move.w	#1,cur_mus			; current music

	clr.l	d0				; copy picture
	move.w	#$1f3f,d0
	lea	piccy+34,a0
	lea	$70000,a1
do_pic	move.l	(a0)+,(a1)+
	dbf	d0,do_pic


rest_sc	move.l	#text,build			; scroller
cont_sc	movea.l	build,a0
	clr.l	d0				; clr old char
	move.b	(a0),d0				; store new one
	cmp.b	#$ff,d0				; end of text ?
	beq.s	rest_sc				; yep restart
	cmp.b	#$5c,d0				; pause ?
	bne.s	no_stop				; no skip

	move.w	#$b,d1				; pause routine
pause_1	move.w	#$ffff,d2
pause_2	dbf	d2,pause_2
	dbf	d1,pause_1
	bra.s	get_key

no_stop	cmp.b	#$20,d0				; space ?
	BNE	L31E76				; no so skip
	tst.w	hz_flag				; already active ?
	BEQ	L31E76				; yes so skip
	clr.w	hz_flag				; clear flag
	move.l	build,temp_sc			; store main scroll
	move.l	#htz_scl,build			; insert htz
L31E76	CMP.B	#$40,d0				; end of htz ?
	BNE	L31E94				; no so skip
	move.l	temp_sc,build			; replace main scroll
	move.b	#$20,d0				; and insert a space
	eori.b	#3,tog_htz			; toggle 5-6-5 etc

L31E94	subi.b	#$20,d0				; get char
	mulu	#$20,d0				; adjust for font
	addi.l	#font,d0			; add to font
	movea.l	d0,a0				; and store
	movea.l	def_scn,a1			; screen
	adda.l	#$7ede,a1			; scan line
	
	bsr	do_font				; draw character

get_key	addi.l	#1,build			; increase scroll pointer

	MOVE.W	#$FF,-(A7)			; get keypress
	MOVE.W	#6,-(A7)
	TRAP	#1
	ADDQ.L	#4,A7
	TST.L	D0				; key pressed ?
	BEQ	cont_sc				; no continue
	TST.W	D0				; scan code ?
	BEQ	L32020				; yes do function keys

	cmp.b	#$30,D0				; '0' ?
	bne.s	spd_up				; no speed up
	cmpi.l	#text,build			; main scroll on?
	blt.s	spd_up				; no speed up
	move.w	#1,hz_flag			; toggle htz flag
	bchg	#1,st_htz			; toggle htz
	bra	cont_sc				; continue scroller

spd_up	cmp.b	#$2b,d0				; plus
	bne.s	spd_dn				; no - skip
	cmpi.w	#3,srl_spd			; speed = 3?
	beq	cont_sc				; yes, cont scroll
	addq.w	#1,srl_spd			; increase speed
	bra	cont_sc				; continue scroller

spd_dn	cmp.b	#$2d,d0				; minus
	bne.s	one				; no - skip
	cmpi.w	#1,srl_spd			; speed = 1?
	beq	cont_sc				; yes, cont scroll
	subq.w	#1,srl_spd			; decrease speed
	bra	cont_sc				; continue scroller

one	cmp.b	#$31,d0				; '1' ?
	bne.s	two				; no
	bsr	tidy_up
	pea	env
	pea	com
	pea	file1
	bra	load_it				; load file

two	cmp.b	#$32,d0				; '2' ?
	bne.s	three				; no
	bsr	tidy_up
	pea	env
	pea	com
	pea	file2
	bra	load_it				; load file

three	cmp.b	#$33,d0				; '3' ?
	bne.s	four				; no 
	bsr	tidy_up				; tidy up 
	bra	quit				; and quit

four	cmp.b	#$34,d0				; '4' ?
	bne.s	five				; no
	bsr	tidy_up				; tidy up
	bra	quit				; and quit

five	cmp.b	#$35,d0				; '5' ?
	bne.s	none				; no
	bsr	tidy_up				; tidy up
	bra	quit				; and quit
none	bra	cont_sc


L32020	*LEA	L32472,A1			; handle function keypress
	swap	d0				; get scan code
	cmp.b	#$3b,d0				; 'F1' ?
	bne.s	key_f2				; no
	cmpi.w	#1,cur_mus			; is music 1 playing?
	beq	cont_sc				; yes so skip
	moveq	#2,d0				; set music 2 ?
	jsr	(music)				; start it ?
	move.w	#$2000,d1			; wait a while
L32048	nop
	dbf	d1,L32048	
	moveq	#1,d0				; set music 1
	jsr	(music)				; and start it
	move.w	#1,cur_mus			; set current music to 1
	bra	cont_sc
key_f2	cmp.b	#$3c,d0				; 'F2' ?
	bne	key_f3				; no
	cmpi.w	#2,cur_mus			; music 2 on ?
	beq	cont_sc				; yes so skip
	moveq	#2,d0				; set music 2 ?
	JSR	(music)				; start it
	move.w	#2,cur_mus			; set current music to 2
	bra	cont_sc				; continue scroller

key_f3	cmp.b	#$3d,d0				; 'F3' ?
	BNE	L320C4				; no
	CMPI.W	#3,cur_mus			; msuic 3 on ?
	BEQ	cont_sc				; yes so skip
	MOVEQ	#2,D0				; set music 2 ?
	JSR	(music)				; start it ?
	MOVE.W	#$2000,D1			; wait a while
L320AA	NOP
	DBF	D1,L320AA
	MOVEQ	#3,D0				; set music 3
	JSR	(music)				; start it
	MOVE.W	#3,cur_mus			; set current music to 3
	bra	cont_sc				; continue scroller

L320C4	CMP.B	#$3E,D0
	BNE	L320E8
	CMPI.W	#4,cur_mus
	BEQ	cont_sc
	MOVEQ	#4,D0
	JSR	(music)
	MOVE.W	#4,cur_mus
L320E8	bra	cont_sc				; do scroller 


load_it	move.w	#0,-(a7)			; load program
	move.w	#$4B,-(a7)
	trap	#1
	addq.l	#6,a7
	bra	quit

tidy_up	lea	$70000,a0			; clear default screen
clr_sc1 clr.l	(a0)+
	cmpa.l	#$7ff00,a0
	blt.s	clr_sc1

	clr.w	$ff8240				; border black
	move.w	#$777,$ff8246			; paper white

	move.l	old_70,$70
	JSR	(music+12)

	bsr	ras_off				; turn rasters off

	move.l #$8080000,$ff8820		clear
	move.l #$9090000,$ff8820		sound
	move.l #$a0a0000,$ff8820		chip
	move.l #$707ffff,$ff8820		registers
	move.b #$f0,$fffa23			new timer c
	
	move.b	st_htz,$FF820A			; replace htz
	
	move.w	#8,-(A7)			; mouse on
	move.w	#4,-(A7)
	move.w	#3,-(A7)
	trap	#13
	addq.l	#6,A7
	
	ori.b	#3,$484				; click on

	clr.l	$426				; clear reset vector
	clr.l	$42A

	move.w	#0,-(a7)			; set low res
	move.l	phy_scn,-(a7)
	move.l	phy_scn,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#$C,a7

	move.l	spr_stk,-(a7)			; supr mode off
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,A7
	rts
	
quit	clr.w	-(a7)				; quit to desktop
	trap	#1
	addq.l	#2,a7
	rts

; ------------------------------------------------------------------------

* THAT WAS THE EASY STUFF!!!!! *

do_font	move.l	a1,cur_scn			; save screen
	movea.l	#buffer,a2			; get buffer adr
	movem.l	(a0),d0-d7			; get font position
	movem.l	d0-d7,(a2)			; and store in screen		
	move.w	#$F,d5				; 16 scan lines
al_line	movem.l	d0-d1,-(a7)			; save d0,d1
	addq.w	#1,speedo			; increase speed pointer
	move.w	srl_spd,d0			; get current scroll speed
	move.w	speedo,d1			; get speed pointer
	cmp.w	d0,d1				; the same
	blt.s	no_slow				; if speed > pointer
	bsr	w_vbl				; slow down scroll
	
no_slow	movem.l	(a7)+,d0-d1			; restore d0,d1
	movea.l	#buffer,a0			; 16 word buffer
	move.w	#$F,d2				; 16 lines
	movea.l	cur_scn,a3			; current screen	

rot_scl	movea.l	a3,a1				; get current screen
	move.w	(a0),d3
	ROXL	(A0)
	ROXL	0(A1)
	ROXL	-8(A1)
	ROXL	-$10(A1)
	ROXL	-$18(A1)
	ROXL	-$20(A1)
	ROXL	-$28(A1)
	ROXL	-$30(A1)
	ROXL	-$38(A1)
	ROXL	-$40(A1)
	ROXL	-$48(A1)
	ROXL	-$50(A1)
	ROXL	-$58(A1)
	ROXL	-$60(A1)
	ROXL	-$68(A1)
	ROXL	-$70(A1)
	ROXL	-$78(A1)
	ROXL	-$80(A1)
	ROXL	-$88(A1)
	ROXL	-$90(A1)
	ROXL	-$98(A1)
	MOVE.W	D3,(A0)
	ROXL	(A0)
	ROXL	0(A1)
	ROXL	-8(A1)
	ROXL	-$10(A1)
	ROXL	-$18(A1)
	ROXL	-$20(A1)
	ROXL	-$28(A1)
	ROXL	-$30(A1)
	ROXL	-$38(A1)
	ROXL	-$40(A1)
	ROXL	-$48(A1)
	ROXL	-$50(A1)
	ROXL	-$58(A1)
	ROXL	-$60(A1)
	ROXL	-$68(A1)
	ROXL	-$70(A1)
	ROXL	-$78(A1)
	ROXL	-$80(A1)
	ROXL	-$88(A1)
	ROXL	-$90(A1)
	ROXL	-$98(A1)
	MOVE.W	0(A1),$A0(A1)
	MOVE.W	-8(A1),$98(A1)
	MOVE.W	-$10(A1),$90(A1)
	MOVE.W	-$18(A1),$88(A1)
	MOVE.W	-$20(A1),$80(A1)
	MOVE.W	-$28(A1),$78(A1)
	MOVE.W	-$30(A1),$70(A1)
	MOVE.W	-$38(A1),$68(A1)
	MOVE.W	-$40(A1),$60(A1)
	MOVE.W	-$48(A1),$58(A1)
	MOVE.W	-$50(A1),$50(A1)
	MOVE.W	-$58(A1),$48(A1)
	MOVE.W	-$60(A1),$40(A1)
	MOVE.W	-$68(A1),$38(A1)
	MOVE.W	-$70(A1),$30(A1)
	MOVE.W	-$78(A1),$28(A1)
	MOVE.W	-$80(A1),$20(A1)
	MOVE.W	-$88(A1),$18(A1)
	MOVE.W	-$90(A1),$10(A1)
	MOVE.W	-$98(A1),8(A1)
	LEA	2(A0),A0
	LEA	$140(A3),A3
	DBF	D2,rot_scl			; do sroll line
	dbf	d5,al_line			; 16 screen lines
	rts


rst_vec	lea	$ff8240,a0			; the reset vector
	move.w	#7,d0
rset	clr.l	(a0)+
	dbf	d0,rset
	clr.l	$426
	clr.l	$42A
loopy	nop
	bra.s	loopy
	
w_vbl	clr.w	speedo
	clr.w	wait
wait1	tst.w	wait
	beq.s	wait1
	rts
	
new_70	move.w	#1,wait
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	piccy+2,$ffff8240.w		; picture pal
	move.l	piccy+6,$ffff8244.w		;     ''
	move.l	piccy+10,$ffff8248.w		;     ''
	move.l	piccy+14,$ffff824C.w		;  etc etc etc.
	move.l	piccy+18,$ffff8250.w
	move.l	piccy+22,$ffff8254.w
	move.l	piccy+26,$ffff8258.w
	move.l	piccy+30,$ffff825C.w
	
	MOVE.B	#0,$FFFFFA1B
	
	ADDQ.W	#1,L337B8
	MOVE.W	L337B8,D0
	MOVE.W	#$B5,D1
	LEA	L337AC,A0
	MOVE.W	L337B6,D2
	SUB.W	0(A0,D2.W),D1
	CMP.W	D1,D0
	BNE	L3242E
	ADDQ.W	#2,L337B6
	CMPI.W	#$A,L337B6
	BNE	L32426
	CLR.W	L337B6
L32426	CLR.W	D0
	MOVE.W	D0,L337B8

L3242E	LEA	bar_line,A0
	LEA	L337A2,A1
	MOVE.W	L337B6,D1
	ADD.W	0(A1,D1.W),D0
	MOVE.B	0(A0,D0.W),D0
	MOVE.W	L337B6,D1
	MULU	#$13,D1
	ADD.B	D1,D0
	MOVE.B	d0,$FFFA21
	MOVE.B	D0,L337BA
	MOVE.L	#L32748,$120.W
	
	MOVE.B	#8,$FFFFFA1B
	
	jsr (music+4)				call music player
	tst.w	bars_on
	beq	no_bars
	
; un-comment the following for vdu bars
	 MOVEA.L	#$77F80,A0
	 MOVEA.L	A0,A1
	 MOVEA.L	A0,A2
	 MOVE.W	#3,D0
L3248E	CLR.W	(A0)
	 CLR.W	$A0(A0)
	 CLR.W	$140(A0)
	 CLR.W	$1E0(A0)
	 CLR.W	$280(A0)
	 CLR.W	$320(A0)
	 CLR.W	$20(A0)
	 CLR.W	$C0(A0)
	 CLR.W	$160(A0)
	 CLR.W	$200(A0)
	 CLR.W	$2A0(A0)
	 CLR.W	$340(A0)
	 CLR.W	$40(A0)
	 CLR.W	$E0(A0)
	 CLR.W	$180(A0)
	 CLR.W	$220(A0)
	 CLR.W	$2C0(A0)
	 CLR.W	$360(A0)
	 CLR.W	$60(A0)
	 CLR.W	$100(A0)
	 CLR.W	$1A0(A0)
	 CLR.W	$240(A0)
	 CLR.W	$2E0(A0)
	 CLR.W	$380(A0)
	 ADDQ.W	#8,A0
	 DBF	D0,L3248E
	 
	 MOVE.B	#8,$FF8800
	 MOVE.B	$FF8800,D0
	 ANDI.W	#$F,D0
L32504	 SUBQ.W	#1,(A1)
	 SUBQ.W	#1,$A0(A1)
	 SUBQ.W	#1,$140(A1)
	 SUBQ.W	#1,$1E0(A1)
	 SUBQ.W	#1,$280(A1)
	 SUBQ.W	#1,$320(A1)
	 ADDQ.W	#8,A1
	 DBF	D0,L32504
	 ADDA.L	#$5A2,A2
	 MOVEA.L	A2,A1
	 MOVEA.L	A2,A0
	 MOVE.W	#3,D0
L3252E	 CLR.W	(A0)
	 CLR.W	$A0(A0)
	 CLR.W	$140(A0)
	 CLR.W	$1E0(A0)
	 CLR.W	$280(A0)
	 CLR.W	$320(A0)
	 CLR.W	$20(A0)
	 CLR.W	$C0(A0)
	 CLR.W	$160(A0)
	 CLR.W	$200(A0)
	 CLR.W	$2A0(A0)
	 CLR.W	$340(A0)
	 CLR.W	$40(A0)
	 CLR.W	$E0(A0)
	 CLR.W	$180(A0)
	 CLR.W	$220(A0)
	 CLR.W	$2C0(A0)
	 CLR.W	$360(A0)
	 CLR.W	$60(A0)
	 CLR.W	$100(A0)
	 CLR.W	$1A0(A0)
 	 CLR.W	$240(A0)
	 CLR.W	$2E0(A0)
	 CLR.W	$380(A0)
	 ADDQ.W	#8,A0
	 DBF	D0,L3252E
 
	 MOVE.B	#9,$FF8800
	 MOVE.B	$FF8800,D0
	 ANDI.W	#$F,D0
L325A4	 SUBQ.W	#1,(A1)
	 SUBQ.W	#1,$A0(A1)
	 SUBQ.W	#1,$140(A1)
	 SUBQ.W	#1,$1E0(A1)
	 SUBQ.W	#1,$280(A1)
	 SUBQ.W	#1,$320(A1)
	 ADDQ.W	#8,A1
	 DBF	D0,L325A4
 	  ADDA.L	#$5A2,A2
	 MOVEA.L	A2,A1
	 MOVEA.L	A2,A0
	 MOVE.W	#3,D0
L325CE	 CLR.W	(A0)
	 CLR.W	$A0(A0)
	 CLR.W	$140(A0)
	 CLR.W	$1E0(A0)
	 CLR.W	$280(A0)
	 CLR.W	$320(A0)
	 CLR.W	$20(A0)
	 CLR.W	$C0(A0)
	 CLR.W	$160(A0)
	 CLR.W	$200(A0)
	 CLR.W	$2A0(A0)
	 CLR.W	$340(A0)
	 CLR.W	$40(A0)
	 CLR.W	$E0(A0)
	 CLR.W	$180(A0)
	 CLR.W	$220(A0)
	 CLR.W	$2C0(A0)
	 CLR.W	$360(A0)
	 CLR.W	$60(A0)
	 CLR.W	$100(A0)
	 CLR.W	$1A0(A0)
	 CLR.W	$240(A0)
	 CLR.W	$2E0(A0)
	 CLR.W	$380(A0)
	 ADDQ.W	#8,A0
	 DBF	D0,L325CE
	 MOVE.B	#$A,$FF8800
	 MOVE.B	$FF8800,D0
	 ANDI.W	#$F,D0
L32644	 SUBQ.W	#1,(A1)
	 SUBQ.W	#1,$A0(A1)
	 SUBQ.W	#1,$140(A1)
	 SUBQ.W	#1,$1E0(A1)
	 SUBQ.W	#1,$280(A1)
	 SUBQ.W	#1,$320(A1)
	 ADDQ.W	#8,A1
	 DBF	D0,L32644

; this must be the cycling colours
; ----------------------------------------------------------------------- ;
no_bars	cmpi.l	#$54,count			; count done ?
	bne.s	inc_cnt				; keep counting
	clr.l	count				; reset counter
inc_cnt	lea	big_pal,a0			; big pal
	lea	cpal_1,a1			; new registers
	adda.l	count,a0			; get new pal colour
	addq.l	#2,count			; pointer to next colour
	movem.l	(a0),d0-d7/a2-a6		; store a0
	movem.l	d0-d7/a2-a6,(a1)		; into a1
	movem.l	$34(a0),d0-d2			; plus some more
	movem.l	d0-d2,$34(a1)			;       ''
	movem.l	(a7)+,d0-d7/a0-a6		; restore registers
	move.l	old_70,-(a7)			; and continue
	rts					; end of vbl!
; ----------------------------------------------------------------------- ;
rast_on	move.b	$fffffa07.w,old_07		; save old 07
	move.b	$fffffa09.w,old_09		;  &	   09
	move.b	$fffffa0f.w,old_0f		;  &	   0f
	move.b	$fffffa11.w,old_11		;  &	   11
	move.b	$fffffa1b.w,old_1b		;  &	   1b
	andi.b	#$df,$fffffa09.w		; turn off
	andi.b	#$fe,$fffffa07.w		; turn off
	move.l	#nul_120,$120.w			; new data
	ori.b	#1,$fffffa07.w			; turn on
	ori.b	#1,$fffffa13.w			; turn on
	rts					; return
; ----------------------------------------------------------------------- ;
ras_off	move	sr,-(a7)
	move.w	#$2700,sr
	move.b	old_07,$fffffa07.w
	move.b	old_09,$fffffa09.w
	move.b	old_0f,$fffffa0f.w
	move.b	old_11,$fffffa11.w
	move.b	old_1b,$fffffa1b.w
	move.l	old_120,$120.w
	move.w	(a7)+,sr
	rts
; ----------------------------------------------------------------------- ;
nul_120	rte

L32748	MOVE.B	#0,$FFFFFA1B			; timer b off
	MOVE.W	bar_01,$FF8240			; bar pal1
	MOVE.B	#1,$FFFA21			; last scan line +1
	MOVE.L	#L3277C,$120.W			; next vector
	MOVE.B	#8,$FFFFFA1B 			; timer b on
	BCLR	#0,$FFFFFA0F			; end of interupt
	RTE					; do next one

L3277C	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_02,$FF8240
	MOVE.L	#L327A8,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L327A8	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_03,$FF8240
	MOVE.L	#L327D4,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L327D4	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_04,$FF8240
	MOVE.L	#L32800,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32800	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_05,$FF8240
	MOVE.L	#L3282C,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L3282C	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_06,$FF8240
	MOVE.L	#L32858,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32858	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_07,$FF8240
	MOVE.L	#L32884,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32884	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_08,$FF8240
	MOVE.L	#L328B0,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L328B0	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_09,$FF8240
	MOVE.L	#L328DC,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L328DC	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_10,$FF8240
	MOVE.L	#L32908,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32908	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_11,$FF8240
	MOVE.L	#L32934,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32934	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_12,$FF8240
	MOVE.L	#L32960,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32960	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_13,$FF8240
	MOVE.L	#L3298C,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L3298C	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_14,$FF8240
	MOVE.L	#L329B8,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L329B8	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_15,$FF8240
	MOVE.L	#L329E4,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L329E4	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_16,$FF8240
	MOVE.L	#L32A10,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32A10	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_17,$FF8240
	MOVE.L	#L32A3C,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32A3C	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_18,$FF8240
	MOVE.L	#L32A68,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32A68	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_19,$FF8240
	MOVE.L	#L32A94,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32A94	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_20,$FF8240
	MOVE.L	#L32AC0,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32AC0	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_21,$FF8240
	MOVE.L	#L32AEC,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32AEC	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_22,$FF8240
	MOVE.L	#L32B18,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32B18	MOVE.B	#0,$FFFFFA1B
	MOVE.W	bar_23,$FF8240
	MOVE.L	#L32B44,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32B44	MOVE.B	#0,$FFFFFA1B
	move.w	bar_24,$FF8240
	MOVE.L	#L32B70,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE


; no problems from here on

; this is the cycling colours raster - at screen line ...

L32B70	MOVE.B	#0,$FFFFFA1B			; timer b off
	move.w	piccy+2,$ffff8240.w		; black border
	MOVE	SR,-(A7)			; save SR
	MOVEM.L	D0-D1/A0,-(A7)			; save d0,d1,a0
	MOVE.B	#$AF,D1				; d1=175
	MOVE.B	L337BA,D0			; current raster line
	SUB.B	D0,D1				; new line = 175 - current
	MOVE.B	D1,$FFFFFA21			; scan line to cycle
	MOVE.L	#no_bord,$120.W			; next vector
	MOVEM.L	(A7)+,D0-D1/A0			; restore regs
	MOVE.W	(A7)+,SR			; restore sr
	MOVE.B	#8,$FFFFFA1B			; timer b on
	BCLR	#0,$FFFFFA0F			; end of interupt
	RTE					; byb bye


no_bord	CLR.B	$FFFFFA1B
	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFFFA21,A0
	MOVE.B	#$C8,(A0)
	MOVE.B	#8,$FFFFFA1B
	MOVE.B	(A0),D0
L32BD8	CMP.B	(A0),D0
	BEQ	L32BD8
	MOVE.B	#$FC,$FFFF820A
	MOVE.W	#2,D0
L32BEA	NOP
	DBF	D0,L32BEA
	MOVE.B	#$FE,$FFFF820A
	MOVEM.L	(A7)+,D0/A0
	MOVE.B	#0,$FFFFFA1B
	MOVE.B	#1,$FFFFFA21
	MOVE.L	#L32C26,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE


L32C26	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_1,$FF8250
	MOVE.W	cpal_1,$FF8252
	MOVE.W	cpal_1,$FF8254
	MOVE.W	cpal_1,$FF8258
	MOVE.L	#L32C70,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32C70	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_2,$FF8250
	MOVE.W	cpal_2,$FF8252
	MOVE.W	cpal_2,$FF8254
	MOVE.W	cpal_2,$FF8258
	MOVE.L	#L32CBA,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32CBA	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_3,$FF8250
	MOVE.W	cpal_3,$FF8252
	MOVE.W	cpal_3,$FF8254
	MOVE.W	cpal_3,$FF8258
	MOVE.L	#L32D04,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32D04	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$222,$FF8242
	MOVE.W	cpal_4,$FF8250
	MOVE.W	cpal_4,$FF8252
	MOVE.W	cpal_4,$FF8254
	MOVE.W	cpal_4,$FF8258
	MOVE.L	#L32D56,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32D56	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$444,$FF8242
	MOVE.W	cpal_5,$FF8250
	MOVE.W	cpal_5,$FF8252
	MOVE.W	cpal_5,$FF8254
	MOVE.W	cpal_5,$FF8258
	MOVE.L	#L32DA8,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32DA8	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$777,$FF8242
	MOVE.W	cpal_6,$FF8250
	MOVE.W	cpal_6,$FF8252
	MOVE.W	cpal_6,$FF8254
	MOVE.W	cpal_6,$FF8258
	MOVE.L	#L32DFA,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32DFA	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$777,$FF8242
	MOVE.W	cpal_7,$FF8250
	MOVE.W	cpal_7,$FF8252
	MOVE.W	cpal_7,$FF8254
	MOVE.W	cpal_7,$FF8258
	MOVE.L	#L32E4C,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32E4C	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$444,$FF8242
	MOVE.W	cpal_8,$FF8250
	MOVE.W	cpal_8,$FF8252
	MOVE.W	cpal_8,$FF8254
	MOVE.W	cpal_8,$FF8258
	MOVE.L	#L32E9E,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32E9E	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$222,$FF8242
	MOVE.W	cpal_9,$FF8250
	MOVE.W	cpal_9,$FF8252
	MOVE.W	cpal_9,$FF8254
	MOVE.W	cpal_9,$FF8258
	MOVE.L	#L32EF0,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32EF0	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_10,$FF8250
	MOVE.W	cpal_10,$FF8252
	MOVE.W	cpal_10,$FF8254
	MOVE.W	cpal_10,$FF8258
	MOVE.L	#L32F3A,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32F3A	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_11,$FF8250
	MOVE.W	cpal_11,$FF8252
	MOVE.W	cpal_11,$FF8254
	MOVE.W	cpal_11,$FF8258
	MOVE.L	#L32F84,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32F84	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_12,$FF8250
	MOVE.W	cpal_12,$FF8252
	MOVE.W	cpal_12,$FF8254
	MOVE.W	cpal_12,$FF8258
	MOVE.L	#L32FCE,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L32FCE	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$22,$FF8244
	MOVE.W	cpal_13,$FF8250
	MOVE.W	cpal_13,$FF8252
	MOVE.W	cpal_13,$FF8254
	MOVE.W	cpal_13,$FF8258
	MOVE.L	#L33020,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33020	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$44,$FF8244
	MOVE.W	cpal_14,$FF8250
	MOVE.W	cpal_14,$FF8252
	MOVE.W	cpal_14,$FF8254
	MOVE.W	cpal_14,$FF8258
	MOVE.L	#L33072,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33072	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$77,$FF8244
	MOVE.W	cpal_15,$FF8250
	MOVE.W	cpal_15,$FF8252
	MOVE.W	cpal_15,$FF8254
	MOVE.W	cpal_15,$FF8258
	MOVE.L	#L330C4,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L330C4	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$77,$FF8244
	MOVE.W	cpal_16,$FF8250
	MOVE.W	cpal_16,$FF8252
	MOVE.W	cpal_16,$FF8254
	MOVE.W	cpal_16,$FF8258
	MOVE.L	#L33116,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33116	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$44,$FF8244
	MOVE.W	cpal_17,$FF8250
	MOVE.W	cpal_17,$FF8252
	MOVE.W	cpal_17,$FF8254
	MOVE.W	cpal_17,$FF8258
	MOVE.L	#L33168,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33168	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$22,$FF8244
	MOVE.W	cpal_18,$FF8250
	MOVE.W	cpal_18,$FF8252
	MOVE.W	cpal_18,$FF8254
	MOVE.W	cpal_18,$FF8258
	MOVE.L	#L331BA,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L331BA	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_19,$FF8250
	MOVE.W	cpal_19,$FF8252
	MOVE.W	cpal_19,$FF8254
	MOVE.W	cpal_19,$FF8258
	MOVE.L	#L33204,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33204	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_20,$FF8250
	MOVE.W	cpal_20,$FF8252
	MOVE.W	cpal_20,$FF8254
	MOVE.W	cpal_20,$FF8258
	MOVE.L	#L3324E,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L3324E	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_21,$FF8250
	MOVE.W	cpal_21,$FF8252
	MOVE.W	cpal_21,$FF8254
	MOVE.W	cpal_21,$FF8258
	MOVE.L	#L33298,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33298	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$220,$FF8248
	MOVE.W	cpal_22,$FF8250
	MOVE.W	cpal_22,$FF8252
	MOVE.W	cpal_22,$FF8254
	MOVE.W	cpal_22,$FF8258
	MOVE.L	#L332EA,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L332EA	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$440,$FF8248
	MOVE.W	cpal_23,$FF8250
	MOVE.W	cpal_23,$FF8252
	MOVE.W	cpal_23,$FF8254
	MOVE.W	cpal_23,$FF8258
	MOVE.L	#L3333C,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L3333C	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$770,$FF8248
	MOVE.W	cpal_24,$FF8250
	MOVE.W	cpal_24,$FF8252
	MOVE.W	cpal_24,$FF8254
	MOVE.W	cpal_24,$FF8258
	MOVE.L	#L3338E,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L3338E	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$770,$FF8248
	MOVE.W	cpal_25,$FF8250
	MOVE.W	cpal_25,$FF8252
	MOVE.W	cpal_25,$FF8254
	MOVE.W	cpal_25,$FF8258
	MOVE.L	#L333E0,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L333E0	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$440,$FF8248
	MOVE.W	cpal_26,$FF8250
	MOVE.W	cpal_26,$FF8252
	MOVE.W	cpal_26,$FF8254
	MOVE.W	cpal_26,$FF8258
	MOVE.L	#L33432,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33432	MOVE.B	#0,$FFFFFA1B
	MOVE.W	#$220,$FF8248
	MOVE.W	cpal_27,$FF8250
	MOVE.W	cpal_27,$FF8252
	MOVE.W	cpal_27,$FF8254
	MOVE.W	cpal_27,$FF8258
	MOVE.L	#L33484,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33484	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_28,$FF8250
	MOVE.W	cpal_28,$FF8252
	MOVE.W	cpal_28,$FF8254
	MOVE.W	cpal_28,$FF8258
	MOVE.L	#L334CE,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L334CE	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_29,$FF8250
	MOVE.W	cpal_29,$FF8252
	MOVE.W	cpal_29,$FF8254
	MOVE.W	cpal_29,$FF8258
	MOVE.L	#L33518,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33518	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_30,$FF8250
	MOVE.W	cpal_30,$FF8252
	MOVE.W	cpal_30,$FF8254
	MOVE.W	cpal_30,$FF8258
	MOVE.L	#L33562,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L33562	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_31,$FF8250
	MOVE.W	cpal_31,$FF8252
	MOVE.W	cpal_31,$FF8254
	MOVE.W	cpal_31,$FF8258
	MOVE.L	#L335AC,$120.W
	MOVE.B	#8,$FFFFFA1B
	BCLR	#0,$FFFFFA0F
	RTE

L335AC	MOVE.B	#0,$FFFFFA1B
	MOVE.W	cpal_32,$FF8250
	MOVE.W	cpal_32,$FF8252
	MOVE.W	cpal_32,$FF8254
	MOVE.W	cpal_32,$FF8258
	BCLR	#0,$FFFFFA0F
	RTE

	section data
big_pal	DC.B	0,1,0,2,0,3,0,4
	DC.B	0,5,0,6,0,7,0,7
	DC.B	0,$17,0,$27,0,$37,0,$47
	DC.B	0,$57,0,$67,0,$77,1,$76
	DC.B	2,$75,3,$74,4,$73,5,$72
	DC.B	6,$71,7,$70,7,$61,7,$52
	DC.B	7,$43,7,$34,7,$25,7,$16
	DC.B	7,7,7,6,7,5,7,4
	DC.B	7,3,7,2,7,1,7,0
	DC.B	6,0,5,0,4,0,3,0
	DC.B	2,0,1,0,0,1,0,2
	DC.B	0,3,0,4,0,5,0,6
	DC.B	0,7,0,7,0,$17,0,$27
	DC.B	0,$37,0,$47,0,$57,0,$67
	DC.B	0,$77,1,$76,2,$75,3,$74
	DC.B	4,$73,5,$72,6,$71,7,$70
	DC.B	7,$61,7,$52,7,$43,7,$34
	DC.B	7,$25,7,$16,7,7,7,6
	DC.B	7,5,7,4

; bouncing bar raster

bar_01	dc.w	$200
bar_02	dc.w	$300
bar_03	dc.w	$400
bar_04	dc.w	$500
bar_05	dc.w	$600
bar_06	dc.w	$700
bar_07	dc.w	$722
bar_08	dc.w	$733
bar_09	dc.w	$744
bar_10	dc.w	$755
bar_11	dc.w	$766
bar_12	dc.w	$777
bar_13	dc.w	$777
bar_14	dc.w	$766
bar_15	dc.w	$755
bar_16	dc.w	$744
bar_17	dc.w	$733
bar_18	dc.w	$722
bar_19	dc.w	$700
bar_20	dc.w	$600
bar_21	dc.w	$500
bar_22	dc.w	$400
bar_23	dc.w	$300
bar_24	dc.w	$200


bar_line
	dc.b	$AD,$AA,$A7,$A4,$A1,$9E,$9B,$98
	dc.b	$96,$93,$90,$8D,$8A,$88,$85,$82
	dc.b	$7F,$7C,$7A,$77,$74,$72,$6F,$6C
	dc.b	$6A,$67,$64,$62,$5F,$5D,$5A,$58
	dc.b	$55,$53,$50,$4E,$4B,$49,$47,$44
	dc.b	$42,$40,$3E,$3C,$39,$37,$35,$33
	dc.b	$31,$2F,$2D,$2B,$29,$28,$26,$24
	dc.b	$22,$21,$1F,$1D,$1C,$1A,$19,$17
	dc.b	$16,$15,$13,$12,$11,$10,$0E,$0D
	dc.b	$0C,$0B,$0A,$09,$08,$08,$07,$06
	dc.b	$05,$05,$04,$04,$03,$03,$02,$02
	dc.b	$01,$01,$01,$01,$01,$01,$02,$02
	dc.b	$03,$03,$04,$04,$05,$05,$06,$07
	dc.b	$08,$08,$09,$0A,$0B,$0C,$0D,$0E
	dc.b	$10,$11,$12,$13,$15,$16,$17,$19
	dc.b	$1A,$1C,$1D,$1F,$21,$22,$24,$26
	dc.b	$28,$29,$2B,$2D,$2F,$31,$33,$35
	dc.b	$37,$39,$3C,$3E,$40,$42,$44,$47
	dc.b	$49,$4B,$4E,$50,$53,$55,$58,$5A
	dc.b	$5D,$5F,$62,$64,$67,$6A,$6C,$6F
	dc.b	$72,$74,$77,$7A,$7C,$7F,$82,$85
	dc.b	$88,$8A,$8D,$90,$93,$96,$98,$9B
	dc.b	$9E,$A1,$A4,$A7,$AA,$00,$00,$00
	even
	
L337A2	DC.B	0,0,0,$D,0,$1B,0,$2B
	DC.B	0,$41

L337AC	DC.B	0,0,0,$1A,0,$36,0,$56
	DC.B	0,$82

L337B6	DC.B	0,0
L337B8	DC.B	0,0
L337BA	DC.B	0,0

	section bss
	
old_07	ds.b	1
old_09	ds.b	1
old_0f	ds.b	1
old_11	ds.b	1
st_htz	ds.b	1
cpal_1	ds.w	1
cpal_2	ds.w	1
cpal_3	ds.w	1
cpal_4	ds.w	1
cpal_5	ds.w	1
cpal_6	ds.w	1
cpal_7	ds.w	1
cpal_8	ds.w	1
cpal_9	ds.w	1
cpal_10	ds.w	1
cpal_11	ds.w	1
cpal_12	ds.w	1
cpal_13	ds.w	1
cpal_14	ds.w	1
cpal_15	ds.w	1
cpal_16	ds.w	1
cpal_17	ds.w	1
cpal_18	ds.w	1
cpal_19	ds.w	1
cpal_20	ds.w	1
cpal_21	ds.w	1
cpal_22	ds.w	1
cpal_23	ds.w	1
cpal_24	ds.w	1
cpal_25	ds.w	1
cpal_26	ds.w	1
cpal_27	ds.w	1
cpal_28	ds.w	1
cpal_29	ds.w	1
cpal_30	ds.w	1
cpal_31	ds.w	1
cpal_32	ds.w	1
wait	ds.w	1
bars_on	ds.w	1
hz_flag	ds.w	1
speedo	ds.w	1
srl_spd	ds.w	1
cur_mus	ds.w	1
old_120	ds.l	1
old_70	ds.l	1
old_1b	ds.l	1
temp_sc	ds.l	1
build	ds.l	1
phy_scn	ds.l	1
spr_stk	ds.l	1
count	ds.l	1
cur_scn	ds.l	1
def_scn	ds.l	1	
buffer	ds.l	16

	section data

htz_scl	dc.b	"  - "		
tog_htz	dc.b	"60 HZ - @",0	
	
text	incbin	text.blk
	
	EVEN	

file1	DC.B	"prog1.prg",0
file2	DC.B	"prog2.prg",0
env	dc.l	0	
com	dc.l	0

	section data

piccy	incbin	piccy1.pi1
music	incbin	chamber.mus
font	incbin	font.dat

	END
		