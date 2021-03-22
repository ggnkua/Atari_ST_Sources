IMPLEMENTATION MODULE VDIInquires;
(*$L-, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die VDI Nachfragefunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version   2.2     V#0031
 *)

(*  18.08.89 MCH V0.11  | 'GetLineStyle' um die Linienenden erweitert
 *  ???????? TT  V2.1   | REF-Parm.
 *  02.04.90 MCH V2.2   | Anpassung an public arrays
 *  25.02.91 TT           "error"-Setzung ber occured-Funktion
 *  17.04.91 TT         | 'GetLineStyle' korrigiert: 'handle' wurde falsch
 *                        ermittelt - fhrte zu Laufzeitfehler
 *  28.04.91 TT         | 'GetLineStyle' korrigiert (Parms stimmten nicht)
 *                        und getestet.
 *)


FROM    SYSTEM          IMPORT ASSEMBLER;
 
FROM    MOSGlobals      IMPORT StringOverflow;
 
FROM    GrafBase        IMPORT Rectangle, WritingMode;
 
FROM    GEMGlobals      IMPORT LineType, MarkerType, FillType, THorJust,
                               TVertJust, LineEnding;
                   
IMPORT  GEMShare;

FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)
 

PROCEDURE GetColorDef(handle:DeviceHandle;color:CARDINAL;set:BOOLEAN;
                      VAR r,g,b:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      -(A3),-(A7)
    MOVE.L      -(A3),-(A7)
    MOVE.L      -(A3),-(A7)
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.vINTIN(A0)
    MOVE.W      #INQUIRE_COLOR,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.L      pubs,A0
    TST.W       pubArrays.vINTOUT(A0)
    BPL         noErr
    JSR         gemErrorOccured
    ADDA.W      #12,A7
    BRA         cont
noErr
    MOVE.L      (A7)+,A1
    MOVE.W      pubArrays.vINTOUT+2(A0),(A1)
    MOVE.L      (A7)+,A1
    MOVE.W      pubArrays.vINTOUT+4(A0),(A1)
    MOVE.L      (A7)+,A1
    MOVE.W      pubArrays.vINTOUT+6(A0),(A1)
cont
  END;
END GetColorDef;

PROCEDURE GetLineStyle(    handle: DeviceHandle;
                       VAR typ   : LineType;
                       VAR color : CARDINAL;
                       VAR mode  : WritingMode;
                       VAR begin,
                           end   : LineEnding;
                       VAR width : CARDINAL    );
                       
BEGIN
  ASSEMBLER
        MOVE.L  -28(A3),(A3)+           ; handle
        MOVE.W  #INQUIRE_LINE,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT(A0),(A1)      ; 'width' = ptsout[0]
        
        LEA     pubArrays.vINTOUT(A0),A0
        
        MOVE.L  our_cb,A1
        CMPI.W  #3,cb.V_CONTRL.sintout(A1)
        BLS     noBegEnd
        
        MOVE.L  -(A3),A1
        MOVE.W  2*4(A0),D0
        SUBQ.W  #1,D0
        MOVE.W  D0,(A1)                 ; 'end' = vINTOUT[4]
        
        MOVE.L  -(A3),A1
        MOVE.W  2*3(A0),D0
        SUBQ.W  #1,D0
        MOVE.W  D0,(A1)                 ; 'begin' = vINTOUT[3]
        
        BRA     cont
        
noBegEnd:
        MOVE.L  -(A3),A1
        CLR.W   (A1)
        MOVE.L  -(A3),A1
        CLR.W   (A1)
        
cont:   ADDQ.L  #6,A0
        
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),D0
        SUBQ.W  #1,D0
        MOVE.W  D0,(A1)                 ; 'mode' = intout[2]
        
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)              ; 'color' = intout[1]
        
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),D0
        SUBQ.W  #1,D0
        MOVE.W  D0,(A1)                 ; 'typ' = intout[0]
        
        SUBQ.L  #4,A3
  END;
END GetLineStyle;

PROCEDURE GetMarkerStyle(handle:DeviceHandle;VAR typ:MarkerType;
                         VAR color:CARDINAL;VAR mode:WritingMode;
                         VAR height:CARDINAL);
                         
BEGIN
  ASSEMBLER
        MOVE.L  -20(A3),(A3)+
        MOVE.W  #INQUIRE_MARKER,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+2(A0),(A1)
        LEA     pubArrays.vINTOUT+$6(A0),A0
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),D0
        SUBQ.W  #1,D0
        MOVE.W  D0,(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),D0
        ;SUBQ.W  #1,D0          un”tig wegen GEM-Fehler
        MOVE.W  D0,(A1)
        SUBQ.L  #4,A3
  END;
END GetMarkerStyle;
                         
PROCEDURE GetFillStyle(handle:DeviceHandle;VAR typ:FillType;VAR color:CARDINAL;
                       VAR index:CARDINAL;VAR mode:WritingMode;
                       VAR peri:BOOLEAN);
                       
BEGIN
  ASSEMBLER
        MOVE.L  -24(A3),(A3)+
        MOVE.W  #INQUIRE_FILL,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        LEA     pubArrays.vINTOUT+$A(A0),A0
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),D0
        SUBQ.W  #1,D0
        MOVE.W  D0,(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        SUBQ.L  #4,A3
  END;
END GetFillStyle;
                           
PROCEDURE GetTextStyle(handle:DeviceHandle;VAR font,color,angle:CARDINAL;
                       VAR hor:THorJust;VAR vert:TVertJust;VAR mode:WritingMode;
                       VAR charW,charH,boxW,boxH:CARDINAL);
                       
BEGIN
  ASSEMBLER
        MOVE.L  -44(A3),(A3)+
        MOVE.W  #INQUIRE_TEXT,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+6(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+4(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+2(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT(A0),(A1)
        LEA     pubArrays.vINTOUT+$C(A0),A0
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),D0
        ;SUBQ.W  #1,D0          un”tig wegen GEM-Fehler
        MOVE.W  D0,(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  -(A0),(A1)
        SUBQ.L  #4,A3
  END;
END GetTextStyle;
                       
PROCEDURE TextExtent(handle:DeviceHandle;REF str:ARRAY OF CHAR):Rectangle;

BEGIN
  ASSEMBLER
        MOVE.L  D4,-(A7)
        CLR.W   D4
        JSR     stringIntoINTIN
        MOVE.W  -(A3),D0
        
        MOVE.W  D0,-(A7)
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        MOVE.W  (A7)+,D1
        MOVE.W  (A7)+,D0
        TST.W   D1
        BEQ     ende
        
        MOVE.L  our_cb,A0
        MOVE.W  #TEXT_EXTENT,cb.V_CONTRL.opcode(A0)
        CLR.W   cb.V_CONTRL.sptsin(A0)
        MOVE.L  cb.CURDEVICE(A0),A1     ; set current device handle
        MOVE.W  device.handle(A1),cb.V_CONTRL.handle(A0)
        MOVE.W  D0,cb.V_CONTRL.sintin(A0) ; strlen(in vINTIN) -> ctrl-array
        MOVE.L  A0,(A3)+
        JSR     vdi_call
        MOVE.L  pubs,A0
        LEA     pubArrays.PTSOUT(A0),A0        ; Get first two coor.pairs
        MOVE.W  (A0)+,D0
        MOVE.W  (A0)+,D1
        MOVE.W  (A0)+,D2
        MOVE.W  (A0)+,D3
        CMP.W   D0,D2                   ; d0 ~ smallest x
        BCC     cont3                   ; d1 ~ smallest y
        EXG     D0,D2                   ; d2 ~ greatest x
cont3                                   ; d3 ~ greatest y
        CMP.W   D1,D3
        BCC     cont4
        EXG     D1,D3
cont4
        MOVEQ   #1,D5                   ; there are 2 points left
loop2
        MOVE.L  (A0)+,D4                ; get point
        CMP.W   D1,D4                   ; and test y
        BCC     cont5
        MOVE.W  D4,D1
        BRA     cont6
cont5
        CMP.W   D4,D3
        BCC     cont6
        MOVE.W  D4,D3
cont6
        SWAP    D4                      ; test x
        CMP.W   D0,D4
        BCC     cont7
        MOVE.W  D4,D0
        BRA     cont8
cont7
        CMP.W   D4,D2
        BCC     cont8
        MOVE.W  D4,D2
cont8
        DBF     D5,loop2                ; next point, if one is left
        SUB.W   D0,D2
        SUB.W   D1,D3
        ADDQ.W  #1,D2
        ADDQ.W  #1,D3
        MOVE.W  D0,(A3)+                ; RETURN Rect(x,y,w,h)
        MOVE.W  D1,(A3)+
        MOVE.W  D2,(A3)+
        MOVE.W  D3,(A3)+
ende
        MOVE.L  (A7)+,D4
  END;
END TextExtent;

PROCEDURE GetCharSize(handle:DeviceHandle;
                      ch:CHAR; VAR width,dLeft,dRight:CARDINAL);

BEGIN
  ASSEMBLER
    MOVE.L      -(A3),-(A7)
    MOVE.L      -(A3),-(A7)
    MOVE.L      -(A3),-(A7)
    MOVE.L      pubs,A0
    MOVEQ       #0, D0
    SUBQ.L      #1, A3
    MOVE.B      -(A3),D0
    MOVE.W      D0,pubArrays.vINTIN(A0)
    MOVE.W      #INQUIRE_CELL,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.L      pubs,A0
    TST.W       pubArrays.vINTOUT(A0)
    BPL         noError
    JSR         gemErrorOccured
    TST.L       (A7)+
    TST.L       (A7)+
    TST.L       (A7)+
    BRA         cont
noError
    MOVE.L      (A7)+,A1
    MOVE.W      pubArrays.PTSOUT(A0),(A1)
    MOVE.L      (A7)+,A1
    MOVE.W      pubArrays.PTSOUT+4(A0),(A1)
    MOVE.L      (A7)+,A1
    MOVE.W      pubArrays.PTSOUT+8(A0),(A1)
cont
  END;
END GetCharSize;

PROCEDURE GetFaceName(handle:DeviceHandle;num:CARDINAL;VAR name:ARRAY OF CHAR);

CONST   faceNameLen     =32;    (* L„nge des Fontnamens *)

BEGIN
  ASSEMBLER
        MOVE.W  -(A3),D0
        CMP.W   #faceNameLen-2,D0
        BLS     err             ; Falls HIGH(name)<=30, dann springe zu 'Fehler'
        MOVE.W  D0,-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.W  #VQT_NAME,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        LEA     pubArrays.vINTOUT+2(A0),A0
        MOVE.L  (A7)+,A1
        MOVE.W  #faceNameLen-1,D0
loop
        MOVE.W  (A0)+,D1
        MOVE.B  D1,(A1)+
        DBF     D0,loop
        MOVE.W  (A7)+,D0
        CMP.W   #faceNameLen-1,D0
        BEQ     ende
        CLR.B   (A1)
        BRA     ende
err
        TRAP    #noErrorTrap
        DC.W    StringOverflow
        SUBA.W  #10,A3
ende
  END;
END GetFaceName;

PROCEDURE GetCellArray (handle:DeviceHandle; frame:Rectangle;
                        rowLength,numRows:CARDINAL;
                        VAR usedElems,usedRows:CARDINAL;
                        VAR undef:BOOLEAN; VAR colArray:ARRAY OF CARDINAL);
BEGIN
  ASSEMBLER
        JSR     HALT
  END
END GetCellArray;

PROCEDURE GetFaceInfo (handle:DeviceHandle; VAR minADE,maxADE:CARDINAL;
                       VAR bottom,descent,half,ascent,top:CARDINAL;
                       VAR maxWidth,deltaXSpecial,leftOff,rightOff:INTEGER);
                       
BEGIN
  ASSEMBLER
        MOVE.L  -48(A3),(A3)+
        MOVE.W  #VQT_FONTINFO,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+12(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+8(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+4(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+18(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+14(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+10(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+6(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.PTSOUT+2(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.vINTOUT+2(A0),(A1)
        MOVE.L  -(A3),A1
        MOVE.W  pubArrays.vINTOUT+0(A0),(A1)
        SUBQ.L  #4,A3
  END;
END GetFaceInfo;


END VDIInquires. 
(* $FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$0000227A$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780$FFF8B780€$00000A11T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFECD75C$00000940$FFECD75C$0000092A$00000918$00000927$00000A7E$00000A2F$00000940$000009B1$000001CD$000002CE$0000025E$000002CB$00000A20$00000A11€€ƒ*)
