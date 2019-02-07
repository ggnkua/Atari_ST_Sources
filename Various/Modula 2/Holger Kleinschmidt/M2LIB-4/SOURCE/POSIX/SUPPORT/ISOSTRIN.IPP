IMPLEMENTATION MODULE ISOStrings;
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
(* 27-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* CONST*) MAXCARD,
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD;

IMPORT types;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE Length ((* EIN/ -- *) REF stringVal : ARRAY OF CHAR): CARDINAL;

#if !((defined ISOM2) || (defined MM2) || (defined HM2))
VAR __REG__ i : UNSIGNEDWORD;

BEGIN
 i := 0;
 WHILE (i <= VAL(UNSIGNEDWORD,HIGH(stringVal))) & (stringVal[i] # types.EOS) DO
   INC(i);
 END;
 RETURN(VAL(CARDINAL,i));
#else
BEGIN
 RETURN(VAL(CARDINAL,LENGTH(stringVal)));
#endif
END Length;

(*---------------------------------------------------------------------------*)

PROCEDURE Assign ((* EIN/ -- *) REF source      : ARRAY OF CHAR;
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
   destination[i] := source[i];
   INC(i);
 END;
 IF i <= VAL(UNSIGNEDWORD,HIGH(destination)) THEN
   destination[i] := types.EOS;
 END;
END Assign;

(*---------------------------------------------------------------------------*)

PROCEDURE Extract ((* EIN/ -- *) REF source          : ARRAY OF CHAR;
                   (* EIN/ -- *)     startIndex      : CARDINAL;
                   (* EIN/ -- *)     numberToExtract : CARDINAL;
                   (* -- /AUS *) VAR destination     : ARRAY OF CHAR );

VAR         sLen : CARDINAL;
    __REG__ sIdx : UNSIGNEDWORD;
    __REG__ dIdx : SIGNEDWORD;
    __REG__ max  : SIGNEDWORD;

BEGIN
 sLen := Length(source);

 IF   (numberToExtract              > MAXCARD - startIndex)
   OR (startIndex + numberToExtract > sLen)
 THEN
   IF startIndex < sLen THEN
     numberToExtract := sLen - startIndex;
   ELSE
     numberToExtract := 0; (* destination := "" *)
     startIndex      := 0;
   END;
 END;

 IF numberToExtract > VAL(CARDINAL,HIGH(destination)) THEN
   max := VAL(SIGNEDWORD,HIGH(destination));
 ELSE
   max := VAL(SIGNEDWORD,numberToExtract) - 1;
 END;

 sIdx := VAL(UNSIGNEDWORD,startIndex);
 dIdx := 0;
 WHILE dIdx <= max DO
   destination[dIdx] := source[sIdx];
   INC(dIdx);
   INC(sIdx);
 END;

 IF dIdx <= VAL(SIGNEDWORD,HIGH(destination)) THEN
   destination[dIdx] := types.EOS;
 END;
END Extract;

(*---------------------------------------------------------------------------*)

PROCEDURE Delete ((* EIN/AUS *) VAR stringVar      : ARRAY OF CHAR;
                  (* EIN/ -- *)     startIndex     : CARDINAL;
                  (* EIN/ -- *)     numberToDelete : CARDINAL      );

VAR __REG__ sLen : CARDINAL;
    __REG__ sIdx : CARDINAL;
    __REG__ dIdx : CARDINAL;

BEGIN
 sLen := Length(stringVar);

 IF startIndex < MAXCARD - numberToDelete THEN
   INC(numberToDelete, startIndex);
 ELSE
   numberToDelete := MAXCARD;
 END;
 dIdx := startIndex;
 sIdx := numberToDelete;

 WHILE sIdx < sLen DO
   stringVar[VAL(UNSIGNEDWORD,dIdx)] := stringVar[VAL(UNSIGNEDWORD,sIdx)];
   INC(dIdx);
   INC(sIdx);
 END;

 IF dIdx <= VAL(CARDINAL,HIGH(stringVar)) THEN
   stringVar[dIdx] := types.EOS;
 END;
END Delete;

(*---------------------------------------------------------------------------*)

PROCEDURE Insert ((* EIN/ -- *)     source      : ARRAY OF CHAR;
                  (* EIN/ -- *)     startIndex  : CARDINAL;
                  (* EIN/AUS *) VAR destination : ARRAY OF CHAR );

VAR         spc  : SIGNEDWORD;
    __REG__ dLen : SIGNEDWORD;
    __REG__ sLen : SIGNEDWORD;
    __REG__ i    : SIGNEDWORD;

BEGIN
 dLen := VAL(SIGNEDWORD,Length(destination));
 sLen := VAL(SIGNEDWORD,Length(source));

 IF startIndex >= VAL(CARDINAL,dLen) THEN
   RETURN;
 END;

 spc := (VAL(SIGNEDWORD,HIGH(destination) + 1) - dLen) - sLen;

 IF spc < 0 THEN
   INC(dLen, spc);
   IF VAL(SIGNEDWORD,HIGH(destination) + 1) - VAL(SIGNEDWORD,startIndex) < sLen THEN
     sLen := VAL(SIGNEDWORD,HIGH(destination) + 1) - VAL(SIGNEDWORD,startIndex);
   END;
 ELSIF spc > 0 THEN
   destination[dLen+sLen] := types.EOS;
 END;

 FOR i := dLen - 1 TO VAL(SIGNEDWORD,startIndex) BY -1 DO
   destination[i+sLen] := destination[i];
 END;

 dLen := VAL(SIGNEDWORD,startIndex);
 FOR i := 0 TO sLen - 1 DO
   destination[i+dLen] := source[i];
 END;
END Insert;

(*---------------------------------------------------------------------------*)

PROCEDURE Replace ((* EIN/ -- *)     source      : ARRAY OF CHAR;
                   (* EIN/ -- *)     startIndex  : CARDINAL;
                   (* EIN/AUS *) VAR destination : ARRAY OF CHAR );

VAR         dLen : CARDINAL;
            sLen : CARDINAL;
    __REG__ sIdx : UNSIGNEDWORD;
    __REG__ dIdx : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;

BEGIN
 dLen := Length(destination);
 sLen := Length(source);

 IF startIndex >= dLen THEN
   RETURN;
 END;
 IF sLen <= dLen - startIndex THEN
   max := VAL(UNSIGNEDWORD,sLen);
 ELSE
   max := VAL(UNSIGNEDWORD,dLen - startIndex);
 END;

 sIdx := 0;
 dIdx := VAL(UNSIGNEDWORD,startIndex);
 WHILE sIdx < max DO
   destination[dIdx] := source[sIdx];
   INC(sIdx);
   INC(dIdx);
 END;
END Replace;

(*---------------------------------------------------------------------------*)

PROCEDURE Append ((* EIN/ -- *)     source      : ARRAY OF CHAR;
                  (* EIN/AUS *) VAR destination : ARRAY OF CHAR );

VAR __REG__ dIdx : UNSIGNEDWORD;
    __REG__ sIdx : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;

BEGIN
 dIdx := VAL(UNSIGNEDWORD,Length(destination));
 max  := VAL(UNSIGNEDWORD,HIGH(destination) + 1) - dIdx;
 IF max > VAL(UNSIGNEDWORD,HIGH(source)) THEN
   max := VAL(UNSIGNEDWORD,HIGH(source)) + 1;
 END;

 sIdx := 0;
 WHILE (sIdx < max) & (source[sIdx] # types.EOS) DO
   destination[dIdx] := source[sIdx];
   INC(sIdx);
   INC(dIdx);
 END;

 IF dIdx <= VAL(UNSIGNEDWORD,HIGH(destination)) THEN
   destination[dIdx] := types.EOS;
 END;
END Append;

(*---------------------------------------------------------------------------*)

PROCEDURE Concat ((* EIN/ -- *) REF source1     : ARRAY OF CHAR;
                  (* EIN/ -- *)     source2     : ARRAY OF CHAR;
                  (* -- /AUS *) VAR destination : ARRAY OF CHAR );

VAR __REG__ i1  : SIGNEDWORD;
    __REG__ i2  : SIGNEDWORD;
    __REG__ max : SIGNEDWORD;

BEGIN
 IF HIGH(source1) > HIGH(destination) THEN
   max := VAL(SIGNEDWORD,HIGH(destination));
 ELSE
   max := VAL(SIGNEDWORD,HIGH(source1));
 END;

 i1 := 0;
 WHILE (i1 <= max) & (source1[i1] # types.EOS) DO
   destination[i1] := source1[i1];
   INC(i1);
 END;

 IF VAL(SIGNEDWORD,HIGH(source2)) > (VAL(SIGNEDWORD,HIGH(destination)) - i1) THEN
   max := VAL(SIGNEDWORD,HIGH(destination)) - i1;
 ELSE
   max := VAL(SIGNEDWORD,HIGH(source2));
 END;

 i2 := 0;
 WHILE (i2 <= max) & (source2[i2] # types.EOS) DO
   destination[i1] := source2[i2];
   INC(i1);
   INC(i2);
 END;

 IF i1 <= VAL(SIGNEDWORD,HIGH(destination)) THEN
   destination[i1] := types.EOS;
 END;
END Concat;

(*---------------------------------------------------------------------------*)

PROCEDURE CanAssignAll
  ((* EIN/ -- *)     sourceLength : CARDINAL;
   (* EIN/ -- *) VAR destination  : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(sourceLength <= VAL(CARDINAL,HIGH(destination)) + 1);
END CanAssignAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanExtractAll
  ((* EIN/ -- *)     sourceLength    : CARDINAL;
   (* EIN/ -- *)     startIndex      : CARDINAL;
   (* EIN/ -- *)     numberToExtract : CARDINAL;
   (* EIN/ -- *) VAR destination     : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(  (numberToExtract <= sourceLength)
        & (startIndex      <= sourceLength - numberToExtract)
        & (numberToExtract <= VAL(CARDINAL,HIGH(destination)) + 1));
END CanExtractAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanDeleteAll ((* EIN/ -- *) sourceLength   : CARDINAL;
                        (* EIN/ -- *) startIndex     : CARDINAL;
                        (* EIN/ -- *) numberToDelete : CARDINAL ): BOOLEAN;

BEGIN
 RETURN(  (numberToDelete <= sourceLength)
        & (startIndex     <= sourceLength - numberToDelete));
END CanDeleteAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanInsertAll
  ((* EIN/ -- *)     sourceLength : CARDINAL;
   (* EIN/ -- *)     startIndex   : CARDINAL;
   (* EIN/ -- *) VAR destination  : ARRAY OF CHAR ): BOOLEAN;

VAR __REG__ dLen : CARDINAL;

BEGIN
 dLen := Length(destination);
 RETURN(  (startIndex   < dLen)
        & (sourceLength <= VAL(CARDINAL,HIGH(destination)+1) - dLen));
END CanInsertAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanReplaceAll
  ((* EIN/ -- *)     sourceLength : CARDINAL;
   (* EIN/ -- *)     startIndex   : CARDINAL;
   (* EIN/ -- *) VAR destination  : ARRAY OF CHAR ): BOOLEAN;

VAR __REG__ dLen : CARDINAL;

BEGIN
 dLen := Length(destination);
 RETURN(  (sourceLength <= dLen)
        & (startIndex   <= dLen - sourceLength));
END CanReplaceAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanAppendAll
  ((* EIN/ -- *)     sourceLength : CARDINAL;
   (* EIN/ -- *) VAR destination  : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(sourceLength <= VAL(CARDINAL,HIGH(destination) + 1) - Length(destination));
END CanAppendAll;

(*---------------------------------------------------------------------------*)

PROCEDURE CanConcatAll
  ((* EIN/ -- *)     source1Length : CARDINAL;
   (* EIN/ -- *)     source2Length : CARDINAL;
   (* EIN/ -- *) VAR destination   : ARRAY OF CHAR ): BOOLEAN;

BEGIN
 RETURN(  (source1Length <= VAL(CARDINAL,HIGH(destination) + 1))
        & (source2Length <= VAL(CARDINAL,HIGH(destination) + 1) - source1Length));
END CanConcatAll;

(*---------------------------------------------------------------------------*)

PROCEDURE Compare
  ((* EIN/ -- *) REF stringVal1 : ARRAY OF CHAR;
   (* EIN/ -- *) REF stringVal2 : ARRAY OF CHAR ): CompareResults;

VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ ch  : CHAR;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(stringVal1) > HIGH(stringVal2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(stringVal2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(stringVal1));
 END;

 i := 0;
 REPEAT
   ch := stringVal1[i];
   IF ch # stringVal2[i]  THEN
     IF ch < stringVal2[i]  THEN
       RETURN(less);
     ELSE
       RETURN(greater);
     END;
   ELSIF ch = types.EOS THEN
     RETURN(equal);
   END;

   INC(i);
 UNTIL i > max;

 (* Bis hierher waren die beiden Strings gleich *)

 IF HIGH(stringVal1) < HIGH(stringVal2) THEN
   (* i <= HIGH(stringVal2) *)
   IF stringVal2[i] = types.EOS THEN
     RETURN(equal);
   ELSE
     RETURN(less);
   END;
 ELSIF HIGH(stringVal1) > HIGH(stringVal2) THEN
   (* i <= HIGH(stringVal1) *)
   IF stringVal1[i] = types.EOS  THEN
     RETURN(equal);
   ELSE
     RETURN(greater);
   END;
 ELSE (* HIGH(stringVal1) = HIGH(stringVal2) *)
   RETURN(equal);
 END;
END Compare;

(*---------------------------------------------------------------------------*)

PROCEDURE Equal ((* EIN/ -- *) REF stringVal1 : ARRAY OF CHAR;
                 (* EIN/ -- *) REF stringVal2 : ARRAY OF CHAR ): BOOLEAN;

VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ ch  : CHAR;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(stringVal1) > HIGH(stringVal2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(stringVal2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(stringVal1));
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

 RETURN(~ (   (HIGH(stringVal1) < HIGH(stringVal2))
            & (stringVal2[i] # types.EOS)
           OR (HIGH(stringVal1) > HIGH(stringVal2))
            & (stringVal1[i] # types.EOS)));
END Equal;

(*---------------------------------------------------------------------------*)

PROCEDURE FindNext ((* EIN/ -- *) REF pattern        : ARRAY OF CHAR;
                    (* EIN/ -- *) REF stringToSearch : ARRAY OF CHAR;
                    (* EIN/ -- *)     startIndex     : CARDINAL;
                    (* -- /AUS *) VAR patternFound   : BOOLEAN;
                    (* -- /AUS *) VAR posOfPattern   : CARDINAL      );

VAR         sLen  : CARDINAL;
            tries : CARDINAL;
    __REG__ pLen  : CARDINAL;
    __REG__ pIdx  : UNSIGNEDWORD;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 sLen := Length(stringToSearch);
 pLen := Length(pattern);

 patternFound := FALSE;
 IF (pLen = 0) OR (pLen > sLen) OR (startIndex > sLen - pLen) THEN
   RETURN;
 END;
 tries := sLen - pLen - startIndex;
 start := VAL(UNSIGNEDWORD,startIndex);

 LOOP
   pIdx := 0;
   WHILE (pIdx < VAL(UNSIGNEDWORD,pLen)) & (stringToSearch[start] = pattern[pIdx]) DO
     INC(start);
     INC(pIdx);
   END;
   DEC(start, pIdx);

   IF pIdx = VAL(UNSIGNEDWORD,pLen) THEN
     patternFound := TRUE;
     posOfPattern := VAL(CARDINAL,start);
     RETURN;
   ELSIF tries = 0 THEN
     RETURN;
   END;

   INC(start);
   DEC(tries);
 END;
END FindNext;

(*---------------------------------------------------------------------------*)

PROCEDURE FindPrev ((* EIN/ -- *) REF pattern        : ARRAY OF CHAR;
                    (* EIN/ -- *) REF stringToSearch : ARRAY OF CHAR;
                    (* EIN/ -- *)     startIndex     : CARDINAL;
                    (* -- /AUS *) VAR patternFound   : BOOLEAN;
                    (* -- /AUS *) VAR posOfPattern   : CARDINAL      );

VAR         sLen  : CARDINAL;
    __REG__ pLen  : CARDINAL;
    __REG__ pIdx  : UNSIGNEDWORD;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 sLen := Length(stringToSearch);
 pLen := Length(pattern);

 patternFound := FALSE;
 IF (pLen = 0) OR (pLen > sLen) THEN
   RETURN;
 END;
 IF startIndex > sLen - pLen THEN
   startIndex := sLen - pLen;
 END;
 start := VAL(UNSIGNEDWORD,startIndex);

 LOOP
   pIdx := 0;
   WHILE (pIdx < VAL(UNSIGNEDWORD,pLen)) & (stringToSearch[start] = pattern[pIdx]) DO
     INC(start);
     INC(pIdx);
   END;
   DEC(start, pIdx);

   IF pIdx = VAL(UNSIGNEDWORD,pLen) THEN
     patternFound := TRUE;
     posOfPattern := VAL(UNSIGNEDWORD,start);
     RETURN;
   ELSIF start = 0 THEN
     RETURN;
   END;

   DEC(start);
 END;
END FindPrev;

(*---------------------------------------------------------------------------*)

PROCEDURE FindDiff ((* EIN/ -- *) REF stringVal1      : ARRAY OF CHAR;
                    (* EIN/ -- *) REF stringVal2      : ARRAY OF CHAR;
                    (* -- /AUS *) VAR differenceFound : BOOLEAN;
                    (* -- /AUS *) VAR posOfDifference : CARDINAL      );

VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ ch  : CHAR;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(stringVal1) > HIGH(stringVal2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(stringVal2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(stringVal1));
 END;

 i := 0;
 REPEAT
   ch := stringVal1[i];
   IF ch # stringVal2[i]  THEN
     differenceFound := TRUE;
     posOfDifference := VAL(CARDINAL,i);
     RETURN;
   ELSIF ch = types.EOS THEN
     differenceFound := FALSE;
     RETURN;
   END;
   INC(i);
 UNTIL i > max;

 IF   (HIGH(stringVal1) < HIGH(stringVal2))
    & (stringVal2[i] # types.EOS)
   OR (HIGH(stringVal1) > HIGH(stringVal2))
    & (stringVal1[i] # types.EOS)
 THEN
   differenceFound := TRUE;
   posOfDifference := VAL(CARDINAL,i);
 ELSE
   differenceFound := FALSE;
 END;
END FindDiff;

(*---------------------------------------------------------------------------*)

PROCEDURE Capitalize ((* EIN/AUS *) VAR stringVar : ARRAY OF CHAR );

VAR __REG__ i : UNSIGNEDWORD;

BEGIN
 i := 0;
 WHILE (i <= VAL(UNSIGNEDWORD,HIGH(stringVar))) & (stringVar[i] # types.EOS) DO
   stringVar[i] := CAP(stringVar[i]);
   INC(i);
 END;
END Capitalize;

END ISOStrings.
