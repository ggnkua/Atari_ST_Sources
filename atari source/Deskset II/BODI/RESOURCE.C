/**************************************************************************/
/*  FILE:  RESOURCE.C		PROGRAM TITLE: DeskSET II Alpha Version   */
/*  Date Created: 12/15/87						  */ 
/*  Last Modified: 01/27/89						  */
/*									  */
/*  Description: RESOURCE, DIALOG BOXES, ALERT BOXES ROUTINES		  */
/*  Routines:   o   open_resource()  - Gaddr Resources and Display Menu   */
/*		o   do_pagenum()     - Handle page icon			  */
/*		o   draw_book()	     - Draw book icon			  */
/*		o   close_resource() - Hides Menu Bar and Frees Resource  */
/*		o   execform()       - Put up a dialog box.               */
/*		o   get_int()	     - Ascii ob_spec to int		  */
/*		o   set_int()	     - Put int to ASCII ob_spec           */
/*		o   get_float()	     - ASCII ob_spec to float		  */
/*		o   set_float()	     - Put float to ASCII ob_spec	  */
/*		o   draw_fbox()	     - Draw fill box in graphics dialog	  */
/*		o   draw_lbox()	     - Draw line box in graphics dialog   */
/*		o   do_grdialog()    - Handle graphics attribute dialog   */
/*		o   hndl_box()	     - Handle box once object is found    */
/*		o   do_point_size()  - Set Point Size			  */
/*		o   do_scoffset()    - Scan offset Dialog Handler	  */
/*		o   do_go_page()     - Set Current Page Number...	  */
/*		o   do_font_info()   -   				  */
/*		o   get_image()	     - Setup to load images dialog	  */
/*		o   update_point_dialog() Setup font info		  */
/*		o   init_artobj()    - Initialize Article Selector box	  */
/*		o   deselect()	     - Deselect all objects of the article*/
/*		o   init_slider()    - Initialize slider size in box	  */
/*		o   get_num_arts()   - Return # of articles in memory	  */
/*		o   do_slider()	     - Move slider in slider box	  */
/*		o   do_artobj()	     - 					  */
/*		o   hndl_abox()	     - Handle the article box		  */
/*		o   hndl_list()	     - Handle font selection list	  */
/*		o   scroll()	     -					  */
/*		o   set_artobj()     -					  */
/*		o   do_unit_dialog() - Handle changing units of measure   */
/* 		o   do_grid_space()  - Select grid spacing dialog	  */
/*		o   do_page_def()    - Page Type Selection Dialog  	  */
/*		o   do_clip_dialog() - Handle clipping of icons		  */
/*		o   do_rcoord()	     - Typed coordinates of a region      */
/*		o   do_set_paths()   - Handle Default Path dialog	  */
/*		o   set_tedit()	     - Insert Text in Text Dialog Field   */
/*		o   get_edit()	     - Get Text from Editable Text Field  */
/*		o   do_pcoord()	     - Typed coordinates of a primitive   */
/* 		o   set_template()   - Handle template usage dialog box   */
/*		o   page_numbering() - Handle page numbering dialog box   */
/*		o   do_dpi()	     - Handle user defined dpi ...	  */
/**************************************************************************/


/**************************************************************************/
/* HISTORY								  */
/*									  */
/* 11/02/89	- Set_Text_Defaults()					  */
/*		  The Font UID number is now initialized according to the */
/*		  UID number of the FIRST font of the 16 fonts in the	  */
/*		  current dress file.					  */
/*		  B4, it slammed it to #1 which is incorrect.		  */
/*									  */
/* 11/02/89	- do_point_size()					  */
/*		  If the UID number in gltxtattr.font does not exist      */
/*		  among one of the 16 fonts in the current dress file,    */
/*		  the FONT NAME will be blank and the FONT UID # of the   */
/*		  requested UID number will be displayed. The user can    */
/* 		  also scroll among the 16 other fonts + this blank one   */
/*		  See the code as to how it works.			  */
/*		  B4, if the UID # didn't exist, the FONT NAME would've   */
/*		  been the first font in the dress and the UID # would've */
/*		  been either 0 or 1					  */
/*									  */
/* 11/02/89	- page_numbering()					  */
/*		  Changes made for the exact same reasons as the	  */
/*		  do_point_size bug.					  */
/*									  */
/* 11/03/89	- Changed page numbering dialog box routines to ALWAYS    */
/*		  number pages from EXISTING MIN PAGE to EXISTING MAX PAGE*/
/*		  This is checked upon entry to the routine. B4, the user */
/*		  specified the range which was never automatically 	  */
/*		  updated.						  */
/*		  Routine touched: page_numbering()			  */
/*									  */
/* 11/07/89	- Convert all calls form scale_v() to scaler()		  */
/*		- hndl_abox() - replace scale_v() with scaler()		  */
/*		- do_info()   - replace scale_v() with scaler()		  */
/*									  */
/* 11/07/89	- Replace all vmutopix() calls with vmupix()		  */
/*		  do_point_size() - replace vmutopix() with vmupix()      */
/**************************************************************************/

/**************************************************************************/
/* INCLUDE FILES							  */
/**************************************************************************/
#include "define.h"
#include "deskset2.h"
#include "gemdefs.h"
#include <obdefs.h>
#include "osbind.h"
#include "alert.h"
#include "dbase.h"



/**************************************************************************/
/* DEFINES								  */
/**************************************************************************/

					/* From FTMGR.C			  */
#define		SFTSIZ	1548		/* Size of font			  */
#define		TFNOFS 	15		/* Offset to Typeface name	  */
#define 	INFOMAX 10		/* info dialog box slots	  */

#define DINFO struct dinfo

struct dinfo
{
   char  txtptr[40];
   DINFO *next;
   DINFO *prev;
};


/**************************************************************************/
/* EXTERNALS								  */
/**************************************************************************/
extern int splane;
extern int sxres,syres;				/* screen x and y rez     */
extern int xbook,ybook;				/* book icon position	  */

extern int shandle;				/* screen handle	  */
extern int prev_handle;				 
extern int pageside;				

extern int gl_lstyle;				/* graphic attributes     */
extern int gl_lwidth;				/* like..line width	  */
extern int gl_fstyle;				/* Fill style		  */
extern int gl_findex;				/* fill index		  */
extern int gl_repel;				/* graphic repel?	  */
extern int gl_repbounds;			
extern int gl_repoffset;

extern int scale_set;
extern int view_size;				/* what view scale on scrn*/

extern int zdevice;				/* device drawing to...   */
extern int SH;					/* height of scan...      */
extern unsigned long gl_region_ptr;		/* Text region pointer    */
extern unsigned long gl_grregion_ptr;		/* graphic region pointer */
extern unsigned long region_ptr;		/* region pointer	  */

extern int curr_page;				/* current page number    */
extern int mode_change;				/* display or not...      */

extern int cur_pic_type;			/* current pic type       */
extern int (*funcs)();
extern int nada();
extern char fbuffer[];				/* file name buffer...    */
extern int opwidth,opheight;
extern int graph_flag;
extern int opwidth,opheight;
extern int force_draw_flag;

extern	int	gl_hchar;
extern	int	gl_wchar;
extern  int 	ptsin[];			/* ptsin array...	  */

extern  long	getf_article();			/* extern declarations    */
extern  long	getn_article();
extern  char	*get_artfname();

extern struct txtattr gltxtattr;		/* global text attributes */
extern int glgrattr[];				/* global graphic attrib  */
extern char pathbuf[];				/* path...		  */

extern int txt_handle;				/* text window handle     */
extern int prev_handle;				/* preview window handle  */
extern int unit_type;				/* current unit of measure*/

extern int dummy;

typedef struct dta				/* dta for file i/o	  */
{
     char res[21];
     char attr;
     int  time;
     int  date;
     long fsize;
     char str[14];
} DTA;

extern DTA thedta;				/* store DTA info here!  */
extern int hgridspace,vgridspace;		/* h and v grid space    */
extern int pagetype;				
extern int pagemux[];
extern int pagemuy[];

extern int hpage_size;				/* h and v size in mu's  */
extern int vpage_size;
extern int pxy[];				/* global vertices...    */
extern int cur_scale;

extern GRECT dpwork;				/* Actual preview work area*/
extern GRECT pwork;				/* Total preview work area */
extern GRECT page_area; 			/* GRECT area Preview area */

extern char *gcvt();
extern int article_flag;
extern long bufpath;

extern int active_prim;			/* flag if prim is active  */
extern long prim_ptr;			/* ptr to current primitive*/
extern int wmode;
extern long get_curreg();

extern int tmplate_flag;
extern int disp_type;			/* display template- BOTH,LEFT,RIGHT*/
extern int disp_pos;			/* display template-FRONT,BACK      */

extern PNUMBER pnum;			/* page number structure	    */
extern double get_float();

extern int axdpi[];			/* array for xdpi		    */
extern int aydpi[];			/* array for ydpi		    */
extern int half_xdpi[];			/* array for half of x dpi	    */
extern int half_ydpi[];			/* array for half of y dpi	    */
extern int xdpi[];			/* GO Graphics xdpi array	    */
extern int ydpi[];			/* GO Graphics ydpi array	    */

extern long MALLOC();

extern unsigned long scan_bytes;	/* number of bytes in scan buffer   */
extern unsigned long prev_bytes;	/* number of bytes in preview buff  */
extern unsigned long scanptr,scanesc;   /* pointers to scan buffer	    */
extern unsigned long page_ptr,pagesc;	/* pointers to preview buffer       */

extern int scan_xres;			/* x and y resolution of scan buff  */
extern int scan_yres;

extern int sdevm;
extern int mhandle;			/* preview workstation handle     */
extern int intout[];
extern int mxres,myres;			/* current xy res of preview buff */
extern FDB page_MFDB;			/* Preview MFDB area		  */
extern unsigned char *get_lmem();
extern long pagebytes;
extern PAGE *curpage;
extern int multi_mode;
extern long first_aregion();
extern long get_regart();
extern long get_lcmem();

extern int Pval;	/* parmcheck() result value */

extern int ruler_flag;
extern int show_grids;
extern int snap_to_grids;
extern int grid_space;

extern int bgmono2[];
extern int bgmed1[];
extern int bgmed2[];

extern ARTICLE *arthd;
extern ARTICLE *tarthd;
extern PAGE *pagehd;
extern PAGE *tpagehd;

extern int ptsarray[];
extern long get_fregion();
extern long get_nregion();
extern long get_fpage();
extern long get_npage();
extern PAGE *left_tmplate;
extern PAGE *right_tmplate;
extern ARTICLE *rtarthd;
extern ARTICLE *ltarthd;

extern DINFO *set_info_graphics();
extern PAGE *clippage;
extern ARTICLE *curart;
extern char *winfo[][4];

extern DINFO *get_grfname();

/**************************************************************************/
/* GLOBAL VARIABLES							  */
/**************************************************************************/
char rscerr[]  = "[3][ Unable to Locate Resource!][OK]";
char rscerr1[] = "[3][ Preview Functions Disabled.][OK]";
char rscerr2[] = "[1][ Printing Functions Disabled.][OK]";
char rscerr3[] = "[3][ Delete all regions?][OK|CANCEL]";
char linkerr[] = "[3][ This Region is already| linked to an article.][OK]";
char del_page[]= "[3][ Delete Page? ][OK|CANCEL]";
char delregion[]="[3][ Delete Region? ][OK|CANCEL]";
char not_found[]="[1][ File Not Found! ][CONTINUE]";
char dprint[]   ="[2][ Commence Printing? ][OK|CANCEL]";
char scanerr[] = "[3][ Unable to Open|Scanner Workstation!][EXIT DESKSET]";
char preverr[] = "[3][ Unable to Open|Preview Workstation!][EXIT DESKSET]";
char quiter[]  = "[3][ Do you really want to QUIT? ][QUIT|CANCEL]";

char *gtype[] = {
	          ".NEO",
		  ".IMG",
		  ".GEM",
		  ".PI1"
	        };


char *grid_inch[] =
{
   "1/8 inch",
   "1/4 inch",
   "1/2 inch",
   "1 inch"
};
char *grid_cents[] =
{
   "1/2 centimeter",
   "1 centimeter",
   "2 centimeters",
   "3 centimeters"
};
char *grid_picas[] =
{
   "1 pica",
   "2 picas",
   "3 picas",
   "4 picas"
};

char *grid_cicero[] =
{
   "1 ciceros",
   "2 ciceros",
   "3 ciceros",
   "4 ciceros"
};


char *rcoord_unit[] = 
{
   " Inches      ",
   " Picas       ",
   "Centimeters  ",
   " Ciceros     "
};

char *dpagenum[] = {
		    " Distance From Top Of Page:   ",
		    " Distance From Bottom Of Page:"
		   };



/* all are based upon 1301 mu per Horizontal inch 	    */
/* 		      1156 mu per Vertical inch   	    */
/* These are based on the 1301 and 1156 mus		    */ 
/*
int hinch_mus[] = {163,325,651,1301}; 	* inches	    *
int vinch_mus[] = {145,289,578,1156};   * 1/8 1/4 1/2 1     *

int hcent_mus[] = {256,512,1024,1537};  * 1/2, 1,2,3  	    *
int vcent_mus[] = {228,455,910,1365};   * 2.54 cm == 1 inch *

int hpica_mus[] = {217,434,651,867};	* 1,2,3,4  picas    *
int vpica_mus[] = {193,385,651,771};    * 6 picas == 1 inch *
*/



/* These numbers are based upon 1296 and 1152 mus	*/
int hinch_mus[] = {162,324,648,1296}; /* inches  	*/
int vinch_mus[] = {144,288,576,1152}; /* 1/8 1/4 1/2 1  */

int hcent_mus[] = {255,510,1020,1531}; /* Centimeters   2.54 cm == 1 inch*/
int vcent_mus[] = {227,454,907,1361};  /* 1/2, 1 2 3 */

int hpica_mus[] = {216,432,648,864}; /* 1,2,3,4 picas     */
int vpica_mus[] = {192,384,576,768}; /* 6 picas == 1 inch */

int hcicero_mus[] = {231,462,693,924};  /* 1,2,3,4  */
int vcicero_mus[] = {205,410,615,820};	/* ciceros hasn't been touched */

OBJECT *ad_menu;				/* Address of menu object */
OBJECT *ad_deskset;				/* Address of About object*/
OBJECT *ad_bkgrnd;				/* Address of BKGRND objct*/
OBJECT *ad_point_size;				/* Set Font Size	  */
OBJECT *ad_go_page;				/* Goto page #		  */
OBJECT *ad_get_image;
OBJECT *ad_grattr;
OBJECT *artobj;
OBJECT *unitobj;
OBJECT *gridspace;
OBJECT *adpagedef;
OBJECT *adoutput;
OBJECT *adclipobj;
OBJECT *ad_scanoff;
OBJECT *ad_rcoord;
OBJECT *ad_paths;
OBJECT *ad_pcoord;
OBJECT *ftmenu;
OBJECT *ad_settmpl;
OBJECT *ad_pagenum;
OBJECT *ad_autoflow;
OBJECT *ad_dpi;
OBJECT *ad_credits;
OBJECT *ad_info;
OBJECT *ad_filebuf;

int maxpat;				/* Graphic screen device limits   */
int maxhatch;
int maxlwidth;
int maxlstyles;


char	tmpflname[14] = {"________.___"};

#define PAGESIZ 8

int	aworkx;
int	aworky;
int	aworkw;
int	aworkh;


int	curfirst_art;		/* beginning of font list */
int	hslider;		/* vertical slider height */
char	pagestr[10];
int *clipe;
int *icdata;
ICONBLK *icnptr;
BITBLK *bgicptr;

double atof();
char *pathptr;
char *get_edit();

char *dpath1;		/* Pointers to Default paths for Text..*/
char *dpath2;		/* clipboard,Graphics and Docs         */
char *dpath3;		/* in that order...		       */
char *dpath4;

char pnumtext[PTEXTMAX];
int pstorage[51];	/*******************************************/
			/* int array storage for default parameters*/
			/* Default Save Parameters Format...       */
			/* Base Zero, but of course...		   */
			/* (0)  int Preview Size - 50%,100% etc... */
			/* (1)  int Ruler Display - On/Off	   */
			/* (2)  int Ruler Units - Metric etc...    */
			/* (3)  int Grid Spacing - Units Etc..     */
			/* (4)  int Grid Display - On/Off          */
			/* (5)  int Snap To Grid - On/Off	   */
			/* (6)  int DPI Setting  - X dpi	   */
			/* (7)  int DPI Setting  - Y dpi	   */
			/* (8)  int Global Font Number		   */
			/* (9)  int Global Point Size		   */
			/* (10) int Global Set Size		   */
			/* (11) int Global Line Space - in Mu's    */
			/* (12) int Kerning - On/Off		   */
			/* (13) int Reverse Video - On/Off	   */
			/* (14) int Justification		   */
			/* (15) int Paper Type - A4,B5,Letter,Legal*/
			/* (16) int Scan Offset - In mu's	   */ 
			/* (17) int Fill Type  - Pattern/Hatch     */
			/* (18) int Fill Index			   */
			/* (19) int Line Style			   */
			/* (20) int Line Width			   */
			/* (21) int Repel Mode			   */
			/* (22) int Repel Bounds		   */
			/* (23) int Boundary Offset		   */
			/* (24) int Page Number Font		   */
			/* (25) int Page Number Point Size	   */
			/* (26) int Page Number Set Size	   */
			/* (27) int Page Number Display		   */
			/* (28) int Page Number Left Page Just     */
			/* (29) int Page Number Right Page Just    */
			/* (30) int Page Usage			   */
			/* (31) int Page Number Vertical Position  */
			/* (32) int Page Number Distance - in Mu's */
			/* (33) int Page Number From---		   */
			/* (34) int Page Number To---		   */
			/* (35) int Template Usage - Both,Left,Rt  */
			/* (36) int Template Display Location      */
			/* (37) int Manual char. Compensation	   */
			/* (38) int Auto. Char Compensation	   */
			/* (39) int Hyphenation flag		   */
			/* (40) int No. of Sucessive Hyphens	   */
			/* (41) int No. of chars Before Hyphen	   */
			/* (42) int No. of chars AFter Hyphen	   */
			/* (43) int Letterspacing Mode flag        */
			/* (44) int Positive Letter Space in RU    */
			/* (45) int Negative Letter SPace In RU    */
			/* (46) int Minimum Space in RU		   */
			/* (47) int Preferred Space In RU	   */
			/* (48) int Maximum Space In RU		   */
			/* (49) int Pseudo Italic Mode Flag	   */
			/* (50) int # of Chars in Page Text	   */
			/* (X) char Page Number Text	   	   */
			/* Null					   */
			/*******************************************/


int *primicons;

int info_what;	 /* info dialog box - DOC,TEMPLATE,orCLIPBOARD 0,1,2*/
int info_type;   /* info dialog box - TEXT or GRAPHIC - 0,1         */ 


DINFO *tdinfo_ptr;	/* pointer to first node of text info structure DOC*/
DINFO *gdinfo_ptr;      /* pointer to first node of graphic info struct DOC*/

DINFO *ttdinfo_ptr;	/* ptr to first node of text info in template	   */
DINFO *tgdinfo_ptr;	/* ptr to first node of graphic info in template   */

DINFO *ctdinfo_ptr;	/* empty - null on purpose			   */
DINFO *cgdinfo_ptr;	/* ptr to first node of graphic info in clipboard  */

int dtcount;		/* number of doc text items.			   */
int dgcount;		/* number of doc graphic items  		   */

int ttcount;		/* number of template text items		   */
int tgcount;		/* number of template graphic items		   */
    
int ctcount;		/* number of clipboard text items - always zero    */
int cgcount;		/* number of clipboard graphic items	 	   */

int maincount;		/* number of items in DINFO structure-for active struct*/
DINFO *curdinfo;	/* current dinfo pointer			   */

ARTICLE *xarthd;	/* temp for testing in set_dtmplate() */

int attr_flag[23];	/* attribute flags - 0 if not changed, 1 if changed*/
struct txtattr tmpattr; /* temporary txt attributes structure 		   */


/**************************************************************************/
/* Function:    open_resource()						  */
/* Description: Gets Address of Resource objects and displays menu bar.   */
/**************************************************************************/
open_resource()
{
    int fullx,fully,fullw,fullh;

    rsrc_gaddr(0,MENU,&ad_menu);		/* menu...        */
    rsrc_gaddr(0,DESKSET,&ad_deskset);		/* About Dialog   */
    rsrc_gaddr(0,BKGRND,&ad_bkgrnd);
    rsrc_gaddr(0,FONTSIZE,&ad_point_size);
    rsrc_gaddr(0,GOPAGE,&ad_go_page);
    rsrc_gaddr(0,PICTYPE,&ad_get_image);
    rsrc_gaddr(0,GRATTR,&ad_grattr);
    rsrc_gaddr(0,ARTSEL,&artobj);
    rsrc_gaddr(0,MEASURE,&unitobj);
    rsrc_gaddr(0,GRIDSP,&gridspace);
    rsrc_gaddr(0,PAGESIZE,&adpagedef);
    rsrc_gaddr(0,OUTPUT,&adoutput);
    rsrc_gaddr(0,CLIPTREE,&adclipobj);
    rsrc_gaddr(0,SCANOFF,&ad_scanoff);
    rsrc_gaddr(0,REGCOORD,&ad_rcoord);
    rsrc_gaddr(0,PATHS,&ad_paths);
    rsrc_gaddr(0,PRMCOORD,&ad_pcoord);
    rsrc_gaddr(0,FONTMAN,&ftmenu);
    rsrc_gaddr(0,SETTMPL,&ad_settmpl);
    rsrc_gaddr(0,PAGENUMS,&ad_pagenum);
    rsrc_gaddr(0,AUTOFL,&ad_autoflow);
    rsrc_gaddr(0,DOTS,&ad_dpi);
    rsrc_gaddr(0,CREDITS,&ad_credits);
    rsrc_gaddr(0,DOCINFO,&ad_info);
    rsrc_gaddr(0,FILEBUF,&ad_filebuf);

    wind_get(0,WF_WORKXYWH,&fullx,&fully,&fullw,&fullh);
    ad_bkgrnd[0].ob_x 	    = fullx;
    ad_bkgrnd[0].ob_y       = fully;
    ad_bkgrnd[0].ob_width   = fullw;
    ad_bkgrnd[0].ob_height  = fullh;
    ad_bkgrnd[BOOKOBJ].ob_x = xbook;
    if(splane == 2)	/* color med res */
        ad_bkgrnd[BOOKOBJ].ob_y = ybook - 3;
    else
	ad_bkgrnd[BOOKOBJ].ob_y = ybook - 11;
    ad_bkgrnd[CLIPOBJ].ob_y = ybook - 16;
    ad_bkgrnd[CLIPOBJ].ob_x = xbook - ad_bkgrnd[BOOKOBJ].ob_width - 10;

    set_int(adoutput,OCOPIES,1);
    set_int(adoutput,OTOPAGE,1);
    set_int(adoutput,OFROMPAG,1);

    icnptr = ad_bkgrnd[CLIPOBJ].ob_spec;
    bgicptr = ad_bkgrnd[BGICON].ob_spec;
    
    clipe = icnptr->ib_pdata;
    if(splane == 2)				/* medium res */
    {
        bgicptr->bi_pdata = bgmed1;
	icdata = bgmed1;
	primicons = bgmed2;
        bgicptr->bi_wb = 0x0008;		/* 8 bytes across */
	bgicptr->bi_hl = 0x00c1;
    }
    else
    {
        icdata = bgicptr->bi_pdata;		/* at least hi resolution */
	primicons = bgmono2;
    }
    do_pagenum(1,1);				/* Page 1, 0 = left side */
    form_dial(0,0,0,0,0,0,16,sxres,syres-16);
    wind_set(0,WF_NEWDESK,ad_bkgrnd,0,0);
    objc_draw(ad_bkgrnd,ROOT,MAX_DEPTH,0,fully,sxres,syres);
    
    ad_menu[TEXT].ob_state = DISABLED;
    menu_bar(ad_menu,TRUE);
    menu_ienable(ad_menu,AAUTOFL,FALSE);
}


/**************************************************************************/
/* Function: get_range()						  */
/* Description: Get rang efor autoflow pages...				  */
/**************************************************************************/
get_range(min,max)
int *min;
int *max;
{
   int button;

   set_int(ad_autoflow,AFFROM,0);
   set_int(ad_autoflow,AFTO,0);
   button = execform(ad_autoflow,AFFROM);
   ad_autoflow[button].ob_state = NORMAL;
   *min = get_int(ad_autoflow,AFFROM);
   *max = get_int(ad_autoflow,AFTO);
   if(button == AFOK)
	return(1);
   else
	return(0);
}
   


/**************************************************************************/
/* Function: do_pagenum()						  */
/* Description: Handles the book icon					  */
/**************************************************************************/
do_pagenum(num,side)
int num;
int side;
{
   register ICONBLK *icnptr;
   register int width;
   int height;
   int tflag;

   icnptr = ad_bkgrnd[BOOKOBJ].ob_spec;
   width = ad_bkgrnd[BOOKOBJ].ob_width;
   height = ad_bkgrnd[BOOKOBJ].ob_height;
   icnptr->ib_wtext = 18;
   icnptr->ib_htext = 6;
   icnptr->ib_ytext = height/4;			/* one fourth down screen */	
   if(!side)					/* LEFT side  */
   {
	pageside = 0;
	icnptr->ib_xtext = width/8;
/*        pagestr[0] = 'L';*/
	strcpy(pagestr,"L  ");
   } 
   else
   {
	pageside = 1;
	icnptr->ib_xtext = (5*width)/8;
/*        pagestr[0] = 'R';*/
	strcpy(pagestr,"R  ");
   }

   if(!tmplate_flag)
   	itoa(num,pagestr);
   icnptr->ib_ptext = pagestr;
   draw_book();

   if(ad_menu[RCLOSE].ob_state == 0x0)
   {
	 tflag = article_flag;
	 article_flag = TRUE;
         close_region();
	 article_flag = tflag;
	 if(!article_flag)
		graf_mouse(0,&dummy);	/* arrow then... */
   }

}




/**************************************************************************/
/* Function: draw_book()						  */
/* Description: Draw the book icon					  */
/**************************************************************************/
draw_book()
{
int x,y,w,h;
	   wind_get(prev_handle,WF_CURRXYWH,&x,&y,&w,&h);
	   if(x + w >= xbook && y + h >= ybook)
		return;
	   wind_get(txt_handle,WF_CURRXYWH,&x,&y,&w,&h);
	   if(x + w >= xbook && y + h >= ybook)
		return;
	   Vsync();
	   objc_draw(ad_bkgrnd,BOOKOBJ,1,xbook,ybook,
		sxres - xbook,syres - ybook);   
}

   

/**************************************************************************/
/* Function:    close_resource()					  */
/* Description: Closes menu bar and releases resources.			  */
/**************************************************************************/
close_resource()
{
    menu_bar(ad_menu,FALSE);
    form_dial(3,0,0,0,0,0,16,sxres,syres-16);    
    rsrc_free();
}



/**************************************************************************/
/* Function:     execform()						  */
/* Description:  Put up a Dialog Box					  */
/* IN:  the_tree   - tree OBJECT					  */
/*      crsr_pos   - object to place cursor on...			  */
/* OUT: returns button pressed.						  */
/**************************************************************************/
execform(the_tree,crsr_pos)
register OBJECT the_tree[];
int    crsr_pos;			
{
  int x,y,w,h;
  int button;

        active_prim = FALSE;
  	form_center(the_tree,&x,&y,&w,&h);
  	the_tree[0].ob_x = x + 3;
	the_tree[0].ob_y = y + 3;
	form_dial(0,0,0,36,36,x,y,w,h);
	form_dial(1,0,0,36,36,x,y,w,h);
	objc_draw(the_tree,0,MAX_DEPTH,x,y,w,h);
	button = form_do(the_tree,crsr_pos);
	form_dial(2,0,0,36,36,x,y,w,h);
	form_dial(3,0,0,36,36,x,y,w,h);  
	return(button);
}



/**************************************************************************/
/* Function:     get_int()						  */
/* Description:  Convert ob_spec ascii to int				  */
/* IN:  tree  - address of OBJECT					  */
/*      obj   - object in question					  */
/* OUT: returns integer							  */
/**************************************************************************/
get_int(tree,obj)
OBJECT *tree;
int obj;
{
     long *str1;

     str1 = tree[obj].ob_spec;
     return(atoi(*str1));
}



/**************************************************************************/
/* Function:     set_int()						  */
/* Description:  Inserts an ascii string into the dialog box.		  */
/* IN:  tree  - address OBJECT of tree in question			  */
/*	obj   - object in dialog box in question			  */
/*	num   - number to insert					  */
/* OUT: none  								  */
/**************************************************************************/
set_int(tree,obj,num)
OBJECT *tree;
int obj;
int num;
{
     char str[4];
     long *str1;

     itoa(num,str);
     str1 = tree[obj].ob_spec;
     strcpy(*str1,str);
}



/**************************************************************************/
/* Function: get_float()						  */
/* Description: ASCII ob_spec to float					  */
/**************************************************************************/
double get_float(tree,obj)
OBJECT *tree;
int obj;
{
     long *str1;

     str1 = tree[obj].ob_spec;
     return(atof(*str1));
}



/**************************************************************************/
/* Function: set_float()						  */
/* Description: float to ASCII ob_spec					  */
/**************************************************************************/
set_float(tree,object,num)
OBJECT *tree;
int object;
double num;
{
   char str[64];
   long *str1;
   char *s;

   s = gcvt(num,4,str);
   str1 = tree[object].ob_spec;
   strcpy( *str1,s);
}





/**************************************************************************/
/* Function: draw_fbox()						  */
/* Description: Draw Fill box in graphical dialog			  */
/**************************************************************************/
draw_fbox(patmode)
int patmode;
{
   int pxyarray[4];
   register int styleflag;
   int xpos,ypos;

   objc_offset(ad_grattr,FBOX,&xpos,&ypos);
   
   if(patmode)
   {
	if(gl_findex == maxpat)
		styleflag = 0;
	else 
		styleflag = 2;
   }
   else
	styleflag = 3;			/* Else hatch   */

   gsx_moff();
   vsf_interior(shandle,styleflag);
   vsf_style(shandle,gl_findex);
   pxyarray[0] = xpos;
   pxyarray[1] = ypos;
   pxyarray[2] = pxyarray[0] + ad_grattr[FBOX].ob_width - 1;
   pxyarray[3] = pxyarray[1] + ad_grattr[FBOX].ob_height - 1;
   v_bar(shandle,pxyarray);
   gsx_mon();
}




/**************************************************************************/
/* Function: draw_lbox()						  */
/* Description: Draw line box in graphics dialog			  */
/**************************************************************************/
draw_lbox(wider)
int wider;
{
   int pxyarray[4];
   int xpos,ypos;

   objc_offset(ad_grattr,LBOX,&xpos,&ypos);
   pxyarray[0] = xpos;
   pxyarray[1] = ypos;
   pxyarray[2] = pxyarray[0] + ad_grattr[LBOX].ob_width - 1;
   pxyarray[3] = pxyarray[1] + ad_grattr[LBOX].ob_height - 1;
   gsx_moff();
   if(!wider)
   {
      vsf_interior(shandle,0);
      v_bar(shandle,pxyarray);
   }
   vsl_type(shandle,gl_lstyle);
   vsl_width(shandle,1);
   pxyarray[1] = pxyarray[3] = ypos + (ad_grattr[LBOX].ob_height/2);
   v_pline(shandle,2,pxyarray);
   gsx_mon();
}




/**************************************************************************/
/* Function: do_grdialog()						  */
/* Description: Handle graphics attribute dialog box			  */
/**************************************************************************/
do_grdialog()
{
   int x,y,w,h;
   int obj;
   int cont;
   int okflag;
   int tmp_lstyle,tmp_lwidth;
   int tmp_fstyle,tmp_findex;
   int tmp_repel;
   int tmp_repoffset;
   int tmp_repbounds;
   int tmpxy[4];
   register int i;
   int output_done;
   register REGION *rptr;
   int perimeter;
   int patmode;
   int oldrect[4];
   int dummy;

  
   vs_clip(shandle,0,tmpxy);


   if(region_ptr)
   {
	if(region_ptr == gl_grregion_ptr)
	{
	   gl_region_ptr = 0L;
           get_grattr(gl_grregion_ptr,glgrattr);
           gl_lstyle = glgrattr[0];
    	   gl_lwidth = glgrattr[1];
           gl_fstyle = glgrattr[2];
           gl_findex = glgrattr[3];
	   gl_repel  = glgrattr[4];
	   gl_repbounds = glgrattr[6];
	   gl_repoffset = glgrattr[5];
        }
   }
   tmp_lstyle = gl_lstyle;
   tmp_lwidth = gl_lwidth;
   tmp_fstyle = gl_fstyle;
   tmp_findex = gl_findex;
   tmp_repel = gl_repel;
   tmp_repoffset = gl_repoffset;
   tmp_repbounds = gl_repbounds;

   perimeter = gl_fstyle & 0x8000;
   gl_fstyle &= 0x7fff;

   ad_grattr[FPATTERN].ob_state = NORMAL;
   ad_grattr[FHATCH].ob_state = NORMAL;

   if(gl_fstyle == 2)
   {
	ad_grattr[FPATTERN].ob_state = SELECTED;
	patmode = 1;
   }
   else
   {
	ad_grattr[FHATCH].ob_state = SELECTED;
	patmode = 0;
   }

   set_int(ad_grattr,GRBOFF,gl_repoffset);

   if(perimeter)
   {
	ad_grattr[PERIMON].ob_state = SELECTED;
        ad_grattr[PERIMOFF].ob_state = NORMAL;
   }
   else
   {
	ad_grattr[PERIMON].ob_state = NORMAL;
	ad_grattr[PERIMOFF].ob_state = SELECTED;
   }

   if(gl_lwidth)
   {
	ad_grattr[GRPIXWID].ob_state = NORMAL;
        ad_grattr[GRPTSWID].ob_state = SELECTED;
	set_int(ad_grattr,GRLWID,gl_lwidth);
   }
   else
   {
	ad_grattr[GRPTSWID].ob_state = NORMAL;
        ad_grattr[GRPIXWID].ob_state = SELECTED;
	set_int(ad_grattr,GRLWID,0);
   }

   for(i=GRTHRU;i<=GRAROUND;i++)
		ad_grattr[i].ob_state = NORMAL;

   ad_grattr[gl_repel + GRTHRU].ob_state = SELECTED;

   ad_grattr[RPLREG].ob_state = NORMAL;
   ad_grattr[RPLIMG].ob_state = NORMAL;
   ad_grattr[gl_repbounds + RPLREG].ob_state = SELECTED;


   form_center(ad_grattr,&x,&y,&w,&h);
   form_dial(0,0,0,36,36,x,y,w,h);
   objc_draw(ad_grattr,0,MAX_DEPTH,x,y,w,h);
   draw_fbox(patmode);
   draw_lbox(1);
   do
   {
	 obj = form_do(ad_grattr,0);
  	 obj &= 0x7fff;
	 cont = hndl_box(obj,&okflag);
   }while(cont);
   for(i = GRTHRU;i <= GRAROUND;i++)
   {
      if(ad_grattr[i].ob_state == SELECTED)
      {
	ad_grattr[i].ob_state = NORMAL;
	gl_repel = i - GRTHRU;
	break;
      }
   }
   if(ad_grattr[RPLREG].ob_state == SELECTED)
   {
	ad_grattr[RPLREG].ob_state = NORMAL;
	gl_repbounds = 0;
   }
   else
   {
	ad_grattr[RPLIMG].ob_state = NORMAL;
	gl_repbounds = 1;
   }
   gl_repoffset = get_int(ad_grattr,GRBOFF);
   if(ad_grattr[PERIMON].ob_state == SELECTED)
	perimeter = TRUE;
   else
	perimeter = FALSE;
   if(ad_grattr[GRPIXWID].ob_state == SELECTED)
	gl_lwidth = 0;
   else
	gl_lwidth = get_int(ad_grattr,GRLWID);
   if(!okflag)
   {
	gl_lstyle = tmp_lstyle;
        gl_lwidth = tmp_lwidth;
  	gl_fstyle = tmp_fstyle;
	gl_findex = tmp_findex;
	gl_repel  = tmp_repel;
        gl_repbounds = tmp_repbounds;
   	gl_repoffset = tmp_repoffset;
   }

   form_dial(3,0,0,36,36,x,y,w,h);
   check_top_window();

   if(okflag)
   {
        if(perimeter)
	   gl_fstyle |= 0x8000;				/* perimeter set */
        if(multi_mode)
        {
	   output_done = 1;
	   rptr = curpage->regptr;
           while(rptr)
	   {
	      if(rptr->multi_select && rptr->type)
	      {
  	         find_boundary(rptr,&oldrect[0],&oldrect[1],&oldrect[2],&oldrect[3],&dummy,&dummy);
   	         redraw_spot(rptr,oldrect,0);	/* cjg - to clear out old rectangle */
                 glgrattr[0] = gl_lstyle;	/* Set up graphic attributes */
        	 glgrattr[1] = gl_lwidth;
        	 glgrattr[2] = gl_fstyle;
        	 glgrattr[3] = gl_findex;
		 glgrattr[4] = gl_repel;
		 glgrattr[5] = gl_repoffset;
        	 glgrattr[6] = gl_repbounds;

                 put_grattr(rptr,glgrattr);
	         if((tmp_repel != gl_repel) || (tmp_repoffset != gl_repoffset)
				   || (tmp_repbounds != gl_repbounds))
	         {
	            update_repel(0,0L);
                 }
		 else
		 {
		      redr_regarea(rptr,1);
	 	 }
	      }
	      rptr = rptr->plink;
 	   }	
	}
	else if(gl_grregion_ptr)	 
        {
	   find_boundary(gl_grregion_ptr,&oldrect[0],&oldrect[1],&oldrect[2],&oldrect[3],&dummy,&dummy);
           redraw_spot(gl_grregion_ptr,oldrect,0);  /* to clear out old rectangle */
           glgrattr[0] = gl_lstyle;		  /* Set up graphic attributes */
           glgrattr[1] = gl_lwidth;
           glgrattr[2] = gl_fstyle;
           glgrattr[3] = gl_findex;
	   glgrattr[4] = gl_repel;
	   glgrattr[5] = gl_repoffset;
           glgrattr[6] = gl_repbounds;

           put_grattr(gl_grregion_ptr,glgrattr); /* and store in region  */
	   if((tmp_repel != gl_repel) || (tmp_repoffset != gl_repoffset)
				   || (tmp_repbounds != gl_repbounds))
	   {
	      update_repel(0,0L);
	      output_done = 1;
           }
	   else
	      output_done = 0;
	}

        if((graph_flag || gl_grregion_ptr)&&!output_done)
        {
           redr_regarea(gl_grregion_ptr,1);
        }

   }
   screen_clip();
}




/**************************************************************************/
/* Function: hndl_box()							  */
/* Descriptio: Handle box once object is found				  */
/**************************************************************************/
hndl_box(obj,okflag)
int obj;
int *okflag;
{
   int patmode;
   int cont;
   cont = 1;
   *okflag = 1;

   if(ad_grattr[FPATTERN].ob_state == SELECTED)
   {
	gl_fstyle = 2;
	patmode = 1;
   }
   else
   {
	gl_fstyle = 3; 
	patmode = 0;
   }

   switch(obj)
   {
	case FINDEXL:
		if(gl_findex > 1)
		   gl_findex -= 1;
		else
		{
		   if(patmode)
			gl_findex = maxpat;
		   else
		 	gl_findex = maxhatch;
		
		}
		draw_fbox(patmode);
		break;

	case FINDEXR:
		if(patmode)
	 	{
		   if(gl_findex >= maxpat)
			gl_findex = 1;
		   else 
			gl_findex += 1;
		}
		else
		{
		   if(gl_findex >= maxhatch)
			gl_findex = 1;
		   else
			gl_findex += 1;
		}
		draw_fbox(patmode);
		break;
	case FPATTERN:
		gl_fstyle = 2;
		draw_fbox(1);
		break;
	case FHATCH:
		gl_fstyle = 3;
		if(gl_findex > maxhatch)
			gl_findex = maxhatch;
		draw_fbox(0);
		break;
	case LSTYLEL:
		if(gl_lstyle > 1)
			gl_lstyle -= 1;
		else
			gl_lstyle = maxlstyles;
		draw_lbox(1);
		break;
	case LSTYLER:
		if(gl_lstyle == maxlstyles)
			gl_lstyle = 1;
		else
			gl_lstyle += 1;
		draw_lbox(1);
		break;
	case GROK:
		ad_grattr[GROK].ob_state = NORMAL;
		cont = 0;
		break;
	case GRCANCEL:
		ad_grattr[GRCANCEL].ob_state = NORMAL;
		*okflag = 0;
		cont = 0;
		break;
	}
	return cont;
}


		


/**************************************************************************/
/* Function:    do_point_size()						  */
/* Description: Set Current Point Size					  */
/**************************************************************************/
do_point_size()
{
     int button;
     int tmplnsp;
     long *str1;
     long str2;
     int x,y,w,h;
     int x1,y1;
     int fnt;
     int pxy[4];
     register int findex;
     int *fntptr;
     int found;
     int sobj;
     int jtype;
     int lowend = 0;

     clr_attr_flag();

     if(region_ptr)
     {
	if(gl_region_ptr == region_ptr)
	{
	  gl_grregion_ptr = 0L;
	  get_txtattr(gl_region_ptr,&gltxtattr);
	  update_point_dialog();
	}
     }

     fnt = gltxtattr.font;
     findex = found = 0;
     for(findex = 0; findex < 16;findex++)
     {
	fntptr = ftlib + (findex*SFTSIZ);
	if(fnt == *fntptr)
	{
	   found = 1;
	   break;
	}
     }
     str1 = ad_point_size[FNTNME].ob_spec;
     if(!found)
     {
	lowend = findex = -1;
	str2 = " ";
	
     }
     else    
        str2 = ftlib + ((findex * SFTSIZ)+TFNOFS); 
     strcpy(*str1,str2);

     update_point_dialog();
	
     ad_point_size[FKERNON].ob_state = NORMAL;
     ad_point_size[FKERNOFF].ob_state = NORMAL;
     ad_point_size[FREVON].ob_state = NORMAL;
     ad_point_size[FREVOFF].ob_state = NORMAL;

     if(gltxtattr.kernmd)
	ad_point_size[FKERNON].ob_state = SELECTED;
     else
	ad_point_size[FKERNOFF].ob_state = SELECTED;

     if(gltxtattr.rvomd)
	ad_point_size[FREVON].ob_state = SELECTED;
     else
	ad_point_size[FREVOFF].ob_state = SELECTED;

     form_center(ad_point_size,&x,&y,&w,&h);
     form_dial(0,0,0,36,36,x,y,w,h);
     objc_draw(ad_point_size,0,MAX_DEPTH,x,y,w,h);

     objc_offset(ad_point_size,FNTNME,&x1,&y1);
     pxy[0] = x1;
     pxy[1] = y1;
     pxy[2] = x1 + ad_point_size[FNTNME].ob_width - 1;
     pxy[3] = y1 + ad_point_size[FNTNME].ob_height - 1;
     vsf_interior(shandle,0);

     sobj = FONTNUM;
err: do
     {
	button = form_do(ad_point_size,sobj);
 	button &= 0x7fff;
        if((button == FNTFWD) || (button == FNTBAK))
	{
	   if(button == FNTFWD)
	      findex += 1;
	   else
	      findex -= 1;

	   if(findex < lowend)			/* either 0 or -1 */
	      findex = 15;

	   if(findex > 15)
	      findex = lowend;			/* either 0 or -1 */
	   if( findex == -1 )
	     str2 = " ";	
	   else
     	     str2 = ftlib + ((findex * SFTSIZ)+TFNOFS); 
     	   strcpy(*str1,str2);	   
	   v_bar(shandle,pxy);
	   objc_draw(ad_point_size,FNTNME,1,x,y,w,h);
	   fntptr = ftlib + (findex*SFTSIZ);
	   if(findex == -1 )
	     set_int(ad_point_size,FONTNUM,fnt);
	   else
	     set_int(ad_point_size,FONTNUM,*fntptr);	   
	   objc_draw(ad_point_size,FONTNUM,1,x,y,w,h);	    
	}
     } while((button != FOK) && (button != FCANCEL));


     ad_point_size[button].ob_state = NORMAL;
     if(button == FOK)
     {
        tmplnsp = (int)gltxtattr.lnsp;
	attr_flag[2] = 1;
        do_font_info(ad_point_size,FONTNUM,999,1,&gltxtattr.font);
        attr_flag[5] = 1;

	if(!parmcheck(ad_point_size,FNTSIZE,2,0))
	{
			gltxtattr.ptsz = Pval;
			attr_flag[3] = 1;
	}
        else
        {
	 sobj = FNTSIZE;
         objc_draw(ad_point_size,button,1,x,y,w,h);
         goto err;
        }
	
        if(!parmcheck(ad_point_size,SSETSIZE,2,0))
        {
			gltxtattr.ssiz = Pval;
			attr_flag[4] = 1;			
	}
	else
	{
	 sobj = SSETSIZE;
         objc_draw(ad_point_size,button,1,x,y,w,h);
	 goto err;
	}


        jtype = unit_type;
	unit_type = 1;	/* points */
	if(!parmcheck(ad_point_size,LINESPCE,4,0)) /* used to be a 4 */
	{
		        unit_type = jtype;
			gltxtattr.lnsp = (long)Pval;
			attr_flag[2] = 1;
 	}
        else
	{
	  unit_type = jtype;
	  sobj = LINESPCE;
          objc_draw(ad_point_size,button,1,x,y,w,h);
	  goto err;
	}



        if(ad_point_size[FKERNON].ob_state == SELECTED)
        {
	   gltxtattr.kernmd = 1;
	   ad_point_size[FKERNON].ob_state = NORMAL;
        }
	else
	{
	   gltxtattr.kernmd = 0;
	   ad_point_size[FKERNOFF].ob_state = NORMAL;
	}
	attr_flag[8] = 1;

        if(ad_point_size[FREVON].ob_state == SELECTED)
        {
	   gltxtattr.rvomd = 1;
	   ad_point_size[FREVON].ob_state = NORMAL;
        }
	else
	{
	   gltxtattr.rvomd = 0;
	   ad_point_size[FREVOFF].ob_state = NORMAL;
	}
        attr_flag[19] = 1;
     }
     update_point_dialog();
     form_dial(3,0,0,3,36,x,y,w,h);
     zdevice = SCANNER;
     SH = vmupix((int)gltxtattr.lnsp);
     
     if(button == FOK)
     {
	 upd_txt_attributes();
     }

}



/************************************************************************/
/* Function: upd_txt_attributes()					*/
/* Description: Stuff global attributes into the proper regions(s)      */
/************************************************************************/
upd_txt_attributes()
{
  register REGION *rptr;
  int found;     
  long art;
  struct txtattr locattr;

   if(multi_mode)
   {
           f_move(&gltxtattr.llen,&locattr.llen,sizeof(struct txtattr));
	   rptr = curpage->regptr;
	   while(rptr)
	   {
	      get_txtattr(rptr,&tmpattr);

	      if(rptr->multi_select && !rptr->type)
	      {
                   f_move(&locattr.llen,&gltxtattr.llen,sizeof(struct txtattr));
		   copy_attr(&tmpattr);
		   put_txtattr(rptr,&tmpattr);
	 	   art = get_regart(rptr);
		   if(art)
		   {
			open_article(art);
			do_artcleanup(rptr,0);
		   }
	      }
	      rptr = rptr->plink;
	   }
	   force_preview();
   }
   else if(gl_region_ptr)
   {
      put_txtattr(gl_region_ptr,&gltxtattr);
      page_redraw(gl_region_ptr);
   }
}



/**************************************************************************/
/* Function: do_scoffset()						  */
/* Description: Dialog to handle scan offset				  */
/**************************************************************************/
do_scoffset()
{
     int button;
     int x,y,w,h;
     int jtype;

     clr_attr_flag();

     jtype = unit_type;
     unit_type = 1;
     to_mu_vlrv(ad_scanoff,gltxtattr.scoff,SSCANVAL);
     unit_type = jtype;

     form_center(ad_scanoff,&x,&y,&w,&h);
     form_dial(0,0,0,36,36,x,y,w,h);
     objc_draw(ad_scanoff,0,MAX_DEPTH,x,y,w,h);
     
err:
     button = form_do(ad_scanoff,SSCANVAL);
     ad_scanoff[button].ob_state = NORMAL;
     if(button == SCANOK)
     {
	 jtype = unit_type;
	 unit_type = 1;
	 if(!parmcheck(ad_scanoff,SSCANVAL,4,0)) /* used to be a 4 */
	 {
	    unit_type = jtype;
	    gltxtattr.scoff = Pval;
	    attr_flag[22] = 1;
	    upd_txt_attributes();
	 }
	 else
	 {
	    unit_type = jtype;
	    objc_draw(ad_scanoff,button,1,x,y,w,h);
	    goto err;
	 }
     }
     form_dial(3,0,0,3,36,x,y,w,h);
}





/**************************************************************************/
/* Function:    do_go_page()						  */
/* Description: Set Current Page Number					  */
/**************************************************************************/
do_go_page()
{
     int button;
     int tmp_setting;
     int prev_page;

     prev_page = tmp_setting = curr_page;

     set_int(ad_go_page,GOTOPAGE,curr_page);     
     button = execform(ad_go_page,GOTOPAGE);
     ad_go_page[button].ob_state = NORMAL;
     if(button == GOOK)
     {
	 tmp_setting = get_int(ad_go_page,GOTOPAGE);
	 if(tmp_setting > 999)
		  curr_page = 999;
         else
	     curr_page = ((tmp_setting < 0) ? (0):(tmp_setting));
     }
     set_int(ad_go_page,GOTOPAGE,curr_page);

     if(prev_page != curr_page)
     {
		mode_change = TRUE;
		force_preview();
     }
     do_pagenum(curr_page,(curr_page%2)?1:0);
}




/**************************************************************************/
/* Function:    do_font_info()						  */
/* Description: Get info from dialog boxes				  */
/**************************************************************************/
do_font_info(tree,index,fmax,fmin,value)
OBJECT *tree;
int index;
int fmax;
int fmin;
int *value;
{
    int tmp_setting;

    tmp_setting = get_int(tree,index);
    if(tmp_setting > fmax)
        *value = fmin;
    else
        *value = ((tmp_setting < fmin) ? (fmin): (tmp_setting));
}




/**************************************************************************/
/* Function:	get_image()						  */
/* Description:	Setup to load images dialog				  */
/**************************************************************************/
get_image()
{
    int button;
    register int i;
    int changed;

    button = execform(ad_get_image,0);
    ad_get_image[button].ob_state = NORMAL;
    for(i=INEO;i<=IPI1;i++)
    {
       if(ad_get_image[i].ob_state == SELECTED)
       {
	  cur_pic_type = i - INEO;
          break;
       }
    }
    strcpy(pathbuf,dpath3);
    switch(cur_pic_type)
    {
       case 0:  strcat(pathbuf,"*.NEO");
		
		break;

       case 1:  strcat(pathbuf,"*.IMG");
		break;

       case 2:  strcat(pathbuf,"*.GEM");
		break;

       case 3:  strcat(pathbuf,"*.PI1");
		break;
    }
    if(!get_fs(fbuffer,&changed))
    {
               funcs = &nada;
	       graf_mouse(ARROW,&dummy);
	       return(0);
    }

    if(changed)					/* If path changed */
    {
	alert_cntre(ALERT38);
	funcs = &nada;
	graf_mouse(ARROW,&dummy);
	return(0);
    }

    extender(fbuffer,gtype[cur_pic_type]);
    Fsetdta(&thedta.res[0]);
    if(Fsfirst(fbuffer,0) <= -1)
    {
		funcs = &nada;
		graf_mouse(ARROW,&dummy);
		alert_cntre(ALERT8);		
		return(0);
    }
    return(1);
	      
}




/**************************************************************************/
/* Function:	update_point_dialog()					  */
/* Description:	Setup Font info						  */
/**************************************************************************/
update_point_dialog()
{
     int jtype;

     set_int(ad_point_size,FONTNUM,gltxtattr.font);
     to_mu_pt12(ad_point_size,gltxtattr.ssiz,SSETSIZE);
     to_mu_pt12(ad_point_size,gltxtattr.ptsz,FNTSIZE);

     jtype = unit_type;
     unit_type = 1;	/* points */     
     to_mu_vlrv(ad_point_size,(int)gltxtattr.lnsp,LINESPCE);
     unit_type = jtype;
}




/**************************************************************************/
/* Function: init_artobj()						  */
/* Description:	Initialize Article selector box				  */
/**************************************************************************/
init_artobj()
{
   int tot;

   tot = get_num_arts();
   init_slider(artobj,tot,DSLDER,DSLDBOX,&hslider,PAGESIZ);
   curfirst_art = 0;			/* Start with first article */
   set_artobj(curfirst_art);
}





/**************************************************************************/
/* Function: deselect()							  */
/* Description: Deselect all objects of the Article tree		  */
/**************************************************************************/
deselect()
{
   register int i;

   for(i = DART1;i <= DART8;i++)
   {
	if(artobj[i].ob_state == SELECTED)
	{
	   objc_change(artobj,i,0,aworkx,aworky,aworkw,aworkh,
		NORMAL,1);
	}
   }
}




/**************************************************************************/
/* Function: init_slider()						  */
/* Description: Initialize the slider size in the Article box		  */
/**************************************************************************/
init_slider(obj,tot_names,slider,sld_box,height,max)
OBJECT *obj;
int	tot_names,slider,sld_box;
int	*height;
int     max;
{
	register OBJECT	*sldobj;
	register OBJECT	*sldbxobj;

	sldobj = &obj[slider];		/* init slider object */
	sldbxobj = &obj[sld_box];	/* init slider object */

	sldobj->ob_y = 0;		/* init slider -top position */
					/* set slider box size */
	if(tot_names <= max)
		sldobj->ob_height=sldbxobj->ob_height;
	else
		sldobj->ob_height=(sldbxobj->ob_height*max)/tot_names;
	*height = sldbxobj->ob_height - sldobj->ob_height;
}



/************************************************************************/
/* Function: get_num_arts()						*/
/* Description: Return number of articles in memory			*/
/************************************************************************/
get_num_arts()
{
   register int count;

   if(!getf_article())
	return(0);
   count = 1;
   while(getn_article())
	count++;
   return(count);
}




/************************************************************************/
/* do_slider	Move the slider in the slider box to the correct	*/
/*		position.						*/
/************************************************************************/
do_slider(obj,slider,sld_box,sld_height,tot_names,cur_name,max)
OBJECT	*obj;
int	slider;
int	sld_box;
register int	sld_height;
int	tot_names;
int	cur_name;
int     max;
{
   int	y;
   register OBJECT	*sldobj;

   sldobj = &obj[slider];	 	      /* init slider object      */
   y = sldobj->ob_y;		              /* get current y position  */
   sldobj->ob_y =  (sld_height*cur_name)/(tot_names-max);
   if(sldobj->ob_y > sld_height)              /* keep in parent box      */
   	sldobj->ob_y = sld_height;
   if(sldobj->ob_y != y)		      /* If (different position) */
	objc_draw(obj,sld_box,1,aworkx,aworky,aworkw,aworkh);     /* draw it */
}



/**************************************************************************/
/* Function do_artobj()							  */
/* Description: 							  */
/**************************************************************************/
long do_artobj()
{
   int x,y,w,h;
   register int obj;
   int cont;
   int okflag;
   int tmpxy[4];
   register long artptr;
   register int i;
   int found;
   char *str;

   vs_clip(shandle,0,tmpxy);
   init_artobj();
   form_center(artobj,&x,&y,&w,&h);
   form_dial(0,0,0,36,36,x,y,w,h);
   objc_draw(artobj,0,MAX_DEPTH,x,y,w,h);

   do
   {
	 obj = form_do(artobj,0);
  	 obj &= 0x7fff;
	 cont = hndl_abox(obj,&okflag);
   }while(cont);
   if(okflag)
   {
      artobj[DOK].ob_state = NORMAL;
      found = 0;
      for(i = DART1;i <= DART8;i++)
      {
	 if(artobj[i].ob_state == SELECTED)
	 {
		artobj[i].ob_state = NORMAL;
		found = 1;
		break;
	 }
      }
      if(found)
      {
         artptr = getf_article();
	 while(artptr)
	 {
	    str = get_artfname();

	    if(!strcmp(str,artobj[i].ob_spec))
		break;
	    artptr = getn_article();
	 }
      }
      else		/* If not found */
	artptr = 0L;
   }
   else			/* If cancel selected */
   {
	artobj[DCANCEL].ob_state = NORMAL;
	artptr = 0L; 
   }
   form_dial(3,0,0,36,36,x,y,w,h);
   screen_clip();
   return artptr;
}




/************************************************************************/
/* get_artptr	Handle the article box					*/
/************************************************************************/
hndl_abox(obj,okflag)
int	obj;
int 	*okflag;
{
int	mov_dir;
int	x_box,y_box;
int	value;
int	num;
register OBJECT	*slider;
register OBJECT	*slidbox;
int 	cont;
int 	mx,my;
int	dummy;

   *okflag = 1;
   cont = 1;
   num = get_num_arts();
   slider = &artobj[DSLDER];
   slidbox = &artobj[DSLDBOX];
   switch(obj)
   {
	case	DDOWN:
	   if(slider->ob_y == slidbox->ob_height-hslider) 
		break;
	   hndl_list(curfirst_art,1);
	   break;
	case	DUP:
	   if(!slider->ob_y) 
		break;
	   hndl_list(curfirst_art,-1);
	   break;
	case	DSLDBOX:
	   graf_mkstate(&mx,&my,&dummy,&dummy);
	   objc_offset(artobj,DSLDBOX,&x_box,&y_box);
	   if(my > y_box+slider->ob_y) 
		mov_dir = PAGESIZ;
	   else	
		mov_dir = -PAGESIZ;
	   hndl_list(curfirst_art,mov_dir);
	   break;
	case	DSLDER:
	   value = graf_slidebox(artobj,DSLDBOX,DSLDER);
	   value = scaler(value,num-PAGESIZ,1000);
	   hndl_list(value,0);
	   break;
	case	DART1:
	case	DART2:
	case	DART3:
	case	DART4:
	case	DART5:
	case	DART6:
	case	DART7:
	case	DART8:
           break;
	case	DOK:
	   cont = 0;
	   *okflag = 1;
	   break;
	case 	DCANCEL:
	   cont = 0;
	   *okflag = 0;
	default:
           break;
   } /* end switch */

   return(cont);
}





/************************************************************************/
/* hndl_list	Routine to handle the font selection list.		*/
/************************************************************************/
hndl_list(begname,movdir)
int	begname;
int	movdir;
{
   int	tot;

   tot =  get_num_arts();
   gsx_moff();			/* remove the rat */
   deselect();			/* deselect names */
   curfirst_art = scroll(tot,begname,movdir);
   do_slider(artobj,DSLDER,DSLDBOX,hslider,tot,curfirst_art,PAGESIZ);
   gsx_mon();	
}




/************************************************************************/
/* scroll	Given a pointer to a device block the starting font in  */
/* the font list, and the amt to scroll(1,-1,PAGESIZ,-PAGESIZ). Returns */
/* the object number of the top displayed object.		        */
/************************************************************************/
scroll(total_names,startname,amount)
int	total_names;
int	startname;		/* starting font in linked list */
int	amount;			/* amount to move by */
{
   register int	i,j;
   int	textobj,x,y;
   long scrmfdb;

   scrmfdb = 0L;

   i = startname+amount;
   j = total_names-PAGESIZ;

   if(i<0 || j<0) 
	i = 0;
   if(j<0) 
	j=0;
   if(i>j) 
    	i = j;


   set_artobj(i);

   if(amount != -1 && amount != 1) 
   { 					/* do page scrolling (objc_draw) */
	objc_draw(artobj,DARTROOT,1,aworkx,aworky,aworkw,aworkh);
	return(i);
   }
   if(i==startname)
	 return(i);			/* reject unnecessary single scroll */

					/* else we do single line scroll */

   objc_offset(artobj,DART1,&x,&y);

   ptsin[0] = x;				/* init clipping x,y,w,h */
   ptsin[1] = y;
   ptsin[2] = x+artobj[DART1].ob_width;
   ptsin[3] = y+gl_hchar*PAGESIZ-1;

   ptsin[4] = x;				/* init blit destination */
   ptsin[5] = y;
   ptsin[6] = ptsin[2];
   ptsin[7] = ptsin[3];

   vs_clip(shandle,1,ptsin);

   if(amount < 0) 
   {						/* if (-) going up */
	ptsin[1] -= gl_hchar;		/* src y */
	ptsin[3] += gl_hchar;		/* src h */
	ptsin[7] += gl_hchar;
	textobj = artobj[DARTROOT].ob_head;
   }
   else 
   {						/* going down */
	ptsin[3] += gl_hchar;
	ptsin[5] -= gl_hchar;
	ptsin[7] -= gl_hchar;
	textobj = artobj[DARTROOT].ob_tail;
   }
   gsx_moff();
   vro_cpyfm(shandle,3,ptsin,&scrmfdb,&scrmfdb);
   objc_draw(artobj,textobj,0,aworkx,aworky,aworkw,aworkh);
   gsx_mon();
   return(i);
}




/************************************************************************/
/* set_artobj	Set the objects string pointers in the artobj to the    */
/*		article names found in article linked list. Starting	*/
/*		at the curr_index articles and continuing until		*/
/*		PAGESIZ are done or no more.  				*/
/************************************************************************/
set_artobj(nameindex)
register int	nameindex;
{
   int	flag;
   register OBJECT *curobj;
   register int i;
   int obj;
   register long artnames;
   char *fname;

   flag = SELECTABLE|RBUTTON;			/* if displayed fonts */
						/* get to current index */
   artnames = getf_article();
   if(artnames)
   {
	while(nameindex-- && artnames)
	   artnames = getn_article();
   }
   i  = PAGESIZ-1;
   obj = DART1;
   do 
   {
	curobj = &artobj[obj];			  /* current GSTRING   */
	if(!artnames) 
	{					  /* if no font        */
	   curobj->ob_spec = tmpflname; 	  /* use template      */
           curobj->ob_flags = NONE;
	}
	else 
	{
	   fname = get_artfname();
	   curobj->ob_spec = fname;               /* or filename       */
	   curobj->ob_flags = flag;	 	  /* set proper flags  */
	   artnames = getn_article();
	}
	obj = curobj->ob_next;	   		  /* next object index */

   } while(i--);
}





/**************************************************************************/
/* Function: do_unit_dialog()						  */
/* Description: handle changing units of measure			  */
/**************************************************************************/
do_unit_dialog()
{
   int button;
   register int i;
   register int *hval,*vval;
   int titem;

   unitobj[MINCHES+unit_type].ob_state = SELECTED;
   button = execform(unitobj,0);
   unitobj[button].ob_state = NORMAL;
   if(button == MOK)
   {
	for(i = MINCHES;i <= MCICERO;i++)
	{
	   if(unitobj[i].ob_state == SELECTED)
	   {
		unitobj[i].ob_state = NORMAL;
		unit_type = i - MINCHES;
	   }
        }

    	   switch(unit_type)
           {
      	      case 0:   hval = hinch_mus;
			vval = vinch_mus; 
 			break;

      	      case 1:	hval = hpica_mus;
			vval = vpica_mus;
			break;

	      case 2:	hval = hcent_mus;
			vval = vcent_mus;
			break;

      	      case 3:	hval = hcicero_mus;
			vval = vcicero_mus;
			break;
   	    }


	    for(i = GRBUT1;i <= GRBUT4;i++)
            {
	       if(gridspace[i].ob_state == SELECTED)
	       {
		 hgridspace = hval[i - GRBUT1];
		 vgridspace = vval[i - GRBUT1];
	       }
	    }
            if(view_size != PADJCNT)
		titem = view_size;
      	    else
       	 	titem = ((curr_page % 2)?(view_size + 1):(view_size));	    
      	    wind_set(prev_handle,WF_INFO,winfo[titem - PSIZE][unit_type]);
	    return(1);	
   }
   else
   {
	for(i=MINCHES;i<=MCICERO;i++)
		unitobj[i].ob_state = NORMAL;
	unitobj[MINCHES+unit_type].ob_state = SELECTED;
	return(0);
   }
}





/**************************************************************************/
/* Function: do_grid_space()						  */
/* Description: select grid spacing dialog				  */
/**************************************************************************/
do_grid_space()
{
   int button;
   register int i;
   int oldsp;
   register char **str;
   register int *hval;
   register int *vval;
   
   switch(unit_type)
   {
      case 0:   str = grid_inch;
		hval = hinch_mus;
		vval = vinch_mus; 
 		break;
      case 1:   str = grid_picas;
		hval = hpica_mus;
		vval = vpica_mus;
		break;
      case 2:   str = grid_cents;
		hval = hcent_mus;
		vval = vcent_mus;
		break;
      case 3:   str = grid_cicero;
		hval = hcicero_mus;
		vval = vcicero_mus;
   }
   for(i = GRBUT1;i <= GRBUT4;i++)
   {
      gridspace[i].ob_spec = str[i - GRBUT1];
      if(gridspace[i].ob_state == SELECTED)
      {
	oldsp = i;
      }
   }
   button = execform(gridspace,0);
   if(button == GRIDOK)
   {
	gridspace[GRIDOK].ob_state = NORMAL;
	for(i = GRBUT1;i <= GRBUT4;i++)
        {
	   if(gridspace[i].ob_state == SELECTED)
	   {
		hgridspace = hval[i - GRBUT1];
		vgridspace = vval[i - GRBUT1];
	   }
	}
	return(1);
   }
   else
   {
	for(i = GRBUT1;i <= GRBUT4;i++)
        {
	   gridspace[i].ob_state = NORMAL;
	}
        gridspace[oldsp].ob_state = SELECTED;
	gridspace[GRIDCAN].ob_state = NORMAL;
	return(0);
   }
   
}
	




/**************************************************************************/
/* Function: do_page_def()						  */
/* Description: Page Type Selection Dialog				  */
/**************************************************************************/
do_page_def()
{
   int button;
   register int i;
   int pagetmp;

   for(i=PA4;i<=PLEGAL;i++)
	adpagedef[i].ob_state = NORMAL;
   adpagedef[PPORT].ob_state = NORMAL;
   adpagedef[PLAND].ob_state = NORMAL;

   if(pagetype > PLEGAL)
   {
	adpagedef[PLAND].ob_state = SELECTED;		/* offset by 4    */
	adpagedef[pagetype - 4].ob_state = SELECTED;    /* for index      */
   }
   else
   {
     adpagedef[PPORT].ob_state = SELECTED;
     adpagedef[pagetype].ob_state  = SELECTED;
   }
   pagetmp = pagetype;

   button = execform(adpagedef,0);
   adpagedef[button].ob_state = NORMAL;
   if(button == PSIZEOK)
   {
	for(i=PA4;i<=PLEGAL;i++)
	{
	   if(adpagedef[i].ob_state == SELECTED)
	   {
		pagetype = i;
		if(adpagedef[PLAND].ob_state == SELECTED)
				pagetype += 4;		    /* offset to landscape*/
	        if(pagetype == PLEGAL + 4)
		{
		   if((view_size == PADJCNT) || (view_size == P200))
							goto cancel;
		   menu_ienable(ad_menu,PADJCNT,FALSE);
		   menu_ienable(ad_menu,P200,FALSE);
	        }
                else
                {
		   menu_ienable(ad_menu,PADJCNT,TRUE);
		   menu_ienable(ad_menu,P200,TRUE);
                }
		hpage_size = pagemux[pagetype - PA4];
		vpage_size = pagemuy[pagetype - PA4];
		mutomem(hpage_size,vpage_size,&scan_xres,&scan_yres);
      		page_area.g_x = page_area.g_y = 0L;
                gsx_moff();
                vsf_interior(shandle,0);			/* Set to Solid   */
      		if((view_size == PSIZE) ||
		   (view_size == PADJCNT))
		 	pdraw_fit(view_size);
      		else
		 	pdraw_scale();
      		zoom_setup();
      		cur_scale = get_scale_num(view_size);
      		get_work(prev_handle);
      		update_preview_blit();
      		set_clip(TRUE,&pwork);
      		vr_recfl(shandle,pxy);
      		set_clip(FALSE,&pwork);
      		gsx_mon();
      		clear_window(prev_handle,2,1);
      		set_clip(TRUE,&pwork);
      		init_rulers();
      		force_preview();
      		slider_chk();
      		set_clip(TRUE,&dpwork);
	   }
	}
   }
   else
   {
cancel:
	pagetype = pagetmp;
	for(i=PA4;i<=PLEGAL;i++)
		adpagedef[i].ob_state = NORMAL;
	adpagedef[PPORT].ob_state = NORMAL;
	adpagedef[PLAND].ob_state = NORMAL;

        if(pagetype > PLEGAL)
	{
	   adpagedef[pagetype-4].ob_state  = SELECTED;
	   adpagedef[PLEGAL].ob_state = SELECTED;
	}
	else
	{
	   adpagedef[pagetype].ob_state  = SELECTED;
	   adpagedef[PPORT].ob_state = SELECTED;
	}
   }
}





/**************************************************************************/
/* Function: do_clip_dialog()						  */
/* Description: clip board dialog box...				  */
/**************************************************************************/
do_clip_dialog()
{
   int button;
   int fromval,toval;
   register int i;

   set_int(adclipobj,CLFROM,curr_page);
   set_int(adclipobj,CLTO,curr_page);

   button = execform(adclipobj,CLTO);
   if(button == CLOK)
   {
      adclipobj[CLOK].ob_state = NORMAL;
      fromval = get_int(adclipobj,CLFROM);
      toval   = get_int(adclipobj,CLTO);
      if(toval < fromval)
	 toval = fromval;
      if(adclipobj[CLCUR].ob_state == SELECTED)
      {	        
         clip_to_page(curr_page);
      }
      else if(adclipobj[CLALL].ob_state == SELECTED)
      {
	 for(i = fromval; i <= toval;i++)
	 {
	    if(!clip_to_page(i))
		break;
	 }
      }
      else if(adclipobj[CLEVEN].ob_state == SELECTED)
      {
	 for(i = fromval; i <= toval;i++)
	 {
	    if(!(i & 1))		/* Only even numbers */
	    {
		if(!clip_to_page(i))
		   break;
	    }
	 }
      }
      else 
      {
	for(i = fromval; i <= toval; i++)
	{
	   if(i & 1)
	   {
		if(!clip_to_page(i))
		   break;
	   }
	}
      }
      force_draw_flag = TRUE;
      force_preview();
      menu_ienable(ad_menu,ACREATE,1);
   }
   else
	adclipobj[CLCANCEL].ob_state = NORMAL;
}





/**************************************************************************/
/* Function: do_rcoord()						  */
/* Description: Handle typed in coordinates of regions			  */
/**************************************************************************/
do_rcoord()
{
     int button;
     long *str1;
     int  page;
     int  type;
     int  bx1,by1,bx2,by2;
     int  cx1,cy1,cx2,cy2;
     int  sobj;
     int  x,y,w,h;

   if(region_ptr)
   {
     check_top_window();
     find_boundary(region_ptr,&bx1,&by1,&bx2,&by2,&type,&page);


     int_mu_hlrv(ad_rcoord,bx1,RUPLEFT);
     int_mu_vlrv(ad_rcoord,by1,RUPRIGHT);
     int_mu_hlrv(ad_rcoord,bx2-bx1,REGWIDTH);
     int_mu_vlrv(ad_rcoord,by2-by1,RHEIGHT);

     str1 = ad_rcoord[REGUNITS].ob_spec;
     strcpy(*str1,rcoord_unit[unit_type]);
     form_center(ad_rcoord,&x,&y,&w,&h);
     form_dial(0,0,0,36,36,x,y,w,h);
     objc_draw(ad_rcoord,0,MAX_DEPTH,x,y,w,h);

     sobj = RUPLEFT;     

err:
     button = form_do(ad_rcoord,sobj);

     ad_rcoord[button].ob_state = NORMAL;
     if(button == ROK)
     {

        if(!parmcheck(ad_rcoord,RUPLEFT,1,1))   /* Upper left */
        {
	  cx1 = Pval;
          if(!parmcheck(ad_rcoord,RUPRIGHT,3,1))/* upper right*/
	  {
	    cy1 = Pval;
            if(!parmcheck(ad_rcoord,REGWIDTH,1,1))/* lower left */
	    {
	      cx2 = Pval;
              if(!parmcheck(ad_rcoord,RHEIGHT,3,1))/* lower right*/
	      {
	        cy2 = Pval; 
	        do_trans_scale(bx1,by1,bx2-bx1,by2-by1,
		       cx1,cy1,cx2,cy2,type);
	      }
	      else
	      {
    	   	objc_draw(ad_rcoord,button,1,x,y,w,h);
		sobj = RHEIGHT;
		goto err;
	      }
	    }
	    else
	    {
    	   	objc_draw(ad_rcoord,button,1,x,y,w,h);
		sobj = REGWIDTH;
		goto err;
	    }
	  }
	  else
	  {
     	     objc_draw(ad_rcoord,button,1,x,y,w,h);
	     sobj = RUPRIGHT;
	     goto err;
	  }
        }      /*if(!parmcheck(ad_pcoord,PUPLEFT,1))*/
	else
	{
    	   objc_draw(ad_rcoord,button,1,x,y,w,h);
	   sobj = RUPLEFT;
	   goto err;
	}
     }
   }
   form_dial(3,0,0,3,36,x,y,w,h);
   clear_regprim_flags();
   do_blit();
}



/**************************************************************************/
/* Function: do_set_paths()						  */
/* Description: Handle Default Path dialog box				  */
/**************************************************************************/
do_set_paths()
{
   int button;

   button = execform(ad_paths,PATHTEXT);
   ad_paths[button].ob_state = NORMAL;
   
   if(button == PATHOK)				/* save paths */
   {
      dpath1 = get_edit(ad_paths,PATHTEXT);
      dpath2 = get_edit(ad_paths,PATHCLIP);
      dpath3 = get_edit(ad_paths,PATHGRAP);
      dpath4 = get_edit(ad_paths,PATHDOC);	

      write_paths(dpath1,dpath2,dpath3,dpath4);
   }
   else						/* restore    */
   {
      restore_paths(dpath1,dpath2,dpath3,dpath4);
      set_tedit(ad_paths,PATHTEXT,dpath1);
      set_tedit(ad_paths,PATHCLIP,dpath2);
      set_tedit(ad_paths,PATHGRAP,dpath3);
      set_tedit(ad_paths,PATHDOC,dpath4);	
   }
}



/**************************************************************************/
/* Function: set_tedit()						  */
/* Description: Insert Text into Text Dialog Field			  */
/**************************************************************************/
set_tedit(tree,object,str)
OBJECT *tree;
int object;
char *str;
{
    long *str1;

     str1 = tree[object].ob_spec;
     strcpy(*str1,str);
}


/**************************************************************************/
/* Function: get_edit()							  */
/* Description: Get text from Editable Text Dialog Field		  */
/**************************************************************************/
char *get_edit(tree,obj)
OBJECT *tree;
int obj;
{
    long *str1;

    str1 = tree[obj].ob_spec;
    return(*str1);
}




/**************************************************************************/
/* Function: do_pcoord()						  */
/* Description: Handle primitive type in coordinates dialog box		  */
/**************************************************************************/
do_pcoord()
{
     int button;
     long *str1;
     int  type;
     int  bx1,by1,bx2,by2;
     int  cx1,cy1,cx2,cy2;
     int opcode,pcount;
     unsigned long rptr;
     int sobj;
     int x,y,w,h;

     if(!region_ptr)
     {
	clear_regprim_flags();		/* if no region, ergo, no prim  */
	do_blit();
	return;				/* ergo, clean up and return    */
     }

     rptr = get_curreg(&type);  
     opcode = get_cur_prim(&pcount,&wmode,&prim_ptr);

     if(prim_ptr)
     {
       calc_prim(opcode,&bx1,&by1,&bx2,&by2,pcount);
       check_top_window();


       int_mu_hlrv(ad_pcoord,bx1,PUPLEFT);
       int_mu_vlrv(ad_pcoord,by1,PUPRIGHT);
       int_mu_hlrv(ad_pcoord,bx2-bx1,PWIDTH);
       int_mu_vlrv(ad_pcoord,by2-by1,PHEIGHT);

       str1 = ad_pcoord[PRIMUNIT].ob_spec;
       strcpy(*str1,rcoord_unit[unit_type]);


     sobj = PUPLEFT;
     form_center(ad_pcoord,&x,&y,&w,&h);
     form_dial(0,0,0,36,36,x,y,w,h);
     objc_draw(ad_pcoord,0,MAX_DEPTH,x,y,w,h);

err:
       button = form_do(ad_pcoord,sobj);

       ad_pcoord[button].ob_state = NORMAL;

       if(button == POK)
       {
	  if(!parmcheck(ad_pcoord,PUPLEFT,1,1))
          {
	    cx1 = Pval;

	    if(!parmcheck(ad_pcoord,PUPRIGHT,3,1))
	    {
	      cy1 = Pval;
	      if(!parmcheck(ad_pcoord,PWIDTH,1,1))
	      {
	        cx2 = Pval;
	        if(!parmcheck(ad_pcoord,PHEIGHT,3,1))
		{
	        cy2 = Pval;

	        scale_prim_coord(opcode,bx1,by1,bx2-bx1,by2-by1,
	  	           cx1,cy1,cx2,cy2,type,pcount,wmode);
		}
		else
		{
    	    	  objc_draw(ad_pcoord,button,1,x,y,w,h);
		  sobj = PHEIGHT;
		  goto err;
		}
	      }
	      else
	      {
    	        objc_draw(ad_pcoord,button,1,x,y,w,h);
		sobj = PWIDTH;
		goto err;
	      }
	    }
	    else
	    {
    	      objc_draw(ad_pcoord,button,1,x,y,w,h);
	      sobj = PUPRIGHT;
	      goto err;
	    }
          }	  /*if(!parmcheck(ad_pcoord,PUPLEFT,1))  */
	  else
	  {
    	    objc_draw(ad_pcoord,button,1,x,y,w,h);
	    sobj = PUPLEFT;
	    goto err;
	  }
       }
     }
     form_dial(3,0,0,3,36,x,y,w,h);
     clear_regprim_flags();
     do_blit();				/* always clear primitives and regions*/
					/* and screen of markings after this  */
}




/**************************************************************************/
/* Function: set_template()						  */
/* Description: Set template usage dialog box				  */
/**************************************************************************/
set_template()
{
   register int i;
   int button;

   for(i=SETTBOTH;i<=SETTRITE;i++)
	ad_settmpl[i].ob_state = NORMAL;
   ad_settmpl[disp_type + SETTBOTH].ob_state = SELECTED;

   ad_settmpl[SETTFRNT].ob_state = NORMAL;
   ad_settmpl[SETTBACK].ob_state = NORMAL;

   if(disp_pos)
	ad_settmpl[SETTBACK].ob_state = SELECTED;
   else
	ad_settmpl[SETTFRNT].ob_state = SELECTED;
   
   button = execform(ad_settmpl,0);
   ad_settmpl[button].ob_state = NORMAL;
   
   if(button == SETTOK)
   {
     for(i=SETTBOTH;i<=SETTRITE;i++)
     {
      if(ad_settmpl[i].ob_state == SELECTED)
			disp_type = i - SETTBOTH;
     }
						/* 0 = front 1 = back */
     disp_pos=((ad_settmpl[SETTFRNT].ob_state==SELECTED)?(0):(1));
     force_preview();
   }
}



/**************************************************************************/
/* Function: page_numbering()						  */
/* Description: Handle page numbering dialog box			  */
/**************************************************************************/
page_numbering()
{
    int button;
    long *str1;
    long *str3;
    long *str4;
    long *str5;
    long str2;
    int fnt;
    int ptsize;
    int setsize;
    int pxy[4];
    int x,y,w,h;
    int x1,y1;
    int curvpos;
    int curdflag;
    char text[PTEXTMAX];    
    register int i;
    int lcurjust;
    int rcurjust;
    int curusage;
    register int findex;
    int *fntptr;
    int found;
    int fpage,tpage;
    int minpage,maxpage;
    int tmppage;
    int sobj;
    int lowend = 0;
 
    fnt = pnum.pfnum;
    ptsize = pnum.pptsize;;
    setsize = pnum.pstsize;
    curvpos = pnum.vpos;
    curdflag = pnum.display;
    strcpy(text,pnum.text);
    lcurjust = pnum.ljust;
    rcurjust = pnum.rjust;
    curusage = pnum.usage;
    fpage = pnum.fpage;
    tpage = pnum.tpage;

    maxpage = minpage = 0;    
    if(get_fpage(&minpage))
    {
     maxpage = minpage;
     while(get_npage(&tmppage))
     {
	maxpage = tmppage;
     }
    }
     
/*
     fpage = max(fpage,minpage);
     tpage = min(tpage,maxpage);
*/
   fpage = minpage;			/* Slam to max and min of REAL Pages*/
   tpage = maxpage;  			/* Regardless of what they've typed */
   if(tpage < fpage)			/* in....			    */
		tpage = fpage;

    set_int(ad_pagenum,PNUMFROM,fpage);
    set_int(ad_pagenum,PNUMTO,tpage);

    /* to display or not */
    ad_pagenum[PDISPNUM].ob_state = ((curdflag)?(CHECKED):(NORMAL));


    findex = found = 0;
    for(findex = 0;findex < 16;findex++)
    {
	fntptr = ftlib + (findex*SFTSIZ);
	if(fnt == *fntptr)
	{
	  found = 1;
	  break;
	}
    }
    str1 = ad_pagenum[PFNAME].ob_spec;		/* Font name and number*/
    if(!found)
    {
	   findex = -1;
	   lowend = -1;
	   str2 = " ";
           set_int(ad_pagenum,PFNUM,fnt);
    }
    else
    {
       set_int(ad_pagenum,PFNUM,*fntptr);
       str2 = ftlib + ((findex * SFTSIZ)+TFNOFS);
    }
    strcpy(*str1,str2);

    to_mu_pt12(ad_pagenum,ptsize,PPOINTS);   /* Point size*/
    to_mu_pt12(ad_pagenum,setsize,PSETSIZE); /* Set size  */

    str3 = ad_pagenum[PAGEUNIT].ob_spec;	/* units - inches etc...*/
    strcpy(*str3,rcoord_unit[unit_type]);

    str4 = ad_pagenum[PTDIST].ob_spec;		/* Text for distance    */
    strcpy(*str4,dpagenum[curvpos]);

    str5 = ad_pagenum[PSTRING].ob_spec;
    strcpy(*str5,text);


    to_mu_vlrv(ad_pagenum,pnum.distance,PDIST);

    for(i=PLJLEFT;i<=PLJRIGHT;i++)
    {
       ad_pagenum[i].ob_state = NORMAL;
    }
    ad_pagenum[lcurjust + PLJLEFT].ob_state = SELECTED;


    for(i=PRJLEFT;i<=PRJRIGHT;i++)
    {
       ad_pagenum[i].ob_state = NORMAL;
    }
    ad_pagenum[rcurjust + PRJLEFT].ob_state = SELECTED;


    for(i=PLEFT;i<=PBOTH;i++)
    {
	ad_pagenum[i].ob_state = NORMAL;
    }
    ad_pagenum[curusage + PLEFT].ob_state = SELECTED;

    for(i=PTOP;i<=PBOTTOM;i++)
    {
	ad_pagenum[i].ob_state = NORMAL;
    }
    ad_pagenum[curvpos + PTOP].ob_state = SELECTED;

    form_center(ad_pagenum,&x,&y,&w,&h);
    form_dial(0,0,0,36,36,x,y,w,h);
    objc_draw(ad_pagenum,0,MAX_DEPTH,x,y,w,h);
    objc_offset(ad_pagenum,PFNAME,&x1,&y1);
    pxy[0] = x1;
    pxy[1] = y1;
    pxy[2] = x1 + ad_pagenum[PFNAME].ob_width - 1;
    pxy[3] = y1 + ad_pagenum[PFNAME].ob_height - 1;
    vsf_interior(shandle,0);

    sobj = PFNUM;
err:do
    {
      button = form_do(ad_pagenum,sobj);
      button &= 0x7fff;
      switch(button)
      {
	case PLARROW:
	case PRARROW:
		     findex = ((button==PRARROW)?(findex + 1):(findex-1));
		     if(findex < lowend)		/* 0 or -1 */
			   findex = 15;
		     if(findex > 15)
			   findex = lowend;		/* 0 or -1 */
		     if( findex == -1 )
			str2 = " ";
		     else
		        str2 = ftlib + ((findex * SFTSIZ)+TFNOFS);

		     strcpy(*str1,str2);
		     v_bar(shandle,pxy);
		     objc_draw(ad_pagenum,PFNAME,1,x,y,w,h);
		     fntptr = ftlib + (findex*SFTSIZ);
		     if(findex == -1 )
			set_int( ad_pagenum,PFNUM,fnt );
		     else
		        set_int(ad_pagenum,PFNUM,*fntptr);
		     objc_draw(ad_pagenum,PFNUM,1,x,y,w,h);
		     break;

	case PDISPNUM:curdflag^=TRUE; 
                      ad_pagenum[PDISPNUM].ob_state=((curdflag)?(CHECKED):(NORMAL));
		      objc_draw(ad_pagenum,PDISPNUM,1,x,y,w,h);
		      break;
	
	case PTOP:
	case PBOTTOM: curvpos = ((button == PTOP)?(0):(1));
		      strcpy(*str4,dpagenum[curvpos]);
		      objc_draw(ad_pagenum,PTDIST,1,x,y,w,h);
		      break;

        
	default:
		     break;
      }
    }while((button != PAGEOK) && (button != PAGECANC));


    ad_pagenum[button].ob_state = NORMAL;
    if(button == PAGEOK)
    {
	do_font_info(ad_pagenum,PFNUM,999,1,&pnum.pfnum); /* get font number */


	if(!parmcheck(ad_pagenum,PPOINTS,2,0))
				pnum.pptsize = Pval;
  	else
	{
	  sobj = PPOINTS;
          objc_draw(ad_pagenum,button,1,x,y,w,h);
	  goto err;
	}

	if(!parmcheck(ad_pagenum,PSETSIZE,2,0))
				pnum.pstsize = Pval;
	else
	{
	   sobj = PSETSIZE;
           objc_draw(ad_pagenum,button,1,x,y,w,h);
	   goto err;
	}

	pnum.display = (ad_pagenum[PDISPNUM].ob_state == CHECKED);

/*
        fpage = max(get_int(ad_pagenum,PNUMFROM),minpage);
        tpage = min(get_int(ad_pagenum,PNUMTO),maxpage);
*/
	fpage = minpage;		/* always slam it to max and */
	tpage = maxpage;		/* min number of REAL pages  */
        if(tpage < fpage)
		tpage = fpage;
	pnum.fpage = fpage;
        pnum.tpage = tpage;

	if(!parmcheck(ad_pagenum,PDIST,3,0))
			pnum.distance = Pval;
	else
	{
	  sobj = PDIST;
          objc_draw(ad_pagenum,button,1,x,y,w,h);	  
	  goto err;
	}

	for(i=PLJLEFT;i<=PLJRIGHT;i++)
	{
	   if(ad_pagenum[i].ob_state == SELECTED)
			pnum.ljust = i - PLJLEFT;
	}


	for(i=PRJLEFT;i<=PRJRIGHT;i++)
	{
	   if(ad_pagenum[i].ob_state == SELECTED)
			pnum.rjust = i - PRJLEFT;
	}

	for(i=PLEFT;i<=PBOTH;i++)
	{
	   if(ad_pagenum[i].ob_state == SELECTED)
			pnum.usage = i - PLEFT;
	}	
	
	for(i=PTOP;i<=PBOTTOM;i++)
	{
	   if(ad_pagenum[i].ob_state == SELECTED)
				pnum.vpos = i-PTOP;
	}
	strcpy(pnum.text,*str5);	
        pnum.tattrib.ptsz = pnum.pptsize;
        pnum.tattrib.font = pnum.pfnum;
	pnum.tattrib.ssiz = pnum.pstsize;
        pnum.tattrib.lnsp = (long)pttomu(pnum.pptsize/8);
    }
    form_dial(3,0,0,3,36,x,y,w,h);
    force_preview();

}



/**************************************************************************/
/* Function: do_dpi()							  */
/* Description: Set dpi for large monitors...				  */
/**************************************************************************/
do_dpi()
{
   int button;
   int xin,yin;
   long totalm;
   int dxres,dyres;
   long sbytes,pbytes;

   set_int(ad_dpi,HDPIDAT,axdpi[0]);
   set_int(ad_dpi,VDPIDAT,aydpi[0]);

   button = execform(ad_dpi,HDPIDAT);
   ad_dpi[button].ob_state = NORMAL;
   if(button == DOTOK)
   {
        xin = get_int(ad_dpi,HDPIDAT);
	yin = get_int(ad_dpi,VDPIDAT);

	totalm = Malloc(-1L);
        totalm += scan_bytes + prev_bytes;

	dxres = xin * 8;	/* max page sizes in inches */
        dyres = yin * 14;
        sbytes = ((((long)dxres) * (long)dyres)/ 8L);
	pbytes = sbytes * 4L;   /* for 200% size  */

        if((sbytes + pbytes) < totalm)
        {
	    Mfree(scanesc);	/* free both buffers...*/
	    Mfree(pagesc);
	    scan_bytes = sbytes;
	    pagebytes = prev_bytes = pbytes;
	    scanptr = scanesc = (unsigned long)Malloc(scan_bytes);
	    page_ptr = pagesc = (unsigned long)Malloc(prev_bytes);

	    axdpi[0] = axdpi[1] = axdpi[2] = xin;
	    aydpi[0] = aydpi[1] = aydpi[2] = yin;

 	    half_xdpi[0] = half_xdpi[1] = half_xdpi[2] = xin/2;
	    half_ydpi[0] = half_ydpi[1] = half_ydpi[2] = yin/2;

	    sdevm = 0;
	    xdpi[0] = xin;
	    ydpi[0] = yin;

            mutomem(hpage_size,vpage_size,&scan_xres,&scan_yres);	    
            page_MFDB.fd_addr = page_ptr;         /* Preview address MFDB */

	    mutopage(hpage_size,vpage_size,&mxres,&myres,1);

      	    page_area.g_x = page_area.g_y = 0L;

	    gsx_moff();
      	    vsf_interior(shandle,0);			/* Set to Solid   */

      	    GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);	    


      	    if( (view_size == PSIZE) ||
	  	(view_size == PADJCNT))
		 	pdraw_fit(view_size);
	    else
		        pdraw_scale();
	    zoom_setup();
      	    cur_scale = get_scale_num(view_size);
      	    get_work(prev_handle);
      	    update_preview_blit();
      	    set_clip(TRUE,&pwork);
      	    vr_recfl(shandle,pxy);
      	    clear_window(prev_handle,2,1);
      	    init_rulers();

      	    set_clip(TRUE,&dpwork);
      	    gsx_mon();
  	    world_setup();			/* Redo mu conversion table */
            IF_close();
	    IF_open(0);
	    recalc_alt_text();

	    force_preview();
            slider_chk();
        }
	else
	   alert_cntre(ALERT33);	/* not enough memory ...*/
   }
   /* cancel? axdpi[] and aydpi[] will stil be the same...    */
}




/**************************************************************************/
/* Function: set_parameters();						  */
/* Description: Save current parameters as default for startup.		  */
/**************************************************************************/
save_parameters()
{
  register int i;
  int grid_unit;
  int length;

     if(alert_cntre(ALERT34)==1)	  	   /* hit ok, so save...  */
     {
	pstorage[0]  = 	 view_size;		   /* Preview Size	  */
	pstorage[1]  = 	 ruler_flag;		   /* Ruler Display	  */
	pstorage[2]  = 	 unit_type;		   /* Ruler Units	  */

	for(i=GRBUT1;i<=GRBUT4;i++)
	{
	   if(gridspace[i].ob_state == SELECTED)
					grid_unit = i;
	}
	pstorage[3]  = 	grid_unit;		   /* Grid Spacing...     */ 

	pstorage[4]  = 	 show_grids;		   /* Grid Display	  */
	pstorage[5]  = 	 snap_to_grids;		   /* Snap To Grid...     */

        pstorage[6]  =   get_int(ad_dpi,HDPIDAT);  /* xdpi for moniterm   */
	pstorage[7]  =   get_int(ad_dpi,VDPIDAT);  /* ydpi for moniterm   */

	pstorage[8]  = 	 gltxtattr.font;	   /* Global Font	  */
	pstorage[9]  = 	 gltxtattr.ptsz;	   /* Global Point Size   */
	pstorage[10] = 	 gltxtattr.ssiz;	   /* Global Set Size     */
	pstorage[11] = 	 (int)gltxtattr.lnsp;	   /* Global Line Space   */
	pstorage[12] = 	 gltxtattr.kernmd;	   /* Global Kerning...   */
	pstorage[13] = 	 gltxtattr.rvomd;	   /* Reverse Video	  */
	pstorage[14] = 	 gltxtattr.jstmd;	   /* Justification	  */
	pstorage[15] = 	 pagetype;		   /* Paper Type	  */
	pstorage[16] = 	 gltxtattr.scoff;	   /* Scan Offset	  */
	pstorage[17] = 	 gl_fstyle;		   /* Fill Style	  */
	pstorage[18] = 	 gl_findex;		   /* Fill Index	  */
	pstorage[19] = 	 gl_lstyle;		   /* Line Style	  */
	pstorage[20] = 	 gl_lwidth;		   /* Line Width	  */
	pstorage[21] = 	 gl_repel;		   /* Repel Mode	  */
	pstorage[22] = 	 gl_repbounds;		   /* Repel Bounds	  */
	pstorage[23] = 	 gl_repoffset;		   /* Boundary Offset     */
	pstorage[24] = 	 pnum.pfnum;		   /* Page Number Font    */
	pstorage[25] = 	 pnum.pptsize;		   /* Page Num Pt Size    */
	pstorage[26] = 	 pnum.pstsize;		   /* Page Num Set Size   */
	pstorage[27] = 	 pnum.display;		   /* Page Num Display    */
	pstorage[28] = 	 pnum.ljust;		   /* Page Num Left Just  */
	pstorage[29] = 	 pnum.rjust;		   /* Page Num Right Just */
	pstorage[30] = 	 pnum.usage;		   /* Page Num Usage	  */
	pstorage[31] = 	 pnum.vpos;		   /* Page Num Vert. Pos  */
	pstorage[32] = 	 (int)pnum.distance;	   /* Page Num Distance   */
	pstorage[33] = 	 pnum.fpage;		   /* Page Num From...    */
	pstorage[34] = 	 pnum.tpage;		   /* Page Num To...	  */
	pstorage[35] = 	 disp_type;		   /* Template Usage...   */
	pstorage[36] = 	 disp_pos;		   /* Template Location   */
	pstorage[37] =   gltxtattr.mcomp;	   /* Manual Char. Comp.  */
	pstorage[38] =   gltxtattr.acomp;          /* Auto. Char Comp.    */
	pstorage[39] =   gltxtattr.hypmd;	   /* Hyphenation Mode    */
	pstorage[40] =   gltxtattr.nsuchyp;	   /* No. Of Succ. Hyphens*/
	pstorage[41] =   gltxtattr.nbefhyp;	   /* No. of chars Before */
	pstorage[42] =   gltxtattr.nafthyp;	   /* No. of chars After  */
	pstorage[43] =   gltxtattr.ltsmd;	   /* Letterspacing mode  */
	pstorage[44] =   gltxtattr.plts;	   /* Pos. Letter Spacing */
	pstorage[45] =   gltxtattr.nlts;	   /* Neg. Letter Spacing */
	pstorage[46] =   gltxtattr.minsp;	   /* Min. Space in RU	  */
	pstorage[47] =   gltxtattr.prfsp;	   /* Pref. Space In RU   */
	pstorage[48] =   gltxtattr.maxsp;	   /* Max Space in RU     */
	pstorage[49] =   gltxtattr.psimd;	   /* Pseudo Italic Mode  */

	length = strlen(pnum.text);
	pstorage[50] = 	 length;		   /* Number of Chars     */
	strcpy(pnumtext,pnum.text);

	write_defaults();
     }
}




restore_defaults()
{
   register int i;
   int length;
   int grid_unit;
   register int *hval;
   register int *vval;
   register int **str;

   if(read_defaults())
   {
	view_size  = pstorage[0];		   /* Preview Size	  */
	ruler_flag = pstorage[1];		   /* Ruler Display	  */
	unit_type  = pstorage[2];		   /* Ruler Units	  */

	grid_unit    = pstorage[3];		   /* Grid Spacing...     */ 

        switch(unit_type)
	{
 	   case 0:   str = grid_inch;
		     hval = hinch_mus;
		     vval = vinch_mus; 
 		     break;
           case 1:   str = grid_picas;
		     hval = hpica_mus;
		     vval = vpica_mus;
		     break;
           case 2:   str = grid_cents;
		     hval = hcent_mus;
		     vval = vcent_mus;
		     break;
           case 3:   str = grid_cicero;
		     hval = hcicero_mus;
		     vval = vcicero_mus;
		     break;
	}
	for(i=GRBUT1;i<=GRBUT4;i++)
	{
	   gridspace[i].ob_spec=str[i-GRBUT1];
	   gridspace[i].ob_state=NORMAL;
	}
	gridspace[grid_unit].ob_state = SELECTED;

	hgridspace = hval[grid_unit - GRBUT1];
	vgridspace = vval[grid_unit - GRBUT1];


	show_grids    = pstorage[4];		   /* Grid Display	  */
	snap_to_grids = pstorage[5];		   /* Snap To Grid...     */

        set_int(ad_dpi,HDPIDAT,pstorage[6]);	   /* set dialog xdpi and */
        set_int(ad_dpi,VDPIDAT,pstorage[7]);	   /* ydpi for moniterm   */

        init_tattr();				   /* Init Text Attributes*/


	pagetype         = pstorage[15];	   /* Paper Type	  */
	gl_fstyle        = pstorage[17];	   /* Fill Style	  */

	gl_findex 	 = pstorage[18];	   /* Fill Index	  */
	gl_lstyle 	 = pstorage[19];	   /* Line Style	  */
	gl_lwidth 	 = pstorage[20];	   /* Line Width	  */

	gl_repel	 = pstorage[21];	   /* Repel Mode	  */
	gl_repbounds 	 = pstorage[22];	   /* Repel Bounds	  */
	gl_repoffset 	 = pstorage[23];	   /* Boundary Offset     */
	pnum.pfnum 	 = pstorage[24];	   /* Page Number Font    */

	pnum.pptsize     = pstorage[25];	   /* Page Num Pt Size    */
	pnum.pstsize     = pstorage[26];	   /* Page Num Set Size   */
	pnum.display     = pstorage[27];	   /* Page Num Display    */
	pnum.ljust 	 = pstorage[28];	   /* Page Num Left Just  */
	pnum.rjust       = pstorage[29];	   /* Page Num Right Just */

	pnum.usage       = pstorage[30];	   /* Page Num Usage	  */
	pnum.vpos        = pstorage[31];	   /* Page Num Vert. Pos  */
	pnum.distance    = (long)pstorage[32];	   /* Page Num Distance   */

	pnum.fpage       = pstorage[33];	   /* Page Num From...    */
	pnum.tpage       = pstorage[34];	   /* Page Num To...	  */

	disp_type        = pstorage[35];	   /* Template Usage...   */
	disp_pos         = pstorage[36];	   /* Template Location   */

	for(i=SETTBOTH;i<=SETTRITE;i++)
		ad_settmpl[i].ob_state = NORMAL;
	ad_settmpl[disp_type+SETTBOTH].ob_state = SELECTED;

	
        ad_settmpl[SETTFRNT].ob_state = NORMAL;
        ad_settmpl[SETTBACK].ob_state = NORMAL;
	
	if(disp_pos)
	     ad_settmpl[SETTBACK].ob_state = SELECTED;
	else
	     ad_settmpl[SETTFRNT].ob_state = SELECTED;


	length 	         = pstorage[50];	   /* Number of Chars     */
	strcpy(pnum.text,pnumtext);
   }
}




set_text_defaults()
{
	int *fntptr;

        pstorage[9]  = 24*8;
	fntptr = ftlib;
	pstorage[8]  = *fntptr;
	pstorage[10] = 24*8;
	pstorage[11] = pttomu(26);
	pstorage[37] = 0;		/* Manual char. Compensation	  */
	pstorage[38] = 0;		/* Auto. chr. Compensation        */
	pstorage[12] = 0;		/* Kerning			  */
	pstorage[39] = 1;		/* Hyphenation			  */
	pstorage[40] = 2;		/* No. of Successive Hyphens	  */
	pstorage[41] = 2;		/* No. of chars Before Hyphen	  */
	pstorage[42] = 3;		/* No. of chars After Hyphen	  */
	pstorage[43] = 1;		/* Letterspacing Mode flag        */
	pstorage[44] = 3;		/* Positive Letter Space In RU    */
	pstorage[45] = 1;		/* Negative Letter Space In RU	  */
	pstorage[46] = 12;		/* Minimum Space In RU		  */
	pstorage[47] = 8;		/* Preferred Space in RU	  */
	pstorage[48] = 30;		/* Maximum Space In RU		  */
	pstorage[13] = 0;		/* Reverse Video Mode		  */
	pstorage[49] = 0;		/* Pseudo Italic Mode Flag	  */
	pstorage[14] = 0;		/* Justification Mode		  */
	pstorage[16] = 0;		/* Scan Line Offset		  */
}	




change_dpi()
{
   int xin,yin;
   long totalm;
   int dxres,dyres;
   long sbytes,pbytes;

    totalm = Malloc(-1L);
    totalm += scan_bytes + prev_bytes;

    xin = pstorage[6];
    yin = pstorage[7];

    dxres = xin * 8;   /* max page sizes in inches */
    dyres = yin * 14;
    sbytes = ((((long)dxres) * (long)dyres)/8L);
    pbytes = sbytes * 4L;	                 /* for 200% size */

    if((sbytes + pbytes) < totalm)
    {
	    Mfree(scanesc);	/* free both buffers...*/
	    Mfree(pagesc);
	    scan_bytes = sbytes;
	    pagebytes = prev_bytes = pbytes;
	    scanptr = scanesc = (unsigned long)Malloc(scan_bytes);
	    page_ptr = pagesc = (unsigned long)Malloc(prev_bytes);

	    axdpi[0] = axdpi[1] = axdpi[2] = xin;
	    aydpi[0] = aydpi[1] = aydpi[2] = yin;

 	    half_xdpi[0] = half_xdpi[1] = half_xdpi[2] = xin/2;
	    half_ydpi[0] = half_ydpi[1] = half_ydpi[2] = yin/2;

	    xdpi[0] = xin;
	    ydpi[0] = yin;

/*
	    scan_xres = axdpi[0] * 8;
	    scan_yres = aydpi[0] * 14;
*/
	    mutomem(hpage_size,vpage_size,&scan_xres,&scan_yres);
            page_MFDB.fd_addr = page_ptr;         /* Preview address MFDB */

	    mutopage(hpage_size,vpage_size,&mxres,&myres,1);

      	    page_area.g_x = page_area.g_y = 0L;

	    gsx_moff();
      	    vsf_interior(shandle,0);			/* Set to Solid   */

      	    GDvq_extnd(mhandle,0,intout,mxres,myres,&page_ptr);	    

    }
    else
	alert_cntre(ALERT33);	/* not enough memory */

}


/* kludge for startup.c - adjustdpi() */
set_ad_dpi()
{
   set_int(ad_dpi,HDPIDAT,95);
   set_int(ad_dpi,VDPIDAT,95);
}





/**************************************************************************/
/*									  */
/**************************************************************************/
do_about()
{
    int x,y,w,h;
    int sx,sy,sw,sh;
    int button;

    form_center(ad_deskset,&x,&y,&w,&h);
    form_center(ad_credits,&sx,&sy,&sw,&sh);

    form_dial(0,0,0,36,36,x,y,w,h);
    objc_draw(ad_deskset,0,MAX_DEPTH,x,y,w,h);

    do
    {
      button = form_do(ad_deskset,0);
      button &= 0x7fff;

      if(button == DTOUCH)
      {
        objc_draw(ad_credits,0,MAX_DEPTH,sx,sy,sw,sh);	
	button = form_do(ad_credits,0);
	button = OK;
      }

    }while(button != OK);
    form_dial(3,0,0,3,36,x,y,w,h);

    force_blit_redraw(0);	/* normal redraw with blits...*/
           
}



/**************************************************************************/
/* Function: do_info()						  	  */
/* Description: Handle information dialog box				  */
/**************************************************************************/
do_info()
{
    int x,y,w,h;
    int button;
    register int i;
    int dtxtflag;
    int dgflag;
    register OBJECT *slider;
    register OBJECT *sldbox;
    int    value;
    int x_box,y_box;
    int mov_dir;
    int mx,my;
    int dummy;
    int numpages;
    int pagenum;
    int tmppage;
    PAGE *xcurpage;
    PAGE *xpagehd;
    register REGION *rptr;
    int dwhat;
    int dtype;

    active_prim = FALSE;
    numpages = 0;
    tmppage = curr_page;
    xpagehd = pagehd;
    xcurpage = curpage;
    if(get_fpage(&pagenum))
    {
       numpages++;
       while(get_npage(&pagenum))       
		        numpages++;
    }
    curr_page = tmppage;
    pagehd = xpagehd;
    curpage = xcurpage;
    set_int(ad_info,DOCPAGE,numpages);
    tdinfo_ptr = gdinfo_ptr = ttdinfo_ptr = tgdinfo_ptr = cgdinfo_ptr = 0L;

    for(i=DI1;i<=DI10;i++)
   	set_tedit(ad_info,i,tmpflname);

    if(region_ptr)		/* if a region is selected already     */
    {			        /* So show file only related to region */
       rptr = region_ptr;
       ctdinfo_ptr = 0L;		/* clipboard text, always null */
       cgdinfo_ptr = 0L;		/* clipboard graphics null     */

       if(tmplate_flag)			/* Is it a base page region?   */
       {				/* yes...template region       */
	  dwhat = DITMPLTE;
	  tdinfo_ptr = 0L;		/* document ptrs are null      */
          gdinfo_ptr = 0L;
	  if(rptr->type)		/* graphic region?	       */
	  {				/* Yes...		       */
		ttdinfo_ptr = 0L; 	/* Zero out text ptr           */
		tgdinfo_ptr = get_grfname(rptr);
		dtype = DIGRAPH;
	  }
	  else				/* No..It's a text region      */
	  {
		tgdinfo_ptr = 0L; 	/* Zero out graphic ptr        */
		ttdinfo_ptr = 0L;
		
		if(rptr->artptr)
	 	{
		  ttdinfo_ptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
		  strcpy(ttdinfo_ptr->txtptr,rptr->artptr->filename);
	          ttdinfo_ptr->next = 0L;
		  ttdinfo_ptr->prev = 0L;
		}
	        dtype = DITEXT;
	  }
       }
       else				/* document region             */
       {
	  dwhat = DIDOC;
	  ttdinfo_ptr = 0L;		/* template ptrs are null      */
	  tgdinfo_ptr = 0L;
	  if(rptr->type)		/* graphic region ?	       */
	  {				/* Yes...		       */
		tdinfo_ptr = 0L;	/* Zero out the text ptr       */
		gdinfo_ptr = get_grfname(rptr);
		dtype = DIGRAPH;
	  }
	  else				/* No...It's a text region     */
	  {
		gdinfo_ptr = 0L;	/* Zero out the graphic ptr    */
		tdinfo_ptr = 0L;
		if(rptr->artptr)
		{
		  tdinfo_ptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
		  strcpy(tdinfo_ptr->txtptr,rptr->artptr->filename);
	          tdinfo_ptr->next = 0L;
		  tdinfo_ptr->prev = 0L;
		}
		dtype = DITEXT;
	  }
       }
       region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
    }
    else			       /*show ALL text and graphic files*/
    {
       dtxtflag = set_dtext();		/* Document Text	       */
       dgflag = set_dgraphics();	/* Document Graphics	       */
       ctdinfo_ptr = 0L;		/* clipboard text, always null */
       set_dtmplate();			/* Template Graphics and Text  */
       set_dclipboard();		/* Clipboard Graphics	       */
       dwhat = DIDOC;
       dtype = DITEXT;
    }


    for(i=DIDOC;i<=DICLIP;i++)
		ad_info[i].ob_state = NORMAL;
    ad_info[info_what + dwhat].ob_state = SELECTED;

    ad_info[DITEXT].ob_state = NORMAL;
    ad_info[DIGRAPH].ob_state = NORMAL;
    ad_info[info_type + dtype].ob_state = SELECTED;


    form_center(ad_info,&x,&y,&w,&h);
    form_dial(0,0,0,36,36,x,y,w,h);
    form_dial(1,0,0,36,36,x,y,w,h);


    maincount = dtcount = get_dinfo_items(tdinfo_ptr);
    dgcount = get_dinfo_items(gdinfo_ptr);
    ttcount = get_dinfo_items(ttdinfo_ptr);
    tgcount = get_dinfo_items(tgdinfo_ptr);
    cgcount = get_dinfo_items(cgdinfo_ptr);
    ctcount = 0;    



    objc_draw(ad_info,ROOT,MAX_DEPTH,x,y,w,h);
    type_info(dtype,dwhat);
    objc_draw(ad_info,DBOX,1,x,y,w,h);   

    slider = &ad_info[DISLIDE];
    sldbox = &ad_info[DIVERT];
    curfirst_art = 0;

    do
    {
       button = form_do(ad_info,0);
       button &= 0x7fff;
 
       switch(button)
       {
	   case DIUP:	if(!slider->ob_y)
				     break;
			hndl_dlist(curfirst_art,-1);
			break;

	   case DIDOWN:	if(slider->ob_y >= sldbox->ob_height - slider->ob_height)
							break;	
			hndl_dlist(curfirst_art,1);
			break;


	   case DISLIDE:value = graf_slidebox(ad_info,DIVERT,DISLIDE,1);
			value = scaler(value,maincount-INFOMAX,1000);
			hndl_dlist(value,0);
			break;

	   case DIVERT: graf_mkstate(&mx,&my,&dummy,&dummy);
			objc_offset(ad_info,DIVERT,&x_box,&y_box);
			if(my > y_box + slider->ob_y)
					mov_dir = INFOMAX;
			else
			   mov_dir = -INFOMAX;
			hndl_dlist(curfirst_art,mov_dir);
			break;

	   case DIDOC:
	   case DITMPLTE:
	   case DICLIP:   type_info(info_type+DITEXT,button);
			  info_what = button - DIDOC;
			  objc_draw(ad_info,DBOX,1,x,y,w,h);   
			  break;


	   case DITEXT:
	   case DIGRAPH:  type_info(button,info_what+DIDOC);
			  info_type = button - DITEXT;
			  objc_draw(ad_info,DBOX,1,x,y,w,h);   
			  break;
	   default:
		   break;
       }

    }while(button != DIEXIT);
    form_dial(2,0,0,36,36,x,y,w,h);
    form_dial(3,0,0,3,36,x,y,w,h);
    info_what = info_type = 0;	/* set to first buttons */
    ad_info[button].ob_state = NORMAL;

    cleanup();
    force_blit_redraw(0);
}




/**************************************************************************/
/**************************************************************************/
set_dtext()
{
    register ARTICLE *darthd;
    register DINFO   *tptr;
    DINFO   *newptr;

    darthd = ((tmplate_flag)?(tarthd):(arthd));

    if(darthd)
    {
       tptr = tdinfo_ptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));        
       strcpy(tptr->txtptr,darthd->filename);
       tptr->next = 0L;
       tptr->prev = 0L;

       while(darthd->nextart)
       {
	     darthd = darthd->nextart;
	     newptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
	     tptr->next = newptr;
	     tptr->next->prev = tptr;
	     tptr = tptr->next;
	     tptr->next = 0L;
	     strcpy(tptr->txtptr,darthd->filename);
       }
       return(1);	/* at least 1 or more text articles*/
    }
    return(0);	/* no text articles */
}




/**************************************************************************/
/**************************************************************************/
set_dgraphics()
{
    PAGE    *dpagehd;
    int     tmppage;
    PAGE    *tppage;

    dpagehd = ((tmplate_flag)?(tpagehd):(pagehd));

    tppage = pagehd;
    pagehd = dpagehd;
    tmppage = curr_page;

    gdinfo_ptr = set_info_graphics();

    curr_page = tmppage;
    region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
    curpage = pagehd = tppage;
}



/**************************************************************************/
/**************************************************************************/
cleanup()
{
    if(tdinfo_ptr)	/* DOCS TEXT MALLOC? */
	cleanse(tdinfo_ptr);

    if(gdinfo_ptr)	/* DOCS GRAPHIC MALLOC?*/
	cleanse(gdinfo_ptr);

    if(ttdinfo_ptr)	/* template TEXT malloc?*/
	cleanse(ttdinfo_ptr);

    if(tgdinfo_ptr)	/* template GRAPHIC malloc?*/
	cleanse(tgdinfo_ptr);    

    if(cgdinfo_ptr)	/* clipboard Graphic malloc*/
	cleanse(cgdinfo_ptr);
    tdinfo_ptr = gdinfo_ptr = ttdinfo_ptr = tgdinfo_ptr = cgdinfo_ptr = 0L;
}




/**************************************************************************/
/**************************************************************************/
cleanse(tptr)
register DINFO *tptr;
{
   register DINFO *pptr;

   while(tptr->next)
	tptr = tptr->next;
   pptr = tptr->prev;
   free(tptr);
   while(pptr)
   {
     tptr = pptr;
     pptr = tptr->prev;
     free(tptr);
   }
}



/**************************************************************************/
/**************************************************************************/
draw_text(tptr)
register DINFO *tptr;
{
  register int i;

  i = DI1;
  while((i<=DI10) && tptr)
  {
     set_tedit(ad_info,i,tptr->txtptr);
     tptr = tptr->next;
     i++;
  }
}



/**************************************************************************/
/**************************************************************************/
type_info(type,what)
int type;
int what;
{
   register DINFO *tptr;
   register int i;
   register int tot_names;
  
   for(i=DI1;i<=DI10;i++)
   	set_tedit(ad_info,i,tmpflname);
   
   switch(what)
   {
 	case DIDOC:     tptr=((type==DITEXT)?(tdinfo_ptr):(gdinfo_ptr));
			tot_names=((type==DITEXT)?(dtcount):(dgcount));
			break;

	case DITMPLTE:  tptr=((type==DITEXT)?(ttdinfo_ptr):(tgdinfo_ptr));
			tot_names=((type==DITEXT)?(ttcount):(tgcount));
			break;

	case DICLIP:	tptr=((type==DITEXT)?(ctdinfo_ptr):(cgdinfo_ptr));
			tot_names=((type==DITEXT)?(ctcount):(cgcount));
			break;
   }
   maincount = tot_names;
   curdinfo  = tptr;
   curfirst_art = 0;
   init_slider(ad_info,tot_names,DISLIDE,DIVERT,&hslider,INFOMAX);
   do_slider(ad_info,DISLIDE,DIVERT,hslider,tot_names,0,INFOMAX);
   objc_draw(ad_info,DIVERT,1,aworkx,aworky,aworkw,aworkh);     /* draw it */
   draw_text(tptr);
}




/**************************************************************************/
/* Function: Setup DINFO structure for tmplate	 			  */
/**************************************************************************/
set_dtmplate()
{
   register DINFO *tptr;

   DINFO *mptr;
   DINFO *newptr;
   DINFO *tempptr;

   PAGE *bpagehd;
   int  bcurr_page;
   PAGE *bcurpage;

   
   ttdinfo_ptr = 0L;
   tgdinfo_ptr = 0L;
   xarthd = 0L;
   xarthd = ltarthd;

   if(xarthd)				/* left template text */
   {
      tptr = ttdinfo_ptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
      strcpy(tptr->txtptr,xarthd->filename);
      tptr->next = 0L;
      tptr->prev = 0L;
      
      while(xarthd->nextart)
      {
	xarthd = xarthd->nextart;
	newptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
	tptr->next = newptr;
	tptr->next->prev = tptr;
	tptr = tptr->next;
	tptr->next = 0L;
	strcpy(tptr->txtptr,xarthd->filename);
      }
   }

   xarthd = 0L;
   xarthd = rtarthd;
   if(xarthd)				/* right template text */
   {					
      newptr = mptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
      if(!ttdinfo_ptr)
      {
	   tptr = ttdinfo_ptr = mptr;
           strcpy(tptr->txtptr,xarthd->filename);
           tptr->next = 0L;
           tptr->prev = 0L;
      }
      else
      {
	tptr->next = newptr;
	tptr->next->prev = tptr;
	tptr = tptr->next;
	tptr->next = 0L;
	strcpy(tptr->txtptr,xarthd->filename);
      }

      while(xarthd->nextart)
      {
	xarthd = xarthd->nextart;
	newptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
	tptr->next = newptr;
	tptr->next->prev = tptr;
	tptr = tptr->next;
	tptr->next = 0L;
	strcpy(tptr->txtptr,xarthd->filename);

      }      
   }

   bpagehd = pagehd;
   bcurr_page = curr_page;
   bcurpage = curpage;

   pagehd = left_tmplate;
   tgdinfo_ptr = set_info_graphics();   
   
   
   pagehd = right_tmplate;
   tempptr = set_info_graphics();

   if(tgdinfo_ptr)
   {
      if(tempptr)
      {
        tptr = tgdinfo_ptr;
        while(tptr->next)
	   tptr = tptr->next;
	tptr->next = tempptr;
      }
   }
   else
	tgdinfo_ptr = tempptr;
   
   curr_page = bcurr_page;
   pagehd = bpagehd;
   curpage = bcurpage;
   region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;
}




/**************************************************************************/
/**************************************************************************/
DINFO *set_info_graphics()
{
    int     pagenum;
    register unsigned long    rptr;
    int     graf_flag;
    int     murect[4];    
    register int     op;		/* opcode */
    int     cnt;	/* count  */
    int     mode;	/* wmode  */
    int     flag;
    register DINFO   *tptr;
    DINFO   *newptr;
    DINFO   *xptr;

    flag = FALSE;
    xptr = 0L;
    if(get_fpage(&pagenum))
    {
     do
     {
	rptr = get_fregion(pagenum,&murect[0],&murect[1],
			   &murect[2],&murect[3],&graf_flag);
        while(rptr)
	{
           if(graf_flag)
	   {
	     op = get_fprimitive(rptr,&cnt,&mode);
	     while(op != -1)
	     {
		if(op == 2)	/* only want filenames of graphics*/
		{
		  if(!flag)	/* not even 1 malloc'ed yet */
		  {
		    tptr=xptr=(unsigned long)get_lmem((long)sizeof(struct dinfo));
		    strcpy(tptr->txtptr,&ptsarray[5]);
		    tptr->next = 0L;
		    tptr->prev = 0L;
		    flag = TRUE;
		  }
		  else		/* add to linked list       */
		  {
	            newptr=(unsigned long)get_lmem((long)sizeof(struct dinfo));		    
	     	    tptr->next = newptr;
	     	    tptr->next->prev = tptr;
	     	    tptr = tptr->next;
	     	    tptr->next = 0L;
		    strcpy(tptr->txtptr,&ptsarray[5]);
		  }  

		}
		op = get_nprimitive(&cnt,&mode);
	     }
	   }
	   rptr = get_nregion(&murect[0],&murect[1],
			      &murect[2],&murect[3],&graf_flag);
	}
	
     }while(get_npage(&pagenum));
    }
    return(xptr);

}




/**************************************************************************/
/**************************************************************************/
set_dclipboard()
{
   PAGE *bpagehd;
   int  bcurr_page;
   PAGE *bcurpage;

   bpagehd = pagehd;
   bcurr_page = curr_page;
   bcurpage = curpage;

   pagehd = clippage;
   if(pagehd)
      cgdinfo_ptr = set_info_graphics();   
   
   curr_page = bcurr_page;
   pagehd = bpagehd;
   curpage = bcurpage;
   region_ptr = gl_region_ptr = gl_grregion_ptr = 0L;

}


get_dinfo_items(tptr)
register DINFO *tptr;
{
    register int i;

    i = 0;
    while(tptr)
    {
	i++;
	tptr = tptr->next;
    }
    return(i);
}






hndl_dlist(begname,movdir)
int begname;
int movdir;
{
   gsx_moff();
   curfirst_art = dscroll(maincount,begname,movdir);
   do_slider(ad_info,DISLIDE,DIVERT,hslider,maincount,curfirst_art,INFOMAX);
   gsx_mon();
}





dscroll(total_names,startname,amount)
int total_names;
int startname;
int amount;
{
  register int i,j;
  int textobj,x,y;
  long scrmfdb;

  scrmfdb = 0L;

  i = startname + amount;
  j = total_names - INFOMAX;

  if(i<0 || j<0)
	i = 0;
  if(j<0)
	j = 0;
  if(i>j)
	i = j;

  set_info_ptrs(i);

  if(amount != -1 && amount != 1)
  {				/* do page scrolling */
	objc_draw(ad_info,DBOX,1,aworkx,aworky,aworkw,aworkh);
	return(i);
  }

  if(i==startname)		/* reject unnecessary single scroll */
	return(i);		/* else we do a single line scroll  */

  objc_offset(ad_info,DI1,&x,&y);

   ptsin[0] = x;			/* init clipping x,y,w,h */
   ptsin[1] = y;
   ptsin[2] = x+ad_info[DI1].ob_width;
   ptsin[3] = y+gl_hchar*INFOMAX-1;

   ptsin[4] = x;			/* init blit destination */
   ptsin[5] = y;
   ptsin[6] = ptsin[2];
   ptsin[7] = ptsin[3];

   vs_clip(shandle,1,ptsin);

   if(amount < 0)
   {				/* - if going up -Up Arrow!!!*/
      ptsin[1] -= gl_hchar;	/* src y */
      ptsin[3] += gl_hchar;	/* src h*/
      ptsin[7] += gl_hchar;	
      textobj = ad_info[DBOX].ob_head;
      
   }
   else				/* going down -Down Arrow!! */
   {
      ptsin[3] += gl_hchar;
      ptsin[5] -= gl_hchar;
      ptsin[7] -= gl_hchar;
      textobj = ad_info[DBOX].ob_tail;
   }

   gsx_moff();
   vro_cpyfm(shandle,3,ptsin,&scrmfdb,&scrmfdb);
   objc_draw(ad_info,textobj,0,aworkx,aworky,aworkw,aworkh);
   gsx_mon();
   return(i);
}





set_info_ptrs(pos)
register int pos;
{
   register int i;
   register DINFO *tptr;

   for(i=DI1;i<=DI10;i++)
	set_tedit(ad_info,i,tmpflname);

   tptr = curdinfo;

   i = 0;		/* dangerous, eh?*/
   while((i!=pos) && tptr)
   {
	i++;
	tptr = tptr->next;
   }

   if(tptr)
      draw_text(tptr);
}






clr_attr_flag()
{
   register int i;

   for(i=0;i<=22;i++)
	    attr_flag[i] = 0;
}




copy_attr(attr)
register struct txtattr *attr;
{
   register int i;

   for(i=0;i<= 22;i++)
   {
	if(attr_flag[i])
	{
	    switch(i)
	    {
		case 0: attr->llen   = gltxtattr.llen;
			break;

		case 1: attr->depth  = gltxtattr.depth;
			break;

		case 2: attr->lnsp   = gltxtattr.lnsp;
			break;

		case 3: attr->ptsz   = gltxtattr.ptsz;
			break;

		case 4: attr->ssiz   = gltxtattr.ssiz;
			break;

		case 5: attr->font   = gltxtattr.font;
			break;

		case 6: attr->mcomp  = gltxtattr.mcomp;
			break;

		case 7: attr->acomp  = gltxtattr.acomp;
			break;

		case 8: attr->kernmd = gltxtattr.kernmd;
			break;

		case 9: attr->hypmd  = gltxtattr.hypmd;
			break;

		case 10: attr->nsuchyp  = gltxtattr.nsuchyp;
			break;

		case 11: attr->nbefhyp  = gltxtattr.nbefhyp;
			break;

		case 12: attr->nafthyp  = gltxtattr.nafthyp;
			break;

		case 13: attr->ltsmd  = gltxtattr.ltsmd;
			break;

		case 14: attr->plts   = gltxtattr.plts;
			break;

		case 15: attr->nlts   = gltxtattr.nlts;
			break;

		case 16: attr->minsp  = gltxtattr.minsp;
			break;

		case 17: attr->prfsp  = gltxtattr.prfsp;
			break;

		case 18: attr->maxsp  = gltxtattr.maxsp;
			break;

		case 19: attr->rvomd  = gltxtattr.rvomd;
			break;

		case 20: attr->psimd  = gltxtattr.psimd;
			break;

		case 21: attr->jstmd  = gltxtattr.jstmd;
			break;

		case 22: attr->scoff  = gltxtattr.scoff;
			break;
	    }
	}
   }
}



/*************************************************************/
/* Get filename of graphics for do_info...		     */
/* specifically, only for when a region is selected...       */
/*************************************************************/
DINFO *get_grfname(rptr)
REGION *rptr;
{
    int cnt,mode;
    register int op;
    int flag;
    register DINFO *tptr;
    DINFO *xptr;
    DINFO *newptr;

    flag = FALSE;
    xptr = 0L;
    op = get_fprimitive(rptr,&cnt,&mode);
    while(op != -1)
    {
       if(op == 2)	/* Only want filenames of graphics*/
       {
          if(!flag)	/* not even 1 malloc'ed yet...    */
	  {
	      tptr = xptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
              strcpy(tptr->txtptr,&ptsarray[5]);
	      tptr->next = 0L;
              tptr->prev = 0L;
	      flag = TRUE;
          }
          else
          {
	      newptr = (unsigned long)get_lmem((long)sizeof(struct dinfo));
	      tptr->next = newptr;
              tptr->next->prev = tptr;
              tptr = tptr->next;
              tptr->next = 0L;
              strcpy(tptr->txtptr,&ptsarray[5]);
          }
       }
       op = get_nprimitive(&cnt,&mode);
    }
    
    return(xptr);
}
