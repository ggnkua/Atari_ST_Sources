(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	Name						: Rumpf 																						-*)
(*- 	Version 				: 1.000 																						-*)
(*- 	Art 						: Module																						-*)
(*- 	Aufgabe 				: PlugIn fÅr GEMAR																	-*)
(*- 	Autor 					: Steffen Engel 											(C) 93				-*)
(*- 	Letzte énderung : 27.10.1993, 12:35:52															-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- Beschreibung	: 																											-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	History 																														-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 	Vers | Datum		| Beschreibung																			-*)
(*-  ------|----------|---------------------------------------						-*)
(*- 			 |					| 																									-*)
(*- 			 |					| 																									-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
MODULE Rumpf;

IMPORT SYSTEM, CPX;


(* Magic-Lib *)
FROM MagicSys 	IMPORT
								(* Const *) Nil, Null, Bit0, Bit1, Bit2, Bit3, Bit4, Bit5,
														Bit6, Bit7, Bit8, Bit9, Bit10, Bit11, Bit12,
														Bit13, Bit14, Bit15,
								(* Type  *) LOC, Byte, ByteSet, sWORD, sINTEGER, sCARDINAL,
														sBITSET, lINTEGER, lCARDINAL, lWORD, lBITSET;

IMPORT void;

IMPORT PlugParms;


VAR PlugEnv : PlugParms.tpPlugEnvironment;


(*$K+ $E+ *)
PROCEDURE CallPlug(parm : SYSTEM.ADDRESS) : LONGINT;

	BEGIN

		void.I := PlugEnv^.Alert(1, '[1][PlugIn: Aufruf][Aha]');

		RETURN 0;
	END CallPlug;
(*$K= $E+ *)




BEGIN

	PlugEnv := PlugParms.tpPlugEnvironment(CPX.pXCPB);

	IF PlugEnv^.Version < 0100H
		THEN
			void.I := PlugEnv^.Alert(1, '[3][PlugIn: Fehlerhafte Parameterversion][Aha]');
			CPX.Return(NIL);
		ELSE
			void.I := PlugEnv^.Alert(1, '[3][PlugIn: Installiert][Aha]');
			CPX.Return(SYSTEM.ADDRESS(CallPlug));
		END;

END Rumpf.
				