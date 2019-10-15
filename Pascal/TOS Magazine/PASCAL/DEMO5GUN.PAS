(* Unit fÅr komfortables Dateiselektor- und *)
(* Alarmfeld als einfaches GEM-Beispiel.    *)

UNIT Demo5GUnit;

INTERFACE

USES GEM,DOS;

(* Deklaration des Objekttypen TFileSelector *)

TYPE PFileSelector=^TFileSelector;
	 TFileSelector=	OBJECT
					CONSTRUCTOR Init(NewPath:STRING);
					FUNCTION SelectFile(VAR Pathname:STRING):BOOLEAN;
					PRIVATE
					Path:STRING;
					Name:STRING;
					END;

(* Deklaration des Objekttypen TAlertbox *)

	 PAlertbox=^TAlertbox;
	 TAlertbox=	OBJECT
	 			CONSTRUCTOR Init(NDefault,Icon:INTEGER; Text,Buttons:STRING);
	 			FUNCTION Alert:INTEGER;
	 			PRIVATE
	 			Default:INTEGER;
	 			Textinfo:STRING[160];
	 			END;

CONST 	AlertNone=0;
		AlertNote=1;
		AlertWait=2;
		AlertStop=3;

IMPLEMENTATION

(* Implementation der Methoden von TFileSelector *)

CONSTRUCTOR TFileSelector.Init(NewPath:STRING);
BEGIN
Path:=NewPath;
Name:='';
END;

FUNCTION TFileSelector.SelectFile(VAR Pathname:STRING):BOOLEAN;
VAR Button,Test:INTEGER;
	SelDir:DirStr;
	SelName:NameStr;
	SelExt:ExtStr;
BEGIN
Test:=Fsel_Input(Path,Name,Button);
IF (Button=1) AND (Test<>0) THEN
	BEGIN
	FSplit(Path,SelDir,SelName,SelExt);
	PathName:=CONCAT(SelDir,Name);
	SelectFile:=TRUE
	END
ELSE SelectFile:=FALSE
END;

(* Implementation der Methoden von TAlertbox *)

CONSTRUCTOR TAlertbox.Init(NDefault,Icon:INTEGER; Text,Buttons:STRING);
BEGIN
TextInfo:=CONCAT('[',CHR(ORD('0')+Icon),'][',Text,'][',Buttons,']');
Default:=NDefault
END;

FUNCTION TAlertbox.Alert:INTEGER;
BEGIN
Alert:=Form_Alert(Default,TextInfo);
END;

END.
