MODULE Oberon;


IMPORT
  S:=SYSTEM, Cookie, GEMDOS, Error, Sys, Str:=Strings, Form,
  Storage, IO:=ChatIO, Task, Env:=Environment, CommandLine,
  FN:=Filename, Fsel, StdPath, OLDPar, O2Modules, Halt,
  LTLHalt, LTLProgram;


CONST

(* CL_INIT: Diese Nachricht muž Chatwin nach dem Start an den Lader
 * schicken, damit er die Adresse der Kommunikationsprozedur erh„lt.
 *)
CLINIT		= 6500H;
(*
 * Word[1] = Oberes Wort des Zeigers auf die Kommunikationsprozedur
 * Word[2] = Unteres Wort des Zeigers
 *)

(* CL_COMMAND: Diese Nachricht teilt dem Lader mit, daž ein Kommando
 * vorliegt, daž den Start eines Moduls erfordert.
 *)
CLCOMMAND	= 6501H;
(*
 * Word[1] = Oberes Wort des Zeigers auf das gesamte Kommando,
 * Null-terminiert
 * Word[2] = Unteres Wort des Zeigers auf das Kommando
 * Word[4] = Oberes Wort des Zeigers auf das Environment
 * Word[5] = Unteres Wort des Zeigers auf das Environment
 *)

(* CL_TIME: Diese Nachricht schickt Chatwin an den Lader, wenn keine
 * Eingaben des Benutzers vorliegen.
 *)
CLTIME		= 6502H;
(*
 *)

(* LC_WRCHAR: Diese Nachricht schickt der Lader an Chatwin, um ein Zeichen
 * auf der Console auszugeben.
 *)
LCWRCHAR	= 6503H;
(*
 * Word[3] = Char
 *)

(* LC_WRSTR: Wird an Chatwin geschickt, um einen 0-terminierten String
 * auf dem Consolefenster auszugeben.
 *)
LCWRSTR		= 6504H;
(*
 * Word[1] = Oberes Wort des Zeigers auf den String, Null-terminiert
 * Word[2] = Unteres Wort des Zeigers auf den String
 *)

(* LC_OUTBUF: Weist Chatwin an, den Zeichenpuffer auf dem Consolerfenster
 * auszugeben.
 *)
LCOUTBUF	= 6505H;
(*
 *)

(* LC_CLOSEWIN: weist Chatwin an, alle seine momentan offenen Fenster
 * zu schliežen. Dies wird nach einem Modulstart ben”tigt, um bei GEM-
 * Programmen die Fenster zu schliežen.
 *)
LCCLOSEWIN = 6506H;
(*
 * keine Parameter
 *)

(* LC_OPENWIN: weist Chatwin an, alle Fenster wieder zu ”ffnen, die
 * vorher mit LC_CLOSEWIN geschlossen wurden. Diese Nachricht kommt
 * nachdem ein GEM-Modul beendet wurde.
 *)
LCOPENWIN = 6507H;
(*
 * keine Parameter
 *)


TYPE
  msg    = RECORD
             Type : INTEGER;
             Ptr  : S.PTR;
             Char : INTEGER;
             Env  : S.PTR;
           END;
  msgptr = POINTER TO msg;


VAR
  MyStack : S.PTR;
  defStart : FN.path;


PROCEDURE CloseWindows;
  VAR Msg : msg;
 BEGIN
  IF IO.SendMsg # NIL THEN
    Msg.Type := LCCLOSEWIN; IO.SendMsg( S.ADR( Msg));
  END;
 END CloseWindows;


PROCEDURE OpenWindows;
  VAR Msg : msg;
 BEGIN
  IF IO.SendMsg # NIL THEN
    Msg.Type := LCOPENWIN; IO.SendMsg( S.ADR( Msg));
  END;
 END OpenWindows;


PROCEDURE CallModule*(VAR Command : ARRAY OF CHAR);
  VAR
    i,j : INTEGER;
    ModName,ProcName : ARRAY 30 OF CHAR;
    s,path : FN.path;
    Mod : O2Modules.Module;
    Proc : O2Modules.Command;
 BEGIN
  OLDPar.Init;
  O2Modules.importsIO := FALSE;
  i := 0;
  WHILE (Command[i] = " ") DO INC(i) END;
  j := 0;
  WHILE (Command[i] >= "0") DO
    ModName[j] := Command[i]; INC(i); INC(j)
  END;
  ModName[j] := 0X; j := 0;
  FN.GetPath( ModName, path);
  StdPath.Set( path);
  IF Command[i] = "." THEN
    INC(i);
    WHILE (Command[i] >= "0") DO
      ProcName[j] := Command[i]; INC(i); INC(j)
    END;
    ProcName[j] := 0X;
  ELSE
    ProcName := "Run";
  END;
  WHILE (Command[i] = " ") DO INC(i) END;
  j := 0;
  WHILE Command[i] # 0X DO
    Sys.Basepage.Command[j] := Command[i]; INC(i); INC(j)
  END;
  Sys.Basepage.Command[j] := 0X; Sys.Basepage.ComLen := SHORT(j);
  CommandLine.Reset;
  Mod := O2Modules.Load(ModName);
  IF Mod = NIL THEN
    IO.WriteString( "Module "); IO.WriteString( ModName);
    IO.WriteString( " could not be loaded."); IO.WriteLn;
  ELSIF ProcName # "" THEN
    Proc := O2Modules.GetCommand(Mod, ProcName);
    IF Proc = NIL THEN
      IO.WriteString( "Procedure "); IO.WriteString( ProcName);
      IO.WriteString( " not found."); IO.WriteLn;
    ELSE
      Proc;
    END;
  END;
 END CallModule;


PROCEDURE RecMsg(Msg : msgptr) : INTEGER;
(*
 receives a message in Msg and executes it
 *)
  VAR p : Str.ptr;
 BEGIN
  Task.Init; S.PUTREG( 15, MyStack);
  IF Msg.Type = CLINIT THEN
    IO.SendMsg := S.VAL(IO.cproc, Msg.Ptr);
    IO.WriteString("Oberon load time linking installed. (c) Stephan Junker  ");
    IO.WriteString( Sys.compDate);
    IO.WriteLn;
    Cookie.Delete( "OBNL");
  ELSIF Msg.Type = CLCOMMAND THEN
    p := Msg.Ptr; Sys.Basepage.Env := Msg.Env;
    CallModule(p^);
  ELSIF Msg.Type = CLTIME THEN
  END;
  Task.Exit(0);
 END RecMsg;


PROCEDURE Start;
  VAR
    d : INTEGER; d2 : LONGINT;
    ext : FN.ext;
    path : FN.path;
 BEGIN
  IF Cookie.Enter("OBNL", S.ADR(RecMsg) ) THEN
    S.GETREG( 15, MyStack); DEC( MyStack, 100);
    IF CommandLine.arg # NIL THEN
      COPY( CommandLine.arg^, defStart)
    ELSIF NOT Env.ReadStr("DEFSTART", defStart) THEN
      path := "*.*"; defStart[0] := 0X;
      IF NOT Fsel.ExInput( path, defStart, "Execute") THEN
        defStart[0] := 0X
      END;
    END;
    IF defStart[0] # 0X THEN
      FN.GetPath( defStart, path);
      StdPath.Set( path);
      d2 := GEMDOS.Pexec( 0, S.ADR(""), S.ADR(defStart), 0);
      IF d2 < 0 THEN
        Error.NumStrOut(SHORT(d2), defStart)
      END;
      StdPath.Set( StdPath.stdPath);
    END;
    Cookie.Delete( "OBNL");
  ELSE
    d := Form.Alert( 1, "[1][Cookie could not be entered][Cancel]");
  END;
 END Start;


BEGIN
  Start;
  Task.Exit(0)
END Oberon.