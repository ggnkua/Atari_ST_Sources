#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <falcon.h>
#include "teps.h"

#ifndef TRUE
#define TRUE  -1
#endif

/* Prototypen: */
char  *strcpy(char *s1, const char *s2);
char  *strcat(char *s1, const char *s2);
char    *ultoa( unsigned long value, char *string, int radix );

extern int msgbuff[8];        /* Globale Variablen */
extern OBJECT *menutree;      /* Definition in TEPSMAIN */
extern OBJECT *dialtree;
extern int swihndl;
extern char popupposibl;
extern OBJECT *moditree;
extern OBJECT *freqstree;
extern char *sambufstart;
extern char *sambufend;
extern unsigned long samlength;
extern char *playbufstart;
extern char *playbufend;
extern unsigned long playlength;

int vhandle;                  /* VDI-Kennung */

char *lvolslid;                  /* Nummer im 1. Slider */
char *rvolslid;                  /* Nummer im 2. Slider */

char swiinfo[]="Buffergr”že: 00000 kB"; /* Infozeile */

/* ***Auf Fehler aufmerksam machen*** */
void write_error(char *text)
{
 char alerttext[88];
 strcpy(alerttext, "[3][Fehler:|");
 strcat(alerttext, text);
 strcat(alerttext, "][Abbruch]");
 form_alert(1, alerttext);
}

/* ***Dialoge vorbereiten*** */
void fixdial(OBJECT *tree)
{
 register int actobj=0;
 do
  {
   if(tree[actobj].ob_type>>8 == 'T')
    tree[actobj].ob_y-=tree[actobj].ob_height/2;
  }
 while( !(tree[actobj++].ob_flags & LASTOB) );
}


/* ***RSC laden, Objectadressen abfragen, beim VDI anmelden usw.*** */
int initGEM(void)
{
 int i;
 int work_in[12], work_out[57];        /* Workstation-Informationen */
 int wx, wy, ww, wh;

 i=appl_init();                     /* Beim AES anmelden */
 if(i==-1)  { Cconws("\r\nFehler bei appl_init!"); Crawcin(); return(-1); }

 if(rsrc_load("TEPS.RSC")==0)
  { write_error("TEPS.RSC konnte nicht|geladen werden!");
   appl_exit();  return(-1);
  }
 rsrc_gaddr(R_TREE, MAINMENU, &menutree); /* Adressen der Objekte holen */
 rsrc_gaddr(R_TREE, MAINDIAL, &dialtree);
 rsrc_gaddr(R_TREE, MODI, &moditree);
 rsrc_gaddr(R_TREE, FREQS, &freqstree);

 fixdial(dialtree);                   /* Titel auf richtige H”he bringen */

 wind_get(0, WF_WORKXYWH, &wx, &wy, &ww, &wh);           /* Desktopgr”že */
 swihndl=wind_create(NAME|MOVER|INFO, wx, wy, ww, wh);   /* Fenster anmelden */
 if(swihndl<0)
  { write_error("Kein Fenster mehr|verfgbar!");
   rsrc_free(); appl_exit(); return(-1);
  }
 wind_set(swihndl, WF_NAME, "Samplefenster", 0L);  /* Name setzen */
 form_center(dialtree, &wx, &wy, &ww, &wh);  /* Koors Dialog */
 wy+=wh+16;                      /* Samplefenster unter Dialogfenster setzen */
 wind_calc(WC_BORDER, NAME|MOVER|INFO, wx, wy, ww, 64,
         &wx, &wy, &ww, &wh);
 wind_set(swihndl, WF_INFO, swiinfo, 0L);    /*Infozeile setzen */
 wind_open(swihndl, wx, wy, ww, wh);         /* Samplefenster ”ffnen */

 graf_mouse(ARROW, 0L);                /* Maus als Pfeil */
 menu_bar(menutree, 1);                /* Men darstellen */

 lvolslid=dialtree[LVOLSLID].ob_spec.free_string;  /* Stringadr. holen */
 rvolslid=dialtree[RVOLSLID].ob_spec.free_string;


 for(i=0; i<10; i++)  work_in[i]=1;       /* Work-in fllen */
 work_in[10]=2;
 vhandle=graf_handle(&i, &i, &i, &i);     /* Handle holen */
 v_opnvwk(work_in, &vhandle, work_out);      /* VDI anmelden */

 return(0);
}

/* ***Beim GEM abmelden*** */
void exitGEM(void)
{
 wind_close(swihndl);
 wind_delete(swihndl);              /* Fenster l”schen */
 menu_bar(menutree, 0);             /* Men freigeben */
 rsrc_free();                       /* RSC freigeben */
 v_clsvwk(vhandle);                 /* VDI abmelden */
 appl_exit();                       /* AES abmelden */
}

/* ***Programm an Soundsubsystem anpassen, Buffer vorbereiten*** */
int initsamplebuf(void)
{
 long *i;

 samlength=(unsigned long)Malloc(-1L)/4L;
 sambufstart=(char *)Malloc(samlength);
 if( sambufstart< (char *)(1L) )
  { write_error("Nicht genug|Speicher brig!"); return(-1); }

 sambufstart=(char *)( (1L + ((long)sambufstart)) & 0xFFFFFFFEL);
 samlength &= 0xFFFFFFFEL;
 sambufend=playbufend=sambufstart+samlength;
 playbufstart=sambufstart;
 playlength=samlength;

 ultoa(samlength/1024L, &swiinfo[13], 10);
 strcat(swiinfo, " kB");
 for(i=(long *)sambufstart; i<(long *)sambufend; i++) *i=0;

 Setbuffer(0, sambufstart, sambufend);
 Devconnect(DMAPLAY, DAC, 0, CLK12K, 1);   /* 12KHz einstellen */
 Setmode(MONO8);
 Soundcmd(LTATTEN, 0x070); Soundcmd(RTATTEN, 0x070);

 return(0);
}
