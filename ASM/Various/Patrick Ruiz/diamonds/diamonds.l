; DIAMONDS
; Version 1.07
; D�mo style "Jeu de la Vie" en basse r�solution.
; Charge une image ou remplit al�atoirement l'�cran
; puis affiche les g�n�rations.
; "Delete": Recommencer.
; "Esc"   : Fin du programme.

 ILABEL GEM.BIB
 GEM_APP

 SCRN_GRES
 tst D0
 bne FIN
 SCRN_GPBASE
 move.l D0,ECR_N
 PROG_SUPER #GETPALETTE
 bsr MSE_OFF
 SCRN_TEXT #AIDE,0,0
 SCRN_TEXT #AIDE2,0,0
 CONS_IN #2
choix_f: lea CHEMIN(PC),A3
 lea FICHIER(PC),A4
 clr.b (A4)
 bsr MSE_ON
 FILE_SELECT A3,A4,CHOIX
 bsr MSE_OFF
 bsr CLS
 tst CHOIX
 beq \1
 ;chargement
 bsr NOUV_CHEMIN
 tst D3
 bne \err
 FILE_OPEN #FICHIER,#0
 move D0,D3
 bmi \err
 move.l #32128,D4
 FILE_READ D3,D4,#IMG
 cmp.l D4,D0
 seq DEG_NEO
 beq \2
 cmpi.l #32034,D0
 beq \2
 cmpi.l #32066,D0
 beq \2
\err clr CHOIX
 bra \1
\2 FILE_CLOSE D3
\1 lea palette(PC),A3
 tst CHOIX
 beq \3
 lea IMG+2(PC),A3
 tst.b DEG_NEO
 beq \3
 addq #2,A3
\3 SCRN_SPALETTE A3

 sf N_M
 ;initialiser ECR_M
 lea ECR_M+4+256,A0
 move.l A0,D0
 andi.l #$3FFF00,D0
 move.l D0,ECR_M

 ;init TAB_N
 tst CHOIX
 bne IMAGE

HAZARD: lea TAB_N+322+1,A3
 move #320/2-1,D3 ;col.
 move #200-1,D4 ;lign.
 move #$0F0F,D5 ;masque
\1 move #17,-(SP)
 trap #14
 addq #2,SP
 lsr.l #7,D0 ;allons savoir
 and D5,D0
 move D0,(A3)+
 dbra D3,\1
 move #320/2-1,D3
 addq #2,A3
 dbra D4,\1
 bra pres

IMAGE: ;IMG+34ou128 ---> TAB_N
 lea IMG+34(PC),A0  ;A0=srce
 tst.b DEG_NEO
 beq \1
 lea IMG+128(PC),A0
\1 lea TAB_N+322+1,A1 ;A1=dest
 moveq #16-1,D0     ;D0=pix.
 move #320/16-1,D1  ;D1=col. de 16 pixels
 move #200-1,D2     ;D2=lign.
\nsp move (A0)+,D3  ;D3=CR0
 move (A0)+,D4      ;D4=CR1
 move (A0)+,D5      ;D5=CR2
 move (A0)+,D6      ;D6=CR3
\2 clr.b D7           ;D7=pixel
 lsl #1,D6
 roxl.b #1,D7
 lsl #1,D5
 roxl.b #1,D7
 lsl #1,D4
 roxl.b #1,D7
 lsl #1,D3
 roxl.b #1,D7
 move.b D7,(A1)+
 dbra D0,\2
 moveq #16-1,D0
 dbra D1,\nsp
 move #320/16-1,D1
 addq #2,A1
 dbra D2,\nsp

pres: bsr SPHERE
 bsr VOIR
 CONS_IN #2

DIAMONDS:
 lea TAB_M,A0
 lea TAB_N,A1
 tst.b N_M
 beq \1
 lea TAB_N,A0
 lea TAB_M,A1
\1              ;A0=TAB srce
                ;A1=TAB dest
 movea.l A0,A2
 adda #322+1,A2 ;A2=ptr srce
 movea.l A1,A3
 adda #322+1,A3 ;A3=ptr dest
 move #320-1,D0 ;D0=col.
 move #200-1,D1 ;D1=lign.
 moveq #-  1,D2 ;D2=offset G
 moveq #   1,D3 ;D3=offset D
 movea # 322,A4 ;A4=offset H
 movea #-322,A5 ;A5=offset B
\np move.b (A2)+,D4 ;D4=coul pixel
 move.b D4,D5   ;D5=coul nouv pixel
 moveq #$F,D6   ;D6=masque mod16
 addq #1,D5
 and.b D6,D5
 cmp.b -1(A2,D2),D5
 beq \sq ;saut quantique!
 cmp.b -1(A2,D3),D5
 beq \sq
 cmp.b -1(A2,A4),D5
 beq \sq
 cmp.b -1(A2,A5),D5
 beq \sq
 move.b D4,D5 ;rien de neuf
\sq move.b D5,(A3)+
 dbra D0,\np
 addq #2,A2
 addq #2,A3
 move #320-1,D0
 dbra D1,\np

 bsr SPHERE
 bsr VOIR

attente: CONS_GINSTATE #2
 tst D0
 beq DIAMONDS
 CONS_IN #2
 cmpi.b #27,D0
 seq D3
 beq EPILOGUE
 cmpi.b #127,D0
 beq EPILOGUE
 bra attente

EPILOGUE:
 bsr CLS
 SCRN_SET #-1,ECR_N,#-1
 SCRN_SPALETTE #palette_orig
 tst.b D3
 beq choix_f
 bsr MSE_ON
 bra FIN

SPHERE: ; report sph�rique
 lea TAB_N,A0
 tst.b N_M
 beq \1
 lea TAB_M,A0
\1 ;A0=TAB
 ;lign. -1 et 200
 lea 1(A0),A1
 move.l #200*322,D0
 move #320-1,D1
\L_1 move.b (A1,D0.L),(A1)+
 dbra D1,\L_1
 movea.l A0,A1
 adda.l #201*322+1,A1
 move #320-1,D1
 neg.l D0
\L200 move.b (A1,D0.L),(A1)+
 dbra D1,\L200
 ;col. -1 et 320
 lea 322(A0),A1
 move #200-1,D1
\C_1 move.b 320(A1),(A1)
 adda #322,A1
 dbra D1,\C_1
 lea 322+320+1(A0),A1
 move #200-1,D1
\C320 move.b -320(A1),(A1)
 adda #322,A1
 dbra D1,\C320
 rts

VOIR: ;TAB ---> ECR
 lea TAB_N,A0
 movea.l ECR_N,A1
 tst.b N_M
 beq \1
 lea TAB_M,A0
 movea.l ECR_M,A1
\1 adda #322+1,A0 ;A0=srce
                  ;A1=dest
 movea.l A1,A3    ;A3=svg
 move #320/2-1,D0 ;D0=col. /2 car on traite 2 pixels � la fois
 move #200-1,D1   ;D1=lign.
 moveq #1,D5      ;D2/D3/D4/D5=plans avec D5 indic. d�bordement
\nsp move.b (A0)+,D6  ;D6=coul 1er pixel
 move.b (A0)+,D7  ;D7=coul 2�me pixel
 lsr.b #1,D6
 roxl #1,D2
 lsr.b #1,D6
 roxl #1,D3
 lsr.b #1,D6
 roxl #1,D4
 lsr.b #1,D6
 roxl #1,D5
 lsr.b #1,D7
 roxl #1,D2
 lsr.b #1,D7
 roxl #1,D3
 lsr.b #1,D7
 roxl #1,D4
 lsr.b #1,D7
 roxl #1,D5
 dbcs D0,\nsp
 move D2,(A1)+ ;vidage
 move D3,(A1)+
 move D4,(A1)+
 move D5,(A1)+
 moveq #1,D5
 dbra D0,\nsp
 addq #2,A0
 move #320/2-1,D0
 dbra D1,\nsp

 SCRN_SET #-1,A3,#-1
 not.b N_M
 CONS_OUT #2,#7 ;BELl
 rts

GETPALETTE: lea $FFFF8240,A0
 lea palette_orig(PC),A1
 moveq #15,D0
\1 move (A0)+,(A1)+
 dbra D0,\1
 rts

MSE_ON: GRAF_MOUSE #257,A0
 rts

MSE_OFF: GRAF_MOUSE #256,A0
 rts

CLS: CONS_OUT #2,#27
 CONS_OUT #2,#'E'
 rts

NOUV_CHEMIN: ;tenir compte du disque et du chemin
 ;E:A3=chemin  S:D3=erreur
 cmpi.b #'A',(A3)
 blo \1
 cmpi.b #'P',(A3)
 bhi \1
 clr D0
 move.b (A3),D0
 subi #'A',D0
 DISK_SET D0
 tst D0
 bmi \err
\1 ;chercher '\'
 movea.l A3,A0
 movea.l A0,A1 ;dernier'\'
 moveq #'\',D0
\3 moveq #12,D1
\4 cmp.b (A0)+,D0
 bne \2
 lea -1(A0),A1
 bra \3
\2 tst.b (A0)
 dbeq D1,\4
 lea PAD(PC),A2
 move.l A1,(A2)+
 move.b 1(A1),(A2)+
 clr.b 1(A1)
 DISK_SDIR A3
 lea PAD(PC),A2
 movea.l (A2)+,A0
 move.b (A2)+,1(A0)
 tst D0
 bmi \err
 clr D3
\f rts

\err neg D3
 bra \f

 _D
AIDE: DC.B 27,"H",10,10,10
 DC.B "          Charge une image ou    ",13,10
 DC.B "[Annuler]:Remplissage al�atoire. ",13,10,10
 DC.B " [Touche]:D�but.                 ",13,10,0
AIDE2 DC.B " [Delete]:Recommencer.           ",13,10
 DC.B "    [Esc]:Fin du programme.      ",0

CHEMIN: DC.B ".\*.PI1",0
 DS.B 64-8+1,0

palette DC.W $000,$200,$300,$400,$500,$600,$700,$732
        DC.W $742,$752,$652,$552,$770,$773,$775,$777

 _M
PAD DS.L 16
ECR_N DS.L 1
palette_orig DS.W 16
FICHIER DS.B 12+1
CHOIX DC.W 0
IMG DS.B 32128
DEG_NEO DS.B 1 ;drap.

N_M DS.B 1 ;indicateur Normal/Miroir
ECR_M DS.L 1
 DS.B 32000+256

 DS.B 1 ;"r�aligner" les TAB
TAB_N DS.B (320+2)*(200+2)
TAB_M DS.B (320+2)*(200+2)
 END
 