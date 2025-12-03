/********************************************************************

             Mikro-Shell: Startprogramm fuer Okami-Shell

                          WR 1.11.89
                          
  énderungen:
  
  18.02.90  Optional öbergabe der Konfigurationsdatei
  01.03.90  Internes Kommando: echo

*******************************************************************/

#define PRGNAME  "msh"                  /* normalerweise: argv[0]       */
#define KONFFILE "msh.inf"              /* Default bei argc==1          */

#include <stdio.h>
#include <osbind.h>

main(argc,argv)
int argc;
char *argv[];
{
  FILE *FPtr;                           /* Pointer Konf.-Datei          */
  char  *FName;                         /* Name Konf.-Datei             */
  char  St[80+1];                       /* eingelesene Zeile            */
  char  Com[80+1];                      /* daraus: Kommando             */
  register char *Para;                  /* Parameter fÅr Com            */
  register int   i;                     /* fÅr Schleife                 */
  register char  Flag=1;                /* Flag fÅr Meldungen           */
  
  switch (argc)
  {
    case 1:     /* ohne Parameter */
      FName=KONFFILE;
      break;
    case 2:     /* mit 1 Parameter */
      FName=argv[1];
      break;
    default:    /* mehr als 1 Parameter */
      puts("Verwendung: msh [Konfigurationsdatei]");
      exit();
  }
  
  
  if ((FPtr=fopen(FName,"r"))==NULL)
    exit();
    
  while (fgets(St,80,FPtr)!=NULL)
  {
    Para=St;

    while (Para[0]==' ') Para++;        /* fÅhrende Leerzeichen         */
    
    if (Para[0]=='\0' || Para[0]=='\n' || Para[0]=='#')
      continue;
      
    if (Para[0]=='-')                   /* -: Meldung abschalten        */
    {
      Flag=0;
      continue;
    }
    if (Para[0]=='+')                   /* +: Meldung einschalten       */
    {
      Flag=1;
      continue;
    }
      
    if (Flag)
      puts(Para);
      
    Com[0]='\0';
    i=0;

    while(Para[0]!='\0' && Para[0]!='\n' && Para[0]!=' ')
    {
      Com[i++]=Para[0];
      Para++;
    }
   
    if (! strcmp(Com,"echo"))           /* internes Kommando: echo      */
      fputs(Para,stdout);
    
    else if (Pexec(0,Com,Para,NULL)<0)
      if (Flag)
        puts("** not found **");
  }

  fclose(FPtr);

}

