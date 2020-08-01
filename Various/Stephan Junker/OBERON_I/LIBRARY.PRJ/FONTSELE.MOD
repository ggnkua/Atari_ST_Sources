MODULE FontSelect;

(* Stephan Junker    22.11.92   Version : 19.01.93   14:48 *)

(* "FontSelect" erm”glicht die Auswahl einer der geladenen GDOS-Fonts mit
   einer Dialogbox. In dieser Dialogbox mssen sechs Elemente vorhanden
   sein :
   1. Ein nicht zu kleines Objekt, in das der Fontname mit dem eingestellten
      Font geschrieben wird. Es sollte sich um eine Box handeln. "Init"
      macht daraus ein benutzerdefiniertes Objekt.
   2. Ein Button fr die Auswahl des vorigen Fonts, TOUCHEXIT
   3. Dasgleiche fr den n„chsten Font
   4. Ein Text mit zwei Zeichen L„nge, in den die Fontgr”že eingetragen wird
   5. Ein Button fr eine kleinere Fontgr”že, TOUCHEXIT
   6. Dasgleiche fr eine gr”žere Fontgr”že
*)

IMPORT S:=SYSTEM, VC:=VDIControl, VA:=VDIAttributes, VI:=VDIInquiry,
       VO:=VDIOutput ,Dialogs, Objc, Str:=Strings ,NStr:=NumStr ,VDI, Graf;

CONST MAXHEIGHT = 20;

TYPE proc = PROCEDURE (Ptr : Objc.parmblkptr) : INTEGER;

VAR FontNo*,Font*,Height* : INTEGER;
   (* In "Font" steht die Fontidentifikationsnummer des gerade eingestellten
   Fonts, in "Height" dessen H”he. Beim Aufruf der Dialogbox werden diese
   Werte angezeigt, bei Verlassen der Box werden evtl. ver„nderte Werte
   hier gespeichert. "FontNo" wird intern ben”tigt und enth„lt die Nummer
   eines Fonts. Der Systemfont hat die Nummer eins, alle weiteren Fonts
   folgen in aufsteigender Reihenfolge. Im Gegensatz dazu ist "Font" die
   Identifikationsnummer, deren Wert im Font festgelegt wird und zum
   Einstellen mit "VstFont" ben”tigt wird. Nur ber "FontNo" ist es m”glich,
   einen Font vorw„rts oder rckw„rts zu gehen. Daher ist es nicht n”tig,
   daž "Font" beim Aufruf der Dialogbox einen sinnvollen Wert hat, sondern
   nur "FontNo" und "Height". Diese Werte werden zu 1 (Systemfont) bzw.
   13 (8*16) initialisiert *)

VAR Station* : INTEGER;
   (* Dies ist die VDI-Workstation, mit der gearbeitet wird. Alle Attribute
   fr Textausgabe und Fllmuster drfen nicht ver„ndert werden. Die
   Einstellungen sind : Schreibmodus REPLACE, Textfarbe schwarz, Rand
   unsichtbar, Fllung weiž *)

VAR Workout*  : VC.workout;
   (* dies sind die Rckgabewerte von VOpnvwk und nur fr Info-Zwecke
   gedacht *)

VAR ApplBlk   : proc;
    Workin    : VC.workin;
    NumFonts  : INTEGER;
    ActBox    : LONGINT;
    FontIndex : INTEGER;
    SizeIndex : INTEGER;
    PrevIndex : INTEGER;
    NextIndex : INTEGER;
    SmalIndex : INTEGER;
    LargIndex : INTEGER;

VAR d : INTEGER;

PROCEDURE SetHeight;
  VAR s : ARRAY 4 OF CHAR;
      Ptr : Objc.tedinfoptr;
 BEGIN
  NStr.IntTo(Height,10,s); Str.Adjust(Str.right,2,"0",s); s[2] := 0X;
  Ptr := Objc.GetSpec(ActBox,SizeIndex); COPY(s,Ptr.Text^);
 END SetHeight;

PROCEDURE WriteFontHeight;
 BEGIN
  SetHeight;
  Objc.Draw(ActBox,SizeIndex,1,0,0,Workout.MaxX,Workout.MaxY);
  Objc.Draw(ActBox,FontIndex,1,0,0,Workout.MaxX,Workout.MaxY);
 END WriteFontHeight;

PROCEDURE SnapHeight(Height : INTEGER) : INTEGER;
  VAR d : INTEGER;
 BEGIN
  VA.VstPoint(Station,Height,d,d,d,d); RETURN VDI.Intout[0];
 END SnapHeight;

PROCEDURE DisableSelectors;
  VAR h : INTEGER;
 BEGIN
  IF FontNo = 1 THEN
    Objc.SetState(ActBox,PrevIndex,{Objc.DISABLED});
    Objc.SetFlags(ActBox,PrevIndex,{});
  ELSE
    Objc.SetState(ActBox,PrevIndex,{});
    Objc.SetFlags(ActBox,PrevIndex,{Objc.TOUCHEXIT});
  END(*IF*);
  IF FontNo = NumFonts THEN
    Objc.SetState(ActBox,NextIndex,{Objc.DISABLED});
    Objc.SetFlags(ActBox,NextIndex,{});
  ELSE
    Objc.SetState(ActBox,NextIndex,{});
    Objc.SetFlags(ActBox,NextIndex,{Objc.TOUCHEXIT});
  END(*IF*);
  h := Height;
  REPEAT DEC(h); UNTIL (h = 0) OR (SnapHeight(h) # Height);
  IF h = 0 THEN
    Objc.SetState(ActBox,SmalIndex,{Objc.DISABLED});
    Objc.SetFlags(ActBox,SmalIndex,{});
  ELSE
    Objc.SetState(ActBox,SmalIndex,{});
    Objc.SetFlags(ActBox,SmalIndex,{Objc.TOUCHEXIT});
  END(*IF*);
  h := Height;
  REPEAT INC(h); UNTIL (h = MAXHEIGHT) OR (SnapHeight(h) # Height);
  IF h = MAXHEIGHT THEN
    Objc.SetState(ActBox,LargIndex,{Objc.DISABLED});
    Objc.SetFlags(ActBox,LargIndex,{});
  ELSE
    Objc.SetState(ActBox,LargIndex,{});
    Objc.SetFlags(ActBox,LargIndex,{Objc.TOUCHEXIT});
  END(*IF*);
  VA.VstPoint(Station,Height,h,h,h,h);
 END DisableSelectors;

PROCEDURE RedrawSelectors;
 BEGIN
  Objc.Draw(ActBox,PrevIndex,1,0,0,Workout.MaxX,Workout.MaxY);
  Objc.Draw(ActBox,NextIndex,1,0,0,Workout.MaxX,Workout.MaxY);
  Objc.Draw(ActBox,SmalIndex,1,0,0,Workout.MaxX,Workout.MaxY);
  Objc.Draw(ActBox,LargIndex,1,0,0,Workout.MaxX,Workout.MaxY);
 END RedrawSelectors;

PROCEDURE SetNewFont;
  VAR Name : ARRAY 34 OF CHAR;
      Font : INTEGER;
      h    : INTEGER;
 BEGIN
  Font := VI.VqtName(Station,FontNo,Name);
  VA.VstFont(Station,Font);
  Height := SnapHeight(Height);
  IF Height >= MAXHEIGHT THEN
    h := MAXHEIGHT;
    REPEAT DEC(h); UNTIL SnapHeight(h) # MAXHEIGHT;
    Height := SnapHeight(h);
  END(*IF*);
  WriteFontHeight; DisableSelectors; RedrawSelectors;
 END SetNewFont;

PROCEDURE* SetPrev;
 BEGIN
  DEC(FontNo); SetNewFont;
 END SetPrev;

PROCEDURE* SetNext;
 BEGIN
  INC(FontNo); SetNewFont;
 END SetNext;

PROCEDURE* SetSmaller;
  VAR h : INTEGER;
 BEGIN
  h := Height;
  REPEAT DEC(h); UNTIL SnapHeight(h) # Height;
  Height := SnapHeight(h);
  WriteFontHeight; DisableSelectors; RedrawSelectors;
 END SetSmaller;

PROCEDURE* SetLarger;
  VAR h : INTEGER;
 BEGIN
  h := Height;
  REPEAT INC(h); UNTIL SnapHeight(h) # Height;
  Height := SnapHeight(h);
  WriteFontHeight; DisableSelectors; RedrawSelectors;
 END SetLarger;

PROCEDURE* DrawName(Ptr : Objc.parmblkptr) : INTEGER;
  VAR Name : ARRAY 34 OF CHAR;
      c    : CHAR;
      X2,Y2,d,DistBaseTop : INTEGER;
 BEGIN
  Font := VI.VqtName(Station,FontNo,Name);
  VA.VstFont(Station,Font);
  VI.VqtFontinfo(Station,c,c,d,d,d,d,DistBaseTop,d,d,d,d);
  X2 := Ptr.X+Ptr.W-1; Y2 := Ptr.Y+Ptr.H-1;
  VC.VsClip(Station,TRUE,Ptr.X,Ptr.Y,X2,Y2);
  VO.VBar(Station,Ptr.X,Ptr.Y,X2,Y2);
  VO.VGtext(Station,Ptr.X,Ptr.Y + DistBaseTop,Name);
  RETURN 0
 END DrawName;

PROCEDURE Init*(dialog : Dialogs.Dialog; FontName,PrevFont,NextFont,Size,
                Smaller,Larger : INTEGER);
 (* installiert die Routinen dieses Moduls bei "Dialogs", um die Fontauswahl
    zu erm”glichen. Die Parameter "Fontname" bis "Larger" sind die Indizes
    im Objektbaum. Wird dieselbe Dialogbox sp„ter nochmal aufgerufen, braucht
    nicht neu initialisiert zu werden *)
  VAR Ptr : Objc.ptr;
 BEGIN
  ActBox := dialog.objTree; FontIndex := FontName; SizeIndex := Size;
  PrevIndex := PrevFont; NextIndex := NextFont; SmalIndex := Smaller;
  LargIndex := Larger;
  dialog.SetWork(PrevFont,SetPrev,{});
  dialog.SetWork(NextFont,SetNext,{});
  dialog.SetWork(Smaller,SetSmaller,{});
  dialog.SetWork(Larger,SetLarger,{});
  ApplBlk := DrawName;
  Ptr := Objc.GetPtr(dialog.objTree,FontName);
  Ptr^.ObSpec := S.ADR(ApplBlk);
  Ptr^.Type := Objc.PROGDEF;
  DisableSelectors; SetHeight;
 END Init;

BEGIN
  Station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0; Workin.FillPat := 0;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VC.VOpnvwk(Workin,Station,Workout);
  VA.VswrMode(Station,VA.REPLACE);
  VA.VstPoint(Station,13,d,d,d,d);
  VA.VsfPerimeter(Station,FALSE);
  NumFonts := 1;
  IF VC.GDOSinstalled() THEN INC(NumFonts,VC.VstLoadFonts(Station,0)) END;
  FontNo := 1; Font := 1; Height := 10;
END FontSelect.
