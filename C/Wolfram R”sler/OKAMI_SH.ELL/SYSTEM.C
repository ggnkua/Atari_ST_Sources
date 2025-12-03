/****************************************************************

         Okami Shell - Kommando: system

     zum Einbinden der Shell in eigene Programme

                    wr 28.12.89
                    
 Aufruf: system(Shell-Kommando)
 

***************************************************************/

#define  TEST 0
#include <osbind.h>

long system(com)
char *com;
{
  long Erg;
  static char St[3*80+1];
  extern char *_shpath;
  
  sprintf(St," \"%s\"",com);
  Erg=Pexec(0,_shpath,St,0L); 
  
  return Erg;
}


#if TEST

char *_shpath;

main()
{
  _shpath="sh.ttp";
  
  system("echo '^nShell-Dateien:'");
  system("ls -l | grep sh");
  system("echo '^nBelegung von Disk A:'");
  system("df a:");
  system("echo '^n^nBitte ENTER drÅcken:^c'");
  system("read");
  
}
#endif TEST
