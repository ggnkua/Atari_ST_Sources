MODULE PrtSer;

(* Bedruckt Disk-Aufkleber fÅr M-2 *)

FROM Strings IMPORT String, Concat, Split, Delete, PosLen, Space, Length,
                Compare, Relation;

FROM Files IMPORT Access, File, Open, Close, EOF;

IMPORT Text, NumberIO;

FROM InOut IMPORT WriteString, WriteLn, Read, BusyRead, ReadCard, Done, GotoXY,
        WriteCard;


CONST   spc1 = 50;
        spc2 = 100;
        
        ESC          = 33C;
        FF           = 14C;
        UnderlineOn  = '&dD';
        UnderlineOff = '&d@';


VAR printer: File;

PROCEDURE line (n:CARDINAL);
  BEGIN
    WHILE n>0 DO Text.WriteLn (printer); DEC (n) END
  END line;

PROCEDURE spc (n:CARDINAL);
  BEGIN
    Text.Write (printer,15C);
    WHILE n>0 DO Text.Write (printer, ' '); DEC (n) END
  END spc;

PROCEDURE print;
  VAR n, von, bis: CARDINAL; ch:CHAR;
  BEGIN
    WriteLn;
    WriteString ('  Druckprogramm fÅr Modula-2 Diskettenaufkleber');
    WriteLn;
    WriteLn;
    WriteString ('Start bei Seriennummer: ');
    ReadCard (von);
    IF ~Done THEN RETURN END;
    WriteLn;
    WriteString ('Ende bei Seriennummer : ');
    ReadCard (bis);
    IF ~Done THEN RETURN END;
    WriteLn;
    WriteLn;
    WriteString ('Aufkleber einlegen und RETURN drÅcken (ESC fÅr Abbruch).');
    WriteLn;
    LOOP
      Read (ch);
      IF ch=CHR(13) THEN EXIT
      ELSIF ch=33C THEN RETURN END;
    END;
    FOR n:= von TO bis DO
      BusyRead (ch);
      IF ch=33C THEN RETURN END;
      GotoXY (0,10);
      WriteString ('Drucke Nr. ');
      WriteCard (n,4);
      
      line (11);
      spc (spc1);
      Text.WriteString (printer, 'Shell');
      spc (spc2);
      Text.WriteString (printer, 'Linker');
      line (1);
      spc (spc1);
      Text.WriteString (printer, 'Compiler');
      spc (spc2);
      Text.WriteString (printer, 'RCP');
      line (1);
      spc (spc1);
      Text.WriteString (printer, 'Editor');
      
      line (2);
      spc (21);
      Text.WriteString (printer, 'Serien-Nr. ');
      NumberIO.WriteCard (printer, n,0);
      
      line (14);
      spc (spc1);
      Text.WriteString (printer, 'Bootdisk');
      spc (spc2);
      Text.WriteString (printer, 'Sources');
      
      Text.Write (printer, FF);
    END;
  END print;

BEGIN
  Open ( printer, 'PRN:', writeSeqTxt );
  print;
  Close ( printer )
END PrtSer.

(* $FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$00000284$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470$FFF95470Ä$000007DET.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000845$000007CF$00000845$0000072A$0000089A$00000845$00000645$00000835$000007BB$00000835$00000828$0000081F$000007F4$000007DE$00000845$000007CDåÄÄ*)
