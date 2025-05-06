TITLE: Screen control implementation
IMPLEMENTATION MODULE ScrCtl;


FROM Terminal   IMPORT  Write, WriteString, Read;



PROCEDURE eseq(c : CHAR);       (* write escape sequence to screen *)

BEGIN                           (* this is utility routine within module *)

  Write(CHR(27));

  Write(c);

END eseq;



PROCEDURE gotoxy(x,y : INTEGER);        (* cursor to col x, row y *)

BEGIN

  eseq("Y");

  Write(CHR(y+31));

  Write(CHR(x+31));

END gotoxy;



PROCEDURE clrscr;               (* home cursor, clear screen *)

BEGIN

  eseq("E");

END clrscr;



PROCEDURE clreol;               (* clear from cursor to end of line *)

BEGIN

  eseq("K");

END clreol;



PROCEDURE clreos;               (* clear from cursor to end of screen *)

BEGIN

  eseq("J");

END clreos;



PROCEDURE con;                  (* turn cursor on *)

BEGIN

  eseq("e");

END con;



PROCEDURE coff;                 (* turn cursor off *)

BEGIN

  eseq("f");

END coff;



PROCEDURE savcurs;              (* save cursor position *)

BEGIN

  eseq("j");

END savcurs;



PROCEDURE rstcurs;              (* place cursor at saved position *)

BEGIN

  eseq("k");

END rstcurs;



PROCEDURE rvon;                 (* start reverse video *)

BEGIN

  eseq("p");

END rvon;


PROCEDURE rvoff;                (* end reverse video *)

BEGIN

  eseq("q");

END rvoff;



PROCEDURE clr24;                (* clear first 24 lines only *)

BEGIN

  gotoxy(80,24);

  eseq("d");

  eseq("H");                    (* home cursor *)

END clr24;



PROCEDURE bell(n : CARDINAL);   (* ring bell n times *)

BEGIN

  WHILE (n > 0) DO

    Write(CHR(7));

    DEC(n);

  END;

END bell;

PROCEDURE msg(VAR s : ARRAY OF CHAR;cd : CARDINAL);

VAR

        ch      : CHAR;

BEGIN

  savcurs;coff;                 (* save cursor pos and turn curs off *)

  gotoxy(1,25);clreol;rvon;     (* clear out bottom line *)

  IF (cd IN {2..5}) THEN        (* BELL requested? *)

    Write(CHR(7));

  END;

  IF (cd = 5) THEN

    WriteString("Fatal ");

  END;

  IF (cd IN {4,5}) THEN

    WriteString("Error: ");

  END;

  WriteString(s);WriteString(" .. ");rvoff;

  IF (cd IN {3..5}) THEN

    WriteString("Any Key to Continue..");

    con;

    Read(ch);                   (* wait for response *)

    coff;

    gotoxy(1,25);clreol;

  END;

  IF (cd = 5) THEN              (* fatal error? *)

    con;                        (* turn cursor on *)

    HALT;                       (* and quit *)

  END;

  rstcurs;                      (* put cursor back where found *)

END msg;


BEGIN

  eseq("w");                    (* disable line wrap *)

END ScrCtl.

