IMPLEMENTATION MODULE cstr;
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
(* 05-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD;

IMPORT e;

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
 WHILE ptr^[len] <> 0C DO
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
 WHILE c <> 0C DO
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
 WHILE c <> 0C DO
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
 WHILE d^[dIdx] <> 0C DO
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
 WHILE d^[dIdx] <> 0C DO
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
 IF c <> 0C THEN
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
   IF c <> s2^[idx] THEN
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

PROCEDURE stricmp ((* EIN/ -- *) str1 : StrPtr;
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
   IF c1 <> c2 THEN
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
END stricmp;

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
   IF c <> s2^[idx] THEN
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

PROCEDURE strnicmp ((* EIN/ -- *) str1  : StrPtr;
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
   IF c1 <> c2 THEN
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
END strnicmp;

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
 WHILE p^[pLen] <> 0C DO
   INC(pLen);
 END;
 sLen := 0;
 WHILE s^[sLen] <> 0C DO
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
   WHILE (pIdx < pLen) AND (s^[sIdx] = p^[pIdx]) DO
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
 WHILE s^[sIdx] <> 0C DO
   c    := s^[sIdx];
   bIdx := 0;
   WHILE (bIdx < bLen) AND (b^[bIdx] <> c) DO
     INC(bIdx);
   END;
   IF bIdx < bLen THEN
     RETURN(CAST(StrPtr,ADR(s^[sIdx])));
   END;
   INC(sIdx);
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
 WHILE (idx <= max) AND (strM2[idx] <> EOS) DO
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
 WHILE (idx <= m) AND (c <> 0C) DO
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
 IF (err >= e.MINeBIOS) AND (err <= e.MAXeBIOS) THEN
   s := Messages^.bioserr[VAL(UNSIGNEDWORD,-err + e.MAXeBIOS)];
 ELSIF (err >= e.MINeGEMDOS) AND (err <= e.MAXeGEMDOS) THEN
   s := Messages^.gemdoserr[VAL(UNSIGNEDWORD,-err + e.MAXeGEMDOS)];
 ELSIF (err >= e.MINeMiNT) AND (err <= e.MAXeMiNT) THEN
   s := Messages^.minterr[VAL(UNSIGNEDWORD,-err + e.MAXeMiNT)];
 ELSIF (err >= e.MINePOSIX) AND (err <= e.MAXePOSIX) THEN
   s := Messages^.posixerr[VAL(UNSIGNEDWORD,-err + e.MAXePOSIX)];
 ELSIF (err >= e.MINeSOCKET) AND (err <= e.MAXeSOCKET) THEN
   s := Messages^.socketerr[VAL(UNSIGNEDWORD,-err + e.MAXeSOCKET)];
 ELSE
   s := Messages^.unknownerr;
 END;
 AssignCToM2(s, 0, errbuf);
 RETURN(ADR(errbuf));
END strerror;

(*---------------------------------------------------------------------------*)

PROCEDURE strsignal ((* EIN/ -- *) sig : int ): StrPtr;
VAR s : StrPtr;
BEGIN
 IF (sig >= 0) AND (sig <= 30) THEN
   s := Messages^.signalstr[VAL(UNSIGNEDWORD,sig)];
 ELSE
   s := Messages^.unknownsig;
 END;
 AssignCToM2(s, 0, sigbuf);
 RETURN(ADR(sigbuf));
END strsignal;

(*---------------------------------------------------------------------------*)

PROCEDURE Token ((* EIN/ -- *)     str   : StrPtr;
                 (* EIN/ -- *)     stop  : StrPtr;
                 (* EIN/AUS *) VAR idx   : StrRange;
                 (* EIN/AUS *) VAR l1    : StrRange;
                 (* EIN/AUS *) VAR l2    : StrRange;
                 (* -- /AUS *) VAR tlen  : StrRange;
                 (* -- /AUS *) VAR token : StrPtr   ): BOOLEAN;

VAR         end    : StrPtr;
            stpLen : StrRange;
    __REG__ min    : StrRange;
    __REG__ max    : StrRange;
    __REG__ strLen : StrRange;

BEGIN
 IF l1 = 0 THEN
   (* Beim ersten Aufruf muessen die Stringlaengen berechnet werden.
    * Sie werden fuer spaetere Aufrufe gemerkt.
    *)
   l1 := VAL(StrRange,strlen(str));
   l2 := VAL(StrRange,strlen(stop));
 END;
 strLen := l1;
 stpLen := l2;

 min := idx;
 IF (min > strLen) OR (stpLen = 0) THEN
   (* <str> vollstaendig durchsucht *)
   tlen  := 0;
   token := NULL;
   RETURN(FALSE);
 END;

 (* Anfang des naechsten Tokens suchen, dabei fuehrende Leerzeichen
  * ueberlesen.
  *)
 WHILE (min < strLen) AND (str^[min] = ' ') DO
   INC(min);
 END;
 token := CAST(StrPtr,ADR(str^[min]));

 (* Abschliessendes Trennzeichen suchen, das fuehrende wurde schon
  * beim letzten Mal ueberlesen, oder es ist das erste Token im String.
  *)
 end := strpbrk(token, stop);
 IF end = NULL THEN
   (* Kein Trennzeichen mehr -> jetzt kommt letztes Token, oder der
    * String ist zuende.
    *)
   max := strLen;
   idx := strLen + 1; (* beim naechsten Mal abbrechen *)
 ELSE
   max := VAL(StrRange,DIFADR(end, str));
   idx := max + 1; (* beim naechsten Mal hinter dem Trenner starten *)
 END;

 WHILE (max > min) AND (str^[max-1] = ' ') DO
   (* abschliessende Leerzeichen ueberlesen *)
   DEC(max);
 END;

 tlen := max - min;
 RETURN(TRUE);
END Token;

(*===========================================================================*)

BEGIN (* cstr *)
 null  := 0C;
 nullP := CAST(StrPtr,ADR(null));
END cstr.
