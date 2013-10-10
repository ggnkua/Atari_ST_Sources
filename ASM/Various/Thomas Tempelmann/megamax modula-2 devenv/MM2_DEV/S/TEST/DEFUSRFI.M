MODULE Fill;

FROM SYSTEM IMPORT ASSEMBLER;
FROM Storage       IMPORT ALLOCATE;
FROM GrafBase      IMPORT black,Pnt,Rect,WordBitSet;
FROM GEMGlobals    IMPORT FillType;
FROM GEMEnv        IMPORT RC,DeviceHandle,GemHandle,InitGem,ExitGem,
                          CurrGemHandle;
FROM VDIControls   IMPORT ClearWorkstation;
FROM VDIAttributes IMPORT SetFillType,SetFillColor,SetFillIndex,PtrFillPattern,
                          DefUserFill;
FROM VDIInputs     IMPORT HideCursor, ShowCursor;
FROM VDIOutputs    IMPORT GrafText,FillRectangle;
FROM Terminal      IMPORT Read;


VAR Geraet: DeviceHandle;
    GemKennung: GemHandle;
    pattern: PtrFillPattern;
    ok: BOOLEAN;
    c: CHAR;
    
BEGIN

  (* FÅllmuster definieren *)
  ALLOCATE(pattern,SIZE(pattern));
  
  (* Hohe Auflîsung: *)
  pattern^.planes:=1;
  
  (* FÅllmuster: *)
  pattern^.hiResPlane[0]:= WordBitSet(02222H);
  pattern^.hiResPlane[1]:= WordBitSet(0);
  pattern^.hiResPlane[2]:= WordBitSet(08888H);
  pattern^.hiResPlane[3]:= WordBitSet(0);
  pattern^.hiResPlane[4]:= WordBitSet(02A2AH);
  pattern^.hiResPlane[5]:= WordBitSet(0);
  pattern^.hiResPlane[6]:= WordBitSet(08888H);
  pattern^.hiResPlane[7]:= WordBitSet(0);
  pattern^.hiResPlane[8]:= WordBitSet(02222H);
  pattern^.hiResPlane[9]:= WordBitSet(0);
  pattern^.hiResPlane[10]:=WordBitSet(08888H);
  pattern^.hiResPlane[11]:=WordBitSet(0);
  pattern^.hiResPlane[12]:=WordBitSet(02A2AH);
  pattern^.hiResPlane[13]:=WordBitSet(0);
  pattern^.hiResPlane[14]:=WordBitSet(08888H);
  pattern^.hiResPlane[15]:=WordBitSet(0);

  InitGem(RC, Geraet, ok);        (* Programm beim GEM anmelden         *)
  IF NOT ok THEN HALT END;        (* GEM will nicht => brutal Abbrechen *)
  GemKennung := CurrGemHandle();  (* GEM-Handle beschaffen              *)
  HideCursor(Geraet);             (* Maus weg                           *)
  ClearWorkstation(Geraet);       (* Bildschirm lîschen                 *)
  SetFillColor(Geraet,black);     (* FÅllfarbe schwarz                  *)
  
  
  SetFillType(Geraet,userPattern);(* Benutzerdefiniertes FÅllmuster     *)
  DefUserFill(Geraet,pattern);    (* FÅllmuster definieren              *)
  
  (****** AB HIER TUT SICH NICHTS MEHR **********************************)
  
  (*
     Diese zwei Zeilen funktioniern, im Gegensatz zu den obigen zwei:
  
     SetFillType(Geraet,dottPattern);
     SetFillIndex(Geraet,10);
     
   *)
   
   
  FillRectangle(Geraet,Rect(20,20,200,200));    (* Rechteck fÅllen      *)
  GrafText(Geraet,Pnt(20,300),"Taste ....");    (* Info fÅr Benutzer    *)
  Read(c);                                      (* Warten auf Taste     *)
  ShowCursor(Geraet,FALSE);                     (* Maus zeigen          *)
  
  ExitGem(GemKennung)                           (* Abmelden             *)

END Fill.
