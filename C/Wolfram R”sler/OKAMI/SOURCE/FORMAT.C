/**********************************************************************

	Programm zum Formatieren von Disketten

		  wr 18.04.90-02.06.90
		     
      zum Aufruf als TTP oder von der Okami-Shell

Datum	  Ver.	énderung
20.10.90  1.1	Volume Label (-l)
14.01.91  1.2	Schwerer Fehler beseitigt: &argv[i][2] statt argv[i][2]
24.05.91  1.3	Fehlerabfragen; -V: Versionsnummer

**********************************************************************/
static char _M_ID[]="@(#)format.c - Okami Format";

#include <stdio.h>
#include <osbind.h>
#include <ctype.h>

/* Die Datei cmpdat.h enthÑlt das Kompilierungsdatum des Programms,
** wer diese Datei nicht hat, kann das include gegen das folgende
** define austauschen:
	#define _CMP_DAT "????"
** und statt ???? das aktuelle Datum eintragen.
*/
#include <cmpdat.h>

#define PRGNAME     "format"	/* eigentlich: argv[0]			*/
#define VERSION	    "1.3"	/* Versionsnummer			*/
#define FLAG_NOBOOT (-99)	/* Flag fÅr keinen Bootsektor anlegen	*/
#define FLAG_NOFMT  (-987)	/* Flag fÅr nur Bootsektor anlegen	*/
#define MAGIC	    0x87654321L /* Magische Zahl, hexhexhex		*/
#define SECSIZE     512 	/* Bytes pro Sektor			*/
#define FMTBUFSIZE  0x3000	/* Formatierpuffer			*/

/* VT52-Steuercodes */
#define C_SAVE		"\033j"
#define C_RESTORE	"\033k"

char TError[]="!!! Error";

 
main(argc,argv)
int argc;
char *argv[];
{
  int	devno;			/* Laufwerksnummer: 0 A:, 1 B:		*/
  int	spt;			/* Sektoren pro Track			*/
  int	Sides;			/* Anzahl Seiten (1/2)			*/
  int	Tracks; 		/* Anzahl Tracks			*/
  int	interlv;		/* Interleave-Faktor			*/
  int	virgin; 		/* Virgin-Wort fÅr Sektoren		*/
  long	SerNo;			/* Seriennummer fÅr Bootsektor		*/
  int	Exec;			/* Bootsektor ausfÅhrbar		*/
  int	Quiet;			/* Flag Sicherheitsabfragen: 0 ja,1 nein */
  char *VolLbl;			/* Diskettenname oder NULL		*/

  int i;
  
  /* Standardwerte initialisieren */
  devno   = 0;			/* Laufwerk A:				*/
  spt	  = 9;			/* 9 Sektoren pro Track 		*/
  Sides   = 2;			/* 2 Seiten pro Diskette		*/
  Tracks  = 80; 		/* 79 Tracks pro Diskette		*/
  interlv = 1;			/* Kein Interleave			*/
  virgin  = 0xe5e5;		/* Normalerweise immer			*/
  SerNo   = 0x01000001L;	/* zufÑllige Seriennummer		*/
  Exec	  = 0;			/* nicht ausfÅhrbar			*/
  Quiet   = 0;			/* mit Sicherheitsabfragen		*/
  VolLbl  = NULL;		/* kein Diskettenname			*/
  
  if (argc==1)			/* keine Parameter angegeben		*/
  {
    Format(devno,spt,Sides,Tracks,interlv,virgin,SerNo,Exec,Quiet);
    exit(0);
  }
  
  /* Parameter scannen */
  for (i=1;i<argc;i++)
  {
    if (argv[i][0]=='-')		/* Flag */
      switch(argv[i][1])
      {
        case 'V':			/* Versionsnummer	*/
	  printf("Okami Format V%s\n",VERSION);
	  printf("compiled %s\n",_CMP_DAT);
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
	  virgin=atoi(&argv[i][2]);
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
	case 'x':			/* Bootsektor ausfÅhrbar*/
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
      }
    else				/* Laufwerksnummer	*/
      devno=tolower(argv[i][0])-'a';

  } /* for */

  Format(devno,spt,Sides,Tracks,interlv,virgin,SerNo,Exec,Quiet,VolLbl);
  
  exit(0);
}


Format(devno,spt,Sides,Tracks,interlv,virgin,SerNo,Exec,Quiet,VolLbl)
int devno,spt,interlv,virgin,Exec,Quiet;
register int Tracks,Sides;
long SerNo;
char *VolLbl;
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
	YesOrNo();
      }
	
      if (virgin!=0xe5e5)
      {
	printf("You are about to format with a virgin of 0x%x.\n",virgin);
	YesOrNo();
      }
    
    
      /* Letzte Warnung */
      printf(
      "LAST CHANCE TO STOP:\nYou are about to format the disk in drive %c.\n",
      (char)devno+'A');
	
      YesOrNo();
    
    } /* if (!Quiet) */
      
    /* Los gehts */
    
    /* Speicher fÅr RÅckgabewert */
    Buf=calloc(FMTBUFSIZE,sizeof(int));
    if (Buf==NULL)
    {
      fprintf(stderr,"%s: Out of memory (need %d bytes)\n",PRGNAME,
						FMTBUFSIZE*sizeof(int));
      exit(1);
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
	  exit(1);
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
    Protobt(Buf,SerNo,(Sides-1)+(((Tracks/40)-1)<<1),Exec);
    strncpy(Buf+3,"Okami",5);
    Erg=Flopwr(Buf,0L,devno,1,0,0,1);
    free(Buf);
    if (Erg!=0)
    {
      fprintf(stderr,"\n%s %d writing bootsector\n",TError,Erg);
      exit(1);
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
}


YesOrNo()
{
  int c;

  printf("Do you really want to do that? (y or n)\n");
  c=fgetc(stdin);

  if (tolower(c)!='y')
    exit(0); /* ja, es IST miserabler Stil, aber es ist einfach */

}


Usage(PrgName)
char PrgName[];
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

  exit(1);
}
