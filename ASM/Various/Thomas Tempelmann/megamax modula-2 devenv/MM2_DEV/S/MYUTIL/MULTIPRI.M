MODULE MultiPrint;

(* Listet Text-Dateien.
 * 2 oder 3 Parameter beim Aufruf:
 *    - Ordnername mit Datei-Wildcard fÅr Auswahl der Dateien, z.B. "D:*.TXT"
 *    - Ausgabedateiname, z.B. "PRN:"
 *    - Wahlweise '@': Alle Texte sind Def-Module, öberschrift wird gedruckt.
 *)

IMPORT GEMDOSIO;
FROM InOut IMPORT WritePg, WriteString, Write, Read, FlushKbd, WriteLn,
KeyPressed;

FROM Strings IMPORT String, Concat, Split, Delete, PosLen, Space, Length,
                Compare, Relation;

FROM Directory IMPORT FileAttrSet, DirEntry, DirQuery;

FROM ArgCV IMPORT InitArgCV, PtrArgStr, ArgStr;

FROM Files IMPORT ResetState, State, Access, File, Open, Close, Create, replaceOld, EOF;

FROM Text IMPORT EOL;
IMPORT Text;

FROM StrConv IMPORT CardToStr;



CONST   Lines = 62;
        Columns = 80;
        head1 = 'B.';
        head2 = 'Anhang';
        head3 = head1 + " " + head2;
        
        ESC          = 33C;
        FF           = 14C;
        TAB          = 11C;
        UnderlineOn  = (* Brother: *) '&dD';
        UnderlineOff = (* Brother: *) '&d@';

VAR Pages: CARDINAL;

PROCEDURE Text_Write (f: File; s: CHAR);
  (*
   * Mit Timeout-Erkennung
   *)
  VAR ch: CHAR; l: LONGCARD;
  BEGIN
    LOOP
      Text.Write (f, s);
      IF State (f) < 0 THEN
        ResetState (f);
        l:= 0;
        LOOP
          INC (l);
          IF l = 20000 THEN
            EXIT
          END
        END;
        (*
        Write (CHR (7));
        WriteLn;
        WriteLn;
        WriteString ("*** Timeout ***");
        WriteLn;
        WriteLn;
        WriteString ('Taste zum weiterdrucken...');
        FlushKbd();
        l:= 0;
        LOOP
          IF KeyPressed () THEN EXIT END;
          INC (l);
          IF l = 4000 THEN
            Write (CHR (7));
            l:= 0
          END
        END;
        Read (ch);
        WriteLn;
        *)
      ELSE
        EXIT
      END
    END
  END Text_Write;

PROCEDURE Text_WriteString (f: File; REF s: ARRAY OF CHAR);
  VAR i: CARDINAL;
  BEGIN
    FOR i:= 0 TO HIGH (s) DO
      IF s[i] = 0C THEN RETURN END;
      Text_Write (f, s[i]);
    END;
  END Text_WriteString;

PROCEDURE Text_WriteLn (f: File);
  BEGIN
    Text_Write (f, CHR(13));
    Text_Write (f, CHR(10));
  END Text_WriteLn;


VAR printer: File;
    defMod : BOOLEAN;

PROCEDURE print ( REF path: ARRAY OF CHAR; dir: DirEntry ): BOOLEAN;
  
  VAR txt: File; c: CHAR; s,l,l2: String; ok: BOOLEAN; line: CARDINAL;
  
  BEGIN
    WriteLn;
    WriteString (dir.name);
    Concat ( path, dir.name, s, ok );
    
    IF defMod THEN
      Open ( txt, s, readSeqTxt );
      LOOP
        Text.ReadString ( txt, l );
        Text.ReadLn (txt);
        Split ( l, 18, l2, l, ok );
        IF Compare ( 'DEFINITION MODULE ', l2 ) = equal THEN
          Delete ( l, PosLen (';',l,0), 99, ok );
          EXIT
        END;
        IF EOF (txt) THEN
          HALT; (* Kein Definitionsmodul !? *)
          l:= '';
          EXIT
        END
      END;
      Close (txt)
    END;
    
    line:= 0;
    Open ( txt, s, readSeqTxt );
    WHILE ~EOF (txt) DO
      IF defMod & (line = 0) THEN (* Kopfzeile *)
        Text_WriteLn (printer);
        IF defMod THEN
          Text_Write (printer, ESC);
          (*
            Text_Write (printer, "!");
            Text_Write (printer, CHR(128));
          *)
          Text_WriteString (printer, UnderlineOn);
          IF ODD (Pages) THEN
            Text_WriteString (printer, head3);
            Text_WriteString (printer, Space (Columns-LENGTH(head3)-LENGTH(l)));
            Text_WriteString (printer, l);  (* Modulname *)
          ELSE
            Text_WriteString (printer, l);  (* Modulname *)
            Text_WriteString (printer, Space (Columns-LENGTH(head3)-LENGTH(l)));
            Text_WriteString (printer, head3);
          END;
          Text_Write (printer, ESC);
          Text_WriteString (printer, UnderlineOff);
          (*
            Text_Write (printer, "!");
            Text_Write (printer, CHR(0));
          *)
          
          (*
          Text_WriteString (printer, head1);
          Text_Write (printer, TAB);
          Text_WriteString (printer, l);  (* Modulname *)
          Text_WriteString (printer, Space (20-Length (l)));
          Text_Write (printer, TAB);
          Text_WriteString (printer, head2);
          *)
          Text_WriteLn (printer);
          Text_WriteLn (printer);
          Text_WriteLn (printer);
          line:= 4
        ELSE
          line:= 1
        END;
      END;
      Text.Read (txt, c);
      IF EOL (txt) & ~EOF (txt) THEN
        INC (line);
        IF defMod & (line > Lines) THEN
          INC (Pages);
          Text_Write (printer, FF);
          line:= 0
        ELSE
          Text_WriteLn (printer)
        END
      ELSE
        IF c='û' (* sz *) THEN c:= CHR (225) (* beta *) END;
        Text_Write (printer, c)
      END
    END;
    Close (txt);
    Text_Write (printer, FF);
    INC (Pages);
    
    RETURN TRUE
  END print;


VAR argc: CARDINAL;
    argv: ARRAY [0..3] OF PtrArgStr;
    err: INTEGER;
    inname, prname, dummy: String;

BEGIN
  Pages:= 1;
  WritePg;
  (*
  InitArgCV (argc, argv);
  defMod:= argv[3]^[0] = '@';
  *)
  defMod:= TRUE;
  inname:= 'c:\d\*.d';
  prname:= 'prn:';
  Create ( printer, prname, writeSeqTxt, replaceOld );
  (* Init. f. Laserjet:
  *)
  Text_Write (printer, ESC); Text_WriteString (printer, '&l0L');
  (* Fettschrift Laserjet: *)
  Text_Write (printer, ESC); Text_Write (printer, "E");
  DirQuery ( inname, FileAttrSet {}, print, err );
  Close ( printer );
  WriteLn;
  WriteString ('Total pages: ');
  WriteString (CardToStr (Pages, 0));
END MultiPrint.

(* $FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$000005DE$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EB$FFF954EBÄ$000015B1T.......T.T.....T.......T.......T.......T.......T.......T.......T.......T.......$000006A7$000005C5$00000567$00000582$0000059E$00000796$000015B1$000015F9$0000052E$00000512$00000285$FFEBF4AA$00001618$0000070E$00000BF4$000005D1†ÄÄ*)
