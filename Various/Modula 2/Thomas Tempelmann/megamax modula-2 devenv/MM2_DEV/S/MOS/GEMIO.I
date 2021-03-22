IMPLEMENTATION MODULE GEMIO;
(*$B+,Y+,S-,R-*)

(*
 * Treibermodul.
 *
 * Leitet alle Ein- und Ausgaben von 'InOut' und der Unit 'CON:' auf
 * ein Window von 'TextWindows'.
 *
 * Durch Setzen von 'ConfirmClose' auf TRUE wird erreicht, daž
 * beim Ende des damit gelinkten Programms auf eine Taste gewartet
 * wird, bevor der Fensterinhalt verschwindet.
 *
 * Die Gr”že des "StdIO"-Fenster, das von 'InOut' erzeugt wird, kann frei
 * gew„hlt werden, indem die Konstanten 'StdX' und 'StdY' (s.u.) ver„ndert
 * werden. Dann ist dies Modul zu compilieren und ggf. auch die Shell neu
 * zu linken.
 *
 * N„heres siehe Definitions-Text
 *)


FROM SYSTEM IMPORT WORD, LONGWORD, ADDRESS, CAST, ADR, ASSEMBLER;
IMPORT TextWindows, InOutBase, FileBase;
FROM MOSGlobals IMPORT MemArea, OutOfMemory;
FROM AESForms IMPORT FormAlert;
FROM Strings IMPORT Delete, Concat, Append;
FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;


CONST
  StdX = 80;              (* Zeichenbreite des InOut-Fensters *)
  StdY = 25;              (* Zeilenanzahl des InOut-Fensters *)
  ConfirmClose = FALSE;   (* TRUE -> Bei Prg-Ende wird auf Taste gewartet *)


VAR conOp, ioOp, ok: BOOLEAN;
    waitAtEnd: BOOLEAN;
    opened: CARDINAL;
    window: TextWindows.Window;


PROCEDURE chkWdw;
  BEGIN
    IF ~ok THEN
      (*
        RaiseError (OutOfMemory,'Kein Fenster mehr frei.',selfCaused,mustAbort)
      *)
      ASSEMBLER
        TRAP    #6
        DC.W    OutOfMemory-$A000
        ACZ     'Kein Fenster mehr frei.'
      END
    END
  END chkWdw;

PROCEDURE close;
  VAR c: CHAR;
  BEGIN
    IF opened > 0 THEN
      DEC (opened);
      IF opened = 0 THEN
        IF waitAtEnd & ConfirmClose THEN
          (* Am Programmende auf Tastendruck warten *)
          TextWindows.Read (window, c);
        END;
        TextWindows.Close (window)
      END
    END;
  END close;

PROCEDURE ioClose;
  BEGIN
    ioOp:= FALSE;
    IF ~conOp THEN close END;
  END ioClose;


PROCEDURE open (x,y: CARDINAL);
  BEGIN
    IF opened = 0 THEN
      IF x=0 THEN x:= StdX END;
      IF y=0 THEN y:= StdY END;
      TextWindows.Open (window,x,y,TextWindows.WQualitySet{TextWindows.movable,
                        TextWindows.dynamic,TextWindows.titled},
                        TextWindows.noHideWdw, TextWindows.noForce,
                        'StdIO', -1,-1,-1,-1, ok);
      waitAtEnd:= FALSE;
      chkWdw
    END;
    INC (opened)
  END open;

PROCEDURE ioOpen (x,y: CARDINAL);
  BEGIN
    open (x,y);
    ioOp:= TRUE;
  END ioOpen;


PROCEDURE Read (VAR c:CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        CLR     waitAtEnd       ; waitAtEnd:= FALSE
        MOVE.L  -(A3),D0
        MOVE.L  window,(A3)+
        MOVE.L  D0,(A3)+
        JMP     TextWindows.Read
    END
  END Read;
  (*$L=*)

PROCEDURE Write(c:CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    #1,waitAtEnd    ; waitAtEnd:= TRUE
        MOVE.W  -(A3),D0
        MOVE.L  window,(A3)+
        MOVE.W  D0,(A3)+
        JMP     TextWindows.Write
    END
  END Write;
  (*$L=*)

PROCEDURE CondRead (VAR c:CHAR;VAR b:BOOLEAN);
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     TextWindows.CondRead
    END
  END CondRead;
  (*$L=*)

PROCEDURE KeyPressed ():BOOLEAN;
  (*$L-*)
  BEGIN
    ASSEMBLER
        JMP     TextWindows.KeyPressed
    END
  END KeyPressed;
  (*$L=*)

PROCEDURE WriteLn;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  window,(A3)+
        JMP     TextWindows.WriteLn
    END
  END WriteLn;
  (*$L=*)

PROCEDURE WritePg;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  window,(A3)+
        JMP     TextWindows.WritePg
    END
  END WritePg;
  (*$L=*)

PROCEDURE GotoXY (x,y:CARDINAL);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D0
        MOVE.L  window,(A3)+
        MOVE.L  D0,(A3)+
        JMP     TextWindows.GotoXY
    END
  END GotoXY;
  (*$L=*)

PROCEDURE ReadString (VAR c:ARRAY OF CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        CLR     waitAtEnd       ; waitAtEnd:= FALSE
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),D0
        MOVE.L  window,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.W  D1,(A3)+
        JSR     TextWindows.ReadString
        MOVE.L  window,(A3)+
        JMP     TextWindows.WriteLn
    END
  END ReadString;
  (*$L=*)

PROCEDURE WriteString (REF c:ARRAY OF CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    #1,waitAtEnd    ; waitAtEnd:= TRUE
        MOVE.W  -(A3),D1
        MOVE.L  -(A3),D0
        MOVE.L  window,(A3)+
        MOVE.L  D0,(A3)+
        MOVE.W  D1,(A3)+
        JMP     TextWindows.WriteString
    END
  END WriteString;
  (*$L=*)

(*
PROCEDURE openAskWdw ( VAR wdw: TextWindows.Window );
  BEGIN
    TextWindows.Open (wdw,34,7,TextWindows.WQualitySet{TextWindows.titled},
                      TextWindows.noHideWdw,TextWindows.forceCursor,
                      'E/A Umleitung', -1,-1,-1,-1, ok);
    chkWdw
  END openAskWdw;
*)

PROCEDURE GetInput ( VAR name: ARRAY OF CHAR );
  VAR wdw: TextWindows.Window;
  BEGIN
    (*
      openAskWdw (wdw);
      TextWindows.WriteString (wdw, 'Eingabedatei:');
      TextWindows.WriteLn (wdw);
      TextWindows.Write (wdw, '<');
    *)
    ReadString (name);
    (*
      TextWindows.Close (wdw)
    *)
  END GetInput;

PROCEDURE GetOutput ( VAR name: ARRAY OF CHAR; VAR append: BOOLEAN );
  VAR wdw: TextWindows.Window;
  BEGIN
    (*
      openAskWdw (wdw);
      TextWindows.WriteString (wdw, 'Ausgabedatei:');
      TextWindows.WriteLn (wdw);
      TextWindows.Write (wdw, '>');
    *)
    ReadString (name);
    append:= name[0] = '>';
    IF append THEN
      Delete (name,0,1,ok)
    END;
    (*
      TextWindows.Close (wdw)
    *)
  END GetOutput;

PROCEDURE OpenError ( VAR msg: ARRAY OF CHAR; VAR retry: BOOLEAN );
  VAR txt: ARRAY [0..89] OF CHAR;
      but: CARDINAL;
  BEGIN
    Concat ('[0][Fehler beim ™ffnen:|',msg,txt,ok);
    Append ('|Nochmalige Eingabe ?][ Ja |Nein]',txt,ok);
    FormAlert (1,txt,but);
    retry:= but=1
  END OpenError;

PROCEDURE IOError ( VAR msg: ARRAY OF CHAR; input: BOOLEAN );
  VAR txt: ARRAY [0..99] OF CHAR;
      but: CARDINAL;
  BEGIN
    txt:= '[0][Fehler bei Datei';
    IF input THEN
      Append ('eingabe:|',txt,ok)
    ELSE
      Append ('ausgabe:|',txt,ok)
    END;
    Append (msg,txt,ok);
    Append ('|Datei wird geschlossen][ OK ]',txt,ok);
    FormAlert (1,txt,but)
  END IOError;


PROCEDURE conOpen (VAR hdl:LONGWORD; name: ARRAY OF CHAR): INTEGER;
  BEGIN
    open (80,25);
    conOp:= TRUE;
    hdl:= CAST (LONGWORD,window);
    RETURN 0
  END conOpen;

PROCEDURE conClose (hdl:LONGWORD): INTEGER;
  BEGIN
    conOp:= FALSE;
    IF ~ioOp THEN close END;
    RETURN 0
  END conClose;

PROCEDURE conOut ( hdl: LONGWORD; ad:ADDRESS; VAR l:LONGCARD ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  (A0),D0
        BEQ     e0
        ; mehr als 64 KB Text wird's wohl nicht sein...
        SUBQ    #1,D0
        MOVE    D0,(A3)+
        JSR     TextWindows.WriteString
        CLR     (A3)+           ; RETURN 0
        RTS
    e0  SUBQ.L  #8,A3
        CLR     (A3)+           ; RETURN 0
    END
  END conOut;
  (*$L=*)


PROCEDURE conStrOut ( hdl: LONGWORD; REF str: ARRAY OF CHAR ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        JSR     TextWindows.WriteString
        CLR     (A3)+           ; RETURN 0
    END
  END conStrOut;
  (*$L=*)


PROCEDURE conIn ( hdl: LONGWORD; ad:ADDRESS; VAR l:LONGCARD ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEM.L D4/A4,-(A7)
        MOVE.L  -(A3),A0
        MOVE.L  (A0),D4
        MOVE.L  -(A3),A4
        SUBQ.L  #4,A3
        BRA     st
       lo:
        MOVE.L  A4,(A3)+
        CLR     -(A7)
        MOVE.L  A7,(A3)+
        JSR     TextWindows.CondRead
        TST     (A7)+
        BEQ     lo
       st:
        DBRA    D4,lo
        MOVEM.L (A7)+,D4/A4
        CLR     (A3)+
    END
  END conIn;
  (*$L=*)

PROCEDURE conCIn ( hdl: LONGWORD ): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A3
        CLR     -(A7)
       lo:
        MOVE.L  A7,(A3)+
        CLR     -(A7)
        MOVE.L  A7,(A3)+
        JSR     TextWindows.CondRead
        TST     (A7)+
        BEQ     lo
        MOVEQ   #0,D0
        MOVE.B  (A7)+,D0
        MOVE    D0,(A3)+
    END
  END conCIn;
  (*$L=*)


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
    pswap (InOutBase.Read, Read);
    pswap (InOutBase.Write, Write);
    pswap (InOutBase.OpenWdw, ioOpen);
    pswap (InOutBase.CloseWdw, ioClose);
    pswap (InOutBase.KeyPressed, KeyPressed);
    pswap (InOutBase.CondRead, CondRead);
    pswap (InOutBase.WriteLn, WriteLn);
    pswap (InOutBase.WritePg, WritePg);
    pswap (InOutBase.WriteString, WriteString);
    pswap (InOutBase.ReadString, ReadString);
    pswap (InOutBase.GotoXY, GotoXY);
    pswap (InOutBase.GetInput, GetInput);
    pswap (InOutBase.GetOutput, GetOutput);
    pswap (InOutBase.OpenError, OpenError);
    pswap (InOutBase.IOError, IOError)
  END pset;

PROCEDURE restore;
  BEGIN
    pset (FALSE) (* Wiederherstellen der alten PROC-Werte *)
  END restore;

VAR tc: RemovalCarrier; st: MemArea;

BEGIN
  opened:= 0;
  CatchRemoval (tc, restore, st);
  pset (TRUE);  (* Retten der alten PROC-Werte und Setzen der Neuen *)

  (*** Einrichten der Unit 'CON:' als Window ***)
  WITH FileBase.UnitDriver [FileBase.con] DO
    (* šbernahme der Standard-Einstellungen (FileBase):
      valid:= TRUE;
      name:= 'CON:';
      input:= TRUE;
      output:= TRUE;
    *)
    initHdl:= CAST (LONGWORD, NIL);
    open:= conOpen;
    close:= conClose;
    wrData:= conOut;
    rdData:= conIn;
    wrStr:= conStrOut;
    rdChr:= conCIn;
  END;
END GEMIO.
