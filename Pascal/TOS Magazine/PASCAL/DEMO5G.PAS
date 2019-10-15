(* Beispielprogramm fÅr die Anwendung des Dateiselektor- *)
(* und des Alarmfeldes (realisiert durch Objekte)        *)

PROGRAM Demo5G;

USES Demo5GUnit;

VAR Auswahl:TFileSelector;
	Alarm:TAlertbox;
	Datei,Alarmtext:STRING;
	test:INTEGER;

BEGIN
Auswahl.Init('C:\*.*');
WHILE Auswahl.SelectFile(Datei) DO
	BEGIN
	Alarmtext:=CONCAT('Datei:|',Datei,' ');
	Alarm.Init(1,0,Alarmtext,' OK ');
	Test:=Alarm.Alert;
	END;
END.
