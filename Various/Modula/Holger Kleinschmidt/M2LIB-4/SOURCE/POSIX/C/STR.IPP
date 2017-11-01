IMPLEMENTATION MODULE str;
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
(* 29-Mae-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD;

FROM er IMPORT
(* CONST*) MINeBIOS, MAXeBIOS, MINeGEMDOS, MAXeGEMDOS, MINeMiNT, MAXeMiNT,
           MINePOSIX, MAXePOSIX, MINeSOCKET, MAXeSOCKET;

FROM types IMPORT
(* CONST*) EOS, MAXSTR,
(* TYPE *) int, unsigned, sizeT, StrPtr, StrRange;

FROM ctype IMPORT
(* PROC *) tolower, toupper;

FROM LCTypes IMPORT
(* TYPE *) LCMessages;

FROM LC IMPORT
(* VAR  *) Messages;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  null  : CHAR;
  nullP : StrPtr;

VAR
  errbuf : ARRAY [0..100] OF CHAR;
  sigbuf : ARRAY [0..100] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE strlen ((* EIN/ -- *) str : StrPtr ): sizeT;

VAR __REG__ len : StrRange;
    __REG__ ptr : StrPtr;

BEGIN
 ptr := str;
 IF ptr = NULL THEN
   RETURN(0);
 END;
 len := 0;
 WHILE ptr^[len] # 0C DO
   INC(len);
 END;
 RETURN(VAL(sizeT,len));
END strlen;

(*---------------------------------------------------------------------------*)

PROCEDURE strcpy ((* EIN/ -- *) dst : StrPtr;
                  (* EIN/ -- *) src : StrPtr );

VAR __REG__ idx : StrRange;
    __REG__ c   : CHAR;
    __REG__ d   : StrPtr;
    __REG__ s   : StrPtr;

BEGIN
 d := dst;
 s := src;
 IF d = NULL THEN
   RETURN;
 ELSIF s = NULL THEN
   s := nullP;
 END;
 idx := 0;
 REPEAT
   c := s^[idx];
   d^[idx] := c;
   INC(idx);
 UNTIL c = 0C;
END strcpy;

(*---------------------------------------------------------------------------*)

PROCEDURE strncpy ((* EIN/ -- *) dst : StrPtr;
                   (* EIN/ -- *) src : StrPtr;
                   (* EIN/ -- *) len : sizeT  );

VAR __REG__ idx : StrRange;
    __REG__ c   : CHAR;
    __REG__ d   : StrPtr;
    __REG__ s   : StrPtr;
    __REG__ l   : StrRange;

BEGIN
 d := dst;
 s := src;
 IF len > VAL(sizeT,MAXSTR) THEN
   l := MAXSTR;
 ELSE
   l := VAL(StrRange,len);
 END;
 IF (d = NULL) OR (l = 0) THEN
   RETURN;
 ELSIF s = NULL THEN
   s := nullP;
 END;
 idx := 0;
 REPEAT
   c := s^[idx];
   d^[idx] := c;
   INC(idx);
   DEC(l);
 UNTIL (c = 0C) OR (l = 0);
 WHILE l > 0 DO
   d^[idx] := 0C;
   INC(idx);
   DEC(l);
 END;
END strncpy;

(*---------------------------------------------------------------------------*)

PROCEDURE strlwr ((* EIN/ -- *) str : StrPtr );

VAR __REG__ idx : StrRange;
    __REG__ ptr : StrPtr;
    __REG__ c   : CHAR;

BEGIN
 ptr := str;
 IF ptr = NULL THEN
   RETURN;
 END;
 idx := 0;
 c   := ptr^[0];
 WHILE c # 0C DO
   ptr^[idx] := tolower(c);
   INC(idx);
   c := ptr^[idx];
 END;
END strlwr;

(*---------------------------------------------------------------------------*)

PROCEDURE strupr ((* EIN/ -- *) str : StrPtr );

VAR __REG__ idx : StrRange;
    __REG__ ptr : StrPtr;
    __REG__ c   : CHAR;

BEGIN
 ptr := str;
 IF ptr = NULL THEN
   RETURN;
 END;
 idx := 0;
 c   := ptr^[0];
 WHILE c # 0C DO
   ptr^[idx] := toupper(c);
   INC(idx);
   c := ptr^[idx];
 END;
END strupr;

(*---------------------------------------------------------------------------*)

PROCEDURE strcat ((* EIN/ -- *) dst : StrPtr;
                  (* EIN/ -- *) src : StrPtr );

VAR __REG__ dIdx : StrRange;
    __REG__ sIdx : StrRange;
    __REG__ c    : CHAR;
    __REG__ d    : StrPtr;
    __REG__ s    : StrPtr;

BEGIN
 d := dst;
 s := src;
 IF (d = NULL) OR (s = NULL) THEN
   RETURN;
 END;
 dIdx := 0;
 WHILE d^[dIdx] # 0C DO
   INC(dIdx);
 END;
 sIdx := 0;
 REPEAT
   c := s^[sIdx];
   d^[dIdx] := c;
   INC(sIdx);
   INC(dIdx);
 UNTIL c = 0C;
END strcat;

(*---------------------------------------------------------------------------*)

PROCEDURE strncat ((* EIN/ -- *) dst : StrPtr;
                   (* EIN/ -- *) src : StrPtr;
                   (* EIN/ -- *) len : sizeT  );

VAR __REG__ dIdx : StrRange;
    __REG__ sIdx : StrRange;
    __REG__ c    : CHAR;
    __REG__ d    : StrPtr;
    __REG__ s    : StrPtr;
    __REG__ l    : StrRange;

BEGIN
 d := dst;
 s := src;
 IF len > VAL(sizeT,MAXSTR) THEN
   l := MAXSTR;
 ELSE
   l := VAL(StrRange,len);
 END;
 IF (d = NULL) OR (s = NULL) OR (l = 0) THEN
   RETURN;
 END;
 dIdx := 0;
 WHILE d^[dIdx] # 0C DO
   INC(dIdx);
 END;
 sIdx := 0;
 REPEAT
   c := s^[sIdx];
   d^[dIdx] := c;
   INC(sIdx);
   INC(dIdx);
   DEC(l);
 UNTIL (c = 0C) OR (l = 0);
 IF c # 0C THEN
   d^[dIdx] := 0C;
 END;
END strncat;

(*---------------------------------------------------------------------------*)

PROCEDURE strcmp ((* EIN/ -- *) str1 : StrPtr;
                  (* EIN/ -- *) str2 : StrPtr ): int;

VAR __REG__ idx : StrRange;
    __REG__ c   : CHAR;
    __REG__ s1  : StrPtr;
    __REG__ s2  : StrPtr;

BEGIN
 s1 := str1;
 s2 := str2;
 IF s1 = NULL THEN
   IF s2 = NULL THEN
     RETURN(0);
   ELSE
     RETURN(-1);
   END;
 ELSIF s2 = NULL THEN
   RETURN(1);
 END;

 idx := 0;
 LOOP
   c := s1^[idx];
   IF c # s2^[idx] THEN
     IF c < s2^[idx] THEN
       RETURN(-1);
     ELSE
       RETURN(1);
     END;
   ELSIF c = 0C THEN
     RETURN(0);
   END;
   INC(idx);
 END;
END strcmp;

(*---------------------------------------------------------------------------*)

PROCEDURE strcasecmp ((* EIN/ -- *) str1 : StrPtr;
                      (* EIN/ -- *) str2 : StrPtr ): int;

VAR __REG__ idx : StrRange;
    __REG__ c1  : CHAR;
    __REG__ c2  : CHAR;
    __REG__ s1  : StrPtr;
    __REG__ s2  : StrPtr;

BEGIN
 s1 := str1;
 s2 := str2;
 IF s1 = NULL THEN
   IF s2 = NULL THEN
     RETURN(0);
   ELSE
     RETURN(-1);
   END;
 ELSIF s2 = NULL THEN
   RETURN(1);
 END;

 idx := 0;
 LOOP
   c1 := CAP(s1^[idx]);
   c2 := CAP(s2^[idx]);
   IF c1 # c2 THEN
     IF c1 < c2 THEN
       RETURN(-1);
     ELSE
       RETURN(1);
     END;
   ELSIF c1 = 0C THEN
     RETURN(0);
   END;
   INC(idx);
 END;
END strcasecmp;

(*---------------------------------------------------------------------------*)

PROCEDURE strncmp ((* EIN/ -- *) str1  : StrPtr;
                   (* EIN/ -- *) str2  : StrPtr;
                   (* EIN/ -- *) len   : sizeT  ): int;

VAR __REG__ idx : StrRange;
    __REG__ l   : StrRange;
    __REG__ c   : CHAR;
    __REG__ s1  : StrPtr;
    __REG__ s2  : StrPtr;

BEGIN
 s1 := str1;
 s2 := str2;
 IF len > VAL(sizeT,MAXSTR) THEN
   l := MAXSTR;
 ELSE
   l := VAL(StrRange,len);
 END;
 IF s1 = NULL THEN
   IF s2 = NULL THEN
     RETURN(0);
   ELSE
     RETURN(-1);
   END;
 ELSIF s2 = NULL THEN
   RETURN(1);
 END;
 IF l = 0 THEN
   RETURN(0);
 END;

 idx := 0;
 REPEAT
   c := s1^[idx];
   IF c # s2^[idx] THEN
     IF c < s2^[idx] THEN
       RETURN(-1);
     ELSE
       RETURN(1);
     END;
   ELSIF c = 0C THEN
     RETURN(0);
   END;
   INC(idx);
   DEC(l);
 UNTIL l = 0;
 RETURN(0);
END strncmp;

(*---------------------------------------------------------------------------*)

PROCEDURE strncasecmp ((* EIN/ -- *) str1  : StrPtr;
                       (* EIN/ -- *) str2  : StrPtr;
                       (* EIN/ -- *) len   : sizeT  ): int;

VAR __REG__ idx : StrRange;
    __REG__ l   : StrRange;
    __REG__ c1  : CHAR;
    __REG__ c2  : CHAR;
    __REG__ s1  : StrPtr;
    __REG__ s2  : StrPtr;

BEGIN
 s1 := str1;
 s2 := str2;
 IF len > VAL(sizeT,MAXSTR) THEN
   l := MAXSTR;
 ELSE
   l := VAL(StrRange,len);
 END;
 IF s1 = NULL THEN
   IF s2 = NULL THEN
     RETURN(0);
   ELSE
     RETURN(-1);
   END;
 ELSIF s2 = NULL THEN
   RETURN(1);
 END;
 IF l = 0 THEN
   RETURN(0);
 END;

 idx := 0;
 REPEAT
   c1 := CAP(s1^[idx]);
   c2 := CAP(s2^[idx]);
   IF c1 # c2 THEN
     IF c1 < c2 THEN
       RETURN(-1);
     ELSE
       RETURN(1);
     END;
   ELSIF c1 = 0C THEN
     RETURN(0);
   END;
   INC(idx);
   DEC(l);
 UNTIL l = 0;
 RETURN(0);
END strncasecmp;

(*---------------------------------------------------------------------------*)

PROCEDURE strchr ((* EIN/ -- *) s : StrPtr;
                  (* EIN/ -- *) c : CHAR   ): StrPtr;

VAR __REG__ idx : StrRange;
    __REG__ ptr : StrPtr;
    __REG__ ch  : CHAR;

BEGIN
 ptr := s;
 IF ptr = NULL THEN
   RETURN(NULL);
 END;
 idx := 0;
 LOOP
   ch := ptr^[idx];
   IF ch = c THEN
     RETURN(CAST(StrPtr,ADR(ptr^[idx])));
   ELSIF ch = 0C THEN
     RETURN(NULL);
   END;
   INC(idx);
 END;
END strchr;

(*---------------------------------------------------------------------------*)

PROCEDURE strrchr ((* EIN/ -- *) s : StrPtr;
                   (* EIN/ -- *) c : CHAR   ): StrPtr;

VAR __REG__ idx : StrRange;
    __REG__ ptr : StrPtr;
    __REG__ tmp : SIGNEDWORD;
    __REG__ ch  : CHAR;

BEGIN
 ptr := s;
 IF ptr = NULL THEN
   RETURN(NULL);
 END;
 tmp := -1;
 idx := 0;
 LOOP
   ch := ptr^[idx];
   IF ch = 0C THEN
     IF c = 0C THEN
       RETURN(CAST(StrPtr,ADR(ptr^[idx])));
     ELSIF tmp = -1 THEN
       RETURN(NULL);
     ELSE
       RETURN(CAST(StrPtr,ADR(ptr^[tmp])));
     END;
   END;
   IF ch = c THEN
     tmp := VAL(SIGNEDWORD,idx);
   END;
   INC(idx);
 END;
END strrchr;

(*---------------------------------------------------------------------------*)

PROCEDURE strstr ((* EIN/ -- *) str : StrPtr;
                  (* EIN/ -- *) pat : StrPtr ): StrPtr;

VAR __REG__ pLen : StrRange;
    __REG__ sLen : StrRange;
    __REG__ pIdx : StrRange;
    __REG__ sIdx : StrRange;
    __REG__ s    : StrPtr;
    __REG__ p    : StrPtr;

BEGIN
 s := str;
 p := pat;
 IF (s = NULL) OR (p = NULL) THEN
   RETURN(NULL);
 END;
 pLen := 0;
 WHILE p^[pLen] # 0C DO
   INC(pLen);
 END;
 sLen := 0;
 WHILE s^[sLen] # 0C DO
   INC(sLen);
 END;
 IF pLen = 0 THEN
   RETURN(CAST(StrPtr,ADR(s^[sLen])));
 ELSIF pLen > sLen THEN
   RETURN(NULL);
 END;

 DEC(sLen, pLen);
 sIdx := 0;
 LOOP
   pIdx := 0;
   WHILE (pIdx < pLen) & (s^[sIdx] = p^[pIdx]) DO
     INC(sIdx);
     INC(pIdx);
   END;
   DEC(sIdx, pIdx);

   IF pIdx = pLen THEN
     RETURN(CAST(StrPtr,ADR(s^[sIdx])));
   ELSIF sLen = 0 THEN
     RETURN(NULL);
   END;

   INC(sIdx);
   DEC(sLen);
 END;
END strstr;

(*---------------------------------------------------------------------------*)

PROCEDURE strpbrk ((* EIN/ -- *) str : StrPtr;
                   (* EIN/ -- *) brk : StrPtr ): StrPtr;

VAR __REG__ bIdx : StrRange;
    __REG__ bLen : StrRange;
    __REG__ sIdx : StrRange;
    __REG__ c    : CHAR;
    __REG__ b    : StrPtr;
    __REG__ s    : StrPtr;

BEGIN
 s := str;
 b := brk;
 IF (s = NULL) OR (b = NULL) THEN
   RETURN(NULL);
 END;
 bLen := VAL(StrRange,strlen(b));
 sIdx := 0;
 c    := s^[0];
 WHILE c # 0C DO
   bIdx := 0;
   WHILE (bIdx < bLen) & (b^[bIdx] # c) DO
     INC(bIdx);
   END;
   IF bIdx < bLen THEN
     RETURN(CAST(StrPtr,ADR(s^[sIdx])));
   END;
   INC(sIdx);
   c := s^[sIdx];
 END;
 RETURN(NULL);
END strpbrk;

(*---------------------------------------------------------------------------*)

PROCEDURE AssignM2ToC ((* EIN/ -- *) REF strM2 : ARRAY OF CHAR;
                       (* EIN/ -- *)     sizeC : StrRange;
                       (* EIN/ -- *)     strC  : StrPtr        );

VAR __REG__ idx : StrRange;
    __REG__ max : StrRange;
    __REG__ ptr : StrPtr;

BEGIN
 ptr := strC;
 IF (ptr = NULL) OR (sizeC = 0) THEN
   RETURN;
 END;

 IF VAL(StrRange,HIGH(strM2)) < sizeC THEN
   max := VAL(StrRange,HIGH(strM2));
 ELSE
   max := sizeC - 1;
 END;
 idx := 0;
 WHILE (idx <= max) & (strM2[idx] # EOS) DO
   ptr^[idx] := strM2[idx];
   INC(idx);
 END;
 IF idx < sizeC THEN
   ptr^[idx] := 0C;
 END;
END AssignM2ToC;

(*---------------------------------------------------------------------------*)

PROCEDURE AssignCToM2 ((* EIN/ -- *)     strC  : StrPtr;
                       (* EIN/ -- *)     max   : StrRange;
                       (* -- /AUS *) VAR strM2 : ARRAY OF CHAR );

VAR __REG__ idx : StrRange;
    __REG__ m   : StrRange;
    __REG__ c   : CHAR;
    __REG__ ptr : StrPtr;

BEGIN
 ptr := strC;
 IF ptr = NULL THEN
   strM2[0] := EOS;
   RETURN;
 END;
 IF (max = 0) OR (max > VAL(StrRange,HIGH(strM2))) THEN
   m := VAL(StrRange,HIGH(strM2));
 ELSE
   m := max - 1;
 END;
 idx := 0;
 c   := ptr^[0];
 WHILE (idx <= m) & (c # 0C) DO
   strM2[idx] := c;
   INC(idx);
   c := ptr^[idx];
 END;
 IF idx <= VAL(StrRange,HIGH(strM2)) THEN
   strM2[idx] := EOS;
 END;
END AssignCToM2;

(*---------------------------------------------------------------------------*)

PROCEDURE strerror ((* EIN/ -- *) err : int ): StrPtr;
VAR s : StrPtr;
BEGIN
 IF (err >= MINeBIOS) & (err <= MAXeBIOS) THEN
   s := Messages^.bioserr[VAL(UNSIGNEDWORD,-err + MAXeBIOS)];
 ELSIF (err >= MINeGEMDOS) & (err <= MAXeGEMDOS) THEN
   s := Messages^.gemdoserr[VAL(UNSIGNEDWORD,-err + MAXeGEMDOS)];
 ELSIF (err >= MINeMiNT) & (err <= MAXeMiNT) THEN
   s := Messages^.minterr[VAL(UNSIGNEDWORD,-err + MAXeMiNT)];
 ELSIF (err >= MINePOSIX) & (err <= MAXePOSIX) THEN
   s := Messages^.posixerr[VAL(UNSIGNEDWORD,-err + MAXePOSIX)];
 ELSIF (err >= MINeSOCKET) & (err <= MAXeSOCKET) THEN
   s := Messages^.socketerr[VAL(UNSIGNEDWORD,-err + MAXeSOCKET)];
 ELSE
   s := Messages^.unknownstr[0];
 END;
 AssignCToM2(s, 0, errbuf);
 RETURN(ADR(errbuf));
END strerror;

(*---------------------------------------------------------------------------*)

PROCEDURE strsignal ((* EIN/ -- *) sig : int ): StrPtr;
VAR s : StrPtr;
BEGIN
 IF (sig >= 0) & (sig <= 30) THEN
   s := Messages^.signalstr[VAL(UNSIGNEDWORD,sig)];
 ELSE
   s := Messages^.unknownstr[1];
 END;
 AssignCToM2(s, 0, sigbuf);
 RETURN(ADR(sigbuf));
END strsignal;

(*---------------------------------------------------------------------------*)

PROCEDURE Token ((* EIN/ -- *)     str   : StrPtr;
                 (* EIN/ -- *)     stop  : StrPtr;
                 (* EIN/ -- *)     slen  : StrRange;
                 (* EIN/AUS *) VAR idx   : StrRange;
                 (* -- /AUS *) VAR tlen  : StrRange;
                 (* -- /AUS *) VAR token : StrPtr   ): BOOLEAN;

VAR __REG__ min    : StrRange;
    __REG__ max    : StrRange;
    __REG__ strLen : StrRange;
    __REG__ c2     : CHAR;
    __REG__ sidx   : StrRange;
    __REG__ c      : CHAR;

BEGIN
 strLen := slen;
 min    := idx;
 IF min > strLen THEN
   (* <str> vollstaendig durchsucht *)
   tlen  := 0;
   token := NULL;
   RETURN(FALSE);
 END;

 (* Anfang des naechsten Tokens suchen, dabei fuehrende Leerzeichen
  * ueberlesen.
  *)
 WHILE (min < strLen) & (str^[min] = ' ') DO
   INC(min);
 END;

 (* Abschliessendes Trennzeichen suchen, das fuehrende wurde schon
  * beim letzten Mal ueberlesen, oder es ist das erste Token im String.
  *)
 max := min;
 LOOP
   IF max = strLen THEN
     EXIT;
   END;
   c    := str^[max];
   sidx := 0;
   REPEAT
     c2 := stop^[sidx];
     INC(sidx);
   UNTIL (c2 = 0C) OR (c2 = c);
   IF c2 # 0C THEN
     EXIT;
   END;
   INC(max);
 END;

 IF max = strLen THEN
   (* Kein Trennzeichen mehr -> jetzt kommt letztes Token, oder der
    * String ist zuende.
    *)
   idx := strLen + 1; (* beim naechsten Mal abbrechen *)
 ELSE
   idx := max + 1; (* beim naechsten Mal hinter dem Trenner starten *)
 END;

 WHILE (max > min) & (str^[max-1] = ' ') DO
   (* abschliessende Leerzeichen ueberlesen *)
   DEC(max);
 END;

 tlen  := max - min;
 token := ADR(str^[min]);
 RETURN(TRUE);
END Token;

(*===========================================================================*)

BEGIN (* str *)
 null  := 0C;
 nullP := ADR(null);
END str.
