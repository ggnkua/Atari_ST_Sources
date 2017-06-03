IMPLEMENTATION MODULE EdPro2; (* 2.10, 2.11 countblk, 2.12 BAK *)
(* 3.11 fix vert slide after merge *)
(* 3.10 slider based on full bigfile, allow save cfg anywhere *)
(* 2.40 horiz slider, fully moveable/resizable w/leftedge
   *)
(* 2.35 Re-install read-only check in Writefile using Fattrib; x
   Move FileAlert here from main EDHAK.MOD; x
   Fix buffsize & maxlines to limit maxlines to 0FFFFH in init code; x
   *)
(* 2.33... fix full disk non-error introduced in 2.30; x
   & fix a couple long(4*maxlines) to 4*long(maxlines); x
   & change SFirst to Open; x
   *)
FROM SYSTEM IMPORT ADR, ADDRESS, CODE, REGISTER, SETREG, PUSH;
(* FROM BIOS IMPORT BConOut, Device; *)
FROM GEMX IMPORT BasePageAddress; (* was pointer to BasePageType *)
(**
  BasePageType = RECORD       (* GEMDOS base page format *)
                   LowTPA   : ADDRESS ;
                   HiTPA    : ADDRESS ;
                   CodeBase : ADDRESS ;
                   CodeLen  : LONGCARD ;
                   DataBase : ADDRESS ;
                   DataLen  : LONGCARD ;
                   BssBase  : ADDRESS ;
                   BssLen   : LONGCARD ;
                   DtaPtr   : ADDRESS ;
                   ParentBasePage : ADDRESS ;
                   resvd1   : LONGCARD ;
                   EnvPtr   : POINTER TO ARRAY [0..79] OF CHAR ;
                   resvd2   : ARRAY [30H..7FH] OF CHAR ;
                   CmdLine  : ARRAY [0..79] OF CHAR ;
                 END ;
**)
FROM Mylib IMPORT MoveMem, Find;
FROM GEMDOS IMPORT Create, Open, Close, Read, Write, Seek, SeekMode;
     (* SFirst, SetDTA, Rename, Delete, GetDTA, GetDrv, GetPath *)(*, NecIn, ConWS *)
FROM GEMVDIbase IMPORT PxyArrayType, BigPxyArrayType,
     (* procs *) CallVDI,
                 SetContrl,
     (* vars  *) contrl,
                 intin,
                 ptsin;
(*ds*)
FROM VDIAttribs IMPORT SetWritingMode; (*, SetFillInteriorStyle, SetFillColour; *)
(*ds*)
FROM VDIControls IMPORT SetClipping;
(*
FROM VDIInputs IMPORT ShowCursor, HideCursor; (* v_show_c, v_hide_c *)
(* ShowCursor(0) forces display *)
*)
FROM VDIOutputs IMPORT FillRectangle;
FROM VDIRasters IMPORT CopyRasterOpaque;
IMPORT GEMAESbase;

FROM AESMenus IMPORT MenuRegister (* , MenuBar, MenuItemEnable,
     MenuTitleNormal *); 
FROM AESApplications IMPORT ApplInitialise, ApplWrite, ApplFind;

FROM AESGraphics IMPORT GrafMouse;
FROM AESForms IMPORT FormAlert, FileSelectorInput;
FROM AESWindows IMPORT WindowSet, WindowGet;
FROM Strings IMPORT Concat, Length;
FROM EdPlus IMPORT maxlines, RETURNKEY,
(*ds*)
     configname, (* bssbaselen, *)
(*ds*)
     D0,D1,D2,D3,A0,A1,A2,A7,              (* CONST *)
     Fseltype, Fsel0type, Pathtype,  (* arrays 0..100, 0..12, 0..88 OF CHAR *)
     DTA,       (* ARRAY[0..43] OF CHAR, GEM disk transfer adr buffer *)
     olddta,    (* address of pre-edhak DTA *)
     newlnptradr, (* 2.40 - remove local one! *)
     pipeBuff,
     daccTitle,            (* ARRAY[0..12] OF CHAR; *)
     diaryname,            (* Fsel0type *)
     cfg,                  (* Config RECORD *)
     newchar, typeahead, (* eolchar, *)       (* CHAR *)
     kreturn, line, lastline, saveline,
     linepos, newlinepos, lm, startcol, pageW, wrapW,
     lastcol, curdispline, linelen, displaylen, 
     vcurx, leftedge, blocktype,
     counter, outdev,   (* CARDINAL *)
     VDIHandle,         (* INTEGER *)
     Window1, topwind,            (* INTEGER *)
     ismdx, ok, bigpart, saved, (* BOOLEAN *)
     Appl, dacc, (* maxX,*) maxY, vcury,
     fullX, fullY, fullW, fullH,
     (* wind1X, wind1Y, wind1W, *) wind1H,
     workX,workY,workW,workH, rowH, colW,  (* INTEGER *)
     accbuffsize, buffsize, newbuffsize,   (* LONGCARD *)
(*
     newmaxbuff, newminsys,  (* LONGCARD *)
*)
     ptr1, ptr2,             (* POINTER TO CHAR *)
     cardptr,                (* POINTER TO CARDINAL *)
     longptr, adrptr,        (* POINTERs TO LONGCARD, ADDRESS *)
     startadr, lineAadr, screenadr, bpadr, lnptradr, (* ADDRESS *)
     mhideptr,        (* POINTER TO INTEGER *)
     mfdb,            (* POINTER TO MFDBType *)
     clipxy2,         (* PxyArrayType : clipping rectangle *)
     startf, endf, fileend, (* LONGCARD, pointers to start/end of bigpart *)
     i, last, lasti, blockstart,
     blockend, delstart,
     pastelen, tmplong,
(*ds*)
     configpath,        (* Pathtype = ARRAY[0..32] OF CHAR *)
(*ds*)
     fsel,              (* Fseltype = ARRAY[0..40] OF CHAR *)
     notistrg,          (* ARRAY [0..9] OF CHAR for Notice *)
     InitMenu,       (* procedures *)
     PageBigFile,
     ShowNew;

CONST (* offsets from lineAadr *)
  bssbaselen = 000013F0H; (* adds buffline *)
(*
   13EE EditPlus
   13DE EditPro Config file size
   139C w/block menu (maxitems = 35)
   12A0 w/membot & ??
   1298 w/unshiftptr,shiftptr,capslockptr
   0128CH; (* w/menuok *)
   128A w/ DTA & olddta
   125A w/100 byte fsel's, 896 byte stack
   10BE w/mhideptr+cfg.autoindent...
   10B6 with kbshiftadr
   10B2 for 2.30 w/stalkid & ishex
   10B0 for 2.25 w/new GEMX. 
   1030 for 2.24  ds 00BE8H;
*ds*)
  D4 = 4;
  A4 = 12;
(*
  StackSize = 256; (* words = 512 bytes *)
  maxlines = (*** 200;***) 1000; (* 500 for 10K, 200 for 4K *)(* adjust if want more (shorter) lines *)
*)
(**
   VCELWR  = -028H; (* -40 *) (* 2 bytes, bytes to next vert char cell *)
**)

VAR
(*
    Stack: ARRAY [0..StackSize] OF CARDINAL;
*)
(*
    newlnptr: ARRAY[0..maxlines] OF CARDINAL; (* tmp array for word wrap & for undo buffer *)
    daccTitle: ARRAY[0..12] OF CHAR;
*)
(** (* needed for debug routines only *)
    cardstrg   : ARRAY[0..5] OF CHAR;
    ch  :    CHAR;
**)
    isroom : BOOLEAN;
    j, k, tmpln (*, vcurx, endofline, blocklen *) : CARDINAL;

    handle, int, dummy, fillcolor (*, vcury *)   :      INTEGER;
    (* Appl :         INTEGER ; *)
    jlong, klong, endofline, blocklen, count :     LONGCARD;

    wrapadr, vcurad (* junkadr, was newlnptradr *) : ADDRESS;
    pxy4       : BigPxyArrayType;
(*
    diaryname: Fsel0type;
*)
    (* bpadrptr, bssptr: POINTER TO ADDRESS; *)
    (* macroptr: POINTER TO Macrotype; *)

PROCEDURE Showmouse; (* (wantcount: INTEGER); *)
(* get hidecount, call showmouse that number of times *)
VAR hidden: INTEGER;
BEGIN
  hidden:= mhideptr^;
  LOOP
    IF hidden > 0 THEN
      CODE(0A009H); (* lineA Show mouse *)
      DEC(hidden);
    ELSE
      EXIT;
    END;
  END;
END Showmouse;

(***
PROCEDURE ShowCursor(Reset: INTEGER);
(* show mouse *)
BEGIN
  intin[0]:= Reset; (* 0 means force show *)
  SetContrl(122, 0, 1, 0, VDIHandle);
  CallVDI;
END ShowCursor;

PROCEDURE HideCursor;
(* Hide mouse *)
BEGIN
  SetContrl(123, 0, 0, 0, VDIHandle);
  CallVDI;
END HideCursor;
***)

PROCEDURE Bconout(ch : CHAR; device: CARDINAL);
(* device 5 = full 255 char set, 0 = PRT, 1 = AUX(RS232), 2 = CON *)
(* 3 = midi, 4 = IKDB *)
VAR x : CARDINAL; (* word-length version of ch *)
BEGIN
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  x:= ORD(ch);
  PUSH(x);
  PUSH(device); (* see if this works ?? It does! *)
  PUSH(3);
  CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all registers used *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
END Bconout;

PROCEDURE Bcosstat(device, inout: CARDINAL): BOOLEAN;
(* check output or input device ready status, TRUE = ready *)
(* 0=PRN, 1=AUX, 2=CON, 3=MIDI, 4=full 256 char display *)
(* 8 = output, 1 = input *)
BEGIN
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  PUSH(device); (* see if this works ?? It does! *)
  PUSH(inout); (* input or output, 1 or 8 *)
  CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
  CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
  (* restore all registers used *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  IF REGISTER(D0) = 0 THEN (* device not ready or chars not waiting *)
    RETURN FALSE;
  END;
  RETURN TRUE;
END Bcosstat;

PROCEDURE BconinGetBPB(devdrive, opcode: CARDINAL): LONGCARD;
(* use INTEGER() for conin, ADDRESS() for bpbptr *)
(* dev: 0=PRN, 1=AUX, 2=CON, 3=MIDI, 4=IKBD, 5=full 256 char display *)
(* drive: 0=A:, 1=B: etc. *)
(* opcode: 7 = GetBPB, 2 = bconin *)
BEGIN
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  PUSH(devdrive); (* see if this works ?? It does! *)
  PUSH(opcode); (* conin or getbpb, 2 or 7 *)
  CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
  CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
  (* restore all registers used *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  RETURN LONGCARD(REGISTER(D0));
END BconinGetBPB;

PROCEDURE Kbshift(VAR int: INTEGER);
BEGIN
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  PUSH(-1); (* mode = Read keyboard shift status *)
  PUSH(11);
  CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
  CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
  int:= INTEGER(REGISTER(D0));
  (* restore all registers used *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
END Kbshift;


PROCEDURE Graphictext(Handle, x, y: INTEGER; stradr: ADDRESS;
                      strlen: CARDINAL);
VAR (* saveA4, saveD4: ADDRESS; *)
    idx, tmplen, sumlen: CARDINAL; (* counter *)
(* write text to display surface *)
(* time critical? ... yes, and there IS something I can do about that *)
 PROCEDURE Stringout;
 BEGIN
   idx:= 0;
   WHILE idx < tmplen DO
     intin[idx]:= ORD(ptr1^);
     INC(ptr1);
     INC(idx);
   END;
 (***)
   SetContrl(8, 1, INTEGER(tmplen), 0, Handle);
   ptsin[0]:= x;
   ptsin[1]:= y;
   CallVDI;
 END Stringout;

BEGIN (* main graphictext *)
(***
  saveA4:= REGISTER(A4);
  saveD4:= REGISTER(D4);
  SETREG(A4, stradr);
  SETREG(A0, ADR(intin));
  SETREG(D4, strlen);
  CODE(05288H); (* 0101 0010 1000 1000 *)(* addq.l #1,a0 to get low byte *)
  CODE(05344H); (* 0101 0011 0100 0100  subq.w #1,d4 ; for dbra counter *)
(* fillloop  *)
  CODE(0109CH); (* move.b  (a4)+,(a0) *)
  CODE(05488H); (* addq.l  #2,a0 *)
  CODE(051CCH,0FFFAH); (* 0101 0001 1100 1100 *)(* dbra d4,fillloop *)
***)
  ptr1:= stradr;
(****
  idx:= 0;
  WHILE idx < tmplen DO
    intin[idx]:= ORD(ptr1^);
    INC(ptr1);
    INC(idx);
  END;
(***)
  SetContrl(8, 1, INTEGER(tmplen), 0, Handle);
  ptsin[0]:= x;
  ptsin[1]:= y;
  CallVDI;
****)
  sumlen:= 0;
  LOOP
    IF strlen > sumlen THEN
      tmplen:= Min(strlen - sumlen, 128);
    ELSE (* done *)
      EXIT;
    END;
    Stringout;
    INC(sumlen, tmplen); (* ptr1 inc's itself in Stringout *)
    INC(x, INTEGER(tmplen) * colW);
  END; (* loop *)
(*
  SETREG(A4, saveA4);
  SETREG(D4, saveD4);
*)
END Graphictext;


PROCEDURE Conzap(chx: CHAR);
(* use VDI vgtext output *)
VAR strg: ARRAY[0..1] OF CHAR;
BEGIN
  Graphictext(VDIHandle, INTEGER(vcurx)*colW, vcury+rowH, ADR(chx), 1);
  INC(vcurx);
END Conzap;

PROCEDURE CursorPos(y, x: CARDINAL);  (* row, column *)
(* assembly replacement for vt52 esc-Y or VDI CursorAddress *)
BEGIN
  DEC(y); (* since parameters being passed were based on first = 1 *)
  vcurx:= x - 1;
(*
  vcury:= INTEGER(y) * rowH-1; (* -3 for mono vdi baseline offset *)
*)
(** get rid of topdispline, so no longer based on 25 set rows **)
  vcury:= workY + (INTEGER(y+1) * rowH) - 1; (* -3 for mono vdi baseline offset *)
END CursorPos;

PROCEDURE CursorDraw;
(* toggles cursor on/off at current screen address, vcurad *)
VAR cursH, cursY: INTEGER; (* cursor height, 2.30 1/9/92 *)
BEGIN
  cursH:= rowH;
  cursY:= vcury+1;
  IF NOT cfg.insertmode THEN
    cursH:= 2; (* for overwrite mode *)
    cursY:= vcury + rowH-1;
  END;

  dummy:= SetWritingMode(VDIHandle, 3); (* XOR *)
  SetClipFill(INTEGER(vcurx)*colW, cursY, colW, cursH, FALSE); (* was vcury+3 *)
  dummy:= SetWritingMode(VDIHandle, 1); (* replace *)
END CursorDraw;


(*$S-,$T- *)
PROCEDURE Compare(strg1, strg2: ARRAY OF CHAR): BOOLEAN;
VAR i: CARDINAL; (* for exact match only *)
BEGIN
(*
  IF INTEGER(Length(strg2)) - INTEGER(Length(strg1)) <> 0 THEN
    RETURN FALSE; (* prevent erroring out later? *)
  END;
*)
  i:= 0;
  REPEAT
    IF strg1[i] <> strg2[i] THEN
      RETURN FALSE;
    END; (* if *)
    INC(i);
  UNTIL strg1[i-1] = 0C; (* even checks null at end of strgs *)
  RETURN TRUE;
END Compare;


PROCEDURE Min(a,b : CARDINAL) : CARDINAL;
BEGIN
  IF a < b THEN RETURN a;
  END;
  RETURN b;
END Min;

PROCEDURE Max(a,b : CARDINAL) : CARDINAL;
BEGIN
  IF a > b THEN RETURN a;
  END;
  RETURN b;
END Max;

PROCEDURE SetClipFill(x,y,w,h: INTEGER; setclip: BOOLEAN);
(* sets clipxy2 rect or fills/clears xywh area *)
VAR pxyarray2: PxyArrayType;
BEGIN
 (* are these two precautions needed for anything? *)
  (* may screw up Window3 closing redraw *)
(**
  IF x < 0 THEN
    x:= 0;
  END;
  IF y < workY THEN
    y:= workY;
  END;
**)
  pxyarray2[0] := x ;
  pxyarray2[1] := y ;
  pxyarray2[2] := x + w - 1 ;
  pxyarray2[3] := y + h - 1 ;
  (* limit to screen coords, 3.02 *)
  IF pxyarray2[3] > maxY THEN
    pxyarray2[3]:= maxY;
  END;
  IF pxyarray2[2] > fullW THEN
    pxyarray2[2]:= fullW;
  END;

  IF setclip THEN
    clipxy2:= pxyarray2;
  ELSE
    FillRectangle(VDIHandle, pxyarray2) ;
  END; (* if setclip *)
END SetClipFill;

(**
PROCEDURE ClearArea(x,y,w,h: INTEGER);
VAR pxyarray2: PxyArrayType;
BEGIN
  pxyarray2[0] := x ;
  pxyarray2[1] := y ;
  pxyarray2[2] := x + w - 1 ;
  pxyarray2[3] := y + h - 1 ;
  FillRectangle(VDIHandle, pxyarray2) ;
END ClearArea ;
**)

PROCEDURE Blit(x,y,w,h, newX,newY: INTEGER);
BEGIN
(* non-multiTOS, simple version *)
  DEC(h);
  pxy4[0]:= x;     pxy4[1]:= y;     pxy4[2]:= x+w;     pxy4[3]:= y+h;
  pxy4[4]:= newX;  pxy4[5]:= newY;  pxy4[6]:= newX+w;  pxy4[7]:= newY+h;

  (* limit to screen coords, 3.02 *)
  IF (pxy4[3] > maxY) OR (pxy4[7] > maxY) THEN
    IF newY < y THEN
      pxy4[3]:= maxY;
      pxy4[7]:= maxY - (y - newY);
    ELSE
      pxy4[3]:= maxY + (newY - y);
      pxy4[7]:= maxY;
    END;
  END;
(**)
  IF pxy4[2] > fullW THEN
    pxy4[2]:= fullW;
  END;
(**)
  CopyRasterOpaque(VDIHandle, 3, pxy4, mfdb, mfdb);
END Blit;


PROCEDURE Findend(ln: CARDINAL): LONGCARD;
(* returns index of first eol character *)
VAR longptr: POINTER TO LONGCARD;
BEGIN
  IF ln = lastline THEN (* no next lnptr *)
    endofline:= last; (* since last has no value *)
  ELSE
    longptr:= lnptradr + ADDRESS(4*LONG(ln) + 4); (* x4 for 4 bytes/index *)
    endofline:= longptr^ - LONG(cfg.eollen);
  END;
  IF (cfg.eollen = 0) & (endofline > 0) & (ln <> lastline) THEN
    DEC(endofline);
  END;
  RETURN endofline;
END Findend;

PROCEDURE SetSlideSize;
VAR tmplast: LONGCARD; (* 3.12 *)
BEGIN
  (* try basing it on whole file, not just what's in buffer *)
  IF (startf > 0) OR (endf < fileend) THEN (* bigfile *)
    tmplast:= fileend;
    IF last > lasti THEN
      INC(tmplast, last - lasti);
    ELSE
      DEC(tmplast, lasti - last);
    END;
    int:= SHORT((LONG(cfg.maxdispline+1) * 1000) DIV (fileend DIV (last DIV LONG(lastline)) + 1) );
(**)
  ELSE
    int:= ((cfg.maxdispline+1) * 1000) DIV (lastline + 1); (* vert slider size *)
  END;
(**)

  IF int < 5 THEN
    int:= -1; (* minimum (square) size *)
  ELSIF int > 1000 THEN
    int:= 1000; (* max *)
  END; (* if *)
  WindowSet(Window1, GEMAESbase.VertSliderSize, int, dummy,dummy,dummy);
END SetSlideSize;

PROCEDURE SetSlidePos; (*  Set Vert Slider Position, 0..1000 *)
(* Needs to be done anytime line or lastline changes *)
VAR tmplast: LONGCARD; (* 3.11 *)
BEGIN
  int:= 0; (* assume at top unless found otherwise, avoids ELSE's *)
  IF (startf > 0) OR (endf < fileend) THEN (* bigfile *)
    (* 3.11 *)
    tmplast:= fileend;
    IF last > lasti THEN
      INC(tmplast, last - lasti);
    ELSE
      DEC(tmplast, lasti - last);
    END;

    IF (startf > 0) OR (line > 0) THEN
      longptr:= lnptradr + ADDRESS(4*LONG(line+cfg.maxdispline));
      int:= INTEGER(((startf+longptr^) * 1000) DIV (tmplast + 1)); (* temp vert slider size *)
    END;
(**)
  ELSE
    IF (* (line > 0) & *) lastline > cfg.maxdispline THEN
      int:= INTEGER(SHORT(LONG(line)*1000 DIV LONG(lastline - cfg.maxdispline)));
    END; (* if anywhere to move slide *)
  END; (* if bigfile *)
(**)
  WindowSet(Window1, GEMAESbase.WindowVertSlide, int, dummy,dummy,dummy);
END SetSlidePos;

PROCEDURE SetHSlidePos; (*  Set Horiz Slider Position, 0..1000 *)
(* Needs to be done anytime startcol changes *)
BEGIN
  int:= 0; (* assume at top unless found otherwise, avoids ELSE's *)
  IF startcol > 0 THEN
    int:= INTEGER(SHORT(LONG(startcol)*1000 DIV LONG(lastcol (* - displaylen *) )));
  END;
  WindowSet(Window1, GEMAESbase.WindowHorizSlide, int, dummy,dummy,dummy);
  SetHSlideSize;
END SetHSlidePos;

PROCEDURE SetHSlideSize;
BEGIN
  int:= INTEGER(SHORT((LONG(displaylen) * 1000) DIV LONG(lastcol)));
  IF int < 5 THEN
    int:= -1; (* minimum (square) size *)
  ELSIF int > 1000 THEN
    int:= 1000; (* max *)
  END; (* if *)
  WindowSet(Window1, GEMAESbase.HorizSliderSize, int, dummy,dummy,dummy);
END SetHSlideSize;

PROCEDURE Findline(index: LONGCARD): CARDINAL;
(* finds which line a given text buffer index is on, after a search *)
VAR ln: CARDINAL;
   (* KEEP longptr global for Wrapblock Pattie fix *)
BEGIN
  ln:= 0;
(**
  WHILE (cardptr^ <= index) & (ln <= lastline) DO
    INC(ln);
    cardptr:= ADDRESS(cardptr) + 2;
  END; (* while *)
  RETURN ln - 1;
**)
(** following is MUCH faster than above single line method **)
  longptr:= lnptradr;
  WHILE (longptr^ <= index) & (ln <= lastline) DO
    INC(ln, 30);
    longptr:= ADDRESS(longptr) + 120; (* 4 bytes per line *)
  END; (* while zeroing in *)
  IF ln > lastline THEN
    ln:= lastline + 1;
    longptr:= lnptradr + ADDRESS(4*LONG(ln));
  END;
  REPEAT
    DEC(ln);
    longptr:= ADDRESS(longptr) - 4;
  UNTIL longptr^ <= index;
  RETURN ln;  
END Findline;

PROCEDURE Findscrn(xpos: CARDINAL);
(* Sets startcol for display of screen containing xpos *)
BEGIN
  IF xpos > startcol + displaylen THEN (* need to adjust *)
    startcol:= xpos - displaylen + 10;
  ELSIF xpos < startcol THEN
    IF xpos >= 10 THEN
      startcol:= xpos - 10;
    ELSE (* xpos < 10 *)
      startcol:= 0;
    END;
  END;
(**+
  startcol:= 0;
  WHILE startcol + displaylen < xpos DO
    INC(startcol, pageW);
  END;
+**)
END Findscrn;

PROCEDURE CheckStart;
BEGIN
  IF startcol > 0 THEN
    startcol:= 0;
    Display(0, cfg.maxdispline);
    SetHSlidePos;
  END;
END CheckStart;


PROCEDURE Redraw(x,y,w,h: INTEGER); (* rectangle to redraw *)
VAR wx,wy,ww,wh: INTEGER; (* window x,y,w,h *)
BEGIN (* main Redraw *)
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy); (* wx,wy,ww,wh); *)
(*
  Box(x,y,w,h);
*)
  (* WindowUpdate(1); (* begin, ends at end of redraw *) *)
  IF Window1 = topwind THEN
    InitMenu; (* ?? *)
(*
    SetClipxy(x, y, w, h); (* -6 & +6 are for the dropdown menu *)
*)
    SetClipFill(x, y, w, h, TRUE);
    SetClipping(VDIHandle, 1, clipxy2);
    Display(0, cfg.maxdispline);
  ELSE (* Window1 is covered at least partially or is just not topped! *)
    CODE(0A00AH);  (* LineA hide mouse *)
    WindowGet(Window1,GEMAESbase.FirstXYWH, wx,wy,ww,wh);
    (* Windfix;(**??**) *)
    WHILE (ww > 0) & (wh > 0) DO
(** 2.30 1/18/92 ??? *)
(*
      (* IS something sticking out *)
      IF (wx < x) OR (wx+ww > x+w) OR (wy < y) OR (wy+wh > y+h) THEN (* redraw area *)
*)
(**
      (* IS some overlap *)
      IF (x < wx+ww) & (wx < x+w) & (y+h < wy) & (wy+wh < y) THEN (* redraw area *)
**)
      (* original: (hybrid?) *)
      IF (x < wx+ww) & (wx < x+w) & (y < wy+wh) & (wy < y+h) THEN (* redraw area *)
(*
        SetClipxy(wx, wy, ww, wh);
*)
        SetClipFill(wx, wy, ww, wh, TRUE);
        SetClipping(VDIHandle, 1, clipxy2);
        Display(0, cfg.maxdispline);
      END; (* if area needs redraw *)
      WindowGet(Window1, GEMAESbase.NextXYWH, wx,wy,ww,wh);
    END; (* while checking for rectangles to redraw *)
    Showmouse;  (* LineA show mouse, not top wind *)
  END; (* if topwind *)
  (* WindowUpdate(0); (* end *) *)
  SetClipping(VDIHandle, 0, clipxy2);
(*
  SetClipxy(1,1,maxX,maxY); (* -2? *)
*)
  SetClipFill(1,1,fullW (* maxX *), maxY, TRUE);
  SetClipping(VDIHandle, 1, clipxy2);
END Redraw;


PROCEDURE ShowBlock(startln, endln: CARDINAL; startb, endb: LONGCARD);
(* hilites selected block *)
VAR j, endshow, startshow, lnlen, startbcol, endbcol: CARDINAL;
    startX, endX, y: INTEGER;
BEGIN
  IF blocktype = 1 THEN
    startshow:= Max(Findline(startb), startln);
    endshow:= Min(Findline(endb), Min(endln, lastline));

    IF (startshow <= line + cfg.maxdispline) & (endshow >= line) THEN
      (* block exists somewhere in window *)
      (* Set VDI fill attributes *)
      dummy:= SetWritingMode(VDIHandle, 3); (* XOR *)
      (* find what column to start hiliting in *)
      (*** here, lnlen is distance to start of block ***)
      (* get starting # of chars from start of line *)
      longptr:= lnptradr + ADDRESS(4*LONG(startshow));
      lnlen:= 0;
      IF startb > longptr^ THEN
        lnlen:= SHORT(startb - longptr^);
      END;
      (* looks strange to handle if startshow > line of startb *)
      startX:= workX + colW;
      IF lnlen > startcol THEN
        startX:= workX + colW * INTEGER(lnlen - startcol + 1);
      END;
      IF lnlen > startcol + pageW THEN (* starts to right of this window *)
        INC(startshow);
        startX:= workX + colW;
      END; (* if beyond this window *)
      y:= workY + INTEGER(startshow - line) * rowH;
      WHILE startshow <= endshow DO
        (* find endX *)
        longptr:= lnptradr + ADDRESS(4*LONG(startshow));
        tmplong:= Findend(startshow) + 1;
        lnlen:= SHORT(endb - longptr^);
        IF tmplong < endb THEN
          lnlen:= SHORT(tmplong - longptr^);
        END;
        IF lnlen > startcol THEN (* is something there on that line *)
          j:= Min(lnlen - startcol, pageW);
          (* in case block end and end of line are beyond window *)
          INC(j);
          endX:= workX + colW * INTEGER(j);
          (* fill area per current style *)
          SetClipFill(startX, y, endX - startX, rowH, FALSE);
        END; (* if anything on that line *)
        startX:= workX + colW; (* assuming const left margin *)
        INC(startshow);
        INC(y, rowH);
      END; (* while *)
      (* Reset VDI fill attributes *)
      dummy:= SetWritingMode(VDIHandle, 1); (* replace *)
    END; (* if any part of block in window *)
  ELSE (* blocktype=2, column block *)
    startshow:= Findline(startb);
    longptr:= lnptradr + ADDRESS(4*LONG(startshow));
    startbcol:= SHORT(startb - longptr^);
    (* 3.02 *)
    IF startbcol < startcol THEN
      startbcol:= startcol;
    END;

    endshow:= Findline(endb);
    longptr:= lnptradr + ADDRESS(4 * LONG(endshow));
    endbcol:= SHORT(endb - longptr^);
  
    startshow:= Max(startshow, startln);
    endshow:= Min(endshow, Min(endln, lastline));
  
    IF (startshow <= line + cfg.maxdispline) & (endshow >= line) &
       (startbcol <= startcol + pageW) & (endbcol >= startcol) THEN
      (* block exists somewhere in window *)
      IF (endbcol > startbcol) THEN (* valid col block *)
        (* Set VDI fill attributes *)
        dummy:= SetWritingMode(VDIHandle, 3); (* XOR *)
        (* find what column to start hiliting in *)
        startX:= workX + colW * INTEGER(startbcol - startcol + 1);
        y:= workY + INTEGER(startshow - line) * rowH;

        endX:= workX + colW * INTEGER(endbcol - startcol + 1);
        IF endX > workX + workW THEN (* 3.0D *)
          endX:= workX + workW;
        END;
        WHILE startshow <= endshow DO
          SetClipFill(startX, y, endX - startX, rowH, FALSE); (* do fill *)
          INC(startshow);
          INC(y, rowH);
        END; (* while *)
        (* Reset VDI fill attributes *)
        dummy:= SetWritingMode(VDIHandle, 1); (* replace *)
(****
      ELSE
        blocktype:= 0;
******)
(*
        Ruinblock(TRUE);
*)
      END; (* if valid col blk *)
    END; (* if any part of block in window *)
  END; (* if blocktype=1 *)
END ShowBlock;


PROCEDURE Findxpos(x: INTEGER): CARDINAL;
(* returns linepos of absolute pixel x coord, e.g., from mouse click *)
(* does not adjust for being beyond end of line.  See Downup. *)
BEGIN
  IF x - workX < colW THEN
    RETURN 0;
  END;
  j:= SHORT(LONGCARD(ABS(x-workX-colW)) * LONG(displaylen+lm) DIV LONGCARD(workW-colW+2));
  RETURN Min(j, displaylen); (* don't return anything outside work area *)
END Findxpos;

PROCEDURE Finddispline(y: INTEGER; limit: BOOLEAN): CARDINAL;
(* finds which text line in window corresponds to a Y screen position *)
VAR displine: CARDINAL;
BEGIN
  IF y <= workY THEN (* was < *)
    RETURN 0; (* was <= *)
  ELSIF y > workY + workH THEN (* below work area *) (* was >= *)
    displine:= cfg.maxdispline;
  ELSE
    displine:= CARDINAL((y - workY) DIV rowH); (* rowH = workH/(cfg.maxdispline+1) *)
  END;
  IF limit & (displine > lastline - line) THEN (* is below last displayed line *)
    RETURN lastline - line;
  END; (* if need to adjust up to find some text *)
  RETURN displine;
END Finddispline;

PROCEDURE Lineout(ln, startpos, endpos: CARDINAL);
(* outputs one line of text at current cursor position *)
(* followed by eol character -- or extention arrow if line is too long *)
VAR (* j, k, max: CARDINAL; *)
    jlong, klong: LONGCARD;

  PROCEDURE Outchar;
  BEGIN
    ptr1:= startadr + ADDRESS(jlong);
    Conzap(ptr1^); (* Bconout(ptr1^, 5); *)(* BConOut(CON, ptr1^);*)
    INC(jlong);
  END Outchar;

BEGIN
(*
  SetClipFill(workX, workY + rowH*(INTEGER(ln-line)), workW, rowH, FALSE);
*)
  endofline:= Findend(ln);
  IF (cfg.eollen = 0) & (ln <> lastline) THEN
    INC(endofline);
  END;
(*
  j:= lnptrarray[ln] + startpos + startcol;
  k:= Min(endofline, lnptrarray[ln] + endpos + startcol); (* end array index *)
*)
  longptr:= lnptradr + ADDRESS(4*LONG(ln)); (* ptr to start of line *)
  (* check for max line length for horiz slider *)
  j:= SHORT(endofline - longptr^); (* line length *)
  IF j > lastcol THEN
    lastcol:= j;
  END; (* if new longer longest line for horiz slider *)
  jlong:= LONG(startcol + startpos) + longptr^;
  klong:= LONG(startcol + endpos) + longptr^;
  IF klong > endofline THEN
    klong:= endofline; (* end array index *)
  END; 
(**
  WHILE (jlong < klong) DO
    Outchar; (* inc's j *)
  END; (* for that line *)
**)
  IF klong > jlong THEN
    DEC(klong, jlong);
    Graphictext(VDIHandle, INTEGER(vcurx)*colW, vcury+rowH,
              startadr+ADDRESS(jlong), SHORT(klong));
    INC(vcurx, klong);
    INC(jlong, klong);
  END;
  IF (jlong < endofline) & (clipxy2[2] >= workX+workW-2) THEN (* line too long for window *)
    Outchar;
    (* Bconout(CHR(3), 5); (* big rt arrow *) *)
  ELSIF (ln <> lastline) & (jlong = endofline) & (cfg.eollen > 0) &
    ((jlong < longptr^ + LONG(endpos)) OR (endpos = displaylen)) THEN
    Conzap(cfg.eolchar); (* Bconout(eolchar, 5); *)
  END; (* if extended line *)
END Lineout;


PROCEDURE Display2(displine, enddispline: CARDINAL);
(* print block of lines starting with line from displine..enddispline *)
VAR startpos, endpos: CARDINAL;
    minln, maxln, countint: INTEGER;
BEGIN
  (* find clipping limits in terms of char position and displayline *)
  minln:= INTEGER(Finddispline(clipxy2[1], TRUE)); (* +int, top clip display line *)
  (* check if top of start row goes beyond clip area *)
  maxln:= INTEGER(Finddispline(clipxy2[3], TRUE)); (* -int, bottom clip display line *)
  (* check if bottom of end row goes beyond clip area *)
  (* Clear Area: *)
  SetClipFill(workX, workY + rowH*(INTEGER(displine)),
            workW, rowH*(1 + INTEGER(enddispline-displine)), FALSE);
  IF maxln >= minln THEN
    startpos:= Findxpos(clipxy2[0] (*+ +2 +*) ); (* linepos of left clip extent *)
    endpos:= Min(displaylen, Findxpos(clipxy2[2]-3)+1); (* linepos of right clip extent *)
    countint:= minln;
    WHILE countint <= maxln DO (* show that line *)
      CursorPos(CARDINAL(countint), leftedge+startpos);
      Lineout(CARDINAL(countint)+line, startpos, endpos);
      INC(countint);
    END; (* while countint <= maxln display line *)
(*ds*)
    IF blocktype > 0 (* isblock *) THEN
      ShowBlock(line + CARDINAL(minln), line + CARDINAL(maxln),
                blockstart, blockend);
      SetClipFill(1, 1, fullW (* maxX *), maxY, TRUE);
      SetClipping(VDIHandle, 1, clipxy2);
    END;
(*ds*)
  END; (* if maxln >= minln *)
  CursorPos(curdispline, leftedge+linepos);
END Display2;

PROCEDURE Display(displine, enddispline: CARDINAL);
(** MultiTOS version, by rect list: **)
VAR wx,wy,ww,wh: INTEGER; (* window x,y,w,h *)
BEGIN (* MultiDisp *)
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy); (* wx,wy,ww,wh); *)
  IF Window1 = topwind THEN
    Display2(displine, enddispline);
  ELSE (* Window1 is covered at least partially or is just not topped! *)
    WindowGet(Window1,GEMAESbase.FirstXYWH, wx,wy,ww,wh);
    WHILE (ww > 0) & (wh > 0) DO
      IF (workX < wx+ww) & (wx < workX+workW) & (workY < wy+wh) & (wy < workY+workH) THEN (* redraw area *)
        SetClipFill(wx, wy, ww, wh, TRUE);
        SetClipping(VDIHandle, 1, clipxy2);
        Display2(displine, enddispline);
      END; (* if area needs redraw *)
      WindowGet(Window1, GEMAESbase.NextXYWH, wx,wy,ww,wh);
    END; (* while checking for rectangles to redraw *)
  END; (* if topwind *)
  SetClipping(VDIHandle, 0, clipxy2);
  SetClipFill(1,1,fullW (* maxX *), maxY, TRUE);
  SetClipping(VDIHandle, 1, clipxy2);
END Display;


PROCEDURE DisplayLine(displine: CARDINAL);
VAR wx,wy,ww,wh: INTEGER;
    ln: CARDINAL;
(* doesn't need to worry about clipping since only gets called
   when Diary is top window *)
BEGIN
  ln:= line + displine;
  SetClipFill(workX, workY + rowH*(INTEGER(displine)), workW, rowH, FALSE);
  CursorPos(displine, leftedge);
  Lineout(ln, 0, displaylen);
  IF blocktype > 0 (* isblock *) THEN
    ShowBlock(ln, ln, blockstart, blockend);
  END;
(*
  SetSlidePos;
*)
END DisplayLine;

PROCEDURE Scrolldown;
VAR cutH: INTEGER;
BEGIN
  INC(line);
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy); (* wx,wy,ww,wh); *)
  IF Window1 = topwind THEN
    Blit(workX, workY+rowH, workW, workH-rowH, workX, workY);
    cutH:= maxY - workY;
    IF cutH >= workH THEN
      DisplayLine(cfg.maxdispline);
    ELSE (* some of window off screen *)
      int:= cutH DIV rowH;
      DisplayLine(int);
      IF int > 0 THEN      
        DisplayLine(int - 1);
      END;
    END;
  ELSE
    Display(0, cfg.maxdispline);
  END; (* if topwind *)
  SetSlidePos;
END Scrolldown;

PROCEDURE Scrollup;
BEGIN
  DEC(line);
  WindowGet(Window1, GEMAESbase.Top, topwind, dummy,dummy,dummy); (* wx,wy,ww,wh); *)
  IF Window1 = topwind THEN
    Blit(workX, workY, workW, workH-rowH, workX, workY+rowH);
    DisplayLine(0);
  ELSE
    Display(0, cfg.maxdispline);
  END; (* if topwind *)
  SetSlidePos;
END Scrollup;

 
PROCEDURE Rtarrow;
BEGIN
  IF (i < last) THEN (* is someplace for it to go *)
    tmpln:= line + curdispline;
    longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
    linelen:= SHORT(Findend(tmpln) - longptr^);
    IF linepos + startcol >= linelen THEN
      (* to next line *) (* check if line extends beyond window *)
      IF line + curdispline < lastline THEN (* is line to move to *)
        INC(curdispline);
        longptr:= ADDRESS(longptr) + 4;
        i:= longptr^;
        linepos:= 0;
        CheckStart;
        IF curdispline > cfg.maxdispline THEN (* scroll down *)
          Scrolldown;
          curdispline:= cfg.maxdispline;
         ELSE (* just move to start of next line *)
        END; (* if need to scroll *)
      (* at end of displayable part of last line, so do nothing *)
      END; (* if is another line *)
    ELSIF linepos >= displaylen THEN  (* at end of display window *)
      (* so shift screen to include end of line *)
      ScrnRt(10);
      INC(i);
      INC(linepos);
    ELSE (* just move cursor right on current line *)
      INC(i);
      INC(linepos);
    END; (* if go to next line *)
    CursorPos(curdispline, leftedge + linepos);
  ELSE
    IF (endf < fileend) & PageBigFile(TRUE, TRUE) THEN (* forward, ask *)
      ShowNew;
    END;
  END; (* if i < last *)
END Rtarrow;

PROCEDURE Leftarrow;
BEGIN
  IF i > 0 THEN (* is room to move it left *)
    IF (linepos = 0) THEN (* goto prior line *)
      IF startcol = 0 THEN (* find where to put cursor in prior line *)
        tmpln:= line + curdispline - 1;
        i:= Findend(tmpln);
        longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
        linelen:= SHORT(i - longptr^);
        IF linelen > displaylen + startcol THEN
          (* need to shift screen to include end of line *)
          Findscrn(linelen); (* sets startcol *)
          linepos:= linelen - startcol;
          Display(0, cfg.maxdispline);
          SetHSlidePos;
        ELSE
          linepos:= linelen;
        END; (* if it's an extended line *)
        IF (curdispline = 0) THEN (* scroll up *)
          Scrollup;
        ELSE
          DEC(curdispline);
        END;  (* if need to scroll *)
      ELSE (* startcol > 0, so shift screen left *)
        ScrnLeft(10);
        DEC(linepos);
        DEC(i);
      END; (* if linepos = 0 *)
    ELSE (* linepos > 0 *)
      (* just move cursor left in current line *)
      DEC(i);
      DEC(linepos);
    END; (* if linepos = 0 *)
    CursorPos(curdispline, leftedge + linepos);
  ELSE
    IF (startf > 0) & PageBigFile(FALSE, TRUE) THEN (* backward, ask *)
      ShowNew;
    END;
  END; (* if i > 0 *)
END Leftarrow;

PROCEDURE ScrnRt(shiftcols: CARDINAL);
(* move screen right only if text exists over there in that line *)
(* add blit for 3.02 *)
VAR tmpW: INTEGER;
BEGIN
  tmpln:= line + curdispline;
  longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
  linelen:= SHORT(Findend(tmpln) - longptr^); (* linelen *)
  IF linelen > startcol THEN
    IF linelen < startcol + shiftcols (* displaylen *) THEN
      shiftcols:= linelen - startcol;
      linepos:= 0;
    END;
    INC(startcol, shiftcols);
    IF linepos > shiftcols THEN
      linepos:= linepos - shiftcols;
    ELSE (* linepos <= shiftcols *)
      linepos:= 0;
    END;
    i:= longptr^ + LONG(startcol + linepos);
(* 3.02 *)
    IF Window1 = topwind THEN
      tmpW:= INTEGER(shiftcols) * colW + colW;
      Blit(workX+tmpW, workY, workW-tmpW-1, workH, workX+colW, workY);
      int:= workX + workW;
      IF int > fullW THEN
        int:= fullW;
      END;
      SetClipFill(int-tmpW, workY, tmpW, workH, TRUE);
      SetClipping(VDIHandle, 1, clipxy2);
    END;
    Display(0, cfg.maxdispline);
    SetClipFill(1,1, fullW, maxY, TRUE);
    SetClipping(VDIHandle, 1, clipxy2);
(**)
    SetHSlidePos;
  END; (* if doshift *)
END ScrnRt;

PROCEDURE ScrnLeft(shiftcols: CARDINAL);
VAR tmpW: INTEGER;
BEGIN
  IF startcol > 0 THEN
(*
    shiftcols:= pageW;
*)
    IF startcol < shiftcols THEN
      shiftcols:= startcol;
    END;
    DEC(startcol, shiftcols);
    INC(linepos, shiftcols);
    IF linepos > displaylen THEN
      linepos:= displaylen;
    END;
    longptr:= lnptradr + ADDRESS(4*LONG(line + curdispline));
    i:= longptr^ + LONG(linepos + startcol);
(*
    Display(0, cfg.maxdispline);
*)
(* 3.02 *)
    IF Window1 = topwind THEN
      tmpW:= INTEGER(shiftcols) * colW + colW;
      Blit(workX+colW-1, workY, workW-tmpW, workH, workX+tmpW-1, workY);
      SetClipFill(workX, workY, tmpW, workH, TRUE);
      SetClipping(VDIHandle, 1, clipxy2);
    END;
    Display(0, cfg.maxdispline);
    SetClipFill(1,1, fullW, maxY, TRUE);
    SetClipping(VDIHandle, 1, clipxy2);
(**)
    SetHSlidePos;
  END;
END ScrnLeft;


PROCEDURE Downup;
(* finds i and sets cursorpos from given line, curdispline, linepos *)
(* redisplays if needs a screen shift left/right *)
VAR tmpcol: CARDINAL;
BEGIN
    tmpln:= line + curdispline;
    longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
    linelen:= SHORT(Findend(tmpln) - longptr^);
    IF linepos + startcol > linelen THEN (* was newlinepos. since linepos starts at 0 *)
      (* need to move left since next line is shorter then current line *)
      tmpcol:= startcol;
      Findscrn(linelen); (* gets proper startcol *)
      linepos:= linelen - startcol;
      IF tmpcol <> startcol THEN (* screen shifted right or left *)
        Display(0, cfg.maxdispline);
        SetHSlidePos;
      END;
    END; (* if can't go straight down *)
    CursorPos(curdispline, leftedge + linepos); (* was newlinepos *)
    i:= longptr^ + LONG(linepos + startcol);
END Downup;

PROCEDURE Downarrow;
BEGIN
  IF line + curdispline < lastline THEN (* is room to move down *)
    IF curdispline = cfg.maxdispline THEN (* need to scroll down *)
      Scrolldown;
    ELSE INC(curdispline);
    END; (* if need to scroll *)
    Downup;
  ELSE Rtarrow; (* on last line already *)
  END; (* if can move down a line *)
END Downarrow;

PROCEDURE Uparrow;
BEGIN
  IF line + curdispline > 0 THEN (* CAN move up *)
    IF curdispline > 0 THEN (* can just move up without scroll *)
      DEC(curdispline);
    ELSE (* need to scroll up *)
      Scrollup;
    END; (* if need to scroll *)
    Downup;
  ELSE Leftarrow; (* on top line already *)
  END; (* if CAN move up *)
END Uparrow;

(*ds*)
PROCEDURE Wrapblock(startline: CARDINAL; VAR endaskline: CARDINAL):
  CARDINAL; (* returns actual endline used for wrap *)
 (* wordwraps block, if endaskline = 0FFFFH then wraps to end of P'graph *)
 (* puts LF wherever end of line should be, and skips any existing ones? *)
 (* so ONLY use this for eol chars of cr/lf !! *)
VAR
    endline, wrapln, deletes, inserts, lnlen, newlns, dellns: CARDINAL;
    k: CARDINAL; (* 2.30 1/9/92 *)
    jlong, startind, endind, start1, length, remains: LONGCARD;
    longptr2: POINTER TO LONGCARD;
BEGIN
  (* find start of a paragraph *)
  longptr2:= lnptradr + ADDRESS(4*LONG(startline));
  WHILE (Findend(startline) = longptr2^) (* (ptr1^ = 15C) *)
    & (startline < lastline) DO
    INC(startline); (* this happens also when eollen = 0 and just 1 char on line *)
    longptr2:= ADDRESS(longptr2) + 4;
  END; (* while blank line *)
  startind:= longptr2^;

  (** find end of paragraph **)
  endline:= startline;
  IF (endaskline > endline) & (endline < lastline) THEN
    INC(endline);
    longptr2:= ADDRESS(longptr2) + 4;
  END;
  ptr1:= startadr + ADDRESS(longptr2^);
  (* while not start of new pgraph and not last line, inc endline *)
  WHILE (Findend(endline) > longptr2^) (* non-blank *)(* was <> , (ptr2^ <> 15C) *)
    & (ptr1^ <> ' ')
    & (ptr1^ <> 11C) (* tab *)
    & (endline < lastline) DO
    INC(endline); (* 15C = 13 dec = CR *)
    longptr2:= ADDRESS(longptr2) + 4;
    ptr1:= startadr + ADDRESS(longptr2^);
  END; (* while not end of Pgraph *)
(***)
  IF (endline > endaskline) (* & (endaskline <> 0FFFFH) implicit *) THEN
    (* only go as far as asked. 0FFFFH means do to end of paragraph *)
    endline:= endaskline;
  END; (* if *)
(***)
  (* Then see if wrap is needed & find end char & adjust end line as needed *)
  IF (endline > startline) OR (* checks to see if wrap is needed *)
    (Findend(startline) - startind >= LONG(wrapW)) THEN (* do wrap *)

    IF cfg.eollen = 0 THEN (* just do simple Lineptrs *)
      Lineptrs(startline);
    ELSE (* eollen:= 2; *)(* force to cr/lf as eol chars *)
      pastelen:= 0; (* 2.31 2/24/92 *)

      endind:= Findend(endline) - 1;
      (* if need to fake next lineptr for line after non-blank lastline *)
      longptr2:= lnptradr + ADDRESS(4*LONG(lastline) + 4);
      longptr2^:= endind + LONG(cfg.eollen + 1); (* simulates next lnptr *)
      (* reset cardptr & ptr1 to start of endline *)
      longptr2:= lnptradr + ADDRESS(4*LONG(endline));
      ptr1:= startadr + ADDRESS(longptr2^);
      (* Adjust endline & endind backward to last char of desired line *)

(** start revised part **)
      IF (endline > startline)
        (* if lastline then not start of new Pgraph *)
        & ((endline < lastline) OR (* is last line, but is new Pgraph *)
          ((ptr1^ = ' ') OR (ptr1^ = 11C) OR (longptr2^ = endind+1))) THEN

          DEC(endline); (*** ???? ***)
          endind:= longptr2^ - 1 - LONG(cfg.eollen);
      END; (* includes blank lastline or endline that starts with indent *)
(** end revised part **)
(*    
      ClearWindow(Window1);
      CursorPos(0, lm);
      ConWS('endind1: '); ConCard(endind);
      ConWS(' lastline: '); ConCard(lastline); 
      ConWS(' endline: '); ConCard(endline); 
*)    
      (* take out all cr/lf's except last and replace each pair with a space *)
      (* only needed if eollen > 0 *)
      deletes:= 0;
      dellns:= 0;
      wrapln:= startline;
      WHILE wrapln < endline DO
        INC(wrapln);
        (** replace cr with space **)
        (* get ptr to start of next line *)
        longptr2:= lnptradr + ADDRESS(4*LONG(wrapln));
        (* point to the CR at the end of current line *)
        ptr1:= startadr + ADDRESS(longptr2^ - LONG(cfg.eollen) - LONG(deletes));
        ptr1^:= 40C;
(***)
        DEC(ptr1);
        IF ptr1^ <> '.' THEN
          INC(deletes);
        ELSE (* period at end of line *)
          ptr1:= ADDRESS(ptr1) + ADDRESS(cfg.eollen); (* 2 = eollen *)
          ptr1^:= 40C; (* overwrite old LF with space *)
        END; (* if no period at end of line *)
(***)
        (* Then shift rest of line back & fill LF space if needed *)
        wrapadr:= startadr + ADDRESS(longptr2^);
        INC(dellns);
(**)
        longptr:= ADDRESS(longptr2) + 4;
        MoveMem(wrapadr, wrapadr - ADDRESS(deletes), 
          longptr^ - longptr2^ - LONG(cfg.eollen));
          (* we don't need to move the old CR/LF in this operation *)
      END; (* while wrapln < endline *)
      DEC(endind, deletes);
(*    
      ConWS('deletes: '); ConCard(deletes);
      ConWS('endind: '); ConCard(endind);
*)    
      (* Now find new places to place end of lines *)
      length:= endind - startind + 1; (*  + 1 since endind is char we want *)
      start1:= startind; (* start of each line created *)
(**)
      newlns:= 0; (* counter for number of new lines created during wrap *)
(**)
      inserts:= 0; (* newlns - ones not needing LF insertion due to '.' *)
      (* REPEAT *)
      LOOP
        IF length <= LONG(wrapW) THEN
          EXIT;      (* lnlen:= length;*) (** <=, -1?? all done *)
        ELSE  (* scan backward from right margin to find first space *)
          (* DEC(length); (**?**) *)
          lnlen:= wrapW;
          ptr1:= startadr + ADDRESS(start1 + LONG(lnlen));
          WHILE (ptr1^ <> 40C) & (lnlen > 5) (* wrapW DIV 2 *) DO (* find space *)
            DEC(lnlen);
            DEC(ptr1); (* ptr1:= startadr + ADDRESS(start1 + lnlen); *)
          END; (* while look for space *)
          IF ptr1^ = 40C THEN (* found a space *)
            (* ptr1:= startadr + ADDRESS(start1 + lnlen); *)
            ptr1^:= 15C; (* CR, later add LF *)
            IF start1 + LONG(lnlen) < i THEN (* adding newlines in front of current pos *)
              INC(i);
            END;
            INC(lnlen); (* to put it to spot just AFTER cr *)
            INC(start1, lnlen); (* + 1? *) (* spot just AFTER cr *)
            INC(ptr1); (* check for space after that space, if was '.' *)
            IF ptr1^ <> 40C THEN
              INC(inserts);
            END; (* if will add a space for LF *)
            INC(newlns);
            longptr2:= newlnptradr + ADDRESS(4*LONG(newlns));
            longptr2^:= start1;
            DEC(length, lnlen);
            (* INC(length); (** ?? **) *)
          ELSE
            INC(start1, wrapW); (* forget about that line without spaces *)
            DEC(length, wrapW);
          END; (* if was a space to wrap at *)
        END; (* if length <= displaylen *)
      END; (* Loop *)
      
      (** Now movemem all the text after the wrap block to its new
      position in charray and adjust its line pointers **)     
      k:= 0; (* in case inserts = deletes *)
      IF (inserts <> deletes) (* AND (endline <= lastline) *) THEN
        (* at least lnptrs need to move *)
        IF (endline < lastline) THEN
          (* there is text after the wrap block which also needs to move *)
          remains:= endind + 1 + LONG(deletes);
          (* since endind moved back by # of deletes *)
          (* wrapadr:= ADR(charray[remains]); *) (* start extra text *)
          wrapadr:= startadr + ADDRESS(remains);
          IF inserts > deletes THEN (* shift right *)
            MoveMem(wrapadr, wrapadr + ADDRESS(inserts - deletes), 
              last - remains);
          ELSE (* deletes > inserts so shift left *)
            MoveMem(wrapadr, wrapadr - ADDRESS(deletes - inserts), 
              last - remains);
          END; (* if inserts > deletes *)
        END; (* if endline < lastline *)

        (*** and also Adjust line pointers ***)
(************
 FOR adjusting lnptrs left or right, need to check if newlns <> dellns,
 NOT if inserts <> deletes
**************)

        IF inserts > deletes THEN
          k:= inserts - deletes;
          INC(last, k);
          (* inc following lnptrs by inserts - deletes *)
          jlong:= LONG(endline);
          longptr2:= lnptradr + ADDRESS(4*jlong);
          WHILE jlong < LONG(lastline) DO
            INC(jlong);
            longptr2:= ADDRESS(longptr2) + 4;
            longptr2^:= longptr2^ + LONG(k);
          END; (* while dec'ing lnptrs *)
        ELSE (* deletes > inserts *)
          k:= deletes - inserts;
          DEC(last, k);
          (* dec following lnptrs by deletes - inserts *)
          jlong:= LONG(endline);
          longptr2:= lnptradr + ADDRESS(4*jlong);
          WHILE jlong < LONG(lastline) DO
            INC(jlong);
            longptr2:= ADDRESS(longptr2) + 4;
            longptr2^:= longptr2^ - LONG(k);
          END; (* while dec'ing lnptrs *)
        END; (* if shift text left or right *)
      END; (* if inserts <> deletes *)      
      IF newlns <> dellns THEN
        longptr2:= lnptradr + ADDRESS(4*LONG(endline) + 4); (* was in both below *)
        IF newlns > dellns THEN
          (** shift lnptrs right to make room for new lines **)
          k:= newlns - dellns;
          (* longptr2:= lnptradr + ADDRESS(4*LONG(endline) + 4); *)
          MoveMem(ADDRESS(longptr2), ADDRESS(longptr2) + ADDRESS(4*LONG(k)),
            4*LONG(lastline - endline));
          INC(endline, k);
          IF endaskline < 0FFFFH THEN
            INC(endaskline, k);
          END; (* if room to inc it *)
          INC(lastline, k);
        ELSE (* dellns > newlns *)
          (** shift lnptrs left to overwrite deleted lines **)
          k:= dellns - newlns;
          (* longptr2:= lnptradr + ADDRESS(4*LONG(endline) + 4); *)
          MoveMem(ADDRESS(longptr2), ADDRESS(longptr2) - ADDRESS(4*LONG(k)), 
            4*LONG(lastline - endline));
          (* longcard = 4 bytes *)
          DEC(endline, k);
          DEC(endaskline, k);
          DEC(lastline, k);
        END; (* if shift lnptrs right or left *)
      END; (* if need to shift lnptrs at all *)
      IF newlns > 0 THEN (* put in LF's *)
        (* start with end of last line of wrapblock and work backward *)
        longptr2:= newlnptradr + ADDRESS(4*LONG(newlns) + 4);
        longptr2^:= endind + 1; (* lnptrarray[endline+1]; *)

        (*** Insert LF's after each CR in the wrap block ***)
        (* And fix line pointers for lines in wrap block *)
        (* could just replace newlnptr stuff with Lineptrs(startline) *)
        remains:= LONG(newlns - inserts);
        FOR jlong:= LONG(newlns) TO 1 BY -1 DO (* since newlnptr array starts at 1 *)
          (* get start of line *)
          longptr2:= newlnptradr + ADDRESS(4*jlong);
          wrapadr:= startadr + ADDRESS(longptr2^);
          k:= 0; (* tmp addition for period handling *)
          ptr1:= wrapadr;
          IF (ptr1^ = 40C) (* & (remains > 0) *) THEN (* space at start of line, due to period *)
            k:= 1;
            IF remains > 0 THEN
              DEC(remains);
            END;
          END; (* if line starts with space, as due to period handling *)
          (* move text right to make room for LF insertion, where needed *)
          longptr:= ADDRESS(longptr2) + 4; (* ptr to start of next line *)
          MoveMem(wrapadr, wrapadr + ADDRESS(jlong-remains-LONG(k)), longptr^-longptr2^);
          longptr:= lnptradr + ADDRESS(4*(LONG(startline) + jlong));
          longptr^:= longptr2^ + jlong - remains;
          ptr1:= startadr + ADDRESS(longptr^) - 1;
          ptr1^:= 12C; (* LF *)
        END; (* for each line in final wrapblock *)
      END; (* if inserts > 0 *)
    END; (* if eollen = 0 *)
      
    (** find where to put cursor **)

(*** revised/added code: ****)

    longptr2:= lnptradr + ADDRESS(4*LONG(line + curdispline));
(*
   (* 3.02 *)
    lnlen:= Min(SHORT(Findend(line + curdispline) - longptr2^), displaylen);
*)
    lnlen:= SHORT(Findend(line + curdispline) - longptr2^);
    jlong:= LONG(startcol); (* old startcol *)
    k:= linepos; (* old linepos *)
    deletes:= curdispline; (* temp holder for old line, was remains *)

    curdispline:= Findline(i) - line;
    inserts:= 0; (* how many lines to adjust *)

    WHILE curdispline > cfg.maxdispline DO  (* >=? scroll down *)
      (* this could be done faster by doing it all at once, but usually
         it wouldn't be more than one line anyway *)
      INC(line);
      DEC(curdispline);
      INC(inserts);
    END;  (* if need to make room for another line *)
    longptr2:= lnptradr + ADDRESS(4*LONG(line + curdispline));
    linepos:= SHORT(i - longptr2^); (* careful: may be beyond screen *)

    Findscrn(linepos); (* sets new startcol *)
    DEC(linepos, startcol); (* new linepos *)

    (** but what if wrapW is greater than 75 ? **)
    IF LONG(startcol) <> jlong THEN (* need to shift scrn left or right *)
      Display(0, curdispline); (* Wrapshow does rest *)(* cfg.maxdispline); *)
      SetHSlidePos;
    ELSE (* handle blanking of rest of current line *)
      (* take care of any blanking needed on current line & put eolchar *)
      int:= 0; (* 3.02 *)
      IF lm + lnlen > startcol THEN
        int:= INTEGER(lm+lnlen-startcol) * colW - 1; (* -1 handles M,W,K *)
      END;
      IF int < workW THEN (* end of line in window *) (* 3.02 *)
        SetClipFill(workX+int, workY+INTEGER(deletes)*rowH,
                  workW-int, rowH, FALSE); (* clear rest of line *)
        CursorPos(curdispline, leftedge+lnlen-startcol);
        (* Display handles the final cursor positioning *)
        Conzap(cfg.eolchar); (* inc's vcurx *) (* what if eollen=0 & at edge? *)
      END; (* if *)
      IF inserts > 0 THEN
        (* if > 1 would have to have been startcol <> jlong ?? *)
        (* no, because if wrap at col 25 of 75 *)
        IF cfg.maxdispline+1 > inserts THEN
          Blit(workX, workY+(rowH*INTEGER(inserts)), workW,
               INTEGER(cfg.maxdispline+1-inserts)*rowH, workX, workY);
        ELSE (* have to redraw whole screen *)
          Display(0, curdispline); (* wrapshow does rest of lines *)
        END; (* if blit or redraw whole screen *)
      END;

    END; (* if need to move back to first window *)
    (* lines starting at new curdispline get drawn by Wrapshow *)

(*** end revised code ***)

    SetSlideSize;
    SetSlidePos;
    RuinBlock(FALSE);
  END; (* if wrap is needed *)
(*
  CursorPos(1, lm);
  ConWS('last: '); ConCard(last);
  ConWS(' lastline: '); ConCard(lastline); 
  ConWS(' endline: '); ConCard(endline); 
  ConWS('endind: '); ConCard(endind); NecIn(ch);
  NecIn(ch);
*)
  RETURN endline;
END Wrapblock;

PROCEDURE Wrapshow(startln, endln: CARDINAL);
BEGIN
  j:= Wrapblock(startln, endln);
  Display(curdispline, cfg.maxdispline);
  Bottomstay;
END Wrapshow;
(*ds*)

PROCEDURE Bottomstay; (* keep text at bottom of window if possible *)
VAR j: CARDINAL; (* # of lines to adjust downward *)
BEGIN
  IF (lastline-line < cfg.maxdispline) & (line > 0) THEN (* move everything down as needed & possible *)
    j:= cfg.maxdispline - (lastline-line); (* number of lines to scroll *)
    IF line < j THEN (* can only move as far as line 0 *)
      j:= line;
    END;
    DEC(line, j);
    INC(curdispline, j);
    Blit(workX, workY, workW, workH-rowH*(INTEGER(j)), workX, workY+rowH*(INTEGER(j)));
    Display(0, j);
  END;
  SetSlideSize;
  SetSlidePos;
  SetHSlideSize;
  SetHSlidePos;
END Bottomstay;

PROCEDURE FullAlert;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][Sorry, Not enough room|to add that text.|Save & Re-Open][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
END FullAlert;


PROCEDURE AddInsert;
(* eol chars Must be cr/lf or nothing *)
BEGIN
 (*ds*)
  RuinBlock(FALSE); (* should do nothing when Adding *)
 (*ds*)
  IF cfg.insertmode OR (i = last) THEN
    IF last < buffsize-1 THEN (* is room to insert 2 chars *)(* 32 bit *)
      IF ((kreturn <> RETURNKEY) & (kreturn <> 0720DH)) OR (cfg.eollen = 0) THEN
        (* just process that one char *)
        tmpln:= line + curdispline;
        ptr1:= startadr + ADDRESS(i);
        INC(last);
  (*
        IF insert THEN (* if Add, then movemem simply moves zero bytes *)
  *)
          MoveMem(ptr1, ADDRESS(ptr1) + 1, last - i);
  (*
        END;
  *)
        ptr1^:= newchar;
        INC(i);
        INC(linepos);
  
        (* increment all subsequent line pointers *)
        j:= tmpln + 1;
        WHILE j <= lastline DO (* doesn't do it at all if Adding *)
          longptr:= lnptradr + ADDRESS(4*LONG(j));
          longptr^:= longptr^ + 1;
          INC(j);
        END;  (* while inc'ing rest of line pointers *)
        longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
        linelen:= SHORT(Findend(tmpln) - longptr^);

        (** ? **)
        IF cfg.eollen = 0 THEN
          INC(linelen);
        END;
        Conzap(newchar); (* Bconout(newchar, 5); *)
  
        IF (linelen <= wrapW) OR (NOT cfg.autowrap) THEN (* display rest on same line *)
          IF linepos > displaylen THEN (* is not room in current screen *)
            ScrnRt(10);;
          ELSIF i < last (* insert *) (* linepos <= displaylen *) THEN
            (* keep on inserting *)
            Lineout(tmpln, linepos, displaylen);
            CursorPos(curdispline, leftedge+linepos);
          END; (* if is room in current screen *)
        ELSE (* autowrap AND linelen > wrap width, wrap *)
          j:= 0FFFFH; (* wrap paragraph *)
(**
          j:= tmpln;
          IF i < last (* insert *) THEN
            j:= 0FFFFH; (* wrap whole paragraph *)
  (*
            Wrapshow(tmpln, j);
          ELSIF (newchar = 40C) & (startcol = 0) & (cfg.eollen > 0) THEN (* change space to CR/LF *)
            DEC(i);
            DEC(linepos);
            DEC(last);
            InsNewline; (* was Newline *)
          ELSE (* WRAP!!!! *)
            j:= tmpln;
            Wrapshow(tmpln, tmpln); (* was Wrapln; *)
  *)
          END; (* if insert & wrap whole Pgraph *)
**)
          Wrapshow(tmpln, j); (* was Wrapln; *)

        END; (* if don't need to wrap *)
      ELSE (* IF newchar = 15C THEN *) (* also insert LF, and redo lnptrs and wrap *)
        InsNewline;
      END; (* if newchar <> CR *)
    ELSE (* no more room in buffer *)
      FullAlert;
    END; (* if room to insert or add *)
  
  ELSE (* Overwrite *) (* still needs to handle alt eol's *)
    tmpln:= line + curdispline;
    endofline:= Findend(tmpln);
    ptr1:= startadr + ADDRESS(i);
    IF (cfg.eollen = 0) (* & (i = endofline) put w/rtarrow? *) THEN
      ptr1^:= newchar;
      Conzap(newchar); (* Bconout(newchar, 5);*) (* BConOut(CON, newchar); *)
      IF i = last THEN (* Add *)
        INC(last);
      END;
      Rtarrow; (* inc's i & linepos appropriately *)
    (** NOTE, the above may screw up any other cases of eollen = 0 **)
    ELSIF (i <> endofline) & (kreturn <> RETURNKEY)
     & (kreturn <> 0720DH) THEN (* simple overwrite *)
      ptr1^:= newchar;
      Conzap(newchar); (* Bconout(newchar, 5); *)
      INC(i);
      INC(linepos);
    ELSIF (i <> endofline) (* (ptr1^ <> 15C) *) &
     ((kreturn = RETURNKEY) OR (kreturn = 0720DH)) THEN (* was > 15C *)
      InsNewline; (* doesn't overwrite char with cr *)
    ELSIF (i = endofline) & (ptr1^ = 15C)
     & (kreturn <> RETURNKEY) & (kreturn <> 0720DH) THEN
      (* replace CR with new character *)
      ptr1^:= newchar;
      INC(i); (* get rid of LF *)
      INC(linepos);
      INC(ptr1);
      MoveMem(ADDRESS(ptr1) + 1, ptr1, last - i);
      (* adjust lineptrs *)
      FOR j:= tmpln + 1 TO lastline DO
        longptr:= lnptradr + ADDRESS(4*LONG(j));
        longptr^:= longptr^ - 1;
      END; (* for *)
      longptr:= lnptradr + ADDRESS(4*LONG(tmpln) + 4);
      MoveMem(ADDRESS(longptr) + 4, ADDRESS(longptr),
              4*LONG(lastline - tmpln));
      DEC(lastline);
      DEC(last);
  (*ds*)
      IF cfg.autowrap THEN
        Wrapshow(tmpln, tmpln); (* assumes autowrap is wanted *)
      ELSE (* don't wrap *)
  (*ds*)
        Display(curdispline, cfg.maxdispline);
  (*ds*)
      END; (* if wrap *)
  (*ds*)
    END; (* if not CR *)
(**%**)
    IF linepos > displaylen THEN (* is not room in current screen *)
      ScrnRt(10);
    END; (* if shift right *)
  END; (* if AddInsert or Overwrite *)
  saved:= FALSE;
END AddInsert;


PROCEDURE InsNewline; (* Insert CR/LF, newchar = 15C *)
(** eol chars Must be cr/lf or none **)
VAR int: INTEGER;
    j: CARDINAL;
    jlong, indents: LONGCARD;
BEGIN
  indents:= 0;
  tmpln:= line + curdispline;
  IF cfg.autoindent & (cfg.eollen > 0) THEN
    (** 2.30 1/16/92 auto-indent **)
    longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
    (* count until hit a non-space character, such as eol or anything *)
    ptr1:= startadr + ADDRESS(longptr^);
    WHILE (ptr1^ = ' ') & (SHORT(indents) < linepos+startcol) DO
      INC(ptr1);
      INC(indents);
    END;
  END; (* if autoindent *)
  (* is room to insert 2 chars, and not trying to insert blank line if no eolchars *)

  IF (last < buffsize-1-indents) & (NOT ((cfg.eollen = 0) (* 32 bit *)
  & (linepos = 0) & (startcol = 0))) THEN
    ptr1:= startadr + ADDRESS(i);
    wrapadr:= lnptradr + ADDRESS(4*LONG(tmpln) + 4);
    INC(lastline);
    IF i < last THEN (* is Insert rather than Add *)
      (* clear rest of line *)
      int:= INTEGER(lm+linepos) * colW - 1; (* -1 for chars K, M, or W *)
      SetClipFill(workX+int, workY+INTEGER(curdispline)*rowH,
                workW-int, rowH, FALSE);
      (* make room for new line ptr, 4 bytes for each longcard *)
      MoveMem(wrapadr, wrapadr + 4, 4*LONG(lastline - tmpln - 1));
      IF cfg.eollen > 0 THEN
        (* make room to insert the CR and LF *)
        MoveMem(ptr1, ADDRESS(ptr1) + ADDRESS(2+indents), last - i + 1);
        (* increment all subsequent line pointers *)
        FOR j:= tmpln + 2 TO lastline DO  (* could use +2 *)
          longptr:= lnptradr + ADDRESS(4*LONG(j));
          longptr^:= longptr^ + 2 + indents;
        END; (* for rest of line pointers *)
      END; (* if eollen > 0 *)

    END; (* if Inserting newline rather than Adding *)

    IF cfg.eollen > 0 THEN
      ptr1^:= 15C; (* CR *)
      INC(i, 2);
      INC(ptr1);
      ptr1^:= 12C; (* LF *)
      jlong:= 0;
      WHILE jlong < indents DO
        INC(ptr1);
        ptr1^:= ' '; (* fill indented area of ram with spaces *)
        INC(jlong);
      END;
      INC(last, 2+indents);
      (** display **)
    END; (* if eollen > 0 *)  
    Conzap(cfg.eolchar); (* Bconout(eolchar, 5); *)
    (* set new lnptr for start of new line *)
   (* 32 bit *)
    longptr:= wrapadr;
    longptr^:= i;

    INC(i,indents);
    IF curdispline >= cfg.maxdispline THEN (* should never be > *)
      Scrolldown; (* inc's line *)
    ELSE
      INC(curdispline);
    END; (* if need to scroll *)
    j:= startcol; (* tmp *)
    Findscrn(SHORT(indents)); (* sets new startcol *)
    linepos:= SHORT(indents)-startcol; (* after findscrn to use new startcol *)
    IF j = startcol THEN 
      IF curdispline < cfg.maxdispline THEN
        int:= INTEGER(curdispline)*rowH; (* height of undisturbed area *)
        Blit(workX, workY+int, workW, workH-int-rowH, workX, workY+int+rowH);
      END; (* if anything to blit *)
      Display(curdispline, curdispline);
    ELSE (* shift to different startcol *)
      Display(0, cfg.maxdispline);
      SetHSlidePos;
    END;
    SetSlideSize;
    SetSlidePos;
    IF typeahead <> 0C THEN (* send line to Stalker or outdev *)
      TypeAhead(tmpln);
    END;
  END; (* if room for 2 chars *)
END InsNewline;


PROCEDURE TypeInit;
BEGIN
  IF typeahead = 0C THEN (* determine desired output device *)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1, "[2][ Send Lines/Blocks To:][Stalker|Modem|Printer]");
    CODE(0A00AH); (* lineA Hide mouse *)
    typeahead:= 2C; (* direct to modem/printer *)
    outdev:= 0; (* printer *)
    IF dummy = 1 THEN
      typeahead:= 1C; (* to stalker *)
    ELSIF dummy = 2 THEN
      outdev:= 1; (* serial port *)
    END; (* if tospaces *)
    notistrg:= 'Type-ahead';
  ELSE
    typeahead:= 0C;
(*
    outdev:= 0; (* reset to parallel port *)
*)
    notistrg:= 'NoTypahead';
  END; (* if typeahead *)
  InitMenu;
END TypeInit;


PROCEDURE TypeAhead(ln: CARDINAL);
VAR longptr2: POINTER TO LONGCARD;
    tmplong1, delend: LONGCARD;
BEGIN
  IF blocktype > 0 THEN (* send block instead of line *)
    ptr1:= startadr + ADDRESS(blockstart);
    tmplong:= blockend - blockstart - 1;
    delstart:= blockstart;
    delend:= blockend;
  ELSE
    (* get start of line *)
    longptr2:= lnptradr + ADDRESS(4*LONG(ln));
    tmplong1:= longptr2^;
    ptr1:= startadr + ADDRESS(tmplong1);
    (* get end of line *)
    delend:= last;
    IF ln < lastline THEN
      longptr2:= ADDRESS(longptr2) + 4;
      delend:= longptr2^;
    END; (* if lastline *)
    tmplong:= delend - tmplong1 - 1; (* line length *)
    delstart:= tmplong1;
  END; (* if block *)
  IF typeahead = 1C THEN
    int:= ApplFind('STALKER '); (* stalkID *)
    IF int < 0 THEN (* not found *)
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1, "[1][Stalker not found][OK]");
      CODE(0A00AH); (* lineA Hide mouse *)
    ELSE (* must send as a NULL TERMINATED string! *)
      pastelen:= 0; (* zero the undo buffer *)
      ok:= Copyblock(delend); (* sets new pastelen *)
      ptr2:= newlnptradr + ADDRESS(pastelen);
      ptr2^:= 0C; (* null terminate *)
      pipeBuff[0]:= 2008; (* 2008 = send line to stalker *)
      pipeBuff[1]:= Appl; (* EdHak application ID *)
      pipeBuff[2]:= 0; (* excess message length *)
      pipeBuff[3]:= SHORT(LONGCARD(newlnptradr) DIV 010000H); (* hi word of adr *)
      pipeBuff[4]:= SHORT(LONGCARD(newlnptradr) MOD 010000H); (* low word of adr *)
      pipeBuff[5]:= 0; (* CARDINAL(tmplong);*) (* length *)
      ApplWrite(int, 16, ADR(pipeBuff)); (* std 16 byte msg *)
    END; (* if found stalker *)
  ELSE (* output directly to modem/printer *)
    LOOP (* for retries *)
      IF Bcosstat(outdev,8) THEN (* printer/modem ready to start *)
        tmplong1:= 0;
        LOOP
          (* ch:= ptr1^; *)
          Bconout(ptr1^, outdev);
          INC(ptr1);
          INC(tmplong1);
          IF tmplong1 > tmplong THEN (* done line *)
            EXIT; (* output loop *)
          END;
        END; (* output loop *)
        EXIT; (* retry loop *)
      ELSE (* printer not ready *)
        Showmouse; (* lineA Show mouse *)
        dummy:= FormAlert(1, "[1][Device not Responding][Retry|Abort]");
        CODE(0A00AH); (* lineA Hide mouse *)
        IF dummy = 2 THEN  (* abort; else keep looping *)
          EXIT; (* retry loop *)
        END; (* if abort *)
      END; (* if printer ready at first *)
    END; (* retry loop *)
  END; (* if to stalker or modem/printer *)
END TypeAhead;

PROCEDURE DeleteLine(ln: CARDINAL);
VAR longptr2: POINTER TO LONGCARD;
    int: INTEGER;
BEGIN
(*ds*)
  IF i <> delstart THEN (* not consecutive deletions *)
    pastelen:= 0; (* will only be able to undo THIS line *)
  END;
(*  
  RuinBlock(TRUE); (* ruin it no matter where it is *)
*)
(*ds*)
  longptr2:= lnptradr + ADDRESS(4*LONG(ln));
  delstart:= longptr2^;

  IF (blocktype > 0) (* isblock *) & (delstart < blockend) THEN
    (* uses tmplong & longptr in showblock *)
    RuinBlock(TRUE); (* ruin it no matter where it is *)
  END;

  tmplong:= last; (* delend. doing this instead of ELSE makes slightly smaller code *)
  IF ln < lastline THEN
    longptr2:= ADDRESS(longptr2) + 4;
    tmplong:= longptr2^;
  END; (* if lastline *)
(*
  saveline:= ln; (* for cursor positioning purposes *)
*)
  IF Cutblock(tmplong) THEN (* did it, includes startcol:=0, so redo display *)
    IF curdispline < cfg.maxdispline THEN (* move text up to fill void *)
      int:= rowH * INTEGER(curdispline + 1);
      Blit(workX, workY+int, workW, workH-int, workX, workY+int-rowH);
    END;
    Display(cfg.maxdispline, cfg.maxdispline);
    Bottomstay;
  END; (* if do it *)
END DeleteLine;

PROCEDURE DelToEnd(ln: CARDINAL); (* Alt-Delete *)
VAR int: INTEGER;
BEGIN
(*ds*)
  IF i <> delstart THEN (* not consecutive deletions *)
    pastelen:= 0; (* will only be able to undo THIS line *)
  END;
  delstart:= i;
  IF (blocktype > 0) (* isblock *) & (delstart < blockend) THEN
    (* uses tmplong & longptr in showblock *)
    RuinBlock(TRUE); (* ruin it no matter where it is *)
  END;
  tmplong:= Findend(ln);
  IF Cutblock(tmplong) THEN (* did it, includes startcol:=0, so redo display *)
    (* clear rest of display line *)
    int:= INTEGER(vcurx) * colW;
    SetClipFill(int, vcury+1, workX+workW-int, rowH, FALSE);
    IF i <> last THEN
      Conzap(cfg.eolchar); (* inc's vcurx *)
      DEC(vcurx);
    END;
  END; (* if do it *)
END DelToEnd;

(*ds*)
PROCEDURE Movetobuff(n: LONGCARD); (* 32 bit.  was CARDINAL *)
BEGIN
  IF isroom THEN
    MoveMem(startadr + ADDRESS(delstart),
      newlnptradr + ADDRESS(pastelen), n);
    INC(pastelen, n);
  END;
END Movetobuff;

PROCEDURE BuffRoom(): BOOLEAN;
BEGIN
  isroom:= TRUE;
  IF (blocklen + pastelen) > 4*LONG(maxlines) THEN (* is not room, since 4 bytes per line pointer *)
    isroom:= FALSE;
    Showmouse; (* lineA Show mouse *)
    int:= FormAlert(1,'[3][Block is bigger than paste|buffer, so no undo/paste][Continue|Cancel]');
    CODE(0A00AH); (* lineA Hide mouse *)
    IF int <> 1 THEN (* abort *)
      RETURN FALSE;
    END;
  END; (* if block too big for undo *)
  RETURN TRUE;
END BuffRoom;

(****+*)
PROCEDURE Copycolblk(firstcol: BOOLEAN): BOOLEAN;
(* moves block to paste buffer *)
(* for 2.4, can move column block *)
(* blocklen, pastelen are global longcards *)
VAR (* j,*) startbcol, endbcol, endline, blocklines, blockwidth, movelen: CARDINAL;
    startind: LONGCARD;
BEGIN
  pastelen:= 0; (* empty paste buffer *)
  saveline:= Findline(blockstart);
  endline:= Findline(blockend);
  longptr:= lnptradr + ADDRESS(4 * LONG(saveline));
(*
  startbcol:= SHORT(blockstart - longptr^);
  longptr:= lnptradr + ADDRESS(4 * endline);
  endbcol:= SHORT(blockend - longptr^);
*)
  IF firstcol THEN
    blockstart:= longptr^; (* for final i cursorpos *)
    startbcol:= 0;
    endbcol:= 1;
  ELSE (* cols of blockstart/end *)
    startbcol:= SHORT(blockstart - longptr^);
    longptr:= lnptradr + ADDRESS(4 * LONG(endline));
    endbcol:= SHORT(blockend - longptr^);
  END; (* if firstcol *)

  IF endbcol > startbcol THEN
    blockwidth:= endbcol - startbcol;
  ELSE
    RETURN FALSE;
  END;
  blocklines:= endline - saveline + 1;
  blocklen:= LONG(blockwidth + cfg.eollen) * LONG(blocklines); (* bytes needed *)
  IF NOT BuffRoom() THEN
    RETURN FALSE;
  END;
  (* if is room in buffer, Movemem lines of block to paste buffer with loop *)
  tmpln:= saveline;
  LOOP (* copy block part of each line *)
    longptr:= lnptradr + ADDRESS(4 * tmpln);
    linelen:= SHORT(Findend(tmpln) - longptr^);
    movelen:= 0;
    IF linelen > startbcol THEN (* need to copy some text *)
    (* else should pad with spaces *)
      startind:= longptr^ + LONG(startbcol);
      movelen:= blockwidth;
      IF endbcol > linelen THEN
        movelen:= linelen - startbcol;
      END; (* if this line ends before block endbcol *)
      MoveMem(startadr + ADDRESS(startind), 
        newlnptradr + ADDRESS(pastelen), LONG(movelen));
(*
      Showmouse; (* lineA Show mouse *)
      int:= FormAlert(1,'[3][done loop movemem][ok]');
      CODE(0A00AH); (* lineA Hide mouse *)
*)
      INC(pastelen, LONG(movelen)); (* long()? *)
    END; (* if text to copy *)
    j:= movelen;
    ptr1:= newlnptradr + ADDRESS(pastelen);
    LOOP (* fill with spaces as needed *)
      IF j >= blockwidth THEN
        EXIT;
      END; (* done space fill *)
      ptr1^:= ' ';
      INC(ptr1);
      INC(j);
    END; (* space fill loop *)
(**)
    ptr1^:= 15C; (* cr *)
    INC(ptr1);
    ptr1^:= 12C; (* LF *)
(*
    INC(ptr1);
*)
    INC(pastelen, blockwidth - movelen + 2); (* 2 = eollen of cr/lf *)(* long? *)
(**)
(*
    INC(pastelen, blockwidth - movelen + cfg.eollen); (* need real eolstrg length *)
    MoveMem(ADR(cfg.eolstrg), ptr1, cfg.eollen);
*)
    INC(tmpln);
    IF tmpln > endline THEN
      EXIT;
    END;
  END; (* loop copying from each line *)
  RETURN TRUE;
END Copycolblk;

(**********
PROCEDURE Lcardtostrg(x: LONGCARD; VAR cardstrg: ARRAY OF CHAR;
                     ishex: BOOLEAN; digits: CARDINAL);
(* modified to do 5 or 6 digits WITH leading zeros as needed *)
(* now should do ANY number of digits, if receiving strg is long enough *)
VAR i, card, ref, place, max, base: CARDINAL;
    y: LONGCARD;
BEGIN
  i:= 0;
  max:= digits - 1;
  base:= 10;
  IF ishex THEN
    base:= 16;
  END;
  FOR place:= max TO 0 BY -1 DO (* 4 for full 5 digits *)
    y:= LONG(base);
    IF place = 0 THEN y:= 1;
    ELSIF place > 1 THEN
      FOR card:= 2 TO place DO
        y:= y * LONG(base);
      END; (* for *)
    END; (* if *) (* note: if place=1 then y just stays as x *)
    card:= SHORT(x DIV y);
    ref:= 48; (* ORD('0') *)
    IF card > 9 THEN (* A-F *)
      ref:= 55; (* ORD ('A') - ORD('9') + 1 *)
    END;
    cardstrg[i]:= CHR(card + ref);
    x:= x MOD y;
    (* big:= TRUE; *)
    INC(i);
  END; (* for place = 4 to 1 *)
  cardstrg[i]:= 0C; (* was i+1 *)
END Lcardtostrg;

PROCEDURE StrgZap(cardstrg: ARRAY OF CHAR);
VAR j: CARDINAL;
BEGIN
  j:= 0;
  WHILE (cardstrg[j] <> 0C) & (j <= displaylen) DO
    Conzap(cardstrg[j]);
    INC(j);
  END;
END StrgZap;
*****)

PROCEDURE Delcolblk(firstcol: BOOLEAN);
(* delete marked column block *)
VAR (* j,*) startbcol, endbcol, endline, blocklines, blockwidth, movelen: CARDINAL;
    tmplong2: LONGCARD;
    fromadr, toadr: ADDRESS;
BEGIN
  saveline:= Findline(blockstart);
  endline:= Findline(blockend);
  longptr:= lnptradr + ADDRESS(4 * LONG(saveline));
  IF firstcol THEN
    blockstart:= longptr^; (* for final i cursorpos *)
    startbcol:= 0;
    endbcol:= 1;
  ELSE (* cols of blockstart/end *)
    startbcol:= SHORT(blockstart - longptr^);
    longptr:= lnptradr + ADDRESS(4 * LONG(endline));
    endbcol:= SHORT(blockend - longptr^);
  END; (* if firstcol *)
  IF endbcol > startbcol THEN
    blockwidth:= endbcol - startbcol;
    blocklines:= endline - saveline + 1;
    blocklen:= LONG(blockwidth + cfg.eollen) * LONG(blocklines); (* bytes needed *)
    (* Movemem lines of block to fill where block was *)
    tmpln:= saveline;
    tmplong:= 0; (* counter for total number of bytes removed *)
    tmplong2:= 0;
    longptr:= lnptradr + ADDRESS(4 * tmpln);
    linelen:= SHORT(Findend(tmpln) - longptr^);
    i:= longptr^ + LONG(Min(linelen, startbcol));
    LOOP (* delete block part of each line *)
      movelen:= 0;
      tmplong2:= 0; (* bytes deleted from this line *)
      fromadr:= startadr + ADDRESS(longptr^ + LONG(Min(linelen, startbcol)));
      toadr:= fromadr - ADDRESS(tmplong);
(*
      toadr:= startadr + ADDRESS(longptr^ + LONG(Min(linelen, startbcol)) - tmplong);
      fromadr:= toadr + ADDRESS(tmplong);
*)
      IF linelen > startbcol THEN (* need to delete some text *)
        IF linelen > endbcol THEN
          INC(movelen, linelen - endbcol);
        END;
        tmplong2:= LONG(Min(blockwidth, linelen - startbcol)); (* bytes deleted *)
        fromadr:= fromadr + ADDRESS(tmplong2);
      END; (* if stuff to delete on this line *)

      IF tmpln < lastline THEN (* also move CR *)
        INC(movelen, cfg.eollen);
      END; (* if *)

      IF tmpln < endline THEN (* also move 1st part of next line *)
        longptr:= lnptradr + ADDRESS(4 * (tmpln + 1));
        linelen:= SHORT(Findend(tmpln + 1) - longptr^);
        INC(movelen, Min(linelen, startbcol));
      END; (* if *)
      MoveMem(fromadr, toadr, LONG(movelen));
      INC(tmplong, tmplong2); (* total bytes deleted *)
      INC(tmpln);
      IF tmpln > endline THEN
        EXIT;
      END;
    END; (* loop copying from each line *)
    (* Now MoveMem any text after block to current cursor position *)
    IF tmpln <= lastline THEN
      longptr:= lnptradr + ADDRESS(4 * LONG(tmpln));
      fromadr:= startadr + ADDRESS(longptr^);
      toadr:= fromadr - ADDRESS(tmplong);
      MoveMem(fromadr, toadr, last - longptr^);
    END;
    DEC(last, tmplong);
    DEC(blockend, tmplong); (* total number of bytes deleted *)
    (* fix line pointers *)
    Lineptrs(saveline); (* starting line of block *)
    (* set cursor position to where block started *)
  (*
    i:= delstart;
    SetFoundPos(FALSE, TRUE); (* forcetop, findlnpos *)
  *)
    i:= blockstart;
    longptr:= lnptradr + ADDRESS(4*LONG(saveline));
    k:= SHORT(i - longptr^);
    IF startcol > k THEN (* shift screen *)
      startcol:= k - 1;
      linepos:= 1;
      Display(0, cfg.maxdispline);
    ELSE
      linepos:= SHORT(i - longptr^) - startcol;
    END;
    IF (saveline < line) OR (saveline > line + cfg.maxdispline) THEN
      line:= saveline; (* get where block started into window *)
      curdispline:= 0;
    ELSE
      curdispline:= saveline - line; (* just get it back to blockstart *)
    END;
    saved:= FALSE;
    IF NOT firstcol THEN
      blocktype:= 0;
    END; (* if deselect block *)
  END; (* if *)
END Delcolblk;

PROCEDURE Pastecolblk(): BOOLEAN;
(* 2.4 paste column block at cursor *)
VAR startbcol, endline, blocklines, blockwidth, movelen: CARDINAL;
    tmpadr, newadr, fromadr: ADDRESS;
    longptr2: POINTER TO LONGCARD;
    eolstrg: ARRAY[0..2] OF CHAR;
BEGIN
(*******)
  IF pastelen = 0 THEN (* nothing to paste *)
    PasteAlert;
    RETURN FALSE;
  END;
  IF last + pastelen > buffsize THEN (* not enough room *)
    FullAlert;
    RETURN FALSE;
  END;
  (* Find blockwidth of column block in paste buffer *)
  blockwidth:= 0;
  tmpadr:= newlnptradr; (* start of paste buffer *)
  eolstrg[0]:= 15C; (* cr *)
  eolstrg[1]:= 12C; (* LF *)
  eolstrg[2]:= 0C;
  IF NOT Find(LONGCARD(newlnptradr - lnptradr),
          ADR(eolstrg), cfg.eollen, TRUE, tmpadr) THEN (* found it! *)
    RETURN FALSE;
  END; (* if *)    
  blockwidth:= CARDINAL(tmpadr - newlnptradr); (* found location *)
  (* blockwidth does not include cr/lf separator *)
  tmpln:= line + curdispline;
  longptr:= lnptradr + ADDRESS(4 * LONG(tmpln));
  startbcol:= SHORT(i - longptr^);
  (* make room for all insertions *)
  blocklines:= SHORT(pastelen DIV LONG(blockwidth + 2)); (* 2=eollen of cr/lf *)
  endline:= tmpln + blocklines (* - 1 *) ; (* x 1st nonblock line *)
  (* need to add new lines/lineptrs? if pasting to end? *)
  IF endline > lastline + 1 THEN
(**
          Showmouse; (* lineA Show mouse *)
          dummy:= FormAlert(1,'[3][add lines][ok]');
          CODE(0A00AH); (* lineA Hide mouse *)
**)
    longptr:= lnptradr + ADDRESS(4*LONG(lastline));
    ptr1:= startadr + ADDRESS(last);
    LOOP
      ptr1^:= 15C; (* CR *)
      INC(ptr1);
      ptr1^:= 12C; (* LF *)
      INC(longptr, 4);
      INC(last, 2);
      longptr^:= last;
      INC(lastline);
      IF lastline + 1 >= endline THEN
        EXIT;
      END;
      INC(ptr1);
    END; (* loop *)
  END; (* if create lines *)
(*********)
  longptr2:= lnptradr + ADDRESS(4*LONG(endline (* + 1 *) )); (* 1st nonblock line *)
  tmplong:= LONG(blockwidth) * LONG(blocklines); (* size of entire insertion *)
  tmpadr:= startadr + ADDRESS(longptr2^);
  newadr:= tmpadr + ADDRESS(tmplong);
  IF endline <= lastline THEN (* lines beyond block *)
    MoveMem(tmpadr, newadr, last - longptr2^);
  ELSE (* endline = lastline + 1 *)
    longptr2^:= last;
    tmpadr:= startadr + ADDRESS(longptr2^);
    newadr:= tmpadr + ADDRESS(tmplong);
  END; (* if lines beyond block *)
  fromadr:= newlnptradr + ADDRESS(pastelen); (* from pastebuff *)
  INC(last, tmplong);
  (* move pieces of lines & block into each new line *)
  LOOP
    DEC(endline);
    longptr:= lnptradr + ADDRESS(4 * LONG(endline));
    linelen:= SHORT(longptr2^ - longptr^) (* - cfg.eollen *); (* 2=eollen *)
    IF endline < lastline THEN
      DEC(linelen, cfg.eollen); (* 2=eollen *)
    END;
    (* in any case, must be sure to put cr/lf in new location, unless hack mode *)
    IF linelen >= startbcol THEN (* is trailer or at least CR/LF to move *)
      tmpadr:= startadr + ADDRESS(longptr^) + ADDRESS(LONG(startbcol));
      movelen:= linelen - startbcol (* + cfg.eollen *);
      IF endline < lastline THEN
        INC(movelen, cfg.eollen);
      END;
      newadr:= newadr - ADDRESS(LONG(movelen));
(***
          Lcardtostrg(LONGCARD(tmpadr), cardstrg, FALSE, 7); (* in dec *)
          StrgZap(cardstrg);
***)
      MoveMem(tmpadr, newadr, LONG(movelen));
    ELSIF linelen < startbcol THEN
    (* make room for spaces up to startbcol at new location *)
      tmpadr:= newadr + ADDRESS(LONG(startbcol - linelen));
      movelen:= SHORT(last - LONGCARD(newadr - startadr));
      MoveMem(newadr, tmpadr, LONG(movelen));
(**)
      INC(last, LONGCARD(tmpadr - newadr));
(**)
      newadr:= tmpadr;
      IF (cfg.eollen > 0) & (endline < lastline) THEN
        newadr:= newadr - ADDRESS(LONG(cfg.eollen));
        ptr1:= newadr;
        ptr1^:= 15C; (* CR *)
        INC(ptr1);
        ptr1^:= 12C; (* LF *)
      END; (* if need cr/lf *)
    END; (* if linelen > or < startbcol *)
    (* now move block line *)
    newadr:= newadr - ADDRESS(LONG(blockwidth));
    fromadr:= fromadr - ADDRESS(LONG(blockwidth)) - 2; (* skip cr/lf *)
    MoveMem(fromadr, newadr, LONG(blockwidth));

    (* finally move line leader if any and/or put spaces *)
    tmpadr:= startadr + ADDRESS(longptr^); (* start of line *)
    movelen:= Min(linelen, startbcol);
    newadr:= newadr - ADDRESS(LONG(startbcol));
    MoveMem(tmpadr, newadr, LONG(startbcol)); (* LONG(movelen)); *)
    (* now make that new area into spaces *)
    LOOP
      IF linelen >= startbcol THEN
        EXIT;
      END;
      ptr1:= newadr + ADDRESS(linelen);
      ptr1^:= ' '; (* 40C *)
      INC(linelen);
(**
      INC(last);
**)
    END; (* space loop *)

    IF endline <= tmpln THEN
      EXIT;
    END;
    longptr2:= ADDRESS(longptr);
  END; (* loop *)
  (* adjust lineptrs here or just do Lineptrs call at end? *)
  Lineptrs(tmpln);
  Display(curdispline, cfg.maxdispline);
  RETURN TRUE;
END Pastecolblk;
(*+****)
(*ds*)


PROCEDURE DeleteChar;
VAR n, tmpend: LONGCARD;
    k: CARDINAL;
BEGIN
  IF (last > 0) & (i < last) THEN (* is something to delete here *)
    tmpln:= line + curdispline;
    tmpend:= Findend(tmpln);
    ptr1:= startadr + ADDRESS(i);
(*ds*)
    RuinBlock(FALSE); (* just ruin if char is before blockend *)
(*ds*)
    IF (i < tmpend) OR ((cfg.eollen = 0) & (i = tmpend) & (linepos > 0))
     THEN (* just process that one char *)
      (* don't delete first char of line in hack mode *)
      (* Shift text back in charray *)
      MoveMem(ADDRESS(ptr1) + 1, ptr1, last - i);
      DEC(last);
 
      (* decrement all subsequent line pointers *)
      FOR j:= tmpln + 1 TO lastline DO
        longptr:= lnptradr + ADDRESS(4*LONG(j));
        longptr^:= longptr^ - 1;
      END; (* for rest of line pointers *)
 
      (* shift rest of line left one space *)
      Lineout(tmpln, linepos, displaylen);
      n:= 0;
      IF tmpln = lastline THEN
        n:= 1;
      END;
      longptr:= lnptradr + ADDRESS(4*LONG(tmpln));
      IF tmpend <= longptr^ + n + LONG(displaylen + startcol) THEN
        Conzap(40C); (* Bconout(40C, 5); *)(* was <, blank out old eolchar with a space *)
      END; (* if need to blank out old eol *)
      IF (cfg.eollen = 0) & (linepos+startcol >= SHORT(tmpend-longptr^)) THEN
        k:= 0FFFFH; (* to whole paragraph *)
        j:= Wrapblock(tmpln, k);
        Display(curdispline, cfg.maxdispline);
        Bottomstay; (* does display *)
      END;
      CursorPos(curdispline, leftedge+linepos);
    ELSE (* deleting eol char and eollen > 0, or 1st char in hack mode *)
      IF (linepos = 0) & (startcol = 0) THEN (* blank line *)
        DeleteLine(tmpln); (* this handles save to pastebuffer on its own *)
      ELSE
        (* delete CR/LF, and redo lnptrs and wrap *)
        ptr1^:= ' '; (* change CR to space *)
        n:= 1;
        longptr:= lnptradr + ADDRESS(4*LONG(tmpln) + 4);
        IF Findend(tmpln + 1) = longptr^ THEN (* next line is blank *)
          (* don't want to insert space *)
          n:= 0;
        END;
        (* move text back 1 or 2 chars, 2 if don't want space *) 
        MoveMem(ADDRESS(ptr1) + 2, ADDRESS(ptr1) + ADDRESS(n), last - i - n);

        (* move lnptrs *)
        wrapadr:= lnptradr + ADDRESS(4*LONG(tmpln) + 8);
        MoveMem(wrapadr, wrapadr - 4, 4*LONG(lastline - tmpln));
        (* adjust lnptrs by -2 *)
        DEC(lastline);
        DEC(last, 2-n); (* was 2 *)
        j:= tmpln + 1;
        WHILE j <= lastline DO
          longptr:= lnptradr + ADDRESS(4*LONG(j));
          longptr^:= longptr^ - (2 - n);
          INC(j);
        END; (* while *)
(*ds*)
(* 2.30 1/2/92 *)
        IF cfg.autowrap THEN
          k:= 0FFFFH; (* to whole paragraph *)
          j:= Wrapblock(tmpln, k); (* or tmpln, tmpln for just that line *)
        END; (* if autowrap *)
(*ds*)
        (* keep last line on bottom *)
        Display(curdispline, cfg.maxdispline);
        Bottomstay; (* does display *)
      END; (* if delete CR *)
    END; (* if newchar <> CR *)
    saved:= FALSE;
  END; (* if (last > 0) & (i < last) *)
END DeleteChar;

PROCEDURE Backspace;
BEGIN 
  (* simplified when changed Leftarrow to do Shift Screen for extended line *)
  IF i > 0 THEN
    Leftarrow;
    IF (cfg.eollen > 0) OR (cfg.insertmode = TRUE) THEN
      DeleteChar;
    END; (* if not hack mode *)
  END; (* if i > 0 *)
END Backspace;

(*$S-,$T- *)
(* 32 bit *)
PROCEDURE Lineptrs(j: CARDINAL);
(* Find start of lines & build lnptrarray from line j, e.g., after reading in a file *)
VAR klong: LONGCARD;
    saveA1, saveA2, saveD1, saveD2, saveD3, saveD4: ADDRESS;
BEGIN
 (* first char always starts first line *)
  longptr:= lnptradr;
  longptr^:= 0;  (* this init shouldn't be needed ?? *)

  INC(longptr, 4*LONG(j));
  klong:= longptr^; (* line pointer of starting line *)

  lastline:= j; (* needed for silly new ML routine *)

(*ds*)
  IF cfg.eollen = 0 THEN (* in Hack Mode *)
    IF (cfg.hackable) THEN (* 3.2 wrap at cr/lf's or window edge *)
      wrapW:= displaylen;
      lastcol:= wrapW;
      LOOP 
        IF (j >= maxlines) OR (klong + 2 > last) THEN (* no more lines possible *)
          EXIT;
        END;
        k:= 0; (* where we are in line *)
        LOOP (* for each line *)
          IF (klong (* + 2 *) >= last) THEN
            EXIT; (* within line loop & will exit outer loop *)
          ELSE (* more text to process *)
            IF (k > wrapW) THEN (* create a wrapped line *)
              INC(longptr, 4);
              longptr^:= klong;
              INC(j); (* create wrapped newline *)
              EXIT; (* within line loop *)
            ELSE (* check for cr/lf *)
              ptr1:= startadr + ADDRESS(klong);
              IF ptr1^ = 15C THEN (* found CR *)
                INC(ptr1);
                IF ptr1^ = 12C THEN (* found LF end of line *)
                  INC(longptr, 4);
                  INC(klong, 2);
                  longptr^:= klong;
                  INC(j); (* create cr/lf newline *)
                  EXIT; (* within line loop *)
                END; (* if found cr/lf before wrapw *)
              END; (* if found cr *)
            END; (* if hit wrapW or cr/lf *)
          END; (* if at end of text *)
          INC(klong);
          INC(k);
        END; (* within line loop *)
      END; (* while loop *)
      lastline:= j;
    ELSE (* no wrap at CR/LF, just at 64/32 cols *)
      lastcol:= wrapW;
      WHILE (j < maxlines) & (klong + LONG(wrapW) < last) DO
        (* i.e., there IS another line *)
        INC(j);
        INC(klong, wrapW); (* this used to be able to go beyond 65535 ! *)
        INC(longptr, 4);
        longptr^:= klong;
      END; (* while assigning lnptrs *)
      lastline:= j;
    END; (* if wrap CRs. cfg.hackable *)
  ELSE (* eollen:= 2; *) (* force to cr/lf as eol chars *)
(*ds*)
    IF last-klong >= LONG(cfg.eollen) THEN (* could be more line(s) *)
   (**
      CODE(048E7H, 07060H); (*  movem.l A1-A2/D1-D3,-(SP) *)
   **)
      saveA1:= REGISTER(A1);
      saveA2:= REGISTER(A2);
      saveD1:= REGISTER(D1);
      saveD2:= REGISTER(D2);
      saveD3:= REGISTER(D3);
      saveD4:= REGISTER(D4);
   (**)
   (*
      SETREG(A0, startadr); (* startadr + offset of startline *)
   *)
      SETREG(A1, longptr); (* lnptradr + 4*ln *)
      SETREG(D0, maxlines);
      SETREG(D1, klong); (* char offset *)
      SETREG(D2, last); (* as loop counter *)
      SETREG(D3, j);
      SETREG(D4, startadr);
   
      (* sub.l D1,D2 *)
      CODE(09481H); (* D2:= last-klong as loop counter *)
 (*
      (* subq.l #2,D2 *) (** NOTE: must make this eollen if allow other than 2 **)
      CODE(05582H); (* for eollen *)
 *)  
 (** 2.30 1/18/92 **)
      (* subq.l #1,D2 *) (** NOTE: must make this eollen if allow other than 2 **)
      CODE(05382H); (* for eollen *)
(** **)
      (* movea.l D4,A2 *) (* save startadr *)
      CODE(02444H);
      (* adda.l D1,A2 *) (* set A2 at current char *)
      CODE(0D5C1H);
   
      (* addq.l #4,A1 *)
      CODE(05889H); (* get pointing to next lnptradr *)
 (* LOOP *)
      (* cmpi.b #13,(A2)+ *)
      CODE(00C1AH, 0000DH); (* eolstrg[0] *)
      (* bne.s END1 *)
      CODE(06612H);
      (* cmpi.b #10,(A2)+ *)
      CODE(00C1AH, 0000AH); (* eolstrg[1] *)
      (* bne.s END0 *)
      CODE(0660AH);
 
      (* Found Line start *)
   (*
      (* addq.l #1,D1 *) (* inc(klong) *)
      (* move.l D1,(A1)+ *)
   *)
   (*
      (* move.l A2,(A1)+ *)
      CODE(022CAH);
   *)
      (* move.l A2,(A1) *)
      CODE(0228AH);
      (* sub.l D4,(A1)+ *)
      CODE(09999H);
      (* addq.w #1,D3 *)
      CODE(05243H); (* inc lnptr *)
      (* cmp.w D3,D0 *) (* up to maxlines yet? *)
      CODE(0B043H);
   (*
      (* bls.s END2 *)
      CODE(06306H);
   *)
      (* beq.s END2 *) (* reached maxlines, so exit *)
      CODE(06706H);
   
    (* END0 *)
      (* subq.l #1,A2 *)
      CODE(0538AH);(* to make up for having done (A2)+ for second char *)
    (* END1 *)
   (**
      (* dbra D2,LOOP *)
      CODE(051CAH, 0FFE8H);
   **)
      (* subq.l #1,D2 *) (* dec(counter) *)
      CODE(05382H);
 (*
      (* bcc.s LOOP *) (* D2 > 0 *)
      CODE(064E4H);
 *)
      (* bhi.s LOOP *) (* D2 > 0 *)
      CODE(062E4H);
    (* END2 *)
 
      lastline:= SHORT(LONGCARD(REGISTER(D3)));
      (* restore all registers used *)
   (**
      (* movem.l A1-A2/D1-D3,(SP)+ *)
      CODE(048DFH, 0060EH); (* movem.l A1-A2/D1-D3,(SP)+ *)
   **)
      SETREG(A1, saveA1);
      SETREG(A2, saveA2);
      SETREG(D1, saveD1);
      SETREG(D2, saveD2);
      SETREG(D3, saveD3);
      SETREG(D4, saveD4);

    END; (* if last >= eollen *)
(**)
(*ds*)
  END; (* if eollen = 0 or 2 *)
(*ds*)
  IF lastline >= maxlines THEN (* too many lines *)
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[1][WARNING|Ran out of|available lines][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
  END; (* if too many lines *)
END Lineptrs;

(*ds*)
PROCEDURE RuinBlock(always: BOOLEAN);
(* gets rid of marked block either always, or only if i is before blockend 
   in insertmode or somewhere in block in overwrite mode *)
BEGIN
  IF (blocktype > 0) (* isblock *) & (always OR 
    ((i < blockend) & (cfg.insertmode OR (i >= blockstart)))) THEN
    (* erases block hilite: *)
    ShowBlock(line, line + cfg.maxdispline, blockstart, blockend);
    blocktype:= 0; (* isblock:= FALSE; *)
    notistrg:= '';
    InitMenu; (* get rid of BLOCK msg *)
  END; (* if insert/delete in block or want to clear block *)
END RuinBlock;
(*ds*)

PROCEDURE Copyblock(delend: LONGCARD): BOOLEAN;
(* delstart is global *)
BEGIN
  (* check if room in paste buffer for block *)
  blocklen:= delend - delstart; (* assumes end is 1 past last to be cut *)
  IF NOT BuffRoom() THEN
    RETURN FALSE;
  END;
(********
  isroom:= TRUE;
  IF (blocklen + pastelen) > 4*LONG(maxlines) THEN (* is not room, since 4 bytes per line pointer *)
    isroom:= FALSE;
    Showmouse; (* lineA Show mouse *)
    int:= FormAlert(1,'[3][Block is bigger than paste|buffer, so no undo/paste][Continue|Cancel]');
    CODE(0A00AH); (* lineA Hide mouse *)
    IF int <> 1 THEN (* abort *)
      RETURN FALSE;
    END;
  END; (* if block too big for undo *)
*******)
  (* if is room in buffer, Movemem block to paste buffer *)
  Movetobuff(blocklen);
  RETURN TRUE;
END Copyblock;

PROCEDURE Cutblock(delend: LONGCARD): BOOLEAN;
(* delstart is global *)
BEGIN
(***
  (* check if room in paste buffer for block *)
  blocklen:= delend - delstart; (* assumes end is 1 past last to be cut *)
  isroom:= TRUE;
(*ds*)
  IF (blocklen + pastelen) > 4*LONG(maxlines) THEN (* is not room, since 4 bytes per line pointer *)
    isroom:= FALSE;
    Showmouse; (* lineA Show mouse *)
    int:= FormAlert(1,'[3][Block is bigger than paste|buffer, so no undo/paste][Continue|Cancel]');
    CODE(0A00AH); (* lineA Hide mouse *)
    IF int <> 1 THEN (* abort *)
      RETURN FALSE;
    END;
  END; (* if block too big for undo *)
  (* if is room in buffer, Movemem block to paste buffer *)
  Movetobuff(blocklen);
(*ds*)
***)
  IF NOT Copyblock(delend) THEN
    RETURN FALSE;
  END;

  saveline:= Findline(delstart);
  (* Now MoveMem all text after block to current cursor position *)
  MoveMem(startadr + ADDRESS(delend), startadr + ADDRESS(delstart), last - delend);
  DEC(last, blocklen);
  (* fix line pointers *)
  (* why not determine saveline at start of this routine? *)
  Lineptrs(saveline); (* starting line of block *)
  (* set cursor position to where block started *)
  i:= delstart;

  longptr:= lnptradr + ADDRESS(4*LONG(saveline));
  IF startcol > SHORT(i - longptr^) THEN

    (** since could crash if inc'd startcol after setting blockstart **)
    startcol:= 0;
    linepos:= 0;
    i:= longptr^;
    Display(0, cfg.maxdispline);
  ELSE
    linepos:= SHORT(i - longptr^) - startcol;
  END;
  IF (saveline < line) OR (saveline > line + cfg.maxdispline) THEN
    line:= saveline; (* get where block started into window *)
    curdispline:= 0;
  ELSE
    curdispline:= saveline - line; (* just get it back to blockstart *)
  END;
(*
  isblock:= FALSE; (* only if deleted a marked block, rather than line *)
*)
  saved:= FALSE;
  RETURN TRUE;
END Cutblock;

PROCEDURE PasteAlert;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][There is nothing to paste][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
END PasteAlert;

(*ds*)
PROCEDURE Pasteblock;
BEGIN
  IF pastelen > 0 THEN
    IF pastelen < buffsize - last THEN (* is room for paste *)
      (* Shift all text after cursor pastelen bytes up in memory to make room for paste *)
      ptr1:= startadr + ADDRESS(i);
      MoveMem(ptr1, ADDRESS(ptr1) + ADDRESS(pastelen), last - i + 1);
      INC(last, pastelen);
      (* INC(i); *)  (* keep cursor at start of inserted block *)
      (* Movemem pastelen bytes from undo buffer to beginning of current LINE, not cursor pos *)
      MoveMem(newlnptradr, ptr1, pastelen);
      (* fix line pointers *)
      Lineptrs(line + curdispline); (* for now simply recompute them all *)
      (* redraw window from current line down *)
      Display(curdispline, cfg.maxdispline);
      SetSlideSize;
      SetSlidePos;
      saved:= FALSE;
    ELSE
      FullAlert; 
    END; (* if is room for paste *)
  ELSE
    PasteAlert;
  END; (* if a pasteblock exists *)
END Pasteblock;

PROCEDURE BlockAlert;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[1][First mark a block|with F1/F2 or Mouse][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
END BlockAlert;

(** 3.1 **)
PROCEDURE ChangeCase(lowupper: INTEGER);
(* lowupper: 1=make lower, 2=makeupper, 3=capitalize *)
VAR counter: LONGCARD;
    ptr2: POINTER TO CHAR;

  PROCEDURE Upper;
  BEGIN
    IF (ptr1^ >= 141C) & (ptr1^ <= 172C) THEN (* is now lower case *)
      ptr1^:= CHR(ORD(ptr1^) - 32);
    END; (* if make UC *)
  END Upper;

  PROCEDURE Lower;
  BEGIN
    IF (ptr1^ >= 101C) & (ptr1^ <= 132C) THEN (* is now upper case *)
      ptr1^:= CHR(ORD(ptr1^) + 32);
    END; (* if make UC *)
  END Lower;

BEGIN
(* go from blockstart to blockend *)
  IF blocktype > 0 THEN (* is block *)
    ptr1:= startadr + ADDRESS(blockstart);
    IF blockstart > 0 THEN
      ptr2:= ADDRESS(ptr1) - ADDRESS(1);
    ELSE
      ptr2:= ADDRESS(ptr1);
    END;
    blocklen:= blockend - blockstart;
    counter:= 0;
    IF lowupper = 1 THEN (* make lowercase *)
      LOOP
        IF counter >= blocklen THEN
          EXIT;
        END;
        Lower;
        INC(ptr1);
        INC(counter);
      END; (* lower loop *)
    ELSIF lowupper = 2 THEN (* make uppercase *)
      LOOP
        IF counter >= blocklen THEN
          EXIT;
        END;
        Upper;
        INC(ptr1);
        INC(counter);
      END; (* lower loop *)
    ELSE (* Capitalize *)
      LOOP
        IF counter >= blocklen THEN
          EXIT;
        END;
        IF ptr2 = ADDRESS(ptr1) THEN (* first char of buffer *)
          Upper;
        ELSE (* if prior char is char, then make lower *)
          IF ((ptr2^ >= 101C) & (ptr2^ <= 132C))
          OR ((ptr2^ >= 141C) & (ptr2^ <= 172C)) THEN
            Lower;
          ELSE (* else make upper *)
            Upper;
          END;
        END; (* if ptr2 *)
        ptr2:= ADDRESS(ptr1);
        INC(ptr1);
        INC(counter);
      END; (* lower loop *)
    END; (* if lower *)
    saved:= FALSE;
    Display(0, cfg.maxdispline);
  ELSE (* no block *)
    BlockAlert;
  END; (* if isblock *)
END ChangeCase;
(***)

PROCEDURE FileAlert;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[1][WARNING: File not found|or other Read error][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
END FileAlert;


PROCEDURE OpenFile(VAR fname: Fseltype; VAR handle: INTEGER;
                   VAR flen: LONGCARD): BOOLEAN;
BEGIN
  Open(fname, 0, handle); 
  IF handle < 0 THEN
    ok:= Close(handle);
    RETURN FALSE;
  END;
  Seek(0, handle, end, flen); (* get file length, actually last file index *)
(**
  (* remove for 2.30 1/9/92 *)
  IF (flen <= 0) THEN (* file is zero bytes long *)
    ok:= Close(handle);
    RETURN FALSE;
  END;
**)
  RETURN TRUE;
END OpenFile;


PROCEDURE Mergefile(VAR fname: Fseltype; topastebuff: BOOLEAN): BOOLEAN;
VAR flen: LONGCARD;
    toadr: ADDRESS;
BEGIN
  IF NOT OpenFile(fname, handle, flen) THEN
    FileAlert;
    RETURN FALSE;
  END;
  (* openfile leaves seek pointer at end of file *)
  ok:= Close(handle);
  (* count:= Min(SHORT(flen), SHORT(buffsize - LONG(last))); *)
  IF flen > buffsize - last THEN (* file too big to merge *)(* 32 bit *)
    FullAlert;
    RETURN FALSE;
  END;
  GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)
  RuinBlock(TRUE);
  IF topastebuff THEN
    blocklen:= flen;
    pastelen:= 0;
    IF NOT BuffRoom() THEN
      RETURN FALSE;
    END;
    IF flen > 4*LONG(maxlines) THEN (* truncate *)
      flen:= 4*LONG(maxlines);
    END;
    pastelen:= flen;
    toadr:= newlnptradr;
  ELSE (* to text *)
    (* make room for inserted text *)
    ptr1:= startadr + ADDRESS(i);
    (* ptr2:= ADDRESS(ptr1) + ADDRESS(flen); *)
    MoveMem(ptr1, ADDRESS(ptr1) + ADDRESS(flen), last - i + 1);
    INC(last, flen); (* 32 bit.  was SHORT(flen)); *)
    toadr:= startadr + ADDRESS(i);
  END; (* if topastebuff *)
  Open(fname, 0, handle); (* gets beginning of file, already verified exist *)
(*
  Seek(0, handle, beginning, count); (* reposition to start of disk file *)
*)
  count:= flen;
  Read(handle, count, toadr);
  ok:= Close(handle);
  GrafMouse(GEMAESbase.Arrow, NIL); (* from busy bee *)
  IF count <> flen THEN (* read error *)
    FileAlert;
    RETURN FALSE;
  END;
  RETURN TRUE;
END Mergefile;
(*ds*)

PROCEDURE Readfile(VAR fname: Fseltype; VAR startread, endread: LONGCARD): CARDINAL;
 (* read in requested portion of file *)
 (* Returns: 0 = read error, not found, zero length, 1 = ok, 2 = too big for buffer *)
VAR flen, pos: LONGCARD;
BEGIN
  IF NOT OpenFile(fname, handle, flen) THEN
    RETURN 0;
  END;
  IF flen < endread THEN (* file is shorter than requested length *)
    endread:= flen;
  END;
  count:= endread - startread; (* should be +1? *)
  IF (count > buffsize - 4) THEN (* too big, leaving a couple safety spaces *)
    endread:= flen; (* in case I want to let user know size or # of blocks *)
    ok:= Close(handle);
    RETURN 2;
  END;

  Showmouse; (* lineA Show mouse *)
  GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)

  Seek(startread, handle, beginning, pos); (* reposition to read file *)
  pos:= count;
  Read(handle, count, startadr); (* ADR(charray)); *)

  ok:= Close(handle);
  GrafMouse(GEMAESbase.Arrow, NIL); (* end busy bee *)
  CODE(0A00AH); (* lineA Hide mouse *)

  IF count <> pos THEN (* read error *)
    RETURN 3; (* probably read in something, but not all of it *)
  END;
  RETURN 1; (* all ok *)
END Readfile;


PROCEDURE MakeBak(VAR fname: Fseltype; ext: ARRAY OF CHAR): BOOLEAN;
(* Renames file to .BAK after deleting existing BAK if there was one *)
(* changed to boolean 2.30 1/2/92 *)
VAR j, k, len: CARDINAL;
    fseltmp: Fseltype;
    tmphandle: INTEGER;
    tmplong2: LONGCARD;
    (** ext: ARRAY[0..3] OF CHAR; **)
BEGIN
(**2.12**
  ext:= 'BAK';
**2.12**)
  fseltmp:= fname;
  len:= Length(fname);
  j:= len;
  k:= 0;
  WHILE (j > 0) & (k < 4) DO (* find current '.' if exists *)
    DEC(j);
    INC(k);
    IF fname[j] = '.' THEN
      k:= 4; (* force end *)
    END;
  END; (* while finding '.' *)
  IF fname[j] <> '.' THEN (* '.' wasn't found, so tack onto end *)
    j:= len; (* '.' wasn't found, or is at position zero *)
  END;
  fname[j]:= '.';
  INC(j);
  FOR k:= 0 TO 2 DO
    fname[j + k]:= ext[k];
  END; (* for *)
  fname[j + 3]:= 0C; (* terminator *)
  (* END ChangeExt; *)

(*%%%%%%%%%
(*******)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
(*
  GetDTA(tmpadr); (* temporary use *)
*)
  PUSH(02FH); (* GetDTA opcode *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
  olddta:= ADDRESS(REGISTER(D0)); (* use wrapadr as temp address *)

  (* try using my own DTA 2.30 1/30/92 *)
  (* SetDTA(ADR(DTA))); *)
  SETREG(A0, ADR(DTA));
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(*********)

  SFirst(fname, 017H, int); (* = all file types: hidden, system, & folders *)

(*********)
  (* SetDTA(olddta); *)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  SETREG(A0, olddta);
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(**********)
  IF int = 0 THEN (* BAK file exists already, so delete it *)
%%%%%%%%%%%*)
(*%%*)
  (* 2.33 4/8/92 *)
  Open(fname, 0, tmphandle); 
  ok:= Close(tmphandle);
  IF tmphandle >= 0 THEN  (* file exists already *)
(*%%*)
(*
    ok:= Delete(fname);
*)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(ADR(fname));
    PUSH(041H); (* gemdos delete file opcode *)
    CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
    CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
    (* 2.30 1/2/92 *)
    (* need to tst D0 to see if was error like disk write protected *)
    (* tst.w D0   ; 0 means all ok *)
    k:= SHORT(LONGCARD(REGISTER(D0)));
    IF k <> 0 THEN
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1,'[3][Not able to delete|old BAK file][ OK ]');
      CODE(0A00AH); (* lineA Hide mouse *)
      RETURN FALSE;
    END; (* if error on rename *)
  END;
(*
  Rename(fseltmp, fname);
  (* renames old file to BAK; does nothing if that file already exists *)
  (* "Rename fseltmp to fname" *)
*)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  PUSH(ADR(fname));
  PUSH(ADR(fseltmp));
  PUSH(00H);
  PUSH(056H); (* gemdos rename opcode *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
  CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  (* 2.30 1/2/92 *)
(* need to tst D0 to see if was error like disk write protected *)
  (* tst.w D0   ; 0 means all ok *)
  k:= SHORT(LONGCARD(REGISTER(D0)));
  IF k <> 0 THEN
    Showmouse; (* lineA Show mouse *)
    dummy:= FormAlert(1,'[3][Unable to rename|file to BAK][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN FALSE;
  END; (* if error on rename *)
(*
  fname:= fseltmp; (* restore since used VAR *)
*)
  RETURN TRUE;
END MakeBak;

PROCEDURE WriteErr;
BEGIN
  Showmouse; (* lineA Show mouse *)
  dummy:= FormAlert(1,'[1][Write Error, Disk full?][ OK ]');
  CODE(0A00AH); (* lineA Hide mouse *)
END WriteErr;

PROCEDURE Writefile(VAR fname: Fseltype; startblk, endblk: LONGCARD;
                    bigpart: BOOLEAN; overpend: INTEGER): BOOLEAN;
(*
  overpend parameter added in 2.30...
   0 = no force overwrite or append
   1 = force overwrite
   2 = force append
*)
VAR handle0: INTEGER; (* for destination file *)
    countblk, endbig, pos, count: LONGCARD;
    j, blocks: CARDINAL;
    badwrite: BOOLEAN;
    fseltmp, fseltmp2: Fseltype; (** 2 added for 2.11 **)
    tmpadr: ADDRESS;
    int: INTEGER;

  PROCEDURE CheckWrite; (* tells if disk full or other error *)
  BEGIN
    IF pos <> countblk THEN
      badwrite:= TRUE;
    END;
  END CheckWrite;

  PROCEDURE WriteRemains(remainder: LONGCARD);
  (* writes portions of bigfile before and after buffer part *)
  BEGIN
    j:= 0;
    pos:= countblk; (* for checking if write is successful *)
    WHILE (j < blocks) DO (* read from old file *)
      Read(handle0, countblk, newlnptradr);
      Write(handle, countblk, newlnptradr);
      INC(j);
    END; (* while copying blocks *)
    CheckWrite;
    countblk:= remainder MOD countblk; (* now do remainder *)
    IF countblk > 0 THEN
      pos:= countblk; (* for checking write *)
      Read(handle0, countblk, newlnptradr);
      Write(handle, countblk, newlnptradr);
      CheckWrite;
    END; (* if copy remainder *)
  END WriteRemains;

BEGIN (* main writefile *)
  IF bigpart & (Compare(fname, fsel)) THEN (* need to rename original as .BAK *)
    (* should check if saved & if last = endf - startf *)
    IF NOT MakeBak(fsel, 'BAK') THEN (* 2.30 1/2/92 *)
      RETURN FALSE; (* doesn't need another alert *)
    END;
    fseltmp:= fsel;
  END; (* if make BAKup *)

(*%%%%%%%%%
(***
  (* try using my own DTA 2.30 1/30/92 *)
  (* SetDTA(ADR(DTA))); *)
  SETREG(A0, ADR(DTA));
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  move.l  a0,-(sp)
  move.w  #$1A,-(sp)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
***)
(*******)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
(*
  GetDTA(tmpadr); (* temporary use *)
*)
  PUSH(02FH); (* GetDTA opcode *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
  olddta:= ADDRESS(REGISTER(D0)); (* use wrapadr as temp address *)

  (* try using my own DTA 2.30 1/30/92 *)
  (* SetDTA(ADR(DTA))); *)
  SETREG(A0, ADR(DTA));
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(*********)

  SFirst(fname, 017H, int); (* 10111 all file types: hidden, system, & folders *)
(*********)
  (* SetDTA(olddta); *)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
  SETREG(A0, olddta);
  CODE(02F08H); (* move.l  a0,-(sp) *)
  CODE(03F3CH,0001AH); (* move.w  #$1A,-(sp) *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(**********)

  IF int = 0 THEN (* file exists already *)

(********
(*
    GetDTA(tmpadr); (* temporary use *)
*)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)

    PUSH(02FH); (* GetDTA opcode *)
    CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
    CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)

    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)

    tmpadr:= ADDRESS(REGISTER(D0)); (* use wrapadr as temp address *)
    ptr1:= tmpadr + ADDRESS(21);
*********)
    ptr1:= ADR(DTA) + ADDRESS(21);
(*
    j:= ORD(ptr1^); (* make cardinal *)
    IF (0 IN BITSET(j)) OR (4 IN BITSET(j)) THEN
*)
    (* 011H = bits 0 and 4 set *)

    IF BITSET(011H) * BITSET(ORD(ptr1^)) <> {} THEN (* AND *)
      Showmouse; (* lineA Show mouse *)
      int:= FormAlert(1,'[3][Sorry, Folder or Read-only][ OK ]');
      CODE(0A00AH); (* lineA Hide mouse *)
      RETURN FALSE;
    END; (* if can't save *)
%%%%%%%%*)
(*%%*)
  (* 2.33 4/8/92 *)
  Open(fname, 0, handle); 
  ok:= Close(handle);
  IF handle >= 0 THEN  (* file exists already *)
(*%%*)
    (* if bigpart, has already changed name, so don't get this alert *)
    IF overpend = 0 THEN (* no force append or overwrite *)
      Showmouse; (* lineA Show mouse *)
      overpend:= FormAlert(cfg.defoverwrite,'[2][That file name already exists][Overwrite| Append | Cancel ]');
      CODE(0A00AH); (* lineA Hide mouse *)
    END;

    IF overpend = 3 THEN
      RETURN FALSE; (* TRUE; *) (* cancelled, so no other alert needed *)
    ELSE (* check attributes for read-only *)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
      PUSH(00H); (* move.w  #0,-(sp) not needed for just reading attribs *)
      PUSH(00H); (* move.w  #0,-(sp)  ; to get attribs *)
      SETREG(A0, ADR(fname));
      CODE(02F08H); (* move.l  a0,-(sp) *)
      PUSH(043H); (* Fattrib code *)
      CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
      (* lea.l 10(sp),sp   ; adjust SP *)
      CODE(04FEFH,0000AH);
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
      int:= INTEGER(REGISTER(D0)); (* save attribs *)
      IF (int < 0) OR (BITSET(011H) * BITSET(int) <> {}) THEN (* AND *)
        Showmouse; (* lineA Show mouse *)
        int:= FormAlert(1,"[3][Can't Write, Read-Only][ OK ]");
        CODE(0A00AH); (* lineA Hide mouse *)
        RETURN FALSE; (* no other alert needed *)
      END; (* if can't save *)
    END; (* if cancel or read only *)

    IF overpend = 2 THEN (* Append *)
      cfg.defoverwrite:= 2;
      Showmouse; (* lineA Show mouse *)
      Open(fname, 1, handle); (* 1 = write only *)
      CODE(0A00AH); (* lineA Hide mouse *)
      Seek(0, handle, end, count); (* position at end of file *)
(*2.30*)
      (** Update file date to current date/time **)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)

      (* first get current system date/time *)
      PUSH(02CH); (* gettime code *)
      CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
      CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
      (* returns time code in low word of D0 *)     
      (* move.w D0,D1 *)
      CODE(03200H);
      PUSH(02AH); (* getdate code *)
      CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
      CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
      (* returns datecard in word of D0 *)
      (* swap D1   ; make room for time word *)
      CODE(04841H);
      (* move.w D0,D1    ; put time word into low word of D1 *)
      CODE(03200H);
      (* then set file date/time stamp *)
      tmpadr:= REGISTER(D1); (* NOT an address though *)
      (* move.w #1,-(sp)  ; mode 1 = set *)
      PUSH(1); (* mode 1 = set date/time *)
      PUSH(handle); (* file handle *)
      PUSH(ADR(tmpadr));
      PUSH(057H); (* set date/time opcode *)
      (* trap #1  ; GEMDOS trap *)
      CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
      (* lea.l 10(sp),sp   ; adjust SP *)
      CODE(04FEFH,0000AH);
      (* restore all necessary registers *)
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
(*2.30*)
    ELSE (* Overwrite with or w/o BAK *)
      cfg.defoverwrite:= 1; (* make overwrite the default *)
      (* if bigfile w/o dobak, this never occurs, so fseltmp isn't BAK *)
      IF cfg.dobak THEN (* make (new) BAKup of file *)
        fseltmp:= fname;
        IF NOT MakeBak(fseltmp, 'BAK') THEN (* 2.30 1/2/92 fixed 1/12/92 *)
          RETURN FALSE; (* no other alert needed *)
        END;
(*
        MakeBak(fseltmp, 'BAK');
*)
        (* so fseltmp can later be renamed to orig if error *)
        (*** BUT if is bigpart, then BAK was already made, so won't find need for overwrite? ***)
      END; (* if dobak *)
      Showmouse; (* lineA Show mouse *)
      Create(fname, 0, handle);
      CODE(0A00AH); (* lineA Hide mouse *)
    END;
  ELSE (* file doesn't already exist *)
    Showmouse; (* lineA Show mouse *)
    Create(fname, 0, handle);
    CODE(0A00AH); (* lineA Hide mouse *)
  END; (* if file exists already *)

  badwrite:= FALSE; (* init it *)

  Showmouse; (* lineA Show mouse *)
  GrafMouse(GEMAESbase.HourGlass, NIL); (* busy bee *)

  count:= endblk - startblk;
  IF bigpart THEN (* first copy the chunk before buffer part to new file *)
    (* fix to 4*long() 2.33 4/8/92 *)
    countblk:= 4*LONG(maxlines); (* reinit since changed for remainder of first block *)
    pastelen:= 0;
    Open(fsel, 0, handle0); (* this is now the BAK file to copy from *)
    blocks:= SHORT(startf DIV countblk);
    WriteRemains(startf);
  END; (* if write first part of bigpart file *)

(*  IF NOT badwrite THEN *)

    pos:= count;
    Write(handle, count, startadr + ADDRESS(startblk)); (* write from buffer *)
    IF count <> pos THEN
      badwrite:= TRUE;
    END;

(*   END; *)

  IF bigpart (*& NOT badwrite *) THEN (* then copy the chunk after buffer part to new file *)
    (** 2.33..  was long(4*maxlines) **)
    countblk:= 4 * LONG(maxlines); (* reinit since changed for remainder of first block *)
    Seek(0, handle0, end, endbig); (* get old file length, actually last file index *)
    Seek(endf, handle0, beginning, pos); (* position to read trailing block of bigpart *)
    blocks:= SHORT((endbig - endf) DIV countblk);
    WriteRemains(endbig - endf);
    ok:= Close(handle0);
  END; (* if write last part of bigpart file *)

  IF (NOT Close(handle)) THEN
    badwrite:= TRUE;   
    (* 2.30 was incorrectly setting badright:= close(handle) *)
  END;
(*
  ok:= Close(handle);
*)

  GrafMouse(GEMAESbase.Arrow, NIL); (* end busy bee *)
  CODE(0A00AH); (* lineA Hide mouse *)
  IF badwrite THEN

    (** should rename BAK to Orig, and rename Orig to BAD or XXX **)
    (**)
    fseltmp2:= fname;
    ok:= MakeBak(fseltmp2, 'XXX'); (* since was bad write *)(* but screws fname *)
    (* don't change fname since it is VAR *)
    (**)
    (** then rename BAK to orig **)
(*
    Rename(fseltmp, fname); (* renames old file to BAK; does nothing if that file already exists *)
    (* "Rename fseltmp to fname" *)
*)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(ADR(fname));
    PUSH(ADR(fseltmp));
    PUSH(00H);
    PUSH(056H); (* gemdos rename opcode *)
    CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
    CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
    CODE(0588FH); (* (0101 1000 1000 1111) addq.l #4, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
    WriteErr;
    RETURN FALSE; (* disk full? *)
  END; (* if badwrite *)
  RETURN TRUE; (* all ok *)
END Writefile;

(*ds*)
PROCEDURE ReadConfig(): BOOLEAN;
(** read all config variables from DIARY.CFG file **)
VAR tmplong: LONGCARD;
    fseltmp: Fseltype;
BEGIN  
  (* now get variables from config file *)
  Concat(configpath, configname, fseltmp);
  Open(fseltmp, 0, handle); (* 0 = read only *)
  IF handle < 0 THEN (* file not found *)
    RETURN FALSE;
  END;
  Seek(0, handle, end, count); (* get size of file *)
(**)
  (* remove for 2.30 1/15/92 *)
  tmplong:= SIZE(cfg); (* size of cfg record in bytes *)
  IF count <> tmplong THEN (* incorrect config file size, so abort *)
    RETURN FALSE;
  END;
(**)
  Seek(0, handle, beginning, tmplong); (* reposition at start of file *)
  Read(handle, count, ADR(cfg)); (* ensure this is a valid config size *)
  ok:= Close(handle);
  RETURN TRUE;
END ReadConfig;

PROCEDURE WriteConfig(): BOOLEAN;
(** write new config variables to file **)
VAR tmplong: LONGCARD;
    fseltmp: Fseltype;
    temppath: Pathtype;
(*
    fsel0tmp: Fsel0type;
*)
BEGIN  
  Concat(configpath, configname, fseltmp);
  Showmouse; (* lineA Show mouse *)
  Create(fseltmp, 0, handle); (* 0 = read/write DIARY.CFG *)
  CODE(0A00AH); (* lineA Hide mouse *)
  IF handle < 0 THEN
    RETURN FALSE;
  END;
  tmplong:= SIZE(cfg); (* size of cfg record in bytes *)
  Write(handle, tmplong, ADR(cfg)); (* write cfg record to file *)
  ok:= Close(handle);

(*
  IF buffsize <> newbuffsize THEN (* save new size to main acc file *)
*)
  IF accbuffsize <> newbuffsize THEN (* save new size to main acc file *)
    (* later need to allow other names for MultiDesk, and mult acc's *)
    count:= 4; (* 4 bytes to write *)
(****)
    temppath:= configpath;
    diaryname:= 'EDITPLUS.ACC';
(*
    IF daccTitle[0] = 0C THEN (* prg, grab desired ram *)
      diaryname:= 'EDITPLUS.PRG';
    END;
*)
    LOOP
(*
      Concat(configpath, diaryname, fseltmp);
*)
      Concat(temppath, diaryname, fseltmp);
      Showmouse; (* lineA Show mouse *)
      Open(fseltmp, 2, handle); (* 2 = read/write *)
      CODE(0A00AH); (* lineA Hide mouse *)
      IF handle < 0 THEN (* DIARYxxx.ACC not found, let user find file *)
(* allow user finding EdHak file, 2.30 1/26/92 *)
(*
        temppath:= configpath;
*)
        Showmouse; (* lineA Show mouse *)
(*
        dummy:= FormAlert(1,"[3][Not Found/Opened.|Find EditPlus 3.1 in THIS Path|to write New Buffer Size][ OK ]");
*)
        dummy:= FormAlert(1,"[3][Not Found.  Find|EditPlus ACC or PRG|to write New|ACC Buffer Size][ OK ]");
        FileSelectorInput(ADR(temppath), ADR(diaryname), int);
        CODE(0A00AH); (* lineA Hide mouse *)
        IF int = 0 THEN (* CANCEL *)
          RETURN FALSE;
        END;
        (* strip wildcards & filename so path works *)
        j:= Length(temppath); (* was -1, but stripped for safety *)
        WHILE (temppath[j] <> '\') AND (j > 0) DO
          temppath[j]:= 0C;
          DEC(j);
        END; (* while *)
      ELSE (* EdHak acc/prg found & opened *)
        EXIT;
      END; (* if not found/opened EdHak *)
    END; (* open loop *)
(****
      Showmouse; (* lineA Show mouse *)
      dummy:= FormAlert(1,"[3][EdHak file not found.|Must be named EDHAK235.ACC|(or .PRG)][ OK ]");
      CODE(0A00AH); (* lineA Hide mouse *)
      RETURN FALSE;
    END; (* if diary file not found *)
****)
    Seek(10, handle, beginning, tmplong); (* position at bsslen longcard *)

    (* fixes possibility of maxlines > 0FFFFH, 2.35 *)
    IF newbuffsize > (16 * 0FFFFH) THEN
      tmplong:= 080000H; (* 8*(0FFFFH+1) *)
    ELSE (* newbuffsize < 1 meg *)
      tmplong:= newbuffsize DIV 2;
    END;
    tmplong:= bssbaselen + newbuffsize + tmplong; (* adds length for lnptrs *)

    (* maxlines:= 1/20 of total resvd space, x 4 byte/line x 2 lnptr arrays *)
    Write(handle, count, ADR(tmplong));
    ok:= Close(handle);
    (* buffsize:= newbuffsize; *)
  END; (* if save new buffer size *)
  RETURN TRUE;
END WriteConfig;
(*ds*)

BEGIN (* main *)
  (* find where startadr should be = end of bss segment minus buffsize *)
  (* get address of basepage from stack pointer + 4 *)
(*
  (* movea.l A0, A4 *)
  CODE(02848H); (* 0010 1000 0100 1000 *)
*)
(*
  (* A4 = saved stack pointer from GEMACCX2.MOD *)
  adrptr:= REGISTER(A7) + ADDRESS(4); (* 4 pointer to basepage address *)
*)

  bpadr:= ADDRESS(BasePageAddress); (* from my revised GEMACCX *)

(***
  count:= LONGCARD(bpadr);

  j:= SHORT(count DIV 01000000H);
  BConOut(CON, CHR(j));
  IF j < 32 THEN BConOut(CON, '*');
    BConOut(CON, CHR(j+32));
  END;
  dummy:= FormAlert(1,'[3][bpadr 1][ OK ]');

  j:= SHORT((count MOD 01000000H) DIV 010000H);
  BConOut(CON, CHR(j));
  IF j < 32 THEN BConOut(CON, '*');
    BConOut(CON, CHR(j+32));
  END;
  dummy:= FormAlert(1,'[3][That is bpadr 2][ OK ]');

  j:= SHORT((count MOD 010000H) DIV 0100H);
  BConOut(CON, CHR(j));
  IF j < 32 THEN BConOut(CON, '*');
    BConOut(CON, CHR(j+32));
  END;
  dummy:= FormAlert(1,'[3][That is bpadr 3][ OK ]');

  j:= SHORT(count MOD 0100H);
  BConOut(CON, CHR(j));
  IF j < 32 THEN BConOut(CON, '*');
    BConOut(CON, CHR(j+32));
  END;

  dummy:= FormAlert(1,'[3][That is bpadr 4!][ OK ]');

(*
  newbuffsize:= LONGCARD(adrptr^); (* use as tmp to display bpadr *)
  bpadr:= (* REGISTER(A4);*) adrptr^ - 5000; (* 522 *)(* was 1200 with MathLib0 *)
*)
  bpadr:= bpadr - ADDRESS(6000);
  j:= 0;
  LOOP (* find basepage *)
    adrptr:= bpadr + ADDRESS(16);
    startadr:= adrptr^; (* tmp data address *)
    INC(adrptr, 4); (* 20 *)
    IF adrptr^ = 0 THEN (* data len = 0 *)
      INC(adrptr, 4); (* 24 *)
      IF adrptr^ = startadr THEN (* bssadr = data adr *)
        INC(adrptr, 4); (* 28 *)
        IF adrptr^ = ADDRESS(bssbaselen + 03200H) THEN (* assumes 10K buffer *)
(*
          INC(adrptr, 8);
          IF adrptr^ = 0 THEN (* found acc *)
*)
          k:= j DIV 0100H;
          BConOut(CON, CHR(k));
          IF k < 32 THEN BConOut(CON, '*');
            BConOut(CON, CHR(k+32));
          END;
        
          k:= j MOD 0100H;
          BConOut(CON, CHR(k));
          IF k < 32 THEN BConOut(CON, '*');
            BConOut(CON, CHR(k+32));
          END;
        
          dummy:= FormAlert(1,'[3][FOUND !!][ OK ]');
          EXIT;
        END;
      END;
    END;
    INC(bpadr, 2);
    INC(j);
    IF j > 10000 THEN
      dummy:= FormAlert(1,'[3][NOT FOUND][ OK ]');
      EXIT;
    END;
  END; (* loop to find basepage *)

  bpadr:= ADDRESS(count); (* restore to orig *)

 (***)
  bpadr:= (* REGISTER(A4);*) adrptr^ (* - 522 *); (* was 1200 with MathLib0 *)
***)
   (* why? it works with GEMACCX.LNK,
    while the A0 or A7 methods work with normal GEMX.LNK for normal prg *)
  (* get address of start of bss segment *)
  adrptr:= bpadr + ADDRESS(24); (* was bssptr *)
  startadr:= adrptr^ + ADDRESS(bssbaselen);
  (* get length of bss segment, includes buffsize *)
  INC(adrptr, 4); (* adrptr now points to size of bss *)

  (* CAUTION: maxlines used to try going above 65535!! *)

  tmplong:= LONGCARD(adrptr^) - bssbaselen; (* free space to use *)
  buffsize:= 2 * tmplong DIV 3;
  IF buffsize > (16 * 0FFFFH) THEN
    maxlines:= 0FFFFH;
    buffsize:= tmplong - 080000H; (* 8 * LONG(maxlines+1) *);
  ELSE
    maxlines:= SHORT(buffsize DIV 16);
  END; (* if truncate maxlines *)
(**
  maxlines:= SHORT((LONGCARD(adrptr^) - bssbaselen) DIV 24);
  (* since maxlines*8 + buffsize = tmplong *)
  buffsize:= 16 * LONG(maxlines); (* was LONGCARD(bssptr^) - bssbaselen; *)
**)
  newbuffsize:= buffsize;
  accbuffsize:= buffsize;
  lnptradr:= startadr + ADDRESS(buffsize); (* start of lnptrarray *)
(*
  newlnptradr:= lnptradr + ADDRESS(maxlines + maxlines);
*)
  newlnptradr:= lnptradr + ADDRESS(4*LONG(maxlines));
  DEC(maxlines); (* since used to be 0..maxlines, and now is 1 less length *)
(*
  macroptr:= bpadr + ADDRESS(128);
  cfg.macro[1]:= macroptr^; (* see what's there *)
*)
  (* save registers *)
  CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)

(*******
(*
  GetDTA(tmpadr); (* temporary use *)
*)
  PUSH(02FH); (* GetDTA opcode *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
  olddta:= ADDRESS(REGISTER(D0)); (* use wrapadr as temp address *)
********)
(*
  GetPath(fsel, 0); (* 0=current drive, but doesn't give drive or last \ *)
*)
  (* pass this on to main DIARY program to form default paths *)  
  PUSH(00H); (* 0 = current drive *)
  PUSH(ADR(fsel)); (* hold current path temporarily *)
  PUSH(047H); (* get path opcode *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(0508FH); (* (0101 0000 1000 1111) addq.l #8, sp [stack corr.] *)
(*
  GetDrv(j);
*)
  PUSH(019H); (* GetDrv opcode *)
  CODE(04E41H); (* (0100 1110 0100 1101) trap #1 [call GEMDOS] *)
  CODE(0548FH); (* (0101 0100 1000 1111) addq.l #2, sp [stack corr.] *)
  (* restore all necessary registers *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
  j:= CARDINAL(REGISTER(D0));
  cfg.oldpath[0]:= CHR(65 + j);

  ismdx:= FALSE;
  Appl:= ApplInitialise() ; (* was just before Init *)
  IF GEMAESbase.AESIntOut[1] = 04E52H (* MDX *) THEN (* treat as prg *)
    ismdx:= TRUE;
  END;
  daccTitle:= '';
(*
  diaryname:= 'EDITPLUS.PRG';
*)
  adrptr:= bpadr + ADDRESS(36);
  IF adrptr^ = 0 THEN (* is running as desk acc *)
(*
    diaryname:= 'EDITPLUS.ACC';
*)
    daccTitle:= '  Edit Plus';
    dacc:= MenuRegister(Appl, daccTitle);
(*
    dummy:= MenuRegister(-1, 'EDHAK   ');
*)
  END; (* if acc *)
END EdPro2.

