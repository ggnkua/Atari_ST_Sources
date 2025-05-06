IMPLEMENTATION MODULE InOut;

(* This is a replacement for the InOut supplied by TDI, Inc. The       *)
(* following bugs  are fixed:                                          *)
(*    (1) Read did not convert a CR-LF pair to an EOL character,       *)
(*    (2) Read set Done to FALSE after successfully reading the last   *)
(*        character in a file,                                         *)
(*    (3) ReadString didn't stop reading when it saw a (non-leading)   *)
(*        space but went on to the next control character (usually CR),*)
(*    (4) Due to (1) above, ReadString returned an extra null string   *)
(*        at the end of each line (between the CR and LF),             *)
(*    (5) Due to (3) above, ReadCard and ReadInt would bomb if you     *)
(*        tried to read a line with multiple numbers separated by      *)
(*        spaces,                                                      *)
(*    (6) Due to (4) above, and the fact that ReadCard and ReadInt     *)
(*        interpret a null string as a zero, you would get an extra    *)
(*        zero value at the end of each line,                          *)
(*    (7) Write(EOL) was not equivalent to WriteLn,                    *)
(*    (8) termCH was always set to 0C.                                 *)

(* In addition, Streams.OpenStream doesn't recognize the names of the  *)
(* special streams "con:", "aux:", and "prn:" unless they are written  *)
(* just like that, all in lowercase. I adopt the simplest solution in  *)
(* the opening routines defined here, by translating the entire file   *)
(* name to lowercase. *)

(* To use this module, first rename the your old INOUT.LNK to something *)
(* like INOUT.OLD. Then compile this module and copy the resulting LNK  *)
(* file to wherever you kept the old INOUT.LNK. The INOUT.DEF and       *)
(* INOUT.SYM files supplied by TDI correctly describe this module.      *)
(* Of course for this to work this file must be named INOUT.MOD.        *)

(* I have added some handy features to InOut that may or may not be    *)
(* compatible with Wirth's definitions in the second edition of        *)
(* "Programming in MODULA-2", he leaves a lot out. Anyway, the new     *)
(* features are:                                                       *)
(*    (1) The character ASCII.US (ctrl-DEL) is interprteted as an end  *)
(*        of file signal if reading from the terminal ONLY. This allows*)
(*        a program that tests the Done flag to operate correctly no   *)
(*        matter where its input comes from,                           *)
(*    (2) ReadCard and ReadInt ignore null strings. This allows one to *)
(*        have trailing spaces in a line without reading a spurious 0. *)
(*        Please note that ReadString *does* return null strings at    *)
(*        the ends of lines with trailing spaces.                      *)
(*    (3) ReadString turns on the cursor if input is to come from the  *)
(*        terminal. Since ReadCard, etc., use ReadString, you can tell *)
(*        that they were not satisfied by a null input since the cursor*)
(*        has not vanished. Read also turns on the cursor.             *)
(*    (4) When ReadInt and ReadCard encounter invalid input, they don't*)
(*        HALT, but print an error message and wait for a character to *)
(*        be typed. They then return to the caller with the Done flag  *)
(*        set to FALSE, as if an end of file had been found. This is   *)
(*        to allow the user to see what caused the problem, and for her*)
(*        program to terminate gracefully (assuming it tests the Done  *)
(*        flag properly). To force a HALT after the error message, use *)
(*        control-C.                                                   *)
(*    (5) If ReadString finds a string terminated by the end of the    *)
(*        file instead of a space or control character, it will return *)
(*        the string with Done=TRUE, but set things up so that the next*)
(*        call to Read or ReadString will immediately return with Done *)
(*        set to FALSE. After a return with Done=FALSE, input reverts  *)
(*        to the terminal.                                             *)
(*    (6) A null response to the filename request from OpenInput or    *)
(*        OpenOutput is equivalent to "con:".                          *)


(* Version 1.00, 7 April 1986 by Stephen Tether. *)
(* satether on BIX.         *)
(* SAT@MIT-MC on ARPANET.   *)
(* TETHER@MITLNS on BITNET. *)

(* Version 1.10, 26 April 1986 by Stephen Tether. *)
(* Changes: *)
(*     CloseInput, OpenInput, and OpenInputFile empty the terminal line *)
(* buffer and set DelayedEOS to FALSE.                                  *)
(*     Read now uses Fetch to handle the terminal bells-and-whistles    *)
(* properly. In particular this means that it won't wait for the next   *)
(* char after a CR from the terminal (to test if it is LF). Control-DEL *)
(* is handled properly, etc. Note also that Read will now wait for an   *)
(* entire line to be entered before passing chars back to the caller,   *)
(* and that you can correct mistakes with DEL. People wanting to handle *)
(* DEL themselves must use Terminal.Read. This seems to be the only way *)
(* to let people switch between ReadString and Read in the middle of a  *)
(* line of terminal input and get consistent results.                   *)
(*     The CR ending a line of terminal input is now echoed by ReadLine *)
(* instead of Fetch, so that the cursor goes to the next line right away*)
(* instead of sometime later.                                           *)

FROM Streams IMPORT Stream, StreamKinds, OpenStream, CloseStream,
   Write8Bit, Read8Bit, EOS, Con;

FROM M2Conversions IMPORT ConvertCardinal, ConvertInteger, ConvertOctal,
   ConvertHex, ConvertToCardinal, ConvertToInteger;

FROM ASCII IMPORT CR, LF, US, DEL, ESC, ETX;

FROM String IMPORT Assign;

IMPORT Terminal;

(* Local stuff. *)
CONST
   BufferSize = 256;  (* Maximum number of chars that InOut will handle *)
                      (* internally. *)

TYPE
   WorkBuffer = ARRAY [0..BufferSize-1] OF CHAR;
   
VAR
   TermIn, TermOut: BOOLEAN; (* Set TRUE by the opening routines       *)
                             (* if the corresponding stream is to/from *)
                             (* the terminal. *)

   DelayedEOS: BOOLEAN;      (* See ReadString. *)

   LineBuffer: WorkBuffer;   (* Holds a line of terminal input. *)
   BufNext: CARDINAL;

(* Procedure definitions. *)

PROCEDURE MakeLowercase(VAR str: ARRAY OF CHAR);
TYPE
   CharSet = SET OF CHAR;
CONST
   Uppercase = CharSet{'A'..'Z'};
VAR
   i: CARDINAL;
   CaseCorrection: CARDINAL;
BEGIN
   CaseCorrection := ORD('a') - ORD('A');
   i := 0;
   WHILE (i <= HIGH(str)) AND (str[i] # 0C) DO
      IF str[i] IN Uppercase THEN
         str[i] := CHR( ORD(str[i]) + CaseCorrection );
         END;
      INC(i);
      END;
   END MakeLowercase;

PROCEDURE OpenInput(VAR defext:ARRAY OF CHAR);
(* Prompt at the terminal for a stream name, then use that to open the *)
(* standard input. The argument "defext" is not used, but is provided  *)
(* for compatibility with implementations that use it to define a      *)
(* default file extension. If the open succeeds, Done is set to TRUE.  *)
(* Otherwise, Done is set FALSE and input reverts to the terminal.     *)
(* The TermIn flag is set according to whether the input is from the   *)
(* terminal. *)
VAR
   s: WorkBuffer;
   reply: INTEGER;
BEGIN
   CloseStream(In, reply);
   Terminal.WriteLn;
   Terminal.WriteString("File name for In: ");
   ReadFileName(s);
   MakeLowercase(s);
   OpenStream(In, s, READ, reply);
   IF reply # 0 THEN
      Done := FALSE;
      (*  ******* "con:" MUST be all lowercase as shown! ******* *)
      OpenStream(In, "con:", READ, reply);
   ELSE
      Done := TRUE;
      END;
   TermIn := (In.dev = Con); (* See definition module Streams. *)
   DelayedEOS := FALSE;
   BufNext := BufferSize;
   END OpenInput;

PROCEDURE OpenOutput(VAR defext:ARRAY OF CHAR);
(* Quite similar to OpenInput, which see. *)
VAR
   s: WorkBuffer;
   reply: INTEGER;
BEGIN
   CloseStream(Out, reply);
   Terminal.WriteLn;
   Terminal.WriteString("File name for Out: ");
   ReadFileName(s);
   MakeLowercase(s);
   OpenStream(Out, s, READWRITE, reply);
   IF reply # 0 THEN
      Done := FALSE;
      OpenStream(Out, "con:", READWRITE, reply);
   ELSE
      Done := TRUE;
      END;
   TermOut := (Out.dev = Con); (* See definition module Streams. *)
   END OpenOutput;

PROCEDURE OpenInputFile(VAR FileName:ARRAY OF CHAR);
(* Similar to OpenInput, except that the file name is passed as an *)
(* argument. *)
VAR
   reply: INTEGER;
   str: WorkBuffer;
BEGIN
   CloseStream(In, reply);
   Assign(str, FileName);
   MakeLowercase(str);
   OpenStream(In, str, READ, reply);
   IF reply # 0 THEN
      Done := FALSE;
      OpenStream(In, "con:", READ, reply);
   ELSE
      Done := TRUE;
      END;
   TermIn := (In.dev = Con); (* See definition module Streams. *)
   DelayedEOS := FALSE;
   BufNext := BufferSize;
   END OpenInputFile;

PROCEDURE OpenOutputFile(VAR FileName:ARRAY OF CHAR);
(* Similar to OpenOutput, except that the file name is passed as an *)
(* argument. *)
VAR
   reply: INTEGER;
   str: WorkBuffer;
BEGIN
   CloseStream(Out, reply);
   Assign(str, FileName);
   MakeLowercase(str);
   OpenStream(Out, str, READWRITE, reply);
   IF reply # 0 THEN
      Done := FALSE;
      OpenStream(Out, "con:", READWRITE, reply);
   ELSE
      Done := TRUE;
      END;
   TermOut := (Out.dev = Con); (* See definition module Streams. *)
   END OpenOutputFile;

PROCEDURE CloseInput;
(* Close the "In" stream and revert to terminal input. GEMDOS errors   *)
(* are ignored. *)
VAR
   reply: INTEGER;
BEGIN
   CloseStream(In, reply);
   OpenStream(In, "con:", READ, reply);
   TermIn := TRUE;
   DelayedEOS := FALSE;
   BufNext := BufferSize;
   END CloseInput;

PROCEDURE CloseOutput;
(* Close the "Out" stream, and revert output to the terminal. GEMDOS  *)
(* errors are ignored. *)
VAR
   reply: INTEGER;
BEGIN
   CloseStream(Out, reply);
   OpenStream(Out, "con:", READWRITE, reply);
   TermOut := TRUE;
   END CloseOutput;

PROCEDURE Read(VAR ch:CHAR);
(* Get a character from In and place it in "ch". If all goes well, set *)
(* variable Done to TRUE. If there are no more characters to be had,   *)
(* set Done to FALSE and ch to 0C. *)
(* Complication 1: change a CR-LF pair to an EOL character.            *)
(* Complication 2: watch out for a delayed EOS set by ReadString.      *)
(* Complication 3: use Fetch for terminal input.                       *)
VAR
   ch2: CHAR; (* Look-ahead for CR-LF -> EOL conversion. *)
BEGIN
   (* Test for no more data. *)
   IF DelayedEOS OR EOS(In) THEN 
      ch := 0C;
      Done := FALSE;
      CloseInput;
   ELSIF NOT TermIn THEN
      (* We read something. *)
      Done := TRUE;
      Read8Bit(In, ch);
      (* Test for CR-LF combination. *)
      IF (ch = CR) AND NOT EOS(In) THEN
         Read8Bit(In, ch2);
         (* If the second char is not LF, put it back. *)
         IF ch2 = LF THEN ch := EOL;
         ELSE In.rAgainBuf := ch2; In.rAgain := TRUE; END;
         END;
   ELSE
      (* Special handling for the terminal. *)
      Fetch(ch);
      END;
   END Read;

PROCEDURE Write(ch:CHAR);
(* Send a character to Out. Much easier than Read, all we have to watch *)
(* out for is that Write(EOL) does the same thing as WriteLn.           *)
BEGIN
   IF ch = EOL THEN Write8Bit(Out, CR); Write8Bit(Out, LF);
   ELSE Write8Bit(Out, ch); END;
   END Write;

PROCEDURE WriteLn;
(* Terminate a line on Out. *)
BEGIN
   Write8Bit(Out, CR); Write8Bit(Out, LF);
   END WriteLn;

PROCEDURE ReadLine;
(* Read a line from In assuming that it is the terminal. A line is a   *)
(* sequence of characters terminated by CR or US (endfile marker). CR  *)
(* is changed to EOL. The line, including the terminating character,   *)
(* is stored in variable LineBuffer. If the line is too long, the extra*)
(* characters are lost, although the terminator is still stored. Treat *)
(* DEL as a command to discard the last character stored.              *)
VAR
   ch: CHAR;
BEGIN
   CursorOn;
   BufNext := 0;
   REPEAT
      Read8Bit(In, ch);
      IF ch = DEL THEN

         Rubout;  (* Erase the "delta" echoed for DEL. *)
         IF BufNext > 0 THEN DEC(BufNext); Rubout; END;
      ELSE
         LineBuffer[BufNext] := ch;
         IF BufNext < (BufferSize-1) THEN INC(BufNext); END;
         END;
      UNTIL (ch = CR) OR (ch = US);
   IF ch = CR THEN
      LineBuffer[BufNext] := EOL;
      Terminal.WriteLn;
      END;
   BufNext := 0;
   CursorOff;
   END ReadLine;

PROCEDURE Fetch(VAR ch: CHAR);
(* Look at the next char in LineBuffer. If there is none, get the next *)
(* line via ReadLine. If the next char is ASCII.US, set Done to FALSE  *)
(* and set ch to 0C. Otherwise, set Done to true and return the next   *)
(* character in ch. *)
BEGIN
   IF BufNext >= BufferSize THEN ReadLine; END;
   ch := LineBuffer[BufNext];
   INC(BufNext);
   IF ch = US THEN
      ch := 0C;
      Done := FALSE;
      BufNext := BufferSize;  (* End of the line. *)
   ELSE
      Done := TRUE;
      IF ch = EOL THEN
         BufNext := BufferSize;
         END;
      END;
   END Fetch;

PROCEDURE ReadString(VAR str:ARRAY OF CHAR);
(* Read a "string" into str, the string being defined as all the chars *)
(* seen from the first non-blank up to but not including the first     *)
(* char <= " ". The variable termCH will be set to the character that  *)
(* marked the end of the string. A terminator of 0C will be added to   *)
(* mark the end of the string **inside variable str**. Therefore the   *)
(* maximum number of chars that will be stored is HIGH(str), although  *)
(* the entire string will be removed from the input stream. Done is set*)
(* to FALSE only if we hit EOS before seeing a non-blank. Note that the*)
(* Streams procedures do their own echoing for terminal input. *)
VAR
   next: CARDINAL;   (* Index into str, where next char will go. *)
   ch: CHAR;         (* Character buffer. *)
   max: CARDINAL;    (* Maximum number of chars to store. *)
BEGIN
   (* Watch out for EOS detected in a previous call (see below). *)
   IF DelayedEOS THEN
      Done := FALSE;
      str[0] := 0C;
      CloseInput;
      RETURN;
      END;
   (* Normal operation. *)
   max := HIGH(str);
   next := 0;

   (* Skip leading blanks. *)
   REPEAT 
      Read(ch);
      UNTIL ch # " "; (* ch = 0C if not Done *)
   (* Collect the string. *)
   WHILE ch > " " DO 
      (* Add new char to string if there is room. *)
      IF next < max THEN
         str[next] := ch;
         INC(next);
         END;
      Read(ch);
      END;
   termCH := ch;
   str[next] := 0C;
   (* Now we must set Done and DelayedEOS properly. There are four *)
   (* possible cases, according to the contents of string str and  *)
   (* present value of Done (set by Read or Fetch):                *)
   (*    (1) Null string and Done: Done unchanged, DelayedEOS:=FALSE     *)
   (*    (2) Null string and not Done: Done unchanged, DelayedEOS:=FALSE *)
   (*    (3) Non-null string, Done: Done unchanged, DelayedEOS:=FALSE    *)
   (*    (4) Non-null string, not Done: Done:=TRUE, DelayedEOS:=TRUE     *)
   IF (next > 0) AND (NOT Done) THEN
      Done := TRUE;
      DelayedEOS := TRUE;
   ELSE
      DelayedEOS := FALSE;
      END;
   IF NOT Done THEN CloseInput; END;
   END ReadString;

PROCEDURE ReadFileName(VAR str:ARRAY OF CHAR);
(* Read a string (as in ReadString) from the terminal to be used as a    *)
(* file name. Note that we return as soon as we see a space or control   *)
(* character. The Read procedure in Terminal is used to avoid disturbing *)
(* the In stream. Terminal.Read doesn't echo, so we do it here. Notice   *)
(* the care taken to avoid Terminal.Write of control characters, which   *)
(* can really lose, e.g., DEL. *)
VAR
   next: CARDINAL;   (* Index into str, where next char will go. *)
   ch: CHAR;         (* Character buffer. *)
   max: CARDINAL;    (* Maximum number of chars to store. *)
BEGIN
   max := HIGH(str);
   next := 0;
   CursorOn;
   (* Skip leading blanks. *)
   LOOP
      Terminal.Read(ch);
      IF ch # " " THEN EXIT END;
      Terminal.Write(ch);
      END;
   (* Loop over the characters in the string. *)
   LOOP
      IF (ch = DEL) THEN 
         (* Rub-out last char (if any). *)
         IF  (next > 0) THEN
            DEC(next);
            Rubout;
            END;
      ELSIF ch > " " THEN
         Terminal.Write(ch);
         (* Add new char to string if there is room. *)
         str[next] := ch;
         IF next < max THEN INC(next); END
      ELSE
         Terminal.WriteLn;
         EXIT;
         END;
      Terminal.Read(ch);
      END;
   str[next] := 0C;
   IF next = 0 THEN Assign(str, "con:"); END;
   CursorOff;
   END ReadFileName;

PROCEDURE WriteString(VAR str:ARRAY OF CHAR);
(* Write the chars in variable str up to but not including the first    *)
(* 0C. If there is no 0C then transmit all of str.                      *)

VAR
   i: CARDINAL;
BEGIN
   i := 0;
   WHILE (i <= HIGH(str)) AND (str[i] # 0C) DO
      Write8Bit(Out, str[i]);
      INC(i);
      END;
   END WriteString;

PROCEDURE ReadCard(VAR cd:CARDINAL);
(* Convert the first non-null string to a cardinal, storing the result   *)
(* in variable cd. If the string won't convert, send an error message to *)
(* the terminal and simulate an end-of-file (Done = FALSE).              *)
VAR
   str: WorkBuffer;
BEGIN
   REPEAT
      ReadString(str);
      UNTIL (NOT Done) OR (str[0] # 0C);
   cd := 0;
   IF NOT Done THEN RETURN END;
   ConvertToCardinal(str, Done, cd);
   IF NOT Done THEN
      Complain("ReadCard", str);
      cd := 0;
      END;
   END ReadCard;

PROCEDURE ReadInt(VAR it:INTEGER);
(* Convert the first non-null string to an integer, storing the result   *)
(* in variable it. If the string won't convert, send an error message to *)
(* the terminal and simulate an end-of-file (Done = FALSE).              *)
VAR
   str: WorkBuffer;
BEGIN
   REPEAT
      ReadString(str);
      UNTIL (NOT Done) OR (str[0] # 0C);
   it := 0;
   IF NOT Done THEN RETURN END;
   ConvertToInteger(str, Done, it);
   IF NOT Done THEN
      Complain("ReadInt", str);
      it := 0;
      END;
   END ReadInt;

PROCEDURE WriteCard(cd,len:CARDINAL);
VAR
   str: WorkBuffer;
BEGIN
   ConvertCardinal(cd, len, str);
   WriteString(str);
   END WriteCard;

PROCEDURE WriteInt(it:INTEGER; len:CARDINAL);
VAR
   str: WorkBuffer;
BEGIN
   ConvertInteger(it, len, str);
   WriteString(str);
   END WriteInt;

PROCEDURE WriteOct(cd,len:CARDINAL);
VAR
   str: WorkBuffer;
BEGIN
   ConvertOctal(cd, len, str);
   WriteString(str);
   END WriteOct;

PROCEDURE WriteHex(cd,len:CARDINAL);
VAR
   str: WorkBuffer;
BEGIN
   ConvertHex(cd, len, str);
   WriteString(str);
   END WriteHex;

PROCEDURE Rubout;
(* Use GEMDOS escape sequences (VT52-like) to erase a character on the *)
(* screen. *)
BEGIN
   Terminal.Write(ESC);   (* Cursor left. *)
   Terminal.Write("D");
   Terminal.Write(ESC);   (* Clear to end of line. *)
   Terminal.Write("K");
   END Rubout;

PROCEDURE CursorOn;
BEGIN
   Terminal.Write(ESC);
   Terminal.Write("e");
   END CursorOn;

PROCEDURE CursorOff;
BEGIN
   Terminal.Write(ESC);
   Terminal.Write("f");
   END CursorOff;

PROCEDURE Complain(VAR Hero, Villain: ARRAY OF CHAR);
(* The routine named in string Hero found the invalid input contained *)
(* in string Villain. Write an error message to the screen, and pause *)
(* so the poor user has a chance to see it. *)
VAR
  ch: CHAR;
BEGIN
   Terminal.WriteLn;
   Terminal.WriteString(Hero);
   Terminal.WriteString(" doesn't like '");
   Terminal.WriteString(Villain);
   Terminal.WriteString("' as input.");
   Terminal.WriteLn;
   Terminal.WriteString
      ("Type control-C to stop the program, or any other character to");
   Terminal.WriteLn;
   Terminal.WriteString("return from ");
   Terminal.WriteString(Hero);
   Terminal.WriteString(" with Done=FALSE: ");
   CursorOn;
   Terminal.Read(ch);
   CursorOff;
   Terminal.WriteLn;
   IF ch = ETX THEN HALT; END;
   Done := FALSE;
   END Complain;

BEGIN
   Terminal.Write(ESC);  (* Clear the screen and home the cursor. *)
   Terminal.Write("E");
   Terminal.Write(ESC);  (* Make long lines wrap around. *)
   Terminal.Write("v");
   CursorOff;
   CloseInput;
   CloseOutput;
   termCH := 0C;
   Done := TRUE;
   BufNext := BufferSize;
   DelayedEOS := FALSE;
   END (* implementation module *) InOut.
