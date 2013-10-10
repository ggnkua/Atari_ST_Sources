MODULE OwnState;
(*$E MOS *)
IMPORT GEMDOSIO;

IMPORT ModBase, ModCtrl (*, PathEnv*);
FROM InOut IMPORT Write, WriteString, WriteLn;

VAR dummy, name: ModBase.ModStr;
    ref: ModBase.ModRef;

PROCEDURE show (name: ARRAY OF CHAR);
  VAR st: [MIN (ModBase.ModState)..MAX (ModBase.ModState)];
  BEGIN
    WriteString (name);
    Write (':');
    WriteLn;
    IF ModBase.ModLoaded (name, FALSE, dummy, ref) THEN
      IF ref^.prevBSS = NIL THEN
        WriteString ('  prevBSS = NIL!');
        WriteLn;
      END;
      FOR st:= MIN (ModBase.ModState) TO MAX (ModBase.ModState) DO
        IF st IN ref^.state THEN
          WriteString ('  ');
          CASE st OF
            ModBase.linked: WriteString ('linked')|
            ModBase.loaded: WriteString ('loaded')|
            ModBase.loadImp: WriteString ('loadImp')|
            ModBase.installed: WriteString ('installed')|
            ModBase.instImp: WriteString ('instImp')|
            ModBase.mainMod: WriteString ('mainMod')|
            ModBase.running: WriteString ('running')|
            ModBase.initialized: WriteString ('initialized')|
            ModBase.firstCall: WriteString ('firstCall')|
            ModBase.program: WriteString ('program')|
            ModBase.procSym: WriteString ('procSym')|
            ModBase.crunched: WriteString ('crunched')|
            ModBase.dirty: WriteString ('dirty')|
            ModBase.reentrant: WriteString ('reentrant')|
            ModBase.msr1: WriteString ('msr1')|
            ModBase.msr2: WriteString ('msr2')|
          END;
          WriteLn
        END
      END
    ELSE
      WriteString ('  not loaded?!');
    END;
    WriteLn;
  END show;

BEGIN
  (*
  WriteString ('HomePath: '); WriteString (PathEnv.HomePath); WriteLn;
  *)
  WriteLn;
  ModCtrl.GetOwnName (name);
  show (name);
  show ('PathEnv');
END OwnState.
