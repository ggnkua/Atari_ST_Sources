/* MagicSLM - SLM Printer Modul                */
/* by Bernd Spellenberg & Harald Schînfeld     */
/* (c) Maxon 1995                              */

# include <stdio.h>
# include <ext.h>

extern int ScaleFact;   /* Vergrîûerungsfaktor */

struct {                /* öbergabestruktur    */
   char *s_form;        /* fÅr Diablo-Treiber  */
   int s_xmin;
   int s_ymin;
   int s_nxln;
   int b_width;
   int b_height;
   int d_xmin;
   int d_ymin;
   int scale;
} diabloimg;

/* Ausdrucken der Bitmap auf dem SLM           */

void SlmWrite(unsigned char *Data,
              long XDim, long YDim)
{
   delay(100);          /* Warten bis XOFF     */
                        /* beim Mac ankommt    */
                        
   /* Diablo-Parameter setzen                  */
   
   diabloimg.s_form=(char *)Data;
   diabloimg.s_xmin=0;
   diabloimg.s_ymin=0;
   diabloimg.s_nxln=(int) XDim;
   diabloimg.b_width=(int) XDim*8;
   diabloimg.b_height=(int) YDim;
   diabloimg.d_xmin=0;
   diabloimg.d_ymin=0;
   diabloimg.scale = ScaleFact;

   /* Diablografik einschalten, Adresse der    */
   /* Struktur Åbergeben, Ausdruck starten     */
   
   fprintf(stdprn,"\033\015P\0333");
   fprintf(stdprn,"\033\022G$%08lx ",
           (long)&diabloimg);
   fprintf(stdprn,"\0334");
   fprintf(stdprn,"\014");
   fflush(stdprn);
}