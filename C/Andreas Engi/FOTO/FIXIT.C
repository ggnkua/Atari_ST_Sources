#include "stdio.h"

/*----------------------------------------------------------------------*
*   GEMDOS Disk-Transfer und Disk-free  Struktur                        *
*-----------------------------------------------------------------------*/
/*
struct DTA   {
   char junk[20];                               * reserviert           *
   char attrib;                                 * Dateiattribute       *
   short time;                                  * Zeit                 *
   short date;                                  * Datum                *
   long size;                                   * Dateigroesse         *
   char fname[13];                              * Name                 *
};

struct DSP   {                                  * Diskettenplatz       *
   long frecl;                                  * freie cluster        *
   long totcl;                                  * gesamt cluster       *
   long bps;                                    * Bytes/Sektor         *
   long spc;                                    * Sektoren/Cluster     *
};
*/

/*----------------------------------------------------------------------*
*                     Meldungen und Konstanten                          *
*-----------------------------------------------------------------------*/
#define NOFOTO  "FOTO nicht geladen !!\n\r"
#define FMSG    "\33E Bitte Dateinamen eingeben: "
#define FULLMSG "\n\rDiskette ist voll !!!"
#define NOMSG   "\n\rNicht komplett geschrieben"

#define WRITE        1                          /* schreiben            */
#define T13V        45                          /* TRAP 13              */
#define FILESIZE 32034                          /* 32034 Bytes /Bild    */

/*----------------------------------------------------------------------*
*   Dieses Programm schreibt ein mit FOTO konserviertes Bild im DEGAS   *
*       Format auf einen Massenspeicher.                                *
*       Es wird nach dem Dateinamen gefragt, geprueft ob er noch nicht  *
*       vorhanden ist. Ausserdem verweigert das Programm das Abspeichern*
*       wenn zuwenig Platz auf der Diskette ist.                        *
*               struct DEGAS   {                                        *
*                  short resolution;            resolution              *
*                  short  palette[16];          Farbpalette             *
*                  char   screen[32000];        Screen                  *
*               };                                                      *
*-----------------------------------------------------------------------*/

char ext[] = ".PI ",path[64];                   /* diverse Puffer       */

 
main()
{
char  *screen,*isfoto();
short i,res,pal[16];
int fd,cnt;                                     /* Filehandle & count   */

   /*-------------------------------------------------------------------*
   *                Resolution und Farbpalette festhalten               *
   *--------------------------------------------------------------------*/

   res = Getrez();                              /* Resolution           */
   ext[3] = res + '1';                          /*    "    -> Fname     */
   for(i=0;i<15;pal[i++] = Setcolor(i,-1));     /* Farbpalette          */

   /*-------------------------------------------------------------------*
   *          Falls Foto geladen, Dateinamen einlesen                   *
   *--------------------------------------------------------------------*/

   if (! (screen = isfoto()))                   /* Foto geladen?        */
      err(NOFOTO);                              /* wenn nicht, exit     */

   do   {
      puts(FMSG);                               /* Nach Namen fragen    */
      gets(&path);
      if (! stpchr(path,'.'))                   /* Extension angegeben ?*/
         strcat(path,ext);                      /* nein, anhaengen bis  */
   } while (fexist(path));                      /* Datei nicht vorh.    */

   /*-------------------------------------------------------------------*
   *                Wenn genug Platz, Bild abspeichern                  *
   *--------------------------------------------------------------------*/

   if (dfree(path) < FILESIZE)   {              /* Genug Platz ?        */
      puts(FULLMSG);                            /* nein                 */
      exit(1);
   }
   fd = Fcreate(path,0);                        /* Datei eroeffnen      */
   cnt =  Fwrite(fd,2,&res);                    /* Resolution  -> fd    */
   cnt += Fwrite(fd,32,&pal);                   /* Palette     -> fd    */
   cnt += Fwrite(fd,32000,screen);              /* Bild        -> fd    */
   Fclose(fd);
   if (cnt < FILESIZE) err(NOMSG);              /* Fehler beim Schreiben*/

}

 
/*----------------------------------------------------------------------*
*   Liefert die Screenadresse falls FOTO geladen                        *
*-----------------------------------------------------------------------*/
char *isfoto()
{
long *vec;

   vec = (long *)(Setexc(T13V,-1) + 2);
   return((*vec == 0x12344321) ? *++vec :0); /* Noch Fragen   ???    */
}

/*----------------------------------------------------------------------*
*   Liefert TRUE, falls der Pfad existiert                              *
*-----------------------------------------------------------------------*/
fexist(p)
char *p;                                        /* passed Pfadname      */
{
struct DTA dta;                                 /* DTA-buffer           */
   Fsetdta(&dta);                               /* Set Transferaddr     */
   return(Fsfirst(p,Fattrib(p,0,0) ) ?FALSE :TRUE);
}

/*----------------------------------------------------------------------*
*   Liefert den freien Diskettenplatz                                   *
*-----------------------------------------------------------------------*/

dfree(path)
char *path;
{
struct DSP dsp;
short drv = Dgetdrv()+1;

   if (*(++path) == ':') drv = *(--path) & 7;   /* Falls Laufwerk       */
   Dfree(&dsp,drv);                             /* Struc einlesen       */
   return(dsp.frecl * dsp.bps * dsp.spc);       /* Platz errechnen      */
}

/*----------------------------------------------------------------------*
*            Fehlerbedingung, Meldung senden und Abbruch                *
*-----------------------------------------------------------------------*/
err(s)
char *s;
{
   puts(s);                                     /* Meldung senden       */
   getchar();                                   /* Fuer die GEM-Freaks  */
   exit(1);                                     /* Ende....             */
}

/*----------------------------------------------------------------------*
*   char *stpchr(s,c)                                                   *
*     char *s,c;                                                        *
*   Liefert als Ergebnis einen Pointer auf das Zeichen 'c' im String 's'*
*   oder NUL, falls nicht im String enthalten                           *
*-----------------------------------------------------------------------*/
char *stpchr(s,c)
char *s,c;
{
   while (*s)   {                               /* Solange string       */
      if ( *cp++ == c) return (--cp);           /* Zeichen erreicht ?   */
   }                                            /* return(addr)         */
   return(NULL);                                /* else NULL            */
}
