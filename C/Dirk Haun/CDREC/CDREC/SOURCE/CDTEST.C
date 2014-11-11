#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>
#include "cd.h"

#ifndef FALSE
# define FALSE (0)
# define TRUE  (1)
#endif

typedef struct
{
 unsigned metados : 1;
 unsigned driver : 1;
 unsigned open : 1;
 unsigned anz_tracks : 1;
 unsigned trackinfo : 1;
 unsigned read_single : 1;
 unsigned read_multiple : 1;
} CHECKLIST;

#define SEKTOREN 256L

void main(int argc,char *argv[])
{
 int i, errors, drv=-1;
 long d, ret, sektoren;
 char *cp, *buffer;
 CHECKLIST check;
 META_INFO_1 m1;
 META_DRVINFO md;
 struct cdrom_tochdr tn;
 struct cdrom_tocentry te;
 struct cdrom_read rd;

 puts("Testprogramm fÅr MetaDOS-Audio-CD-Kommandos, Dirk Haun 12/1994");
 if(argc>1) sektoren=atol(argv[1]);
 else sektoren=SEKTOREN;
 buffer=malloc(2352L*sektoren);
 if(buffer)
 {
  memset(&check,0,sizeof(CHECKLIST));
  memset(&m1,0,sizeof(META_INFO_1));
  Metainit(&m1);
  if(m1.mi_drivemap)
  {
   check.metados=TRUE;
   printf("%s\n",m1.mi_version_string);
   cp=(char*)m1.mi_info->mi_log2phys;
   for(i=0;i<26;i++)
   {
    printf("%d,",*cp++);
   }
   printf("\n");
   printf("MetaDOS-Laufwerke:\n");
   d=1;
   for(i=0;i<32;i++)
   {
    if(m1.mi_drivemap&d)
    {
     printf("%c: ",(char)(i+'A'));
     memset(&md,0,sizeof(META_DRVINFO));
     printf("[%ld] ",Metaopen(i+'A',&md));
     if(md.mdr_name)
     {
      printf("%s\n",md.mdr_name);
      if(drv<0)
      {
       if(md.mdr_name[0]=='C' && md.mdr_name[1]=='D') drv=i+'A';
       else if(strstr(md.mdr_name," BOS ")) drv=i+'A';  /* extra fÅr FALCON.BOS - funkt aber eh nicht ... */
      }
     }
     else printf("(kein Name)\n");
     Metaclose(i+'A');
    }
    d<<=1;
   }
   if(drv>=0)
   {
    check.driver=TRUE;
    memset(&md,0,sizeof(META_DRVINFO));
    if(Metaopen(drv,&md)==0)
    {
     check.open=TRUE;
     ret=Metaioctl(drv,'FCTL',CDROMREADTOCHDR,&tn);
     printf("erster Track: %d, letzter Track: %d\n",tn.cdth_trk0,tn.cdth_trk1);

     if(tn.cdth_trk0>0 && tn.cdth_trk1>0 && tn.cdth_trk1>tn.cdth_trk0 && ret>=0)
     {
      check.anz_tracks=TRUE;
      errors=0;
      for(i=tn.cdth_trk0;i<=tn.cdth_trk1;i++)
      {
       memset(&te,0,sizeof(struct cdrom_tocentry));
       te.cdte_track=i;
       te.cdte_format=CDROM_MSF;
       ret=Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
       if(ret==0) printf("Track %2d: %2d:%02d.%02d",i,te.dte_addr.msf.minute,te.dte_addr.msf.second,te.dte_addr.msf.frame);
       else
       {
        printf("Track %2d: Returncode %ld",ret);
        errors++;
       }

       memset(&te,0,sizeof(struct cdrom_tocentry));
       te.cdte_track=i;
       te.cdte_format=CDROM_LBA;
       ret=Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
       if(ret==0) printf(" (%ld)\n",te.dte_addr.lba);
       else
       {
        printf(" (Returncode %ld)\n",ret);
        errors++;
       }
       if(errors) break;
      }
      if(errors==0)
      {
       check.trackinfo=TRUE;
       memset(&te,0,sizeof(struct cdrom_tocentry));
       te.cdte_track=CDROM_LEADOUT;
       te.cdte_format=CDROM_MSF;
       Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
       printf("Ende    : %2d:%02d.%02d",te.dte_addr.msf.minute,te.dte_addr.msf.second,te.dte_addr.msf.frame);

       memset(&te,0,sizeof(struct cdrom_tocentry));
       te.cdte_track=CDROM_LEADOUT;
       te.cdte_format=CDROM_LBA;
       Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
       printf(" (%ld)\n",te.dte_addr.lba);

       errors=0;
       for(i=tn.cdth_trk0;i<=tn.cdth_trk1;i++)
       {
        memset(&te,0,sizeof(struct cdrom_tocentry));
        te.cdte_track=i;
        te.cdte_format=CDROM_LBA;
        Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
        memset(&rd,0,sizeof(struct cdrom_read));
        rd.cdread_lba=te.dte_addr.lba+(Random()%500);
        rd.cdread_bufaddr=buffer;
        rd.cdread_buflen=2352L;
        printf("Lese Track %d, Sektor %ld ... ",i,rd.cdread_lba);
        ret=Metaioctl(drv,'FCTL',CDROMREADDA,&rd);
        if(ret==0) puts("ok");
        else
        {
         printf("Returncode %ld\n",ret);
         errors++;
        }
        if(errors) break;
       }
       if(errors==0)
       {
        check.read_single=TRUE;

        errors=0;
        for(i=tn.cdth_trk0;i<=tn.cdth_trk1;i++)
        {
         memset(&te,0,sizeof(struct cdrom_tocentry));
         te.cdte_track=i;
         te.cdte_format=CDROM_LBA;
         Metaioctl(drv,'FCTL',CDROMREADTOCENTRY,&te);
         memset(&rd,0,sizeof(struct cdrom_read));
         rd.cdread_lba=te.dte_addr.lba;
         rd.cdread_bufaddr=buffer;
         rd.cdread_buflen=2352L*sektoren;
         printf("Lese Track %d, Sektoren %ld-%ld ... ",i,rd.cdread_lba,rd.cdread_lba+sektoren-1);
         ret=Metaioctl(drv,'FCTL',CDROMREADDA,&rd);
         if(ret==0) puts("ok");
         else
         {
          printf("Returncode %ld\n",ret);
          errors++;
         }
         if(errors) break;
        }
        if(errors==0) check.read_multiple=TRUE;
       }
      }
     }
     Metaclose(drv);
    }
    else puts("Can\'t open CD-ROM.");
   }
   else puts("Kein CD-ROM-Treiber gefunden.");
  }
  else puts("Kein MetaDOS installiert.");

  puts("\nDiagnose:");
  if(!check.metados) puts("MetaDOS nicht installiert.");
  else
  {
   if(!check.driver) puts("Kein CD-ROM-Treiber gefunden.");
   else
   {
    if(!check.open) puts("Konnte kein MetaDOS-Laufwerk îffnen.");
    else
    {
     if(!check.anz_tracks)
     {
      puts("Konnte Anzahl Titel der CD nicht ermitteln.");
      puts("--> Treiber unterstÅtzt offenbar keine Audio-Kommandos.");
     }
     else
     {
      if(!check.trackinfo)
      {
       puts("Konnte Informationen der Titel nicht ermitteln.");
       puts("--> Treiber unterstÅtzt offenbar keine Audio-Kommandos.");
      }
      else
      {
       if(!check.read_single)
       {
        puts("Lesen der Audio-Daten fehlgeschlagen.");
        puts("--> Treiber oder Laufwerk unterstÅtzt Lesen von Audio-Daten nicht.");
       }
       else
       {
        if(!check.read_multiple)
        {
         puts("Fehler beim Lesen groûer Audio-Datenblîcke.");
         puts("--> Das ist leider ein Fehler im Treiber.");
        }
        else
        {
         puts("Treiber und Laufwerk unterstÅtzen Kommandos zum Abspielen");
         puts("und Lesen von Audio-Daten.");
        }
       }
      }
     }
    }
   }
  }

  free(buffer);
 }
 else
 {
  printf("Sorry, brauche ca. %ld KByte Speicher.\n",(sektoren*2352L)/1024L);
  printf("Versuchen Sie \'cdtest %ld\'.\n",sektoren/2);
 }
 printf("Taste ... ");
 Crawcin();
}
