/* MagicSLM - PCL Interpreter Modul            */
/* by Bernd Spellenberg & Harald Schînfeld     */
/* (c) Maxon 1995                              */

# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <ctype.h>

# include "global.h"        /* Globaler Header */
# include "pcl.h" /* spez. Header fÅr Interpr. */

      /* Array mit Knoten fÅr PCL-Befehls-Baum */
LISTELEM  ElemList[LISTELEMANZ];
                           /* Wurzel des Baums */
LISTELEM  TopElem = {0L, 0L, 0, (char) 0};

      /* Liste aller unterstÅtzten PCL Befehle */
PCLBEFEHL PclBefehle[] = {
{ 0L, NOARG},     /*  00 */
{ "\xd", NOARG},
{ "\033E", NOARG},
{ "\033=", NOARG},
{ "\0339", NOARG},
{ "\033*p", ARG}, /*  05 */
{ "\033*c", ARG},
{ "\033*t", ARG},
{ "\033*r", ARG},
{ "\033*b", ARG},
{ "\033*v", ARG}, /*  10 */
{ "\033*1P", NOARG},
{ "\033&l", ARG},
{ "\033&a", ARG},
{ "\033&k", ARG},
{ "\033&s", ARG}, /*  15 */
{ "\033&f", ARG},
{ "\033&p", ARG},
{ "\033(s", ARG},
{ "\033)s", ARG},
{ "\033&d0D", NOARG},   /*  20 */
{ "\033&d3D", NOARG},
{ "\033&d@", NOARG},
{ "\033(3@", NOARG},
{ "\033(0D", NOARG},
{ "\033(1D", NOARG},    /*  25 */
{ "\033(1E", NOARG},
{ "\033(0F", NOARG},
{ "\033(1F", NOARG},
{ "\033(0G", NOARG},
{ "\033(1G", NOARG},    /*  30 */
{ "\033(0I", NOARG},
{ "\033(0K", NOARG},
{ "\033(2K", NOARG},
{ "\033(0N", NOARG},
{ "\033(0S", NOARG},    /*  35 */
{ "\033(1S", NOARG},
{ "\033(2S", NOARG},
{ "\033(3S", NOARG},
{ "\033(4S", NOARG},
{ "\033(5S", NOARG},    /*  40 */
{ "\033(6S", NOARG},
{ "\033(0U", NOARG},
{ "\033(2U", NOARG},
{ "\033(8U", NOARG},
{ "\033(10U", NOARG},   /*  45 */
{ "\033(11U", NOARG},
{ "\033(12U", NOARG},
{ "\033)3@", NOARG},
{ "\033Z", NOARG},
{ "\033Y", NOARG},      /*  50 */
{ "\xc", NOARG},
{ 0L, NOARG}
};

long CurrPageNo = 0;  /* Aktuelle Seitennummer */
unsigned char *LJPage; /* Zeiger auf Seitenbuf.*/
unsigned char *CurrRaster; /* ...auf Zeilenbuf.*/
long LineAnz=MAXHEIGHT,      /* Max. Anzahl an */
     ColAnz=MAXWIDTH/8;  /* Zeilen und Spalten */
long CurrXPos = 0, /* Akt. X und Y Position in */
     CurrYPos = 0;                /* der Seite */
int  GfxMode = 0;    /* Akt. Kompressionsmodus */
int ScaleFact = 1;      /* Vergrîûerungsfaktor */
int PageUsed = 0; /* Flag ob Seite beschrieben */


static long ElemListEndPtr=0;
   /* NÑchster verfÅgbarer Knoten fÅr den Baum */

/* Initialisieren des Interpreters             */

void InitPage(void)
{
   FileEndFlag=0; /* Input File nicht beendet  */
   CurrPageNo = 0;        /* Akt Seitennr. = 0 */
   LineAnz=MAXHEIGHT;       /* Max. Zeilen und */
   ColAnz=MAXWIDTH/8;               /* Spalten */
   CurrXPos = 0;        /* Links oben beginnen */
   CurrYPos = 0;
   GfxMode = 0;        /* Unkomprimierte Daten */
   ScaleFact = 1;         /* Keine Vergîûerung */
   PageUsed =0;         /* Seite ist noch leer */
}

/* PCL-Befehlsbaum aufbauen                    */

void InitPcl(void)
{
   int i;
   
   i = 1;
   do {           /* FÅr alle PCL-Befehle .... */
      PutNextCmdInList (i); /* Befehl eintragen*/
      i++;
   }
   while (PclBefehle[i].BefPrefix);
}

/* PCL-Befehl ausfÅhren                        */

void ExCmd (int CmdNo, char *CmdArg,
            char *CmdTerm,
            READ_FUNC *GetNextByte,
            STOP_FUNC *Stop,
            WRITE_FUNC *WritePage)
{
   long temp, i, j;
   long LineLength=0; /* LÑnge der Rasterzeile */
   char Ctrl, Zchn;   /* Control und Datenbyte */
   static long LastLineLength = 0; /* LÑnge der*/
                        /* letzten Rasterzeile */
   unsigned char *ThisPtr;    /* Akt. Ende der */
                          /* derz. Rasterzeile */
   static unsigned char /*Buffer fÅr die kompr.*/
      CurrLine[3*(MAXHEIGHT/8)];   /* Rohdaten */

      /* Switch-Statement fÅr alle PCL-Befehle */
   switch (CmdNo) {
   case 51:                       /* Form feed */
      if(Stop)       /* Falls Synch. Befehl... */
         (*Stop)(1);   /* öbertragung anhalten */
                             /* Seite ausgeben */
      (*WritePage) (LJPage, ColAnz, LineAnz);
      if(Stop)
         (*Stop)(0); /* öbertragung fortfÅhren */
            
      CurrPageNo++;           /* nÑchste Seite */
      CurrXPos = CurrYPos = 0; /* links oben.. */
                             /* Buffer lîschen */
      memset (LJPage, 0, LineAnz*ColAnz);
      memset (CurrRaster, 0, MAXHEIGHT/8);
      PageUsed = 0;   /* Seite ist wieder leer */
   break;

   case 52:    /* Reset, Seite einfach lîschen */
      CurrXPos = CurrYPos = 0;
      memset (LJPage, 0, LineAnz*ColAnz);
      memset (CurrRaster, 0, MAXHEIGHT/8);
      PageUsed = 0;
   break;

   case 17:         /* Nicht benîtigter Befehl */
      if (CmdTerm[0] == 'X') {     /* Argument */
         temp = atol (CmdArg);     /* auslesen */
         for (i = 0; i < temp; i++) {
            CurrLine[i] = (*GetNextByte) ();
         }
      } 
   break;

   case 9:                     /* Rastergrafik */
      switch (CmdTerm[0]) {
      case 'W':                 /* Rasterdaten */
         PageUsed = 1;    /* Seite beschrieben */
         temp = atol (CmdArg);     /* Argument */
         for (i = 0; i < temp; i++) {/*auslesen*/
            CurrLine[i] = (*GetNextByte) ();
         }
 
  /* Auswerten in AbhÑngigkeit des Kompr.modes */
         switch (GfxMode) {
         case 0:             /* unkompr. Daten */
                   /* Daten einfach Åbernehmen */
            memset (CurrRaster, 0, MAXHEIGHT/8);
            for (i = 0; i < temp; i++) {
               CurrRaster[i] = CurrLine[i];
            } 
            LastLineLength = LineLength = temp;
         break;
         
         case 2:                 /* TIFF Kompr.*/
            memset (CurrRaster, 0, MAXHEIGHT/8);
            ThisPtr = CurrRaster;
            i = 0;
            while (i < temp) { /*FÅr alle Bytes*/
                         /* Kontrollbyte lesen */
               Ctrl = CurrLine[i++];
               if (Ctrl >= 0) { 
                  /* Die nÑchsten 'Ctrl' Bytes */
                        /* einmalig Åbernehmen */
                  for (j = 0; j <= Ctrl; j++) {
                     *(ThisPtr++) =CurrLine[i++];
                  } 
               } else if (Ctrl != -128) {
                  /* NÑchstes Byte -'Ctrl' mal */
                                /* wiederholen */
                  Zchn = CurrLine[i++];
                  for (j = 0; j <= -Ctrl; j++) {
                     *(ThisPtr++) = Zchn;
                  } 
               } 
            }
            LastLineLength = LineLength =
               (long)ThisPtr - (long)CurrRaster;
         break;
            
         case 3:                /* Deltakompr. */
            i = 0;
              /* Letzte Rasterzeile Åbernehmen */
            ThisPtr = CurrRaster;
            while (i < temp) {
                         /* Kontrollbyte lesen */
               Ctrl = CurrLine[i++];
        /* Als Offset fÅr die nÑchste énderung */
               ThisPtr += (((unsigned char)Ctrl)
                                          &0x1f);
             /* Falls Offset grîûer als 255... */
               if ((((unsigned char)Ctrl)&0x1f)
                                         == 31) {
                  do {
                     ThisPtr += (unsigned char)
                            Zchn = CurrLine[i++];
                  } while ((unsigned char)Zchn
                              == 255);
               }
               /* Zu Ñndernde Bytes Åbernehmen */
               Ctrl = ((((unsigned char)Ctrl)
                                    &0xe0)>>5)+1;
               for (j = 0; j < Ctrl; j++) {
                  *(ThisPtr++) = CurrLine[i++];
               } 
            }
/* LÑnge der Zeile ist Max. aus alter und akt. */
            LineLength = (long)ThisPtr
                              - (long)CurrRaster;
            if (LineLength > LastLineLength) {
               LastLineLength = LineLength;
            } else {
               LineLength = LastLineLength;
            } 
         break;

         default: 
         break;
         } 

         /* Akt. Rasterzeile in Seite kopieren */
         CopyRaster (LJPage+CurrYPos*ColAnz,
                     CurrRaster, LineLength,
                     CurrXPos);
         CurrYPos++; /* Eine Zeile weitergehen */
      break;

      case 'M':    /* Kompressionsmodus Ñndern */
         GfxMode = CmdArg[0]-'0';
      break;

      case 'Y':   /* Raster Y Offset bestimmen */
         CurrYPos+= atol (CmdArg);
      break;

      default:
      break;
      }
   break;

   case 8:
      switch (CmdTerm[0]) {
      case 'A':                /* Grafikanfang */
         memset (CurrRaster, 0, MAXHEIGHT/8);
         if (CmdArg[0] == '0')
            CurrXPos = 0L;
      break;

      case 'F':      /* Landscape/rotate Image */

      case 'B':             /* Ende der Grafik */

      default:
      break;
      }
   break;
   
   case 7:          /* Grafikaufloesung in dpi */
      switch ((int)atol(CmdArg)) {
         case 75:
            ScaleFact = 4;
         break;

         case 100:    /* Wird von Diablo nicht */
            ScaleFact = 3;    /* unterstÅtzt ! */
         break;

         case 150:
            ScaleFact = 2;
         break;

         case 300:
            ScaleFact = 1;
         break;

         default:
         break;
      }
   break;

   case 1:                  /* Carriage Return */
   break;

   case 5:         /* Position in Seite setzen */
      switch (CmdTerm[0]) {

      case 'X':     /* Vert Pos in Dots setzen */
            /* + oder - relativ, sonst absolut */
         if((CmdArg[0]=='+') || (CmdArg[0]=='-'))
            CurrXPos += atol (CmdArg)/ScaleFact;
         else
            CurrXPos = atol (CmdArg)/ScaleFact;
      break;

      case 'Y':            /* Horz. Pos setzen */
         if((CmdArg[0]=='+') || (CmdArg[0]=='-'))
            CurrYPos += atol (CmdArg)/ScaleFact;
         else
            CurrYPos = atol (CmdArg)/ScaleFact;
         memset (CurrRaster, 0, MAXHEIGHT/8);
      break;

      case 'C':  /* Vert Pos in Columns setzen */
         if((CmdArg[0]=='+') || (CmdArg[0]=='-'))
            CurrXPos += atol (CmdArg);
         else
            CurrXPos = atol (CmdArg);
      break;

      case 'R':            /* Horz. Pos setzen */
         if((CmdArg[0]=='+') || (CmdArg[0]=='-'))
            CurrYPos += atol (CmdArg);
         else
            CurrYPos = atol (CmdArg);
         memset (CurrRaster, 0, MAXHEIGHT/8);
      break;

      case 'H':  /* Vert Pos in Decipt. setzen */
         if((CmdArg[0]=='+') || (CmdArg[0]=='-'))
            CurrXPos += atol (CmdArg)
                             /ScaleFact*300/720;
         else
            CurrXPos = atol (CmdArg)
                             /ScaleFact*300/720;
      break;

      case 'V':            /* Horz. Pos setzen */
         if((CmdArg[0]=='+') || (CmdArg[0]=='-'))
            CurrYPos += atol (CmdArg)
                             /ScaleFact*300/720;
         else
            CurrYPos = atol (CmdArg)
                             /ScaleFact*300/720;
         memset (CurrRaster, 0, MAXHEIGHT/8);
      break;

      default:
      break;
      }
   break;

   case 12:                    /* Seitenformat */
      switch (CmdTerm[0]) {
         case 'L':         /* Perforation Skip */
         break;

         case 'O':
            switch((int)atol(CmdArg)) {
               case 0:             /* Portrait */
               case 2:
                  LineAnz=MAXHEIGHT;
                  ColAnz=MAXWIDTH/8;
               break;
               
               case 1:            /* Landscape */
               case 3:
                  LineAnz=MAXWIDTH;
                  ColAnz=MAXHEIGHT/8;
               break;
               
               default:
               break;
            }
            memset (LJPage, 0, LineAnz*ColAnz);
            memset (CurrRaster, 0, MAXHEIGHT/8);
         break;

         default:
         break;
      }
   break;

   default:
   break;
   } 

      /* Verhindern, daû Åber die Seite hinaus */
                           /* geschrieben wird */  
   if(CurrYPos>=LineAnz)
      CurrYPos=LineAnz-1;

}

/* Eine Rasterzeile um 'Offset' Pixel nach     */
/* rechts verschoben kopieren                  */

void CopyRaster (unsigned char *To,
                 unsigned char *From,
                 long Length, long Offset)
{
   long          i;
   int           HighShft, LowShft;
   unsigned char HighMask, LowMask;

          /* Anzahl der ganzen Bytes im Offset */
   To += Offset/8;

/* Nur bis zum rechten Rand des Ziels kopieren */
   if((Offset/8+Length)>ColAnz)
      Length=ColAnz-Offset/8;

           /* Falls Offset Vielfaches von Acht */     
   if (!(Offset&7)) {
      for (i = 0; i < Length; i++) {
         *(To++) |= *(From++);
      } 
   } else {                        /* sonst... */
   
   /* Anzahl der Shifts und passende Bitmasken */
      HighShft = (int) Offset&7;
      LowShft  = 8 - HighShft;
      LowMask  = (1<<HighShft)-1;
      HighMask = 255 - LowMask;

                               /* Kopieren ... */
      for (i = 0; i < Length; i++, To++, From++){
         To[0] |= ((*From)&HighMask)>>HighShft;
         To[1] |= ((*From)&LowMask)<<LowShft;
      } 
      
      /* Letztes Byte wurde zuviel beschrieben */ 
      if(Length==(ColAnz-Offset/8))
         To[1]=0;
   } 
}

/* Naechsten PCL-Befehl lesen                  */

int ParseNextCmd (char *arg, char *terminator,
                          READ_FUNC *GetNextByte)
{
   LISTELEM   *LELast,      /* Akt. Baumknoten */
              *LENext;  /* NÑchsten Baumknoten */
   int         CmdNo,         /* Befehlsnummer */
               Zchn, /* letztes gelesenes Zchn */
               i;
   static int  LastCmdNo = 0; /* Nr des zuletzt*/
     /* gelesenen Befehls (falls Mehrfachbef.) */
   
   arg[0] = terminator[0] = terminator[1] = 0;
   

               /* Falls zuletzt Mehrfachbefehl */
   if (LastCmdNo) {
      CmdNo = LastCmdNo;
      LastCmdNo = 0;
   } else {      /* sonst: neuen Befehl parsen */
               /* Am Anfang des Baums beginnen */
      LENext = &TopElem;
      do {
                        /* NÑchstes Byte lesen */
         Zchn = (*GetNextByte) ();
         if (Zchn > 255) /* Falls Button gedr. */
            return Zchn;

         /* Knoten mit allen Befehlen, die mit */
          /* diesem Zeichen weitergehen suchen */
         LELast = LENext;
         LENext = FindNextElemInLine
                                (LELast, Zchn);
      }
       /* Bis ein vollst. Befehl gelesen wurde */
      while (LENext && (!LENext->BefehlNo));
      
      if (!LENext) {      /* Falls kein Befehl */
         return (-1);        /* gefunden wurde */
      }
                        /* Befehlsnummer lesen */
      CmdNo = LENext->BefehlNo;
   } 
   
    /* Falls Befehl mit Argument, dieses lesen */
   if (PclBefehle[CmdNo].Type == ARG) {
      i = 0;
      do {
         arg[i++] = Zchn = (*GetNextByte) ();
         if (Zchn > 255)
            return Zchn;

     /* Falls Kleinbuchstabe -> Mehrfachbefehl */
         if ((Zchn >= 'a') && (Zchn <= 'z')) {
            Zchn = toupper (Zchn);
            LastCmdNo = CmdNo;
         } 
      }
              /* Buchstabe ist Befehlsabschluû */
      while ((Zchn < 'A') || (Zchn > 'Z'));
      arg[--i] = 0;
      
      terminator[0] = Zchn;
   }

                  /* Befehlsnummer zurÅckgeben */
   return CmdNo;
}

/* NÑchsten Knoten mit allen Befehlen, die mit */
/* 'Zchn' beginnen suchen                      */

LISTELEM *FindNextElemInLine (LISTELEM *CurrElem,
                              char Zchn)
{
   LISTELEM *LEResult = (LISTELEM *)0L,
            *LENextElem;
   
                     /* erster Nachfolgeknoten */
   LENextElem = CurrElem->FirstElemNextLine;
   
   while (LENextElem) { /*Alle Nachfolgeknoten */
      if (LENextElem->Zchn == Zchn) {
         LEResult = LENextElem;   /* Nach Zchn */
         break;                 /* durchsuchen */
      }
      LENextElem = LENextElem->NextElemInLine;
   }
   
   /* Passenden Knoten (oder Null) zurÅckgeben */
   return (LEResult);
}

/* Ende der Liste der Nachfolgeknoten suchen   */

LISTELEM *FindEndOfLine (LISTELEM *CurrElem)
{
   while (CurrElem->NextElemInLine)
      CurrElem=CurrElem->NextElemInLine;
   
   return CurrElem;
}

/* Einen Befehl in den PCL-Baum einfÅgen       */

void PutNextCmdInList (int CmdNo)
{
   LISTELEM *NextElem = &TopElem, *LastElem;
   int i=0;
   
   /* Soweit die Zeichenfolge bereits im Baum  */
              /* eingetragen, diesen verfolgen */
   do {
      LastElem = NextElem;
      NextElem = FindNextElemInLine (LastElem,
              PclBefehle[CmdNo].BefPrefix[i++]);
   }
   while (NextElem != 0);
   
   if (--i == strlen(
                 PclBefehle[CmdNo].BefPrefix)) {
      exit (1234);     /* Fehler in PCL Liste? */
   }
   
   /* Restliche Zeichenfolge in Baum eintragen */
   for (; 
         i < strlen(PclBefehle[CmdNo].BefPrefix);
         i++) {
 /* Im nÑchsten freien Knoten nÑchstes Zeichen */
     /* eintragen und diesen in Baum einbinden */
      NextElem = &ElemList[ElemListEndPtr++];
      NextElem->Zchn =
              PclBefehle[CmdNo].BefPrefix[i];
      NextElem->NextElemInLine = 0L;
      NextElem->FirstElemNextLine = 0L;
      NextElem->BefehlNo = 0;
      
 /* Falls im letzten Knoten bereits Nachfolge- */
  /* knoten eingetragen, Neuen ans Ende hÑngen */
      if (LastElem->FirstElemNextLine)
         FindEndOfLine
                 (LastElem->FirstElemNextLine)
                     ->NextElemInLine= NextElem;
      else
         LastElem->FirstElemNextLine = NextElem;

          /* An Neuem restliche Zeichen binden */
      LastElem = NextElem;
   }

               /* Letzter Knoten ergibt Befehl */
   LastElem->BefehlNo = CmdNo;
}
