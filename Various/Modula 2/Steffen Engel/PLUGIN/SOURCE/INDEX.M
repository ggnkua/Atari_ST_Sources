(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- 	Name						: Index 																						-*)
(*- 	Version 				: 1.000 																						-*)
(*- 	Art 						: Module																						-*)
(*- 	Aufgabe 				: PlugIn fr GEMAR																	-*)
(*- 	Autor 					: Steffen Engel 											(C) 93				-*)
(*- 	Letzte Žnderung : 27.10.1993, 12:35:52															-*)
(*- 																																			-*)
(*-------------------------------------------------------------------------*)
(*-------------------------------------------------------------------------*)
(*- 																																			-*)
(*- Beschreibung	: Bearbeiten des Index eines Backups. 									-*)
(*- 								Nach einem Backup wird dieses PlugIn gerufen, um			-*)
(*- 								die M”glichkeit zu freiem Export des Index zu haben.	-*)
(*- 								Dabei wird Das Modul fr jede Datei einmal aufge- 		-*)
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
MODULE Index;

IMPORT SYSTEM, TOS, CPX;

IMPORT GEMDOS, Str, form, fsel;

(* Magic-Lib *)
FROM MagicSys 	IMPORT
								(* Const *) Nil, Null, Bit0, Bit1, Bit2, Bit3, Bit4, Bit5,
														Bit6, Bit7, Bit8, Bit9, Bit10, Bit11, Bit12,
														Bit13, Bit14, Bit15,
								(* Type  *) LOC, Byte, ByteSet, sWORD, sINTEGER, sCARDINAL,
														sBITSET, lINTEGER, lCARDINAL, lWORD, lBITSET;


IMPORT mtTime;


IMPORT PlugParms;

CONST MaxPathLen = 513; 								 (* maximale L„nge eines Pfades 			*)
			MaxNameLen = 128; 								 (* maximale L„nge eines Dateinamens	*)

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


		 tIndexHeader = RECORD
										 Header 			: ARRAY[0..19]OF CHAR;
																							(* TextInfo ber das Backup  *)
										 Revision 		: sCARDINAL;
										 time 				: Time;
										 date 				: Date;
																								(* Zeitpunkt der Anfertigung *)
										 DataSize 		: lCARDINAL;	(* Anzahl der Datenbl”cke 	 *)
										 IndexSize		: lCARDINAL;	(* Anzahl der Bytes im Index *)
										 reserved0		: lCARDINAL;
										 FileAnz			: sCARDINAL;	(* Anzahl der Dateien 			 *)
										 Cartridges 	: sCARDINAL;	(* Anzahl der B„nder				 *)
										 reserved 		: ARRAY[0..8] OF sCARDINAL;
										 Packed 			: BOOLEAN;		(* Gepacktes Archiv?				 *)
										 reserved5		: SYSTEM.BYTE;
										 PackId 			: ARRAY[0..15] OF CHAR;
										 Comment			: ARRAY[0..33] OF CHAR;
										 MintDrives 	: lBITSET;
									 END;

		tpIndexHeader = POINTER TO tIndexHeader;


VAR PrintIt : BOOLEAN;
		LastPath, ExpFile : tPathStr;
		ExpName : tNameStr;
		handle	: SHORTINT;
		PathSize, PathFiles : LONGCARD;
		PlugEnv : PlugParms.tpPlugEnvironment;
		IndexHeader : tpIndexHeader;

	

PROCEDURE WriteGEMDOS(Str : ARRAY OF CHAR);
VAR Chars : LONGINT;
	BEGIN
		Chars := LENGTH(Str);
		Chars := GEMDOS.Fwrite(handle, Chars, SYSTEM.ADR(Str));
	END WriteGEMDOS;
	
	
PROCEDURE InterpretStr(InStr:ARRAY OF CHAR; VAR OutStr:ARRAY OF CHAR);

	VAR
		i,j 	 : SHORTCARD;
		InLen  : SHORTCARD;
		OutLen : SHORTCARD;

	PROCEDURE ValHex(Ch:CHAR) : SHORTCARD;

		BEGIN
			Ch:=CAP(Ch);
			IF Ch>'9' THEN
				RETURN ORD(Ch)-55;
			ELSE
				RETURN ORD(Ch)-48;
			END;
		END ValHex;
	
	BEGIN
		i:=0;
		j:=0;
		InLen:=HIGH(InStr)+1;
		OutLen:=HIGH(OutStr)+1;
		WHILE (InStr[j]<>0C) AND (j<InLen) AND (i<OutLen) DO
			IF InStr[j]='/' THEN
				CASE CAP(InStr[j+1]) OF
					'C' : OutStr[i]:=015C  |
					'L' : OutStr[i]:=012C  |
					'E' : OutStr[i]:=033C  |
					'/' : OutStr[i]:=057C  |
					'N' : OutStr[i]:=015C;
								INC(i);
								OutStr[i]:=012C; |
					'$' : OutStr[i]:=CHR(16*ValHex(InStr[j+2])+ValHex(InStr[j+3]));
								INC(j,2)				 |
				END;
				INC(i);
				INC(j,2);
			ELSE
				OutStr[i]:=InStr[j];
				INC(i);
				INC(j);
			END;
		END;
		OutStr[i]:=0C;
	END InterpretStr;
	

PROCEDURE WriteStr(Str:ARRAY OF CHAR);

VAR  StrBuf : ARRAY[0..100] OF CHAR;

	BEGIN
		InterpretStr(Str, StrBuf);
		WriteGEMDOS(StrBuf);
	END WriteStr;
	

PROCEDURE WriteLNum(Num:LONGCARD;Width:SHORTCARD);

	VAR
		NumStr : ARRAY[0..10] OF CHAR;
		i 		 : SHORTCARD;

	BEGIN
		IF Width>0 THEN
			FOR i:=Width-1 TO 0 BY -1 DO
				IF (Num = 0) AND (i # Width-1)
					THEN
						NumStr[i]:=' ';
					ELSE
						NumStr[i]:=CHR(48+VAL(SHORTCARD,Num MOD 10));
						Num := Num DIV 10;
					END;
			END;
			NumStr[Width]:=0C;
			WriteGEMDOS(NumStr);
		END;
	END WriteLNum;

					
PROCEDURE WriteLHex(Hex:LONGCARD;Width:SHORTCARD);

	VAR
		NumStr	: ARRAY[0..10] OF CHAR;
		Potenz	: LONGCARD;
		Number,
		i 			: SHORTCARD;

	BEGIN
		IF Width>0 THEN
			Potenz:=1;
			FOR i:=Width-1 TO 0 BY -1 DO
				Number:=VAL(SHORTCARD, (Hex DIV Potenz) MOD 16);
				IF Number>9 THEN
					NumStr[i]:=CHR(55+Number);
				ELSE
					NumStr[i]:=CHR(48+Number);
				END;
				Potenz:=Potenz*16;
			END;
			NumStr[Width]:=0C;
			WriteGEMDOS(NumStr);
		END;
	END WriteLHex;


PROCEDURE WriteNum(Num,Width:SHORTCARD);

	BEGIN
		WriteLNum(VAL(LONGCARD, Num), Width);
	END WriteNum;


PROCEDURE WriteHex(Hex,Width:SHORTCARD);

	BEGIN
		WriteLHex(VAL(LONGCARD, Hex),Width);
	END WriteHex;


(*$K+ $E+ *)
PROCEDURE CallPlug(File : tpFileEntry) : LONGINT;
VAR SwapStr : ARRAY[0..40] OF CHAR;

	BEGIN

		IF File = SYSTEM.ADDRESS(-1)
			THEN
				(* hier sollen wir uns deinstallieren *)
				IF ~PrintIt
					THEN
						handle := GEMDOS.Fclose(handle);
					END;
			ELSIF File = NIL
			THEN
				(* IndexHeader in private *)
				IF PlugEnv^.Private # NIL
					THEN
						IndexHeader := PlugEnv^.Private;
						WITH IndexHeader^ DO
							WriteStr('/n************************************************'
											 + '************************************************/n');
				
							WriteStr('Gemar-Index  ');
				
							WITH date DO
								mtTime.DateString(mtTime.EncodeDate(day, month, year),
																	SwapStr);

							END;
							WriteStr(SwapStr);
							WriteStr('   ');
							WITH time DO
								mtTime.TimeString(mtTime.EncodeTime(hour, minute, second),
																	SwapStr);
							END;
							WriteStr(SwapStr);
							WriteStr('/n');
				
				
							IF LENGTH(Comment) # 0
								THEN
									WriteStr('>>> ');
									WriteStr(Comment);
									WriteStr('/n');
								END;
							WriteStr('/n');
				
							WriteNum(FileAnz, 10);
							WriteStr(' Entries/n');
				
							WriteLNum(DataSize, 10);
							WriteStr(' Blocks/n');
				
							WriteNum(Cartridges, 10);
							WriteStr(' Cartridge');
							IF Cartridges > 1
								THEN
									WriteStr('s');
								END;
							WriteStr('/n');
				
							IF Packed
								THEN
									WriteStr('Compressed by ');
									WriteStr(PackId);
								END;

							WriteStr('/n/n');

						END;
					END;
			ELSE
				IF ~Str.Equal(File^.Path, LastPath)
					THEN
						Str.Assign(LastPath, File^.Path);
						WriteStr('/n====');
						WriteLNum(PathFiles, 6);
						WriteStr(' Files mit ');
						WriteLNum(PathSize, 8);
						WriteStr(' Bytes ====/n/n');
						WriteStr('Ordner ');
						WriteStr(LastPath);
						WriteStr('/n/n');
						PathSize := 0;
						PathFiles := 0;
					END;

				(* Ordner z„hlen *)
				INC(PathFiles);
				PathSize := PathSize + File^.pFile^.Entry.size;

				WriteStr('  ');
				WriteStr(File^.pFile^.pName^);
				IF LENGTH(File^.pFile^.pName^) < 20
					THEN
						SwapStr := '                    ';
						SwapStr[20 - LENGTH(File^.pFile^.pName^)] := 0C;
					ELSE
						SwapStr := '  ';
					END;
				WriteStr(SwapStr);
				WriteLNum(File^.pFile^.Entry.size, 8);
				WriteStr('/n');
			END;

		RETURN 0;
	END CallPlug;
(*$K= $E+ *)




PROCEDURE CutPath(VAR path : STRING);
VAR count, pos : LONGINT;

	BEGIN
		FOR count := 0 TO LENGTH(ExpFile) DO
			IF ExpFile[count] = '\'
				THEN
					pos := count;
				END;
		END;
		ExpFile[pos+1] := 0C; 					(* abschneiden *)
	END CutPath;


BEGIN

	PlugEnv := PlugParms.tpPlugEnvironment(CPX.pXCPB);

	CASE PlugEnv^.Alert(3, '[1][PlugIn:|Index bearbeiten][[Drucken|Da[tei|:Abbruch]') OF
		1: PrintIt := TRUE;
			 handle := 3;

	 |2: PrintIt := FALSE;
			 Str.Assign(ExpFile, PlugEnv^.PlugPath^);
			 CutPath(ExpFile);
			 Str.Concat(ExpFile, '*.ASC');
			 ExpName := '*.ASC';
			 IF fsel.exinput(ExpFile, ExpName, 'Index exportieren')
				 THEN
					 CutPath(ExpFile);
					 Str.Concat(ExpFile, ExpName);	 (* Namen dran *)
					 handle := GEMDOS.Fcreate(ExpFile, BITSET{});
					 IF handle < 0
						 THEN
							 CPX.Return(NIL);  (* Abbruch *)
						 END;
				 ELSE
					 (* Abbruch *)
					 CPX.Return(NIL);
				 END;
	 ELSE CPX.Return(NIL);
	END;

	LastPath := '';
	PathSize := 0;
	PathFiles := 0;

	CPX.Return(SYSTEM.ADDRESS(CallPlug));
END Index.
				