/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*-   Name            : REQSENSE                                          -*/
/*-   Version         : 0.2                                               -*/
/*-   Art             : PlugIn                                            -*/
/*-   Aufgabe         : Requestsense-Meldung fÅr GEMAR                    -*/
/*-   Autor           : Steffen Engel                       (C) 93        -*/
/*-   Letzte énderung : 26.10.1993, 11:59:28                              -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*-   Beschreibung  : Dies ist ein Beispiel fÅr die Programmierung von    -*/
/*-                   PlugIns fÅr GEMAR.                                  -*/
/*-                   Wenn ein Fehler bei einem SCSI-Aufruf auftritt, der -*/
/*-                   Check Condition meldet, holt GEMAR die Request      -*/
/*-                   Sense Daten vom GerÑt, um die Fehlermeldung         -*/
/*-                   zusammenzustellen.                                  -*/
/*-                   Falls ein PlugIn mit dem Namen REQSENSE.PLG         -*/
/*-                   existiert, wird dieses geladen und mit einem        -*/
/*-                   Zeiger auf die Request-Sense Daten aufgerufen.      -*/
/*-                   Das PlugIn kann dann eine differenzierte Fehlermel- -*/
/*-                   dung zusammenstellen und eine Zeiger darauf         -*/
/*-                   liefern.                                            -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*-   History                                                             -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-   Vers | Datum    | Beschreibung                                      -*/
/*-  ------|----------|---------------------------------------            -*/
/*-   0.1  | 26.10.93 | erstellt                                          -*/
/*-   0.2  | 09.11.93 | auf externe Datei mit Meldungen umgestellt        -*/
/*-        |          |                                                   -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/




/* die Åblichen Header-Dateien --------------- */
int errno;
long _FilSysV;

#include <portab.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

char Msg[100];

typedef struct head
{
  int valid     : 1; 
  int ErrorCode : 7;
} HEADBITS;

typedef struct key
{
  int FM       : 1;
  int EOM      : 1;
  int ILI      : 1;
  int reserved : 1;
  Key          : 4;
} KEY;

typedef struct reqsense
{
  char HeadBits;    /* eigentlich HEADBITS, aber Bitfield mindestens 16 Bit */
  char SegmentNo;
  char SenseKey;    /* eigentlich KEY, aber... */
  char InfoByte1;
  char InfoByte2;
  char InfoByte3;
  char InfoByte4;
  char AddLength;
  unsigned long  CmdSpecific;
  char AS;
  char ASQ;
} REQSENSE;

long cdecl CallProc (REQSENSE *SenseData);

char NoSense[]          = "Kein Fehler?";
char ReqSenseError[]    = "Fehler bei Request Sense!";
char UnknownError[]     = "Unbekannter Fehler";
char FileMark[]         = "Filemark";
char EndOfMedia[]       = "Bandende";
char IllegalLength[]    = "IllegalLength";
char RecoveredError[]   = "Korrigierter Lesefehler";
char NotReady[]         = "Nicht bereit";
char MediumError[]      = "Medium-Fehler";
char HardwareError[]    = "Hardware-Fehler";
char IllegalRequest[]   = "Illegaler Befehl";
char UnitAttention[]    = "Unit Attention";
char DataProtect[]      = "Schreibschutz";
char BlankCheck[]       = "Keine Daten auf dem Band";
char CopyAborted[]      = "Abbruch von 'Copy'";;
char AbortedCommand[]   = "Abgebrocheneds Kommando";
char Equal[]            = "Equal";
char VolumeOverflow[]   = "Volume Overflow/Bandende";
char Miscompare[]       = "Miscompare";



/* vom Programm Åbergebene Parameter */
typedef struct
  {
    int Version;    
    void *private;
    int ApplId;
    int VDIHandle;
    char *PlugPath;
    int (*Alert) (int defbutt, char *msg);
  } PLUGPARMS;


PLUGPARMS *PlugParms;

/* Funktionen -------------------------------- */

/***********************************************/
/* Initialisierung des Moduls:                 */
/***********************************************/
long cdecl init(PLUGPARMS *parms)
{
  if (((long)parms == 0)             /* Keine Parameter? -> Urks     */
     || (parms->Version < 0x0000))   /* Minimalversion der Parameter */
  {
    return 0;
  }

  /* Parameterzeiger merken */
  PlugParms = parms;

  /* Adresse der Prozedur zurÅckgeben */
  return((long)CallProc);
}  


/***********************************************/
/* Text fÅr AS und ASQ aus REQSENSE.DAT lesen  */
/***********************************************/
void GetAS(char buffer[], int AS, int ASQ)
{
  
  char fname[512], msg[120];
  int count, as, asq; 
  FILE *file;

  /* Kopie des Pfades */
  strcpy(fname, PlugParms->PlugPath);
  
  /* Pfad abtrennen */
  for (count = (int) strlen(fname); 
       count >= 0 && fname[count] != 92;
        --count)
    {
      fname[count] = 0;  
    }

  strcat(fname, "REQSENSE.DAT");
  file = fopen(fname, "r"); 

  if (file == NULL)
    {
      strcpy(buffer, "REQSENSE.PLG: ");
      strcat(buffer, fname);
      strcat(buffer, " not found");
      return;
    }
 
  while (1)
  {
    if (fscanf(file, "%x %x %[#-z ]", &as, &asq, msg) == 0) 
      {
        /* Ende der Datei -> AS und ASQ an bereits existierende Meldung anhÑngen */
        sprintf(msg, ": AS: $%02x, ASQ: $%02x", AS, ASQ);
        strcat (buffer, msg);
        break;
      }
    if (AS == as && (ASQ == asq || asq == 0xFF))
    {
      strcpy(buffer, msg);

      /* qualifier mit FF soll in Text einkopiert werden */
      if (asq == 0xFF)
        {
          sprintf(buffer, msg, ASQ);
        }
      break;        
    }
  }
  fclose(file);   /* Datei schlieûen */
}   /* GetAS */


/***********************************************/
/* die eigentliche Plug-Prozedur               */
/***********************************************/
long cdecl CallProc(REQSENSE *SenseData)
{
  if ((long) SenseData != -1)      /* beim Deinit-Call nichts machen */
    {
      if ((((int) SenseData->HeadBits & 0x7f) != 0x70)
           && (((int) SenseData->HeadBits & 0x7f) != 0x71))
      {
        strcpy (Msg, "Was'ndas'n?");
      }
      else
      {
        switch (SenseData->SenseKey & 0x0F)
        {
          case 0x00: strcpy(Msg, NoSense); 
                     break;
          case 0x01: strcpy(Msg, RecoveredError);
                     break;
          case 0x02: strcpy(Msg, NotReady);
                     break;
          case 0x03: strcpy(Msg, MediumError);
                     break;
          case 0x04: strcpy(Msg, HardwareError);
                     break;
          case 0x05: strcpy(Msg, IllegalRequest);
                     break;
          case 0x06: strcpy(Msg, UnitAttention);
                     break;
          case 0x07: strcpy(Msg, DataProtect);
                     break;
          case 0x08: strcpy(Msg, BlankCheck);
                     break;
      /* |09H : RETURN VendorUnique; */
          case 0x0A: strcpy(Msg, CopyAborted);
                     break;
          case 0x0B: strcpy(Msg, AbortedCommand);
                     break;
          case 0x0C: strcpy(Msg, Equal);
                     break;
          case 0x0D: strcpy(Msg, VolumeOverflow);
                     break;
          case 0x0E: strcpy(Msg, Miscompare);
                     break;
          
          default:   if (SenseData->SenseKey && 0x80)
                     {
                       strcpy(Msg, FileMark);
                     } 
                     else
                     {
                       if (SenseData->SenseKey && 0x40)
                       {
                         strcpy(Msg, EndOfMedia);
                       }
                       else
                       {
                         if (SenseData->SenseKey && 0x20)
                         {
                           strcpy(Msg, IllegalLength);
                         }
                         else
                         {
                           sprintf(Msg, " Code : $%x Key : $%x", 
                                   SenseData->HeadBits, SenseData->SenseKey);
                         }
                       }
                     }
        }
      }
      if (SenseData->AS != 0)
      {
        GetAS(Msg, SenseData->AS, SenseData->ASQ);
      }
       return (long)&Msg;
    }
  else
    {
      return 0;
    }
}     /* CallProc */
