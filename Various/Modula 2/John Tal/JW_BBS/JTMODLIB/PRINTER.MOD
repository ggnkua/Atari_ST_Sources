IMPLEMENTATION MODULE Printer;

FROM ASCII      IMPORT EOL;
FROM FileSystem IMPORT File, Lookup, Close, WriteChar, Response, Doio;
FROM Terminal   IMPORT WriteString, WriteLn;
FROM System     IMPORT TermProcedure,InitProcedure;
FROM Functions  IMPORT ToSpaces;
FROM Strings    IMPORT Length,Copy;


VAR
 printer : File;
 printHead : CARDINAL;


PROCEDURE PrintLn;
BEGIN
  WriteChar(printer, EOL);
  (* empty the buffer in the Modula-2 FileSystem *)
  Doio(printer);
  printHead := 1;
END PrintLn;


PROCEDURE PrintChar(c : CHAR);
BEGIN
  IF c = EOL THEN
     PrintLn
  ELSE
     WriteChar(printer,c);
  END;
END PrintChar;


PROCEDURE PrintString(str : ARRAY OF CHAR);
  VAR i : CARDINAL;
BEGIN
  i := 0;
  WHILE (i<=HIGH(str)) AND (str[i]<>0C) DO
    PrintChar(str[i]);
    INC(i);
  END;
END PrintString;


PROCEDURE PrintStringMid(str : ARRAY OF CHAR; beg,len : CARDINAL);
  VAR i : CARDINAL;
BEGIN
  i := beg;
  WHILE (i<=HIGH(str)) AND (str[i]<>0C) AND (i < len) DO
    PrintChar(str[i]);
    INC(i);
  END;
END PrintStringMid;

(*
   printHead is current location of print head on printer where next
   character would be printed.   printHead = [1..132]
*)


PROCEDURE PrintTab(tab : INTEGER; str : ARRAY OF CHAR);
VAR
 SS : ARRAY [0..255] OF CHAR;
 k : CARDINAL;
 r : INTEGER;
 crlf : BOOLEAN;
 written : CARDINAL;
BEGIN
 k := 0; r := 0; crlf := FALSE;

 IF (tab < 0) THEN
    crlf := TRUE;
    tab := ABS(tab);
 END;

 k := Length(str);

 r := tab - INTEGER(printHead);

 IF (r > 0) THEN   (* needs to be 1 for new line at tab 1 *)
   ToSpaces(SS,r);
   PrintString(SS);                      (* advance spaces from last position to new tab *)
 END;

 IF (r > -1) THEN  (* new data to print does not overlap last printed data *)
   PrintString(str);                     (* print data *)
   printHead := (printHead + CARDINAL(r) + Length(str));
                                         (* increment print_head for next read *)
 END;

 IF (r < 0) THEN
   PrintLn;
   ToSpaces(SS,tab-1);
   PrintString(SS);
   PrintString(str);
   printHead := CARDINAL(tab) + Length(str);
 END;

 IF (crlf) THEN
   PrintLn;
   printHead := 1;
 END;

END PrintTab;


PROCEDURE PrintTabMid(tab : INTEGER; str : ARRAY OF CHAR; beg,len : CARDINAL);
VAR
 temps : ARRAY[0..255] OF CHAR;
BEGIN
 Copy(str,beg,len,temps);
 PrintTab(tab,temps);
END PrintTabMid;


PROCEDURE ClosePrinter;
BEGIN
  Close(printer);
END ClosePrinter;


PROCEDURE OpenPrinter;
BEGIN
  Lookup(printer,"DK:PRN", FALSE);
  IF printer.res <> done THEN
    WriteString("cannot open 'PRN'");
    WriteLn;
    RETURN;
  END;
  (* printHead := 1; *)
END OpenPrinter;


PROCEDURE InitHead;
BEGIN
 printHead := 1;
END InitHead;


BEGIN
 InitProcedure(InitHead);
 TermProcedure(ClosePrinter);
END Printer.



