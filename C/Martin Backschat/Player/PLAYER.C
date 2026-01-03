/*     MUSIC-Player C-Sourcekode - written by MABA
       -------------------------------------------

       spielt auf Wunsch ein MusikstÅck ab.
*/

#define   state(x)       *(zeiger + (x * 12) + 5)

#define       PRG    4
#define       AGAIN  5


char pathname[66] = "A:*.SNG";
char filename[14] = 0;

long speicher = 0;

extern long   gemdos();
extern long   bios();
extern long   xbios();

extern int gl_apid;
int id,index;

int *zeiger;

struct DTA {
       char   shit1[26];
       unsigned int h_len;
       unsigned int l_len;
       char   shit2[20];
} dta;


/******************  Programmteil ******************/
main()
{

       appl_init();
       id = menu_register(gl_apid,"  Music-Player 1.0");

       if (!rsrc_load("player.rsc")) {    /* Fehler beim Laden */
              form_alert(1,"[1][Kann PLAYER.RSC nicht nachladen!][ABBRUCH]");
              return;
       }

       rsrc_gaddr(1,0,&zeiger);  /* Startadr. holen */


       state(AGAIN) = 8|32;    /* DISABLED /*

       gemdos(0x48,(long) 5);      /* 5 Bytes belegen */

       multi();
}


/***** Acc-Handle-Routine *****/
multi()
{
int event,msgbuff[8],mx,my,ret;

       while (1) {

            event = evnt_multi(16,1,1,1,0,0,0,0,0,0,0,0,0,0,msgbuff,0,0,
                               &mx,&my,&ret,&ret,&ret,&ret);

              if ((event & 16) && (msgbuff[0] == 40) && (msgbuff[4] == id))
                   opn_form();

       }
}


/***** verwaltet Formular *****/
opn_form()
{
int    x,y,w,h;

     form_center (zeiger, &x,&y,&w,&h);
     form_dial (0, x,y,w,h, x,y,w,h);
     form_dial (1, 10,10,20,20, x,y,w,h);
     objc_draw (zeiger,0,1, x,y,w,h);
     index = form_do (zeiger,0);
     state(index) = 32;     /* nur Shadowed */

       react();

     form_dial (2, 10,10,20,20, x,y,w,h);
     form_dial (3, x,y,w,h, x,y,w,h);
}


/***** reagiert auf Benutzer-Wunsch *****/
react()
{
int    ret,handle,i;
long   len;


       pathname[0] = (int) gemdos(0x19)+'A';

       if (index == AGAIN)
              goto dosound;


       if (speicher)
            gemdos(0x49,speicher);      /* Speicher wieder freigeben */

       fsel_input(pathname,filename,&ret); /* Filenamen holen */

       if (!ret)
              return;       /* Cancel */

       gemdos(0x0e,((int) pathname[0])-'A');      /* Laufwerk setzen */
       set_path();   /* setzt Pfadnamen */
       gemdos(0x1a,&dta);

       if(gemdos(0x4e,filename,0)) {
error:        form_alert(1,"[1][Kann Song-File nicht îffnen!][ABBRUCH]");
              return;
       }

       len = ((long) dta.h_len)*65536+dta.l_len;  /* LÑnge berechnen */

       speicher = gemdos(0x48,len);       /* Speicher reservieren */
       if (speicher < 0) {
              form_alert(1,"[1][Zuwenig Speicherplatz!][ABBRUCH]");
              speicher = 0;
              return;
       }

       handle = gemdos(0x3d,filename,0);  /* îffne File */
       if (handle < 0) { /* Fehler beim ôffnen */
              gemdos(0x3e,handle); /* schliessen */
              goto error;
       }

       gemdos(0x3f,handle,0x2al,speicher);
       gemdos(0x3f,handle,len-0x2al,speicher);  /* Daten lesen */

       gemdos(0x3e,handle);        /* File wieder schliessen */

dosound:
       len = gemdos(0x20,0l);
       asm("  and.b  #$fe,$484     ");    /* Key-Click aus */
       gemdos(0x20,len);

       xbios(32,speicher);  /* Musik spielen lassen */

       state(AGAIN) &= 0xf7;
}


/**** setzt Pfadnamen ****/
set_path()
{
  register char pa;
  register int i;

     i = 0;
     while ( *(pathname+i))
          i++;  /* LÑnge */

     while ( *(pathname+i) != 0x5c)
          i--;  /* Bis zum letzten Backslash */

     pa = *(pathname+i);
     *(pathname+i) = 0;

     gemdos(0x3b,pathname);

       *(pathname+i) = pa;
}

