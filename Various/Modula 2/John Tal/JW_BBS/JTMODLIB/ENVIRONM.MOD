IMPLEMENTATION MODULE Environment;

(**********************************************************)
(*   ROLLINS MEDICAL/DENTAL SYSTEMS                       *)
(*   360 CLAUSEN BUILDING                                 *)
(*   23100 PROVIDENCE DRIVE                               *)
(*   SOUTHFIELD, MI  48075-3677                           *)
(*   -------------------------------------------------    *)
(*  |                                                 |   *)
(*  | Interface to Hardware/Bios/Dos                  |   *)
(*  | Central Library Module                          |   *)
(*  |                                                 |   *)
(*   -------------------------------------------------    *)
(*   Author: John Tal            Created: 04/22/1986      *)
(*   Version:  2.00 a          Last Edit: 04/26/1986      *)
(*                                                        *)
(*   Public Domain Version                                *)
(**********************************************************)

FROM SYSTEM    IMPORT AX,BX,CX,DX,ES,SETREG,GETREG,CODE,SWI,WORD,BYTE,ADR,
                      INBYTE,OUTBYTE,ADDRESS,DOSCALL;
FROM DOS3      IMPORT GetProgramSegmentPrefix;
FROM Strings   IMPORT Concat,Copy,Length;
FROM Keyboard  IMPORT KeyPressed;
FROM TimeDate  IMPORT Time,GetTime;
FROM Functions IMPORT StringReplace;
FROM NumberConversion IMPORT CardToString;


PROCEDURE Ptr(seg, off : CARDINAL) : ADDRESS;
VAR
  Result :
    RECORD
      CASE BOOLEAN OF
        FALSE :
          adr : ADDRESS;
      | TRUE :
          off, seg : CARDINAL;
        END;
      END;
BEGIN
  Result.off := off;
  Result.seg := seg;
  RETURN Result.adr;
END Ptr;

PROCEDURE GetScreenAdr(VAR Screen: ScreenAdr);
VAR  hInfo : CARDINAL;
BEGIN
  SWI(11H);
  GETREG(AX,hInfo);
  IF 4 IN BITSET(hInfo) THEN
    Screen := Ptr(MonoScreen,0H);
    ScreenType := Mono;
  ELSE
    Screen := Ptr(ColorScreen,0H);
    ScreenType := Color;
  END;
END GetScreenAdr;

PROCEDURE DetermineComputer;
VAR P: POINTER TO CHAR;
BEGIN
  P := Ptr(0F000H,0FFFEH);
  CASE ORD(P^) OF
    0FFH: Computer := PC;
  | 0FEH: Computer := XT;
  | 0FDH: Computer := JR;
  | 0FCH: Computer := AT;
  | 0FBH: Computer := XT2;
  | 0FAH: Computer := AT2;
  | 0F9H: Computer := CV;
  ELSE
    Computer := XT;
  END;
END DetermineComputer;

PROCEDURE MemSize() : CARDINAL;
VAR
  Blocks: CARDINAL;
BEGIN
  CODE(55H);
  SWI(12H); (* int 12, return 1k contigous blocks on machine *)
  CODE(5DH);
  GETREG(AX,Blocks);
  RETURN Blocks;
END MemSize;

PROCEDURE Shell( COMMAND : ARRAY OF CHAR; VAR Error : CARDINAL);
VAR
  pspPTR,memTopPTR : POINTER TO CARDINAL;
  pspPTR2 : POINTER TO ARRAY[0..64] OF CHAR;
  Comaddr,pspadr,psp2adr,ComspecAdr,memTOPadr : ADDRESS;
  paramblock : ARRAY[0..6] OF WORD;
  Command : ARRAY[0..128] OF CHAR;
  Comspec : ARRAY[0..32] OF CHAR;
  PSPsegment,error,fctval,newBlockSize : WORD;
  psp,z,i,memTOP,memBOT,memAvail,newMemSize : CARDINAL;
  cr : CHAR;
BEGIN
  fctval := WORD(0);
  cr := CHR(13);
  (* --- prep Command Line for Param block --- *)
  Command := '/C ';
  Concat(Command,COMMAND,Command);
  z := Length(Command);
  Concat(Command,cr,Command);       (* append 0DH on end *)
  FOR i := (z+1) TO 1 BY -1 DO      (* shift string from end *)
    Command[i] := Command[i-1];
  END;
  Command[0] := CHR(z);             (* first byte must be length *)
  Command[z+2] := CHR(0);
  Comaddr := ADR(Command);
  (* ---------------- get PSP  --------------- *)
  GetProgramSegmentPrefix(PSPsegment);
  psp := CARDINAL(PSPsegment);
  pspadr.SEGMENT := psp;
  pspadr.OFFSET := 02CH;
  (* ---- calc total memory used right now by Modula-2 ------ *)
  memBOT := psp;
  memTOPadr.SEGMENT := psp;         (*  PSP:02H points to memtop  *)
  memTOPadr.OFFSET := 02H;
  memTopPTR := memTOPadr;
  memTOP := memTopPTR^;
  memAvail := memTOP - memBOT;
  newMemSize := memAvail - 1000H;   (*  snatch 64K away from application  *)
                                    (*  take 2000H away (128k) for FORMAT/s *)
  (* ---------- Go get COMSPEC = ------------- *)
  pspPTR := pspadr;                 (* points to PSP + 2CH *)
  psp2adr.SEGMENT := pspPTR^;
  psp2adr.OFFSET := 0;
  pspPTR2 := psp2adr;               (* points to COMSPEC = *)
  (* ------- copy comspec to local area ------ *)
  Copy(pspPTR2^,8,24,Comspec);
  ComspecAdr := ADR(Comspec);
  (* ------- setup paramater block ----------- *)
  paramblock[0] := WORD(psp2adr.SEGMENT);     (*   environment string *)
  paramblock[1] := WORD(Comaddr.OFFSET);      (*  command line  *)
  paramblock[2] := WORD(Comaddr.SEGMENT);     (*  command line  *)
  paramblock[3] := WORD(05CH);                (*  PSP defaults  *)
  paramblock[4] := WORD(PSPsegment);              (*  "  *)
  paramblock[5] := WORD(06CH);                    (*  "  *)
  paramblock[6] := WORD(PSPsegment);              (*  "  *)
  (* --- Shrink memory by 64K to allow second Command.com --- *)
  newBlockSize := WORD(newMemSize);
  DOSCALL(4AH,pspadr,newBlockSize,error);
  (* ----------- if ok then EXEC ------------- *)
  Error := CARDINAL(error);
  IF Error = 0 THEN
    DOSCALL(4BH,ComspecAdr,ADR(paramblock),fctval,error);  (* EXEC - 4BH *)
    Error := CARDINAL(error);
   (* -- Restore memory (block) to original size -- *)
(*
    newBlockSize := WORD(memAvail);
    DOSCALL(4AH,pspadr,newBlockSize,error);
*)
  END;
END Shell;

PROCEDURE Peek(Segment,Offset : CARDINAL) : CARDINAL;
VAR
 a : ADDRESS;
 p : POINTER TO CHAR;
BEGIN
 a.SEGMENT := Segment;
 a.OFFSET := Offset;
 p := a;
 RETURN CARDINAL(ORD(p^));
END Peek;

PROCEDURE Poke(Segment,Offset,val : CARDINAL);
VAR
 a : ADDRESS;
 p : POINTER TO CHAR;
BEGIN
 a.SEGMENT := Segment;
 a.OFFSET := Offset;
 p := a;
 p^ := CHR(val);
END Poke;


PROCEDURE RowAdj(Row:CARDINAL) : CARDINAL;
BEGIN
 RETURN(Row-1) MOD RowMax+1
END RowAdj;

PROCEDURE ColAdj(Col:CARDINAL) : CARDINAL;
BEGIN
 RETURN(Col-1) MOD ColMax+1
END ColAdj;

PROCEDURE Locate( row,col : CARDINAL );
VAR
 row1,col1 : CARDINAL;
 dx : WORD;
BEGIN
  row1 := row-1;
  col1 := col-1;
  dx := WORD(col1 + (row1 * 256));
  CODE(55H);           (* push BP *)
  SETREG(AX,200H);     (* position cursor function *)
  SETREG(DX,dx);       (* row in dh, col in dl *)
  SETREG(BX,0H);       (* current page *)
  SWI(10H);            (* Video ROM call *)
  CODE(5DH);           (* pop BP *)
END Locate;

PROCEDURE GotoXY( col,row : CARDINAL );
VAR
 row1,col1 : CARDINAL;
 dx : WORD;
BEGIN
  row1 := row-1;
  col1 := col-1;
  dx := WORD(col1 + (row1 * 256));
  CODE(55H);           (* push BP *)
  SETREG(AX,200H);     (* position cursor function *)
  SETREG(DX,dx);       (* row in dh, col in dl *)
  SETREG(BX,0H);       (* current page *)
  SWI(10H);            (* Video ROM call *)
  CODE(5DH);           (* pop BP *)
END GotoXY;

PROCEDURE Cls;
VAR
 dx : WORD;
BEGIN
  dx := WORD(79 + (24 * 256));
  CODE(55H);           (* push BP *)
  SETREG(AX,600H);     (* Scroll up *)
  SETREG(CX,000H);     (* upper left row and column *)
  SETREG(DX,dx);       (* lower right row in dh, col in dl *)
  SETREG(BX,700H);     (* blank line attribute *)
  SWI(10H);            (* Video ROM call *)
  CODE(5DH);           (* pop BP *)
  Locate(1,1);
END Cls;

PROCEDURE CursorOff;
BEGIN
  SETREG(AX,0100h);
  SETREG(CX,2607h);
  SWI(10h);
END CursorOff;

PROCEDURE CursorOn;
BEGIN
  SETREG(AX,0100h);
  SETREG(CX,0607h);
  SWI(10h);
END CursorOn;

PROCEDURE GetDateString( VAR D : ARRAY OF CHAR);      (*  put date in d$ *)
VAR
 curTime : Time;
 date,month,year : CARDINAL;
 daymask,monthmask,yearmask,timebit : BITSET;
 dateTemp,monthTemp,yearTemp : ARRAY[0..2] OF CHAR;
BEGIN
 daymask   := {0,1,2,3,4};
 monthmask := {5,6,7,8};
 yearmask  := {9,10,11,12,13,14,15};
 GetTime(curTime);
 timebit := BITSET(curTime.day);
 date  := CARDINAL(timebit * daymask);    (* curTime.day MOD 32 *)
 month := CARDINAL(timebit * monthmask) DIV 32;
 year  := (CARDINAL(timebit * yearmask)  DIV 512);
 CardToString(date,dateTemp,2);
 CardToString(month,monthTemp,2);
 CardToString(year,yearTemp,2);
 StringReplace(dateTemp,' ','0');
 StringReplace(monthTemp,' ','0');
 Concat(monthTemp,'/',D);
 Concat(D,dateTemp,D);
 Concat(D,'/',D);
 Concat(D,yearTemp,D);
END GetDateString;

PROCEDURE Delay( delayM : CARDINAL);
VAR
 curTime : Time;
 startM,curM : CARDINAL;
BEGIN
 GetTime(curTime);
 startM := curTime.millisec;
 curM := startM;
 WHILE  (curM < (startM + delayM)) DO
   GetTime(curTime);
   curM := curTime.millisec;
 END;
END Delay;

PROCEDURE ToneInit;
VAR
 sc,rl,mode,bcd,cnword : CARDINAL;
 cnWord : BITSET;
BEGIN
 sc := 2;
 rl := 3;
 mode := 3;
 bcd := 0;
 cnword := sc*040H + rl * 010H + mode * 2 + bcd;
 cnWord := BITSET(cnword);
 OUTBYTE(043H,cnWord);
END ToneInit;

PROCEDURE Tone( Freq,dur : CARDINAL);
VAR
 F,FHi,FLo : CARDINAL;
 contents : BITSET;
 Frequency : WORD;
BEGIN
 F := TRUNC( 1.193182E6 / FLOAT(Freq));
 FHi := F DIV 256;
 FLo := F MOD 256;
 (* Frequency := WORD(F); *)
 OUTBYTE(042H,CHR(FLo));    (* toneset *)
 OUTBYTE(042H,CHR(FHi));
 INBYTE(061H,contents);      (* toneon *)
 INCL(contents,0);
 INCL(contents,1);
 OUTBYTE(061H,contents);
 Delay(dur);
 INBYTE(061H,contents);  (* turn off tone *)
 EXCL(contents,0);       (* turn off lower 2 bits *);
 EXCL(contents,1);
 OUTBYTE(061H,contents);
END Tone;

PROCEDURE TimeDifference( start, end: Time): REAL;
VAR
  dif1, dif2: REAL;
BEGIN
  IF end.minute >= start.minute THEN
    dif1 := FLOAT( end.minute - start.minute );
  ELSE
    dif1 := 1440.0 (* 60*24 *) - FLOAT( start.minute - end.minute );
  END;
  IF end.millisec >= start.millisec THEN
    dif2 := FLOAT( end.millisec - start.millisec );
  ELSE
    dif2 := - FLOAT( start.millisec - end.millisec );
  END;
  RETURN dif1 * 60.0 + dif2 / 1000.0;
END TimeDifference;

PROCEDURE Pause(secs: REAL);
VAR
  start, end: Time;
BEGIN
  GetTime(start);
  REPEAT
    GetTime(end);
  UNTIL TimeDifference(start,end) >= secs;
END Pause;

BEGIN
  DetermineComputer;
  GetScreenAdr(Screen);
END Environment.
