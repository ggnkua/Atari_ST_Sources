/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/

/*******************************************************************************
	WORKING DEFINES:
		FOR DEFINITIVE RELEASE, ALL THIS DEFINES MUST BE CLEARED !

	FORCE_MALLOC:
		force certains index de malloc. Voir un peu plus loin dans le
		fichier les dÇfinitions MEM_FORCE DEFINES.
*******************************************************************************/
/*#define		FORCE_MALLOC*/

/*******************************************************************************
	DEFINES
*******************************************************************************/
#define		PRG_NAME		"Bitmap View IV"
#define		PRG_SNAME	"  Bv4  "
#define		RELEASE		"v4.2.2 (GPL)"
#define		NUM			20						/*Max images par dÇfaut*/
#define		WMINI			64
#define		HMINI			64
/*******************************************************************************
	MEM_FORCE DEFINES

	Surtout ne pas modifier l'ordre des index. Les blocs mÇmoire des
	index WIN/IMG/RSC ne doivent en aucun cas pouvoir àtre dÇplacÇs en
	mÇmoire par le memory manager sous peine de plantage !!
	Les donnÇes WIM/IMG/RSC sont chargÇes dans cet ordre !!
*******************************************************************************/
#define	MEM_WIN		0		/*	Structure des fenàtres		*/
#define	MEM_IMG		1		/*	Structure des images			*/
#define	MEM_RSC		2		/*	Fichier RSC+userdef			*/
#define	MEM_TRM		3		/*	PARX.TRM							*/
#define	MEM_RIM		4		/*	Modules RIM						*/
#define	MEM_WIM		5		/*	Modules WIM						*/
#define	MEM_IFX		6		/*	Modules IFX						*/
#define	MEM_FIRST	7		/*	Premier index de libre		*/


/*******************************************************************************
	INCLUDES
*******************************************************************************/
#include		"COMPAT.H"
#include		<stdio.h>
#include		<stdlib.h>
#include		<tos.h>
#include		"_AES.H"
#include		"_VDI.H"
#include		<ctype.h>
#include		<math.h>
#include		<string.h>
#include		<time.h>
#include		"PARX.H"
#include		"INTERN.RH"
#include		"INTERN.H"
#include		"RMOUSE\RMOUSE.H"
#include		"BV4_FR.H"
#include		"RSC.H"
#include		"WIN.H"

/*******************************************************************************
	MISCELLANEOUS DEFINITIONS
*******************************************************************************/
#ifndef TRUE
#define		FALSE				(BOOLEAN)0
#define		TRUE    			(BOOLEAN)1
#endif


/*******************************************************************************
	MAIN.C
*******************************************************************************/
void LigneDeCommande(void);
void _EGlib(void);
void menuOff(void);
void menuOn(void);
int _rcIntersect(GRECT *p1,GRECT *p2);
void _setClip(int flag,GRECT *area);
void _loadPal(int n);
int _word(int val);
void _sigQUIT(long ptr);
void _reportLog(long flag);
void _initReport(void);
void _exitReport(void);

/*******************************************************************************
	AES.C
*******************************************************************************/
void _gereAes(void);
void _menuBar(int obj,int flag);
int _StdKey(int shift,int key);
void _clearAesBuffer(void);
void _mousework(void);

/*******************************************************************************
	BV4_CNV.C
*******************************************************************************/
void convert(void);

/*******************************************************************************
	BV4_IMG.C
*******************************************************************************/
void wload(void);
int cdecl wopen(char *fname);
void fullscreen(int i);
void mosaique(void);
void closeImg(int i);
void closeAllImg(void);
void wsave(int i);
void wusave(int i);
void wprintGDOS(int i);
void wprintWIM(int i);
void wgen(void);
int trmConvert(int alert,int isrc,int *idst,int psrc,int *pdst,MFDB *src,MFDB *dst,int mask,int dith,int nforce);
void wZoom(int i);
void wNewOpen(int j,int imem,int pmem);

/*******************************************************************************
	BV4_MAIN.C
*******************************************************************************/
void initLast(void);
void cdecl exitFirst(void);
void gereMenu(int option);
void Finfo(void);
void setLog(void);
void Flog(void);
void Foption(void);
void Finterface(void);
void FoptionSEL(void);
void Fregister(void);
void Fslide(void);
void Fconvert(void);
void Fmodule(void);
void Fmemory(void);
void Fsystem(void);
int findIMG(int index);
void updFreeMem(void);
int isIMG(void);
void BoiteAcon(void);
void quit(void);
void _updatePath(char *pname);

/*******************************************************************************
	BV4_SLD.C
*******************************************************************************/
void slideshow(void);

/*******************************************************************************
	COL_ICON.C
*******************************************************************************/
int _addCicon(RSC *rsc,CICONBLK *cicnblk,OBJECT *obj,UBLK *obblk,CICON *cicon_table);
void _fillFarbTbl(void);
int _testRez(void);
int cdecl _drawCicon(PARMBLK *pb);

/*******************************************************************************
	INIT.C
*******************************************************************************/
int initAll(void);
void _initAes(void);
int _initMem(void);
int _initWin(void);
void _initVdi(void);
void _initGDOS(void);
void _initDiv(void);
int _initRsc(void);
void _initRWI(void);
void _initRIM(void);
void _initWIM(void);
void _initIFX(void);
void _initTRM(void);
void _initBRO(void);
void _initMOT(void);
void _initPAL(void);
void _initDesk(void);
void _initBox(void);
void _exitDesk(void);
void _exitRWI(void);
void _exitRsc(void);
void _exitVdi(void);
void _exitAes(void);
void _exitMem(void);

/*******************************************************************************
	INI_FILE.C
*******************************************************************************/
void _loadINI(int code);
void _saveINI(void);

/*******************************************************************************
	MEMORY.C
*******************************************************************************/
void _pDim(long len);
int _mAlloc(long len,int cls);
int _mAllocForce(int in,long len,int cls);
void _mFree(int i);
void _mSpecFree(long adr);
long _mDim(int i,long len,int cls,long off);
long _freeRam(int type);
void *_Malloc(long number,int type);

/*******************************************************************************
	MODULS.C
*******************************************************************************/
void _setModule(void);
void _setmodparam(void);
void _drawMod(void);
void _modInfo(int type,int n);
void _modConfig(int type,int n);
void _modDelete(int type,int n);
void _modAdd(int type);
void _modDefault(int type,int n);
int cdecl _addRim(char *name);
void _delRim(int i);
int cdecl _addWim(char *name);
void _delWim(int i);
int cdecl _addIfx(char *name);
void _delIfx(int i);

/*******************************************************************************
	POPUP.C
*******************************************************************************/
int _formMenu(OBJECT *tree,int obj);
int _formXmenu	(OBJECT *tree,int obj,char *tab,long off,int nmb,int loff,int roff,int len,int val);
void _initPopUp(OBJECT *tree,int obj,int popTree,int val,int hJust,int vJust,int Video);
void _initXPopUp(OBJECT *tree,int obj,char *tab,long off,int nmb,int loff,int roff,int len,int val);
int _getPopUp(OBJECT *tree,int obj);


/*******************************************************************************
	PROGRESS.C
*******************************************************************************/
void _progOn(void);
void _prog(char *tx1,char *tx2);
void _progOff(void);

/*******************************************************************************
	RSC_LOAD.C
*******************************************************************************/
int _loadRSC(RSC *rsc);
void _unloadRSC(RSC *rsc);
void _obPutStr(OBJECT *tree,int n,const char *str);
void _putPath(OBJECT *tree,int n,int len,char *name);
char *_obGetStr(OBJECT *tree,int objc);
int _father(OBJECT *tree,int child);
void _coord(OBJECT *tree,int obj,int larg,int *x,int *y,int *w,int *h);
void _initNum(OBJECT *tree,int obj,uint vmin,uint vmax,uint inc,uint val);
int _getNum(OBJECT *tree,int obj);

/*******************************************************************************
	RSC_INIT.C
*******************************************************************************/
void _initRSC(int obj,int n);

/*******************************************************************************
	RSC_CLIC.C
*******************************************************************************/
void _clicRSC(int obj,int n,int nmb);

/*******************************************************************************
	SLECTRIC.C
*******************************************************************************/
int _multifsel(char *pfname,char *pname,char *fname,char *ext,char *title,int cdecl (*call)(char *name));
int _fexist(char *name,DTA *res);
int _dexist(char *name);
int _fselect(char *pfname,char *pname,char *fname,char *ext,char *title);
int _slctExtPath(int ext_num, char *(*ext)[], int path_num, char *(*paths)[]);

/*******************************************************************************
	USERDEF.C
*******************************************************************************/
int cdecl _drawButton(PARMBLK *parm);
int cdecl _drawNiceLine(PARMBLK *parm);
int cdecl _drawCroixCarre(PARMBLK *parm);
int cdecl _drawPopUp(PARMBLK *parm);

/*******************************************************************************
	WIN.C
*******************************************************************************/
int _winOpen(window *win);
int _winFindWin(int handle);
int _winFindId(int type,int id,int open);
void _winName(int i,char *name,char *sname);
void _winRedraw(int i,int x,int y,int w,int h);
void _winTop(int i);
void _winUntop(int i);
void _winOntop(int i);
void _winBottom(int i);
void _winMakeTop(void);
void _winClose(int i);
void _winMove(int i,int xx,int yy);
void _winSize(int i,int w,int h);
void _winFull(int i);
void _winArrow(int i,int type);
void _winHslid(int i,int pos);
void _winVslid(int i,int pos);
void _winClic(int i,int x,int y,int k,int nmb);
void _winSmall(int i);
void _winUnSmall(int i);
void _winAlign(void);

/*******************************************************************************
	WIN_FORM.C
*******************************************************************************/
int _winForm(int tree,char *name,char *sname,int ic_tree,int icon,int type,int xtype);
void cdecl _keybdForm(int i,int key);
void cdecl _redrawForm(int i,int x,int y,int w,int h);
void cdecl _moveForm(int i,int x,int y);
void cdecl _clicForm(int i,int x,int y,int k,int nmb);
void _winObdraw(int i,OBJECT *tree,int obj, int dept, int x,int y,int w,int h);
void _whichEdit(int i,int *obj,int *pos);
void _setEdit(int i,int obj,int pos);

/*******************************************************************************
	PARX_RIM.C
*******************************************************************************/
PARX_RIM *_rimAdr(int n);
int _rimLoad(int alert,char *name,long *flen,MFDB *img,char *txt,int *imem,int *pmem,int n);

/*******************************************************************************
	PARX_WIM.C
*******************************************************************************/
PARX_WIM *_wimAdr(int n);
int _wimSave(int alert,MFDB *img,int imem,int pmem,int fcol,int fsel,char *pname,char *fname,char *title);
int _wimPrint(int imem,int pmem,MFDB *img);

/*******************************************************************************
	PARX_TRM.C
*******************************************************************************/
int _trmInit(void);
int _trmExit(void);
int _trmConvert(int alert,int isrc,int *idst,int psrc,int *pdst,MFDB *msrc,MFDB *dst,int mask,int dith,int nforce);
int _trmZoom(int alert,int isrc,int *idst,int psrc,int *pdst,MFDB *msrc,MFDB *dst,int mask,int dith,int nforce);

/*******************************************************************************
	PARX_IFX.C
*******************************************************************************/
PARX_IFX *_ifxAdr(int n);

/*******************************************************************************
	GDOS_PRT.C
*******************************************************************************/
void _GdosPrintImg(int isrc,int psrc,MFDB *src);
void _GdosPrintCancel(void);
void _GdosPrintContinue(void);
int _GdosPrintInit(void);

/*******************************************************************************
	ASM.S
*******************************************************************************/
long _cookie(long Cook);
long _cookieJar(void);
int _getBoot(void);
int _vTOS(void);
int _AKP(void);
long _LONG(long adr);
int _CARD(long adr);
char _BYTE(long adr);

/*******************************************************************************
	CLS.S
*******************************************************************************/
void _cls(long adr,long len);

/*******************************************************************************
	MOVE.S
*******************************************************************************/
void _bmove(long a,long,long l);

/*******************************************************************************
	PROTOCOLE AV
*******************************************************************************/
#define	VA_START		0x4711

/*******************************************************************************
	LOG DEFINES
*******************************************************************************/
#define	LOG_FORCE	0xFF
#define	LOG_INI		0x01L
#define	LOG_MEM		0x02L
#define	LOG_TRM		0x04L
#define	LOG_RIM		0x08L
#define	LOG_WIM		0x10L
#define	LOG_IFX		0x20L

/*******************************************************************************
	KEYBOARD DEFINES
*******************************************************************************/
#define	K_NIL			0x00			/*	No Key				*/
#define	K_UP			0x01			/*	Cursor UP			*/
#define	K_DOWN		0x02			/*	cursor DOWN			*/
#define	K_RIGHT		0x03			/*	cursor RIGHT		*/
#define	K_LEFT		0x04			/*	cursor LEFT			*/
#define	K_BS			0x08			/*	BACKSPACE			*/
#define	K_TAB			0x09			/*	TAB					*/
#define	K_ENTER		0x0A			/*	ENTER					*/
#define	K_INS			0x0B			/*	INSERT				*/
#define	K_CLRHOME	0x0C			/*	CLR-HOME				*/
#define	K_RETURN		0x0D			/*	RETURN				*/
#define	K_HELP		0x0E			/*	HELP					*/
#define	K_UNDO		0x0F			/*	UNDO					*/
#define	K_F1			0x10			/*	Function Key #1	*/
#define	K_F2			0x11			/*	Function Key #2	*/
#define	K_F3			0x12			/*	Function Key #3	*/
#define	K_F4			0x13			/*	Function Key #4	*/
#define	K_F5			0x14			/*	Function Key #5	*/
#define	K_F6			0x15			/*	Function Key #6	*/
#define	K_F7			0x16			/*	Function Key #7	*/
#define	K_F8			0x17			/*	Function Key #8	*/
#define	K_F9			0x18			/*	Function Key #9	*/
#define	K_F10			0x19			/*	Function Key #10	*/
#define	K_ESC			0x1B			/*	ESCAPE				*/
#define	K_DEL			0x7F			/*	DELETE				*/

#define	KF_FUNC		0x4000		/*	Function flag		*/
#define	KF_NUM		0x2000		/*	Numeric pad			*/
#define	KF_CAPS		0x1000		/*	CapsLock				*/
#define	KF_ALT		0x0800		/*	Alternate			*/
#define	KF_CTRL		0x0400		/*	Control				*/
#define	KF_SHIFT		0x0300		/*	any Shift			*/
#define	KF_LSH		0x0200		/*	Left Shift			*/
#define	KF_RSH		0x0100		/*	Right Shift			*/


/*******************************************************************************
	MEMORY DEFINES
*******************************************************************************/
#define	NO_MEMORY	-1													/*	No lib memory	*/
#define	SWP_MEMORY	-2													/*	Swapped memory	*/
#define	ST_ONLY		0
#define	TT_ONLY		1
#define	ST_PREF		2
#define	TT_PREF		3


/*******************************************************************************
	LANGUAGE DEFINES
*******************************************************************************/
#define	L_FRENCH		0
#define	L_ENGLISH	1
#define	L_DEUTSCH	2


/*******************************************************************************
	PARX DEFINES
*******************************************************************************/
#define	P_RIM		0x1
#define	P_WIM		0x2
#define	P_IFX		0x4
#define	P_TRM		0x8
#define	P_MEM		0x10
#define	P_BRO		0x20
#define	P_MOT		0x40
#define	P_PAL		0x80


/*******************************************************************************
	OTHER DEFINES
*******************************************************************************/
#define	max(A,B)			( (A) > (B) ? (A) : (B) )
#define	min(A,B)			( (A) < (B) ? (A) : (B) )
#define	LOG_MAX			256


/*******************************************************************************
	struct for ME moduls
*******************************************************************************/
typedef struct
{
	int	n;					/*	NumÇro du module	*/
	char	name[32];		/*	Nom du module		*/
}	MODSTR;



/*******************************************************************************

	Selectric support (The *best* fileselector replacement)

*******************************************************************************/
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



/*******************************************************************************
	This struct contains all the parameters of the lib
*******************************************************************************/
typedef struct
{
	struct
	{
		int		id;							/*	AES handle						*/
		int		ver;							/*	AES version						*/
		int		type;							/*	application flag				*/
		MFORM		s[1+FMOUDN];				/*	mouse form				*/
		int		top;							/*	TOPped window			*/
		int		x,y,w,h;
		int		buf[8];
		int		evnt;
		int		kst;
		int		key,std;
		int		mx,my,mk;
		int		nmbClic;
		int		Old_Tree;
		int		Old_Icon;
		int		fmod;
		int		wmod;
		int		sel_icn;
		int		icon;							/*	APP Iconified window			*/
		int		win;
		struct
		{
			int		x;							/*	x dim of desk					*/
			int		y;							/*	y dim of desk					*/
			int		w;							/*	w dim of desk					*/
			int		h;							/*	h dim of desk					*/
			int		first_icon;				/*	Number of first icon			*/
			int		trash_icon;				/*	Number of trash icon			*/
			int		print_icon;				/*	Number of printer icon		*/
			int		scrap_icon1;			/*	Number of empty clipboard	*/
			int		scrap_icon2;			/*	Number of full clipboard	*/
			int		trame1;
			int		color2;
			int		trame2;
			int		color4;
			int		trame4;
		}	desk;
		struct
		{
			struct
			{
				int	bevent;
				int	multitask;
			}	sys;
		}	info;
		struct
		{
			int		menu;						/*	RSC tree for MENU				*/
			int		desk;						/*	RSC tree for DESK				*/
			int		icon;						/*	Tree which contains icons	*/
		}	tree;
		struct
		{
			int		flag;						/*	evnt_multi flag				*/
			int		f1,x1,y1,w1,h1;		/*	in/out rect 1					*/
			int		f2,x2,y2,w2,h2;		/*	in/out rect 2					*/
			int		t1;						/*	timer low byte					*/
			int		t2;						/*	timer high byte				*/
		}	event;
	}	aes;

	RSC		rsc;								/*	program RSC header			*/

	struct
	{
		int		ha;							/*	VDI handle						*/
		int		out[57];						/*	VDI parameters					*/
		int		extnd[57];					/*	VDI parameters					*/
		int		xscr;							/*	x dim of screen				*/
		int		yscr;							/*	y dim of screen				*/
		int		wscr;							/*	w dim of screen				*/
		int		hscr;							/*	h dim of screen				*/
		int		wcell;						/*	text cellul width				*/
		int		hcell;						/*	text cellul height			*/
		int		wbox;							/*	box width						*/
		int		hbox;							/*	box height						*/
		int		gdos;							/*	flag GDOS						*/
		int		vgdos;						/*	Version of GDOS				*/
		int		low;							/*	low rez flag					*/
		int		pal;							/*	index memoire pal VDI		*/
	}	vdi;

	struct
	{
		int		Win_Num;						/*	Number of windows				*/
		int		Mem_Num;						/*	Number of memory blocs		*/
		long		Mem_Len;						/*	Len of allocated memory		*/
		int		Mem_Boot;					/*	Len of memory at init		*/
		int		Mouse_Form;					/*	Form to mouse					*/
		int		Flash_PopUp;				/*	Flash the selected option	*/
		int		Save_Config;				/*	Save config at exit			*/
		int		Auto_Icon;					/*	Auto align icon				*/
		int		Rev_Horiz;					/*	Reverse horizontal			*/
		int		Rev_Verti;					/*	Reverse vertical				*/
		int		mask;							/*	Pour pavÇ DEMOVERSION*/
		int		win;
		int		trm;
		int		MAJ;
		int		useExt;
		int		usePat;
		int		gfx;							/*	Flag graphic card		*/
		int		zap;							/*	Load to icon			*/
		int		pal;							/*	Force unique palette	*/
		int		deskfull;					/*	slide: partial full	*/
		int		is_tv;
		int		is_led;
		int		in;							/*	ind.mem. pavÇ DEMO	*/
		int		d_trm;						/*	Tramage par dÇfaut	*/
		char		ext[11][6];					/*	Extensions				*/
		char		pat[11][FILENAME_MAX];	/*	Chemins					*/
		char		sl_pfname[FILENAME_MAX];/*	slide: nom complet	*/
		char		sl_path[FILENAME_MAX];	/*	slide: chemin			*/
		char		sl_name[FILENAME_MAX];	/*	slide: extension		*/
		int		sl_pause;					/*	slide: pause			*/
		int		sl_ptime;					/*	slide: temps pause	*/
		int		sl_tv;						/*	slide: Turbo Veille	*/
		int		sl_led;						/*	slide: LedPanel		*/
		int		sl_info;						/*	slide: nom image		*/
		int		sl_loop;						/*	slide: boucle			*/
		int		sl_rec;						/*	slide: recursive		*/
		int		sl_zdec;						/*	slide: zoom reduit	*/
		int		sl_zinc;						/*	slide: zoom agrandit	*/
		int		cnv_del;						/*	convert: effacer		*/
		int		cnv_col;						/*	convert: nbre plans	*/
		int		zoom_hq;						/*	zoom: high quality	*/
		int		zoom_rep;					/*	zoom: replace image	*/
		char		cnv_pfname[FILENAME_MAX];/*	convert: source	*/
		char		cnv_path[FILENAME_MAX];	/*	convert: source		*/
		char		cnv_name[FILENAME_MAX];	/*	convert: source		*/
		char		cnv_dst[FILENAME_MAX];	/*	convert: destination	*/
		int		Language;					/*	Language							*/
		char		INI_File[FILENAME_MAX];	/*	File w/Path to EGLIB.INI	*/
		char		LOG_File[FILENAME_MAX];	/*	File w/Path to EGLIB.LOG	*/
		char		APP_Path[FILENAME_MAX];	/*	Path to prg sys folder		*/
		char		Prog_Name[16];				/*	Program name					*/
		int		log;							/*	Activation LOG					*/
		int		baklog;						/*	Sauvegarde du flag log		*/
		long		logmask;						/*	Masque pour le LOG			*/
		long		baklogmask;					/*	Sauvegarde mask log			*/
	}	opt;

	struct
	{
		int	type;
		long	tfre;								/*	Total free lenght				*/
		long	tlen;								/*	Total lenght					*/
		long	*adr;								/*	blocs' adresse					*/
		long	*len;								/*	blocs' len						*/
		long	free;
		long	mem;
	}	mem;

	struct
	{
		int		Active;		/*	Modules actifs							*/
		int		n_rim;		/*	Nombre de RIM							*/
		int		i_rim;		/*	Index mÇmoire des RIM				*/
		int		p_rim;		/*	Index mÇmoire du popup des RIM	*/
		int		n_wim;		/*	Nombre de WIM							*/
		int		i_wim;		/*	Index mÇmoire des WIM				*/
		int		p_wim;		/*	Index mÇmoire du popup des WIM	*/
		int		n_ifx;		/*	Nombre de IFX							*/
		int		i_ifx;		/*	Index mÇmoire des IFX				*/
		int		p_ifx;		/*	Index mÇmoire du popup des IFX	*/
		int		i_trm;		/*	Index mÇmoire des TRM				*/
		int		p_trm;		/*	Index mÇmoire du popup des TRM	*/
		int		i_bro;		/*	Index mÇmoire des BRO				*/
		int		i_mot;		/*	Index mÇmoire des MOT				*/
		int		i_pal;		/*	Index mÇmoire des PAL				*/
		int		d_rim;		/*	RIM par dÇfaut							*/
		int		d_wim;		/*	WIM par dÇfaut							*/
		int		d_ifx;		/*	IFX par dÇfaut							*/
		int		d_trm;		/*	TRM par dÇfaut							*/
		char		Path[FILENAME_MAX];		/*	Path to sys folder*/
		int		Mask;							/*	Mask of elements	*/
		char		def_rim[10];				/*	Default rim id		*/
		char		def_wim[10];				/*	Default wim id		*/
		char		def_ifx[10];				/*	Default ifx id		*/
		int		setmod;
		int		setdef;
		int		strin;
		int		strnmb;
		int		def_dim;
		int		def_xdim;
		int		def_ydim;
	}	parx;

	struct
	{
		int			dev;
		int			max;
		int			out;
		int			xcenter;
		int			ycenter;
	}	print;

	struct
	{
		int		farb[256][32];
		ulong		farb2[32];
		int		pal[256][4];
		int		xpixel;
	}	icn;

	struct
	{
		void	cdecl	(*eFirst)(void);						/*	First exit		*/
	}	func;

	struct
	{
		char		path[FILENAME_MAX];		/*	current directory				*/
		int		AccOp;						/*	open ACC flag					*/
		int		Exit;							/*	exit flag						*/
		int		MCH;							/*	machine type					*/
		int		TOS;							/*	TOS version						*/
		long		*fsel;
		char		log[LOG_MAX];
		char		pname[FILENAME_MAX];
		char		pfname[FILENAME_MAX];
		char		fname[14];
		char		ext[14];
		char		tit[40];
		char		buf[10240];
		char		SWP_Path[FILENAME_MAX];	/*	Path to TMP folder*/
		int		mouse;
		int		win;
		int		avail_fr;				/*	Franáais disponible	*/
		int		avail_uk;				/*	Anglais disponible	*/
		int		avail_de;				/*	Allemand disponible	*/
		int		slide;
	}	div;
}	GLB;


/*******************************************************************************
	STRUCTURE DE DONNEES POUR UNE IMAGE
*******************************************************************************/
typedef struct
{
	MF_RIM	mfdb;
	char		name[14];		/*	Nom du fichier				*/
	char		iname[10];		/*	Nom image					*/
	char		type[32];		/*	Description du RIM		*/
	long		flen;				/*	Taille fichier				*/
	int		flag;				/*	Image utilisÇe ?			*/
	int		num;				/*	NumÇro pour multiimg		*/
	int		oldw,oldh;		/*	Dimension dÇpart			*/
	int		oldplanes;		/*	Nbre plans dÇpart			*/
	uint		x,y,w,h;			/*	position de la fenàtre	*/
	uint		oldx,oldy;		/*	Pour le fuller				*/
	uint		cx,cy,cw,ch;	/*	Decoupe fenàtre			*/
	uint		cflag;			/*	flag de dÇcoupe			*/
}	IMG;


/*******************************************************************************
	STRUCTURE DE DONNEES POUR TURBO VEILLE
*******************************************************************************/
typedef struct
{
	uint	dum;
	uint	ver;			/*	Version TurboVeille au format $0000xxyy						*/
	ulong	beg;			/*	DÇbut du programme (apräs la basepage) (TEXT)				*/
	ulong	key_rtn;		/*	Routine clavier TurboVeille (adresse)							*/
	ulong	vbl_rtn;		/*	Routine VBL TurboVeille (adresse)								*/
	ulong	vbl_count;	/*	Compteur de VBL pour Çteindre l' Çcran (en VBLs)			*/
	ulong	key_old;		/*	Sauvegarde de l'ancienne routine clavier TOS (adresse)	*/
	ulong	vbl_nmb;		/*	DÇlai avant extinction (en nombre de VBLs)					*/
	ulong	len_res;		/*	Taille du programme rÇsident (basepage incluse) en octets*/
	uchar	rsvd1[17];
	uchar	status;		/*	Status "Çteint" ($FF=allumÇ $0=Çteint)							*/
	uint	freq;			/*	FrÇquence VBL de TV (en Hz)										*/
	uint	rsvd2;
	uchar	line;			/*	Effacer 1e ligne Çcran en veille (Çvite les parasites)	*/
	uchar	stop;			/*	Etat activÇ (0) ou STOP ($FF) (Version>1.15)					*/
}	VEIL;


/*******************************************************************************
	STRUCTURE DE DONNEES POUR LEDPanel
*******************************************************************************/
typedef struct
{
	struct
	{
		long magic;		/*	magische Zahl MAGIC							*/
		int version;	/*	Versionsnummer und							*/
		long verdate;	/*	Datum des LED-Panels							*/
		int varlen;		/*	LÑnge der Patch-Area in Bytes				*/
		int light;		/*	Flag fÅr "light"-Version					*/
	}	header;
	int	active;		/*	Flag fÅr Anzeige aktiv						*/
}	LEDP;


/****************************************************************************
	VARIABLES
****************************************************************************/
extern	IMG			*img;
extern	long			tfre;
extern	int			Curr;
extern	int			Break;
extern	int			working;
extern	GLB		glb;					/*	global parameter struct						*/
extern	window	*W;					/*	global window struct							*/
extern	SLCT_STR	*slct;				/*	For use with Slectric (see GLB_FSEL)	*/
