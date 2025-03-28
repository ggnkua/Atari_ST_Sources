{------------------------------------------------
Anwendung Parametrischer Prozeduren/Funktionen
zur Automatisierung von Fenster-Redraws bei
Verwendung einer allgemeinen Event-Routine.

Beispiel: Aufbau von Fenstern, Definition einer
          allgemeinen Zeichenroutine fÅr die
          Fensterinhalte und Verwaltung via
          neuer AutoRedraw_Event-Routine.

(C) Rolf Darr, Oktober 1990

entwickelt mit und fÅr ST-Pascal+ V.2.08 (CCD)
------------------------------------------------}
{$I-,C-}
PROGRAM FensterRedrawTest;

CONST
  {$I gemconst.pas}
  KeinFenster     =   0;
  MaxFenster      =   4;

TYPE
  {$I gemtype.pas}
  SemaphorTyp     =   KeinFenster..MaxFenster;

VAR
  {Globale Verwaltung}
  ApplNr          :   Integer;    {klar!}

  {Globale Fenstervariablen}
  FensterSemaphor :  SemaphorTyp;
  FensterTitel    :  Window_Title;


{$I gemsubs.pas}   {alle Routinen aus PASGEM}

{ ZusÑtzlich noch die neue Auto-Redraw-Event-Funktion}
{================================================
 DIESEN TEIL IN EINE INCLUDE-DATEI SPEICHERN ODER
 AN DAS ENDE DER DATEI GEMSUBS.PAS HéNGEN.
 DIE OBJEKTDATEI DES PROGRAMMODULS AUS LISTING 1
 ALS ZUSéTZLICHE LINKDATEI EINTRAGEN UND DIE
 NEUE FUNKTION IMMER DANN STATT DER ALTEN VER-
 WENDEN, WENN FENSTERINHALTE AUTOMATISCH GEZEICH-
 NET WERDEN SOLLEN.
================================================}
FUNCTION AutoRedraw_Event 
         ( EventMask, ButtonMask,
           ButtonState, NClicks: Short_Integer;
           Ticks               : Long_Integer;
           r1Flag              : Boolean;
           r1x, r1y, r1w, r1h  : Short_Integer;
           r2Flag              : Boolean;
           r2x, r2y, r2w, r2h  : Short_Integer;
           VAR Message         : Message_Buffer;
           VAR Key,
               BState, BCount  : Short_Integer;
           VAR mx, my          : Short_Integer;
           VAR KbdState        : Short_Integer;

           PROCEDURE Draw (WindowHandle,
                           x,y,w,h:Short_Integer)
         ):  Short_Integer;
  EXTERNAL;
{===============================================}

{----- Eine allgemeine Zeichenfunktion fÅr Fensterinhalte -----}
Procedure FensterDraw ( Handle, x,y,w,h: Integer );
  Begin{FensterDraw}
    Paint_Color ( White );
    Line_Color ( Black );
    Draw_Mode ( 1 );
    Set_Clip( x, y, w, h );
    Paint_Rect( x, y, w, h );    { leeren }
    Frame_Rect( x, y, w, h );    { Kasten }
    PLine( x, y, x+w-1, y+h-1 ); { X in Kasten }
    PLine( x+w-1, y, x, y+h-1 );
  End{FensterDraw};

{----- Fenster îffnen -----}
Function FensterAuf ( FensterSemaphor:SemaphorTyp ): SemaphorTyp;
  Var
    hand: integer;
  Begin{FensterAuf}
    IF FensterSemaphor < MaxFenster
      THEN
        BEGIN
          FensterSemaphor:= succ ( FensterSemaphor );
          hand:=  New_Window (G_Name|G_Close|G_Move|G_Size, FensterTitel, 0,0,0,0);
          Open_Window (hand, 20*FensterSemaphor, 20*FensterSemaphor, 200,120);
        END;
    FensterAuf:=  FensterSemaphor
  End{FensterAuf};

{----- Initialisierungen -----}
Procedure FensterInit (VAR semaphor: SemaphorTyp);
  Begin{FensterInit}
    FensterTitel:=  ' Fenster ';
    semaphor:=  KeinFenster;
    REPEAT
      semaphor:=  FensterAuf ( semaphor )
    UNTIL semaphor = MaxFenster
  End{FensterInit};

{----- Fenster schlieûen -----}
Procedure FensterZu ( hand: Integer );
  Begin{FensterZu}
    close_window ( hand );
    delete_window ( hand )
  End{FensterZu};

{----- Die Eventverwaltung -----}
Procedure event_loop;

  Const
    M_Type    =   0;    {Message Index}
  Var
    event:              integer;
    msg:                message_buffer;
    key,
    bcnt,bstate, mx,my,
    kbd_state:          integer;

s:string;dummy:integer;

  Begin
    REPEAT
      event:= AutoRedraw_Event 
                ( E_Keyboard|E_Message,
                  0,0,0,              { diverse }
                  0,                  { timer }
                  false,0,0,0,0,      { mouse(r1) }
                  false,0,0,0,0,      { mouse(r2) }
                  msg,                { message-buffer }
                  key,                { keyboard-code }
                  bcnt,bstate, mx,my, { mouse-states }
                  kbd_state,          { sondertasten }
                  FensterDraw         { die Zeichenroutine}
                );
     
      IF event&E_Message = E_Message
        THEN  
          CASE msg[M_Type]
          OF
            WM_Topped:  Bring_To_Front (msg[3]);
            WM_Closed:  BEGIN
                          FensterZu (msg[3]);
                          FensterSemaphor:= pred (FensterSemaphor)
                        END;
            WM_Sized,
            WM_Moved:   Set_WSize (msg[3], msg[4],msg[5],msg[6],msg[7])
          END{ Case };

      IF event&E_Keyboard = E_Keyboard
        THEN {Tastatur-Verwaltung}
          BEGIN
            WriteV ( s, '[1][Taste = $',key:4:h,' ][  OK  ]' );
            Dummy:= Do_Alert (s,1)
          END;
    UNTIL FensterSemaphor = KeinFenster;
  End{ event_loop };

{--------------- Hauptprogramm ---------------}
BEGIN
  ApplNr:=  Init_Gem;
  IF ApplNr>=0
    THEN
      BEGIN
        Init_Mouse;
        FensterInit (FensterSemaphor);
        event_loop;
        exit_gem
      END
END{Hauptprogramm}.

