 TEXT 
Begin:
                  MOVEA.L   4(A7),A5
                  MOVE.L    12(A5),D0 
                  ADD.L     20(A5),D0 
                  ADD.L     28(A5),D0 
                  ADDI.L    #$100,D0
                  MOVE.L    D0,-(A7)
                  MOVE.L    A5,-(A7)
                  CLR.W     -(A7) 
                  MOVE.W    #$4A,-(A7)
                  TRAP      #1
                  LEA       12(A7),A7 
                  MOVE.W    #4,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #2,A7 
                  CMP.B     #2,D0 
                  BEQ       ITS_HI_RES
                  MOVE.W    D0,OLDREZ 
                  DC.B      ' ',10
                  BSR       SUPER 
                  BCLR      #0,$484.W 
                  MOVEA.L   #$FF8240,A0 
                  MOVEM.L   (A0),D0-D7
                  MOVEA.L   #OLDCOLOURS,A0
                  MOVEM.L   D0-D7,(A0)
                  MOVEQ     #1,D0 
                  BSR       SETRES
                  MOVE.L    $44E.W,SCRADD 
                  MOVE.L    #$7770000,-$7DC0.W
                  MOVE.L    #0,-$7DBC.W 
                  BSR       NEWFILE 
                  MOVEA.L   #TEXTFILE,A0
                  MOVE.L    A0,TEXTPOS
                  CLR.W     LINENO1 
                  BRA       SHOWPAGE
MAINLOOP:         LEA       TOTETEXT1,A0
                  MOVE.W    #$14,D0 
                  BSR       PLINE 
                  BSR       INVERT
MAINLOOP1:        BSR       GETKEY
                  CMP.L     #$500032,D0 
                  BEQ       DOWNPAGE
                  CMP.L     #$480038,D0 
                  BEQ       UPPAGE
                  CMP.B     #$20,D0 
                  BEQ       LOADFILE
                  CMP.B     #$31,D0 
                  BEQ       GOMARKER1 
                  CMP.B     #$32,D0 
                  BEQ       GOMARKER2 
                  CMP.B     #$33,D0 
                  BEQ       GOMARKER3 
                  SWAP      D0
                  CMP.B     #$48,D0 
                  BEQ       UPLINE
                  CMP.B     #$50,D0 
                  BEQ       DOWNLINE
                  CMP.B     #$14,D0 
                  BEQ       TOPTEXT 
                  CMP.B     #$4B,D0 
                  BEQ       TOPTEXT 
                  CMP.B     #$30,D0 
                  BEQ       BOT 
                  CMP.B     #$4D,D0 
                  BEQ       BOT 
                  CMP.B     #$78,D0 
                  BEQ       SETMARKER1
                  CMP.B     #$79,D0 
                  BEQ       SETMARKER2
                  CMP.B     #$7A,D0 
                  BEQ       SETMARKER3
                  CMP.B     #$10,D0 
                  BEQ       QUIT
                  CMP.B     #$61,D0 
                  BEQ       QUIT
                  CMP.B     #$3E,D0 
                  BEQ       CLRMARKERS
                  CMP.B     #$3B,D0 
                  BEQ       MARK_START
                  CMP.B     #$3C,D0 
                  BEQ       MARK_END2 
                  CMP.B     #$3D,D0 
                  BEQ       MARK_END1 
                  CMP.B     #$2E,D0 
                  BEQ       CHANGECOLS
                  CMP.B     #$44,D0 
                  BEQ       PRINT 
                  CMP.B     #$62,D0 
                  BEQ       HELP
                  BRA       MAINLOOP1 
GETKEY:           PEA       $600FF
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.W     D0
                  BNE.B     GETKEY
                  MOVE.W    #7,-(A7)
                  TRAP      #1
                  ADDQ.L    #2,A7 
                  RTS 
UPLINE:           SF        EOF 
                  MOVEA.L   TEXTPOS,A0
                  CMPA.L    #TEXTFILE,A0
                  BNE.B     CONTUP
                  CLR.W     LINENO1 
                  BRA       XDONEALL
CONTUP:           SUBQ.L    #1,A0 
L0005:            CMPA.L    #TEXTFILE,A0
                  BLE.B     ITSTOP
                  SUBQ.L    #1,A0 
                  CMPI.B    #$A,(A0)
                  BNE.B     L0005 
                  ADDQ.L    #1,A0 
                  SUBQ.W    #1,LINENO1
                  BRA.B     OKUP
ITSTOP:           LEA       TEXTFILE(PC),A0 
                  MOVE.L    A0,TEXTPOS
                  CLR.W     LINENO1 
                  BRA.B     OKUP1 
OKUP:             MOVE.L    A0,TEXTPOS
OKUP1:            MOVEM.L   A1-A6/D0-D7,-(A7) 
                  MOVEA.L   SCRADD,A0 
                  ADDA.L    #$5A00,A0 
                  MOVEA.L   A0,A1 
                  ADDA.L    #$500,A0
                  MOVE.W    #$12,D0 
SHIFTDOWN:        BSR       DOIT
                  SUBA.L    #$A00,A0
                  SUBA.L    #$A00,A1
                  DBF       D0,SHIFTDOWN
                  CLR.W     D0
                  MOVEA.L   TEXTPOS,A0
                  BSR       PLINE 
                  MOVEM.L   (A7)+,A1-A6/D0-D7 
                  BRA       XDONEALL
DOWNLINE:         TST.W     EOF 
                  BEQ       GODOWNTHEN
                  BRA       MAINLOOP1 
GODOWNTHEN:       MOVEA.L   TEXTPOS,A0
                  MOVEA.L   A0,A1 
L000C:            MOVE.B    (A0)+,D2
                  CMPI.B    #$D,D2
                  BEQ.B     L000D 
                  CMPI.B    #0,D2 
                  BNE.B     L000C 
                  ST        EOF 
                  BRA       MAINLOOP1 
L000D:            ADDQ.L    #1,A0 
                  MOVE.L    A0,TEXTPOS
                  MOVE.W    #$12,D1 
L000E:            MOVE.B    (A0)+,D2
                  CMPI.B    #$D,D2
                  BEQ.B     L000F 
                  CMPI.B    #0,D2 
                  BNE.B     L000E 
                  ST        EOF 
                  MOVE.L    A1,TEXTPOS
                  BRA       MAINLOOP1 
L000F:            DBF       D1,L000E
                  ADDQ.L    #1,A0 
                  CMPA.L    FILEEND,A0
                  BLE.B     L0010 
                  BRA       MAINLOOP1 
L0010:            MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVE.L    A0,-(A7)
                  MOVEA.L   SCRADD,A1 
                  MOVEA.L   A1,A0 
                  ADDA.L    #$500,A1
                  MOVE.W    #$12,D0 
SHIFTUP:          BSR       DOIT
                  DBF       D0,SHIFTUP
                  MOVEA.L   (A7)+,A0
                  MOVE.W    #$13,D0 
                  BSR       PLINE 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  ADDQ.W    #1,LINENO1
                  BRA       XDONEALL
DOWNPAGE:         MOVEA.L   TEXTPOS,A0
                  CMPI.B    #0,2(A0)
                  BEQ       XDONEALL
                  ADDI.L    #$14,LINENO1
                  MOVE.W    #$13,D1 
DOWNLOOP:         MOVE.B    (A0)+,D0
                  CMP.B     #0,D0 
                  BEQ       MAINLOOP1 
                  CMP.B     #$A,D0
                  BNE.B     DOWNLOOP
                  DBF       D1,DOWNLOOP 
                  CMPI.B    #0,-1(A0) 
                  BEQ       MAINLOOP1 
                  MOVE.L    A0,TEXTPOS
                  ADDI.W    #$14,LINENO1
                  BRA       SHOWPAGE
UPPAGE:           SF        EOF 
                  MOVE.W    #$14,D1 
                  MOVEA.L   TEXTPOS,A0
                  CMPI.L    #TEXTFILE,TEXTPOS 
                  BGT       BLOOP 
                  CLR.W     LINENO1 
                  BRA       XDONEALL
BLOOP:            MOVE.B    (A0),D0 
                  SUBQ.L    #1,A0 
                  CMPA.L    #TEXTFILE,A0
                  BGT.B     L0016 
                  MOVE.L    #TEXTFILE,TEXTPOS 
                  MOVEA.L   TEXTPOS,A0
                  CLR.W     LINENO1 
                  BRA       SHOWPAGE
L0016:            CMP.B     #$A,D0
                  BNE.B     BLOOP 
                  DBF       D1,BLOOP
                  ADDQ.L    #2,A0 
                  MOVE.L    A0,TEXTPOS
                  SUBI.W    #$14,LINENO1
                  BRA       SHOWPAGE
TOPTEXT:          LEA       TEXTFILE,A0 
                  MOVE.L    A0,TEXTPOS
                  SF        EOF 
                  CLR.W     LINENO1 
                  BRA       SHOWPAGE
BOT:              TST.W     EOF 
                  BNE       XDONEALL
                  MOVE.W    BOTTOMNO,LINENO1
                  MOVEA.L   BOTTOM1,A0
                  MOVE.L    A0,TEXTPOS
                  BRA       SHOWPAGE
MARK_START:       MOVEA.L   TEXTPOS,A0
                  SF        EOF 
                  MOVE.L    A0,MARKSTART
                  BRA       SHOWPAGE
MARK_END1:        MOVEA.L   TEXTPOS,A0
                  SF        EOF 
                  MOVE.L    A0,MARKEND
                  BRA       SHOWPAGE
MARK_END2:        MOVEA.L   TEXTPOS,A0
                  CMPI.B    #0,2(A0)
                  BEQ.B     BENDX 
                  MOVE.W    #$13,D1 
BENDLOOP:         MOVE.B    (A0)+,D0
                  CMP.B     #0,D0 
                  BEQ.B     BENDX 
                  CMP.B     #$A,D0
                  BNE.B     BENDLOOP
                  DBF       D1,BENDLOOP 
                  CMPI.B    #0,(A0) 
                  BNE.B     BENDCONT
BENDX:            MOVEA.L   FILEEND,A0
                  SUBQ.L    #1,A0 
BENDCONT:         MOVE.L    A0,MARKEND
                  SF        EOF 
                  MOVEA.L   TEXTPOS,A0
                  BRA       SHOWPAGE
CLRMARKERS:       CLR.L     MARKSTART 
                  CLR.L     MARKEND 
                  SF        EOF 
                  MOVEA.L   TEXTPOS,A0
                  BRA       SHOWPAGE
CHANGECOLS:       NOT.W     -$7DC0.W
                  NOT.W     -$7DBE.W
                  NOT.W     -$7DBC.W
                  NOT.W     -$7DBA.W
                  BRA       MAINLOOP1 
SETMARKER1:       MOVEA.L   TEXTPOS,A0
                  MOVE.L    A0,MARKER1
                  MOVE.W    LINENO1,MARKER1LINE 
                  BRA       MAINLOOP1 
SETMARKER2:       MOVEA.L   TEXTPOS,A0
                  MOVE.L    A0,MARKER2
                  MOVE.W    LINENO1,MARKER2LINE 
                  BRA       MAINLOOP1 
SETMARKER3:       MOVEA.L   TEXTPOS,A0
                  MOVE.L    A0,MARKER3
                  MOVE.W    LINENO1,MARKER3LINE 
                  BRA       MAINLOOP1 
GOMARKER1:        TST.L     MARKER1 
                  BEQ       MAINLOOP
                  MOVEA.L   MARKER1,A0
                  MOVE.L    A0,TEXTPOS
                  SF        EOF 
                  MOVE.W    MARKER1LINE,LINENO1 
                  BRA       SHOWPAGE
GOMARKER2:        TST.L     MARKER2 
                  BEQ       MAINLOOP
                  MOVEA.L   MARKER2,A0
                  MOVE.L    A0,TEXTPOS
                  SF        EOF 
                  MOVE.W    MARKER2LINE,LINENO1 
                  BRA       SHOWPAGE
GOMARKER3:        TST.L     MARKER3 
                  BEQ       MAINLOOP
                  MOVEA.L   MARKER3,A0
                  MOVE.L    A0,TEXTPOS
                  SF        EOF 
                  MOVE.W    MARKER3LINE,LINENO1 
                  BRA       SHOWPAGE
DONEALL:          MOVE.W    LINENO1,D0
                  LEA       SHOWING1,A0 
                  BSR       TODECIMAL 
                  MOVE.W    LINENO1,D0
                  ADDI.W    #$13,D0 
                  MOVE.W    LINES,D1
                  CMP.W     D0,D1 
                  BGT.B     DONEALL1
                  MOVE.W    LINES,D0
                  LEA       SHOWING2,A0 
                  BSR       TODECIMAL 
                  BRA       DONEALL2
DONEALL1:         LEA       SHOWING2,A0 
                  BSR       TODECIMAL 
DONEALL2:         LEA       SHOWINGX,A0 
                  MOVE.W    #$16,D0 
                  BSR       PLINE 
                  BRA       MAINLOOP
XDONEALL:         MOVE.W    LINENO1,D0
                  LEA       SHOWING1,A0 
                  BSR       TODECIMAL 
                  MOVE.W    LINENO1,D0
                  ADDI.W    #$13,D0 
                  MOVE.W    LINES,D1
                  CMP.W     D0,D1 
                  BGT.B     XDONEALL1 
                  MOVE.W    LINES,D0
                  LEA       SHOWING2,A0 
                  BSR       TODECIMAL 
                  BRA       XDONEALL2 
XDONEALL1:        LEA       SHOWING2,A0 
                  BSR       TODECIMAL 
XDONEALL2:        LEA       SHOWINGX,A0 
                  MOVE.W    #$16,D0 
                  BSR       PLINE 
                  BRA       MAINLOOP1 
SHOWPAGE:         MOVE.W    #0,D0 
                  CLR.W     LINENO2 
L002E:            BSR.B     PLINE 
                  TST.W     EOF 
                  BNE.B     ENDOFTEXT 
                  ADDQ.W    #1,D0 
                  CMP.W     #$14,D0 
                  BGE.B     GORTS 
                  BRA.B     L002E 
GORTS:            BRA       DONEALL 
ENDOFTEXT:        LEA       ENDSPACES,A0
                  BSR.B     PLINE 
                  ADDQ.W    #1,D0 
                  CMP.W     #$14,D0 
                  BGE.B     GORTS 
                  BRA.B     ENDOFTEXT 
PLINE:            BSR       CLEARBUFF 
                  MOVE.W    D0,D1 
                  MULU      #$500,D1
                  LEA       LINEBUFFER,A1 
                  MOVEA.L   SCRADD,A2 
                  ADDA.L    D1,A2 
                  MOVE.L    A2,SCREENPOS
LINELOOP:         CLR.L     D2
                  MOVE.B    (A0)+,D2
                  TST.B     D2
                  BNE.B     L0033 
                  ST        EOF 
                  BRA       ENDOFLINE 
L0033:            CMPI.B    #$D,D2
                  BEQ       ENDOFLINE 
                  CMPI.B    #9,D2 
                  BEQ       TAB 
                  BSR.B     DOCHAR
                  ADDQ.L    #1,A1 
                  MOVE.B    (A0)+,D2
                  TST.B     D2
                  BNE.B     L0034 
                  ST        EOF 
                  BRA       ENDOFLINE 
L0034:            CMPI.B    #$D,D2
                  BEQ       ENDOFLINE 
                  CMPI.B    #9,D2 
                  BEQ       TAB 
                  BSR.B     DOCHAR
                  ADDQ.L    #3,A1 
                  BRA.B     LINELOOP
DOCHAR:           LEA       FONT(PC),A2 
                  ADDA.W    D2,A2 
                  MOVE.B    (A2),(A1) 
                  MOVE.B    256(A2),160(A1) 
                  MOVE.B    512(A2),320(A1) 
                  MOVE.B    768(A2),480(A1) 
                  MOVE.B    1024(A2),640(A1)
                  MOVE.B    1280(A2),800(A1)
                  MOVE.B    1536(A2),960(A1)
                  MOVE.B    1792(A2),1120(A1) 
                  CMPA.L    MARKSTART,A0
                  BLE.B     NOBLOCK 
                  CMPA.L    MARKEND,A0
                  BGE.B     NOBLOCK 
                  TST.L     MARKEND 
                  BEQ       NOBLOCK 
                  ANDI.B    #$55,(A1) 
                  ANDI.B    #$55,160(A1)
                  ANDI.B    #$55,320(A1)
                  ANDI.B    #$55,480(A1)
                  ANDI.B    #$55,640(A1)
                  ANDI.B    #$55,800(A1)
                  ANDI.B    #$55,960(A1)
                  ANDI.B    #$55,1120(A1) 
NOBLOCK:          RTS 
TAB:              MOVE.L    A1,D3 
                  BTST      #0,D3 
                  BEQ.B     NEXTTAB 
                  CLR.B     (A1)
                  CLR.B     160(A1) 
                  CLR.B     320(A1) 
                  CLR.B     480(A1) 
                  CLR.B     640(A1) 
                  CLR.B     800(A1) 
                  CLR.B     960(A1) 
                  CLR.B     1120(A1)
                  ADDQ.L    #3,A1 
NEXTTAB:          CLR.W     (A1)
                  CLR.W     160(A1) 
                  CLR.W     320(A1) 
                  CLR.W     480(A1) 
                  CLR.W     640(A1) 
                  CLR.W     800(A1) 
                  CLR.W     960(A1) 
                  CLR.W     1120(A1)
                  ADDQ.L    #4,A1 
NEXTTAB1:         MOVE.L    A1,D2 
                  LEA       LINEBUFFER,A3 
                  SUB.L     A3,D2 
                  DIVU      #$A0,D2 
                  SWAP      D2
                  TST.W     D2
                  BEQ       STARTOFLINE 
                  ANDI.L    #$FFFF,D2 
                  DIVU      #$10,D2 
                  SWAP      D2
                  DIVU      #$A,D2
                  SWAP      D2
                  TST.B     D2
                  BEQ.B     DONETAB 
STARTOFLINE:      CLR.W     (A1)
                  CLR.W     160(A1) 
                  CLR.W     320(A1) 
                  CLR.W     480(A1) 
                  CLR.W     640(A1) 
                  CLR.W     800(A1) 
                  CLR.W     960(A1) 
                  CLR.W     1120(A1)
                  ADDQ.L    #4,A1 
                  BRA.B     NEXTTAB1
DONETAB:          CLR.L     D2
                  BRA       LINELOOP
ENDOFLINE:        MOVEM.L   A0-A6/D0-D7,-(A7) 
                  LEA       LINEBUFFER,A1 
                  MOVEA.L   SCREENPOS,A0
                  BSR       DOIT
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  ADDQ.L    #1,A0 
                  RTS 
CLEARBUFF:        MOVE.L    A0,-(A7)
                  LEA       LINEBUFFER,A0 
                  CLR.L     D1
                  MOVE.L    D1,D2 
                  MOVE.L    D1,D3 
                  MOVE.L    D1,D4 
                  MOVE.L    D1,D5 
                  MOVE.L    D1,D6 
                  MOVE.L    D1,D7 
                  MOVEA.L   D1,A2 
                  MOVEA.L   D1,A3 
                  MOVEA.L   D1,A4 
                  MOVEA.L   D1,A5 
                  MOVEA.L   D1,A6 
                  MOVEM.L   A2-A6/D1-D7,(A0)
                  MOVEM.L   A2-A6/D1-D7,48(A0)
                  MOVEM.L   A2-A6/D1-D7,96(A0)
                  MOVEM.L   A2-A6/D1-D7,144(A0) 
                  MOVEM.L   A2-A6/D1-D7,192(A0) 
                  MOVEM.L   A2-A6/D1-D7,240(A0) 
                  MOVEM.L   A2-A6/D1-D7,288(A0) 
                  MOVEM.L   A2-A6/D1-D7,336(A0) 
                  MOVEM.L   A2-A6/D1-D7,384(A0) 
                  MOVEM.L   A2-A6/D1-D7,432(A0) 
                  MOVEM.L   A2-A6/D1-D7,480(A0) 
                  MOVEM.L   A2-A6/D1-D7,528(A0) 
                  MOVEM.L   A2-A6/D1-D7,576(A0) 
                  MOVEM.L   D1-D4,624(A0) 
                  LEA       640(A0),A0
                  MOVEM.L   A2-A6/D1-D7,(A0)
                  MOVEM.L   A2-A6/D1-D7,48(A0)
                  MOVEM.L   A2-A6/D1-D7,96(A0)
                  MOVEM.L   A2-A6/D1-D7,144(A0) 
                  MOVEM.L   A2-A6/D1-D7,192(A0) 
                  MOVEM.L   A2-A6/D1-D7,240(A0) 
                  MOVEM.L   A2-A6/D1-D7,288(A0) 
                  MOVEM.L   A2-A6/D1-D7,336(A0) 
                  MOVEM.L   A2-A6/D1-D7,384(A0) 
                  MOVEM.L   A2-A6/D1-D7,432(A0) 
                  MOVEM.L   A2-A6/D1-D7,480(A0) 
                  MOVEM.L   A2-A6/D1-D7,528(A0) 
                  MOVEM.L   A2-A6/D1-D7,576(A0) 
                  MOVEM.L   D1-D4,624(A0) 
                  MOVEA.L   (A7)+,A0
                  RTS 
DOIT:             MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,(A0)
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,48(A0)
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,96(A0)
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,144(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,192(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,240(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,288(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,336(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,384(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,432(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,480(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,528(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,576(A0) 
                  MOVEM.L   (A1)+,D1-D4 
                  MOVEM.L   D1-D4,624(A0) 
                  LEA       640(A0),A0
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,(A0)
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,48(A0)
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,96(A0)
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,144(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,192(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,240(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,288(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,336(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,384(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,432(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,480(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,528(A0) 
                  MOVEM.L   (A1)+,A2-A6/D1-D7 
                  MOVEM.L   A2-A6/D1-D7,576(A0) 
                  MOVEM.L   (A1)+,D1-D4 
                  MOVEM.L   D1-D4,624(A0) 
                  LEA       640(A0),A0
                  RTS 
PRINT:            BSR       CLS 
                  LEA       POTEXT,A0 
                  MOVE.W    #$14,D0 
                  BSR       PLINE 
                  BSR       INVERT
PRINT1:           MOVE.L    LINESPP,D0
                  MOVEA.L   #LPPX,A0
                  BSR       TODECIMAL 
                  MOVE.W    #$15,D0 
                  LEA       LPPTEXT,A0
                  BSR       PLINE 
                  BSR       SHOWBLK 
                  BSR       SHOWPALL
PRINTOPTS:        BSR       GETKEY
                  CMP.L     #$500032,D0 
                  BEQ       DOWN10LPP 
                  CMP.L     #$480038,D0 
                  BEQ       UP10LPP 
                  SWAP      D0
                  CMP.B     #$3B,D0 
                  BEQ       CPTYPE
                  CMP.B     #$3C,D0 
                  BEQ       CPMODE
                  CMP.B     #$3D,D0 
                  BEQ       CPPORT
                  CMP.B     #$52,D0 
                  BEQ       RESTORELPP
                  CMP.B     #$48,D0 
                  BEQ       UPLPP 
                  CMP.B     #$50,D0 
                  BEQ       DOWNLPP 
                  CMP.B     #$43,D0 
                  BEQ       PRINTBLOCK
                  CMP.B     #$44,D0 
                  BEQ       PRINTALL
                  CMP.B     #$10,D0 
                  BEQ       MAINLOOP
                  CMP.B     #$61,D0 
                  BEQ       DONEPRINT 
                  BRA.B     PRINTOPTS 
DONEPRINT:        BSR       CLS 
                  MOVEA.L   TEXTPOS,A0
                  SF        EOF 
                  BRA       SHOWPAGE
CPTYPE:           MOVE.W    PCONFIG,D0
                  BTST      #2,D0 
                  BEQ       TOEPSON 
                  BCLR      #2,D0 
                  BRA       OKPTYPE 
TOEPSON:          BSET      #2,D0 
OKPTYPE:          MOVE.W    D0,PCONFIG
                  BTST      #2,D0 
                  BEQ       TYPEATARI 
                  LEA       PEPSON,A0 
                  LEA       PTTYPE,A1 
                  BRA.B     XTYPE 
TYPEATARI:        LEA       PATARI,A0 
                  LEA       PTTYPE,A1 
XTYPE:            MOVE.W    #$15,D0 
TYPECHANGE:       MOVE.B    (A0)+,(A1)+ 
                  DBF       D0,TYPECHANGE 
                  BRA       PRINT1
CPMODE:           MOVE.W    PCONFIG,D0
                  BTST      #3,D0 
                  BEQ       TOQUALITY 
                  BCLR      #3,D0 
                  BRA.B     OKPMODE 
TOQUALITY:        BSET      #3,D0 
OKPMODE:          MOVE.W    D0,PCONFIG
                  BTST      #3,D0 
                  BEQ       MODEDRAFT 
                  LEA       PQUALITY,A0 
                  LEA       PTMODE,A1 
                  BRA.B     XTYPE 
MODEDRAFT:        LEA       PDRAFT,A0 
                  LEA       PTMODE,A1 
                  BRA.B     XTYPE 
CPPORT:           MOVE.W    PCONFIG,D0
                  BTST      #4,D0 
                  BEQ       TORS232 
                  BCLR      #4,D0 
                  BRA.B     OKPPORT 
TORS232:          BSET      #4,D0 
OKPPORT:          MOVE.W    D0,PCONFIG
                  BTST      #4,D0 
                  BEQ       PORTCENT
                  LEA       PRS232,A0 
                  LEA       PTPORT,A1 
                  BRA       XTYPE 
PORTCENT:         LEA       PCENTRON,A0 
                  LEA       PTPORT,A1 
                  BRA       XTYPE 
SHOWBLK:          MOVEA.L   MARKSTART,A2
                  MOVEA.L   MARKEND,A3
PLOOP:            MOVE.B    (A2)+,D0
                  CMPA.L    A2,A3 
                  BLT.B     DONEP 
                  CMP.B     #$D,D0
                  BNE.B     PLOOP 
                  ADDQ.L    #1,D5 
                  BRA.B     PLOOP 
DONEP:            MOVE.L    LINESPP,D4
                  DIVU      D4,D5 
                  MOVE.L    D5,D3 
                  SWAP      D3
                  TST.W     D3
                  BEQ.B     NOTADD
                  ADDQ.L    #1,D5 
NOTADD:           ANDI.L    #$FFFF,D5 
                  MOVE.L    D5,D0 
                  LEA       BLKNOPAGES(PC),A0 
                  BSR       TODECIMAL 
                  LEA       BLKPRINT1,A0
                  MOVE.W    #$16,D0 
                  BSR       PLINE 
                  RTS 
SHOWPALL:         LEA       TEXTFILE,A2 
                  MOVEA.L   FILEEND,A3
PLOOP1:           MOVE.B    (A2)+,D0
                  CMPA.L    A2,A3 
                  BLT.B     DONEP1
                  CMP.B     #$D,D0
                  BNE.B     PLOOP1
                  ADDQ.L    #1,D5 
                  BRA.B     PLOOP1
DONEP1:           MOVE.L    LINESPP,D4
                  DIVU      D4,D5 
                  MOVE.L    D5,D3 
                  SWAP      D3
                  TST.W     D3
                  BEQ.B     NOTADD1 
                  ADDQ.L    #1,D5 
NOTADD1:          ANDI.L    #$FFFF,D5 
                  MOVE.L    D5,D0 
                  LEA       ALLNOPAGES(PC),A0 
                  BSR       TODECIMAL 
                  LEA       ALLPRINT1,A0
                  MOVE.W    #$17,D0 
                  BSR       PLINE 
                  RTS 
PRINTBLOCK:       TST.L     MARKSTART 
                  BEQ       PRINT1
                  TST.L     MARKEND 
                  BEQ       PRINT1
                  LEA       BLKNOPAGES,A0 
                  LEA       PALL,A1 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVEA.L   MARKSTART,A0
                  MOVEA.L   MARKEND,A1
                  BRA       PRINTER 
PRINTALL:         LEA       ALLNOPAGES,A0 
                  LEA       PALL,A1 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVE.B    (A0)+,(A1)+ 
                  MOVE.B    (A0)+,(A1)+ 
                  LEA       TEXTFILE,A0 
                  MOVEA.L   FILEEND,A1
PRINTER:          MOVEA.L   A0,A2 
                  MOVEA.L   A1,A3 
                  CLR.L     D5
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
                  BSR       CLS 
                  LEA       PRINTING,A0 
                  MOVE.W    #$14,D0 
                  BSR       PLINE 
                  BSR       INVERT
                  MOVE.W    PCONFIG,-(A7) 
                  MOVE.W    #$21,-(A7)
                  TRAP      #$E 
                  ADDQ.L    #4,A7 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  MOVE.L    #0,PAGESDONE
                  CLR.L     D5
PRTLOOP1:         ADDQ.L    #1,PAGESDONE
                  BSR.B     PAGEXOFX
                  MOVE.W    LINESPP,D7
                  SUBQ.W    #1,D7 
PRTLOOP:          MOVE.W    #$FF,-(A7)
                  MOVE.W    #6,-(A7)
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.W     D0
                  BEQ.B     NOKEY 
                  BRA       QUITPRINT 
NOKEY:            MOVE.B    (A0)+,D5
                  CMPA.L    A0,A1 
                  BGT.B     PRINTCHAR 
                  BSR.B     NEWPAGE 
                  BRA       DONEPRINT 
PRINTCHAR:        MOVE.W    D5,-(A7)
                  MOVE.W    D5,-(A7)
                  MOVE.W    #5,-(A7)
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  TST.W     D0
                  BEQ       QUITPRINT 
                  MOVE.W    (A7)+,D5
                  CMP.B     #$A,D5
                  BNE.B     CONT
                  DBF       D7,PRTLOOP
                  BSR.B     NEWPAGE 
                  BRA.B     PRTLOOP1
CONT:             BRA.B     PRTLOOP 
NEWPAGE:          MOVE.W    #$C,-(A7) 
                  MOVE.W    #5,-(A7)
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  RTS 
PAGEXOFX:         MOVEM.L   A0-A6/D0-D7,-(A7) 
                  MOVE.L    PAGESDONE,D0
                  LEA       PDONE,A0
                  BSR       TODECIMAL 
                  LEA       GOING,A0
                  MOVE.W    #$16,D0 
                  BSR       PLINE 
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  RTS 
                  BRA       PRINT 
QUITPRINT:        LEA       PRINTERROR1,A0
                  MOVE.W    #$14,D0 
                  BSR       PLINE 
                  BSR       INVERT
                  LEA       PRINTERROR2,A0
                  MOVE.W    #$16,D0 
                  BSR       PLINE 
                  BSR       GETKEY
                  BRA       PRINT 
RESTORELPP:       MOVE.L    #$40,LINESPP
                  BRA       PRINT1
DOWN10LPP:        SUBI.L    #$A,LINESPP 
                  CMPI.L    #1,LINESPP
                  BGE       PRINT1
                  MOVE.L    #1,LINESPP
                  BRA       PRINT1
UP10LPP:          ADDI.L    #$A,LINESPP 
                  CMPI.L    #$3E8,LINESPP 
                  BLE       PRINT1
                  MOVE.L    #$3E8,LINESPP 
                  BRA       PRINT1
DOWNLPP:          SUBQ.L    #1,LINESPP
                  CMPI.L    #1,LINESPP
                  BGE       PRINT1
                  MOVE.L    #1,LINESPP
                  BRA       PRINT1
UPLPP:            ADDQ.L    #1,LINESPP
                  CMPI.L    #$3E8,LINESPP 
                  BLE       PRINT1
                  MOVE.L    #$3E8,LINESPP 
                  BRA       PRINT1
                  MOVE.L    LINESPP,D0
                  MOVEA.L   #LPPX,A0
                  BSR       TODECIMAL 
                  MOVE.W    #$14,D0 
                  LEA       LPPTEXT,A0
                  BSR       PLINE 
                  BRA       PRINTOPTS 
INVERT:           MOVEM.L   A1/D0,-(A7) 
                  MOVEA.L   SCRADD,A1 
                  MULU      #$500,D0
                  ADDA.W    D0,A1 
                  MOVE.W    #$27,D0 
INV1:             NOT.W     (A1)
                  NOT.W     160(A1) 
                  NOT.W     320(A1) 
                  NOT.W     480(A1) 
                  NOT.W     640(A1) 
                  NOT.W     800(A1) 
                  NOT.W     960(A1) 
                  NOT.W     1120(A1)
                  ADDQ.L    #4,A1 
                  DBF       D0,INV1 
                  MOVEM.L   (A7)+,A1/D0 
                  RTS 
TODECIMAL:        ANDI.L    #$FFFF,D0 
                  DIVU      #$3E8,D0
                  ADDI.B    #$30,D0 
                  MOVE.B    D0,(A0)+
                  SWAP      D0
                  ANDI.L    #$FFFF,D0 
                  DIVU      #$64,D0 
                  ADDI.B    #$30,D0 
                  MOVE.B    D0,(A0)+
                  SWAP      D0
                  ANDI.L    #$FFFF,D0 
                  DIVU      #$A,D0
                  ADDI.B    #$30,D0 
                  MOVE.B    D0,(A0)+
                  SWAP      D0
                  ANDI.L    #$FFFF,D0 
                  ADDI.B    #$30,D0 
                  MOVE.B    D0,(A0)+
                  RTS 
CLS:              CLR.W     D0
CLS1:             LEA       ENDSPACES,A0
                  BSR       PLINE 
                  ADDQ.W    #1,D0 
                  CMP.W     #$18,D0 
                  BEQ.B     CLSEND
                  BRA.B     CLS1
CLSEND:           RTS 
HELP:             BSR.B     CLS 
                  LEA       HELPTEXTF1,A0 
                  BSR       SHOWHELP1 
                  LEA       HLINESF1,A6 
                  BSR       BOXLINEA
HELPWAIT:         LEA       HELPTEXTA,A0
                  MOVE.W    #$17,D0 
                  BSR       PLINE 
                  BSR       INVERT
                  BSR       GETKEY
                  SWAP      D0
                  CMP.B     #$3B,D0 
                  BNE       HELPF2
                  BSR.B     CLS 
                  LEA       HELPTEXTF1,A0 
                  BSR       SHOWHELP1 
                  LEA       HLINESF1,A6 
                  BSR       BOXLINEA
                  BRA.B     HELPWAIT
HELPF2:           CMP.B     #$3C,D0 
                  BNE       HELPUNDO
                  BSR.B     CLS 
                  LEA       HELPTEXTF2,A0 
                  BSR       SHOWHELP1 
                  LEA       HLINESF2,A6 
                  BSR       BOXLINEA
HELPUNDO:         CMP.B     #$61,D0 
                  BNE.B     HELPWAIT
                  BSR       CLS 
                  MOVEA.L   TEXTPOS,A0
                  SF        EOF 
                  BRA       SHOWPAGE
SHOWHELP1:        SF        EOF 
                  MOVE.W    #0,D0 
HLOOP:            BSR       PLINE 
                  TST.W     EOF 
                  BNE.B     ENDOFHELP 
                  ADDQ.W    #1,D0 
                  CMP.W     #$16,D0 
                  BGE.B     GOHRTS
                  BRA.B     HLOOP 
GOHRTS:           RTS 
ENDOFHELP:        LEA       ENDSPACES,A0
                  BSR       PLINE 
                  ADDQ.W    #1,D0 
                  CMP.W     #$16,D0 
                  BGE.B     GOHRTS
                  BRA.B     ENDOFHELP 
BOXLINEA:         DC.B      ' ',0 
                  DC.B      '(H'
DRAWLOOP:         DC.B      '"N',12,'QÿÿgF9Q',0 
                  DC.B      '&9i',0 
                  DC.B      2,0 
                  DC.B      '(9i',0 
                  DC.B      4,0 
                  DC.B      '*9i',0 
                  DC.B      6,0 
                  DC.B      ',9|',0 
                  DC.B      'ÿ',0 
                  DC.B      24,'9|',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      26,'9|',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      28,'9|',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      30,'9|ÿÿ',0 
                  DC.B      '"9|',0 
                  DC.B      1,0 
                  DC.B      '$9|ÿÿ',0 
                  DC.B      '  ',3
                  ADDQ.L    #8,A6 
                  BRA.B     DRAWLOOP
                  RTS 
LOADFILE:         BSR.B     NEWFILE 
                  SF        EOF 
                  CLR.W     LINENO1 
                  LEA       TEXTFILE,A0 
                  MOVE.L    A0,TEXTPOS
                  BRA       SHOWPAGE
NEWFILE:          BSR       CLS 
                  MOVEA.L   #$FF8240,A0 
                  MOVEM.L   (A0),D0-D7
                  MOVEA.L   #STCOLOURS,A1 
                  MOVEM.L   D0-D7,(A1)
                  MOVEA.L   #LOADTEXT2A,A0
                  CLR.W     D0
                  BSR       PLINE 
                  BSR       INVERT
                  MOVEA.L   #LOADTEXT2B,A0
                  MOVEQ     #2,D0 
                  BSR       PLINE 
                  BSR       REDRAW
SFILELOOP:        BSR       GETKEY
                  SWAP      D0
                  CMP.B     #$48,D0 
                  BNE       TRYDOWNARR
                  SUBQ.W    #1,SELECTFILE 
                  CMPI.W    #0,SELECTFILE 
                  BGE.B     FNOTTOP 
                  MOVE.W    #0,SELECTFILE 
                  BRA.B     SFILELOOP 
FNOTTOP:          BSR       REDRAW
                  BRA.B     SFILELOOP 
TRYDOWNARR:       CMP.B     #$50,D0 
                  BNE.B     TRYOK 
                  ADDQ.W    #1,SELECTFILE 
                  CMPI.W    #1,SELECTFILE 
                  BLE.B     FNOTBOTTOM
                  MOVE.W    #1,SELECTFILE 
                  BRA.B     SFILELOOP 
FNOTBOTTOM:       BSR       REDRAW
                  BRA.B     SFILELOOP 
TRYOK:            SWAP      D0
                  CMP.B     #$20,D0 
                  BNE.B     TRYCANCEL 
                  BRA       GOTHEN
TRYCANCEL:        SWAP      D0
                  CMP.B     #$61,D0 
                  BNE.B     SFILELOOP 
                  BRA       NOLOAD
REDRAW:           MOVE.W    #5,D0 
                  MOVE.W    #0,D1 
DONEXTL:          LEA       FILETAB(PC),A6
                  MOVE.W    D1,D4 
                  LSL.W     #3,D4 
                  MOVEA.L   0(A6,D4.W),A0 
                  MOVEM.L   D0-D7,-(A7) 
                  BSR       PLINE 
                  MOVEM.L   (A7)+,D0-D7 
                  ADDQ.W    #1,D0 
                  ADDQ.W    #1,D1 
                  CMP.W     #1,D1 
                  BLE.B     DONEXTL 
                  MOVEA.L   SCRADD,A0 
                  MOVE.W    SELECTFILE,D3 
                  MULU      #$500,D3
                  ADDI.W    #$1900,D3 
                  ADDA.W    D3,A0 
                  ADDA.W    #$40,A0 
                  MOVE.W    #6,D3 
XYZLOOP:          NOT.W     (A0)
                  NOT.W     160(A0) 
                  NOT.W     320(A0) 
                  NOT.W     480(A0) 
                  NOT.W     640(A0) 
                  NOT.W     800(A0) 
                  NOT.W     960(A0) 
                  NOT.W     1120(A0)
                  ADDQ.L    #4,A0 
                  DBF       D3,XYZLOOP
                  RTS 
GOTHEN:           MOVE.W    SELECTFILE,D0 
                  LSL.W     #3,D0 
                  LEA       FILETAB,A0
                  MOVEA.L   4(A0,D0.W),A6 
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
                  BSR       CLS 
                  LEA       LOADTEXT1,A0
                  MOVE.W    #$14,D0 
                  BSR       PLINE 
                  BSR       INVERT
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  CLR.L     MARKSTART 
                  CLR.L     MARKEND 
                  LEA       TEXTFILE(PC),A0 
                  MOVE.W    #-$BDC,D0 
CLRTEXTBLK:       CLR.L     (A0)+ 
                  DBF       D0,CLRTEXTBLK 
                  BSR       UNSUPER 
                  MOVE.W    #0,-(A7)
                  MOVE.L    A6,-(A7)
                  MOVE.W    #$3D,-(A7)
                  TRAP      #1
                  ADDQ.L    #8,A7 
                  MOVE.W    D0,HANDLE 
                  PEA       TEXTFILE
                  MOVE.L    #$3D08F,-(A7) 
                  MOVE.W    HANDLE,-(A7)
                  MOVE.W    #$3F,-(A7)
                  TRAP      #1
                  ADDA.L    #$C,A7
                  MOVE.W    HANDLE,-(A7)
                  MOVE.W    #$3E,-(A7)
                  TRAP      #1
                  ADDQ.L    #4,A7 
                  BSR       SUPER 
                  LEA       TEXTFILE,A0 
                  CMPI.L    #$49434521,(A0) 
                  BNE.B     FINDEND 
                  LEA       DEPACKTEXT,A0 
                  MOVE.W    #$14,D0 
                  BSR       PLINE 
                  BSR       INVERT
                  LEA       TEXTFILE,A0 
                  BSR       ICE_DECRUNCH_2
FINDEND:          LEA       TEXTFILE(PC),A0 
ENDLOOP:          CMPI.B    #0,(A0)+
                  BNE.B     ENDLOOP 
                  SUBQ.L    #1,A0 
                  MOVE.L    A0,FILEEND
                  MOVE.W    #$13,D1 
                  MOVEA.L   FILEEND,A0
BOTLOOP:          MOVE.B    (A0),D0 
                  SUBQ.L    #1,A0 
                  CMPA.L    #TEXTFILE,A0
                  BGE.B     L0089 
                  MOVE.L    #TEXTFILE,BOTTOM1 
                  BRA.B     GETLNO
L0089:            CMP.B     #$A,D0
                  BNE.B     BOTLOOP 
                  DBF       D1,BOTLOOP
                  ADDQ.L    #2,A0 
                  MOVE.L    A0,BOTTOM1
GETLNO:           LEA       TEXTFILE(PC),A1 
                  CLR.W     D1
RBOTNO:           MOVE.B    (A1)+,D0
                  CMPA.L    A0,A1 
                  BEQ.B     DONEBOTNO 
                  CMP.B     #$D,D0
                  BNE.B     RBOTNO
                  ADDQ.W    #1,D1 
                  BRA.B     RBOTNO
DONEBOTNO:        MOVE.W    D1,BOTTOMNO 
                  LEA       TEXTFILE(PC),A0 
                  CLR.W     LINES 
RLINES:           MOVE.B    (A0)+,D0
                  CMP.B     #0,D0 
                  BEQ.B     DONELINES 
                  CMP.B     #$D,D0
                  BNE.B     RLINES
                  ADDQ.W    #1,LINES
                  BRA.B     RLINES
DONELINES:        CMPI.B    #$A,-2(A0)
                  BEQ       NOLOAD
                  ADDQ.L    #1,LINES
NOLOAD:           MOVEA.L   #STCOLOURS,A1 
                  MOVEM.L   (A1),D0-D7
                  MOVEA.L   #$FF8240,A0 
                  MOVEM.L   D0-D7,(A0)
                  TST.B     TEXTFILE
                  BEQ       QUIT
                  RTS 
QUIT:             MOVE.W    OLDREZ,D0 
                  BSR       SETRES
                  BSET      #0,$484.W 
                  LEA       OLDCOLOURS,A0 
                  MOVEM.L   (A0),D0-D7
                  LEA       $FF8240.L,A0
                  MOVEM.L   D0-D7,(A0)
                  MOVE.L    OLDSTACK,-(A7)
                  MOVE.W    #$20,-(A7)
                  TRAP      #1
                  ADDQ.L    #6,A7 
ITS_HI_RES:       CLR.W     -(A7) 
                  TRAP      #1
SUPER:            MOVE.L    #1,-(A7)
                  MOVE.W    #$20,-(A7)
                  TRAP      #1
                  ADDQ.L    #6,A7 
                  TST.W     D0
                  BNE.B     EXITSUPER 
                  CLR.L     -(A7) 
                  MOVE.W    #$20,-(A7)
                  TRAP      #1
                  ADDQ.L    #6,A7 
                  MOVE.L    D0,OLDSTACK 
EXITSUPER:        RTS 
UNSUPER:          MOVE.L    #1,-(A7)
                  MOVE.W    #$20,-(A7)
                  TRAP      #1
                  ADDQ.L    #6,A7 
                  TST.L     D0
                  BEQ.B     EXITUN
                  MOVE.L    OLDSTACK,-(A7)
                  MOVE.W    #$20,-(A7)
                  TRAP      #1
                  ADDQ.L    #6,A7 
EXITUN:           RTS 
SETRES:           MOVE.W    D0,-(A7)
                  PEA       -1.W
                  PEA       -1.W
                  MOVE.W    #5,-(A7)
                  TRAP      #$E 
                  LEA       12(A7),A7 
                  RTS 
ICE_DECRUNCH_2:   LINK      A3,#-$78
                  MOVEM.L   A0-A6/D0-D7,-(A7) 
                  LEA       120(A0),A4
                  MOVEA.L   A4,A6 
                  BSR       L009F 
                  BSR.B     L009F 
                  LEA       -8(A0,D0.L),A5
                  BSR.B     L009F 
                  MOVE.L    D0,(A7) 
                  ADDA.L    D0,A6 
                  MOVEA.L   A6,A1 
                  MOVEQ     #$77,D0 
L0098:            MOVE.B    -(A1),-(A3) 
                  DBF       D0,L0098
                  MOVEA.L   A6,A3 
                  MOVE.B    -(A5),D7
                  BSR.B     L00A1 
                  MOVEA.L   A3,A5 
                  BSR       L00A5 
                  BCC.B     L009C 
                  MOVE.W    #$F9F,D7
                  BSR       L00A5 
                  BCC.B     L0099 
                  MOVEQ     #$F,D0
                  BSR       L00A7 
                  MOVE.W    D1,D7 
L0099:            MOVEQ     #3,D6 
L009A:            MOVE.W    -(A3),D4
                  MOVEQ     #3,D5 
L009B:            ADD.W     D4,D4 
                  ADDX.W    D0,D0 
                  ADD.W     D4,D4 
                  ADDX.W    D1,D1 
                  ADD.W     D4,D4 
                  ADDX.W    D2,D2 
                  ADD.W     D4,D4 
                  ADDX.W    D3,D3 
                  DBF       D5,L009B
                  DBF       D6,L009A
                  MOVEM.W   D0-D3,(A3)
                  DBF       D7,L0099
L009C:            MOVEM.L   (A7),A0-A3/D0-D7
L009D:            MOVE.B    (A4)+,(A0)+ 
                  SUBQ.L    #1,D0 
                  BNE.B     L009D 
                  MOVEQ     #$77,D0 
L009E:            MOVE.B    -(A3),-(A5) 
                  DBF       D0,L009E
                  MOVEM.L   (A7)+,A0-A6/D0-D7 
                  UNLK      A3
                  RTS 
L009F:            MOVEQ     #3,D1 
L00A0:            LSL.L     #8,D0 
                  MOVE.B    (A0)+,D0
                  DBF       D1,L00A0
                  RTS 
L00A1:            BSR.B     L00A5 
                  BCC.B     L00A4 
                  MOVEQ     #0,D1 
                  BSR.B     L00A5 
                  BCC.B     L00A3 
                  LEA       L00B2(PC),A1
                  MOVEQ     #4,D3 
L00A2:            MOVE.L    -(A1),D0
                  BSR.B     L00A7 
                  SWAP      D0
                  CMP.W     D0,D1 
                  DBNE      D3,L00A2
                  ADD.L     20(A1),D1 
L00A3:            MOVE.B    -(A5),-(A6) 
                  DBF       D1,L00A3
L00A4:            CMPA.L    A4,A6 
                  BGT.B     L00AA 
                  RTS 
L00A5:            ADD.B     D7,D7 
                  BNE.B     L00A6 
                  MOVE.B    -(A5),D7
                  ADDX.B    D7,D7 
L00A6:            RTS 
L00A7:            MOVEQ     #0,D1 
L00A8:            ADD.B     D7,D7 
                  BNE.B     L00A9 
                  MOVE.B    -(A5),D7
                  ADDX.B    D7,D7 
L00A9:            ADDX.W    D1,D1 
                  DBF       D0,L00A8
                  RTS 
L00AA:            LEA       L00B3(PC),A1
                  MOVEQ     #3,D2 
L00AB:            BSR.B     L00A5 
                  DBCC      D2,L00AB
                  MOVEQ     #0,D4 
                  MOVEQ     #0,D1 
                  MOVE.B    1(A1,D2.W),D0 
                  EXT.W     D0
                  BMI.B     L00AC 
                  BSR.B     L00A7 
L00AC:            MOVE.B    6(A1,D2.W),D4 
                  ADD.W     D1,D4 
                  BEQ.B     L00AE 
                  LEA       L00B4(PC),A1
                  MOVEQ     #1,D2 
L00AD:            BSR.B     L00A5 
                  DBCC      D2,L00AD
                  MOVEQ     #0,D1 
                  MOVE.B    1(A1,D2.W),D0 
                  EXT.W     D0
                  BSR.B     L00A7 
                  ADD.W     D2,D2 
                  ADD.W     6(A1,D2.W),D1 
                  BPL.B     L00B0 
                  SUB.W     D4,D1 
                  BRA.B     L00B0 
L00AE:            MOVEQ     #0,D1 
                  MOVEQ     #5,D0 
                  MOVEQ     #-1,D2
                  BSR.B     L00A5 
                  BCC.B     L00AF 
                  MOVEQ     #8,D0 
                  MOVEQ     #$3F,D2 
L00AF:            BSR.B     L00A7 
                  ADD.W     D2,D1 
L00B0:            LEA       2(A6,D4.W),A1 
                  ADDA.W    D1,A1 
                  MOVE.B    -(A1),-(A6) 
L00B1:            MOVE.B    -(A1),-(A6) 
                  DBF       D4,L00B1
                  BRA       L00A1 
                  DC.B      127,'ÿ',0 
                  DC.B      14,0
                  DC.B      'ÿ',0 
                  DC.B      7,0 
                  DC.B      7,0 
                  DC.B      2,0 
                  DC.B      3,0 
                  DC.B      1,0 
                  DC.B      3,0 
                  DC.B      1 
L00B2:            DC.B      0 
                  DC.B      0 
                  DC.B      1,13,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      14,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      7,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      4,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      1 
L00B3:            DC.B      9,1,0 
                  DC.B      'ÿÿ',8,4,2,1,0
L00B4:            DC.B      11,4,7,0
                  DC.B      1,31,'ÿÿ',0 
                  DC.B      31
LOADTEXT1:        DC.B      '                        Loading text fil'
                  DC.B      'e  -  Please wait',13,10,0   
LOADTEXT2A:       DC.B      '        Ecstasy Crack in 93  Coded By Mushromm -  Please select a file                  ',13,10,0
                  DC.B      0 
LOADTEXT2B:       DC.B      'Use UP/DOWN arrows to select, SPACE will'
                  DC.B      ' load the inversed file, UNDO to cancel',13
                  DC.B      10,0
DEPACKTEXT:       DC.B      '                           Depacking - I'
                  DC.B      'CE Packer 2.4 File',13,10,0
                  DC.B      0 
HELPTEXTA:        DC.B      ' HELP  PAGE  -  F1 for NORMAL COMMANDS, '
                  DC.B      ' F2 for PRINT COMMANDS,  UNDO to exit.',13,10
                  DC.B      0 
                  DC.B      0 
                  DC.B      '                      This displayer was'
                  DC.B      ' coded by MUSHROOM',13,10,0
                  DC.B      0 
                  DC.B      '      Greets go to other members of Talk'
                  DC.B      ' of The East, TBE, Bacchus, and you',13,10,0 
HELPTEXTF1:       DC.B      13,10,'  ',9,'                      Normal Comman'
                  DC.B      'ds',13,10,13,10,'    KEY(s)                        ' 
                  DC.B      '         ACTION',13,10,13,10,'    cursor up        ' 
                  DC.B      '                      up 1 line',13,10,'    shi' 
                  DC.B      'ft-cursor up                        up 1'
                  DC.B      ' page (20 lines)',13,10,'    cursor down       ' 
                  DC.B      '                     down 1 line',13,10,'    sh' 
                  DC.B      'ift-cursor down                      dow'
                  DC.B      'n 1 page (20 lines)',13,10,'    alt-T or cursor' 
                  DC.B      ' left                   goto top of docu'
                  DC.B      'ment',13,10,'    alt-B or cursor right         ' 
                  DC.B      '         goto bottom of document',13,10,'    al' 
                  DC.B      't-1 / 1                              set'
                  DC.B      ' / goto marker 1',13,10,'    alt-2 / 2         ' 
                  DC.B      '                     set / goto marker 2'
                  DC.B      13,10,'    alt-3 / 3                         '
                  DC.B      '     set / goto marker 3',13,10,'    HELP      ' 
                  DC.B      '                             obvious!',13,10,' ' 
                  DC.B      '   SPACE                                '
                  DC.B      '  load a new file',13,10,'    alt-C            ' 
                  DC.B      '                      invert colours',13,10,'  ' 
                  DC.B      '  UNDO or alt-Q                         '
                  DC.B      ' quit',13,10,0 
HELPTEXTF2:       DC.B      13,10,'  ',9,'                       Print Comman'
                  DC.B      'ds',13,10,13,10,'    KEY(s)                        ' 
                  DC.B      '         ACTION',13,10,13,10,'    F1               ' 
                  DC.B      '                      Mark start of bloc'
                  DC.B      'k',13,10,'    F2                               ' 
                  DC.B      '      Mark end of block at bottom',13,10,'    F' 
                  DC.B      '3                                     Ma'
                  DC.B      'rk end of block to top',13,10,'    F4          ' 
                  DC.B      '                           Clear block m'
                  DC.B      'arkers',13,10,'    F10                         ' 
                  DC.B      '           Enter printing and print opti'
                  DC.B      'ons',13,10,13,10,'    When in the print menu the fo' 
                  DC.B      'llowing keys have the corresponding effe'
                  DC.B      'ct.',13,10,13,10,'    F1                           ' 
                  DC.B      '          Toggle printer type',13,10,'    F2   ' 
                  DC.B      '                                  Toggle'
                  DC.B      ' printer mode',13,10,'    F3                   ' 
                  DC.B      '                  Toggle printer port',13,10,' ' 
                  DC.B      '   F9                                   '
                  DC.B      '  Print marked block',13,10,'    F10           ' 
                  DC.B      '                         Print all of th'
                  DC.B      'e textfile',13,10,'    (shift) cursor up       ' 
                  DC.B      '               increases lines per page '
                  DC.B      'by (10) 1',13,10,'    (shift) cursor down      ' 
                  DC.B      '              decreases lines per page b'
                  DC.B      'y (10) 1',13,10,'    INSERT                    ' 
                  DC.B      '             restore lines per page (64)'
                  DC.B      13,10,'    UNDO                              '
                  DC.B      '     return to main menu',13,10,0
                  DC.B      0 
                  DC.B      27,'E',0
                  DC.B      0 
TOTETEXT1:        DC.B      '     Pure Energy Doc Displayer V.1   -  '
                  DC.B      ' Press HELP for instructions',13,10,0
                  DC.B      0 
PRINTERROR1:      DC.B      '                    Error or key press o'
                  DC.B      'ccurred during printing.',13,10,0
                  DC.B      0 
PRINTERROR2:      DC.B      '                       Press any key to '
                  DC.B      'return to print menu.',13,10,0 
PRINTING:         DC.B      '                         PRINTING - PRES'
                  DC.B      'S ANY KEY TO CANCEL',13,10,0 
GOING:            DC.B      '                             PRINTING PA'
                  DC.B      'GE ' 
PDONE:            DC.B      '0000 OF '
PALL:             DC.B      '0000',13,10,0
SHOWINGX:         DC.B      'Current lines being displayed  : ' 
SHOWING1:         DC.B      '0000 - ' 
SHOWING2:         DC.B      '0000',13,10,0
                  DC.B      0 
PATARI:           DC.B      'F1 - Atari printer  ',13,10
PEPSON:           DC.B      'F1 - Epson printer  ',13,10
PQUALITY:         DC.B      'F2 - Quality mode   ',13,10
PDRAFT:           DC.B      'F2 - Draft mode     ',13,10
PRS232:           DC.B      'F3 - RS-232 port    ',13,10
PCENTRON:         DC.B      'F3 - Centronics port',13,10
POTEXT:           DC.B      '  PRINT AND PRINT-OPTIONS     F9 - Print'
                  DC.B      ' block, F10 - Print all, UNDO - Exit',13,10,0
                  DC.B      0 
LPPTEXT:          DC.B      'Number of lines per page       : ' 
LPPX:             DC.B      '0000           ' 
PTTYPE:           DC.B      'F1 - Epson printer  ',13,10,0
                  DC.B      0 
BLKPRINT1:        DC.B      'NUMBER OF PAGES MARKED BY BLOCK: ' 
BLKNOPAGES:       DC.B      '0000           ' 
PTMODE:           DC.B      'F2 - Draft mode     ',13,10,0
                  DC.B      0 
ALLPRINT1:        DC.B      'NUMBER OF PAGES IN WHOLE TEXT  : ' 
ALLNOPAGES:       DC.B      '0000           ' 
PTPORT:           DC.B      'F3 - Centronics port',13,10,0
                  DC.B      0 
ENDSPACES:        DC.B      '                                        '
                  DC.B      '                                        '
                  DC.B      13,10 
FONT:             DC.B      0 
                  DC.B      24,'<',24,24,'<ÿç',1,'~',24,24,'ðð',5,' |',6,'||Æ|||||',0 
                  DC.B      'x',7,'ð',17,4,0
                  DC.B      24,'f',0
                  DC.B      24,0
                  DC.B      '8',24,14,'p',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      2,'<',24,'<~',12,'~<~<<',0
                  DC.B      0 
                  DC.B      6,0 
                  DC.B      '`<<',24,'|<x~~>f<',6,'f`Æf<|<|<~ffÆff~',30,'@x',16,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '`',0 
                  DC.B      6,0 
                  DC.B      28,0
                  DC.B      '`',24,24,'`8',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      14,24,'p',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'f',12,24,'f0',24,0 
                  DC.B      24,'f0f',24,'`f',24,12,0
                  DC.B      '?',24,'f0',24,'0fff',24,28,'f',28,30,12,12,12,12,'44',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'ÆÆ',0
                  DC.B      27,'Ø44',2,0
                  DC.B      0 
                  DC.B      127,'044f',12,0 
                  DC.B      'z~~ñfö',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '`',0 
                  DC.B      0 
                  DC.B      '`',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      14,0
                  DC.B      'f',0 
                  DC.B      28,0
                  DC.B      0 
                  DC.B      'þ',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '<',0 
                  DC.B      0 
                  DC.B      28,12,0 
                  DC.B      '><',0
                  DC.B      24,'0',12,0 
                  DC.B      24,24,0 
                  DC.B      '88',0
                  DC.B      0 
                  DC.B      '88x',0 
                  DC.B      0 
                  DC.B      '<$',28,'8™ÿÃ',3,'Ã<',28,'ÀÀ',5,' Æ',6,6,6,'ÆÀÀ',6,'ÆÆ',0 
                  DC.B      '`',15,'ø',11,'(',0 
                  DC.B      24,'fl>fl',24,28,'8f',24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      6,'f8f',12,28,'``',6,'ff',24,24,12,0
                  DC.B      '0ff<ffl```f',24,6,'l`îvfffff',24,'ffÆff',6,24,'`',24,'8',0 
                  DC.B      'À',0 
                  DC.B      '`',0 
                  DC.B      6,0 
                  DC.B      '0',0 
                  DC.B      '`',0 
                  DC.B      0 
                  DC.B      '`',24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,24,24,'`',24,'<',0 
                  DC.B      24,'f',0
                  DC.B      24,24,0 
                  DC.B      'f',0 
                  DC.B      24,0
                  DC.B      'f0',0
                  DC.B      0 
                  DC.B      24,0
                  DC.B      'xf',0
                  DC.B      24,'f',24,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,':f60',24,24,24,24,'XX<<',24,0 
                  DC.B      0 
                  DC.B      'ÌÌ',24,'6lXX<',2,0 
                  DC.B      'Ø',24,'XX',0 
                  DC.B      24,16,'ÊÃÃ[',0
                  DC.B      'ff|',30,'~|',28,30,'~n<>~l',28,'>6~f>xÖ|',28,'>þ~6',27,16,'÷',0
                  DC.B      '6þ',0
                  DC.B      'f',30,0
                  DC.B      0 
                  DC.B      24,'<<6',24,16,'pf~',24,24,24,14,24,24,'2l|',0
                  DC.B      0 
                  DC.B      'll',12,'þ',0 
                  DC.B      'f$öoÃþ™',6,'Ó<',22,'þß',5,' Æ',6,6,6,'ÆÀÀ',6,'ÆÆ<x',31,'ì',13,'Ø',0
                  DC.B      24,'fþ`l8',24,24,24,'<',24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      12,'n',24,6,24,'<|`',12,'ff',24,24,24,'~',24,6,'nff`f```f',24,6,'x' 
L00D8:            BRA.B     L00D8 
                  DC.B      '~ffff`',24,'ffÆ<f',12,24,'0',24,'l',0
                  DC.B      '`<|<><|>|8',24,'f',24,'ì|<|>|>~ffÆff~',24,24,24,'ò',24,'f',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '<',0 
                  DC.B      0 
                  DC.B      '<',0 
                  DC.B      '<',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,24,'~~Ø',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'f<f<0<f|',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      6,'f',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'ØØ',0
                  DC.B      'l6',0
                  DC.B      0 
                  DC.B      'f<~Ø',0
                  DC.B      0 
                  DC.B      '<',0 
                  DC.B      '08Ê½½_æfv',12,6,12,6,12,12,'6f',12,6,6,'>',12,'66ff',6,12,'Öl',12,6,'ff6<8™vf' 
                  DC.B      'fþ08l~<ffx8|`f',0
                  DC.B      '~',12,'0',27,24,0
                  DC.B      'L88',0 
                  DC.B      15,'l',24,'8',0 
                  DC.B      0 
                  DC.B      'ÃçƒÁçü<ŒÓ<',16,'ØÛ',13,'°',0 
                  DC.B      0 
                  DC.B      '|||||',0 
                  DC.B      '||',6,'`',24,4,6,'(',0 
                  DC.B      24,0
                  DC.B      'l<',24,'p',0 
                  DC.B      24,24,'ÿ~',0
                  DC.B      '~',0 
                  DC.B      24,'v',24,12,12,'l',6,'|',24,'<>',0 
                  DC.B      0 
                  DC.B      '0',0 
                  DC.B      12,12,'jf|`f||n~',24,6,'p`Ö~f|f|<',24,'ffÖ',24,'<',24,24,24,24,'Æ',0
                  DC.B      '0',6,'f`ff0ff',24,24,'l',24,'þfffff`',24,'ffÆ<f',12,'0',24,12,'ž4`f<<',6,'<<`' 
                  DC.B      '<f<888<<`',27,'Þ<<<fffff`|',24,'|0<8<f|f>f',24,'>|66',24,'Ø',27
                  DC.B      '<<nnÛÞ',24,24,'f',0
                  DC.B      0 
                  DC.B      16,'Ê±¥Uff<',12,14,12,'f',12,6,'6f',12,6,6,'f',12,'66v<6',12,'Öl',12,6,'fv',28,'fl™Ü|b' 
                  DC.B      'l',24,'ll',24,'f~fÜTÖ~f~',24,24,24,27,24,'~',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,'l0',12,0
                  DC.B      0 
                  DC.B      'çÃƒÁÃù™ØÛ~',16,'Þÿ',13,'°Æ',6,'À',6,6,6,'Æ',6,'Æ',6,'~~',24,4,7,'Ð',0
                  DC.B      24,0
                  DC.B      'l',6,'0Þ',0
                  DC.B      24,24,'<',24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      '0f',24,24,6,'~',6,'f0f',6,24,24,24,0 
                  DC.B      24,24,'n~f`f``ff',24,6,'x`Ænf`vl',6,24,'ffþ<',24,'0',24,12,24,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '>f`f~0ff',24,24,'x',24,'Öffff`<',24,'ffÖ',24,'f',24,24,24,24,12,'4ff~',6,'>',6,6,'`~'
                  DC.B      '~~',24,24,24,'ff|',127,'øffffffff`0<f0',6,24,'fffvff00',12,'kn',24,'l6',6
                  DC.B      'fvvßØ<<f',0
                  DC.B      0 
                  DC.B      16,'z±¹Qffn',12,30,12,'f',12,6,'6f',0 
                  DC.B      6,6,'f',12,'66',6,14,'6',12,'Öl',12,6,'f',6,12,'fÆïÈf`l0ll',24,'fffÌTÖ`f',0 
                  DC.B      24,'0',12,24,'Ø',0
                  DC.B      '2',0 
                  DC.B      0 
                  DC.B      24,'Øl|x',0 
                  DC.B      0 
                  DC.B      '$föo™óÃpÃ',16,'p',24,30,25,'˜Æ',6,'À',6,6,6,'Æ',6,'Æ',6,'f',24,16,4,'.',16,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'þ|fÌ',0
                  DC.B      28,'8f',24,'0',0
                  DC.B      24,'`f',24,'0f',12,'ff0f',12,24,24,12,'~0',0
                  DC.B      '`fffl``ff',24,'fl`Æff`lff',24,'f<îf',24,'`',24,6,24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      'ff`f`0>f',24,24,'l',24,'Æffff`',6,24,'f<|<>0',24,24,24,0 
                  DC.B      'b<f`~f~~<```',24,24,24,'~~`ØØfffff>ff<0',24,'f0~',24,'fffn>' 
                  DC.B      '<`0',12,'ÃÖ',24,'6l~fffØØfff',0
                  DC.B      0 
                  DC.B      16,10,'½­',0
                  DC.B      'ööf~6',12,'f',12,6,'6~',0
                  DC.B      '>',14,'n<',28,'~~~4',12,'þì',12,6,'~',6,12,'<‚fÜf`lfll',24,'<f$ì8Öpf~',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,'Ø',24,'L',0 
                  DC.B      0 
                  DC.B      24,'p',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '$<',28,'8<çç Ã8ð',24,27,'yž|',6,'||',6,'||',6,'||<',30,30,'<9à',0
                  DC.B      24,0
                  DC.B      'l',24,'Fv',0 
                  DC.B      14,'p',0
                  DC.B      0 
                  DC.B      '0',0 
                  DC.B      24,'@<~~<',12,'<<0<8',0 
                  DC.B      '0',6,0 
                  DC.B      '`',24,'>f|<x~`>f<<f~Æf<`6f<',24,'>',24,'Æf',24,'~',30,2,'x',0
                  DC.B      'þ',0 
                  DC.B      '>|<><0',6,'f<',24,'f<Æf<|>`|',14,'>',24,'lf',6,'~',14,24,'p',0 
                  DC.B      '~',8,'><>>>>',8,'<<<<<<ff~~ß<<<>>',6,'<>',24,'~',24,'|`><<>ff',0 
                  DC.B      0 
                  DC.B      'f0',12,'†Ÿ',24,27,'Ø><<<~',127,'~~f',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      10,'ÃÃ',0 
                  DC.B      6,6,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '0',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      12,6,0
                  DC.B      6,12,'Ø',0
                  DC.B      0 
                  DC.B      'v|`lþ8',127,24,24,'<fx0|>f',0
                  DC.B      '~~~',24,'p',24,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '0',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '<',24,24,24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '~',16,'`',0
                  DC.B      0 
                  DC.B      'qŽ',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      23,'T8',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '`',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '|',0 
                  DC.B      0 
                  DC.B      'p',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '`',6,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '|',0 
                  DC.B      0 
                  DC.B      24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      '8',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '|',0 
                  DC.B      0 
                  DC.B      24,0
                  DC.B      0 
                  DC.B      '`',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '<<<',0 
                  DC.B      0 
                  DC.B      15,6,24,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '@@',0
                  DC.B      0 
                  DC.B      'ff<',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      10,'~~',0 
                  DC.B      28,28,0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'p',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '`øH',0 
                  DC.B      0 
                  DC.B      'À',16,'<',0
                  DC.B      0 
                  DC.B      0 
                  DC.B      '`',16,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      24,0
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      'System font',0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      0 
LINESPP:          DC.B      0 
                  DC.B      0 
                  DC.B      0 
                  DC.B      '@' 
SELECTFILE:       DC.B      0 
                  DC.B      0 
SEL1:             DC.B      'THESE DOCS GIVE ME PURE XTC:      PIC-SWITCH',13,10,0
                  DC.B      0 
SEL2:             DC.B      '                                  MEGA DEPACK ',13,10,0
                  DC.B      0 
SEL3:             DC.B      '                                   ',13,10,0 
SEL4:             DC.B      '                                   ',13,10,0 
SEL5:             DC.B      '                                   ',13,10,0 
SEL6:             DC.B      '                                   ',13,10,0 
SEL7:             DC.B      '                                   ',13,10,0 
SEL8:             DC.B      '                                   ',13,10,0 
SEL9:             DC.B      '                                   ',13,10,0 
SEL10:            DC.B      '                              ',13,10,0
                  DC.B      0 
FIL1:             DC.B      'a:\PICSW.101\PICSW101.DOC',0 
FIL2:             DC.B      'a:\MEGA_DPK.212\MEGA.TXT',0
                  DC.B      0 
FIL3:             DC.B      'a:\CHAPTER3.DD',0
                  DC.B      0 
FIL4:             DC.B      'a:\CHAPTER2.DD',0
                  DC.B      0 
FIL5:             DC.B      'a:\CHAPTER5.DD',0
                  DC.B      0 
FIL6:             DC.B      'a:\CHAPTER5.DD',0
                  DC.B      0 
FIL7:             DC.B      'a:\CHAPTER2.DD',0
                  DC.B      0 
FIL8:             DC.B      'a:\CHAPTER2.DD',0
                  DC.B      0 
FIL9:             DC.B      'a:\CHAPTER2.DD',0
                  DC.B      0 
FIL10:            DC.B      'a:\CHAPTER5.DD',0
                  DC.B      0 
FILETAB:          DC.L      SEL1
                  DC.L      FIL1
                  DC.L      SEL2
                  DC.L      FIL2
                  DC.L      SEL3
                  DC.L      FIL3
                  DC.L      SEL4
                  DC.L      FIL4
                  DC.L      SEL5
                  DC.L      FIL5
                  DC.L      SEL6
                  DC.L      FIL6
                  DC.L      SEL7
                  DC.L      FIL7
                  DC.L      SEL8
                  DC.L      FIL8
                  DC.L      SEL9
                  DC.L      FIL9
                  DC.L      SEL10 
                  DC.L      FIL10 
PCONFIG:          DC.B      0 
                  DC.B      4 
HLINESF1:         DC.B      0 
                  DC.B      10,0
                  DC.B      5,2,'u',0 
                  DC.B      5,0 
                  DC.B      10,0
                  DC.B      19,2,'u',0
                  DC.B      19,0
                  DC.B      10,0
                  DC.B      '#',2,'u',0 
                  DC.B      '#',0 
                  DC.B      10,0
                  DC.B      '–',2,'u',0 
                  DC.B      '–',0 
                  DC.B      10,0
                  DC.B      5,0 
                  DC.B      10,0
                  DC.B      '–',2,'u',0 
                  DC.B      5,2,'u',0 
                  DC.B      '–',1,'@',0 
                  DC.B      19,1,'@',0
                  DC.B      '–ÿÿÿÿÿÿÿÿ' 
HLINESF2:         DC.B      0 
                  DC.B      10,0
                  DC.B      5,2,'u',0 
                  DC.B      5,0 
                  DC.B      10,0
                  DC.B      19,2,'u',0
                  DC.B      19,0
                  DC.B      10,0
                  DC.B      '#',2,'u',0 
                  DC.B      '#',0 
                  DC.B      10,0
                  DC.B      '²',2,'u',0 
                  DC.B      '²',0 
                  DC.B      10,0
                  DC.B      'T',2,'u',0 
                  DC.B      'T',0 
                  DC.B      10,0
                  DC.B      'd',2,'u',0 
                  DC.B      'd',0 
                  DC.B      10,0
                  DC.B      5,0 
                  DC.B      10,0
                  DC.B      '²',2,'u',0 
                  DC.B      5,2,'u',0 
                  DC.B      '²',1,'@',0 
                  DC.B      19,1,'@',0
                  DC.B      'T',1,'@',0 
                  DC.B      'd',1,'@',0 
                  DC.B      '²ÿÿÿÿÿÿÿÿ' 
 BSS
                  DS.L      1 
LINES:            DS.W      1 
PAGESDONE:        DS.W      1 
HANDLE:           DS.W      1 
EOF:              DS.W      1 
SCRADD:           DS.L      1 
OLDREZ:           DS.W      1 
OLDCOLOURS:       DS.B      32
STCOLOURS:        DS.B      32
OLDSTACK:         DS.L      1 
MARKSTART:        DS.L      1 
MARKEND:          DS.B      6 
MARKER1:          DS.L      1 
MARKER2:          DS.L      1 
MARKER3:          DS.L      1 
MARKER1LINE:      DS.L      1 
MARKER2LINE:      DS.L      1 
MARKER3LINE:      DS.L      1 
TEXTPOS:          DS.L      1 
LINENO1:          DS.W      1 
LINENO2:          DS.W      1 
BOTTOMNO:         DS.W      1 
BOTTOM1:          DS.L      1 
SCREENPOS:        DS.L      1 
LINEBUFFER:       DS.B      1280
FILEEND:          DS.L      1 
TEXTFILE:         DS.B      25000 
ZUEND: END
