MODULE AccDemo;

    (*
     *               Demo program for an accessory
     *
     *           written by Andreas Pauletti 29.05.1988
     *                   with MEGAMAX MODULA-2
     *)

FROM SYSTEM IMPORT ADR;

IMPORT GEMEnv;
FROM AESForms IMPORT FormAlert;
FROM AESEvents IMPORT MessageEvent, MessageBuffer, accOpen;
FROM AESMenus IMPORT RegisterAcc;
FROM PrgCtrl IMPORT Accessory;
IMPORT AESMisc;


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
    Alert1 = '[1][This is the first alert box][other|QUIT]';
    Alert2 = '[1][This is the second alert box][other|QUIT]';

  BEGIN
    AESMisc.ShellWrite (TRUE, AESMisc.graphicPrgm, 'D:\GEP_ED.PRG', '');
  END DoTheWork;


BEGIN
  GEMEnv.InitGem(GEMEnv.RC, devHdl, done);
  IF done THEN
    gemHdl:= GEMEnv.CurrGemHandle ();
    IF NOT Accessory () THEN
      (*
       * Started as normal program -> activate immediately
       *)
      DoTheWork
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
            DoTheWork
          END
        END               (* Endless loop! Accessories never terminate! *)
      ELSE
        FormAlert(1, "Can't install AccDemo", retButton)
      END
    END
  END
END AccDemo.
