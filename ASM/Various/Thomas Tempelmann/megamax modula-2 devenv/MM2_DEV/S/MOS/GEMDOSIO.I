IMPLEMENTATION MODULE GEMDOSIO;
(*$B+,Y+,S-,M-,R-*)

(*
 * Treibermodul.
 *
 * Leitet alle Ein- und Ausgaben von 'InOut' auf 'Console'.
 *
 * NÑheres siehe Definitions-Text
 *)

FROM SYSTEM IMPORT WORD, LONGWORD, ADR, BYTE, ADDRESS;
IMPORT Console, InOutBase;
FROM Strings IMPORT Delete;
FROM MOSGlobals IMPORT MemArea;
FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

VAR ok: BOOLEAN;

PROCEDURE myReadLine (VAR s: ARRAY OF CHAR);
  BEGIN
    Console.ReadLine (s);
    Console.WriteLn
  END myReadLine;

PROCEDURE CondRead (VAR c: CHAR; VAR ok: BOOLEAN);
  BEGIN
    Console.BusyRead (c);
    ok:= c # 0C
  END CondRead;

PROCEDURE WritePg;
  BEGIN
    Console.Write (33C);
    Console.Write ('E')
  END WritePg;

PROCEDURE GotoXY (x,y: CARDINAL);
  BEGIN
    Console.Write (33C);
    Console.Write ('Y');
    Console.Write (CHR(y+32));
    Console.Write (CHR(x+32));
  END GotoXY;

PROCEDURE Open (x,y: CARDINAL);
  END Open;

PROCEDURE Close;
  END Close;

PROCEDURE GetInput ( VAR name: ARRAY OF CHAR );
  BEGIN
    myReadLine (name);
  END GetInput;

PROCEDURE GetOutput ( VAR name: ARRAY OF CHAR; VAR append: BOOLEAN );
  BEGIN
    myReadLine (name);
    append:= name[0] = '>';
    IF append THEN
      Delete (name,0,1,ok)
    END;
  END GetOutput;

PROCEDURE OpenError ( VAR msg: ARRAY OF CHAR; VAR retry: BOOLEAN );
  VAR c: CHAR;
  BEGIN
    Console.WriteLn;
    Console.WriteString ('Fehler beim ôffnen: ');
    Console.WriteString (msg);
    Console.WriteLn;
    Console.WriteString ('Nochmalige Eingabe ? (J/N) ');
    REPEAT
      Console.Read (c);
      c:= CAP (c)
    UNTIL (c='J') OR (c='N');
    retry:= c='J';
    Console.WriteLn;
  END OpenError;

PROCEDURE IOError ( VAR msg: ARRAY OF CHAR; input: BOOLEAN );
  VAR c: CHAR;
  BEGIN
    Console.WriteLn;
    Console.WriteString ('Fehler bei Datei');
    IF input THEN
      Console.WriteString ('eingabe: ')
    ELSE
      Console.WriteString ('ausgabe: ')
    END;
    Console.WriteString (msg);
    Console.WriteLn;
    Console.WriteString ('Datei wird geschlossen. Bitte Taste drÅcken. ');
    Console.FlushKbd;
    Console.Read (c);
    Console.WriteLn;
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
    pswap (InOutBase.Read, ADDRESS (Console.Read));
    pswap (InOutBase.Write, ADDRESS (Console.Write));
    pswap (InOutBase.OpenWdw, ADDRESS (Open));
    pswap (InOutBase.CloseWdw, ADDRESS (Close));
    pswap (InOutBase.KeyPressed, ADDRESS (Console.KeyPressed));
    pswap (InOutBase.CondRead, ADDRESS (CondRead));
    pswap (InOutBase.WriteLn, ADDRESS (Console.WriteLn));
    pswap (InOutBase.WritePg, ADDRESS (WritePg));
    pswap (InOutBase.WriteString, ADDRESS (Console.WriteString));
    pswap (InOutBase.ReadString, ADDRESS (myReadLine));
    pswap (InOutBase.GotoXY, ADDRESS (GotoXY));
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
END GEMDOSIO.
