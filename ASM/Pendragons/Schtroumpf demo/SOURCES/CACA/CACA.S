debug	equ 0	* 0 FINAL,  1 DEBUGGING

	opt o+,w-,d+
	
vsync	macro  

	move.l d0,-(sp)
	move.l $466.w,d0
.\@a	cmp.l $466.w,d0
	beq.s .\@a
	move.l (sp)+,d0
	
	endm

	ifeq debug
	
	opt d-
	
	endc
	
	pea rout(pc)
	move.w #$26,-(sp)
	trap #14
	addq.l #6,sp
	
	clr.w -(sp)
	trap #1
	
rout	move.l #buf_ecr,d0
	and.l #$ffffff00,d0
	add.l #$100,d0
	move.l d0,ecran
	
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,anc_pal
		
	move.b $fffffa07.w,mfp1
	move.b $fffffa09.w,mfp2
	move.b $fffffa0f.w,mfp3
	move.b $fffffa13.w,mfp4
	move.b $fffffa17.w,mfp5
	move.b $fffffa1b.w,mfp6
	move.b $fffffa21.w,mfp7
	
	ifeq debug
	
	sf $fffffa07.w
	sf $fffffa09.w
	
	endc
	
	moveq #0,d0
	jsr musique+$4d2
		
	move.l $44e.w,anc_ecr
	move.l $70.w,anc_vbl
	move.l $120.w,anc_tb
		
	move.w #(((32000/4)/4)-1),d0
	lea screen+34,a0
	move.l ecran,a1
copy_ecr	rept 4
	move.l (a0)+,(a1)+
	endr
	dbf d0,copy_ecr
	
	movem.l screen+2,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	ifne debug
	vsync
	sf $ffff8260.w
	endc
	
	vsync
	
	move.b ecran+1,$ffff8201.w
	move.b ecran+2,$ffff8203.w
	
	move.l #text,txt_pos
	
	move.l #vbl,$70.w
	move.l #it_tb,$120.w
	
	
	move.b #250,$fffffa21.w
	move.b #8,$fffffa1b.w
	
	bclr #3,$fffffa17.w
	bset #0,$fffffa07.w
	bset #0,$fffffa13.w
	
scroll	
	move.l ecran,a1
	lea 44*160(a1),a1
	
	moveq #25,d0
scroll1	
n	set 0
	rept 19
	move.b n+1(a1),n(a1)
	move.b n+8(a1),n+1(a1)
n	set n+8
	endr
	
	lea 160(a1),a1
	
	dbf d0,scroll1
	
	vsync
	vsync
	
	move.l ecran,a1
	lea 44*160(a1),a1
	
	moveq #25,d0
scroll2	
n	set 0
	rept 18
	move.b n+1(a1),n(a1)
	move.b n+8(a1),n+1(a1)
n	set n+8
	endr
	move.b n+1(a1),n(a1)
	
	lea 160(a1),a1
	
	dbf d0,scroll2
	
	vsync
	vsync

	move.l ecran,a1
	lea 44*160(a1),a1
	
	moveq #25,d0
scroll3	
n	set 0
	rept 18
	move.b n+1(a1),n(a1)
	move.b n+8(a1),n+1(a1)
n	set n+8
	endr
	
	lea 160(a1),a1
	
	dbf d0,scroll3
	
	vsync
	vsync
	
	move.l ecran,a1
	lea 44*160(a1),a1
	
	moveq #25,d0
scroll4	
n	set 0
	rept 17
	move.b n+1(a1),n(a1)
	move.b n+8(a1),n+1(a1)
n	set n+8
	endr
	move.b n+1(a1),n(a1)
	
	lea 160(a1),a1
	
	dbf d0,scroll4
	
loop_txt	moveq #0,d0
	move.l txt_pos,a1
	move.b (a1)+,d0
	move.l a1,txt_pos
	
	cmp.b #-1,d0
	bne.s cont
	
	move.l #text,txt_pos
	bra.s loop_txt
	
cont	lea table_fnt,a1
	
	
	lsl.w #2,d0
	
	add.w d0,a1
	
	move.l (a1),a1
	
	move.l ecran,a2
	
	lea (44*160)+144(a2),a2
	
	moveq #25,d0
	
loop_buf	move.l (a1),(a2)
	move.l 4(a1),4(a2)
	move.l 8(a1),8(a2)
	move.l 12(a1),12(a2)
	
	lea 160(a1),a1
	lea 160(a2),a2 
	
	dbf d0,loop_buf

	vsync
	vsync

	cmp.b #$39,$fffffc02.w
	beq.s quit
	
	bra scroll
	
quit	move.l anc_vbl,$70.w
	move.l anc_tb,$120.w
	
	move.b mfp1,$fffffa07.w
	move.b mfp2,$fffffa09.w
	move.b mfp3,$fffffa0f.w
	move.b mfp4,$fffffa13.w
	move.b mfp5,$fffffa17.w
	move.b mfp6,$fffffa1b.w
	move.b mfp7,$fffffa21.w
	
	vsync
	
	move.b anc_ecr+1,$ffff8201.w
	move.b anc_ecr+2,$ffff8203.w
	
	movem.l anc_pal,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	
	pea chut 
	move.w #$20,-(sp)
	trap #14
	addq.l #6,sp
	
	rts
		
vbl
	move.l #it_tb,$120.w
toto:	move.b #1,$fffffa21.w
	move.b #8,$fffffa1b.w
	add.b #1,toto+3
	movem.l d0-d7/a0-a6,-(sp)
	movem.l (sp)+,d0-d7/a0-a6
	
	addq.l #1,$466.w
	
	rte
	
it_tb
*	bchg #1,$ffff820a.w
*	bchg #1,$ffff820a.w
	bchg #1,$ffff8260.w
	bchg #1,$ffff8260.w
	dcb.w 10,$4e71

	move.w #$100,$ffff8240.w
	move.w #$200,$ffff8240.w
	move.w #$300,$ffff8240.w
	move.w #$400,$ffff8240.w
	move.w #$500,$ffff8240.w
	move.w #$600,$ffff8240.w
	move.w #$700,$ffff8240.w
	move.w #$600,$ffff8240.w
	move.w #$500,$ffff8240.w
	move.w #$400,$ffff8240.w
	move.w #$300,$ffff8240.w
	move.w #$200,$ffff8240.w
	move.w #$100,$ffff8240.w
	move.w #$010,$ffff8240.w
	move.w #$020,$ffff8240.w
	move.w #$030,$ffff8240.w
	move.w #$040,$ffff8240.w
	move.w #$050,$ffff8240.w
	move.w #$060,$ffff8240.w
	move.w #$070,$ffff8240.w
	move.w #$060,$ffff8240.w
	move.w #$050,$ffff8240.w
	move.w #$040,$ffff8240.w
	move.w #$030,$ffff8240.w
	move.w #$020,$ffff8240.w
	move.w #$010,$ffff8240.w
	move.w #$000,$ffff8240.w
	
	movem.l d0-d7/a0-a6,-(sp)
	jsr musique+$28
	movem.l (sp)+,d0-d7/a0-a6
	
	
	move.b #0,$fffffa1b.w		
	rte
	
musique	incbin 'd:\musiques\datas\starquak.mus'
	even
	
	section data
	
text	incbin 'a:\sources\caca\text.cod"
	even
	
screen	incbin 'a:\sources\caca\caca.pi1'
	even
	
fonte	incbin 'a:\sources\caca\caca_fnt.pi1'
	even

table_fnt	dc.l fonte+34,fonte+34+16
	dc.l fonte+34+32,fonte+34+48
	dc.l fonte+34+64,fonte+34+80
	dc.l fonte+34+96,fonte+34+112
	dc.l fonte+34+128,fonte+34+144
	dc.l fonte+34+(26*160),fonte+34+(26*160)+16
	dc.l fonte+34+(26*160)+32,fonte+34+(26*160)+48
	dc.l fonte+34+(26*160)+64,fonte+34+(26*160)+80
	dc.l fonte+34+(26*160)+96,fonte+34+(26*160)+112
	dc.l fonte+34+(26*160)+128,fonte+34+(26*160)+144
	dc.l fonte+34+(52*160),fonte+34+(52*160)+16
	dc.l fonte+34+(52*160)+32,fonte+34+(52*160)+48
	dc.l fonte+34+(52*160)+64,fonte+34+(52*160)+80
	dc.l fonte+34+(52*160)+96,fonte+34+(52*160)+112
	dc.l fonte+34+(52*160)+128,fonte+34+(52*160)+144
	even
	
chut	dc.b 7,255,8,0,9,0,10,0,6,0,11,0,12,0,13,0
	even
	
	section bss

buf_ecr	ds.b 32256
ecran	ds.l 1
anc_pal	ds.l 8
anc_vbl	ds.l 1
anc_tb	ds.l 1
anc_ecr	ds.l 1
txt_pos	ds.l 1
mfp1	ds.b 1
mfp2	ds.b 1
mfp3	ds.b 1
mfp4	ds.b 1
mfp5	ds.b 1
mfp6	ds.b 1
mfp7	ds.b 1