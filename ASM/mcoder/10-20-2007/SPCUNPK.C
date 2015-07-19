/***************************************************/
/* Spc_unpack(Spc_dest,Spc_srce,Spc_pal);          */
/*-------------------------------------------------*/
/* char *Spc_dest; Adresse de l'image decompactee. */
/* char *Spc_srce; Adresse de l'image compactee.   */
/* char *Spc_pal;  Adresse de la palette (19200).  */
/*-------------------------------------------------*/
/* Decompactage d'une image Spectrum 512.          */
/***************************************************/

Spc_unpack(Spc_dest,Spc_srce,Spc_pal)
char *Spc_dest,*Spc_srce,*Spc_pal;
{
     asm  {
          movea.l   Spc_srce(A6),A0
          adda.l    #4,A0
          move.l    (A0),D7
          adda.l    #8,A0
          add.l     A0,D7
          movea.l   Spc_dest(A6),A1
          move.w    #0x0001,D1
          move.w    #0x0007,D3
          lea       32000(A1),A2
          lea       8(A2),A3
lbl9:     lea       -31840(A2),A1
lbl8:     move.b    (A0)+,D2
          ext.w     D2
          bmi.s     lbl4
lbl5:     move.b    (A0)+,(A1)
          adda.w    D1,A1
          exg       D1,D3
          dbf       D2,lbl5
          bra.s     lbl6
lbl4:     neg.w     D2
          addq.w    #1,D2
          move.b    (A0)+,D0
lbl7:     move.b    D0,(A1)
          adda.w    D1,A1
          exg       D1,D3
          dbf       D2,lbl7
lbl6:     cmpa.l    A2,A1
          bcs.s     lbl8
          addq.l    #2,A2
          cmpa.l    A3,A2
          bcs.s     lbl9
          movea.l   D7,A0
          movea.l   Spc_pal(A6),A1
          move.w    #0x0254,D3
          clr.w     D0
lbl13:    move.w    #0x000D,D2
          move.w    (A0)+,D1
          lsr.w     #1,D1
          move.w    D0,(A1)+
lbl11:    lsr.w     #1,D1
          bcc.s     lbl10
          move.w    (A0)+,(A1)+
          dbf       D2,lbl11
          bra.s     lbl12
lbl10:    move.w    D0,(A1)+
          dbf       D2,lbl11
lbl12:    move.w    D0,(A1)+
          dbf       D3,lbl13
          }
}

