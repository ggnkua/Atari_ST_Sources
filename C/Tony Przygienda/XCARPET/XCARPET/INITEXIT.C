/********************************************************************
 *
 *  initexit.c		projekt : xcarpet
 *-------------------------------------------------------------------
 *  initialisierungen, startprozeduren ...
 *-------------------------------------------------------------------
 *
 *
 ********************************************************************/
 
 /*  april 88	Åbernahme der quelle 'carpet.c' von tony przygienda
  *  13. 5.	auslagerung von 'initexit.c'
  */

#include "..\carpet.h"

#include <stdio.h>
#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif
#include <portab.h>
#if COMPILER==TURBOC
	#include <aes.h>
	#include <vdi.h>
	#include <stdlib.h>
	#include <tos.h>
	#include "..\initexit.h"
#endif

#include "..\monorsc.h"	 	/* resource definitions */
#include "..\colorrsc.h"


/* all variables imported from INOUT */

extern char    func_string[]; /* enthÑlt string der Funktionsgleichung */
extern double  xstart,xend,ystart,yend; /* definition range of function */
extern double  consta,constb,constc;  /* Werte der Konstanten */
extern double  xangle,zangle; /* rotation angles of the carpet in 3D-space */
extern double  look_x,look_y,look_z,plane_y; /* coordinates of the view-point */
extern int     light_x,light_y,light_z; /* of the light source */
extern int     xlines,ylines; /* resolution, how much line does it need */
extern int     xres,yres;
#if COMPILER==TURBOC
	#include "..\inout.h"
#endif


/* from CALC module */
#if COMPILER==TURBOC
	#include "..\calc.h"
#endif
extern boolean counted2d,counted3d,shadowed,inferior,funcgiven,filegiven;
extern boolean countedfl; /* brauche zur Feststellung ob berechnet */

/* from TREE module */
#if COMPILER==TURBOC
	#include "..\tree.h"
#endif
extern void give_function(); 
extern boolean error; /* eventuell Fehler aufgetreten */
extern double variables[];


/* from GEMHELP */
extern void show_mouse(),hide_mouse();
#if COMPILER==TURBOC
	#include "..\gemhelp.h"
	#include "..\multi.h"  /* wegen check */
#endif


#if COMPILER==TURBOC
	#include "..\xcarpet.h"   /* wegen memory_error */
#endif


/* Variablen globale */
WORD contrl[12];    /* control input          */
WORD intin[128];    /* max string length       */
WORD ptsin[128];    /* polygon fill points     */
WORD intout[128];   /* open workstation output */
WORD ptsout[128];
WORD work_in[11];
WORD work_out[57];

static int  aes=FALSE,rsc=FALSE,vdi=FALSE;  /* angemeldet oder nicht ? */

WORD gr_hwchar;   /* character width      */
WORD gr_hhchar;   /* character height      */
WORD gr_hwbox;     /* box (cell) width      */
WORD gr_hhbox;     /* box (cell) height      */
WORD gr_hspace;   /* height of space between lines */
int  colours;    /* how much colours allows the resolution !! */

/* Variablen des Programms, direkt von Resource gesetzt */

OBJECT *menu_tree = NIL;  /* Adress of the pulldown */
OBJECT *icons_tree = NIL; /* Adress of the icons   */
WORD gr_handle;   /* physical workstation handle   */
WORD handle;     /* virtual workstation handle    */
WORD wi_handle =  NO_WINDOW;/* window handle     */
WORD top_window = NO_WINDOW;
WORD ap_id;

int  xdesk, ydesk,hdesk,wdesk; /* the size of the desktop window */
int  xwork, ywork,hwork,wwork; /* window absolute Koordinates and size */
int  xpict, ypict,hpict,wpict; /* x,y are the coordinates of the upper */
                               /* corner of the window in the graphics */
                               /* the h&w concerns the help graph page */
                               
/* Konstanten des RSC Files, abhÑngig von Auflîsung und von der Routine */
/* rscConstSet initialisiert */

/* pulldown-titel (vt...), menÅpunkte (vm...), bÑume + objekte	*/

				/*  menÅ-titel	(pulldown)	*/
int vpulldown, vtinfo, vtdata, vtaction, vtconst, vthelp; 

				/*  desk- und daten-menÅ	*/
int vminfo;
int vmfile, vmfunc, vmsavemode, vmsave;
int vinfo,vmyname;
int vinputfun,vfunc1,vfunc2,vxstart,vxend,vystart,vconsta,vconstb,vconstc;

				/*  action-menu			*/
int vmdrawf, vmhardcopy, vmexit;
int vdrawfun,vcount3d,vcount2d,vcountfl,vcountsh;

				/*  konstanten-menÅ		*/
int vmrotate,vmview,vmlight,vmresol,vmdrawmode,vmdegree,vmradiant;
int vrotation,vzrotate,vxrotate;
int vview,vlookx,vlooky,vlookz,vplaney;
int vlight,vlightx,vlighty,vlightz,vrahmein;
int vdrawmode,vxraster,vyraster,vxyraster,vcentral,vparallel,
    vwire,vhidden,vshadow;
int vresoluti,vxlinien,vylinien;
int vstartinf;  /* Anfangsdialog */
int vsavemode,votimg,votstad,votdegas,votdoodle,votascii;

				/*  help-menÅ			*/
int vmhstad,vmhfunc,vmhspecf,vmhrotate,vmhview,vmhresol,vmhdraw; 
int vhfunct,vhrotate,vhprojekt,vhresol,vhdraw,vhspecf,vhstad;

				/*  icons und sonstiges		*/
int vsyserror,vqsyserr,vsavefun;
int vicons,vdesktop,visave,viinputf,vidrawf,virotate,vilight,viview,viresol,vistyle; /* icons */
int vmemostat,vhelpkey; /* memory free */


char    pic_format;
boolean degree;      /* are all the angles in programs in degree or not ?*/

int     drawmode; /* gives information about the graph's resolution */
boolean central; 		/* orthogonal or central projection */
boolean xraster,yraster;	/* zu zeichnende rasterlinien	    */

#if COMPILER==MEGAMAX
	extern char *malloc();
	extern long xbios();
#endif

FDB source,target;
char *reserved_screen=NIL; /* zur Rettung des Bildschirms dienend ! */

long screenbytes=0; 	/* how much bytes contains an normal screen */

void aes_exit()		{  appl_exit();  		}

void close_vwork()	{  v_clsvwk(handle);	}

static boolean aes_init()			/* inits aes */
{
  ap_id = appl_init();
  gr_handle = graf_handle(&gr_hwchar,&gr_hhchar,&gr_hwbox,&gr_hhbox);
  
  return (TRUE);
}

double farbe(double x, int i)
{
#define c1f1		 616.017E-12
#define c2f1		-1.42706E-08
#define c3f1		-1812.48379E-8
#define c4f1		-232.67955E-4
#define c5f1		-14.04161
#define c1f2		10.035E-4
#define c2f2		708.17328e-4
#define c3f2		133.41216e0
#define c1f3		8841.647e-4
#define c2f3		188.9011

switch (i)
	{
	case 0:	
		return (((c1f1*x+c2f1)*x+c3f1*x)*x+c4f1)*x+c5f1;
	case 1:
		return (c1f2*x+c2f2)*x+c3f2;
	case 2:
		return (c1f3*x+c2f3);
	default:
		puts("Error, colour unknown \n");
		return 0.;
	}					
}

static boolean open_vwork()		/* opens virtuall work station */
{
  register int i,j;

  static int background[]= { 0,0,429 };
  static int foreground[]= { 572,572,572 };
  static int stdcolours[][3]={  {143,0,0}, {286,143,0}, {429,143,0},
                   {429,286,0}, {572,286,0}, {572,429,0}, {715,429,0},
                   {715,572,0}, {858,715,0}, {858,858,286},
                   {858,1000,286}, {1000,1000,429}, {1000,1000,715},
                   {1000,1000,1000}, {-1,-1,-1} };
  static int newcolour[3];

  for(i=0;i<10;work_in[i++]=1);     /* init string for VDI routine */
  work_in[10]=2;
  v_opnvwk(work_in,&handle,work_out); /* call VDI open virtual workstation */
  colours=work_out[13];               /* how much colours to manage        */
  vs_color(handle,0,background);
  vs_color(handle,1,foreground); /* standards */

	if (colours<=16)
		{
		i=2;
		while (i<=colours && stdcolours[i-2][0]!=-1)
			{
			vs_color(handle,i,stdcolours[i-2]);
			i++;
			}
		}
	else /* Regression ranlegen ! */
		{
		register double step=1024./(colours-2);
		register double colr=0.;
		
		for (i=2;i<=colours; i++);
			{
			for (j=0;j<3; j++)
				{
				newcolour[j]=farbe(colr,j);
				newcolour[j]=(newcolour[j]<0    ? 0    : newcolour[j]);
				newcolour[j]=(newcolour[j]>1024 ? 1024 : newcolour[j]);
				}
			colr+=step;
			vs_color(handle,i,newcolour);	
			}
		}				
 
  return (TRUE);
}

static boolean init_rsc()
{
#if COMPILER==TURBOC
	void RscConstSet(void);
#endif

  boolean abbruch;
  static char mrscname [] = "monorsc.rsc";
  static char crscname [] = "colorrsc.rsc";

  abbruch = (colours>2 ? !rsrc_load(crscname): !rsrc_load(mrscname)) ;
  if (abbruch)
    {
    form_alert(1,"[1][Sorry ! Resource nicht da ...][ Tja... ]");
    }
  else
    { 	/* setzt alle RSC Konstanten in entsprechende Variablen */   
    RscConstSet();  
	 abbruch = !rsrc_gaddr(R_TREE,vpulldown,&menu_tree); 
    if (abbruch)
    	{
    	form_alert(1,
      	"[1][Was ist das fÅr|ein Resource ?..][ Ich dachte... ]");
    	}
    }
  return !abbruch;
}

int init_carpet()
{ 
#if COMPILER==TURBOC
	boolean aes_init(void),open_vwork(void),init_rsc(void);
	void exitus(void);
#endif

  int ok;
  
  ok=aes=aes_init();
  vdi=open_vwork();
  ok= ok && vdi;  
  if (ok)
  		rsc=init_rsc();
  
  ok = ok && rsc;
  if (ok)
    {
    hide_mouse();
  	 }
  else
    exitus();		/* sofortiger abbruch bei startfehlern	*/
    
  return (ok);
}

void exitus ()
{
#if COMPILER==TURBOC
	void aes_exit(void),close_vwork(void);
	int rsrc_free(void);
#endif

   show_mouse();
   
   if (rsc) rsrc_free();
   if (vdi) close_vwork();
   if (aes) aes_exit();
   
   exit (0);
}

void init_variables()
{
  OBJECT *dial_adr;

			/* zuerst Menumarks lîschen oder setzen */
  pic_format=FIMG;
  write_savemode();
  
  degree=TRUE;
  uncheck(vmradiant);
  check(vmdegree);

  drawmode=HIDDENMODE;
  central=FALSE;
  xraster=yraster=TRUE;
  write_drawmode();

  /* ... des Function Input Formulars !! */
  func_string[0]='\0';
  xstart=ystart=-2.;
  xend=yend=2.;
  consta=constb=0.;
  constc=PI;
  write_forminp();

  xangle=40.;
  zangle=20.;
  write_rotate();

  look_x=0.;
  look_y=1200.;
  look_z=0.;
  plane_y=600.;
  write_view();

  light_x=0;
  light_y=1000;
  light_z=500;
  inferior=TRUE; /* Umrahmung ein */
  write_light();

  xlines=ylines=10;
  xres=yres=xlines+1;
  write_resolution();

  counted3d=counted2d=FALSE;
  funcgiven=FALSE; /* noch keine Funktion */
  filegiven=FALSE; /* noch keine */
  error=FALSE; /* vorsichtshalber */

  rsrc_gaddr(R_TREE,vinputfun,&dial_adr);
  ((char *)((TEDINFO *) dial_adr[vfunc2].ob_spec)->te_ptext)[0]='\0';
  ((char *)((TEDINFO *) dial_adr[vfunc1].ob_spec)->te_ptext)[0]='\0';
}

void show_startmessage()
{
  OBJECT *dial_adr;

  rsrc_gaddr (R_TREE,vstartinf,&dial_adr);
  undo_obj(dial_adr,hndl_dial(dial_adr,0,xdesk/2,ydesk/2,1,1),SELECTED);
}

void test_name()
/* diese Routine nicht Ñndern, da sonst das ganze Programm einen RIESEN-, */
/* RIESENABSTURZ liefert und Euer Computer in einen C64 verwandelt wird,  */
/* mit der Tastatur eines ZX81, Schnelligkeit eines TI99 und dem Monitor  */
/* eines Schneiders, dazu wird der noch IBM kompatibel (Kotz, Kotz !!!)   */
{
  char *b;
  OBJECT *a;
  int worth=0; /* checksumme, bitte, bitte nicht Ñndern */

  rsrc_gaddr(R_TREE,vinfo,&a);
  b=((TEDINFO *) a[vmyname].ob_spec)->te_ptext;
  while (*b)
   worth^=*(b++);
  if (worth!=64) /* Konstante, um Deine Kiste in 'nen 64!er zu Ñndern */
   {
   form_alert(1,"[1][I hate people changing|my resource ...][ Sorry ]");
   exit(0);
   /* keine Freigabe von Speicherplatz, soll ihm doch die Kiste absaufen */
   }
}

static void RscConstSet()
	/* sets all const-var depending on the read resource file */
{
  if (colours>2)
   {
   vpulldown=CPULLDOW; vtinfo=CTINFO; vtdata=CTFILE; vtaction=CTFUNC;
   vtconst=CTCONST; vthelp=CTHELP; 
   
   vminfo=CMINFO; vmfile=CDATEI; vmfunc=CFUNKTIO; 
   vmsavemode=CMSAVEMO;
   vmsave=CMSAVE; 
   
   vmdrawf=CMDRAWF; vmhardcopy=CHARDCOP; vmexit=CQUIT;
   
   vmrotate=CMROTATE; vmview=CMVIEW; vmlight=CMLIGHT; vmresol=CMRESOL; 
   vmdrawmode=CDARSTEL; vmdegree=CMDEGREE; vmradiant=CMRADIAN;

   vmhstad=CMHSTAD; vmhfunc=CMHFUNC; vmhspecf=CMHSPECF;
   vmhrotate=CMHROTAT;vmhview=CMHVIEW;vmhresol=CMHRESOL;vmhdraw=CMHDRAW; 

   vinfo=CINFOFOR; vmyname=CMYNAME;
   
   vinputfun=CINPUTF; vfunc1=CFUNC1; vfunc2=CFUNC2; vxstart=CXSTART;
   vxend=CXEND; vystart=CYSTART; vconsta=CCONSTA; vconstb=CCONSTB; 
   vconstc=CCONSTC;
   
   vdrawfun=CDRAWFUN; vcount3d=CCOUNT3D; vcount2d=CCOUNT2D; vcountfl=CCOUNTFL;
   vcountsh=CCOUNTSH;
   
   vrotation=CROTATIO; vzrotate=CZROTATE; vxrotate=CXROTATE;
   vview=CVIEW; vlookx=CLOOKX; vlooky=CLOOKY; vlookz=CLOOKZ; vplaney=CPLANEY;

   vresoluti=CRESOLUT; vxlinien=CXWERTE; vylinien=CYWERTE;

   vdrawmode=CGRAFMOD;
   vxraster=CXRASTER; vyraster=CYRASTER; vxyraster=CXYRASTE;
   vcentral=CZENTRAL; vparallel=CNORMALP;
   vwire=CDRAHT; vhidden=CHIDDEND; vshadow=CSUNSHIN;
   
   vhfunct=CHFUNCT; vhrotate=CHROTATE; vhprojekt=CHPROJEK; vhresol=CHRESOL;
   vhdraw=CHDRAW; vhspecf=CHSPECF; vhstad=CHSTAD; /* helps */
 
   vsyserror=CSYSERRO; vqsyserr=CQSYSERR; vsavefun=CSAVEFUN;
   vlight=CLIGHT; vlightx=CLIGHTX; vlighty=CLIGHTY; vlightz=CLIGHTZ;
   vrahmein=CRAHMEIN;
   vstartinf=CSTARTIN;
   vicons=CICONS; vdesktop=CDESKTOP; visave=CISAVE; viinputf=CIINPUTF;
   vidrawf=CIDRAWF; virotate=CIROTATE; vilight=CILIGHT; viview=CIVIEW;
   viresol=CIRESOL; vistyle=CISTYLE; /* icons */
   vmemostat=CMEMOSTA;
   vhelpkey =0;
   
	vsavemode=COUTPUT; votimg=COTIMG; votstad=COTSTAD;
	votdegas=COTDEGAS; votdoodle=COTDOODL; votascii=COTASCII;
/*	hier noch ohne farbe !!! 	*/
   }
  else /* monochrom */
   {
   vpulldown=PULLDOWN; vtinfo=TINFO; vtdata=TFILE; vtaction=TFUNC;
   vtconst=TCONST; vthelp=THELP; 
   
   vminfo=MINFO; vmfile=DATEI; vmfunc=FUNKTION; 
   vmsavemode=MSAVEMOD;
   vmsave=MSAVE; 
   
   vmdrawf=MDRAWF; vmhardcopy=HARDCOPY; vmexit=QUIT;
   
   vmrotate=MROTATE; vmview=MVIEW; vmlight=MLIGHT; vmresol=MRESOL; 
   vmdrawmode=DARSTELL; vmdegree=MDEGREE; vmradiant=MRADIANT;

   vmhstad=MHSTAD; vmhfunc=MHFUNC; vmhspecf=MHSPECF;
   vmhrotate=MHROTATE;vmhview=MHVIEW;vmhresol=MHRESOL;vmhdraw=MHDRAW; 

   vinfo=INFOFORM; vmyname=MYNAME;
   
   vinputfun=INPUTFUN; vfunc1=FUNC1; vfunc2=FUNC2; vxstart=XSTART;
   vxend=XEND; vystart=YSTART; vconsta=CONSTA; vconstb=CONSTB; 
   vconstc=CONSTC;
   
   vdrawfun=DRAWFUN; vcount3d=COUNT3D; vcount2d=COUNT2D; vcountfl=COUNTFL;
   vcountsh=COUNTSH;
   
   vrotation=ROTATION; vzrotate=ZROTATE; vxrotate=XROTATE;
   vview=VIEW; vlookx=LOOKX; vlooky=LOOKY; vlookz=LOOKZ; vplaney=PLANEY;

   vresoluti=RESOLUTI; vxlinien=XWERTE; vylinien=YWERTE;

   vdrawmode=GRAFMODE;
   vxraster=XRASTER; vyraster=YRASTER; vxyraster=XYRASTER;
   vcentral=ZENTRAL; vparallel=NORMALPR;
   vwire=DRAHT; vhidden=HIDDENDR; vshadow=SUNSHINE;
   
   vhfunct=HFUNCT; vhrotate=HROTATE; vhprojekt=HPROJEKT; vhresol=HRESOL;
   vhdraw=HDRAW; vhspecf=HSPECF; vhstad=HSTAD; /* helps */
 
   vsyserror=SYSERROR; vqsyserr=QSYSERR; vsavefun=SAVEFUN;
   vlight=LIGHT; vlightx=LIGHTX; vlighty=LIGHTY; vlightz=LIGHTZ;
   vrahmein=RAHMEIN;
   vstartinf=STARTINF;
   vicons=ICONS; vdesktop=DESKTOP; visave=ISAVE; viinputf=IINPUTF;
   vidrawf=IDRAWF; virotate=IROTATE; vilight=ILIGHT; viview=IVIEW;
   viresol=IRESOL; vistyle=ISTYLE; /* icons */
   vmemostat= MEMOSTAT;
   vhelpkey = 0;
   
	vsavemode=OUTPUT; votimg=OTIMG; votstad=OTSTAD;
	votdegas=OTDEGAS; votdoodle=OTDOODLE; votascii=OTASCII;   
   }
/* uff, rsc installed */
}

#define testrast   FALSE

WORD llog2( LONG arg)
/* gibt ganzzahligen 2-er Logarithmus zurÅck von arg				*/
{
register WORD counter=0;

if (arg<0)
	while (arg<-1)
		{
		arg/=2;
		counter --;
		}
else
	while (arg>1)
		{
		arg/=2;
		counter++;
		}
return (counter);
}

void reserve_screen()
{
  register long runner;
  register BYTE *clearer;

		/* special request for planes & resolutions */
  vq_extnd(handle,0,work_out); 	/* first the normal ones */
  screenbytes=(long) (work_out[0]+1)/8*(long) (work_out[1]+1);
  vq_extnd(handle,1,work_out); /* now look how much planes it needs */
  screenbytes*=(work_out[4]);

  reserved_screen=malloc((unsigned int) (screenbytes+3));
#if COMPILER==MEGAMAX
  target.fd_addr=(long) reserved_screen;
#endif
#if COMPILER==TURBOC
  target.fd_addr=reserved_screen;
#endif

  if (!reserved_screen)
    memory_error();
    
  /* automatically on word boundary */
#if testrast
  printf("res:%lx tar.fd_addr:%lx\n",reserved_screen,target.fd_addr);
#endif
  clearer=(BYTE *) target.fd_addr;
  for (runner=0;runner<screenbytes;runner++)
    *(clearer++)='\0'; /* i hope 0 is no colour */

#if testrast
  printf("p: %lx s:%lx dcarpet:%ld\n",target.fd_addr,clearer,(long) (clearer-target.fd_addr));
  gemdos(7);
#endif

		/* aufbereiten beider DBF's */
		/*  fd_addr bereits getan */
  vq_extnd(handle,0,work_out); 		/* first the normal ones */
  target.fd_w=work_out[0]+1;
  target.fd_h=work_out[1]+1;
  target.fd_wdwidth=target.fd_w/16;
  target.fd_stand=0;
  vq_extnd(handle,1,work_out); /* now the enhanced */
  target.fd_nplanes=(work_out[4]);

  source=target;
  source.fd_addr=
#if COMPILER==MEGAMAX
	xbios(2);
#endif
#if COMPILER==TURBOC
	Physbase();
#endif
	/* the ?pict var are allready installed in window_open */
}

/********************************************************************/

