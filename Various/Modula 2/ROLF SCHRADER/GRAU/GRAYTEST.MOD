MODULE GrayTest;
(* ½ 1989-93 by ROLF SCHRADER. * 15.1.89 .. 15.3.93 *)

FROM   SYSTEM  IMPORT ADDRESS;
IMPORT SYSTEM, BIOS, XBIOS, AESGraphics, GEMVDIbase, VDIRasters;

MODULE Gray;
(* Dieser Modul stellt 2 Bildschirme #0, #1 und dazugeh”rige Prozeduren zu*)
(* deren Manipulation zur Verfgung. Der Standardschirm (norm. GEM-Video- *)
(* RAM) wird Scrap (normal #0). SetScreen & FlipScreen erm”glichen, in die*)
(* Schirme mit gew. GEM-Fktnen. zu schreiben. AS ist der aktuelle, SS der *)
(* Scrap-Schirm; 8ung: memPtr nur zum Bitpopeln.*)
(* Nach Benutzung dieses Moduls muž man bei Prg.-Ende EndScreen aufrufen! *)

FROM   SYSTEM      IMPORT ADR, ADDRESS, CODE;
FROM   XBIOS       IMPORT ScreenPhysicalBase, ScreenLogicalBase,
                          SetScreenBase, SuperExec;
FROM   AESGraphics IMPORT GrafHandle;
FROM   GEMVDIbase  IMPORT BigPxyArrayType;
FROM   VDIRasters  IMPORT CopyRasterOpaque;

EXPORT GraySwitch, ModBox, FlipActS, InvScreen, SetScreen, EndScreen,
       ASmemPtr, SSmemPtr, BPZ;

CONST  WMAX = 640; HMAX = 400;
       XMAX = 639; YMAX = 399;
       BPZ  = WMAX DIV 8;                              (* Bytes pro Zeile *)
       SCREENSIZE = HMAX * (WMAX DIV 8);
CONST  SPTRADR = 45EH; VBLHADR = 70H;                  (* System-Adressen *)

VAR    ASadr, SSadr:       ADDRESS;              (* -> MFDBs fr CopyRas. *)
       ASmemPtr, SSmemPtr: POINTER TO ADDRESS;   (* akt. Schirm & Scrap.  *)


MODULE ManiSch;
IMPORT GrafHandle, BigPxyArrayType, CopyRasterOpaque, ASadr, SSadr,
       FlipVideo, XMAX, YMAX;
EXPORT ClrScrap, ClrScreen, SaveScreen, ReScreen, InvScreen, ModBox;

VAR    ja:           INTEGER;                                 (* Ja-Sager *)
       GDev:         INTEGER;                 (* VDI-Handle f. Graph. Dev.*)
       Ganz:         BigPxyArrayType;
       REKoo:        BigPxyArrayType;

PROCEDURE SetPoints (ax,ay,bx,by,Ax,Ay,Bx,By:INTEGER;VAR P:BigPxyArrayType);
 BEGIN P[0] := ax; P[1] := ay; P[2] := bx; P[3] := by;
       P[4] := Ax; P[5] := Ay; P[6] := Bx; P[7] := By; END SetPoints;

PROCEDURE ClrScrap;
 BEGIN CopyRasterOpaque (GDev, 0, Ganz, SSadr,SSadr) END ClrScrap;
PROCEDURE ClrScreen;
 BEGIN CopyRasterOpaque (GDev, 0, Ganz, ASadr,ASadr) END ClrScreen;
PROCEDURE SaveScreen;     (* Rettet den Bildschirm in den Scrapbildschirm.*)
 BEGIN CopyRasterOpaque (GDev, 3, Ganz, ASadr,SSadr) END SaveScreen;
PROCEDURE ReScreen;  (* Schreibt Scrapbildschirm zurck in den Bildschirm.*)
 BEGIN CopyRasterOpaque (GDev, 3, Ganz, SSadr,ASadr) END ReScreen;
PROCEDURE InvScreen;
 BEGIN CopyRasterOpaque (GDev,12, Ganz, ASadr,SSadr);
       FlipVideo; ReScreen; FlipVideo; END InvScreen;   (* Ohne Flimmern! *)

PROCEDURE ModBox (ax,ay, bx,by, wrMode: INTEGER); (* wrMode -> CopyRast.O.*)
    (* M=0: AS weiž; M=-15: SS schwarz; M=3: SS->AS; M=-6: ASxorSS->SS ...*)
 BEGIN SetPoints (ax,ay, bx,by, ax,ay, bx,by, REKoo);
  IF (wrMode > 15)   OR    (wrMode < -16) THEN RETURN END;
  IF (wrMode <  0) THEN IF (wrMode = -16) THEN wrMode := -0 END;
   CopyRasterOpaque (GDev,-wrMode, REKoo, ASadr,SSadr); RETURN END (*I*);
   CopyRasterOpaque (GDev, wrMode, REKoo, SSadr,ASadr); END ModBox;

BEGIN (* Init.*) GDev := GrafHandle (ja,ja,ja,ja);
      SetPoints (0,0,XMAX,YMAX, 0,0,XMAX,YMAX, Ganz); END (*M*) ManiSch;


MODULE Screens;
IMPORT ADR, ADDRESS, WMAX, HMAX, SCREENSIZE, ClrScreen, ClrScrap,
       ScreenPhysicalBase, ScreenLogicalBase, SetScreenBase,
       ASadr,ASmemPtr, SSadr,SSmemPtr;
EXPORT SetScreen, FlipVideo, FlipScreen, InitScreen, EndScreen, FlipActS;
CONST  A1 = ADDRESS (-1);
TYPE   MFDBType = RECORD adr: ADDRESS; w,h,ww,koo,pl,r1,r2,r3: INTEGER; END;
VAR    Memory:    ARRAY [0..SCREENSIZE +256] OF CHAR;            (* fr S.*)
       BsMemAdr:  ARRAY [0..1] OF ADDRESS;          (* Scrap + Bildschirm.*)
       ASMB,SSMB: MFDBType;                      (* MemFormDefs fr AS,SS.*)

PROCEDURE SetScreen (Nr: INTEGER);      (* Setzt den aktuellen Bildschirm.*)
 BEGIN ASmemPtr^ := BsMemAdr[Nr]; END SetScreen;
PROCEDURE FlipVideo; (* Wechselt den Video-Schirm, aber nicht die Ausgabe.*)
 BEGIN IF  (ScreenPhysicalBase () = ASmemPtr^) THEN
            SetScreenBase (A1,      SSmemPtr^, -1);
       ELSE SetScreenBase (A1,      ASmemPtr^, -1); END END FlipVideo;
PROCEDURE FlipScreen; (* Wechselt den Ausgabeschirm, aber nicht das Video.*)
 BEGIN IF  (ScreenLogicalBase ()  = ASmemPtr^) THEN
            SetScreenBase (SSmemPtr^,      A1, -1);
       ELSE SetScreenBase (ASmemPtr^,      A1, -1); END END FlipScreen;
PROCEDURE InitScreen;   (* Setzt neuen Speicherbereich fr den Bildschirm.*)
 BEGIN      SetScreenBase (BsMemAdr[1],    A1, -1); ClrScreen;
            SetScreenBase (A1,    BsMemAdr[1], -1); END InitScreen;
PROCEDURE  EndScreen;             (* Setzt wieder den Standard-Bildschirm.*)
 BEGIN      SetScreenBase (BsMemAdr[0],    A1, -1); ClrScrap;
            SetScreenBase (A1,    BsMemAdr[0], -1); END EndScreen;
PROCEDURE FlipActS;  (* Vertauscht akt. Schirm & Scrap (Ziel-Rtg.-Umkehr) *)
 VAR   a: ADDRESS;
 BEGIN a := ASmemPtr^; ASmemPtr^ := SSmemPtr^; SSmemPtr^ := a; END FlipActS;

PROCEDURE Blattgrenze (MemAdr: ADDRESS): ADDRESS; (* Erford. f. Video-Ram!*)
 BEGIN RETURN MemAdr + (256 - (MemAdr MOD 256)) END Blattgrenze;

BEGIN (* Altes Video-RAM wird Scrapschirm, wahres Bild liegt im 'Memory'. *)
   BsMemAdr[0] := ScreenLogicalBase(); (* sic! nicht PhysB.! *)
   BsMemAdr[1] := Blattgrenze (ADR (Memory));
   WITH ASMB DO  adr := BsMemAdr[1];
        w := WMAX; h := HMAX; ww := w DIV 16; koo := 1; pl := 1; END (*W*);
   ASadr := ADR (ASMB); ASmemPtr := ADR (ASMB.adr);
   SSMB  := ASMB;       SSMB.adr := BsMemAdr[0];
   SSadr := ADR (SSMB); SSmemPtr := ADR (SSMB.adr);
   SetScreen (1);                 (* Zuerst ist #1 der aktive Bildschirm. *)
   InitScreen;            (* Bei Programmende mit EndScreen zurcksetzen! *)
END (*M*) Screens;


MODULE Dorian;
IMPORT ADDRESS, CODE, SuperExec, SPTRADR, VBLHADR,
       ScreenPhysicalBase, SetScreenBase;
EXPORT GraySwitch;

VAR    VBHandler[VBLHADR]: ADDRESS;
       ScreenPtr[SPTRADR]: ADDRESS;
       Sadr0, Sadr1, OldS: ADDRESS;
       GrayHandler:        ADDRESS;
       Count, GrauGrenze:  CARDINAL;
       OldVecPtr:          POINTER TO ADDRESS;
       xbraP, grayP:       POINTER TO LONGCARD;
       ProtPtr:            POINTER TO ARRAY [-3..-1] OF LONGCARD;
CONST  RTS = 04E75H;  A1 = ADDRESS (-1);

PROCEDURE GraySwitch (OnOff: CARDINAL; Plane0,Plane1: ADDRESS);
 (* Verbiegt den Vektor 'VBI-List-Handler', hin und zurck! *)
 BEGIN GrauGrenze  := OnOff+1; OldS := ScreenPhysicalBase ();
  IF   (OnOff # 0) THEN       Sadr0 := Plane0; Sadr1 := Plane1;
       SuperExec (PROC (InstallGray));
  ELSE SuperExec (PROC ( BleachGray));
       SetScreenBase (A1, OldS, -1); END (*E*); END GraySwitch;

(*$P-*) PROCEDURE InstallGray;          (* P- -> Komm. zu XBIOS.SuperExec.*)
 BEGIN ProtPtr :=  ADDRESS (-12) + VBHandler;
   IF (ProtPtr^[-3] # xbraP^) OR
      (ProtPtr^[-2] # grayP^) THEN OldVecPtr^ := VBHandler;
                                   VBHandler  := GrayHandler; END (*I*);
   CODE (RTS); (* 'raus wie C *) END InstallGray; (*$P=*)

(*$P-*) PROCEDURE  BleachGray;          (* P- -> Komm. zu XBIOS.SuperExec.*)
 BEGIN ProtPtr :=  ADDRESS (-12) + VBHandler;    ScreenPtr := 0 (*!!*);
   IF (ProtPtr^[-3] = xbraP^) &
      (ProtPtr^[-2] = grayP^) THEN VBHandler  := OldVecPtr^; END (*I*);
   CODE (RTS); (* 'raus wie C *) END  BleachGray; (*$P=*)

(*$P-*) PROCEDURE GrayCode;         (* Wird von MakeXBRAgray modifiziert! *)
 BEGIN CODE (0,0,0,0,0,0); (* Platz f. XBRA-Protokoll nach Braner/Reschke.*)
   (* Einsprung: *)        (* Zuerst den alten VBL-Handler auf den Stack: *)
   CODE (02F3AH, 0FFFAH);  (* move.l d(pc),-(sp); -6 (lt. XBRA genau da!) *)
   IF    (Count = 0) THEN ScreenPtr := Sadr0;
          Count:= GrauGrenze;
   ELSIF (Count = 1) THEN ScreenPtr := Sadr1;
   ELSE                   ScreenPtr := 0; END;
   DEC   (Count); (* mod GrauGrenze *)
   CODE (RTS) (* mit'm alten Handler weiter! *) END GrayCode; (*$P=*)

PROCEDURE MakeXBRAgray;     (* Modifiziert GrayCode gem„ž XBRA-Protokoll! *)
VAR   Ch4Ptr: POINTER TO ARRAY [0..3] OF CHAR;
BEGIN GrayHandler := ADDRESS (GrayCode) +12;        (* Einsprung-Adresse. *)
      OldVecPtr   := GrayHandler  -4;
      Ch4Ptr      := GrayHandler  -8;   Ch4Ptr^ := 'GRAY';
      grayP       := GrayHandler  -8;
      Ch4Ptr      := GrayHandler -12;   Ch4Ptr^ := 'XBRA';
      xbraP       := GrayHandler -12;
END MakeXBRAgray;

BEGIN (* Init.*) MakeXBRAgray; Count := 0; END (*M*) Dorian;

END (*M*) Gray;

PROCEDURE Mon;  BEGIN AESGraphics.GrafMouse (257, NIL) END Mon;
PROCEDURE Moff; BEGIN AESGraphics.GrafMouse (256, NIL) END Moff;
PROCEDURE FillWords (adr: ADDRESS; W,H, fw: CARDINAL);
 VAR   w:  CARDINAL;    ptr: POINTER TO CARDINAL;
 BEGIN WHILE (H > 0) DO ptr := adr; INC (adr, BPZ); DEC (H);
         FOR  w := 1 TO W DO ptr^ := fw; (*$T-*) INC (ptr, 2) (*$T=*) END;
         END (*H*); END FillWords;
PROCEDURE Pause;  BEGIN IF (0 = BIOS.BConIn  (BIOS.CON)) THEN END END Pause;
PROCEDURE wCh (ch: CHAR); BEGIN BIOS.BConOut (BIOS.CON, ch) END wCh;
PROCEDURE wSt (VAR s: ARRAY OF CHAR); VAR k: CARDINAL;
 BEGIN k:=0; WHILE (k<=HIGH(s))&(s[k]#0C) DO wCh (s[k]); INC(k) END END wSt;

PROCEDURE PaintGray (K, s0,a0, W,H, F1,F2,F3,F4: CARDINAL);
 BEGIN FOR k := 0 TO K DO
        FillWords (SSmemPtr^ +ADDRESS (s0+   (k*2)*BPZ), W,H, F1);
        FillWords (SSmemPtr^ +ADDRESS (s0+ (1+k*2)*BPZ), W,H, F2);
        FillWords (ASmemPtr^ +ADDRESS (a0+   (k*2)*BPZ), W,H, F3);
        FillWords (ASmemPtr^ +ADDRESS (a0+ (1+k*2)*BPZ), W,H, F4);
        END (*k*); END PaintGray;

VAR   k, f1,f2: CARDINAL;
BEGIN Moff;                                              (* TESTPROGRAMM: *)
   FlipActS;  ModBox (160, 50,480,150,  0);
   InvScreen; ModBox (160,250,480,350,  0); FlipActS;
              ModBox (240,100,320,300,  0);
              ModBox (320,100,400,300, 15);

(* Interleaving a la Fernsehen alias Flimmerkiste *)
   PaintGray (124, 10+50*BPZ, 10+100*BPZ, 10,1, 0,0FFFFH,0FFFFH,0);
   f1 := 1 +4 +16 +64; f1 := f1 *256 +f1;
   f2 := f1 *2;
(* das neue, leckere Grau ! *)
   PaintGray (124, 50+50*BPZ, 50+100*BPZ, 10,1, f1,f2,f2,f1);

   Mon;
(* TEST 1: *)
    GraySwitch (1, ASmemPtr^,SSmemPtr^); Pause; GraySwitch (0, 0,0);
(* TEST 2: *)
    GraySwitch (2, ASmemPtr^,SSmemPtr^); Pause; GraySwitch (0, 0,0);
   Moff;

   PaintGray (150, 10+ 50*BPZ,10+ 50*BPZ,30,1, f1,f2,f2,f1);      (* grau *)
   PaintGray ( 50, 40+200*BPZ,40+200*BPZ, 5,1, 0FFFFH,0FFFFH,0FFFFH,0FFFFH);
   PaintGray ( 50, 30+200*BPZ,30+200*BPZ, 5,1, 0,0,0,0);          (* s+w  *)
   PaintGray ( 16,    352*BPZ,   352*BPZ,40,1, 0,0,0,0);
(* +2 weitere Graustufen - bei halber Aufl”sung *)
   PaintGray ( 50, 30+100*BPZ,30+100*BPZ, 5,1, f1,0FFFFH,0FFFFH,f2);
   PaintGray ( 50, 40+100*BPZ,40+100*BPZ, 5,1, f1,0,0,f2);

(* wCh (33C); wCh ("Y"); wCh (CHR (32 +8)); wCh (CHR (32+32)); *)
   wCh (33C); wCh ("Y"); wCh (CHR (32+22)); wCh (CHR (32 +10));
   wSt (' 2 weitere Graustufen mit Pfeffer & Salz! ');
   wCh (33C); wCh ("Y"); wCh (CHR (32+23)); wCh (CHR (32 +10));
   wSt (' Flimmerts noch? Dann Kontrast oder Helligkeit etwas verringern.');
   Mon;
(* TEST 3: *)
    GraySwitch (1, ASmemPtr^,SSmemPtr^); Pause;
   Moff; GraySwitch (0, 0,0); EndScreen;
END GrayTest.
