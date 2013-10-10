
MODULE Time;

FROM InOut IMPORT Write, Read, WriteLn, WriteString, ReadString, GotoXY;

FROM Clock IMPORT Time, Date, CurrentTime, CurrentDate, SetDateAndTime;

FROM TimeConvert IMPORT TimeToText, DateToText, TextToTime, TextToDate;


CONST ESCchar = 33C; (* ESC-Zeichen *)

PROCEDURE clrEOS; (* lîscht Bildschirm ab Cursorpos. *)
  BEGIN
    Write (ESCchar);
    Write ('J')
  END clrEOS;

PROCEDURE clrEOL; (* lîscht Zeile ab Cursorpos. *)
  BEGIN
    Write (ESCchar);
    Write ('K')
  END clrEOL;

PROCEDURE showDateTime;
  VAR s:ARRAY [0..31] OF CHAR;
  BEGIN
    GotoXY (1,1);
    WriteString ('Das augenblickliche Datum ist ');
    DateToText (CurrentDate (), '', s);
    WriteString (s);
    GotoXY (1,3);
    WriteString ('Die augenblickliche Zeit ist ');
    TimeToText (CurrentTime (), '', s);
    WriteString (s);
  END showDateTime;

PROCEDURE showOK ( ok: BOOLEAN ): BOOLEAN;
  BEGIN
    IF ok THEN
      WriteString ('OK.')
    ELSE
      WriteString ('UngÅltig !')
    END;
    RETURN ok
  END showOK;

PROCEDURE enter ( t: ARRAY OF CHAR; VAR s: ARRAY OF CHAR );
  BEGIN
    GotoXY (0,12);
    WriteString (t);
    ReadString (s);
    WriteLn;
  END enter;

PROCEDURE menu;
  BEGIN
    GotoXY (0,6);
    WriteString ('E(nde');
    WriteLn;
    WriteString ('Z(eit setzen');
    WriteLn;
    WriteString ('D(atum setzen');
  END menu;

VAR selection: CHAR;
    s: ARRAY [0..31] OF CHAR;
    ok: BOOLEAN;
    newTime: Time;
    newDate: Date;

BEGIN
  menu;
  LOOP
    showDateTime;
    
    GotoXY (0,10);
    WriteString ('Ihre Wahl: ');
    clrEOL;                         (* lîscht Zeile ab Cursorpos. *)
    Read (selection);
    
    clrEOS;                         (* lîscht Bildschirm ab Cursorpos. *)
    
    CASE CAP (selection) OF
      'E': EXIT |
      'Z': enter ('Neue Zeit: ',s);
           TextToTime (s,newTime,ok);
           IF showOK (ok) THEN
             SetDateAndTime ( CurrentDate (), newTime )
           END |
      'D': enter ('Neues Datum: ',s);
           TextToDate (s,0,newDate,ok);
           IF showOK (ok) THEN
             SetDateAndTime ( newDate, CurrentTime () )
           END |
    ELSE
    END (* of CASE *)
  END (* of LOOP *)
END Time.
