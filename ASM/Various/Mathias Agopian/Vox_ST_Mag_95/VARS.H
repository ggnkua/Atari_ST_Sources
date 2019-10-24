/* structures */

/* Variables Globales */

/* Gestion du GEM */

char *rsrc_name="VOX.RSC";

int WorkHCeil;
long gl_lang;
int index=0;
DTA FirstDta;
DTA *dta;
int speedo;
int xb,yb,wb,hb;
int xi,yi,wi,hi;
int ap_id;
int handle;
int whandle; 						           /* Handle fenˆtre cliqu‚e */
int buf[8];
int mybuf[8];
int mx,my,mk,kbd,key,clik;
int objet;
int edit;
int fhandle;
int flacc=0;
int wind_handle,wind_index,wind_indexGem;
int x,y,w,h;
int xw,yw,ww,hw;
int quit=0;
int event,i;
int xpos,ypos,sel_return;
int pxy[8],pxy1[6],pxy2[6],pxy3[6],pxy4[6];
int nb_colors,Xresolution,Yresolution;
int error;

GRECT r,rd;
MN_SET values;
MENU menu_in, menu_out, pad;

AESPB aespb;
VDIPB vdipb;
OBJECT *adr_menu;	  								/* Adresse du menu */
OBJECT *adr_desk;     								/* Adresse du bureau */
OBJECT *adr_pop_clk;
OBJECT *adr_icn;


/* Gestion des fenetres */


WINDOW window[nb_window+1];


/* Autres variables */

char app_path[256];
int FlagDefault;
int	dummy;
int pos;
int choix;
int temp;
int xpop,ypop;
int inline_help=0;
int no_index=0;
int wh;

long cnt200;

char Texttemp[30];
char nbre[4];
char nomfich[256];
