/***********************************************************/
/* Spc_copy(Spc_srce,Spc_pal);                             */
/*---------------------------------------------------------*/
/* char *Spc_srce; Adresse de l'image decompactee.         */
/* char *Spc_pal;  Adresse de la palette de couleurs.      */
/*---------------------------------------------------------*/
/* Affichage image Spectrum 512 et attente touche clavier. */
/***********************************************************/

Spc_copy(Spc_srce,Spc_pal)
char *Spc_srce,*Spc_pal;
{
     asm  {
          movem.l   D0-D7/A0-A5,-(A7)
          move.w    #18,-(A7)
          move.w    #4,-(A7)
          move.w    #3,-(A7)
          trap      #13
          addq.l    #6,A7
          move.w    #2,-(A7)
          trap      #14
          addq.l    #2,A7
          movea.l   D0,A3
          lea       Spc_dat(PC),A1
          move.l    Spc_pal(A6),(A1)
          clr.l     -(A7)
          move.w    #0x0020,-(A7)
          trap      #1
          addq.l    #6,A7
          move.l    D0,-(A7)
          move.l    0x000004CE,4(A1)
          lea       Spc_rtn(PC),A0
          lea       0x00FF8240,A2
          move.l    #7,D1
Spc_clr:  clr.l     (A2)+
          dbf       D1,Spc_clr
          move.l    Spc_srce(A6),A2
          move.l    #499,D1
Spc_bcl:  move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          move.l    (A2)+,(A3)+
          dbf       D1,Spc_bcl
          move.l    A0,0x04CE
          move.w    #0x0020,-(A7)
          trap      #1
          addq.l    #6,A7
          move.w    #0x0007,-(A7)
          trap      #1
          addq.l    #2,A7
          clr.l     -(A7)
          move.w    #0x0020,-(A7)
          trap      #1
          addq.l    #6,A7
          move.l    D0,-(A7)
          lea       Spc_dat(PC),A1
          move.w    SR,-(A7)
          ori       #0x0700,SR
          move.l    4(A1),0x04CE
          lea       0x00FF8240,A1
          move.l    #7,D0
Spc_clr2: clr.l     (A1)+
          dbf       D0,Spc_clr2
          move.w    (A7)+,SR
          move.w    #0x0020,-(A7)
          trap      #1
          addq.l    #6,A7
          move.w    #8,-(A7)
          move.w    #4,-(A7)
          move.w    #3,-(A7)
          trap      #13
          addq.l    #6,A7
          movem.l   (A7)+,D0-D7/A0-A5
          unlk      A6
          rts
Spc_dat:  dc.l      0,0
Spc_one:  dc.l      0
Spc_rtn:  tst.w     0x043E
          bne       Spc_excl
          move.w    SR,-(A7)
          ori       #0x0700,SR
          lea       0x00FF8240,A4
          lea       0x00FF8209,A5
          lea       (A4),A0
          lea       (A4),A1
          lea       (A4),A2
          lea       Spc_nop(PC),A6
          movea.l   Spc_dat(PC),A3
          move.w    #0x00C4,D7
          moveq     #0x00,D0
Spc_test: tst.b     (A5)
          beq.s     Spc_test
          move.b    (A5),D0
          adda.l    D0,A6
          adda.l    Spc_one(PC),A6
          jmp       (A6)
Spc_nop:  nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
          nop
lbl20:    nop
          lea       (A4),A0
          lea       (A4),A1
          lea       (A4),A2
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          nop
          dbf       D7,lbl20
          lea       (A4),A0
          lea       (A4),A1
          lea       (A4),A2
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          lea       (A4),A0
          lea       (A4),A1
          lea       (A4),A2
          lea       -19040(A3),A4
          nop
          nop
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A0)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A1)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.l    (A3)+,(A2)+
          move.w    (A7)+,SR
Spc_excl: rts
          }
}

