{------------------------------------------------
Anwendung Parametrischer Prozeduren/Funktionen
zur Erzeugung von Prozeduradressen.

Beispiel: Einbau einer eigenen Zeichenroutine
          in ein Dialogitem vom Typ G_ProgDef.

(C) Rolf Darr, Oktober 1990

entwickelt mit und fÅr ST-Pascal+ V.2.08 (CCD)

------------------------------------------------}
{$I-,C-,D-,P-,R-,T-}   {kein Debugging/PrÅfungen}
PROGRAM DialogTest;

CONST
  {$I gemconst.pas}


TYPE
  {$I gemtype.pas}

  ParmBlkPtr=   ^ParmBlk;
  ParmBlk   =   RECORD
                  PtoDial:      Dialog_Ptr;   {Zeiger auf Objektbaum}
                  ObjNr:        Integer;      {Objektnummer}
                  PrevState:    Integer;      {vorheriger Status}
                  CurrState:    Integer;      {neuer Status}
                  PbX:          Integer;      {Koordinaten}
                  PbY:          Integer;
                  PbW:          Integer;      {    -"-    }
                  PbH:          Integer;
                  XClip:        Integer;      {Begrenzungsrechteck}
                  YClip:        Integer;
                  WClip:        Integer;      {        -"-        }
                  HClip:        Integer;
                  PbParm:       Long_Integer; {Parameter aus USRBLK}
                END;

  UsrBlkPtr =   ^User_Blk;


VAR
  {Globale Verwaltung}
  ApplNr        :   Integer;    {klar!}
  VdiHandle     :   Integer;    {der Workstation}
  {FÅr das Special-Item:}
  SpecialStyle  :   Integer;    {Index FÅllmuster}
  UbSpecial     :   UsrBlkPtr;  {User-Block}

  {Variablen fÅr den Dialog}
  MyDialog      :   Dialog_Ptr;
  {Dialog-Items}
  ErgItem,                      {nur als Dummy}
  DialOk,                       {Dialog-Ausgang}
  Special       :   Integer;    {ProgDef-Item}



{$I gemsubs.pas}   {alle Routinen aus PASGEM}

{  zusÑtzlich benîtigen wir noch folgende VDI-Routinen
   innerhalb der Zeicheroutine fÅr das Special-Item,
   da wir die entsprechenden PASGEM-Routinen leider
   nicht verwenden kînnen.}
   
{----- v_rfbox :- Filled Rounded Rectangle VDI 11/9 -----}
PROCEDURE v_rfbox ( Handle: Integer; x1,y1, x2,y2:Integer );
  CONST
    Opcode      = 11;
    SubOpCode   = 9;
    AnzIntIn    = 0;
    AnzPunkte   = 4;
  VAR
    Ctrl      : Ctrl_Parms ;
    IntIn     : Int_In_Parms ;
    IntOut    : Int_Out_Parms ;
    PtsIn     : Pts_In_Parms ; 
    PtsOut    : Pts_Out_Parms ;
  BEGIN{v_rfbox}
    Ctrl[6]:= Handle;
    PtsIn[0]:=  x1;
    PtsIn[1]:=  y1;
    PtsIn[2]:=  x2;
    PtsIn[3]:=  y2;
    VDI_Call ( Opcode,SubOpCode,AnzIntIn,AnzPunkte,
               Ctrl, IntIn, IntOut, PtsIn, PtsOut, False )
  END{v_rfbox};

{----- vsf_style :- Set Fill Style Index VDI 24 -----}
PROCEDURE vsf_style ( Handle: Integer; StyleIndex: Integer );
  CONST
    Opcode      = 24;
    SubOpCode   = 0;
    AnzIntIn    = 1;
    AnzPunkte   = 0;
  VAR
    Ctrl      : Ctrl_Parms ;
    IntIn     : Int_In_Parms ;
    IntOut    : Int_Out_Parms ;
    PtsIn     : Pts_In_Parms ; 
    PtsOut    : Pts_Out_Parms ;
  BEGIN{vsf_style}
    Ctrl[6]:= Handle;
    IntIn[0]:=  StyleIndex;
    VDI_Call ( Opcode,SubOpCode,AnzIntIn,AnzPunkte,
               Ctrl, IntIn, IntOut, PtsIn, PtsOut, False )
  END{vsf_style};

{sowie die AES-Funktion:}

{----- Graf_Handle (AES 77) -----}
FUNCTION GrafHandle ( VAR cw, ch,  bw, bh: Integer ): Integer;
  VAR
    IntIn:  Int_In_Parms;
    IntOut: Int_Out_Parms;
    AdrIn:  Addr_In_Parms;
    AdrOut: Addr_Out_Parms;
  BEGIN{GrafHandle}
    AES_Call (77, IntIn, IntOut, AdrIn, AdrOut);
    GrafHandle:= IntOut[0];
    cw:= IntOut[1];
    ch:= IntOut[2];
    bw:= IntOut[3];
    bh:= IntOut[4];
  END{GrafHandle};


{Die externe Funktion aus dem Modul von Listing 3
 hier fÅr unsere Zwecke umdeklariert:}
FUNCTION Adr_Proc ( PROCEDURE f(pb: ParmBlkPtr) ): Long_Integer;
  EXTERNAL;


{----- die Draw-Routine fÅr das SPECIAL-ITEM -----}

PROCEDURE DrawSpecial  ( pb: ParmBlkPtr );
  CONST
    LastStyle =   24;
  BEGIN{DrawSpecial}
    WITH pb^
      DO
      BEGIN
        IF CurrState&Selected<>PrevState&Selected  {angeklickt?}
          THEN  
            BEGIN
              {nÑchstes FÅllmuster: wir zÑhlen einfach den Index
               von 1 bis 24 im Rundlauf}
              SpecialStyle:=  (SpecialStyle+1) MOD LastStyle;
              Write (#7); {und klingeln}
              {FÅllmuster setzen}
            END;
        vsf_style ( VdiHandle, SpecialStyle+1 );
        {Normalerweise mÅûte hier noch der Clip-Bereich eingestellt
         werden, was natÅrlich auch nicht mit der PASGEM-Routine
         "Set_Clip" geschehen darf, sondern mit der extra definierten
         VDI-Routine "Set clipping rectabgle" (129). Hier unnîtig!}
        {Gebilde ganz zeichnen}
        v_rfbox (VdiHandle, PbX, PbY, PbX+PbW, Pby+PbH);
      END
  END{DrawSpecial};


{---------------- Dialog erstellen ----------------}

Procedure SetUsrBlk;    {trÑgt die Funktionsadresse und den Wert
                         des optionalen Parameters in die UsrBlk-
                         Strukur ein}
  Var
    FunctionAdress: Long_Integer;
  Begin{SetUsrBlk}
    New (UbSpecial);
    FunctionAdress:=  Adr_Proc ( DrawSpecial );
    WITH UbSpecial^
      DO
      BEGIN
        ub_code:= FunctionAdress;
        ub_parm:=  0
      END
  End{SetUsrBlk};

Procedure SetOb_spec ( VAR Obj: Object );
                        {hÑngt die globale UsrBlk-Struktur in
                         den Ob_Spec-Zeiger eines Objektes ein}
  Begin{SetOb_spec}
    Obj.ob_spec.ptr:= Ord( UbSpecial );
  End{SetOb_spec};

Function MakeDialog: Dialog_Ptr;    {Beispiel-Dialog erstellen}
  Const
    MaxItems    =    5;     {etwas Luft nach hinten}
    Xpos        =    0;     {wird sowieso zentriert}
    Ypos        =    0;
    W           =   36;     {kann verÑndert werden}
    H           =   12;
  Var
    Dial:   Dialog_Ptr;
    Dummy:  Integer;
  Begin{MakeDialog}
    {Einstellungen zum Zeichnen. Hier kînnen noch die PASGEM-
     Routinen verwendet werden, weil wir noch nicht innerhalb
     des AES sind!}
    Paint_Style ( 2 );  {setzt intern den FÅlltyp auf 2 und
                         den Musterindex auf 1. Spart die
                         Deklaration von SetFillInteriorIndex
                         (VDI 23), daher nîtig}
    {Die anderen Einstellungen}
    Paint_Color ( Black );
    Draw_Mode ( 1 {Replace!} );
    Line_Style ( 1 );
    Paint_Outline ( True );

    {Speicherplatz reservieren}
    Dial:=  New_Dialog ( MaxItems, Xpos,Ypos,W,H );

    {Die Items eintragen}
    DialOk:=  Add_Ditem ( Dial, G_BoxText, Selectable|Default|Exit_Btn,
                          (W DIV 2)-5, H-3, 10,2, -2, 
                          D_Color(Black,Black,True, 0, 0)
                        );
    Set_Dtext ( Dial, DialOk, 'OK', System_Font, TE_Center );
    Obj_SetState ( Dial, DialOk, Shadowed, False );

    Special:= Add_Ditem ( Dial, G_ProgDef{!!!}, Selectable,
                          2, 1, W-4, H-6, 0, 0);
    Obj_SetState ( Dial, Special, Normal, False );
    SpecialStyle:=  0;      {nur als Initialisierung}
    {Die Spezialfunktion einbinden...}
    SetUsrBlk;
    SetOb_spec ( Dial^[Special]);

    {Den Dialog in die Mitte bringen}
    Center_Dialog ( Dial );

    {Globalen Vdi-Handle fÅr Draw-Funktionen holen}
    VdiHandle:= GrafHandle (Dummy,Dummy,Dummy,Dummy);

    {und fertig: den Zeiger retournieren}
    MakeDialog:=  Dial
  End{MakeDialog};

{--------------- Hauptprogramm ---------------}
BEGIN
  ApplNr:=  Init_Gem;
  IF ApplNr>=0
    THEN
      BEGIN
        Init_Mouse;
        MyDialog  :=  MakeDialog;
        ErgItem   :=  Do_Dialog (MyDialog,0);
        End_Dialog (MyDialog);
        Delete_Dialog (MyDialog);
        Dispose (UbSpecial);  {sollte noch freigegeben werden}
        exit_gem
      END
END{Hauptprogramm}.

