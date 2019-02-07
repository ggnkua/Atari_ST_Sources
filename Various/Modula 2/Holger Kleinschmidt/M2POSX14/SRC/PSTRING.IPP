IMPLEMENTATION MODULE pSTRING;
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
(* 25-Apr-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM PORTAB IMPORT
(* CONST*) NULL, MAXCARD,
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD;

FROM types IMPORT
(* CONST*) EOS;

FROM ctype IMPORT
(* PROC *) tolower, toupper;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  NOTFOUND = -1;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE SLEN ((* EIN/ -- *) REF s : ARRAY OF CHAR ): CARDINAL;
(*T*)
#if (defined ISOM2) || (defined MM2) || (defined HM2)
BEGIN
 RETURN(VAL(CARDINAL,LENGTH(s)));
#else
VAR __REG__ i : UNSIGNEDWORD;
BEGIN
 i := 0;
 WHILE (i <= VAL(UNSIGNEDWORD,HIGH(s))) AND (s[i] <> EOS) DO
   INC(i);
 END;
 RETURN(VAL(CARDINAL,i));
#endif
END SLEN;

(*---------------------------------------------------------------------------*)

PROCEDURE ASSIGN ((* EIN/ -- *) REF src : ARRAY OF CHAR;
                  (* -- /AUS *) VAR dst : ARRAY OF CHAR );
(*T*)
VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF HIGH(src) > HIGH(dst) THEN
   max := VAL(UNSIGNEDWORD,HIGH(dst));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(src));
 END;

 i := 0;
 WHILE (i <= max) AND (src[i] <> EOS) DO
   dst[i] := src[i];
   INC(i);
 END;
 IF i <= VAL(UNSIGNEDWORD,HIGH(dst)) THEN
   dst[i] := EOS;
 END;
END ASSIGN;

(*---------------------------------------------------------------------------*)

PROCEDURE CONCAT ((* EIN/ -- *) REF s1  : ARRAY OF CHAR;
                  (* EIN/ -- *)     s2  : ARRAY OF CHAR;
                  (* -- /AUS *) VAR dst : ARRAY OF CHAR );
(*T*)
VAR __REG__ i1  : SIGNEDWORD;
    __REG__ i2  : SIGNEDWORD;
    __REG__ max : SIGNEDWORD;

BEGIN
 IF HIGH(s1) > HIGH(dst) THEN
   max := VAL(SIGNEDWORD,HIGH(dst));
 ELSE
   max := VAL(SIGNEDWORD,HIGH(s1));
 END;

 i1 := 0;
 WHILE (i1 <= max) AND (s1[i1] <> EOS) DO
   dst[i1] := s1[i1];
   INC(i1);
 END;

 IF VAL(SIGNEDWORD,HIGH(s2)) > (VAL(SIGNEDWORD,HIGH(dst)) - i1) THEN
   max := VAL(SIGNEDWORD,HIGH(dst)) - i1;
 ELSE
   max := VAL(SIGNEDWORD,HIGH(s2));
 END;

 i2 := 0;
 WHILE (i2 <= max) AND (s2[i2] <> EOS) DO
   dst[i1] := s2[i2];
   INC(i1);
   INC(i2);
 END;

 IF i1 <= VAL(SIGNEDWORD,HIGH(dst)) THEN
   dst[i1] := EOS;
 END;
END CONCAT;

(*---------------------------------------------------------------------------*)

PROCEDURE iappend (    len : CARDINAL;
                   VAR app : ARRAY OF CHAR;
                   VAR dst : ARRAY OF CHAR );

VAR __REG__ dIdx : UNSIGNEDWORD;
    __REG__ aIdx : UNSIGNEDWORD;
    __REG__ max  : UNSIGNEDWORD;

BEGIN
 dIdx := VAL(UNSIGNEDWORD,SLEN(dst));
 max  := VAL(UNSIGNEDWORD,HIGH(dst) + 1) - dIdx;
 IF VAL(CARDINAL,max) > len THEN
   max := VAL(UNSIGNEDWORD,len);
 END;
 IF max > VAL(UNSIGNEDWORD,HIGH(app)) THEN
   max := VAL(UNSIGNEDWORD,HIGH(app) + 1);
 END;

 aIdx := 0;
 WHILE (aIdx < max) AND (app[aIdx] <> EOS) DO
   dst[dIdx] := app[aIdx];
   INC(aIdx);
   INC(dIdx);
 END;

 IF dIdx <= VAL(UNSIGNEDWORD,HIGH(dst)) THEN
   dst[dIdx] := EOS;
 END;
END iappend;

(*---------------------------------------------------------------------------*)

PROCEDURE APPEND ((* EIN/ -- *) REF app : ARRAY OF CHAR;
                  (* EIN/AUS *) VAR dst : ARRAY OF CHAR );
(*T*)
BEGIN
 iappend(MAXCARD, app, dst);
END APPEND;

(*---------------------------------------------------------------------------*)

PROCEDURE APPENDN ((* EIN/ -- *)     len : CARDINAL;
                   (* EIN/ -- *) REF app : ARRAY OF CHAR;
                   (* EIN/AUS *) VAR dst : ARRAY OF CHAR );
(*T*)
BEGIN
 iappend(len, app, dst);
END APPENDN;

(*---------------------------------------------------------------------------*)

PROCEDURE APPENDCHR ((* EIN/ -- *)     c   : CHAR;
                     (* EIN/AUS *) VAR dst : ARRAY OF CHAR );
(*T*)
VAR __REG__ dIdx : UNSIGNEDWORD;

BEGIN
 dIdx := VAL(UNSIGNEDWORD,SLEN(dst));
 IF dIdx <= VAL(UNSIGNEDWORD,HIGH(dst)) THEN
   dst[dIdx] := c;
   IF dIdx < VAL(UNSIGNEDWORD,HIGH(dst)) THEN
     dst[dIdx+1] := EOS;
   END;
 END;
END APPENDCHR;

(*---------------------------------------------------------------------------*)

PROCEDURE COPY ((* EIN/ -- *)     from : CARDINAL;
                (* EIN/ -- *)     len  : CARDINAL;
                (* EIN/ -- *) REF src  : ARRAY OF CHAR;
                (* -- /AUS *) VAR dst  : ARRAY OF CHAR );
(*T*)
VAR          srcLen : CARDINAL;
             cnt    : CARDINAL;
     __REG__ sIdx   : UNSIGNEDWORD;
     __REG__ dIdx   : SIGNEDWORD;
     __REG__ max    : SIGNEDWORD;

BEGIN
 srcLen := SLEN(src);

 IF (len > MAXCARD - from) OR (from + len > srcLen) THEN
   IF from < srcLen THEN
     cnt := srcLen - from;
   ELSE
     cnt := 0;
   END;
 ELSE
   cnt := len;
 END;

 IF cnt > VAL(CARDINAL,HIGH(dst)) THEN
   max := VAL(SIGNEDWORD,HIGH(dst));
 ELSE
   max := VAL(SIGNEDWORD,cnt) - 1;
 END;

 dIdx := 0;
 sIdx := VAL(UNSIGNEDWORD,from);
 WHILE dIdx <= max DO
   dst[dIdx] := src[sIdx];
   INC(dIdx);
   INC(sIdx);
 END;

 IF dIdx <= VAL(SIGNEDWORD,HIGH(dst)) THEN
   dst[dIdx] := EOS;
 END;
END COPY;

(*---------------------------------------------------------------------------*)

PROCEDURE INSERT ((* EIN/ -- *)     at  : CARDINAL;
                  (* EIN/ -- *)     ins : ARRAY OF CHAR;
                  (* EIN/AUS *) VAR s   : ARRAY OF CHAR );
(*T*)
VAR         spc  : SIGNEDWORD;
    __REG__ sLen : SIGNEDWORD;
    __REG__ iLen : SIGNEDWORD;
    __REG__ i    : SIGNEDWORD;

BEGIN
 sLen := VAL(SIGNEDWORD,SLEN(s));
 iLen := VAL(SIGNEDWORD,SLEN(ins));

 IF at > VAL(CARDINAL,sLen) THEN
   at := VAL(CARDINAL,sLen);
 END;

 spc := (VAL(SIGNEDWORD,HIGH(s) + 1) - sLen) - iLen;

 IF spc < 0 THEN
   INC(sLen, spc);
   IF VAL(SIGNEDWORD,HIGH(s) + 1) - VAL(SIGNEDWORD,at) < iLen THEN
     iLen := VAL(SIGNEDWORD,HIGH(s) + 1) - VAL(SIGNEDWORD,at);
   END;
 ELSIF spc > 0 THEN
   s[sLen+iLen] := EOS;
 END;

 FOR i := sLen - 1 TO VAL(SIGNEDWORD,at) BY -1 DO
   s[i+iLen] := s[i];
 END;

 FOR i := 0 TO iLen - 1 DO
   s[VAL(SIGNEDWORD,at)+i] := ins[i];
 END;
END INSERT;

(*---------------------------------------------------------------------------*)

PROCEDURE DELETE ((* EIN/ -- *)     from : CARDINAL;
                  (* EIN/ -- *)     len  : CARDINAL;
                  (* EIN/AUS *) VAR s    : ARRAY OF CHAR );
(*T*)
VAR __REG__ strLen : CARDINAL;

BEGIN
 strLen := SLEN(s);

 IF from < MAXCARD - len THEN
   INC(len, from);
 ELSE
   len := MAXCARD;
 END;

 WHILE len < strLen DO
   s[VAL(UNSIGNEDWORD,from)] := s[VAL(UNSIGNEDWORD,len)];
   INC(from);
   INC(len);
 END;

 IF from <= VAL(CARDINAL,HIGH(s)) THEN
   s[VAL(UNSIGNEDWORD,from)] := EOS;
 END;
END DELETE;

(*---------------------------------------------------------------------------*)

PROCEDURE LOWER ((* EIN/AUS *) VAR s : ARRAY OF CHAR );
(*T*)
VAR __REG__ i : UNSIGNEDWORD;

BEGIN
 i := 0;
 WHILE (i <= VAL(UNSIGNEDWORD,HIGH(s))) AND (s[i] <> EOS) DO
   s[i] := tolower(s[i]);
   INC(i);
 END;
END LOWER;

(*---------------------------------------------------------------------------*)

PROCEDURE UPPER ((* EIN/AUS *) VAR s : ARRAY OF CHAR );
(*T*)
VAR __REG__ i : UNSIGNEDWORD;

BEGIN
 i := 0;
 WHILE (i <= VAL(UNSIGNEDWORD,HIGH(s))) AND (s[i] <> EOS) DO
   s[i] := toupper(s[i]);
   INC(i);
 END;
END UPPER;

(*---------------------------------------------------------------------------*)

PROCEDURE compare (    len : CARDINAL;
                   VAR s1  : ARRAY OF CHAR;
                   VAR s2  : ARRAY OF CHAR ): INTEGER;

CONST less    = -1;
      equal   =  0;
      greater =  1;

VAR __REG__ i   : UNSIGNEDWORD;
    __REG__ ch  : CHAR;
    __REG__ max : UNSIGNEDWORD;

BEGIN
 IF len = 0 THEN
   RETURN(equal);
 ELSE
   DEC(len);
 END;
 IF HIGH(s1) > HIGH(s2) THEN
   max := VAL(UNSIGNEDWORD,HIGH(s2));
 ELSE
   max := VAL(UNSIGNEDWORD,HIGH(s1));
 END;
 IF VAL(CARDINAL,max) > len THEN
   max := VAL(UNSIGNEDWORD,len);
 END;

 i := 0;
 REPEAT
   ch := s1[i];
   IF ch <> s2[i]  THEN
     IF ch < s2[i]  THEN
       RETURN(less);
     ELSE
       RETURN(greater);
     END;
   ELSIF ch = EOS THEN
     RETURN(equal);
   END;

   INC(i);
 UNTIL i > max;

(* Bis hierher waren die beiden Strings gleich *)

 IF max = VAL(UNSIGNEDWORD,len) THEN
   RETURN(equal);
 ELSIF HIGH(s1) < HIGH(s2) THEN
   (* i <= HIGH(s2) *)
   IF s2[i] = EOS THEN
     RETURN(equal);
   ELSE
     RETURN(less);
   END;
 ELSIF HIGH(s1) > HIGH(s2) THEN
   (* i <= HIGH(s1) *)
   IF s1[i] = EOS  THEN
     RETURN(equal);
   ELSE
     RETURN(greater);
   END;
 ELSE (* HIGH(s1) = HIGH(s2) *)
   RETURN(equal);
 END;
END compare;

(*---------------------------------------------------------------------------*)

PROCEDURE EQUAL ((* EIN/ -- *) REF s1 : ARRAY OF CHAR;
                 (* EIN/ -- *) REF s2 : ARRAY OF CHAR ): BOOLEAN;
(*T*)
BEGIN
 RETURN(compare(MAXCARD, s1, s2) = 0);
END EQUAL;

(*---------------------------------------------------------------------------*)

PROCEDURE EQUALN ((* EIN/ -- *)     len : CARDINAL;
                  (* EIN/ -- *) REF s1  : ARRAY OF CHAR;
                  (* EIN/ -- *) REF s2  : ARRAY OF CHAR ): BOOLEAN;
(*T*)
BEGIN
 RETURN(compare(len, s1, s2) = 0);
END EQUALN;

(*---------------------------------------------------------------------------*)

PROCEDURE COMPARE ((* EIN/ -- *) REF s1 : ARRAY OF CHAR;
                   (* EIN/ -- *) REF s2 : ARRAY OF CHAR ): INTEGER;
(*T*)
BEGIN
 RETURN(compare(MAXCARD, s1, s2));
END COMPARE;

(*---------------------------------------------------------------------------*)

PROCEDURE COMPAREN ((* EIN/ -- *)     len : CARDINAL;
                    (* EIN/ -- *) REF s1  : ARRAY OF CHAR;
                    (* EIN/ -- *) REF s2  : ARRAY OF CHAR ): INTEGER;
(*T*)
BEGIN
 RETURN(compare(len, s1, s2));
END COMPAREN;

(*---------------------------------------------------------------------------*)

PROCEDURE LPOS ((* EIN/ -- *)     from : CARDINAL;
                (* EIN/ -- *) REF pat  : ARRAY OF CHAR;
                (* EIN/ -- *) REF s    : ARRAY OF CHAR ): INTEGER;
(*T*)
VAR         sLen  : CARDINAL;
            tries : CARDINAL;
    __REG__ pLen  : CARDINAL;
    __REG__ pIdx  : UNSIGNEDWORD;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 sLen := SLEN(s);
 pLen := SLEN(pat);

 IF (pLen = 0) OR (pLen > sLen) OR (from > sLen - pLen) THEN
   RETURN(NOTFOUND);
 ELSE
   tries := sLen - pLen - from;
   start := VAL(UNSIGNEDWORD,from);
 END;

 LOOP
   pIdx := 0;
   WHILE (pIdx < VAL(UNSIGNEDWORD,pLen)) AND (s[start] = pat[pIdx]) DO
     INC(start);
     INC(pIdx);
   END;
   DEC(start, pIdx);

   IF pIdx = VAL(UNSIGNEDWORD,pLen) THEN
     RETURN(VAL(INTEGER,start));
   ELSIF tries = 0 THEN
     RETURN(NOTFOUND);
   END;

   INC(start);
   DEC(tries);
 END;
END LPOS;

(*---------------------------------------------------------------------------*)

PROCEDURE RPOS ((* EIN/ -- *)     from : CARDINAL;
                (* EIN/ -- *) REF pat  : ARRAY OF CHAR;
                (* EIN/ -- *) REF s    : ARRAY OF CHAR ): INTEGER;
(*T*)
VAR         sLen  : CARDINAL;
    __REG__ pLen  : CARDINAL;
    __REG__ pIdx  : UNSIGNEDWORD;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 sLen  := SLEN(s);
 pLen  := SLEN(pat);

 IF (pLen = 0) OR (pLen > sLen) THEN
   RETURN(NOTFOUND);
 END;

 IF from > sLen - pLen THEN
   from := sLen - pLen;
 END;
 start := VAL(UNSIGNEDWORD,from);

 LOOP
   pIdx := 0;
   WHILE (pIdx < VAL(UNSIGNEDWORD,pLen)) AND (s[start] = pat[pIdx]) DO
     INC(start);
     INC(pIdx);
   END;
   DEC(start, pIdx);

   IF pIdx = VAL(UNSIGNEDWORD,pLen) THEN
     RETURN(VAL(INTEGER,start));
   ELSIF start = 0 THEN
     RETURN(NOTFOUND);
   END;

   DEC(start);
 END;
END RPOS;

(*---------------------------------------------------------------------------*)

PROCEDURE LPOSCHR ((* EIN/ -- *)     from : CARDINAL;
                   (* EIN/ -- *)     c    : CHAR;
                   (* EIN/ -- *) REF s    : ARRAY OF CHAR ): INTEGER;
(*T*)
VAR __REG__ len   : UNSIGNEDWORD;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 len   := VAL(UNSIGNEDWORD,SLEN(s));
 start := VAL(UNSIGNEDWORD,from);

 WHILE (start < len) AND (s[start] <> c) DO
   INC(start);
 END;

 IF start >= len THEN
   RETURN(NOTFOUND);
 ELSE
   RETURN(VAL(INTEGER,start));
 END;
END LPOSCHR;

(*---------------------------------------------------------------------------*)

PROCEDURE RPOSCHR ((* EIN/ -- *)     from : CARDINAL;
                   (* EIN/ -- *)     c    : CHAR;
                   (* EIN/ -- *) REF s    : ARRAY OF CHAR ): INTEGER;
(*T*)
VAR         len   : CARDINAL;
    __REG__ start : UNSIGNEDWORD;

BEGIN
 len := SLEN(s);

 IF len = 0 THEN
   RETURN(NOTFOUND);
 ELSIF from >= len THEN
   from := len - 1;
 END;
 start := VAL(UNSIGNEDWORD,from);

 WHILE (start > 0) AND (s[start] <> c) DO
   DEC(start);
 END;

 IF s[start] = c THEN
   RETURN(VAL(INTEGER,start));
 ELSE
   RETURN(NOTFOUND);
 END;
END RPOSCHR;

(*---------------------------------------------------------------------------*)

PROCEDURE LPOSCHRSET ((* EIN/ -- *)     from : CARDINAL;
                      (* EIN/ -- *) REF set  : ARRAY OF CHAR;
                      (* EIN/ -- *) REF str  : ARRAY OF CHAR ): INTEGER;
(*T*)
VAR         strLen : CARDINAL;
    __REG__ setIdx : UNSIGNEDWORD;
    __REG__ setLen : UNSIGNEDWORD;
    __REG__ c      : CHAR;

BEGIN
 strLen := SLEN(str);
 setLen := VAL(UNSIGNEDWORD,SLEN(set));
 IF (from >= strLen) OR (setLen = 0) THEN
   RETURN(NOTFOUND);
 END;

 LOOP
   c      := str[VAL(UNSIGNEDWORD,from)];
   setIdx := 0;
   WHILE (setIdx < setLen) AND (c <> set[setIdx]) DO
     INC(setIdx);
   END;

   IF setIdx < setLen THEN
     RETURN(CAST(INTEGER,from));
   ELSIF from >= strLen THEN
     RETURN(NOTFOUND);
   ELSE
     INC(from);
   END;
 END;
END LPOSCHRSET;

(*---------------------------------------------------------------------------*)

PROCEDURE RPOSCHRSET ((* EIN/ -- *)     from : CARDINAL;
                      (* EIN/ -- *) REF set  : ARRAY OF CHAR;
                      (* EIN/ -- *) REF str  : ARRAY OF CHAR ): INTEGER;
(*T*)
VAR         strLen : CARDINAL;
    __REG__ setIdx : UNSIGNEDWORD;
    __REG__ setLen : UNSIGNEDWORD;
    __REG__ c      : CHAR;

BEGIN
 strLen := SLEN(str);
 setLen := VAL(UNSIGNEDWORD,SLEN(set));

 IF (setLen = 0) OR (strLen = 0) THEN
   RETURN(NOTFOUND);
 ELSIF from >= strLen THEN
   from := strLen - 1;
 END;

 LOOP
   c      := str[VAL(UNSIGNEDWORD,from)];
   setIdx := 0;
   WHILE (setIdx < setLen) AND (c <> set[setIdx]) DO
     INC(setIdx);
   END;

   IF setIdx < setLen THEN
     RETURN(CAST(INTEGER,from));
   ELSIF from = 0 THEN
     RETURN(NOTFOUND);
   ELSE
     DEC(from);
   END;
 END;
END RPOSCHRSET;

END pSTRING.

