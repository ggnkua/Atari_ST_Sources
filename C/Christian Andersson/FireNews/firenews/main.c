#include "firenews.h"
/********************************************************************/
/* Huvud-funktionen, dvs den funktion som startar upp allt          */
/********************************************************************/
int main(const int argc, const char *argv[], const char *env[]) /***********************************/
{
  if(init(argc,argv))
    check();
  deinit();
#ifdef LOGGING
  Log(LOG_GENERAL,"*****************************************\n");
  Log(LOG_GENERAL,"* FireSTorm News Reader has now Exited  *\n");
  Log(LOG_GENERAL,"*****************************************\n");
  Log(LOG_GENERAL,"\n");
#endif
  return(fel.type);
}

#ifdef LOGGING
/********************************************************************/
/* Skall fungera ungef„r som printf                                 */
/* %d - int                                                         */
/* %l - long                                                        */
/*  NOT %c - char                                                   */
/* %s - char *                                                      */
/********************************************************************/
#include <stdarg.h>
void Log(const char *logtype,char *logstring,...)
{
  char *point=logstring;
  int num_parm=NOLL;
  va_list ap;
  FILE *logfile;
  int logging=FALSE;

  if(log.on)
  {
    if(log.all)
      logging=TRUE;
    else if(strstr(log.what,logtype)) logging=TRUE;
    else if(!strcmp(LOG_GENERAL,logtype)) logging=TRUE;
    if(logging)
    {
      logfile=fopen("firenews.log","a");
      if(logfile!=NOLL)
      {
        fprintf(logfile,"%s - ",logtype);
        while(*point!=NOLL)
        {
          if(*point=='%')
          {
            point++;
            if((*point=='c')||(*point=='d')||(*point=='s')||(*point=='l'))
              num_parm++;
            if(*point==NOLL)
              point--;
          }
          point++;
        }
        if(num_parm>0)
          va_start(ap,logstring);
        point=logstring;
        
        while(*point!=NOLL)
        {
          if(*point=='%')
          {
            point++;
            if(*point=='%')
              fputc('%',logfile);
            else if(*point=='d')
              fprintf(logfile,"%d",va_arg(ap,int));
            else if(*point=='l')
              fprintf(logfile,"%ld",va_arg(ap,long));
//            else if(*point=='c')
//              fprintf(logfile,"%c",va_arg(ap,char));
            else if(*point=='s')
              fprintf(logfile,"%s",va_arg(ap,char *));
            else if( *point=='b')
            {
              int value,counter;
              value=va_arg(ap,int);
              for(counter=32; counter>0; counter--)
                fprintf(logfile,"%d",value&(2^counter)==(2^counter));
            }
            else if(*point!=NOLL)
            {
              fputc('%',logfile);
              fputc(*point,logfile);
            }
            else
              point--;
          }
          else
            fputc(*point,logfile);
          point++;
        }
        fclose(logfile);
        va_end(ap);
      }
    }
  }
}
#endif
