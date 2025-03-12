/* MagicSLM - Kontrollmodul                    */
/* by Bernd Spellenberg & Harald Sch”nfeld     */
/* (c) Maxon 1995                              */

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <aes.h>
# include "global.h"

void PrintStat(long , long , char *);

FILE *InputFH;    /* Globales Input Filehandle */
int SerialFlag=0; /* Flag ob ser. Schnittstelle*/
                  /* gerade abgefragt wird     */


/* Vorbereiten der Wandlung:                   */
/* Bei File-Import direkt starten              */
/* Bei Eingabe ber ser. Port nur Scannen      */
/* einschalten                                 */

void StartScan(void)
{
   if(Input==MODEMINPUT) { /* Ser. Port initi- */
      SInit();      /* alisieren, Flag setzen, */
      SerialFlag=1;       /* Timer zum Scannen */
      TimerMode=MU_TIMER;       /* einschalten */

   } else if(Input==FILEINPUT) {
      TimerMode=0;       /* Timer ausschalten, */
      StartConversion();  /* Wandlung beginnen */
   }
}

/* Scannen des ser. Ports stoppen              */

void StopScan(void)
{
   TimerMode=0;                   /* Timer aus */
   if(SerialFlag)     /* Falls n”tig, serielle */
      SClose();     /* Schnittstelle freigeben */
   SerialFlag=0;
}

/* Speicher fr Wandlung allozieren            */

int AllocBuffer (void)
{
                   /* Speicher fr ganze Seite */
   if (!(LJPage = malloc (MAXWIDTH*MAXHEIGHT/8)))
      return 0;
                /* Speicher fr aktuelle Zeile */
   if (!(CurrRaster = malloc (MAXHEIGHT/8))) {
      free (LJPage);
      return 0;
   }
   return 1;
}

/* Speicher freigeben                          */

void FreeBuffer (void)
{
   free (LJPage);
   free (CurrRaster);
}

/* Wandeln                                     */

void StartConversion(void)
{
   READ_FUNC  *Read;   /* Zu verwendende Lese- */
   STOP_FUNC  *Stop;      /* Synchronisations- */
   WRITE_FUNC *Write; /* und Schreib- Funktion */

   int BefNr;     /* Listennr. des PCL-Befehls */
   long CommandNo; /*Anz. gelesener PCL-Befehle*/
   char Arg[100],           /* Befehlsargument */
        Term[5];         /* Endung des Befehls */
   
      /* Lese/Sync-Funktionen je nach Inputtyp */
      /* festlegen. Wenn n”tig PCL-File ”ffnen */

   InputFH = 0L;
      
   if (Input == FILEINPUT) {
      Read = GetNextByte;
      Stop = 0L;
      if (!(InputFH = fopen (InPath, "rb"))) {
         return;
      }
   } else if (Input == MODEMINPUT) {
      Read = SGet;
      Stop = XOnOff;
   }

  /* Schreib-Funktion nach Outputtyp festlegen */
  
   if (Output == SLMOUTPUT) {
      Write = SlmWrite;
   } else if (Output = PCXOUTPUT) {
      Write = PcxWrite;
   }
   
                          /* Buffer allozieren */
   if (!AllocBuffer()) {
      form_alert(1,
      "[1][|Nicht gengend|Speicher!][Abbruch]");
      return;
   }
   
                     /* Speicherinhalt l”schen */
   memset (LJPage, 0, MAXWIDTH*MAXHEIGHT/8);
   memset (CurrRaster, 0, MAXHEIGHT/8);

   InitPage();        /* Init der PCL-Wandlung */
   InitFile();      /* Init des Eingabebuffers */

   CommandNo =0;     /* Befehlsz„hler auf Null */

   InitDlg(Print); /* Status-Dialog darstellen */

   while (!FileEndFlag) {      /* Solange kein */
   
    /* Datenende erreicht, n„chsten PCL Befehl */ 
                                   /* auslesen */
                                   
      BefNr = ParseNextCmd (Arg, Term, Read);
   
      if (BefNr > 255) {  /* Button gedrckt ? */

         switch (BefNr) {   /* FormFeed Button */

            case 255+FF: /* Button selektieren */
               SelectButton(Print,FF,1);
               BefNr = 51;     /* FF ausfhren */
            break;
            
            case 255+RESET:    /* Reset Button */
               SelectButton(Print,RESET,1);
               CommandNo=0; /* Z„hler auf Null */
               BefNr = 52;  /* Reset ausfhren */
            break;
            
            case 255+ABBR:   /* Abbruch Button */
               SelectButton(Print,ABBR,1);
               FreeBuffer(); /*Buffer freigeben*/
               StopScan();  /* Scannen stoppen */

               if (InputFH)       /* Inputfile */
                  fclose (InputFH);/*schliessen*/

               SelectButton(Print,ABBR,0);
               CloseDlg(); /* Dialog schliessen*/

               return;
            break;
         }
      }

      CommandNo++;    /* Befehlsz„hler erh”hen */
      
   /* Nach je 16 Befehlen Dialog aktualisieren */
      if(!(CommandNo%16)) {
         
          /* Je nach Modus Statustext ausgeben */
         if (Input == FILEINPUT)
            PrintStat(CommandNo, CurrPageNo,
                      "      Lese");
         else if (Input == MODEMINPUT)
            PrintStat(CommandNo, CurrPageNo, 
                      "  Empfange");
      }

       /* Bei Seitenende Statustext „ndern und */
                             /* Biene anzeigen */
      if(BefNr>50) {
         graf_mouse(BUSYBEE,0L);
         if (Output == SLMOUTPUT)
            PrintStat(CommandNo, CurrPageNo,
                      "    Drucke");
         else if (Output = PCXOUTPUT)
            PrintStat(CommandNo, CurrPageNo,
                      "  Schreibe");
      }
      
                       /* PCL-Befehl ausfhren */
      ExCmd(BefNr, Arg, Term, Read, Stop, Write);
      
                        /* Nach Seitenende ... */
      if(BefNr>50) {

         if(Stop)               /* XOFF senden */
            (*Stop)(1);    
                        /* Statustext „ndern */
         PrintStat(CommandNo, CurrPageNo, 
                   "     Warte");

         while(CheckButton());/*Warten bis kein*/
           /* Button mehr gedrckt (Entprellen)*/

         SelectButton(Print,ABBR,0); /* Buttons*/
         SelectButton(Print,FF,0); /* deselekt.*/
         SelectButton(Print,RESET,0);

         if(Stop)                /* XON senden */
            (*Stop)(0);

         graf_mouse(ARROW,0L);    /* Mauspfeil */
      }
   }

        /* Falls bei Fileende noch ungedruckte */
         /* Daten in der Seite: Seite ausgeben */
   if (PageUsed) {
      graf_mouse(BUSYBEE,0L);
      if (Output == SLMOUTPUT)   /* Statustext */
         PrintStat(CommandNo, CurrPageNo,
                   "    Drucke");
      else if (Output = PCXOUTPUT)
         PrintStat(CommandNo, CurrPageNo,
                   "  Schreibe");

                               /* FF ausfhren */        
      ExCmd (51, Arg, Term, Read, Stop, Write);
      
      graf_mouse(ARROW,0L);
   }
   
   CloseDlg();      /* Statusdialog schliessen */
   
   if (InputFH)        /* Inputfile schliessen */
      fclose (InputFH);

   FreeBuffer();           /* Buffer freigeben */
}

/* Statustexte eintragen und darstellen        */

void PrintStat(long CommandNo, long CurrPageNo,
               char *Text)
{
   sprintf(
      Print[BYTES].ob_spec.tedinfo->te_ptext,
      "%ld",CommandNo);
   sprintf(
      Print[PAGENR].ob_spec.tedinfo->te_ptext,
      "%ld",CurrPageNo+1);
   sprintf(
      Print[ZUSTAND].ob_spec.tedinfo->te_ptext,
      Text);
   UpdateDlg(Print,PAGENR);
   UpdateDlg(Print,ZUSTAND);
   UpdateDlg(Print,BYTES);
}