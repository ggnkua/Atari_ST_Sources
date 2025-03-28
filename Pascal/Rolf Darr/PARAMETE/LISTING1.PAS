{------------------------------------------------
Anwendung Parametrischer Prozeduren/Funktionen
zur Automatisierung von Fenster-Redraws bei
Verwendung einer allgemeinen Event-Routine.

Modul mit Funktion AutoRedraw_Event

(C) Rolf Darr, Oktober 1990

entwickelt mit und fÅr ST-Pascal+ V.2.08 (CCD)
------------------------------------------------}

{$I-,C-,D-,P-,T-}   {kein Debugging/PrÅfungen}
{$M+} {Modul}
PROGRAM Modul_AutoRedraw_Event;

CONST
  {$I gemconst.pas}


TYPE
  {$I gemtype.pas}


{----- die folgenden Subroutinen aus PASGEM -----}
FUNCTION Get_Event(     emask, bmask, bstate, n_clicks : short_integer ;
                        ticks : long_integer ;
                        m1_flag : boolean ; m1x, m1y, m1w, m1h : short_integer ;
                        m2_flag : boolean ; m2x, m2y, m2w, m2h : short_integer ;
                        VAR message : Message_Buffer ;
                        VAR key, brtn, bclick, mx, my, kstate : short_integer
                        ) : short_integer ;
  EXTERNAL ;
PROCEDURE Begin_Update ;
  EXTERNAL ;
PROCEDURE End_Update ;
  EXTERNAL ;
PROCEDURE Hide_Mouse ;
  EXTERNAL ;
PROCEDURE Show_Mouse ;
  EXTERNAL ;
PROCEDURE First_Rect( wind : short_integer ; VAR x, y, w, h : short_integer ) ;
  EXTERNAL ;
PROCEDURE Next_Rect( wind : short_integer ; VAR x, y, w, h : short_integer ) ;
  EXTERNAL ;
FUNCTION Rect_Intersect( x, y, w, h : short_integer ; VAR x1, y1, w1, h1 : short_integer )
                        : boolean ;
  EXTERNAL ;



{$E+} {----- die neue Eventfunktion -----}
Function AutoRedraw_Event ( EventMask   ,
                            ButtonMask  ,
                            ButtonState ,
                            NClicks             : Integer;
                            Ticks               : Long_Integer;
                            r1Flag              : Boolean;
                            r1x, r1y, r1w, r1h  : Integer;
                            r2Flag              : Boolean;
                            r2x, r2y, r2w, r2h  : Integer;
                            VAR Message         : Message_Buffer;
                            VAR Key,
                                BState, BCount  : Integer;
                            VAR mx, my          : Integer;
                            VAR KbdState        : Integer;

                            PROCEDURE Draw (WindowHandle, x,y,w,h:  Integer)
                          ):  Integer;

  Const
    MessageType     = 0;
    MesWindowHandle = 3;
    MesX            = 4;  {Die Koordianten }
    MesY            = 5;  {des zu          }
    MesW            = 6;  {aktualisierenden}
    MesH            = 7;  {Bereiches       }
    NoEvent         = 0;  {kein Event mehr}

  Var
    TempEvent:  Integer;
    {Koordinaten}
    x,y,w,h:    Integer;

  Begin{AutoRedraw_Event}
    REPEAT  {so lange es nur Redraw-Events gibt}
      TempEvent:= Get_Event ( EventMask|E_Message, {falls noch nicht enthalten} 
                              ButtonMask, ButtonState, NClicks,
                              Ticks,
                              r1Flag, r1x, r1y, r1w, r1h,
                              r2Flag, r2x, r2y, r2w, r2h,
                              Message,
                              Key, BState, BCount,
                              mx, my,
                              KbdState
                            );
      IF TempEvent&E_Message=E_Message
        THEN  {nur auf Redraw-Meldungen reagieren}
          IF Message[MessageType] = WM_Redraw
            THEN  {den automatischen Redraw organisieren}
              BEGIN
              {Rechtecklisten abarbeiten}
                Begin_Update;
                Hide_Mouse;
                First_Rect (Message[MesWindowHandle], x,y,w,h);
                WHILE (w<>0) AND (h<>0)
                  DO
                  BEGIN
                    IF Rect_Intersect (Message[MesX],Message[MesY],Message[MesW],Message[MesH],x,y,w,h)
                      THEN Draw (Message[MesWindowHandle], x,y,w,h);
                    Next_Rect (Message[MesWindowHandle], x,y,w,h)
                  END;
                Show_Mouse;
                End_Update;
              {und den verarbeiteten Event ausblenden}
                TempEvent:= TempEvent & (~E_Message)
              END
    UNTIL TempEvent <> NoEvent;
    AutoRedraw_Event:=  TempEvent
  End{AutoRedraw_Event};
{$E=}

BEGIN   {Module haben kein Hauptprogramm}
END.

