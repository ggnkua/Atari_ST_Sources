; ALIEN MUTATION PREVIEW
; Coded by Epsilon in 1989
; source code for Overlanders compil code

 lea $64000,sp
 move.w #4,-(sp)
 trap #$e
 addq.l #2,sp
 cmpi.w #2,d0
 bne.s basse_resol
erreur:
 clr.w -(sp)
 trap #1
basse_resol:
 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.b #$12,$fffffc02
 clr.w -(sp)
 move.l #$75000,-(sp)
 move.l #$75000,-(sp)
 move.w #5,-(sp)
 trap #$e
 adda.l #12,sp
 jsr Eff_pal
 lea $64000,a3
 lea PIC2+34,a5
 jsr decomp
 lea $75000+160,a3
 lea PIC1+34,a5
 jsr decomp
 lea $75000+160,a0
 lea $6a000+160,a1
 move.w #7999,d0
dpl_scr:
 move.l (a0)+,(a1)+
 dbra d0,dpl_scr
 lea $64000+16000,a0
 lea $75000+32320,a1
 lea $6a000+32320,a2
 move.w #959,d0
dpl_leds:
 move.l (a0),(a1)+
 move.l (a0)+,(a2)+
 dbra d0,dpl_leds
 jsr calc_ad
 jsr MOD_TXT
 lea music,a0
 lea $60000,a1
 move.w #(FIN_MUS-music)/4,d0
dpl_mus:
 move.l (a0)+,(a1)+
 dbra d0,dpl_mus
 jsr player
 move.l #$75000,screen
 move.l #$6a000,screen1
 jsr init
loop:
 moveq #0,d0
 move.b $fffffc02,d0
 cmp.b #$3b,d0
 blt.s loop
 cmp.b #$3d,d0
 bge.s loop
 subi.b #$3b,d0
 andi.l #1,d0
 jsr player+2
 bra.s loop
screen:
 dc.l 0
screen1:
 dc.l 0
set_screen:
 move.l screen1,d0
 move.l screen,screen1
 move.l d0,screen
 asr.l #8,d0
 move.b d0,$ffff8203
 asr.l #8,d0
 move.b d0,$ffff8201
 rts
pt_vbl:
 dc.w 0
vbl:
 movem.l d0-a6,-(sp)
 addq.w #1,pt_vbl
 jsr set_screen
 move.b #199,$ffffa21
 move.b #8,$ffffa1b
 lea PIC1+2,a0
 lea $ffff8240,a1
 movem.l (a0),d0-d7
 movem.l d0-d7,(a1)
 jsr scroll
 jsr player+6
 jsr aff_spr
 movem.l (sp)+,d0-a6
 rte
Eff_pal:
 lea $ffff8240,a1
 move.w #15,d0
eff_pals1:
 clr.w (a1)+
 dbra d0,eff_pals1
 rts
init:
 bclr #0,$484
 clr.b $fffa1b
 Bset #0,$fFFFA07
 bset #0,$ffffa13
 bclr #5,$ffffa09
 move.l #mfp1,$120
 move.l #vbl,$70
 RTS
mfp1:
 movem.l d0-a0,-(sp)
 lea $fffffa21,a0
 move.b (a0),d0
ms1:
 cmp.b (a0),d0
 beq.s ms1
 bclr #1,$ffff820a
 rept 13
 dc.w $4e71
 endr
 bset #1,$ffff820a
 move.b (a0),d0
ms2:
 cmp.b (a0),d0
 beq.s ms2
 movem.l pal,d0-d7
 movem.l d0-d7,$ffff8240
 movem.l (sp)+,d0-a0
 clr.b $fffa1b
 bclr #0,$ffffa0f
 rte
pal:
 dc.w $000,$222,$020,$030,$050,$200,$300,$500
 dc.w $000,$333,$040,$050,$070,$400,$500,$700
aff_spr:
 move.b #8,$ff8800
 move.b $ff8800,d2
 andi.l #15,d2
 move.l screen,a0
 ADD.L #6+32320,A0
 jsr part_g
 move.l screen,a0
 add.l #102+32320,a0
 jsr part_d
 move.b #9,$ff8800
 move.b $ff8800,d2
 andi.l #15,d2
 move.l screen,a0
 add.l #1286+32320,a0
 jsr part_g
 move.l screen,a0
 add.l #1382+32320,a0
 jsr part_d
 move.b #10,$ff8800
 move.b $ff8800,d2
 andi.l #15,d2
 move.l screen,a0
 add.l #2566+32320,a0
 jsr part_g
 move.l screen,a0
 add.l #2662+32320,a0
part_d:
 move.l a0,a1
 moveq #7,d0
pd1:
 move.w #0,(a1)
 move.w #0,$a0(a1)
 move.w #0,$140(a1)
 move.w #0,$1e0(a1)
 move.w #0,$280(a1)
 move.w #0,$320(a1)
 move.w #0,$3c0(a1)
 lea 8(a1),a1
 dbra d0,pd1
 tst.b d2
 beq.s pd3
 move.l d2,d1
 lsr.b #1,d1
 move.l a0,a1
pd2:
 move.w #-1,(a1)
 move.w #-1,$a0(a1)
 move.w #-1,$140(a1)
 move.w #-1,$1e0(a1)
 move.w #-1,$280(a1)
 move.w #-1,$320(a1)
 move.w #-1,$3c0(a1)
 lea 8(a1),a1
 subq.w #1,d1
 bpl.s pd2
 lea -8(a1),a1
 move.l d2,d1
 andi.b #1,d1
 bne.s pd3
 move.b #0,1(a1)
 move.b #0,$a1(a1)
 move.b #0,$141(a1)
 move.b #0,$1e1(a1)
 move.b #0,$281(a1)
 move.b #0,$321(a1)
 move.b #0,$3c1(a1)
pd3:
 rts
part_g:
 moveq #7,d0
pg1:
 move.w #0,(a0)
 move.w #0,$a0(a0)
 move.w #0,$140(a0)
 move.w #0,$1e0(a0)
 move.w #0,$280(a0)
 move.w #0,$320(a0)
 move.w #0,$3c0(a0)
 lea 8(a0),a0
 dbra d0,pg1
 lea -8(a0),a0
 tst.b d2
 beq.s pg3
 move.l d2,d1
 lsr.b #1,d1
 move.l a0,a1
pg2:
 move.w #-1,(a1)
 move.w #-1,$a0(a1)
 move.w #-1,$140(a1)
 move.w #-1,$1e0(a1)
 move.w #-1,$280(a1)
 move.w #-1,$320(a1)
 move.w #-1,$3c0(a1)
 lea -8(a1),a1
 subq.w #1,d1
 bpl.s pg2
 move.l d2,d1
 andi.b #1,d1
 bne.s pg3
 lea 8(a1),a1
 move.b #0,(a1)
 move.b #0,$a0(a1)
 move.b #0,$140(a1)
 move.b #0,$1e0(a1)
 move.b #0,$280(a1)
 move.b #0,$320(a1)
 move.b #0,$3c0(a1)
pg3:
 rts
decomp:
 move.l #$c7,d4
 move.l #6,a0
 moveq #4,d6
 moveq #$28,d7
dec9:
 clr.b d1
 move.l a3,a4
dec8:
 move.l a4,-(sp)
 clr.b d3
dec7:
 move.b (a5)+,d0
 tst.b d0
 bmi.s dec1
 addq.b #1,d0
dec3:
 move.b (a5)+,(a4)+
 addq.b #1,d3
 move.l a4,d5
 btst #0,d5
 bne.s dec2
 add.l a0,a4
dec2:
 subq.b #1,d0
 bne.s dec3
 bra.s dec4
dec1:
 neg.b d0
 addq.b #1,d0
 move.b (a5)+,d2
dec6:
 move.b d2,(a4)+
 addq.b #1,d3
 move.l a4,d5
 btst #0,d5
 bne.s dec5
 add.l a0,a4
dec5:
 subq.b #1,d0
 bne.s dec6
dec4:
 cmp.b d7,d3
 BNE.S dec7
 move.l (sp)+,a4
 addq.l #2,a4
 addq.b #1,d1
 cmp.b d6,d1
 bne.s dec8
 add.l #$a0,a3
 dbra d4,dec9
 rts
scroll:
 move.l screen1,a1      ; tampon scroll
; add.l #32800,a1
 move.l a1,a2
 addq.l #8,a2
 move.l a1,a0
 move.l screen,a5
 add.l #$98,a5
 lea tampon2,a3
 moveq #19,d0
scr_s1:
 rept	38
 move.l (a2)+,(a0)+
 endr
 move.l a0,a2
 move.l a5,a4
 move.l (a4)+,(a2)+
 move.l (a4)+,(a2)+
 move.l a0,a2
 move.b 1(a2),(a0)+
 move.b 0(a3),(a0)+
 move.b 3(a2),(a0)+
 move.b 2(a3),(a0)+
 move.b 5(a2),(a0)+
 move.b 4(a3),(a0)+
 move.b 7(a2),(a0)+
 move.b 6(a3),(a0)+
 move.l a0,a2
 add.l #$a0,a5
 addq.l #8,a2
 addq.l #8,a3
 dbra d0,scr_s1
scr_s6:
 tst.w pt_lettre
 BEQ new_let
 subq.w #1,pt_lettre
 move.w pt_lettre,d0
 lea tampon,a0
 lea tampon2,a1
 cmp.w #3,d0
 beq scr_s2
 cmp.w #2,d0
 beq scr_s3
 cmp.w #1,d0
 beq scr_s4
 cmp.w #0,d0
 beq scr_s5
 bra new_let
scr_s2:
 moveq #19,d0
scr_s2_2:
 move.b (a0),(a1)
 move.b 2(a0),2(a1)
 move.b 4(a0),4(a1)
 move.b 6(a0),6(a1)
 add.l #16,a0
 addq.l #8,a1
 dbra d0,scr_s2_2
 rts
scr_s3:
 moveq #19,d0
scr_s3_2:
 move.b 1(a0),(a1)
 move.b 3(a0),2(a1)
 move.b 5(a0),4(a1)
 move.b 7(a0),6(a1)
 add.l #16,a0
 addq.l #8,a1
 dbra d0,scr_s3_2
 rts
scr_s4:
 moveq #19,d0
scr_s4_2:
 move.b 8(a0),(a1)
 move.b 10(a0),2(a1)
 move.b 12(a0),4(a1)
 move.b 14(a0),6(a1)
 add.l #16,a0
 addq.l #8,a1
 dbra d0,scr_s4_2
 rts
scr_s5:
 moveq #19,d0
scr_s5_2:
 move.b 9(a0),(a1)
 move.b 11(a0),2(a1)
 move.b 13(a0),4(a1)
 move.b 15(a0),6(a1)
 add.l #16,a0
 addq.l #8,a1
 dbra d0,scr_s5_2
 rts
new_let:
 lea message,a0
 move.w pt_mes,d0
 move.b (a0,d0.w),d1
 cmp.b #-1,d1
 bne.s new_s1
 clr.w pt_mes
 bra.s new_let
new_s1:
 addq.w #1,pt_mes
 lea ad_let,a1
 move.b d1,d2
 ext.w d1
 asl.w #2,d1
 move.l (a1,d1.w),a1
 lea tampon,a0
 moveq #19,d0
new_s2:
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 move.l (a1)+,(a0)+
 lea $90(a1),a1
 dbra d0,new_s2
 cmp.b #8,d2
 beq.s short
 cmp.b #27,d2
 beq.s short
 cmp.b #36,d2
 beq.s short
 cmp.b #38,d2
 beq.s short
 cmp.b #39,d2
 beq.s short
 CMP.B #40,d2
 beq.s short
 cmp.b #41,d2
 beq.s short
 cmp.b #43,d2
 beq.s short
 cmp.b #45,d2
 beq.s short
 cmp.b #46,d2
 beq.s short
 move.w #4,pt_lettre
 bra scr_s6
short:
 move.w #2,pt_lettre
 bra scr_s6
MOD_TXT:
 LEA message,A0
mods1:
 move.b (a0),d0
 BMI mods16
 cmp.b #"A",d0
 blt.s mods2
 cmp.b #"Z",d0
 bhi.s mods2
 sub.b #"A",d0
 BRA mods15
mods2:
 cmp.b #"0",d0
 blt.s mods3
 cmp.b #"9",d0
 bhi.s mods3
 sub.b #"0"-26,d0
 BRA mods15
mods3:
 cmp.b #"!",d0
 bne.s mods4
 move.b #36,d0
 bra.s mods15
mods4:
 cmp.b #'"',d0
 bne.s mods5
 move.b #37,d0
 bra.s mods15
mods5:
 cmp.b #"'",d0
 bne.s mods6
 move.b #38,d0
 bra.s mods15
mods6:
 cmp.b #"(",d0
 bne.s mods7
 move.b #39,d0
 bra.s mods15
mods7:
 cmp.b #")",d0
 bne.s mods8
 move.b #40,d0
 bra.s mods15
mods8:
 cmp.b #",",d0
 bne.s mods9
 move.b #41,d0
 bra.s mods15
mods9:
 cmp.b #"-",d0
 bne.s mods10
 move.b #42,d0
 bra.s mods15
mods10:
 cmp.b #".",d0
 bne.s mods11
 move.b #43,d0
 bra.s mods15
mods11:
 cmp.b #"?",d0
 bne.s mods12
 move.b #44,d0
 bra.s mods15
mods12:
 cmp.b #":",d0
 bne.s mods13
 move.b #45,d0
 bra.s mods15
mods13:
 cmp.b #";",d0
 bne.s mods14
 move.b #46,d0
 bra.s mods15
mods14:
 move.b #47,d0
mods15:
 move.b d0,(a0)+
 BRA mods1
mods16:
 rts
calc_ad:
 lea ad_let,a0
 moveq #4,d0
 move.l #$64000,d2
calc_s1:
 moveq #9,d1
calc_s2:
 move.l d2,(a0)+
 addi.w #$10,d2
 dbra d1,calc_s2
 add.w #$be0,d2
 DBRA D0,calc_s1
 rts
ad_let:
 ds.l 50
PIC1:
 incbin \alien_de.mo\ALIEN_2.PC1
 even
PIC2:
 incbin \alien_de.mo\ALI_FNt.pc1
 even
player:
 incbin \alien_de.mo\mad_max.b
 even
music:
 incbin \alien_de.mo\tex_copy.b
FIN_MUS:
 even
message:
 dc.b "    OVERLANDERS COMPIL CODE            ",-1
 even
pt_lettre:
 dc.w 0
pt_mes:
 dc.w 0
               *bss
tampon:
 ds.b 20*16
tampon2:
 ds.b 20*8
fin_prg:
 end
?