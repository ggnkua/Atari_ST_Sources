	****************************
	* (C)1991 MISFITS SOFTWARE *
	*      Code : EPSILON      *
	*      Gfx  :  VIXIT       *
	*      Music: EPIC         *
	****************************
 
	include a:\util.lib
	
debug	equ 0	0=Debug Off/1=Debug On.
prg_file	equ 1	0=Screen demo/1=Demo prg.

	ifeq debug
	opt o+,w-,d-
	endc
	
	ifne prg_file
	supexec main
	pterm
	elseif
	org $12345678
	opt o+,w-,d-
debug	equ 0
	endc
	
main	jsr clr_bss
	jsr init_var
	jsr clr_screen
	jsr init_smp
	jsr init_snd
	jsr init
	lea pic_1+34,a5
	jsr decomp
	lea pic_1+2,a0
	jsr fade_out
	move.b #5,$fffffa19.w
	move.b #5,$fffffa1f.w
	move.w #50*10,d0
timer	jsr wait_vbl
	dbra d0,timer
	jsr fade_in
	lea pic_2+34,a5
	jsr decomp
	lea pic_2+2,a0
	jsr fade_out
loop	cmp.b #$39,$fffffc02.w
	bne.s loop
	jsr fade_in
	jsr restore
	setscreen2 #0,#$78000
	lea pic_3+34,a5
	move.l #$78000,screen1
	jsr decomp
	lea pic_3+2,a0
	jsr fade_out
	move.l old_vbl,$70.w
	rts
	
clr_bss	lea old_vbl,a0
	lea ecran,a1
clr_bss_s1	clr.l (a0)+
	cmp.l a1,a0
	blt.s clr_bss_s1
	rts

init_var	move.l #ecran,d0
	clr.b d0
	move.l d0,screen1
	lea track,a0
	move.l (a0)+,ad_sample
	move.l (a0)+,lg_smp
	move.l a0,pt_track
	lea pic_1,a0
	lea pic_2,a1
	moveq #15,d0
init_vars1	and.w #$777,(a0)+
	and.w #$777,(a1)+
	dbra d0,init_vars1
	rts
	
init	move.w #$2700,sr
	getphys2 oldphys
	getrez2 oldrez
	savepal oldpal
	mouseoff
	move.l $70.w,old_vbl
	move.l $134.w,old134
	move.b $fffffa07.w,old07
	move.b $fffffa09.w,old09
	move.b $fffffa13.w,old13
	move.b $fffffa15.w,old15
	move.b $fffffa17.w,old17
	move.b $fffffa19.w,old19
	move.b $fffffa1f.w,old1f
	clr.b $fffffa07.w
	clr.b $fffffa09.w
	clr.b $fffffa13.w
	clr.b $fffffa15.w
	move.b #$21,$fffffa07.w
	move.b #$21,$fffffa13.w
	bclr #3,$fffffa17.w
	move.l #vbl2,$70.w
	move.l #play_smp,$134.w
	loadpal null
	move.w #$2300,sr
	jsr wait_vbl
	setscreen2 #0,screen1
	move.l #vbl,$70.w
	rts
	
restore	move.l #vbl2,$70.w
	jsr wait_vbl
	move.l old_hbl,$120.w
	move.l old134,$134.w
	move.b old07,$fffffa07.w
	move.b old09,$fffffa09
	move.b old13,$fffffa13.w
	move.b old15,$fffffa15.w
	move.b old17,$fffffa07.w
	move.b old19,$fffffa19.w
	move.b old1f,$fffffa1f.w
	soundoff
	rts
	
clr_screen	move.l screen1,a0
	move.w #32000/4-1,d0
clr_scrs1	clr.l (a0)+
	dbra d0,clr_scrs1
	rts
	
wait_vbl	sf.b pt_vbl
wait_vbls1	tst.b pt_vbl
	beq.s wait_vbls1
	rts
	
vbl2	st.b pt_vbl
	rte
	
vbl	st.b pt_vbl
	rte

;
; Chargement et Decompactage d'image pc1
;
decomp	move.l screen1,a3
dec10	move.l #$c7,d4
	move.l #6,a0
	moveq #4,d6
	moveq #$28,d7
dec9	clr.b d1
	move.l a3,a4
dec8	move.l a4,-(sp)
	clr.b d3
dec7	move.b (a5)+,d0
	tst.b d0
	bmi.s dec1
	addq.b #1,d0
dec3	move.b (a5)+,(a4)+
	addq.b #1,d3
	move.l a4,d5
	btst #0,d5
	bne.s dec2
	add.l a0,a4
dec2	subq.b #1,d0
	bne.s dec3
	bra.s dec4
dec1	neg.b d0
	addq.b #1,d0
	move.b (a5)+,d2
dec6	move.b d2,(a4)+
	addq.b #1,d3
	move.l a4,d5
	btst #0,d5
	bne.s dec5
	add.l a0,a4
dec5	subq.b #1,d0
	bne.s dec6
dec4	cmp.b d7,d3
	BNE.S DEC7
	move.l (sp)+,a4
	addq.l #2,a4
	addq.b #1,d1
	cmp.b d6,d1
	bne.s dec8
	add.l #$a0,a3
	dbra d4,dec9
	rts

;
; fondu de la palette vers le noir.
;
fade_in	moveq #7,d3
fadeins1	jsr wait_vbl
	jsr wait_vbl
	jsr wait_vbl
	jsr wait_vbl
	lea $ffff8240,a0
	moveq #15,d4
fadeins2	move.w (a0),d0
	move.w d0,d1
	move.w d1,d2
	lsr.w #8,d0
	and.w #7,d0
	lsr.w #4,d1
	and.w #7,d1
	and.w #7,d2
	subq.w #1,d0
	bpl.s fadeins3
	moveq #0,d0
fadeins3	subq.w #1,d1
	bpl.s fadeins4
	moveq #0,d1
fadeins4	subq.w #1,d2
	bpl.s fadeins5
	moveq #0,d2
fadeins5	lsl.w #8,d0
	lsl.w #4,d1
	or.w d1,d2
	or.w d2,d0
	move.w d0,(a0)+
	dbra d4,fadeins2
	dbra d3,fadeins1
	rts
;
; Fondu du noir vers une palette A0
;
fade_out	move.l a0,tmp_pal
	moveq #7,d3
fdout2s1	jsr wait_vbl
	jsr wait_vbl
	jsr wait_vbl
	jsr wait_vbl
	move.l tmp_pal,a0
	lea $ffff8240,a1
	moveq #15,d4
fdout2s2	move.w (a0)+,d0
	move.w d0,d1
	move.w d0,d2
	lsr.w #8,d0
	lsr.w #4,d1
	and.w #7,d0
	and.w #7,d1
	and.w #7,d2
	sub.w d3,d0
	bpl.s fdout2s3
	moveq #0,d0
fdout2s3	sub.w d3,d1
	bpl.s fdout2s4
	moveq #0,d1
fdout2s4	sub.w d3,d2
	bpl.s fdout2s5
	moveq #0,d2
fdout2s5	lsl.w #8,d0
	lsl.w #4,d1
	or.w d2,d1
	or.w d1,d0
	move.w d0,(a1)+
	dbra d4,fdout2s2
	dbra d3,fdout2s1
	rts

init_smp	lea	sample,a0
init_smps1	add.b	#$80,(a0)+
	cmp.l	#end_sample,a0
	bne.s	init_smps1
	rts

PLAY_SMP	MOVEM.L	D0-D1/a0,-(SP)
play_smps2	moveq	#0,d0
	move.l	ad_sample,a0
	move.b	(a0)+,d0
	cmp.l	lg_smp,a0
	bne.s	play_smps1
play_smps3	move.l	pt_track,a0
	move.l	(a0)+,d0
	bpl.s	play_smps4
	move.l	#track,pt_track
	bra.s	play_smps3
play_smps4	move.l	d0,ad_sample
	move.l	(a0)+,lg_smp
	move.l	a0,pt_track
	bra.s	play_smps2
play_smps1	move.l	a0,ad_sample
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	$ffff8800.w,a0
	MOVE.L	snd_out(pc,D0.W),D1	GET DATA #1
	MOVEP.L	D1,0(A0)		PLAY #1
	MOVE.W	snd_out+4(pc,D0.W),D1	GET DATA #2
	MOVEP.W	D1,0(A0)		PLAY #2
	movem.l	(sp)+,d0-d1/a0
	RTE

SND_OUT	dc.w	$80c,$90b,$a09,0,$80c,$90b,$a09,0
	dc.w	$80d,$908,$a08,0,$80b,$90b,$a0b,0
	dc.w	$80d,$909,$a05,0,$80c,$90b,$a08,0
	dc.w	$80d,$909,$a02,0,$80d,$908,$a06,0
	dc.w	$80c,$90b,$a07,0,$80d,$907,$a07,0
	dc.w	$80c,$90b,$a06,0,$80c,$90a,$a09,0
	dc.w	$80b,$90b,$a0a,0,$80c,$90b,$a02,0
	dc.w	$80c,$90b,$a00,0,$80c,$90a,$a08,0

	dc.w	$80d,$906,$a04,0,$80d,$905,$a05,0
	dc.w	$80d,$905,$a04,0,$80c,$909,$a09,0
	dc.w	$80d,$904,$a03,0,$80b,$90b,$a09,0
	dc.w	$80c,$90a,$a05,0,$80b,$90a,$a0a,0
	dc.w	$80c,$909,$a08,0,$80b,$90b,$a08,0
	dc.w	$80c,$90a,$a00,0,$80c,$90a,$a00,0
	dc.w	$80c,$909,$a07,0,$80b,$90b,$a07,0
	dc.w	$80c,$909,$a06,0,$80b,$90b,$a06,0

	dc.w	$80b,$90a,$a09,0,$80b,$90b,$a05,0
	dc.w	$80a,$90a,$a0a,0,$80b,$90b,$a02,0
	dc.w	$80b,$90a,$a08,0,$80c,$907,$a07,0
	dc.w	$80c,$908,$a04,0,$80c,$907,$a06,0
	dc.w	$80b,$909,$a09,0,$80c,$906,$a06,0
	dc.w	$80a,$90a,$a09,0,$80c,$907,$a03,0
	dc.w	$80b,$90a,$a05,0,$80b,$909,$a08,0
	dc.w	$80b,$90a,$a03,0,$80a,$90a,$a08,0

	dc.w	$80b,$90a,$a00,0,$80b,$909,$a07,0
	dc.w	$80b,$908,$a08,0,$80a,$90a,$a07,0
	dc.w	$80a,$909,$a09,0,$80c,$901,$a01,0
	dc.w	$80a,$90a,$a06,0,$80b,$908,$a07,0
	dc.w	$80a,$90a,$a05,0,$80a,$909,$a08,0
	dc.w	$80a,$90a,$a02,0,$80a,$90a,$a01,0
	dc.w	$80a,$90a,$a00,0,$809,$909,$a09,0
	dc.w	$80a,$908,$a08,0,$80b,$908,$a01,0

	dc.w	$80a,$909,$a06,0,$80b,$907,$a04,0
	dc.w	$80a,$909,$a05,0,$809,$909,$a08,0
	dc.w	$80a,$909,$a03,0,$80a,$908,$a06,0
	dc.w	$80a,$909,$a00,0,$809,$909,$a07,0
	dc.w	$809,$908,$a08,0,$80a,$908,$a04,0
	dc.w	$809,$909,$a06,0,$80a,$908,$a01,0
	dc.w	$809,$909,$a05,0,$809,$908,$a07,0
	dc.w	$808,$908,$a08,0,$809,$909,$a02,0

	dc.w	$809,$908,$a06,0,$809,$909,$a00,0
	dc.w	$809,$907,$a07,0,$808,$908,$a07,0
	dc.w	$809,$907,$a06,0,$809,$908,$a02,0
	dc.w	$808,$908,$a06,0,$809,$906,$a06,0
	dc.w	$808,$907,$a07,0,$808,$908,$a04,0
	dc.w	$808,$907,$a06,0,$808,$908,$a02,0
	dc.w	$807,$907,$a07,0,$808,$906,$a06,0
	dc.w	$808,$907,$a04,0,$807,$907,$a06,0

	dc.w	$808,$906,$a05,0,$808,$906,$a04,0
	dc.w	$807,$906,$a06,0,$807,$907,$a04,0
	dc.w	$808,$905,$a04,0,$806,$906,$a06,0
	dc.w	$807,$906,$a04,0,$807,$905,$a05,0
	dc.w	$806,$906,$a05,0,$806,$906,$a04,0
	dc.w	$806,$905,$a05,0,$806,$906,$a02,0
	dc.w	$806,$905,$a04,0,$805,$905,$a05,0
	dc.w	$806,$905,$a02,0,$805,$905,$a04,0

	dc.w	$805,$904,$a04,0,$805,$905,$a02,0
	dc.w	$804,$904,$a04,0,$804,$904,$a03,0
	dc.w	$804,$904,$a02,0,$804,$903,$a03,0
	dc.w	$803,$903,$a03,0,$803,$903,$a02,0
	dc.w	$803,$902,$a02,0,$802,$902,$a02,0
	dc.w	$802,$902,$a01,0,$801,$901,$a01,0
	dc.w	$802,$901,$a00,0,$801,$901,$a00,0
	dc.w	$801,$900,$a00,0,$800,$900,$a00,0

	dc.w	$80e,$90d,$a0c,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0a,0,$80e,$90d,$a0a,0

	dc.w	$80e,$90d,$a0a,0,$80e,$90d,$a0a,0
	dc.w	$80e,$90c,$a0c,0,$80e,$90d,$a00,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0

	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0a,0,$80e,$90c,$a0a,0
	dc.w	$80e,$90c,$a0a,0,$80e,$90c,$a0a,0
	dc.w	$80d,$90d,$a0c,0,$80d,$90d,$a0c,0
	dc.w	$80e,$90c,$a09,0,$80e,$90c,$a09,0
	dc.w	$80e,$90c,$a05,0,$80e,$90c,$a00,0
	dc.w	$80e,$90c,$a00,0,$80e,$90b,$a0b,0
	dc.w	$80e,$90b,$a0b,0,$80e,$90b,$a0b,0

	dc.w	$80e,$90b,$a0b,0,$80e,$90b,$a0a,0
	dc.w	$80e,$90b,$a0a,0,$80e,$90b,$a0a,0
	dc.w	$80d,$90d,$a0b,0,$80d,$90d,$a0b,0
	dc.w	$80d,$90d,$a0b,0,$80e,$90b,$a09,0
	dc.w	$80e,$90b,$a09,0,$80e,$90b,$a09,0
	dc.w	$80d,$90c,$a0c,0,$80d,$90d,$a0a,0
	dc.w	$80e,$90b,$a07,0,$80e,$90b,$a00,0
	dc.w	$80e,$90b,$a00,0,$80d,$90d,$a09,0

	dc.w	$80d,$90d,$a09,0,$80e,$90a,$a09,0
	dc.w	$80d,$90d,$a08,0,$80d,$90d,$a07,0
	dc.w	$80d,$90d,$a04,0,$80d,$90d,$a00,0
	dc.w	$80e,$90a,$a04,0,$80e,$909,$a09,0
	dc.w	$80e,$909,$a09,0,$80d,$90c,$a0b,0
	dc.w	$80e,$909,$a08,0,$80e,$909,$a08,0
	dc.w	$80e,$909,$a07,0,$80e,$908,$a08,0
	dc.w	$80e,$909,$a01,0,$80c,$90c,$a0c,0

	dc.w	$80d,$90c,$a0a,0,$80e,$908,$a06,0
	dc.w	$80e,$907,$a07,0,$80e,$908,$a00,0
	dc.w	$80e,$907,$a05,0,$80e,$906,$a06,0
	dc.w	$80d,$90c,$a09,0,$80e,$905,$a05,0
	dc.w	$80e,$904,$a04,0,$80d,$90c,$a08,0
	dc.w	$80d,$90b,$a0b,0,$80e,$900,$a00,0
	dc.w	$80d,$90c,$a06,0,$80d,$90c,$a05,0
	dc.w	$80d,$90c,$a02,0,$80c,$90c,$a0b,0

	dc.w	$80c,$90c,$a0b,0,$80d,$90b,$a0a,0
	dc.w	$80d,$90b,$a0a,0,$80d,$90b,$a0a,0
	dc.w	$80d,$90b,$a0a,0,$80c,$90c,$a0a,0
	dc.w	$80c,$90c,$a0a,0,$80c,$90c,$a0a,0
	dc.w	$80d,$90b,$a09,0,$80d,$90b,$a09,0
	dc.w	$80d,$90a,$a0a,0,$80d,$90a,$a0a,0
	dc.w	$80d,$90a,$a0a,0,$80c,$90c,$a09,0
	dc.w	$80c,$90c,$a09,0,$80c,$90c,$a09,0

	dc.w	$80d,$90b,$a06,0,$80c,$90b,$a0b,0
	dc.w	$80c,$90c,$a08,0,$80d,$90b,$a00,0
	dc.w	$80d,$90b,$a00,0,$80c,$90c,$a07,0
	dc.w	$80c,$90c,$a06,0,$80c,$90c,$a05,0
	dc.w	$80c,$90c,$a03,0,$80c,$90c,$a01,0
	dc.w	$80c,$90b,$a0a,0,$80d,$90a,$a05,0
	dc.w	$80d,$90a,$a04,0,$80d,$90a,$a02,0
	dc.w	$80d,$909,$a08,0,$80d,$909,$a08,0

init_SND	MOVE.B	#0,$ffff8800.w	CHANNEL A
	MOVE.B	#0,$ffff8802.w
	MOVE.B	#1,$ffff8800.w
	MOVE.B	#0,$ffff8802.w

	MOVE.B	#2,$ffff8800.w	CHANNEL B
	MOVE.B	#0,$ffff8802.w
	MOVE.B	#3,$ffff8800.w
	MOVE.B	#0,$ffff8802.w

	MOVE.B	#4,$ffff8800.w	CHANNEL C
	MOVE.B	#0,$ffff8802.w
	MOVE.B	#5,$ffff8800.w
	MOVE.B	#0,$ffff8802.w

	MOVE.B	#7,$ffff8800.w	SET UP CHANNEL MIXING & PORT 'A' I/O
	MOVE.B	#$FF,$ffff8802.w

	MOVE.B	#8,$ffff8800.w	SET ALL VOLUMES TO ZERO
	MOVE.B	#0,$ffff8802.w
	MOVE.B	#9,$ffff8800.w
	MOVE.B	#0,$ffff8802.w
	MOVE.B	#10,$ffff8800.w
	MOVE.B	#0,$ffff8802.w
	RTS

	section data
	
sample
d1	incbin a:\present\xenon2.spl
end_sample	equ *
	even
d2	equ d1+$fcc2

PIC_1	incbin a:\present\pic_1.pc1
	even
pic_2	incbin a:\present\pic_2.pc1
	even
pic_3	incbin a:\loader\load.pc1
	even

track	dc.l d1,d1+$fcc2
	dc.l d2,d2+$be40
	dc.l d2,d2+$3e82
	dc.l d2,d2+$be40
	dc.l d2,d2+$3e82
	dc.l d1,d1+$3bd
	dc.l d1,d1+$b37
	dc.l d1,d1+$1033
	dc.l d1,d1+$3bd
	dc.l d1,d1+$b37
	dc.l d1,d1+$3bd
	dc.l d1,d1+$c76
	dc.l -1

	section bss

old_vbl	ds.l 1
old_hbl	ds.l 1
old134	ds.l 1
oldphys	ds.l 1
oldrez	ds.w 1
oldpal	ds.w 16

pt_vbl	ds.b 1
old07	ds.b 1
old09	ds.b 1
old13	ds.b 1
old15	ds.b 1
old17	ds.b 1
old19	ds.b 1
old1f	ds.b 1

screen1	ds.l 1

tmp_pal	ds.l 1

ad_sample	ds.l 1
lg_smp	ds.l 1
pt_track	ds.l 1

null	ds.w 16

	ds.b 256
ecran	equ *
