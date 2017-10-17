IMPLEMENTATION MODULE ScsiUtils;
(****************************************************************************
 *
 * Utilities fÅr die Arbeit am SCSI-Port
 *
 * Teile aus ScsiBase, die bei nichtresidenten Moduln verwendet werden,
 * sind hierin gesammelt.
 * Grund dafÅr ist der Modulrumpf von ScsiBase, der aufgrund der
 * Initialisierungen zum Einbinden von Treibern ca. 8 kByte Code produziert,
 * die sonst unnîtig sind.
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsiutil.m,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/10/30 17:44:48 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiutil.m,v $
 * Revision 1.2  1995/10/30  17:44:48  S_Engel
 * *** empty log message ***
 *
 * Revision 1.1  1995/01/01  19:14:58  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)

FROM Portab IMPORT tCompiler, Compiler;
(*$?Compiler=Haenisch:
 (*$S- $V- $T- *)
 *)
(*$?Compiler=Megamax:
	(*$R- BereichsprÅfung aus 				*)
	(*$S- Stack-PrÅfung aus 					*)
	(*$Z+ Funktionswerte in Registern *)
 *)

FROM SYSTEM 	IMPORT
		(* Type  *) ADDRESS;
IMPORT SYSTEM;

(*$?Compiler=Haenisch:
	FROM SYSTEM  IMPORT CODE;
	(* String fÅr WHAT - leider ein biûchen HM2-spezifisches *)
	CONST What = '@(#) ScsiUtil '
							 + CHR(SYSTEM.DATE DIV 1000000H DIV 10 + 48)
							 + CHR(SYSTEM.DATE DIV 1000000H MOD 10 + 48) + '.'
							 + CHR(SYSTEM.DATE DIV 10000H MOD 100H DIV 10 MOD 10 + 48)
							 + CHR(SYSTEM.DATE DIV 10000H MOD 100H MOD 10 + 48) + '.'
							 + CHR(SYSTEM.DATE MOD 10000H DIV 10 MOD 10 + 48)
							 + CHR(SYSTEM.DATE MOD 10000H MOD 10 + 48)
							 + '  (c) S. Engel';
 *)


VAR
	memvalid	[0000420H] : LONGCARD;
	ResValid	[0000426H] : LONGCARD;
	memval2 	[000043AH] : LONGCARD;
	OldSsp							 : ADDRESS;


(*$?Compiler=Megamax: (*$L-*) *)
(*$?Compiler=Haenisch: (*$Y- $X-*) *)
PROCEDURE IsSuperOn():BOOLEAN;
BEGIN
	(*$?Compiler=Haenisch:
(*\ONYX v2.00  28.02.93 14:37*)(*$D-*)
(*26 bytes of MC68020 code*)
CODE(048E7H,02020H);
CODE(02F3CH,00000H,00001H);
CODE(03F3CH,00020H);
CODE(04E41H);
CODE(05C8FH);
CODE(00240H,00001H);
CODE(04CDFH,00404H);
(*$D=*)
(*\=
		MOVEM.L D2/A2, -(SP)
		MOVE.L	#1, -(SP) 								; Inquire SuperMode
		MOVE.W	#32,-(SP) 								; Super
		TRAP		#1												; GEMDOS
		ADDQ.L	#6,SP 										; D0 = 0 : aus, D0 = -1 : an
		ANDI.W	#1, D0										; aus -1 mach 1
		MOVEM.L (SP)+,D2/A2
\*)
	 *)
	(*$?Compiler=Megamax:
	SYSTEM.ASSEMBLER
		MOVE.L	#1, -(SP) 								; Inquire SuperMode
		MOVE.W	#32,-(SP) 								; Super
		TRAP		#1												; GEMDOS
		ADDQ.L	#6,SP 										; D0 = 0 : aus, D0 = -1 : an
		ANDI.W	#1, D0										; aus -1 mach 1
	END;
	 *)
END IsSuperOn;
(*$?Compiler=Megamax: (*$L=*) *)
(*$?Compiler=Haenisch: (*$Y= $X=*) *)


(*$?Compiler=Megamax: (*$L-*) *)
PROCEDURE SuperOn;
BEGIN
	(*$?Compiler=Haenisch:
(*\ONYX v2.00  28.02.93 14:37*)(*$D-*)
(*18 bytes of MC68020 code*)
CODE(048E7H,02020H);
CODE(042A7H);
CODE(03F3CH,00020H);
CODE(04E41H);
CODE(05C8FH);
CODE(04CDFH,00404H);
(*$D=*)
(*\=
		MOVEM.L D2/A2, -(SP)
		CLR.L 	-(SP)
		MOVE.W	#32,-(SP)
		TRAP		#1
		ADDQ.L	#6,SP
		MOVEM.L (SP)+,D2/A2
\*)
	SYSTEM.STORE (0, OldSsp); 	(* OldSsp sichern *)
	 *)
	(*$?Compiler=Megamax:
	SYSTEM.ASSEMBLER
		CLR.L 	-(SP)
		MOVE.W	#32,-(SP)
		TRAP		#1
		ADDQ.L	#6,SP
		MOVE.L	D0,OldSsp
	END;
	*)
END SuperOn;
(*$?Compiler=Megamax: (*$L=*) *)


(*$?Compiler=Megamax: (*$L-*) *)
PROCEDURE SuperOff;
BEGIN
	(*$?Compiler=Haenisch:
	SYSTEM.LOAD(OldSsp, 0);
(*\ONYX v2.00  28.02.93 14:37*)(*$D-*)
(*18 bytes of MC68020 code*)
CODE(048E7H,02020H);
CODE(02F00H);
CODE(03F3CH,00020H);
CODE(04E41H);
CODE(05C8FH);
CODE(04CDFH,00404H);
(*$D=*)
(*\=
		MOVEM.L D2/A2, -(SP)
		MOVE.L	D0,-(SP)
		MOVE.W	#32,-(SP)
		TRAP		#1
		ADDQ.L	#6,SP
		MOVEM.L (SP)+,D2/A2
\*)
	 *)
	(*$?Compiler=Megamax:
	SYSTEM.ASSEMBLER
		MOVE.L	OldSsp,-(SP)
		MOVE.W	#32,-(SP)
		TRAP		#1
		ADDQ.L	#6,SP
	END;
	*)
END SuperOff;
(*$?Compiler=Megamax: (*$L=*) *)


PROCEDURE WarmReset;
 BEGIN
	SuperOn;
	(*$?Compiler=Haenisch:
(*\ONYX v2.00  28.02.93 14:37*)(*$D-*)
(*14 bytes of MC68020 code*)
CODE(02079H,00000H,004F2H);
CODE(02050H);
CODE(02068H,00008H);
CODE(04ED0H);
(*$D=*)
(*\=
		MOVEA.L $4f2,A0 		; sysbase
		MOVEA.L (A0),A0 		; wegen Fehler in altem AHDI
		MOVEA.L 8(A0),A0		; osbeg
		JMP 		(A0)				; und ab die Post
\*)
	 *)
	(*$?Compiler=Megamax:
	SYSTEM.ASSEMBLER
		MOVE.L	$4f2,A0 		; sysbase
		MOVE.L	(A0),A0 		; wegen Fehler in altem AHDI
		MOVE.L	8(A0),A0		; osbeg
		JMP 		(A0)				; und ab die Post
	END;
	*)
END WarmReset;


PROCEDURE ColdReset;
 BEGIN
	SuperOn;
	(* fÅr Kaltstart die System-Variablen lîschen *)
	memvalid := 0;
	ResValid := 0;
	memval2  := 0;
	SuperOff;
	WarmReset;
END ColdReset;


PROCEDURE Wait(Ticks : LONGCARD);
VAR Clock[04BAH], Time : LONGCARD;

	BEGIN
		Time := Clock + Ticks;
		WHILE Clock < Time DO
		END;
	END Wait;


CONST Dummy = '#@#@#@#@#@#@#@#@#@#@#@#@';


END ScsiUtils.
				
