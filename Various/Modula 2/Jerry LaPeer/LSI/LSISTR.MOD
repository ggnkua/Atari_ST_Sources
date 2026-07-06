(************************************************************************)
(*       From JOURNAL OF PASCAL, ADA AND MODULA2                        *)
(*                                                                      *)
(*        Strlib:                                                       *)
(*               Library module to handle strings.  Included is         *)
(*               terminal I/O, string length, assignment, conc-         *)
(*               atention, insertion, deletion, alteration and          *)
(*               the ability to select portions of a string.            *)
(*                                                                      *)
(*       Verson :                                                       *)
(*               1.0 ; November 16, 83 ;   Namir C. Shammas             *)
(*               1.1 ; November 21, 84 ;   Walter Maner                 *)
(*               Extracts for LSI May 30, 1986 ny Jerry LaPeer          *)
(*                                                                      *)
(************************************************************************)


IMPLEMENTATION MODULE LSISTR;

(*$S-*) (*$T-*) (*$A+*) (*$F-*)

FROM SYSTEM IMPORT BYTE,
                   ADDRESS,ADR;

PROCEDURE BlockComp(ParmA,ParmB : ADDRESS;
                    Length      : CARDINAL) : INTEGER;

VAR i:          CARDINAL;
    Aop,
    Bop:        POINTER TO CHAR;

BEGIN

  Aop := ParmA;
  Bop := ParmB;

  i := 0;

  WHILE (i < Length) DO
        IF Aop^ = Bop^
           THEN INC(i);
                Aop := ADDRESS(CARDINAL(Aop) + 1);
                Bop := ADDRESS(CARDINAL(Bop) + 1);
           ELSE IF Aop^ < Bop^
                   THEN RETURN -1;
                   ELSE RETURN +1;
                END;
        END;
  END;

  RETURN 0;

END BlockComp;

PROCEDURE BlockMove(ParmA,ParmB : ADDRESS;
                    Length      : CARDINAL);

VAR i:          CARDINAL;
    Aop,
    Bop:        POINTER TO BYTE;

BEGIN

  Aop := ParmA;
  Bop := ParmB;

  FOR i := 1 TO Length DO
        Aop^ := Bop^;
        Aop := ADDRESS(CARDINAL(Aop) + 1);
        Bop := ADDRESS(CARDINAL(Bop) + 1);
  END;

END BlockMove;

PROCEDURE LenStr(VAR Str : ARRAY OF CHAR):CARDINAL;

(* Returns the length of the string *)

VAR  i:         CARDINAL;
     StrHigh:   CARDINAL;

BEGIN

  StrHigh := HIGH(Str) + 1;

  i := 0;

(* Scan the string until the eos is found *)

  WHILE (Str[i] <> eos) AND
        (i < StrHigh) DO
        INC(i)
  END;

  RETURN i

END LenStr;

PROCEDURE PosStr(VAR Str1,Str2 : ARRAY OF CHAR; Start : CARDINAL):CARDINAL;

(* Returns the position where the sub-string Str2 occurs within string *)
(* starting at positon 'Start' Str1.                                   *)
(*                                                                     *)
(*---------------------------------------------------------------------*)
(*  Error Handling :                                                   *)
(*  (1) If Str2 is bigger than Str1 to begin with, then there can be   *)
(*      no matching of Str2 in Str1.                                   *)
(*  (2) If Start is greater than the length of Str1 then return zero   *)
(*      as a result.                                                   *)
(*---------------------------------------------------------------------*)


VAR
    long1,
    long2,
    ptr1,
    ptr2,
    last:       CARDINAL;
    Found:      BOOLEAN;

BEGIN

(* Initialize and obtain string lengths *)

  IF Start = 0
     THEN Start := 1;
  END;

  long1 := LenStr(Str1);
  long2 := LenStr(Str2);

  IF (long1 < 1)                    OR
     (long2 < 1)                    OR
     (Start > long1)                OR
     (((Start - 1) + long2) > long1)
     THEN RETURN 0;
  END;

  ptr1 := Start - 1;
  ptr2 :=0;

  last := ptr1;

  Found := FALSE;

(* Peform the function if the sub-string is indeed the smaller *)

    IF (long2 < long1) AND
       (long1 > Start)
       THEN REPEAT IF Str1[ptr1] = Str2[ptr2]
                      THEN IF BlockComp(ADR(Str1[ptr1]),
                                        ADR(Str2),
                                        long2) = 0
                              THEN Found := TRUE;
                              ELSE INC(ptr1);
                           END;
                      ELSE INC(ptr1);
                   END;
            UNTIL (Found)                  OR
                  ((ptr1 + long2) > long1);
    END;

(* Return zero if there was no match.                          *)

  IF Found
     THEN RETURN (ptr1 + 1);
     ELSE RETURN 0;
  END;

END PosStr;

PROCEDURE MoveStr (VAR Str1,Str2 : ARRAY OF CHAR);

(* Procedure will assign string Str2 to string Str1 *)

VAR i,
    long1,
    long2:      CARDINAL;

BEGIN

(* Obtain the length of both strings Str1 & Str2 *)

    long1 := HIGH(Str1);
    long2 := LenStr(Str2);

(* If string Str2 is too long pick up only the portion that will *)
(* fit  in string Str1.                                          *)

    IF long2 > long1
       THEN long2 := long1;
    END;

    FOR i := 0 TO long2 DO
        Str1[i] := Str2[i];
    END;

(* Put the eos if string Str1 is not full to capacity *)

    IF i < long1
       THEN Str1[i] := eos;
    END;

END MoveStr;

PROCEDURE ConCatStr(VAR S1 : ARRAY OF CHAR;
                    VAR S2,S3 : ARRAY OF CHAR);

VAR S1Max:        CARDINAL;
    Smax:         CARDINAL;
    Sin:          CARDINAL;
    Sout:         CARDINAL;

BEGIN

  S1Max := HIGH(S1);
  Sout := 0;

  Smax := HIGH(S2);
  Sin := 0;

  WHILE (Sout <= S1Max) AND
        (Sin <= Smax)   AND
        (S2[Sin] <> CHR(0)) DO
        S1[Sout] := S2[Sin];
        Sout := Sout + 1;
        Sin := Sin + 1;
  END;

  Smax := HIGH(S3);
  Sin := 0;

  WHILE (Sout <= S1Max) AND
        (Sin <= Smax)   AND
        (S3[Sin] <> CHR(0)) DO
        S1[Sout] := S3[Sin];
        Sout := Sout + 1;
        Sin := Sin + 1;
  END;

  IF Sout < S1Max
     THEN S1[Sout] := CHR(0);
  END;

END ConCatStr;

PROCEDURE AppendStr (VAR Str1,Str2 : ARRAY OF CHAR );

(*-----------------------------------------------------------------*)
(* Procedure to concatenate two strings such that,                 *)
(*                     Str1 = Str1 + Str2                          *)
(*-----------------------------------------------------------------*)


VAR i,
    long1,
    long2,
    hi:         CARDINAL;

BEGIN

(* Obtain the length of the strings  *)

  hi := HIGH(Str1);
  long1 := LenStr(Str1);

  IF long1 > hi
     THEN RETURN;
  END;

  long2 := HIGH(Str2);

  i := 0;

  WHILE (Str2[i] # eos) AND
        (i <= hi)       AND
        (i <= long2) DO
        Str1[long1 + i] := Str2[i];
        INC(i);
  END;

(* Put the eos if string Str1 is not full to capacity *)

  IF (i # 0)            AND
     ((i + long1) < hi)
     THEN Str1[i + long1] := eos;
  END;

END AppendStr;

PROCEDURE CopyStr(VAR Str1,Str2 : ARRAY OF CHAR ;
                      Start, Count : CARDINAL);

(* Procedure will copy the portion of string Str2 from the character   *)
(* position 'Start' and for 'Count' characters into string Str1.       *)
(*                                                                     *)
(*---------------------------------------------------------------------*)
(*  Error Handling : If the sum of Start and Count is greater than the *)
(*  string length then the resulting string Str1 will be identical to  *)
(*  string Str2.                                                       *)
(*---------------------------------------------------------------------*)

VAR OurCount,
    c,
    LStr2:      CARDINAL;

BEGIN

  LStr2 := LenStr(Str2);

  IF (LStr2  = 0)     OR
     (Start = 0)      OR
     (Count = 0)      OR
     (Start > LStr2)
     THEN Str1[0] := eos;
          RETURN;
  END;

  DEC(Start);

  IF (Start + Count) > LStr2
     THEN OurCount := (Start + Count) - LStr2;
     ELSE OurCount := Count;
  END;
(*
  BlockMove(ADR(Str1[0]),ADR(Str2[Start]),OurCount);
*)
  FOR c := 0 TO (OurCount - 1) DO
      Str1[c] := Str2[Start + c];
  END;

  IF OurCount <= HIGH(Str1)
     THEN Str1[OurCount] := eos;
  END;

END CopyStr;

PROCEDURE DeleteStr(VAR Str : ARRAY OF CHAR ; First,Last : CARDINAL);

(* Procedure to delete a portion of a string by specifying the first *)
(* and last character by position.                                   *)
(*                                                                   *)
(*-------------------------------------------------------------------*)
(*  Error Handling :                                                 *)
(*                                                                   *)
(*  (1) If Fisrt is greater than the string length, string Str will  *)
(*      remain intact.                                               *)
(*  (2) If Last is graeter than the string length, string Str will   *)
(*      end at position Last.                                        *)
(*-------------------------------------------------------------------*)


VAR i,
    i1,
    long:       CARDINAL;

BEGIN

  long := LenStr(Str);

(* If the first character is greater than the string length ignore   *)
(* the Procedure altogether.                                         *)

  IF First > long
     THEN RETURN;
  END;

  IF Last >= long                     (* Check if the last character *)
     THEN Str[First - 1] := eos;      (* position is within limits.  *)
     ELSE FOR i := Last TO (long-1) DO       (* Delete up to the last*)
              Str[First+i-Last-1] := Str[i]; (* character            *)
          END;                                       
          Str[long+First-Last-1] := eos;     (* Put the eos in       *)
  END;                                       (* string Str1          *)

END DeleteStr;

PROCEDURE InsertStr(VAR Str1,Str2 : ARRAY OF CHAR;
                        Start : CARDINAL);

(* Procedure will insert string Str2 in Str1 at the character *)
(* position 'Start' of string Str1.                           *)
(*                                                            *)
(*------------------------------------------------------------*)
(*  Error Handling : If there no room for string Str2 to be   *)
(*  inserted entirely string Str1 will remain intact.         *)
(*------------------------------------------------------------*)

VAR
   i,
   long1,
   long2:       CARDINAL;

BEGIN

  DEC(Start);

  long1 := LenStr(Str1);
  long2 := LenStr(Str2);

  IF (long1+long2-1) <= HIGH(Str1)
     THEN (* Relocate portions of Str1 to make way for string Str2. *)
          FOR i := (long1-1) TO Start BY -1 DO
              Str1[i+long2] := Str1[i]
          END;
          (* Copy string Str2 into the reserved loaction of string Str1. *)
          FOR i := Start TO (Start+long2-1) DO
              Str1[i] := Str2[i-Start]
          END;
          INC(long1,long2);
          IF (long1-1) < HIGH(Str1)
             THEN Str1[long1] := eos;
          END;
  END;

END InsertStr;

END LSISTR.
