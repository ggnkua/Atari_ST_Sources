PROGRAM Set_Time( input, output );   {--- Program by Ric Mears, 2/2/1986 --}

TYPE  Word                   = Integer;
      Response               = String[12];
      One_Letter             = String[1];

VAR   Time, Date,
      Second, Minute, Hour,
      Day, Month, Year       : Word;
      PM                     : Boolean;
      Input                  : Response;
      Answer, esc            : Char;


{ --EXTERNAL ROUTINES-- }

FUNCTION  GetDate: Word;          GEMDOS( $2a );
FUNCTION  GetTime: Word;          GEMDOS( $2c );
PROCEDURE SetDate( Date: Word );  GEMDOS( $2b );
PROCEDURE SetTime( Time: Word );  GEMDOS( $2d );


{ --LOCAL ROUTINES-- }

PROCEDURE Clear_Screen;  { and turn on cursor, and display title too }
BEGIN
   esc := chr(27);
   writeln( esc,'E',esc,'e','       for your Auto folder:',esc,'B');
   writeln( esc,'p TIME SET - A freebie by Ric Mears ',
            esc,'q',esc,'B',esc,'B');
END;


PROCEDURE Cursor_Off;
BEGIN
   write( esc,'f' );
END;


PROCEDURE Display_Time; {-----------------------------------------------------}
BEGIN
       { --get system info-- }
   Time := GetTime;
       { --unpack & reformat the data-- }
   Second := ( Time & $1F ) * 2;
   Minute := ( Time & $7e0 ) DIV $20;
   Hour   := ((( Time & $f800 ) DIV $800 ) & $1f );
   PM     := Hour > 11;
   IF Hour = 0 THEN Hour := 12;
   IF Hour > 12 THEN Hour := Hour - 12;
       { --print it out-- }
   Write('System Time is: ',Hour:1,':');
   IF Minute < 10 THEN write('0');
   Write( Minute:1 );
   IF PM THEN writeln(' PM' ) ELSE writeln(' AM');
END; {procedure Display Time}


PROCEDURE Set_Time; {---------------------------------------------------------}
BEGIN
   Time := GetTime;
   Time := Time & $1F;
   Time := Time | (Minute * $20);
   IF PM THEN IF Hour < 12 THEN Hour := Hour + 12;
   IF NOT PM THEN IF Hour = 12 THEN Hour := 0;
   Time := Time | (Hour * $800);
   Settime( Time );
END; {procedure Set_Time}


PROCEDURE Display_Date; {-----------------------------------------------------}
BEGIN
      { --get system info-- }
   Date := GetDate;
      { --unpack & reformat it-- }
   Day    := ( Date & $1f );
   Month  := ( Date & $1e0 ) DIV $20;
   Year   := (( Date & $fe00 ) DIV $200 ) + 1980;

   Writeln('System Date is: ',Month:1,'/',Day:1,'/',Year:4 );
END; {procedure Display Date}


PROCEDURE Set_Date; {---------------------------------------------------------}
BEGIN
   Date := Day;
   Date := Date + (Month * $20);
   Date := Date + ( (Year-1980) * $200 );
   SetDate( Date );
END; {procedure Set_Time}


PROCEDURE Get_New_Time; {---------------------------------------------------}
BEGIN
   Writeln;
   Writeln('  Correct TIME:          ',
           'or <Return>');
   Write  (' -any separator-',esc,'A');
   Readln( input );
END; {procedure Input Time}


PROCEDURE Get_New_Date; {---------------------------------------------------}
BEGIN
   Writeln;
   Writeln('  Correct DATE:            or <Return>');
   Write  (' -any separator-',esc,'A');
   Readln( input );
END; {procedure Input Date}


PROCEDURE Erase_Prompts; {----------------------------------------------------}
BEGIN   {cursor up 2x, clear to end}
   writeln( esc,'A',esc,'A',esc,'A',esc,'J');
   write(esc,'A');
END; {Procedure Erase Prompts}


FUNCTION Digit( Letter: One_Letter ) : BOOLEAN; {----------------------------}
BEGIN
   Digit := ((Letter>='0') AND (Letter<='9'));
END;


FUNCTION Read_Number( VAR I, Max: Word ): Word; {-----------------------------}
   LABEL 1;
   CONST   Asci_Zero = 48;
   VAR     Total : Word;
BEGIN
   Total := 0;
   IF i > max THEN GOTO 1;
       { --Skip any leading non-number characters-- }
   WHILE NOT Digit( input[i] ) DO BEGIN
      i := i + 1;
      IF i > max THEN GOTO 1;
   END;
       { --Now read the digits until they run out-- }
   Total := ord(input[i]) - Asci_Zero;
   REPEAT
      i := i + 1;
      IF i > max THEN GOTO 1;
      IF Digit(input[i]) THEN Total := (Total*10) + ord(input[i]) - Asci_Zero;
   UNTIL NOT Digit( input[i] );

   { --End of string encountered-- }
1: Read_Number := Total;
END; {procedure Read Number}


PROCEDURE Parse_Time; {-------------------------------------------------------}
VAR   hr, mn, len, i : Word;
BEGIN
   len := LENGTH( input );
   IF Len > 0 THEN BEGIN
      i := 1;
         { --get the hour input-- }
      hr := Read_Number( i, len );
         { --get the minute input-- }
      mn := Read_Number( i, len );
         { --read the AM/PM-- }
      IF i <= Len THEN BEGIN     {they don't have to specify the am/pm}
         Delete( input, 1, i );
         IF (Pos('a',input) > 0) OR (Pos('A',input) > 0) THEN PM := False;
         IF (Pos('p',input) > 0) OR (Pos('P',input) > 0) THEN PM := True;
      END;
      IF hr > 0 THEN
      IF hr <= 12 THEN
      IF mn <= 59 THEN BEGIN  { input is ok }
         hour := hr;
         minute := mn;
      END;
   END;
END; {Procedure Parse_Time}


PROCEDURE Parse_Date; {-------------------------------------------------------}
VAR   mo, da, yr, len, i : Word;
BEGIN
   len := LENGTH( input );
   IF Len > 0 THEN BEGIN
      i := 1;
         { --get the month input-- }
      mo := Read_Number( i, len );
         { --get the day input-- }
      da := Read_Number( i, len );
         { --get the year-- }
      yr := Read_Number( i, len );
      IF yr < 1900 THEN yr := yr + 1900;   { let 'em type in short hand year }
      IF mo > 0  THEN
      IF mo < 13 THEN
      IF da > 0  THEN
      IF da < 32 THEN
      IF yr > 1900 THEN BEGIN  { input is ok }
         Month := mo;
         Day   := da;
         Year  := yr;
      END;
   END;
END; {Procedure Parse_Date}


PROCEDURE Display_OSS_Notice;
BEGIN
   writeln( esc,'ETIME SET:  written in Personal Pascal. ',esc,'B');
   writeln( esc,'p     Portions of this product are      ');
   writeln(      '    Copyright (c) 1986, OSS and CCD    ');
   writeln(      '       Used by permission of OSS       ',esc,'q',esc,'B');
   write('Press any key');
   read( answer );
   writeln( esc,'E' );
END; {Procedure Display OSS Notice}


BEGIN {=======================================================================}

REPEAT
   Clear_Screen;

   Display_Time;
   Get_New_Time;
   Parse_Time;
   Set_Time;
   Erase_Prompts;
   Display_Time;

   Display_Date;
   Get_New_Date;
   Parse_Date;
   Set_Date;
   Erase_Prompts;
   Display_Date;

   writeln; writeln( 'Ok now? ');
   read( answer );

UNTIL (answer<>'n') AND (answer<>'N');

Cursor_Off;
Display_OSS_Notice;

END. {program}
