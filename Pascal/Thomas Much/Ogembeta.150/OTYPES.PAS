{****************************************
 *   O b j e c t G E M   Version 1.50   *
 *   Copyright 1992-98 by Thomas Much   *
 ****************************************
 *          Unit  O T Y P E S           *
 ****************************************
 *     Thomas Much, Gerwigstraûe 46,    *
 * 76131 Karlsruhe, Fax (0721) 62 28 21 *
 *          Thomas Much @ KA2           *
 *  Thomas.Much@stud.uni-karlsruhe.de   *
 *  www.uni-karlsruhe.de/~Thomas.Much   *
 ****************************************
 *      erstellt am:        13.07.1992  *
 *      letztes Update am:  05.03.1999  *
 ****************************************}

{
  WICHTIGE ANMERKUNGEN ZUM QUELLTEXT:

	ObjectGEM ist Freeware, d.h. jeder darf die Units verwenden, ohne
	fÅr die damit entwickelten Programme Lizenzen o.Ñ. zahlen zu mÅssen,
	so lange alle Dateien _zusammen_ und _unverÑndert_ (!) weitergegeben
	werden.
	
	Ich freue mich natÅrlich trotzdem Åber kleine Aufmerksamkeiten wie
	Belegexemplare, originelle T-Shirts (L oder XL) sowie grÅnen Tee
	aus Japan :-)

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


{$B+,D-,G-,I-,L-,N-,P-,Q-,R-,S-,T-,V-,X+,Z-}

unit OTypes;

interface

uses

	Gem;

const

	GOVersion             = $0150;
	GODate                = $03051999;

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
	as_OLGA               =  2048;
	as_CancelOnClose      =  4096;

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

	cs_ByteAlignClient    =      1;
	cs_ByteAlignWindow    =      2;
	cs_VerAlignClient     =      4;
	cs_VerAlignWindow     =      8;
	cs_FullRedraw         =     16;
	cs_SaveBits           =     32;
	cs_Rubbox             =     64;
	cs_WorkBackground     =    128;
	cs_DblClks            =    256;
	cs_CreateOnAccOpen    =    512;
	cs_CancelOnClose      =   1024;
	cs_AutoCreate         =   2048;
	cs_AutoOpen           =   4096;
	cs_ToolbarOpposite    =   8192;
	cs_QuitOnClose        =  16384;
	cs_WindowMenuToolbar  =  32768;
	cs_OLGADocument       =  65536;
	cs_FreeOnClose        = 131072;
	cs_HRedraw            =     cs_FullRedraw;
	cs_VRedraw            =     cs_FullRedraw;

	tf_GetData            =     0;
	tf_SetData            =     1;
	tf_SizeData           =     2;

	crd_Normal            =     0;
	crd_First             =     1;
	crd_Last              =     2;

	wb_Transfer           =     1;
	wb_Lazy               =     2;
	wb_ExtFocus           =     4;

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
	cs_ListBox            =  1024;

	es_ASCIIOnly          =  2048;
	es_Undo               =  4096;
	es_MultiLine          =  8192;  { ... }
	es_Password           = 16384;

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
	es_SubMenu            = 32768;

	xb_Neutral            =    -1;
	xb_False              =     0;
	xb_True               =     1;

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
	MEA_INQUIRE           =     0;
	MEA_ATTACH            =     1;
	MEA_REMOVE            =     2;
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
	MAXTOOLBARS           =     4;

	PROTO_XACC            =     1;
	PROTO_AV              =     2;

	HSLIDER               = LFARROW or RTARROW or HSLIDE;
	VSLIDER               = UPARROW or DNARROW or VSLIDE;
	SLIDER                = HSLIDER or VSLIDER;


	WF_OWNER              =    20;  { Achtung: Die Konstanten in diesem Block }
	WF_BEVENT             =    24;  {          sollten irgendwann mal in der  }
	WF_BOTTOM             =    25;  {          Unit GEM zu finden sein...     }
	WF_MINXYWH            =   103;
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
	G_SHORTCUT            =    38;
	WHITEBAK              = $0040;
	DRAW3D                = $0080;
	UNDERLINE             = $0f00;
	XSTATE                = $f000;
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

	AGI_REGULARFONT       =     0;
	AGI_SMALLFONT         =     1;
	AGI_COLORS            =     2;
	AGI_LANGUAGE          =     3;
	AGI_ENVIRONMENT1      =     4;
	AGI_ENVIRONMENT2      =     5;
	AGI_ENVIRONMENT3      =     6;
	AGI_OSEXTENSIONS      =     7;
	AGI_MOUSE             =     8;
	AGI_MENU              =     9;
	AGI_SHELWRITE         =    10;
	AGI_WINDOW            =    11;
	AGI_MESAG             =    12;
	AGI_OBJECT            =    13;
	AGI_FORM              =    14;
	AGI_WINX              = 22360;


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

	AC_HELP               =  1025;
	AC_REPLY              =  1026;
	AC_VERSION            =  1027;
	AC_COPY               =  1028;

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
	AV_SENDCLICK          = $4709;
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
	AV_STARTED            = $4738;
	VA_FONTCHANGED        = $4739;
	AV_XWIND              = $4740;
	VA_XOPEN              = $4741;

	VA_OB_UNKNOWN         =     0;
	VA_OB_TRASHCAN        =     1;
	VA_OB_SHREDDER        =     2;
	VA_OB_CLIPBOARD       =     3;
	VA_OB_FILE            =     4;
	VA_OB_FOLDER          =     5;
	VA_OB_DRIVE           =     6;
	VA_OB_WINDOW          =     7;

	MSG_SETSTATUS         = $0001;
	MSG_START             = $0002;
	MSG_STARTED           = $0004;
	MSG_FONTCHANGED       = $0008;
	MSG_QUOTING           = $0010;

	MSG_SENDKEY           = $0001;
	MSG_ASKFILEFONT       = $0002;
	MSG_ASKCONFONT        = $0004;
	MSG_ASKOBJECT         = $0008;
	MSG_OPENWIND          = $0010;
	MSG_STARTPROG         = $0020;
	MSG_ACCWINDOPEN       = $0040;
	MSG_STATUS            = $0080;
	MSG_COPY_DRAGGED      = $0100;
	MSG_PATH_UPDATE       = $0200;
	MSG_EXIT              = $0400;
	MSG_XWIND             = $0800;
	MSG_FONTCHANGED_4701  = $1000;
	MSG_STARTED_4701      = $2000;
	MSG_QUOTING_4701      = $4000;

	FILE_SELECTED         = $4560;

	FONT_CHANGED          = $7a18;
	FONT_SELECT           = $7a19;
	FONT_ACK              = $7a1a;
	XFONT_CHANGED         = $7a1b;

	SC_CHANGED            = $0050;
	PRN_CHANGED           = $0052;
	FNT_CHANGED           = $0053;
	COLORS_CHANGED        = $0054;
	SH_CHANGED            = $5343;

	SCF_INDEF             = $0000;
	SCF_DBASE             = $0001;
	SCF_TEXT              = $0002;
	SCF_VECTOR            = $0004;
	SCF_RASTER            = $0008;
	SCF_SHEET             = $0010;
	SCF_SOUND             = $0020;
	SCF_ARCHIVE           = $0040;
	SCF_SYSTEM            = $8000;

	OLE_INIT                 = $4950;
	OLE_EXIT                 = $4951;
	OLE_NEW                  = $4952;

	OLGA_INIT                = $1236;
	OLGA_UPDATE              = $1238;
	OLGA_ACK                 = $1239;
	OLGA_RENAME              = $123a;
	OLGA_OPENDOC             = $123b;
	OLGA_CLOSEDOC            = $123c;
	OLGA_LINK                = $123d;
	OLGA_UNLINK              = $123e;
	OLGA_UPDATED             = $123f;
	OLGA_RENAMELINK          = $1240;
	OLGA_LINKRENAMED         = $1241;
	OLGA_GETOBJECTS          = $1242;
	OLGA_OBJECTS             = $1243;
	OLGA_BREAKLINK           = $1244;
	OLGA_LINKBROKEN          = $1245;
	OLGA_START               = $1246;
	OLGA_GETINFO             = $1247;
	OLGA_INFO                = $1248;
	OLGA_IDLE                = $1249;
	OLGA_ACTIVATE            = $124a;
	OLGA_EMBED               = $124b;
	OLGA_EMBEDDED            = $124c;
	OLGA_UNEMBED             = $124d;
	OLGA_GETSETTINGS         = $124e;
	OLGA_SETTINGS            = $124f;
	OLGA_REQUESTNOTIFICATION = $1250;
	OLGA_RELEASENOTIFICATION = $1251;
	OLGA_NOTIFY              = $1252;
	OLGA_NOTIFIED            = $1253;
	OLGA_SERVERTERMINATED    = $1254;
	OLGA_CLIENTTERMINATED    = $1255;
	OLGA_INPLACEUPDATE       = $1256;
	OLGA_ID4UPDATE           = $1257;
	OLGA_GETEXTENSION        = $1258;
	OLGA_EXTENSION           = $1259;
	OLGA_GETSERVERPATH       = $125a;
	OLGA_SERVERPATH          = $125b;
	OLGA_IE_BUTTON           = $125c;
	OLGA_IE_KEY              = $125d;

	OL_SERVER                = $0001;
	OL_CLIENT                = $0002;
	OL_PEER                  = OL_SERVER or OL_CLIENT;
	OL_CONF                  = $0400;
	OL_IDLE                  = $0800;
	OL_PIPES                 = $1000;
	OL_START                 = $2000;
	OL_MANAGER               = $4000;
	OL_OEP                   = $0001;

	OLS_TYPE                 =     1;
	OLS_EXTENSION            =     2;
	OLS_NAME                 =     3;

	OL_SRV_ID4               = $0001;

	GS_REQUEST            = $1350;
	GS_REPLY              = $1351;
	GS_COMMAND            = $1352;
	GS_ACK                = $1353;
	GS_QUIT               = $1354;
	GS_OPENMACRO          = $1355;
	GS_MACRO              = $1356;
	GS_WRITE              = $1357;
	GS_CLOSEMACRO         = $1358;
	
	GSM_COMMAND           = $0001;
	GSM_MACRO             = $0002;
	GSM_WRITE             = $0004;
	GSM_HEXCODING         = $0008;
	
	GSACK_OK              =     0;
	GSACK_UNKNOWN         =     1;
	GSACK_ERROR           =     2;

	KEYTAB_ID_IDENTICAL   =     0;
	KEYTAB_ID_ANSI        =     1;
	KEYTAB_ID_MAC         =     2;
	KEYTAB_ID_PC          =     3;

	GO_PRIVATE            = $1235;

	GOP_GETVERSION        =     0;
	GOP_TOOLBAR           =     1;
	GOP_SETQUIT           =     2;
	GOP_RELEASEBUTTON     =     3;
	GOP_VERSION           =  $3ff;
	GOP_USERDEF           =  $400;

	BUBBLEGEM_REQUEST     = integer($baba);
	BUBBLEGEM_SHOW        = integer($babb);
	BUBBLEGEM_ACK         = integer($babc);
	BUBBLEGEM_ASKFONT     = integer($babd);
	BUBBLEGEM_FONT        = integer($babe);
	BUBBLEGEM_HIDE        = integer($babf);

	BGS7_USRHIDE          = $0001;
	BGS7_MFDB             = $0002;
	BGS7_MOUSE            = $0004;
	BGS7_2STRINGS         = $0008;
	BGS7_REQBYDEMON       = $0010;
	BGS7_ERROR            = $8000;

	CAB_CCHANGED          = integer($cab0);
	CAB_EXIT              = integer($cab1);
	CAB_PATH              = integer($cab2);
	CAB_VIEW              = integer($cab3);
	CAB_TERM              = integer($cab4);
	CAB_REQUESTSTATUS     = integer($cab5);
	CAB_STATUS            = integer($cab6);
	CAB_RELEASESTATUS     = integer($cab7);
	CAB_HELLO             = integer($cab8);
	CAB_MAIL              = integer($cab9);
	CAB_MAILSENT          = integer($caba);
	CAB_SUPPORT           = integer($cabb);
	
	DHST_ADD              = integer($dadd);
	DHST_ACK              = integer($dade);

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

	COLOR_ID              = integer($c010);
	COLOR_RGB             = integer($c011);

	PAGE_DEFAULT          =     0;
	PAGE_A3               =     1;
	PAGE_A4               =     2;
	PAGE_A5               =     3;
	PAGE_B5               =     4;
	PAGE_LETTER           =    16;
	PAGE_HALF             =    17;
	PAGE_LEGAL            =    18;
	PAGE_DOUBLE           =    19;
	PAGE_BROAD            =    20;

	CSPACE_RGB		        =     1;
	CSPACE_ARGB	     	    =	    2;
	CSPACE_CMYK		        =     4;

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
	
	PGSInfo               = ^TGSInfo;
	TGSInfo               = record
		Len    : longint;
		Version,
		Msgs   : word;
		Ext    : TCookieID
	end;

	PDHSTInfo             = ^TDHSTInfo;
	TDHSTInfo             = record
		AppName,
		AppPath,
		DocName,
		DocPath: PChar
	end;

	PKEYT = ^TKEYT;
	TKEYT = record
		Magic             : TCookieID;
		Size              : longint;
		GetExportCount    : function: integer;
		pasGetExportName  : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): PChar;
		GetExportFilter   : function(d1,d2: pointer; d3,d4,d5: longint; eid: integer): integer;
		ExportChar        : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer; echr: char): char;
		GetImportCount    : function: integer;
		pasGetImportName  : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): PChar;
		GetImportFilter   : function(d1,d2: pointer; d3,d4,d5: longint; iid: integer): integer;
		ImportChar        : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ichr: char): char;
		ExportString      : procedure(d1,d2: pointer; d3,d4,d5: longint; enr: integer; elen: longint; echrs: PChar);
		ImportString      : procedure(d1,d2: pointer; d3,d4,d5: longint; inr: integer; ilen: longint; ichrs: PChar);
		GetExportName     : function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;
		GetImportName     : function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;
		GetExportShortName: function(d1,d2: pointer; d3,d4,d5: longint; enr: integer): longint;
		GetImportShortName: function(d1,d2: pointer; d3,d4,d5: longint; inr: integer): longint;
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

	PToolbarDescr         = ^TToolbarDescr;
	TToolbarDescr         = record
		Indx,
		Size: integer;
		Tree: PTree
	end;

	PXBRA                 = ^XBRA;
	XBRA                  = record
		xb_magic,
		xb_id    : array [0..3] of char;
		xb_oldvec: pointer
	end;

	PXTED                 = ^XTED;
	XTED                  = record
		xte_ptmplt,
		xte_pvalid: pointer;
		xte_vislen,
		xte_scroll: integer
	end;

	PXFNT_INFO            = ^XFNT_INFO;
	XFNT_INFO             = record
		size       : longint;
		format,
		id,
		index      : integer;
		font_name,
		family_name,
		style_name : array [0..49] of char;
		file_name1,
		file_name2,
		file_name3 : array [0..199] of char;
		pt_cnt     : integer;
		pt_sizes   : array [0..63] of integer
	end;

	PCOLOR_RGB = ^TCOLOR_RGB;
	TCOLOR_RGB = record
		reserved,
		red,
		green,
		blue    : word
	end;
	
	PCOLOR_CMYK = ^TCOLOR_CMYK;
	TCOLOR_CMYK = record
		cyan,
		magenta,
		yellow,
		black  : word
	end;
	
	PCOLOR_ENTRY = ^TCOLOR_ENTRY;
	TCOLOR_ENTRY = record
		case boolean of
			false: (rgb : TCOLOR_RGB);
			true:  (cmyk: TCOLOR_CMYK)
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
		Style        : longint;
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
		VWork     : GRECT;
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
		EventMask  : integer;
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

	PAppTypeMR            = ^TAppTypeMR;
	TAppTypeMR            = string[2];

	POLGAAttr             = ^TOLGAAttr;
	TOLGAAttr             = record
		Msg,
		Protocol,
		ManagerMsg,
		ManagerProtocol: integer
	end;

	POLGAInfHeader        = ^TOLGAInfHeader;
	TOLGAInfHeader        = record
		Magic  : array [0..3] of char;
		Version,
		Skip   : word
	end;

	POLGABlockHeader      = ^TOLGABlockHeader;
	TOLGABlockHeader      = record
		ID    : array [0..3] of char;
		Length: longint
	end;

	PRGB = ^TRGB;
	TRGB = record
		case boolean of
			false: (RGB           : ARRAY_3);
			true:  (Red,Green,Blue: integer)
	end;

	POLGAColorTable = ^TOLGAColorTable;
	TOLGAColorTable = record
		Count : integer;
		Colors: array [0..255] of TRGB
	end;

	POLGAObjectInfo       = ^TOLGAObjectInfo;
	TOLGAObjectInfo       = record
		Filename      : PChar;
		ClientGEMPB   : AESPBPtr;
		ClientData,
		ServerData    : longint;
		CBLock,
		CBCount       : integer;
		CBDraw        : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo; outScreen,outHandle,outDevID: integer; Size,Clip: PGRECT);
		CBUnembed     : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo);
		CBXDraw       : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo; outScreen,outHandle,outDevID: integer; Size,Clip: PGRECT; Width_mm1000, Height_mm1000, Scale: longint);
		cbColorTable  : POLGAColorTable;
		cbClientID,
		cbServerID    : integer;
		CBIEActivate  : procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo);
		CBIEDeactivate: procedure(d1,d2: pointer; d3,d4,d5: longint; objectinfo: POLGAObjectInfo);
	end;
	
	POLGAIEInfo           = ^TOLGAIEInfo;
	TOLGAIEInfo           = record
		len       : longint;
		wHandle,
		kShift    : integer;
		Size      : PGRECT;
		objectinfo: POLGAObjectInfo;
	end;

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

	PIntegerArray         = ^TIntegerArray;
	TIntegerArray         = array [0..1073741822] of integer;

	PLongintArray         = ^TLongintArray;
	TLongintArray         = array [0..536870910] of longint;

	PPicResult            = ^TPicResult;
	TPicResult            = (prComplete, prIncomplete, prEmpty, prError,
																prSyntax, prAmbiguous, prIncompNoFill);


implementation

end.