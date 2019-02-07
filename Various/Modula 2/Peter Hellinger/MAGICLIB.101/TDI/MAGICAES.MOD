(*######################################################################
                                                                        
  MAGIC         Modula's  All purpose  GEM  Interface  Cadre
                ˇ         ˇ            ˇ    ˇ          ˇ
########################################################################

  AES   Application Environment Services        Interface for Modula-2

                Implementation fÅr TDI-Modula-2/ST
########################################################################
  V1.0  (C) by Peter Hellinger
######################################################################*)

IMPLEMENTATION MODULE MagicAES;

(*------------------------------*)
(*      TDI-Compilerswitches    *)
(*                              *)
(*$V-   Overflow-Checks         *)
(*$R-   Range-Checks            *)
(*$S-   Stack-Check             *)
(*$N-   NIL-Checks              *)
(*$T-   TDI-Compiler vor 3.01   *)
(*$Q+   Branch statt Jumps      *)
(*                              *)
(*------------------------------*)

FROM SYSTEM IMPORT ADDRESS, ADR, WORD, BYTE, SETREG, REGISTER, CODE;
IMPORT MagicXBIOS, MagicDOS, MagicSys;


(*#######################################################################*)

PROCEDURE AESCall (op, c1, c2, c3, c4: INTEGER): INTEGER;
CONST GEM =   200;
      TRAP2 = 04E42H;
BEGIN
 WITH AESControl DO
  opcode:= op;
  sizeIntIn:= c1;
  sizeIntOut:= c2;
  sizeAddrIn:= c3;
  sizeAddrOut:= c4;
 END;
 SETREG(0, GEM);  
 SETREG(1, ADR(AESPB));
 CODE(TRAP2);
 CallResult:= AESIntOut[0];
 RETURN CallResult;
END AESCall;




PROCEDURE ApplInit(): INTEGER;
BEGIN
 RETURN AESCall(10, 0, 1, 0, 0);
END ApplInit;


PROCEDURE ApplRead (id, len: INTEGER; VAR pipe: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:=  id;
 AESIntIn[ 1]:=  len;
 AESAddrIn[ 0]:= ADR(pipe);
 CallResult:= AESCall(11, 2, 1, 1, 0);
END ApplRead;


PROCEDURE ApplWrite (id, len: INTEGER; VAR pipe: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:=  id;
 AESIntIn[ 1]:=  len;
 AESAddrIn[ 0]:= ADR(pipe);
 CallResult:= AESCall(12, 2, 1, 1, 0);
END ApplWrite;


PROCEDURE ApplFind (name: ARRAY OF CHAR): INTEGER;
BEGIN
 AESAddrIn[ 0]:= ADR(name);
 RETURN AESCall(13, 0, 1, 1, 0);
END ApplFind;


PROCEDURE ApplTplay (num, speed: INTEGER; VAR buffer: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:=  num;
 AESIntIn[ 1]:=  speed;
 AESAddrIn[ 0]:= ADR(buffer);
 CallResult:= AESCall(14, 2, 1, 1, 0);
END ApplTplay;


PROCEDURE ApplTrecord (count: INTEGER; VAR buffer: ARRAY OF WORD): INTEGER;
BEGIN
 AESIntIn[ 0]:=  count;
 AESAddrIn[ 0]:= ADR(buffer);
 RETURN AESCall(15, 1, 1, 1, 0);
END ApplTrecord;


PROCEDURE ApplBvset (disk, hard: BITSET);
BEGIN
 AESIntIn[ 0]:= MagicSys.BitsetToInt (disk);
 AESIntIn[ 1]:= MagicSys.BitsetToInt (hard);
 CallResult:= AESCall(16, 2, 1, 1, 0);
END ApplBvset;


PROCEDURE ApplYield;
BEGIN
 CallResult:= AESCall(17, 0, 1, 0, 0);
END ApplYield;


PROCEDURE ApplExit;
BEGIN
 CallResult:= AESCall(19, 0, 1, 0, 0);
END ApplExit;


(*########################################################################
  In Abweichung zu den gÑngigen Bindings wird bei keybd und multi der
  korrekte (!) Tastatur-Zustand beim Auftreten des Events wiedergegeben.
  Dadurch haben diese Prozeduren mehr Parameter als Åblich.
  ######################################################################*)
 
CONST   MaxNum =        128; (* Anzahl der Tasten im modulinternen Puffer *)

TYPE    TastPtr =       POINTER TO TastenTyp;
        TastenTyp =     RECORD
                         state, scan, unused, char: CHAR;
                        END;
                        (* Tastentyp zum Auswerten des BIOS-Puffers *)

VAR     kbd:            MagicXBIOS.PtrIOREC;
                        (* Zeiger auf den Pufferdeskriptor fÅr die Tastatur *)

VAR     Tastatur :      RECORD
                         buffer:  ARRAY [0..MaxNum] OF TastenTyp;
                         in, out: INTEGER;
                        END;
                        (* Interner Tastatur-Puffer. Ab Index in wird
                         * geschrieben, ab out gelesen
                         *)

VAR     head:           INTEGER; (* Index des BIOS-Puffers *)
        taste:          TastPtr; (* Zum Auswerten des Puffers *)

(* Tastatur so initialisieren, daû KBShifts mit abgefragt werden *)

CONST   TastenKlick =   MagicSys.Bit0;   (* gesetzt = Tastaturklick ein  *)
        TastenRepeat =  MagicSys.Bit1;   (* gesetzt = Wiederholung ein   *)
        Glocke =        MagicSys.Bit2;   (* Ding-Dong bei Ctrl-G         *)
        Kbshift =       MagicSys.Bit3;   (* Tastaturzustand              *)

TYPE    ByteSet =       SET OF [0..7];
                          (* Damit wir nachher elegant mit INCL und
                           * EXCL das Bit setzten bzw. lîschen kînnen.
                           *)

VAR     ConTerm[0484H]: ByteSet; (* Sysvar, ist nur ein Byte! *)
        oldConterm:     ByteSet; (* Zum Zwischenspeichern     *)
        stack:          ADDRESS; (* Stackadresse fÅr GEMDOS.Super *)



PROCEDURE GetKeys(key: INTEGER);
(* Ermittelt die Tastenwerte zwischen Event-Aufrufen und ÅbertrÑgt
 * sie in den internen Puffer.  key ist ein ZÑhler, in dem die Anzahl der
 * gedrÅckten Tasten vermerkt wird.
 *)
VAR index: INTEGER;
BEGIN
 index:= head - ((key * 4) - 4);        (* Pufferzeiger feststellen *)
 IF index < 0 THEN index:= kbd^.ibufsize - 4; END; (* Overflow verhindern *)
 WHILE key > 0 DO   (* Solange Tasten da sind *)
  taste:= kbd^.ibuf + MagicSys.IntToAddr (index);   (* Tasten auslesen *)
  WITH Tastatur DO 
   buffer[in]:= taste^;   (* in internen Puffer Åbertragen *)
   INC(in);
   IF in > MaxNum THEN in:= 0; END;   (* Overflow verhindern *)
   IF in = out THEN   (* Zeichen abweisen, Puffer ist voll! *)
    DEC(in);
    IF in < 0 THEN in:= MaxNum; END;
   END;
  END; (* WITH *)
  INC(index, 4);  (* NÑchstes Zeichen *)
  IF MagicSys.IntToCard (index) > kbd^.ibufsize THEN index:= 0; END;
  DEC(key);
 END; (* WHILE *)
END GetKeys;


(*-----------------------------------------------------------------------*)


PROCEDURE EvntKeybd (VAR key: INTEGER;  VAR shift: BITSET;
                 VAR scan: INTEGER;  VAR chr: CHAR);
BEGIN
 key:= AESCall(20, 0, 1, 0, 0); (* Auf Keyboard-Event warten *)
 head:= kbd^.ibuftl;
 GetKeys(1); (* nur eine Taste lesen *)
 WITH Tastatur DO
  shift:= MagicSys.CharToBitset (buffer[out].state);
  scan:=  ORD (buffer[out].scan);
  chr:=   buffer[out].char;
  INC(out); (* Pufferindex erhîhen *)
  IF out > MaxNum THEN out:= 0; END; (* Overflow verhindern *)
  RETURN;
 END; (* WITH *)
END EvntKeybd;


PROCEDURE EvntMulti (wich: BITSET;  maxclicks: INTEGER;  mask, state: BITSET;
                     m1mode: INTEGER;  m1rect: ARRAY OF WORD;
                     m2mode: INTEGER;  m2rect: ARRAY OF WORD;
                     VAR msgBuff: ARRAY OF WORD;
                     loTimer, hiTimer: INTEGER;
                     VAR x, y: INTEGER;
                     VAR button: BITSET;
                     VAR taste: CARDINAL;
                     VAR kbshift: BITSET;
                     VAR scan: CARDINAL;
                     VAR ascii: CHAR;
                     VAR clicks: INTEGER): BITSET;

VAR event:      BITSET;
    firstevent: BITSET;
    keys:       INTEGER;

BEGIN (* multi *)

 IF (MUKEYBD IN wich) AND (Tastatur.in # Tastatur.out) THEN
  INCL(wich, MUTIMER);  loTimer:= 0;  hiTimer:= 0;  (* Timer-Event erzwingen *)
 END;

 (* Array's laden *)
 AESIntIn[ 0]:= MagicSys.BitsetToInt (wich);
 AESIntIn[ 1]:= maxclicks;
 AESIntIn[ 2]:= MagicSys.BitsetToInt (mask);
 AESIntIn[ 3]:= MagicSys.BitsetToInt (state);
 AESIntIn[ 4]:= m1mode;
 AESIntIn[ 5]:= MagicSys.WordToInt (m1rect[0]);
 AESIntIn[ 6]:= MagicSys.WordToInt (m1rect[1]);
 AESIntIn[ 7]:= MagicSys.WordToInt (m1rect[2]);
 AESIntIn[ 8]:= MagicSys.WordToInt (m1rect[3]);
 AESIntIn[ 9]:= m2mode;
 AESIntIn[10]:= MagicSys.WordToInt (m2rect[0]);
 AESIntIn[11]:= MagicSys.WordToInt (m2rect[1]);
 AESIntIn[12]:= MagicSys.WordToInt (m2rect[2]);
 AESIntIn[13]:= MagicSys.WordToInt (m2rect[3]);
 AESIntIn[14]:= loTimer;
 AESIntIn[15]:= hiTimer;
 AESAddrIn[0]:= ADR(msgBuff);

 event:= MagicSys.IntToBitset (AESCall(25, 16, 7, 1, 0));

 firstevent:= event; (* Aufgetretene Events merken *)
 x:= AESIntOut[1];
 y:= AESIntOut[2];
 button:= MagicSys.IntToBitset (AESIntOut[3]);
 taste:= AESIntOut[5];

 (* TastendrÅcke zÑhlen und AES-Puffer lîschen *)
 keys:= 0;
 WHILE (MUKEYBD IN event) DO
  INC(keys);
  head:= kbd^.ibuftl;
  AESIntIn[0]:= MagicSys.BitsetToInt ({MUKEYBD, MUTIMER});
  AESIntIn[14]:= 0; (* Timer auf 0 *)
  AESIntIn[15]:= 0;
  event:= MagicSys.IntToBitset (AESCall(25, 16, 7, 1, 0));
 END;

 (* Tasten vom BIOS in internen Puffer Åbertragen *)
 IF keys > 0 THEN GetKeys(keys); END;

 (* Internen Puffer auslesen *)
 IF Tastatur.in # Tastatur.out THEN
  WITH Tastatur DO
   kbshift:= MagicSys.CharToBitset (buffer[out].state);
   scan:=    ORD(buffer[out].scan);
   ascii:=   buffer[out].char;
   INC(out);
   IF out > MaxNum THEN out:= 0; END;
   INCL(firstevent, MUKEYBD); (* KeyboardEvent-Flag setzen *)
  END; (* WITH *)
 ELSE
  kbshift:= {};  scan:= 0;   ascii:= 0C;
  EXCL(firstevent, MUKEYBD);
 END;
 RETURN firstevent;
END EvntMulti;


PROCEDURE EvntPmulti (): BITSET;
BEGIN
 RETURN MagicSys.IntToBitset (AESCall(25, 16, 7, 1, 0));
END EvntPmulti;


PROCEDURE EvntButton (maxclicks: INTEGER; mask, state: BITSET;
                      VAR x, y: INTEGER;  VAR button, kbshift: BITSET): INTEGER;
VAR clicks: INTEGER;
BEGIN
 AESIntIn[ 0]:= maxclicks;
 AESIntIn[ 1]:= MagicSys.BitsetToInt (mask);
 AESIntIn[ 1]:= MagicSys.BitsetToInt (state);
 clicks:= AESCall(21, 3, 5, 0, 0);
 x:= AESIntOut[1];
 y:= AESIntOut[2];
 button:= MagicSys.IntToBitset (AESIntOut[3]);
 kbshift:= MagicSys.IntToBitset (AESIntOut[4]);
 RETURN clicks;
END EvntButton;


PROCEDURE EvntMouse  (mode: INTEGER;  m1rect: ARRAY OF WORD;
                      VAR x, y: INTEGER;  VAR button, kbshift: BITSET);
BEGIN
 AESIntIn[ 0]:= mode;
 AESIntIn[ 1]:= MagicSys.WordToInt (m1rect[0]);
 AESIntIn[ 2]:= MagicSys.WordToInt (m1rect[1]);
 AESIntIn[ 3]:= MagicSys.WordToInt (m1rect[2]);
 AESIntIn[ 4]:= MagicSys.WordToInt (m1rect[3]);
 CallResult:= AESCall(22, 5, 5, 0, 0);
 x:= AESIntOut[1];
 y:= AESIntOut[2];
 button:=  MagicSys.IntToBitset (AESIntOut[3]);
 kbshift:= MagicSys.IntToBitset (AESIntOut[4]);
END EvntMouse;


PROCEDURE EvntMesag (VAR buffer: ARRAY OF WORD);
BEGIN
 AESAddrIn[0]:= ADR(buffer);
 CallResult:= AESCall(23, 0, 1, 1, 0);
END EvntMesag;


PROCEDURE EvntTimer (count: LONGCARD);
VAR trick: RECORD
            CASE : BOOLEAN OF
             TRUE: long: LONGCARD;|
             FALSE: hi, lo: INTEGER;|
            END;
           END;
BEGIN
 trick.long:= count;
 AESIntIn[ 0]:= trick.lo;
 AESIntIn[ 1]:= trick.hi;
 CallResult:= AESCall(24, 2, 1, 0, 0);
END EvntTimer;


PROCEDURE EvntDclicks (new: INTEGER; set: BOOLEAN): INTEGER;
BEGIN
 AESIntIn[ 0]:= new;
 IF set THEN AESIntIn[ 1]:= 1; ELSE AESIntIn[ 1]:= 0; END;
 RETURN AESCall(26, 2, 1, 0, 0);
END EvntDclicks;


(*######################################################################*)


PROCEDURE FormDo (tree: ADDRESS; start: INTEGER): INTEGER;
BEGIN
 AESIntIn[ 0]:= start;
 AESAddrIn[0]:= tree;
 RETURN AESCall(50, 1, 1, 1, 0);
END FormDo;


PROCEDURE FormDial (flag: INTEGER; small, big: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= flag;
 AESIntIn[ 1]:= MagicSys.WordToInt (small[0]);
 AESIntIn[ 2]:= MagicSys.WordToInt (small[1]);
 AESIntIn[ 3]:= MagicSys.WordToInt (small[2]);
 AESIntIn[ 4]:= MagicSys.WordToInt (small[3]);
 AESIntIn[ 5]:= MagicSys.WordToInt (big[0]);
 AESIntIn[ 6]:= MagicSys.WordToInt (big[1]);
 AESIntIn[ 7]:= MagicSys.WordToInt (big[2]);
 AESIntIn[ 8]:= MagicSys.WordToInt (big[3]);
 CallResult:= AESCall(51, 9, 1, 1, 0);
END FormDial;


PROCEDURE FormAlert  (button: INTEGER; string: ARRAY OF CHAR): INTEGER;
BEGIN
 AESIntIn[ 0]:= button;
 AESAddrIn[0]:= ADR(string);
 RETURN AESCall(52, 1, 1, 1, 0);
END FormAlert;


PROCEDURE FormError  (errNum: INTEGER);
BEGIN
 AESIntIn[ 0]:= errNum;
 CallResult:= AESCall(53, 1, 1, 0, 0);
END FormError;


PROCEDURE FormCenter (tree: ADDRESS; VAR rect: ARRAY OF WORD);
BEGIN
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(54, 0, 5, 1, 0);
 rect[0]:= MagicSys.IntToWord (AESIntOut[1]);
 rect[1]:= MagicSys.IntToWord (AESIntOut[2]);
 rect[2]:= MagicSys.IntToWord (AESIntOut[3]);
 rect[3]:= MagicSys.IntToWord (AESIntOut[4]);
END FormCenter;


PROCEDURE FormKeybd (tree: ADDRESS;  object, chIn: INTEGER;
                     VAR next, chOut: INTEGER): INTEGER;
BEGIN
 AESIntIn[ 0]:= object;
 AESIntIn[ 1]:= chIn;
 AESIntIn[ 2]:= 0;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(55, 3, 3, 1, 0);
 next:= AESIntOut[1];
 chOut:= AESIntOut[2];
 RETURN CallResult;  
END FormKeybd;


PROCEDURE FormButton (tree: ADDRESS; obj, cl: INTEGER; VAR next: INTEGER): INTEGER;
BEGIN
 AESIntIn[ 0]:= obj;
 AESIntIn[ 1]:= cl;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(56, 2, 2, 1, 0);
 next:= AESIntOut[1];
 RETURN CallResult;
END FormButton;


(*#######################################################################*)

PROCEDURE FselInput (VAR pfad, name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 AESAddrIn[0]:= ADR(pfad);
 AESAddrIn[1]:= ADR(name);
 CallResult:= AESCall(90, 0, 2, 2, 0);
 RETURN AESIntOut[1] = 1;
END FselInput;


PROCEDURE FselExinput (VAR info, pfad, name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 AESAddrIn[0]:= ADR(pfad);
 AESAddrIn[1]:= ADR(name);
 AESAddrIn[2]:= ADR(info);
 CallResult:= AESCall(91, 0, 2, 3, 0);
 RETURN AESIntOut[1] = 1;
END FselExinput;


(*#######################################################################*)

PROCEDURE GrafRubberbox (x, y, mw, mh: INTEGER; VAR lw, lh: INTEGER);
BEGIN
 AESIntIn[ 0]:= x;
 AESIntIn[ 1]:= y;
 AESIntIn[ 2]:= mw;
 AESIntIn[ 3]:= mh;
 CallResult:= AESCall(70, 4, 3, 0, 0);
 lw:= AESIntOut[1];
 lh:= AESIntOut[2];
END GrafRubberbox;


PROCEDURE GrafDragbox (moving, boundary: ARRAY OF WORD; VAR x, y: INTEGER);
BEGIN
 AESIntIn[ 0]:= MagicSys.WordToInt (moving[2]);
 AESIntIn[ 1]:= MagicSys.WordToInt (moving[3]);
 AESIntIn[ 2]:= MagicSys.WordToInt (moving[0]);
 AESIntIn[ 3]:= MagicSys.WordToInt (moving[1]);
 AESIntIn[ 4]:= MagicSys.WordToInt (boundary[0]);
 AESIntIn[ 5]:= MagicSys.WordToInt (boundary[1]);
 AESIntIn[ 6]:= MagicSys.WordToInt (boundary[2]);
 AESIntIn[ 7]:= MagicSys.WordToInt (boundary[3]);
 CallResult:= AESCall(71, 8, 3, 0, 0);
 x:= AESIntOut[1];
 y:= AESIntOut[2];
END GrafDragbox;


PROCEDURE GrafMovebox (sx, sy, sw, sh, dx, dy: INTEGER);
BEGIN
 AESIntIn[ 0]:= sx;
 AESIntIn[ 1]:= sy;
 AESIntIn[ 2]:= sw;
 AESIntIn[ 3]:= sh;
 AESIntIn[ 4]:= dx;
 AESIntIn[ 5]:= dy;
 CallResult:= AESCall(72, 6, 1, 0, 0);
END GrafMovebox;


PROCEDURE GrafGrowbox (source, dest: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= MagicSys.WordToInt (source[0]);
 AESIntIn[ 1]:= MagicSys.WordToInt (source[1]);
 AESIntIn[ 2]:= MagicSys.WordToInt (source[2]);
 AESIntIn[ 3]:= MagicSys.WordToInt (source[3]);
 AESIntIn[ 4]:= MagicSys.WordToInt (dest[0]);
 AESIntIn[ 5]:= MagicSys.WordToInt (dest[1]);
 AESIntIn[ 6]:= MagicSys.WordToInt (dest[2]);
 AESIntIn[ 7]:= MagicSys.WordToInt (dest[3]);
 CallResult:= AESCall(73, 8, 1, 0, 0);
END GrafGrowbox;


PROCEDURE GrafShrinkbox (source, dest: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= MagicSys.WordToInt (source[0]);
 AESIntIn[ 1]:= MagicSys.WordToInt (source[1]);
 AESIntIn[ 2]:= MagicSys.WordToInt (source[2]);
 AESIntIn[ 3]:= MagicSys.WordToInt (source[3]);
 AESIntIn[ 4]:= MagicSys.WordToInt (dest[0]);
 AESIntIn[ 5]:= MagicSys.WordToInt (dest[1]);
 AESIntIn[ 6]:= MagicSys.WordToInt (dest[2]);
 AESIntIn[ 7]:= MagicSys.WordToInt (dest[3]);
 CallResult:= AESCall(74, 8, 1, 0, 0);
END GrafShrinkbox;


PROCEDURE GrafWatchbox (tree: ADDRESS; item: INTEGER; in, out: BITSET): INTEGER;
BEGIN
 AESIntIn[1]:= item;
 AESIntIn[2]:= MagicSys.BitsetToInt (in);
 AESIntIn[3]:= MagicSys.BitsetToInt (out);
 AESAddrIn[0]:= tree;
 RETURN AESCall(75, 4, 1, 0, 0);
END GrafWatchbox;


PROCEDURE GrafSlidebox (tree: ADDRESS; parent, object, dir: INTEGER): INTEGER;
BEGIN
 AESIntIn[ 0]:= parent;
 AESIntIn[ 1]:= object;
 AESIntIn[ 2]:= dir;
 AESAddrIn[ 0]:= tree;
 RETURN AESCall(76, 3, 1, 0, 0);
END GrafSlidebox;


PROCEDURE GrafHandle (VAR handle, cw, ch, bw, bh: INTEGER);
BEGIN
 CallResult:= AESCall(77, 0, 5, 0, 0);
 handle:= AESIntOut[0];
 cw:= AESIntOut[1];
 ch:= AESIntOut[2];
 bw:= AESIntOut[3];
 bh:= AESIntOut[4];
END GrafHandle;


PROCEDURE GrafMouse (form: INTEGER; user: ADDRESS);
BEGIN
 AESIntIn[0]:= form;
 AESAddrIn[ 0]:= user;
 CallResult:= AESCall(78, 1, 1, 0, 0);
END GrafMouse;


PROCEDURE GrafMkstate (VAR x, y: INTEGER; VAR button, key: BITSET);
BEGIN
 CallResult:= AESCall(79, 0, 5, 0, 0);
 x:= AESIntOut[1];
 y:= AESIntOut[2];
 button:= MagicSys.IntToBitset (AESIntOut[3]);
 key:= MagicSys.IntToBitset (AESIntOut[4]);
END GrafMkstate;


(*#######################################################################*)

PROCEDURE MenuBar (tree: ADDRESS; action: INTEGER);
BEGIN
 AESIntIn[ 0]:= action;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(30, 1, 1, 1, 0);
END MenuBar;


PROCEDURE MenuIcheck (tree: ADDRESS; item: INTEGER; action: INTEGER);
BEGIN
 AESIntIn[ 0]:= item;
 AESIntIn[ 1]:= action;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(31, 2, 1, 1, 0);
END MenuIcheck;


PROCEDURE MenuIenable (tree: ADDRESS; item: INTEGER; action: INTEGER);
BEGIN
 AESIntIn[ 0]:= item;
 AESIntIn[ 1]:= action;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(32, 2, 1, 1, 0);
END MenuIenable;


PROCEDURE MenuTnormal (tree: ADDRESS; item: INTEGER; action: INTEGER);
BEGIN
 AESIntIn[ 0]:= item;
 AESIntIn[ 1]:= action;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(33, 2, 1, 1, 0);
END MenuTnormal;


PROCEDURE MenuText (tree: ADDRESS; item: INTEGER; str: ARRAY OF CHAR);
BEGIN
 AESIntIn[ 0]:= item;
 AESAddrIn[0]:= tree;
 AESAddrIn[1]:= ADR(str);
 CallResult:= AESCall(34, 1, 1, 2, 0);
END MenuText;


PROCEDURE MenuRegister (apid: INTEGER; str: ARRAY OF CHAR);
BEGIN
 AESIntIn[ 0]:= apid;
 AESAddrIn[0]:= ADR(str);
 CallResult:= AESCall(35, 1, 1, 1, 0);
END MenuRegister;


PROCEDURE MenuUnregister (apid: INTEGER);
BEGIN
 AESIntIn[ 0]:= apid;
 CallResult:= AESCall(36, 1, 1, 1, 0);
END MenuUnregister;


(*#######################################################################*)

PROCEDURE RsrcLoad (name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 AESAddrIn[ 0]:= ADR(name);
 CallResult:= AESCall(110, 0, 1, 1, 0);
 RETURN CallResult # 0;
END RsrcLoad;


PROCEDURE RsrcFree;
BEGIN
 CallResult:= AESCall(111, 0, 1, 0, 0);
END RsrcFree;


PROCEDURE RsrcGaddr (type, item: INTEGER): ADDRESS;
BEGIN
 AESIntIn[ 0]:= type;
 AESIntIn[ 1]:= item;
 CallResult:= AESCall(112, 2, 1, 0, 1);
 RETURN  AESAddrOut[0];
END RsrcGaddr;


PROCEDURE RsrcSaddr (type, item: INTEGER; adr: ADDRESS);
BEGIN
 AESIntIn[ 0]:= type;
 AESIntIn[ 1]:= item;
 AESAddrIn[0]:= adr;
 CallResult:= AESCall(113, 2, 1, 1, 0);
END RsrcSaddr;


PROCEDURE RsrcObfix (tree: ADDRESS; object: INTEGER);
BEGIN
 AESIntIn[ 0]:= object;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(114, 1, 1, 1, 0);
END RsrcObfix;


(*#######################################################################*)

PROCEDURE ScrpRead (VAR pfad: ARRAY OF CHAR): BITSET;
BEGIN
 AESAddrIn[0]:= ADR(pfad);
 CallResult:= AESCall(80, 0, 1, 1, 0);
 RETURN BITSET(CallResult);
END ScrpRead;


PROCEDURE ScrpWrite (pfad: ARRAY OF CHAR);
BEGIN
 AESAddrIn[0]:= ADR(pfad);
 CallResult:= AESCall(81, 0, 1, 1, 0);
END ScrpWrite;


PROCEDURE ScrpClear; 
BEGIN
 CallResult:= AESCall(82, 0, 1, 0, 0);
END ScrpClear;


(*#######################################################################*)
 
PROCEDURE ShelRead (VAR command, path: ARRAY OF CHAR);
BEGIN
 AESAddrIn[0]:= ADR(command);
 AESAddrIn[1]:= ADR(path);
 CallResult:= AESCall(120, 0, 1, 2, 0);
END ShelRead;


PROCEDURE ShelWrite (exec, appl, start: INTEGER; command, path: ARRAY OF CHAR);
BEGIN
 AESIntIn[0]:=  exec;
 AESIntIn[1]:=  appl;
 AESIntIn[2]:=  start;
 AESAddrIn[0]:= ADR(command);
 AESAddrIn[1]:= ADR(path);
 CallResult:= AESCall(121, 3, 1, 2, 0);
END ShelWrite;


PROCEDURE ShelGet (len: INTEGER; VAR buffer: ARRAY OF WORD);
BEGIN
 AESIntIn[0]:=  len;
 AESAddrIn[0]:= ADR(buffer);
 CallResult:= AESCall(122, 1, 1, 1, 0);
END ShelGet;


PROCEDURE ShelPut (len: INTEGER; VAR buffer: ARRAY OF WORD);
BEGIN
 AESIntIn[0]:=  len;
 AESAddrIn[0]:= ADR(buffer);
 CallResult:= AESCall(123, 1, 1, 1, 0);
END ShelPut;


PROCEDURE ShelFind (VAR name: ARRAY OF CHAR);
BEGIN
 AESAddrIn[0]:= ADR(name);
 CallResult:= AESCall(124, 0, 1, 1, 0);
END ShelFind;


PROCEDURE ShelEnvrn (VAR param: ARRAY OF CHAR; name: ARRAY OF CHAR);
BEGIN
 AESAddrIn[0]:= ADR(param);
 AESAddrIn[1]:= ADR(name);
 CallResult:= AESCall(125, 0, 1, 2, 0);
END ShelEnvrn;


PROCEDURE ShelRdef (command, path: ARRAY OF CHAR);
(* Erst ab GEM 2.0 *)
BEGIN
 AESAddrIn[0]:= ADR(command);
 AESAddrIn[1]:= ADR(path);
 CallResult:= AESCall(126, 0, 1, 2, 0);
END ShelRdef;


PROCEDURE ShelWdef (command, path: ARRAY OF CHAR);
(* Erst ab GEM 2.0 *)
BEGIN
 AESAddrIn[0]:= ADR(command);
 AESAddrIn[1]:= ADR(path);
 CallResult:= AESCall(127, 0, 1, 2, 0);
END ShelWdef;


(*#######################################################################*)

PROCEDURE WindCreate (comp: BITSET; size: ARRAY OF WORD): INTEGER;
BEGIN
 AESIntIn[ 0]:= MagicSys.WordToInt (comp);
 AESIntIn[ 1]:= MagicSys.WordToInt (size[0]);
 AESIntIn[ 2]:= MagicSys.WordToInt (size[1]);
 AESIntIn[ 3]:= MagicSys.WordToInt (size[2]);
 AESIntIn[ 4]:= MagicSys.WordToInt (size[3]);
 RETURN AESCall(100, 5, 1, 0, 0);
END WindCreate;


PROCEDURE WindOpen   (handle: INTEGER; size: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= handle;
 AESIntIn[ 1]:= MagicSys.WordToInt (size[0]);
 AESIntIn[ 2]:= MagicSys.WordToInt (size[1]);
 AESIntIn[ 3]:= MagicSys.WordToInt (size[2]);
 AESIntIn[ 4]:= MagicSys.WordToInt (size[3]);
 CallResult:= AESCall(101, 5, 1, 0, 0);
END WindOpen;


PROCEDURE WindClose  (handle: INTEGER);
BEGIN
 AESIntIn[ 0]:= handle;
 CallResult:= AESCall(102, 1, 1, 0, 0);
END WindClose;


PROCEDURE WindDelete (handle: INTEGER);
BEGIN
 AESIntIn[ 0]:= handle;
 CallResult:= AESCall(103, 1, 1, 0, 0);
END WindDelete;


PROCEDURE WindGet (handle, flag: INTEGER; VAR para: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= handle;
 AESIntIn[ 1]:= flag;
 CallResult:= AESCall(104, 2, 5, 0, 0);
 para[0]:= MagicSys.IntToWord (AESIntOut[ 1]);
 para[1]:= MagicSys.IntToWord (AESIntOut[ 2]);
 para[2]:= MagicSys.IntToWord (AESIntOut[ 3]);
 para[3]:= MagicSys.IntToWord (AESIntOut[ 4]);
END WindGet;


PROCEDURE WindSet (handle, flag: INTEGER; VAR para: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= handle;
 AESIntIn[ 1]:= flag;
 AESIntIn[ 2]:= MagicSys.WordToInt (para[0]);
 AESIntIn[ 3]:= MagicSys.WordToInt (para[1]);
 AESIntIn[ 4]:= MagicSys.WordToInt (para[2]);
 AESIntIn[ 5]:= MagicSys.WordToInt (para[3]);
 CallResult:= AESCall(105, 6, 1, 0, 0);
END WindSet;


PROCEDURE WindFind (x, y: INTEGER): INTEGER;
BEGIN
 AESIntIn[ 0]:= x;
 AESIntIn[ 1]:= y;
 RETURN AESCall(106, 2, 1, 0, 0);
END WindFind;


PROCEDURE WindUpdate (mode: INTEGER);
BEGIN
 AESIntIn[ 0]:= mode;
 CallResult:= AESCall(107, 1, 1, 0, 0);
END WindUpdate;


PROCEDURE WindCalc (what: INTEGER; comp: BITSET; VAR in, out: ARRAY OF WORD); 
BEGIN
 AESIntIn[ 0]:= what;
 AESIntIn[ 1]:= MagicSys.WordToInt (comp);
 AESIntIn[ 2]:= MagicSys.WordToInt (in[0]);
 AESIntIn[ 3]:= MagicSys.WordToInt (in[1]);
 AESIntIn[ 4]:= MagicSys.WordToInt (in[2]);
 AESIntIn[ 5]:= MagicSys.WordToInt (in[3]);
 CallResult:= AESCall(108, 6, 5, 0, 0);
 out[0]:= MagicSys.IntToWord (AESIntOut[ 1]);
 out[1]:= MagicSys.IntToWord (AESIntOut[ 2]);
 out[2]:= MagicSys.IntToWord (AESIntOut[ 3]);
 out[3]:= MagicSys.IntToWord (AESIntOut[ 4]);
END WindCalc;


PROCEDURE WindNew;
BEGIN
 CallResult:= AESCall(109, 0, 0, 0, 0);
END WindNew;


(*#######################################################################*)

PROCEDURE ObjcAdd (tree: ADDRESS; parent, child: INTEGER);
BEGIN
 AESIntIn[ 0]:= parent;
 AESIntIn[ 1]:= child;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(40, 2, 1, 1, 0);
END ObjcAdd;


PROCEDURE ObjcDelete (tree: ADDRESS; object: INTEGER);
BEGIN
 AESIntIn[ 0]:= object;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(41, 1, 1, 1, 0);
END ObjcDelete;


PROCEDURE ObjcDraw (tree: ADDRESS; start, depth: INTEGER; VAR pxy: ARRAY OF WORD);
BEGIN
 AESIntIn[ 0]:= start;
 AESIntIn[ 1]:= depth;
 AESIntIn[ 2]:= MagicSys.WordToInt (pxy[0]);
 AESIntIn[ 3]:= MagicSys.WordToInt (pxy[1]);
 AESIntIn[ 4]:= MagicSys.WordToInt (pxy[2]);
 AESIntIn[ 5]:= MagicSys.WordToInt (pxy[3]);
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(42, 6, 1, 1, 0);
END ObjcDraw;


PROCEDURE ObjcFind (tree: ADDRESS; start, depth, x, y: INTEGER): INTEGER;
BEGIN
 AESIntIn[ 0]:= start;
 AESIntIn[ 1]:= depth;
 AESIntIn[ 2]:= x;
 AESIntIn[ 3]:= y;
 AESAddrIn[0]:= tree;
 RETURN AESCall(43, 4, 1, 1, 0);
END ObjcFind;


PROCEDURE ObjcOffset (tree: ADDRESS; object: INTEGER; VAR x, y: INTEGER);
BEGIN
 AESIntIn[ 0]:= object;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(44, 1, 3, 1, 0);
 x:= AESIntOut[1];
 y:= AESIntOut[2];
END ObjcOffset;


PROCEDURE ObjcOrder (tree: ADDRESS; object, newpos: INTEGER);
BEGIN
 AESIntIn[ 0]:= object;
 AESIntIn[ 1]:= newpos;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(45, 2, 1, 1, 0);
END ObjcOrder;


PROCEDURE ObjcEdit (tree: ADDRESS; object: INTEGER; VAR pos: INTEGER;
                  char, kind: INTEGER);
BEGIN
 AESIntIn[ 0]:= object;
 AESIntIn[ 1]:= char;
 AESIntIn[ 2]:= pos;
 AESIntIn[ 3]:= kind;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(46, 4, 2, 1, 0);
 pos:= AESIntOut[1];
END ObjcEdit;


PROCEDURE ObjcChange (tree: ADDRESS; object: INTEGER; VAR pxy: ARRAY OF WORD;
                  state: BITSET; mode: INTEGER);
BEGIN
 AESIntIn[ 0]:= object;
 AESIntIn[ 1]:= 0;
 AESIntIn[ 2]:= MagicSys.WordToInt (pxy[0]);
 AESIntIn[ 3]:= MagicSys.WordToInt (pxy[1]);
 AESIntIn[ 4]:= MagicSys.WordToInt (pxy[2]);
 AESIntIn[ 5]:= MagicSys.WordToInt (pxy[3]);
 AESIntIn[ 6]:= MagicSys.WordToInt (state);
 AESIntIn[ 7]:= mode;
 AESAddrIn[0]:= tree;
 CallResult:= AESCall(47, 8, 1, 1, 0);
END ObjcChange;


(*#######################################################################*)

PROCEDURE XgrfStepcalc (ow, oh, x, y, w, h: INTEGER;
                        VAR cx, cy, count, xstep, ystep: INTEGER);
BEGIN
 AESIntIn[ 0]:= ow;
 AESIntIn[ 1]:= oh;
 AESIntIn[ 2]:= x;
 AESIntIn[ 3]:= y;
 AESIntIn[ 4]:= w;
 AESIntIn[ 5]:= h;
 CallResult:= AESCall(130, 6, 6, 0, 0);
 cx:=    AESIntOut[ 1];
 cy:=    AESIntOut[ 2];
 count:= AESIntOut[ 3];
 xstep:= AESIntOut[ 4];
 ystep:= AESIntOut[ 5]; 
END XgrfStepcalc;


PROCEDURE Xgrf2box (xc, yc, wc, hc, corners, count, xstep, ystep, doubled: INTEGER);
BEGIN
 AESIntIn[ 0]:= count; 
 AESIntIn[ 1]:= xstep; 
 AESIntIn[ 2]:= ystep; 
 AESIntIn[ 3]:= doubled; 
 AESIntIn[ 4]:= corners; 
 AESIntIn[ 5]:= xc; 
 AESIntIn[ 6]:= yc; 
 AESIntIn[ 7]:= wc; 
 AESIntIn[ 8]:= hc; 
 CallResult:= AESCall(131, 9, 1, 0, 0);
END Xgrf2box;



BEGIN
 AESGlobal.apPtree:= MagicSys.CardToAddr (0);
 WITH AESPB DO
  cbControl:=  ADR (AESControl);
  cbPglobal:=  ADR (AESGlobal);
  cbPintin:=   ADR (AESIntIn);
  cbPintout:=  ADR (AESIntOut);
  cbPadrin:=   ADR (AESAddrIn);
  cbPadrout:=  ADR (AESAddrOut);
 END;

 (* Zeiger auf Tastatur Puffer-Deskriptor holen *)
 kbd:= MagicXBIOS.Iorec(MagicXBIOS.IKBD);
 head:= 0;
 Tastatur.in:= 0;
 Tastatur.out:= 0;
 stack:= 0;
 MagicDOS.Super(stack);
 oldConterm:= ConTerm;
 INCL(ConTerm, Kbshift);
 MagicDOS.Super( stack );
END MagicAES.

