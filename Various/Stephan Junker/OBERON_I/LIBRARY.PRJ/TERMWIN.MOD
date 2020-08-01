MODULE TermWin; (* Stephan Junker  9.11.93 *)

(* TermWin extends the object WinView.Viewer in order to provide a simple
 * method of displaying text data in a window. The usual output procedures
 * WriteChar etc. are implemented as procedures bound to the viewer.
 * Input of characters is automatically displayed. If return or enter
 * is pressed, a stored procedure is called with the contents of the
 * current line as argument. The string is written into and read from the
 * terminal, but the line is not left. If other behaviour is desired,
 * just override HandleKeyEvent (by extending WriteTerminal.Viewer) and
 * react on the desired keys. For example, react on cursor up and down
 * by displaying a command history. ReadTerminal works only with the
 * characters stored in the terminal window, so you may write a different
 * string without causing trouble.
 *
 * Usage:
 * Allocate and initialize an object of type TermWin.Viewer (or an
 * extension of that type). Use the methods Open and Close to open and
 * close the window. Store a procedure to handle string inputs.
 *)


IMPORT
  S:=SYSTEM, WinView, Memory, VA:=VDIAttributes, VO:=VDIOutput,
  VC:=VDIControl, VDI, Wind, VI:=VDIInquiry, NumStr, Graf,
  Str:=Strings, Evnt, Task, VR:=VDIRaster;

(*---------------------------------TYPE----------------------------------*)

TYPE
  Viewer*   = POINTER TO ViewDesc;

  StringProc* = PROCEDURE (v: Viewer; VAR string: ARRAY OF CHAR);

  ViewDesc* = RECORD(WinView.ViewDesc)
    rows-,cols- : INTEGER;
    curx-,cury- : INTEGER;
    scx-,scy-   : INTEGER;
    station-    : INTEGER;
    cw-,ch-     : INTEGER;
    edstart-    : INTEGER;
    curon-      : BOOLEAN;
    memory-     : S.PTR;
    handler     : StringProc;
  END;
  Line      = POINTER TO ARRAY 1000 OF CHAR;

(*---------------------------------VAR-----------------------------------*)

VAR
  station : INTEGER; (* used for the cursor *)
  Workin  : VC.workin;
  Workout : VC.workout;
  esc,newRow,d : INTEGER;

(*---------------------------------StoreHandler--------------------------*)

PROCEDURE (v : Viewer) StoreHandler*(handler: StringProc);
(*
 Stores handler to be called whenever the user hits return with the string
 in the current line as parameter.
 *)
 BEGIN
  v.handler := handler;
 END StoreHandler;


PROCEDURE DummyHandler(v: Viewer; VAR string: ARRAY OF CHAR);
 END DummyHandler;

(*---------------------------------CursorOn------------------------------*)

PROCEDURE (v : Viewer) CursorOn*;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF NOT v.curon THEN
    v.curon := TRUE;
    v.UpdateRect( v.x + v.curx*v.cw, v.y + v.cury*v.ch, v.cw, v.ch );
  END;
 END CursorOn;

(*---------------------------------CursorOff-----------------------------*)

PROCEDURE (v : Viewer) CursorOff*;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF v.curon THEN
    v.curon := FALSE;
    v.UpdateRect( v.x + v.curx*v.cw, v.y + v.cury*v.ch, v.cw, v.ch );
  END;
 END CursorOff;

(*---------------------------------SetCursor-----------------------------*)

PROCEDURE(v : Viewer) SetCursor*(col,row : INTEGER);
  (* changes the position where the next output has to appear. If one
     of the parameter exceeds its limits, it will be set at the maximum
     value. *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF col < 0 THEN col := 0
  ELSIF col >= v.cols THEN col := v.cols-1
  END;
  IF row < 0 THEN row := 0
  ELSIF row >= v.rows THEN row := v.rows-1
  END;
  cur := v.curon; v.CursorOff;
  v.curx := col; v.cury := row;
  IF cur THEN v.CursorOn END;
 END SetCursor;

(*---------------------------------ClearHome-----------------------------*)

PROCEDURE(v : Viewer) ClearHome*;
  (* clears the memory of viewer v and the window if opened *)
 BEGIN
  IF NOT v.opened THEN v.Open END;
  Memory.Fill( v.memory, v.rows*v.cols, 20202020H);
  v.curx := 0; v.cury := 0;
  v.Update(0);
 END ClearHome;

(*---------------------------------CursorUp------------------------------*)

PROCEDURE (v : Viewer) CursorUp*;
  (* set cursor in previous line. Scroll down and clear first line if
     cursor is in first line *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF v.cury # 0 THEN v.SetCursor(v.curx, v.cury-1)
  ELSE
    cur := v.curon; v.CursorOff;
    S.MOVE( v.memory, v.memory + LONG(v.cols), (v.rows-1) * v.cols);
    Memory.Fill( v.memory, v.cols, 20202020H);
    v.curon := cur;
    IF v.IsTop() THEN
      VR.ScrollDown( 1, v.x, v.y, v.x+v.w-1, v.y+v.h-1, v.ch);
      v.UpdateRect( v.x, v.y, v.w, v.ch);
    ELSE
      v.UpdateRect( v.x, v.y, v.w, v.h);
    END;
  END;
 END CursorUp;

(*---------------------------------ClearEOS------------------------------*)

PROCEDURE (v : Viewer) ClearEOS*;
  (* clears from cursor to end of screen *)
  VAR cur : BOOLEAN; dist : INTEGER;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  dist := v.cols*v.cury + v.curx;
  Memory.Fill( v.memory + LONG(dist), v.rows*v.cols - dist, 20202020H);
  v.curon := cur;
  v.UpdateRect( v.x, v.y+v.cury*v.ch, v.w, v.h-v.cury*v.ch);
 END ClearEOS;

(*---------------------------------ClearSOS------------------------------*)

PROCEDURE (v : Viewer) ClearSOS*;
  (* clears from start of screen to cursor *)
  VAR cur : BOOLEAN; dist : INTEGER;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  dist := v.cols*v.cury + v.curx+1;
  Memory.Fill( v.memory, dist, 20202020H);
  v.curon := cur;
  v.UpdateRect( v.x, v.y, v.w, (v.cury+1)*v.ch);
 END ClearSOS;

(*---------------------------------ClearEOL------------------------------*)

PROCEDURE (v : Viewer) ClearEOL*;
  (* clears from cursor to end of line *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  Memory.Fill( v.memory + LONG(v.cols*v.cury+v.curx), v.cols-v.curx, 20202020H);
  v.curon := cur;
  v.UpdateRect( v.x+v.curx*v.cw, v.y+v.cury*v.ch, v.w-v.curx*v.cw, v.ch);
 END ClearEOL;

(*---------------------------------InsertLine----------------------------*)

PROCEDURE (v : Viewer) InsertLine*;
  (* inserts a line above the current line. The line is cleared and
     cursor set at column 0 *)
  VAR cur : BOOLEAN; addr : S.PTR;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  addr := v.memory + LONG(v.cols*v.cury);
  S.MOVE( addr, addr + LONG( v.cols), (v.rows-v.cury-1)*v.cols );
  Memory.Fill( addr, v.cols, 20202020H);
  v.curx := 0; v.curon := cur;
  IF v.IsTop() THEN
    VR.ScrollDown( 1, v.x, v.y+v.cury*v.ch, v.x+v.w-1,
                   v.y+v.h-v.cury*v.ch-1, v.ch);
    v.UpdateRect( v.x, v.y+v.cury*v.ch, v.w, v.ch);
  ELSE
    v.UpdateRect( v.x, v.y+v.cury*v.ch, v.w, v.h);
  END;
 END InsertLine;

(*---------------------------------DeleteLine----------------------------*)

PROCEDURE (v : Viewer) DeleteLine*;
  (* deletes the current line. Cursor is set at column 0 *)
  VAR cur : BOOLEAN; addr : S.PTR;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon;
  addr := v.memory + LONG(v.cols*v.cury);
  S.MOVE( addr + LONG( v.cols), addr, (v.rows-v.cury-1)*v.cols );
  Memory.Fill(v.memory + LONG(v.cols*(v.rows-1)) , v.cols, 20202020H);
  v.curx := 0;
  IF v.IsTop() THEN
    VR.ScrollUp( 1, v.x, v.y+v.cury*v.ch, v.x+v.w-1,
                v.y+v.h-v.cury*v.ch-1, v.ch);
    v.UpdateRect( v.x, v.y+(v.rows-1)*v.ch, v.w, v.ch);
    IF cur THEN v.curon := FALSE; v.CursorOn END;
  ELSE
    v.curon := cur;
    v.UpdateRect( v.x, v.y+v.cury*v.ch, v.w, v.h);
  END;
 END DeleteLine;

(*---------------------------------SaveCursor----------------------------*)

PROCEDURE (v : Viewer) SaveCursor*;
  (* saves the current cursor position *)
 BEGIN
  v.scx := v.curx; v.scy := v.cury;
 END SaveCursor;

(*---------------------------------RestoreCursor-------------------------*)

PROCEDURE (v : Viewer) RestoreCursor*;
  (* restores the current cursor position *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  v.curx := v.scx; v.cury := v.scy;
  IF cur THEN v.CursorOn END;
 END RestoreCursor;

(*---------------------------------ClearLine-----------------------------*)

PROCEDURE (v : Viewer) ClearLine*;
  (* clears the line the cursor is in. Cursor is sest in column 0 *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  Memory.Fill( v.memory + LONG(v.cols*v.cury), v.cols, 20202020H);
  v.curon := cur;
  v.UpdateRect( v.x, v.y+v.cury*v.ch, v.w, v.ch);
 END ClearLine;

(*---------------------------------ClearSOL------------------------------*)

PROCEDURE (v : Viewer) ClearSOL*;
  (* clears from start of line to cursor *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  Memory.Fill( v.memory + LONG(v.cols*v.cury), v.curx+1, 20202020H);
  v.curon := cur;
  v.UpdateRect( v.x, v.y+v.cury*v.ch, (v.curx+1)*v.cw, v.ch);
 END ClearSOL;

(*---------------------------------Backspace-----------------------------*)

PROCEDURE (v : Viewer) Backspace*;
  (* cursor left and overwrite character with space *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF v.curx # 0 THEN
    cur := v.curon; v.CursorOff;
    DEC(v.curx);
    S.PUT( v.memory + LONG(v.cols*v.cury+v.curx), " ");
    v.curon := cur;
    v.UpdateRect( v.x+v.curx*v.cw, v.y+v.cury*v.ch, v.cw, v.ch);
  END;
 END Backspace;

(*---------------------------------Delete--------------------------------*)

PROCEDURE (v : Viewer) Delete*;
  (* delete character by shifting the rest of the line *)
  VAR addr : S.PTR;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF v.curx # 0 THEN
    addr := v.memory + LONG(v.cols*v.cury+v.curx);
    S.MOVE( addr+1, addr, v.cols-v.curx);
    S.PUT( v.memory + LONG(v.cols*(v.cury+1)-1), " ");
    IF v.IsTop() THEN
      VR.ScrollLeft( 1, v.x+v.curx*v.cw, v.y+v.cury*v.ch,
                     v.x+v.w-1, v.y+(v.cury+1)*v.ch-1, v.cw);
      v.UpdateRect( v.x+(v.cols-1)*v.cw, v.y+v.cury*v.ch, v.cw, v.ch);
      IF v.curon THEN v.curon := FALSE; v.CursorOn END;
    ELSE
      v.UpdateRect( v.x+v.curx*v.cw, v.y+v.cury*v.ch, v.w, v.ch);
    END;
  END;
 END Delete;

(*---------------------------------Insert--------------------------------*)

PROCEDURE (v : Viewer) Insert*;
  (* shifts the line to the right and inserts a space *)
  VAR addr : S.PTR; cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  addr := v.memory + LONG(v.cols*v.cury+v.curx);
  S.MOVE( addr, addr+1, v.cols-v.curx-1);
  S.PUT( v.memory + LONG(v.cols*v.cury+v.curx), " ");
  v.curon := cur;
  IF v.IsTop() THEN
    VR.ScrollRight( 1, v.x+v.curx*v.cw, v.y+v.cury*v.ch,
                    v.x+v.w-1, v.y+(v.cury+1)*v.ch-1, v.cw);
    v.UpdateRect( v.x+v.curx*v.cw, v.y+v.cury*v.ch, v.cw, v.ch);
  ELSE
    v.UpdateRect( v.x+v.curx*v.cw, v.y+v.cury*v.ch, v.w, v.ch);
  END;
 END Insert;

(*---------------------------------CheckAbortion-------------------------*)

PROCEDURE CheckAbortion;
  VAR msgBuf : Evnt.msgbuf;
      events,shift : SET; scan : INTEGER; ascii : CHAR;
      d : INTEGER; s : SET;
 BEGIN
  events := Evnt.Multi( {Evnt.KEYBOARD, Evnt.TIME}, 1, {}, {},
                       0,0,0,0,0,0,0,0,0,0, msgBuf, 0, d, d, s,
                       shift, scan, ascii, d);
  IF (Evnt.KEYBOARD IN events)
      AND (shift - {Evnt.CAPSLOCK} = {Evnt.CONTROL}) THEN
    IF scan = 2EH THEN (* c *)
      Task.Exit(0)
    END;
    IF scan = 1FH THEN
      events := Evnt.Multi( {Evnt.KEYBOARD}, 1, {}, {},
                           0,0,0,0,0,0,0,0,0,0, msgBuf, 0, d, d, s,
                           shift, scan, ascii, d);
    END;
  END;
 END CheckAbortion;

(*---------------------------------LineFeed-------------------------------*)

PROCEDURE(v : Viewer) LineFeed*;
  (* set cursor in following row, scroll if needed *)
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon; v.CursorOff;
  INC(v.cury);
  IF v.cury = v.rows THEN
    DEC(v.cury);
    S.MOVE( v.memory + LONG(v.cols), v.memory, (v.rows-1) * v.cols);
    Memory.Fill( v.memory + LONG((v.rows-1) * v.cols), v.cols, 20202020H);
    v.curon := cur;
    IF v.IsTop() THEN
      VR.ScrollUp( 1, v.x, v.y, v.x+v.w-1, v.y+v.h-1, v.ch);
      v.UpdateRect( v.x, v.y+v.h-v.ch, v.w, v.ch);
    ELSE
      v.UpdateRect( v.x, v.y, v.w, v.h);
    END;
  ELSIF cur THEN
    v.CursorOn
  END;
  CheckAbortion;
 END LineFeed;

(*---------------------------------SetSize-------------------------------*)

PROCEDURE(v : Viewer) SetSize*(cols,rows : INTEGER);
  (* changes the size of viewer v. The memory size is adjusted and its
     previous contents transferred to the new location. If size became
     smaller, the data will be cut, else the new characters will be
     cleared. The old memory is of course disposed. If the window is
     open, it will also be changed in size. *)
  VAR mem : LONGINT;
      line1,line2 : Line;
      oldr,oldc,r,c,maxr,maxc : INTEGER;
 BEGIN
  mem := v.memory; oldr := v.rows; oldc := v.cols;
  v.rows := rows; v.cols := cols;
  S.NEW(v.memory, rows*cols+1);
  Memory.Fill( v.memory, v.rows*v.cols, 20202020H);
  v.curx := 0; v.cury := 0;
  IF mem # 0 THEN (* transfer old contents *)
    line2 := v.memory; line1 := mem;
    maxc := oldc; maxr := oldr;
    IF maxc > cols THEN maxc := cols END;
    IF maxr > rows THEN maxr := rows END;
    REPEAT
      c := 0;
      REPEAT line2[c] := line1[c]; INC(c) UNTIL c >= maxc;
      INC(r); INC(line2,cols); INC(line1,oldc);
    UNTIL r >= maxr;
    S.DISPOSE( S.VAL( S.PTR, mem));
  END;
  v.SetSize^( cols * v.cw, rows * v.ch);
 END SetSize;

(*---------------------------------SetFont-------------------------------*)

PROCEDURE(v : Viewer) SetFont*(fontId,fontHeight : INTEGER);
  (* sets the font used to display the characters. FontId is the value
     used for VstFont, and FontHeight is used for VstPoint. Correct
     function with proportional fonts is not guaranteed. The number of
     characters per line is calculated using the maximum size of a
     character, so there will be an unused margin at the right. The cursor
     position is calculated as the product of v.col and maximum width
     of characters (v.cw), so this will cause problems.
     If the window is open, it will be updated immediatly. *)
  VAR d : INTEGER;
 BEGIN
  VA.VstFont(v.station,fontId);
  VA.VstPoint(v.station,fontHeight,d,d,v.cw,v.ch);
  v.SetSize^( v.cols * v.cw, v.rows * v.ch);
  v.Update(0);
 END SetFont;

(*---------------------------------Initialize----------------------------*)

PROCEDURE(v : Viewer) Initialize*;
  (* initializes a viewer. The size is set to 80 columns and 22 rows
     (640*400 screen with 8*16 font). A closer and mover is provided.
     The title is "Terminal window", but you can change it using
     v.SetTitle. The screen is cleared, of course, and cursor is in
     row 0, col 0. Cursor means the position where the next output
     will appear. This cursor is set invisible *)
  VAR Workin : VC.workin; Workout : VC.workout;
      d : INTEGER;
 BEGIN
  v.Initialize^;
  v.SetElements({Wind.TITLE,Wind.MOVER,Wind.CLOSER});
  v.SetTitle("Terminal window");
  v.station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 0; Workin.FillPat := 0;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VC.VOpnvwk(Workin,v.station,Workout);
  VA.VswrMode(v.station,VA.REPLACE);
  VA.VsfPerimeter(v.station,FALSE);
  v.curon := TRUE; v.edstart := 0;
  VA.VstFont(v.station,1);
  VA.VstPoint(v.station,13,d,d,v.cw,v.ch);
  v.rows := 22; v.cols := 80;
  S.NEW(v.memory, 80*22+1);
  Memory.Fill( v.memory, 80*22, 20202020H);
  v.curx := 0; v.cury := 0;
  v.SetSize^( 80 * v.cw, 22 * v.ch);
  v.handler := DummyHandler;
 END Initialize;

(*---------------------------------WriteChar-----------------------------*)

PROCEDURE^ IsEscape(v : Viewer; c : CHAR) : BOOLEAN;

PROCEDURE(v : Viewer) WriteChar*(c : CHAR);
  (* writes a character into the memory of viewer v at the current cursor
     position. The position is increased. If the end of line is reached,
     output will continue in the next line. If the last line is reached,
     the output is shifted up one line. If the window is not open, it will
     be opened *)
 BEGIN
  IF NOT v.opened THEN v.Open END;
  IF NOT IsEscape(v,c) THEN
    S.PUT( v.memory + LONG(v.cury*v.cols + v.curx), c);
    INC(v.curx);
    IF v.curx >= v.cols THEN
      v.UpdateRect( v.x+(v.curx-1)*v.cw, v.y+v.cury*v.ch, v.cw, v.ch);
      v.curx := 0; INC(v.cury);
      IF v.cury >= v.rows THEN
        v.cury := v.rows - 1;
        S.MOVE( v.memory + LONG(v.cols), v.memory, (v.rows-1) * v.cols);
        Memory.Fill( v.memory + LONG( (v.rows-1) * v.cols), v.cols, 20202020H);
        IF v.IsTop() THEN
          VR.ScrollUp( 1, v.x, v.y, v.x+v.w-1, v.y+v.h-1, v.ch);
          v.UpdateRect( v.x, v.y+v.h-v.ch, v.w, v.ch);
        ELSE
          v.UpdateRect( v.x, v.y, v.w, v.h);
        END;
      ELSE
        v.UpdateRect( v.x+v.curx*v.cw, v.y+v.cury*v.ch, v.cw, v.ch);
      END;
    ELSE
      v.UpdateRect( v.x+(v.curx-1)*v.cw, v.y+v.cury*v.ch, v.cw*2, v.ch);
    END;
  END;
 END WriteChar;

(*---------------------------------WriteString---------------------------*)

PROCEDURE(v : Viewer) WriteString*(str : ARRAY OF CHAR);
  (* writes a string into the memory of viewer v at the current cursor
     position. It follows the same procedure as WriteChar. *)
  VAR firstc,i,j : INTEGER;
      line : Line;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  firstc := v.curx; i := v.curx; j := 0;
  line := v.memory + LONG(v.cury*v.cols);
  WHILE str[j] # 0X DO
    IF IsEscape(v,str[j]) THEN
      INC(j)
    ELSE
      line[i] := str[j]; INC(i); INC(j);
      IF i >= v.cols THEN
        v.UpdateRect( v.x+firstc*v.cw, v.y+v.cury*v.ch, (i-firstc)*v.cw, v.ch);
        INC(v.cury); i := 0; firstc := 0;
        IF v.cury >= v.rows THEN
          v.cury := v.rows - 1;
          S.MOVE( v.memory + LONG(v.cols), v.memory, (v.rows-1) * v.cols);
          Memory.Fill( v.memory + LONG((v.rows-1) * v.cols), v.cols, 20202020H);
          IF v.IsTop() THEN
            VR.ScrollUp( 1, v.x, v.y, v.x+v.w-1, v.y+v.h-1, v.ch);
            v.UpdateRect( v.x, v.y+v.h-v.ch, v.w, v.ch);
          ELSE
            v.UpdateRect( v.x, v.y, v.w, v.h);
          END;
        ELSE
          INC(line, v.cols);
        END;
      END;
    END;
  END;
  v.curx := i;
  v.UpdateRect( v.x+firstc*v.cw, v.y+v.cury*v.ch, (i-firstc+1)*v.cw, v.ch);
 END WriteString;

(*---------------------------------Tabulator-----------------------------*)

PROCEDURE (v : Viewer) Tabulator*;
  (* sets the cursor to the next tabulator position *)
  VAR i,j : INTEGER;
      str : ARRAY 10 OF CHAR;
 BEGIN
  i := v.curx; j := 0;
  REPEAT
    INC(i); str[j] := " "; INC(j);
  UNTIL (i = v.cols) OR (i MOD 8 = 0);
  str[j] := 0X; v.WriteString(str);
 END Tabulator;

(*---------------------------------IsEscape------------------------------*)

PROCEDURE IsEscape(v : Viewer; c : CHAR) : BOOLEAN;
 BEGIN
  CASE esc OF
    0: CASE c OF
         08X: v.Backspace
       | 09X: v.Tabulator
       | 0DX: v.SetCursor(0,v.cury)
       | 0AX: v.LineFeed
       | 7FX: v.Delete
       | 1BX: esc := 1
       ELSE RETURN FALSE
       END;
  | 1: esc := 0;
       CASE c OF
         "A": v.SetCursor(v.curx, v.cury-1)
       | "B": v.SetCursor(v.curx, v.cury+1)
       | "C": v.SetCursor(v.curx+1, v.cury)
       | "D": v.SetCursor(v.curx-1, v.cury)
       | "E": v.ClearHome
       | "H": v.SetCursor(0,0)
       | "I": v.CursorUp
       | "J": v.ClearEOS
       | "K": v.ClearEOL
       | "L": v.InsertLine
       | "M": v.DeleteLine
       | "Y": esc := 3
       | "b","c": esc := 2
       | "d": v.ClearSOS
       | "e": v.CursorOn
       | "f": v.CursorOff
       | "j": v.SaveCursor
       | "k": v.RestoreCursor
       | "l": v.ClearLine
       | "o": v.ClearSOL
       ELSE
       END;
  | 2: esc := 0
  | 3: newRow := ORD(c) -20H; esc := 4
  | 4: v.SetCursor( ORD(c) - 20H, newRow); esc := 0
  END;
  RETURN TRUE
 END IsEscape;

(*---------------------------------WriteLn-------------------------------*)

PROCEDURE(v : Viewer) WriteLn*;
  VAR cur : BOOLEAN;
 BEGIN
  IF NOT v.opened THEN v.Open END;
  cur := v.curon;
  v.CursorOff;
  v.curx := 0; INC(v.cury);
  IF v.cury = v.rows THEN
    DEC(v.cury);
    S.MOVE( v.memory + LONG(v.cols), v.memory, (v.rows-1) * v.cols);
    Memory.Fill( v.memory + LONG((v.rows-1) * v.cols), v.cols, 20202020H);
    v.curon := cur;
    IF v.IsTop() THEN
      VR.ScrollUp( 1, v.x, v.y, v.x+v.w-1, v.y+v.h-1, v.ch);
      v.UpdateRect( v.x, v.y+v.h-v.ch, v.w, v.ch);
    ELSE
      v.UpdateRect( v.x, v.y, v.w, v.h);
    END;
  ELSIF cur THEN
    v.CursorOn
  END;
  CheckAbortion;
 END WriteLn;

(*---------------------------------WriteInt------------------------------*)

PROCEDURE(v : Viewer) WriteInt*(Value : LONGINT);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NumStr.LIntTo(Value,10,s); v.WriteString(s);
 END WriteInt;

(*---------------------------------WriteInt------------------------------*)

PROCEDURE(v : Viewer) WriteFInt*(Value : LONGINT; Base,Adj,Len : INTEGER; Fill : CHAR);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NumStr.LIntTo(Value,Base,s); Str.Adjust(Adj,Len,Fill,s); v.WriteString(s);
 END WriteFInt;

(*---------------------------------WriteReal-----------------------------*)

PROCEDURE(v : Viewer) WriteReal*(Value : REAL; n,Adj,Len : INTEGER; Fill : CHAR);
  VAR s : ARRAY 100 OF CHAR;
 BEGIN
  NumStr.RealTo(Value,n,s); Str.Adjust(Adj,Len,Fill,s); v.WriteString(s);
 END WriteReal;

(*---------------------------------Redraw--------------------------------*)

PROCEDURE(v : Viewer) Redraw(x,y,w,h : INTEGER);
  VAR x2, y2, firstc, lastc, firstx, maxc, maxy, d, i, DistBaseTop : INTEGER;
      c : CHAR;
      line : Line;
 BEGIN
  x2 := x+w-1; y2 := y+h-1;
  VC.VsClip( v.station, TRUE, x, y, x2, y2);
  VC.VsClip( station, TRUE, x, y, x2, y2);
  VO.VBar( v.station, x, y, x2, y2 );
  VI.VqtFontinfo(v.station,c,c,d,d,d,d,DistBaseTop,d,d,d,d);
  line := v.memory; y2 := v.y + v.ch;
  WHILE y2 <= y DO
    INC(line, v.cols); INC(y2, v.ch)
  END;
  DEC(y2, v.ch - DistBaseTop);
  firstc := (x - v.x) DIV v.cw; firstx := firstc * v.cw + v.x;
  maxc := w DIV v.cw + 2 + firstc; maxy := y + h + DistBaseTop;
  REPEAT
    lastc := maxc-1;
    WHILE (lastc >= firstc) AND (line[lastc] = " ") DO
      DEC(lastc);
    END;
    IF lastc >= firstc THEN
      VDI.Ptsin[0] := firstx; VDI.Ptsin[1] := y2;
      VDI.Ptsin[3] := 0; i := firstc; d := 0;
      WHILE i <= lastc DO VDI.Intin[d] := ORD(line[i]); INC(i); INC(d) END;
      VDI.Ptsin[2] := d; VDI.Call(8,0,v.station,01000000H + d*256);
    END;
    INC(y2, v.ch); INC(line, v.cols);
  UNTIL y2 >= maxy;
  IF v.curon THEN
    x2 := v.x + v.curx*v.cw;
    y2 := v.y + v.cury*v.ch;
    VO.VBar( station, x2, y2, x2+v.cw-1, y2+v.ch-1 );
  END;
 END Redraw;

(*---------------------------------SetEditStart--------------------------*)

PROCEDURE(v : Viewer) SetEditStart*;
  (* normally, the editing of a string starts in column zero. If there is
     a prompt or so, set the start at the current column with this
     procedure. After a handler call, the start is column 0 again. *)
 BEGIN
  v.edstart := v.curx;
 END SetEditStart;

(*---------------------------------Remove--------------------------------*)

PROCEDURE(v : Viewer) Remove*;
 BEGIN
  VC.VClsvwk( v.station);
  v.Remove^;
 END Remove;

(*---------------------------------HandleKeyEvent------------------------*)

PROCEDURE (v : Viewer) HandleKeyEvent*(shift : SET;
                               scan : INTEGER; ascii : CHAR) : BOOLEAN;
  VAR
    i: INTEGER;
    s: ARRAY 162 OF CHAR;
 BEGIN
  IF v.curon THEN
    LOOP
      IF shift = {} THEN
        IF scan = 52H THEN (* insert *)
          v.Insert
        ELSIF scan = 0EH THEN (* backspace *)
          IF v.curx > v.edstart THEN v.Backspace END;
        ELSIF scan = 4BH THEN (* cursor left *)
          IF v.curx > v.edstart THEN v.SetCursor(v.curx-1, v.cury) END;
        ELSIF scan = 4DH THEN (* cursor right *)
          v.SetCursor(v.curx+1, v.cury)
        ELSIF (scan = 1CH) OR (scan = 72H) THEN (* return/enter *)
          S.MOVE(v.memory + LONG(v.cury*v.cols+v.edstart), S.ADR(s), 160);
          i := v.cols-v.edstart-1;
          WHILE (i > 0) AND (s[i] = " ") DO DEC(i) END;
          s[i+1] := 0X;
          v.WriteLn; v.edstart := 0;
          v.handler(v, s);
        ELSIF ascii # 0X THEN
          v.WriteChar(ascii);
        ELSE
          EXIT
        END;
      ELSIF shift = {Evnt.LSHIFT} THEN
        IF scan = 53H THEN (* delete *)
          v.ClearEOL
        ELSIF scan = 0EH THEN (* backspace *)
          IF v.curx > v.edstart THEN v.Backspace END;
        ELSIF ascii # 0X THEN
          v.WriteChar(ascii);
        ELSE
          EXIT
        END;
      ELSIF ascii # 0X THEN
        v.WriteChar(ascii);
      ELSE
        EXIT
      END;
      RETURN TRUE
    END;
  END;
  RETURN v.HandleKeyEvent^(shift,scan, ascii);
 END HandleKeyEvent;

(*---------------------------------Module--------------------------------*)

BEGIN
  station := Graf.Handle(d, d, d, d);
  Workin.Id := 1; Workin.LineType := 1; Workin.LineColor := 1;
  Workin.MarkType := 1; Workin.MarkColor := 1; Workin.Font := 1;
  Workin.TextColor := 1; Workin.FillStyle := 1; Workin.FillPat := 0;
  Workin.FillColor := 1; Workin.KoorType := 2;
  VC.VOpnvwk(Workin,station,Workout);
  VA.VswrMode(station,VA.EXOR);
  VA.VsfPerimeter(station,FALSE);
  IF VC.GDOSinstalled() THEN d := VC.VstLoadFonts(station,0) END;
END TermWin.