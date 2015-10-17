MODULE DJ_Init;

(*
 * Ruft Xbios (30,32) auf, um nachtr„glich eingeschalteten HP DeskJet
 * ansprechen zu k”nnen, ohne neu zu booten.
 * Ist nur auf „lteren TOS-Versionen n”tig (auf 1.04, jedoch nicht auf 2.06)
 *)

(*$E MAC     Endung fr Linker: Datei mit Endung ACC erzeugen *)
(*$R-,S-     Keine Bereichs-, šberlauf- und Stackprfung *)

IMPORT XBIOS;
FROM SYSTEM IMPORT ADR;

IMPORT GEMEnv;
FROM AESEvents IMPORT MessageEvent, MessageBuffer, accOpen;
FROM AESMenus IMPORT RegisterAcc;
FROM PrgCtrl IMPORT Accessory;

VAR
  gemHdl: GEMEnv.GemHandle;
  menuID: CARDINAL;
  menuEntry: ARRAY[0..19] OF CHAR; (* must be global!! *)
  msg: MessageBuffer;
  done: BOOLEAN;

BEGIN
  GEMEnv.InitApplication (done);
  IF done THEN
    gemHdl:= GEMEnv.CurrGemHandle ();
    IF NOT Accessory () THEN
      (*
       * Started as normal program -> activate immediately
       *)
      XBIOS.GIOnBit (32);
    ELSE
      (*
       * Started as accessory -> wait for activation via gem-menu
       *)
      menuEntry:= '  DeskJet init';
      RegisterAcc(ADR(menuEntry), menuID , done);
      LOOP
        MessageEvent(msg);
        IF (msg.msgType = accOpen) THEN
          XBIOS.GIOnBit (32);
        END
      END               (* Endless loop! Accessories never terminate! *)
    END
  END
END DJ_Init.
