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
  ASSEMBLER

	MOVE.L	#ParmBlk,D1
	MOVE.L	D1,A5
	MOVEA.L	(A5),A0
	MOVE.W	$10(A6),(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	MOVE.L	8(A6),D0
	MOVEP.L	D0,-7(A0)
	MOVE.W	$E(A6),(A0)+
	MOVE.W	$C(A6),(A0)
	MOVE.W	#$73,D0
	TRAP	#2

  END
 END Call;

BEGIN
  ParmBlk.Contrl := S.ADR(Contrl);
  ParmBlk.Intin := S.ADR(Intin);
  ParmBlk.Intout := S.ADR(Intout);
  ParmBlk.Ptsin := S.ADR(Ptsin);
  ParmBlk.Ptsout := S.ADR(Ptsout);
END VDI.
