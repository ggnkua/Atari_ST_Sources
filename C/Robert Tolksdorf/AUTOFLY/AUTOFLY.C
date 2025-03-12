/* AUTOFLY.C
*
*  "Flying dialogs" in JEDEM GEM-Programm
*
*  by Robert Tolksdorf
*  (c) 1991 MAXON Computer
*
*  Datum    Version  feat.
*  18.11.90 0.0      Neue form_do- und form_dial-Routinen
*                 zum Fliegen
*  26.11.90 0.9      GEM- und BIOS-Einbindung, AUTO-Start mîglich
*  28.01.91 1.0      -  Sicherer gegenÅber anderen #2-Programmen,
*  08.02.91          insbesondere LGSELECT von Charles F. Johnson
*                 -  Bessere Standardbeachtung (Prozessortyp, Cookie)
*                 -  Sicherer gegenÅber Fehlersituationen
*                 -  Kommentare fÅr Verîffentlichung
*
*/

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <linea.h>

extern int  vq_aes(void);
extern void my_gem_handler();
extern void my_bios_handler();
extern void my_gemdos_handler();
extern void my_exec_os();
extern void first_restore();
extern void normal_restore();
extern void (*XB_VEC2)();
extern void (*XB_VEC13)();
extern void (*XB_VEC1)();
extern void (*XB_VECEX)();
extern void (*aes_save)();
extern void (*restore_vec)();

#define NULL        ( ( void * ) 0L )

/* Der Puffer-MFDB */
MFDB  buffer;

/* Zur Kommunikation mit dem Trap-Handler */
int      callcount   =-1,
      firstformdo = 1;
      
/* Ein MFDB fuer den Bildschirm */
MFDB  screen = {NULL};

/* Beschreibt einen noch nicht gesaeuberten Bildschirmbereich */
int      restore[8];
int      restorevalid=0;

/* Ein paar Variablen, die von allen Routinen benutzt werden. Zum
   Sparen von Stackplatz global deklariert. */
int      workout[57];
int      p[8];
int      handle;

int my_fm_do(OBJECT *tree, int start_fld)
{
   int      edit_obj, next_obj, obj, which,
            cont, idx, theflag,
            mx, my, mb, ks, kr, br,
            sx, sy, smx, smy,
            fw, fh,
            nx, ny, xoff, yoff, dxoff, dyoff;
   int      h[8], v[8] ;

   /*    alles andere stoppen */
    wind_update(BEG_UPDATE);
    wind_update(BEG_MCTRL);
    /* aktuelles VDI-Handle und Cell-Hoehe ermitteln */
    handle=graf_handle(&nx,&nx,&nx,&sy); /* eine Cell fuer Menueleiste */
    /*   VDI-Screen Ausmasse zum Begrenzen des Fliegens ermitteln */
   vq_extnd(handle,0,&workout);
   sx=0;
   smx=workout[0];
   smy=workout[1];
    /*   Ausmasse des Forms ermitteln und in p[0]..p[3] ablegen */
    nx=tree[ROOT].ob_x  ;  /* alte Lage merken */
    ny=tree[ROOT].ob_y;
   /* Ausmasse des Forms ermitteln */
    form_center(tree, &v[0], &v[1], &fw, &fh);
    /*   ZusÑtzlicher Platzbedarf ist v[0/1]-tree[ROOT].x/y 
      p[0],p[1]=urspruengliches X,Y des Forms plus Offsets */
    p[0]=nx+(v[0]-tree[ROOT].ob_x);
    p[1]=ny+(v[1]-tree[ROOT].ob_y);
    /* Andere Ecke der Form-Flaeche errechnen */
    p[2]=p[0]+fw-1;
    p[3]=p[1]+fh-1;
    tree[ROOT].ob_x=nx; /* alte Lage wiederherstellen */
    tree[ROOT].ob_y=ny;
   /* Erstes  Edit-Feld suchen, falls gewuenscht */
   if (start_fld == 0)
   {
      obj = 1;
      while ( obj >= 0 )
      {
         if ((theflag = tree[obj].ob_flags) & EDITABLE)
         {
            next_obj=obj;
            obj=-1;
         }
         else
         {
            if (theflag & LASTOB)   /* schreckliche */
            {                 /* Schleife!   */
               next_obj=0;
               obj=-1;
            }
            else
               obj++;
         }
      }
   }
    else
      next_obj = start_fld;
   edit_obj = 0;
   /* los geht's */
   cont = 1;
    while(cont)
    {
      /* Cursor auf Edit-Feld, wenn vorhanden */
      if ((next_obj != 0) && (edit_obj != next_obj))
      {
        edit_obj = next_obj;
        next_obj = 0;
        objc_edit(tree, edit_obj, 0, &idx, ED_INIT);
      }
      /* Auf Maus- oder Tastaturereignis warten */
      which = evnt_multi(MU_KEYBD | MU_BUTTON, 
                    0x02, 0x01, 0x01, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0x0L, 0, 0,
                    &mx, &my, &mb, &ks, &kr, &br);
      /* Taste gedrueckt -> EDIT-Feld oder DEFAULT */
      if (which & MU_KEYBD)
      {
        cont = form_keybd(tree, edit_obj, next_obj, kr, &next_obj, &kr);
        if (kr)
          objc_edit(tree, edit_obj, kr, &idx, ED_CHAR);
      }
      /* Button gedrueckt */
      if (which & MU_BUTTON)
      {
         /* Auf welchem Object ? Wenn ausserhalb von Form -> BEEEEP ! */
        if ((next_obj = objc_find(tree, ROOT, MAX_DEPTH, mx, my))
                 == -1) /* NIL */
        {
        Cconout('\a');
          next_obj = 0;
        }
        else
          /*   Jetzt kommt's: Wenn auf das ROOT-Object geklickt wurde
               und form_dial vorher den Schirm gepuffert hat -> Fly  */
        if (tree[next_obj].ob_flags == NONE)
          {
            /* jegliches Clipping aus */
         vs_clip(handle,0,&p);
         /* Hand zum verschieben */
         graf_mouse(FLAT_HAND,0);
         /* Mausposition ermitteln */
            graf_mkstate(&mx,&my,&nx,&nx);
            /* noch nichts verschoben */
            dxoff=dyoff=0;
            /* solange geflogen wird ... */
            do
            {
               /* warten auf Mausbewegung oder Knopf-Loslassen */
               which= evnt_multi(MU_BUTTON | MU_M1,
                     0x01,0x01,0x00,
                     1, mx, my, 1, 1,
                     0, 0, 0, 0,
                     0, 0,
                     0, 0,
                     &nx, &ny, &mb, &ks, &kr, &br);
               /* Wenn nicht losgelassen, wurde bewegt */
               if (!(which & MU_BUTTON))
               {
                  /* Verschiebungen errechnen und gegen AES-Screen-Grenzen sichern */
                  xoff=nx-mx;
                  if (p[0]+xoff<sx)
                     xoff=sx-p[0];
                  if (p[2]+xoff>smx)
                     xoff=smx-p[2];
                  yoff=ny-my;
                  if (p[1]+yoff<sy)
                     yoff=sy-p[1];
                  if (p[3]+yoff>smy)
                     yoff=smy-p[3];
                  /* Neuen Bereich fuer's Form errechnen
                     (p[0]..p[3] enthalten aktuellen Bereich) */
                  p[4]=p[0]+xoff;
                  p[5]=p[1]+yoff;
                  p[6]=p[4]+fw-1;
                  p[7]=p[5]+fh-1;
                  /* zu restauriernden Bereich
                     links oder rechts errechnen */
                  if (xoff<0) /* rechts */
                  {
                     h[0]=h[4]=p[2]+xoff+1;
                     h[1]=h[5]=p[1];
                     h[2]=h[6]=p[2];
                     h[3]=h[7]=p[3];
                  }
                  if (xoff>0) /* links */
                  {
                     h[0]=h[4]=p[0];
                     h[1]=h[5]=p[1];
                     h[2]=h[6]=p[0]+xoff-1;
                     h[3]=h[7]=p[3];
                  }
                  /* zu restauriernden Bereich
                     oben oder unten errechnen */
                  if (yoff<0) /* unten */
                  {
                     v[0]=v[4]=p[0];
                     v[1]=v[5]=p[3];
                     v[2]=v[6]=p[2];
                     v[3]=v[7]=p[3]+yoff+1;
                  }
                  if (yoff>0) /* oben */
                  {
                     v[0]=v[4]=p[0];
                     v[1]=v[5]=p[1];
                     v[2]=v[6]=p[2];
                     v[3]=v[7]=p[1]+yoff-1;
                  }
                  /* jetzt verschieben */
                  graf_mouse(M_OFF, 0);
                  /* Form kopieren */
                  vro_cpyfm(handle,S_ONLY,&p,&screen,&screen);
                  /* links/rechts restaurieren */
                  if (xoff!=0)
                     vro_cpyfm(handle,S_ONLY,&h,&buffer,&screen);
                  /* oben/unten restaurieren */
                  if (yoff!=0)
                     vro_cpyfm(handle,S_ONLY,&v,&buffer,&screen);
                  graf_mouse(M_ON, 0);
                  /* Neue Form-Lage vermerken */
                  p[0]+=xoff;
                  p[1]+=yoff;
                  p[2]+=xoff;
                  p[3]+=yoff;
                  /* Verschiebung merken */
                  dxoff+=xoff;
                  dyoff+=yoff;
                  /* Neue Mausposition vermerken */
                  mx=nx;
                  my=ny;
               }
            } while (!(which & MU_BUTTON));
            /* und wieder der Pfeil */
            graf_mouse(ARROW, 0);
            /* Neue Objektlage vermerken */
            tree[ROOT].ob_x+=dxoff;
            tree[ROOT].ob_y+=dyoff;
            next_obj=0;
           }
          else
            /* Auf anderes Objekt geklickt */
            cont = form_button(tree, next_obj, br, &next_obj);
      }
      /* Edit-Feld abschliessend saeubern */
      if ((!cont) || ((next_obj != 0) && (next_obj != edit_obj)))
         objc_edit(tree, edit_obj, 0, &idx, ED_END);
    }
    /* Die anderen duerfen wieder */
    wind_update(END_MCTRL);
    wind_update(END_UPDATE);
    /*   Den zuletzt vom Form belegten Bereich fuer ein spaeteres
      form_dial(FMD_FINISH) merken, damit dann einfach kopiert
      werden kann */
    restore[0]=restore[4]=p[0];
    restore[1]=restore[5]=p[1];
    restore[2]=restore[6]=p[2];
    restore[3]=restore[7]=p[3];
    restorevalid=1;
    /* Exit-Objekt als Ergebnis */
    return(next_obj);
}

int my_fm_dial(int flag)
{
   /* Handle ermitteln */
   handle=graf_handle(&p[0],&p[0],&p[0],&p[0]);
   /* Maus aus */
   graf_mouse(M_OFF, 0);
      /* jegliches Clipping aus */
   vs_clip(handle,0,&p);
   if (flag==FMD_START)
   {
      /* VDI-Screen-Groesse ermitteln */
      vq_extnd(handle,0,&workout);
      p[0]=p[4]=p[1]=p[5]=restorevalid=0;
      p[2]=p[6]=workout[0];
      p[3]=p[7]=workout[1];
      vro_cpyfm(handle,S_ONLY,&p,&screen,&buffer);
      callcount++;
      firstformdo=1;
   }
   else /* FMD_FINISH */
   {
      /* Bereich kopieren und kein Redraw mehr! */
      vro_cpyfm(handle,S_ONLY,&restore,&buffer,&screen);
   }
   /* Maus an */
   graf_mouse(M_ON, 0);
   /* Klappt immer */
   return(1);
}

#define AFlyId    0x52544146L /* RTAF     */
#define AFlyVal      0x00010000L /* Vers 1.0 */

typedef struct{
   long  id,   val;
} COOKIE;

SYSHDR   *rom_start;
long  stackcorr;
long  super_stack;
int      geminstalled = 0;

/* Cookie-Jar einrichten, Zeiger auf ersten Cookie abliefern */
COOKIE *install_cookie_jar(long n)
{
   COOKIE   *cookie;
   
   cookie=Malloc(sizeof(COOKIE)*n);
   Super(0L);
   *(long *)0x5A0L=cookie;
   Super((void *) super_stack);
   cookie->id=0L;
   cookie->val=n;
   return (cookie);
}

main()
{
   COOKIE   *cookie, *cookieo;
   int      ncookie = 0;
   long  jarsize;
   int      xpixels, ypixels, planes;
   char  *l1      =  "\r\n\x1Bp        AUTOFLY V1.0        \x1Bq\r\n" \
                  "(C) 1990 by Robert Tolksdorf\r\n" \
                  "Public Domain -- No warranty\r\n\n";
   char  *l2      =  "Already ";
   char  *l3      =  "Installed\r\n\n" \
                  "Why is a raven like a writing-desk?\r\n\n";
   
   /* 1. Mitteilung raus */
   Cconws(l1);
   /* Systemvariablen lesen */
   super_stack=Super(0L);
   cookie=cookieo= *(long *)0x5A0L;
   rom_start= *(long *)0x4F2L;
   stackcorr = (*(int *)0x59EL) ? 8 : 6 ;
   Super((void *) super_stack);
   /* Kein Cookie-Jar vorhanden -> neuen einrichten */
   if (!cookie)
   {
      cookie=install_cookie_jar(8L);
      ncookie=0;
   }
   else
      /* sonst durchsuchen */
      for (;((cookie->id) && (cookie->id!=AFlyId));cookie++, ncookie++);
   /* cookie zeigt auf AFly-Cookie oder Null-Cookie */
   if (!cookie->id)  /* AUTOFLY noch nicht installiert */
   {
      /* Ist noch Platz ?? (nur, wenn Jar schon eingerichtet!) */
      if (cookie->val<=ncookie)
      {
         /* nein -> neuen einrichten, alten kopieren */
         cookie=install_cookie_jar(cookie->val+8L);
         for (;cookieo->id!=0L; (*cookie++)=(*cookieo++));
         cookie->id=0L;
         cookie->val=cookieo->val+8L;
      }
      /* Cookie hinterlassen */
      jarsize=cookie->val; /* Groesse des Cookie-Jars merken */
      cookie->id=AFlyId;
      cookie++->val=AFlyVal;
      cookie->id=0L;
      cookie->val=jarsize;
      
      /* Start des ROM vermerken */
      rom_start=rom_start->os_base;
      /* TRAP #13-Vektor auf unseren Trap-Handler setzen
         und alten Vektor XBRA-maessig merken */
      XB_VEC13=Setexc(45,my_bios_handler);
      /* TRAP #1-Vektor auf unseren Trap-Handler setzen
         und alten Vektor XBRA-maessig merken */
      XB_VEC1=Setexc(33,my_gemdos_handler);
      /* Ist AES schon installiert ?? */
      if (!vq_aes())
      {
         /* Handle ermitteln (workout[0] als Dummy-int) */
         handle=graf_handle(&workout[0],&workout[0],&workout[0],&workout[0]);
         /* Bildschirmausmasse erfragen */
         vq_extnd(handle,0,&workout);
         xpixels=workout[0]+1;
         ypixels=workout[1]+1;
         /* Anzahl der Planes ermitteln */
         vq_extnd(handle,1,&workout);
         planes=workout[4];
         /* TRAP #2-Vektor auf unseren Trap-Handler setzen
            und alten Vektor XBRA-maessig merken */
         XB_VEC2=Setexc(34,my_gem_handler);
         aes_save=my_gem_handler;
         restore_vec=normal_restore;
      }
      else
      {
         linea_init();
         planes=Linea->v_planes;
         xpixels=Vdiesc->v_rez_hz;
         ypixels=Vdiesc->v_rez_vt;
         restore_vec=first_restore;
         /* in exec_os einhaengen */
         super_stack=Super(0L);
         XB_VECEX= *(long *)0x4FEL;
         *(long *)0x4FEL=my_exec_os;
         Super((void *) super_stack);
      }
      buffer.fd_wdwidth=(xpixels+16)/16;
      /* Worte mal Zeilen mal Planes als Puffer reservieren */
      buffer.fd_addr=Malloc((long)buffer.fd_wdwidth*2*
                        (long)ypixels*(long)planes);
      /* Puffer.MFDB einrichten */
      buffer.fd_w=xpixels;
      buffer.fd_h=ypixels;
      buffer.fd_stand=1;
      buffer.fd_nplanes=planes;
      /* "Installiert"-Meldung */
      Cconws(l3);
      /* Und resident im Speicher bleiben */
      Ptermres(_PgmSize,0);
   }
   else
   {
      /* "Already Installed" melden */
      Cconws(l2);
      Cconws(l3);
      /* Mit Fehlercode enden */
      return(1);
   }
}


