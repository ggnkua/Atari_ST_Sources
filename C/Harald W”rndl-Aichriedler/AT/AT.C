/*
   AT.C

   (c) 1992 MAXON Computer

   Stellt Wecker auf eine gewisse Zeit.
   Syntax:
   at [-v] [-n] [hh:mm [dd.mm.jjjj]] [+###{s[econd] | mi[nute] | h[our]
      | d[ay] | mo[nth] | y[ear]}] DO 'kommandozeile'

   -v: Verbose, volle Information (nur falls -n, sonst immer)
   -n: Keine Sicherheitsabfrage

*/

#include <tos.h>
#include <ext.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <aes.h>

char usage[] = "\x1bp Anwendung: \x1bq\n"
"at [-v] [-n] [hh:mm [dd.mm.jjjj]] [+###{s[econd] | mi[nute] | h[our]\n"
"   | d[ay] | mo[nth] | y[ear]}] DO 'kommandozeile'\n"
"-Reihenfolge beachten!\n"; 


int appl_id = -1;

#define TRUE   -1
#define  FALSE 0
int verbose = FALSE, no_req = FALSE;

#define WORK_DIR  "C:\\WECKER\\"
#define KOMM_STR  WORK_DIR "TIME%04i.MUP"

#define WECK_MSG  2422  /* Nachrichtennummer fÅr Weckerstart */
#define WECK_REQ  2423  /* Nachrichtennummer fÅr RÅckgabewert */

typedef struct
{
   time_t   next, offset;
   int kommando;
} wecke;

void end_error(char *str);
int msg_num(char *msg);
void del_batch_file(int kommando_nr);
int request(void);
void send_msg(wecke *msg);

main(int argc, char *argv[])
{
   time_t   exec_time;
   struct tm zeit = {0,0,0,0,0,0,0,0,0};
   int comm_beg, search = 0, i;
   long offset=0L;
   char line[128]="\0";
   wecke evnt;
   
   /*** SUCHE BEGIN DER AUFZURUFENDEN KOMMANDOZEILE: ***/
   for(comm_beg=0; comm_beg<argc &&
               strcmp(argv[comm_beg], "DO"); comm_beg++);
   comm_beg++;
   if(comm_beg >= argc || comm_beg <2) end_error(usage);

   /*** WERTE ARGUMENTE AUS: ***/
   while(*argv[++search] == '-')
      switch(argv[search][1])
      {
         case 'N':   case 'n':   no_req = TRUE; break;
         case 'V':   case 'v':   verbose = TRUE; break;
         default: printf("Falsche Option: %s\n",argv[search]);
                  end_error(usage);
      }
   if(!no_req) verbose = TRUE;

   /*** FALLS ZUMINDEST ZEIT GEGEBEN: ***/
   if(strchr(argv[search],':'))
   {
      sscanf(argv[search++],"%2i:%2i",&zeit.tm_hour,&zeit.tm_min);

      /*** FALLS AUCH DATUM DABEI: ***/
      if(strchr(argv[search],'.'))
      {
         sscanf(argv[search++],"%2i.%2i.%4i"
            ,&zeit.tm_mday, &zeit.tm_mon, &zeit.tm_year);
         zeit.tm_mon--;
         if(zeit.tm_year > 1900) zeit.tm_year -= 1900;
      }
      else
      {
         /*** SONST DATUM VON HEUTE: ***/
         struct date act_date;
         getdate(&act_date);
         zeit.tm_mday = act_date.da_day;
         zeit.tm_mon = act_date.da_mon-1;
         zeit.tm_year = act_date.da_year-1900;
      }
      
      /*** ZEIT DARF NICHT IN VERGANGENHEIT LIEGEN: */
      exec_time = mktime(&zeit);
      if(exec_time < time(NULL))
         exec_time = time(NULL);
   }
   else
      /*** FALLS GAR NICHTS GEGEBEN, VERWENDE AKTUELLE ZEIT ***/
      exec_time = time(NULL);

   if(verbose)             /* INFO AUSGEBEN: */
   {
      zeit = *gmtime(&exec_time);
      printf("\x1bp AT: Eventsteuerung \x1bq\n"
         "Zeit: %i:%02i  Datum: %i.%i.%i\n"
         ,zeit.tm_hour+1, zeit.tm_min
         ,zeit.tm_mday, zeit.tm_mon+1, zeit.tm_year+1900);
   }
   
   /*** OFFSET BERECHNEN: ***/
   if(argv[search][0] == '+')
   {
      char s[20];
      sscanf(argv[search]+1, "%li%s", &offset,s);
      strupr(s);
      switch(*s)
      {
         case 'S': break;                    /* Sekunde */
         case 'M':
            switch(s[1])
            {
               case 'I': offset *= 60L; break;     /* Minute */
               case 'O': offset *= 2629350L; break;/* Monat */
               default: offset = 0L;
            }; break;
         case 'H':   offset *= 3600L; break;       /* Stunde */
         case 'D':   offset *= 86400L; break;      /* Tag */
         case 'Y':   offset *= 31552200L; break;      /* Jahr */
         default: if(*s>=32) offset = 0L;
      }
      if(offset == 0)
      {
         printf("Falsche Zeiteingabe: %s\n",argv[search]+1);
         end_error(usage);
      }
   }
   

   /*** REST VON KOMMANDOZEILE ZUSAMMENFöGEN: ***/
   for(strcat(line,argv[i=comm_beg]); i<(argc-1); strcat(line,argv[++i]))
      strcat(line," ");

   if(verbose) printf("Kommandozeile: %s\n", line);
   if(verbose && offset)
      printf("AusfÅhrung alle %li Sekunden.\n", offset);

   if((i=msg_num(line)) < 0)
      end_error("Konnte Datei in "WORK_DIR" nicht îffnen!\n");
   
   /*** WECKSTRUKTUR AUSFöLLEN: ***/
   evnt.next = exec_time;
   evnt.offset = offset;
   evnt.kommando = i;
   
   /*** SICHERHEITSABFRAGE: ***/
   if(!no_req)
   {
      printf("Sicherheitsabfrage! Falls alles stimmt, drÅcken Sie ':'");
      if(getchar() != ':')
         end_error("Sie haben die Operation abgebrochen...\n");
   }
   
   appl_id = appl_init();
   
   /*** NACHRICHT SENDEN: ***/
   send_msg(&evnt);
   if(verbose) printf("Nachricht an Wecker gesendet...");

   /*** BESTéTIGUNG ERWARTEN: */
   switch(i=request())
   {
      case -1:
         del_batch_file(evnt.kommando);
         end_error("Zeitpuffer voll. Andere Ereignisse Stornieren!\n");
      case -2:
         del_batch_file(evnt.kommando);
         end_error("WECKER.ACC antwortet nicht!\n");
      default:
         if(verbose)
            printf("Empfang bestÑtigt. Noch %i Ereignisse davor.\n"
                  "Alles OK\n", i);
   }
   appl_exit();
   return 0;
}

void end_error(char *str)
{
   printf("%s",str);
   if(appl_id >= 0) appl_exit();
   exit(0);
}

int msg_num(char *msg)
{
   char f_name[128];
   int t, han;

   for(t=0; t<10000; t++)
   {
      sprintf(f_name, KOMM_STR, t);
      if(Fsfirst(f_name,0))
      {
         han = Fcreate(f_name,0);
         if(han<0)
            {t=-1; break;}
         Fwrite(han, strlen(msg), msg);
         Fclose(han);
         if(verbose)
            printf("Zum lîschen der Weckzeit lîschen Sie %s\n", f_name);
         break;
      }
   }
   return t;
}

void del_batch_file(int kommando_nr)
{
   char dateiname[128];
   sprintf(dateiname, KOMM_STR, kommando_nr);
   Fdelete(dateiname);
}

int request(void)
{
   int in[8], d, e_art;
   do
   {
      e_art = evnt_multi(MU_TIMER | MU_MESAG,
               0,0,0,0,0,0,0,0,0,0,0,0,0,
               in, 3000, 0, /* Low/High-Counter Timer */
               &d,&d,&d,&d,&d,&d);
      
   } while(e_art != MU_TIMER &&
         !(e_art == MU_MESAG && in[0] == WECK_REQ));
   if(e_art == MU_TIMER)
      return -2;
   return in[3];
}

void send_msg(wecke *msg)
{
   int ap_id = appl_find("WECKER  ");
   int buf[8] = {WECK_MSG,0,0};

   if(ap_id < 0)
      end_error("WECKER.ACC muû unter diesem Namen gestartet sein!\n");
   buf[1] = appl_id;
   *(wecke*)(&buf[3]) = *msg;
   appl_write(ap_id, 16, buf);
}
