(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	Name						: Space 																						-*)
(*- 	Version 				: 1.000 																						-*)
(*- 	Art 						: Module																						-*)
(*- 	Aufgabe 				: PlugIn fÅr GEMAR																	-*)
(*- 	Autor 					: Steffen Engel 											(C) 93				-*)
(*- 	Letzte énderung : 27.10.1993, 12:35:52															-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- Beschreibung	: Adaption des Space-Kommandos auf Streamer mit 				-*)
(*- 								beschrÑnktem Parameterumfang. 												-*)
(*- 								Dieses ist fÅr ExaByte-Streamer.											-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	History 																														-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 	Vers | Datum		| Beschreibung																			-*)
(*-  ------|----------|---------------------------------------						-*)
(*- 	1.0  | 15.11.93 | erstellt																					-*)
(*- 			 |					| 																									-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
MODULE Space;

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


CONST ParmVersion = 0000H;				 (* Version des Prameterblockes *)
			PathLen 		= 512;

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

		 tPlugEnvironment
				= RECORD
						(* aktuelle Parameterversion = 1.00 = 0100H *)
						Version  : sINTEGER;													(* Version zeigt Umfang der Parameter an	 *)
						private  : tpSpacePrivate;
						ApplId	 : sINTEGER;													(* Applikationsid des rufenden Programmes  *)
						VDIHandle : sINTEGER; 												(* Workstation des Hauptprogrammes				 *)
						PlugPath : POINTER TO ARRAY[0..PathLen-1] OF CHAR;	(* Name und Pfad des PlugIn, kann auch
																														 relativ sein 													 *)
						(*$K+*)
						Alert 	 : PROCEDURE( 	(* def	 *) sINTEGER,
																 VAR(* msg	 *) STRING) : sINTEGER;
						(*$K=*)
					END;

		 tpPlugEnvironment = POINTER TO tPlugEnvironment;



VAR PlugEnv : tpPlugEnvironment;

TYPE tpSpaceParms = POINTER TO tSpaceParms;
		 tSpaceParms	= RECORD
											Code	: SHORTCARD;
											Count : LONGINT;
										END;
		 tCmdBlock		= RECORD
											Command : BYTE;
											LunAdr	: BYTE;
											ADR 		: SHORTCARD;
											Len 		: BYTE;
											Flags 	: BYTE;
										END;	

CONST SpaceBlock				= 0;
			SpaceMark 				= 1;
			SpaceSerie				= 2;
			SpaceEnd					= 3;
			SpaceSetmarks 		= 4;
PROCEDURE SpaceCmd(Code:SHORTCARD;Count:LONGINT;
									 Timeout:LONGCARD) : SHORTCARD;

	VAR
		CmdBlock			 : tCmdBlock;
		
BEGIN
	WITH CmdBlock DO
		Command:=BYTE(011H);
		LunAdr:=BYTE(VAL(CHAR, Code MOD 4));
		ADR:=VAL(SHORTCARD, LONGCARD(Count) DIV 0100H);
		Len:=BYTE(VAL(CHAR, LONGCARD(Count) MOD 0100H));
		Flags:=BYTE(0);
	END;
	RETURN PlugEnv^.private^.In(SYSTEM.ADR(CmdBlock), 6, NIL, 0, Timeout, 400);
END SpaceCmd;


PROCEDURE CheckforBlankCheck() : SHORTCARD;
TYPE tSenseData = RECORD
										HeadBits		 : BYTE;
										SegmentNo 	 : BYTE;
										SenseKey		 : BYTE;
										InfoByte1 	 : BYTE;
										InfoByte2 	 : BYTE;
										InfoByte3 	 : BYTE;
										InfoByte4 	 : BYTE;
										AddLength 	 : BYTE;
										CmdSpecific  : LONGCARD;
										AddSense		 : SHORTCARD;
									END;
VAR SenseData : tSenseData;
		CmdBlock	: tCmdBlock;
		retCode 	: SHORTCARD;

	BEGIN
		(* Kommando zusammenstellen *)
		WITH CmdBlock DO
			Command := BYTE(03H);
			LunAdr	:= BYTE(0);
			ADR 		:= 0;
			Len 		:= BYTE(14);
			Flags 	:= BYTE(0);
		END;
		retCode := PlugEnv^.private^.In(SYSTEM.ADR(CmdBlock), 6,
																		SYSTEM.ADR(SenseData), 14, 400, 400);
		IF retCode = 0
			THEN
			 IF (VAL(SHORTCARD, CHAR(SenseData.HeadBits)) DIV 010H MOD 08H # 07H) 	 (* extended Sense? *)
				 OR (VAL(SHORTCARD, CHAR(SenseData.SenseKey)) MOD 010H # 08H)  (* Blank Check?		*)
					THEN
						retCode := 0FFFFH;		(* Was'n Das'n? *)
					END;
			END;
		RETURN retCode;
	END CheckforBlankCheck;


PROCEDURE SpaceEOM() : SHORTCARD;
VAR result : SHORTCARD;

	BEGIN
		LOOP
			(* einen Block Åberspringen (erster Datenblock)
			 * Wenn es fehlschlÑgt, wurde vermutlich das Bandende erreicht
			 *)
			result := SpaceCmd(SpaceBlock, 1, 1000);
			IF result # 0
				THEN
					(* Hier kînnte man checken, wah? *)
					RETURN CheckforBlankCheck();
				END;

			(* Dann zum Ende dieses Backup, Fehlschlag bedeutet Fehler
			 * im Bandaufbau *)
			result := SpaceCmd(SpaceMark, 6, 120000);
			IF result # 0
				THEN
					(* Fehler melden *)
					RETURN result;
				END;
		END;
	END SpaceEOM;


(*$K+ $E+ *)
PROCEDURE CallPlug(parms : tpSpaceParms) : LONGINT;

	BEGIN
		IF parms^.Code = SpaceEnd
			THEN
				(* ExaByte kann kein Space to end, daher anders tricksen *)
				RETURN SpaceEOM();
			ELSE
				RETURN SpaceCmd(parms^.Code, parms^.Count, 1200);
			END;
	END CallPlug;
(*$K= $E+ *)


BEGIN

	PlugEnv := tpPlugEnvironment(CPX.pXCPB);

	IF PlugEnv^.private^.Version # 0101H
		THEN
			void.I := PlugEnv^.Alert(1, '[3][PlugIn: Space-Installation:|falsche Parameterversion][Aha]');
		ELSE
			CPX.Return(SYSTEM.ADDRESS(CallPlug));
		END;

END Space.
				