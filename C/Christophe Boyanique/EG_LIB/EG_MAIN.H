/******************************************************************************/
/*																										*/
/*	Library "Easy Gem"																			*/
/*	by:	Christophe BOYANIQUE																	*/
/*			29 Rue R‚publique																		*/
/*			37230 FONDETTES																		*/
/*			FRANCE																					*/
/*		e-mail:	cb@spia.freenix.fr	*very* small mail please!						*/
/*																										*/
/******************************************************************************/
/*	TABULATION: 3 CARACTERES																	*/
/******************************************************************************/
#ifndef	__EGLIB__
#define	__EGLIB__
#define	EGLIB_VERSION		0x0121

/******************************************************************************/
/*	Include files																					*/
/******************************************************************************/
#include		<stdio.h>
#include		<stdlib.h>
#include		<ctype.h>
#include		<aes.h>
#include		<vdi.h>
#include		<tos.h>
#include		<math.h>
#include		<string.h>
#include		<MiNT.h>
#include		"EG_RSC.H"


/******************************************************************************/
/*	STANDARD TYPE DEFINITIONS																	*/
/******************************************************************************/
#define		BYTE				signed char
#define		UBYTE				unsigned char
#define		WORD				signed int
#define		UWORD				unsigned int
#define		LONG				signed long
#define		ULONG				unsigned long
#define		uchar				unsigned char
#define		uint				unsigned int
#define		ulong				unsigned long
#define		BOOLEAN			int
#define		FLOAT				float
#define		DOUBLE			double
#define		REG				register
#define		EXTERN			extern
#define		LOCAL				static
#define		statique			static
#define		MLOCAL			LOCAL
#define		GLOBAL
/******************************************************************************/
#define		CDECL				cdecl
#define		SIZE_T			size_t
#define		VOID				void
/******************************************************************************/
/*	COMPILER DEPENDENT DEFINITIONS															*/
/******************************************************************************/
#define		_(params)		params
/******************************************************************************/
/*	OPERATING SYSTEM DEPENDENT DEFINITIONS													*/
/******************************************************************************/
#define		NEAR
#define		FAR
#define		HUGE
/******************************************************************************/
/*	MISCELLANEOUS DEFINITIONS																	*/
/******************************************************************************/
#ifndef TRUE
#define		FALSE				(BOOLEAN)0
#define		TRUE    			(BOOLEAN)1
#endif
/******************************************************************************/
#define		FAILURE			-1
#define		SUCCESS			0
#define		FOREVER			for (;;)
#define		EOS				'\0'
/******************************************************************************/
/******************************************************************************/


/******************************************************************************/
/*	WINDOW DEFINES																					*/
/******************************************************************************/
#define	TW_FORM			0						/*	Window type: Form		(reserved)	*/
#define	TW_HELP			1						/*	Window type: Help		(reserved)	*/
#define	TW_IMG			2						/*	Window type: Image					*/

#define	wNAMEMAX			60							/*	Max window name					*/
#define	wSNAMEMAX		10							/*	max iconified window name		*/

#define	wNAME				0x0001	/*	Window gadget: Change name						*/
#define	wMOVE				0x0002	/*	Window gadget: Move window						*/
#define	wCLOSE			0x0004	/*	Window gadget: Close window					*/
#define	wMENU				0x0008	/*	Window gadget: PopUp menu on the window	*/
#define	wCYCLE			0x0010	/*	Window gadget: Cycle window					*/
#define	wICON				0x0020	/*	Window gadget: Iconifie window				*/
#define	wFULL				0x0040	/*	Window gadget: Full window						*/
#define	wVSLIDE			0x0080	/*	Window gadget: Vertical slider				*/
#define	wUARROW			0x0100	/*	Window gadget: Up arrow							*/
#define	wDARROW			0x0200	/*	Window gadget: Down arrow						*/
#define	wSIZE				0x0400	/*	Window gadget: Resize window					*/
#define	wRARROW			0x0800	/*	Window gadget: Right arrow						*/
#define	wLARROW			0x1000	/*	Window gadget: Left arrow						*/
#define	wHSLIDE			0x2000	/*	Window gadget: Horizontal slide				*/
#define	wXWORK16			0x4000	/*	Window gadget: Force xwork pos 16 multiple*/


/******************************************************************************/
/*	RSC DEFINES																						*/
/******************************************************************************/
#define	EXT_RSC			0					/*	extern RSC file: load & relocate it	*/
#define	INT_RSC			1					/*	intern RSC file: relocate it			*/

#define	USD_CARRE		0x0100				/*	STRING with a [checked] box		*/
#define	USD_ROND			0x0200				/*	STRING with a radio button			*/
#define	USD_POPUP		0x0300				/*	PopUp menu BUTTON						*/
#define	USD_XPOPUP		0x0400				/*	Extended PopUp menu BUTTON			*/
#define	USD_DNARROW		0xFD00				/*	USERDEF: down arrow					*/
#define	USD_UPARROW		0xFC00				/*	USERDEF: up arrow						*/
#define	USD_LFARROW		0xFB00				/*	USERDEF: left arrow					*/
#define	USD_RTARROW		0xFA00				/*	USERDEF: right arrow					*/
#define	USD_LQARROW		0xF900				/*	USERDEF: double left arrow			*/
#define	USD_RQARROW		0xF800				/*	USERDEF: double right arrow		*/

#define	ED_CLIP			0x0100				/*	Clip with _objcEdit()				*/


/******************************************************************************/
/*	HELP DEFINES																					*/
/******************************************************************************/
#define	HLP_TABUL		30
#define	HLP_DECPAR		20
#define	HLP_DECLINE		10
#define	PAR_MAX			200				/*	max number of paragraph					*/
#define	COUL_TRUE		11					/*	default color for existing file		*/
#define	COUL_FALSE		14					/*	default color for non existing file	*/
#define	MAX_HIST			10					/*	history lenght								*/
#define	MAX_LEN_HIST	20					/*	history text lenght						*/


/******************************************************************************/
/*	MiNT SIGNALS																					*/
/******************************************************************************/
#define	SIGNULL		0		/*	not really a signal					*/
#define	SIGHUP		1		/*	hangup signal							*/
#define	SIGINT		2		/*	sent by ^C								*/
#define	SIGQUIT		3		/*	quit signal								*/
#define	SIGILL		4		/*	illegal instruction					*/
#define	SIGTRAP		5		/*	trace trap								*/
#define	SIGABRT		6		/*	abort signal							*/
#define	SIGPRIV		7		/*	privilege violation					*/
#define	SIGFPE		8		/*	divide by zero							*/
#define	SIGKILL		9		/*	cannot be ignored						*/
#define	SIGBUS		10		/*	bus error								*/
#define	SIGSEGV		11		/*	illegal memory reference			*/
#define	SIGSYS		12		/*	bad argument to a system call		*/
#define	SIGPIPE		13		/*	broken pipe								*/
#define	SIGALRM		14		/*	alarm clock								*/
#define	SIGTERM		15		/*	software termination signal		*/
#define	SIGURG		16		/*	urgent condition on I/O channel	*/
#define	SIGSTOP		17		/*	stop signal not from terminal		*/
#define	SIGTSTP		18		/*	stop signal from terminal			*/
#define	SIGCONT		19		/*	continue stopped process			*/
#define	SIGCHLD		20		/*	child stopped or exited				*/
#define	SIGTTIN		21		/*	read by background process			*/
#define	SIGTTOU		22		/*	write by background process		*/
#define	SIGIO			23		/*	I/O possible on a descriptor		*/
#define	SIGXCPU		24		/*	CPU time exhausted					*/
#define	SIGXFSZ		25		/*	file size limited exceeded			*/
#define	SIGVTALRM	26		/*	virtual timer alarm					*/
#define	SIGPROF		27		/*	profiling timer expired				*/
#define	SIGWINCH		28		/*	window size changed					*/
#define	SIGUSR1		29		/*	ser signal 1							*/
#define	SIGUSR2		30		/*	user signal 2							*/

#define	NSIG			31		/*	number of signals recognized		*/
#define	SIG_DFL		0
#define	SIG_IGN		1


/******************************************************************************/
/*	KEYBOARD DEFINES																				*/
/******************************************************************************/
#define	K_NIL			0x00			/*	No Key				*/
#define	K_UP			0x01			/*	Cursor UP			*/
#define	K_DOWN		0x02			/*	cursor DOWN			*/
#define	K_RIGHT		0x03			/*	cursor RIGHT		*/
#define	K_LEFT		0x04			/*	cursor LEFT			*/
#define	K_INS			0x05			/*	INSERT				*/
#define	K_CLRHOME	0x06			/*	CLR-HOME				*/
#define	K_HELP		0x07			/*	HELP					*/
#define	K_UNDO		0x08			/*	UNDO					*/
#define	K_F1			0x09			/*	Function Key #1	*/
#define	K_F2			0x0A			/*	Function Key #2	*/
#define	K_F3			0x0B			/*	Function Key #3	*/
#define	K_F4			0x0C			/*	Function Key #4	*/
#define	K_F5			0x0D			/*	Function Key #5	*/
#define	K_F6			0x0E			/*	Function Key #6	*/
#define	K_F7			0x0F			/*	Function Key #7	*/
#define	K_F8			0x10			/*	Function Key #8	*/
#define	K_F9			0x11			/*	Function Key #9	*/
#define	K_F10			0x12			/*	Function Key #10	*/

#define	K_ESC			0x1B			/*	ESCAPE				*/
#define	K_TAB			0x09			/*	TAB					*/
#define	K_DEL			0x7F			/*	DELETE				*/
#define	K_BS			0x08			/*	BACKSPACE			*/
#define	K_RET			0x0D			/*	RETURN				*/

#define	KF_FUNC		0x4000		/*	Function flag		*/
#define	KF_NUM		0x2000		/*	Numeric pad			*/
#define	KF_CAPS		0x1000		/*	CapsLock				*/
#define	KF_ALT		0x0800		/*	Alternate			*/
#define	KF_CTRL		0x0400		/*	Control				*/
#define	KF_SHIFT		0x0300		/*	any Shift			*/
#define	KF_LSH		0x0200		/*	Left Shift			*/
#define	KF_RSH		0x0100		/*	Right Shift			*/


/******************************************************************************/
/*	MEMORY DEFINES																					*/
/******************************************************************************/
#define	MEM_NMB		10										/*	Number of Malloc blocs	*/

#define	MB_IGNORE	0										/*	free bloc					*/
#define	MB_NORM		1										/*	allocated bloc				*/
#define	MB_NOMOVE	2										/*	allocated bloc fixed		*/

#define	OK_MEM		0													/*	No error			*/
#define	NO_OS_MEM	-1													/*	No TOS memory	*/
#define	NO_MEMORY	-2													/*	No lib memory	*/


/******************************************************************************/
/*	LANGUAGE DEFINES																				*/
/******************************************************************************/
#define	L_FRENCH		0
#define	L_ENGLISH	1


/******************************************************************************/
/*	OTHER DEFINES																					*/
/******************************************************************************/
#define	max(A,B)			( (A) > (B) ? (A) : (B) )
#define	min(A,B)			( (A) < (B) ? (A) : (B) )


/******************************************************************************/
/*	struct to retain RSC parameters for each window										*/
/******************************************************************************/
typedef struct
{
	int	x;
	int	y;
	int	flags;
}	xy;
typedef struct
{
	int	x;
	int	y;
	int	w;
	int	h;
	int	flags;
}	wh;
typedef struct
{
	int		x,y,w,h;
	wh		_box;
	wh		_name;
	xy		_close;
	xy		_menu;
	xy		_cycle;
	xy		_icon;
	xy		_full;
	wh		_vslf;
	wh		_vslp;
	wh		_vsli;
	xy		_uarr;
	xy		_darr;
	xy		_size;
	xy		_rarr;
	xy		_larr;
	wh		_hslf;
	wh		_hslp;
	wh		_hsli;
	int	_smstate;
}	_form;
typedef struct
{
	int		pos;
	int		obj;
	OBJECT	*tree;
}	WFORM;

/******************************************************************************/
/*	struct for GDOS font handling																*/
/******************************************************************************/
typedef struct
{
	char		name[34];					/*	0..31: Name | 32: vectoriel flag		*/
	int		index;						/*	GDOS index									*/
}	FONT;


/******************************************************************************/
/*	Options of the lib																			*/
/******************************************************************************/
typedef struct
{
	int	mnmb;
	long	mlen;
	int	Gfnt;							/*	Font in GEM							*/
	int	GDfnt;						/*	Default GDOS font in GEM		*/
	int	GIfnt;						/*	Intern GDOS font in GEM			*/
	int	Hfnt;							/*	Font in help						*/
	int	HDfnt;						/*	Default GDOS font in help		*/
	int	HIfnt;						/*	Intern GDOS font in help		*/
	int	popf;
	int	font;
	int	help;
	int	hsiz;
	int	full;
	int	save;
	int	mfrm;
	int	lang;
	int	chlpt;
	int	chlpf;
	char	phelp[FILENAME_MAX];
	char	path[FILENAME_MAX];
}	_options;


/******************************************************************************/
/*	struct for USERDEF objects																	*/
/******************************************************************************/
typedef struct
{
	int			type;
	USERBLK		blk;
	long			spec;
	int			user1;
	int			user2;
	int			user3;
	int			user4;
	long			userl;
}	UBLK;


/******************************************************************************/
/*	structs for memory handling																*/
/******************************************************************************/
typedef struct
{
	long	adr;
	long	len;
	int	type;
}	BLOC;
typedef struct
{
	int	n;										/*	Max number of MBalloc	*/
	long	tfre;									/*	Total free lenght			*/
	long	tlen;									/*	Total lenght				*/
	long	mfre;									/*	Max free bloc				*/	
	long	Badr[MEM_NMB];						/*	Malloc adress				*/
	long	Blen[MEM_NMB];						/*	Malloc lenght				*/
	BLOC	*bloc;
}	MEM;


/******************************************************************************/
/*																										*/
/*	Selectric support (The *best* fileselector replacement)							*/
/*																										*/
/******************************************************************************/
#define	CMD_FILES_OUT	0x01							/*	Return filelist				*/
#define	CFG_ONESTRING	0x02							/*	Return list in one string	*/
#define	CFG_FIRSTNEXT	0x08
typedef struct
{
	ulong		id;						/* Selectric ID (SLCT)		*/
	uint		version;					/* version (BCD-Format)		*/
	struct
	{
		unsigned 			:	8;		/*	reserved						*/
		unsigned pthsav	:	1;		/*	save GEMDOS paths			*/
		unsigned stdest	:	1;		/*	stay in destination path*/
		unsigned autloc	:	1;		/*	auto-locator				*/
		unsigned numsrt	:	1;		/*	numsort						*/
		unsigned lower		:	1;		/*	use lowercase letters	*/
		unsigned dclick	:	1;		/*	open folder on dclick	*/
		unsigned hidden	:	1;		/*	show hidden files			*/
		unsigned bypass	:	1;		/*	Selectric ON/OFF			*/
	}	config;
	int		sort;						/*	sort-mode (neg. = rev.)	*/
	int		num_ext;					/*	number of extensions		*/
	char		*(*ext)[];				/*	preset extensions			*/
	int		num_paths;				/*	number of paths			*/
	char		*(*paths)[];			/*	preset paths				*/
	int		comm;						/*	communication word		*/
	int		in_count;				/*	input counter				*/
	void		*in_ptr;					/*	input pointer				*/
	int		out_count;				/*	output counter				*/
	void		*out_ptr;				/*	output pointer				*/
	int cdecl	(*get_first)(DTA *dta,int attrib);
	int cdecl 	(*get_next)(DTA *dta);
	int cdecl	(*release_dir)(void);
}	SLCT_STR;


/******************************************************************************/
/*	RSC header and support struct																*/
/******************************************************************************/
typedef struct
{
	int			nobs;
	int			ntree;
	int			nted;
	int			ncib;
	int			nib;
	int			nbb;
	int			nfstr;
	int			nfimg;
	OBJECT		*object;
	TEDINFO		*tedinfo;
	ICONBLK		*iconblk;
	BITBLK		*bitblk;
	CICON			*cicon;
	CICONBLK		*ciconblk;
	char			**frstr;
	BITBLK		**frimg;
	OBJECT		**trindex;
}	myRSHDR;

typedef struct
{
	char		name[14];							/*	RSC file name							*/
	int		type;									/*	Type of RSC (intern or extern ?)	*/
	myRSHDR	head;									/*	RSC Header								*/
	int		in;									/*	memory index of RSC					*/
	UBLK		*ublk;								/*	userdef array							*/
	CICON		*cicon;								/*	color icon array						*/
}	RSC;


/******************************************************************************/
/*	function pointer																				*/
/******************************************************************************/
typedef void	(*Fptr)		(void);
typedef void	(*Fredraw)	(int i,int x,int y,int w,int h);		/*	W REDRAW		*/
typedef void	(*Ftop)		(int i);										/*	W TOPPED		*/
typedef void	(*Fpop)		(int i,int n);								/*	W TOPPED		*/
typedef void	(*Fclosed)	(int i);										/*	W CLOSED		*/
typedef void	(*Ffull)		(int i);										/*	W FULLED		*/
typedef void	(*Farrow)	(int i,int type);							/*	W ARROWED	*/
typedef void	(*Fhslid)	(int i,int size);							/*	W HSLID		*/
typedef void	(*Fvslid)	(int i,int size);							/*	W VSLID		*/
typedef void	(*Fsize)		(int i,int w,int h);						/*	W SIZED		*/
typedef void	(*Fmove)		(int i,int x,int y);						/*	W MOVED		*/
typedef void	(*Funtop)	(int i);										/*	W UNTOP		*/
typedef void	(*Fontop)	(int i);										/*	W ONTOP		*/
typedef void	(*Fsmall)	(int i);										/*	W SMALL		*/
typedef void	(*Fnsmall)	(int i);										/*	W UNSMALL	*/
typedef void	(*Finit)		(int i);										/*	W init		*/
typedef void	(*Fclic)		(int i,int mx,int my,int mk,int nb);/*	W clic		*/
typedef void	(*Fkeybd)	(int i,int key);							/*	W keybd		*/
typedef void	(*Fbclic)	(int mx,int my,int mk);					/*	Desk clic	*/
typedef void	(*Ffclic)	(int obj,int n,int nmb);				/*	Form clic	*/
typedef void	(*Fmenu)		(int option);								/*	MENU			*/
typedef void	(*Frsc)		(int tree,int obj);						/*	RSC init		*/
typedef void	(*FKey)		(int key);									/*	key			*/
typedef void	(*FMesag)	(int buf[8]);								/*	mesag event	*/


/******************************************************************************/
/*	This struct is used to save configuration												*/
/******************************************************************************/
typedef struct
{
	int		tree;
	char		name[wNAMEMAX+2];
	char		sname[wSNAMEMAX+2];
	char		help[14];
	int		popup;
	int		icon;
	int		xwind;
	int		ywind;
	int		wwind;
	int		hwind;
}	S_WIN;
typedef struct
{
	char		name[16];
	_options	opt;
	int		wdesk;
	int		hdesk;
	int		xhelp,yhelp,whelp,hhelp;
	int		help;
	char		histoire[MAX_HIST+1][MAX_LEN_HIST+1];
	char		histoire2[MAX_HIST+1][MAX_LEN_HIST+1];
	char		file[14];
	int		cu_hist,cp_hist;
	int		gdos;
}	S_CNF;

/******************************************************************************/
/*	This struct contains all the parameters of the lib									*/
/******************************************************************************/
typedef struct
{
	int		app_id;					/*	AES handle				*/
	int		vAES;						/*	AES version				*/
	int		Multi;					/*	multitask flag			*/
	int		type;						/*	application flag		*/
	int		xdesk;					/*	x dim of desk			*/
	int		ydesk;					/*	y dim of desk			*/
	int		wdesk;					/*	w dim of desk			*/
	int		hdesk;					/*	h dim of desk			*/
	int		menu,desk,icon;		/*	RSC trees				*/
	int		NMB_WDW;					/*	number of windows		*/

	int		flag;						/*	evnt_multi flag		*/
	int		f1;						/*	in/out flag 1			*/
	int		x1;						/*	x rect 1					*/
	int		y1;						/*	y rect 1					*/
	int		w1;						/*	w rect 1					*/
	int		h1;						/*	h rect 1					*/
	int		f2;						/*	in/out flag 2			*/
	int		x2;						/*	x rect 2					*/
	int		y2;						/*	y rect 2					*/
	int		w2;						/*	w rect 2					*/
	int		h2;						/*	h rect 2					*/
	int		timer1;					/*	timer low byte			*/
	int		timer2;					/*	timer high byte		*/

	int		hvdi;						/*	VDI handle				*/
	int		out[57];					/*	VDI parameters			*/
	int		extnd[57];				/*	VDI parameters			*/
	int		xscr;						/*	x dim of screen		*/
	int		yscr;						/*	y dim of screen		*/
	int		wscr;						/*	w dim of screen		*/
	int		hscr;						/*	h dim of screen		*/
	int		wcell;					/*	text cellul width		*/
	int		hcell;					/*	text cellul height	*/
	int		wbox;						/*	box width				*/
	int		hbox;						/*	box height				*/
	int		gdos;						/*	flag GDOS				*/
	int		vgdos;					/*	Version of GDOS		*/
	int		nfont;					/*	Number of GDOS fonts	*/
	int		low;						/*	low rez flag			*/

	long		sig[NSIG];				/*	signal functions		*/
	Fptr		FinitSig;				/*	init function			*/

	Fptr		Finit;					/*	General init			*/
	Fptr		FiAES;					/*	AES init					*/
	Fptr		FiVDI;					/*	VDI init					*/
	Fptr		FiDIV;					/*	divers init				*/
	Fptr		Fcut;						/*	Cut the RSC tables	*/
	Frsc		FiObRSC;					/*	RSC by object init	*/
	Fptr		FiDesk;					/*	desk init				*/
	Fptr		FiLast;					/*	Last chance to init!	*/
	Fptr		FeFirst;					/*	First exit routine!	*/
	Fptr		FeAES;					/*	AES exit					*/
	Fptr		FeVDI;					/*	VDI exit					*/
	Fptr		FeDIV;					/*	divers exit				*/
	Fmenu		FgereMenu;				/*	menu handling			*/
	Fptr		Ftimer;					/*	TIMER event				*/
	Fptr		Fbox1;					/*	BOX 1 event				*/
	Fptr		Fbox2;					/*	BOX 2 event				*/
	FKey		Fkey;						/*	KEY event				*/
	FMesag	Fmesag;					/*	MESAG event				*/
	Fptr		FacOpen;					/*	AC_OPEN event			*/
	Fptr		FacClose;				/*	AC_CLOSE event			*/
	Fbclic	FclicB;					/*	Desk clic event		*/	
	Ffclic	FclicF;					/*	Wform clic event		*/	
	Fpop		fpop;						/*	Window PopUp			*/
	Fptr		FLang;					/*	Language switch		*/

	_options	opt;						/*	lib options				*/
	char		path[FILENAME_MAX];	/*	current directory		*/
	char		help[14];				/*	Default help file		*/
	char		cnf[14];					/*	Default cnf file		*/
	int		AccOp;					/*	open ACC flag			*/
	int		Exit;						/*	exit flag				*/
	int		MCH;						/*	machine type			*/
	int		vTOS;						/*	TOS version				*/
	char		name[16];				/*	program name			*/
	int		pal;						/*	palette memory index	*/
	RSC		rsc;						/*	program RSC header	*/
}	GLB;


/******************************************************************************/
/*	window struct																					*/
/******************************************************************************/
typedef struct
{
	int		in;							/*	index for the program (resv for Wform)	*/
	int		smallflag;					/*	SMALL flag										*/
	int		xslidpos,xslidlen;		/*	Position & lenght of X slider				*/
	int		yslidpos,yslidlen;		/*	Position & lenght of Y slider				*/
	int		x,y,w,h;						/*	dimension free for the user				*/
	int		handle;						/*	AES handle of the window					*/
	int		gadget;						/*	Gadgets											*/
	int		type;							/*	Type of window									*/
	int		id;							/*	Identification of window					*/
	int		xwind;						/*	X pos of the window							*/
	int		ywind;						/*	Y pos of the window							*/
	int		wwind;						/*	W pos of the window							*/
	int		hwind;						/*	H pos of the window							*/
	int		xfull;						/*	X full pos of the window					*/
	int		yfull;						/*	Y full pos of the window					*/
	int		wfull;						/*	W full pos of the window					*/
	int		hfull;						/*	H full pos of the window					*/
	int		xwork;						/*	X work pos of the window					*/
	int		ywork;						/*	Y work pos of the window					*/
	int		wwork;						/*	W work pos of the window					*/
	int		hwork;						/*	H work pos of the window					*/
	int		popup;						/*	RSC tree index of PopUp Menu object		*/
	int		icon;							/*	RSC tree index of ICONIFIED window		*/

	char		name[wNAMEMAX+2];	/*	Name of the window							*/
	char		sname[wSNAMEMAX+2];	/*	Name of the iconified window				*/
	char		help[14];					/*	Name of the help file						*/

	Fredraw		redraw;					/*	REDRAW routine				*/
	Ftop			top;						/*	TOP routine					*/
	Fpop			pop;						/*	PopUp event routine		*/
	Fclosed		closed;					/*	CLOSE routine				*/
	Ffull			full;						/*	FULL routine				*/
	Farrow		arrow;					/*	ARROW routine				*/
	Fhslid		hslid;					/*	Hslid routine				*/
	Fvslid		vslid;					/*	Vslid routine				*/
	Fsize			size;						/*	SIZE routine				*/
	Fmove			move;						/*	MOVE routine				*/
	Funtop		untop;					/*	UNTOP routine				*/
	Fontop		ontop;					/*	ONTOP routine				*/
	Fsmall		small;					/*	SMALL routine				*/
	Fnsmall		nsmall;					/*	UNSMALL routine			*/
	Fclic			clic;						/*	Button event routine		*/
	Fkeybd		keybd;					/*	Keyboard event routine	*/
	Finit			init;						/*	init routine				*/
} window;

typedef struct								/*	This struct is *intern*	*/
{
	int		mxwork;						/*	real X work pos window	*/
	int		mywork;						/*	real Y work pos window	*/
	int		mwwork;						/*	real W work pos window	*/
	int		mhwork;						/*	real H work pos window	*/
	int		xold;							/*	reserved for Fuller		*/
	int		yold;							/*	reserved for Fuller		*/
	int		wold;							/*	reserved for Fuller		*/
	int		hold;							/*	reserved for Fuller		*/
	int		wmini;						/*	minimum width				*/
	int		hmini;						/*	minimum height				*/
	int		xsmall,xwsmall;			/*	X iconified pos			*/
	int		ysmall,ywsmall;			/*	Y iconified pos			*/
	int		wsmall,wwsmall;			/*	W iconified pos			*/
	int		hsmall,hwsmall;			/*	H iconified pos			*/
	_form		params;						/*	reserved array				*/
} __window;



/******************************************************************************/
/*	INTERN VARIABLES:																				*/
/******************************************************************************/
extern	__window	*__W;					/*	intern window struct							*/
extern	RSC		__rsc;				/*	intern RSC header								*/
extern	int		__x,__y,__w,__h;
extern	int		__TOP;				/*	intern flag: TOPped window					*/
extern	MFORM		__s[14];				/*	predefined mouse form of the lib			*/
extern	int		__buf[8],__evnt,__kst,__key,__std,__mx,__my,__mk,__nmbClic;
extern	GRECT		__r;					/*	for GEM handling								*/
extern	int		__adrW;				/*	window array pointer							*/
extern	int		__farb[256][32];	/*	for color icon handling						*/
extern	ulong		__farb2[32];		/*	for color icon handling						*/
extern	int		__pal[256][4];		/*	for color icon handling						*/
extern	int		__xpixel;			/*	for color icon handling						*/
extern	int		cu_hist,cp_hist;
extern	char		histoire[MAX_HIST+1][MAX_LEN_HIST+1],histoire2[MAX_HIST+1][MAX_LEN_HIST+1];


/******************************************************************************/
/*	GLOBAL VARIABLES:																				*/
/******************************************************************************/
extern	GLB		glb;					/*	global parameter struct						*/
extern	window	*W;					/*	global window struct							*/
extern	MEM		mem;
extern	SLCT_STR	*slct;				/*	For use with Slectric (see GLB_FSEL)	*/
extern	long		*fsel;				/*	------------------------------------	*/
extern	FONT		*font;				/*	GDOS fonts information array				*/
extern	char		pname[FILENAME_MAX],pfname[FILENAME_MAX],fname[14],ext[14],tit[30];


/******************************************************************************/
/*	FUNCTIONS: GLB																					*/
/******************************************************************************/
void	_clearGLB				(void);
void	_EGlib					(void);
int	_initMEM					(void);
void	_exitMEM					(void);
void	_initAES					(void);
int	_initVDI					(void);
void	_initDIV					(void);
int	_loadRSC					(void);
int	_initRSC					(void);
int	_initMyRSC				(void);
void	_initDesk				(void);
void	_menuBar					(int obj,int flag);
void	_exitDesk				(void);
void	_exitRSC					(void);
void	_exitDIV					(void);
void	_exitVDI					(void);
void	_exitAES					(void);
int	_windowInit				(void);
void	_gereAES					(void);
void	_traiteEvntKeybd		(void);
void	_traiteEvntButton		(void);
void	_traiteEvntBox1		(void);
void	_traiteEvntBox2		(void);
void	_traiteEvntMesag		(void);
void	_traiteEvntTimer		(void);
void	_gereMenu				(int titre,int option);
void	_small					(int i);
void	_allsmall				(int i);
void	_unsmall					(int i);
void	_allunsmall				(int i);
void	_AcOpen					(void);
void	_AcClose					(void);
int	_winOpen					(window *win);
void	_winClose				(int i);
void	_setWindow				(int i);
void	_winVslid				(int i);
void	_winHslid				(int i);
void	_clicBureau				(int mx,int my,int mk,int nmb);
void	_top						(int i);
void	_untop					(int i);
void	_ontop					(int i);
void	_closed					(int i);
void	_full						(int i);
void	_size						(int i,int w,int h);
void	_move						(int i,int x,int y);
void	_redraw					(int i,int x,int y,int w,int h);
void	_clicWin					(int i,int x,int y,int k,int nmb);
void	_maketop					(void);
void	_makeform				(int i);
void	_winName					(int i,char *name,char *sname);
void	_winWsize				(int i,int w,int h);
void	_winSize					(int i,int w,int h);
void	_winMove					(int i,int x,int y);
void	_redrawWindow			(int i);


/******************************************************************************/
/*	FUNCTIONS: GLB_CICN																			*/
/******************************************************************************/
int			_addCicon		(CICONBLK *cicnblk,OBJECT *obj,UBLK *obblk,CICON *cicon_table);
void			_fillFarbTbl	(void);
int			_testRez			(void);
int cdecl	_drawCicon		(PARMBLK *pb);

/******************************************************************************/
/*	FUNCTIONS: GLB_FSEL																			*/
/******************************************************************************/
int	_fexist					(char *name,int type);
int	_fselect					(char *pfname,char *pname,char *fname,char *ext,char *title);
int	_slctCheck				(uint version);
int	_slctExtPath			(int ext_num,char *(*ext)[],int path_num,char *(*paths)[]);
int	_slctMoreNames			(int mode,int num,void *str);
int	_slctFirst				(DTA *mydta,int attr);
int	_slctNext				(DTA *mydta);
int	_slctRelease			(void);


/******************************************************************************/
/*	FUNCTIONS: GLB_HELP																			*/
/******************************************************************************/
void	_initAide				(void);
void	_initHelp				(void);
void	_Aide						(void);
int	_ouvreHelp				(char *name);


/******************************************************************************/
/*	FUNCTIONS: GLB_KEY																			*/
/******************************************************************************/
int	_traiteKey				(int shift,int key);


/******************************************************************************/
/*	FUNCTIONS: GLB_LANG																			*/
/******************************************************************************/
void	_switchLang				(void);
void	_initLang				(void);
char	*_putSpec				(OBJECT *tree,int n,char *txt);
char	*_getLang				(char *txt);
void	_cut						(char *txt);


/******************************************************************************/
/*	FUNCTIONS: GLB_MEM																			*/
/******************************************************************************/
int	_pAlloc		(int n,long len);
void	_pFree		(void);
void	_pDim			(long len);
int	_mAlloc		(long len,int type,int cls);
void	_mFree		(int index);
void	_mSpecFree	(long adr);
int	_mDim			(int index,long len,int cls);
long	_freeSys		(void);


/******************************************************************************/
/*	FUNCTIONS: GLB_POP																			*/
/******************************************************************************/
int	_formMenu	(OBJECT *tree,int obj,OBJECT *menu,int hJust,int vJust,int Video);
int	_popUp		(OBJECT *menu,int x,int y);
int	_formXmenu	(OBJECT *tree,int obj,char *tab,int nmb,int off,int len,int val);


/******************************************************************************/
/*	FUNCTIONS: GLB_SIG																			*/
/******************************************************************************/
void	_initSIG					(void);
void	_sigQUIT					(long sig);


/******************************************************************************/
/*	FUNCTIONS: GLB_USRD																			*/
/******************************************************************************/
int			_initUserdef	(RSC *tab);
void			_exitUserdef	(RSC *tab);
int cdecl	_drawString		(PARMBLK *pb);
int cdecl	_drawNiceLine	(PARMBLK *pb);
int cdecl	_draw3dButton	(PARMBLK *pb);
int cdecl	_drawBakButton	(PARMBLK *pb);
int cdecl	_drawButton		(PARMBLK *pb);
int cdecl	_drawText		(PARMBLK *pb);
int cdecl	_drawFText		(PARMBLK *pb);
int cdecl	_drawBoxText	(PARMBLK *pb);
int cdecl	_drawFBoxText	(PARMBLK *pb);
int cdecl	_drawBox			(PARMBLK *pb);
int cdecl	_drawCroixCarre(PARMBLK *pb);
int cdecl	_drawPopUp		(PARMBLK *pb);


/******************************************************************************/
/*	FUNCTIONS: GLB_UTIL																			*/
/******************************************************************************/
void	_obPutStr				(OBJECT *tree,int objc,const char *str);
void	_putPath					(OBJECT *tree,int n,int len,char *name);
char	*_obGetStr				(OBJECT *tree,int objc);
int	_father					(OBJECT *tree,int child);
int	_rcIntersect			(GRECT *p1,GRECT *p2);
void	_setClip					(int flag,GRECT *area);
void	_clearAesBuffer		(void);
void	_mousework				(void);
void	_savePal					(void);
void	_loadPal					(int flag);
int	_word						(int val);
void	_initFont				(void);
void	_exitFont				(void);
void	_saveSys					(void);
void	*_Malloc					(long number);
int	_Mfree					(void *block);
int	_Mshrink					(int zero,void *block,long newsiz);
int	_winFindWin				(int handle);
int	_winFindId				(int type,int id,int open);
void	_winRedraw				(int i,int x,int y,int w,int h);
void	_coord					(OBJECT *tree,int obj,int larg,int *x,int *y,int *w,int *h);
void	_initPopUp				(OBJECT *tree,int obj,int popTree,int val);
void	_initXPopUp				(OBJECT *tree,int obj,char *tab,int nmb,int off,int len,int val);
int	_getPopUp				(OBJECT *tree,int obj);
void	_relocRSC				(long adr,myRSHDR *reloc);
void	_loadConfig				(void);
void	_saveConfig				(void);
void	_EGlibPop				(void);
void	_whichEdit				(int i,int *obj,int *pos);
void	_setEdit					(int i,int obj,int pos);


/******************************************************************************/
/*	FUNCTIONS GLB_WFRM																			*/
/******************************************************************************/
void	_winObdraw				(int i,OBJECT *tree,int obj, int dept, int x,int y,int w,int h);
int	_objcEdit				(OBJECT *tree,int obj,int kc,int *idx,int mode);
int	_winForm					(int tree,char *name,char *sname,char *help,int popup,int icon);
void	_myInitForm				(int obj,int n);
void	_keybdForm				(int i,int key);
void	_moveForm				(int i,int x,int y);
void	_clicForm				(int i,int mx,int my,int mk,int nmb);
void	_redrawForm				(int i,int x,int y,int w,int h);
void	_myCloseForm			(int i);
void	_closeForm				(int i);


/******************************************************************************/
/*	GLB_ASM																							*/
/******************************************************************************/
void	_cls						(long adr,long len);
long	_cookie					(long Cook);
long	_cookieJar				(void);
int	_vTOS						(void);
int	_AKP						(void);
int	_getBoot					(void);
long	_LONG						(long adr);
int	_CARD						(long adr);
char	_BYTE						(long adr);


/******************************************************************************/
/*	GLB_MOVE																							*/
/******************************************************************************/
void	_bmove					(long a,long,long l);

#endif
