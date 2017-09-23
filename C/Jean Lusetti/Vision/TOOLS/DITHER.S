    .EXPORT dither_rvb16to8planes, tab_grey
    .EXPORT dither_rvb24to8planes, new_ind



* void dither_rvb16to8planes( pt_rvb, in->fd_w, pt ) ;
*                                A0      D0     A1
dither_rvb16to8planes:
  MOVE.L    D2,-(SP)
  MOVE.L    D3,-(SP)
  SUBQ.W    #1,D0   ; Pour DBF
drvb16_bcl:
  MOVE.W    (A0)+,D1
  MOVE.W    D1,D2
  MOVE.W    D1,D3

  ANDI.W    #$1F,D1

  LSR.W     #6,D2
  ANDI.W    #$1F,D2
  ADD.B     D2,D1

  ROL.W     #5,D3
  ANDI.W    #$1F,D3
  ADD.B     D3,D1

  MOVE.B    tab_grey(PC,D1.W),(A1)+

  DBF       D0,drvb16_bcl

  MOVE.L   (SP)+,D2
  MOVE.L   (SP)+,D3
  RTS


tab_grey: DS.B 256*3

* void dither_rvb24to8planes( pt_rvb, in->fd_w, pt ) ;
*                                A0      D0     A1
dither_rvb24to8planes:
  MOVE.L    D2,-(SP)
  MOVE.L    D3,-(SP)
  SUBQ.W    #1,D0   ; Pour DBF

  MOVEQ.L   #0,D3
  MOVEQ.L   #0,D2
drvb24_bcl:
  MOVEQ.L   #0,D1
  MOVE.B    (A0)+,D3
  MOVE.B    (A0)+,D2
  MOVE.B    (A0)+,D1
  ADD.W     D2,D1
  ADD.W     D3,D1

  MOVE.B    new_ind(PC,D1.W),(A1)+

  DBF       D0,drvb24_bcl

  MOVE.L   (SP)+,D2
  MOVE.L   (SP)+,D3
  RTS

new_ind : DS.B 256*3
