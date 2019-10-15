(* Beispielprogramm fÅr die DOS-Unit *)

PROGRAM Demo4C;

{$I-} (* Keine automatischen I/O-Fehlermeldungen *)

USES DOS;

VAR Zeiger:POINTER;
	Tag,Monat,Jahr,Wochentag,Stunde,Minute,Sekunde,Sek100:WORD;
	Datei:TEXT;
	Zeitpaket:LONGINT;
	Zeitdaten:DateTime;
	Attribute:WORD;
	Pfadname:PathStr;
	Dirname:DirStr;
	Filename:NameStr;
	Fileext:ExtStr;

BEGIN
GetDate(Jahr,Monat,Tag,Wochentag);
WRITELN('Heute ist der ',Tag,'.',Monat,'.',Jahr,' (',
			Wochentag,'. Wochentag)');
GetTime(Stunde,Minute,Sekunde,Sek100);
WRITELN('Zeit: ',Stunde,':',Minute,':',Sekunde);
WRITELN;

ASSIGN(Datei,'DEMO4C.PAS');
RESET(Datei);
GetFTime(Datei,Zeitpaket);
IF DosError <> 0 THEN WRITELN('Fehler bei Dateizugriff.')
ELSE
	BEGIN
	UnpackTime(Zeitpaket,Zeitdaten);
	WITH Zeitdaten DO
		BEGIN
		WRITELN('Die Datei >DEMO4C.PAS< wurde zuletzt modifiziert:');
		WRITELN('Tag:  ',day,'.',month,'.',year);
		WRITELN('Zeit: ',hour,':',min,':',sec);
		END;
	END;
GetFAttr(Datei,Attribute);
IF DosError=0 THEN
	BEGIN
	WRITE('Die Datei ist ');
	IF (Attribute AND ReadOnly) <> 0
		THEN WRITE('schreibgeschÅtzt und ')
		ELSE WRITE('ungeschÅtzt und ');
	IF (Attribute AND Hidden) <> 0
		THEN WRITELN('versteckt.')
		ELSE WRITELN('nicht versteckt.');
	WRITE('Das Archivbit ist ');
	IF (Attribute AND Archive) = 0 THEN WRITE('nicht ');
	WRITELN('gesetzt.');
	END;

CLOSE(Datei);
WRITELN;

Pfadname:=FExpand('DEMO4C.PAS');
WRITELN('Der volle Pfadname der Datei ist: ',Pfadname);
WRITELN;
FSplit(Pfadname,Dirname,Filename,Fileext);
WRITELN('Dir: ',Dirname,'  Dateiname: ',Filename,'  Extension: ',Fileext);
WRITELN;

Pfadname:=Fsearch('DEMO4C.PAS','A:\;.');
IF Pfadname=''	THEN WRITELN('>DEMO4C.PAS< nicht gefunden.')
				ELSE WRITELN('>DEMO4C.PAS< gefunden: ',Pfadname);
WRITELN;

WRITELN('Freier Platz des akt. Laufwerks: ',DiskFree(0),' Bytes');
WRITELN('GesamtkapazitÑt des Laufwerks:   ',DiskSize(0),' Bytes');
WRITELN;

GetIntVec(2,Zeiger);
WRITELN('Busfehler-Interrupthandler bei Adresse: ',LONGINT(Zeiger));
WRITELN;
END.