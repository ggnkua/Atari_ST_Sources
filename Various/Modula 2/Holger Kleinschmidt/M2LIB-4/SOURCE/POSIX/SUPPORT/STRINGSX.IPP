IMPLEMENTATION MODULE StringsX;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 11-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD;

IMPORT types;

FROM ISOStrings IMPORT
(* TYPE *) CompareResults,
(* PROC *) Length;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ExtractTail ((* EIN/ -- *)     source          : ARRAY OF CHAR;
                       (* EIN/ -- *)     numberToExtract : CARDINAL;
                       (* -- /AUS *) VAR destination     : ARRAY OF CHAR );

VAR         sLen : CARDINAL;
    __REG__ sIdx : UNSIGNEDWORD;
    __REG__ dIdx : SIGNEDWORD;
    __REG__ max  : SIGNEDWORD;

BEGIN
 sLen := Length(source);

 IF numberToExtract > sLen THEN
   numberToExtract := sLen;
 END;

 IF numberToExtract > VAL(CARDINAL,HIGH(destination)) THEN
   max := VAL(SIGNEDWORD,HIGH(destination));
 ELSE
   max := VAL(SIGNEDWORD,numberToExtract) - 1;
 END;

 sIdx := VAL(UNSIGNEDWORD,sLen - numberToExtract);
 dIdx := 0;
 WHILE dIdx <= max DO
   destination[dIdx] := source[sIdx];
   INC(dIdx);
   INC(sIdx);
 END;

 IF dIdx <= VAL(SIGNEDWORD,HIGH(destination)) THEN
   destination[dIdx] := types.EOS;
 END;
END ExtractTail;

(*---------------------------------------------------------------------------*)

PROCEDURE Convert ((* EIN/ -- *) REF source      : ARRAY OF CHAR;
                   (* EIN/ -- *)     convert     : CharConvert;
                   (* -- /AUS *) VAR destination : ARRAY OF CHAR );

VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(source) > HIGH(destination) THEN
   max := VAL(UNSIGNEDWORD,HIGH(destination));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(source));
 END;

 i := 0;
 WHILE (i <= max) & (source[i] # types.EOS) DO
   destination[i] := convert(source[i]);
   INC(i);
 END;
 IF i <= VAL(UNSIGNEDWORD,HIGH(destination)) THEN
   destination[i] := types.EOS;
 END;
END Convert;

(*---------------------------------------------------------------------------*)

PROCEDURE Revert ((* EIN/ -- *)     source      : ARRAY OF CHAR;
                  (* -- /AUS *) VAR destination : ARRAY OF CHAR );

VAR __REG__ sIdx : SIGNEDWORD;
    __REG__ dIdx : SIGNEDWORD;
    __REG__ max  : SIGNEDWORD;

BEGIN
 sIdx := VAL(SIGNEDWORD,Length(source)) - 1;

 IF sIdx > VAL(SIGNEDWORD,HIGH(destination)) THEN
   max := VAL(SIGNEDWORD,HIGH(destination));
 ELSE
   max := sIdx;
 END;

 dIdx := 0;
 WHILE dIdx <= max DO
   destination[dIdx] := source[sIdx];
   INC(dIdx);
   DEC(sIdx);
 END;
 IF dIdx <= VAL(SIGNEDWORD,HIGH(destination)) THEN
   destination[dIdx] := types.EOS;
 END;
END Revert;

(*---------------------------------------------------------------------------*)

PROCEDURE Trim ((* EIN/AUS *) VAR string : ARRAY OF CHAR );

VAR __REG__ i     : UNSIGNEDWORD;
    __REG__ start : SIGNEDWORD;
    __REG__ end   : SIGNEDWORD;

BEGIN
 end := VAL(SIGNEDWORD,Length(string));
 REPEAT
   DEC(end)
 UNTIL (end < 0) OR (string[end] # ' ');

 start := 0;
 WHILE (start <= end) & (string[start] = ' ') DO
   INC(start);
 END;

 i := 0;
 WHILE start <= end DO
   string[i] := string[start];
   INC(i);
   INC(start);
 END;
 IF i <= VAL(UNSIGNEDWORD,HIGH(string)) THEN
   string[i] := types.EOS;
 END;
END Trim;

(*---------------------------------------------------------------------------*)

PROCEDURE Align ((* EIN/ -- *)     width   : CARDINAL;
                 (* EIN/ -- *)     aligned : Alignment;
                 (* EIN/AUS *) VAR string  : ARRAY OF CHAR );

VAR __REG__ sLen  : SIGNEDWORD;
    __REG__ sIdx  : SIGNEDWORD;
    __REG__ dIdx  : SIGNEDWORD;
            pre   : SIGNEDWORD;
            post  : SIGNEDWORD;
            blnks : SIGNEDWORD;

BEGIN
 sLen := VAL(SIGNEDWORD,Length(string));

 IF width > VAL(CARDINAL,HIGH(string)) + 1 THEN
   width := VAL(CARDINAL,HIGH(string)) + 1;
 END;
 IF width <= VAL(CARDINAL,sLen) THEN
   RETURN;
 END;

 blnks := VAL(SIGNEDWORD,width) - sLen;
 CASE aligned OF
   left   : pre  := 0;
            post := blnks;
  |middle : pre  := (blnks + 1) DIV 2;
            post := blnks - pre;
  |right  : pre  := blnks;
            post := 0;
 END;

 sIdx := sLen - 1;
 dIdx := pre + sLen + post - 1;
 IF dIdx < VAL(SIGNEDWORD,HIGH(string)) THEN
   string[dIdx+1] := types.EOS;
 END;

 INC(sLen, pre);
 WHILE dIdx >= sLen DO
   string[dIdx] := ' ';
   DEC(dIdx);
 END;

 WHILE sIdx >= 0 DO
   string[dIdx] := string[sIdx];
   DEC(sIdx);
   DEC(dIdx);
 END;

 WHILE dIdx >= 0 DO
   string[dIdx] := ' ';
   DEC(dIdx);
 END;
END Align;

(*---------------------------------------------------------------------------*)

PROCEDURE CanConvertAll
  ((* EIN/ -- *)     sourceLength : CARDINAL;
   (* EIN/ -- *) VAR destination  : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(sourceLength <= VAL(CARDINAL,HIGH(destination)) + 1);
END CanConvertAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanRevertAll
  ((* EIN/ -- *)     sourceLength : CARDINAL;
   (* EIN/ -- *) VAR destination  : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(sourceLength <= VAL(CARDINAL,HIGH(destination)) + 1);
END CanRevertAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanExtractTailAll
  ((* EIN/ -- *)     sourceLength    : CARDINAL;
   (* EIN/ -- *)     numberToExtract : CARDINAL;
   (* EIN/ -- *) VAR destination     : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(  (numberToExtract <= sourceLength)
        & (numberToExtract <= VAL(CARDINAL,HIGH(destination)) + 1));
END CanExtractTailAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanAlignAll ((* EIN/ -- *)     width  : CARDINAL;
                       (* EIN/ -- *) VAR string : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(  (width <= VAL(CARDINAL,HIGH(string)) + 1)
        & (width >= Length(string)));
END CanAlignAll;

(*---------------------------------------------------------------------------*)

PROCEDURE EqualPrefix ((* EIN/ -- *)     prefixLen  : CARDINAL;
                       (* EIN/ -- *) REF stringVal1 : ARRAY OF CHAR;
                       (* EIN/ -- *) REF stringVal2 : ARRAY OF CHAR ): BOOLEAN;

VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ ch  : CHAR;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF prefixLen = 0 THEN
   RETURN(TRUE);
 END;
 DEC(prefixLen);

 IF HIGH(stringVal1) > HIGH(stringVal2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(stringVal2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(stringVal1));
 END;
 IF VAL(CARDINAL,max) > prefixLen THEN
   max := VAL(UNSIGNEDWORD,prefixLen);
 END;

 i := 0;
 REPEAT
   ch := stringVal1[i];
   IF ch # stringVal2[i]  THEN
     RETURN(FALSE);
   ELSIF ch = types.EOS THEN
     RETURN(TRUE);
   END;
   INC(i);
 UNTIL i > max;

 RETURN(   (VAL(CARDINAL,max) = prefixLen)
        OR ~(   (HIGH(stringVal1) < HIGH(stringVal2))
              & (stringVal2[i] # types.EOS)
             OR (HIGH(stringVal1) > HIGH(stringVal2))
              & (stringVal1[i] # types.EOS)));
END EqualPrefix;

(*---------------------------------------------------------------------------*)

PROCEDURE FindNextInClass ((* EIN/ -- *)     inClass        : CharClassTest;
                           (* EIN/ -- *) REF stringToSearch : ARRAY OF CHAR;
                           (* EIN/ -- *)     startIndex     : CARDINAL;
                           (* -- /AUS *) VAR charFound      : BOOLEAN;
                           (* -- /AUS *) VAR posOfChar      : CARDINAL );

VAR __REG__ sLen : CARDINAL;
    __REG__ i    : CARDINAL;

BEGIN
 sLen := Length(stringToSearch);
 i    := startIndex;

 WHILE (i < sLen) & ~inClass(stringToSearch[VAL(UNSIGNEDWORD,i)]) DO
   INC(i);
 END;

 IF i < sLen THEN
   charFound := TRUE;
   posOfChar := i;
 ELSE
   charFound := FALSE;
 END;
END FindNextInClass;

(*---------------------------------------------------------------------------*)

PROCEDURE FindPrevInClass ((* EIN/ -- *)     inClass        : CharClassTest;
                           (* EIN/ -- *) REF stringToSearch : ARRAY OF CHAR;
                           (* EIN/ -- *)     startIndex     : CARDINAL;
                           (* -- /AUS *) VAR charFound      : BOOLEAN;
                           (* -- /AUS *) VAR posOfChar      : CARDINAL );

VAR __REG__ sLen : CARDINAL;
    __REG__ i    : SIGNEDWORD;

BEGIN
 charFound := FALSE;
 sLen      := Length(stringToSearch);
 IF sLen = 0 THEN
   RETURN;
 END;
 IF startIndex >= sLen THEN
   i := VAL(SIGNEDWORD,sLen) - 1;
 ELSE
   i := VAL(SIGNEDWORD,startIndex);
 END;

 WHILE (i >= 0) & ~inClass(stringToSearch[i]) DO
   DEC(i);
 END;

 IF i >= 0 THEN
   charFound := TRUE;
   posOfChar := VAL(CARDINAL,i);
 END;
END FindPrevInClass;

END StringsX.
