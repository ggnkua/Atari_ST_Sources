vsync:	macro 
	move.l	_vsync,d0
.\@l:
	cmp.l	_vsync,d0
	beq.s	.\@l
	endm

	*org $5000
	
	opt w-,o+			*!

	pea rout(pc)		*!
	move.w #$26,-(sp)		*!
	trap #14			*!
	addq.l #6,sp		*!
	
	clr.w -(sp)		*!
	trap #1			*!
	
rout	move.b $ffff8260.w,res	*!
	
	lea debut,a0
	lea fin,a1
eff_bss	clr.w (a0)+
	cmp.l a0,a1
	bne.s eff_bss
	
basse 	move.l #buffer,d0
	and.l #$ffffff00,d0
	add.l #$100,d0
	move.l d0,ecran
	
	move.l #buffer1,d0
	and.l #$ffffff00,d0
	add.l #$100,d0
	move.l d0,ecran1
	
	move.l $44e.w,anc_ecr	*!
	
	move.b #8,$fffffc02.w
	
	move.b $fffffa07.w,mfp1
	move.b $fffffa09.w,mfp2
	move.b $fffffa0f.w,mfp3
	move.b $fffffa13.w,mfp4
	move.b $fffffa17.w,mfp5
	move.b $fffffa1b.w,mfp6
	move.b $fffffa21.w,mfp7

	bset #3,$fffffa17.w
	
	sf $fffffa07.w
	sf $fffffa09.w
	
	movem.l $ffff8240.w,d0-d7	*!
	movem.l d0-d7,anc_pal	*!

	move.l $70.w,anc_vbl
	move.l #play_zik,$70.w
	
	movem.l fonte_v+(120*89),d0-d7
	movem.l d0-d7,$ffff8240.w
	
	vsync
	sf $ffff8260.w		*!
	vsync
	
	move.b ecran1+1,$ffff8201.w
	move.b ecran1+2,$ffff8203.w
	
	move.l ecran1,a1
	lea menu,a0
	lea 32(a0),a2
	move.w #(((32000/4)/4)-1),d0
copy_gfx	rept 4
	move.l (a2)+,(a1)+
	endr
	dbf d0,copy_gfx

	lea (a0),a6
	jsr colorin
	
	move.b #30,fin_car_v
	move.b #4,fin_car
	move.b #3,fin_car1
	move.b #16,fin_car_m
	move.l #text_v,pos_txt_v
	move.l #text,pos_txt
	move.l #text,pos_txt1
	move.l #menu_txt,menpostxt
	move.l #car_buf,s_car_b1
	move.l #car_buf1,s_car_b2
	move.l #pal_scrol,pos_pal
	move.l #tab_pos,pos_spr
	move.l #tab_pos1,pos_spr2
	move.l #x_pos,pos_x
	move.l #x_pos1,pos_x2
	move.l #sbuf1,pos_buf1
	move.l #sbuf2,pos_buf2
	move.l #sbuf3,pos_buf3
	move.l #sbuf4,pos_buf4
	move.l #pos1,save_pos
	move.l #pos2,save_pos1
	move.l #pos3,save_pos3
	move.l #pos4,save_pos4
	
	move.l ecran,a0
	move.l a0,pos1
	move.l a0,pos2
	move.l a0,pos3
	move.l a0,pos4
	
	moveq #1,d0
	jsr count3
	
	jsr spr_pred
	
	move.w #249,d7
attend	vsync
	dbf d7,attend

	lea menu,a6
	jsr colorout
	
	movem.l fonte_v+(120*89),d0-d7
	movem.l d0-d7,$ffff8240.w
	
	move.w #((32000/4)/4)-1,d0
	move.l ecran1,a0
effac_ecr	rept 4
	clr.l (a0)+
	endr
	dbf d0,effac_ecr
	
	move.l ecran,a1
	lea 54*160(a1),a1
	move.l ecran1,a2
	lea 54*160(a2),a2
	lea abbaye,a0

	move.w #(((19200/4)/4)-1),d0
copy_gfx1	rept 4
	move.l (a0),(a1)+
	move.l (a0)+,(a2)+
	endr
	dbf d0,copy_gfx1
	
	jsr predec
	
	move.l $120.w,anc_hbl
	move.l #vbl,$70.w
	move.l #hbl,$120.w
	
	sf $fffffa1b.w
	bset #0,$fffffa07.w
	bset #0,$fffffa13.w
		
loop	vsync
	
	cmp.b #$3b,$fffffc02.w
	bne.s suite1
	
	move.l #$00000756,pal_1+2
	move.l #$06450534,pal_2+2
	move.l #$04230312,pal_3+2
	move.l #$02010100,pal_4+2
	
suite1	cmp.b #$3c,$fffffc02.w
	bne.s suite2
	
	move.l #$00000765,pal_1+2
	move.l #$06540543,pal_2+2
	move.l #$04320321,pal_3+2
	move.l #$02100100,pal_4+2
	
suite2	cmp.b #$3d,$fffffc02.w
	bne.s suite3
	
	move.l #$00000567,pal_1+2
	move.l #$04560345,pal_2+2
	move.l #$02340123,pal_3+2
	move.l #$00120001,pal_4+2

suite3	cmp.b #$3e,$fffffc02.w
	bne.s suite4
	
	move.l #$00000576,pal_1+2
	move.l #$04650354,pal_2+2
	move.l #$02430132,pal_3+2
	move.l #$00210010,pal_4+2
	
suite4	cmp.b #$3f,$fffffc02.w
	bne.s suite5
	
	move.l #$00000675,pal_1+2
	move.l #$05640453,pal_2+2
	move.l #$03420231,pal_3+2
	move.l #$01200010,pal_4+2
	
suite5	cmp.b #$40,$fffffc02.w
	bne.s suite6
	
	move.l #$00000657,pal_1+2
	move.l #$05460435,pal_2+2
	move.l #$03240213,pal_3+2
	move.l #$01020001,pal_4+2
	
suite6	cmp.b #$41,$fffffc02.w
	bne.s suite7
	
	move.l #$00000777,pal_1+2
	move.l #$06660555,pal_2+2
	move.l #$04440333,pal_3+2
	move.l #$02220111,pal_4+2
	
suite7	cmp.b #$42,$fffffc02.w
	bne.s suite8
	
	cmp.l #count2,zik+2
	beq loop
	
	bsr stop_zik
	move.l #count2,zik+2
	move.l #count2,zik1+2
	move.l #count2+8,zik2+2
	
	moveq #1,d0
	jsr count2
	
suite8	cmp.b #$43,$fffffc02.w
	bne.s suite9
	
	cmp.l #count3,zik+2
	beq loop
	
	bsr stop_zik
	move.l #count3,zik+2
	move.l #count3,zik1+2
	move.l #count3+8,zik2+2
	
	moveq #1,d0
	jsr count3
	
suite9	cmp.b #$44,$fffffc02.w
	bne.s suite10
	
	cmp.l #count4,zik+2
	beq loop
	
	bsr stop_zik
	move.l #count4,zik+2
	move.l #count4,zik1+2
	move.l #count4+8,zik2+2
	
	moveq #1,d0
	jsr count4
	
suite10	cmp.b #$02,$fffffc02.w
	bne.s suite11
	
	move.w #$0756,pal_11+4
	move.l #$06450534,pal_12+2
	move.l #$04230312,pal_13+2
	move.l #$02010100,pal_14+2
	move.l #$00000756,pal_15+2
	move.l #$06450534,pal_16+2
	move.l #$04230312,pal_17+2
	move.l #$02010100,pal_18+2
	
suite11	cmp.b #$03,$fffffc02.w
	bne.s suite12
	
	move.w #$0765,pal_11+4
	move.l #$06540543,pal_12+2
	move.l #$04320321,pal_13+2
	move.l #$02100100,pal_14+2
	move.l #$00000765,pal_15+2
	move.l #$06540543,pal_16+2
	move.l #$04320321,pal_17+2
	move.l #$02100100,pal_18+2
	
suite12	cmp.b #$04,$fffffc02.w
	bne.s suite13
	
	move.w #$0567,pal_11+4
	move.l #$04560345,pal_12+2
	move.l #$02340123,pal_13+2
	move.l #$00120001,pal_14+2
	move.l #$00000567,pal_15+2
	move.l #$04560345,pal_16+2
	move.l #$02340123,pal_17+2
	move.l #$00120001,pal_18+2

suite13	cmp.b #$05,$fffffc02.w
	bne.s suite14
	
	move.w #$0576,pal_11+4
	move.l #$04650354,pal_12+2
	move.l #$02430132,pal_13+2
	move.l #$00210010,pal_14+2
	move.l #$00000576,pal_15+2
	move.l #$04650354,pal_16+2
	move.l #$02430132,pal_17+2
	move.l #$00210010,pal_18+2
	
suite14	cmp.b #$06,$fffffc02.w
	bne.s suite15
	
	move.w #$0675,pal_11+4
	move.l #$05640453,pal_12+2
	move.l #$03420231,pal_13+2
	move.l #$01200010,pal_14+2
	move.l #$00000675,pal_15+2
	move.l #$05640453,pal_16+2
	move.l #$03420231,pal_17+2
	move.l #$01200010,pal_18+2
	
suite15	cmp.b #$07,$fffffc02.w
	bne.s suite16
	
	move.w #$0657,pal_11+4
	move.l #$05460435,pal_12+2
	move.l #$03240213,pal_13+2
	move.l #$01020001,pal_14+2
	move.l #$00000657,pal_15+2
	move.l #$05460435,pal_16+2
	move.l #$03240213,pal_17+2
	move.l #$01020001,pal_18+2
	
suite16	cmp.b #$0a,$fffffc02.w
	bne.s suite17
	
	move.l #palette,ch_pal+4
	
suite17	cmp.b #$09,$fffffc02.w
	bne.s suite18
	
	move.l #palette1,ch_pal+4
	
suite18	cmp.b #$6d,$fffffc02.w
	bne.s suite19
	
	move.w #$444,col1+2
	move.w #$333,col2+2
	move.w #$222,col3+2
	move.w #$333,col4+2
	move.w #$444,col5+2
	move.w #$333,col6+2
	move.w #$222,col7+2
	move.w #$444,col17+2
	move.w #$333,col8+2
	move.w #$222,col9+2
	move.w #$333,pal_11+2
	move.w #$444,col10+2
	move.w #$333,col11+2
	move.w #$222,col12+2
	
suite19	cmp.b #$6e,$fffffc02.w
	bne.s suite20
	
	move.w #$432,col1+2
	move.w #$321,col2+2
	move.w #$210,col3+2
	move.w #$321,col4+2
	move.w #$432,col5+2
	move.w #$321,col6+2
	move.w #$210,col7+2
	move.w #$432,col17+2
	move.w #$321,col8+2
	move.w #$210,col9+2
	move.w #$321,pal_11+2
	move.w #$432,col10+2
	move.w #$321,col11+2
	move.w #$210,col12+2
	
suite20	cmp.b #$6f,$fffffc02.w
	bne.s suite21
	
	move.w #$423,col1+2
	move.w #$312,col2+2
	move.w #$201,col3+2
	move.w #$312,col4+2
	move.w #$423,col5+2
	move.w #$312,col6+2
	move.w #$201,col7+2
	move.w #$423,col17+2
	move.w #$312,pal_11+2
	move.w #$423,col10+2
	move.w #$312,col11+2
	move.w #$201,col12+2
	
suite21	cmp.b #$6a,$fffffc02.w
	bne.s suite22
	
	move.w #$234,col1+2
	move.w #$123,col2+2
	move.w #$012,col3+2
	move.w #$123,col4+2
	move.w #$234,col5+2
	move.w #$123,col6+2
	move.w #$012,col7+2
	move.w #$234,col17+2
	move.w #$123,col8+2
	move.w #$012,col9+2
	move.w #$123,pal_11+2
	move.w #$234,col10+2
	move.w #$123,col11+2
	move.w #$012,col12+2
	
suite22	cmp.b #$6b,$fffffc02.w
	bne.s suite23
	
	move.w #$243,col1+2
	move.w #$132,col2+2
	move.w #$021,col3+2
	move.w #$132,col4+2
	move.w #$243,col5+2
	move.w #$132,col6+2
	move.w #$021,col7+2
	move.w #$243,col17+2
	move.w #$132,col8+2
	move.w #$021,col9+2
	move.w #$132,pal_11+2
	move.w #$243,col10+2
	move.w #$132,col11+2
	move.w #$021,col12+2
	
suite23	cmp.b #$6c,$fffffc02.w
	bne.s suite24
	
	move.w #$324,col1+2
	move.w #$213,col2+2
	move.w #$102,col3+2
	move.w #$213,col4+2
	move.w #$324,col5+2
	move.w #$213,col6+2
	move.w #$102,col7+2
	move.w #$324,col17+2
	move.w #$213,col8+2
	move.w #$102,col9+2
	move.w #$213,pal_11+2
	move.w #$324,col10+2
	move.w #$213,col11+2
	move.w #$102,col12+2
	
suite24	cmp.b #$67,$fffffc02.w
	bne.s suite25
	
	move.w #$342,col1+2
	move.w #$231,col2+2
	move.w #$120,col3+2
	move.w #$231,col4+2
	move.w #$342,col5+2
	move.w #$231,col6+2
	move.w #$120,col7+2
	move.w #$342,col17+2
	move.w #$231,col8+2
	move.w #$120,col9+2
	move.w #$231,pal_11+2
	move.w #$342,col10+2
	move.w #$231,col11+2
	move.w #$120,col12+2
	
suite25	cmp.b #$08,$fffffc02.w
	bne.s suite29
	
	move.w #$0777,pal_11+4
	move.l #$06660555,pal_12+2
	move.l #$04440333,pal_13+2
	move.l #$02220111,pal_14+2
	move.l #$00000777,pal_15+2
	move.l #$06660555,pal_16+2
	move.l #$04440333,pal_17+2
	move.l #$02220111,pal_18+2
	
suite29	cmp.b #$0b,$fffffc02.w
	bne.s suite_fin
	
	move.l #palette2,ch_pal+4
	
suite_fin	cmp.b #$39,$fffffc02.w
	beq.s quit
	
	bra loop
	
quit	bra.s restaure
	rts

stop_zik	moveq #0,d0
zik	jsr count3
	rts
	
restaure	move.l anc_hbl,$120.w
	move.l #fin_vbl,$70.w
	
	moveq #0,d0
zik1	jsr count3
	
	move.b mfp7,$fffffa21.w
	move.b mfp6,$fffffa1b.w
	move.b mfp5,$fffffa17.w
	move.b mfp4,$fffffa13.w
	move.b mfp3,$fffffa0f.w
	move.b mfp2,$fffffa09.w
	move.b mfp1,$fffffa07.w
	
	vsync			*!
	move.b res,$ffff8260.w	*!
	
	vsync			*!
	move.b anc_ecr+1,$ffff8201.w	*!
	move.b anc_ecr+2,$ffff8203.w	*!
	
	movem.l anc_pal,d0-d7	*!
	movem.l d0-d7,$ffff8240.w	*!
	
	move.l anc_vbl,$70.w	*!
	
	*illegal
	
	rts

play_zik
	movem.l d0-d7/a0-a6,-(sp)
	
	jsr count3+8
	
	movem.l (sp)+,d0-d7/a0-a6
fin_vbl	addq.l #1,_vsync
	rte
	
vbl	sf $fffffa1b.w
	move.b #1,$fffffa21.w
	move.b #8,$fffffa1b.w

	move.w sr,-(sp)
	movem.l d0-d7/a0-a6,-(sp)
	
	move.b ecran1+1,$ffff8201.w
	move.b ecran1+2,$ffff8203.w
	
	move.l ecran,a0
	move.l ecran1,a1
	move.l a1,ecran
	move.l a0,ecran1
	
	move.l save_pos,a0
	move.l save_pos1,a1
	move.l a1,save_pos
	move.l a0,save_pos1
	
	move.l pos_buf1,a0
	move.l pos_buf2,a1
	move.l a1,pos_buf1
	move.l a0,pos_buf2
	
	move.l save_pos3,a0
	move.l save_pos4,a1
	move.l a1,save_pos3
	move.l a0,save_pos4
	
	move.l pos_buf3,a0
	move.l pos_buf4,a1
	move.l a1,pos_buf3
	move.l a0,pos_buf4
	
ch_pal	movem.l palette2,d0-d7
	movem.l d0-d7,$ffff8240.w

	addq.l #2,pos_pal
	
	cmp.l #fin_pal,pos_pal
	bne.s cont_vbl
	
	move.l #pal_scrol,pos_pal
	
cont_vbl	move.l pos_pal,s_pos_pal
	
	bsr clr_spr
	
	bsr clr_spr2
	
	bsr scroll_v
	
	bsr scroll_m
	
	bsr scroll
	
	bsr vag
	
	bsr sprite_2
	
	bsr sprite
	
zik2	jsr count3+8
	
	*move.w #$700,$ffff8240.w
	
	movem.l (sp)+,d0-d7/a0-a6
	move.w (sp)+,sr
	
	addq.l #1,_vsync
	rte
	
hbl	
col1	move.w #$444,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl1,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl1	
col2	move.w #$333,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl2,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl2	
col3	move.w #$222,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl3,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl3	
col4	move.w #$333,$ffff8240.w
	sf $fffffa1b.w
	move.b #41,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl4,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl4	
col5	move.w #$444,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl5,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl5	
col6	move.w #$333,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl6,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl6	
col7	move.w #$222,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl7,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl7	
pal_1	move.l #$00000765,$ffff8240.w
pal_2	move.l #$06540543,$ffff8244.w
pal_3	move.l #$04320321,$ffff8248.w
pal_4	move.l #$02100100,$ffff824c.w
	move.l #$00020113,$ffff8250.w
	move.l #$02130224,$ffff8254.w
	move.l #$03350445,$ffff8258.w
	move.l #$05560777,$ffff825c.w
	sf $fffffa1b.w
	move.b #120,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl8,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl8	
col17	move.w #$444,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl9,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl9	
col8	move.w #$333,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl10,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl10	
col9	move.w #$222,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl11,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl11	
pal_11	move.l #$03330675,$ffff8240.w
pal_12	move.l #$05640453,$ffff8244.w
pal_13	move.l #$03420231,$ffff8248.w
pal_14	move.l #$01200010,$ffff824c.w
pal_15	move.l #$00000675,$ffff8250.w
pal_16	move.l #$05640453,$ffff8254.w
pal_17	move.l #$03420231,$ffff8258.w
pal_18	move.l #$01200010,$ffff825c.w
	sf $fffffa1b.w
	move.b #4,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl12,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl12	sf $fffffa1b.w
	move.b #15,compt
	move.b #1,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl13,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl13	subq.b #1,compt
	beq.s hbl14
	move.l a6,-(sp)
	move.l s_pos_pal,a6
	move.w (a6)+,$ffff8250.w
	move.l a6,s_pos_pal
	move.l (sp)+,a6
	bclr #0,$fffffa0f.w
	rte
	
hbl14	sf $fffffa1b.w
	move.l a6,-(sp)
	move.l s_pos_pal,a6
	move.w (a6)+,$ffff8250.w
	rept 95
	nop
	endr
	sf $ffff820a.w
	rept 14
	nop
	endr
	move.b #2,$ffff820a.w
	move.w (a6)+,$ffff8250.w
	move.l a6,s_pos_pal
	move.l (sp)+,a6
	move.b #4,compt
	move.b #1,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl15,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl15	subq.b #1,compt
	beq.s hbl16
	move.l a6,-(sp)
	move.l s_pos_pal,a6
	move.w (a6)+,$ffff8250.w
	move.l a6,s_pos_pal
	move.l (sp)+,a6
	bclr #0,$fffffa0f.w
	rte
		
hbl16	sf $fffffa1b.w
	move.b #7,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl17,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl17	
col10	move.w #$444,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl18,$120.w
	bclr #0,$fffffa0f.w
	rte
	
hbl18	
col11	move.w #$333,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl19,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl19	
col12	move.w #$222,$ffff8240.w
	sf $fffffa1b.w
	move.b #2,$fffffa21.w
	move.b #8,$fffffa1b.w
	move.l #hbl20,$120.w
	bclr #0,$fffffa0f.w
	rte

hbl20	clr.w $ffff8240.w
	sf $fffffa1b.w
	move.l #hbl,$120.w
	bclr #0,$fffffa0f.w
	rte

clr_spr2	include 'clr_spr2.s'
	
clr_spr	include 'clr_spr.s'
	
vag	include 'vag.s'

scroll_v	include 'scroll1v.s'
	
scroll	include 'scroll1h.s'

scroll_m	include 'scroll1m.s'

sprite_2	include 'sprite22.s'
	
sprite	include 'sprite.s'

predec	include 'predec1.s'

spr_pred	include 'spr_pred.s'

fadein	include 'fade.s'

count2	incbin 'atomino1.mus'
	even
count3	incbin 'slam.mus'
	even
count4	incbin 'prehis_1.mus'
	even

	section data
	
texte	dc.b $1b,'EOnly color! Sorry...',$d,$a,$a
	dc.b 'Press any key...',0
	even
	dc.b 39
text_v	dc.b 39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
text_v1	incbin 'scroll_v.cod'
	dc.b 39
text	dc.b 39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
	dc.b 39,39,39,39,39,39,39,39,39,39
text1	incbin 'scroll_h.cod'
menu_txt	dc.b 75,75,75,75,75,75,75,75,75,75
	dc.b 75,75,75,75,75,75,75,75,75,75
menu_txt1	dc.b 75,75,75,75,75,75,75,75,75,75
	dc.b 75,75,75,75,75,75,75,75,75,75
	dc.b 0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,26,27,28,29
	dc.b 30,31,32,33,34,35,36,37,38,39
	dc.b 40,41,42,43,44,45,46,47,48,49
	dc.b 50,51,52,53,54,55,56,57,58,59
	dc.b 60,61,62,63,64,65,66,67,68,69
	dc.b 70,71,72,73,74,-1
	even
sprite1	dc.w	$007F,$0000,$0000,$007F,$0000,$0000,$0000,$0000
	dc.w	$03FF,$007F,$0000,$03FF,$E000,$0000,$0000,$E000
	dc.w	$0FC1,$03C1,$003E,$0FFF,$F800,$E000,$0000,$F800
	dc.w	$1E3E,$0E00,$01FF,$1FFF,$3C00,$3800,$C000,$FC00
	dc.w	$39E3,$181C,$07FF,$3FFF,$CE00,$0C00,$F000,$FE00
	dc.w	$31FF,$1000,$0FFF,$3FFF,$C600,$0400,$F800,$FE00
	dc.w	$66FF,$2000,$1FFF,$7FFF,$B300,$0200,$FC00,$FF00
	dc.w	$6477,$2408,$1BFF,$7FFF,$1300,$1200,$EC00,$FF00
	dc.w	$7780,$707F,$0FFF,$7FFF,$F700,$0700,$F800,$FF00
	dc.w	$E700,$20FF,$1FFF,$FFFF,$7380,$8200,$FC00,$FF80
	dc.w	$E800,$67FF,$1FFF,$FFFF,$0B80,$F300,$FC00,$FF80
	dc.w	$487F,$C780,$3FFF,$FFFF,$0900,$F180,$FE00,$FF80
	dc.w	$AD80,$6200,$1FFF,$FFFF,$DA80,$2300,$FC00,$FF80
	dc.w	$A263,$6180,$1FFF,$FFFF,$2280,$C300,$FC00,$FF80
	dc.w	$50FF,$3000,$0FFF,$FFFF,$8500,$0600,$F800,$FF80
	dc.w	$279C,$1C63,$03FF,$7FFF,$F200,$1C00,$E000,$FF00
	dc.w	$10E3,$0088,$0F7F,$7FFF,$8400,$8000,$7800,$FF00
	dc.w	$27DD,$07C1,$183E,$3FFF,$F200,$F000,$0C00,$FE00
	dc.w	$5FEB,$1863,$201C,$7FFF,$FD00,$0C00,$0200,$FF00
	dc.w	$7077,$2014,$0008,$7FFF,$0700,$0200,$0000,$FF00
	dc.w	$7136,$2114,$0108,$7FFF,$4700,$4200,$4000,$FF00
	dc.w	$78EB,$3022,$001C,$7FFF,$8F00,$0600,$0000,$FF00
	dc.w	$3FF7,$38FF,$0008,$3FFF,$FE00,$8E00,$0000,$FE00
	dc.w	$3F5D,$1FA2,$001C,$3FFF,$7E00,$FC00,$0000,$FE00
	dc.w	$1CC9,$072A,$0014,$1FFF,$9C00,$7000,$0000,$FC00
	dc.w	$069C,$0077,$0000,$0FFF,$B000,$0000,$0000,$F800
	dc.w	$0036,$01F7,$0000,$0FFF,$0000,$C000,$0000,$F800
	dc.w	$01B6,$0063,$0000,$07FF,$C000,$0000,$0000,$F000
	dc.w	$016B,$00A2,$0000,$07FF,$4000,$8000,$0000,$F000
	dc.w	$00BE,$01EB,$0000,$03FF,$8000,$C000,$0000,$E000
	dc.w	$00FF,$00FF,$0000,$03FF,$8000,$8000,$0000,$E000
	dc.w	$0022,$0063,$001C,$01FF,$0000,$0000,$0000,$C000
	dc.w	$011C,$0080,$0000,$01FF,$4000,$8000,$0000,$C000
	dc.w	$00E3,$0063,$001C,$00FF,$8000,$0000,$0000,$8000
	dc.w	$003E,$001C,$0000,$007F,$0000,$0000,$0000,$0000
	even
	
sprite2	dc.w	$1C00,$FC00,$03FF,$0000,$03F0,$03F0,$FC0F,$0000
	dc.w	$001F,$001F,$FFE0,$0000,$8001,$8000,$7FFF,$0000
	dc.w	$7807,$FFFF,$7FFF,$0000,$8001,$FFFF,$FFFF,$0000
	dc.w	$E000,$FFFF,$FFFF,$0000,$3E02,$FFFD,$FFFF,$0000
	dc.w	$C000,$C000,$4000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0001,$0003,$0000
	dc.w	$4010,$0007,$FFF0,$0000,$C243,$C09F,$3E40,$0000
	dc.w	$0218,$00F8,$FE07,$0000,$4001,$1801,$C003,$0000
	dc.w	$8773,$7BF7,$FFF3,$0000,$C410,$FACF,$FE5F,$0000
	dc.w	$E678,$7EFF,$FE7F,$0000,$8801,$5C01,$C803,$0000
	dc.w	$0206,$0206,$0602,$0000,$0400,$06C0,$0240,$0000
	dc.w	$40C0,$40C0,$C040,$0000,$8E00,$DE01,$4C03,$0000
	dc.w	$0004,$0206,$0602,$0000,$0280,$06C0,$0240,$0000
	dc.w	$0000,$4040,$C0C0,$0000,$DB00,$DB01,$4A03,$0000
	dc.w	$0404,$0606,$0202,$0000,$0280,$06C0,$0240,$0000
	dc.w	$8040,$C040,$40C0,$0000,$5182,$D983,$4901,$0000
	dc.w	$0402,$0604,$0203,$0000,$7280,$7EC0,$8240,$0000
	dc.w	$80C0,$C0C0,$4040,$0000,$D042,$D8C3,$4881,$0000
	dc.w	$0004,$0607,$0203,$0000,$0600,$BE40,$FEC0,$0000
	dc.w	$00C0,$C0C0,$4040,$0000,$0023,$4863,$D841,$0000
	dc.w	$0400,$0602,$0206,$0000,$2000,$6040,$40C0,$0000
	dc.w	$8040,$C0C0,$4040,$0000,$8001,$C833,$5821,$0000
	dc.w	$0202,$0202,$0606,$0000,$1040,$3040,$20C0,$0000
	dc.w	$4080,$40C0,$C040,$0000,$4801,$C81B,$5811,$0000
	dc.w	$0202,$0202,$0606,$0000,$0040,$1840,$10C0,$0000
	dc.w	$4000,$4040,$C0C0,$0000,$4809,$C80F,$5809,$0000
	dc.w	$0202,$0202,$0606,$0000,$0440,$0C40,$08C0,$0000
	dc.w	$407E,$403F,$C0C0,$0000,$4805,$C807,$5805,$0000
	dc.w	$0606,$0202,$0606,$0000,$00C0,$0440,$06C0,$0000
	dc.w	$C098,$407F,$C0FF,$0000,$D803,$C803,$D803,$0000
	even

menu1	incbin 'menu.1p'
	even
fonte_v	incbin 'fonte_v.3p'
	even
fonte_vv	incbin 'fonte_7.4p'
	even
fonte	incbin 'fonte.3p'
	even
vague	incbin 'vague.bin'

f_vague	dcb.l 78,0

t_vag	dc.l vague
	
palette	dc.w $000,$750,$640,$630,$520,$510,$400,$300
	dc.w $002,$113,$213,$224,$335,$445,$556,$777

palette1	dc.w $000,$777,$666,$555,$444,$333,$222,$111
	dc.w $002,$113,$213,$224,$335,$445,$556,$777

palette2	dc.w $000,$755,$644,$533,$422,$311,$200,$100
	dc.w $002,$113,$213,$224,$335,$445,$556,$777

pal_scrol	dc.w $000,$800,$100,$900,$200,$a00,$300,$b00
	dc.w $400,$c00,$500,$d00,$600,$e00,$700,$f00
	dc.w $f00,$700,$e00,$600,$d00,$500,$c00,$400
	dc.w $b00,$300,$a00,$200,$900,$100,$800,$000
	dc.w $000,$800,$990,$110,$aa0,$220,$bb0,$330
	dc.w $440,$cc0,$550,$dd0,$660,$ee0,$770,$ff0
	dc.w $ff0,$770,$ee0,$660,$dd0,$550,$cc0,$440
	dc.w $bb0,$330,$aa0,$220,$990,$110,$880,$000
	dc.w $000,$080,$010,$090,$020,$0a0,$030,$0b0
	dc.w $040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
	dc.w $0f0,$070,$0e0,$060,$0d0,$050,$0c0,$040
	dc.w $0b0,$030,$0a0,$020,$090,$010,$080,$000
	dc.w $000,$088,$011,$099,$022,$0aa,$033,$0bb
	dc.w $044,$0cc,$055,$0dd,$066,$0ee,$077,$0ff
	dc.w $0ff,$077,$0ee,$066,$0dd,$055,$0cc,$044
	dc.w $0bb,$033,$0aa,$022,$099,$011,$088,$000
	dc.w $000,$008,$001,$009,$002,$00a,$003,$00b
	dc.w $004,$00c,$005,$00d,$006,$00e,$007,$00f
	dc.w $00f,$007,$00e,$006,$00d,$005,$00c,$004
	dc.w $00b,$003,$00a,$002,$009,$001,$008,$000
	dc.w $000,$808,$101,$909,$202,$a0a,$303,$b0b
	dc.w $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
	dc.w $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
	dc.w $b0b,$303,$a0a,$202,$909,$101,$808,$000
	dc.w $000,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w $444,$ccc,$555,$ddd,$666,$eee,$777,$fff
	dc.w $fff,$777,$eee,$666,$ddd,$555,$ccc,$444
	dc.w $bbb,$333,$aaa,$222,$999,$111,$888,$000
	dc.w $000,$800,$300,$b00,$400,$c00,$510,$d90
	dc.w $520,$da0,$630,$eb0,$640,$ec0,$750,$fd0
	dc.w $fd0,$750,$ec0,$640,$eb0,$630,$da0,$520
	dc.w $d90,$510,$c00,$400,$b00,$300,$800,$000
	dc.w $000,$800,$100,$980,$210,$a98,$321,$ba9
	dc.w $432,$cba,$543,$dcb,$654,$edc,$765,$fed
	dc.w $fed,$765,$edc,$654,$dcb,$543,$cba,$432
	dc.w $ba9,$321,$a98,$210,$980,$100,$800,$000
	dc.w $000,$800,$100,$908,$201,$a89,$312,$b9a
	dc.w $423,$cab,$534,$dbc,$645,$ecd,$756,$fde
	dc.w $fde,$756,$ecd,$645,$dbc,$534,$cab,$423
	dc.w $b9a,$312,$a89,$201,$908,$100,$800,$000
	dc.w $000,$080,$010,$098,$021,$8a9,$132,$9ba
	dc.w $243,$acb,$354,$bdc,$465,$ced,$576,$dfe
	dc.w $dfe,$576,$ced,$465,$bdc,$354,$acb,$245
	dc.w $9ba,$132,$8a9,$021,$098,$010,$080,$000
	dc.w $000,$080,$010,$890,$120,$9a8,$231,$ab9
	dc.w $342,$bca,$453,$cdb,$564,$dec,$675,$efd
	dc.w $efd,$675,$dec,$564,$cdb,$453,$bca,$342
	dc.w $ab9,$231,$9a8,$120,$890,$010,$080,$000
	dc.w $000,$008,$001,$089,$012,$89a,$123,$9ab
	dc.w $234,$abc,$345,$bcd,$456,$cde,$567,$def
	dc.w $def,$567,$cde,$456,$bcd,$345,$abc,$234
	dc.w $9ab,$123,$89a,$012,$089,$001,$008,$000
	dc.w $000,$008,$001,$809,$102,$98a,$213,$a9b
	dc.w $324,$bac,$435,$cbd,$546,$dce,$657,$edf
	dc.w $edf,$657,$dce,$546,$cbd,$435,$bac,$324
	dc.w $a9b,$213,$98a,$102,$809,$001,$008,$000
	dc.w $000,$800,$100,$900,$200,$a88,$311,$b99
	dc.w $422,$caa,$533,$dbb,$644,$ecc,$755,$fdd
	dc.w $fdd,$755,$ecc,$644,$dbb,$533,$caa,$422
	dc.w $b99,$311,$a88,$200,$900,$100,$800,$000
	dc.w $000,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w $444,$ccc,$555,$ddd,$666,$eee,$777,$fff
	dc.w $fff,$777,$eee,$666,$ddd,$555,$ccc,$444
	dc.w $bbb,$333,$aaa,$222,$999,$111,$888,$000
fin_pal	dc.w $000,$800,$100,$900,$200,$a00,$300,$b00
	dc.w $400,$c00,$500,$d00,$600,$e00,$700,$f00
	dc.w $f00,$700,$e00,$600
	
tab_pos	incbin 'courbx.dat'
x_pos	incbin 'courby.dat'
tab_pos1	incbin 'courbx1.dat'
x_pos1	incbin 'courby1.dat'

t_vague	dc.l menu,menu+6240
	dc.l menu+(6240*2),menu+6240*3)
	dc.l menu+(6240*4),menu+(6240*5)
	dc.l menu+(6240*6),menu+(6240*7)
	dc.l menu+(6240*8),menu+(6240*9)
	dc.l menu+(6240*10),menu+(6240*11)
	dc.l menu+(6240*12),menu+(6240*13)
	dc.l menu+(6240*14),menu+(6240*15)
	dc.l menu,menu+6240
	dc.l menu+(6240*2),menu+(6240*3)
	dc.l menu+(6240*4)
	
t_spr1	dc.l spr_1,spr_1+840
	dc.l spr_1+(840*2),spr_1+(840*3)
	dc.l spr_1+(840*4),spr_1+(840*5)
	dc.l spr_1+(840*6),spr_1+(840*7)
	dc.l spr_1+(840*8),spr_1+(840*9)
	dc.l spr_1+(840*10),spr_1+(840*11)
	dc.l spr_1+(840*12),spr_1+(840*13)
	dc.l spr_1+(840*14),spr_1+(840*15)

t_spr2	dc.l spr_2,spr_2+600
	dc.l spr_2+(600*2),spr_2+(600*3)
	dc.l spr_2+(600*4),spr_2+(600*5)
	dc.l spr_2+(600*6),spr_2+(600*7)
	dc.l spr_2+(600*8),spr_2+(600*9)
	dc.l spr_2+(600*10),spr_2+(600*11)
	dc.l spr_2+(600*12),spr_2+(600*13)
	dc.l spr_2+(600*14),spr_2+(600*15)

tab_car_v	dc.l fonte_v,fonte_v+12
	dc.l fonte_v+24,fonte_v+36
	dc.l fonte_v+48,fonte_v+60
	dc.l fonte_v+72,fonte_v+84
	dc.l fonte_v+96,fonte_v+108
	dc.l fonte_v+(120*30),fonte_v+(120*30)+12
	dc.l fonte_v+(120*30)+24,fonte_v+(120*30)+36
	dc.l fonte_v+(120*30)+48,fonte_v+(120*30)+60
	dc.l fonte_v+(120*30)+72,fonte_v+(120*30)+84
	dc.l fonte_v+(120*30)+96,fonte_v+(120*30)+108
	dc.l fonte_v+(120*60),fonte_v+(120*60)+12
	dc.l fonte_v+(120*60)+24,fonte_v+(120*60)+36
	dc.l fonte_v+(120*60)+48,fonte_v+(120*60)+60
	dc.l fonte_v+(120*60)+72,fonte_v+(120*60)+84
	dc.l fonte_v+(120*60)+96,fonte_v+(120*60)+108
	dc.l fonte_v+(120*90),fonte_v+(120*90)+12
	dc.l fonte_v+(120*90)+24,fonte_v+(120*90)+36
	dc.l fonte_v+(120*90)+48,fonte_v+(120*90)+60
	dc.l fonte_v+(120*90)+72,fonte_v+(120*90)+84
	dc.l fonte_v+(120*90)+96,fonte_v+(120*90)+108

tab_carvv	dc.l fonte_vv,fonte_vv+12
	dc.l fonte_vv+24,fonte_vv+36
	dc.l fonte_vv+48,fonte_vv+60
	dc.l fonte_vv+72,fonte_vv+84
	dc.l fonte_vv+96,fonte_vv+108
	dc.l fonte_vv+(120*30),fonte_vv+(120*30)+12
	dc.l fonte_vv+(120*30)+24,fonte_vv+(120*30)+36
	dc.l fonte_vv+(120*30)+48,fonte_vv+(120*30)+60
	dc.l fonte_vv+(120*30)+72,fonte_vv+(120*30)+84
	dc.l fonte_vv+(120*30)+96,fonte_vv+(120*30)+108
	dc.l fonte_vv+(120*60),fonte_vv+(120*60)+12
	dc.l fonte_vv+(120*60)+24,fonte_vv+(120*60)+36
	dc.l fonte_vv+(120*60)+48,fonte_vv+(120*60)+60
	dc.l fonte_vv+(120*60)+72,fonte_vv+(120*60)+84
	dc.l fonte_vv+(120*60)+96,fonte_vv+(120*60)+108
	dc.l fonte_vv+(120*90),fonte_vv+(120*90)+12
	dc.l fonte_vv+(120*90)+24,fonte_vv+(120*90)+36
	dc.l fonte_vv+(120*90)+48,fonte_vv+(120*90)+60
	dc.l fonte_vv+(120*90)+72,fonte_vv+(120*90)+84
	dc.l fonte_vv+(120*90)+96,fonte_vv+(120*90)+108

tab_car	dc.l fonte,fonte+12
	dc.l fonte+24,fonte+36
	dc.l fonte+48,fonte+60
	dc.l fonte+72,fonte+84
	dc.l fonte+96,fonte+108
	dc.l fonte+(120*29),fonte+(120*29)+12
	dc.l fonte+(120*29)+24,fonte+(120*29)+36
	dc.l fonte+(120*29)+48,fonte+(120*29)+60
	dc.l fonte+(120*29)+72,fonte+(120*29)+84
	dc.l fonte+(120*29)+96,fonte+(120*29)+108
	dc.l fonte+(120*58),fonte+(120*58)+12
	dc.l fonte+(120*58)+24,fonte+(120*58)+36
	dc.l fonte+(120*58)+48,fonte+(120*58)+60
	dc.l fonte+(120*58)+72,fonte+(120*58)+84
	dc.l fonte+(120*58)+96,fonte+(120*58)+108
	dc.l fonte+(120*87),fonte+(120*87)+12
	dc.l fonte+(120*87)+24,fonte+(120*87)+36
	dc.l fonte+(120*87)+48,fonte+(120*87)+60
	dc.l fonte+(120*87)+72,fonte+(120*87)+84
	dc.l fonte+(120*87)+96,fonte+(120*87)+108

tabmencar	dc.l menu1,menu1+2,menu1+4,menu1+6,menu1+8
	dc.l menu1+10,menu1+12,menu1+14,menu1+16,menu1+18
	dc.l menu1+20,menu1+22,menu1+24,menu1+26,menu1+28
	dc.l menu1+30,menu1+32,menu1+34,menu1+36,menu1+38
	dc.l menu1+(20*40),menu1+(20*40)+2,menu1+(20*40)+4,menu1+(20*40)+6,menu1+(20*40)+8
	dc.l menu1+(20*40)+10,menu1+(20*40)+12,menu1+(20*40)+14,menu1+(20*40)+16,menu1+(20*40)+18
	dc.l menu1+(20*40)+20,menu1+(20*40)+22,menu1+(20*40)+24,menu1+(20*40)+26,menu1+(20*40)+28
	dc.l menu1+(20*40)+30,menu1+(20*40)+32,menu1+(20*40)+34,menu1+(20*40)+36,menu1+(20*40)+38
	dc.l menu1+(40*40),menu1+(40*40)+2,menu1+(40*40)+4,menu1+(40*40)+6,menu1+(40*40)+8
	dc.l menu1+(40*40)+10,menu1+(40*40)+12,menu1+(40*40)+14,menu1+(40*40)+16,menu1+(40*40)+18
	dc.l menu1+(40*40)+20,menu1+(40*40)+22,menu1+(40*40)+24,menu1+(40*40)+26,menu1+(40*40)+28
	dc.l menu1+(40*40)+30,menu1+(40*40)+32,menu1+(40*40)+34,menu1+(40*40)+36,menu1+(40*40)+38
	dc.l menu1+(60*40),menu1+(60*40)+2,menu1+(60*40)+4,menu1+(60*40)+6,menu1+(60*40)+8
	dc.l menu1+(60*40)+10,menu1+(60*40)+12,menu1+(60*40)+14,menu1+(60*40)+16,menu1+(60*40)+18
	dc.l menu1+(60*40)+20,menu1+(60*40)+22,menu1+(60*40)+24,menu1+(60*40)+26,menu1+(60*40)+28
	dc.l menu1+(60*40)+30
		
menu	incbin 'present.4pp'
	even
abbaye	incbin 'ab.4p'
	even
megadeth	incbin 'megadeth.3p'
	even

	section bss
debut	ds.b 1560
megad1	ds.b 45198
buffer	ds.b 42000
buffer1	ds.b 42000
sbuf1	ds.b 840
sbuf2	ds.b 840
sbuf3	ds.b 600
sbuf4	ds.b 600
spr_1	ds.b 840*16
spr_2	ds.b 600*16
mencarbuf	ds.b 40
car_buf 	ds.b 29*16
car_buf1 	ds.b 29*16
buf_scr_v	ds.b 12
buf_scr_w	ds.b 12
anc_ecr	ds.l 1		*!
ecran	ds.l 1
ecran1	ds.l 1
anc_vbl	ds.l 1
anc_hbl	ds.l 1
anc_pal	ds.l 8		*!
pos_txt_v	ds.l 1
pos_txt	ds.l 1
pos_txt1	ds.l 1
menpostxt	ds.l 1
pos_pal	ds.l 1
s_pos_pal	ds.l 1
s_car_b1	ds.l 1
s_car_b2	ds.l 1
anc_car	ds.l 1
pos_spr	ds.l 1
pos_spr2	ds.l 1
pos_x	ds.l 1
pos_x2	ds.l 1
save_pos	ds.l 1
save_pos1	ds.l 1
save_pos3	ds.l 1
save_pos4	ds.l 1
pos_buf1	ds.l 1
pos_buf2	ds.l 1
pos_buf3	ds.l 1
pos_buf4	ds.l 1
pos1	ds.l 1
pos2	ds.l 1
pos3	ds.l 1
pos4	ds.l 1
_vsync	ds.l 1
mfp1	ds.b 1
mfp2	ds.b 1
mfp3	ds.b 1
mfp4	ds.b 1
mfp5	ds.b 1
mfp6	ds.b 1
mfp7	ds.b 1
res	ds.b 1		*!
fin_car_v	ds.b 1
fin_car_m	ds.b 1
fin_car	ds.b 1
fin_car1	ds.b 1
compt	ds.b 1
	
	even
fin
	end
	