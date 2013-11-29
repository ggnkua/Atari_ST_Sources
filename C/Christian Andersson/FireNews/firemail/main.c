#include "firemail.h"
/********************************************************************/
/* Huvud-funktionen, dvs den funktion som startar upp allt          */
/********************************************************************/
int rename_import(void);
int main(int argc, char *argv[]) /***********************************/
{
  fel.type=NOLL;
  if(!init())
    deinit();
  else
    check();
  deinit();
  return(fel.type);
}

/********************************************************************/
/* en liten log-funktion som skall „ndras                           */
/********************************************************************/
void log(char *text)
{
//  FILE *logfile;
//  
  if(text==NULL)
    alertbox(1,fel.text);
//  else
//    printf("%s",text);
//  if(config.logfile[NOLL]!=NOLL)
//  {
//    logfile=fopen(config.logfile,"a");
//    rewind(logfile),fseek(logfile,NOLL,SEEK_END);
//    if(fel.text==NULL)
//      fputs(fel.errortext,logfile);
//    else
//      fputs(text,logfile);
//    fclose(logfile);
//  }
}
