MODULE auxout;

(* Mods

        05/09/86 - rms : insert busyread to allow abort

rms : 4/24/86 - routine to transfer file from file to serial port
          OpenInput and OpenOutput are used with a null default extension,
          because they attach the extension to the front of the filename!! *)


FROM InOut IMPORT Done, OpenOutput, OpenInput, termCH, EOL,
                    CloseInput, CloseOutput, Read, Write;

IMPORT Terminal;


CONST
        handle = 1;                     (* terminal *)


VAR
        tch,                            (* checks for ^C *)
        ch      : CHAR;


BEGIN
  REPEAT
    OpenInput("");                      (* find out whence input *)
    IF (termCH = 03C) THEN
      HALT;
    END;

  UNTIL Done;                           (* don't give up *)
  REPEAT

    OpenOutput("");                     (* where to? *)
    IF (termCH = 03C) THEN
      HALT;
    END;

  UNTIL Done;
  Read(ch);                             (* read from input file *)
  LOOP

    IF NOT Done THEN
      EXIT;
    END;

    Write(ch);                          (* put it out to file *)
    IF (ch = EOL) THEN
      Terminal.WriteLn;
      Terminal.BusyRead(tch);           (* see if key pressed *)
      IF (tch = 03C) THEN               (* is it ^C? *)
        EXIT;                           (* time to quit *)
      END;

    ELSE
      Terminal.Write(ch);               (* echo on console *)
    END;

    Read(ch);                           (* and read next character *)
  END;                                  (* end loop *)

  CloseInput;                           (* close the input file *)
  CloseOutput;

END auxout.

