/********************************************************************

	     Mikro-Shell: Startprogramm fuer Okami-Shell
	     
			  Version 1.5


		  von Wolfram Rîsler 1.11.89

		Usenet: wr@bara.oche.de
		Mausnetz: Wolfram Roesler @ AC2

			~~~ FREEWARE ~~~


  énderungen:
  
18.02.90 Optional öbergabe der Konfigurationsdatei
01.03.90 Internes Kommando: echo
31.03.90 öbergabe mehrerer Konfigurationsdateien
	 internes Kommando: incl
10.05.90 LÑnge des Para-Strings in Pexec korrekt
	 Zeilenumbruch mit \ am Ende einer Zeile
28.12.90 Kommandozeile mit -c und Kommandos
	 internes Kommando: ver
05.03.91 interne Kommandos exit und wait
19.06.91 1.4: Steuersequenzen in echo
19.10.91 1.5: Anpassung an Ansi-C (PureC), Option -v fÅr Versionsnummer

*******************************************************************/
static char _M_ID_[]="@(#)Okami Microshell 1.4 - msh.c";

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <tos.h>

#define _CMP_DAT __DATE__ " " __TIME__

#define StrEqu(a,b)	(!strcmp(a,b))		/* Test: Strings gleich */
#define StrNEqu(a,b,n)	(!strncmp(a,b,n))	/* Test: Strings gleich */
#define StrLast(S)	(*(S+strlen(S)-1))	/* String: letztes char.*/

/* Strings mit Programmname und Versionsnummer				*/

#define TPName		"Okami Microshell"
#define TPVersion	"1.5"

/* Weitere globale Variablen und defines				*/
 
const char KONFFILE[]=	"msh.inf";	/* Default bei argc==1		*/
#define CMDLEN		(3*80)
#define ARGV0		"msh"		/* eigentlich: argv[0]		*/
#define EXITCODE	(-999)		/* Script beenden		*/

short MsgFlag=1;			/* Flag fÅr Meldungen		*/

/* Prototypen */
int	msh	(char FName[]);
int	DoCom	(char *Para);
void	Xputs	(register char *s);
int	DoWait	(char *Para);
void	scan	(char **Ptr,int *adr);

/************************************************************************/

int main(int argc,char *argv[])
{
  register int i;
  short ExFlag=0;			/* 0: Script, 1: Kommando	*/
  int Erg;
  int DoFlag=0;
  
  if (argc>1)
  {
    if (argc==2 && StrEqu(argv[1],"-v"))
    {
      DoCom("ver");
      return 0;
    }
    for (i=1;i<argc;i++)
    {
      if (argv[i][0]=='\0')	/* ja, das _kommt_ vor */
        continue;

      if (StrEqu(argv[i],"-c"))
      {
	ExFlag=1;
	continue;
      }
      if (ExFlag)
	Erg=DoCom(argv[i]);
      else 
	Erg=msh(argv[i]);
      DoFlag=1;
    }
  }

  if (!DoFlag)
    Erg=msh(KONFFILE);

  return Erg;
}

/************************************************************************

	msh: ein MSH-Script ausfÅhren

************************************************************************/
int msh(char FName[])
{
  FILE *FPtr;				/* File-Ptr. Konf.datei 	*/
  char	St[CMDLEN+1];			/* eingelesene Zeile		*/
  char	Para2[CMDLEN+1];		/* Hilfsstring			*/
  register char *Para;
  char c;
  int Erg;
  
  while (isspace(*FName)) FName++;

  if ((FPtr=fopen(FName,"r"))==NULL)
  {
    fputs(ARGV0,stdout);
    fputs(": cannot open ",stdout);
    puts(FName);
     return -1;
  }
 
  while (fgets(St,3*80,FPtr)!=NULL)
  {
    Para=St;

    while (isspace(*Para)) Para++;	/* fÅhrende Leerzeichen	      */

    if (*Para=='\0' || *Para=='\n' || *Para=='#')
      continue;

    for (;;)				/* endende Leerzeichen		*/
    {
      c=StrLast(Para);
      if (isspace(c))
	StrLast(Para)='\0';
      else
	break;
    }
	
    while(StrLast(Para)=='\\')		/* \ am Ende: Zeilenumbruch	*/
    {
      StrLast(Para)='\0';
      fgets(Para2,80,FPtr);
      while (Para2[strlen(Para2)-1]=='\n')
	Para2[strlen(Para2)-1]='\0';
      strcat(Para,Para2);
    }

    /* Kommando ausfÅhren */

    Erg=DoCom(St);
    if (Erg==EXITCODE)
      break;	/* Script beenden */
  }

  fclose(FPtr);
  return Erg;
}

/************************************************************************

	DoCom: ein MSH-Kommando ausfÅhren

Return: EXITCODE: aktuelles Script beenden
	sonst: Returncode
************************************************************************/
int DoCom(char *Para)
{
  char	*Com;
  char Para2[CMDLEN+1];			/* Hilfsstring			*/
  int Ret=0;				/* RÅckgabewert			*/

  if (Para[0]=='-')			/* -: Meldung abschalten	*/
  {
    MsgFlag=0;
    return 0;
  }
  if (Para[0]=='+')			/* +: Meldung einschalten	*/
  {
    MsgFlag=1;
    return 0;
  }

  for (Com=Para;*Para && !isspace(*Para);Para++);
  if (*Para!='\0')
    *Para++='\0';
   
  if (StrEqu(Com,"echo"))		/* internes Kommando: echo	*/
    Xputs(Para);

  else if (StrEqu(Com,"exit"))		/* internes Kommando: exit	*/
    return EXITCODE;
      
  else if (StrEqu(Com,"incl"))		/* internes Kommando: incl	*/
    msh(Para);

  else if (StrEqu(Com,"ver"))		/* internes Kommando: ver	*/
  {
    puts(TPName " " TPVersion);
    puts("compiled " __DATE__ " " __TIME__);
  }

  else if (StrEqu(Com,"wait"))		/* internes Kommando: wait	*/
    Ret = DoWait(Para);
    
  else				/* Programm starten */
  {
    /* Kommentarmodus: Kommando ausgeben */
    if (MsgFlag)
    {
      fputs(Com,stdout);
      fputc(' ',stdout);
      puts(Para);
    }
    
    Para2[0]=(char)strlen(Para);
    strcpy(Para2+1,Para);
    if ((Ret=(int)Pexec(0,Com,Para2,0L))<0)
    if (MsgFlag)
    {
      fputs(Com,stdout);
      puts(": not found");
    }
  }

  return Ret;
}


/************************************************************************

	Xputs: wie puts, aber interpretiert Escape-Sequenzen mit \ und ^

************************************************************************/
void Xputs(register char *s)
{
  for(;*s;s++)
  {
    switch(*s)
    {
      case '\\':
        s++;
        switch(*s)
	{
	  case '\0':
	    return;
	  case 'n':
	    fputc('\n',stdout);
	    break;
	  case 't':
	    fputc('\t',stdout);
	    break;
	  case 'b':
	    fputc('\b',stdout);
	    break;
	  case 'c':
	    break;
	  default:
	    fputc(*s,stdout);
	}
	break;
      case '^':
        s++;
	switch(*s)
	{
	  case '\0':
	    return;
	  default:
	    fputc(*s-'A'+1,stdout);
	}
        break;
      default:
        fputc(*s,stdout);
    }
  }

  if (!(s[-1]=='c' && s[-2]=='\\'))
    fputc('\n',stdout);
}

/************************************************************************

	DoWait: das interne Kommando wait

	Syntax: wait ((ttmmmjj|*) HHMMSS|key)

Return: EXITCODE: User hat abgebrochen, sonst: Zeit ist erreicht

*************************************************************************/
int DoWait(char *Para)
{
  int Tag,Mon,Jahr,Hr,Min,Sek;
  int SollDat,SollUhr;

  while(isspace(*Para)) Para++;

  /* Worauf warten? */
  if (StrEqu(Para,"key"))	/* Tastendruck */
  {
    if ((Cconin()&0xff)==0x1b)
      return EXITCODE;
    else
      return 0;
  }

  /* ab hier: auf Datum und Uhrzeit warten */

  /* Datum beachten? */
  if (*Para=='*') /* nein */
  {
    Tag = -1;
    Para++;
  }
  else
  {
    scan(&Para,&Tag);
    scan(&Para,&Mon);
    scan(&Para,&Jahr);
    Jahr+=1900;
    Para++; /* Leerzeichen */
  } 

  /* Uhrzeit scannen */
  scan(&Para,&Hr);
  scan(&Para,&Min);
  scan(&Para,&Sek);
  if (*Para) Para++;

  /* Umformen in long-Format */
  if (Tag>=0)
    SollDat =  (Tag   &15) | ((Mon&7 )<<5) | (((Jahr-1980)&255)<<9);  
  SollUhr   = ((Sek/2)&15) | ((Min&63)<<5) |   ((Hr       &31 )<<11);

  if (MsgFlag)
  {
    fputs("Waiting",stdout);
    if (*Para)
    {
      fputs(" for ",stdout);
      fputs(Para,stdout);
    }
    puts("... press ESC to abort");
  }

  /* Warteschleife... */
  for(;;)
  {
    /*
      printf("Jetzt: %d %d, warte auf %d %d\n",
      Tgetdate(),Tgettime(),SollDat,SollUhr);
    */

    if (Tag>=0)
    {
      if (Tgettime()==SollUhr && Tgetdate()==SollDat)
        return 0;
    }
    else
      if (Tgettime()==SollUhr)
        return 0;
  
    /* ESC gedrÅckt? */
    if (Cconis())
      if ((Cnecin()&0xff) == 0x1b)
        return EXITCODE;
  }
}

/* entspricht sscanf(*Ptr,"%02d",adr);(*Ptr)+=2 */
void scan(char **Ptr,int *adr)
{
  *adr = 10*((*(*Ptr)++)-'0');
  *adr +=    (*(*Ptr)++)-'0';
}
