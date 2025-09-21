/************************************************************************/
/*   GEM Deklarationen                                                  */
/************************************************************************/
#define NORMAL      0x0
#define SELECTED    0x1
#define SHADOWED    0x20

extern long    xbios();
#define Dosound(a)  xbios(32,a)

#define   format(a,b,c,d,e,f,g,h,i)     xbios(0x0a,a,b,c,d,e,f,g,h,i)
#define   writes(a,b,c)                 xbios(0x09,a,0l,0,c,b,0,1)
#define   makeboot(a)       xbios(0x12,a,0x01111111l,2 + (s1 ? 1 : 0),0)

#define   state(x)       *(zeiger + (x * 12) + 5)

#define TRUE 1
#define FALSE 0

/************************************************************************/
/*   Included Files ~ Nachzuladende Routinen                            */
/************************************************************************/
#include "gemdefs.h"
#include "mud.inc"

int  phys_handle;
#include "_work.inc"

int  hidden;
#include "mouse.inc"

/************************************************************************/
/*   Titelindex und Eintragsindex                                       */
/************************************************************************/
#define TREE1 0

#define   spt9      13
#define   spt10     14

#define   sf354     17
#define   sf314     18

#define   tracks79  8
#define   tracks80  9
#define   tracks81  10
#define   tracks82  11

#define   QUIT 5
#define   START 4

/************************************************************************/
/*   Globale Deklarationen                                              */
/************************************************************************/
int      *menuaddr;                     /* Adresse des MenÅbaumes */
int       hhchar,hwchar,hhbox,hwbox;
int       xdesk,ydesk,wdesk,hdesk;
int       xwork,ywork,wwork,hwork;

int       *zeiger;
short int       index,x1,y1,w1,h1;

int       xk,yk,radius = 85,x2k;

int       sides,spt;

char      c,*sbuff,track,tracks;
int       count,sector,tr,se;
long      buffn[2048],ser_number,s1,*buff;

/************************************************************************/
/*   Hauptverwaltungs- und Initialisierungsroutine                      */
/************************************************************************/
main()
{
int       ergebnis;           
char      *resource = "format.rsc";

     appl_init();
     phys_handle = graf_handle (&hhchar,&hwchar,&hhbox,&hwbox);
     open_work();

     rsrc_load (resource);

     graf_mouse (ARROW, 0x0L);          /* Pfeil als Maus */
     hidden = FALSE;

     rsrc_gaddr(1,TREE1,&zeiger);       /* holt Startadresse */

     set_select(spt10);                 /* setzt 10 SpT invers */
     set_select(sf314);                 /* setzt SF314 invers */
     set_select(tracks82);              /* setzt 82 Tracks invers */

   while (TRUE) {
     hide_mouse();                      /* Maus verstecken */
     formular();                        /* gibt Formular aus */
     circle();                          /* zeichnet den leeren Kreis */
     show_mouse();                      /* Maus wieder zulassen */

     edit();                            /* wartet das Formular */     
     if (index == QUIT) break;

     test_select();                     /* testet auf SELECTED & setzt */
                                        /* tracks, sides               */
     format_disk();                     /* formatiert diskette   */
     objc_change(zeiger,index,0,x1,y1,w1,h1,NORMAL,1);
   }

     schliess();                       /* schliesst Formular */
     close_work();
}

/************************************************************************/
/*   Subroutine zum ausgeben eines nicht-editierbaren formulares        */
/************************************************************************/ 
formular()
{

     form_center (zeiger, &x1,&y1,&w1,&h1);

     form_dial (0, x1,y1,w1,h1, x1,y1,w1,h1);
     form_dial (1, 10,10,20,20, x1,y1,w1,h1);
     objc_draw (zeiger,0,2, x1,y1,w1,h1);
     music();
     xk = x1+95;   x2k = xk+(radius*2)+4;
     yk = y1+160;

}

/************************************************************************/
/*   wartet das Formular                                                */
/************************************************************************/
edit()
{

     index=form_do (zeiger,0);
}

/************************************************************************/
/*   Schliesst Formular                                                 */
/************************************************************************/
schliess()
{

     form_dial (2, 10,10,20,20, x1,y1,w1,h1);
     form_dial (3, x1,y1,w1,h1, x1,y1,w1,h1);
}

/***********************************************************************/
/*   Musik spielen                                                     */
/***********************************************************************/
music()
{
  static char sound[]={0,200,1,0,7,254,11,255,12,110,13,9,8,16,255,0};
     Dosound(sound);
}

/********************** Setzt FÅllattribute ****************************/
set_attr()
{
     vsf_color(handle,1);
     vsf_interior(handle,1);
     vsf_perimeter(handle,0);
     vswr_mode(handle,1);
}

/***********************************************************************/
/*   gibt Kreis aus                                                    */
/***********************************************************************/
circle()
{
  int pxyarray[4],x;

     pxyarray[0] = xk + radius;
     pxyarray[1] = yk;
     pxyarray[2] = xk;
     pxyarray[3] = yk;

     vsl_color(handle,1);
     vsl_type(handle,1);
     vswr_mode(handle,1);
     vsl_width(handle,1);
     vsl_ends(handle,0,0);

     v_arc(handle,xk,yk,radius,0,3600);

     pxyarray[0] = x2k + radius;
     pxyarray[2] = x2k;

     v_arc(handle,x2k,yk,radius,0,3600);

     vsf_color(handle,1);
     vsf_interior(handle,0);
     vsf_perimeter(handle,1);

     for (x=0; x < 3600; x=x+86) {      /* 86 = Abstand */
          v_pieslice(handle,xk,yk,radius,x,x+86);
          v_pieslice(handle,x2k,yk,radius,x,x+86);
     } 
}

/*******************     setzt Select von 1 Button     ******************/
set_select(index)
  int  index;
{
  /* objc_change(zeiger,index,0,x1,y1,w1,h1,SELECTED | SHADOWED,1); */
     state(index) = (SELECTED | SHADOWED);
}

/************************************************************************/
/*        Testet auf SELECTED                                           */
/************************************************************************/
test_select()
{
     if ((state(spt9) & SELECTED) == SELECTED)
               spt = 9;
          else spt = 10;

     if ((state(sf314) & SELECTED) == SELECTED)
               sides = 1;
          else sides = 0;


tracks=1;

          if ((state(tracks79) & SELECTED) == SELECTED)
               tracks = 80;   /* 790 */

          if ((state(tracks80) & SELECTED) == SELECTED)
               tracks = 81;   /* 800 */

          if ((state(tracks81) & SELECTED) == SELECTED)
               tracks = 82;   /* 810 */

          if ((state(tracks82) & SELECTED) == SELECTED)
               tracks = 83;   /* 820 */
}

/************************************************************************/
/*   Formatiert eine ganze Diskette                                     */
/************************************************************************/
format_disk()
{
  int bttn,blk;

     blk = tracks * spt;
     buff = buffn;
     sbuff = buff;
        
     s1 = sides;
     bttn = form_alert(1,"[1][Insert the Diskette,|then press RETURN|Note: All Data will be|erased !][ OK | Cancel ]");
     if (bttn == 1) {
          if (!write_disk(buff,s1)) {
               for(count = 0; count < 512; *(sbuff + count++) = 0);
               makeboot(buff);
               *(sbuff + 0x13) = (blk + (s1 ? blk : 0)) & 0xff;
               *(sbuff + 0x14) = ((blk + (s1 ? blk : 0)) >> 8) & 0xff;
               *(sbuff + 0x18) = spt;
               tr = 0;   se = 1;
               writes(buff,tr,se);
               for(count = 0; count < 512; *(sbuff + count++) = 0);
               *(sbuff) = 0xf7;
               *(sbuff + 1) = 0xff;
               *(sbuff + 2) = *(sbuff + 1);
               tr = 0;   se = 7;
               writes(buff,tr,se);
               tr = 0;   se = 2;
               writes(buff,tr,se);
               for(count = 0; count < 512; *(sbuff + count++) = 0);
               tr = 1;   se = 3;
               writes(buff,tr,se);
          }
          else form_alert(1,"[1][Error found while|formatting Diskette!|Check it or use|another one!][ OK ]");
     }             
}    

/************************************************************************/
/*   Formatiert alle tracks                                             */
/************************************************************************/
write_disk(puffer,s)       /* formatiert tracks */
  long *puffer,s;
{  
  int  winkel,abstand = 86;

     set_attr();              /* setzt PIE-Attribute */

     for(track = 0,winkel = 0; track < tracks; track++,winkel=(winkel+abstand)) {

          if(0 == format(puffer,0l,0,10,track,0,1,0x87654321,0l) &&
           (s ? 0 == format(puffer,0l,0,10,track,1,1,0x87654321,0l) : 1)) {

               if ((winkel+abstand) <= 3612) { /* 3612=42tracks*abstand */
                    hide_mouse();
                    v_pieslice(handle,xk,yk,radius,winkel,winkel+abstand);
                    show_mouse();
                    }
               else {
                    hide_mouse();
                    v_pieslice(handle,x2k,yk,radius,winkel-3612,winkel+abstand-3600);
                    show_mouse();
                    }
          }

          else return(2);
     }
     return(0);
}

