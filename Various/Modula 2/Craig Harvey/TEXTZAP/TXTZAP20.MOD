MODULE Txttst; (* try writing directly to screen *)
FROM SYSTEM IMPORT ADR, PUSH, CODE, SETREG, REGISTER, ADDRESS;
FROM GEMDOS IMPORT NecIn, ConWS;
FROM BIOS IMPORT BConOut, Device;
FROM XBIOS IMPORT GetResolution, ScreenPhysicalBase;

(*****
 Note to non Modula-2 people: hex numbers are denoted by an H at
 the end and must always start with a zero.  Comments, like this,
 are denoted by (* and *) and may be nested.
*****)

CONST
  (* various LineA variables *)
  (* offsets from lineAadr *)
  BYTESLIN  = -002H; (*  -2 *) (* 2 bytes, 80 mono, 160 lo/med res color *)
(*
  (** I ended up not using these variables, but used the ones following
      in case I want to be able to easily switch fonts later **)
  VFNTAD    = -016H; (* -22 *) (* 4 bytes, address of monospaced font *)
  VFNTWD    = -00EH; (* -14 *) (* 2 bytes, font form width in bytes = sum of widths/8 *)
  VCELHT    = -02EH; (* -46 *) (* 2 bytes, txt cell height in pixels *)
  VCURAD    = -022H; (* -34 *) (* 4 bytes, current cursor address *)
  VCURX     = -01CH; (* -28 *) (* 2 bytes, current cursor column, 0 = 1st *)
  VCURY     = -01AH; (* -26 *) (* 2 bytes, current cursor row, 0 = 1st *)
  VCUROF    = -01EH; (* -30 *) (* 2 bytes, bytes from screen base to top of 1st char *)
*)
  VCELWR    = -028H; (* -40 *) (* 2 bytes, bytes to next vert char cell *)
  DATATABLE = 76; (* offset in font header of pointer to font *)
  FORMWIDTH = 80; (* offset in font header of total font width, in bytes *)
                  (* 192 for 6x6, 256 for 8x8 and 8x16 I think *)
  FORMHEIGHT= 82; (* offset in font header of cell height for that font *)
  
  Init = 0A000H; (* LineA initialization code *)

  (* Registers *)
  D0 = 0;
  D1 = 1;
  D2 = 2;
  D3 = 3;
  D4 = 4;
  D5 = 5;
  A0 = 8;
  A1 = 9;
  A2 = 10;

VAR ch: CHAR;
    i,j,k, counter, vfntwd, vcelht, byteslin, vcurx, endcol: CARDINAL;
    (* CARDINAL = unsigned integer for you C types *)
    cardptr, vfntwdptr: POINTER TO CARDINAL;
    adrptr, vfntadptr: POINTER TO ADDRESS;
    lineAadr, fnthdadr, vcurad, vfntad, screenadr, sysfontoffset: ADDRESS;
    res: INTEGER; (* signed *)

PROCEDURE LineAinit;
(* to get addresses of LineA variable table and font headers *)
BEGIN
  (* save all registers to be used *)
  (* movem.l A0-A1/D0-D1,-(SP) *)
  CODE(048E7H, 0C0C0H); (* 0100 1000 1110 0111, 1100 0000 1100 0000 *)
  CODE(0A000H); (* lineA init code, high, low word *)
  lineAadr:= REGISTER(A0); (* A0 = address of lineA variable table *)
  fnthdadr:= REGISTER(A1); (* A1 = address of font headers, 6x6,8x8,8x16 *)
  (* restore all registers used *)
  (* movem.l A0-A2/D0-D2,(SP)+ *)
  CODE(04CDFH, 00303H); (* 0100 1100 1101 1111, 0000 0011 0000 0011 *)
END LineAinit;


PROCEDURE Biostst;
(* Uses BIOS bconout routine, which is the ST's fastest built-in text
   output method as far as I've been able to determine *)
BEGIN
  FOR k:= 0 TO 5 (* screenfuls *) DO
    BConOut(CON, CHR(27));
    BConOut(CON, 'E'); (* clrhome *)
    FOR i:= 1 TO 22 (* lines *) DO
      FOR j:= 0 TO endcol DO
        BConOut(CON, CHR(65 + k)); (* A,B,C... *)
      END; (* for line *)
      BConOut(CON, 15C); (* CR *)
      BConOut(CON, 12C); (* LF *)
    END; (* for lines *)
  END; (* for screens *)
END Biostst;


PROCEDURE Conzap(ch: CHAR); (* fast char output routine to screen *)
BEGIN
    (* save all registers to be used, except scratch registers D0 and A0 *)
    (* movem.l A1-A2/D1-D2,-(SP) *)
    CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  
    SETREG(A0, vcurad);
    SETREG(A1, vfntad);
    SETREG(A2, ADR(vcurad));
  
    SETREG(D0, CARDINAL(ch)); (* make it a word instead of a byte *)
    SETREG(D1, counter); (* vcelht - 2 *)
    SETREG(D2, vfntwd);
  
    (* adda.w  D0,A1 ; get address of char data in font *)
    CODE(0D2C0H); (* 1101 0010 1100 0000 *)
    (* D0 is no longer needed, so should be free for other uses *)
  
    SETREG(D0, byteslin);
  
    IF res = 2 THEN (* hi res monochrome, 1 byte of screen for each char *)
      (** LOOP: **)  (* move char from font to screen one line at a time *)
        (* move.b (a1),(a0) *)
        CODE(01091H); (* 0001 0000 1001 0001 *)
    
        (* adda.w d2,a1 *) (* to get next line in font *)
        CODE(0D2C2H); (* 1101 0010 1100 0010 *)
       
        (* adda.w d0,a0 *) (* to get next line on screen *)
        CODE(0D0C0H); (* 1101 0000 1100 0000 *)

        CODE(051C9H,0FFF8H); (* PC relative decrement & branch *)
        (* 0101 0001 1100 1001, 1111 1111 1111 1000 = DBRA D1,-8 *)
      (** END Loop **)
      (* finally, do last line of character without further incrementing *)
      (* move.b (a1),(a0) *)
      CODE(01091H); (* 0001 0000 1001 0001 *)

      (* addq.l #1,(A2) *) (* INC(vcurad) *)
      CODE(05292H); (* 0101 0010 1001 0010 *)
    ELSIF res = 1 THEN (* medium res color, 2 words for each 2 chars *)
      SETREG(D0, vcurx); (* column *)
      (* check to see if you're at an even column *)
      (* btst #0,D0 *)
      CODE(00800H, 00000H); (* 0000 1000 0000 0000 0000 0000 0000 0000 *)

      (* beq 2(pc) *) (* if even skip next instruction *)
      CODE(06702H); (* 0110 0111 0000 0010 *)

      (* addq.l #1,a0 *) (* so char data will be put into 2nd byte of word *)
      CODE(05288H); (* 0101 0010 1000 1000 *)

      (* addq.l #2,(A2) *) (* INC(vcurad,2) *)
      CODE(05492H); (* 0101 0100 1001 0010 *)

      SETREG(D0, byteslin); (* since I used D0 for something else above *)
 
      (** LOOP: **)  (* move char from font to screen one line at a time *)
        (* move.b (a1),(a0) *)
        CODE(01091H); (* 0001 0000 1001 0001 *)

        (* move.b (a0),2(a0) *) (* copy char data to next word for med res *)
        CODE(01150H, 00002H); (* 0001 0001 0101 0000, 0000 0000 0000 0010 *)

        (* adda.w d2,a1 *) (* to get next line in font *)
        CODE(0D2C2H); (* 1101 0010 1100 0010 *)

        (* adda.w d0,a0 *) (* to get next line on screen *)
        CODE(0D0C0H); (* 1101 0000 1100 0000 *)
    
        CODE(051C9H,0FFF4H); (* PC relative decrement & branch *)
        (* 0101 0001 1100 1001, 1111 1111 1111 0100 = DBRA D1,-12 *)
      (** END LOOP **)
      (* finally, do last line of character without further incrementing *)
      (* move.b (a1),(a0) *)  (* as in loop *)
      CODE(01091H); (* 0001 0000 1001 0001 *)

      (* move.b (a0),2(a0) *)  (* as in loop *)
      CODE(01150H, 00002H); (* 0001 0001 0101 0000, 0000 0000 0000 0010 *)
    ELSE (* res = 0  low res color, 4 words of screen for each 2 chars *)
      SETREG(D0, vcurx); (* column *)
      (* check if at even column *)
      (* btst #0,D0 *)
      CODE(00800H, 00000H); (* 0000 1000 0000 0000, 0000 0000 0000 0000 *)

      (* beq 2(pc) *) (* if even skip next instruction *)
      CODE(06702H); (* 0110 0111 0000 0010 *)

      (* subq.l #3,a0 *) (* to get it back to one byte after prior char *)
      CODE(05788H); (* 0101 0111 1000 1000 *)

      (* addq.l #4,(A2) *) (* INC(vcurad,4) *)
      CODE(05892H); (* 0101 1000 1001 0010 *)

      SETREG(D0, byteslin); (* since used D0 for something else above *)
 
      (** LOOP: **)  (* move char data to screen one line at a time *)
        (* move.b (a1),(a0) *) (* move char data to first of screen bytes *)
        CODE(01091H); (* 0001 0000 1001 0001 *)

        (* move.b (a0),2(a0) *) (* copy char data to 2nd word of screen *)
        CODE(01150H, 00002H); (* 0001 0001 0101 0000, 0000 0000 0000 0010 *)

        (* move.b (a0),4(a0) *) (* copy char data to 3rd word of screen *)
        CODE(01150H, 00004H); (* 0001 0001 0101 0000, 0000 0000 0000 0100 *)

        (* move.b (a0),6(a0) *) (* copy char data to 4th word of screen *)
        CODE(01150H, 00006H); (* 0001 0001 0101 0000, 0000 0000 0000 0110 *)

        (* adda.w d2,a1 *) (* to get next line in font *)
        CODE(0D2C2H); (* 1101 0010 1100 0010 *)

        (* adda.w d0,a0 *) (* to get next line on screen *)
        CODE(0D0C0H); (* 1101 0000 1100 0000 *)
    
        CODE(051C9H,0FFECH); (* PC relative decrement & branch *)
        (* 0101 0001 1100 1001, 1111 1111 1110 1100 = DBRA D1,-20 *)
      (** END LOOP **)
      (* finally, output last (bottom) line of character *)
      (* move.b (a1),(a0) *) (* as in loop *)
      CODE(01091H); (* 0001 0000 1001 0001 *)

      (* move.b (a0),2(a0) *) (* as in loop *)
      CODE(01150H, 00002H); (* 0001 0001 0101 0000, 0000 0000 0000 0010 *)

      (* move.b (a0),4(a0) *) (* as in loop *)
      CODE(01150H, 00004H); (* 0001 0001 0101 0000, 0000 0000 0000 0100 *)

      (* move.b (a0),6(a0) *) (* as in loop *)
      CODE(01150H, 00006H); (* 0001 0001 0101 0000, 0000 0000 0000 0110 *)
    END; (* if hi, med or lo res *)      
  (**
    SETREG(A0, ADR(vcurx));
    (* addq.w #1,(A0) *)  (* INC(vcurx) seems to be just as fast *)
    CODE(05250H); (* 0101 0010 0101 0000 *)
  **)
    (* restore all registers used *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
END Conzap;


PROCEDURE CursorPos(y, x: CARDINAL);  (* row, column *)
(* assembly replacement for vt52 esc-Y or VDI CursorAddress *)
(****
  I just copied this from the back of ST Internals, so there are a few
  points of it that I don't fully understand, but it works.
****)
BEGIN
  (* save all registers to be used *)
  (* movem.l A1-A2/D1-D5,-(SP) *)(* save needed registers, except scratch ones *)
  CODE(048E7H, 07C60H); (* 0100 1000 1110 0111, 0111 1100 0110 0000 *)
  SETREG(A1, screenadr);
  SETREG(A2, lineAadr); (* also is address of number of screen planes *)
  SETREG(D0, x);
  SETREG(D1, y);

  (* move.w (A2),D3 ; *) (* # of screen planes *)
  CODE(03612H); (* 0011 0110 0001 0010 *)

  (* move.w D0,D5 *) (* column *)
  CODE(03A00H); (* 0011 1010 0000 0000 *)

  (* bclr #0,D5 *) (* round down to even column # *)
  CODE(0085H, 00000H); (* 0000 1000 1000 0101, 0000 0000 0000 0000 *)

  (* mulu.w D5,D3 *) (* rounded column times planes *)
  CODE(0C6C5H); (* 1100 0110 1100 0101 *)

  (* btst #0,D0 *) (* see if on an even column *) 
  CODE(00800H, 00000H); (* 0000 1000 0000 0000, 0000 0000 0000 0000 *)

  (* beq 2(pc) *)  (* skip next addition if on even column *)
  CODE(06702H); (* 0110 0111 0000 0010 *)

  (* addq.w #1,D3 *) (* add 1 since it was an odd column *)
  CODE(054C3H); (* 0101 0100 1100 0011 *)

  (* move.w VCELWR(A2),D5 *) (* bytes to next vertical char cell *)
  CODE(03A2AH, VCELWR); (* 0011 1010 0010 1010, VCELWR *)

  (* mulu.w D1,D5 *) (* times line = offset to start of this line *)
  CODE(0CAC1H); (* 1100 1010 1100 0001 *)

  (** move.l ($44E),A1 **) (* screen base address, already done above *)

  (* adda.w D5,A1 *) (* line offset added to screen base *)
  CODE(0D2C5H); (* 1101 0010 1100 0101 *)

  (* adda.w D3,A1 *) (* column offset added to screen base *)
  CODE(0D2C3H); (* 1101 0010 1100 0011 *)
(**
  (* ignore, since should always be zero or maybe this is what the 
     -1 and -3 changes I made to the screen address are! ?? *)
  (* adda.w VCUROF(A2),A1 *) (* offset to first char from screen base *)
  CODE(0D2EAH, VCUROF); (* 1101 0010 1110 1010, VCUROF *)
**)
  vcurad:= REGISTER(A1); (* set screen address for given row and column *)
  (* restore all registers used *)
  (* movem.l A1-A2/D1-D5,(SP)+ *)
  CODE(04CDFH, 0063EH); (* 0100 1100 1101 1111, 0000 0110 0011 1110 *)
END CursorPos;


PROCEDURE CursorDraw;
(* toggles cursor on/off at current screen address, vcurad *)
BEGIN
  (* save all registers to be used *)
  (* movem.l /D1-D3,-(SP) *)(* save needed registers except scratch ones *)
  CODE(048E7H, 07000H); (* 0100 1000 1110 0111, 0111 0000 0000 0000 *)
  (* xor each byte of char with $FF *)
  SETREG(A0, vcurad);
  SETREG(D0, vcurx);
  SETREG(D1, counter); (* vcelht - 2 *)
  SETREG(D2, byteslin);
  SETREG(D3, 0FFH);
  IF res = 2 THEN (* hi res *)
    (** LOOP: **)
      (* eor.b D3,(A0)  also known as XOR *)
      CODE(0B710H); (* 1011 0111 0001 0000 *)
  
      (* adda.w D2,A0 *) (* get to next piece of character on screen *)
      CODE(0D0C2H); (* 1101 0000 1100 0010 *)
  
      CODE(051C9H,0FFFAH); (* PC relative decrement & branch *)
      (* 0101 0001 1100 1001, 1111 1111 1111 1010 = DBRA D1,-6 *)
    (** END LOOP **)
    (* finally, do last line of char on screen *)
    (* eor.b D3,(A0) *)
    CODE(0B710H); (* 1011 0111 0001 0000 *)
  ELSIF res = 1 THEN (* med color *)
    (* if at odd column, inc(a0) and vcurad *)
    (* btst #0,D0 *)
    CODE(00800H, 00000H); (* 0000 1000 0000 0000 0000 0000 0000 0000 *)

    (* beq 2(pc) *) (* if even skip next instruction *)
    CODE(06702H); (* 0110 0111 0000 0010 *)

    (* addq.l #1,a0 *) (* to get to 1st byte of second word of this char *)
    CODE(05288H); (* 0101 0010 1000 1000 *)

    (** LOOP: **)
      (* eor.b D3,(A0) *) (* also known as XOR *)
      CODE(0B710H); (* 1011 0111 0001 0000 *)

      (* eor.b D3,2(A0) *) (* do next word for med res *)
      CODE(0B728H, 00002H); (* 1011 0111 0010 1000, 0000 0000 0000 0010 *)

      (* adda.w D2,A0 *) (* get to next line of character on screen *)
      CODE(0D0C2H); (* 1101 0000 1100 0010 *)

      CODE(051C9H,0FFF6H); (* PC relative decrement & branch *)
      (* 0101 0001 1100 1001, 1111 1111 1111 0110 = DBRA D1,-10 *)
    (** END LOOP **)
    (* finally, do last line of char on screen, as in loop *)
    (* eor.b D3,(A0) *) (* also known as XOR *)
    CODE(0B710H); (* 1011 0111 0001 0000 *)

    (* eor.b D3,2(A0) *) (* do next screen word of char *)
    CODE(0B728H, 00002H); (* 1011 0111 0010 1000, 0000 0000 0000 0010 *)

  ELSE (* res = 0  low res color *)
    (* btst #0,D0 *) (* see if you are at an even column *)
    CODE(00800H, 00000H); (* 0000 1000 0000 0000 0000 0000 0000 0000 *)

    (* beq 2(pc) *) (* if even skip next instruction *)
    CODE(06702H); (* 0110 0111 0000 0010 *)

    (* subq.l #3,a0 *) (* to get it back to one byte after prior char *)
    CODE(05788H); (* 0101 0111 1000 1000 *)

    (** LOOP: **)
      (* eor.b D3,(A0) *) (* also known as XOR *)
      CODE(0B710H); (* 1011 0111 0001 0000 *)

      (* eor.b D3,2(A0) *)  (* do next screen word of char *)
      CODE(0B728H, 00002H); (* 1011 0111 0010 1000, 0000 0000 0000 0010 *)

      (* eor.b D3,4(A0) *) (* do next screen word of char *)
      CODE(0B728H, 00004H); (* 1011 0111 0010 1000, 0000 0000 0000 0100 *)

      (* eor.b D3,6(A0) *) (* do next screen word of char *)
      CODE(0B728H, 00006H); (* 1011 0111 0010 1000, 0000 0000 0000 0110 *)

      (* adda.w D2,A0 *) (* get to next line of character on screen *)
      CODE(0D0C2H); (* 1101 0000 1100 0010 *)

      CODE(051C9H,0FFEEH); (* PC relative decrement & branch *)
      (* 0101 0001 1100 1001, 1111 1111 1110 1110 = DBRA D1,-18 *)
    (** END LOOP **)

    (* finally, do last line of char on screen, as in loop *)
    (* eor.b D3,(A0) *)
    CODE(0B710H); (* 1011 0111 0001 0000 *)

    (* eor.b D3,2(A0) *) (* as in loop *)
    CODE(0B728H, 00002H); (* 1011 0111 0010 1000, 0000 0000 0000 0010 *)

    (* eor.b D3,4(A0) *) (* as in loop *)
    CODE(0B728H, 00004H); (* 1011 0111 0010 1000, 0000 0000 0000 0100 *)

    (* eor.b D3,6(A0) *) (* as in loop *)
    CODE(0B728H, 00006H); (* 1011 0111 0010 1000, 0000 0000 0000 0110 *)

  END; (* if hi or med res *)
  (* restore all registers used, except scratch ones *)
  (* movem.l /D1-D3,(SP)+ *)
  CODE(04CDFH, 0000EH); (* 0100 1100 1101 1111, 0000 0000 0000 1110 *)
END CursorDraw;

BEGIN (* main *)
  LineAinit; (* gets lineAadr & fnthdadr *)
  res:= GetResolution();
  screenadr:= ScreenPhysicalBase() -1; (* why -1?? because it works *)
  sysfontoffset:= ADDRESS(8); (* assume mono 8x16 font and change if color *)
  endcol:= 78;
  IF res < 2 THEN (* color *)
    sysfontoffset:= 4; (* 8x8 font *)
    IF res = 0 THEN
      DEC(screenadr, 3); (* why? because it's needed for low res *)
      endcol:= 38;
    END;
  END;

  vfntadptr:= fnthdadr + sysfontoffset; (* get font address *)
  adrptr:= vfntadptr^ + ADDRESS(DATATABLE);
  vfntad:= adrptr^;

  cardptr:= vfntadptr^ + ADDRESS(FORMHEIGHT); (* get font height *)
  vcelht:= cardptr^;
  counter:= vcelht - 2; (* since DBRA instruction ends at -1, not zero *)
  
  cardptr:= vfntadptr^ + ADDRESS(FORMWIDTH); (* get font width *)
  vfntwd:= cardptr^;

  cardptr:= lineAadr + ADDRESS(BYTESLIN); (* get bytes per screen line *)
  byteslin:= cardptr^;

  CODE(0A00AH);  (* LineA hide mouse *)

  BConOut(CON, CHR(27));
  BConOut(CON, 'E'); (* clrhome *)

  BConOut(CON, 15C); (* CR *)
  BConOut(CON, 12C); (* LF *)
  ConWS('BIOS text ouput followed by');
  BConOut(CON, 15C); (* CR *)
  BConOut(CON, 12C); (* LF *)
  ConWS('TxtZap Fast text ouput.');
  BConOut(CON, 15C); (* CR *)
  BConOut(CON, 12C); (* LF *)
  ConWS(' ( Any resolution )');
  BConOut(CON, 15C); (* CR *)
  BConOut(CON, 12C); (* LF *)
  ConWS('Press any key to start BIOS demo');
  NecIn(ch);

  (* Show speed of operating system bconout routine *)
  Biostst;

  ConWS('Press any key to start TxtZap demo.');
  BConOut(CON, 15C); (* CR *)
  BConOut(CON, 12C); (* LF *)
  ConWS('Then hit key at end to continue.');
  NecIn(ch); (* wait for keypress *)

  (* Now output same stuff using Faster char output method *)
  FOR k:= 0 TO 5 DO (* fill screen *)
    BConOut(CON, CHR(27));
    BConOut(CON, 'E'); (* clrhome *)
    i:= 0; (* line *)
    WHILE i < 22 DO
      CursorPos(i, 0);
      FOR vcurx:= 0 TO endcol DO
        Conzap(CHR(65 + k));
      END; (* for line *)
      INC(i); (* next line *)
    END;
  END; (* for screen fills *)
  NecIn(ch);

  (* Now try out the cursor stuff *)
  BConOut(CON, CHR(27));
  BConOut(CON, 'E'); (* clrhome *)
  ConWS('Type, See cursor work. Space bar ends.');
  vcurx:= 0;
  CursorPos(2, 0); (* should set vcurad to correct screen address *)
  CursorDraw; (* puts cursor *)
  REPEAT
    NecIn(ch); (* wait for a character, without writing it to screen *)
    Conzap(ch); (* write to screen.  cursor gets overwritten by new char *)
    INC(vcurx); (* next column *)
    CursorDraw; (* draws cursor at new location *)
  UNTIL ch = 40C; (* space *)

  CODE(0A009H);  (* LineA show mouse *)
END Txttst.

