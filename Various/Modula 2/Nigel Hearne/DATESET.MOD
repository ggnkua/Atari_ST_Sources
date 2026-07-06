(**************************************************************



DATESET.PRG by Nigel Hearne,  Atari (UK),  5-Oct-1986



DATESET.PRG and DATE.TXT must live in the \AUTO folder.

DATE.TXT contains a string containing the date and an optional message eg.
 
06/10/86Nigel  Hearne's  Disk...

The  optional message may be  up  to  50 characters long.


When the date displays,  if it is the correct date, press CR else type the 
entire date excluding slashes ie 210586 (the slashes will appear automati-
cally).  If you changed the date it will be saved into DATE.TXT so if  you 
re-boot during the day you don't have to keep re-setting the date. When
typing, ESC will abort the process entirely;

Time: must be entered in 24 hour format excluding colon ie 1358, the colon 
will automatically appear...

This is public domain software, do with it what you will!


************************************************************************)




MODULE DateSet;

FROM GEMDOS IMPORT Open,
                   Close,
                   Read,
                   Write,
                   GetDate,
                   SetDate,
                   GetTime,
                   SetTime,
                   NecIn,
                   ConOut;

FROM SYSTEM IMPORT ADR;


                   
TYPE Str20   = ARRAY[0..20] OF CHAR;
     CharSet = SET OF CHAR;

CONST NumSet = CharSet{'0'..'9'};

VAR tCard,
    dateTime : CARDINAL;
    theFile  : INTEGER;
    tLong    : LONGCARD;
    abort    : BOOLEAN;
    putBack  : BOOLEAN;
    theData  : ARRAY[0..7] OF CHAR; (* 22/11/86 *)
    message  : ARRAY[0..60] OF CHAR;
    
PROCEDURE WriteString( VAR s : ARRAY OF CHAR; len : INTEGER );
VAR i : INTEGER;
BEGIN
  FOR i := 0 TO len-1 DO
    ConOut( s[i] );
  END;
END WriteString;

PROCEDURE StringToNum( VAR s: ARRAY OF CHAR; start : CARDINAL): CARDINAL;
BEGIN
  RETURN CARDINAL(ORD(s[start])-48)*10 + CARDINAL(ORD(s[start+1])-48);
END StringToNum;

(* Modula's realy mucky about here... *)
PROCEDURE ShiftBits( VAR b: CARDINAL; shift: CARDINAL );
VAR i,
    c      : CARDINAL;
    source,
    target : BITSET;
BEGIN
  source := BITSET( b );
  FOR c := 1 TO shift DO
    target := {};
    FOR i := 0 TO 14 DO
      CASE i OF
        0 : IF 0  IN source THEN INCL( target, 1 ); END;|
        1 : IF 1  IN source THEN INCL( target, 2 ); END;|
        2 : IF 2  IN source THEN INCL( target, 3 ); END;|
        3 : IF 3  IN source THEN INCL( target, 4 ); END;|
        4 : IF 4  IN source THEN INCL( target, 5 ); END;|
        5 : IF 5  IN source THEN INCL( target, 6 ); END;|
        6 : IF 6  IN source THEN INCL( target, 7 ); END;|
        7 : IF 7  IN source THEN INCL( target, 8 ); END;|
        8 : IF 8  IN source THEN INCL( target, 9 ); END;|
        9 : IF 9  IN source THEN INCL( target, 10 ); END;|
        10: IF 10 IN source THEN INCL( target, 11 ); END;|
        11: IF 11 IN source THEN INCL( target, 12 ); END;|
        12: IF 12 IN source THEN INCL( target, 13 ); END;|
        13: IF 13 IN source THEN INCL( target, 14 ); END;|
        14: IF 14 IN source THEN INCL( target, 15 ); END;|
      ELSE END;
    END;
    source := target;
  END;
  b := CARDINAL( source );
END ShiftBits;

PROCEDURE DoTime();
VAR time : ARRAY [0..1] OF CHAR;
BEGIN
  dateTime := 0;
  message  := 'Time: ';
  WriteString( message, 6 );
  ReadNumChar( time[0] );
  ReadNumChar( time[1] );
  tCard := StringToNum( time,0 ) * 2; (* Hours   *)
  ShiftBits( tCard, 10 );
  INC( dateTime, tCard );

  ConOut( ':' );
  ReadNumChar( time[0] );
  ReadNumChar( time[1] );
  tCard := StringToNum( time, 0 );     (* Mins    *)
  ShiftBits( tCard, 5 );
  INC( dateTime, tCard );

  SetTime( dateTime );
END DoTime;

PROCEDURE DoDate();
VAR c    : CHAR;
    i    : CARDINAL;
BEGIN
  message := 'Date: ';
  WriteString( message, 6 );
  ConOut( theData[0] );
  ConOut( theData[1] );
  ConOut( '/' );
  ConOut( theData[3] );
  ConOut( theData[4] );
  ConOut( '/' );
  ConOut( theData[6] );
  ConOut( theData[7] );

  putBack := FALSE;
  FOR i := 1 TO 8 DO
    ConOut( 10C );
  END;

  NecIn( c );
  abort := c = 33C;
  IF (c IN NumSet) AND (NOT abort) THEN
    ConOut( c );
    putBack := TRUE;
    theData[2] := '/';
    theData[5] := '/';
    theData[0] := c;
    ReadNumChar(theData[1]);
    ConOut( '/' );
    ReadNumChar(theData[3]);
    ReadNumChar(theData[4]);
    ConOut( '/' );
    ReadNumChar(theData[6]);
    ReadNumChar(theData[7]);
  END;
  
  dateTime := 0;
  tCard := StringToNum(theData,0);     (* Day    *)
  ShiftBits( tCard, 0 );
  INC( dateTime, tCard );
    
  tCard := StringToNum(theData,3);     (* Month  *)
  ShiftBits( tCard, 5 );
  INC( dateTime, tCard );
    
  tCard := StringToNum(theData,6);     (* Year   *)
  INC( tCard, 20 );
  ShiftBits( tCard, 9 );
  INC( dateTime, tCard );

  SetDate( dateTime );
  WriteLn;
END DoDate;

PROCEDURE ReadNumChar( VAR c: CHAR );
BEGIN
  REPEAT 
    NecIn( c );
  UNTIL c IN NumSet;
  ConOut( c );
  
END ReadNumChar;

PROCEDURE WriteLn();
BEGIN
  ConOut( 12C );
  ConOut( 15C );
END WriteLn;

BEGIN
  WriteLn;
  Open( '\AUTO\DATE.TXT', 0, theFile );
  IF theFile >= 0 THEN
    tLong := 8;
    Read( theFile, tLong, ADR(theData) );
    tLong := 60;
    Read( theFile, tLong, ADR(message) );
    IF Close( theFile ) THEN END;
    WriteString( message, INTEGER(tLong) );
    WriteLn;
    WriteLn;
    DoDate();
    IF NOT abort THEN
      DoTime();
      IF putBack THEN
        Open( '\AUTO\DATE.TXT', 2, theFile );
        IF theFile >= 0 THEN
          tLong := 8;
          Write( theFile, tLong, ADR(theData) );
          IF Close( theFile ) THEN END;
        END;
      END;
    END;
  END;
END Preset.
 
