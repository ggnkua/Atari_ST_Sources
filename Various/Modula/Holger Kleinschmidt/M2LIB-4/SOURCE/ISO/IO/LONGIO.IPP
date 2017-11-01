IMPLEMENTATION MODULE LongIO;
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
(* CONST*) MAXREAD, MaxLExp, MinLExp, DEFSIGFIGS,
(* TYPE *) ExpStr, SigFigStr, ReadStr, RealFormat,
(* PROC *) strToReal, split, mantToStr, expLen;

FROM ConvTypes IMPORT
(* TYPE *) ScanState, ScanClass;

FROM LongConv IMPORT
(* TYPE *) ConvResults,
(* PROC *) ScanReal;

FROM FIOBase IMPORT
(* PROC *) writeFloat, writeFix, writeForm;

IMPORT LowLong;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

#if LONGREAL_var
VAR
  null : LONGREAL; (* 0.0 *)
  nine : LONGREAL; (* 9.0 *)

TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : LONGREAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

VAR
  cast : lrc;
#else
CONST
  null  = LRC(0.0,0);
  nine  = LRC(9.0,0);
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE ReadReal ((* EIN/ -- *)     cid  : ChanId;
                    (* -- /AUS *) VAR real : LONGREAL );

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
                    "[S]LongIO.ReadReal: Not a channel");
 END;

 tid^.errNum := 0;

 idx  := 0;
 real := null;
 tid^.doLook(tid, ch, res);
 WHILE ch = ' ' DO
 (* Falls 'ch' bei 'res' # 'allRight' undefiniert:
 WHILE (res = allRight) & (ch = ' ') DO
 *)
   (* fuehrende Leerzeichen ueberlesen *)
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
     real := strToReal(s, LowLong.small, MinLExp, LowLong.large, MaxLExp, cres);
     res  := VAL(ReadResults,ORD(cres) + 1);
   END;
   tid^.result := res;
 END; (* IF res *)
END ReadReal;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFloat ((* EIN/ -- *) cid     : ChanId;
                      (* EIN/ -- *) real    : LONGREAL;
                      (* EIN/ -- *) sigFigs : CARDINAL;
                      (* EIN/ -- *) width   : CARDINAL );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    form : RealFormat;

BEGIN
 IF split(real, neg, real, exp, form) THEN
   writeFloat(cid, neg, real, exp, FALSE, VAL(SIGNEDWORD,sigFigs), TRUE, VAL(UNSIGNEDWORD,width));
 ELSE
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
 END;
END WriteFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteEng ((* EIN/ -- *) cid     : ChanId;
                    (* EIN/ -- *) real    : LONGREAL;
                    (* EIN/ -- *) sigFigs : CARDINAL;
                    (* EIN/ -- *) width   : CARDINAL );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    form : RealFormat;

BEGIN
 IF split(real, neg, real, exp, form) THEN
   writeFloat(cid, neg, real, exp, TRUE, VAL(SIGNEDWORD,sigFigs), TRUE, VAL(UNSIGNEDWORD,width));
 ELSE
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
 END;
END WriteEng;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteFixed ((* EIN/ -- *) cid    : ChanId;
                      (* EIN/ -- *) real   : LONGREAL;
                      (* EIN/ -- *) places : INTEGER;
                      (* EIN/ -- *) width  : CARDINAL );

VAR neg  : BOOLEAN;
    exp  : SIGNEDWORD;
    form : RealFormat;

BEGIN
 IF split(real, neg, real, exp, form) THEN
   writeFix(cid, neg, real, exp, VAL(SIGNEDWORD,places), TRUE, VAL(UNSIGNEDWORD,width));
 ELSE
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
 END;
END WriteFixed;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteReal ((* EIN/ -- *) cid   : ChanId;
                     (* EIN/ -- *) real  : LONGREAL;
                     (* EIN/ -- *) width : CARDINAL );

VAR         neg    : BOOLEAN;
            exp    : SIGNEDWORD;
            whole  : SIGNEDWORD;
            mant   : SigFigStr;
            digs   : UNSIGNEDWORD;
    __REG__ needs  : SIGNEDWORD; (* Mindestlaenge der Repraesentation *)
            form   : RealFormat;

BEGIN
 IF ~split(real, neg, real, exp, form) THEN
   writeForm(cid, form, VAL(UNSIGNEDWORD,width));
   RETURN;
 END;
 IF width > 0 THEN
   IF exp >= 0 THEN
     whole := exp;
     IF real >= nine THEN
       (* Repraesentation kann durch Rundung ein Zeichen laenger werden,
        * bzw. die Exponentenlaenge kann sich aendern, wenn der Exponent
        * durch die Rundung von Null auf Eins geaendert wird.
        *)
       mantToStr(real, TRUE, -1, TRUE, whole, digs, mant);
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
   writeFix(cid, neg, real, exp, VAL(SIGNEDWORD,width) - needs - 1, TRUE, VAL(UNSIGNEDWORD,width));
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
   writeFloat(cid, neg, real, exp, FALSE, CAST(UNSIGNEDWORD,needs), TRUE, VAL(UNSIGNEDWORD,width));
 END;
END WriteReal;

#if LONGREAL_var
(*===========================================================================*)

BEGIN (* LongIO *)
 WITH cast DO
   lc1 := 000000000H; lc2 := 0H; null := lr;
   lc1 := 040220000H; lc2 := 0H; nine := lr;
 END;
#endif
END LongIO.
