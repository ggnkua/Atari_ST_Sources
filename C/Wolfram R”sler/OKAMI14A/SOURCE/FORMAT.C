/**********************************************************************

	Programm zum Formatieren von Disketten


		von Wolfram R”sler
		     

      zum Aufruf als TTP oder von der Okami-Shell


Datum	  Ver.	Žnderung
20.10.90  1.1	Volume Label (-l)
14.01.91  1.2	Schwerer Fehler beseitigt: &argv[i][2] statt argv[i][2]
24.05.91  1.3	Fehlerabfragen; -V: Versionsnummer
25.07.91  1.4	MSDOS-kompatibler Bootsektor
01.12.91  1.5	Anpassung an TurboC/PureC (Ansi-C)

**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>

#define PRGNAME     "format"	/* eigentlich: argv[0]			*/
#define VERSION	    "1.5"	/* Versionsnummer			*/
#define FLAG_NOBOOT (-99)	/* Flag fr keinen Bootsektor anlegen	*/
#define FLAG_NOFMT  (-987)	/* Flag fr nur Bootsektor anlegen	*/
#define MAGIC	    0x87654321L /* Magische Zahl, hexhexhex		*/
#define SECSIZE     512 	/* Bytes pro Sektor			*/
#define FMTBUFSIZE  0x3000	/* Formatierpuffer			*/

/* VT52-Steuercodes */
#define C_SAVE		"\033j"
#define C_RESTORE	"\033k"

char TError[]="!!! Error";

int YesOrNo(void)
{
  fputs("Do you really want to do that? (y or n) ",stdout);
  fflush(stdout);
  return tolower(getchar())!='y';
}


int Format(int devno,int spt,int Sides,int Tracks,int interlv,
	unsigned virgin,long SerNo,int Exec,int Quiet,char *VolLbl)
{
  register int i,j;
  register char *Buf;
  int Erg;
  
  if (Exec!=FLAG_NOFMT)
  {
  
    if (!Quiet)
    {
  
      /* Parameter checken */
      if (devno!=0 && devno!=1)
      {   
	printf("You are about to format drive %c.\n",(char)devno+'A');	
	if (YesOrNo())
	  return 0;
      }
	
      if (virgin!=0xe5e5)
      {
	printf("You are about to format with a virgin of 0x%x.\n",virgin);
	if (YesOrNo())
	  return 0;
      }
    
      /* Letzte Warnung */
      printf(
      "LAST CHANCE TO STOP:\nYou are about to format the disk in drive %c.\n",
      (char)devno+'A');
	
      if (YesOrNo())
        return 0;
    
    } /* if (!Quiet) */
      
    /* Los gehts */
    
    /* Speicher fr Rckgabewert */
    Buf=calloc(FMTBUFSIZE,sizeof(int));
    if (Buf==NULL)
    {
      fprintf(stderr,"%s: Out of memory (need %d bytes)\n",PRGNAME,
						FMTBUFSIZE*sizeof(int));
      return 1;
    }
    
    /* *** FORMATIEREN *** */
    
    printf("Formatting disk %c, %d side%s, %d tracks, %d sec/track\n%s",
		(char)devno+'A',Sides,Sides==1?"":"s",Tracks,spt,C_SAVE);

    for (i=Tracks-1;i>=0;i--)
      for (j=0;j<Sides;j++)
      {
	printf("%s%sSide %d Track %d  ",C_RESTORE,C_SAVE,j,i);
	fflush(stdout);
	Erg=Flopfmt((int *)Buf,0L,devno,spt,i,j,interlv,MAGIC,
						    i>1 ? virgin : 0);
	if (Erg!=0)
	{
	  fprintf(stderr,"\n%s %d on side %d, track %d\n",TError,Erg,j,i);
	  free(Buf);
	  return 1;
	}
      }

    free(Buf);
    fputs(C_RESTORE,stdout);

  } /* if (Formatieren) */ 
 
  /* *** BOOTSEKTOR *** */
  
  if (Exec!=FLAG_NOBOOT)
  {
    printf("Creating %sexecutable boot sector",Exec ? "" : "non-");
    fflush(stdout);
    Buf=malloc(SECSIZE);
    if (Buf==0)
    {
      fprintf(stderr,"\n%s: Out of memory (need %d bytes)\n",PRGNAME,
								SECSIZE);
      return 1;
    }
    Protobt(Buf,SerNo,(Sides-1)+(((Tracks/40)-1)<<1),Exec);
    /* MSDOS-kompatibel */
    Buf[0]=0xeb;
    Buf[1]=0x34;
    Buf[2]=0x90;
    Erg=Flopwr(Buf,0L,devno,1,0,0,1);
    free(Buf);
    if (Erg!=0)
    {
      fprintf(stderr,"\n%s %d writing bootsector\n",TError,Erg);
      return 1;
    }
  }

  fputc('\n',stdout);

  /* Diskettenname erzeugen */
  if (VolLbl!=NULL && *VolLbl!='\0')
  {
    int Fd;
    char Path[80+1];

    printf("Creating volume label");
    fflush(stdout);
    sprintf(Path,"%c:\\%s",devno+'A',VolLbl);
    Fd = Fcreate(Path,1<<3);
    if (Fd<0)
      fprintf(stderr,"\n\t%s %d creating volume label\n",TError,Erg);
    else
      Fclose(Fd);
    fputc('\n',stdout);
  }
  return 0;
}

void Usage(char *PrgName)
{
  fprintf(stderr,
   "Usage: %s [-V]|[-s(Sec/Trk)] [-t(Trk/Dsk)] [-1] [-i(interlv)] \\\n%s",PrgName,
   "	   [-v(virgin)] [-n(SerNo)] [-(N|B)] [-x] [-q] [-l(VolLbl)] [Drive]");
  fprintf(stderr,"\nDefaults: -s9 -t80 -i1 -v0xE5E5 A:\n\n");
  fprintf(stderr,"-1: Format Single Sided\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n",
		 "-N: No Boot Sector",
		 "-B: Boot Sector only",
		 "-x: Executable Boot Sector",
		 "-q: No security requests",
		 "-l: Volume Label (default: none)",
		 "-V: just print version number",
		 "Drive: A or B (floppy disk drives only, no hard disks!)");
}

int main(int argc,char *argv[])
{
  int	devno	= 0;		/* Laufwerksnummer: 0 A:, 1 B:		*/
  int	spt	= 9;		/* Sektoren pro Track			*/
  int	Sides	= 2;		/* Anzahl Seiten (1/2)			*/
  int	Tracks	= 80; 		/* Anzahl Tracks			*/
  int	interlv	= 1;		/* Interleave-Faktor			*/
  unsigned virgin = 0xe5e5;	/* Virgin-Wort fr Sektoren		*/
  long	SerNo	= 0x01000001L;	/* Seriennummer fr Bootsektor		*/
  int	Exec	= 0;		/* Bootsektor ausfhrbar		*/
  int	Quiet	= 0;		/* Flag Sicherheitsabfragen: 0 ja,1 nein*/
  char *VolLbl	= NULL;		/* Diskettenname oder NULL		*/
  int i;
  
  if (argc==1)
    return Format(devno,spt,Sides,Tracks,interlv,virgin,SerNo,Exec,Quiet,VolLbl);
  
  /* Parameter scannen */
  for (i=1;i<argc;i++)
  {
    if (argv[i][0]=='-')		/* Flag */
      switch(argv[i][1])
      {
        case 'V':			/* Versionsnummer	*/
	  puts("Okami Format " VERSION);
	  puts("compiled " __DATE__ " " __TIME__);
	  exit(0);
	case 's':			/* Sektoren pro Track	*/
	  spt=atoi(&argv[i][2]);
	  break;
	case 't':			/* Tracks pro Disk	*/
	  Tracks=atoi(&argv[i][2]); 
	  break;
	case '1':			/* Einseitig		*/
	  Sides=1;
	  break;
	case 'i':			/* Interleaf-Faktor	*/
	  interlv=atoi(&argv[i][2]);
	  break;
	case 'v':			/* Virgin-Wort		*/
	  virgin=(unsigned)atoi(&argv[i][2]);
	  break;
	case 'n':			/* Seriennummer 	*/
	  SerNo=atol(&argv[i][2]);
	  break;
	case 'N':			/* kein Bootsektor	*/
	  Exec=FLAG_NOBOOT;
	  break;
	case 'B':			/* nur Bootsektor	*/
	  Exec=FLAG_NOFMT;
	  break;
	case 'x':			/* Bootsektor ausfhrbar*/
	  Exec=1;
	  break;
	case 'q':			/* keine Sicherheitsabfragen */
	  Quiet=1;
	  break;
	case 'l':			/* Diskettenname	*/
	  VolLbl= &(argv[i][2]);
	  break;
	default:			/* Falsches Flag	*/
	  Usage(PRGNAME);
	  return 1;
      }
    else				/* Laufwerksnummer	*/
      devno=tolower(argv[i][0])-'a';
  }

  return Format(devno,spt,Sides,Tracks,interlv,virgin,SerNo,Exec,Quiet,VolLbl);
}