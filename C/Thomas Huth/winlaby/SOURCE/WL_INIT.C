// ### Winlaby: Init-Funktionen ##

#include <aes.h>
#include <vdi.h>
#include "winlaby.h"

int rgb1[3],rgb2[3]; 		  /* Um Farbwerte zu speichern */

/* Externe Variablen: */
extern int wi_handle;
extern int deskx, desky, deskw, deskh;
extern int vhandle, ap_id;
extern int work_in[], work_out[];
extern void *tree_adr;

/* Prototypen: */
void fehler(text);


/* ****AES und VDI initialisieren**** */
int GEMinit(void)
{
 int i, rgb[3];

 ap_id=appl_init();							/* Applikationsnummer */
 graf_mouse(ARROW, 0L); 					/* Maus als Pfeil */
 wind_get(0, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh); /* Desktopgr”že */

 vhandle=graf_handle(&i,&i,&i,&i);			/* Grafikhandle holen */
 for(i=0;i<10;i++)  work_in[i]=1;			/* Werte initialisieren */
 work_in[7]=0; work_in[8]=0; work_in[10]=2;
 v_opnvwk(work_in,&vhandle,work_out);		/* Virtuelle er”ffnen */

 /*--- RSC laden ---*/
 if(rsrc_load("WINLABY.RSC")==0)
  { fehler("[3][Fehler beim|Laden des RSC!][ ABBRUCH ]"); return(-1); }
 rsrc_gaddr(0, LABMENUE, &tree_adr);
 menu_bar(tree_adr, 1);

 /*--- Voreinstellungen ---*/
 vq_color(vhandle,2,0,rgb1); vq_color(vhandle,3,0,rgb2);
 rgb[0]=0; rgb[1]=900; rgb[2]=1000; vs_color(vhandle,2,rgb); /* Himmelblau */
 rgb[0]=500; rgb[1]=0; rgb[2]=0; vs_color(vhandle,3,rgb);	 /* + Braun einstellen */

 return(0);
}


/* ***Beim GEM abmelden*** */
void GEMexit(void)
{
 vs_color(vhandle,2,rgb1); vs_color(vhandle,3,rgb2);
 menu_bar(tree_adr,0);		 /* Men freigeben */
 rsrc_free();
 v_clsvwk(vhandle);			 /* Virtuelle abmelden */
 appl_exit();
}


/* ****Fenster basteln**** */
int init_window(void)
{
 wi_handle=wind_create(NAME|CLOSER|FULLER|MOVER|INFO|SIZER, deskx ,desky,
					  deskw, deskh);					/* Window anmelden */
 if(wi_handle<0)
  {
	fehler("[3][Kein Fenster brig!][Abbruch]");
	return(-1);
  }
 wind_set(wi_handle, WF_NAME, "WindowLabyrinth", 0L);	/* Name setzen */
 graf_growbox(deskx+deskw/2, desky+deskh/2, 1, 1,
				  deskx, desky, deskw, deskh);
 wind_open(wi_handle, deskx, desky, deskw, deskh);		/* Window ”ffnen */
 return(0);
}
