(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	Name						: QFA 																							-*)
(*- 	Version 				: 1.000 																						-*)
(*- 	Art 						: Module																						-*)
(*- 	Aufgabe 				: PlugIn fÅr GEMAR																	-*)
(*- 	Autor 					: Steffen Engel 											(C) 93				-*)
(*- 	Letzte énderung : 27.10.1993, 12:35:52															-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- Beschreibung	: Adaption der QFA-Kommandos an problematische					-*)
(*- 								Streamer. 																						-*)
(*- 								Dieses ist fÅr Locate auf TDC 4200 mit SCSI-2-Firm- 	 *)
(*- 								ware																									-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	History 																														-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 	Vers | Datum		| Beschreibung																			-*)
(*-  ------|----------|---------------------------------------						-*)
(*- 	1.0  | 17.12.93 | erstellt																					-*)
(*- 			 |					| 																									-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
MODULE QFA;

IMPORT SYSTEM, CPX;
FROM SYSTEM IMPORT BYTE;

(* Magic-Lib *)
FROM MagicSys 	IMPORT
								(* Const *) Nil, Null, Bit0, Bit1, Bit2, Bit3, Bit4, Bit5,
														Bit6, Bit7, Bit8, Bit9, Bit10, Bit11, Bit12,
														Bit13, Bit14, Bit15,
								(* Type  *) LOC, Byte, ByteSet, sWORD, sINTEGER, sCARDINAL,
														sBITSET, lINTEGER, lCARDINAL, lWORD, lBITSET;

IMPORT void;

IMPORT PlugParms;

TYPE
		tSpacePrivate  = RECORD
											Version : SHORTCARD;
											(*$K+*)
											In	: PROCEDURE ((* Cmd 	 *) SYSTEM.ADDRESS,
																			 (* CmdLen *) SHORTCARD,
																			 (* Buffer *) SYSTEM.ADDRESS,
																			 (* Transferlen *)	LONGCARD,
																			 (* CmdTimeout *) LONGCARD,
																			 (* DataTimeout *) LONGCARD) : SHORTCARD;
											Out : PROCEDURE ((* Cmd 	 *) SYSTEM.ADDRESS,
																			 (* CmdLen *) SHORTCARD,
																			 (* Buffer *) SYSTEM.ADDRESS,
																			 (* Transferlen *)	LONGCARD,
																			 (* CmdTimeout *) LONGCARD,
																			 (* DataTimeout *) LONGCARD) : SHORTCARD;
											(*$K=*)
										END;
		 tpSpacePrivate = POINTER TO tSpacePrivate;


VAR PlugEnv : PlugParms.tpPlugEnvironment;

TYPE tpQFAParms = POINTER TO tQFAParms;

		 tQFAParms	= RECORD
										Opcode		: SHORTCARD;				(* 1 = Position lesen
																									 * 2 = Position ansteuern *)
										Imed			: SHORTCARD;
										BlockAdr	: POINTER TO LONGCARD;
									END;

		 tCmdBlock		= RECORD
											Command : BYTE;
											Lun 		: BYTE;
											Adr 		: LONGCARD;
											Zero		: BYTE;
											LenHigh : BYTE;
											LenLow	: BYTE;
											Flags 	: BYTE; 
										END;


(*------------------------------------------------------------------*)
(*- 																															 -*)
(*- Blockadresse von Streamer holen 															 -*)
(*- 																															 -*)
(*------------------------------------------------------------------*)
PROCEDURE BlockAdr(VAR BlockAdr : LONGCARD) : LONGINT;
TYPE tPositionData = RECORD
											 Flags		 : BYTE;	(* BOP, EOP, Res, Res, Res, BDU, Res, Res *)
											 part 		 : BYTE;
											 Res1 		 : BYTE;
											 Res2 		 : BYTE;
											 FirstLoc  : LONGCARD;
											 LastLoc	 : LONGCARD;
											 Res3 		 : BYTE;
											 NBlBuff2  : BYTE;
											 NBlBuff1  : BYTE;
											 NBlBuff0  : BYTE;
											 BuffBytes : LONGCARD;
										 END;
(*$? SYSTEM.TSIZE(tPositionData) # 20 : Fragezeichen? *)

VAR PositionData	: tPositionData;
		CmdBlock			: tCmdBlock;
		retCode 			: SHORTCARD;

	BEGIN
		WITH CmdBlock DO
			Command := BYTE(034H);				 (* Read Position *)
			Adr 		:= 0;
			Lun 		:= BYTE(1); 					 (* Genau hierum geht es!
																			* TDC kann nur Read Position mit BT = 1 *)
			Zero		:= BYTE(0);
			LenHigh := BYTE(0);
			LenLow	:= BYTE(0);
			Flags 	:= BYTE(0);
		END;

		retCode := tpSpacePrivate(PlugEnv^.Private)^.In(SYSTEM.ADR(CmdBlock), 10,
																		SYSTEM.ADR(PositionData), SIZE(PositionData),
																		300, 300);

		(* Antwort umkopieren *)
		BlockAdr := PositionData.FirstLoc;

		(* und fertig *)
		RETURN VAL(LONGINT, retCode);

	END BlockAdr;


(*------------------------------------------------------------------*)
(*- 																															 -*)
(*- Blockadresse auf Streamer anspringen													 -*)
(*- 																															 -*)
(*------------------------------------------------------------------*)
PROCEDURE SeekBlock(Imed : BOOLEAN; BlockAdr : LONGCARD) : LONGINT;

TYPE tLoc = RECORD
								 Command : BYTE;
								 Lun		 : BYTE;
								 Res1 	 : BYTE;
								 Adr3 	 : BYTE;
								 Adr2 	 : BYTE;
								 Adr1 	 : BYTE;
								 Adr0 	 : BYTE;
								 Res2 	 : BYTE;
								 part 	 : BYTE;
								 Flags	 : BYTE; 
							 END;

VAR Cmd 					 : tLoc;
		Ok						 : BOOLEAN;

	BEGIN

		(* Kommandoblock zusammensetzen *)
		WITH Cmd DO
			Command:=BYTE(02BH);

			IF Imed
				THEN
					(* Bit setzen *)
					Lun := BYTE(1);
				ELSE
					Lun := BYTE(0);
				END;

			Res1 := BYTE( 0);

			(* Adresse einkopieren *)
			Adr3	:= BYTE(VAL(CHAR, BlockAdr DIV 01000000H));
			Adr2	:= BYTE(VAL(CHAR, BlockAdr DIV 010000H MOD 0100H));
			Adr1	:= BYTE(VAL(CHAR, BlockAdr DIV 0100H MOD 0100H));
			Adr0	:= BYTE(VAL(CHAR, BlockAdr MOD 0100H));
			Res2	:= BYTE(0);
			part	:= BYTE(0);
			Flags := BYTE(0);
		END;
		RETURN VAL(LONGINT,
							 tpSpacePrivate(PlugEnv^.Private)^.Out(SYSTEM.ADR(Cmd), 10,
							 NIL, 0, 1200*100, 1200*100));

	END SeekBlock;


(*$K+ $E+ *)
PROCEDURE CallPlug(parms : tpQFAParms) : LONGINT;

	BEGIN
		IF parms^.Opcode = 1
			THEN
				RETURN BlockAdr(parms^.BlockAdr^);
			ELSE
				RETURN SeekBlock(parms^.Imed = 1, parms^.BlockAdr^);
			END;
	END CallPlug;
(*$K= $E+ *)


BEGIN

	PlugEnv := PlugParms.tpPlugEnvironment(CPX.pXCPB);

	IF tpSpacePrivate(PlugEnv^.Private)^.Version # 0101H
		THEN
			void.I := PlugEnv^.Alert(1, '[3][PlugIn: QFA-Installation:|falsche Parameterversion][Aha]');
		ELSE
			CPX.Return(SYSTEM.ADDRESS(CallPlug));
		END;

END QFA.
				