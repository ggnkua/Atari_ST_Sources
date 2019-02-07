IMPLEMENTATION MODULE WholeIO;
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


(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'SIGNED' und 'UNSIGNED' koennen mittels CAST uminterpretiert
            werden, d.h. sie haben die gleiche Speichergroesse, oder CAST
            kann auch bei unterschiedlichen Groessen verwendet werden, und
            UNSIGNED ist groesser als SIGNED.
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)



VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNED, SIGNED, UNSIGNEDWORD;

IMPORT types;

IMPORT EXCEPTIONS;

FROM IOConsts IMPORT
(* TYPE *) ReadResults;

FROM WConvBase IMPORT
(* CONST*) MAXREAD,
(* TYPE *) WholeString, ReadString,
(* PROC *) valToStr, strToCard, strToInt;

FROM ConvTypes IMPORT
(* TYPE *) ScanState, ScanClass;

FROM WholeConv IMPORT
(* TYPE *) ConvResults,
(* PROC *) ScanCard, ScanInt;

FROM IOChan IMPORT
(* TYPE *) ChanId, ChanExceptions;

FROM IOLink IMPORT
(* TYPE *) DeviceTable, DeviceTablePtr;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

IMPORT blk;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

CONST
  FILLSIZE = 128;

VAR
  spaces : ARRAY [0..FILLSIZE-1] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE raiseNotChannel;
BEGIN
 EXCEPTIONS.RAISE(iolibSource, ORD(notAChannel), "[S]WholeIO: Not a channel");
END raiseNotChannel;

(*---------------------------------------------------------------------------*)

PROCEDURE writeWhole ((* EIN/ -- *)     cid   : ChanId;
                      (* EIN/ -- *)     size  : UNSIGNEDWORD;
                      (* EIN/ -- *)     width : UNSIGNEDWORD;
                      (* EIN/ -- *) VAR s     : WholeString );

VAR __REG__ len : UNSIGNEDWORD;
#ifdef MM2
            tid : DeviceTablePtr;
#else
    __REG__ tid : DeviceTablePtr;
#endif

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;
 tid^.errNum := 0;

 (* Optionale fuehrende Leerzeichen schreiben *)
 IF width = 0 THEN
   tid^.doTextWrite(tid, ADR(spaces), 1);
 ELSIF width > size THEN
   DEC(width, size);
   REPEAT
     IF width > FILLSIZE THEN
       len := FILLSIZE;
     ELSE
       len := width;
     END;
     tid^.doTextWrite(tid, ADR(spaces), VAL(UNSIGNED,len));
     DEC(width, len);
   UNTIL width = 0;
 END;
 tid^.doTextWrite(tid, ADR(s), VAL(UNSIGNED,size));
END writeWhole;

(*---------------------------------------------------------------------------*)

PROCEDURE readWhole ((* EIN/ -- *)     cid    : ChanId;
                     (* EIN/ -- *)     signed : BOOLEAN;
                     (* -- /AUS *) VAR int    : SIGNED;
                     (* -- /AUS *) VAR card   : UNSIGNED );

VAR         ch    : CHAR;
#ifdef MM2
            tid   : DeviceTablePtr;
#else
    __REG__ tid   : DeviceTablePtr;
#endif
    __REG__ idx   : UNSIGNEDWORD;
            res   : ReadResults;
            cres  : ConvResults;
            s     : ReadString;
            state : ScanState;
            class : ScanClass;

BEGIN
 tid := CAST(DeviceTablePtr,cid);
 IF tid = NIL THEN
   raiseNotChannel;
 END;

 tid^.errNum := 0;

 idx  := 0;
 int  := 0;
 card := 0;
 tid^.doLook(tid, ch, res);
 WHILE ch = ' ' DO
 (* Falls 'ch' bei 'res' # 'allRight' undefiniert:
 WHILE (res = allRight) & (ch = ' ') DO
 *)
   (* fuehrende Leerzeichen ueberlesen *)
   tid^.doSkipLook(tid, ch, res);
 END;
 IF res = allRight THEN
   IF signed THEN
     state := ScanInt;
   ELSE
     state := ScanCard;
   END;
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
     IF signed THEN
       strToInt(s, int, cres);
     ELSE
       strToCard(s, card, cres);
     END;
     res := VAL(ReadResults,ORD(cres) + 1);
   END;
   tid^.result := res;
 END;
END readWhole;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadInt ((* EIN/ -- *)     cid : ChanId;
                   (* -- /AUS *) VAR int : SIGNED );

VAR card : UNSIGNED;

BEGIN
 readWhole(cid, TRUE, int, card);
END ReadInt;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteInt ((* EIN/ -- *) cid   : ChanId;
                    (* EIN/ -- *) int   : SIGNED;
                    (* EIN/ -- *) width : CARDINAL );

VAR size : UNSIGNEDWORD;
    s    : WholeString;

BEGIN
 valToStr(CAST(UNSIGNED,int), TRUE, size, s);
 writeWhole(cid, size, VAL(UNSIGNEDWORD,width), s);
END WriteInt;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadCard ((* EIN/ -- *)     cid  : ChanId;
                    (* -- /AUS *) VAR card : UNSIGNED );

VAR int : SIGNED;

BEGIN
 readWhole(cid, FALSE, int, card);
END ReadCard;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteCard ((* EIN/ -- *) cid   : ChanId;
                     (* EIN/ -- *) card  : UNSIGNED;
                     (* EIN/ -- *) width : CARDINAL );

VAR size : UNSIGNEDWORD;
    s    : WholeString;

BEGIN
 valToStr(card, FALSE, size, s);
 writeWhole(cid, size, VAL(UNSIGNEDWORD,width), s);
END WriteCard;

(*===========================================================================*)

BEGIN (* WholeIO *)
 blk.memset(ADR(spaces), ORD(' '), FILLSIZE);
END WholeIO.
