	opt o+

debug	equ 0	; 0=affichage temps restant [SHIFT GAUCHE]

spec	macro
	movem.l (a1)+,d0-d7
	movem.l d0-d7,(a0)
	movem.l (a1)+,d0-d7
	movem.l d0-d7,(a0)
	movem.l (a1)+,d0-d7
	movem.l d0-d7,(a0)
	nop
	nop
	endm

sprite	macro
	
	move.w (a1)+,d0
	move.l (a3)+,d1
	move.l (a0),d2
	move.l 4(a0),d3
	move.l d2,(a2)+
	move.l d3,(a2)+
	
	and.l d1,d2
	and.l d1,d3
	or.w d0,d3
	move.l d2,(a0)+
	move.l d3,(a0)+
	
	endm
		
	include macro.s
	
	section text
	
	super main
	
	quit

main	move.b $ffff8260.w,res
	move.l $44e.w,anc_ecr

	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,anc_pal
	
	move.b $fffffa07.w,mfp1
	move.b $fffffa09.w,mfp2
	move.b $fffffa0f.w,mfp3
	move.b $fffffa13.w,mfp4
	move.b $fffffa17.w,mfp5
	move.b $fffffa1b.w,mfp6
	move.b $fffffa21.w,mfp7
	
	bclr #3,$fffffa17.w
	
	sf $fffffa07.w
	sf $fffffa09.w

	move.b #$12,$fffffc02.w
			
	moveq #4,d0
	bsr musique
	
	bsr prd_prism
	
	move.l $70.w,anc_vbl
	move.l #vbl,$70.w
	
	adr_ecr buffer,ecran
	move.l ecran,a0
	lea 32000(a0),a0
	move.l a0,ecran1
	
	
	lea 160*122(a0),a0
	lea -32000(a0),a1
	lea logo,a2
	move.w #(9360/6)-1,d0
copy_logo	move.l (a2),(a0)+
	move.l (a2)+,(a1)+
	move.w (a2),(a0)+
	move.w (a2)+,(a1)+
	addq.l #2,a0
	addq.l #2,a1
	dbf d0,copy_logo
	
	move.l #message,mes_pnt
	move.l #pal_scrol,pos_pal
	move.l #tab_pos,pos_spr
	move.l #x_pos,pos_x
	move.l #sbuf1,pos_buf1
	move.l #sbuf2,pos_buf2
	move.l #pos1,save_pos
	move.l #pos2,save_pos1
	
	move.l ecran,a0
	move.l a0,pos1
	move.l a0,pos2
	
	bsr prep_clr
	
	init_vsync
	vsync
	sf $ffff8260.w
	vsync
	
	move.b ecran1+1,$ffff8201.w
	move.b ecran1+2,$ffff8203.w
	
	move.l $120.w,anc_hbl
	move.l #vbl_rout,$70.w
	move.l #hbl,$120.w

	sf $fffffa1b.w
	bset #0,$fffffa07.w
	bset #0,$fffffa13.w
	
loop	vsync

	ifeq debug
	cmp.b #$2a,$fffffc02.w
	bne.s d_suite
	move.w #$777,time+2
	move.w #$700,time2+2
	bra.s d_saut
d_suite	move.w #$000,time+2
	move.w #$000,time2+2
d_saut	
	endc

	cmp.b #$39,$fffffc02.w
	bne.s loop
	
	move.l #vbl,$70.w
	move.l anc_hbl,$120.w
	
	move.b #$8,$fffffc02.w
	
	move.b mfp1,$fffffa07.w
	move.b mfp2,$fffffa09.w
	move.b mfp3,$fffffa0f.w
	move.b mfp4,$fffffa13.w
	move.b mfp5,$fffffa17.w
	move.b mfp6,$fffffa1b.w
	move.b mfp7,$fffffa21.w
	
	move.b #$c0,$fffffa23.w	* reset keyboard
	
	vsync
	move.b anc_ecr+1,$ffff8201.w
	move.b anc_ecr+2,$ffff8203.w
	vsync
	move.b res,$ffff8260.w
	vsync
	
	moveq #0,d0
	bsr musique
	
	move.l #$00000000,$ffff8800.w
	move.l #$01010000,$ffff8800.w
	move.l #$02020000,$ffff8800.w
	move.l #$03030000,$ffff8800.w
	move.l #$04040000,$ffff8800.w
	move.l #$05050000,$ffff8800.w
	move.l #$06060000,$ffff8800.w
	move.l #$0707ffff,$ffff8800.w
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	
	movem.l anc_pal,d0-d7
	movem.l d0-d7,$ffff8240.w
	
	move.l anc_vbl,$70.w
	
	rts
	
vbl	addq.l #1,_vsync
	rte
	
vbl_rout	move.b ecran1+1,$ffff8201.w
	move.b ecran1+2,$ffff8203.w
	
	move.l ecran,a0
	move.l ecran1,a1
	move.l a1,ecran
	move.l a0,ecran1
	
	move.l pos_buf1,a0
	move.l pos_buf2,a1
	move.l a1,pos_buf1
	move.l a0,pos_buf2
	
	move.l save_pos,a0
	move.l save_pos1,a1
	move.l a1,save_pos
	move.l a0,save_pos1
	
	addq.l #4,pos_pal
	
	cmp.l #fin_pal,pos_pal
	bne.s cont_vbl
	
	move.l #pal_scrol,pos_pal

cont_vbl	move.l pos_pal,s_pos_pal

	bsr musique+8
	
	bsr clr_prism
	
	bsr spr_prism

	bsr spectrum
	
	sf $fffffa1b.w
	move.b #14,$fffffa21.w
	move.b #8,$fffffa1b.w
	
	move.l ecran,a0
	rept 40
	clr.l (a0)+
	endr
		
	addq.l #1,_vsync
	
	ifeq debug
time	move.w #$000,$ffff8240.w
	endc
	
	rte
	
hbl	move.b #17,compt
	move.b #1,$fffffa21.w
	move.l #hbl1,$120.w
	rte
	
hbl1	subq.b #1,compt
	beq.s hbl2
	move.l a6,-(sp)
	move.l s_pos_pal,a6
	move.l (a6),$ffff8250.w
	move.l (a6),$ffff8254.w
	move.l (a6),$ffff8258.w
	move.l (a6)+,$ffff825c.w
	move.l a6,s_pos_pal
	move.l (sp)+,a6
	rte
	
hbl2	sf $fffffa1b.w
	move.l #hbl,$120.w
	rte
	
spectrum	include 'e:\langages\devpac2\spectrum\scroll.s'

prd_prism	lea prism,a0
	lea spr_1,a1
	
	moveq #15,d0
	
trans_spr	movem.l (a0)+,d1-d2
	movem.l d1-d2,(a1)
	move.w (a0)+,8(a1)
	
	lea 12(a1),a1
	
	dbf d0,trans_spr
	
	lea spr_1,a0
	lea spr_1+192,a1
	
	moveq #14,d0
	
predec	moveq #15,d1

predec1	movem.l (a0)+,d2-d4
	movem.l d2-d4,(a1)
	
	rept 6
	roxr.w (a1)+
	endr
	
	dbf d1,predec1
	
	dbf d0,predec
	
mask	lea spr_1,a0
	lea mspr_1,a1
	
	moveq #15,d1	;16 sprites
	 
trans1	moveq #15,d0	;16 de hauteur
	
trans_msk	move.w (a0)+,(a1)
	move.w (a0)+,4(a1)
	move.w (a0)+,8(a1)
	move.w (a0)+,12(a1)
	move.w (a0)+,16(a1)
	move.w (a0)+,20(a1)
	
	lea 24(a1),a1
	
	dbf d0,trans_msk
	
	dbf d1,trans1
	
	lea mspr_1,a1

	moveq #0,d3	
	moveq #15,d2	;16 sprites
calc1	moveq #15,d1	;16 de haut
calc2	moveq #5,d0	;88 de large
	
calc_msk	move.w (a1),d3
	or.l d3,(a1)
	not.l (a1)+
	
	dbf d0,calc_msk
	dbf d1,calc2
	dbf d2,calc1	
	rts
	
spr_prism	move.l ecran,a0
	lea t_spr1,a1
	move.l pos_buf1,a2
	lea t_mspr1,a3
	
rec_prism	move.l pos_spr,a4
	move.w (a4)+,d0
	move.l a4,pos_spr
	
	cmp.w #-1,d0
	bne.s ct_prism
	
	move.l #tab_pos,pos_spr
	bra.s rec_prism
	
ct_prism	move.w d0,d1
	and.w #$fff0,d0
	and.w #$000f,d1
	lsr.w #1,d0
	lsl.w #2,d1
	
	move.l (a1,d1.w),a1
	move.l (a3,d1.w),a3
	lea (a0,d0.w),a0
	
rc_prism	move.l pos_x,a4
	move.w (a4)+,d0
	move.l a4,pos_x
	
	cmp.w #-1,d0
	bne.s ctprism2
	
	move.l #x_pos,pos_x
	bra.s rc_prism
	
ctprism2	lea (a0,d0.w),a0

	move.l save_pos,a4
	move.l a0,(a4)
	
affprism	moveq #0,d0

	rept 16

	sprite
	
	sprite
	
	sprite
	
	sprite
	
	sprite
	
	sprite
	
	lea 160-48(a0),a0

	endr
	
	rts
	
clr_prism	move.l pos_buf1,a1
	move.l save_pos,a2
	move.l (a2),a0
	
n	set 0
	rept 16
	movem.l (a1)+,d0-d7/a2-a5
	movem.l d0-d7/a2-a5,n(a0)
n	set n+160
	endr
	
	rts
	
prep_clr	move.l ecran,a0
	lea sbuf1,a1
	
n1	set 0
n2	set 0
	rept 16
	movem.l n1(a0),d0-d7/a2-a5
	movem.l d0-d7/a2-a5,n2(a1)
	movem.l d0-d7/a2-a5,768+n2(a1)
n1	set n1+160
n2	set n2+48
	endr
	
	rts
	
musique	incbin 'e:\musiques\datas\mad_max\dragonf1.mus'
	even

	section data
	
tab_pos	incbin 'e:\langages\devpac2\spectrum\courbx1.dat'
x_pos	incbin 'e:\langages\devpac2\spectrum\courby1.dat'

pal_spec	include 'e:\langages\devpac2\spectrum\spc_pal.s'

pal_suit	dc.w $000,$111,$211,$222,$322,$333,$433,$444
	
pal_scrol	dc.w $000,$000,$800,$800,$100,$100,$900,$900
	dc.w $200,$200,$a00,$a00,$300,$300,$b00,$b00
	dc.w $400,$400,$c00,$c00,$500,$500,$d00,$d00
	dc.w $600,$600,$e00,$e00,$700,$700,$f00,$f00
	dc.w $f00,$f00,$700,$700,$e00,$e00,$600,$600
	dc.w $d00,$d00,$500,$500,$c00,$c00,$400,$400
	dc.w $b00,$b00,$300,$300,$a00,$a00,$200,$200
	dc.w $900,$900,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$800,$800,$990,$990,$110,$110
	dc.w $aa0,$aa0,$220,$220,$bb0,$bb0,$330,$330
	dc.w $440,$440,$cc0,$cc0,$550,$550,$dd0,$dd0
	dc.w $660,$660,$ee0,$ee0,$770,$770,$ff0,$ff0
	dc.w $ff0,$ff0,$770,$770,$ee0,$ee0,$660,$660
	dc.w $dd0,$dd0,$550,$550,$cc0,$cc0,$440,$440
	dc.w $bb0,$bb0,$330,$330,$aa0,$aa0,$220,$220
	dc.w $990,$990,$110,$110,$880,$880,$000,$000
	dc.w $000,$000,$080,$080,$010,$010,$090,$090
	dc.w $020,$020,$0a0,$0a0,$030,$030,$0b0,$0b0
	dc.w $040,$040,$0c0,$0c0,$050,$050,$0d0,$0d0
	dc.w $060,$060,$0e0,$0e0,$070,$070,$0f0,$0f0
	dc.w $0f0,$0f0,$070,$070,$0e0,$0e0,$060,$060
	dc.w $0d0,$0d0,$050,$050,$0c0,$0c0,$040,$040
	dc.w $0b0,$0b0,$030,$030,$0a0,$0a0,$020,$020
	dc.w $090,$090,$010,$010,$080,$080,$000,$000
	dc.w $000,$000,$088,$088,$011,$011,$099,$099
	dc.w $022,$022,$0aa,$0aa,$033,$033,$0bb,$0bb
	dc.w $044,$044,$0cc,$0cc,$055,$055,$0dd,$0dd
	dc.w $066,$066,$0ee,$0ee,$077,$077,$0ff,$0ff
	dc.w $0ff,$0ff,$077,$077,$0ee,$0ee,$066,$066
	dc.w $0dd,$0dd,$055,$055,$0cc,$0cc,$044,$044
	dc.w $0bb,$0bb,$033,$033,$0aa,$0aa,$022,$022
	dc.w $099,$099,$011,$011,$088,$088,$000,$000
	dc.w $000,$000,$008,$008,$001,$001,$009,$009
	dc.w $002,$002,$00a,$00a,$003,$003,$00b,$00b
	dc.w $004,$004,$00c,$00c,$005,$005,$00d,$00d
	dc.w $006,$006,$00e,$00e,$007,$007,$00f,$00f
	dc.w $00f,$00f,$007,$007,$00e,$00e,$006,$006
	dc.w $00d,$00d,$005,$005,$00c,$00c,$004,$004
	dc.w $00b,$00b,$003,$003,$00a,$00a,$002,$002
	dc.w $009,$009,$001,$001,$008,$008,$000,$000
	dc.w $000,$000,$808,$808,$101,$101,$909,$909
	dc.w $202,$202,$a0a,$a0a,$303,$303,$b0b,$b0b
	dc.w $404,$404,$c0c,$c0c,$505,$505,$d0d,$d0d
	dc.w $606,$606,$e0e,$e0e,$707,$707,$f0f,$f0f
	dc.w $f0f,$f0f,$707,$707,$e0e,$e0e,$606,$606
	dc.w $d0d,$d0d,$505,$505,$c0c,$c0c,$404,$404
	dc.w $b0b,$b0b,$303,$303,$a0a,$a0a,$202,$202
	dc.w $909,$909,$101,$101,$808,$808,$000,$000
	dc.w $000,$000,$888,$888,$111,$111,$999,$999
	dc.w $222,$222,$aaa,$aaa,$333,$333,$bbb,$bbb
	dc.w $444,$444,$ccc,$ccc,$555,$555,$ddd,$ddd
	dc.w $666,$666,$eee,$eee,$777,$777,$fff,$fff
	dc.w $fff,$fff,$777,$777,$eee,$eee,$666,$666
	dc.w $ddd,$ddd,$555,$555,$ccc,$ccc,$444,$444
	dc.w $bbb,$bbb,$333,$333,$aaa,$aaa,$222,$222
	dc.w $999,$999,$111,$111,$888,$888,$000,$000
	dc.w $000,$000,$800,$800,$300,$300,$b00,$b00
	dc.w $400,$400,$c00,$c00,$510,$510,$d90,$d90
	dc.w $520,$520,$da0,$da0,$630,$630,$eb0,$eb0
	dc.w $640,$640,$ec0,$ec0,$750,$750,$fd0,$fd0
	dc.w $fd0,$fd0,$750,$750,$ec0,$ec0,$640,$640
	dc.w $eb0,$eb0,$630,$630,$da0,$da0,$520,$520
	dc.w $d90,$d90,$510,$510,$c00,$c00,$400,$400
	dc.w $b00,$b00,$300,$300,$800,$800,$000,$000
	dc.w $000,$000,$800,$800,$100,$100,$980,$980
	dc.w $210,$210,$a98,$a98,$321,$321,$ba9,$ba9
	dc.w $432,$432,$cba,$cba,$543,$543,$dcb,$dcb
	dc.w $654,$654,$edc,$edc,$765,$765,$fed,$fed
	dc.w $fed,$fed,$765,$765,$edc,$edc,$654,$654
	dc.w $dcb,$dcb,$543,$543,$cba,$cba,$432,$432
	dc.w $ba9,$ba9,$321,$321,$a98,$a98,$210,$210
	dc.w $980,$980,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$800,$800,$100,$100,$908,$908
	dc.w $201,$201,$a89,$a89,$312,$312,$b9a,$b9a
	dc.w $423,$423,$cab,$cab,$534,$534,$dbc,$dbc
	dc.w $645,$645,$ecd,$ecd,$756,$756,$fde,$fde
	dc.w $fde,$fde,$756,$756,$ecd,$ecd,$645,$645
	dc.w $dbc,$dbc,$534,$534,$cab,$cab,$423,$423
	dc.w $b9a,$b9a,$312,$312,$a89,$a89,$201,$201
	dc.w $908,$908,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$080,$080,$010,$010,$098,$098
	dc.w $021,$021,$8a9,$8a9,$132,$132,$9ba,$9ba
	dc.w $243,$243,$acb,$acb,$354,$354,$bdc,$bdc
	dc.w $465,$465,$ced,$ced,$576,$576,$dfe,$dfe
	dc.w $dfe,$dfe,$576,$576,$ced,$ced,$465,$465
	dc.w $bdc,$bdc,$354,$354,$acb,$acb,$245,$245
	dc.w $9ba,$9ba,$132,$132,$8a9,$8a9,$021,$021
	dc.w $098,$098,$010,$010,$080,$080,$000,$000
	dc.w $000,$000,$080,$080,$010,$010,$890,$890
	dc.w $120,$120,$9a8,$9a8,$231,$231,$ab9,$ab9
	dc.w $342,$342,$bca,$bca,$453,$453,$cdb,$cdb
	dc.w $564,$564,$dec,$dec,$675,$675,$efd,$efd
	dc.w $efd,$efd,$675,$675,$dec,$dec,$564,$564
	dc.w $cdb,$cdb,$453,$453,$bca,$bca,$342,$342
	dc.w $ab9,$ab9,$231,$231,$9a8,$9a8,$120,$120
	dc.w $890,$890,$010,$010,$080,$080,$000,$000
	dc.w $000,$000,$008,$008,$001,$001,$089,$089
	dc.w $012,$012,$89a,$89a,$123,$123,$9ab,$9ab
	dc.w $234,$234,$abc,$abc,$345,$345,$bcd,$bcd
	dc.w $456,$456,$cde,$cde,$567,$567,$def,$def
	dc.w $def,$def,$567,$567,$cde,$cde,$456,$456
	dc.w $bcd,$bcd,$345,$345,$abc,$abc,$234,$234
	dc.w $9ab,$9ab,$123,$123,$89a,$89a,$012,$012
	dc.w $089,$089,$001,$001,$008,$008,$000,$000
	dc.w $000,$000,$008,$008,$001,$001,$809,$809
	dc.w $102,$102,$98a,$98a,$213,$213,$a9b,$a9b
	dc.w $324,$324,$bac,$bac,$435,$435,$cbd,$cbd
	dc.w $546,$546,$dce,$dce,$657,$657,$edf,$edf
	dc.w $edf,$edf,$657,$657,$dce,$dce,$546,$546
	dc.w $cbd,$cbd,$435,$435,$bac,$bac,$324,$324
	dc.w $a9b,$a9b,$213,$213,$98a,$98a,$102,$102
	dc.w $809,$809,$001,$001,$008,$008,$000,$000
	dc.w $000,$000,$800,$800,$100,$100,$900,$900
	dc.w $200,$200,$a88,$a88,$311,$311,$b99,$b99
	dc.w $422,$422,$caa,$caa,$533,$533,$dbb,$dbb
	dc.w $644,$644,$ecc,$ecc,$755,$755,$fdd,$fdd
	dc.w $fdd,$fdd,$755,$755,$ecc,$ecc,$644,$644
	dc.w $dbb,$dbb,$533,$533,$caa,$caa,$422,$422
	dc.w $b99,$b99,$311,$311,$a88,$a88,$200,$200
	dc.w $900,$900,$100,$100,$800,$800,$000,$000
	dc.w $000,$000,$888,$888,$111,$111,$999,$999
	dc.w $222,$222,$aaa,$aaa,$333,$333,$bbb,$bbb
	dc.w $444,$444,$ccc,$ccc,$555,$555,$ddd,$ddd
	dc.w $666,$666,$eee,$eee,$777,$777,$fff,$fff
	dc.w $fff,$fff,$777,$777,$eee,$eee,$666,$666
	dc.w $ddd,$ddd,$555,$555,$ccc,$ccc,$444,$444
	dc.w $bbb,$bbb,$333,$333,$aaa,$aaa,$222,$222
	dc.w $999,$999,$111,$111,$888,$888,$000,$000
fin_pal	dc.w $000,$000,$800,$800,$100,$100,$900,$900
	dc.w $200,$200,$a00,$a00,$300,$300,$b00,$b00
	dc.w $400,$400,$c00,$c00,$500,$500,$d00,$d00
	dc.w $600,$600,$e00,$e00,$700,$700,$f00,$f00

message	dc.b 180,180,180,180,180,180,180,180,180,180
	dc.b 180,180,180,180,180,180,180,180,180,180
	dc.b 180,180,180,180,180,180,180,180,180,180
	dc.b 180,180,180,180,180,180,180,180,180,180
	dc.b 0,1,2,3,4,5,6,7,8,9
	dc.b 10,11,12,13,14,15,16,17,18,19
	dc.b 20,21,22,23,24,25,26,27,28,29
	dc.b 30,31,32,33,34,35,36,37,38,39
	dc.b 40,41,42,43,44,45,46,47,48,49
	dc.b 50,51,52,53,54,55,56,57,58,59
	dc.b 60,61,62,63,64,65,66,67,68,69
	dc.b 70,71,72,73,74,75,76,77,78,79
	dc.b 80,81,82,83,84,85,86,87,88,89
	dc.b 90,91,92,93,94,95,96,97,98,99
	dc.b 100,101,102,103,104,105,106,107,108,109
	dc.b 110,111,112,113,114,115,116,117,118,119
	dc.b 120,121,122,123,124,125,126,127,128,129
	dc.b 130,131,132,133,134,135,136,137,138,139
	dc.b 140,141,142,143,144,145,146,147,148,149
	dc.b 150,151,152,153,154,155,156,157,158,159
	dc.b 160,161,162,163,164,165,166,167,168,169
	dc.b 170,171,172,173,174,175,176,177,178,179
	dc.b 180,180,180,180,180,180,180,180,180,180
	dc.b -1
	even

tab_font	
n	set 0
	rept 181
	dc.l fonte+n
n	set n+16
	endr
t_spr1	
n	set 0
	rept 16
	dc.l spr_1+n
n	set n+192
	endr
t_mspr1	
n	set 0
	rept 16
	dc.l mspr_1+n
n	set n+384
	endr
	
logo	incbin 'e:\langages\devpac2\spectrum\spc_base.3p'

prism	dc.w $0000,$FFE7,$FCCF,$F9C7,$0000,$0001,$FFE7,$FCCF
	dc.w $F9E7,$8000,$0003,$8066,$0CCC,$01F7,$C000,$0007
	dc.w $0066,$0CCC,$01BE,$E000,$000E,$0066,$0CCC,$019E
	dc.w $7000,$001C,$0067,$FCCF,$F98E,$3800,$003F,$FFE7
	dc.w $FCCF,$F986,$1C00,$007F,$FFE7,$C0C0,$1980,$0E00
	dc.w $00E0,$0006,$E0C0,$1980,$0700,$01C0,$0006,$70C0
	dc.w $1980,$0380,$0380,$0006,$38CF,$F980,$01C0,$0700
	dc.w $0006,$1CCF,$F980,$00E0,$0E00,$0000,$0000,$0000
	dc.w $0070,$1C00,$0000,$0000,$0000,$0038,$3FFF,$FFFF
	dc.w $FFFF,$FFFF,$FFFC,$7FFF,$FFFF,$FFFF,$FFFF,$FFFE
	
fonte	incbin 'e:\langages\devpac2\spectrum\fonte.dat'

	section bss
	
buffer	ds.b 64256
sbuf1	ds.b 768
sbuf2	ds.b 768
spr_1	ds.b 192*16
mspr_1	ds.b 192*32
anc_pal	ds.w 16
anc_ecr	ds.l 1
anc_vbl	ds.l 1
anc_hbl	ds.l 1
mes_pnt	ds.l 1
pos_pal	ds.l 1
s_pos_pal	ds.l 1
ecran1	ds.l 1
pos_spr	ds.l 1
pos_x	ds.l 1
save_pos	ds.l 1
save_pos1	ds.l 1
pos_buf1	ds.l 1
pos_buf2	ds.l 1
pos1	ds.l 1
pos2	ds.l 1
mfp1	ds.b 1
mfp2	ds.b 1
mfp3	ds.b 1
mfp4	ds.b 1
mfp5	ds.b 1
mfp6	ds.b 1
mfp7	ds.b 1
res	ds.b 1
compt	ds.b 1 
	even
	
	end
	