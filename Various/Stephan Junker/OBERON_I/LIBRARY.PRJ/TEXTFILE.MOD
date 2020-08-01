MODULE TextFiles; (* Stephan Junker *)

(*
 * TextFiles extends BFiles with some text specific i/o commands.
 *)


IMPORT
  Files:=BFiles;


TYPE
  Rider*  = RECORD(Files.Rider)
            END;


PROCEDURE(VAR r : Rider) ReadLine*(VAR line : ARRAY OF CHAR);
(*
 * reads the contents of a line, terminated by cr, lf or eof. The control
 * characters are deleted. Empty lines are not returned!
 *)
  VAR
    i : INTEGER;
    c : CHAR;
 BEGIN
  REPEAT
    i := 0;
    REPEAT
      r.Read(c);
      line[i] := c;
      INC(i);
    UNTIL (c = 0DX) OR (c = 0AX) OR r.eof;
    IF (c = 0DX) OR (c = 0AX) THEN
      line[i-1] := 0X
    ELSE
      line[i] := 0X
    END;
  UNTIL r.eof OR (line[0] # 0X);
 END ReadLine;


PROCEDURE(VAR r : Rider) WriteLine*(line : ARRAY OF CHAR);
(*
 * writes the contents of a line, terminated by cr and lf. The cr and lf
 * are added by WriteLine.
 *)
  VAR
    i : INTEGER;
 BEGIN
  i := 0;
  WHILE line[i] # 0X DO
    r.Write(line[i]);
    INC(i);
  END;
  r.Write(0DX);
  r.Write(0AX);
 END WriteLine;


END TextFiles.