/****************************\
* GEM-WindowDump             *
* Autor: Gabriel Schmidt     *
* (c)1992 by MAXON-Computer  *
* L„uft als PRG und als ACC  *
\****************************/

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <errno.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "bitmfile.h"

/* --- Konstanten, Typen, Variablen ---------- */

#define ACC_NAME     "  GEM-WindowDump"
#define MONO_ALERT   \
   "[2][Diese Graphik|ist monochrom.|"\
   "Welches Format soll|erzeugt werden?]"\
   "[XIMG|IMG]"
#define FILE_ALERT   \
   "[3][Datei konnte nicht|"\
   "geschrieben werden!][Abbruch]"
#define MEMORY_ALERT \
   "[3][Der Speicher ist voll!][Abbruch]"

/* Applikationsflag */
extern int _app;

/* AES- und VDI-Infos */
int work_in[11], work_out[57], ext_work_out[57];
int gl_wchar, gl_hchar, gl_wbox, gl_hbox;
int phys_handle, handle;
int appl_id;

#define VDI_RESX (work_out[0]+1)
#define VDI_RESY (work_out[1]+1)
#define VDI_RESC (work_out[13])
#define VDI_PIXW (work_out[3])
#define VDI_PIXH (work_out[4])
#define VDI_PLANES (ext_work_out[4])
#define VDI_LOOKUP (ext_work_out[5])
#define SCREENSIZE(sx,sy,sp) \
   ((long) ((sx+15)/16)*2*sy*sp)

int wind_x, wind_y, wind_w, wind_h;

/* Pfade fr Dateiauswahl */
char fsel_path[128], fsel_file[13];
char filename[128];

/* Dummy-Variable */
static int idum;

/* --- Hauptprogramm ------------------------- */

void get_vdi_color(unsigned int colind,
   struct RGB *rgb)
{
   vq_color(handle,colind,0,(int *) rgb);
}

void get_vdi_pixel(int x, int y,
   unsigned int *colind)
{
   v_get_pixel(handle,wind_x+x,wind_y+y,
      &idum,(int *) colind);
}

void do_windowdump(void)
{
   int error, mx, my, bstate, wind_handle;
   int koord[8];
   MFDB screen, wind_dmp;
   char *strpos;
   int fsel_but;
   FILE_TYP typ;

   wind_update(BEG_UPDATE);
   graf_mouse(THIN_CROSS,NULL);
   wind_update(BEG_MCTRL);
   /* Bitte ein Window anklicken! */
   evnt_button(256|1,3,0,&mx,&my,&bstate,&idum);
   evnt_button(1,bstate,0,
      &idum,&idum,&idum,&idum);
   wind_update(END_MCTRL);
   /* Rechte Maustaste nicht gedrckt? */
   if ((bstate&2)==0)
   {
      graf_mouse(BUSYBEE,NULL);
      /* Welches Window wurde ausgew„hlt? */
      wind_handle=wind_find(mx,my);
      /* Abfrage der Gr”že:             */
      /* WF_CURRXYWH = gesamtes Window  */
      /* WF_WORKXYWH = nur Windowinhalt */
      wind_get(wind_handle,WF_CURRXYWH,
         &wind_x,&wind_y,&wind_w,&wind_h);
      if (wind_x+wind_w>VDI_RESX)
         wind_w=VDI_RESX-wind_x;
      if (wind_y+wind_h>VDI_RESY)
         wind_h=VDI_RESY-wind_y;
      if (wind_w<=0 || wind_h<=0)
      /* Kann auftreten bei WF_WORKXYWH */
      {
         wind_update(END_UPDATE);
         graf_mouse(ARROW,NULL);
         return;
      }

      /* Bildschirmausschnitt retten */
      screen.fd_addr=NULL;
      wind_dmp.fd_addr=malloc(
         SCREENSIZE(wind_w,wind_h,VDI_PLANES));
      if (wind_dmp.fd_addr==NULL)
      {
         wind_update(END_UPDATE);
         graf_mouse(ARROW,NULL);
         form_alert(1,MEMORY_ALERT);
         return;
      }
      wind_dmp.fd_w=wind_w;
      wind_dmp.fd_h=wind_h;
      wind_dmp.fd_wdwidth=(wind_w+15)/16;
      wind_dmp.fd_stand=0;
      wind_dmp.fd_nplanes=VDI_PLANES;
      koord[0]=wind_x; koord[1]=wind_y;
      koord[2]=wind_x+wind_w-1;
      koord[3]=wind_y+wind_h-1;
      koord[4]=koord[5]=0;
      koord[6]=wind_w-1;
      koord[7]=wind_h-1;
      graf_mouse(M_OFF,NULL);
      vro_cpyfm(handle,S_ONLY,koord,
         &screen,&wind_dmp);
      /* Format & Namen vom Benutzer erfragen */
      graf_mouse(M_ON,NULL);
      typ=XIMG;
      if (VDI_PLANES==1 &&
            form_alert(1,MONO_ALERT)==2)
         typ=IMG;
      if (!fsel_input(fsel_path,fsel_file,
            &fsel_but) || !fsel_but)
      {
         free(wind_dmp.fd_addr);
         wind_update(END_UPDATE);
         graf_mouse(ARROW,NULL);
         return;
      }
      /* Bildschirmausschnitt restaurieren */
      koord[4]=wind_x; koord[5]=wind_y;
      koord[6]=wind_x+wind_w-1;
      koord[7]=wind_y+wind_h-1;
      koord[0]=koord[1]=0;
      koord[2]=wind_w-1;
      koord[3]=wind_h-1;
      graf_mouse(M_OFF,NULL);
      vro_cpyfm(handle,S_ONLY,koord,
         &wind_dmp,&screen);
      graf_mouse(M_ON,NULL);
      free(wind_dmp.fd_addr);
      /* Filenamen "berechnen" */
      strcpy(filename,fsel_path);
      strpos=strrchr(filename,'\\');
      if (strpos==NULL)
         strpos=strrchr(filename,':');
      if (strpos==NULL)
         strpos=filename;
      else
         strpos++;
      strcpy(strpos,fsel_file);

      /* Windowdump ausfhren */
      graf_mouse(M_OFF,NULL);
      error=bitmap_to_file(typ,wind_w,wind_h,
         VDI_PIXW,VDI_PIXH,VDI_PLANES,VDI_RESC,
         filename,get_vdi_color,get_vdi_pixel);
      if (error!=0)
      {
         switch (error)
         {
            case ENOMEM:
               form_alert(1,MEMORY_ALERT);
               break;
            default:
               form_alert(1,FILE_ALERT);
         }
      }
      graf_mouse(M_ON,NULL);
   }
   wind_update(END_UPDATE);
   graf_mouse(ARROW,NULL);
}

int main(void)
{
   int appl_id, menu_id, i, msgbuf[8];

   /* Applikation beim AES anmelden */
   appl_id=appl_init();
   if (appl_id!=-1)
   {
      /* Workstation beim VDI anmelden */
      for (i=0; i < 10; i++)
         work_in[i] =1;
      work_in[10]=2;
      phys_handle=graf_handle(&gl_wchar,&gl_hchar,
         &gl_wbox,&gl_hbox);
      handle=phys_handle;
      v_opnvwk(work_in, &handle, work_out);
      if (handle!=0)
      {
         vq_extnd(handle,1,ext_work_out);
         /* Defaultpfade fr Fileselectbox best. */
         strcpy(fsel_path,"A:");
         fsel_path[0]='A'+Dgetdrv();
         if (Dgetpath(filename,0)==0)
            strcat(fsel_path,filename);
         strcat(fsel_path,"\\*.");
         strcat(fsel_path,get_file_ext(XIMG));
         strcpy(fsel_file,"GEMWD   .");
         strcat(fsel_file,get_file_ext(XIMG));
         /* L„uft GEMWD als... */
         if (_app)
            /* ...Programm? */
            do_windowdump();
         else
         {
            /* ...Accessory? */
            menu_id=menu_register(appl_id,ACC_NAME);
            while (1)
            {
               evnt_mesag(msgbuf);
               if (msgbuf[0]==AC_OPEN &&
                     msgbuf[4]==menu_id)
                  do_windowdump();
            }
         }
         /* Workstation schliežen */
         v_clsvwk(handle);
      }
      /* Applikation abmelden */
      appl_exit();
   }
   return(0);
}

