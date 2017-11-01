IMPLEMENTATION MODULE ProgramArgs;
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
(* 10-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNED;

FROM er IMPORT
(* CONST*) EIO;

IMPORT types, blk, str, ISOStrings, args;

FROM IOshare IMPORT
(* VAR  *) iolibSource;

IMPORT EXCEPTIONS;

IMPORT IOConsts, ChanConsts;

FROM IOChan IMPORT
(* TYPE *) ChanExceptions, DeviceErrNum;

FROM IOLink IMPORT
(* TYPE *) DeviceId, DeviceTable, DeviceTablePtr,
(* PROC *) AllocateDeviceId;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   ANNAHME: 'ChanId' wird in der gesamten IO-Bibliothek als Synonym
            fuer 'DeviceTablePtr' behandelt !
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ *)

#if 0
TYPE
  ChanId = DeviceTablePtr;
#endif

VAR
  argDevice : DeviceId;
  argChan   : DeviceTable;
  argChanId : ChanId;

  ARGC   : types.ArrayRange; (* Anzahl der Argumente *)
  ARGV   : types.StrArray;   (* Zeiger auf Argumente *)
  ARG    : types.ArrayRange; (* Nr. des aktuellen Arguments *)
  ARGPTR : types.StrPtr;     (* Zeiger auf aktuelles Argument *)
  ARGLEN : types.StrRange;   (* Laenge des aktuellen Arguments *)
  ARGIDX : types.StrRange;   (* Leseposition im aktuellen Argument *)

(*===========================================================================*)
(* Geraeteoperationen                                                        *)
(*===========================================================================*)

PROCEDURE raiseEOF;
BEGIN
 argChan.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                  "ProgramArgs: No more arguments");
END raiseEOF;

(*---------------------------------------------------------------------------*)

PROCEDURE raiseWrite;
BEGIN
 argChan.errNum := EIO;
 EXCEPTIONS.RAISE(iolibSource, ORD(notAvailable),
                  "ProgramArgs: 'Write' not available");
END raiseWrite;

(*---------------------------------------------------------------------------*)

#ifdef HM2
(*$E+*)
#endif
PROCEDURE argLook ((* -- / -- *)     arg : DeviceTablePtr;
                   (* -- /AUS *) VAR c   : CHAR;
                   (* -- /AUS *) VAR res : IOConsts.ReadResults );

VAR __REG__ ch : CHAR;

BEGIN
 IF ~(ChanConsts.readFlag IN argChan.flags) THEN
   raiseEOF;
 ELSIF ARGIDX >= ARGLEN THEN
   ch             := 0C;
   res            := IOConsts.endOfInput;
   argChan.result := IOConsts.endOfInput;
 ELSE
   ch := ARGPTR^[ARGIDX];
   (* Da ein Kommandozeilenargument immer mit einem Nullbyte
    * abgeschlossen ist, braucht vor dem Zugriff auf ARGPTR^[ARGIDX+1]
    * kein Indextest zu erfolgen.
    *)
   IF (ch = types.LF) OR (ch = types.CR) & (ARGPTR^[ARGIDX+1] = types.LF) THEN
     res            := IOConsts.endOfLine;
     argChan.result := IOConsts.endOfLine;
   ELSE
     res            := IOConsts.allRight;
     argChan.result := IOConsts.allRight;
   END;
 END;
 c := ch;
END argLook;

(*---------------------------------------------------------------------------*)

PROCEDURE argSkip ((* -- / -- *) arg : DeviceTablePtr );
BEGIN
 IF ~(ChanConsts.readFlag IN argChan.flags) THEN
   raiseEOF;
 ELSIF ARGIDX >= ARGLEN THEN
   argChan.errNum := EIO;
   EXCEPTIONS.RAISE(iolibSource, ORD(skipAtEnd),
                    "ProgramArgs: Skip at end of argument");
 ELSE
   (* Da ein Kommandozeilenargument immer mit einem Nullbyte
    * abgeschlossen ist, braucht vor dem Zugriff auf ARGPTR^[ARGIDX+1]
    * kein Indextest zu erfolgen.
    *)
   IF (ARGPTR^[ARGIDX] = types.CR) & (ARGPTR^[ARGIDX+1] = types.LF) THEN
     (* Nur bei CR+LF zwei Zeichen weiter, bei LF auch nur ein Zeichen *)
     INC(ARGIDX, 2);
   ELSE
     INC(ARGIDX);
   END;
   argChan.result := IOConsts.allRight;
 END;
END argSkip;

(*---------------------------------------------------------------------------*)

PROCEDURE argSkipLook ((* -- / -- *)     arg : DeviceTablePtr;
                       (* __ /AUS *) VAR c   : CHAR;
                       (* __ /AUS *) VAR res : IOConsts.ReadResults );
BEGIN
 argSkip(arg);
 argLook(arg, c, res);
END argSkipLook;

(*---------------------------------------------------------------------------*)

PROCEDURE argTextRead ((* -- / -- *)     arg  : DeviceTablePtr;
                       (* EIN/ -- *)     to   : ADDRESS;
                       (* EIN/ -- *)     size : UNSIGNED;
                       (* -- /AUS *) VAR read : UNSIGNED       );

VAR __REG__ c : CHAR;
    __REG__ i : types.StrRange;
    __REG__ l : types.StrRange;
    __REG__ p : types.StrPtr;

BEGIN
 i    := ARGIDX;
 read := 0;
 IF ~(ChanConsts.readFlag IN argChan.flags) THEN
   raiseEOF;
 ELSIF size = VAL(UNSIGNED,0) THEN
   argChan.result := IOConsts.allRight;
 ELSIF i >= ARGLEN THEN
   argChan.result := IOConsts.endOfInput;
 ELSE
   (* Maximal soviel Zeichen lesen wie in dem Argument noch vorhanden sind
    * (aber mindestens ein Zeichen, da <size> > 0 und ARGLEN > i).
    *)
   IF size > VAL(UNSIGNED,ARGLEN - i) THEN
     l := ARGLEN - i;
   ELSE
     l := VAL(types.StrRange,size);
   END;

   (* Nach einem Zeilenende suchen *)
   WHILE (l > 0) & (ARGPTR^[i] # types.LF) DO
     INC(i);
     DEC(l);
   END;

   (* Ein CR vor einem LF gehoert zum Zeilenende, deswegen ein Zeichen
    * zurueck.
    *)
   IF (ARGPTR^[i] = types.LF) & (i > 0) & (ARGPTR^[i-1] = types.CR) THEN
     DEC(i);
   END;
   (* i := Anzahl der zu uebertragenden Zeichen *)
   DEC(i, ARGIDX);

   IF i = 0 THEN
     argChan.result := IOConsts.endOfLine;
   ELSE
     (* Zeichen uebertragen, und Lesezeiger im Argument entsprechend
      * erhoehen.
      *)
     blk.memmove(to, ADR(ARGPTR^[ARGIDX]), VAL(types.sizeT,i));
     INC(ARGIDX, i);
     argChan.result := IOConsts.allRight;
     read           := VAL(UNSIGNED,i);
   END;
 END;
END argTextRead;

(*---------------------------------------------------------------------------*)

PROCEDURE argRawRead ((* -- / -- *)     arg  : DeviceTablePtr;
                      (* EIN/ -- *)     to   : ADDRESS;
                      (* EIN/ -- *)     size : UNSIGNED;
                      (* -- /AUS *) VAR read : UNSIGNED       );

BEGIN
 read := 0;
 IF ~(ChanConsts.readFlag IN argChan.flags) THEN
   raiseEOF;
 ELSIF size = VAL(UNSIGNED,0) THEN
   argChan.result := IOConsts.allRight;
 ELSIF ARGIDX >= ARGLEN THEN
   argChan.result := IOConsts.endOfInput;
 ELSE
   (* Maximal soviel Zeichen lesen wie in dem Argument noch vorhanden sind
    * (aber mindestens ein Zeichen, da ARGLEN > ARGIDX).
    *)
   IF size > VAL(UNSIGNED,ARGLEN - ARGIDX) THEN
     size := VAL(UNSIGNED,ARGLEN - ARGIDX);
   END;

   (* Zeichen uebertragen, und Lesezeiger im Argument entsprechend
    * erhoehen.
    *)
   blk.memmove(to, ADR(ARGPTR^[ARGIDX]), VAL(types.sizeT,size));
   INC(ARGIDX, VAL(types.StrRange,size));
   read           := size;
   argChan.result := IOConsts.allRight;
 END;
END argRawRead;

(*---------------------------------------------------------------------------*)

PROCEDURE argWrite ((* -- / -- *) arg  : DeviceTablePtr;
                    (* -- / -- *) from : ADDRESS;
                    (* -- / -- *) size : UNSIGNED       );
BEGIN
 raiseWrite;
END argWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE argWriteLn ((* -- / -- *) arg : DeviceTablePtr );
BEGIN
 raiseWrite;
END argWriteLn;

(*---------------------------------------------------------------------------*)

PROCEDURE argName ((* -- / -- *)     arg  : DeviceTablePtr;
                   (* -- /AUS *) VAR name : ARRAY OF CHAR  );
BEGIN
 ISOStrings.Assign("ProgramArgs", name);
END argName;

(*---------------------------------------------------------------------------*)

PROCEDURE argReset ((* -- / -- *) arg : DeviceTablePtr );
BEGIN
 ARG    := 0;
 ARGIDX := 0;
 IF ARGC = 0 THEN
   (* Kein Kommandozeilenargument, also 'readFlag' loeschen *)
   argChan.flags := ChanConsts.FlagSet{ChanConsts.textFlag,
                                       ChanConsts.rawFlag};
   ARGPTR := NULL;
   ARGLEN := 0;
 ELSE
   (* Adresse und Laenge des ersten Arguments merken *)
   argChan.flags := ChanConsts.FlagSet{ChanConsts.textFlag,
                                       ChanConsts.rawFlag,
                                       ChanConsts.readFlag};
   ARGPTR := ARGV^[0];
   ARGLEN := VAL(types.StrRange,str.strlen(ARGPTR));
 END;
END argReset;

(*---------------------------------------------------------------------------*)

PROCEDURE argProc ((* -- / -- *) arg : DeviceTablePtr );
END argProc;
#ifdef HM2
(*$E=*)
#endif

(*===========================================================================*)

PROCEDURE ArgChan ( ): ChanId;
BEGIN
 RETURN(argChanId);
END ArgChan;

(*---------------------------------------------------------------------------*)

PROCEDURE IsArgPresent ( ): BOOLEAN;
BEGIN
 RETURN(ARG < ARGC);
END IsArgPresent;

(*---------------------------------------------------------------------------*)

PROCEDURE NextArg;
BEGIN
 IF ARG < ARGC THEN
   INC(ARG);
 END;
 IF ARG >= ARGC THEN
   (* Es gibt kein weiteres Argument mehr, also 'readFlag' loeschen *)
   argChan.flags := ChanConsts.FlagSet{ChanConsts.textFlag,
                                       ChanConsts.rawFlag};
   ARGPTR := NULL;
   ARGLEN := 0;
 ELSE
   (* Adresse und Laenge des naechsten Arguments merken *)
   ARGPTR := ARGV^[ARG];
   ARGLEN := VAL(types.StrRange,str.strlen(ARGPTR));
 END;
 (* Mit dem Anfang des Arguments beginnen *)
 ARGIDX := 0;
END NextArg;

(*===========================================================================*)

BEGIN (* ProgramArgs *)
 AllocateDeviceId(argDevice);

 argChanId := CAST(ChanId,ADR(argChan));
#if ISO_value_constructor
 argChan := DeviceTable{
   NIL,
   argDevice, argChanId,
   IOConsts.notKnown, 0,
   ChanConsts.FlagSet{ChanConsts.readFlag,
                      ChanConsts.textFlag,
                      ChanConsts.rawFlag},
   argLook, argSkip, argSkipLook, argWriteLn, argTextRead,
   argWrite, argRawRead, argWrite, argName, argReset, argProc, argProc
 };
#else
 WITH argChan DO
   cd          := NIL;
   did         := argDevice;
   cid         := argChanId;
   result      := IOConsts.notKnown;
   errNum      := 0;
   flags       := ChanConsts.FlagSet{ChanConsts.textFlag,
                                     ChanConsts.rawFlag,
                                     ChanConsts.readFlag};
   doLook      := argLook;
   doSkip      := argSkip;
   doSkipLook  := argSkipLook;
   doWriteLn   := argWriteLn;
   doTextRead  := argTextRead;
   doTextWrite := argWrite;
   doRawRead   := argRawRead;
   doRawWrite  := argWrite;
   doGetName   := argName;
   doReset     := argReset;
   doFlush     := argProc;
   doFree      := argProc;
 END;
#endif
 args.main(ARGC, ARGV);
 argReset(NIL);
END ProgramArgs.
