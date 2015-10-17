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
IMPORT AESMisc, Strings, HdlError, EasyExceptions;

VAR
  devHdl: GEMEnv.DeviceHandle;
  gemHdl: GEMEnv.GemHandle;
  menuID: CARDINAL;
  menuEntry: ARRAY[0..19] OF CHAR; (* must be global!! *)
  msg: MessageBuffer;
  done: BOOLEAN;
  retButton: CARDINAL;

PROCEDURE DoTheWork;

  BEGIN
    AESMisc.ShellWrite (TRUE, AESMisc.graphicPrgm, "D:\GEP_ED.PRG", "");
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
      IF done THEN
        LOOP
          MessageEvent(msg);
          IF (msg.msgType = accOpen) THEN
            DoItSafely
          END
        END               (* Endless loop! Accessories never terminate! *)
      ELSE
        FormAlert(1, "[0][Can't install AccDemo][OK]", retButton);
        LOOP  (* dummy-loop *)
          MessageEvent(msg);
        END               (* Endless loop! Accessories never terminate! *)
      END
    END
  END
END AccDemo.
