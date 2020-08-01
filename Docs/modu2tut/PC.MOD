MODULE PC;

(* The codes in this program are for an EPSON RX-80.  You may have *)
(* to adjust the codes for your printer.                           *)

FROM InOut IMPORT WriteString, WriteLn, Read, Write;
FROM FileSystem IMPORT Lookup, WriteChar, Close, File;

VAR InputChar, Char0, Char1 : CHAR;
    PrintFile               : File;

BEGIN
   WriteString("F Formfeed");                    WriteLn;
   WriteString("C/N Compressed/Normal");         WriteLn;
   WriteString("D/S DoubleStrike/SingleStrike"); WriteLn;
   WriteString("E/R Emphasized/Regular");        WriteLn;
   WriteLn;
   WriteString("Enter Selection --> ");
   Read(InputChar);
   Write(InputChar);
   InputChar := CAP(InputChar);

                          (* Character input - now output the code *)

   CASE InputChar OF
    'F' : Char0 := 14C;      (* Formfeed *)
          Char1 := 0C;   |
    'C' : Char0 := 17C;      (* Compressed mode *)
          Char1 := 0C;   |
    'N' : Char0 := 22C;      (* Normal width *)
          Char1 := 0C;   |
    'D' : Char0 := 33C;      (* Double Strike - esc-'G' *)
          Char1 := 107C; |
    'S' : Char0 := 33C;      (* Single Strike - esc-'H' *)
          Char1 := 110C; |
    'E' : Char0 := 33C;      (* Emphasized Print - esc-'E' *)
          Char1 := 105C; |
    'R' : Char0 := 33C;      (* Emphasized Off - esc-'@' *)
          Char1 := 100C;
   ELSE
      WriteString("Invalid Character.");
   END;

   Lookup(PrintFile,"PRN",TRUE);    (* Open print file *)
   WriteChar(PrintFile,Char0);
   IF Char1 > 0C THEN
      WriteChar(PrintFile,Char1);
   END;
   Close(PrintFile);

END PC.
