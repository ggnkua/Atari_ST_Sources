MODULE VDI;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |30.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM;

TYPE contrlrec* = RECORD
                    Opcode*    : INTEGER;
                    SizePtsin* : INTEGER;
                    SizePtsout*: INTEGER;
                    SizeIntin* : INTEGER;
                    SizeIntout*: INTEGER;
                    SubCode*   : INTEGER;
                    Station*   : INTEGER;
                    Misc*      : ARRAY 10 OF INTEGER;
                  END(*RECORD*);
     intarr*    = ARRAY 128 OF INTEGER;
     parmblkrec*= RECORD
                    Contrl* : POINTER TO contrlrec;
                    Intin*  : POINTER TO intarr;
                    Ptsin*  : POINTER TO intarr;
                    Intout* : POINTER TO intarr;
                    Ptsout* : POINTER TO intarr;
                  END(*RECORD*);

VAR ParmBlk* : parmblkrec;
    Contrl*  : contrlrec;
    Intin*,Ptsin*,Intout*,Ptsout* : intarr;

PROCEDURE Call*(Opcode,Subcode,Handle : INTEGER; Parameter : LONGINT);
 (* Parameter contains the bytes for Contrl 1 to 4 *)
 BEGIN
  S.PUTREG(1,S.ADR(ParmBlk));
  S.INLINE(2655H);              (* movea.l (A5),A3       *)
  S.INLINE(36EEH,0010H);        (* move.w  $10(A6),(A3)+ *)
  S.INLINE(429BH);              (* clr.l   (A3)+         *)
  S.INLINE(429BH);              (* clr.l   (A3)+         *)
  S.INLINE(202EH,0008H);        (* move.l  $8(A6),D0     *)
  S.INLINE(01CBH,0FFF9H);       (* movep.l D0,$FFF9(A3)  *)
  S.INLINE(36EEH,000EH);        (* move.w  $E(A6),(A3)+  *)
  S.INLINE(36AEH,000CH);        (* move.w  $C(A6),(A3)   *)
  S.INLINE(7073H);              (* moveq   #$73,D0       *)
  S.INLINE(4E42H);              (* trap    #2            *)
 END Call;

BEGIN
  ParmBlk.Contrl := S.ADR(Contrl);
  ParmBlk.Intin := S.ADR(Intin);
  ParmBlk.Intout := S.ADR(Intout);
  ParmBlk.Ptsin := S.ADR(Ptsin);
  ParmBlk.Ptsout := S.ADR(Ptsout);
END VDI.
