MODULE ICFS;

(*
 Support of Dirk Haun's ICFS.
 If it is not installed, a primitive replacement handles the messages
 GETPOS and FREEPOS. All others return a -1.
 *)


IMPORT
  S:=SYSTEM, Cookie;


CONST
  GETSIZE = 0; GETPOS = 1; FREEPOS = 2; SNAP = 3; GETBIGPOS = 4;
  FREEALL = 100H;
  INFO = 200H; CONFIG = 201H; SETSIZE = 202H; SETSPACE = 203H;
  NEXTINFO = 2A0H; WINOPEN = 2A1H;


TYPE
  Config* = RECORD
    version- : INTEGER;
    config-  : INTEGER;
    xsize-, ysize-, xspace-, yspcace-: INTEGER;
  END;

  vi2Proc = PROCEDURE (VAR i1, i2: INTEGER; num: INTEGER) : INTEGER;
  vi2i1Proc = PROCEDURE (VAR i1, i2: INTEGER; i3, num: INTEGER) : INTEGER;
  i2Proc = PROCEDURE (i1, i2: INTEGER; num: INTEGER) : INTEGER;
  vi4Proc = PROCEDURE (VAR i1, i2, i3, i4: INTEGER; num: INTEGER) : INTEGER;
  vi4i2Proc = PROCEDURE (VAR i1, i2, i3, i4: INTEGER; i5, i6, num: INTEGER) : INTEGER;
  i1Proc = PROCEDURE (i1, num: INTEGER) : INTEGER;
  i1cProc = PROCEDURE (VAR conf: Config; size, num: INTEGER) : INTEGER;
  Proc = PROCEDURE (num: INTEGER) : INTEGER;


VAR
  positions: SET;



PROCEDURE Server() : S.PTR;
  VAR
    value: LONGINT;
 BEGIN
  IF Cookie.Search("ICFS", value) THEN
    RETURN value
  ELSE
    RETURN S.ADR( MyServer);
  END;
 END Server;


PROCEDURE GetSize*(VAR w, h: INTEGER) : INTEGER;
(*
 Answer the size of an iconized window in w and h. Answer the version of
 ICFS.
 *)
  VAR
    proc: vi2Proc;
 BEGIN
  proc := Server();
  RETURN proc(h, w, GETSIZE)
 END GetSize;


PROCEDURE GetPos*(VAR x, y, w, h: INTEGER) : INTEGER;
(*
 Answer the position and size of an iconized window in w and h. Answer the
 window number for identification.
 *)
  VAR
    proc: vi4Proc;
 BEGIN
  proc := Server();
  RETURN proc(h, w, y, x, GETPOS)
 END GetPos;


PROCEDURE FreePos*(handle: INTEGER) : INTEGER;
(*
 Free the window position with number handle.
 *)
  VAR
    proc: i1Proc;
 BEGIN
  proc := Server();
  RETURN proc(handle, FREEPOS)
 END FreePos;


PROCEDURE Snap*(handle: INTEGER; VAR x, y: INTEGER) : INTEGER;
(*
 Answer a new window coordinate so that the icon window is positioned in
 the normal raster.
 *)
  VAR
    proc: vi2i1Proc;
 BEGIN
  proc := Server();
  RETURN proc(y, x, handle, SNAP)
 END Snap;


PROCEDURE GetBigPos*(wf, hf: INTEGER; VAR x, y, w, h: INTEGER) : INTEGER;
(*
 Answer the position and size of a big iconized window in w and h. Answer
 the window number for identification.
 *)
  VAR
    proc: vi4i2Proc;
 BEGIN
  proc := Server();
  RETURN proc(h, w, y, x, hf, wf, GETBIGPOS)
 END GetBigPos;


PROCEDURE FreeAll*() : INTEGER;
(*
 Free all window positions.
 *)
  VAR
    proc: Proc;
 BEGIN
  proc := Server();
  RETURN proc(FREEALL)
 END FreeAll;


PROCEDURE Info*(VAR conf: Config) : INTEGER;
(*
 Answer the configuration data of ICFS.
 *)
  VAR
    proc: i1cProc;
 BEGIN
  proc := Server();
  RETURN proc(conf, SIZE(Config), INFO)
 END Info;


PROCEDURE Configure*(config: SET) : INTEGER;
(*
 Set the configuration of ICFS.
 *)
  VAR
    proc: i1Proc;
 BEGIN
  proc := Server();
  RETURN proc(SHORT( S.VAL( LONGINT, config) ), CONFIG)
 END Configure;


PROCEDURE SetSize*(nw, nh: INTEGER) : INTEGER;
(*
 Set the size of an iconized window to nw and nh.
 *)
  VAR
    proc: i2Proc;
 BEGIN
  proc := Server();
  RETURN proc(nh, nw, SETSIZE)
 END SetSize;


PROCEDURE SetSpace*(nx, ny: INTEGER) : INTEGER;
(*
 Set the space between iconized windows to nw and nh.
 *)
  VAR
    proc: i2Proc;
 BEGIN
  proc := Server();
  RETURN proc(ny, nx, SETSPACE)
 END SetSpace;


PROCEDURE NextInfo*(VAR conf: Config) : INTEGER;
(*
 Answer the next configuration
 *)
  VAR
    proc: i1cProc;
 BEGIN
  proc := Server();
  RETURN proc(conf, SIZE(Config), NEXTINFO)
 END NextInfo;


PROCEDURE WinOpen*(handle: INTEGER) : INTEGER;
(*
 Answer the number of open windows
 *)
  VAR
    proc: Proc;
 BEGIN
  proc := Server();
  RETURN proc(WINOPEN)
 END WinOpen;


PROCEDURE MyServer(num: INTEGER) : INTEGER;
  VAR
    i, x, y, w, h: INTEGER;

  PROCEDURE SetXYWH;
   BEGIN
    ASSEMBLER
      MOVE.L  10(A6),A0
      MOVE.W  x,(A0)
      MOVE.L  14(A6),A0
      MOVE.W  y,(A0)
      MOVE.L  18(A6),A0
      MOVE.W  w,(A0)
      MOVE.L  22(A6),A0
      MOVE.W  h,(A0)
    END;
   END SetXYWH;

  PROCEDURE GetIndex;
   BEGIN
    ASSEMBLER
      MOVE.W  10(A6),i
    END;
   END GetIndex;

 BEGIN
  CASE num OF
    GETPOS:
      FOR i := 0 TO 31 DO
        IF ~(i IN positions) THEN
          INCL( positions, i);
          x := i * 82 + 10; y := 45;
          w := 72; h := 72;
          SetXYWH;
          RETURN i;
        END;
      END;
      RETURN -1;
  | FREEPOS:
      GetIndex;
      EXCL( positions, i);
      RETURN 0;
  ELSE
    RETURN -1;
  END;
 END MyServer;


END ICFS.