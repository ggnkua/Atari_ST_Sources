IMPLEMENTATION MODULE VDIAttributes;
(*$L-, N+, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die VDI Attributfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version   2.2     V#0032
 *)
 
(*  04.11.87    | šbernahme aus 'GEMBase' und 'GEMExt'
 *  01.02.90    | Anpassung auf Compilerversion 4.0 (SET's verdreht)
 *  13.02.90    | 'SetAbsTHeight' setzt 'errNum' korrekt
 *  02.04.90    | Anpassung auf public arrays
 *  25.02.91 TT | "error"-Setzung ber occured-Funktion
 *  09.04.91 TT | SetAbsTHeight/SetPtsTHeight: Return-Parms vertauscht
 *  01.08.91 TT | DefUserFill geht nun (enthielt gleich zwei Fehler).
 *  22.05.93 TT | SetAbsTHeight/SetPtsTHeight: keine GemError-Abfrage mehr
 *)
 
 
FROM    SYSTEM          IMPORT ASSEMBLER, WORD;

FROM    GrafBase        IMPORT WritingMode;
 
FROM    GEMGlobals      IMPORT LineType, MarkerType, FillType, TEffectSet,
                               LineEnding, THorJust, TVertJust;
 
IMPORT  GEMShare;
 
FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)
 
 
PROCEDURE SetWritingMode(handle:DeviceHandle;mode:WritingMode);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    ADDQ.W      #1,D0
    MOVE.L      pubs,A0
    MOVE.W      D0,pubArrays.vINTIN(A0)
    MOVE.W      #SET_WRITING_MODE,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    JSR         testINTOUT0
  END;
END SetWritingMode;

PROCEDURE DefineColor(handle:DeviceHandle;color,red,green,blue:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    LEA         pubArrays.vINTIN+8(A0),A0
    MOVE.L      -(A3),-(A0)
    MOVE.L      -(A3),-(A0)
    MOVE.W      #SET_COLOR_REP,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END DefineColor;


                (*  Line Attributs  *)
                (*  ==============  *)

PROCEDURE SetLineWidth(handle:DeviceHandle;width:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      -(A3),D0
    MOVE.W      D0,pubArrays.PTSIN(A0)
    CLR.W       pubArrays.PTSIN+2(A0)
    MOVE.W      D0,-(A7)
    MOVE.W      #SET_LINE_WIDTH,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.W      (A7)+,D0
    MOVE.L      pubs,A0
    CMP.W       pubArrays.PTSOUT(A0),D0
    BEQ         cont            ; error:=(PTSOUT[0]#width)
    JSR         gemErrorOccured
cont
  END;
END SetLineWidth;

PROCEDURE SetLineEndings(handle:DeviceHandle;begin,end:LineEnding);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.vINTIN(A0)
    MOVE.W      #SET_LINE_END,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END SetLineEndings;

PROCEDURE DefUserLine(handle:DeviceHandle;pattern:WORD);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      -(A3),pubArrays.vINTIN(A0)
    MOVE.W      #SET_LINE_USER,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END DefUserLine;

PROCEDURE SetLineColor(handle:DeviceHandle;color:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_LINE_COLOR,D1
    JSR         setINT0attribut
  END;
END SetLineColor;

PROCEDURE SetLineType(handle:DeviceHandle;type:LineType);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    ADDQ.W      #1,D0
    MOVE.W      #SET_LINE_TYPE,D1
    JSR         setINT0attribut
  END;
END SetLineType;


                (*  Marker Attributs  *)
                (*  ================  *)

PROCEDURE SetMarkerHeight(handle:DeviceHandle;height:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      -(A3),D0
    MOVE.W      D0,pubArrays.PTSIN+2(A0)
    CLR.W       pubArrays.PTSIN(A0)
    MOVE.W      D0,-(A7)
    MOVE.W      #SET_MARKER_HEIGHT,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.W      (A7)+,D0
    MOVE.L      pubs,A0
    CMP.W       pubArrays.PTSOUT+2(A0),D0
    BEQ         cont            ; error:=(PTSOUT[1]#height)
    JSR         gemErrorOccured
cont
  END;
END SetMarkerHeight;

PROCEDURE SetMarkerColor(handle:DeviceHandle;color:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_MARKER_COLOR,D1
    JSR         setINT0attribut
  END;
END SetMarkerColor;

PROCEDURE SetMarkerType(handle:DeviceHandle;type:MarkerType);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    ADDQ.W      #1,D0
    MOVE.W      #SET_MARKER_TYPE,D1
    JSR         setINT0attribut
  END;
END SetMarkerType;

                (*  Text Attributs  *)
                (*  ==============  *)

PROCEDURE SetPtsTHeight (handle:DeviceHandle; height:CARDINAL;
                         VAR charW,charH,cellW,cellH:CARDINAL);
                         
BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        
        MOVE.W  -(A3),D0
        MOVE.W  #SET_TEXT_HEIGHT_PTS,D1
        
        MOVE.L      pubs,A0
        MOVE.W      D0,pubArrays.vINTIN(A0)
        MOVE.W      D1,(A3)+
        CLR.W       (A3)+
        JSR         vdi_if
        
        MOVE.L  pubs,A0
        LEA     pubArrays.PTSOUT(A0),A0
        MOVEQ   #3,D0
loop
        MOVE.L  (A7)+,A1
        MOVE.W  (A0)+,(A1)
        DBF     D0,loop
  END;
END SetPtsTHeight;

PROCEDURE SetTBaseLine(handle:DeviceHandle;angle:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_TEXT_BASELINE,D1
    JSR         setINT0attribut
  END;
END SetTBaseLine;

PROCEDURE SetTextFace(handle:DeviceHandle;font:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_TEXT_FACE,D1
    JSR         setINT0attribut
  END;
END SetTextFace;

PROCEDURE SetTAlignment(handle:DeviceHandle;hor:THorJust;vert:TVertJust);

BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),D0
    MOVE.L      D0,pubArrays.vINTIN(A0)
    MOVE.L      D0,-(A7)
    MOVE.W      #SET_TEXT_ALIG,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.L      (A7)+,D0
    MOVE.L      pubs,A0
    CMP.L       pubArrays.vINTOUT(A0),D0
    BEQ         cont            ; error:=(vINTOUT[0]#hor)&(vINTOUT[1]#vert)
    JSR         gemErrorOccured
cont
  END;
END SetTAlignment;

PROCEDURE SetAbsTHeight (handle:DeviceHandle; height:CARDINAL;
                         VAR charW,charH,cellW,cellH:CARDINAL);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        
        MOVE.L  pubs,A0
        MOVE.W  -(A3),D0
        MOVE.W  D0,pubArrays.PTSIN+2(A0)
        CLR.W   pubArrays.PTSIN(A0)
        
        MOVE.W  D0,-(A7)
        MOVE.W  #SET_TEXT_HEIGHT_ABS,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.W  (A7)+,D0
        
        MOVE.L  pubs,A0
        (*
          CMP.W   pubArrays.PTSOUT+2(A0),D0
          BEQ     cont            ; error:=(PTSOUT[1]#height)
          JSR     gemErrorOccured
          MOVE.W  pubArrays.PTSOUT+2(A0), errNum
cont    *)
  
        LEA     pubArrays.PTSOUT(A0),A0
        MOVEQ   #3,D0
loop
        MOVE.L  (A7)+,A1
        MOVE.W  (A0)+,(A1)
        DBF     D0,loop
  END;
END SetAbsTHeight;

PROCEDURE SetTextColor(handle:DeviceHandle;color:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_TEXT_COLOR,D1
    JSR         setINT0attribut
  END;
END SetTextColor;

PROCEDURE SetTextEffects(handle:DeviceHandle;effects:TEffectSet);

BEGIN
  ASSEMBLER
        MOVEQ   #0,D0
        SUBQ.L  #1, A3
        MOVE.B  -(A3), D0
        MOVE.W  #SET_TEXT_EFFECT,D1
        JSR     setINT0attribut
  END;
END SetTextEffects;


                (*  Fill Attributs  *)
                (*  ==============  *)

PROCEDURE DefUserFill(handle:DeviceHandle;pattern:PtrFillPattern);

BEGIN
  ASSEMBLER
        MOVE.L  -(A3),A1                ; VAR pattern -> A1
        
        MOVE.L  A1,-(A7)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice       ; (handle, VAR success)
        TST.W   (A7)+
        MOVE.L  (A7)+,A2        ; ver„ndert CCR nicht!
        BEQ     ende
        
        MOVE.L  our_cb,A0               ; Build up the ctrl-array
        MOVE.W  #SET_FILL_USER,cb.V_CONTRL.opcode(A0)
        CLR.W   cb.V_CONTRL.sptsin(A0)
        MOVE.L  cb.CURDEVICE(A0),A1
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        MOVE.W  (A2)+,D0
        LSL.W   #4,D0                   ; pattern.planes*16 -> D0
        MOVE.W  D0,cb.V_CONTRL.sintin(A0)
        MOVE.L  A0,(A3)+                ; Push 'our_cb' for 'vdi_call'
        MOVE.L  pubs, A0
        LEA     pubArrays.vINTIN(A0),A0
        LSR.W   #1,D0                   ; pattern.planes*8 -> D0
        SUBQ.W  #1,D0                   ; pattern.planes*8-1 -> D0 als Z„hler
loop                                    ; new pattern -> vINTIN-Array
        MOVE.L  (A2)+,(A0)+
        DBF     D0,loop
        JSR     vdi_call
ende
  END;
END DefUserFill;

PROCEDURE SetFillColor(handle:DeviceHandle;color:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_FILL_COLOR,D1
    JSR         setINT0attribut
  END;
END SetFillColor;

PROCEDURE SetFillType(handle:DeviceHandle;type:FillType);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_FILL_INTERIOR,D1
    JSR         setINT0attribut
  END;
END SetFillType;

PROCEDURE SetFillIndex(handle:DeviceHandle;index:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_FILL_INDEX,D1
    JSR         setINT0attribut
  END;
END SetFillIndex;

PROCEDURE SetFillPerimeter(handle:DeviceHandle;visible:BOOLEAN);

BEGIN
  ASSEMBLER
    MOVE.W      -(A3),D0
    MOVE.W      #SET_FILL_PERIMETER,D1
    JSR         setINT0attribut
  END;
END SetFillPerimeter;

END VDIAttributes.


(* $FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$00000413$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944$FFF8B944€$0000029AT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00001BCD$00001CE9$00001E9B$00000018$00002224$00000257$0000025F$0000029B$00001B39$00001BAA$FFEDDDBE$00001BB0$00001BBA$00001BEE$00000018$00002224 €ƒ*)
