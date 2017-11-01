IMPLEMENTATION MODULE RealIO;
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
(* 27-Okt-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD;

IMPORT types;

IMPORT EXCEPTIONS;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM IOChan IMPORT
(* TYPE *) ChanId, ChanExceptions;

FROM IOLink IMPORT
(* TYPE *) DeviceTable, DeviceTablePtr;

FROM IOConsts IMPORT
(* TYPE *) ReadResults;

FROM FConvBase IMPORT
#if (defined HM2) && (defined __LONG_REAL__)
(* CONST*) MAXREAD, DEFSIGFIGS, MaxLExp, MinLExp,
(* TYPE *) ExpStr, SigFigStr, ReadStr, RealFormat,
(* PROC *) strToReal, split, mantToStr, expLen, checkLReal;
#else
(* CONST*) MAXREAD, DEFSIGFIGS, MaxExp, MinExp,
(* TYPE *) ExpStr, SigFigStr, ReadStr, RealFormat,
(* PROC *) strToReal, split, mantToStr, expLen, checkReal;
#endif

FROM ConvTypes IMPORT
(* TYPE *) ScanState, ScanClass;

FROM LongConv IMPORT
(* TYPE *) ConvResults,
(* PROC *) ScanReal;

FROM FIOBase IMPORT
(* PROC *) writeFloat, writeFix, writeForm;

#if (defined HM2) && (defined __LONG_REAL__)
IMPORT LowLong;
#else
IMPORT LowReal;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

#if LONGREAL_var
VAR
  nine : LONGREAL; (* 9.0 *)

TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : REAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

VAR
  cast : lrc;
#else
CONST
  nine  = LRC(9.0,0);
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReadReal ((* EIN/ -- *)     cid  : ChanId;
                    (* -- /AUS *) VAR real : REAL   );

VAR __REG__ idx   : UNSIGNEDWORD;
#ifdef MM2
            tid   : DeviceTablePtr;
#else
    __REG__ tid   : DeviceTablePtr;
#endif
            ch    : CHAR;
            res   : ReadResults;
            cres  : ConvResults;
            s     : ReadStr;
            state : ScanState;
            class : ScanClass;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   EXCEPTIONS.RAISE(iolibSource, ORD(notAChannel),
                    "[S]RealIO.ReadReal: Not a channel");
 END;

 tid^.errNum := 0;

 idx  := 0;
 real := 0.0;
 tid^.doLook(tid, ch, res);
 WHILE ch = ' ' DO
 (* Falls 'ch' bei 'res' # 'allRight' undefiniert:
 WHILE (res = allRight) & (ch = ' ') DO
 *)
   tid^.doSkipLook(tid, ch, res);
 END;
 IF res = allRight THEN
   state := ScanReal;
   LOOP
     state(ch, class, state);
     CASE class OF
       padding: (* nichts, duerfte nicht auftreten *)
      |  valid: IF idx <= MAXREAD THEN
                  s[idx] := ch;
                  INC(idx);
                END;
     ELSE (* invalid, terminator *) EXIT;
     END;
     tid^.doSkipLook(tid, ch, res);
     IF res # allRight THEN
       ch := types.EOS; (* -> class = invalid|terminator *)
     END;
   END;
   IF (idx > MAXREAD) OR (class = invalid) THEN
     (* Auch, wenn die gelesene Zahl gerade genau so gross wie
      * 'ReadString' ist; macht aber nix.
      *)
     res := wrongFormat;
   ELSE (* class = terminator *)
     IF idx <= MAXREAD THEN
       s[idx] := types.EOS;
     END;
#if (defined HM2) && (defined __LONG_REAL__)
     real := strToReal(s, LowLong.small, MinLExp, LowLong.large, MaxLExp, cres);
#elif (defined TDIM2)
     real := SHORT(strToReal(s, LONG(LowReal.small), MinExp, LONG(LowReal.large), MaxExp, cres));
#else
     real := strToReal(s, LowReal.small, MinExp, LowReal.large, MaxExp, cres);
#endif
     res  := VAL(ReadResults,ORD(cres) + 1);
   END;
   tid^.result := res;
 END;
END ReadReal;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFloat ((* EIN/ -- *) cid     : ChanId;
                      (* EIN/ -- *) real    : REAL;
                      (* EIN/ -- *) sigFigs : CARDINAL;
                      (* EIN/ -- *) width   : CARDINAL );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    long : LONGREAL;
    form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) &
#else
 IF checkReal(real, form) &
#endif
#ifdef TDIM2
    split(LONG(real), neg, long, exp, form)
#else
    split(real, neg, long, exp, form)
#endif
 THEN
#if (defined HM2) && (defined __LONG_REAL__)
   writeFloat(cid, neg, long, exp, FALSE, VAL(SIGNEDWORD,sigFigs), TRUE, VAL(UNSIGNEDWORD,width));
#else
   writeFloat(cid, neg, long, exp, FALSE, VAL(SIGNEDWORD,sigFigs), FALSE, VAL(UNSIGNEDWORD,width));
#endif
 ELSE
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
 END;
END WriteFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteEng ((* EIN/ -- *) cid     : ChanId;
                    (* EIN/ -- *) real    : REAL;
                    (* EIN/ -- *) sigFigs : CARDINAL;
                    (* EIN/ -- *) width   : CARDINAL );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    long : LONGREAL;
    form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) &
#else
 IF checkReal(real, form) &
#endif
#ifdef TDIM2
    split(LONG(real), neg, long, exp, form)
#else
    split(real, neg, long, exp, form)
#endif
 THEN
#if (defined HM2) && (defined __LONG_REAL__)
   writeFloat(cid, neg, long, exp, TRUE, VAL(SIGNEDWORD,sigFigs), TRUE, VAL(UNSIGNEDWORD,width));
#else
   writeFloat(cid, neg, long, exp, TRUE, VAL(SIGNEDWORD,sigFigs), FALSE, VAL(UNSIGNEDWORD,width));
#endif
 ELSE
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
 END;
END WriteEng;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFixed ((* EIN/ -- *) cid    : ChanId;
                      (* EIN/ -- *) real   : REAL;
                      (* EIN/ -- *) places : INTEGER;
                      (* EIN/ -- *) width  : CARDINAL );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    long : LONGREAL;
    form : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF checkLReal(real, form) &
#else
 IF checkReal(real, form) &
#endif
#ifdef TDIM2
    split(LONG(real), neg, long, exp, form)
#else
    split(real, neg, long, exp, form)
#endif
 THEN
#if (defined HM2) && (defined __LONG_REAL__)
   writeFix(cid, neg, long, exp, VAL(SIGNEDWORD,places), TRUE, VAL(UNSIGNEDWORD,width));
#else
   writeFix(cid, neg, long, exp, VAL(SIGNEDWORD,places), FALSE, VAL(UNSIGNEDWORD,width));
#endif
 ELSE
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
 END;
END WriteFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteReal ((* EIN/ -- *) cid   : ChanId;
                     (* EIN/ -- *) real  : REAL;
                     (* EIN/ -- *) width : CARDINAL );

VAR         neg    : BOOLEAN;
            exp    : SIGNEDWORD;
            whole  : SIGNEDWORD;
            mant   : SigFigStr;
            digs   : UNSIGNEDWORD;
    __REG__ needs  : SIGNEDWORD;
            long   : LONGREAL;
            form   : RealFormat;

BEGIN
#if (defined HM2) && (defined __LONG_REAL__)
 IF ~checkLReal(real, form) OR
#else
 IF ~checkReal(real, form) OR
#endif
#ifdef TDIM2
    ~split(LONG(real), neg, long, exp, form)
#else
    ~split(real, neg, long, exp, form)
#endif
 THEN
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
   RETURN;
 END;
 IF width > 0 THEN
   IF exp >= 0 THEN
     whole := exp;
     IF long >= nine THEN
       (* Repraesentation kann durch Rundung ein Zeichen laenger werden,
        * bzw. die Exponentenlaenge kann sich aendern, wenn der Exponent
        * durch die Rundung von bzw. auf Null geaendert wird.
        *)
#if (defined HM2) && (defined __LONG_REAL__)
       mantToStr(long, TRUE, -1, TRUE, whole, digs, mant);
#else
       mantToStr(long, TRUE, -1, FALSE, whole, digs, mant);
#endif
     END;
     (* Anzahl der Vorkommastellen ist um Eins hoeher als der Exponent *)
     INC(whole);
   ELSE
     (* Genau eine Vorkommastelle, auch bei Rundung: 0.xx bzw. 1.xx *)
     whole := 1;
   END;
   (* Die Repraesentation braucht mindestens soviel Zeichen wie
    * Vorkommastellen.
    *)
   needs := whole;
   IF neg THEN
     (* Ein Zeichen mehr fuer Minuszeichen *)
     INC(needs);
   END;
 END;
 IF (needs <= VAL(SIGNEDWORD,width)) & (width > 0) THEN
   (* Da die Feldbreite groesser als die benoetigte Mindestgroesse ist,
    * kann die Fixpunktdarstellung verwendet werden. Es wird auf die
    * angegebene Feldbreite mit dem Dezimalpunkt und Nachkommastellen
    * aufgefuellt.
    *)
#if (defined HM2) && (defined __LONG_REAL__)
   writeFix(cid, neg, long, exp, VAL(SIGNEDWORD,width) - needs - 1, TRUE, VAL(UNSIGNEDWORD,width));
#else
   writeFix(cid, neg, long, exp, VAL(SIGNEDWORD,width) - needs - 1, FALSE, VAL(UNSIGNEDWORD,width));
#endif
 ELSE
   (* Da die Feldbreite kleiner als die Zahl an Vorkommastellen ist, muss
    * die Gleitpunktdarstellung verwendet werden.
    *)
   IF width > 0 THEN
     (* Es werden mindestens die Vorkommastelle und der Exponent benoetigt *)
     needs := 1 + CAST(SIGNEDWORD,expLen(exp));
     IF neg THEN
       (* Platz fuer Minuszeichen *)
       INC(needs);
     END;
     IF VAL(SIGNEDWORD,width) <= needs + 1 THEN
       (* Mindestens die Vorkommastelle schreiben. Auch wenn noch Platz fuer
        * den Dezimalpunkt waere, wird nur die Vorkommastelle geschrieben.
        *)
       needs := 1;
     ELSE
       (* Noch soviele Nachkommastellen, dass der Platz einschliesslich
        * Vorkommastelle und Dezimalpunkt aufgefuellt wird.
        *)
       needs := VAL(SIGNEDWORD,width) - needs;
     END;
   ELSE
     needs := DEFSIGFIGS;
   END;
#if (defined HM2) && (defined __LONG_REAL__)
   writeFloat(cid, neg, long, exp, FALSE, CAST(UNSIGNEDWORD,needs), TRUE, VAL(UNSIGNEDWORD,width));
#else
   writeFloat(cid, neg, long, exp, FALSE, CAST(UNSIGNEDWORD,needs), FALSE, VAL(UNSIGNEDWORD,width));
#endif
 END;
END WriteReal;

#if LONGREAL_var
(*===========================================================================*)

BEGIN (* RealIO *)
 WITH cast DO
   lc1 := 040220000H; lc2 := 0H; nine := lr;
 END;
#endif
END RealIO.
