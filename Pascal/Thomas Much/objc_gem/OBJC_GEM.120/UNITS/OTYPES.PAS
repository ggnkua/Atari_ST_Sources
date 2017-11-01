{**************************************
 *  O b j e c t G E M   Version 1.20  *
 *  Copyright 1992-94 by Thomas Much  *
 **************************************
 *         Unit  O T Y P E S          *
 **************************************
 *    Softdesign Computer Software    *
 *    Thomas Much, Gerwigstraûe 46,   *
 *  76131 Karlsruhe, (0721) 62 28 41  *
 *         Thomas Much @ KA2          *
 *  UK48@ibm3090.rz.uni-karlsruhe.de  *
 **************************************
 *    erstellt am:        13.07.1992  *
 *    letztes Update am:  29.10.1994  *
 **************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

  ObjectGEM wird mit dem _vollstÑndigen_ Quelltext ausgeliefert, d.h.
  jeder kann sich die Unit selbst compilieren, womit die extrem lÑstigen
  KompatibilitÑtsprobleme mit den PP-Releases beseitigt sind.
  ObjectGEM ist und bleibt aber trotzdem SHAREWARE, d.h. wer die Biblio-
  thek regelmÑûig benutzt, muû sich REGISTRIEREN lassen. DafÅr gibt es
  die neueste Version und - gegen einen geringen Aufpreis - auch ein
  gedrucktes Handbuch.

  WICHTIG: Wer den Quelltext verÑndert und dann Probleme beim Compilieren,
  AusfÅhren o.Ñ. hat, kann nicht damit rechnen, daû ich den Fehler suche;
  tritt der Fehler allerdings auch mit dem Original-Quelltext auf, wÅrde
  ich mich Åber eine genaue Fehlerbeschreibung freuen. VerÑnderte Quell-
  texte dÅrfen _nicht_ weitergegeben werden, dies wÑre ein Verstoû gegen
  das Copyright!

  Wer beim Durchstîbern des Textes auf vermeintliche Fehler oder verbesse-
  rungswÅrdige Stellen trifft (von letzterem gibt es sicherlich noch viele),
  kann mir dies gerne mitteilen - ich habe auch ich nichts gegen kostenlos
  zur VerfÅgung gestellte optimierte Routinen (sofern sich jemand die MÅhe
  macht). Wer in anderen Projekten, die nicht in direkter Konkurrenz zu
  ObjectGEM stehen, einzelne Routinen verwenden mîchte, wendet sich bitte
  an mich (ein solcher Austausch sollte kein Problem sein).

  Wer sich auf nicht dokumentierte "implementation"- oder "private"-Eigen-
  schaften verlÑût, darf sich nicht Åber InkompatibilitÑten zu spÑteren
  Versionen wundern; wer meint, eine DokumentationslÅcke entdeckt zu haben,
  kann mir dies gerne mitteilen.

  Kleine Info zum Schluû: Als "default tabsize" verwende ich 2. Wer drei
  Punkte ("...") im Quelltext entdeckt, hat eine Stelle gefunden, an der
  ich z.Z. arbeite ;-)

  "Mîge die OOP mit Euch sein!"
}


{$IFDEF DEBUG}
	{$B+,D+,G-,I-,L+,N-,P-,Q+,R+,S+,T-,V-,X+,Z-}
{$ELSE}
	{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}
{$ENDIF}

unit OTypes;

interface

uses

	Gem;

const

	GOVersion             = $0120;
	GODate                = $10291994;

	em_OK                 =     0;
	em_OutOfMemory        =    -1;
	em_InvalidWindow      =    -4;
	em_InvalidMainWindow  =    -5;
	em_AccInitFailure     =   -10;
	em_GEMInitFailure     =   -11;
	em_AESNotActive       =   -12;
	em_RscNotFound        =   -13;
	em_WOpenFailure       =   -20;
	em_WCloseFailure      =   -21;
	em_WDestroyFailure    =   -22;
	em_InvalidMenu        =   -30;
	em_InvalidDialog      =   -31;
	em_InvalidToolbar     =   -32;
	em_SpeedoLoadFailure  =   -40;
	em_Terminate          =   -98;
	em_Quit               =   -99;

	as_LoadFonts          =     1;
	as_GrowShrink         =     2;
	as_MenuSeparator      =     4;
	as_MoveDials          =     8;
	as_MoveTransparent    =    16 or as_MoveDials;
	as_Rubbox             =    32;
	as_HandleShutdown     =    64;
	as_3DFlags            =   128;
	as_XInputMode         =   256;
	as_DesktopWindow      =   512;  { ... }
	as_UseHomeDir         =  1024;

	ws_NoWindow           =     1;
	ws_Created            =     2;
	ws_Open               =     3;

	ws_ex_Modeless        =     1;
	ws_ex_TryModeless     =     2 or ws_ex_Modeless;
	ws_ex_AppModal        =     4;  { ... }
	ws_ex_Popup           =     8;
	ws_ex_Center          =    16;
	ws_ex_CenterOnce      =    32 or ws_ex_Center;
	ws_ex_Center2Parent   =    64 or ws_ex_Center;
	ws_ex_MoveDial        =   128;
	ws_ex_MoveTransparent =   256 or ws_ex_MoveDial;
	ws_ex_Disabled        =   512;
	ws_ex_LoadFonts       =  1024;
	ws_ex_ReadOnly        = 32768;

	cs_ByteAlignClient    =     1;
	cs_ByteAlignWindow    =     2;
	cs_VerAlignClient     =     4;
	cs_VerAlignWindow     =     8;
	cs_FullRedraw         =    16;
	cs_SaveBits           =    32;
	cs_Rubbox             =    64;
	cs_WorkBackground     =   128;
	cs_DblClks            =   256;
	cs_CreateOnAccOpen    =   512;
	cs_CancelOnClose      =  1024;
	cs_AutoCreate         =  2048;
	cs_AutoOpen           =  4096;
	cs_ToolbarOpposite    =  8192;
	cs_QuitOnClose        = 16384;
	cs_WindowMenuToolbar  = 32768;
	cs_HRedraw            =     cs_FullRedraw;
	cs_VRedraw            =     cs_FullRedraw;

	tf_GetData            =     0;
	tf_SetData            =     1;
	tf_SizeData           =     2;

	wb_Transfer           =     1;
	wb_Lazy               =     2;

	cs_CheckBox           =     1;
	cs_AutoCheckBox       =     cs_CheckBox;
	cs_3State             =     2 or cs_CheckBox;
	cs_Auto3State         =     cs_3State;
	cs_RadioButton        =     4;
	cs_AutoRadioButton    =     cs_RadioButton;
	cs_PushButton         =     8;
	cs_GroupBox           =    16;
	cs_Static             =    32;
	cs_Edit               =    64;
	cs_ScrollBar          =   128;
	cs_ComboBox           =   256;
	cs_Notepad            =   512; { ... }
	cs_ListBox            =  1024; { ... }

	es_ASCIIOnly          =  2048;
	es_Undo               =  4096;
	es_MultiLine          =  8192;  { ... }

	bs_DefPushButton      =  2048;

	gbs_SmallFont         =  2048;  { ... }
	gbs_Center            =  4096;  { ... }
	gbs_Alert             =  8192;  { ... }
	gbs_Raised            = 16384;  { ... }
	gbs_Recessed          = 32768;  { default... }

	sbs_Horz              =  2048;
	sbs_Vert              =  4096;

	sts_Fill              =  2048;

	scs_BitbltScrolling   =     1;

	bf_Unchecked          =     1;
	bf_Checked            =     2;
	bf_Grayed             =     3;
	bf_Enabled            =     4;
	bf_Disabled           =     5;

	id_Scan               =    -2;  { ... }
	id_NewHandle          =    -1;
	id_No                 =    -1;
	id_OK                 =     0;
	id_Cancel             =     1;
	id_Help               =     2;
	id_Undo               =     3;
	id_Esc                =     4;
	id_NoExit             =    42;

	es_KeyMenu            =     1;
	es_Icon               =     2;
	es_Popup              =     4;
	es_Toolbar            =     8;

	coIndexError          =    -1;
	coOverflow            =    -2;

	MaxCollectionSize     = maxlongint div sizeof(pointer);

	vsOK                  =     0;
	vsSyntax              =     1;

	voFill                = $0001;
	voNotEmpty            = $0002;
	voOnAppend            = $0004;
	voOnEdit              = $0008;
	voReserved            = $00f0;


	K_NORMAL              = $0000;
	K_SHIFT               = K_LSHIFT or K_RSHIFT;

	KsCAPS                = $0010;
	KsALT                 = $0008;
	KsCONTROL             = $0004;
	KsSHIFT               = $0003;
	KsLSHIFT              = $0002;
	KsRSHIFT              = $0001;
	KsNORMAL              = $0000;

	KbSCAN                = $8000;
	KbNUM                 = $4000;
	KbALT                 = $0800;
	KbCONTROL             = $0400;
	KbLSHIFT              = $0200;
	KbRSHIFT              = $0100;
	KbISO                 = $0037;

	KbF1                  = $003b;
	KbF2                  = $003c;
	KbF3                  = $003d;
	KbF4                  = $003e;
	KbF5                  = $003f;
	KbF6                  = $0040;
	KbF7                  = $0041;
	KbF8                  = $0042;
	KbF9                  = $0043;
	KbF10                 = $0044;

	KbF11                 = $0054;
	KbF12                 = $0055;
	KbF13                 = $0056;
	KbF14                 = $0057;
	KbF15                 = $0058;
	KbF16                 = $0059;
	KbF17                 = $005a;
	KbF18                 = $005b;
	KbF19                 = $005c;
	KbF20                 = $005d;

	KbAlt1                = $0078;
	KbAlt2                = $0079;
	KbAlt3                = $007a;
	KbAlt4                = $007b;
	KbAlt5                = $007c;
	KbAlt6                = $007d;
	KbAlt7                = $007e;
	KbAlt8                = $007f;
	KbAlt9                = $0080;
	KbAlt0                = $0081;

	KbUNDO                = $0061;
	KbHELP                = $0062;
	KbINSERT              = $0052;
	KbHOME                = $0047;
	KbUP                  = $0048;
	KbDOWN                = $0050;
	KbLEFT                = $004b;
	KbRIGHT               = $004d;


	USA                   =     0;
	FRG                   =     1;
	FRA                   =     2;
	UK                    =     3;
	SPA                   =     4;
	ITA                   =     5;
	SWE                   =     6;
	SWF                   =     7;
	SWG                   =     8;
	TUR                   =     9;
	FIN                   =    10;
	NOR                   =    11;
	DEN                   =    12;
	SAU                   =    13;
	HOL                   =    14;
	CZE                   =    15;
	HUN                   =    16;

	SIGNULL               =     0;
	SIGHUP                =     1;
	SIGINT                =     2;
	SIGQUIT               =     3;
	SIGILL                =     4;
	SIGTRAP               =     5;
	SIGABRT               =     6;
	SIGPRIV               =     7;
	SIGFPE                =     8;
	SIGKILL               =     9;
	SIGBUS                =    10;
	SIGSEGV               =    11;
	SIGSYS                =    12;
	SIGPIPE               =    13;
	SIGALRM               =    14;
	SIGTERM               =    15;
	SIGSTOP               =    17;
	SIGTSTP               =    18;
	SIGCONT               =    19;
	SIGCHLD               =    20;
	SIGTTIN               =    21;
	SIGTTOU               =    22;
	SIGXCPU               =    24;
	SIGWINCH              =    28;
	SIGUSR1               =    29;
	SIGUSR2               =    30;
	SIG_DFL               = pointer(0);
	SIG_IGN               = pointer(1);

	NUL                   =     0;
	EOS                   =     0;
	SOH                   =     1;
	STX                   =     2;
	ETX                   =     3;
	EOT                   =     4;
	ENQ                   =     5;
	ACK                   =     6;
	BEL                   =     7;
	BS                    =     8;
	HT                    =     9;
	LF                    =    10;
	VT                    =    11;
	FF                    =    12;
	CR                    =    13;
	SO                    =    14;
	SI                    =    15;
	DLE                   =    16;
	DC1                   =    17;
	DC2                   =    18;
	DC3                   =    19;
	DC4                   =    20;
	NAK                   =    21;
	SYN                   =    22;
	ETB                   =    23;
	CAN                   =    24;
	EM                    =    25;
	SUB                   =    26;
	ESC                   =    27;
	FS                    =    28;
	GS                    =    29;
	RS                    =    30;
	US                    =    31;
	SP                    =    32;
	DEL                   =   127;


	DESK                  =     0;
	CLIP_ON               =     1;
	CLIP_OFF              =     0;
	PER_ON                =     1;
	PER_OFF               =     0;
	ME_DRAW               =     1;
	ME_ERASE              =     0;
	ME_INQUIRE            =    -1;
	ME_CHECK              =     1;
	ME_UNCHECK            =     0;
	ME_DISABLE            =     0;
	ME_ENABLE             =     1;
	ME_NORMAL             =     1;
	ME_INVERT             =     0;
	FF_STAND              =     1;
	FF_DEVSPEC            =     0;
	POP_LEFTOP            =     0;
	POP_CENTER            =     1;
	AT_TIMER              =     0;
	AT_BUTTON             =     1;
	AT_MOUSE              =     2;
	AT_KEYBD              =     3;
	NO_ICON               =     0;
	NOTE                  =     1;
	WAIT                  =     2;
	STOP                  =     3;
	NDC                   =     0;
	RC                    =     2;

	PROTO_XACC            =     1;
	PROTO_AV              =     2;

	HSLIDER               = LFARROW or RTARROW or HSLIDE;
	VSLIDER               = UPARROW or DNARROW or VSLIDE;
	SLIDER                = HSLIDER or VSLIDER;


	WF_OWNER              =    20;  { Achtung: Die Konstanten in diesem Block }
	WF_BEVENT             =    24;  {          sollten irgendwann mal in der  }
	WF_BOTTOM             =    25;  {          Unit GEM zu finden sein...     }
	AP_DRAGDROP           =    63;
	CT_KEY                =    53;
	RESCH_COMPLETED       =    61;
	SH_WDRAW              =    72;
	CH_EXIT               =    90;
	DD_OK                 =     0;
	DD_NAK                =     1;
	DD_EXT                =     2;
	DD_LEN                =     3;
	DD_TRASH              =     4;
	DD_PRINTER            =     5;
	DD_CLIPBOARD          =     6;
	DD_TIMEOUT            =  4000;
	DD_NUMEXTS            =     8;
	DD_EXTSIZE            =    32;
	DD_NAMEMAX            =   128;
	DD_HDRMAX             =     8+DD_NAMEMAX;
	FL3DMASK              = $0600;
	FL3DNONE              = $0000;
	FL3DIND               = $0200;
	FL3DBAK               = $0400;
	FL3DACT               = $0600;
	LK3DIND               =     1;
	LK3DAKT               =     2;
	INDBUTCOL             =     3;
	ACTBUTCOL             =     4;
	BACKGRCOL             =     5;
	AD3DVAL               =     6;
	WF_ICONIFY            =    26;
	WF_UNICONIFY          =    27;
	WF_UNICONIFYXYWH      =    28;
	WF_TOOLBAR            =    30;
	WF_FTOOLBAR           =    31;
	WF_NTOOLBAR           =    32;
	WM_BOTTOMED           =    33;
	WM_ICONIFY            =    34;
	WM_UNICONIFY          =    35;
	WM_ALLICONIFY         =    36;
	WM_TOOLBAR            =    37;
	WM_SHADED             = 22360;
	WM_UNSHADED           = 22361;
	BACKDROP              = $2000;
	SMALLER               = $4000;
	GDOS_PROP             =     0;
	GDOS_MONO             =     1;
	GDOS_BITM             =     2;
	M_SAVE                =   258;
	M_LAST                =   259;
	M_RESTORE             =   260;


	IDC_ARROW             =     0;
	IDC_IBEAM             =     1;
	IDC_CROSS             =     5;
	IDC_WAIT              =   100;
	IDC_LOAD              =   101;
	IDC_HELP              =   102;
	IDC_PENCIL            =   103;
	IDC_RUBBER            =   104;
	IDC_SCISSORS          =   105;
	IDC_PASTE             =   106;
	IDC_SLICE1            =   107;
	IDC_SLICE2            =   108;
	IDC_SLICE3            =   109;
	IDC_SLICE4            =   110;
	HOURGLASS             =   IDC_WAIT;

	ACC_ID                =  $400;
	ACC_OPEN              =  $401;
	ACC_CLOSE             =  $402;
	ACC_ACC               =  $403;
	ACC_EXIT              =  $404;
	ACC_ACK               =  $500;
	ACC_TEXT              =  $501;
	ACC_KEY               =  $502;
	ACC_META              =  $503;
	ACC_IMG               =  $504;
	ACC_SPECIAL           =  $800;

	WM_SAVE               = $1000;
	WM_SAVEAS             = $1001;
	WM_PRINT              = $1002;
	WM_UNDO               = $1003;
	WM_CUT                = $1004;
	WM_COPY               = $1005;
	WM_PASTE              = $1006;
	WM_SELECTALL          = $1007;
	WM_FIND               = $1008;
	WM_REPLACE            = $1009;
	WM_FINDNEXT           = $100a;
	WM_HELP               = $100b;
	WM_DELETE             = $100c;

	AV_PROTOKOLL          = $4700;
	VA_PROTOSTATUS        = $4701;
	AV_GETSTATUS          = $4703;
	AV_STATUS             = $4704;
	VA_SETSTATUS          = $4705;
	AV_SENDKEY            = $4710;
	VA_START              = $4711;
	AV_ASKFILEFONT        = $4712;
	VA_FILEFONT           = $4713;
	AV_ASKCONFONT         = $4714;
	VA_CONFONT            = $4715;
	AV_ASKOBJECT          = $4716;
	VA_OBJECT             = $4717;
	AV_OPENCONSOLE        = $4718;
	VA_CONSOLEOPEN        = $4719;
	AV_OPENWIND           = $4720;
	VA_WINDOPEN           = $4721;
	AV_STARTPROG          = $4722;
	VA_PROGSTART          = $4723;
	AV_ACCWINDOPEN        = $4724;
	VA_DRAGACCWIND        = $4725;
	AV_ACCWINDCLOSED      = $4726;
	AV_COPY_DRAGGED       = $4728;
	VA_COPY_COMPLETE      = $4729;
	AV_PATH_UPDATE        = $4730;
	AV_WHAT_IZIT          = $4732;
	VA_THAT_IZIT          = $4733;
	AV_DRAG_ON_WINDOW     = $4734;
	VA_DRAG_COMPLETE      = $4735;
	AV_EXIT               = $4736;

	VA_OB_UNKNOWN         =     0;
	VA_OB_TRASHCAN        =     1;
	VA_OB_SHREDDER        =     2;
	VA_OB_CLIPBOARD       =     3;
	VA_OB_FILE            =     4;
	VA_OB_FOLDER          =     5;
	VA_OB_DRIVE           =     6;
	VA_OB_WINDOW          =     7;

	MSG_SETSTATUS         =     1;
	MSG_START             =     2;
	MSG_SENDKEY           =     1;
	MSG_ASKFILEFONT       =     2;
	MSG_ASKCONFONT        =     4;
	MSG_ASKOBJECT         =     8;
	MSG_OPENWIND          =    16;
	MSG_STARTPROG         =    32;
	MSG_ACCWINDOPEN       =    64;
	MSG_STATUS            =   128;
	MSG_COPY_DRAGGED      =   256;
	MSG_PATH_UPDATE       =   512;
	MSG_EXIT              =  1024;

	SC_CHANGED            = $0050;

	SCF_INDEF             = $0000;
	SCF_DBASE             = $0001;
	SCF_TEXT              = $0002;
	SCF_VECTOR            = $0004;
	SCF_RASTER            = $0008;
	SCF_SHEET             = $0010;
	SCF_SOUND             = $0020;

	GO_PRIVATE            = $1235;

	GOP_GETVERSION        =     0;
	GOP_TOOLBAR           =     1;
	GOP_SETQUIT           =     2;
	GOP_VERSION           = $7fff;

	KOBOLD_JOB            = $2f10;
	KOBOLD_JOB_NO_WINDOW  = $2f11;
	KOBOLD_ANSWER         = $2f12;
	KOBOLD_CONFIG         = $2f13;
	KOBOLD_FIRST_SLCT     = $2f14;
	KOBOLD_NEXT_SLCT      = $2f15;
	KOBOLD_CLOSE          = $2f16;
	KOBOLD_FREE_DRIVES    = $2f17;

	VIEW_FILE             = $5600;
	VIEW_FAILED           = $5601;
	VIEW_OPEN             = $5602;
	VIEW_CLOSED           = $5603;
	VIEW_DATA             = $5604;
	VIEW_GETMFDB          = $5610;	VIEW_SETMFDB          = $5611;	VIEW_MFDB             = $5612;

	VIEWERR_ERROR         =     0;
	VIEWERR_SIZE          =     1;
	VIEWERR_COLOR         =     2;
	VIEWERR_WID           =     3;
	VIEWERR_MEM           =     4;

	HexArray: array [0..15] of char =
							('0','1','2','3','4','5','6','7',
								'8','9','a','b','c','d','e','f');

type

	THandle               = longint;
	HWnd                  = THandle;
	HCursor               = THandle;
	HBrush                = THandle;
	Bool                  = word;

	PStr                  = PChar;
	PString               = ^string;
	PBool                 = ^Bool;
	PByte                 = ^byte;
	PWord                 = ^word;
	PShort                = ^shortint;
	PInteger              = ^integer;
	PLongint              = ^longint;
	PBoolean              = ^boolean;
	PPointer              = ^pointer;
	PTree                 = AESTreePtr;
	PObj                  = AESOBJECTPtr;

	PPipearray            = ^Pipearray;
	Pipearray             = ARRAY_8;

	PGRECT                = ^GRECT;
	GRECT                 = record
		case integer of
			0: (g_x,g_y,g_w,g_h    : integer);
			1: (X,Y,W,H,X1,Y1,X2,Y2: integer);
			2: (A1,A2              : ARRAY_4)
	end;

	PCookieID             = ^TCookieID;
	TCookieID             = array [0..3] of char;

	PCookie               = ^TCookie;
	TCookie               = record
		ID:  TCookieID;
		Val: longint
	end;

	PMetaInfo             = ^TMetaInfo;
	TMetaInfo             = record
		Version: string;
		Drives : longint
	end;

	PItemList             = ^TItemList;
	TItemList             = array [0..MaxCollectionSize-1] of pointer;

	PIterationProc        = ^IterationProc;
	IterationProc         = procedure(p: pointer);

	PIterationFunc        = ^IterationFunc;
	IterationFunc         = function(p: pointer): boolean;

	PXBRA                 = ^XBRA;
	XBRA                  = record
		xb_magic,
		xb_id    : array [0..3] of char;
		xb_oldvec: pointer
	end;

	PINFOXSSI             = ^INFOXSSI;
	INFOXSSI              = record
		id       : longint;
		version  : word;
		save_stat,
		prg_stat : integer;
		vec_stat : longint
	end;

	PAPPLRECORD           = ^APPLRECORD;
	APPLRECORD            = record
		Typ: longint;
		What: record
		case boolean of
			false: (Long: longint);
			true:  (Hi,Lo: word)
		end
	end;

	PWordRec              = ^WordRec;
	WordRec               = record
		Hi,Lo: byte
	end;

	PLongRec              = ^LongRec;
	LongRec               = record
		Hi,Lo: word
	end;

	PMenuEntry = ^TMenuEntry;
	TMenuEntry = record
		Entry,
		Title: integer
	end;

	PMenuEntries = ^TMenuEntries;
	TMenuEntries = record
		Close,
		Print,
		Cut,
		Copy,
		Paste,
		Delete,
		SelectAll,
		Quit,
		Full,
		Cycle    : TMenuEntry
	end;

	PWndClass             = ^TWndClass;
	TWndClass             = record
		Style        : word;
		hCursor      : HCursor;
		hbrBackground: HBrush;
		MenuTree,
		ToolbarTree  : PTree;
		lpszClassName: PString
	end;

	PIconWndClass         = ^TIconWndClass;
	TIconWndClass         = record
		hCursor      : HCursor;
		hbrBackground: HBrush
	end;

	PPaintStruct          = ^TPaintStruct;
	TPaintStruct          = record
		fErase : boolean;
		feColor: HBrush;
		rcPaint: GRECT
	end;

	PScrollBarTransferRec = ^TScrollBarTransferRec;
	TScrollBarTransferRec = record
		LowValue,
		HighValue,
		Position : longint
	end;

	PWindowAttr           = ^TWindowAttr;
	TWindowAttr           = record
		Title,
		SubTitle  : PString;
		RBox      : GRECT;
		Handle    : HWnd;
		gemHandle,
		Status,
		Style,
		sysFonts,
		addFonts,
		charWidth,
		charHeight,
		boxWidth,
		boxHeight : integer;
		ExStyle   : longint
	end;

	PGEMAttr              = ^TGEMAttr;
	TGEMAttr              = record
		EventMask,
		Instance   : integer;
		Style      : longint;
		Country    : word;
		rpTail,
		rpCmd      : PString;
		sysFonts,
		addFonts,
		charSWidth,
		charSHeight,
		boxSWidth,
		boxSHeight,
		charWidth,
		charHeight,
		boxWidth,
		boxHeight,
		MaxPX,
		MaxPY,
		PixW,
		PixH,
		Colors,
		MaxColors,
		Planes     : integer;
		PopChar    : char
	end;

	PAppTypeMR = ^TAppTypeMR;
	TAppTypeMR = string[2];

	PXAccAttr             = ^TXAccAttr;
	TXAccAttr             = record
		Version,
		MsgGroups,
		Protocol   : byte;
		AppTypeMR  : TAppTypeMR;
		AppTypeHR,
		ExtFeatures,
		GenericName,
		Name       : PString;
		apID,
		menuID     : integer;
		AVSrvMsg,
		AVAccMsg   : word;
		pXDSC      : PChar
	end;

	PEventData            = ^TEventData;
	TEventData            = record
		Pipe  : Pipearray;
		mX,
		mY,
		BStat,
		KStat,
		Key,
		Clicks: integer
	end;

	PRsFile               = ^TRsFile;
	TRsFile               = record
		case boolean of
			false: (rsh: RSHDR);
			true:  (rsd: array [0..65535] of byte)
	end;

	PCharSet              = ^TCharSet;
	TCharSet              = set of char;

	PByteArray            = ^TByteArray;
	TByteArray            = array [0..maxlongint-1] of byte;

	PWordArray            = ^TWordArray;
	TWordArray            = array [0..1073741822] of word;

	PPicResult            = ^TPicResult;
	TPicResult            = (prComplete, prIncomplete, prEmpty, prError,
																prSyntax, prAmbiguous, prIncompNoFill);


implementation

end.