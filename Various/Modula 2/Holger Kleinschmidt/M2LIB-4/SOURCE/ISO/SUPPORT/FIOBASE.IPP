IMPLEMENTATION MODULE FIOBase;
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
(* 04-Dez-95, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) UNSIGNED, SIGNEDWORD, UNSIGNEDWORD;

IMPORT EXCEPTIONS;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

FROM IOChan IMPORT
(* TYPE *) ChanId, ChanExceptions;

FROM IOLink IMPORT
(* TYPE *) DeviceTablePtr, DeviceTable;

FROM FConvBase IMPORT
(* CONST*) MAXEXPFIGS, DEFSIGFIGS,
(* TYPE *) ExpStr, SigFigStr, FormStr, RealFormat,
(* PROC *) strToReal, split, mantToStr, floatLen, fixLen, adjustEng, expToStr,
           formToStr, formLen;

IMPORT blk;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  FILLSIZE = 128;

TYPE
  FillStr = ARRAY [0..FILLSIZE-1] OF CHAR;

VAR
  spaces : FillStr;
  nulls  : FillStr;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

PROCEDURE raiseNotChannel;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(notAChannel),
                  "Float-Output: Not a channel");
END raiseNotChannel;

(*---------------------------------------------------------------------------*)

PROCEDURE fill ((* EIN/ -- *)     tid     : DeviceTablePtr;
                (* EIN/ -- *) VAR fillStr : FillStr;
                (* EIN/ -- *)     size    : UNSIGNEDWORD );
(* size > 0 ! *)
VAR __REG__ len : UNSIGNEDWORD;

BEGIN
 REPEAT
   IF size > FILLSIZE THEN
     len := FILLSIZE;
   ELSE
     len := size;
   END;
   tid^.doTextWrite(tid, ADR(fillStr), VAL(UNSIGNED,len));
   DEC(size, len);
 UNTIL size = 0;
END fill;

(*---------------------------------------------------------------------------*)

PROCEDURE writeForm ((* EIN/ -- *) cid   : ChanId;
                     (* EIN/ -- *) form  : RealFormat;
                     (* EIN/ -- *) width : UNSIGNEDWORD );

VAR         s   : FormStr;
#ifdef MM2
            tid : DeviceTablePtr;
#else
    __REG__ tid : DeviceTablePtr;
#endif
    __REG__ len : UNSIGNEDWORD;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;

 formToStr(form, s);
 IF width = 0 THEN
   tid^.doTextWrite(tid, ADR(spaces), 1);
 ELSE
   len := formLen(form);
   IF len < width THEN
     fill(tid, spaces, width - len);
   END;
 END;
 tid^.doTextWrite(tid, ADR(s), VAL(UNSIGNED,len));
END writeForm;

(*---------------------------------------------------------------------------*)

PROCEDURE writeFloat ((* EIN/ -- *) cid     : ChanId;
                      (* EIN/ -- *) neg     : BOOLEAN;
                      (* EIN/ -- *) real    : LONGREAL;
                      (* EIN/ -- *) exp     : SIGNEDWORD;
                      (* EIN/ -- *) eng     : BOOLEAN;
                      (* EIN/ -- *) sigFigs : UNSIGNEDWORD;
                      (* EIN/ -- *) long    : BOOLEAN;
                      (* EIN/ -- *) width   : UNSIGNEDWORD );

VAR         estr : ExpStr;
#ifdef MM2
            tid  : DeviceTablePtr;
#else
    __REG__ tid  : DeviceTablePtr;
#endif
            pre  : UNSIGNEDWORD;
            len  : UNSIGNEDWORD;
            c    : CHAR;
            mant : SigFigStr;
            digs : UNSIGNEDWORD;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;

 tid^.errNum := 0;
 IF sigFigs = 0 THEN
   sigFigs := DEFSIGFIGS;
 END;
 mantToStr(real, FALSE, CAST(SIGNEDWORD,sigFigs), long, exp, digs, mant);

 (* Optionale fuehrende Leerzeichen schreiben *)
 IF width = 0 THEN
   tid^.doTextWrite(tid, ADR(spaces), 1);
 ELSE
   len := floatLen(neg, eng, exp, sigFigs);
   IF len < width THEN
     fill(tid, spaces, width - len);
   END;
 END;

 (* Optionales negatives Vorzeichen schreiben *)
 IF neg THEN
   c := '-';
   tid^.doTextWrite(tid, ADR(c), 1);
 END;

 (* Vorkommastellen schreiben *)
 IF eng THEN
   adjustEng(exp, pre);
 ELSE
   pre := 1;
 END;
 tid^.doTextWrite(tid, ADR(mant), VAL(UNSIGNED,pre));

 (* Optionalen Dezimalpunkt mit Nachkommastellen schreiben *)
 IF sigFigs > pre THEN
   c := '.';
   tid^.doTextWrite(tid, ADR(c), 1);
   tid^.doTextWrite(tid, ADR(mant[pre]), VAL(UNSIGNED,digs - pre));

   IF digs < sigFigs THEN
     (* Jetzt noch Nachkommastellen, die ueber die Genauigkeit hinausgehen *)
     fill(tid, nulls, sigFigs - digs);
   END;
 END;

 (* Optionalen Exponenten schreiben *)
 IF exp # 0 THEN
   expToStr(exp, estr, pre);
   tid^.doTextWrite(tid, ADR(estr[pre]), VAL(UNSIGNED,MAXEXPFIGS - pre + 1));
 END;
END writeFloat;

(*---------------------------------------------------------------------------*)

PROCEDURE writeFix ((* EIN/ -- *) cid    : ChanId;
                    (* EIN/ -- *) neg    : BOOLEAN;
                    (* EIN/ -- *) real   : LONGREAL;
                    (* EIN/ -- *) exp    : SIGNEDWORD;
                    (* EIN/ -- *) places : SIGNEDWORD;
                    (* EIN/ -- *) long   : BOOLEAN;
                    (* EIN/ -- *) width  : UNSIGNEDWORD );

VAR         len  : UNSIGNEDWORD;
#ifdef MM2
            tid  : DeviceTablePtr;
#else
    __REG__ tid  : DeviceTablePtr;
#endif
            c    : CHAR;
            mant : SigFigStr;
            digs : UNSIGNEDWORD;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;

 tid^.errNum := 0;

 mantToStr(real, TRUE, places, long, exp, digs, mant);

   (* Optionale fuehrende Leerzeichen schreiben *)
 IF width = 0 THEN
   tid^.doTextWrite(tid, ADR(spaces), 1);
 ELSE
   len := fixLen(neg, exp, places);
   IF len < width THEN
     fill(tid, spaces, width - len);
   END;
 END;

 (* Optionales negatives Vorzeichen schreiben *)
 IF neg THEN
   c := '-';
   tid^.doTextWrite(tid, ADR(c), 1);
 END;

 IF exp < 0 THEN
(* [-]0.[000]xxxxx[000] *)
   tid^.doTextWrite(tid, ADR(nulls), 1);
   IF places >= 0 THEN
     c := '.';
     tid^.doTextWrite(tid, ADR(c), 1);
     exp := -exp - 1;
     IF exp > 0 THEN
       fill(tid, nulls, CAST(UNSIGNEDWORD,exp));
     END;
     tid^.doTextWrite(tid, ADR(mant), VAL(UNSIGNED,digs));
     IF digs + CAST(UNSIGNEDWORD,exp) < CAST(UNSIGNEDWORD,places) THEN
       fill(tid, nulls, VAL(UNSIGNEDWORD,places - exp - CAST(SIGNEDWORD,digs)));
     END;
   END;
 ELSE (* exp >= 0 *)
   IF places < 0 THEN
(* [-]xxx[000] *)
     tid^.doTextWrite(tid, ADR(mant), VAL(UNSIGNED,digs));
     IF digs <= CAST(UNSIGNEDWORD,exp) THEN
       fill(tid, nulls, (CAST(UNSIGNEDWORD,exp) - digs) + 1);
     END;
   ELSE (* places >= 0, exp >= 0 *)
(* [-]xxx[000[.[000]]] *)
     IF CAST(UNSIGNEDWORD,exp) + 1 >= digs THEN
       tid^.doTextWrite(tid, ADR(mant), VAL(UNSIGNED,digs));
       IF digs <= CAST(UNSIGNEDWORD,exp) THEN
         fill(tid, nulls, (CAST(UNSIGNEDWORD,exp) - digs) + 1);
       END;
       c := '.';
       tid^.doTextWrite(tid, ADR(c), 1);
       IF places > 0 THEN
         fill(tid, nulls, places);
       END;
     ELSE (* places >= 0, exp >= 0, exp < digs - 1 *)
(* [-]xxx.[xxx][000] *)
       INC(exp);
       tid^.doTextWrite(tid, ADR(mant), VAL(UNSIGNED,exp));
       c := '.';
       tid^.doTextWrite(tid, ADR(c), 1);
       DEC(digs, CAST(UNSIGNEDWORD,exp));
       tid^.doTextWrite(tid, ADR(mant[exp]), VAL(UNSIGNED,digs));
       IF digs < CAST(UNSIGNEDWORD,places) THEN
         fill(tid, nulls, CAST(UNSIGNEDWORD,places) - digs);
       END;
     END;
   END;
 END;
END writeFix;

(*===========================================================================*)

BEGIN (* FIOBase *)
 blk.memset(ADR(spaces), ORD(' '), FILLSIZE);
 blk.memset(ADR(nulls), ORD('0'), FILLSIZE);
END FIOBase.
