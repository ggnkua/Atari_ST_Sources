PROGRAM Kleines;

USES
	OWindows,OTypes,ODialogs;
	
{$I KLEINES.I}
	
TYPE
	TMyApplication =	OBJECT(TApplication)
							PROCEDURE InitInstance; VIRTUAL;
							PROCEDURE InitMainWindow; VIRTUAL;
						END;
						
	PMyDialog =	^TMyDialog;
	TMyDialog =	OBJECT(TDialog)
					FUNCTION Ok : BOOLEAN; VIRTUAL;
					FUNCTION Cancel : BOOLEAN; VIRTUAL;
				END;
	
VAR
	MyApplication : TMyApplication;
	Buffer :	RECORD
					Kette : STRING[19];
					O1,O2 : INTEGER;
				END;	
	
PROCEDURE TMyApplication.InitInstance;
BEGIN
	LoadResource('KLEINES.RSC','');
	INHERITED InitInstance;
END;

PROCEDURE TMyApplication.InitMainWindow;
VAR
	p : PMyDialog;
BEGIN
	IF MainWindow = NIL THEN
	BEGIN
		p := NEW(PMyDialog,Init(NIL,'KLEINES šbungsprogramm',main_dial));
		IF MainWindow <> NIL THEN
		BEGIN
			NEW(PButton,Init(p,md_ok,id_ok,TRUE,'Zeigt Eingaben in einer Alertbox an und beendet das Programm.'));
			NEW(PButton,Init(p,md_cancel,id_cancel,TRUE,'Beendet Programm, ohne Daten Anzuzeigen.'));
			NEW(PEdit,Init(p,md_edit,20,'Hier kann Text eingegeben werden.'));
			NEW(PGroupBox,Init(p,md_option_box,'Optionen','In dieser Box befinden sich zwei RadioButtons'));
			NEW(PRadioButton,Init(p,md_option1,TRUE,'Die erste Option'));
			NEW(PRadioButton,Init(p,md_option2,TRUE,'Die zweite Option'));
			p^.TransferBuffer := @Buffer;
		END;
	END;
	IF MainWindow <> NIL THEN
		MainWindow^.MakeWindow;
END;

FUNCTION TMyDialog.Ok : BOOLEAN;
VAR
	Valid : BOOLEAN;
	Ausgabe : STRING;
BEGIN
	Valid := INHERITED Ok;
	IF Valid = TRUE THEN
	BEGIN
		Ausgabe := 'In die Editzeile wurde "'+Buffer.Kette+'" eingegeben. Es wurde der Radiobutton "';
		IF Buffer.O1 = bf_checked THEN 
			Ausgabe := Ausgabe+'1'
		ELSE
			Ausgabe := Ausgabe+'2';
		Ausgabe := Ausgabe+'. Option" ausgew„hlt.';
		Application^.Alert(NIL,1,0,Ausgabe,'&Ok');
		Application^.Quit;
		Ok := TRUE;
	END
	ELSE
		Ok := FALSE;
END;

FUNCTION TMyDialog.Cancel : BOOLEAN;
BEGIN
	IF Application^.Alert(NIL,2,2,'Wirklich Beenden?','&Abbruch|&Ok') = 2 THEN
	BEGIN
		Application^.Quit;
		Cancel := TRUE;
	END
	ELSE
		Cancel := FALSE;
END;

BEGIN
	MyApplication.Init('Kleines');
	MyApplication.Run;
	MyApplication.Done;
END.