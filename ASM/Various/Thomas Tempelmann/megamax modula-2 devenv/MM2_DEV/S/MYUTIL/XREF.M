(*---------------------------------------------------------------------*)
(*---                     Module Cross Reference Generator          ---*)
(*---                    ---------------------------------          ---*)
(*---                                                               ---*)
(*---   XREF aus 4th Edition WIRTH Seite 88                         ---*)
(*---                                                               ---*)
(*--- Programmiersprache :  SPC-Modula-2 V1.4                       ---*)
(*--- Computersystem     :  ATARI 1040 ST                           ---*)
(*--- Autor              :  Uwe A. Ruttkamp                         ---*)
(*--- Datum              :  31.01.1989                              ---*)
(*---                                                               ---*)
(*---------------------------------------------------------------------*)

MODULE XREF;
            
FROM ASCII        IMPORT EOL;
FROM InOut        IMPORT Done, RedirectInput, RedirectOutput,
                         Read, Write, WriteInt, WriteString, WriteLn,
                         CloseInput, CloseOutput;
FROM TableHandler IMPORT WordLength, Table, overflow, InitTable,
                         Record, Tabulate, FinishTable;
IMPORT Environment, HFS, CmdLine, Strings;
                         
TYPE
 Alfa = ARRAY [0..9] OF CHAR;
CONST
 N = 45; (* No. of keywords *)
VAR
 ch                 : CHAR;
 i,k,l,m,r,lno      : INTEGER;
 T                  : Table;
 id                 : ARRAY [0..WordLength-1] OF CHAR;
 key                : ARRAY [1..N] OF Alfa;
 Source, Destination,
 Vol, Dir, Doc, Typ : ARRAY [1..100] OF CHAR;
 Ok, View, List     : BOOLEAN;
 
 PROCEDURE Copy;
 BEGIN
  IF List THEN Write(ch); END;
  Read(ch);
 END Copy;
 
 PROCEDURE heading;
 BEGIN
  lno := lno + 1;
  IF List THEN  WriteInt(lno, 5); Write(" ");  END;
 END heading;
 
BEGIN
 InitTable(T);
 key[1]  := "AND ";      key[2]  := "ARRAY ";      key[3]  := "BEGIN ";
 key[4]  := "BITSET ";   key[5]  := "BOOLEAN ";    key[6]  := "BY ";
 key[7]  := "CASE ";     key[8]  := "CARDINAL ";   key[9]  := "CHAR ";
 key[10] := "CONST ";    key[11] := "DIV ";        key[12] := "DO ";
 key[13] := "ELSE ";     key[14] := "ELSIF ";      key[15] := "END ";
 key[16] := "EXIT ";     key[17] := "EXPORT ";     key[18] := "FALSE ";
 key[19] := "FOR ";      key[20] := "FROM ";       key[21] := "IF ";
 key[22] := "IMPORT ";   key[23] := "IN ";         key[24] := "INTEGER ";
 key[25] := "LOOP ";     key[26] := "MOD ";        key[27] := "MODULE ";
 key[28] := "NOT ";      key[29] := "OF ";         key[30] := "OR ";
 key[31] := "POINTER ";  key[32] := "PROCEDURE ";  key[33] := "QUALIFIED ";
 key[34] := "RECORD ";   key[35] := "REPEAT ";     key[36] := "RETURN ";
 key[37] := "SET ";      key[38] := "THEN ";       key[39] := "TO ";
 key[40] := "TRUE ";     key[41] := "TYPE ";       key[42] := "UNTIL ";
 key[43] := "VAR ";      key[44] := "WHILE ";      key[45] := "WITH ";
 
 WriteString('cross reference generator'); WriteLn;

 Ok := TRUE;
 IF NOT CmdLine.FileArg(Source) THEN
  IF NOT Environment.Get('WorkFile', Source) THEN
   Source := '\TEST.MOD';
  END;
  HFS.Decode(Source, Vol, Dir, Doc, Typ);
  HFS.Encode(Vol, Dir, Doc, '.MOD', Source);
  HFS.AskName(Source, Ok);
 END;
 
 IF Ok AND NOT CmdLine.FileArg(Destination) THEN
  HFS.Decode(Source, Vol, Dir, Doc, Typ);
  HFS.Encode(Vol, Dir, Doc, '.REF', Destination);
  HFS.AskName(Destination, Ok);
 END;
 
 View := FALSE; List := FALSE;
 IF Ok THEN
  WHILE CmdLine.Option(ch, Doc) DO
   IF    CAP(ch) = 'V' THEN View := TRUE;
   ELSIF CAP(ch) = 'L' THEN List := TRUE;
   END;
  END;
 END;

 IF Ok THEN
  IF View THEN WriteString(' * '); WriteString(Source); END;
  RedirectInput(Source);
  Ok := Ok AND Done;
  IF View THEN WriteString(' opened'); WriteLn; END;
 END;
 
 IF Ok THEN
  IF View THEN WriteString(' + '); WriteString(Destination); END;
  RedirectOutput(Destination);
  IF NOT Done THEN CloseInput; END;
  Ok := Ok AND Done;
 END;
   
 IF Ok THEN
  lno := 0;
  Read(ch);
  IF Done THEN heading;
   REPEAT
    IF (CAP(ch) >= "A") & (CAP(ch) <= "Z") THEN
     k:=0;
     REPEAT id[k] := ch; k:=k+1; Copy
     UNTIL (ch < "0") OR (ch > "9") & (CAP(ch) < "A") OR (CAP(ch) > "Z");
     l := 1; r := N; id[k] := " ";
     REPEAT m := (l+r) DIV 2; i:=0;  (* binary search *)
      WHILE (id[i] = key[m,i]) & (id[i] > " ") DO i := i + 1; END;
      IF id[i] <= key[m,i] THEN r := m - 1 END;
      IF id[i] >= key[m,i] THEN l := m + 1 END;
     UNTIL l>r;
     IF l=r+1 THEN Record(T, id, lno) END
    ELSIF (ch >= "0") & (ch <= "9") THEN
     REPEAT Copy
     UNTIL ((ch < "0") OR (ch > "9")) & ((ch < "A") OR (ch > "Z"))
    ELSIF ch = "(" THEN
     Copy;
      IF ch = "*" THEN  (* comment *)
      REPEAT
       REPEAT
        IF ch = EOL THEN
         Copy; heading
        ELSE Copy
        END
       UNTIL ch = "*";
       Copy;
      UNTIL ch = ")";
      Copy;
     END
    ELSIF ch = "'" THEN
     REPEAT Copy UNTIL ch = "'";
     Copy;
    ELSIF ch = '"' THEN
     REPEAT Copy UNTIL ch = '"';
     Copy;
    ELSIF ch = EOL THEN
     Copy;
     IF Done THEN heading END;
    ELSE Copy
    END
   UNTIL NOT Done OR (overflow # 0)
  END;
  IF overflow > 0 THEN
   WriteString("Table overflow"); WriteInt(overflow,6);
   Write(EOL);
  END;
  WriteLn;
  WriteString('Cross-reference list of ');
  WriteString(Destination); WriteLn;
  Tabulate(T); CloseInput; CloseOutput;
  IF View THEN WriteString(' written'); END;
  Strings.Concat('done ',Destination, Destination);
  CmdLine.ResultIs(TRUE, Destination);
 ELSE
  CmdLine.ResultIs(FALSE, 'not done');
 END;
 FinishTable(T);
 IF View THEN WriteLn; END;
END XREF.
