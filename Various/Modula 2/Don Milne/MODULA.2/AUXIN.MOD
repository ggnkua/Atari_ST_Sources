MODULE auxin;

(*  04/30/86 - rms : mod for write when buffer full *)
(*  rms : 4/24/86 - routine to transfer file from serial port to file *)


FROM InOut IMPORT Done, OpenOutput, OpenInputFile, termCH,
                  CloseInput, CloseOutput, Read, Write,
                  WriteString, WriteLn, EOL;

IMPORT Terminal;

FROM TextIO IMPORT WriteReal;


CONST

  eof= 32C;                             (* ctrl-z to end capture *)
  bufsize = 32500;                      (* MAX(INTEGER) doesn't work *)
  LF = 12C;

VAR

  ch   : CHAR;
  i    : CARDINAL;
  ct   : REAL;
  buf  : ARRAY[0..bufsize] OF CHAR;


PROCEDURE writebuf;

VAR
  max  : CARDINAL;

BEGIN

  max := i;                             (* set number of chars *)
  i := 0;
  Terminal.WriteLn;  Terminal.WriteLn;
  Terminal.WriteString('Writing to file..');

  WHILE (i < max) DO                    (* take all chars in buffer *)

    ch := buf[i];
    Write(ch);                          (* write to output file *)
    INC(i);

  END;

  ct := ct + FLOAT(max);
  i := 0;

  Terminal.WriteLn;  Terminal.WriteLn;

END writebuf;


BEGIN

  i := 0; ct := 0.0;
  OpenInputFile("aux:");                (* find out whence input *)

  IF NOT Done THEN

    Terminal.WriteString("Unable to Read Port..");
    Terminal.WriteLn;
    HALT;

  END;

  REPEAT

    OpenOutput("mod");                  (* default ext doesn't work *)
    IF (termCH=03C) THEN
      HALT;

  END;

  UNTIL Done;

  Terminal.WriteString("Ready to Receive File - Send ^Z When Done");
  Terminal.WriteLn;
  Read(ch);                             (* read from input file *)

  WHILE NOT (ch = eof) DO               (* if not end of file *)

    Terminal.Write(ch);                 (* echo on console *)
    IF (ch = EOL) THEN
      Terminal.Write(LF);

  END;

    buf[i] := ch;                       (* insert in buffer *)
    INC(i);                             (* increment buffer pointer *)
    IF (i > bufsize) THEN
      writebuf;

  END;

    Read(ch);                           (* and read next character *)

  END;

  CloseInput;                           (* close the input file *)

  IF (i > 0) THEN

    writebuf;

  END;

  CloseOutput;

  WriteLn;WriteLn;
  WriteString('Bytes copied: ');
  WriteReal(ct,6,0);
  WriteLn;

END auxin.

