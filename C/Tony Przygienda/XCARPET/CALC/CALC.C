/********************************************************************
 *
 *  calc.c		projekt : xcarpet
 *-------------------------------------------------------------------
 *  Berechnung und Darstellung der Kurven
 *-------------------------------------------------------------------
 *
 *******************************************************************/
 
 /*  april 88	Åbernahme der quelle 'carpet.c' von tony przygienda
  *   1. 5.	xraster,yraster,xlinien,ylinien
  *  29. 5.	speicherverwaltung ausgelagert nach 'memory'
  *   5. 6.	V 1.3	einlesen von ascii-dateien
  *	 14.10. Anpassung an ANSI-Standard und TURBO-C
  */

#include "..\carpet.h"
#include <portab.h>

#if COMPILER==MEGAMAX
	#include <obdefs.h>
	#include <gemdefs.h>
#endif
#if COMPILER==TURBOC
	#include "..\calc.h"
	#include <aes.h>
	#include <vdi.h>
	#include <stdlib.h>
	#include <string.h>
#endif

#include <math.h>
#include <stdio.h>

#if 1
#define OPTIMIZE /* newest optimization of calculation formulas */
                         /* in Version 1.1 */
#endif

		/*	testoptionen, kînnen Åber def eingeschaltet werden	*/
#if 0
#define SHADTEST
#define testlist	
#define test3d
#define test2d
#endif


/* from XCARPET */
extern WORD gr_handle;     /* physical workstation handle   */
extern WORD handle;        /* virtual workstation handle    */
extern WORD wi_handle;     /* window handl      */
extern WORD top_window;
extern int  xwork, ywork,hwork,wwork;

extern int  colours; /* how much ? */
   
extern boolean degree;

extern int     drawmode;
extern boolean central;

extern boolean error;
extern double  xstart,xend,ystart,yend;
extern double  consta,constb,constc;  /* Werte der Konstanten */

extern double  xangle,zangle;

extern double  look_x,look_y,look_z,plane_y;
extern int     light_x,light_y,light_z;

extern int     xlines,ylines; 	/* Auflîsung, Anzahl Intervalle */
extern int     xres, yres;	/*  dito,     Anzahl Linien	*/
extern boolean xraster,yraster;

extern FDB source,target; /* Bildschirm update */
extern void memory_error(); /* raus beim Reservierungsfehler */
extern void normal_error();
extern void line();
#if COMPILER==TURBOC
	extern void memory_error(void);
	extern void normal_error(char *);
	extern void line(int, int, int, int);
#endif

/* from TREE.C */
extern void disp_all(); /* released Baum der Funktion */
extern double funcwert();
#if COMPILER==TURBOC
	#include "..\tree.h"
#endif


/* from MEMORY.C */
#if 0			/* öBERBLEIBSEL AUS ALTEM CARPET !!! */
static char *array3d=NIL;            /* array of 3D double worths */
#endif
extern char *array2d;                /* array of 2D int    worths */

extern void *reserve2d();
extern void free_2d();
extern double * row_vector();  /* zeigt auf einen y-spaltenvektor */
extern int reservexyz();
#if COMPILER==TURBOC
	#include "..\memory.h"
#endif
/* Diese Pointer zeigen auf 2 Array Simulate von double-Werten
   die Arrays werden mallocated da 1. sie grîsser als 32K werden
   kînnen (keine Verwaltung von MEGAMAX) und zweitens nicht die
   Bedeutung von festen Arrays haben (Dimensionen Ñndern sich !) */
   
   
/* from FILEIO.C */
extern int read_data();
extern int inp_seekdata();  
#if COMPILER==TURBOC
	extern int read_data(void);
	extern int inp_seekdata(void);  
#endif
   
   
/* from ARRAY3D */
extern void arrayxset(),arrayyset();
extern int array_minimax(),array_mul(),array_add();
#if COMPILER==TURBOC
	#include "..\array3d.h"
#endif


#define ULONG   unsigned long

#define round(x)  (int) ((double) (x)+.5)

#if COMPILER==TURBOC
	extern long Crawcin(void);
#endif

#if COMPILER==MEGAMAX    /* MEGAMAX */
	overlay "calc"
	extern long gemdos();
	extern char *malloc();
#endif

/* global variables of CALC */
boolean counted3d=FALSE;  /* 3d counted or not */
boolean counted2d=FALSE;  /* 2d counted or not */
boolean funcgiven=FALSE;  /* function ok or not*/
boolean filegiven=FALSE;
boolean funcinput=FALSE;
boolean countedfl=FALSE;  /* flÑchen counted or not */
boolean shadowed=FALSE;
boolean inferior=FALSE;

#define SOFD  (long) sizeof(double)
#define SOFI  (long) sizeof(int)

/* hier alles fÅr die Liste der FlÑchen zum Rembrandt */
/* in Version 1.1 wurde sie doppelt gelinkt aus Sortiergeschwindigkeits- */
/* grÅnden */

typedef struct 
   plane
   {
   int           x_coord,y_coord;
   unsigned long distance;
   int           shadow; /* zugehîrige Schattierung */
   struct plane  *left,*right;
   /* the right shows to a bigger one, the left to a lower */
   } nplane;

typedef nplane *piplane;

piplane firstpp=NIL; /* der pi auf den ersten nplane */

void release_all() /* alle Arrays free machen */
{
extern void dispose_list();
#if COMPILER==TURBOC
	void dispose_list(void);
	void free_xyz(void);
	void disp_all(void);
#endif

dispose_list();

free_xyz();	/* 2d- und 3d-speicher freigeben	*/

disp_all();
/* hier noch Funktionsbaum releasen */
}   

void disp_plane(pt)
register piplane pt;
/* this function disposes all elements of the plane list, which are */
/* kids of the given pt root */
{
#if COMPILER==TURBOC
	void disp_plane(piplane);
#endif
if (pt->left)
   disp_plane(pt->left);
if (pt->right)
   disp_plane(pt->right);
free(pt);
}   

void dispose_list() /* of planes */
/* this function disposes the whole plane list */
{
extern void disp_plane();
#if COMPILER==TURBOC
	void disp_plane(piplane);
#endif

/* register piplane pr=firstpp; */

if (firstpp)
   disp_plane(firstpp);
countedfl=FALSE;   
firstpp=NIL;
shadowed=FALSE;
}   

void sort_in(root,child)
register piplane *root,child;
/* this routine sorts the piplane p in the list starting at firstpp */
{
#if COMPILER==TURBOC
	void sort_in(piplane *,piplane);
#endif

if (!(*root)) /* means, if *root==NIL */
   *root=child;
else  
   if (child->distance<(*root)->distance)
      sort_in(&(*root)->left,child);
   else
      sort_in(&(*root)->right,child);
}
   
int make_list(terror) /* FlÑchen sortieren */
char *terror;
{
register int x_run,y_run;
#if 0
register double *p3d;
#endif
register int dummy;
register long ldummy;
piplane  pi_run;
#ifdef OPTIMIZE
long     vektor[3];
#else
double   vektor[3];
#endif
#if 0		/* vom CARPET */
int      constlin=(ylines+1)*3;
#endif

for (x_run=1; x_run!=xlines+1; x_run++)
   {
   register double *p3d_a,*p3d_b;
   
   p3d_a=row_vector(x_run-1); 
   p3d_b=row_vector(x_run);
   for (y_run=1; y_run!=ylines+1; y_run++)
      {
      pi_run=(piplane) malloc(sizeof(nplane));
      if (pi_run==NIL)
      {
         error = TRUE;
         dispose_list();
   		strcpy(terror,"Zu wenig Speicher zum Sortieren der FlÑchen !");
         return (FALSE);
      }
      pi_run->left=pi_run->right=NIL;
      pi_run->x_coord=x_run-1;
      pi_run->y_coord=y_run-1;
      /* zuerst Mittelpunkt der FlÑche */
      for (dummy=0; dummy<3; dummy++)
         {
         vektor[dummy]=
               ((*p3d_a)+(*(p3d_a+3))+
               (*(p3d_b))+(*(p3d_b+3)));
#ifdef OPTIMIZE
         vektor[dummy]/=4;
#else
         vektor[dummy]/=4.; /* Schnitt aller 4 Ecken */
#endif
         p3d_a++;
         p3d_b++;
         }
#ifdef OPTIMIZE
		ldummy=  vektor[0]- (long) look_x;
      pi_run->distance= (ldummy*ldummy);
      ldummy=vektor[1]- (long) look_y;
      pi_run->distance+=(ldummy*ldummy);
      ldummy=vektor[2]- (long) look_z;
      pi_run->distance+=(ldummy*ldummy);
#else
      pi_run->distance=(unsigned long) (vektor[0]-look_x)*(vektor[0]-look_x);
      /* peinlicherweise _ulmul in SYSLIB nicht definiert ?! */
      pi_run->distance+=(unsigned long) (vektor[1]-look_y)*(vektor[1]-look_y);
      pi_run->distance+=(unsigned long) (vektor[2]-look_z)*(vektor[2]-look_z);
      /* Distanz der FlÑche vom Sichtpunkt im Quadrat */
      /* Pointer schon fÅr den nÑchsten Punkt entsprechend erhîht */
      /* maximale Distanz ~(9999+300)^2*3 geht in ulong 32 BIT */
#endif
      sort_in(&firstpp,pi_run);
      }
   }
countedfl=TRUE;

return (TRUE);

} /* liste also schon da */      

#ifdef testlist
void print_list(register piplane root)
{
if (root!=NIL)
	{
	if (root->right)
	   print_list(root->right);
	printf("Adr:%lx,x:%d,y:%d,d:%lu,sh:%d,lft:%lx,rgt:%lx\n",root,*root);
	if (root->left)
	   print_list(root->left);
	}
}
#endif

#if COMPILER!=TURBOC
double sqrt(arg)
register double arg;  /* hoping, it is much faster than the intern function */
{ 
register double x0=arg/2.;
register int    step;

if (x0)
   for (step=1; step<5; step++)
       {
       x0+=arg/x0, x0/=2.;
       }
return x0;
}   
#endif

void count_shadows(terror)
char *terror;
{
extern void rekurs_shadow();
#if COMPILER==TURBOC
	extern void rekurs_shadow(char *,piplane);
#endif

rekurs_shadow(terror,firstpp);
shadowed=TRUE;
}

void rekurs_shadow(t,pp)
char *t; 
register piplane pp;
{
void count_rshadow();
#if COMPILER==TURBOC
	void count_rshadow(char *,piplane);
	void rekurs_shadow(char *,piplane);
#endif

if (pp->left && !error)
   rekurs_shadow(t,pp->left);
if (!error)
   count_rshadow(t,pp);
if (pp->right && !error)
   rekurs_shadow(t,pp->right);
}

void count_rshadow(terror,pp)
char *terror;        /* funktioniert mit extern nicht !!? */
register piplane pp; /* this one is to count */
{
register double   *p3d_a,*p3d_b;
register int      dummy;
#ifdef OPTIMIZE
         long     mittelpunkt[3];
         int      v1[3],v2[3]; /* Vektore der zwei Seiten */
         long     flv[3],lightv[3]; /* flÑchenvektor & lichvektor */
unsigned long     lfl,llight; /* LÑngen der Vektoren */
#else         
         double   mittelpunkt[3];
         double   v1[3],v2[3]; /* Vektore der zwei Seiten */
         double   flv[3],lightv[3]; /* flÑchenvektor & lichvektor */
         double   lfl,llight; /* LÑngen der Vektoren */
#endif         
/* register int      constlin=(xlines+1)*3;     */
register double   cos_fi; /* des Winkels zwischen den flv & lightv */

#ifdef SHADTEST
   printf("Schlaufe rein pp=%lx\n",pp);
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif  

#if 0    /*  im CARPET so gerechnet */ 
p3d=(double *) array3d;
p3d+=pp->y_coord*3+pp->x_coord*constlin; /* Ecke */
#endif

p3d_a = row_vector (pp->x_coord) + pp->y_coord*3 ;
p3d_b = row_vector (pp->x_coord+1) + pp->y_coord*3 ;

for (dummy=0; dummy<3; dummy++)
   {
   mittelpunkt[dummy]=((*(p3d_a+dummy))+
                      (*(p3d_a+3+dummy))+
                      (*(p3d_b+dummy))+
                      (*(p3d_b+3+dummy)));
#ifdef OPTIMIZE
   mittelpunkt[dummy]/=4;
#else
   mittelpunkt[dummy]/=4.;
#endif    
   }   
   /* Schnitt aller 4 Ecken */
   /* hier den FlÑchenvektor berechnen */
for (dummy=0; dummy<3; dummy++)
   {
   v1[dummy]=*(p3d_b+dummy)-(*(p3d_a+dummy));/*Seitenvektor*/
   v2[dummy]=*(p3d_a+dummy+3)-(*(p3d_a+dummy)); /* zweiter Seitenvektor */ 
   }
/* Kreuzprodukt beider Seitenvektoren gibt uns den FlÑchenvektor */
flv[0]=v1[1]*v2[2]-v1[2]*v2[1];
flv[1]=v1[2]*v2[0]-v1[0]*v2[2];
flv[2]=v1[0]*v2[1]-v1[1]*v2[0]; /* Uff */

#if 0  /* im Prinzip nicht nîtig, verfÑlscht Beleuchtung */
/* jetzt noch Test, ob flÑchenvektor richtung der Projektionsebene hat, */
/* falls nicht, muss er umgekehrt werden -> Biegung des Teppiches       */
/* kann den Vektor 'falsche' umdrehen */
#ifdef OPTIMIZE
if (flv[1]<0) /* schaut eben nicht Richtung y-Achse */
   for (dummy=0; dummy<3; flv[dummy++]*=-1);
#else
if (flv[1]<0.) /* schaut eben nicht Richtung y-Achse */
   for (dummy=0; dummy<3; dummy++)
      flv[dummy]*=-1.;
#endif /* of optimize */ 
#endif /* of if 0 */
#ifdef SHADTEST
   puts("Nach mittelflÑche\n");
#endif   
   /* jetzt Vektor von Lichquelle zu Mittelpunkt */
lightv[0]=(long) light_x-mittelpunkt[0];
lightv[1]=(long) light_y-mittelpunkt[1];
lightv[2]=(long) light_z-mittelpunkt[2];
  /* LÑngen der Vektoren berechnen */
lfl=llight=0;
for (dummy=0; dummy<3; dummy++)
   {
   llight+=(lightv[dummy]*lightv[dummy]);
   lfl+=(flv[dummy]*flv[dummy]);
   }
/* LÑngenvektoren im Quadrat abgelegt, Wurzel davon wird erst spÑter taken */
#ifdef SHADTEST
   printf("Nach LÑngen %lf %lf\n",llight,lfl);
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif
if (llight<1) /* dh. Lichtvektor ist Nullvektor */
   {
#ifdef SHADTEST
   puts("Error aufgetreten\n");
#endif
   error=TRUE;
   strcpy(terror,"Lichtquelle ist Element einer FlÑche");
   }
#ifdef SHADTEST
   printf("Nach error %d\n",(int) error);
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif
if (!error)
   {
   /* jetzt zwischenwinkel */
   cos_fi=0.;
   /* Berechnen des Quadrats des Cosinus-Winkels */
   for (dummy=0; dummy<3; dummy++)
      cos_fi+=flv[dummy]*lightv[dummy]; /* Skalarprodukt */
   cos_fi*=(cos_fi<0. ? -cos_fi: cos_fi); /* im Quadrat, aber mit richtigem Vorzeichen! */
#ifdef SHADTEST
   puts("FlÑchenvektor  Lichtvektor\n");
   for (dummy=0; dummy<3; dummy++)
      printf("%lf  %lf\n",flv[dummy],lightv[dummy]);
   printf("fl:%lf lgh:%lf\n",lfl,llight);
   printf("Skalar^2:%lg\n",cos_fi);
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif 
   cos_fi/=((double) llight) * ((double) lfl); /* LÑngenquadrate */
   /* sgn(cos_fi)*cos_fi^2<0 ->FlÑche der Quelle abgewandt fi>180 Grad */        
   if(cos_fi<0.) /* trifft auch auf mein PSEUDO Quadrat zu ! */
      {
      if (colours<=11)
         pp->shadow=0; /* dunkelste Farbe bzw. Schattierung  */
      else
         pp->shadow=2;
      }
   else
      {
#if 0      
      /* nach neusten Erkenntnissen im Quadrat abhÑngig			*/
      cos_fi=sqrt(cos_fi);  /* hier interessiert's uns effektiv */
#endif
      if (colours<=11) /* it means, better with built-in shapes */
         {
         pp->shadow=(int) 9.*cos_fi;
         if (pp->shadow==9) /* too much */
            pp->shadow=8;
         }
      else /* use colours of GEM */
         {
         pp->shadow=(int) (colours-2)*cos_fi+2.;
         if (pp->shadow==colours)
            pp->shadow=colours-1; /* Farbe maximum-1 == die hellste */
         } 
      }      
   }
}

void paint_function(root)
register piplane root;
/* paints the function from the widest to the nearest planes */
{
#if COMPILER==TURBOC
	void paint_function(piplane);
	void paint_rfunction(piplane);
#endif

if (root->right)
   paint_function(root->right);
paint_rfunction(root);
if (root->left)
   paint_function(root->left);
}

void paint_rfunction(p_run)
register piplane p_run;
/* draw this area */
{
register int *p2d;
WORD pxy[10];

#if 0
printf("peri:%d\n",(int) inferior);
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif

p2d=(int *) array2d;
/* jetzt ausrechnen den Index der FlÑchenpunkte */
p2d+=p_run->y_coord*2+p_run->x_coord*2*(ylines+1);
pxy[0]=pxy[8]=*(p2d);pxy[1]=pxy[9]=*(p2d+1);
pxy[2]=*(p2d+2); pxy[3]=*(p2d+3);
p2d+=(ylines+1)*2;
pxy[6]=*(p2d);pxy[7]=*(p2d+1);
pxy[4]=*(p2d+2); pxy[5]=*(p2d+3);
if (drawmode==SHADOW)
   {
   if (colours<=11)
      {
      if (p_run->shadow==8) /* total hell */
         {
         vsf_interior(handle,1);
         vsf_color(handle,0);
         }
      else if (p_run->shadow==0) /* total dunkel */
         {
         vsf_interior(handle,1);
         vsf_color(handle,1);
         }
      else
         {
         vsf_interior(handle,2);
         vsf_color(handle,1);
         vsf_style(handle,8-p_run->shadow);
         }
      }
   else /* built in colours  */
      {
      vsf_interior(handle,1);
      vsf_color(handle,p_run->shadow);
      }
   }
else /* hidden */
   {
   vsf_interior(handle,1); /* FlÑche mit Farbe ausfÅllen */
   vsf_color(handle,0); /* 0 Farbe */
   }
v_fillarea(handle,5,pxy);
vsf_color(handle,1); /* to standard */
if ((colours>11) && (!inferior) && (drawmode==SHADOW)) 
        /* draw the colour border */
   {
   vsl_color(handle,p_run->shadow);
   v_pline(handle,5,pxy);
   vsl_color(handle,1);
   }
if (!((drawmode==SHADOW) && (!inferior)))
   if (xraster && yraster)
     v_pline(handle,5,pxy);
   else if (yraster)
		{
		v_pline (handle,2,&pxy[0]);
		v_pline (handle,2,&pxy[4]);
		}
	else if (xraster) /* x-raster */
		{
		v_pline (handle,2,&pxy[2]);
		v_pline (handle,2,&pxy[6]);
		}
 /* nur Rand der Funktion zeichnen wegen weissen Schatten */
if(p_run->x_coord==0)
   line(pxy[0],pxy[1],pxy[2],pxy[3]);
if(p_run->x_coord==xlines-1)
   line(pxy[4],pxy[5],pxy[6],pxy[7]);
if(p_run->y_coord==0)
   line(pxy[6],pxy[7],pxy[8],pxy[9]);
if(p_run->y_coord==ylines-1)
   line(pxy[2],pxy[3],pxy[4],pxy[5]); /* keine else if, wegen Ecken */  
}   
   
void draw3d()
{
#ifdef testlist
puts("From high to low\n");
print_list(firstpp);
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif

vswr_mode(handle,1); /* replace */
vsl_color(handle,1);
vsf_interior(handle,1);
vsf_color(handle,0);
vsf_perimeter(handle,0);

paint_function(firstpp);
}

void draw_function()
{
#if COMPILER==TURBOC
	void draw2d(void);
	void draw3d(void);
#endif
int pxy[8];

/* graph buff and screen allready cleared in CARPET */
vsl_type(handle,1);
vsl_color(handle,1);
if (drawmode==WIREFRAME)
   draw2d(); /* ohne FlÑchensort ! */
else
   draw3d(); /* mit Sort und allem drum und dran */
/* now, move the drawed to the buffer */
pxy[0]=xwork; /* left upper */
pxy[1]=ywork;
pxy[2]=pxy[0]+wwork-1;
pxy[3]=pxy[1]+hwork-1; /* the area to copy of the graph page */
pxy[4]=0;
pxy[5]=0;
pxy[6]=wwork-1;
pxy[7]=hwork-1; /* copy from the source screen  */
vro_cpyfm(handle, S_ONLY, pxy, &source, &target);
}

int calc3d(terror) /* hier Berechnung des 3d Arrays der Funktion (mit Drehung) */
char *terror;
{
extern void rotate();
#if COMPILER==TURBOC
	extern void rotate(void);
#endif

  double max_fnz=-100000.;
  double min_fnz=100000.; /* nachher zur Zentrierung */
  register int    x_run,y_run;
  register double *dp;
  int    dummy,ok=TRUE;
  double dx_l=(xend-xstart)/xlines;
  double dy_l=(yend-ystart)/ylines;
  double x_60=200./xlines;		/* x-wert-multiplikator	*/
  double y_60=x_60*ylines/xlines;	/* y-wert-multiplikator	*/
  double z_60=200./(xend-xstart);	/* z-wert-multiplikator	*/
  double move_const, delta_z, faktor;
/*  unsigned long help_p; */
 
  dispose_list(); 	/* the list of planes for Rembrandt */

  free_xyz();    

  if (!reservexyz (xlines+1, ylines+1))
  {
    error = TRUE;
	 strcpy(terror,"Zu wenig Speicher (Auflîsung reduzieren !)");
    return (FALSE);
  } 
/* xlines * array[ylines][3] : die ersten zwei Indexes geben die 
   gehîrige X- bzw Y-Linie des Punktes, die 3 kodiert X,Y,Z Koordinate
   des Punktes im 3D System , zeiger auf array : row_vector (x)  */
   
/* berechnen der Z-Werte */
  
  if (funcinput)
  {
    for (x_run=1; x_run!=xlines+2; x_run++)
    {
      dp = row_vector (x_run-1);
      for (y_run=1; y_run!=ylines+2; y_run++)
      {
        *(dp++)=100-(x_run-1)*x_60;
        *(dp++)=100-(y_run-1)*y_60;
        *dp=z_60*funcwert(xend-(x_run-1)*dx_l,yend-(y_run-1)*dy_l);
        if (max_fnz-(*dp)<0.)
          max_fnz=(*dp);
        if ((*dp)-min_fnz<0.)
          min_fnz=(*dp);   
        dp++;
      }
    }
  }
  else		/*  ascii-werte von datei lesen		*/
  {
  	ok = inp_seekdata();
    if (ok && read_data()) /* alles klar	*/
    {
      xstart = ystart = 0;	/* header-daten manipulieren	*/
      xend = 20*xres;		/* ergibt quadratisches raster	*/
      yend = 20*yres;
    
      arrayxset();
      arrayyset();
      array_minimax (2,&min_fnz,&max_fnz);
      if ((delta_z = max_fnz - min_fnz) != 0.)
      {
        extern double sqrt();
        faktor = .333 * form_alert (3,
          "[2][Relative Hîhe in %| |][ 33 | 66 | 100 ]");
        faktor *= (xend - xstart + yend - ystart) / (2. * delta_z);
        array_mul (2,faktor);
      }
    }
    else
    {
		strcpy(terror,"Fehler bei der Dateipositionierung");
      error=TRUE;
    }
  }
   
/* Netz nun berechnet */      

#ifdef test3d
  for (x_run=1; x_run!=xlines+2; x_run++)
  {
    dp = row_vector (x_run-1);
    for (y_run=1; y_run!=ylines+2; y_run++)
    {
      printf("%lf %lf %lf %lx %lx %lx \n",*dp,*(dp+1),*(dp+2),dp,dp+1,dp+2);
      dp+=3;
    }
  }
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif      

/* in Mitte des 3D Systems zentrieren der Z-Koordinate */

  if (ok)
  {
    move_const=(max_fnz+min_fnz)/2.;
    array_add (2,-move_const);
    rotate();
  }
  
  return (ok);
}

void rotate ()
{   
  register int    x_run,y_run;
  register double *dp;
  register double turn_matrix[3][3];
  double xturn_matrix[3][3];
  double zturn_matrix[3][3];
  double grad_const=( degree ? PI/180. : 1. ); /* Grad bei Drehung umrechnen */
                                             /* oder nicht ? */
  double stretch_const=1.;

  
for (x_run=0; x_run<3; x_run++)
   for(y_run=0; y_run<3; y_run++)
      {
      xturn_matrix[x_run][y_run]=0.;
      zturn_matrix[x_run][y_run]=0.;
      }

xturn_matrix[0][0]=1.;
xturn_matrix[1][1]=cos(xangle*grad_const);
xturn_matrix[1][2]=sin(xangle*grad_const);
xturn_matrix[2][1]=-xturn_matrix[1][2];
xturn_matrix[2][2]=xturn_matrix[1][1];

zturn_matrix[0][0]=cos(zangle*grad_const);
zturn_matrix[0][1]=sin(zangle*grad_const);
zturn_matrix[1][0]=-zturn_matrix[0][1];
zturn_matrix[1][1]=zturn_matrix[0][0];
zturn_matrix[2][2]=1.;

for (x_run=0;x_run<3; x_run++)
   {
   for (y_run=0; y_run<3; y_run++)
      {
      turn_matrix[x_run][y_run]=
               xturn_matrix[x_run][0]*zturn_matrix[0][y_run]+
               xturn_matrix[x_run][1]*zturn_matrix[1][y_run]+
               xturn_matrix[x_run][2]*zturn_matrix[2][y_run];
      if (x_run==y_run)
         turn_matrix[x_run][y_run]*=stretch_const;
      /* includes stretching into the matrix */
#ifdef test3d
      printf("%lf ",turn_matrix[x_run][y_run]);
#endif
      }
#ifdef test3d      
   printf("\n");
#endif   
   }
#ifdef test3d               
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif              

/* somit Drehungsmatrix hergestellt und als nÑchstes drehen */

for (x_run=1;x_run!=xlines+2; x_run++)
   {
   dp = row_vector (x_run-1);
   for (y_run=1; y_run!=ylines+2; y_run++)
      {
      register double x,y,z;
        
      x=*(dp), y=*(dp+1), z=*(dp+2);
      *(dp++)=x*turn_matrix[0][0]+
              y*turn_matrix[0][1]+          
              z*turn_matrix[0][2];
      *(dp++)=x*turn_matrix[1][0]+
              y*turn_matrix[1][1]+          
              z*turn_matrix[1][2];    
      *(dp++)=x*turn_matrix[2][0]+
              y*turn_matrix[2][1]+          
              z*turn_matrix[2][2]; 
      }
   }
   
/* und Zeug auf Bildschirm vorsichtshalber */
#ifdef test3d
for (x_run=1; x_run!=xlines+2; x_run++)
   {
   dp = row_vector (x_run-1);
   for (y_run=1; y_run!=ylines+2; y_run++)
      {
      printf("%lf %lf %lf\n",*dp,*(dp+1),*(dp+2));
      dp+=3;
      }
   }
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif
#endif      

counted3d=TRUE;

}

int calc2d(terror)
char *terror;
/* rechnet 3D System in 2D um -> Sichtsystem auf dem Schirm */
{
unsigned long help_p;
int res_x=xwork+wwork/2;
int res_y=ywork+hwork/2;
register int x_run,y_run;
register int *d2p;
register double *d3p;
int yturn_max=-2000;
int yturn_min=2000;
int xturn_max=-2000;
int xturn_min=2000;
int translatey,translatex;
double stretchx,stretchy; /* wird variert */

/* the list of rectangles should not be deleted */

free_2d();

if ((array2d=reserve2d (xlines+1,ylines+1)) == NIL)
{
  error = TRUE;
  strcpy(terror,"Kein Platz fÅr 2d-Feld (merkwÅrdig !)");
  return (FALSE);
}

d2p=(int *) array2d;

for (x_run=1; x_run!=xlines+2; x_run++)
   {
   d3p = row_vector (x_run-1);
   for (y_run=1; y_run!=ylines+2; y_run++)
      {
      if (central) /* zentral projeziert */
         {

         *d2p= round((*d3p)+(look_x-(*d3p))*(plane_y-(*(d3p+1)))
                     /(look_y-(*(d3p+1))));
         *(d2p+1)= round((*(d3p+2))+(look_z-(*(d3p+2)))*(plane_y-(*(d3p+1)))
                     /(look_y-(*(d3p+1))));
         }
      else
         {
         *d2p= round((*d3p));
         *(d2p+1)= round((*(d3p+2)));
         }
      if (yturn_max<*(d2p+1))
         yturn_max=*(d2p+1);
      if (yturn_min>*(d2p+1))
         yturn_min=*(d2p+1);   /* nachher zur Zentrierung in Bildmitte ! */
      if (xturn_max<*(d2p))
         xturn_max=*(d2p);
      if (xturn_min>*(d2p))
         xturn_min=*(d2p);  
      d2p+=2;
      d3p+=3;   
      }
   }
   
translatey=(yturn_max+yturn_min)/2; /* neuerdings die Verschiebung */
if (yturn_max!=translatey)
   stretchy=((double)(res_y-ywork))/((double)(yturn_max-translatey));
else
   stretchy=1.;
   
translatex=(xturn_max+xturn_min)/2; /* neuerdings die Verschiebung */
if (xturn_max!=translatex)
   stretchx=((double)(res_x-xwork))/((double)(xturn_max-translatex));
else
   stretchx=1.;
   
if (stretchx-stretchy<0.)
   stretchy=stretchx;    
else
   stretchx=stretchy; /* gegenseitig anpassen die WÅrgs */
       
                        /* zur Skalierung */
d2p=(int *) array2d;
for (x_run=1; x_run!=xlines+2; x_run++)
   for (y_run=1; y_run!=ylines+2; y_run++)
      {
      *(d2p+1)-=translatey;
      *(d2p)-=translatex;
      *(d2p)=((double) *(d2p))*stretchx;
      *(d2p+1)=((double) *(d2p+1))*stretchy;
      *(d2p)+=res_x;
      *(d2p+1)=res_y-(*(d2p+1));
      d2p+=2;  /* Verschieben in Schirmmitte des Graphen */
      }
  
#ifdef test2d
d2p=(int *) array2d;
for (x_run=1; x_run!=xlines+2; x_run++)
   for (y_run=1; y_run!=ylines+2; y_run++)
      {
      printf("%d %d\n",*d2p,*(d2p+1));
      d2p+=2;
      }
#if COMPILER==TURBOC
	Crawcin();
#else	
   gemdos(7);
#endif    
#endif      

counted2d=TRUE;

return (TRUE);
}      

void draw2d()
{
register int x_run,y_run;
register int *p2d;
extern void line();

vsl_color(handle,1);
vsl_type(handle,1); 
vsl_width(handle,1); /* Linieneinstellung */

			/*   innenbereich + standard-kanten	*/
p2d=(int *) array2d;
for (x_run=1; x_run!=xlines+1; x_run++)
   {
   for (y_run=1; y_run!=ylines+1; y_run++)
      {
      if (yraster || x_run==1) 
        line(*p2d,*(p2d+1),*(p2d+2),*(p2d+3));
      if (xraster || y_run==1)
        line(*p2d,*(p2d+1),*(p2d+ylines*2+2),*(p2d+ylines*2+3));
      p2d+=2;
      }
   p2d+=2;
   }
			/*   auûenkante x  (y = y-ende) 	*/
p2d=(int *) array2d;
p2d+=2*ylines;
/* if (xraster) */
  for (x_run=1;x_run!=xlines+1;x_run++)
   {
   line(*p2d,*(p2d+1),*(p2d+ylines*2+2),*(p2d+ylines*2+3));
   p2d+=2*ylines+2;
   }
			/*   auûenkante y  (x = x-ende) 	*/
p2d=(int *) array2d;
p2d+= (ylines+1)*2*xlines;
/* if (yraster) */
  for (y_run=1;y_run!=ylines+1;y_run++)
   {
   line(*p2d,*(p2d+1),*(p2d+2),*(p2d+3));
   p2d+=2;
   }
}

/***********************************************************/
