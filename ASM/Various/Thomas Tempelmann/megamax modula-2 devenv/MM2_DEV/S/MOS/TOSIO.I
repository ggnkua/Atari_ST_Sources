IMPLEMENTATION MODULE TOSIO;
(*$B+,Y+,S-,M-,R-*)

(*
 * Treibermodul.
 *
 * NÑheres siehe Definitions-Text
 *
 * Durch Setzen von 'ConfirmClose' auf TRUE wird erreicht, daû
 * beim Ende des damit gelinkten Programms auf einen Tastendruck
 * gewartet wird.
 *)

FROM SYSTEM IMPORT WORD, LONGWORD, ADR, BYTE, ADDRESS;
IMPORT Terminal, InOutBase;
FROM Strings IMPORT Delete;
FROM MOSGlobals IMPORT MemArea;
FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

CONST
  ConfirmClose = FALSE;  (* TRUE -> Bei Prg-Ende wird auf Taste gewartet *)


VAR ok: BOOLEAN; c: CHAR;
    waitAtEnd: BOOLEAN;

PROCEDURE Open (x,y: CARDINAL);
  BEGIN
    waitAtEnd:= FALSE;
  END Open;

PROCEDURE Close;
  BEGIN
    IF waitAtEnd & ConfirmClose THEN
      (*
       * Am Programmende auf Tastendruck warten,
       * wenn zuletzt Ausgaben gemacht wurden, die sonst nicht mehr
       * gesehen wÅrden.
       *)
      waitAtEnd:= FALSE;
      Terminal.Read (c)
    END
  END Close;

PROCEDURE Read (VAR c: CHAR);
  BEGIN
    waitAtEnd:= FALSE;
    Terminal.Read (c)
  END Read;

PROCEDURE Write (c: CHAR);
  BEGIN
    waitAtEnd:= TRUE;
    Terminal.Write (c)
  END Write;

PROCEDURE ReadString (VAR c:ARRAY OF CHAR);
  BEGIN
    waitAtEnd:= FALSE;
    Terminal.ReadString (c);
    Terminal.WriteLn
  END ReadString;

PROCEDURE WriteString (REF s: ARRAY OF CHAR);
  BEGIN
    waitAtEnd:= TRUE;
    Terminal.WriteString (s)
  END WriteString;

PROCEDURE GetInput ( VAR name: ARRAY OF CHAR );
  BEGIN
    ReadString (name);
  END GetInput;

PROCEDURE GetOutput ( VAR name: ARRAY OF CHAR; VAR append: BOOLEAN );
  BEGIN
    ReadString (name);
    append:= name[0] = '>';
    IF append THEN
      Delete (name,0,1,ok)
    END;
  END GetOutput;

PROCEDURE OpenError ( VAR msg: ARRAY OF CHAR; VAR retry: BOOLEAN );
  VAR c: CHAR;
  BEGIN
    Terminal.WriteLn;
    Terminal.WriteString ('Fehler beim ôffnen: ');
    Terminal.WriteString (msg);
    Terminal.WriteLn;
    Terminal.WriteString ('Nochmalige Eingabe ? (J/N) ');
    REPEAT
      Terminal.BusyRead (c);
      c:= CAP (c)
    UNTIL (c='J') OR (c='N');
    retry:= c='J';
    Terminal.WriteLn;
  END OpenError;

PROCEDURE IOError ( VAR msg: ARRAY OF CHAR; input: BOOLEAN );
  VAR c: CHAR;
  BEGIN
    Terminal.WriteLn;
    Terminal.WriteString ('Fehler bei Datei');
    IF input THEN
      Terminal.WriteString ('eingabe: ')
    ELSE
      Terminal.WriteString ('ausgabe: ')
    END;
    Terminal.WriteString (msg);
    Terminal.WriteLn;
    Terminal.WriteString ('Datei wird geschlossen. Bitte Taste drÅcken. ');
    Terminal.FlushKbd;
    REPEAT
      Terminal.BusyRead (c);
    UNTIL c#0C;
    Terminal.WriteLn;
  END IOError;


VAR pbuf: ARRAY [0..14] OF LONGWORD; pidx: CARDINAL;


PROCEDURE pset (f:BOOLEAN);
  PROCEDURE pswap (VAR l:LONGWORD; v:LONGWORD);
    (*$R+*)
    BEGIN
      IF f THEN pbuf [pidx]:= l; l:= v ELSE l:= pbuf [pidx] END;
      INC (pidx)
    END pswap;
    (*$R=*)
  BEGIN
    pidx:= 0;
    pswap (InOutBase.Read, ADDRESS (Read));
    pswap (InOutBase.Write, ADDRESS (Write));
    pswap (InOutBase.OpenWdw, ADDRESS (Open));
    pswap (InOutBase.CloseWdw, ADDRESS (Close));
    pswap (InOutBase.KeyPressed, ADDRESS (Terminal.KeyPressed));
    pswap (InOutBase.CondRead, ADDRESS (Terminal.CondRead));
    pswap (InOutBase.WriteLn, ADDRESS (Terminal.WriteLn));
    pswap (InOutBase.WritePg, ADDRESS (Terminal.WritePg));
    pswap (InOutBase.WriteString, ADDRESS (WriteString));
    pswap (InOutBase.ReadString, ADDRESS (ReadString));
    pswap (InOutBase.GotoXY, ADDRESS (Terminal.GotoXY));
    pswap (InOutBase.GetInput, ADDRESS (GetInput));
    pswap (InOutBase.GetOutput, ADDRESS (GetOutput));
    pswap (InOutBase.OpenError, ADDRESS (OpenError));
    pswap (InOutBase.IOError, ADDRESS (IOError));
  END pset;

PROCEDURE restore;
  BEGIN
    pset (FALSE) (* Wiederherstellen der alten PROC-Werte *)
  END restore;

VAR tc: RemovalCarrier; st: MemArea;

BEGIN
  CatchRemoval (tc, restore, st);
  pset (TRUE)   (* Retten der alten PROC-Werte und Setzen der Neuen *)
END TOSIO.
