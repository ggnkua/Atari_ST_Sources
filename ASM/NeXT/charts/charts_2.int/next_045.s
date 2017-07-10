affiche_balle macro
 move.l offset_balle,a2
 moveq #64,d1
ball_2 
 lea buf_x15_balle,a0
 lea buf_masque,a3
 move.l buf1,a1

 add.w (a2)+,a1
 add.w (a2)+,a0
 add.w (a2)+,a3

 movem.l (a3)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 and.l d0,(a1)
 and.l d0,4(a1)
 and.l d2,8(a1)
 and.l d2,12(a1)
 
 and.l d3,160(a1)
 and.l d3,164(a1)
 and.l d4,168(a1)
 and.l d4,172(a1)
 
 and.l d5,320(a1)
 and.l d5,324(a1)
 and.l d6,328(a1)
 and.l d6,332(a1)
 
 movem.l (a3)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 and.l d0,480(a1)
 and.l d0,484(a1)
 and.l d2,488(a1)
 and.l d2,492(a1)
 
 and.l d3,640(a1)
 and.l d3,644(a1)
 and.l d4,648(a1)
 and.l d4,652(a1)
 
 and.l d5,800(a1)
 and.l d5,804(a1)
 and.l d6,808(a1)
 and.l d6,812(a1)
 
 movem.l (a3)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 and.l d0,960(a1)
 and.l d0,964(a1)
 and.l d2,968(a1)
 and.l d2,972(a1)
 
 and.l d3,1120(a1)
 and.l d3,1124(a1)
 and.l d4,1128(a1)
 and.l d4,1132(a1)

 and.l d5,1280(a1)
 and.l d5,1284(a1)
 and.l d6,1288(a1)
 and.l d6,1292(a1) 

 movem.l (a3)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 and.l d0,1440(a1)
 and.l d0,1444(a1)
 and.l d2,1448(a1)
 and.l d2,1452(a1)
 
 and.l d3,1600(a1)
 and.l d3,1604(a1)
 and.l d4,1608(a1)
 and.l d4,1612(a1)
 
 
  
 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,(a1)
 or.l d2,4(a1)
 or.l d3,8(a1)
 or.l d4,12(a1)

 or.l d5,160(a1)
 or.l d6,164(a1)
 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,168(a1)
 or.l d2,172(a1)

 or.l d3,320(a1)
 or.l d4,324(a1)
 or.l d5,328(a1)
 or.l d6,332(a1)

 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,480(a1)
 or.l d2,484(a1)
 or.l d3,488(a1)
 or.l d4,492(a1)
 
 or.l d5,640(a1)
 or.l d6,644(a1)
 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,648(a1)
 or.l d2,652(a1)
 
 or.l d3,800(a1)
 or.l d4,804(a1)
 or.l d5,808(a1)
 or.l d6,812(a1)
 
 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,960(a1)
 or.l d2,964(a1)
 or.l d3,968(a1)
 or.l d4,972(a1)

 or.l d5,1120(a1)
 or.l d6,1124(a1)
 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,1128(a1)
 or.l d2,1132(a1)

 or.l d3,1280(a1)
 or.l d4,1284(a1)
 or.l d5,1288(a1)
 or.l d6,1292(a1)

 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,1440(a1)
 or.l d2,1444(a1)
 or.l d3,1448(a1)
 or.l d4,1452(a1)

 or.l d5,1600(a1)
 or.l d6,1604(a1)
 movem.l (a0)+,d0/d2/d3/d4/d5/d6   ; 6*4=24
 or.l d0,1608(a1)
 or.l d2,1612(a1)
 
 dbra d1,ball_2
 move.l a2,offset_balle
 
 cmp.l #fin_table_balle,offset_balle
 bmi.s saute 
 move.l #table_balle,offset_balle
saute 
 endm

trace_points macro
 move.l #points,a2
 moveq #50-1,d7
point_suivant   
 move.l buf1,a1
 move.w 2(a2),d0
 move.w (a2),d1
 move.w d1,d2
 lsr.w #4,d1
 lsl.w #3,d1
 add.w d1,d0
 move.w d2,d1
 and.b #%11110000,d2
 sub.w d2,d1
 moveq #15,d2
 sub.w d1,d2
 move.w 0(a1,d0.w),d1
 bset.l d2,d1
 move.w d1,0(a1,d0.w)

 move.w 4(a2),d0
 add.w d0,(a2)
 move.w 6(a2),d0
 add.w d0,2(a2)
 
 cmp.w #320,(a2)
 bpl.s init_0
 cmp.w #160*199,2(a2)
 bpl.s init_0
 tst.w (a2)
 bmi.s init_0
 tst.w 2(a2)
 bmi.s init_0
 lea 8(a2),a2
 dbra d7,point_suivant
 bra fin_point
 
init_0
 move.w #160,(a2)
 move.w #160*90,2(a2)
 lea 8(a2),a2
 dbra d7,point_suivant
fin_point
 endm

reflete macro
 move.l buf1,a2
 lea 160*150(a2),a2
 move.l a2,a1
 moveq #50-1,d0
ref
 lea -320(a2),a2
 move.l a2,a0
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 dbra d0,ref
 endm

affiche_texte macro
 move.l offset_pos_texte,a2
 move.l (a2)+,d0
 move.l a2,offset_pos_texte
 tst.l d0
 bne.s saute_charge_texte
 bsr charge_texte
 lea pos_texte,a2
 move.l (a2)+,d0
 move.l a2,offset_pos_texte
saute_charge_texte
 lea buf_fonte,a0
 move.l buf1,a1
 add.l d0,a1
 moveq #7,d0
recop_buf 
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 dbra d0,recop_buf
 endm

palette_1 macro
 move.l #$00000777,$ffff8240.w
 move.l #$00400150,$ffff8244.w
 move.l #$02600370,$ffff8248.w
 move.l #$04040535,$ffff824c.w
 move.l #$06460757,$ffff8250.w
 move.l #$05000700,$ffff8254.w
 move.l #$07400750,$ffff8258.w
 move.l #$07600770,$ffff825c.w
 endm

palette_2 macro
 move.l #$00020557,$ffff8240.w
 move.l #$00300040,$ffff8244.w
 move.l #$01500260,$ffff8248.w
 move.l #$03030424,$ffff824c.w
 move.l #$05350646,$ffff8250.w
 move.l #$04000600,$ffff8254.w
 move.l #$06300640,$ffff8258.w
 move.l #$06500660,$ffff825c.w
 endm
 
;
;
;  The Balls Demo Copyright 1990 Dbug II from T.T.Z.P. Inc.
;
;

 jmp gemdos_init


debut_programme
 pea main
 move.w #$26,-(sp)
 trap #14
 addq.l #6,sp
 clr.w -(sp)
 trap #1

main
 move.b #0,$ffff8260.w
 jsr initialisations

 move.l #buf_ecran,d0
 and.l #$ffffff00,d0
 addi.l #256,d0
 move.l d0,buf1
 addi.l #32000,d0
 move.l d0,buf2

 jsr cls
 jsr affiche_presentation
 jsr charge_graphiques
 jsr init_buffers
 jsr convert
 jsr charge_texte
 jsr vbl_on

loop
 lea page_de_fonds,a0
 move.l buf1,a1
 move #151-1,d0
recopie_fonds
 rept 40
 move.l (a0)+,(a1)+
 endr
 dbra d0,recopie_fonds

 affiche_texte
 trace_points
 affiche_balle
 reflete
 
commute_ecran
 move.l buf1,d0         ; charge adresse dans d0
 asr.l #8,d0            ; prend l'octet faible
 move.b d0,$ffff8203.w  ; stocke dans registre video
 asr.l #8,d0            ; idem pour l'octet fort
 move.b d0,$ffff8201.w
 
 move.w #$25,-(sp)   ; vsync
 trap #14
 addq.l #2,sp        ; retour au programme principal

 move.l buf2,d0      ; puis on swappe les adresses logique-physique
 move.l buf1,buf2
 move.l d0,buf1

 cmpi.b #$39,$fffffc02.w
 bne loop
 
sort_loop 
 move.w #$000,$ffff8240.w 
 
 jsr vbl_off
 jsr cls
 rts
 
*****************
*
* Sous Routines *
*
*****************

charge_texte
 move.l offset_texte,a2
 lea buf_fonte,a5
 move.l #gfx_fonte,a6

 move.l #19,d7
aff_fnt 
 moveq #0,d0
 moveq #0,d1
 move.b (a2)+,d0
 move.b (a2)+,d1
 eor.b #77,d0
 eor.b #77,d1 
 lsl.w #5,d0
 lsl.w #5,d1
 
 move.l a6,a0
 move.l a6,a1
 add.l d0,a0
 add.l d1,a1
 
 move.b (a0)+,0(a5)
 move.b (a1)+,1(a5)
 move.b (a0)+,2(a5)
 move.b (a1)+,3(a5)
 move.b (a0)+,4(a5)
 move.b (a1)+,5(a5)
 move.b (a0)+,6(a5)
 move.b (a1)+,7(a5)

 move.b (a0)+,160(a5)
 move.b (a1)+,161(a5)
 move.b (a0)+,162(a5)
 move.b (a1)+,163(a5)
 move.b (a0)+,164(a5)
 move.b (a1)+,165(a5)
 move.b (a0)+,166(a5)
 move.b (a1)+,167(a5)

 move.b (a0)+,320(a5)
 move.b (a1)+,321(a5)
 move.b (a0)+,322(a5)
 move.b (a1)+,323(a5)
 move.b (a0)+,324(a5)
 move.b (a1)+,325(a5)
 move.b (a0)+,326(a5)
 move.b (a1)+,327(a5)

 move.b (a0)+,480(a5)
 move.b (a1)+,481(a5)
 move.b (a0)+,482(a5)
 move.b (a1)+,483(a5)
 move.b (a0)+,484(a5)
 move.b (a1)+,485(a5)
 move.b (a0)+,486(a5)
 move.b (a1)+,487(a5)

 move.b (a0)+,640(a5)
 move.b (a1)+,641(a5)
 move.b (a0)+,642(a5)
 move.b (a1)+,643(a5)
 move.b (a0)+,644(a5)
 move.b (a1)+,645(a5)
 move.b (a0)+,646(a5)
 move.b (a1)+,647(a5)

 move.b (a0)+,800(a5)
 move.b (a1)+,801(a5)
 move.b (a0)+,802(a5)
 move.b (a1)+,803(a5)
 move.b (a0)+,804(a5)
 move.b (a1)+,805(a5)
 move.b (a0)+,806(a5)
 move.b (a1)+,807(a5)

 move.b (a0)+,960(a5)
 move.b (a1)+,961(a5)
 move.b (a0)+,962(a5)
 move.b (a1)+,963(a5)
 move.b (a0)+,964(a5)
 move.b (a1)+,965(a5)
 move.b (a0)+,966(a5)
 move.b (a1)+,967(a5)

 move.b (a0)+,1120(a5)
 move.b (a1)+,1121(a5)
 move.b (a0)+,1122(a5)
 move.b (a1)+,1123(a5)
 move.b (a0)+,1124(a5)
 move.b (a1)+,1125(a5)
 move.b (a0)+,1126(a5)
 move.b (a1)+,1127(a5)

 add.l #8,a5 
 dbra d7,aff_fnt

 move.l a2,offset_texte
 cmp.l #fin_texte,a2
 bne saute_init_texte
 move.l #texte,offset_texte 
saute_init_texte 
 rts

vbl_on
 move.w #$2700,sr
 move.w #2,$454
 move.b #199,$fffa21
 move.l #hbl,$120
 move.b #8,$fffa1b
 move.l $4ce,sauve_4ce
 move.l $4d2,sauve_4d2
 move.l #vbl,$4ce
 move.b #%00000001,$fffa07
 move.b #%00000001,$fffa13
 moveq.l #1,d0
 jsr music
 move.l #music+8,$4d2
 move.w #$2300,sr
 rts

vbl_off
 move.l sauve_4ce,$4ce
 move.l sauve_4d2,$4d2
 move.b #0,$ffa21
 move.b #0,$fffa1b
 move.l #$ff8800,a0
 move.w #$0800,d0
 movep.w d0,(a0)
 move.w #$0900,d0
 movep.w d0,(a0)
 move.w #$0A00,d0
 movep.w d0,(a0)
 rts

hbl
 palette_2
 move.b #1,$fffa21
 bclr #0,$fffa0f
 rte

vbl
 palette_1
 move.l #hbl,$120
 clr.b $fffa1b
 move.b #150,$fffa21
 move.b #8,$fffa1b
 rts

charge_graphiques
 move.l #boule,a0
 lea buf_x15_balle,a1
 move.l #44-1,d0
recopie_boule
 move.l (a0)+,(a1)+
 dbra d0,recopie_boule 
 rts

convert
 lea buf_x15_balle,a0
 move.l #conv_1,a2
 move.l #3,d5
next_couleur 
 move.l #352-1,d7
r_aff
 move.w #15,d6
next_bit  
 roxl.w 4(a0)
 roxl.w d4
 roxl.w 2(a0)
 roxl.w d4
 roxl.w (a0)
 roxl.w d4
 and.w #%00000111,d4
 move.b 0(a2,d4),d4
 roxr.w d4
 roxl.w d0
 roxr.w d4
 roxl.w d1
 roxr.w d4
 roxl.w d2
 roxr.w d4
 roxl.w d3
 dbra d6,next_bit 
 move.w d0,(a0)+
 move.w d1,(a0)+
 move.w d2,(a0)+
 move.w d3,(a0)+
 dbra d7,r_aff
 add.l #6,a2
 dbra d5,next_couleur
 rts

cls
 move.l buf1,a0
 move.l buf2,a1
 move.l #31999,d0
cls_1
 clr.b (a0)+
 clr.b (a1)+
 dbra d0,cls_1
 rts

init_buffers
 lea buf_x15_balle,a1     ; recopie
 lea 2816*1(a1),a2
 lea 2816*2(a1),a3
 lea 2816*3(a1),a4
 moveq #15,d2
recopie_2
 lea buf_x15_balle,a0
 rept 44
 move.l (a0),(a1)+
 move.l (a0),(a2)+
 move.l (a0),(a3)+
 move.l (a0)+,(a4)+
 endr
 dbra d2,recopie_2

 lea fin_x15_balle,a0     ; predecalle
 move.l #4-1,d6
buffer_suivant 
 move.l #15,d5
scroll
 move.l d5,d3
 move.l #16,d0
 sub.l d3,d0
 move.l #88-1,d1
s1_2
 move.w (a0),d4
 move.w -8(a0),d2
 lsr.w d3,d4        ; decalle de D3 rotations
 lsl.w d0,d2
 add.w d2,d4
 move.w d4,(a0)
 subq.l #2,a0
 dbra d1,s1_2
 dbra d5,scroll
 dbra d6,buffer_suivant

 lea buf_x15_balle,a0   ; calcul des masques
 lea buf_masque,a1
 move.l #352-1,d0
calcule_masque
 move.w (a0)+,d0
 or.w (a0)+,d0
 or.w (a0)+,d0
 or.w (a0)+,d0
 not d0
 move.w d0,(a1)+
 move.w d0,(a1)+
 dbra d0,calcule_masque   
 rts

initialisations
 move.l #table_balle,offset_balle
 move.l #texte,offset_texte
 move.l #pos_texte,offset_pos_texte
 rts
  
gemdos_init:
 move.l a7,a5
 move.l 4(a5),a5
 move.l $c(a5),d0
 add.l $14(a5),d0
 add.l $1c(a5),d0
 add.l #$500,d0
 move.l d0,d1
 add.l a5,d1
 and.l #-2,d1
 move.l d1,a7
 move.l d0,-(sp)
 move.l a5,-(sp)
 clr.w -(sp)
 move.w #$4a,-(sp)
 trap #1
 add.l #12,sp
 jmp debut_programme

efface_palette
 move.l a0,-(sp)
 move.l d0,-(sp)
 lea $ff8240,a0
 move.l #7,d0
eff
 clr.l (a0)+
 dbra d0,eff
 move.l (sp)+,d0
 move.l (sp)+,a0
 rts

affiche_presentation
 palette_1

 lea page_de_fonds,a0
 move.l #8000-1,d0
efface_page
 move.l #0,(a0)+
 dbra d0,efface_page
  
 move.l #gfx_next,a0
 lea page_de_fonds,a1
 add.l #40,a1
 move.l #46,d0
aff_nxt
 rept 80
 move.b (a0)+,(a1)+
 endr
 add.l #80,a1
 dbra d0,aff_nxt

 move.l #gfx_next_2,a0
 lea page_de_fonds,a1
 add.l #72+47*160,a1
 move.l #8,d0
aff_nxt_2
 rept 24
 move.b (a0)+,(a1)+
 endr
 add.l #136,a1
 dbra d0,aff_nxt_2
 
 move.l #gfx_the,a0
 lea page_de_fonds,a1
 add.l #8+73*160,a1
 move.l #44,d0
aff_the
 rept 56
 move.b (a0)+,(a1)+
 endr
 add.l #104,a1
 dbra d0,aff_the

 move.l #gfx_charts,a0
 lea page_de_fonds,a1
 add.l #64+56*160,a1
 move.l #82,d0
aff_chrt
 rept 88
 move.b (a0)+,(a1)+
 endr
 add.l #72,a1
 dbra d0,aff_chrt
 rts

 section DATA
 
boule       incbin "balls.dat"
gfx_the     incbin "The.gfx"
gfx_next    incbin "NeXT.gfx"
gfx_next_2  incbin "NeXT_2.gfx"
gfx_charts  incbin "Charts.gfx"
gfx_fonte   incbin "Fonte.gfx" 
points      incbin "star_160.dat"
table_balle incbin "next_160.coo"
fin_table_balle
music       incbin "atomic.mus"
 even

texte  incbin "message.txt"  
fin_texte
 even
  
pos_texte
 dc.l 160*151,160*150,160*149,160*148,160*147,160*146,160*145
 dc.l 160*144,160*143,160*142
 rept 50
 dc.l 160*141
 endr
 dc.l 160*142,160*143,160*144,160*145,160*146,160*147,160*148
 dc.l 160*149,160*150,160*151
 dc.l 0

conv_1 dc.b 00,01,02,03,04,05
conv_2 dc.b 00,01,06,07,08,09
conv_3 dc.b 00,01,10,11,12,13
conv_4 dc.b 00,01,12,13,14,15

reg   dc.l r 
r     dc.l 0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
 
 section BSS

val           ds.l 1
sauve_pile    ds.l 1
sauve_4ce     ds.l 1
sauve_4d2     ds.l 1
sauve_reg     ds.l 16
sauve_70      ds.l 1

offset_pos_texte ds.l 1
offset_texte     ds.l 1
offset_balle     ds.l 1
buf              ds.l 1
buf1             ds.l 1
buf2             ds.l 1

 even

buf_ecran     ds.b 64256
page_de_fonds ds.b 32000+10000

buf_fonte     ds.b 1280    
fin_fonte

buf_x15_balle ds.b 2816*4
fin_x15_balle
 
buf_masque    ds.b 1408*4
fin_masque

 end
