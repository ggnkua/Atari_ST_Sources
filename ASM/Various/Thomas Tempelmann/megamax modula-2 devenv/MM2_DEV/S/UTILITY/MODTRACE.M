MODULE ModTrace;
(*$Y+*)

(*
 * Wird das Programm gestartet, bleibt es resident und zeigt von da an
 * alle dazugeladenen Module an.
 * Kann durch erneuten Start oder verlassen der Shell wieder deaktiviert
 * werden.
 *)

FROM SYSTEM IMPORT ADDRESS;

FROM Loader IMPORT Loading, LoadingProc;

FROM ModCtrl IMPORT InstallModule, ReleaseModule, FirstModuleStart;

FROM MOSGlobals IMPORT MemArea;

FROM AESForms IMPORT FormAlert;

FROM Strings IMPORT Append, Copy, Concat;

FROM StrConv IMPORT LHexToStr;


VAR oldV: LoadingProc;
    wsp: MemArea;


PROCEDURE show ( REF modname, filename: ARRAY OF CHAR;
                 code: ADDRESS; clen: LONGCARD;
                 var : ADDRESS; vlen: LONGCARD );
  
  VAR s1,s2: ARRAY [0..127] OF CHAR; button: CARDINAL; ok: BOOLEAN;
  
  BEGIN
    Copy ( modname, 0, 27, s2, ok );
    Concat ( '[0][Lade ', s2, s1, ok );
    Append ( '|(', s1, ok );
    Copy ( filename, 0, 30, s2, ok );
    Append ( s2, s1, ok );
    Append ( ')|Code: ', s1, ok );
    Append ( LHexToStr (code,7), s1, ok );
    Append ( '][Weiter]', s1, ok );
    FormAlert ( 1, s1, button )
  END show;


PROCEDURE restore;
  BEGIN
    Loading:= oldV
  END restore;


VAR button: CARDINAL;

BEGIN
  IF FirstModuleStart () THEN
    oldV:= Loading;
    Loading:= show;
    wsp.bottom:= NIL;
    InstallModule (restore,wsp);
    FormAlert ( 1, '[0][ModTrace aktiviert][ OK ]', button )
  ELSE
    restore;
    ReleaseModule;
    FormAlert ( 1, '[0][ModTrace deaktiviert][ OK ]', button )
  END
END ModTrace.
