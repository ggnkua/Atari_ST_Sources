Program Zmodem;


Const
	TPZVER = 'TPZ [Zmodem] 2.1á';
	ZBUFSIZE = 1024;
	zport: Integer = 1;
	zbaud: Long_Integer = 0;

	ZATTNLEN = 32;	{max length Of attention String}
	lastwritten: Byte = 0;
	x1: Byte = 20;
	x2: Byte = 59;
	y1: Byte = 5;
	y2: Byte = 17;
	Fore: Byte = LightGray;
	back: Byte = Black;
	bFore: Byte = Black;
	bback: Byte = Green;

	ZPAD = 42;	{ '*' }
	ZDLE = 24;	{ ^X	}
	ZDLEE = 88;
	ZBIN = 65;	{ 'A' }
	ZHEX = 66;	{ 'B' }
	ZBIN32 = 67;{ 'C' }
	ZRQINIT = 0;
	ZRINIT = 1;
	ZSINIT = 2;
	ZACK = 3;
	ZFILE = 4;
	ZSKIP = 5;
	ZNAK = 6;
	ZABORT = 7;
	ZFIN = 8;
	ZRPOS = 9;
	ZDATA = 10;
	ZEOf = 11;
	ZFERR = 12;
	ZCRC = 13;
	ZCHALLENGE = 14;
	ZCOMPL = 15;
	ZCAN = 16;
	ZFREECNT = 17;
	ZCOMMAnd = 18;
	ZSTDERR = 19;
	ZCRCE = 104; { 'h' }
	ZCRCG = 105; { 'i' }
	ZCRCQ = 106; { 'j' }
	ZCRCW = 107; { 'k' }
	ZRUB0 = 108; { 'l' }
	ZRUB1 = 109; { 'm' }
	ZOK = 0;
	ZERROR = -1;
	ZTIMEOUT = -2;
	RCDo = -3;
	FUBAR = -4;
	GotoR = 256;
	GOTCRCE = 360; { 'h' OR 256 }
	GOTCRCG = 361; { 'i' "	"	}
	GOTCRCQ = 362; { 'j' "	"	}
	GOTCRCW = 363; { 'k' "	"	}
	GOTCAN = 272;	{ CAN OR	"	}

{ xmodem paramaters }
	ENQ = 5;
	CAN = 24;
	XOfF = 19;
	XON = 17;
	SOH = 1;
	STX = 2;
	EOT = 4;
	ACK = 6;
	NAK = 21;
	CPMEOf = 26;

{ Byte positions }
	ZF0 = 3;
	ZF1 = 2;
	ZF2 = 1;
	ZF3 = 0;
	ZP0 = 0;
	ZP1 = 1;
	ZP2 = 2;
	ZP3 = 3;

{ bit masks For ZRINIT }
	CANFDX = 1;		{ can hAndle full-duplex					(yes For PC's)}
	CANOVIO = 2;	{ can overlay disk And serial I/O (ditto)			}
	CANBRK = 4;		{ can sEnd a break - True but superfluous			}
	CANCRY = 8;		{ can encrypt/decrypt - Not defined yet				}
	CANLZW = 16;	{ can LZ compress - Not defined yet						}
	CANFC32 = 32;	{ can use 32 bit crc frame checks - True				}
	ESCALL = 64;	{ escapes all control Chars. Not implemented		}
	ESC8 = 128;		{ escapes the 8th bit. Not implemented					}

{ bit masks For ZSINIT }
	TESCCTL = 64;
	TESC8 = 128;

{ paramaters For ZFILE }
{ ZF0 }
	ZCBIN = 1;
	ZCNL = 2;
	ZCRESUM = 3;
{ ZF1 }
	ZMNEW = 1;	{I haven't implemented these as Of yet - most are}
	ZMCRC = 2;	{superfluous on a BBS - Would be nice from a comm}
	ZMAPND = 3;	{programs' point Of view however								}
	ZMCLOB = 4;
	ZMSPARS = 5;
	ZMDIfF = 6;
	ZMPROT = 7;
{ ZF2 }
	ZTLZW = 1;	{encryption, compression And funny file hAndling }
	ZTCRYPT = 2; {flags - My Docs (03/88) from OMEN say these have}
	ZTRLE = 3;	{Not been defined yet														}
{ ZF3 }
	ZCACK1 = 1;	{God only knows...															}

	lastsent: Byte = 0;

	C1970 = 2440588;
	D0 =		1461;
	D1 =	146097;
	D2 = 1721119;

(* crctab calculated by Mark G. MEndel, Network Systems Corporation *)
	crctab: ARRAY[0..255] Of Integer = (
		$0000,	$1021,	$2042,	$3063,	$4084,	$50a5,	$60c6,	$70e7,
		$8108,	$9129,	$a14a,	$b16b,	$c18c,	$d1ad,	$e1ce,	$f1ef,
		$1231,	$0210,	$3273,	$2252,	$52b5,	$4294,	$72f7,	$62d6,
		$9339,	$8318,	$b37b,	$a35a,	$d3bd,	$c39c,	$f3ff,	$e3de,
		$2462,	$3443,	$0420,	$1401,	$64e6,	$74c7,	$44a4,	$5485,
		$a56a,	$b54b,	$8528,	$9509,	$e5ee,	$f5cf,	$c5ac,	$d58d,
		$3653,	$2672,	$1611,	$0630,	$76d7,	$66f6,	$5695,	$46b4,
		$b75b,	$a77a,	$9719,	$8738,	$f7df,	$e7fe,	$d79d,	$c7bc,
		$48c4,	$58e5,	$6886,	$78a7,	$0840,	$1861,	$2802,	$3823,
		$c9cc,	$d9ed,	$e98e,	$f9af,	$8948,	$9969,	$a90a,	$b92b,
		$5af5,	$4ad4,	$7ab7,	$6a96,	$1a71,	$0a50,	$3a33,	$2a12,
		$dbfd,	$cbdc,	$fbbf,	$eb9e,	$9b79,	$8b58,	$bb3b,	$ab1a,
		$6ca6,	$7c87,	$4ce4,	$5cc5,	$2c22,	$3c03,	$0c60,	$1c41,
		$edae,	$fd8f,	$cdec,	$ddcd,	$ad2a,	$bd0b,	$8d68,	$9d49,
		$7e97,	$6eb6,	$5ed5,	$4ef4,	$3e13,	$2e32,	$1e51,	$0e70,
		$ff9f,	$efbe,	$dfdd,	$cffc,	$bf1b,	$af3a,	$9f59,	$8f78,
		$9188,	$81a9,	$b1ca,	$a1eb,	$d10c,	$c12d,	$f14e,	$e16f,
		$1080,	$00a1,	$30c2,	$20e3,	$5004,	$4025,	$7046,	$6067,
		$83b9,	$9398,	$a3fb,	$b3da,	$c33d,	$d31c,	$e37f,	$f35e,
		$02b1,	$1290,	$22f3,	$32d2,	$4235,	$5214,	$6277,	$7256,
		$b5ea,	$a5cb,	$95a8,	$8589,	$f56e,	$e54f,	$d52c,	$c50d,
		$34e2,	$24c3,	$14a0,	$0481,	$7466,	$6447,	$5424,	$4405,
		$a7db,	$b7fa,	$8799,	$97b8,	$e75f,	$f77e,	$c71d,	$d73c,
		$26d3,	$36f2,	$0691,	$16b0,	$6657,	$7676,	$4615,	$5634,
		$d94c,	$c96d,	$f90e,	$e92f,	$99c8,	$89e9,	$b98a,	$a9ab,
		$5844,	$4865,	$7806,	$6827,	$18c0,	$08e1,	$3882,	$28a3,
		$cb7d,	$db5c,	$eb3f,	$fb1e,	$8bf9,	$9bd8,	$abbb,	$bb9a,
		$4a75,	$5a54,	$6a37,	$7a16,	$0af1,	$1ad0,	$2ab3,	$3a92,
		$fd2e,	$ed0f,	$dd6c,	$cd4d,	$bdaa,	$ad8b,	$9de8,	$8dc9,
		$7c26,	$6c07,	$5c64,	$4c45,	$3ca2,	$2c83,	$1ce0,	$0cc1,
		$ef1f,	$ff3e,	$cf5d,	$df7c,	$af9b,	$bfba,	$8fd9,	$9ff8,
		$6e17,	$7e36,	$4e55,	$5e74,	$2e93,	$3eb2,	$0ed1,	$1ef0
);
	crc_32_tab: ARRAY[0..255] Of Long_Integer = (
$00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
$0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
$1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
$136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
$3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
$35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
$26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
$2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
$76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
$7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
$6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
$65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
$4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
$4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
$5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
$5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
$edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
$e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
$f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
$fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
$d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
$d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
$cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
$c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
$9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
$95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
$86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
$88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
$a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
$aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
$bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
$b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
);

TYPE
	hdrtype = ARRAY[0..3] Of Byte;
	buftype = ARRAY[0..1023] Of Byte;

Var
	vmode: Byte absolute $0040:$0049;
	vcols: Integer absolute $0040:$004A;
	oldx, oldy, oldattr: Byte;
	oldmin, oldmax, cols, rows, size, vseg, vOfs: Integer;
	buffer: POINTER;

	infile: FILE;
	strtpos: Long_Integer;
	rxbuflen: Integer;
	txbuf: buftype;
	blkred: Integer;

	rxpos: Long_Integer; {file position received from Z_GetHeader}
	rxhdr: hdrtype;		{receive header Var}
	rxtimeout,
	rxtype,
	rxframeind: Integer;
	attn: buftype;
	secbuf: buftype;
	fname: String;
	fmode: Integer;
	ftime,
	fsize: Long_Integer;
	usecrc32: Boolean;
	zcps, zerrors: Integer;
	txpos: Long_Integer;
	txhdr: hdrtype;
	ztime: Long_Integer;
	t: Long_Integer;
	rzbatch: Boolean;
	outfile: FILE;		{this is the file}
	tryzhdrtype: Byte;
	rxcount: Integer;
	filestart: Long_Integer;
	isbinary, eOfseen: Boolean;
	zconv: Byte;
	zrxpath: String;

Function RtoS(r: REAL; width, decimals: Integer): String;
Var
	s: String;
Begin
	Str(r:width:decimals,s);
	If (IoResult <> 0) Then s := ''
	Else While (Length(s) > 0) And (s[1] = ' ') Do	Delete(s,1,1);
	RtoS := s
End;

Function ItoS(r: Long_Integer; width: Integer): String;
Var
	s: String;
Begin
	Str(r:width,s);
	If (IoResult <> 0) Then s := ''
	Else While (Length(s) > 0) And (s[1] = ' ') Do Delete(s,1,1);
	ItoS := s
End;


Procedure Z_OpenWinDow(title: String);
Var
	p, q: POINTER;
	n, pads, Bytes: Integer;
Begin
	DirectVideo := True;
	CheckSnow := False;
	oldx := WhereX;
	oldy := WhereY;
	oldattr := TextAttr;
	oldmin := WindMin;
	oldmax := WindMax;
	WinDow(x1,y1,x2,y2);
	TextColor(bFore);
	TextBackground(bback);
	cols := Lo(WindMax) - Lo(WindMin) + 1;
	rows := Hi(WindMax) - Hi(WindMin) + 1;
	If vmode = 7 Then vseg := $B000	Else vseg := $B800;
	vOfs := ((Hi(WindMin) * vcols) + Lo(WindMin)) * 2;
	size := (rows * cols) * 2;
	Bytes := cols * 2;
	pads := (vcols * 2) - Bytes;
	GetMem(buffer,size);
	p := Ptr(vseg,vOfs);
	q := buffer;
	For n := 1 TO rows Do Begin
		MoveFromScreen(p^,q^,cols * 2);
		Inc(Long_Integer(p),vcols * 2);
		Inc(Long_Integer(q),cols * 2)
	End;
	ClrScr;
	If (Length(title) > (cols - 2)) Then title[0] := Chr(cols-2);
	GotoXY((cols - Length(title) - 2) DIV 2 + 1,1);
	WRITE(title);
	title := ' ESCape to abort';
	GotoXY((cols - Length(title) - 2) DIV 2 + 1,rows);
	WRITE(title);
	WinDow(x1+1,y1+1,x2-1,y2-1);
	TextColor(Fore);
	TextBackground(back);
	ClrScr;
	GotoXY(1,1);
	WriteLn(' File name.....:');
	WriteLn(' File size.....:');
	WriteLn(' File blocks...:');
	WriteLn(' Block check...:');
	WriteLn(' Transfer time.:');
	WriteLn(' Current Byte..:');
	WriteLn(' Current BLOCK.:');
	WriteLn(' Error count...:');
	WriteLn(' Last frame....:');
	TextColor(bFore);
	TextBackground(bback);
	GotoXY(1,10);
	ClrEol;
	title := #$19+'Last Message'+#$19;
	GotoXY((cols - Length(title) - 2) DIV 2 + 1,10);
	WRITE(title);
	TextColor(White);
	TextBackground(back)
End;

Procedure Z_CloseWinDow;
Var
	p, q: POINTER;
	n: Integer;
Begin
	TextAttr := oldattr;
	WindMax := oldmax;
	WindMin := oldmin;
	GotoXY(oldx,oldy);
	q := buffer;
	p := Ptr(vseg,vOfs);
	For n := 1 TO rows Do Begin
		MoveToScreen(q^,p^,cols * 2);
		Inc(Long_Integer(p),vcols * 2);
		Inc(Long_Integer(q),cols * 2)
	End;
	FreeMem(buffer,size)
End;

Procedure Z_ShowName(filename: String);
Begin
	If (Length(filename) > 14) Then filename[0] := #14;
	GotoXY(18,1);
	WRITE(filename);
	GotoXY(1,11)
End;


Procedure Z_ShowSize(l: Long_Integer);
Begin
	GotoXY(18,2);
	WRITE(ItoS(l,14));
	If (l MOD 128 <> 0) Then l := (l DIV 128) + 1
	Else l := (l DIV 128);
	GotoXY(18,3);
	WRITE(ItoS(l,14));
	GotoXY(1,11);
End;


Procedure Z_ShowCheck(is32: Boolean);
Begin
	GotoXY(18,4);
	If (is32) Then WRITE('CRC32')
	Else WRITE('CRC16');
	GotoXY(1,11)
End;

Procedure Z_ShowTransferTime(fsize, zbaud: Long_Integer);
Var
	bits: REAL;
Begin
	bits := fsize * 10.0;
	GotoXY(18,5);
	If (bits <> 0.0) Then WRITE(RtoS(((bits / zbaud) / 60),10,2),'min.')
	Else WRITE('0min.');
	GotoXY(1,11)
End;


Procedure Z_Message(s: String);
Begin
	If (Length(s) > 31) Then s[0] := #31;
	GotoXY(1,11);
	WRITE(s,#13)
End;

Procedure Z_Frame(n: Integer);
Begin
	If (n < -3) OR (n > 20) Then n := 20;
	GotoXY(18,9);
	Case Lo(n) Of
		-3 : WRITE('ZNOCARRIER');
		-2 : WRITE('ZTIMEOUT	');
		-1 : WRITE('ZERROR		');
		0	: WRITE('ZRQINIT	');
		1	: WRITE('ZRINIT		');
		2	: WRITE('ZSINIT		');
		3	: WRITE('ZACK			');
		4	: WRITE('ZFILE		');
		5	: WRITE('ZSKIP		');
		6	: WRITE('ZNAK			');
		7	: WRITE('ZABORT		');
		8	: WRITE('ZFIN			');
		9	: WRITE('ZRPOS		');
		10 : WRITE('ZDATA		');
		11 : WRITE('ZEOf			');
		12 : WRITE('ZFERR		');
		13 : WRITE('ZCRC			');
		14 : WRITE('ZCHALLENGE');
		15 : WRITE('ZCOMPL		');
		16 : WRITE('ZCAN			');
		17 : WRITE('ZFREECNT	');
		18 : WRITE('ZCOMMAnd	');
		19 : WRITE('ZSTDERR	');
		20 : WRITE('ZUNKNOWN	')
	End;
	GotoXY(1,11)
End;

Procedure Z_ShowLoc(l: Long_Integer);
Begin
	GotoXY(18,6);
	WRITE(ItoS(l,14));
	If (l MOD 128 <> 0) Then l := (l DIV 128) + 1
	Else l := (l DIV 128);
	GotoXY(18,7);
	WRITE(ItoS(l,14));
	GotoXY(1,11)
End;

Procedure Z_Errors(w: Integer);
Begin
	GotoXY(18,8);
	WRITE(ItoS(w,14));
	GotoXY(1,11)
End;


Procedure GregorianToJuliAndN(Year, Month, Day : Integer;
																	Var JuliAndN : Long_Integer);
Var
	Century,
	XYear		: Long_Integer;
Begin {GregorianToJuliAndN}
	If Month <= 2 Then Begin
		Year := pred(Year);
		Month := Month + 12;
		End;
	Month := Month - 3;
	Century := Year div 100;
	XYear := Year mod 100;
	Century := (Century * D1) shr 2;
	XYear := (XYear * D0) shr 2;
	JuliAndN := ((((Month * 153) + 2) div 5) + Day) + D2
																		+ XYear + Century;
End; {GregorianToJuliAndN}

Procedure JuliAndNToGregorian(JuliAndN : Long_Integer;
									Var Year, Month, Day : Integer);
Var
	Temp,
	XYear	: Long_Integer;
	YYear,
	YMonth,
	YDay		: Integer;
Begin {JuliAndNToGregorian}
	Temp := (((JuliAndN - D2) shl 2) - 1);
	XYear := (Temp mod D1) or 3;
	JuliAndN := Temp div D1;
	YYear := (XYear div D0);
	Temp := ((((XYear mod D0) + 4) shr 2) * 5) - 3;
	YMonth := Temp div 153;
	If YMonth >= 10 Then Begin
		YYear := YYear + 1;
		YMonth := YMonth - 12;
		End;
	YMonth := YMonth + 3;
	YDay := Temp mod 153;
	YDay := (YDay + 5) div 5;
	Year := YYear + (JuliAndN * 100);
	Month := YMonth;
	Day := YDay;
End; {JuliAndNToGregorian}

Function Z_ToUnixDate(fdate: Long_Integer): String;
Var
	dt: DateTime;
	secspast, datenum, dayspast: Long_Integer;
	s: String;
Begin
	UnpackTime(fdate,dt);
	GregorianToJuliAndN(dt.year,dt.month,dt.day,datenum);
	dayspast := datenum - c1970;
	secspast := dayspast * 86400;
	secspast := secspast + dt.hour * 3600 + dt.min * 60 + dt.sec;
	s := '';
	While (secspast <> 0) And (Length(s) < 255) Do Begin
		s := Chr((secspast And 7) + $30) + s;
		secspast := (secspast SHR 3)
	End;
	s := '0' + s;
	Z_ToUnixDate := s
End;

Function Z_FromUnixDate(s: String): Long_Integer;
Var
	dt: DateTime;
	secspast, datenum: Long_Integer;
	n: Integer;
Begin
	secspast := Long_Integer(0);
	For n := 1 TO Length(s) Do secspast := (secspast SHL 3) + Ord(s[n]) - $30;
	datenum := (secspast DIV 86400) + c1970;
	JuliAndNToGregorian(datenum,Integer(dt.year),Integer(dt.month),Integer(dt.day));
	secspast := secspast MOD 86400;
	dt.hour := secspast DIV 3600;
	secspast := secspast MOD 3600;
	dt.min := secspast DIV 60;
	dt.sec := secspast MOD 60;
	PackTime(dt,secspast);
	Z_FromUnixDate := secspast
End;


Function Z_OpenFile(Var f: FILE; pathname: String): Boolean;
Begin
	Assign(f,pathname);
	Reset(f,1);
	Z_OpenFile := (IOresult = 0)
End;

Function Z_MakeFile(Var f: FILE; pathname: String): Boolean;
Begin
	Assign(f,pathname);
	ReWrite(f,1);
	Z_MakeFile := (IOresult = 0)
End;

Procedure Z_CloseFile(Var f: FILE);
Begin
	Close(f);
	If (IOresult <> 0) Then { ignore this error }
End;

Function Z_SeekFile(Var f: FILE; fpos: Long_Integer): Boolean;
Begin
	Seek(f,fpos);
	Z_SeekFile := (IOresult = 0)
End;

Function Z_WriteFile(Var f: FILE; Var buff; Bytes: Integer): Boolean;
Begin
	BlockWrite(f,buff,Bytes);
	Z_WriteFile := (IOresult = 0)
End;

Function Z_ReadFile(Var f: FILE; Var buff; btoread: Integer; Var bread: Integer): Boolean;
Begin
	BlockRead(f,buff,btoread,bread);
	Z_ReadFile := (IOresult = 0)
End;

Function Z_FindFile(pathname: String; Var name: String; Var size, time: Long_Integer): Boolean;
Var
	sr: SearchRec;
Begin
	FindFirst(pathname,Archive,sr);
	If (DosError <> 0) OR (IOresult <> 0) Then Begin
		Z_FindFile := False;
		Exit
	End;
	name := sr.Name;
	size := sr.Size;
	time := sr.Time;
	Z_FindFile := True
End;

Procedure Z_SetFTime(Var f: FILE; time: Long_Integer);
Begin
	SetFTime(f,time);
	If (IOresult <> 0) Then {null}
End;

End.

{ Note: Your crc Variable must be initialized to 0, beFore			}
{			using tis routine.																			}
{ Translated to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau }
{																																}
(*
 * updcrc derived from article Copyright (C) 1986 Stephen Satchell.
 *	NotE: First argument must be in range 0 to 255.
 *				Second argument is referenced twice.
 *
 * Programmers may incorporate any or all code into their programs,
 * giving proper credit within the source. Publication Of the
 * source routines is permitted so long as proper credit is given
 * to Stephen Satchell, Satchell Evaluations And Chuck Forsberg,
 * Omen Technology.
 *)
Function UpdCrc(cp: Byte; crc: Integer): Integer;
Begin { UpdCrc }
	UpdCrc := crctab[((crc SHR 8) And 255)] XOR (crc SHL 8) XOR cp
End;

{ Use a type Long_Integer Variable to store the crc value.										}
{ Initialise the Variable to $FFFFFFFF beFore running the crc routine.		}
{ VERY IMPORTANT!!!! -> This routine was developed For data communications}
{ And returns the crc Bytes in LOW to HIGH order, Not Byte reversed!			}
{ To turn the valu into a 'normal' Long_Integer, you must reverse the Bytes!	}
{ e.g.																																		}
{ Var																																		}
{		l, crc: Long_Integer;																										}
{		list: ARRAY[0..1023] Of Byte;																				}
{		counter: Integer;																										}
{																																				}
{ Begin																																	}
{		crc := $FFFFFFFF;													(* initialise	*)				}
{		FillChar(list,SizeOf(list),1);							(* dummy array *)				}
{		For counter := 0 TO (Pred(SizeOf(list))) Do (* run thru		*)				}
{			crc := UpdC32(buf[counter],crc);				(* finding crc *)				}
{		For counter := 1 TO 4 Do										(* reverse		*)				}
{			l := (l SHL 8) OR Byte(crc);						(* the Bytes	*)				}
{		(* l now contains the 'normalized' crc *)														}
{																																				}



(* Converted to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau			*)
(* Copyright (C) 1986 Gary S. Brown.	You may use this program, or		*)
(* code or tables extracted from it, as desired without restriction.	*)
(*																																		*)
(* First, the polynomial itself And its table Of feedback terms.	The	*)
(* polynomial is																											*)
(* X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0 *)
(* Note that we take it "backwards" And put the highest-order term in	*)
(* the lowest-order bit.	The X^32 term is "implied"; the LSB is the	*)
(* X^31 term, etc.	The X^0 term (usually shown as "+1") results in		*)
(* the MSB being 1.																										*)
(*																																		*)
(* Note that the usual hardware shIft register implementation, which	*)
(* is what we're using (we're merely optimizing it by Doing eight-bit	*)
(* chunks at a time) shIfts bits into the lowest-order term.	In our	*)
(* implementation, that means shIfting towards the right.	Why Do we	*)
(* Do it this way?	Because the calculated CRC must be transmitted in	*)
(* order from highest-order term to lowest-order term.	UARTs transmit *)
(* Characters in order from LSB to MSB.	By storing the CRC this way,	*)
(* we hAnd it to the UART in the order low-Byte to high-Byte; the UART *)
(* sEnds each low-bit to hight-bit; And the result is transmission bit *)
(* by bit from highest- to lowest-order term without requiring any bit *)
(* shuffling on our part.	Reception works similarly.									*)
(*																																		*)
(* The feedback terms table consists Of 256, 32-bit entries.	Notes:	*)
(*																																		*)
(*		The table can be generated at runtime If desired; code to Do so *)
(*		is shown later.	It might Not be obvious, but the feedback			*)
(*		terms simply represent the results Of eight shIft/xor opera-		*)
(*		tions For all combinations Of data And CRC register values.		*)
(*																																		*)
(*		The values must be right-shIfted by eight bits by the "updcrc"	*)
(*		logic; the shIft must be unsigned (bring in zeroes).	On some	*)
(*		hardware you could probably optimize the shIft in assembler by	*)
(*		using Byte-swap instructions.																	*)
(*		polynomial $edb88320																						*)
(*																																		*)

Function UpdC32(octet: Byte; crc: Long_Integer) : Long_Integer;
Begin { UpdC32 }
	UpdC32 := crc_32_tab[Byte(crc XOR Long_Integer(octet))] XOR ((crc SHR 8) And $00FFFFFF)
End;


Function Z_CharAvail: Boolean;
(* See If there is a Character coming in *)
Begin
	Z_CharAvail := Async_Buffer_Check
End;

Procedure Z_ClearInbound;
(* Throw away any pEnding input to clear the line *)
Var
	n: Integer;
Begin
	While (Async_Carrier_Detect) And (Async_Buffer_Check) Do
		Async_Receive_With_Timeout(1,n)
End;

Procedure Z_ClearOutbound;
(* Throw away any pEnding output in the buffer *)
Begin
	Async_Flush_Output_Buffer
End;

Procedure Z_FlushOutbound;
Begin
	Repeat Until (Not Async_Carrier_Detect) OR
		(Async_OBuffer_Head = Async_OBuffer_Tail)
End;

Procedure Z_SEndBreak;
(* SEnd a break signal *)
Begin
	Async_SEnd_Break
End;

Procedure Z_SEndByte(b: Byte);
(* Output one Byte *)
Begin
	Async_SEnd(Chr(b))
End;

Function Z_ReceiveByte: Integer;
(* Input one Byte (N.B.: RETURNS AN Integer!) *)
Var
	n: Integer;
Begin
	Async_Receive_With_Timeout(0,n);
	Z_ReceiveByte := (n And $00FF)
End;

Function Z_Carrier: Boolean;
(* Checks For the presence Of a carrier *)
Begin
	Z_Carrier := (Async_Carrier_Detect)
End;

Procedure Z_AsyncOff;
Var
	I : Integer;
	M : Integer;
Begin	(* Async_Close *)
									(* Read the RBR And reset any pEnding error conditions. *)
									(* First turn Off the Divisor Access Latch Bit to allow *)
									(* access to RBR, etc.																	*)
	INLINE($FA);	(* disable interrupts *)
	Port[UART_LCR + Async_Base] := Port[UART_LCR + Async_Base] And $7F;
									(* Read the Line Status Register to reset any errors *)
									(* it indicates																			*)
	I := Port[UART_LSR + Async_Base];
									(* Read the Receiver Buffer Register in Case it *)
									(* contains a Character												*)
	I := Port[UART_RBR + Async_Base];
									(* enable the irq on the 8259 controller *)
	I := Port[I8088_IMR];	(* get the interrupt mask register *)
	M := (1 SHL Async_Irq) XOR $00FF;
	Port[I8088_IMR] := I And M;
									(* enable OUT2 on 8250 *)
	I := Port[UART_MCR + Async_Base];
	Port[UART_MCR + Async_Base] := I OR $0B;
									(* enable the data ready interrupt on the 8250 *)
	Port[UART_IER + Async_Base] := $0F;
									(* Re-enable 8259 *)
	Port[$20] := $20;
	INLINE($FB); (* enable interrupts *)
	If Async_Open_Flag Then Begin
										(* disable the IRQ on the 8259 *)
				INLINE($FA);								(* disable interrupts *)
				I := Port[I8088_IMR];				(* get the interrupt mask register *)
				M := 1 SHL Async_Irq;				(* set mask to turn Off interrupt	*)
				Port[I8088_IMR] := I OR M;
										(* disable the 8250 interrupts *)
				Port[UART_IER + Async_Base] := 0;
										(* Disable OUT2, RTS, OUT1 on the 8250, but *)
										(* possibly leave DTR enabled.							*)
				Port[UART_MCR + Async_Base] := 1;
				INLINE($FB);								(* enable interrupts *)
										(* re-initialize our data areas so we know *)
										(* the port is closed											*)
				Async_Open_Flag := False;
				Async_XOfF_Sent := False;
										(* Restore the previous interrupt pointers *)
				SetIntVec( Async_Irq + 8 , Async_Save_Iaddr );
			I := Port[UART_LSR + Async_Base];
								(* Read the Receiver Buffer Register in Case it *)
								(* contains a Character												*)
				I := Port[UART_RBR + Async_Base];
						(* enable the irq on the 8259 controller *)
				I := Port[I8088_IMR];	(* get the interrupt mask register *)
				M := (1 SHL Async_Irq) XOR $00FF;
				Port[I8088_IMR] := I And M;
						(* enable OUT2 on 8250 *)
				I := Port[UART_MCR + Async_Base];
				Port[UART_MCR + Async_Base] := I OR $0B;
						(* enable the data ready interrupt on the 8250 *)
				Port[UART_IER + Async_Base] := $0F;
						(* Re-enable 8259 *)
				Port[$20] := $20;
				INLINE($FB); (* enable interrupts *)
			End;
End		(* Async_Close *);

Function Z_AsyncOn(zport: Integer; zbaud: Long_Integer): Boolean;
Begin
	Async_Do_CTS := False;
	Async_Do_DSR := False;
	Async_Do_XonXOff := False;
	Async_Hard_Wired_On := False;
	Async_Break_Length := 500;
	Async_Init(2048,2048,0,0,0);
	Z_AsyncOn := Async_Open(zport,zbaud,'N',8,1)
End;


Function Z_SetTimer: Long_Integer;
Var
	l: Long_Integer;
	h,m,s,x: Integer;
Begin
	GetTime(h,m,s,x);
	l := Long_Integer(h) * 3600;
	l := l + Long_Integer(m) * 60;
	l := l + Long_Integer(s);
	Z_SetTimer := l
End;

Function Z_FileCRC32(Var f: FILE): Long_Integer;
Var
	fbuf: buftype;
	crc: Long_Integer;
	bread, n: Integer;
Begin
	crc := $FFFFFFFF;
	Seek(f,0);
	If (IOresult <> 0) Then {null};
	Repeat
		BlockRead(f,fbuf,ZBUFSIZE,bread);
		For n := 0 TO (bread - 1) Do crc := UpdC32(fbuf[n],crc)
	Until (bread < ZBUFSIZE) OR (IOresult <> 0);
	Seek(f,0);
	If (IOresult <> 0) Then {null};
	Z_FileCRC32 := crc
End;

Function Z_GetByte(tenths: Integer): Integer;
(* Reads a Byte from the modem - Returns RCDo If *)
(* no carrier, or ZTIMEOUT If Nothing received	*)
(* within 'tenths' Of a second.									*)
Var
	n: Integer;
Begin
	Repeat
		If (Not Z_Carrier) Then Begin
			Z_GetByte := RCDo; { nobody to talk to }
			Exit
		End;
		If (Z_CharAvail) Then Begin
			Z_GetByte := Z_ReceiveByte; { got Character }
			Exit
		End;
		Dec(tenths);							{ dec. the count		}
		Delay(100)								{ pause 1/10th sec. }
	Until (tenths <= 0);
	Z_GetByte := ZTIMEOUT				{ timed out }
End;

Function Z_qk_read: Integer;
(* Just like Z_GetByte, but timeout value is in *)
(* global Var rxtimeout.												*)
Begin
	Z_qk_read := Z_GetByte(rxtimeout)
End;


Function Z_TimedRead: Integer;
(* A Z_qk_read, that strips parity And *)
(* ignores XON/XOfF Characters.				*)
Var
	Done: Boolean;
	c: Integer;
Begin
	Done := False;
	Repeat
		c := Z_qk_read And $FF7F								{ strip parity }
	Until (c < 0) OR (Not (Lo(c) IN [17,19])); { wait For other than XON/XOfF }
	Z_TimedRead := c
End;

Procedure Z_SEndCan;
(* SEnd a zmodem CANcel sequence to the other guy *)
(* 8 CANs And 8 backspaces												*)
Var
	n: Byte;
Begin
	Z_ClearOutbound; { spare them the junk }
	For n := 1 To 8 Do Begin
		Z_SEndByte(CAN);
		Delay(100)		{ the pause seems to make reception Of the sequence }
	End;							{ more reliable																		}
	For n := 1 TO 10 Do Z_SEndByte(8)
End;

Procedure Z_PutString(Var p: buftype);
(* Outputs an ASCII-Z type String (null terminated) *)
(* Processes meta Characters 221 (sEnd break) And	*)
(* 222 (2 second delay).														*)
Var
	n: Integer;
Begin
	n := 0;
	While (n < ZBUFSIZE) And (p[n] <> 0) Do Begin
			Case p[n] Of
				221 : Z_SEndBreak;
				222 : Delay(2000)
				Else  Z_SEndByte(p[n])
			End;
			Inc(n)
	End
End;

Procedure Z_PutHex(b: Byte);
(* Output a Byte as two hex digits (in ASCII) *)
(* Uses lower Case to avoid confusion with		*)
(* escaped control Characters.								*)
Const
	hex: ARRAY[0..15] Of Char = '0123456789abcdef';
Begin
	Z_SEndByte(Ord(hex[b SHR 4]));	{ high nybble }
	Z_SEndByte(Ord(hex[b And $0F])) { low nybble	}
End;

Procedure Z_SEndHexHeader(htype: Byte; Var hdr: hdrtype);
(* SEnds a zmodem hex type header *)
Var
	crc: Integer;
	n, i: Integer;
Begin
	Z_SEndByte(ZPAD);									{ '*' }
	Z_SEndByte(ZPAD);									{ '*' }
	Z_SEndByte(ZDLE);									{ 24	}
	Z_SEndByte(ZHEX);									{ 'B' }
	Z_PutHex(htype);
	crc := UpdCrc(htype,0);
	For n := 0 TO 3 Do Begin
		Z_PutHex(hdr[n]);
		crc := UpdCrc(hdr[n],crc)
	End;
	crc := UpdCrc(0,crc);
	crc := UpdCrc(0,crc);
	Z_PutHex(Lo(crc SHR 8));
	Z_PutHex(Lo(crc));
	Z_SEndByte(13);										{ make it readable to the other End }
	Z_SEndByte(10);										{ just in Case											}
	If (htype <> ZFIN) And (htype <> ZACK) Then
			Z_SEndByte(17);								{ Prophylactic XON to assure flow	}
	If (Not Z_Carrier) Then Z_ClearOutbound
End;

Function Z_PullLongFromHeader(Var hdr: hdrtype): Long_Integer;
(* Stuffs a Long_Integer into a header Variable - N.B. - Bytes are REVERSED! *)
Var
	l: Long_Integer;
Begin
	l := hdr[ZP3];							{ hard coded For efficiency }
	l := (l SHL 8) OR hdr[ZP2];
	l := (l SHL 8) OR hdr[ZP1];
	l := (l SHL 8) OR hdr[ZP0];
	Z_PullLongFromHeader := l
End;

Procedure Z_PutLong_IntegeroHeader(l: Long_Integer);
(* Reverse Of above *)
Begin
	txhdr[ZP0] := Byte(l);
	txhdr[ZP1] := Byte(l SHR 8);
	txhdr[ZP2] := Byte(l SHR 16);
	txhdr[ZP3] := Byte(l SHR 24)
End;

Function Z_GetZDL: Integer;
(* Gets a Byte And processes For ZMODEM escaping or CANcel sequence *)
Var
	c, d: Integer;
Begin
	If (Not Z_Carrier) Then Begin
		Z_GetZDL := RCDo;
		Exit
	End;
	c := Z_qk_read;
	If (c <> ZDLE) Then Begin
		Z_GetZDL := c;
		Exit
	End;	{got ZDLE or 1st CAN}
	c := Z_qk_read;
	If (c = CAN) Then	Begin {got 2nd CAN}
			c := Z_qk_read;
			If (c = CAN) Then Begin {got 3rd CAN}
				c := Z_qk_read;
				If (c = CAN) Then c := Z_qk_read  {got 4th CAN}
			End
	End;
	{ Flags set in high Byte }
	Case c Of
			CAN: Z_GetZDL := GOTCAN; {got 5th CAN}
			ZCRCE,									{got a frame End marker}
			ZCRCG,
			ZCRCQ,
			ZCRCW: Z_GetZDL := (c OR GotoR);
			ZRUB0: Z_GetZDL := $007F; {got an ASCII DELete}
			ZRUB1: Z_GetZDL := $00FF	{any parity				}
			Else Begin
				If (c < 0) Then Z_GetZDL := c
				Else If ((c And $60) = $40) Then	{make sure it was a valid escape}
						Z_GetZDL := c XOR $40
				Else Z_GetZDL := ZERROR
			End
	End
End;

Function Z_GetHex: Integer;
(* Get a Byte that has been received as two ASCII hex digits *)
Var
	c, n: Integer;
Begin
	n := Z_TimedRead;
	If (n < 0) Then Begin
		Z_GetHex := n;
		Exit
	End;
	n := n - $30;										{build the high nybble}
	If (n > 9) Then n := n - 39;
	If (n And $FFF0 <> 0) Then Begin
		Z_GetHex := ZERROR;
		Exit
	End;
	c := Z_TimedRead;
	If (c < 0) Then Begin
		Z_GetHex := c;
		Exit
	End;
	c := c - $30;										{now the low nybble}
	If (c > 9) Then c := c - 39;
	If (c And $FFF0 <> 0) Then Begin
		Z_GetHex := ZERROR;
		Exit
	End;
	Z_GetHex := (n SHL 4) OR c				{Insert tab 'A' in slot 'B'...}
End;

Function Z_GetHexHeader(Var hdr: hdrtype): Integer;
(* Receives a zmodem hex type header *)
Var
	crc: Integer;
	c, n: Integer;
Begin
	c := Z_GetHex;
	If (c < 0) Then Begin
		Z_GetHexHeader := c;
		Exit
	End;
	rxtype := c;												{get the type Of header}
	crc := UpdCrc(rxtype,0);
	For n := 0 To 3 Do									{get the 4 Bytes}
	Begin
		c := Z_GetHex;
		If (c < 0) Then Begin
			Z_GetHexHeader := c;
			Exit
		End;
		hdr[n] := Lo(c);
		crc := UpdCrc(Lo(c),crc)
	End;
	c := Z_GetHex;
	If (c < 0) Then Begin
		Z_GetHexHeader := c;
		Exit
	End;
	crc := UpdCrc(Lo(c),crc);
	c := Z_GetHex;
	If (c < 0) Then Begin
		Z_GetHexHeader := c;
		Exit
	End;
	crc := UpdCrc(Lo(c),crc);						{check the CRC}
	If (crc <> 0) Then Begin
		Inc(zerrors);
		Z_Errors(zerrors);
		Z_GetHexHeader := ZERROR;
		Exit
	End;
	If (Z_GetByte(1) = 13) Then	c := Z_GetByte(1);   {throw away CR/LF}
	Z_GetHexHeader := rxtype
End;


Function Z_GetBinaryHeader(Var hdr: hdrtype): Integer;
(* Same as above, but binary with 16 bit CRC *)
Var
	crc: Integer;
	c, n: Integer;
Begin
	c := Z_GetZDL;
	If (c < 0) Then Begin
		Z_GetBinaryHeader := c;
		Exit
	End;
	rxtype := c;
	crc := UpdCrc(rxtype,0);
	For n := 0 To 3 Do Begin
		c := Z_GetZDL;
		If (Hi(c) <> 0) Then Begin
			Z_GetBinaryHeader := c;
			Exit
		End;
		hdr[n] := Lo(c);
		crc := UpdCrc(Lo(c),crc)
	End;
	c := Z_GetZDL;
	If (Hi(c) <> 0) Then Begin
		Z_GetBinaryHeader := c;
		Exit
	End;
	crc := UpdCrc(Lo(c),crc);
	c := Z_GetZDL;
	If (Hi(c) <> 0) Then Begin
		Z_GetBinaryHeader := c;
		Exit
	End;
	crc := UpdCrc(Lo(c),crc);
	If (crc <> 0) Then Begin
		Inc(zerrors);
		Z_Errors(zerrors);
		Exit
	End;
	Z_GetBinaryHeader := rxtype
End;


Function Z_GetBinaryHead32(Var hdr: hdrtype): Integer;
(* Same as above but with 32 bit CRC *)
Var
	crc: Long_Integer;
	c, n: Integer;
Begin
	c := Z_GetZDL;
	If (c < 0) Then Begin
		Z_GetBinaryHead32 := c;
		Exit
	End;
	rxtype := c;
	crc := UpdC32(rxtype,$FFFFFFFF);
	For n := 0 To 3 Do Begin
			c := Z_GetZDL;
			If (Hi(c) <> 0) Then Begin
				Z_GetBinaryHead32 := c;
				Exit
			End;
			hdr[n] := Lo(c);
			crc := UpdC32(Lo(c),crc)
	End;
	For n := 0 To 3 Do Begin
			c := Z_GetZDL;
			If (Hi(c) <> 0) Then Begin
				Z_GetBinaryHead32 := c;
				Exit
			End;
			crc := UpdC32(Lo(c),crc)
	End;
	If (crc <> $DEBB20E3) Then	{this is the polynomial value}
	Begin
			Inc(zerrors);
			Z_Errors(zerrors);
			Z_GetBinaryHead32 := ZERROR;
			Exit
	End;
	Z_GetBinaryHead32 := rxtype
End;

Function Z_GetHeader(Var hdr: hdrtype): Integer;
(* Use this routine to get a header - it will figure out	*)
(* what type it is getting (hex, bin16 or bin32) And call *)
(* the appropriate routine.															*)
Label
	gotcan, again, agn2, splat, Done;	{sorry, but it's actually eisier to}
Var																	{follow, And lots more efficient	}
	c, n, cancount: Integer;					{this way...											}
Begin
	n := zbaud * 2;										{A guess at the # Of garbage Characters}
	cancount := 5;										{to expect.														}
	usecrc32 := False;								{assume 16 bit Until proven otherwise	}
again:
	If (KeyPressed) Then							{check For operator panic}
			If (ReadKey = #27) Then				{in the Form Of ESCape	}
			Begin
				Z_SEndCan;															{tell the other End,	}
				Z_message('Cancelled from keyboard');	{the operator,				}
				Z_GetHeader := ZCAN;									{And the rest Of the	}
				Exit																	{routines to Forget it.}
			End;
	rxframeind := 0;
	rxtype := 0;
	c := Z_TimedRead;
	Case c Of
			ZPAD: {we want this! - all headers Begin with '*'.} ;
			RCDo,
			ZTIMEOUT: Goto Done;
			CAN: Begin
gotcan:
							Dec(cancount);
							If (cancount < 0) Then Begin
								c := ZCAN;
								Goto Done
							End;
							c := Z_GetByte(1);
							Case c Of
								ZTIMEOUT: Goto again;
								ZCRCW: Begin
													c := ZERROR;
													Goto Done
												End;
								RCDo: Goto Done;
								CAN: Begin
												Dec(cancount);
												If (cancount < 0) Then Begin
														c := ZCAN;
														Goto Done
												End;
												Goto again
											End
								Else {fallthru}
							End {Case}
					End {can}
			Else
agn2: Begin
				Dec(n);
				If (n < 0) Then Begin
						Inc(zerrors);
						Z_Errors(zerrors);
						Z_message('Header is FUBAR');
						Z_GetHeader := ZERROR;
						Exit
				End;
				If (c <> CAN) Then cancount := 5;
				Goto again
			End
	End;					{only falls thru If ZPAD - anything Else is trash}
	cancount := 5;
splat:
	c := Z_TimedRead;
	Case c Of
			ZDLE: {this is what we want!} ;
			ZPAD: Goto splat;	{junk or second '*' Of a hex header}
			RCDo,
			ZTIMEOUT: Goto Done
			Else Goto agn2
	End; {only falls thru If ZDLE}
	c := Z_TimedRead;
	Case c Of
			ZBIN32: Begin
								rxframeind := ZBIN32;				{using 32 bit CRC}
								c := Z_GetBinaryHead32(hdr)
							End;
			ZBIN: Begin
							rxframeind := ZBIN;						{bin with 16 bit CRC}
							c := Z_GetBinaryHeader(hdr)
						End;
			ZHEX: Begin
							rxframeind := ZHEX;						{hex}
							c := Z_GetHexHeader(hdr)
						End;
			CAN: Goto gotcan;
			RCDo,
			ZTIMEOUT: Goto Done
			Else Goto agn2
	End; {only falls thru If we got ZBIN, ZBIN32 or ZHEX}
	rxpos := Z_PullLongFromHeader(hdr);				{set rxpos just in Case this}
Done:																				{header has file position	}
	Z_GetHeader := c													{info (i.e.: ZRPOS, etc.	)}
End;

(***************************************************)
(* RECEIVE FILE ROUTINES													*)
(***************************************************)

Function RZ_ReceiveDa32(Var buf: buftype; blength: Integer): Integer;
(* Get a 32 bit CRC data block *)
Label
	crcfoo;
Var
	c, d, n: Integer;
	crc: Long_Integer;
	Done: Boolean;
Begin
	usecrc32 := True;
	crc := $FFFFFFFF;
	rxcount := 0;
	Done := False;
	Repeat
			c := Z_GetZDL;
			If (Hi(c) <> 0) Then Begin
crcfoo:	Case c Of
						GOTCRCE,
						GOTCRCG,
						GOTCRCQ,
						GOTCRCW: Begin
												d := c;
												crc := UpdC32(Lo(c),crc);
												For n := 0 TO 3 Do Begin
													c := Z_GetZDL;
													If (Hi(c) <> 0) Then Goto crcfoo;
													crc := UpdC32(Lo(c),crc)
												End;
												If (crc <> $DEBB20E3) Then Begin
													Inc(zerrors);
													Z_Errors(zerrors);
													RZ_ReceiveDa32 := ZERROR
												End
												Else RZ_ReceiveDa32 := d;
												DoNE := True
										End;
						GOTCAN: Begin
											RZ_ReceiveDa32 := ZCAN;
											DoNE := True
										End;
						ZTIMEOUT: Begin
												RZ_ReceiveDa32 := c;
												DoNE := True
											End;
						RCDo: Begin
										RZ_ReceiveDa32 := c;
										Done := True
									End
						Else Begin
							Z_message('Debris');
							Z_ClearInbound;
							RZ_ReceiveDa32 := c;
							DoNE := True
						End
				End
			End;
			If (Not Done) Then Begin
				Dec(blength);
				If (blength < 0) Then Begin
					Z_message('Long packet');
					RZ_ReceiveDa32 := ZERROR;
					Done := True
				End;
				buf[Integer(rxcount)] := Lo(c);
				Inc(rxcount);
				crc := UpdC32(Lo(c),crc)
			End
	Until Done
End;

Function RZ_ReceiveData(Var buf: buftype; blength: Integer): Integer;
(* get a 16 bit CRC data block *)
Label
	crcfoo;
Var
	c, d: Integer;
	crc: Integer;
	Done: Boolean;
Begin
	If (rxframeind = ZBIN32) Then Begin
		Z_ShowCheck(True);
		RZ_ReceiveData := RZ_ReceiveDa32(buf,blength);
		Exit
	End;
	Z_ShowCheck(False);
	crc := 0;
	rxcount := 0;
	Done := False;
	Repeat
			c := Z_GetZDL;
			If (Hi(c) <> 0) Then Begin
crcfoo:	Case c Of
						GOTCRCE,
						GOTCRCG,
						GOTCRCQ,
						GOTCRCW: Begin
												d := c;
												crc := UpdCrc(Lo(c),crc);
												c := Z_GetZDL;
												If (Hi(c) <> 0) Then Goto crcfoo;
												crc := UpdCrc(Lo(c),crc);
												c := Z_GetZDL;
												If (Hi(c) <> 0) Then Goto crcfoo;
												crc := UpdCrc(Lo(c),crc);
												If (crc <> 0) Then Begin
													Inc(zerrors);
													Z_Errors(zerrors);
													RZ_ReceiveData := ZERROR;
													Done := True
												End;
												RZ_ReceiveData := d;
												DoNE := True
										End;
						GOTCAN: Begin
											Z_Message('Got CANned');
											RZ_ReceiveData := ZCAN;
											DoNE := True
										End;
						ZTIMEOUT: Begin
												RZ_ReceiveData := c;
												DoNE := True
											End;
						RCDo: Begin
										Z_Message('Lost carrier');
										RZ_ReceiveData := c;
										Done := True
									End
						Else Begin
							Z_message('Debris');
							Z_ClearInbound;
							RZ_ReceiveData := c;
							DoNE := True
						End
				End
			End;
			If (Not Done) Then Begin
				Dec(blength);
				If (blength < 0) Then Begin
					Z_message('Long packet');
					RZ_ReceiveData := ZERROR;
					Done := True
				End;
				buf[Integer(rxcount)] := Lo(c);
				Inc(rxcount);
				crc := UpdCrc(Lo(c),crc)
			End
	Until Done
End;

Procedure RZ_AckBibi;
(* ACKnowledge the other Ends request to terminate cleanly *)
Var
	n: Integer;
Begin
	Z_PutLong_IntegeroHeader(rxpos);
	n := 4;
	Z_ClearInbound;
	Repeat
			Z_SEndHexHeader(ZFIN,txhdr);
			Case Z_GetByte(20) Of
				ZTIMEOUT,
				RCDo: Exit;
				79: Begin
							If (Z_GetByte(10) = 79) Then {null};
							Z_ClearInbound;
							Exit
						End
				Else Z_ClearInbound;
				Dec(n)
			End
	Until (n <= 0)
End;

Function RZ_InitReceiver: Integer;
Label
	again;
Var
	c, n, errors: Integer;
Begin
	FillChar(attn,SizeOf(attn),0);
	zerrors := 0;
	For n := 10 DoWNTO 0 Do Begin
			If (Not Z_Carrier) Then Begin
				Z_Message('Lost carrier');
				RZ_InitReceiver := ZERROR;
				Exit
			End;
			Z_PutLong_IntegeroHeader(Long_Integer(0));
			txhdr[ZF0] := CANFDX OR CANOVIO OR CANFC32 OR CANBRK; {Full dplx, overlay I/O And CRC32}
			Z_SEndHexHeader(tryzhdrtype,txhdr);
			If (tryzhdrtype = ZSKIP) Then tryzhdrtype := ZRINIT;
again:
				c := Z_GetHeader(rxhdr);
				Z_Frame(c);
				Case c Of
				ZFILE: Begin
									zconv := rxhdr[ZF0];
									tryzhdrtype := ZRINIT;
									c := RZ_ReceiveData(secbuf,ZBUFSIZE);
									Z_Frame(c);
									If (c = GOTCRCW) Then Begin
										RZ_InitReceiver := ZFILE;
										Exit
									End;
									Z_SEndHexHeader(ZNAK,txhdr);
									Goto again
								End;
				ZSINIT: Begin
									c := RZ_ReceiveData(attn,ZBUFSIZE);
									Z_Frame(c);
									If (c = GOTCRCW) Then Z_SEndHexHeader(ZACK,txhdr)
										Else Z_SEndHexHeader(ZNAK,txhdr);
										Goto again
								End;
				ZFREECNT: Begin
										Z_PutLong_IntegeroHeader(DiskFree(0));
										Z_SEndHexHeader(ZACK,txhdr);
										Goto again
									End;
				ZCOMMAnd: Begin
										c := RZ_ReceiveData(secbuf,ZBUFSIZE);
										Z_Frame(c);
										If (c = GOTCRCW) Then Begin
											Z_PutLong_IntegeroHeader(Long_Integer(0));
											Repeat
													Z_SEndHexHeader(ZCOMPL,txhdr);
													Inc(errors)
											Until (errors > 10) OR (Z_GetHeader(rxhdr) = ZFIN);
											RZ_AckBibi;
											RZ_InitReceiver := ZCOMPL;
											Exit
										End;
										Z_SEndHexHeader(ZNAK,txhdr);
										Goto again
									End;
				ZCOMPL,
				ZFIN: Begin
								RZ_InitReceiver := ZCOMPL;
								Exit
							End;
				ZCAN,
				RCDo: Begin
								RZ_InitReceiver := c;
								Exit
							End
			End
	End;
	Z_message('Timeout');
	RZ_InitReceiver := ZERROR
End;

Function RZ_GetHeader: Integer;
Var
	e, p, n, i: Integer;
	multiplier: Long_Integer;
	s: String;
	ttime, tsize: Long_Integer;
	tname: String;
Begin
	isbinary := True;		{Force the issue!}
	fsize := Long_Integer(0);
	p := 0;
	s := '';
	While (p < 255) And (secbuf[p] <> 0) Do Begin
		s := s + UpCase(Chr(secbuf[p]));
		Inc(p)
	End;
	Inc(p);
	(* get rid Of drive & path specIfiers *)
	While (Pos(':',s) > 0) Do Delete(s,1,Pos(':',s));
	While (Pos('\',s) > 0) Do Delete(s,1,Pos('\',s));
	fname := s;

(**** Done with name ****)

	fsize := Long_Integer(0);
	While (p < ZBUFSIZE) And (secbuf[p] <> $20) And (secbuf[p] <> 0) Do Begin
		fsize := (fsize *10) + Ord(secbuf[p]) - $30;
		Inc(p)
	End;
	Inc(p);

(**** Done with size ****)

	s := '';
	While (p < ZBUFSIZE) And (secbuf[p] IN [$30..$37]) Do Begin
		s := s + Chr(secbuf[p]);
		Inc(p)
	End;
	Inc(p);
	ftime := Z_FromUnixDate(s);

(**** Done with time ****)

	If (Z_FindFile(zrxpath+fname,tname,tsize,ttime)) Then Begin
			If (zconv = ZCRESUM) And (fsize > tsize) Then Begin
				filestart := tsize;
				If (Not Z_OpenFile(outfile,zrxpath + fname)) Then Begin
						Z_message('Error opening '+fname);
						RZ_GetHeader := ZERROR;
						Exit
				End;
				If (Not Z_SeekFile(outfile,tsize)) Then Begin
						Z_Message('Error positioning file');
						RZ_GetHeader := ZERROR;
						Exit
				End;
				Z_Message('Recovering')
			End
			Else Begin
				Z_ShowName(fname);
				Z_Message('File is already complete');
				RZ_GetHeader := ZSKIP;
				Exit
			End
	End
	Else Begin
			filestart := 0;
			If (Not Z_MakeFile(outfile,zrxpath + fname)) Then Begin
				Z_message('Unable to create '+fname);
				RZ_GetHeader := ZERROR;
				Exit
			End
	End;
	Z_ShowName(fname);
	Z_ShowSize(fsize);
	Z_ShowTransferTime(fsize,zbaud);
	RZ_GetHeader := ZOK
End;

Function RZ_SaveToDisk(Var rxBytes: Long_Integer): Integer;
Begin
	If (KeyPressed) Then
			If (ReadKey = #27) Then Begin
				Z_message('Aborted from keyboard');
				Z_SEndCan;
				RZ_SaveToDisk := ZERROR;
				Exit
			End;
	If (Not Z_WriteFile(outfile,secbuf,rxcount)) Then Begin
		Z_Message('Disk write error');
		RZ_SaveToDisk := ZERROR
	End
	Else RZ_SaveToDisk := ZOK;
	rxBytes := rxBytes + rxcount
End;

Function RZ_ReceiveFile: Integer;
Label
	err, nxthdr, moredata;
Var
	c, n: Integer;
	rxBytes: Long_Integer;
	sptr: String;
	Done: Boolean;
Begin
	zerrors := 0;
	Done := False;
	eOfseen := False;
	c := RZ_GetHeader;
	If (c <> ZOK) Then Begin
		If (c = ZSKIP) Then tryzhdrtype := ZSKIP;
		RZ_ReceiveFile := c;
		Exit
	End;
	c := ZOK;
	n := 10;
	rxBytes := filestart;
	rxpos := filestart;
	ztime := Z_SetTimer;
	zcps := 0;
	Repeat
		Z_PutLong_IntegeroHeader(rxBytes);
		Z_SEndHexHeader(ZRPOS,txhdr);
nxthdr:
			c := Z_GetHeader(rxhdr);
			Z_Frame(c);
			Case c Of
				ZDATA: Begin
									If (rxpos <> rxBytes) Then Begin
										Dec(n);
										Inc(zerrors);
										Z_Errors(zerrors);
										If (n < 0) Then Goto err;
										Z_message('Bad position');
										Z_PutString(attn)
									End
									Else Begin
moredata:
											c := RZ_ReceiveData(secbuf,ZBUFSIZE);
											Z_Frame(c);
											Case c Of
												ZCAN,
												RCDo: Goto err;
												ZERROR: Begin
																	Dec(n);
																	Inc(zerrors);
																	Z_Errors(zerrors);
																	If (n < 0) Then Goto err;
																	Z_PutString(attn)
																End;
												ZTIMEOUT: Begin
																		Dec(n);
																		If (n < 0) Then Goto err
																	End;
												GOTCRCW: Begin
																		n := 10;
																		c := RZ_SaveToDisk(rxBytes);
																		If (c <> ZOK) Then Begin
																				RZ_ReceiveFile := c;
																				Exit
																		End;
																		Z_ShowLoc(rxBytes);
																		Z_PutLong_IntegeroHeader(rxBytes);
																		Z_SEndHexHeader(ZACK,txhdr);
																		Goto nxthdr
																	End;
												GOTCRCQ: Begin
																		n := 10;
																		c := RZ_SaveToDisk(rxBytes);
																		If (c <> ZOK) Then Begin
																				RZ_ReceiveFile := c;
																				Exit
																		End;
																		Z_ShowLoc(rxBytes);
																		Z_PutLong_IntegeroHeader(rxBytes);
																		Z_SEndHexHeader(ZACK,txhdr);
																		Goto moredata
																	End;
												GOTCRCG: Begin
																		n := 10;
																		c := RZ_SaveToDisk(rxBytes);
																		If (c <> ZOK) Then Begin
																				RZ_ReceiveFile := c;
																				Exit
																		End;
																		Z_ShowLoc(rxBytes);
																		Goto moredata
																	End;
												GOTCRCE: Begin
																		n := 10;
																		c := RZ_SaveToDisk(rxBytes);
																		If (c <> ZOK) Then Begin
																				RZ_ReceiveFile := c;
																				Exit
																		End;
																		Z_ShowLoc(rxBytes);
																		Goto nxthdr
																	End
											End {Case}
									End
								End; {Case Of ZDATA}
				ZNAK,
				ZTIMEOUT: Begin
										Dec(n);
										If (n < 0) Then Goto err;
										Z_ShowLoc(rxBytes)
									End;
				ZFILE: Begin
									c := RZ_ReceiveData(secbuf,ZBUFSIZE);
									Z_Frame(c)
								End;
				ZEOf: If (rxpos = rxBytes) Then Begin
								RZ_ReceiveFile := c;
								Exit
							End
							Else Goto nxthdr;
				ZERROR: Begin
									Dec(n);
									If (n < 0) Then Goto err;
									Z_ShowLoc(rxBytes);
									Z_PutString(attn)
								End
				Else Begin
						c := ZERROR;
						Goto err
				End
			End {Case}
	Until (Not Done);
err:
	RZ_ReceiveFile := ZERROR
End;

Function RZ_ReceiveBatch: Integer;
Var
	s: String;
	c: Integer;
	Done: Boolean;
Begin
	Z_Message('Receiving...');
	Done := False;
	While (Not Done) Do Begin
			If Not (Z_Carrier) Then Begin
				RZ_ReceiveBatch := ZERROR;
				Exit
			End;
			c := RZ_ReceiveFile;
			zcps := fsize DIV (Z_SetTimer - ztime);
			Z_Frame(c);
			Z_SetFTime(outfile,ftime);
			Z_CloseFile(outfile);
			Str(zcps:4,s);
			Z_Message(s+' cps');
			Case c Of
				ZEOf,
				ZSKIP: Begin
									c := RZ_InitReceiver;
									Z_Frame(c);
									Case c Of
											ZFILE: {null};
											ZCOMPL: Begin
																RZ_AckBibi;
																RZ_ReceiveBatch := ZOK;
																Exit
															End;
											Else Begin
												RZ_ReceiveBatch := ZERROR;
												Exit
											End
									End
								End
				Else Begin
					RZ_ReceiveBatch := c;
					Exit
				End
			End {Case}
	End {While}
End;


Function Zmodem_Receive(path: String; comport: Integer; baudrate: Long_Integer): Boolean;
Var
	i: Integer;
Begin
	zbaud := baudrate;
	zport := comport;
	Z_OpenWinDow(TPZVER);
	Z_Message('Initializing...');
	If (Not Z_AsyncOn(comport,baudrate)) Then Begin
		ClrScr;
		WriteLn('Unable to open:');
		WriteLn('Port: ',comport);
		WriteLn('Baud: ',baudrate);
		Delay(2000);
		Z_CloseWinDow;
		Zmodem_Receive := False;
		Exit
	End;
	zrxpath := path;
	If (zrxpath[Length(zrxpath)] <> '\') And (zrxpath <> '') Then
		zrxpath := zrxpath + '\';
	rxtimeout := 100;
	tryzhdrtype := ZRINIT;
	i := RZ_InitReceiver;
	If (i = ZCOMPL) OR ((i = ZFILE) And ((RZ_ReceiveBatch) = ZOK)) Then Begin
		Z_Message('Restoring async params');
		Z_AsyncOff;
		Z_CloseWinDow;
		Zmodem_Receive := True
	End
	Else Begin
		Z_ClearOutbound;
		Z_Message('SEnding CAN');
		Z_SEndCan;
		Z_Message('Restoring async params');
		Z_AsyncOff;
		Z_CloseWinDow;
		Zmodem_Receive := False;
	End
End;

(*######### SEnd ROUTINES #####################################*)


Procedure SZ_Z_SEndByte(b: Byte);
Begin
	If ((b And $7F) IN [16,17,19,24]) OR (((b And $7F) = 13) And ((lastsent And $7F) = 64)) Then
	Begin
		Z_SEndByte(ZDLE);
		lastsent := (b XOR 64)
	End
	Else lastsent := b;
	Z_SEndByte(lastsent)
End;

Procedure SZ_SEndBinaryHead32(htype: Byte; Var hdr: hdrtype);
Var
	crc: Long_Integer;
	n: Integer;
Begin
	Z_SEndByte(ZPAD);
	Z_SEndByte(ZDLE);
	Z_SEndByte(ZBIN32);
	SZ_Z_SEndByte(htype);
	crc := UpdC32(htype,$FFFFFFFF);
	For n := 0 TO 3 Do Begin
		SZ_Z_SEndByte(hdr[n]);
		crc := UpdC32(hdr[n],crc)
	End;
	crc := (Not crc);
	For n := 0 TO 3 Do Begin
		SZ_Z_SEndByte(Byte(crc));
		crc := (crc SHR 8)
	End;
	If (htype <> ZDATA) Then Delay(500)
End;

Procedure SZ_SEndBinaryHeader(htype: Byte; Var hdr: hdrtype);
Var
	crc: Integer;
	n: Integer;
Begin
	If (usecrc32) Then Begin
		SZ_SEndBinaryHead32(htype,hdr);
		Exit
	End;
	Z_SEndByte(ZPAD);
	Z_SEndByte(ZDLE);
	Z_SEndByte(ZBIN);
	SZ_Z_SEndByte(htype);
	crc := UpdCrc(htype,0);
	For n := 0 TO 3 Do Begin
		SZ_Z_SEndByte(hdr[n]);
		crc := UpdCrc(hdr[n],crc)
	End;
	crc := UpdCrc(0,crc);
	crc := UpdCrc(0,crc);
	SZ_Z_SEndByte(Lo(crc SHR 8));
	SZ_Z_SEndByte(Lo(crc));
	If (htype <> ZDATA) Then Delay(500)
End;

Procedure SZ_SEndDa32(Var buf: buftype; blength: Integer; frameEnd: Byte);
Var
	crc: Long_Integer;
	t: Integer;
Begin
	crc := $FFFFFFFF;
	For t := 0 TO (blength - 1) Do Begin
		SZ_Z_SEndByte(buf[t]);
		crc := UpdC32(buf[t],crc)
	End;
	crc := UpdC32(frameEnd,crc);
	crc := (Not crc);
	Z_SEndByte(ZDLE);
	Z_SEndByte(frameEnd);
	For t := 0 TO 3 Do Begin
		SZ_Z_SEndByte(Byte(crc));
		crc := (crc SHR 8)
	End;
	Begin
		Z_SEndByte(17);
		Delay(500)
	End
End;

Procedure SZ_SEndData(Var buf: buftype; blength: Integer; frameEnd: Byte);
Var
	crc: Integer;
	t: Integer;
Begin
	If (usecrc32) Then Begin
		SZ_SEndDa32(buf,blength,frameEnd);
		Exit
	End;
	crc := 0;
	For t := 0 TO (blength - 1) Do Begin
		SZ_Z_SEndByte(buf[t]);
		crc := UpdCrc(buf[t],crc)
	End;
	crc := UpdCrc(frameEnd,crc);
	Z_SEndByte(ZDLE);
	Z_SEndByte(frameEnd);
	crc := UpdCrc(0,crc);
	crc := UpdCrc(0,crc);
	SZ_Z_SEndByte(Lo(crc SHR 8));
	SZ_Z_SEndByte(Lo(crc));
	If (frameEnd = ZCRCW) Then Begin
		Z_SEndByte(17);
		Delay(500)
	End
End;


Procedure SZ_EndSEnd;
Var
	Done: Boolean;
Begin
	Done := False;
	Repeat
			Z_PutLong_IntegeroHeader(txpos);
			SZ_SEndBinaryHeader(ZFIN,txhdr);
			Case Z_GetHeader(rxhdr) Of
				ZFIN: Begin
								Z_SEndByte(Ord('O'));
								Z_SEndByte(Ord('O'));
								Delay(500);
								Z_ClearOutbound;
								Exit
							End;
				ZCAN,
				RCDo,
				ZFERR,
				ZTIMEOUT: Exit
			End {Case}
	Until (Done)
End;

Function SZ_GetReceiverInfo: Integer;
Var
	rxflags, n, c: Integer;
Begin
	Z_Message('Getting info.');
	For n := 1 TO 10 Do Begin
			c := Z_GetHeader(rxhdr);
			Z_Frame(c);
			Case c Of
				ZCHALLENGE: Begin
											Z_PutLong_IntegeroHeader(rxpos);
											Z_SEndHexHeader(ZACK,txhdr)
										End;
				ZCOMMAnd: Begin
										Z_PutLong_IntegeroHeader(Long_Integer(0));
										Z_SEndHexHeader(ZRQINIT,txhdr)
									End;
				ZRINIT: Begin
									rxbuflen := (Integer(rxhdr[ZP1]) SHL 8) OR rxhdr[ZP0];
									usecrc32 := ((rxhdr[ZF0] And CANFC32) <> 0);
									Z_ShowCheck(usecrc32);
									SZ_GetReceiverInfo := ZOK;
									Exit
								End;
				ZCAN,
				RCDo,
				ZTIMEOUT: Begin
										SZ_GetReceiverInfo := ZERROR;
										Exit
									End
				Else If (c <> ZRQINIT) OR (rxhdr[ZF0] <> ZCOMMAnd) Then
					Z_SEndHexHeader(ZNAK,txhdr)
			End {Case}
	End; {For}
	SZ_GetReceiverInfo := ZERROR
End;

Function SZ_SyncWithReceiver: Integer;
Var
	c, num_errs: Integer;
	Done: Boolean;
Begin
	num_errs := 7;
	Done := False;
	Repeat
			c := Z_GetHeader(rxhdr);
			Z_Frame(c);
			Z_ClearInbound;
			Case c Of
				ZTIMEOUT: Begin
										Dec(num_errs);
										If (num_errs < 0) Then Begin
											SZ_SyncWithReceiver := ZERROR;
											Exit
										End
									End;
				ZCAN,
				ZABORT,
				ZFIN,
				RCDo: Begin
								SZ_SyncWithReceiver := ZERROR;
								Exit
							End;
				ZRPOS: Begin
									If (Not Z_SeekFile(infile,rxpos)) Then Begin
										Z_Message('File seek error');
										SZ_SyncWithReceiver := ZERROR;
										Exit
									End;
									Z_Message('Repositioning...');
									Z_ShowLoc(rxpos);
									txpos := rxpos;
									SZ_SyncWithReceiver := c;
									Exit
								End;
				ZSKIP,
				ZRINIT,
				ZACK: Begin
								SZ_SyncWithReceiver := c;
								Exit
							End
				Else Begin
					Z_Message('I dunno what happened!');
					SZ_SEndBinaryHeader(ZNAK,txhdr)
				End
			End {Case}
	Until (Done)
End;


Function SZ_SEndFileData: Integer;
Label
	waitack, somemore, oops;
Var
	c, e: Integer;
	newcnt, blklen, blkred, maxblklen, goodblks, goodneeded: Integer;
Begin
	Z_Message('SEnding file...');
	goodneeded := 1;
	If (zbaud < 300) Then maxblklen := 128
	Else maxblklen := (Integer(zbaud) DIV 300) * 256;
	If (maxblklen > ZBUFSIZE) Then maxblklen := ZBUFSIZE;
	If (rxbuflen > 0) And (rxbuflen < maxblklen) Then maxblklen := rxbuflen;
	blklen := maxblklen;
	ztime := Z_SetTimer;
somemore:
	If (Z_CharAvail) Then Begin
WaitAck:
			c := SZ_SyncWithReceiver;
			Z_Frame(c);
			Case c Of
				ZSKIP: Begin
									SZ_SEndFileData := ZSKIP;
									Exit
								End;
				ZACK: {null};
				ZRPOS: Begin
									Inc(zerrors);
									Z_Errors(zerrors);
									If ((blklen SHR 2) > 32) Then blklen := (blklen SHR 2)
									Else blklen := 32;
									goodblks := 0;
									goodneeded := (goodneeded SHL 1) OR 1
								End;
				ZRINIT: Begin
									SZ_SEndFileData := ZOK;
									Exit
								End
				Else Begin
						SZ_SEndFileData := ZERROR;
						Exit
				End
			End {Case};
			While (Z_CharAvail) Do Begin
				Case (Z_GetByte(1)) Of
						CAN,
						ZPAD: Goto waitack;
						RCDo: Begin
										SZ_SEndFileData := ZERROR;
										Exit
									End
				End {Case}
			End
	End; {If Char avail}
	newcnt := rxbuflen;
	Z_PutLong_IntegeroHeader(txpos);
	SZ_SEndBinaryHeader(ZDATA,txhdr);
	Z_Message('SEnding data header');
	Repeat
			If (KeyPressed) Then
				If (ReadKey = #27) Then Begin
					Z_Message('Aborted from keyboard');
					Z_SEndCan;
					Goto oops
				End;
			If (Not Z_Carrier) Then Goto oops;
			If (Not Z_ReadFile(infile,txbuf,blklen,blkred)) Then Begin
				Z_Message('Error reading disk');
				Z_SEndCan;
				Goto oops
			End;
			If (blkred < blklen) Then e := ZCRCE
			Else If (rxbuflen <> 0) And ((newcnt - blkred) <= 0) Then Begin
				newcnt := (newcnt - blkred);
				e := ZCRCW
			End
			Else e := ZCRCG;
			SZ_SEndData(txbuf,blkred,e);
			txpos := txpos + blkred;
			Z_ShowLoc(txpos);
			Inc(goodblks);
			If (blklen < maxblklen) And (goodblks > goodneeded) Then Begin
				If ((blklen SHL 1) < maxblklen) Then blklen := (blklen SHL 1)
				Else blklen := maxblklen;
				goodblks := 0
			End;
			If (e = ZCRCW) Then Goto waitack;
			While (Z_CharAvail) Do Begin
				Case Z_GetByte(1) Of
						CAN,
						ZPAD: Begin
										Z_Message('Trouble?');
										Z_ClearOutbound;
										SZ_SEndData(txbuf,0,ZCRCE);
										Goto waitack
									End;
						RCDo: Begin
										SZ_SEndFileData := ZERROR;
										Exit
									End
				End {Case}
			End {While}
	Until (e <> ZCRCG);
	Repeat
		Z_PutLong_IntegeroHeader(txpos);
		Z_Message('SEnding EOf');
		SZ_SEndBinaryHeader(ZEOf,txhdr);
		c := SZ_SyncWithReceiver;
		Case c Of
			ZACK: {null};
			ZRPOS: Goto somemore;
			ZRINIT: Begin
								SZ_SEndFileData := ZOK;
								Exit
							End;
			ZSKIP: Begin
								SZ_SEndFileData := c;
								Exit
							End
			Else
oops:	Begin
				SZ_SEndFileData := ZERROR;
				Exit
			End
		End {Case}
	Until (c <> ZACK)
End;

Function SZ_SEndFile: Integer;
Var
	c: Integer;
	Done: Boolean;
Begin
	zerrors := Integer(0);
	Done := False;
	Repeat
			If (KeyPressed) Then
				If (ReadKey = #27) Then Begin
					Z_SEndCan;
					Z_Message('Aborted from keyboard');
					SZ_SEndFile := ZERROR;
					Exit
				End;
			If (Not Z_Carrier) Then Begin
				Z_Message('Lost carrier');
				SZ_SEndFile := ZERROR;
				Exit
			End;
			FillChar(txhdr,4,0);
			txhdr[ZF0] := ZCRESUM; {recover}
			SZ_SEndBinaryHeader(ZFILE,txhdr);
			SZ_SEndData(txbuf,ZBUFSIZE,ZCRCW);
			Repeat
				c := Z_GetHeader(rxhdr);
				Z_Frame(c);
				Case c Of
						ZCAN,
						RCDo,
						ZTIMEOUT,
						ZFIN,
						ZABORT: Begin
											SZ_SEndFile := ZERROR;
											Exit
										End;
						ZRINIT: {null - this will cause a loopback};
						ZCRC: Begin
										Z_PutLong_IntegeroHeader(Z_FileCRC32(infile));
										Z_SEndHexHeader(ZCRC,txhdr)
									End;
						ZSKIP: Begin
											SZ_SEndFile := c;
											Exit
										End;
						ZRPOS: Begin
										If (Not Z_SeekFile(infile,rxpos)) Then Begin
											Z_Message('File positioning error');
											Z_SEndHexHeader(ZFERR,txhdr);
											SZ_SEndFile := ZERROR;
											Exit
										End;
										Z_Message('Setting start position');
										Z_ShowLoc(rxpos);
										strtpos := rxpos;
										txpos := rxpos;
										SZ_SEndFile := SZ_SEndFileData;
										Exit
									End
				End {Case}
			Until (c <> ZRINIT)
	Until (Done)
End;

Function Zmodem_SEnd(pathname: String; lastfile: Boolean; comport: Integer; baudrate: Long_Integer): Boolean;

Var
	s: String;
	n: Integer;
Begin
	zerrors := 0;
	zbaud := baudrate;
	zport := comport;
	Z_OpenWinDow(TPZVER);
	If (Not Z_AsyncOn(comport,baudrate)) Then Begin
		Z_Message('Unable to open port');
		Delay(2000);
		Z_CloseWinDow;
		Zmodem_SEnd := False;
		Exit
	End;
	If (Not Z_Carrier) Then Begin
		Z_Message('Lost carrier');
		Delay(2000);
		Z_CloseWinDow;
		Z_AsyncOff;
		Zmodem_SEnd := False;
		Exit
	End;
	If (Not Z_FindFile(pathname,fname,fsize,ftime)) Then Begin
		Z_Message('Unable to find/open file');
		SZ_EndSEnd;
		Z_CloseWinDow;
		Z_AsyncOff;
		Zmodem_SEnd := False;
		Exit
	End;
	Z_ShowName(fname);
	Z_ShowSize(fsize);
	Z_ShowTransferTime(fsize,zbaud);
	Str(fsize,s);
	s := (fname + #0 + s + ' ');
	s := s + Z_ToUnixDate(ftime);
	n := Length(s);
	For n := 1 TO Length(s) Do Begin
		If (s[n] IN ['A'..'Z']) Then s[n] := Chr(Ord(s[n]) + $20)
	End;
	FillChar(txbuf,ZBUFSIZE,0);
	Move(s[1],txbuf[0],Length(s));
	If (zbaud > 0) Then rxtimeout := Integer(614400 DIV zbaud)
	Else rxtimeout := 100;
	If (rxtimeout < 100) Then rxtimeout := 100;
	attn[0] := Ord('r');
	attn[1] := Ord('z');
	attn[3] := 13;
	attn[4] := 0;
	Z_PutString(attn);
	FillChar(attn,SizeOf(attn),0);
	Z_PutLong_IntegeroHeader(Long_Integer(0));
	Z_Message('SEnding ZRQINIT');
	Z_SEndHexHeader(ZRQINIT,txhdr);
	If (SZ_GetReceiverInfo = ZERROR) Then Begin
		Z_CloseWinDow;
		Z_AsyncOff;
		Zmodem_SEnd := False;
		Exit
	End;
	If (Not Z_OpenFile(infile,pathname)) Then
	If (IOresult <> 0) Then Begin
		Z_Message('Failure to open file');
		Z_SEndCan;
		Z_CloseWinDow;
		Z_AsyncOff;
		Zmodem_SEnd := False;
		Exit
	End;
	n := SZ_SEndFile;
	zcps := (fsize DIV (Z_SetTimer - ztime));
	Z_CloseFile(infile);
	Z_Frame(n);
	Str(zcps:4,s);
	Z_Message(s+' cps');
	If (n = ZOK) And (lastfile) Then SZ_EndSEnd
	Else Z_SEndCan;
	Z_CloseWinDow;
	Z_AsyncOff;
	Zmodem_SEnd := True
End;
End.

