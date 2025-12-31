/********************************************************************
 *
 * inout.c, manages all input in GEM dialogs 
 *
 *******************************************************************/
 
 /*   april 88	Åbernahme der quelle von tony przygienda
  *   1. 5.	unterschiedliche x- und y-auflîsungen
  *  12. 5.	read_.., write_drawmode() darstellungsparameter
  *  29. 5.	check_resolution() in read_resolution()
  */
  
#include "..\carpet.h"
#include <stdio.h>
#include <portab.h>

#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif
#if COMPILER==TURBOC
	#include "..\inout.h"
	#include <aes.h>
	#include <vdi.h>
	#include <stdlib.h>  /* fÅr atof etc. */
	#include <string.h>
	#include <tos.h>
#endif

/* import rsrc var's from INITEXIT.c */
extern int vinputf,vxstart,vxend,vystart,vconsta,vconstb,vconstc;
extern int vinputfun,vxstart,vxend,vystart;
extern int vrotation,vzrotate,vxrotate;
extern int vview,vplaney,vlookx,vlooky,vlookz;
extern int vlight,vlightx,vlighty,vlightz,vrahmein;
extern int vresoluti,vxlinien,vylinien;
extern int vxraster,vyraster,vxyraster;
extern int vwire,vhidden,vshadow;
extern int vcentral,vparallel;
extern int vdrawmode;

extern int drawmode;
extern boolean central,xraster,yraster;

extern int colours; /* from CARPET module, if >2 then colour rsc to use */
#if COMPILER==TURBOC
	#include "..\initexit.h"
#endif

/* from CARPET module */
extern  void eingabe_error(); 
#if COMPILER==TURBOC
	#include "..\xcarpet.h";
#endif


/* from TREE module */
extern  double variables[]; 
#if COMPILER==TURBOC
	#include "..\tree.h"
#endif


/* from CALC module */
extern  boolean shadowed,inferior,counted2d; 
#if COMPILER==TURBOC
	#include "..\calc.h"
#endif


#if COMPILER==TURBOC
	#include "..\memory.h"
#endif


#if COMPILER==TURBOC
	#include "..\gemhelp.h"
#endif


#if COMPILER==MEGAMAX
	extern  double atof();  /* ascii to double precision */
	extern  int    atoi();
#endif


#define rscWorth(a,b)   (colours>2 ? (b):(a)) /* worth depending on rsc */

char    func_string[200]; /* enthÑlt string der Funktionsgleichung */
double  xstart,xend,ystart,yend;
double  consta,constb,constc;  /* Werte der Konstanten */

double  xangle,zangle;

double  look_x,look_y,look_z,plane_y;
int     light_x,light_y,light_z; /* der Beleuchtung */

int     xlines,ylines; 	/* Auflîsung, Anzahl Intervalle */
int     xres, yres;	/*  dito,     Anzahl Linien	*/

static OBJECT *tree_address;	/* wird Åberall mal gebraucht	*/

#define TREE_ADDR(tree)		rsrc_gaddr (R_TREE,tree,&tree_address)
#define SELECT(object)		do_obj  (tree_address,object,SELECTED)
#define DESELECT(object)	undo_obj(tree_address,object,SELECTED)
#define IS_SELECTED(object)	ask_obj (tree_address,object,SELECTED)

#if COMPILER==MEGAMAX
	overlay "calc"
#endif

/* this part of program should be modified 
double strtof(a);
register double a;
*/

void norm_double(x)
double *x;
/* brings the variable into well defined ranges */
{
if (*x>1.e4)
   {
   eingabe_error();
   *x=1.e3;
   }   
if ((*x)+1.e4<0.)
   {
   eingabe_error();
   *x=-1.e3;
   }   
}   
 
void read_forminp()
/* reads the fields of dialog vinputfun into var (* function & ranges *) */
{
char     *adress;
OBJECT   *tree_adress;
int      ret; /* dummy */
double   dummy;

rsrc_gaddr(R_TREE,vinputfun,&tree_adress);

adress=((TEDINFO *) tree_adress[vxstart].ob_spec)->te_ptext;
ret=sscanf(adress,"%10lf",&xstart);
#if !SCANFERROR
if (!ret)
   {
   eingabe_error();
   xstart=-2.;
   }
#endif
norm_double(&xstart);    
    
adress=((TEDINFO *) tree_adress[vxend].ob_spec)->te_ptext;
ret=sscanf(adress,"%9lf",&xend);
#if !SCANFERROR
if (!ret)
   {
   xend=2.;
   eingabe_error();
   }
#endif
norm_double(&xend);
   
if (xstart>xend)
   {
   dummy=xstart;
   xstart=xend;
   xend=dummy;
   }
   
if (xend-xstart==0.) /* muss ein Bereich da sein !! */
   {
   eingabe_error();
   xstart--;
   }
   
adress=((TEDINFO *) tree_adress[vystart].ob_spec)->te_ptext;
ret=sscanf(adress,"%10lf",&ystart);
#if !SCANFERROR
if (!ret)
   {
   ystart=-2.;
   eingabe_error();
   }
#endif   
norm_double(&ystart);

yend=ystart+(xend-xstart)*ylines/xlines;

adress=((TEDINFO *) tree_adress[vconsta].ob_spec)->te_ptext;
ret=sscanf(adress,"%16lf",&consta);
#if !SCANFERROR
if (!ret)
   {
   consta=0.;
   eingabe_error();
   }
#endif
norm_double(&consta);

adress=((TEDINFO *) tree_adress[vconstb].ob_spec)->te_ptext;
ret=sscanf(adress,"%16lf",&constb);
#if !SCANFERROR
if (!ret)
   {
   constb=0.;
   eingabe_error();
   }
#endif
norm_double(&constb);   

adress=((TEDINFO *) tree_adress[vconstc].ob_spec)->te_ptext;
ret=sscanf(adress,"%16lf",&constc);
#if !SCANFERROR
if (!ret)
   {
   constc=PI;
   eingabe_error();
   }
#endif
norm_double(&constc);   
}

void write_forminp()
/* writes the variables into the dialog FORMINP (function,ranges,constants)*/
{
char     *adress;
OBJECT   *tree_adress;
char     helpstring[30];

rsrc_gaddr(R_TREE,vinputfun,&tree_adress);
adress=((TEDINFO *) tree_adress[vxstart].ob_spec)->te_ptext;
sprintf(helpstring,"%-10.6f",xstart);
strncpy(adress,helpstring,rscWorth(10,6));

adress=((TEDINFO *) tree_adress[vxend].ob_spec)->te_ptext;
sprintf(helpstring,"%-9.6f",xend);
strncpy(adress,helpstring,rscWorth(9,6));

adress=((TEDINFO *) tree_adress[vystart].ob_spec)->te_ptext;
sprintf(helpstring,"%-10.6f",ystart);
strncpy(adress,helpstring,rscWorth(10,6));

adress=((TEDINFO *) tree_adress[vconsta].ob_spec)->te_ptext;
sprintf(helpstring,"%-16.6f",consta);
strncpy(adress,helpstring,rscWorth(16,14));

adress=((TEDINFO *) tree_adress[vconstb].ob_spec)->te_ptext;
sprintf(helpstring,"%-16.6f",constb);
strncpy(adress,helpstring,rscWorth(16,14));

adress=((TEDINFO *) tree_adress[vconstc].ob_spec)->te_ptext;
sprintf(helpstring,"%-16.6f",constc);
strncpy(adress,helpstring,rscWorth(16,14));

/* ins Modul TREE.C schreiben */

variables[0]=consta;
variables[1]=constb;
variables[2]=constc;
}

void read_rotate()
/* manages the dialog vrotation with the rotation angles */
{
char     *adress;
OBJECT   *tree_adress;
int      ret; /* dummy */

rsrc_gaddr(R_TREE,vrotation,&tree_adress);

adress=((TEDINFO *) tree_adress[vzrotate].ob_spec)->te_ptext;
ret=sscanf(adress,"%10lf",&zangle);
#if !SCANFERROR
if (!ret)
   {
   zangle=0.;
   eingabe_error();
   }
#endif
norm_double(&zangle);   
/* nachher aufpassen, ob Grad oder Radiant !!!*/
     
adress=((TEDINFO *) tree_adress[vxrotate].ob_spec)->te_ptext;
ret=sscanf(adress,"%10lf",&xangle);
#if !SCANFERROR
if (!ret)
   {
   xangle=0.;
   eingabe_error();
   }
#endif
norm_double(&xangle);   
}
 
void write_rotate()
/* writes var into the vrotation dialog */
{
char     *adress;
OBJECT   *tree_adress;
char     helpstring[30];

rsrc_gaddr(R_TREE,vrotation,&tree_adress);

adress=((TEDINFO *) tree_adress[vzrotate].ob_spec)->te_ptext;
sprintf(helpstring,"%-10.6f",zangle);
strncpy(adress,helpstring,rscWorth(10,10));

adress=((TEDINFO *) tree_adress[vxrotate].ob_spec)->te_ptext;
sprintf(helpstring,"%-10.6f",xangle);
strncpy(adress,helpstring,rscWorth(10,10));
}

void read_view()
/* reads the coord of the view point from vview dialog */
{
char     *adress;
OBJECT   *tree_adress;
int      ret; /* dummy */

rsrc_gaddr(R_TREE,vview,&tree_adress);

adress=((TEDINFO *) tree_adress[vplaney].ob_spec)->te_ptext;
ret=sscanf(adress,"%5lf",&plane_y);
plane_y= (plane_y<400. ? 401. : plane_y);
#if !SCANFERROR
if (!ret)
   {
   plane_y=401.;
   eingabe_error();
   }
#endif
norm_double(&plane_y);   
 
adress=((TEDINFO *) tree_adress[vlookx].ob_spec)->te_ptext;
ret=sscanf(adress,"%4lf",&look_x);
#if !SCANFERROR
if (!ret)
   {
   look_x=0.;
   eingabe_error();
   }
#endif
norm_double(&look_x);   
     
adress=((TEDINFO *) tree_adress[vlooky].ob_spec)->te_ptext;
ret=sscanf(adress,"%4lf",&look_y);
#if !SCANFERROR
if (look_y<0. || (!ret))
   {
   look_y=0.;
   eingabe_error();
   }
#endif
look_y= (look_y<0. ? 0. : look_y);
if (look_y<plane_y+30.)
   {
   look_y=plane_y+30.;
   eingabe_error();
   }
norm_double(&look_y);   
        
adress=((TEDINFO *) tree_adress[vlookz].ob_spec)->te_ptext;
ret=sscanf(adress,"%4lf",&look_z);
#if !SCANFERROR
if (!ret) 
   {
   look_z=0.;
   eingabe_error();
   }
#endif
norm_double(&look_z);
}

void write_view()
/* writes var into dialog vview */
{
char     *adress;
OBJECT   *tree_adress;
char     helpstring[30];

rsrc_gaddr(R_TREE,vview,&tree_adress);

adress=((TEDINFO *) tree_adress[vlookx].ob_spec)->te_ptext;
sprintf(helpstring,"%-4.3f",look_x);
strncpy(adress,helpstring,rscWorth(4,4));

adress=((TEDINFO *) tree_adress[vlooky].ob_spec)->te_ptext;
sprintf(helpstring,"%-4.3f",look_y);
strncpy(adress,helpstring,rscWorth(4,4));

adress=((TEDINFO *) tree_adress[vlookz].ob_spec)->te_ptext;
sprintf(helpstring,"%-4.3f",look_z);
strncpy(adress,helpstring,rscWorth(4,4));

adress=((TEDINFO *) tree_adress[vplaney].ob_spec)->te_ptext;
sprintf(helpstring,"%-5.4f",plane_y);
strncpy(adress,helpstring,rscWorth(5,4));
}

void norm_int(x)
int *x;
/* brings a int var into well defined ranges */
{
if ((*x)+999<0)
   {
   eingabe_error();
   *x=-999;
   }
if (*x>9999)
   {
   eingabe_error();
   *x=9999;
   }
}   

void read_light()
/* transfers the coord of the light source from dial vlight to vars */
{
char     *adress;
OBJECT   *tree_adress;
int      ret; /* dummy */
int      old_x=light_x;
int      old_y=light_y;
int      old_z=light_z;

rsrc_gaddr(R_TREE,vlight,&tree_adress);

adress=((TEDINFO *) tree_adress[vlightx].ob_spec)->te_ptext;
ret=sscanf(adress,"%4d",&light_x);
if (!ret)
   {
   light_x=0;
   eingabe_error();
   }
norm_int(&light_x);   
     
adress=((TEDINFO *) tree_adress[vlighty].ob_spec)->te_ptext;
ret=sscanf(adress,"%4d",&light_y);
if (!ret)
   {
   light_y=1000;
   eingabe_error();
   }
norm_int(&light_y);   
        
adress=((TEDINFO *) tree_adress[vlightz].ob_spec)->te_ptext;
ret=sscanf(adress,"%4d",&light_z);
if (!ret) 
   {
   light_z=0;
   eingabe_error();
   }
norm_int(&light_z);
/* jetzt noch inferior abfragen zum öberfluss */
inferior=(tree_adress[vrahmein].ob_state&SELECTED ? TRUE: FALSE);
                 /* dh umrahmung eingeschaltet */
if (old_x!=light_x || old_y!=light_y || old_z!=light_z)
   shadowed=FALSE;
}

void write_light()
/* writes var's to dialog vlight */
{
char     *adress;
OBJECT   *tree_adress;
char     helpstring[30];

rsrc_gaddr(R_TREE,vlight,&tree_adress);

adress=((TEDINFO *) tree_adress[vlightx].ob_spec)->te_ptext;
sprintf(helpstring,"%4d",light_x);
strncpy(adress,helpstring,rscWorth(4,4));

adress=((TEDINFO *) tree_adress[vlighty].ob_spec)->te_ptext;
sprintf(helpstring,"%4d",light_y);
strncpy(adress,helpstring,rscWorth(4,4));

adress=((TEDINFO *) tree_adress[vlightz].ob_spec)->te_ptext;
sprintf(helpstring,"%4d",light_z);
strncpy(adress,helpstring,rscWorth(4,4));
}

void read_resolution()
/* reads number of lines from vresolutiON */
{
char     *adress;
OBJECT   *tree_adress;
int      *addr,vlin,i,ret,ok=TRUE;

rsrc_gaddr(R_TREE,vresoluti,&tree_adress);

for (i=0; i <= 1; i++) 
  {
  if (i) 
    {
    vlin=vxlinien;
    addr=&xlines;
    }
  else 
    {
    vlin=vylinien;
    addr=&ylines;
    }
  adress=((TEDINFO *) tree_adress[vlin].ob_spec)->te_ptext;
  ret=sscanf(adress,"%3d",addr);
  if (!ret)
    {
    *addr = 10;
    ok=FALSE;
    }
  }	/* for	*/
xlines= xlines<3 ? 3 : xlines;
ylines= ylines<3 ? 3 : ylines;
if (!check_resolution (xlines+1, ylines+1))
  {
  ok=FALSE;
  ylines = get_yresolution (xlines+1)-1;
  if (ylines<=0)
    xlines=ylines=10;
  }
xres=xlines+1;
yres=ylines+1;
if (!ok)
  eingabe_error();
}

void write_resolution()
/* writes number of lines back */
{
char     *adress;
OBJECT   *tree_adress;
char     helpstring[30];

rsrc_gaddr(R_TREE,vresoluti,&tree_adress);

adress=((TEDINFO *) tree_adress[vxlinien].ob_spec)->te_ptext;
sprintf(helpstring,"%3d",xlines);
strncpy(adress,helpstring,3);

adress=((TEDINFO *) tree_adress[vylinien].ob_spec)->te_ptext;
sprintf(helpstring,"%3d",ylines);
strncpy(adress,helpstring,3);
}

void read_drawmode ()	/* radio-buttons abfragen etc.	*/
{
  TREE_ADDR (vdrawmode);

  xraster = (IS_SELECTED (vxraster) || IS_SELECTED (vxyraster));
  yraster = (IS_SELECTED (vyraster) || IS_SELECTED (vxyraster));
  
  drawmode = (IS_SELECTED   (vwire))? WIREFRAME
           :((IS_SELECTED (vhidden))? HIDDENMODE   : SHADOW);
  
  central = IS_SELECTED (vcentral);
}

void write_drawmode ()	/* radio-buttons setzen (i.a. nur einmal) */
{
/* tja, lieber Gerd, zuerst aber alle abschalten ! */

  TREE_ADDR (vdrawmode);
  
  DESELECT(vxyraster); DESELECT(vxraster); DESELECT(vyraster);
  DESELECT(vwire);     DESELECT(vhidden);  DESELECT(vshadow);
  DESELECT(vcentral);  DESELECT(vparallel);
  
  if (xraster && yraster) SELECT (vxyraster);
  else if (xraster)       SELECT  (vxraster);
  else                    SELECT  (vyraster);
  
  if (drawmode == WIREFRAME)   		SELECT (vwire);
  else if (drawmode == HIDDENMODE) 	SELECT (vhidden);
  else                         		SELECT (vshadow);
  
  if (central) SELECT (vcentral);
  else         SELECT (vparallel);
}

void read_savemode ()	/* radio-buttons abfragen etc.	*/
{
  TREE_ADDR (vsavemode);

  pic_format=  IS_SELECTED(votimg   ) ? FIMG : 
  				(IS_SELECTED(votstad  ) ? FSTAD :
  				(IS_SELECTED(votdegas ) ? FDEGAS :
  				(IS_SELECTED(votdoodle) ? FDOODLE : FASCII )));
}

void write_savemode()  
{
/* zuerst alle ab */
  TREE_ADDR (vsavemode);
  
  if 			(pic_format == FIMG     ) 		SELECT(votimg);
  else if	(pic_format == FSTAD	 	)    	SELECT(votstad);
  else if   (pic_format == FDEGAS	 )		SELECT(votdegas);
  else if 	(pic_format == FDOODLE	 ) 	SELECT(votdoodle);
  else												SELECT(votascii);
}

void update_memostat()
{
char     *adress;
OBJECT   *tree_adress;
char     helpstring[30];

rsrc_gaddr(R_TREE,vicons,&tree_adress);

adress=((TEDINFO *) tree_adress[vmemostat].ob_spec)->te_ptext;
sprintf(helpstring,"Speicher: %5ld kB",((long) Malloc(-1))/1000);
strncpy(adress,helpstring,18);

}

/********************************************************************/
