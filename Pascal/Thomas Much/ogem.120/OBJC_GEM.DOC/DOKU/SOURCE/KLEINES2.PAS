PROGRAM Kleines;

USES
	Gem,OWindows,OTypes,ODialogs;
	
{$I KLEINES.I}
	
TYPE
	TMyApplication =	OBJECT(TApplication)
							PROCEDURE InitInstance; VIRTUAL;
							PROCEDURE InitMainWindow; VIRTUAL;
						END;
						
	PInfoMenu =	^TInfoMenu;
	TInfoMenu =	OBJECT(TKeyMenu)
					PROCEDURE Work; VIRTUAL;
				END;
				
	POpenDialog =	^TOpenDialog;
	TOpenDialog =	OBJECT(TKeyMenu)
						PROCEDURE Work; VIRTUAL;
					END;
									
	PMyDialog =	^TMyDialog;
	TMyDialog =	OBJECT(TDialog)
					FUNCTION Ok : BOOLEAN; VIRTUAL;
					FUNCTION Cancel : BOOLEAN; VIRTUAL;
				END;
	
VAR
	MyApplication : TMyApplication;
	Buffer :	RECORD
					Kette : STRING[21];
					O1,O2 : INTEGER;
				END;

PROCEDURE TMyApplication.InitInstance;
BEGIN
	LoadResource('KLEINES.RSC','');
	LoadMenu(main_menu);
	NEW(PInfoMenu,Init(@SELF,K_Ctrl,Ctrl_I,menu_info,desk_menu));
	NEW(POpenDialog,Init(@SELF,K_Ctrl,Ctrl_D,menu_open_dialog,file_menu));
	INHERITED InitInstance;
	SetQuit(menu_quit,file_menu);
END;

PROCEDURE TMyApplication.InitMainWindow;
BEGIN
END;

PROCEDURE TInfoMenu.Work;
BEGIN
	IF ADialog = NIL THEN
	BEGIN
		NEW(ADialog,Init(NIL,'šber KLEINES',info_dial));
	END;
	IF ADialog <> NIL THEN
		ADialog^.MakeWindow;
END;

PROCEDURE TOpenDialog.Work;
	BEGIN
	IF ADialog = NIL THEN
	BEGIN
		ADialog := NEW(PMyDialog,Init(NIL,'KLEINES šbungsprogramm',main_dial));
		IF ADialog <> NIL THEN
		BEGIN
			NEW(PButton,Init(ADialog,md_ok,id_ok,TRUE,'Zeigt Eingaben in einer Alertbox an und beendet das Programm.'));
			NEW(PButton,Init(ADialog,md_cancel,id_cancel,TRUE,'Beendet Programm, ohne Daten Anzuzeigen.'));
			NEW(PEdit,Init(ADialog,md_edit,21,'Hier kann Text eingegeben werden.'));
			NEW(PGroupBox,Init(ADialog,md_option_box,'Optionen','In dieser Box befinden sich zwei RadioButtons'));
			NEW(PRadioButton,Init(ADialog,md_option1,TRUE,'Die erste Option'));
			NEW(PRadioButton,Init(ADialog,md_option2,TRUE,'Die zweite Option'));
			ADialog^.TransferBuffer := @Buffer;
		END;
	END;
	IF ADialog <> NIL THEN
		ADialog^.MakeWindow;
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
		Ok := TRUE;
	END
	ELSE
		Ok := FALSE;
END;

FUNCTION TMyDialog.Cancel : BOOLEAN;
BEGIN
	IF Application^.Alert(NIL,2,2,'Wirklich Beenden?','&Abbruch|&Ok') = 2 THEN
	BEGIN
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