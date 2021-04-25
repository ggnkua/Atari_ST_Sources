#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
/*#include <errno.h>
*/

#define MAXDIR    42
#define MAXFIL    42
#define PATHLEN   64

#define BELL       7
#define BS         8
#define ENTER     13
#define ESC       27

#define PRT        0

#define READONLY   1
#define HIDDENFILE 2
#define SYSTEMFILE 4
#define VOLUME     8
#define DIRECTORY 16
#define OPENFILE  32

/*
*               DISKLIST.TOS
*               Written: 20-may-1987 by Michael Lynggaard
*/

FILE *fopen(), *fp;
long time();
long getnumber();
long potens();
char *getline();

int attr = READONLY + HIDDENFILE + SYSTEMFILE + VOLUME + DIRECTORY + OPENFILE ;
int key;
int i;

int  totdir;
int  totfiles;
long totsize;

int freaddir  = TRUE;            /* flag for listning af sub-directories */
int fdiskinfo = FALSE;           /* flag for listning af disk-info       */
int fterminal = TRUE;            /* flag for listning p† terminalen      */
int fprinter  = FALSE;           /* flag for listning p† printer         */
int fdisk     = FALSE;           /* flag for listning p† disk            */
int fsortname = TRUE;            /* flag for sortering p† filnavn        */
int fsorttype = TRUE;            /* flag for sortering p† filtype        */
int fsortsize = TRUE;            /* flag for sortering p† filst³relse    */
int fsortdate = TRUE;            /* flag for sortering p† fil dato       */
int fvolume   = TRUE;            /* flag for udskrift af volume linie    */

int device = 'A';
static char file   [] = "*.*";
static char copyright_txt [] = "DISKLIST Diskette Filelist V0.11 - (C) Michael Lynggaard  September 1987\n";
static char sorttxt[] = "Name";
char firstpath [PATHLEN - 1];
char tb        [160];                        /* text-buffer          */

char          volume_name [14];
unsigned long volume_created;

static char listfile [PATHLEN] = "A:\\DLIST.LIS";
int filenumber = 3;
int startnummer= 1;
int filnumstart;
int tekstlines = 66;
int blanklines = 6;
int antal_linier;

unsigned long timedate;

typedef struct dta_struct
  { char  dmy[20];
    int   fileattr;                          /* burde vaere SHORT ?? */
    unsigned long  filedate;
    long  filesize;
    char  filename[14];
  } DTA;
DTA  *dta;

typedef struct elm_struct
  { char  filename[10];
    char  filetype[03];
    unsigned long  filedate;
    long  filesize;
    int   fileattr;                          /* burde vaere SHORT ?? */
    int   write_nr;                          /* sorted write file #  */
  } ELM;

typedef struct disk_struct
  { long free;
    long total;
    long secsiz;
    long clsiz;
  } DSK;

void main()
{
DSK disk;

    setbuf(stdout,0L);
    setbuf(stdin,0L);

    printf("%s",copyright_txt);
    do_menu_txt();
    while ( ((key = Cnecin() & 0x7f) != 'S') && (key != 's') )
       {
       if ( key == 'L' || key == 'l' )
          {
          strcpy(volume_name, "(no volume)");
          fvolume = TRUE;
          if ( fprinter )
             {
             antal_linier = 0;
             print_txt(copyright_txt);
             }
          if ( fdisk )
             {
             fp = fopen(listfile,"w");
/*printf("\n** Errno: %d", errno);
*/
             if (fp == 0)
                {
                printf("\n ** Filen %s kunne ikke †bnes.\n", listfile);
                printf(" **    Fejlmulighederne er:\n");
                printf(" **      Disken er skrivebeskyttet.\n");
                printf(" **      Fejl i navnet p† diskdrev eller folderen.\n");
                printf(" **      Disken er fyldt op.\n\n");
                goto menu;
                }
             fprintf(fp,"%s",copyright_txt);
             }
          totdir   = 0;
          totfiles = 0;
          totsize  = 0L;
          strcat(firstpath,"\0");
          listdir(firstpath,0);
          if ( freaddir )
             {
             sprintf(tb,"A total of %2d directories and %3d files found, total size is %6ld bytes.\n",
                        totdir,totfiles,totsize);
             empty_tb();
             }
          if ( fdiskinfo )
             {
             Dfree(&disk, device + 1 - 'A');
             sprintf(tb,"Clusters free  %4ld, bytes   per sector  %4ld, total free is %6ld bytes.\n",
                        disk.free, disk.secsiz, (disk.free * disk.secsiz * disk.clsiz) );
             empty_tb();
             sprintf(tb,"Clusters total %4ld, sectors per cluster %4ld.\n",
                        disk.total,disk.clsiz);
             empty_tb();
             }
          if ( fdisk )
             {
             startnummer++;
             if ( startnummer > (int) potens( 10L,filenumber) - 1)
                {
                startnummer = 0;
                do_rediger_filnavn();
                }
             fclose(fp);
             }
          if ( fprinter )
             {
             for ( i=antal_linier; i < tekstlines+blanklines; i++ )
                Bconout(PRT,'\n');
             }
menu:
          do_menu_txt();
          }
       else
          if ( key == 'O' || key == 'o' )
             {
             do_options();
             do_menu_txt();
             }
          else
             if ( key == 'I' || key == 'i' )
                {
                do_info();
                do_menu_txt();
                }
             else
                putchar(7);
       }
}


void do_menu_txt()
{
char txt5[5];
int number;
int x;

   printf("\nInds‘t diskette i diskette-drev %c:", device);
   if (fdisk)
      {
      if (filenumber > 0)
         {
         sprintf(txt5, "%05d", startnummer);
         number = startnummer;
         for (i = filenumber; number > 0 && i > 0; )
            {
            listfile[filnumstart + --i] = (number % 10) + '0';
            number /= 10;
            }
         }
      printf("\n Listning p† diskete-filen : %s ", listfile);
      }
   printf("\n L listning, O for options, I for information, S for slut.\n");
}

void do_info()
{
   printf("\nInformation:");
   printf("\n Programmet er skrevet ved brug af Megamax C.");
   printf("\n Vedr. fejl og mangler kan du pr³ve at ringe");
   printf("\n til mig p† tlf 01-167823.");
   printf("\n                              Michael Lynggaard\n");
}

void listdir(path,level)
char path[PATHLEN];
int  level;
{
ELM  dir [MAXDIR];
ELM  fil [MAXFIL];
char newpath [PATHLEN];
char spec    [PATHLEN];
int  sub, sub_write, sub_dir, sub_fil;
int  pchar;
int  tmpint      = 0;
int  i;
int  directories = 0;
int  files       = 0;
long size        = 0L;

    spec[0]=device;
    spec[1]='\0';
    strcat(spec,":\\");
    strcat(spec,path);
    strcat(spec,file);

    dta = (DTA *) Fgetdta();
    if ((tmpint = Fsfirst(spec,attr)) < 0)
       {
       sprintf(tb,"\n\n** ERROR in Fsfirst %d **\n\n ",tmpint);
       empty_tb();
       return 0;
       }
    sub_dir = 0;
    sub_fil = 0;
    do {
       dta = (DTA *) Fgetdta();
       if ( dta->fileattr & VOLUME )
          {
          strcpy(volume_name, dta->filename);
          }
       else
          {
          if (dta->fileattr & DIRECTORY)
             {
             if ( *dta->filename != '.' )
                {
                pchar = 0;
                while ( *(&dta->filename[pchar])  && *(&dta->filename[pchar]) != '.' )
                   pchar++;
                if ( *(&dta->filename[pchar]) == '\0' )
                   {
                   strcpy(dir[sub_dir].filename,dta->filename);
                   strcpy(dir[sub_dir].filetype,"\0");
                   }
                else
                   {
                   strncpy(dir[sub_dir].filename,dta->filename,pchar);
                   *(&dir[sub_dir].filename[pchar]) = '\0';
                   strcpy(dir[sub_dir].filetype,&dta->filename[pchar+1]);
                   }
                dir[sub_dir].filesize = dta->filesize;
                dir[sub_dir].filedate = dta->filedate;
                dir[sub_dir].fileattr = dta->fileattr;
                dir[sub_dir].write_nr = 0;
                sub_dir++;
                }
             }
          else
             {
             pchar = 0;
             while ( *(&dta->filename[pchar]) && *(&dta->filename[pchar]) != '.' )
                pchar++;
             if ( *(&dta->filename[pchar]) == '\0' )
                {
                strcpy(fil[sub_fil].filename,dta->filename);
                strcpy(fil[sub_fil].filetype,"\0");
                }
             else
                {
                strncpy(fil[sub_fil].filename,dta->filename,pchar);
                *(&fil[sub_fil].filename[pchar]) = '\0';
                strcpy(fil[sub_fil].filetype,&dta->filename[pchar+1]);
                }
             fil[sub_fil].filesize = dta->filesize;
             fil[sub_fil].filedate = dta->filedate;
             fil[sub_fil].fileattr = dta->fileattr;
             fil[sub_fil].write_nr = 0;
             sub_fil++;
             }
          }
       } while (Fsnext() > -1);

    if (fvolume)
       {
       sprintf(tb,"\nVolume: %-35s  Written: ", volume_name);
       empty_tb();
       timedate = time();
       write_date(&timedate);
       sprintf(tb,"\n");
       empty_tb();
       fvolume = FALSE;
       }
    
    sprintf(tb,"\nDirectory %-35sLevel %d, Sorted by %s\n  Name     Type     Size  Date     Time      File-attributes\n",
               spec, level, sorttxt );
    empty_tb();

    for (i=0; i<sub_dir; i++)
        {
        sub_write = 0;
        while ( dir[sub_write].write_nr )
           sub_write++;
        for (sub=sub_write + 1; sub<sub_dir; sub++)
           {
           if ( dir[sub].write_nr == 0 )
              if ( test_sort(&dir[sub_write], &dir[sub]) >= 0 )
                 sub_write = sub;
           }
        sprintf(tb,"* %-9s%-3s            ",
                   dir[sub_write].filename,dir[sub_write].filetype);
        empty_tb();
        write_date(&dir[sub_write].filedate);
        write_attr(dir[sub_write].fileattr);
        sprintf(tb,"\n");
        empty_tb();
        dir[sub_write].write_nr = ++directories;
        }
    
    for (i=0; i<sub_fil; i++)
        {
        sub_write = 0;
        while ( fil[sub_write].write_nr )
           sub_write++;
        for (sub=sub_write + 1; sub<sub_fil; sub++)
           {
           if ( fil[sub].write_nr == 0 )
              if ( test_sort(&fil[sub_write], &fil[sub]) >= 0 )
                 sub_write = sub;
           }
        sprintf(tb,"  %-9s%-3s%10ld  ",
                   fil[sub_write].filename,fil[sub_write].filetype,fil[sub_write].filesize);
        empty_tb();
        write_date(&fil[sub_write].filedate);
        write_attr(fil[sub_write].fileattr);
        sprintf(tb,"\n");
        empty_tb();
        size += fil[sub_write].filesize;
        fil[sub_write].write_nr = ++files;
        }

    sprintf(tb,"\n  Directories %d, files %d, total size %ld bytes.\n\n",
               directories,files,size);
    empty_tb();

    if ( fterminal && !(fprinter) && !(fdisk) )
       Cnecin();

    if ( freaddir )
       {
       level++;
       for (i=1; i<=sub_dir; i++)
          {
          for (sub=0; i != dir[sub].write_nr; sub++)
             ;
             strcpy(newpath,path);
             strcat(newpath,dir[sub].filename);
             if ( *dir[sub].filetype )
                {
                strcat(newpath,".");
                strcat(newpath,dir[sub].filetype);
                }
             strcat(newpath,"\\");
             listdir(newpath,level);
          }
       totdir   += directories;
       totfiles += files;
       totsize  += size;
       }
       
}

void write_date(date)
long *date;
{

    sprintf( tb, "%02ld/%02ld/%02ld %02ld:%02ld:%02ld",
                 80+((*date>>9)&0x7f),(*date>>5)&15,*date&31,
                 (*date>>27)&31,(*date>>21)&63,(*date>>15)&62);
    empty_tb();

}

void write_attr(attr)
int attr;
{
    if (attr & READONLY)
       {
       sprintf(tb,"  read only");
       empty_tb();
       }
    if (attr & HIDDENFILE)
       {
       sprintf(tb,"  hidden file");
       empty_tb();
       }
    if (attr & SYSTEMFILE)
       {
       sprintf(tb,"  system file");
       empty_tb();
       }
    if (attr & OPENFILE)
       {   
       sprintf(tb,"  open file");
       empty_tb();
       }

}

void do_options()
{
char txt10 [11];
char txt2 [3];
long number;
long deskdrev;

    printf("\nOptions:\n");
    printf(" Listning fra diskette-drev ?");
    printf("\n V‘lg et af f³lgende:");
    strcpy(txt2,"  ");
    strcpy(txt10," ");
    deskdrev = Drvmap();
    for (i=0; i < 28; i++)
       {
       if (deskdrev & (1 << i) )
          {
          txt2[0] = i + 'A';
          strcat(txt10,txt2);
          }
       }
    printf("%-10s    [%c]: ", txt10, device);
    while ( TRUE )
       {
       key = Cnecin() & 0x7f;
       key = toupper( key );
       if (key == ENTER)
          key = device;
       if ( deskdrev & ( 1 << (key - 'A') ) )
          {
          device = key;
          break;
          }
       putchar(7);
       }
    printf("%c\n", device);
    ask_option("Listning af 'sub'-directories ?",   &freaddir);
    ask_option("Listning af disk-information ?",    &fdiskinfo);
    ask_option("Listning p† terminalen ?",          &fterminal);
    if ( ask_option("Listning til printer (parallel) ?", &fprinter) )
       {
       printf("   Antal tekst-liner pr. side ?    [%02d]: ", tekstlines);
       number=getnumber(txt10,2);
       if ( strlen(txt10) > 0 )
          tekstlines = (int) number;
       else
          printf("%d", tekstlines);
       printf("\n   Antal blanke liner pr. side ?   [%02d]: ", blanklines);
       number=getnumber(txt10,2);
       if ( strlen(txt10) > 0 )
          blanklines = (int) number;
       else
          printf("%d", blanklines);
       printf("\n\n");
       }

    if ( ask_option("Listning p† diskete-fil ?",    &fdisk) )
       do_filename();

    while ( TRUE )
       {
       if ( ask_option("Sorteret efter navn ?", &fsortname) )
          {
          strcpy(sorttxt,"Name");
          break;
          }
       if ( ask_option("Sorteret efter type ?", &fsorttype) )
          {
          strcpy(sorttxt,"Type");
          break;
          }
       if ( ask_option("Sorteret efter st³relse ?", &fsortsize) )
          {
          strcpy(sorttxt,"Size");
          break;
          }
       if ( ask_option("Sorteret efter dato ?", &fsortdate) )
          {
          strcpy(sorttxt,"Date");
          break;
          }
       printf("\n V‘lg en af f³lgende sorteringm†der\n");
       }

}


int ask_option(question,answer)
char *question;
int  *answer;
{

    printf(" %-33s [%c]: ", question, ( *answer ) ? 'J' : 'N' );
    while ( TRUE )
       {
       key = Cnecin() & 0x7f;
       key = toupper( key );
       if (key == 'J')
          {
          *answer = TRUE;
          break;
          }
       if (key == 'N')
          {
          *answer = FALSE;
          break;
          }
       if (key == ENTER)
          break;
       putchar(BELL);
       }
    printf("%s\n", ( *answer ) ? "J" : "N" );
    return(*answer);

}

void do_filename()
{
char txt [PATHLEN];
char txt10 [10];
long number;

    printf("   Angivelse af output-filnavnet");
    printf(" (evt. ogs† navnet p† drev og folder)\n");
    printf("   [%s] : ", listfile);
    getline(txt,PATHLEN - 1);
    if ( strlen(txt) > 0 )
       strcpy(listfile, txt);
    else
       printf("%s",listfile);
    for (i=0; listfile[i]=toupper(listfile[i]); i++) ;

    printf("\n   Antal cifre til fortl³bende nummerering (0-4) ? [%d] : ", filenumber);
    while ( TRUE )
       {
       key = Cnecin() & 0x7f;
       if (key == ENTER)
          break;
       if ( (key >= '0') && (key < '5') )
          {
          filenumber = key - '0';
          break;
          }
       putchar(BELL);
       }
    printf("%d", filenumber);
    if (filenumber > 0)
       {
       i = (int) potens(10L, filenumber) - 1;
       while (startnummer > i)
          startnummer %= 10;
       printf("\n   F³rste nummer til fortl³bende nummerering ?     [%d] : ",
               startnummer);
       number=getnumber(txt10,filenumber);
       if ( strlen(txt10) > 0 )
          startnummer = (int) number;
       else
          printf("%d", startnummer);

       do_rediger_filnavn();
       }
    printf("\n\n");

}

void do_rediger_filnavn()
{
char txt [PATHLEN];
int punktum;

       strcpy(txt, listfile);
       for (punktum = strlen(txt); punktum > 0 && txt[punktum] != '.'; punktum--) ;
       if ( punktum > 0 )
          txt[punktum] = '\0';
       for (i = strlen(txt); i > 0 && txt[i] != '\\' && txt[i] != ':'; i--) ;
       if (i != 0)
          i++;
       txt[ filnumstart = i + 8 - filenumber] = '\0';
       filnumstart = strlen(txt);
       for (i = 0; i < filenumber; i++)
          strcat(txt, "_");
       if ( punktum > 0 )
          strcat(txt, &listfile[punktum]);
       strcpy(listfile, txt);
}

void empty_tb()
{

    if ( fterminal )
       printf("%s",tb);
    if ( fprinter )
       print_txt(tb);
    if ( fdisk )
       fprintf(fp,"%s",tb);

}

void print_txt(text)
char *text;
{
register char *cp;
int i;

    cp = text;
    while (*cp)
       {
       if ( *cp == '\n' )
          {
          antal_linier++;
          if ( antal_linier >= tekstlines )
             {
             antal_linier = 0;
             for ( i=0; i < blanklines; i++ )
               Bconout(PRT,'\n');
             }
          }
       Bconout(PRT,(*cp));
       cp++;
       }

}

int test_sort(old, new)
ELM *old;
ELM *new;
{
int sortres = 0;

    if ( fsorttype )
       sortres = strcmp(old->filetype, new->filetype);
    else
       if ( fsortsize )
          sortres = (old->filesize==new->filesize) ? 0 : ((old->filesize>new->filesize) ? -1 : 1);
       else
          if ( fsortdate )
             sortres = (old->filedate==new->filedate) ? 0 : ((old->filedate>new->filedate) ? -1 : 1);

    if ( fsortname || sortres == 0 )
       {
       if ( ( sortres = strcmp(old->filename, new->filename) )  == 0 )
          sortres = strcmp(old->filetype, new->filetype);
       }

    return( sortres );

}

long time()
{
register long d,t;
        
    d = Tgetdate();
    t = Tgettime() & 0xffffL;
    return (long)(((t<<16) & 0xffff0000) + d);
}


char *getline(dest,maxchr)
char *dest;
int maxchr;
{  
int n;
unsigned int c,x; 
 
        n = 0;
        while ( TRUE )
           {
           c = Crawcin();
           if (c == ENTER)
              {
              *(dest + n) = '\0';
              return dest;
              }
           if (c == BS)
              {
              if (n)
                 {
                 --n;
                 putchar(BS);
                 putchar(' ');
                 putchar(BS);
                 } 
              else 
                 putchar(BELL);
              }
           else
              if ((n < maxchr) && (c > 31 && c < 127))
                 {
                 putchar(c);
                 *(dest + n++) = c;
                 }
              else
                 putchar(BELL);
        }
}


long getnumber(dest,maxchr)
char *dest;
int maxchr;
{
long number;
int n;
unsigned int c,x;

    n = 0;
    number = 0L;
    while ( TRUE )
       {
       c = Crawcin();
       if (c == ENTER)
          {
          *(dest + n) = 0;
          return number;
          }
       if (c == BS) 
          {
          if (n)
             {
             --n;
             putchar(BS);
             putchar(' ');
             putchar(BS);
             number /= 10;
             } 
          else 
             putchar(BELL);
          }
       else
          if ((n < maxchr) && (c >= '0' && c <= '9'))
             {
             putchar(c);
             *(dest + n++) = c;
             number = number * 10 + c - '0';
             }
         else
            putchar(BELL);
        }
}

long potens(number, potens)
long number;
int potens;
{
long result = 1L;

   for ( ; potens > 0 ; potens-- )
      result *= number;

   return(result);
}


void test(tekst)
char *tekst;
{
   printf("%s\n",tekst);
   Cnecin();
}
