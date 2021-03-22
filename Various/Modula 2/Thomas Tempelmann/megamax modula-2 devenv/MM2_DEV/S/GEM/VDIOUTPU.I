IMPLEMENTATION MODULE VDIOutputs;
(*$L-, N+, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die VDI Ausgabefunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  31.10.87
 *
 *  Version   2.2     V#0023
 *)
 
(*  22.01.88 TT         | PolyLine: TST (A3)+ -> TST -(A3)
 *  ???????? TT  V2.1   | REF-Parm.
 *  02.04.90 MCH V2.2   | Anpassung an public arrays
 *  26.03.91 TT         | PolyMarker: TST (A3)+ -> TST -(A3)
 *)


FROM    SYSTEM          IMPORT ASSEMBLER;

FROM    GrafBase        IMPORT Point, Rectangle, WritingMode;
 
IMPORT  MOSGlobals,GEMShare;

FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)
 
 
PROCEDURE PolyLine(handle:DeviceHandle;REF pts:ARRAY OF Point;NoLines:CARDINAL);

BEGIN
  ASSEMBLER
        JSR     testErrorCheck
        MOVE.W  -(A3),D1                ; last -> d1
        MOVE.W  -(A3),D0                ; HIGH(pts) -> d0
        TST.W   D1
        BEQ     cont
        CMP.W   D1,D0
        BCS     cont
        MOVE.W  D1,D0
cont
        
        MOVE.W  D0,-(A7)
        MOVE.W  D1,-(A7)
        MOVE.L  -(A3),-(A7)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        MOVE.W  (A7)+,(A3)+
        MOVE.L  (A7)+,A1
        MOVE.W  (A7)+,D1
        MOVE.W  (A7)+,D0
        TST.W   -(A3)           ; !TT 22.01.88
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.L  cb.VDIPB.ptsin(A0),-(A7); save old PTSIN addr
        MOVE.L  A1,cb.VDIPB.ptsin(A0)   ; ADR(pts) -> Param.block
        MOVE.L  A0,(A3)+                ; our_cb^ -> P.stack( fÅr vdi_call)
        MOVE.L  cb.CURDEVICE(A0),A1     ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        LEA     cb.V_CONTRL(A0),A0      ; Build up the control Array
        MOVE.W  #POLYLINE,(A0)+
        ADDQ.W  #1,D0
        MOVE.W  D0,(A0)+
        CLR.L   (A0)+
        CLR.L   (A0)
        JSR     vdi_call
        MOVE.L  our_cb,A0               ; restore old PTSIN addr
        MOVE.L  (A7)+,cb.VDIPB.ptsin(A0)
ende
  END;
END PolyLine;

(*  callPolyMG -- Macht den gesamten Aufruf fÅr die Funktionen          *
 *                PolyMarker,Polygon.                                   *
 *                In 'cmd' steht der VDI-Opcode der Funktion            *)

PROCEDURE callPolyMG(handle:DeviceHandle;REF pts:ARRAY OF Point;no:CARDINAL;
                     cmd:CARDINAL);

BEGIN
  ASSEMBLER
        JSR     testErrorCheck
        MOVE.W  -(A3),D2                ; cmd -> D2
        MOVE.W  -(A3),D1                ; no -> D1
        MOVE.W  -(A3),D0                ; HIGH(pts) -> D0
        TST.W   D1
        BEQ     useHIGH
        CMP.W   D1,D0
        BCS     useHIGH
        MOVE.W  D1,D0
        BRA     cont
useHIGH
        ADDQ.W  #1,D0
cont
        MOVE.W  D0,-(A7)
        MOVE.W  D1,-(A7)
        MOVE.W  D2,-(A7)
        MOVE.L  -(A3),-(A7)             ; ADR (pts)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        MOVE.W  (A7)+,(A3)+
        MOVE.L  (A7)+,A1
        MOVE.W  (A7)+,D2
        MOVE.W  (A7)+,D1
        MOVE.W  (A7)+,D0
        TST.W   -(A3)
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.L  cb.VDIPB.ptsin(A0),-(A7); save old PTSIN addr
        MOVE.L  A1,cb.VDIPB.ptsin(A0)   ; ADR(pts) -> Param.block
        MOVE.L  A0,(A3)+                ; our_cb^ -> P.stack( fÅr vdi_call)
        MOVE.L  cb.CURDEVICE(A0),A1     ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        LEA     cb.V_CONTRL(A0),A0      ; Build up the control Array
        MOVE.W  D2,(A0)+
        MOVE.W  D0,(A0)+
        CLR.L   (A0)+
        CLR.L   (A0)
        JSR     vdi_call
        MOVE.L  our_cb,A0               ; restore old PTSIN addr
        MOVE.L  (A7)+,cb.VDIPB.ptsin(A0)
ende
  END;
END callPolyMG;

PROCEDURE PolyMarker
(handle:DeviceHandle;REF marks:ARRAY OF Point;NoMarks:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      #POLYMARKER,(A3)+
    JSR         callPolyMG
  END;
END PolyMarker;

PROCEDURE Polygon(handle:DeviceHandle;REF pts:ARRAY OF Point;NoEdges:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      #FILLED_AREA,(A3)+
    JSR         callPolyMG
  END;
END Polygon;

PROCEDURE Line(handle:DeviceHandle;p,q:Point);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.PTSIN+$4(A0)
        MOVE.L  -(A3),pubArrays.PTSIN(A0)
        
        SUBQ.L  #2,A7           ; device handle setzen
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.L  A0,(A3)+                ; our_cb^ -> P.stack( fÅr vdi_call)
        MOVE.L  cb.CURDEVICE(A0),A1     ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        LEA     cb.V_CONTRL(A0),A0      ; Build up the control Array
        MOVE.W  #POLYLINE,(A0)+
        MOVE.W  #2,(A0)+
        CLR.L   (A0)+
        CLR.L   (A0)
        JSR     vdi_call
ende
  END;
END Line;

PROCEDURE Mark(handle:DeviceHandle;q:Point);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.PTSIN(A0)
    
        SUBQ.L  #2,A7           ; device handle setzen
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.L  A0,(A3)+                ; our_cb^ -> P.stack( fÅr vdi_call)
        MOVE.L  cb.CURDEVICE(A0),A1     ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        LEA     cb.V_CONTRL(A0),A0      ; Build up the control Array
        MOVE.W  #POLYMARKER,(A0)+
        MOVE.W  #1,(A0)+
        CLR.L   (A0)+
        CLR.L   (A0)
        JSR     vdi_call
ende
  END;
END Mark;

PROCEDURE CellArray (handle:DeviceHandle; frame:Rectangle;
                     rowLength,usedElems,noRows:CARDINAL;
                     mode:WritingMode; REF colArray:ARRAY OF CARDINAL);
BEGIN
  ASSEMBLER
        TRAP    #noErrorTrap
        DC.W    MOSGlobals.IllegalCall
  END
END CellArray;

PROCEDURE GrafText(handle:DeviceHandle;start:Point;REF text:ARRAY OF CHAR);

BEGIN
  ASSEMBLER
        MOVE.L  D4,-(A7)
        CLR.W   D4                      ; Kein Offset
        JSR     stringIntoINTIN         ; 'text' -> vINTIN
        MOVE.L  our_cb,A0
        MOVE.W  -(A3),cb.V_CONTRL.sintin(A0) ; length(text) -> ctrl-array
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.PTSIN(A0)      ; start -> ptsin(0)+(1)
        
        SUBQ.L  #2,A7           ; device handle setzen
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.W  #GRAF_TEXT,cb.V_CONTRL.opcode(A0)
        MOVE.W  #1,cb.V_CONTRL.sptsin(A0)
        MOVE.L  cb.CURDEVICE(A0),A1             ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        MOVE.L  A0,(A3)+
        JSR     vdi_call
        MOVE.L  (A7)+,D4
ende
  END;
END GrafText;

PROCEDURE ContourFill(handle:DeviceHandle;start:Point;tagColor:CARDINAL;
                      useTag:BOOLEAN);

BEGIN
  ASSEMBLER
        TST.W   -(A3)
        BNE     cont
        MOVE.W  #-1,-2(A3)
cont
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.L  -(A3),pubArrays.PTSIN(A0)
        MOVE.W  #CONTOUR_FILL,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
  END;
END ContourFill;

PROCEDURE FillRectangle(handle:DeviceHandle;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.PTSIN+8(A0),A1
    JSR         getCalcedFrame
    MOVE.W      #FILL_RECTANGLE,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END FillRectangle;


                (*  Generalized Drawing Primitives  *)
                (*  ==============================  *)

PROCEDURE Bar(handle:DeviceHandle;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.PTSIN+8(A0),A1
    JSR         getCalcedFrame
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #BAR,(A3)+
    JSR         vdi_if
  END;
END Bar;

PROCEDURE callArcPie(middle:Point;radius,beg,end:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.vINTIN(A0)
    LEA         pubArrays.PTSIN+$10(A0),A0
    CLR.W       -(A0)
    MOVE.W      -(A3),-(A0)
    CLR.L       -(A0)
    CLR.L       -(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #GRAF_STANDARD,(A3)+
  END;
END callArcPie;

PROCEDURE Arc(handle:DeviceHandle;middle:Point;radius,beg,end:CARDINAL);

BEGIN
  ASSEMBLER
    JSR         callArcPie
    MOVE.W      #ARC,(A3)+
    JSR         vdi_if
  END;
END Arc;

PROCEDURE Pie(handle:DeviceHandle;middle:Point;radius,beg,end:CARDINAL);

BEGIN
  ASSEMBLER
    JSR         callArcPie
    MOVE.W      #PIE,(A3)+
    JSR         vdi_if
  END;
END Pie;

PROCEDURE Circle(handle:DeviceHandle;middle:Point;radius:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.PTSIN+$C(A0),A0
    CLR.W       -(A0)
    MOVE.W      -(A3),-(A0)
    CLR.L       -(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #CIRCLE,(A3)+
    JSR         vdi_if
  END;
END Circle;

PROCEDURE Ellipse(handle:DeviceHandle;middle:Point;xradius,yradius:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.PTSIN+$8(A0),A0
    MOVE.L      -(A3),-(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #ELLIPSE,(A3)+
    JSR         vdi_if
  END;
END Ellipse;

PROCEDURE ElliptArc(handle:DeviceHandle;middle:Point;xradius,yradius,beg,end:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.vINTIN(A0)
    LEA         pubArrays.PTSIN+$8(A0),A0
    MOVE.L      -(A3),-(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #ELLIPTICAL_ARC,(A3)+
    JSR         vdi_if
  END;
END ElliptArc;

PROCEDURE ElliptPie(handle:DeviceHandle;middle:Point;xradius,yradius,beg,end:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.vINTIN(A0)
    LEA         pubArrays.PTSIN+$8(A0),A0
    MOVE.L      -(A3),-(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #ELLIPTICAL_PIE,(A3)+
    JSR         vdi_if
  END;
END ElliptPie;

PROCEDURE RoundRect(handle:DeviceHandle;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.PTSIN+8(A0),A1
    JSR         getCalcedFrame
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #ROUNDED_RECT,(A3)+
    JSR         vdi_if
  END;
END RoundRect;

PROCEDURE FillRoundRect(handle:DeviceHandle;frame:Rectangle);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.PTSIN+8(A0),A1
    JSR         getCalcedFrame
    MOVE.W      #GRAF_STANDARD,(A3)+
    MOVE.W      #FILL_ROUND_RECT,(A3)+
    JSR         vdi_if
  END;
END FillRoundRect;

PROCEDURE JustifiedText(handle:DeviceHandle;start:Point;length:CARDINAL;
                        wSpace,cSpace:BOOLEAN;REF str:ARRAY OF CHAR);
                        
BEGIN
  ASSEMBLER
        MOVE.L  D4,-(A7)
        
        MOVEQ   #2,D4                   ; 2 Elemente Offset
        JSR     stringIntoINTIN
        MOVE.W  -(A3),D0
        MOVE.L  pubs,A0
        MOVE.L  -(A3),pubArrays.vINTIN(A0)      ; wSp., cSp -> vINTIN(0)+(1)
        MOVE.W  -(A3),pubArrays.PTSIN+4(A0)    ; length -> ptsin(2)
        MOVE.L  -(A3),pubArrays.PTSIN(A0)      ; start -> ptsin(0)+(1)
        ADDQ.W  #2,D0
        MOVE.L  our_cb,A0
        MOVE.W  D0,cb.V_CONTRL.sintin(A0) ; strlen(in vINTIN) -> ctrl-array
        
        SUBQ.L  #2,A7           ; device handle setzen
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.W  #GRAF_STANDARD,cb.V_CONTRL.opcode(A0)
        MOVE.W  #JUST_TEXT,cb.V_CONTRL.subcmd(A0)
        MOVE.W  #2,cb.V_CONTRL.sptsin(A0)
        MOVE.L  cb.CURDEVICE(A0),A1     ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        MOVE.L  A0,(A3)+
        JSR     vdi_call
ende
        MOVE.L  (A7)+,D4
  END;
END JustifiedText;

END VDIOutputs. 
(* $00000457$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$000018C8$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5$FFF8B6E5Ä$000000EBT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000001C0$0000018D$000001A0$0000010C$000028FD$00000033$00000D66$00000896$000008F1$FFEB3024$00000918$000008F1$000009D6$00000A3A$00000AE3$000000EBêÄÉ*)
