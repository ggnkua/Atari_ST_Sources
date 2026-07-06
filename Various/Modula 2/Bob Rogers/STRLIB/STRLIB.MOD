IMPLEMENTATION MODULE StrLib;

(*
     StrLib - String Functions

     ** This program is in the public domain. **

     Ver. 1.0  by Bob Rogers (GEnie R.C.ROGERS)

     A string is an array of characters terminated with a null.  The 
     first character is at String[0].  The procedures accept strings of
     any length.  Full source arrays without a null terminator are 
     accepted.  Strings created or modified by the procedures will be 
     null-terminated.
          
     Out-of-range traps will not occur.  Range errors can result in:
          1) a truncated destination string (e.g. appending a 30 
             character string to 2 characters in a string that can only
             hold 6 gives a 6 character sting)
          2) no change (e.g. deleting characters 9 through 10 from a 2
             character string leaves the original 2 character string)
          3) a null string (e.g. extracting character 4 from a 3 
             character string gives an empty result string).

     Some of these functions could have been built from others in this
     module but instead code was duplicated to avoid the overhead of
     additional function calls.
*)

(*$T-*)

FROM ASCII IMPORT BS, CharIsPrintable, CR, NUL;
FROM Terminal IMPORT Read, Write, WriteLn;

VAR
     i1, i2, i3 : CARDINAL;   (* Array indexes *)
     i          : INTEGER;

PROCEDURE StrAppend(VAR String1, String2 : ARRAY OF CHAR);
(*   Appends String1 to String2. *)

BEGIN
     i1 := 0;
     i2 := 0;
     WHILE (i2 <= HIGH(String2)) AND (String2[i2] # EOS) DO
          INC(i2);
     END;
     WHILE (i1 <= HIGH(String1)) 
     AND (String1[i1] # EOS) 
     AND (i2 < HIGH(String2)) DO
          String2[i2] := String1[i1];
          INC(i1);
          INC(i2);
     END;     
     String2[i2] := EOS;
END StrAppend;

PROCEDURE StrAppendChar(C : CHAR;
               VAR String : ARRAY OF CHAR);
(*   Append character C to String. *)

BEGIN
     i1 := 0;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          INC(i1);
     END;
     IF i1 < HIGH(String) THEN
          String[i1] := C;
          String[i1+1] := EOS;
     END;
END StrAppendChar;

PROCEDURE StrCat(VAR String1, String2, String3 : ARRAY OF CHAR);
(*   Concatenates String1 and String2 and puts them in String3. *)

BEGIN
     i1 := 0;
     i2 := 0;
     i3 := 0;
     String3[0] := EOS;
     WHILE (i1 <= HIGH(String1)) 
     AND (String1[i1] # EOS) 
     AND (i3 < HIGH(String3)) DO
          String3[i3] := String1[i1];
          INC(i1);
          INC(i3);
     END;     
     WHILE (i2 <= HIGH(String2)) 
     AND (String2[i2] # EOS) 
     AND (i3 < HIGH(String3)) DO
          String3[i3] := String2[i2];
          INC(i2);
          INC(i3);
     END;     
     String3[i3] := EOS;
END StrCat;

PROCEDURE StrClear(VAR String : ARRAY OF CHAR);
(*   Deletes all the characters in String. *)

BEGIN
     String[0] := EOS;
END StrClear;

PROCEDURE StrCmp(VAR String1 : ARRAY OF CHAR;
                 VAR String2 : ARRAY OF CHAR) : StrCmpResult;
(*   Compares String1 to String2 using ASCII order. *)

BEGIN
     i1 := 0;
     LOOP
          IF String1[i1] > String2[i1] THEN
               RETURN FirstStrGreater;
          ELSIF String1[i1] < String2[i1] THEN
               RETURN FirstStrLess;
          ELSIF String1[i1] = EOS  THEN
               RETURN StrEqual;
          ELSIF (i1 = HIGH(String1)) AND (i1 = HIGH(String2)) THEN
               RETURN StrEqual;
          ELSIF (i1 = HIGH(String1))  
          AND (i1 < HIGH(String2))      
          AND (String2[i1+1] = EOS) THEN
               RETURN StrEqual;
          ELSIF (i1 = HIGH(String2))
          AND (i1 < HIGH(String1))
          AND (String1[i1+1] = EOS) THEN
               RETURN StrEqual;
          END;
          INC(i1);
          IF i1 > HIGH(String1) THEN
               RETURN FirstStrLess;
          ELSIF i1 > HIGH(String2) THEN
               RETURN FirstStrGreater;
          END;
     END; 
END StrCmp;

PROCEDURE StrCmpIgnCase(VAR String1 : ARRAY OF CHAR;
                        VAR String2 : ARRAY OF CHAR) : StrCmpResult;
(*   Compares String1 to String2 using ASCII order, except compare is
     not case-sensitive (e.g. 'a' is equal to 'A'). *)

BEGIN
     i1 := 0;
     LOOP
          IF CAP(String1[i1]) > CAP(String2[i1]) THEN
               RETURN FirstStrGreater;
          ELSIF CAP(String1[i1]) < CAP(String2[i1]) THEN
               RETURN FirstStrLess;
          ELSIF String1[i1] = EOS  THEN
               RETURN StrEqual;
          ELSIF (i1 = HIGH(String1)) AND (i1 = HIGH(String2)) THEN
               RETURN StrEqual;
          ELSIF (i1 = HIGH(String1))  
          AND (i1 < HIGH(String2))      
          AND (String2[i1+1] = EOS) THEN
               RETURN StrEqual;
          ELSIF (i1 = HIGH(String2))
          AND (i1 < HIGH(String1))
          AND (String1[i1+1] = EOS) THEN
               RETURN StrEqual;
          END;
          INC(i1);
          IF i1 > HIGH(String1) THEN
               RETURN FirstStrLess;
          ELSIF i1 > HIGH(String2) THEN
               RETURN FirstStrGreater;
          END;
     END; 
END StrCmpIgnCase;

PROCEDURE StrCopy(VAR String1, String2 : ARRAY OF CHAR);
(*   Copies String1 to String2. *)

BEGIN
     i1 := 0;
     i2 := 0;
     WHILE (i1 <= HIGH(String1)) 
     AND (String1[i1] # EOS) 
     AND (i2 < HIGH(String2)) DO
          String2[i2] := String1[i1];
          INC(i1);
          INC(i2);
     END;     
     String2[i2] := EOS;
END StrCopy;

PROCEDURE StrDelete(VAR String : ARRAY OF CHAR;
                   First, Last : CARDINAL);
(*   Deletes String[First] through String[Last] from String. *)

BEGIN
     IF First <= Last THEN
          IF (First = HIGH(String)) OR (Last >= HIGH(String)) THEN
               String[First] := EOS;
          ELSE
               i1 := First;
               i2 := Last+1;
               WHILE i2 <= HIGH(String) DO 
                    String[i1] := String[i2];
                    IF String[i1] = EOS THEN
                         RETURN;
                    END;
                    INC(i1);
                    INC(i2);
               END;
               String[i1] := EOS;
          END;
     END;
END StrDelete;

PROCEDURE StrDeleteN(VAR String : ARRAY OF CHAR;
                   First, Count : CARDINAL);
(*   Deletes Count characters from String starting with String[First]. *)

BEGIN
     IF (Count > 0) AND (First <= HIGH(String))  THEN
          i2 := First + Count;
          IF (First = HIGH(String)) OR (i2 > HIGH(String)) THEN
               String[First] := EOS;
          ELSE
               i1 := First;
               WHILE i2 <= HIGH(String) DO 
                    String[i1] := String[i2];
                    IF String[i1] = EOS THEN
                         RETURN;
                    END;
                    INC(i1);
                    INC(i2);
               END;
               String[i1] := EOS;
          END;
     END;
END StrDeleteN;

PROCEDURE StrExtract(VAR String1, String2 : ARRAY OF CHAR;
                              First, Last : CARDINAL);
(*   Puts String1[First] through String1[Last] in String2. *)

BEGIN
     String2[0] := EOS;
     IF First <= Last THEN
          i1 := First;
          i2 := 0;
          WHILE (i1 <= Last) 
          AND (i1 <= HIGH(String1)) 
          AND (i2 < HIGH(String2)) DO
               String2[i2] := String1[i1];
               IF String2[i2] = EOS THEN
                    RETURN;
               END;
               INC(i1);
               INC(i2);
          END;
          String2[i2] := EOS;
     END;
END StrExtract;

PROCEDURE StrExtractN(VAR String1, String2 : ARRAY OF CHAR;
                              First, Count : CARDINAL);
(*   Puts Count characters beginning at String1[First] from String1 
     into String2. *)

BEGIN
     String2[0] := EOS;
     IF Count > 0 THEN
          IF First <= HIGH(String1) THEN
               i1 := First;
               i2 := 0;
               i3 := First + Count;
               WHILE (i1 < i3) 
               AND (i1 <= HIGH(String1)) 
               AND (i2 < HIGH(String2)) DO
                    String2[i2] := String1[i1];
                    IF String2[i2] = EOS THEN
                         RETURN;
                    END;
                    INC(i1);
                    INC(i2);
               END;
               String2[i2] := EOS;
          END;
     END;
END StrExtractN;


PROCEDURE StrFound(VAR String1, String2 : ARRAY OF CHAR;
                                  Start : CARDINAL;
                              VAR Pos   : CARDINAL) : BOOLEAN;
(*   Returns TRUE if String1 found in String2.  Sets Pos to location of
     String1 within String2.  Searches begin at String2[Start] and
     continue from left to right.  Pos not changed when FALSE returned. *)

BEGIN
     i2 := Start;
     IF String1[0] # EOS THEN
          WHILE (i2 <= HIGH(String2)) AND (String2[i2] # EOS) DO
               i1 := 0;
               i3 := i2;
               LOOP
                    IF String1[i1] = EOS THEN
                         Pos := i2;
                         RETURN TRUE;
                    ELSIF (i3 > HIGH(String2))
                    OR (String1[i1] # String2[i3]) THEN
                         EXIT;
                    ELSIF i1 = HIGH(String1) THEN
                         Pos := i2;
                         RETURN TRUE;
                    END;                         
                    INC(i1);
                    INi3);
                 END;
               INC(i2);               
          END;
     END;
     RETURN FALSE;
END StrFound;

PROCEDURE StrFoundChar(C : CHAR;
              VAR String : ARRAY OF CHAR;
                   Start : CARDINAL;
                 VAR Pos : CARDINAL) : BOOLEAN;
(*   Returns TRUE if character C found in String.  Sets Pos to location
     of C within String.  Searches begin at String[Start] and continue
     from left to right.  Pos not changed when FALSE returned. *)

BEGIN
     i1 := Start;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          IF String[i1] = C THEN
               Pos := i1;
               RETURN TRUE;
          ELSE
               INC(i1)
          END;
     END;
     RETURN FALSE;
END StrFoundChar;

PROCEDURE StrFoundCharR(C : CHAR;
              VAR String : ARRAY OF CHAR;
                 VAR Pos : CARDINAL) : BOOLEAN;
(*   Returns TRUE if character C found in String.  Sets Pos to location
     of C within String.  Searches begin at the rightmost character in 
     String and continue from right to left.  Pos not changed when 
     FALSE returned. *)

BEGIN
     IF String[0] # EOS THEN
          i := 0;
          WHILE (i < INTEGER(HIGH(String))) AND (String[i+1] # EOS) DO
               INC(i);
          END;
          WHILE i >= 0 DO
               IF String[i] = C THEN
                    Pos := i;
                    RETURN TRUE;
               ELSE
                    DEC(i)
               END;
          END;
     END;
     RETURN FALSE;
END StrFoundCharR;

PROCEDURE StrFoundDiff(VAR String : ARRAY OF CHAR;
                            Start : CARDINAL;
                          VAR Pos : CARDINAL) : BOOLEAN;
(*   Looks for the first character (searching from left to right) that
     is different from the character at String[Start].  Returns TRUE and
     sets Pos to the location of the first different character if one is
     found.  Pos not changed when FALSE returned. *)

BEGIN
     i1 := Start+1;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          IF String[i1] # String[Start] THEN
               Pos := i1;
               RETURN TRUE;
          ELSE
               INC(i1);
          END;
     END;
     RETURN FALSE;
END StrFoundDiff;

PROCEDURE StrFoundR(VAR String1, String2 : ARRAY OF CHAR;
                               VAR Pos   : CARDINAL) : BOOLEAN;
(*   Returns TRUE if String1 found in String2.  Sets Pos to location of
     of String1 within String2.  Searches begin at the rightmost 
     character in String2 and continue from right to left.  Pos not 
     changed when FALSE returned. *)

BEGIN
     IF (String1[0] # EOS) AND (String2[0] # EOS)  THEN
          i1 := 0;
          WHILE (i1 <= HIGH(String1)) AND (String1[i1] # EOS) DO
               INC(i1);
          END;
          i := 0;
          WHILE (i < INTEGER(HIGH(String2))) AND (String2[i+1] # EOS) DO
               INC(i);
          END; 
          i := i+1-INTEGER(i1);
          WHILE i >= 0 DO
               i1 := 0;
               i3 := i;
               LOOP
                    IF String1[i1] = EOS THEN
                         Pos := i;
                         RETURN TRUE;
                    ELSIF (String1[i1] # String2[i3]) THEN
                         EXIT;
                    ELSIF i1 = HIGH(String1) THEN
                         Pos := i;
                         RETURN TRUE;
                    END;                         
                    INC(i1);
                    INC(i3);
               END;
               DEC(i);               
          END;
     END;
     RETURN FALSE;
END StrFoundR;


PROCEDURE StrFoundSame(VAR String : ARRAY OF CHAR;
                            Start : CARDINAL;
                          VAR Pos : CARDINAL) : BOOLEAN;
(*   Looks for the first character (searching from left to right) that
     is the same as the character at String[Start].  Returns TRUE and
     sets Pos to the location of the first identical character if one is
     found.  Pos not changed when FALSE returned. *)

BEGIN
     i1 := Start+1;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          IF String[i1] = String[Start] THEN
               Pos := i1;
               RETURN TRUE;
          ELSE
               INC(i1);
          END;
     END;
     RETURN FALSE;
END StrFoundSame;

PROCEDURE StrFreeSpace(VAR String : ARRAY OF CHAR): CARDINAL;
(*   Returns the amount of available (i.e. unfilled) space in String. *)

BEGIN
     i1 := 0;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          INC(i1);
     END;
     IF i1 >= HIGH(String) THEN
          RETURN 0;
     ELSE
          RETURN (HIGH(String)-i1);
     END;
END StrFreeSpace;
     
PROCEDURE StrInsert(VAR String1, String2 : ARRAY OF CHAR;
                                     Pos : CARDINAL);
(*   Inserts String1 into String2 at String2[Pos]. *)

BEGIN
     i1 := 0;
     WHILE (i1 <= HIGH(String1)) AND (String1[i1] # EOS) DO
          INC(i1);
     END;
     i2 := 0;
     WHILE (i2 <= HIGH(String2)) AND (String2[i2] # EOS) DO
          INC(i2);
     END;
     IF (i1 > 0) AND ((Pos = 0) OR (Pos <= (i2-1))) THEN
          IF i2 > 0 THEN
               FOR i3 := (i2-1) TO Pos BY -1 DO
                    IF (i3+i1) < HIGH(String2) THEN
                         String2[i3+i1] := String2[i3];
                    END;
               END;
          END;
          FOR i3 := Pos TO (Pos+i1-1) DO
               IF i3 < HIGH(String2) THEN
                    String2[i3] := String1[i3-Pos];
               END;
          END;
          INC(i2, i1);
          IF (i2-1) < HIGH(String2) THEN
               String2[i2] := EOS;
          ELSE
               String2[HIGH(String2)] := EOS;
          END;   
     END;
END StrInsert;

PROCEDURE StrLength(VAR String : ARRAY OF CHAR) : CARDINAL;
(*   Returns the length of String. *)

BEGIN
     i1 := 0;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          INC(i1);
     END;
     RETURN i1;
END StrLength;

PROCEDURE StrRead(VAR String : ARRAY OF CHAR);
(*   Reads a string into String.  Read is terminated by a carriage
     return (which does not get put into String).  String can be edited
     using backspace.  Uses Terminal's Read and Write procedures to
     get and echo input. *)

VAR
     c : CHAR;

BEGIN
     i1 := 0;
     LOOP
          Read(c);
          IF (CharIsPrintable(c)) AND (i1 < HIGH(String)) THEN
               Write(c);
               String[i1] := c;
               INC(i1);
          ELSIF (c = BS) AND (i1 > 0) THEN
               Write(BS);
               Write(' ');
               Write(BS);
               DEC(i1);
          ELSIF c = CR THEN
               WriteLn;
               EXIT;
          END;
     END;
     String[i1] := NUL;
END StrRead;

PROCEDURE StrToLower(VAR String : ARRAY OF CHAR);
(*   Convert String to all lower case. *) 

BEGIN
     i1 := 0;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          IF (String[i1] >= 'A') AND (String[i1] <= 'Z') THEN
               String[i1] := CHAR(ORD(String[i1]) + 32);
          END;
          INC(i1);
     END;
END StrToLower;

PROCEDURE StrToUpper(VAR String : ARRAY OF CHAR);
(*   Convert String to all upper case. *) 

BEGIN
     i1 := 0;
     WHILE (i1 <= HIGH(String)) AND (String[i1] # EOS) DO
          String[i1] := CAP(String[i1]);
          INC(i1);
     END;
END StrToUpper;

PROCEDURE StrTruncate(VAR String : ARRAY OF CHAR;
                          Length : CARDINAL);
(*   Truncate String, leaving Length characters. *)
 
BEGIN
     IF Length <= HIGH(String) THEN
          String[Length] := EOS;
     END;
END StrTruncate;

END StrLib.
