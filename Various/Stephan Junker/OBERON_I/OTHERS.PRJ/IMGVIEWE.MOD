MODULE IMGViewer;
(*=============================================  Copyright Wolfgang Radtke
|
|  Paket             :  Behandlung IMG-Blîcke
|  Komponente        :  Expansion und Anzeige
|
|
|  Datum        Version   Autor Kommentar
|  ------------ --------- ----- -----------------
|  18.12.1994   01:05     SJ    Anpassung Model
|                               "mark" raus, SetMark raus
|                               "m" im Viewer -> "model"
|  14.08.1994   01:04     Ra    Mit Clipping, Alloc fÅr Farbebenen korrigiert
|                               Clipping/Redraw noch fehlerhaft
|  21.03.1994   01:04     Ra    jetzt ohne Close
|  19.03.1994   01:03     Ra    1. freigegebene Version. Prozedur 'Close'
|                               sollte jedoch eigentlich entfallen
|  01.02.1994   01:02     Ra    Anpassung Oberon
|  13.12.1987   01:00     Ra    File - Erstellung
|
|=========================================================================*)
IMPORT
  S:=SYSTEM, Modl:=Model, WinView, VDIRaster, VDIOutput, Form, VDI,
  VDIControl, File(*, Traces*), Graf;

(*============================ < Declarations > ============================*)
CONST
  TraceInfo     = FALSE;
  TraceRedraw   = FALSE;

TYPE
  FileZeiger =  POINTER TO ARRAY 32000 OF CHAR    (* Zeiger auf akt Pos *);
  BildZeiger =  POINTER TO ARRAY 32000 OF INTEGER (* Expandiertes Bild *);
  (* Grîûenangaben sind Dummys *)

  IMGKopf = RECORD
    version     :  INTEGER;
    kopfLaenge  :  INTEGER;
    farbEbenen  :  INTEGER     (* Anzahl Farbebenen des Source-GerÑtes *);
    musterLaenge:  INTEGER     (* LÑnge fÅr Muster in Bytes *);
    pBreite     :  INTEGER     (* Pixelbreite in Millimeter *);
    pHoehe      :  INTEGER     (* Pixelhîhe in Millimetern *);
    breite      :  INTEGER     (* Breite Scanzeile in Pixeln *);
    anzahlZeilen:  INTEGER     (* Anzahl Scanzeilen *);
  END (* Record IMGKopf *);

  Model*    = POINTER TO ModelDesc;
  ModelDesc*= RECORD (Modl.Desc)
                fileAddr-   : S.PTR;
                daten-      : S.PTR     (* Zeiger auf IMG-Daten *);
                IMG-        : POINTER TO ARRAY OF INTEGER
                                (* Zeiger auf expandiertes Bild *);
                pixMapSize  : LONGINT (* Grîûe expandiertes Bild *);
                fileLen-    : LONGINT;
                anzByte-    : LONGINT   (* Grîûe Datenteil des Image-File *);
                mfdb        : VDIRaster.mfdbrec;
                wBreite-    : INTEGER   (* Breite Zeile in Worten *);
              END;
  Viewer*   = POINTER TO ViewDesc;
  ViewDesc* = RECORD(WinView.ViewDesc)
              END(*RECORD*);


VAR
  Station,d: INTEGER;
  Workin   : VDIControl.workin;
  Workout  : VDIControl.workout;

(*============================ < Procedures   > ============================*)

PROCEDURE (bild: Model) Initialize*();
BEGIN
  bild.Initialize^;
  bild.fileAddr := NIL; bild.fileLen := 0;
END Initialize;


PROCEDURE(v : Viewer) SetModel*(bild: Modl.Ptr);
 (*
 Set the picture to be displayed.
 *)
VAR
  dummy     : INTEGER;
  kopf      : POINTER TO IMGKopf;
BEGIN
  v.SetModel^(bild);
  kopf := bild(Model).fileAddr;
  v.SetLCSize(kopf.breite,kopf.anzahlZeilen);
  v.SetDataWH(kopf.breite,kopf.anzahlZeilen);
  v.SetFullSize(0,0,kopf.breite,kopf.anzahlZeilen);
  IF (v.w>v.fw) OR (v.h>v.fh) THEN v.SetSize(v.fw,v.fh) END;
END SetModel;


PROCEDURE ZeigeInfo (b  : Model);
  (* Gibt Parameter des aktuellen Bildes in extra Fenster aus *)
(*VAR
    kopf        :  POINTER TO IMGKopf;
BEGIN
  kopf := b.fileAddr;
  Traces.I1cr("Version", kopf.version);
  Traces.I1cr("LÑnge Kopf", kopf.kopfLaenge);
  Traces.I1cr("Farbebenen", kopf.farbEbenen);
  Traces.I1cr("LÑnge Muster", kopf.musterLaenge);
  Traces.I1cr("Pixelbreite", kopf.pBreite);
  Traces.I1cr("Pixelhîhe", kopf.pHoehe);
  Traces.I1cr("Breite Scanzeile", kopf.breite);
  Traces.I1cr("Anzahl Scanzeilen", kopf.anzahlZeilen);
  Traces.I1cr("Breite Scanzeile in Worten", b.wBreite);
  Traces.I1cr("Filegrîûe in Byte", b.fileLen);*)
END ZeigeInfo;

PROCEDURE(v: Viewer) Redraw*(x,y,w,h: INTEGER);
VAR
  screen    : VDIRaster.mfdbrec;
  pxyArray  : VDIRaster.pxyarray;
BEGIN
  (* pxyarray initalisieren *)
  pxyArray[0]:= SHORT(v.xOff)+ x-v.x;
  pxyArray[1]:= SHORT(v.yOff)+ y-v.y;
  pxyArray[2]:= pxyArray[0]+w-1;
  pxyArray[3]:= pxyArray[1]+h-1;
  pxyArray[4]:= x;
  pxyArray[5]:= y;
  pxyArray[6]:= x+w-1;
  pxyArray[7]:= y+h-1;
  IF TraceRedraw THEN
(*    Traces.I4cr("Redraw-Pos auf Monitor (x,y,w,h)",x,y,w,h);
    Traces.I4cr("Offset + Width von Daten",v.xOff,v.yOff,v.dw,v.dh);
    Traces.I2cr("v.x, v.y",v.x,v.y);
    Traces.I4cr("pxyarray
0-3",pxyArray[0],pxyArray[1],pxyArray[2],pxyArray[3]);
    Traces.I4cr("pxyarray
4-7",pxyArray[4],pxyArray[5],pxyArray[6],pxyArray[7]);*)
  END (* IF *);
  (* mfdb 'Screen' initialisieren *)
  screen.Addr:= 0;
  VDIControl.VsClip(Station,TRUE,x,y,x+w-1,y+h-1);
  VDIRaster.VroCpyfm(Station,3,pxyArray,v.model(Model).mfdb,screen);
END Redraw;


  (*-------------------------------------------------------------------------
  |  Erzeugung eines "Solid Run"
  |  Beispiel :  SolidRun (ptr, zeile, anz);
  |-------------------------------------------------------------------------*)
  PROCEDURE SolidRun
  ( VAR ptr     :  FileZeiger   (* i/o Zeiger auf Anfang/Ende Solid Run *);
    VAR zeile   :  FileZeiger   (*  /o Ausgabezeile *);
    VAR anz     :  INTEGER     (*  /o Anzahl Bits im Solid Run *)
  );
  VAR
    i           :  INTEGER;
    wert        :  CHAR;
  BEGIN
    i := ORD (ptr^[0]) MOD 128   (* Anzahl Byte *);
    IF i = ORD (ptr^[0]) THEN
      wert := 0X;
    ELSE
      wert := 0FFX;
    END (* IF *);
    anz :=  i * 8       (* Anzahl Bit *);
    WHILE i > 0 DO
      zeile^[0] :=  wert;
      DEC (i);
      INC (zeile);
    END (* WHILE *);
    INC (ptr)           (* verschieben um ein Byte *);
  END SolidRun;

  (*-------------------------------------------------------------------------
  |  Erzeugung eines "Pattern"
  |  Beispiel :  Pattern (ptr, zeile, anz, musterLaenge);
  |-------------------------------------------------------------------------*)
  PROCEDURE Pattern
  ( VAR ptr     :  FileZeiger   (* i/o Zeiger auf Anfang/Ende Pattern *);
    VAR zeile   :  FileZeiger   (*  /o Ausgabezeile *);
    VAR anz     :  INTEGER      (*  /o Anzahl Bits im gesamten Pattern *);
        musterl :  INTEGER      (* i/  MusterlÑnge in Bytes *)
  );
  VAR
    i,j         :  INTEGER;
  BEGIN
    i   :=  ORD (ptr^[1])     (* Anzahl Muster *);
    anz := i * musterl*8               (* MusterlÑnge in Bits bestimmen *);
    WHILE i>0 DO
      FOR j := 0 TO musterl-1 DO
        zeile^[0]:= ptr^[2+j];
        INC (zeile);
      END (* FOR *);
      DEC (i);
    END (* WHILE *);
    INC (ptr,2+musterl)         (* Um 2 Byte + musterLaenge verschieben *);
  END Pattern;


  (*-------------------------------------------------------------------------
  |  Darstellung eines "BitString"
  |  Beispiel :  BitString (ptr, zeile, anz);
  |-------------------------------------------------------------------------*)
  PROCEDURE BitString
  ( VAR ptr     :  FileZeiger   (* i/o Zeiger auf Anfang/Ende BitString *);
    VAR zeile   :  FileZeiger   (*  /o Ausgabezeile *);
    VAR anz     :  INTEGER     (*  /o Anzahl Bits im Solid Run *)
  );
  VAR
    i           :  INTEGER;
    j           :  INTEGER;
  BEGIN
    i := ORD (ptr^[1]);
    INC (ptr,2);
    FOR j := 0 TO i-1 DO
      zeile^[j] := ptr^[j];
    END (* FOR *);
    anz         := i*8;
    INC (ptr,i)         (* LÑnge Bitstring *);
    INC (zeile,i)       (* Auch hier um LÑnge Bitstring verschieben *);
  END BitString;


  (*-------------------------------------------------------------------------
  |  Erzeugung einer "Wiederholung"
  |  Beispiel :  Wiederholung (ptr);
  |-------------------------------------------------------------------------*)
  PROCEDURE Wiederholung
  ( VAR ptr     :  FileZeiger  (* i/o Zeiger auf Anfang/Ende Wiederholung *)
  );
  VAR
    i           :  INTEGER;
  BEGIN
    INC (ptr,4);
  END Wiederholung;

  (*-------------------------------------------------------------------------
  |  Analyse einer IMG-Datei, hier Analyse einer Zeile
  |  Beispiel :  ZeilenAnalyse (par, zeile, anfang);
  |-------------------------------------------------------------------------*)
  PROCEDURE ZeilenAnalyse
    (     par       :  IMGKopf          (* i/  Parameterblock der Datei *);
          zeile     :  FileZeiger       (* i/  Anfang der Zeile im Speicher *);
      VAR anfang    :  FileZeiger       (* i/o aktuelle Position im File *)
    );
  VAR
    spalte      :  INTEGER     (* aktuelle Spaltennummer *);
    byte1       :  INTEGER     (* Hilfsvariable zur Decodierung *);
    anz         :  INTEGER     (* Anzahl bearbeiteter Bits in Operation *);
  BEGIN
    spalte    :=  0           (* erste Spalte dieser Zeile *);
    WHILE spalte < par.breite DO  (* noch nicht zeilenende *)
      byte1   :=  ORD (anfang^[0]);
      IF byte1 = 128 (* also nur hîchstes Bit gesetzt *) THEN
        BitString (anfang,  zeile, anz);
      ELSIF byte1 # 0 THEN
        SolidRun (anfang, zeile, anz);
      ELSE
        Pattern (anfang, zeile, anz, par.musterLaenge);
      END (* IF *);
      spalte := spalte+anz      (* neue Spaltenposition *);
    END (* While Abarbeitung einer Zeile *);
  END ZeilenAnalyse;


  (*-------------------------------------------------------------------------
  |  Analyse einer IMG-Datei
  |  Beispiel :  KompletteAnalyse (par, MFDB);
  |-------------------------------------------------------------------------*)
  PROCEDURE KompletteAnalyse
    ( bild      :  Model      (* i/  Parameterblock der Datei *);
      MFDB      :  VDIRaster.mfdbrec     (* i/  Speicherbereich fÅr
expandiertes Bild *)
    );
  VAR
    i           :  INTEGER     (* Laufvariable *);
    aktPlane    :  INTEGER      (* Laufvariable aktuelle Farbebene *);
    anfang      :  FileZeiger   (* aktuelle Position im File *);
    zeile       :  INTEGER     (* aktuelle Zeilennummer *);
    line        :  FileZeiger   (* aktuelle Zeile im MFDB *);
    oldLine     :  FileZeiger   (* Anfang der aktuellen Zeile im MFDB *);
    wid         :  INTEGER     (* Anzahl Wiederholungen *);
    kopf        :  POINTER TO IMGKopf;
  BEGIN
    anfang      :=  bild.daten    (* Zeiger auf Bild-Anfang *);
    kopf        :=  bild.fileAddr (* Zeiger auf Fileheader *);
    zeile       :=  0           (* anfang *);
    wid         :=  0           (* vorbelegen mit keine Wiederholungen *);
    WHILE zeile < kopf.anzahlZeilen DO       (* Ende noch nicht erreicht *)
      FOR aktPlane := 1 TO MFDB.Planes DO
          line      :=  S.VAL(FileZeiger,MFDB.Addr +  (LONG(zeile) *
LONG(MFDB.WidthW) * 2)+
                        S.VAL(LONGINT,(aktPlane-1) *bild.pixMapSize));
          IF (anfang^[0] = 0X) AND
             (anfang^[1] = 0X) AND
             (anfang^[2] = 0FFX)
          THEN
            oldLine := line;
            wid     :=  ORD (anfang^[3])       (* Anzahl Wiederholungen *);
            IF zeile+wid>kopf.anzahlZeilen THEN (* darf nie sein *)
              wid := kopf.anzahlZeilen-zeile-1;
            END (* IF *);
            Wiederholung (anfang);
            ZeilenAnalyse (kopf^, line, anfang) (* zu kopierende Zeile aufbauen
*);
            WHILE wid > 0 DO
              line      :=  S.VAL(FileZeiger,MFDB.Addr +  (LONG(zeile) *
LONG(MFDB.WidthW) * 2)+
                            S.VAL(LONGINT,(aktPlane-1) *bild.pixMapSize));
              FOR i := 0 TO MFDB.WidthW * 2 - 1 DO
                line^[i] :=  oldLine^[i];
              END (* FOR *);
              DEC (wid); INC (zeile); oldLine   :=  line;
            END (* WHILE *);
            DEC(zeile);
          ELSE
            wid     :=  0;
            ZeilenAnalyse (kopf^, line, anfang);
          END (* IF Wiederholung *);
      END (* FOR alle Farbebenen *);
      INC (zeile);
    END (* Abarbeitung gesamter File *);
  END KompletteAnalyse;

PROCEDURE(bild : Model) Load*(name : ARRAY OF CHAR);
  (*
  Loads a IMG-file with given name using File.Load and displays it in
  viewer v. The viewer is not opened. For definition of mark see above.
  If loading fails, v.model.fileAdr will not be changed (NIL after
  Init). The name will be set as title.
  *)
VAR
  dummy     : INTEGER;
  kopf      :  POINTER TO IMGKopf;
BEGIN
  IF File.Load(name,0,0,bild.fileAddr,bild.fileLen) THEN
    kopf := bild.fileAddr;
    bild.anzByte:=bild.fileLen-2*kopf.kopfLaenge (* Angabe war in Worten *);
    bild.wBreite:= ((kopf.breite+15) DIV 16)*2 (* Breite Scanzeile in Worten*);
    bild.daten := bild.fileAddr;
    INC (bild.daten,2*kopf.kopfLaenge);
    IF TraceInfo THEN
      ZeigeInfo(bild);
    END (* IF Trace *);
    (* Init mfdb *)
    bild.mfdb.Width := kopf.breite;
    bild.mfdb.Height := kopf.anzahlZeilen;
    bild.mfdb.WidthW := bild.wBreite;
    bild.mfdb.Format := 1 (*Standard *);
    bild.mfdb.Planes := kopf.farbEbenen;
    IF kopf.farbEbenen>1 THEN
      (* Geht (noch) nicht mit mehreren Farbebenen *)
      dummy := Form.Alert(1,"[3]Derzeit nur s/w-Bilder darstellbar[Schade]");
      bild.fileAddr := NIL;
    ELSE
      (* ALLOCATE Platz fÅr Bild *)
      bild.pixMapSize := LONG(bild.wBreite)*LONG(kopf.anzahlZeilen);
      NEW(bild.IMG,bild.pixMapSize*kopf.farbEbenen);
      bild.mfdb.Addr:= S.VAL(S.PTR,bild.IMG);
      IF TraceInfo THEN
(*        Traces.I1cr("Adresse Bildbereich", S.VAL(LONGINT,bild.IMG));
        Traces.I1cr("Grîûe Bildbereich", bild.pixMapSize);*)
      END (* IF Trace *);
      KompletteAnalyse(bild,bild.mfdb);
    END (* 1 Farbebene geht (meist) *);
  END (* IF *);
END Load;


(*============================ < Init Module  > ============================*)
BEGIN
  Station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 1; Workin.FillPat := 0;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VDIControl.VOpnvwk(Workin,Station,Workout);
END IMGViewer.