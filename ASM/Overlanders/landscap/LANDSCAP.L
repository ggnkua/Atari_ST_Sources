screen equ $75000

 clr.l -(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 move.l d0,ancpile
 jsr save_pal
 jsr init_pt
 jsr mod_txt32
 jsr decomp_pic
 jsr get_blk
 jsr inter_on
 JSR SCR16_6
 CLR.W TEMPO_16
get_key:
 jsr scroll_16
 jsr aff_logo
 move.w #$00ff,-(sp)
 move.w #6,-(sp)
 trap #1
 addq.l #4,sp
 cmp.b #32,d0
 bne.s get_key
 jsr inter_off
 jsr load_pal
 move.l ancpile,-(sp)
 move.w #$20,-(sp)
 trap #1
 addq.l #6,sp
 clr.w -(sp)
 trap #1
ancpile:
 dc.l 0
ecran:
 dc.l 0
resol:
 dc.w 0
pal_back:
 ds.w 32,0
save_pal:
 move.w #3,-(sp)
 trap #$e
 addq.l #2,sp
 move.l d0,ecran
 move.w #4,-(sp)
 trap #$e
 addq.l #2,sp
 move.w d0,resol
 lea pal_back,a0
 lea $ffff8240,a1
 moveq #15,d0
spal1:
 move.w (a1),(a0)+
 clr.w (a1)+
 dbra d0,spal1
 clr.w -(sp)
 move.l #screen,-(sp)
 move.l #screen,-(sp)
 move.w #5,-(sp)
 trap #$e
 lea 12(sp),sp
 rts
load_pal:
 move.w resol,-(sp)
 move.l ecran,-(sp)
 move.l ecran,-(sp)
 move.w #5,-(sp)
 trap #$e
 lea 12(sp),sp
 pea pal_back
 move.w #6,-(sp)
 trap #$e
 addq.l #6,sp
 rts
decomp_pic:
 move.l #screen,a0
 move.w #$9600/4-1,d0
dpic1:
 clr.l (a0)+
 dbra d0,dpic1
 move.l fnt16,a3
 lea font_16+34,a5
 jsr decomp
 move.l fnt32,a3
 lea font_32+34,a5
 jsr decomp
 move.l #screen,a3
 lea titre+34,a5
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
 BNE.S DEC7
 move.l (sp)+,a4
 addq.l #2,a4
 addq.b #1,d1
 cmp.b d6,d1
 bne.s dec8
 add.l #$a0,a3
 dbra d4,dec9
 rts
get_blk:
 move.l pays32,a0
 move.l adscr32,a1
 move.w #(32*160)/4-1,d0
gets1:
 move.l (a0)+,(a1)+
 dbra d0,gets1
 move.l adscr16,a0
 move.l back16,a1
 move.w #(16*160)/4-1,d0
gets2:
 move.l (a0)+,(a1)+
 dbra d0,gets2
 move.l #screen,a0
 move.l tmp_logo,a1
 move.w #(50*160)/4-1,d0
gets3:
 move.l (a0)+,(a1)+
 dbra d0,gets3
 rts
deb_adr:
tmp_logo:   dc.l -$dd40
tmpscr16_2: dc.l -$be00
tmpscr16:   dc.l -$b400
tmp32:      dc.l -$aa00
adfnt16:    dc.l -$a900
adfnt32:    dc.l -$a800
back16:     dc.l -$a700
fnt16:      dc.l -$9d00
fnt32:      dc.l -$7d00
pays32:     dc.l -$1400
adscr32:    dc.l 32160
adscr16:    dc.l 131*160
init_pt:
 lea deb_adr,a0
 moveq #11,d0
inpt5:
 add.l #screen,(a0)+
 dbra d0,inpt5
 move.l adfnt16,a0
 move.l fnt16,d2
 moveq #2,d0
inpt1:
 moveq #19,d1
inpt2:
 move.l d2,(a0)+
 addq.l #8,d2
 dbra d1,inpt2
 add.l #15*160,d2
 dbra d0,inpt1
 move.l adfnt32,a0
 move.l fnt32,d2
 moveq #4,d0
inpt3:
 moveq #9,d1
inpt4:
 move.l d2,(a0)+
 add.l #16,d2
 dbra d1,inpt4
 add.l #31*160,d2
 dbra d0,inpt3
 move.w #16,pt_let16
 move.w #4,pt_let32
 rts
mod_txt32:
 lea txt_32,a0
 moveq #0,d0
mods1:
 move.b (a0),d0
 cmp.b #-1,d0
 beq fin_mod
 cmp.b #"A",d0
 blt.s mods2
 cmp.b #"Z",d0
 bhi.s mods2
 sub.b #"A",d0
 bra mods7
mods2:
 cmp.b #"0",d0
 blt.s mods3
 cmp.b #"9",d0
 bhi.s mods3
 sub.b #"0"-26,d0
 bra mods7
mods3:
 cmp.b #"'",d0
 blt.s mods4
 cmp.b #")",d0
 bhi.s mods4
 sub.b #"'"-36,d0
 bra mods7
mods4:
 cmp.b #",",d0
 blt.s mods5
 cmp.b #".",d0
 bhi.s mods5
 sub.b #","-40,d0
 bra mods7
mods5:
 cmp.b #"!",d0
 bne.s mods6
 move.b #39,d0
 bra mods7
mods6:
 cmp.b #":",d0
 bne.s mods6_2
 move.b #43,d0
 bra mods7
MODS6_2:
 move.b #44,d0
mods7:
 move.b d0,(a0)+
 bra mods1
fin_mod:
 rts
tempo_16:
 dc.w 0
scroll_16:
 cmp.w #16,pt_let16
 bne.s scr16_3
SCR16_6:
 moveq #19,d2
 move.l tmpscr16_2,a2
scr16_5:
 lea txt_16,a0
 move.w pt_txt16,d0
 move.b (a0,d0.w),d1
 bpl.s scr16_1
 clr.w pt_txt16
 bra.s scr16_5
scr16_1:
 addq.w #1,pt_txt16
 sub.b #32,d1
 ext.w d1
 asl #2,d1
 move.l adfnt16,a0
 move.l (a0,d1.w),a0
 move.l a2,a1
 moveq #15,d0
scr16_2:
 move.l 0(a0),0(a1)
 move.l 4(a0),4(a1)
 lea 160(a0),a0
 lea 160(a1),a1
 dbra d0,scr16_2
 addq.l #8,a2
 dbra d2,scr16_5
 clr.w pt_let16
 move.w #100,tempo_16
 rts
scr16_3:
 move.l tmpscr16,a0
 add.l #14*160,a0
 move.l a0,a1
 tst.w tempo_16
 bne.s scr16_4
 add.l #160,a1
scr16_4:
 movem.l (a0),d0-d7
 movem.l d0-d7,(a1)
 movem.l $20(a0),d0-d7
 movem.l d0-d7,$20(a1)
 movem.l $40(a0),d0-d7
 movem.l d0-d7,$40(a1)
 movem.l $60(a0),d0-d7
 movem.l d0-d7,$60(a1)
 movem.l $80(a0),d0-d7
 movem.l d0-d7,$80(a1)
 lea -160(a0),a0
 lea -160(a1),a1
 cmp.l tmpscr16_2,a1
 bne.s scr16_4
 tst.w tempo_16
 bne.s scr16_7
 addq.w #1,pt_let16
scr16_7:
 jsr aff_16
 rts
scroll_32:
 cmp.w #4,pt_let32
 bne.s scr32_3
 lea txt_32,a0
 move.w pt_txt32,d0
 move.b (a0,d0.w),d1
 bpl.s scr32_1
 clr.w pt_txt32
 bra.s scroll_32
scr32_1:
 addq.w #1,pt_txt32
 ext.w d1
 asl #2,d1
 move.l adfnt32,a0
 move.l (a0,d1.w),a0
 move.l tmp32,a1
 addq.l #6,a0
 moveq #31,d0
scr32_2:
 move.w (a0),(a1)+
 move.w 8(a0),(a1)+
 lea 160(a0),a0
 dbra d0,scr32_2
 clr.w pt_let32
scr32_3:
 move.l adscr32,a0
 move.l tmp32,a1
 move.w pt_let32,d0
 bclr #0,d0
 add.w d0,a1
 moveq #31,d1
 MOVEq #8,D2
scr32_4:
 moveq #0,d0
 move.w (a1),d0
 lsl.l d2,d0
 move.w d0,(a1)+
 swap d0
 moveq #0,d4
 move.w $9e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$9e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $96(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$96(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $8e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$8e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $86(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$86(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $7e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$7e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $76(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$76(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $6e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$6e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $66(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$66(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $5e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$5e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $56(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$56(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $4e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$4e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $46(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$46(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $3e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$3e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $36(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$36(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $2e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$2e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $26(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$26(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $1e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$1e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $16(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$16(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $e(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$e(a0)
 move.l d4,d0
 swap d0
 moveq #0,d4
 move.w $6(a0),d4
 lsl.l d2,d4
 or.w d0,d4
 move.w d4,$6(a0)
 adda.l #160,a0
 addq.l #2,a1
 dbra d1,scr32_4
 addq.w #1,pt_let32
 rts
AFF_16:
 move.l adscr16,A0
 move.l tmpscr16,A1
 move.l back16,A2
 MOVE.W #(16*160)/8-1,D0
AFF16_1:
 MOVE.W (A1)+,D1
 MOVE.W (A1)+,D2
 MOVE.W (A1)+,D3
 MOVE.W (A1)+,D4
 MOVE.W D1,D5
 OR.W D2,D5
 OR.W D3,D5
 OR.W D4,D5
 NOT.W D5
 MOVE.W (A2)+,D6
 AND.W D5,D6
 OR.W D1,D6
 MOVE.W D6,(A0)+
 MOVE.W (A2)+,D6
 AND.W D5,D6
 OR.W D2,D6
 MOVE.W D6,(A0)+
 MOVE.W (A2)+,D6
 AND.W D5,D6
 OR.W D3,D6
 MOVE.W D6,(A0)+
 MOVE.W (A2)+,D6
 AND.W D5,D6
 OR.W D4,D6
 MOVE.W D6,(A0)+
 DBRA D0,AFF16_1
 RTS
pt_logo:
 dc.w 0
pt_logo1: dc.w 52
pt_logo2: dc.w -1
aff_logo:
 lea pt_logo1,a2
 lea pt_logo2,a1
 move.l tmp_logo,a3
 move.l #screen,a4
 tst.w pt_logo
 bne.s logos1
 subq.w #2,(a2)
 addq.w #1,(a1)
 move.l #160,d4
 clr.l d5
 jsr logos3
 tst.w pt_logo1
 bne fin_logo
 addq.W #1,PT_LOGO
 move.w #-2,pt_logo1
 move.w #26,pt_logo2
 bra fin_logo
logos1:
 cmp.w #1,pt_logo
 bne.s logos2
 add.l #160*49,a3
 addq.w #2,(a2)
 subq.w #1,(a1)
 move.l #-320,d5
 move.l #-160,d4
 jsr logos3
 tst.w pt_logo2
 bne fin_logo
 addq.w #1,pt_logo
 move.w #52,pt_logo1
 move.w #-1,pt_logo2
 bra fin_logo
logos2:
 cmp.w #2,pt_logo
 bne.s logos2_2
 add.l #160*49,a3
 subq.w #2,(a2)
 addq.w #1,(a1)
 move.l #-320,d5
 move.l #-160,d4
 jsr logos3
 tst.w pt_logo1
 bne fin_logo
 addq.w #1,pt_logo
 move.w #-2,pt_logo1
 move.w #26,pt_logo2
 bra fin_logo
logos2_2:
 addq.w #2,(a2)
 subq.w #1,(a1)
 move.l #160,d4
 clr.l d5
 jsr logos3
 tst.w pt_logo2
 bne fin_logo
 clr.w pt_logo
 move.w #52,pt_logo1
 move.w #-1,pt_logo2
fin_logo:
 rts
logos3:
 move.l a3,a0
 move.l a4,a1
 move.w pt_logo2,d1
 mulu #160,d1
 add.l d1,a1
 move.l a1,a2
 sub.w #$140,a2
 move.w #$4f,d7
logos4:
 clr.l (a2)+
 dbra d7,logos4
 move.w pt_logo1,d0
 move.w #25,d1
 move.w #49,d2
logos5:
 add.w d0,d1
 cmp.w #50,d1
 blt.s logos7
 sub.w #50,d1
 moveq #$27,d3
logos6:
 move.l (a0)+,(a1)+
 dbra d3,logos6
 add.l d5,a0
 bra.s logos8
logos7:
 add.l d4,a0
logos8:
 dbra d2,logos5
 move.w #$4f,d7
logos9:
 clr.l (a1)+
 dbra d7,logos9
 rts
INTER_ON:
 st music+4730
 move.l #music+48,music+2
 move.l #music+48,music+12
 move.l #music+48,music+22
 jsr music
 CLR.B $FFFFFA1B
 MOVE.B $FFFFFA09,ANCA09
 ANDI.B #$DF,$FFFFFA09
 MOVE.B $FFFFFA07,ANCA07
 ANDI.B #$FE,$FFFFFA07
 MOVE.L #MFP,$120
 MOVE.B $FFFFFA13,ANCA13
 ORI.B #1,$FFFFFA07
 ORI.B #1,$FFFFFA13
 MOVE.L $70,ANCVBL
 MOVE.L #VBL,$70
 MOVE.B #$12,$FFFFFC02
 RTS
INTER_OFF:
 clr.l $4d2
 move.l #$8080000,-$7800
 move.l #$9090000,-$7800
 move.l #$a0a0000,-$7800
 MOVE.B ANCA09,$FFFFFA09
 MOVE.B ANCA07,$FFFFFA07
 MOVE.B ANCA13,$FFFFFA13
 MOVE.L ANCVBL,$70
 MOVE.B #$8,$FFFFFC02
 RTS
ANCVBL:
 DC.L 0
ANCA07: DC.B 0
ANCA09: DC.B 0
ANCA13: DC.W 0
MFP:
 MOVEM.L D0-A0,-(SP)
 LEA $FFFFFA21,A0
 MOVE.B (A0),D0
MFPS1:
 CMP.B (A0),D0
 BEQ.S MFPS1
 BCLR #1,$FFFF820A
 DS.W 12,$4E71
 BSET #1,$FFFF820A
 MOVEM.L FONT_32+2,D0-D7
 MOVEM.L D0-D7,$FFFF8240
 clr.b $fffffa1b
 BCLR #0,$FFFFFA0F
 MOVEM.L (SP)+,D0-A0
 RTE
pt_vbl: dc.w 0
VBL:
 MOVEM.L D0-a6,-(SP)
 tst.w tempo_16
 beq.s vbl_s1
 subq.w #1,tempo_16
vbl_s1:
 MOVE.w #1,PT_VBL
 MOVEM.L TITRE+2,D0-D7
 MOVEM.L D0-D7,$FFFF8240
 MOVE.B #199,$FFFFFA21
 MOVE.B #8,$FFFFFA1B
 jsr scroll_32
 move.l $4d2,a0
 jsr (a0)
 MOVEM.L (SP)+,D0-a6
 RTE
music:
 ibytes thrust.b
 align.w
pt_let32:
 dc.w 0
pt_txt32:
 dc.w 0
pt_let16:
 dc.w 0
pt_txt16:
 dc.w 0
font_16:
 ibytes fnt16_v1.pc1
 align.w
font_32:
 ibytes fnt32_v1.pc1
 align.w
titre:
 ibytes title.pc1
 align.w
 align.w
txt_16:
 dc.b " HELLO , LADIES AND ","GENTLEMEN, THE ALIEN"," TEAM, ARE PROUD TO "
 dc.b "   PRESENT  YOU :   ","THE LANDSCAPE-SCROLL"," ONE OF THE SEVERAL "
 dc.b "SCREEN OF THIS GREAT","DEMO ! IN FIRST , WE","  THANKS EPSILON ,  "
 DC.B "   BECAUSE HE HAD   ","PROGRAMMED THIS DEMO","ALONE WITH NO HELP !"
 DC.B "IT'S A GREAT PERFORM","   THEN WE THANKS   ","DR PSY AND DR KHEBLO"
 DC.B "FOR ALL THE GRAPHICS","DESIGN OF THIS DEMO,"," AND FOR THIS TEXT. "
 DC.B "DR PSY HAVE MAKE THE","LANDPICTURE IN ABOUT","FOUR HOURS ( YES ) ,"
 DC.B "  THE LANDFONTS IN  ","ABOUT TWO HOURS, AND","DR KHEBLO  HAVE MAKE"
 DC.B "THE KRISTAL-FONT ..."," THE MUSIC HAD BEEN ","COMPOSED BY...  FIND"
 DC.B "  YOURSELF WHO HAD  "," COMPOSED IT , I AM "," SUR YOU HAVE STILL "
 DC.B "HEARD THIS MUSIC !!!","  YOU CAN SEE: TWO  ","DIFFERENTS SCROLLING"
 DC.B "A KRISTAL-SCROLLTEXT"," WITH OUR GREETINGS "," AND THE MEMBERS OF "
 DC.B " THE GREAT ALLIANCE ","( A NEW FRENCH GROUP"," WHO MAKE  A LOT OF "
 DC.B " NICE DEMOS ) . THE ","OTHER SCROLL-TEXT IS"," THE PRINCIPAL  ONE "
 DC.B "  AND YOU CAN READ  "," THIS MESSAGE. THIS ","  PRINCIPAL SCROLL  "
 DC.B "    IS NOT VERY     ","  CONVENTIONAL ...  "," THE KRISTAL-SCROLL "
 DC.B "TOO... IN FACT , THE"," OVERLANDERS IS THE ","FIRST GROUP WHO HAVE"
 DC.B "FOUND HOW  TO MAKE A","KRISTAL-SCROLLING..."," OUR OLD PROGRAMMER "
 DC.B "DEATH-BIRD HAD CODED"," THE FIRST  KRISTAL "," SCROLL BEFORE JULY "
 DC.B "1988 !!! AND, A WEEK","AFTER , HE HAS CODED"," THE DOUBLE KRISTAL "
 DC.B "SCROLL !!! THANKS TO","THE PROGRAMM'S MAKER"," OF MYRIADS FOR THE "
 DC.B "  KNOW-HOW OF THIS  ","SCROLL-TEXT !!!! YES","  WE ARE THE FIRST  "
 DC.B "KRISTAL-SCROLL-MAKER","BEFORE THE VERY BEST","GROUP : THE UNION !!"
 DC.B "AND YOU CAN SEE THIS"," KRISTAL-SCROLL OUT "," OF THE SCREEN , IN "
 DC.B " THE LOW  BORDER OF ","YOUR SUPER  COMPUTER","  THE ATARI ST ...  "
 DC.B "                    "," HEM ! HEM ! THAT'S "," ALL FOR TODAY, BUT "
 DC.B " DO NOT FORGET THAT ","YOU CAN FOUND OTHERS","GOOD SCREENS DEMOS ,"
 DC.B "WITH MORE COULOURS ,","MORE GRAPHICS , ETC."," IT IS THE END , SO "
 DC.B "  PRESS  SPACE FOR  ","     ESCAPE ...     ","THE ALIEN TEAM 1989."
 DC.B "                    ","OK, LET'S START ANEW","                    "
 DC.B "                    ",-1
txt_32:


 DC.B "                                           YYYYY    EEEEEEAAAAAAAHHHHHH !!!! THE OVERLANDERS STRIKE BACK WITH"
 DC.B " ANOTHER GREAT DEMO SCREEN..."
 DC.B "        THE - A L L I A N C E - IS A NEW FRENCH CREW WHO WANTS TO MAKE"
 DC.B " THE BEST DEMOS ON ST LIKE THE UNION.  AND TO PROOVE THAT WE ARE"
 DC.B " THE BEST FRENCH PROGRAMMER,WE HAVE MADE THE --- DELIRIOUS DEMO --"
 DC.B "- !"
 DC.B "         MEMBERS OF THE ALLIANCE ARE : THE OVERLANDERS (ALIEN TEAM,MEGA"
 DC.B " FORCE INTERNATIONAL,GENESIS SYSTEM,THE BIT MASTERS,THE STARKS...)"
 DC.B "      MCS  ( AXEL FOLLET,SHARK,GADGET,MADROM )      MEGABUGS  ( ARCHIE AND CO )"
 DC.B "      AVALANCHE  ( SNOWMAN,LE YETI,GRIZZLY )      BLACK PANTHERES  ( !!! )"
 DC.B "      THE CLONE ( HI,GUYS... )      PENTHAGORE  ( WELL,WELL ... )"
 DC.B "         OUR SUPER GREETINGS ARE SENT TO: ALL MEMBERS OF THE UNION ( ESPECIALLY TO THE CAREBEARS, OK GUYS"
 DC.B " BIG THANKS TO YOU FOR THE FRIENDSHIP AND I LOVE YOUR ' CUDDLY DEMO ',WELL THEY ARE THE BEST, GOOD WORK AN COOL )"
 DC.B "     PHALANX  ( GHOST AND VECTOR )       EQUINOX  ( HI,KRUEGER ... AND, EH ILLEGALL,WHERE'S THE SOUDTRACHER !!! )"
 DC.B "      FLYING EGGS  ( HELLO,MEN ... PLEASE CONTACT US ! )      STARLIGHT      FIRE CRACKERS      V8      DANEEL"
 DC.B "      THE LOST BOYS      AUTOMATION      POSITIVE X       ....."
 DC.B "          THE NORMAL GREETINGS GO TO: WAS (NOT WAS) , FLEXIBLE FRONT ,"
 DC.B "F.O.G , TNT , ATOR , BIRDY , BLUE ADEPT , ALYSSA , BOSS , THE"
 DC.B " BARBARIANS , THE HOBBIT BROTHERS , TSUNOO AND ALL THE OTHER HAPPY"
 DC.B " FREAKS WE KNOW !"
 DC.B "            HI TO YOU,FANS OF FRENCH PIRATE TEAMS,HERE ARE THE"
 DC.B " OVERLANDERS,COMING BACK STRONGER,WITH THEIR IDEAS,THEIR CONTACTS,"
 DC.B " THEIR SWAPPERS AND HACKERS....YES,WE STRIKE BACK AND WE PRESENT"
 DC.B " YOU OUR NEW MEGA-DEMO,CODED BY:  EPSILON  .... THE GRAPHIXX WAS"
 DC.B " DESIGNED 'DE MAIN DE MAITRE' BY:  DR.PSY  AND THE SCROLLING WAS"
 DC.B " WRITTEN BY :  SKY METAL  (TRANSLATION AND ADAPTATION BY:  JABBA)"

 DC.B "         NOW,WE WILL PRESENT YOU ALL THE MEMBERS OF THIS FABULOUS"
 DC.B " INTERGALACTIC TEAM WHO ARE:          ALIEN TEAM (EPSILON,DR PSY,DR KEBLO,XST,PHENEEX,BLACK FOG)"
 DC.B "        THE MEGA FORCE INTERNATIONAL (SKY METAL,JABBA,PEEWEE,CHRONOS,ZIGGY STARDUST,THE MASTER,WHITE SPIRIT"
 DC.B "FURYO,EVINRUDE,DROOPY,NOODLEF,THE CONQUEROR,TEX AVERY,LIVINGSTONE,MAG FLY,TEDDY BOY AND KEOPS )"
 DC.B "        THE GENESIS SYSTEM (JOY KILLER,MANDRAKE,XRAY,TYPHON,SPEEDLIGHT )"
 DC.B "        THE BIT MASTERS (JOJO,LULU,DUCH,YOYO,PHIPHI,MANNIX )"
 DC.B "        THE STARKS (MAD STALKER,DAVE LOST,DR SATAN,PHILL STRAITS,FISHERMAN )"
 DC.B "         HERE IT IS ! THEY ALL BELONG TO THIS BELOVED MEGA CREW: ' THE"
 DC.B " OVERLANDERS ' ... WHO THEMSELVES BELONG TO ' THE ALLIANCE '."
 DC.B "         ' THE ALLIANCE ' WANTS TO PROOVE THAT THE FRENCH PROGRAMMERS ARE"
 DC.B " NOT SO LAME."
 DC.B "  WE HAVE THE PRETENTIOUSNESS TO BECOME ONE OF THE FIRST GROUP IN"
 DC.B " THE WORLD IN ORDER TO PROOVE THAT THERE IS NOT ONLY ' THE UNION '"
 DC.B " WHICH EXISTS..."
 DC.B "  SO,I WOULD LIKE TO TALK ABOUT EACH IMPORTANT MEMBERS OF ' THE"
 DC.B " OVERLANDERS ' SO THAT YOU COULD BETTER KNOW THESE PEOPLE WHO"
 DC.B " ENJOY SO MUCH SIMPLIFYING YOUR LIFE (NOTE FROM TRANSLATOR:THIS"
 DC.B " WAS A QUITE HARD SENTENCE TO TRANSLATE !)"
 DC.B "           SO,IT'S BETTER TO PRESENT THEM MORE PERSONALLY AND - WARNING ! -"
 DC.B " YOU ARE GOING TO KNOW EVERYTHING ................. SO,LET'S GO !"
 DC.B "          ALIEN TEAM  ( EPSILON ,THE SUPER PROGRAMMER,HIS HEAD IS FULL"
 DC.B " OF IDEAS AND HE LOVES THE PRETTY GIRLS WHO DON'T STOP TURNING"
 DC.B " AROUND HIM ALL THE DAY...BUT IT'S NOT THE REASON WHY EVINRUDE"
 DC.B " SHOULD LET YOU TURN AROUND HER,LITTLE BANDIT !        HE IS THE"
 DC.B " COOLER PROGRAMMER AND HE IS TALENTED WHICH IS SOMETHING VERY RARE"
 DC.B " FOR A PROGRAMMER (NFT:???)        SO,AFTER A FEW FUNNY MOMENTS,HE"
 DC.B " STARTED AGAIN WORKING... - DR PSY - ..."
 DC.B " - DR KHEBLO - ..."
 DC.B " - XST - ..."
 DC.B " - PHENEEX - ..."
 DC.B " - BLACK FOG - ..."
 DC.B "       AND ALL THE OTHER THAT I DON'T KNOW"
 DC.B " BECAUSE IT IS A PREVIEW ..........."


 DC.B "          THE MEGA FORCE INTERNATIONAL  ( SKY METAL ,HAHA,IT'S ME,"
 DC.B " FAITHFULL TO THIS MARVELLOUS GROUP THAT IS ' OVERS '."
 DC.B "  WE STARTED AGAIN,FULL OF POWER,WITH NEW PROGRAMMERS,DESIGNERS AND"
 DC.B " SWAPPERS AND I HOPE YOU WILL BE HAPPY TO SEE US AGAIN WITH LOT OF"
 DC.B " PROJECTS.THERE ARE ONLY GOOD THINGS WAITING FOR YOU FOR THE"
 DC.B " COMING MONTHS.AND I PROMISE YOU SOME INTERGALACTIC EXCLUSIVNESS"
 DC.B " FOR SOON."
 DC.B "  SORRY,I DIDN'T REALLY PRESENT MYSELF 'CAUSE OF THE APP.I DON'T"
 DC.B " WANT TO UNVEIL MY 'DARK SIDE' NOR TO SAY ANYMORE ABOUT MY HUMBLE"
 DC.B " PERSON.BUT YOU HAVE TO KNOW ANYWAY THAT IF I DIDN'T EXIST,SOMEONE"
 DC.B " SHOULD INVENT ME (LAUGHS !!!)."
 DC.B "  I HAVE SOMETHING TO SAY : STAY WITH US AND MAY THE FORCE BE WITH"
 DC.B "  (I THINK I HAVE ALREADY HEARD THAT SOMEWHERE...)."
 DC.B "  SO,'AMIS D'UN JOUR,BONJOUR ET AMIS D'UN SOIR BONSOIR' ........."
 DC.B " GLOK ! ."
 DC.B "      JABBA (NFT:IT'S ME !) - OH YOU,THE GFA CHAMPION,I PREDICT"
 DC.B " YOU A GREAT SUCCESS NEXT TO OUR CONTACTS IF YOU SPREAD YOUR"
 DC.B " SUPERB DEMO (NFT:IT'S HIM,NOT ME,WHO SAYS THAT !)...WHAT ? I"
 DC.B " CAN'T HEAR YOU VERY WELL...YOU...YOU MADE A DEMO ESPECIALLY FOR '"
 DC.B " THE ALLIANCE ' ? YEAH,I KNOW AND IT IS OF GENIUS ! (EH,YOU,YOU"
 DC.B " HAVE TO KNOW THAT THERE WILL BE MANY VOLUMES OF THE DELIRIOUS AND"
 DC.B " IN PARTICULAR A BASIC SECTION)... JABBA,YOU FAN OF DUNGEON"
 DC.B " MASTER,YOU WILL SOON ENJOY PLAYING 'CHAOS STRIKES BACK',SEQUEL OF"
 DC.B " THE FANTASTIC DUNGEON MASTER...AND IN TWO YEARS,YOU WILL"
 DC.B " CERTAINLY HAVE FUN WITH DUNGEON MASTER 3 ON THE FUTURE ST PLUS !"
 DC.B "  AH,I FORGOT...I'M VERY PLEASED THAT YOU FINALLY BOUGHT A MEMORY"
 DC.B " EXTENSION FOR YOUR 520 (NFT:SO AM I !)"
 DC.B "        PEEWEE - AHHHH ! AT LAST,A NEW PROGRAMMER,THAT'S COOL,NOOO ?"
 DC.B " HE IS TALENTED AND HE MANAGES QUITE WELL...IN ANY CASE,HIS DEMOS"
 DC.B " ARE VERY FINE AND EVEN OF GENIUS.A FUTURE GREAT MAN,I CAN ASSURE"
 DC.B " YOU ! AND I'M WAITING FOR YOUR NEXT FEATS,DEAR PROGRAMMER ...."
 DC.B "        CHRONOS - YOU ARE THE BEST CRACKER IN ALL THE EUROPE,AND I LOVE YOUR CRACKING ...."
 DC.B "  HELLO,BELOVED CRACKER.DO YOU REMEMBER 'BAAL' 520"
 DC.B " ST,THE FIRST SOFT YOU CRACKED FOR US ? 'DAUBE BIEN FORT',YEAHHH !"
 DC.B "        ZIGGY STARDUST ... "
 DC.B "        THE MASTER - IT IS THE ONE OF THE FIRST MEMBERS OF THE MEGA"
 DC.B " FORCE BECAUSE HE IS MY SECOND.HE IS,LIKE MOST OF THE MEMBERS,VERY"
 DC.B " COOL AND NICE.HE IS THE CHAMPION OF ADVENTURE GAMES (LIKE CHRONO"
 DC.B " QUEST (EXPLORA) 1 AND 2 AND HIS GOAL IS TO FINISH THE GAMES"
 DC.B " QUICKLY TO ALLOW THE OTHERS TO TAKE ADVANTAGE OF IT.SWAPPER,HE"
 DC.B " IS...HE PROVIDES THE DIFFUSION IN OUR REGION....YOU WOULD BE MAD"
 DC.B " NOT TO LIKE HIM,BECAUSE HE'S REALLY SUPER."
 DC.B "        WHITE SPIRIT - BETWEEN BLACK AND WHITE,HE WALKS.HE IS THE"
 DC.B " KING OF THE PRIMARY COLOURS AND HE HANDLES THE MOUSE AS WELL AS"
 DC.B " THE PENCIL.I HOPE HE WILL SOON PUSH OUT A NEW MASTERPIECE,BECAUSE"
 DC.B " IT'S LONG,VERY LONG TO MAKE A PICTURE."
 DC.B "                                        BUT ' IT'S BETTER TO WAIT THAN TO RUN ' (SILLY THOUGHT !) "
 DC.B "        FURYO - HE,HE,YOU DID ENJOY THE FILM,IN THE DARK CINEMA"
 DC.B " ROOMS,OF COURSE...HUH ? WHAT ? YOU KNOW ME ? PFUUUT ! BUT"
 DC.B " EVERYONE KNOWS ME 'CAUSE I AM THE FAMOUS SKY METAL.NO,NO,I AM NOT"
 DC.B " PRETENTIOUS,ONLY REALISTIC. YOU ARE ONE OF THE LAST WHO ENTERED"
 DC.B " THIS FABULOUS ORGANISATION THAT IS THE OVERLANDERS AND YOU KNOW"
 DC.B " THAT THE OVERLANDERS ARE VERY STRONG IN EUROPE..."

 DC.B "        EVINRUDE - PRETTY,VERY PRETTY,VERY VERY PRETTY.IN ONE"
 DC.B " WORD,SHE IS ACTUALLY MARVELLOUS AND (IT'S VERY RARE) SHE HAS GOT"
 DC.B " AN ATARI ST.OH,NOT FOR PROGRAMMING (ALTHOUGH...) BUT RATHER TO"
 DC.B " PLAY ' PUFFY'S SAGA ' A STUPID GAME SHE LOVES MORE THAN"
 DC.B " EVERYTHING ELSE IN THE WORLD (NFT:EXCEPT ME,OF COURSE !).AND THE"
 DC.B " FIRST WHO DARES SAYING THE OPPOSITE WILL BE HUNTED DOWN BY HER"
 DC.B " (INVERTED) DOUBLE,A FOUL WITCH WITH A DISGUSTING BODY,STICKY"
 DC.B " HANDS AND A FROGHEAD ! SO,IT'S PREFERABLE TO BE HER FRIEND"
 DC.B " (NFT:OR BETTER,HER BOYFRIEND,SIGH) OR ONE WOULD RISK TO BE"
 DC.B " TRANSFORMED INTO A BIG SLOBBERING PIG..."
 DC.B "        DROOPY - OH,OH,A SWAPPER IN THE FRENCH ARMY,'WHAT IS THE"
 DC.B " RESULT ?',YOU WILL ASK ME...WELL,NOTHING AT ALL ! BUT HE IS ONE"
 DC.B " OF THE BEST IN FRANCE AND YOU CAN SEE THAT HARDWORKING IS"
 DC.B " SUCCESSFUL !!!."


 DC.B "        NOODLEF - TALENTED DRAWER,I WILL SAY THAT IT'S THE BEST OF"
 DC.B " ALL THE GRAPHISTS WHO MAKE ULTRA-DELIRIOUS CHARACTERS.AND YOU"
 DC.B " WILL SEE WHAT HE PREPARES... I CONGRATULATE YOU FOR YOUR HARD AND"
 DC.B " SUPERB WORK...I AM EAGERLY WAITING FOR ALL YOUR NEW PICTURES AND"
 DC.B " I SLOBBER IN ADVANCE (NFT:BAAAHHHH !)."
 DC.B "         THE CONQUEROR - THE KING OF THE NEWS.I ADMIT THAT HE"
 DC.B " SOMETIMES SURPRISES ME (LIKE FOR 'THE QUEST FOR TIME BIRD' (LA"
 DC.B " QUETE DE L'OISEAU DU TEMPS),IF YOU SEE WHAT I MEAN...).DON'T"
 DC.B " WORRY,'ON LES AURA,VINDIOU DE VINDIOU'."
 DC.B "        TEX AVERY - HE'S A FRIEND OF WHITE SPIRIT'S.HE IS"
 DC.B " SWAPPER,TOO AND LIKE ALL THE OTHERS,HE IS VERY COOL."
 DC.B "        LIVINGSTONE ..."
 DC.B "        MAG FLY ..."
 DC.B "        TEDDY BOY ..."
 DC.B "        KEOPS .... -  WHAT DO YOU DO ? WHERE ARE YOU ? AH,FRIEND OF PEEWEE"
 DC.B " ! OK !. )"

                    
          
         
 DC.B "          THE GENESIS SYSTEM  (JOY KILLER - HI TO YOU,THE NICEST"
 DC.B " SWAPPER IN THE WORLD,WE THANK YOU FOR YOUR DYNAMISM IN THE CREW."
 DC.B " WE HOPE THAT IT WILL LAST LONG AND THAT OUR DIFFUSION WILL BE"
 DC.B " ENLARGED THANKS TO OUR KNOWLEDGE IN THE WORLD.AND WE HOPE THAT"
 DC.B " THE SPEED WILL REMAIN AS GOOD AS TODAY ! HURRAH FOR THE"
 DC.B " OVERLANDERS !!!."
 DC.B "      MANDRAKE - YES,YOU ARE A SUPER COOL GUY (AGAIN !) AND YOU"
 DC.B " CAN SEE THAT 'THE ALLIANCE' MADE,AT LAST,THIS HYPER-SUPER-MEGA"
 DC.B " DEMO.AH,IT'S OF GENIUS !."
 DC.B "      X-RAY - HOW DO YOU DO,MACHINE HANDYMAN ? WHAT ? YOU BURNT"
 DC.B " OUT YOUR ST AGAIN ?  STOP FIXING UP EVERYTHING BECAUSE YOUR HOUSE"
 DC.B " COULD CATCH FIRE !      SO,YOU CAN SEE THAT YOU ARE IN OUR"
 DC.B " SCROLLS ! DO I DREAM ? YOU BEGAN THE ASSEMBLER !?."
 DC.B "      TYPHON - ARE YOU ALLRIGHT NOW ? NO ? SO TAKE TWO ASPIRINS"
 DC.B " AND SOME STOCK AT EVERY LUNCH AND YOU WILL SEE,EVERYTHING WILL BE"
 DC.B " NICE ! AND YOU WON'T SAY THAT I DON'T NAME YOU IN OUR MEGA-"
 DC.B " SCROLLINGS."
 DC.B "      SPEED LIGHT - WAAOOOOOOWWWW ! YOUR FONTS ARE MARVELLOUS..."
 DC.B " (NFT:THERE WAS A KIND OF SEXUAL ALLUSION AFTER THIS PASSAGE BUT"
 DC.B " I DIDN'T TRANSCRIBE IT BECAUSE THIS DEMO IS FOR ALL PUBLIC !)"
 DC.B " THE OVERLANDERS ARE EAGERLY WAITING FOR YOUR NICEST CHARACTERSETS"
 DC.B " ...'A TCHAO,BONSOIR !' . )"

 DC.B "          THE BIT MASTERS ( JOJO ...."
 DC.B "      LULU ...."
 DC.B "      DUCH ...."
 DC.B "      YOYO ...."
 DC.B "      PHIPHI..."
 DC.B "      MANNIX .."
 DC.B "          THE STARKS ( MAD STALKER ..."
 DC.B "      DAVE LOST ...."
 DC.B "      DR SATAN ..."
 DC.B "      PHILL STRAITS ..."

 DC.B "      FISHERMAN - HELLO 'UNE FOIS' (AND 'DEUX FOIS' FOR PLEASURE'S"
 DC.B " SAKE).DO THE BELGIANS LIKE THE 'FRITES' (FRENCH FRIED POTATOES) ?"
 DC.B " YES,SWAPPER IN BELGIUM AND HE PROVIDES US A VERY GOOD POSITION IN"
 DC.B " THIS LAND . )"

 DC.B "                    HERE IT IS.THE WHOLE CREW WAS PRESENTED AND DETAILED SO THAT YOU"
 DC.B " COULD KNOW WHO MAKES WHAT.          THE DIFFUSION OF THIS MEGA-"
 DC.B " SUPER-HYPER DEMO WILL BE...GREAT ('CA VA FAIRE TRES,TRES,MAL !')"
 DC.B " YOU WILL ALL RECITE THAT THE OVERLANDERS ARE INTERGALACTIC...AND"
 DC.B " BEWARE TO THE ONE WHO WOULD SAY THE OPPOSITE BECAUSE OUR REVENGE"
 DC.B " WOULD BE TERRIBLE !        THE OVERLANDERS ARE A CREW WHO WILL"
 DC.B " WITHOUT FURTHER DELAY BELONG TO THE ELITE.AND I CAN ASSURE YOU"
 DC.B " THAT WE REALLY CAN DO THAT EVEN IF SOME OTHER TEAMS ARE AGAINST"
 DC.B " US AND SAY THAT WE ARE NOT SERIOUS (NFT:'DES RIGOLOS',IN FRENCH)"
 DC.B " BUT DON'T WORRY,WE DON'T CARE A FIG ABOUT THOSE MALICIOUS GOSSIPS"
 DC.B " AND WE ARE REALLY READY TO PLEASE YOU.I AM SURE THAT ALL THE"
 DC.B " PEOPLE WHO HAVE FALSE IDEAS ABOUT US WILL QUICKLY MAKE UP THEIR"
 DC.B " MINDS AND STOP TELLING OBSCENE STUFF ABOUT OUR MEGA CREW."
 DC.B "  IN FACT,IF THESE GROUPS TRY TO SHOOT US DOWN,IT'S BECAUSE THEY"
 DC.B " FEAR THE COMPETITION.BUT I DON'T THINK THAT A WAR BETWEEN OUR"
 DC.B " GROUPS WOULD BE A GOOD THING,BECAUSE THE APP IS JUST WAITING FOR"
 DC.B " IT.AND I HOPE THAT EVERYONE WILL BE DIPLOMATIC ENOUGH TO STAY IN"
 DC.B " ONE'S SIDE AND TO TRY NOT TO FINISH OFF COMPETITORS.WELL,I STOP"
 DC.B " THIS BORING SUBJECT OR I WILL BECOME ANGRY..."
 DC.B "    I THINK (NFT:SKY METAL IS QUITE A 'THINKING MAN',HE !) THAT"
 DC.B " THE COURAGEOUS PEOPLE WHO REACHED THIS PASSAGE WOULD LIKE TO GET"
 DC.B " SOMETHING SPECIAL THAT THE OTHERS WHO DIDN'T READ ALL THIS SCROLL"
 DC.B " COULDN'T GET. SO,I AM AT LAAAAAST GOING TO SPEAK ABOUT MYSELF."
 DC.B " MANY PEOPLE ENVY ME BECAUSE I AM THE NERVOUS CENTER OF THIS CREW,"
 DC.B " THE CO-ORDINATOR OF ALL THE 'SMALL' GROUPS.I HAVE TO GUARANTEE"
 DC.B " PERFECT RELATIONSHIP IN THE GROUP AND I THINK THAT ALL THOSE WHO"
 DC.B " KNOW ME WON'T CONTRADICT ME WHEN I SAY THAT I AM INCREDIBLY BUSY"
 DC.B " WITH THE NEWSPAPER (YES,THE OVERLANDERS HAVE THEIR OWN NEWSPAPER),"
 DC.B " THE CRACKING,THE DIFFUSION NEXT TO OUR BIGGEST CONTACTS AND THE 3"
 DC.B " MEGA DEMOS RESPECTIVELY NAMED THE DELIRIOUS DEMO 1,2,3 (HA,HA !)."
 DC.B "  I HAVE NO MORE TIME TO SLEEP AND I KNOW SOMEONE WHO DON'T"
 DC.B " APPRECIATE IT VERY MUCH,YOU KNOW...MY DEAR DELPHINE,I CAN ASSURE"
 DC.B " YOU THAT I WILL SPEND MY NEXT WEEK-END WITH YOU AND I WILL BE"
 DC.B " YOUR SERVANT FOR THE NEXT 48 HOURS...SO,THESE ARE THINGS ABOUT MY"
 DC.B " PRIVATE STORMY LIFE,FULL OF TWISTS AND TURNS AND ALL WHAT YOU CAN"
 DC.B "  IMAGINE...          WARNING ! I WILL NOW GIVE YOU THE MARVELLOUS"
 DC.B " ADDRESS WHERE YOU WILL BE ABLE TO WRITE TO US OR TO GIVE US A"
 DC.B " GIFT (FROM THE MODEST SUM OF 10 FF TO THE MARVELLOUS AMOUNT OF"
 DC.B " 200 FF).INDEED,THIS DEMO IS FREEWARE AND SHAREWARE AND ALL THE"
 DC.B " PEOPLE WHO LIKE THIS TECHNICAL FEAT WILL BE ABLE TO SHOW US THEIR"
 DC.B " ADMIRATION.IT WOULD BE GRATITUDE FOR OUR HARDWORK FOR SIX MONTHS"
 DC.B " TO MAKE THIS FANTASTIC  ' DELIRIOUS DEMO ' FROM ' THE ALLIANCE '"
 DC.B " (NFT:IN FACT,THE HARDWORK WAS TO TRANSLATE THIS SCROLLTEXT !)."
 DC.B "  WE THANK YOU FOR YOUR MONETARY CONTRIBUTION.           HERE IS"
 DC.B " THE ADDRESS OF ' THE ALLIANCE ' : THE ALLIANCE  ( EH, CRACKERS IT'S FOR YOU :"
 DC.B " CRACK THIS DEMO AND I GIVE YOU THE ADRESS OF ' THE ALLIANCE ' ...SEE YOU SOON !             SO,I SAID ENOUGH"
 DC.B " WORDS FOR TODAY BECAUSE MY 'COMPUT' IS ON SINCE THIS MORNING (4"
 DC.B " O'CLOCK) AND IT'S NOW 13.DO YOU SEE THE TIME I TOOK TO WRITE THIS"
 DC.B " SCROLL ? HUH,JABBA ? (NFT:YES ? WHAT ?)...SO,BEFORE STOPPING,I"
 DC.B " WOULD LIKE TO THANKS THE MANY GINI BOTTLES I DRUNK WITH AN"
 DC.B " INCREDIBLE FERVOUR AND THE FOLKIES CHOCOLATE BARS WHICH HELPED ME"
 DC.B " TO SPEND THIS FABULOUS MOMENT WITH YOU.AND DON'T FORGET THAT YOU"
 DC.B " WILL READ A DIFFERENT SCROLLING IN EACH DEMO...SO,WE BEAT THE"
 DC.B " BIG,THE AMIGA AND THE UNION DEMO,ALL GATHERED,ONLY WITH OUR"
 DC.B " DELIRIOUS DEMO.ISN'T IT COOL ? THE FRENCH ARE REALLY STRONG,"
 DC.B " AREN'T THEY ?.................."
 DC.B " .............TEXTE A CONTINUER.................................."
 DC.B "     PREVIEW     JULY 1989 ... AU 12 SEPTEMBRE 1989 .....                                            "
 DC.B -1
 END
 