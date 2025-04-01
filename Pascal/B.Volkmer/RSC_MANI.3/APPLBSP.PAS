(*************************************************
*                                                *
* Listing 1                                      *
*                                                *
* kleines Beispielprogramm fÅr AktivitÑten       *
* in einer Dialogbox                             *
* in Maxon Pascal                                *
*                                                *
* B.Volkmer        (c) 1992 MAXON Computer       *
*************************************************)

Program ApplBeispiel;

Uses AES, VDI, GEM, GrafBase, RSMTEST;

(* Die Konstantendatei vom RSC-Editor wird hier
   der öbersichtlichkeit wegen gleich eingefÅgt *)

CONST
  Rsmdial  =   0;  (* Formular/Dialog           *)
  Rsmtext  =   1;  (* BOXTEXT in Baum RSMDIAL   *)
  Rsmkn1   =   3;  (* BUTTON in Baum RSMDIAL    *)
  Rsmkn2   =   4;  (* BUTTON in Baum RSMDIAL    *)

TYPE  PtrParmBlock = ^ParmBlock;

VAR
     handle                  : INTEGER;
     ok                      : BOOLEAN;
     baum                    : PtrObjTree;
     ecke,bildrect, zielrect : Rectangle;
     Button                  : INTEGER;
     appliblock              : ApplBlock;
     pparmblock              : PtrParmBlock;
     parablock               : ParmBlock;    
     aktMFD                  : MemFormDef;
     paktMFD,phundMFD        : PtrMemFormDef;
     ad                      : POINTER;
     rezol, bw, bh           : INTEGER;

(*$I F:\PASCAL\MAXON\FOLGE.2\BEIPACK\Hund.inc *)    
(* Datei Hund einbinden, Dateipfad anpassen ! *)

(*************************************************
*  Dieses sind die AktivitÑten:                  *
*   'laufen1' kopiert das Hundebild auf den      *
*   Bildschirm,  wartet,  schreibt  dann das     *
*   Bild erneut auf  den Schirm. Durch die       *
*   Exclusiv-Oder-VerknÅpfung wird der alte      *
*   Hintergrund wiederhergestellt.               *
*************************************************)

VAR t,XX,YY: INTEGER;
(*$S-*)
PROCEDURE laufen1;                                
BEGIN
     zielrect.x := XX; zielrect.y := YY;
     CopyOpaque(handle,phundMFD,
                 paktMFD,bildrect,zielrect,sXorD);
     FOR t := 1 TO 4000 DO;
     CopyOpaque(handle,phundMFD,
                 paktMFD,bildrect,zielrect,sXorD);
END (*laufen1*);    


(*************************************************
*  Male lÑût den Hund im Kreis sooft herumlaufen,*
*  wie im ParmBlock.parameter Åbergeben wurde    *   
*  oder bis eine Taste  gedrÅckt   wird.         *
*  Die öbergabe des Parameters aus dem ParmBlock *
*  ist in Maxon-Pascal etwas kompliziert.        *
*  Tip: Quicktip Heft 10/91, Seite 181           *
*************************************************)

VAR radius, y, rq, DY, i, j, wieoft : INTEGER;
    mp                              : Point;
    dyps                            : REAL;
    fertig                          : BOOLEAN;

(*$S-*)
PROCEDURE Male;  (* keine loc. Variablen !!! *)
BEGIN
  asm
   MOVE.L  8(A6),pparmblock
  end;
  parablock := pparmblock^;  
  wieoft    := parablock.parameter;
  radius    := bh DIV 2 - 50;  
  rq        := radius * radius;
  mp.x      := bw DIV 2 - 20;     
  mp.y      := bh DIV 2 - 20;
  j := 0;
  fertig := false;
REPEAT
  i := -radius;
   WHILE i <= radius DO BEGIN  
    dyps := sqrt( FLOAT(rq-i*i));
    DY   := TRUNC(dyps);
    XX := mp.x + i;
    YY := mp.y - DY;
    laufen1;
    IF KeyPressed THEN fertig := TRUE;
    INC(i,10);
   END;

  i := radius;
  WHILE i >= -radius DO BEGIN
   dyps := sqrt( FLOAT(rq-i*i));
   DY   := TRUNC(dyps);
   XX   := mp.x + i;
   YY   := mp.y + DY;
   laufen1;
   IF KeyPressed THEN fertig := TRUE;   
   DEC(i,10);
  END;
  INC(j);
UNTIL (fertig) OR (j > wieoft);
    
END (* Male *);
(*$S+*)

(*************************************************
* Die Vorbereitung zum Malen: Parameter fÅr die  *
* CopyOpaque-Prozedur bereitstellen, Bildschirm- *
* auflîsung erfragen                             *
*                                                *
*************************************************)

PROCEDURE MalenVorbereiten;
BEGIN
    GetScreen(ad,ad,rezol);(* Auflîsung erfragen*)
    GetPhysMemForm(aktMFD);(* MFD vom Akt.Screen*)
    paktMFD :=ADDR(aktMFD);(* d. Pointer sagen  *)
                           (* Platz MFD vom Hund*)
    GetMem(phundMFD,SizeOf(MemFormDef));

    WITH phundMFD^ DO  BEGIN (* MFD Hund fÅllen *)
      BitData;               (* Anfang Bitdaten *)
      start := BitStart;
      w := ImgBreite * 8;
      h := ImgHoehe;
      words := w DIV 16;
      standardForm := 1;
                  (* die VAR bh,bw haben hier...*)
                  (* nichts zu suchen. Aus .....*)
                  (* und Bequeml. grÅnden hier..*)
                  (* mit erzeugt                *)

  CASE rezol OF
   2: BEGIN planes := 1; bh := 400; bw := 640;END;
   1: BEGIN planes := 2; bh := 200; bw := 640;END;
   0: BEGIN planes := 4; bh := 200; bw := 320;END;
  END;
 END;

 WITH zielrect DO BEGIN    (* dorthin  kopieren *)
  x := 0; y := 0; w := phundMFD^.w;
  h := phundMFD^.h;
 END;  
 bildrect := zielrect;     (*  das wird kopiert *)

END (* MalenVorbereiten *);


(*************************************************
* Hier wird der rechte Knopf des Dialoges        *
* umgestaltet                                    *
*************************************************)

PROCEDURE MachUserEintrag;
BEGIN

   WITH appliblock DO BEGIN        
    code := ADDR(Male);   (* die User-Routine   *)
    parm := LONGINT(5);   (* ein Parameter,..   *)
                          (* den man auch..     *)
   END;                   (* auch Åbersehen darf*)

   WITH  baum^[Rsmkn2] DO BEGIN
                          (* das Objekt Knopf   *)
    typ := 24;            (* rechts wird ProgDef*)
                   (* spec zeigt auf appliblock *)
    spec.more := ADDR(appliblock);
   END;

END (* MachUserEintrag *);


  
BEGIN   (************ Hauptprogramm *************)
  InitGem(RC,handle,ok);
  IF ok THEN BEGIN
     IF ~AES.GemError THEN BEGIN

       HideCursor(handle); (* Maus verstecken   *)
       ClearWorkstation(handle); (* lîschen     *)
       ShowCursor(handle,TRUE); 

       baum := TreeAddr^[Rsmdial];

       MalenVorbereiten;
       MachUserEintrag;

       FormCenter(baum,ecke);

       FormDial(reserveForm,ecke,ecke);
       DrawObject(baum,0,8,ecke);
       FormDo(baum,0,Button);   
       FormDial(freeForm,ecke,ecke);

     END;
     ExitGem(handle);
  END;
END (*ApplBeispiel*).
