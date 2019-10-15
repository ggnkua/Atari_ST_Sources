(* Mini-Demoprogramm fÅr die Anwendung von GEM-Funktionen *)

PROGRAM Demo4B;

USES GEM;

VAR test,knopf:INTEGER;
	pfad,name:STRING;

BEGIN
IF form_alert(1,'[2][ Dateiauswahlfeld | anzeigen...? ][ Ja | Nein ]')=1 THEN
	BEGIN
	pfad:='A:\*.PAS';
	name:='DEMO4B.PAS';
	test:=fsel_input(pfad,name,knopf);
	END;
END.
