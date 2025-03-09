/****************************************************/
/*                                                  */
/*     HARDDISK - INFORMATION  TOS-Version 2.0      */
/*                                                  */
/* Programm zum Ausgeben von Informationen Åber die */
/* Belegung von Festplatten 												*/
/****************************************************/
/*          Geschrieben in Megamax C von            */
/*                                                  */
/*                Ulrich Meumann                    */
/*                Lehnerweg 2, 7900 Ulm             */
/*                Tel. 0731/382100                  */
/****************************************************/
/*					(c) 1992 MAXON Computer GmbH						*/
/****************************************************/

#include <osbind.h>

#define ON  -1
#define OFF 0

#define READ 0x08                            /* Controller: Von Platte lesen */ 

#define LANG   400                          
#define KURZ   10

struct partition {                           /* Partition-Info im Bootblock */
                     char  p_flag;           /* Flag, <>0, wenn Part. gÅltig */
                     char  p_id1;            /* Drei ID-Bytes */
                     char  p_id2;
                     char  p_id3;
                     long  p_start;          /* Startsektor der Partition */
                     long  p_size;           /* LÑnge in Sektoren */
};

struct bootblock {
                     char  nutzlos[0x1c0];   /* Je nach Autobooter versch. */
                     char  hi_spt;           /* Sektoren pro Spur (SH205: 17)*/
                     long  hd_size;          /* LÑnge der Platte in Sektoren */
                     struct partition p_table[4];  /* Vier Partition-EintrÑge*/
                     long  bsl_start;        /* Anfang der defekten Sektoren */
                     long  bsl_count;        /* Anzahl der defekten Sektoren */
                     int   checksum;         /* Checksumme fÅr den Autoboot */
};

char puffer[512];                            /* Hier kommt der Bootblock rein*/

struct bootblock *boot = puffer;  

char  *gpip = 0xFFFA01L;                     /* I/O-Register im MFP */

int   *diskctl_w = 0xFF8604L;                /* HDC-Register in der DMA */
long  *diskctl_l = 0xFF8604L;                /* Das Gleiche in long */
int   *fifo      = 0xFF8606L;                /* Steuerregister der DMA */
char  *dmahigh   = 0xFF8609L;                /* DMA-Adresse, High-Byte */
char  *dmamid    = 0xFF860BL;                /* Mid-Byte */
char  *dmalow    = 0xFF860DL;                /* Low-Byte */
int   *hz_200    = 0x4BAL;                   /* Der 200Hz-SystemzÑhler */
int   *flock     = 0x43EL;                   /* Sperren der Floppy-VBL's */

long save_ssp;                               /* Supervisor-Stackpointer */



main()
{
   if (get_boot())
      do_info();
   else
      Cconws("Leider kann keine Information ausgegeben werden !!\n\r");
   Cconin();
}

/***********************************/
/*  Bootsektor von Harddisk lesen  */
/***********************************/

int get_boot()                               
{
   if(Drvmap() & 60)                      /* Sind Åber Stationen angemeldet ?*/
      return(hd_read(0L,1,puffer,0,0));
   else
      return(0);                          
}

/**************************************************************/
/*  >anzahl< Sektoren ab >sektor< vom Laufwerk >drv< mit dem  */
/*  Controller >crtl< in den Puffer >buf< laden               */
/**************************************************************/ 

int hd_read(sektor, anzahl, buf, drv, crtl)
long sektor, buf;
int anzahl, drv, crtl;
{
   int ok;
   super_on();                            /* Supervisor-Modus einschalten */
   *flock = ON;                           /* Floppy-VBL sperren */
   set_buf(buf);                          /* Adresse des Puffers eintragen */
   ok = seek_block(READ, sektor, anzahl, drv, crtl);  /* Sektoren suchen */
   if (ok)
      dma_read(anzahl);                   /* DMA auf Lesen programmieren */
   ok = status();                         /* Hat's auch geklappt ???     */
   *fifo = 0x80;                          /* DMA wieder in den Normalzustand */
   *flock = OFF;                          /* Floppy-VBl wieder freigeben */
   super_off();                           /* ZurÅck in den User-Modus    */
   return(ok);                            /* Das war's !!                */
}

set_buf(buf)                              /* Pufferadresse in DMA eintragen */
long buf;
{
   *dmalow = (char)(buf & 0xFF);
   *dmamid = (char)((buf >> 8) & 0xFF);
   *dmahigh= (char)((buf >> 16) & 0xFF);

}

/****************************************/
/*  Sektor(en) auf der Platte anfahren  */
/****************************************/

int seek_block(befehl, sektor, anzahl, drive, controller)
int befehl, anzahl, drive, controller;
long sektor;
{
   long kommando;
   int fehler;
   
   *fifo = 0x88;
   
   kommando = ((long)controller << 21) | ((long)befehl << 16) | 0x8a;
   *diskctl_l = kommando;                 /* 1.Byte an den Controller schicken*/
   if ((fehler = timer(KURZ)) == 0)       /* 1/20 Sekunde warten, bis */
      return(fehler);                     /* der Controller OK bereit ist */

   *diskctl_l = ((long)drive << 21) | (sektor & 0xFF0000) | 0x8A;
   if ((fehler = timer(KURZ)) == 0)       /* 2.Byte senden und warten */
      return(fehler);

   *diskctl_l = (sektor & 0xFF00) << 8 | 0x8A;  /* 3.Byte senden */
   if ((fehler = timer(KURZ)) == 0)
      return(fehler);
      
   *diskctl_l = (sektor & 0xFF) << 16 | 0x8A;   /* 4.Byte senden */
   if ((fehler = timer(KURZ)) == 0)
      return(fehler);
      
   *diskctl_l = ((long)anzahl & 0xFF) << 16 | 0x8A; /* Anzahl senden */
   return(timer(KURZ));
}

/******************************************************************************/
/* Auf die Bereit-Meldung des Controllers warten, aber hîchstens zeit/20 Sek. */
/******************************************************************************/

timer(zeit)
int zeit;
{
   int wert;
   
   wert = *hz_200 + zeit;
   while (*hz_200 != wert)
      if ((*gpip & 0x20) == 0)           /* Hat der Controller sich gemeldet ?*/
         return(-1);
   return(0);                            /* Zeit abgelaufen: Fehler ! */
}

/******************************************************/
/* DMA auf Lesen von >anzahl< Blocks programmieren... */
/******************************************************/

dma_read(anzahl)
int anzahl;
{
   *fifo = 0x98;                 /* Mit der Schreib-Lese-Leitung klappern..*/
   *fifo = 0x198;
   *fifo = 0x98;
   *diskctl_w = anzahl;          /* Anzahl eintragen... */
   *fifo = 0x8A;
   *diskctl_l = 0L;
}

/**************************************/
/* Statusmeldung vom Controller holen */
/**************************************/

int status()
{
   int fehler;
   
   if ((fehler = timer(LANG)) == 0)       /* Zwei Sekunden warten  */
      return(0);                          /* Fehler, weil Zeit alle */
   *fifo = 0x8A;     
   fehler = *diskctl_w & 0xFF;
   return(!fehler);
}

super_on()                                /* Supervisor-Modus einschalten */
{
   save_ssp = Super(0L);
}

super_off()                               /* ZurÅck in den User-Modus */
{
   Super(save_ssp);
}

/**********************************************/
/*  Information Åber die Festplatte ausgeben  */
/**********************************************/

long p_frei[4], hd_frei, p_lang[4];
char p_str[4]; 

do_info()
{
   long pbuff[4];
   int i;
   
   hd_frei = 0;
   
   Cconws("               \033p HARDDISK-INFORMATION V2.0  Von Ulrich Meumann \033q\n\r");
   Cconws("--------------------------------------------------------------------------------\r");

   for(i=0;i<4;i++)
   {
      if(boot->p_table[i].p_flag && boot->p_table[i].p_id1=='G' && boot->p_table[i].p_id2=='E')
      {
         Dfree(pbuff,i+3);                /* Freier Platz auf der Partition */ 
         p_frei[i] = pbuff[0]*1024;
      }
      else
         p_frei[i] = 0;
      p_lang[i] = boot->p_table[i].p_size;  /* LÑnge der Partition in Sektoren */
      hd_frei += p_frei[i];                 /* Freier Platz auf der ganzen Platte */
   }
   
   disk_info();                     /* Information Åber die Gesamtbelegung */
   partitions();                    /* Informationen zu den Partitions */
}

/**********************************************/
/* Informationen zur gesamten Platte ausgeben */
/**********************************************/

disk_info()
{
   long ws;
   
   printf(" Gesamte Grîûe  : %8ld Sektoren",boot->hd_size);
   printf(" = %8.3f MBytes\n",((float)boot->hd_size*512)/1024/1024);

   ws = (boot->hd_size - boot->bsl_count);

   printf(" Wahre Grîûe    : %8ld Sektoren",ws);
   printf(" = %8.3f MBytes\n",((float)ws*512)/1024/1024);

   printf(" Davon belegt   : %8.3f MBytes",((float)ws*512-hd_frei)/1024/1024);
   printf("   = %7.2f  %%\n",((float)(ws*512-hd_frei)/(float)(ws*512)*100));
   
   printf(" Freier Platz   : %8.3f MBytes\n",((float)hd_frei)/1024/1024);
   
   if (boot->bsl_count)
   {
      printf(" Defekte Sektoren: %5ld",boot->bsl_count);
      printf(" = %8.1fKBytes\n",((float)boot->bsl_count*512)/1024);
   }
   else
      printf(" Keine defekten Sektoren vorhanden.\n");
}

/*******************************************************/
/* Informationen zu den einzelnen Partitionen ausgeben */
/*******************************************************/

partitions()
{
   int i;
   long belegt;
   char p_code[4];
   
   for(i=0;i<4;i++)
   {
      Cconws("--------------------------------------------------------------------------------\r");
      p_code[0]=boot->p_table[i].p_id1;
      p_code[1]=boot->p_table[i].p_id2;
      p_code[2]=boot->p_table[i].p_id3;
      p_code[3]='\0';
      printf(" Partition %d : ",i+1);
      if (boot->p_table[i].p_flag)
         printf("%s ",p_code);
      else
         printf("Nicht benutzt.\n");
      if (boot->p_table[i].p_flag & 0x80)
         printf("und bootbar.\n");
      else
         printf("\n");
      if (boot->p_table[i].p_flag)
      {
         printf(" Grîûe : %8ld Sektoren",p_lang[i]);
         printf(" = %8.3f MBytes\n",((float)p_lang[i]*512)/1024/1024);
         belegt = p_lang[i]*512-p_frei[i];
         printf(" Belegt: %8.3f MBytes",((float)belegt)/1024/1024);
         printf("   = %7.2f  %%",((float)belegt/(float)(p_lang[i]*512))*100);
         printf("      Frei : %8.3f Mbytes\n",(float)p_frei[i]/1024/1024);
      }
   }
}

/***********************************************/
/* ZUSéTZLICHE FUNKTIONEN:SCHREIBEN UND PARKEN */
/***********************************************/ 

#define WRITE 0x0A

/**************************************************************/
/*  >anzahl< Sektoren ab >sektor< vom Puffer >buf< auf das    */
/*  Laufwerk >drv< mit dem Controller >crtl< schreiben        */
/**************************************************************/ 

int hd_write(sektor, anzahl, buf, drv, crtl)
long sektor, buf;
int anzahl, drv, crtl;
{
   int ok;
   super_on();                            /* Supervisor-Modus einschalten */
   *flock = ON;                           /* Floppy-VBL sperren */
   set_buf(buf);                          /* Adresse des Puffers eintragen */
   ok = seek_block(WRITE, sektor, anzahl, drv, crtl);  /* Sektoren suchen */
   if (ok)
      dma_write(anzahl);                 /* DMA auf Schreiben programmieren */
   ok = wr_status();                         /* Hat's auch geklappt ???     */
   *fifo = 0x80;                          /* DMA wieder in den Normalzustand */
   *flock = OFF;                          /* Floppy-VBl wieder freigeben */
   super_off();                           /* ZurÅck in den User-Modus    */
   return(ok);                            /* Das war's !!                */
}

/**********************************************************/
/* DMA auf Schreiben von >anzahl< Blocks programmieren... */
/**********************************************************/

dma_write(anzahl)
int anzahl;
{
   *fifo = 0x98;                 /* Mit der Schreib-Lese-Leitung klappern..*/
   *fifo = 0x198;
   *diskctl_w = anzahl;          /* Anzahl eintragen... */
   *fifo = 0x18A;
   *diskctl_l = 0x100L;
}

/**************************************/
/* Statusmeldung vom Controller holen */
/**************************************/

int wr_status()
{
   int fehler;
   
   if ((fehler = timer(LANG)) == 0)       /* Zwei Sekunden warten  */
      return(0);                          /* Fehler, weil Zeit alle */
   *fifo = 0x18A;     
   fehler = *diskctl_w & 0xFF;
   return(!fehler);
}

#define PARK 0x1B

/***********************************************************************/
/* Kîpfe der Platte >drv< mit HDC >crtl< in die Parkposition fahren... */
/***********************************************************************/

int hd_park(drv,crtl)
int drv, crtl;
{
   int ok;
   super_on();                            /* Supervisor-Modus einschalten */
   *flock = ON;                           /* Floppy-VBL sperren */
   ok = seek_block(PARK, 0L, 0, drv, crtl);  /* Sektoren suchen */
   *diskctl_l = (long)0x0a;               /* Noch ein Byte senden... */
   ok = timer(KURZ);                      /* Und nochmal warten... */
   ok = status();                         /* Hat's auch geklappt ???     */
   *fifo = 0x80;                          /* DMA wieder in den Normalzustand */
   *flock = OFF;                          /* Floppy-VBl wieder freigeben */
   super_off();                           /* ZurÅck in den User-Modus    */
   return(ok);                            /* Das war's !!                */
}
