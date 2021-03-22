IMPLEMENTATION MODULE LineA;
(*$L-, N+, Y+*)


(*  Implementierung der Line-A-Routinen fÅr MEGAMAX Modula-2
 *
 *  Autor: Manuel Chakravarty
 *
 *  Created: 7.4.1987           Version 2.1     V#0100
 *)

(*  18.08.89 MCH V2.0   | 'NegLineAVariables' def. + impl.
 *  ???????? TT  V2.1   | REF-Parm.
 *  17.02.90 TT         | A6 wird nun gerettet, weil LineA das Reg u.U. zerstîrt
 *  24.11.90 TT         | BREAK aus PutPixel entfernt!
 *)
 
 
FROM    SYSTEM          IMPORT ASSEMBLER, ADDRESS;

FROM    GrafBase        IMPORT Point, Rectangle, PtrMouseFormDef,
                               PtrMemFormDef;
 
 
CONST   opcodeBase      = $A000;
 
TYPE    lineAFunc       = (init, putPixel, getPixel, line, horLine, fillRect,
                           fillPolygon, bitBlt, textBlt, showMouse, hideMouse,
                           transMouse, undrawSprite, drawSprite, copyRaster,
                           contourFill);
                          
CONST   initCode        = opcodeBase + CARDINAL (init);
        putPixelCode    = opcodeBase + CARDINAL (putPixel);
        getPixelCode    = opcodeBase + CARDINAL (getPixel);
        lineCode        = opcodeBase + CARDINAL (line);
        horLineCode     = opcodeBase + CARDINAL (horLine);
        fillRectCode    = opcodeBase + CARDINAL (fillRect);
        fillPolygonCode = opcodeBase + CARDINAL (fillPolygon);
        bitBltCode      = opcodeBase + CARDINAL (bitBlt);
        textBltCode     = opcodeBase + CARDINAL (textBlt);
        showMouseCode   = opcodeBase + CARDINAL (showMouse);
        hideMouseCode   = opcodeBase + CARDINAL (hideMouse);
        transMouseCode  = opcodeBase + CARDINAL (transMouse);
        undrawSpriteCode= opcodeBase + CARDINAL (undrawSprite);
        drawSpriteCode  = opcodeBase + CARDINAL (drawSprite);
        copyRasterCode  = opcodeBase + CARDINAL (copyRaster);
        contourFillCode = opcodeBase + CARDINAL (contourFill);
 
VAR     jmpTable        : ARRAY lineAFunc OF ADDRESS;
        sysFontHeader   : PtrSysFontHeader;
        lineAVars       : PtrLineAVars;
        
        ImprovedCall    : BOOLEAN;
        
       
PROCEDURE SystemFonts (): PtrSysFontHeader;

  BEGIN
    ASSEMBLER
        MOVE.L  sysFontHeader,(A3)+
    END;
  END SystemFonts;

PROCEDURE LineAVariables (): PtrLineAVars;

  BEGIN
    ASSEMBLER
        MOVE.L  lineAVars,(A3)+
    END;
  END LineAVariables;

PROCEDURE NegLineAVariables (): PtrNegLineAVars;

  BEGIN
    ASSEMBLER
        MOVE.L  lineAVars, D0
        SUBI.L  #$2E, D0
        MOVE.L  D0, (A3)+
    END;
  END NegLineAVariables;


(* Normaller Aufruf 117 microsec, 'ImprovedCall' 86 microsec *)
PROCEDURE PutPixel(p:Point;color:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        LEA     -6(A3),A1
        MOVE.L  A1,LineAVars.ptsin(A0)
        ADDQ.L  #4,A1
        MOVE.L  A1,LineAVars.intin(A0)
        TST.W   ImprovedCall
        BNE     improved
        MOVE.L  A6, -(A7)
        DC.W    putPixelCode
        MOVE.L  (A7)+, A6
        BRA     ready
improved
        MOVE.L  jmpTable,A0
        MOVE.W  #putPixel,D0
        LSL.W   #2,D0
        ADDA.W  D0,A0
        MOVE.L  (A0),A0
        JSR     (A0)
ready
        SUBQ.L  #6,A3
  END;
END PutPixel;

PROCEDURE PixelColor(p:Point):CARDINAL;

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        LEA     -4(A3),A1
        MOVE.L  A1,LineAVars.ptsin(A0)
        TST.W   ImprovedCall
        BNE     improved
        MOVE.L  A6, -(A7)
        DC.W    getPixelCode
        MOVE.L  (A7)+, A6
        BRA     ready
improved
        MOVE.L  jmpTable,A0
        MOVE.W  #getPixel,D0
        LSL.W   #2,D0
        ADDA.W  D0,A0
        MOVE.L  (A0),A0
        JSR     (A0)
ready
        SUBQ.L  #2,A3
        MOVE.W  D0,-2(A3)
  END;
END PixelColor;

PROCEDURE Line(p,q:Point);

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.L  -(A3),LineAVars.q.x(A0)
        MOVE.L  -(A3),LineAVars.p.x(A0)
        MOVE.L  A6, -(A7)
        DC.W    lineCode
        MOVE.L  (A7)+, A6
  END;
END Line;

PROCEDURE HorizontalLine(x1,x2,y:INTEGER);

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.W  -(A3),LineAVars.p.y(A0)
        MOVE.W  -(A3),LineAVars.q.x(A0)
        MOVE.W  -(A3),LineAVars.p.x(A0)
        MOVE.L  A6, -(A7)
        DC.W    horLineCode
        MOVE.L  (A7)+, A6
  END;
END HorizontalLine;

PROCEDURE FilledRectangle(p,q:Point);
 
BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.L  -(A3),LineAVars.q.x(A0)
        MOVE.L  -(A3),LineAVars.p.x(A0)
        MOVE.L  A6, -(A7)
        DC.W    fillRectCode
        MOVE.L  (A7)+, A6
  END;
END FilledRectangle;
 
PROCEDURE FilledPolygon(REF pts:ARRAY OF Point;noPts:CARDINAL;y:INTEGER);
 
BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.W  -(A3),LineAVars.p.y(A0)
        CLR.L   D0
        MOVE.W  -(A3),D0
        MOVE.W  -(A3),D1
        TST.W   D0
        BEQ     takeHIGH
        CMP.W   D0,D1
        BCC     takeNoPts
takeHIGH
        MOVE.W  D1,D0
takeNoPts
        MOVE.L  D0,-(A7)
        MOVE.L  A7,LineAVars.contrl(A0)
        MOVE.L  -(A3),LineAVars.ptsin(A0)
        MOVE.L  A6, -(A7)
        DC.W    fillPolygonCode
        MOVE.L  (A7)+, A6
        ADDQ.L  #4,A7
  END;
END FilledPolygon;
 
PROCEDURE BitBlockTransfer(deskriptor:PtrBBTDeskriptor);

BEGIN
  ASSEMBLER
        MOVE.L  A6,-(A7)
        
        MOVE.L  -(A3),A0
        MOVE.L  A0,A6
        MOVE.L  A6, -(A7)
        DC.W    bitBltCode
        MOVE.L  (A7)+, A6
        
        MOVE.L  (A7)+,A6
  END;
END BitBlockTransfer;

PROCEDURE TextBlockTransfer(font:PtrFontHeader;ch:CHAR;spot:Point);

CONST   horOffFlag      = 1;

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.L  -(A3),LineAVars.dest(A0) ; 'spot' -> dest
        SUBQ.L  #1,A3
        CLR.W   D0
        MOVE.B  -(A3),D0                ; 'ch' -> D0
        MOVE.L  -(A3),A1                ; 'font' -> A1
        MOVE.L  FontHeader.charOffsetTab(A1),A2
        
        CMP.W   FontHeader.maxADE(A1),D0 ; Bereichscheck
        BHI.W   err
        SUB.W   FontHeader.minADE(A1),D0 ; und Indexberechnung
        BCS.W   err
        ADD.W   D0,D0
        
        BTST    #horOffFlag,FontHeader.flags(A1)
        BEQ     noHorOff
        MOVE.W  LineAVars.dest.x(A0),D1
        SUB.W   0(A2,D0.W),D1
        MOVE.W  D1,LineAVars.dest.x(A0)
noHorOff

        MOVE.W  0(A2,D0.W),D1           ; source Berechnung
        MOVE.W  D1,LineAVars.source.x(A0)
        CLR.W   LineAVars.source.y(A0)
        ADDQ.W  #2,D0
        MOVE.W  0(A2,D0.W),D0
        SUB.W   D1,D0
        MOVE.W  D0,LineAVars.width(A0)
        MOVE.W  FontHeader.formHeight(A1),LineAVars.height(A0)
        
        MOVE.L  FontHeader.fontData(A1),LineAVars.formBase(A0)
        MOVE.W  FontHeader.formWidth(A1),LineAVars.formWidth(A0)
        MOVE.W  FontHeader.leftOffset(A1),LineAVars.leftOff(A0)
        MOVE.W  FontHeader.rightOffset(A1),LineAVars.rightOff(A0)
        MOVE.W  FontHeader.lightMask(A1),LineAVars.lightMask(A0)
        MOVE.W  FontHeader.skewMask(A1),LineAVars.skewMask(A0)
        MOVE.W  FontHeader.thickening(A1),LineAVars.weight(A0)
  
        MOVE.L  A6, -(A7)
        DC.W    textBltCode
        MOVE.L  (A7)+, A6
err
  END;
END TextBlockTransfer;

PROCEDURE ShowMouse(force:BOOLEAN);

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.L  #1,-(A7)
        CLR.L   -(A7)
        MOVE.L  A7,LineAVars.contrl(A0)
        MOVE.W  -(A3),D0
        EORI.W  #1,D0
        MOVE.W  D0,-(A7)
        MOVE.L  A7,LineAVars.intin(A0)
        
        MOVE.L  A6, -(A7)
        DC.W    showMouseCode
        MOVE.L  (A7)+, A6
        ADDA.W  #10,A7
  END;
END ShowMouse;

PROCEDURE HideMouse;

BEGIN
  ASSEMBLER
        MOVE.L  A6, -(A7)
        DC.W    hideMouseCode
        MOVE.L  (A7)+, A6
  END;
END HideMouse;

PROCEDURE TransformMouse(newForm:PtrMouseFormDef);
 
BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.L  #37,-(A7)
        CLR.L   -(A7)
        MOVE.L  A7,LineAVars.contrl(A0)
        MOVE.L  -(A3),LineAVars.intin(A0)
        
        MOVE.L  A6, -(A7)
        DC.W    transMouseCode
        MOVE.L  (A7)+, A6
        ADDQ.L  #8,A7
  END;
END TransformMouse;
 
PROCEDURE UndrawSprite(buffer:PtrSpriteBuffer);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),A2
        MOVE.L  A6, -(A7)
        DC.W    undrawSpriteCode
        MOVE.L  (A7)+, A6
  END;
END UndrawSprite;

PROCEDURE DrawSprite(hotSpot:Point;sprite:PtrSpriteDef;buffer:PtrSpriteBuffer);
 
BEGIN
  ASSEMBLER
        MOVE.L  -(A3),A2
        MOVE.L  -(A3),A0
        MOVE.W  -(A3),D1
        MOVE.W  -(A3),D0
        MOVE.L  A6, -(A7)
        DC.W    drawSpriteCode
        MOVE.L  (A7)+, A6
  END;
END DrawSprite;

PROCEDURE CopyRasterForm (sourceMem,destMem:PtrMemFormDef;
                          sourceStart,sourceEnd, destStart,destEnd:Point;
                          mode:RasterMode; setCol,unsetCol:CARDINAL);
                         
BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        MOVE.L  -(A3),-(A7)
        MOVE.W  -(A3),-(A7)
        MOVE.L  A7,lineAVars.intin(A0)
        LEA     -16(A3),A1
        MOVE.L  A1,lineAVars.ptsin(A0)
        MOVE.L  -4(A1),-(A7)
        MOVE.L  -8(A1),-(A7)
        CLR.L   -(A7)
        CLR.L   -(A7)
        CLR.L   -(A7)
        CLR.W   -(A7)
        MOVE.L  A7,lineAVars.contrl(A0)
        
        MOVE.L  A6, -(A7)
        DC.W    copyRasterCode
        MOVE.L  (A7)+, A6
        ADDA.W  #28,A7
        SUBA.W  #24,A3
  END;
END CopyRasterForm;
 
PROCEDURE ContourFill (p:Point; color:CARDINAL; useColor:BOOLEAN);

BEGIN
  ASSEMBLER
        MOVE.L  lineAVars,A0
        TST.W   -(A3)
        BNE     cont
        MOVE.W  #-1,-2(A3)
cont
        LEA     -6(A3),A1
        MOVE.L  A1,LineAVars.ptsin(A0)
        ADDQ.L  #4,A1
        MOVE.L  A1,LineAVars.intin(A0)
        
        MOVE.L  A6, -(A7)
        DC.W    contourFillCode
        MOVE.L  (A7)+, A6
        SUBQ.L  #6,A3
  END;
END ContourFill;
 
 

BEGIN
  ASSEMBLER
        MOVE.L  A6, -(A7)
        DC.W    initCode                ; Initialisierung der Line-A-Routinen
        MOVE.L  (A7)+, A6
        MOVE.L  D0,lineAVars
        MOVE.L  A1,sysFontHeader
        MOVE.L  A2,jmpTable
        
        CLR.W   ImprovedCall            ; Variablen initalisieren
  END;
END LineA.
 
(* $FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$000008B6$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843$FFFB0843Ä$000001C0T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00001EB4$00001F61$000020D0$000021BA$000022FD$00002600$000027FA$0000002B$00000AE4$0000018B$0000019A$000001C0$00001289$000014F2$0000161F$00001D00∞ÄÅ*)
