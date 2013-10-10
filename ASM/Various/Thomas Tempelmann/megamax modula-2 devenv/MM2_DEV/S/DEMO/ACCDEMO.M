MODULE AccDemo;

    (*
     *             Demo program for a 'safe' accessory
     *
     *           written by Andreas Pauletti 29.05.1988
     *                   with MEGAMAX MODULA-2
     *
     *
     * Thomas Tempelmann: Durch Abfrage mit der Funktion 'Accessory' kann
     * nun auch das Programm alternativ als Programm mit der Endung PRG
     * (statt ACC) direkt vom Desktop gestartet werden.
     *)

(*$E MAC     Endung fr Linker: Datei mit Endung ACC erzeugen *)
(*$R-,S-     Keine Bereichs-, šberlauf- und Stackprfung *)

FROM SYSTEM IMPORT ADR;

IMPORT GEMEnv;
FROM AESForms IMPORT FormAlert;
FROM AESEvents IMPORT MessageEvent, MessageBuffer, accOpen;
FROM AESMenus IMPORT RegisterAcc;
FROM PrgCtrl IMPORT Accessory;
IMPORT Strings, HdlError, EasyExceptions;

VAR
  devHdl: GEMEnv.DeviceHandle;
  gemHdl: GEMEnv.GemHandle;
  menuID: CARDINAL;
  menuEntry: ARRAY[0..19] OF CHAR; (* must be global!! *)
  msg: MessageBuffer;
  done: BOOLEAN;
  retButton: CARDINAL;

PROCEDURE DoTheWork;

  CONST
    Alert1 = '[1][This is the first alert box| |    ERROR will raise|    an exception as|    a demonstration][OTHER|ERROR|QUIT]';
    Alert2 = '[1][This is the second alert box][OTHER|QUIT]';

  VAR d,c: CARDINAL;

  BEGIN
    LOOP
      FormAlert(1, Alert1, retButton);
      IF retButton = 3 THEN
        EXIT
      ELSIF retButton = 2 THEN
        (* generate an error to demonstrate the use of 'EasyException.Call' *)
        c:= 0;
        c:= d DIV c; (* causes a 'division by zero' exception *)
      END;
      FormAlert (1, Alert2, retButton);
      IF retButton = 2 THEN
        EXIT
      END
    END
  END DoTheWork;


PROCEDURE DoItSafely;

  VAR excResult: EasyExceptions.Exception;
      msg: ARRAY [0..99] OF CHAR;
      ok: BOOLEAN;

  BEGIN
    EasyExceptions.Call (DoTheWork, excResult);
    IF excResult # EasyExceptions.NormalReturn () THEN
      HdlError.GetErrorMsg (EasyExceptions.StdErrNo (excResult), msg);
      Strings.Insert ("[0][There was an error:|", 0, msg, ok);
      Strings.Append ("|But the system did not crash][Great!]", msg, ok);
      FormAlert(1, msg, retButton)
    END
  END DoItSafely;

BEGIN
  GEMEnv.InitGem (GEMEnv.RC, devHdl, done);
  IF done THEN
    gemHdl:= GEMEnv.CurrGemHandle ();
    IF NOT Accessory () THEN
      (*
       * Started as normal program -> activate immediately
       *)
      DoItSafely
    ELSE
      (*
       * Started as accessory -> wait for activation via gem-menu
       *)
      menuEntry:= '  Accessory Demo';
      RegisterAcc(ADR(menuEntry), menuID , done);
      IF NOT done THEN
        FormAlert(1, "[0][Can't install AccDemo][OK]", retButton)
      END;
      LOOP
        MessageEvent(msg);
        IF (msg.msgType = accOpen) THEN
          DoItSafely
        END
      END               (* Endless loop! Accessories never terminate! *)
    END
  END
END AccDemo.
