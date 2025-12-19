(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	Name						: ScanIndex 																				-*)
(*- 	Version 				: 1.000 																						-*)
(*- 	Art 						: Module																						-*)
(*- 	Aufgabe 				: PlugIn fÅr GEMAR																	-*)
(*- 	Autor 					: Steffen Engel 											(C) 93				-*)
(*- 	Letzte énderung : 27.10.1993, 12:35:52															-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- Beschreibung	: Bearbeiten des Index eines Backups. 									-*)
(*- 								Nach einem Backup wird dieses PlugIn gerufen, um			-*)
(*- 								die Mîglichkeit zu freiem Export des Index zu haben.	-*)
(*- 								Dabei wird Das Modul fÅr jede Datei einmal aufge- 		-*)
(*- 								rufen.																								-*)
(*- 								Als Beispiel gibt dieses Modul die Liste entweder in	-*)
(*- 								eine Datei aus, oder der Index wird ausgedruckt.			-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	History 																														-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 	Vers | Datum		| Beschreibung																			-*)
(*-  ------|----------|---------------------------------------						-*)
(*- 	1.0  | 26.10.93 | erstellt																					-*)
(*- 			 |					| 																									-*)
(*- 																																			-*)
(*- 																																			-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
MODULE ScanIndex;

IMPORT SYSTEM, TOS, CPX;

IMPORT GEMDOS, Str, POSIX2;

(* GEM-Kram *)
IMPORT AES, form, fsel, rsc, objc;

IMPORT ScanRsc;

(* Magic-Lib *)
FROM MagicSys 	IMPORT
								(* Const *) Nil, Null, Bit0, Bit1, Bit2, Bit3, Bit4, Bit5,
														Bit6, Bit7, Bit8, Bit9, Bit10, Bit11, Bit12,
														Bit13, Bit14, Bit15,
								(* Type  *) LOC, Byte, ByteSet, sWORD, sINTEGER, sCARDINAL,
														sBITSET, lINTEGER, lCARDINAL, lWORD, lBITSET;

IMPORT PlugParms;

CONST MaxPathLen = 513; 								 (* maximale LÑnge eines Pfades 			*)
			MaxNameLen = 128; 								 (* maximale LÑnge eines Dateinamens	*)

TYPE
			Date					= RECORD
												day  : SHORTCARD; (* [1..31]*)
												month: SHORTCARD; (* [1..12]*)
												year : SHORTINT;
											END;

			Time					= RECORD
												second: SHORTCARD; (*[0..59]*)
												minute: SHORTCARD; (*[0..59]*)
												hour	: SHORTCARD; (*[0..23]*)
											 END;

			FileAttr		 = (readOnlyAttr, 					(* Datei nicht beschreibbar *)
											hiddenAttr, 						(* Eintrag unsichtbar *)
											systemAttr, 						(* (Unsichtbare) Systemdatei *)
											volLabelAttr, 					(* Diskname *)
											subdirAttr, 						(* Subdirectory *)
											archiveAttr); 					(* Archivierte Datei *)

			FileAttrSet  = SET OF FileAttr;



			tPathStr			= ARRAY[0..MaxPathLen] OF CHAR;
			tNameStr			= ARRAY[0..MaxNameLen] OF CHAR;

			(* Daten eines Directory-Eintrages *)
			tDirEntry 		= RECORD
												attr: FileAttrSet;
												time: Time;
												date: Date;
												size: LONGCARD;
											END;

			tListEntry		 = RECORD
												pName 			: POINTER TO tNameStr;
												Entry 			: tDirEntry;
											END;

			tFileEntry		 = RECORD
												 Path 			 : tPathStr;
												 pFile			 : POINTER TO tListEntry;
											 END;

			tpFileEntry 	 = POINTER TO tFileEntry;


VAR PrintIt 	 : BOOLEAN;
		SearchFile : tPathStr;
		PlugEnv 	 : PlugParms.tpPlugEnvironment;
		Dial			 : objc.tpTree;



(*$E-*)(*$D-*)(*$S-*)
PROCEDURE First;
BEGIN SYSTEM.CODE(1) (*$P+*)
END First;
(*$P-*)(*$D=*)(*$E=*)(*$S=*)



(*$K+ $E+ *)
PROCEDURE CallPlug(File : tpFileEntry) : LONGINT;
VAR SwapStr : ARRAY[0..20] OF CHAR;

	BEGIN

		IF File = SYSTEM.ADDRESS(-1)
			THEN
				(* hier sollen wir uns deinstallieren *)
			ELSIF File = NIL
			THEN
				(* Neuer Index angefangen, fÅr Scanning uninteressant *)
			ELSE
				IF POSIX2.fnmatch(File^.pFile^.pName^, SearchFile, POSIX2.FNMFlags{}) = 0
					THEN
						 Dial := ScanRsc.Trees^[ScanRsc.cAskmatch];
						 Dial^[ScanRsc.cMatchname].tedinfo^.ptext := SYSTEM.ADDRESS(File^.pFile^.pName);
						 Dial^[ScanRsc.cMatchpath].tedinfo^.ptext := SYSTEM.ADR(File^.Path);
		
						 form.center(Dial, rect);
						 form.dial(form.Start, rect, rect);
						 objc.draw(Dial, 0, 999, rect);
						 ret := form.do(Dial, -1);
						 form.dial(form.Finish, rect, rect);
						 EXCL(sBITSET(ret), Bit15);

						 EXCL(Dial^[ret].state, objc.Selected);

						 IF ret = ScanRsc.cMatchok
							 THEN
								 RETURN 1;
							 END;
					END;
			END;
		RETURN 0;
	END CallPlug;
(*$K= $E+ *)


VAR rect : AES.tRect;
		ret  : sINTEGER;

BEGIN

	PlugEnv := PlugParms.tpPlugEnvironment(CPX.pXCPB);

	CASE PlugEnv^.Alert(1, '[2][SCANINDEX:|Datei suchen?][Ja|:Nein]') OF
		 1 :
				 rsc.relocate(SYSTEM.ADDRESS(First), ScanRsc.Data, ScanRsc.Trees);
				 Dial := ScanRsc.Trees^[ScanRsc.cAskname];
				 Dial^[ScanRsc.cName].tedinfo^.ptext := SYSTEM.ADR(SearchFile);

				 form.center(Dial, rect);
				 form.dial(form.Start, rect, rect);
				 objc.draw(Dial, 0, 999, rect);
				 ret := form.do(Dial, ScanRsc.cName);
				 form.dial(form.Finish, rect, rect);
				 IF ret = ScanRsc.cAskok
					 THEN
						 CPX.Return(SYSTEM.ADDRESS(CallPlug));
					 ELSE
						 CPX.Return(NIL);
					 END;

		|2 : CPX.Return(NIL);
	END;
END ScanIndex.
				