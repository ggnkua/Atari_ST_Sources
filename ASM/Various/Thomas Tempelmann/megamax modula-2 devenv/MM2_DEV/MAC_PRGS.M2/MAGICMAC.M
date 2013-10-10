MODULE MagiCMac;

(*
 * MagiCMac-Accessory
 *
 * MagiC-Pendant zu Mac-Kernelroutinen von MagiCMac.
 *
 * Autor:
 *  Thomas Tempelmann
 *)

(*
So funktioniert's:

Zuerst muû sich dieses Programm beim MagiCMac-Kernel anmelden
und dabei die Adresse einer Routine Åbergeben, die der Kernel
spÑter aufrufen wird.

Wenn MagiC in den Hintergrund geschaltet werden soll (z.B.
durch Cmd-W), wird dies in der Regel in einer Interrupt-
Routine des Kernels erkannt. Diese Intr-Routine wird aber
nur dann aktiv, wenn unter MagiC gerade keine Funktion
im Supervisor-Modus ausgefÅhrt wurde. So wird der aktuelle
MagiC-Anwenderprozeû unterbrochen. Um wieder Zeit an MagiC
abzugeben, wird zurÅck 

*)

(*$E MAC     Endung fÅr Linker: Datei mit Endung ACC erzeugen *)
(*$R-,S-     Keine Bereichs-, öberlauf- und StackprÅfung *)

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
  menuEntry: ARRAY[0..19] OF CHAR; (* must be global! *)
  msg: MessageBuffer;
  done: BOOLEAN;
  retButton: CARDINAL;

BEGIN
  GEMEnv.InitGem (GEMEnv.RC, devHdl, done);
  IF done THEN
    gemHdl:= GEMEnv.CurrGemHandle ();
    IF Accessory () THEN
      menuEntry:= '  MagiCMac Services';
      RegisterAcc(ADR(menuEntry), menuID , done);
    END;
    LOOP
      MessageEvent(msg);
      IF (msg.msgType = accOpen) THEN
        
      END
    END
  END
END MagiCMac.
