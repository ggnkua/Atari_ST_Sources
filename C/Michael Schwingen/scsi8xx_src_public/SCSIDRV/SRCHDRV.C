/*{{{}}}*/
/****************************************************************************
 *
 * Beispiel fÅr die Benutzung des SCSI-Treibers
 * Suche nach vorhandenen GerÑten.
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\srchdrv.c,v $
 *
 * $Revision: 1.6 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:29:58 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: srchdrv.c,v $
 * Revision 1.6  1996/02/14  11:29:58  Steffen_Engel
 * Diverser Kleinkram
 *
 * Revision 1.5  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.4  1995/11/14  22:15:26  S_Engel
 * Meldung von CanDisconnect und ScatterGather
 *
 * Revision 1.3  1995/10/22  15:42:28  S_Engel
 * Anpassung auf lange Handles
 *
 * Revision 1.2  1995/09/29  09:18:56  S_Engel
 * Jetzt ist es Warning Free :-)
 *
 * Revision 1.1  1995/06/16  12:06:46  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************/

#include <stdio.h>

#include <import.h>
#include <portab.h>

#include <scsidrv/scsiio.h>
#include <scsidrv/scsi.h>
#include <scsidrv/scsidisk.h>
#include <export.h>

#define DUMPBLOCKS  0     /* zur Demo der Datentransfers, gleichzeitig Anzahl */
#define READONLY    0     /* Blîcke nur Testlesen, nicht zeigen */

#define MIN(A,B) A>B ? B:A

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


typedef struct tcall
{
  int   num;
  long  Call;
} TCALL;


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
char CopyAborted[]      = "Abbruch von 'Copy'";
char AbortedCommand[]   = "Abgebrocheneds Kommando";
char Equal[]            = "Equal";
char VolumeOverflow[]   = "Volume Overflow/Bandende";
char Miscompare[]       = "Miscompare";




/***********************************************
 * Text fÅr AS und ASQ aus REQSENSE.DAT lesen  *
 ***********************************************/
void GetAS(char buffer[], int AS, int ASQ)
{{{
  
  char fname[512], msg[120];
  int count, as, asq; 
  FILE *file;

  strcpy(fname, "reqsense.dat");
  file = fopen(fname, "r");

  if (file == NULL)
    {
      strcpy(buffer, "REQSENSE.PLG: ");
      strcat(buffer, fname);
      strcat(buffer, " not found");
      /* Ende der Datei -> AS und ASQ an bereits existierende Meldung anhÑngen */
      sprintf(msg, ": AS: $%02x, ASQ: $%02x", AS, ASQ);
      strcat (buffer, msg);
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
    if ((AS == as) && ((ASQ == asq) || (asq == 0xFF)))
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
}}}   /* GetAS */


/***********************************************
 * die eigentliche Plug-Prozedur               *
 ***********************************************/
BOOLEAN SenseMsg(REQSENSE *SenseData, char *Msg)
{{{
  if ((long) SenseData != -1)      /* beim Deinit-Call nichts machen */
    {
      if ((((int) SenseData->HeadBits & 0x7f) != 0x70)
           && (((int) SenseData->HeadBits & 0x7f) != 0x71))
      {
        strcpy (Msg, "Was'n das'n?");
      }
      else
      {
        switch (SenseData->SenseKey & 0x0F)
        {
/* Es kann sein, daû der SenseKey 0 ist, aber in den beren Bits etwas markiert ist.
          case 0x00: strcpy(Msg, NoSense); 
                     break;
 */ 
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
          
          default:   if (SenseData->SenseKey & 0x80)
                     {
                       strcpy(Msg, FileMark);
                     } 
                     else
                     {
                       if (SenseData->SenseKey & 0x40)
                       {
                         strcpy(Msg, EndOfMedia);
                       }
                       else
                       {
                         if (SenseData->SenseKey & 0x20)
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
      
      /* und den Additional Sense-Code, wenn er gemeldet ist */
      if (SenseData->AS != 0)
      {
        GetAS(Msg, SenseData->AS, SenseData->ASQ);
      }
       return TRUE;
    }
  else
    {
      return FALSE;
    }
}}}     /* CallProc */



/***********************************************
 * Daten dumpen
 *
 * noch nicht ausgearbeitet, beherrscht nur vielfache von 16 Bytes!
 *
 ***********************************************/
void dump(unsigned char *data, ULONG len)
{{{
WORD count1, count2;

  /* Schleife Åber 16 Bytes */
  for (count1 = 0; count1 < len/16; count1++)
  {
    printf("      $%04x ", count1*16);
    for (count2 = 0; count2 < 16; count2++)
    {
      printf("%02x ", (UWORD)data[count1*16+count2]);
    }

    printf("  ");
    for (count2 = 0; count2 < 16; count2++)
    {
      if (data[count1*16+count2] >= 16)
      {
        printf("%c", data[count1*16+count2]);
      }
      else
      {
        printf(".");
      }
    }
    printf("\n");
  }

}}}

/***********************************************
 * Die ersten DUMPBLOCKS Blîck eines GerÑtes
 * anzeigen
 * Das handle muû gesetzt sein!
 ***********************************************/
void dumpblocks(void)
{{{
char Block[512];
WORD BlockCount;
LONG result;

  for (BlockCount = 0; BlockCount < DUMPBLOCKS; BlockCount++)
  {
    SuperOn();
    result = Read((ULONG)BlockCount, 1, Block);
    SuperOff();
/*    printf("Block %4d\n", BlockCount);*/
    if (result == 0)
    {
#if !READONLY
      dump(Block, 512);
#endif
    }
    else
    {
      printf("  Block %4d result %ld\n", BlockCount, result);
    }
  }

}}}


/***********************************************
 * Bus nach GerÑten absuchen
 ***********************************************/
void scan_bus(tBusInfo Bus)
{{{
  tInqData  InqData;
  tDevInfo  Dev;
  tHandle   handle;
  ULONG     MaxLen;
  WORD      ret;
  char      Name[20];
  char      Msg[100];
  UWORD     Features;

/* handle = scsicall->Open(1, 0, &MaxLen);*/


  SuperOn();
  ret = scsicall->InquireBus(cInqFirst, Bus.BusNo, &Dev);
  SuperOff();

  while (ret == 0)
  {
    printf("  Id %2ld ", Dev.SCSIId.lo);
#if TRUE
    SuperOn();
    ret = scsicall->CheckDev(Bus.BusNo, &Dev.SCSIId, Name, &Features);
    SuperOff();
    if (ret == 0)
      {
        printf("%s ", Name);
        if (Features & cArbit)
          printf(" arbit,");
        if (Features & cAllCmds)
          printf(" all cmds,");
        if (Features & cTargCtrl)
          printf(" target controlled,");
        if (Features & cTarget)
          printf(" target installable,");
        if (Features & cCanDisconnect)
          printf(" Disconnect possible,");
        if (Features & cScatterGather)
          printf(" scatter gather,");
        printf("\b \n     ");
      }
    else
      {

      }
#endif

    memset (&InqData, 0, sizeof (tInqData));

    SuperOn();
    handle = (tHandle) scsicall->Open(Bus.BusNo, &Dev.SCSIId, &MaxLen);
    if ((LONG) handle >= 0)
    {
      SetScsiUnit(handle, 0, MaxLen);
      /* erst den Header */
      ret = Inquiry(&InqData, FALSE, 0, 5);
      if (ret == 0L)
      {
        ret = Inquiry(&InqData, FALSE, 0, (WORD) MIN((WORD)5 + (WORD)InqData.AddLen, (WORD)sizeof(InqData)));
      }
    }

    SuperOff();

    if ((LONG) handle >= 0)
    {
      printf(" handle $%lx", handle);
      printf(" MaxLen $%lx", MaxLen);
    }


    if (((LONG) handle >= 0) && (ret == 0L))
    {
      InqData.Revision[0] = 0;
      printf(" %s ", InqData.Vendor);
      switch (InqData.Device & 0x1F) {
        case 0: printf ("direct access device");
                break;
        case 1: printf ("sequential access device");
                break;
        case 2: printf ("printer device");
                break;
        case 3: printf ("processor device");
                break;
        case 4: printf ("write-once device");
                break;
        case 5: printf ("CD-ROM device");
                break;
        case 6: printf ("scanner device");
                break;
        case 7: printf ("optical memory device");
                break;
        case 8: printf ("medium changer device");
                break;
        case 9: printf ("communications device");
                break;
        case 10:
        case 11: printf ("ASC IT 8 (graphic arts pre-press device)");
                break;
        case 0x1f: printf ("unknown device");
                break;

        default : printf(" reserved device type %h", InqData.Device);
      }
    }
    else
    {
      if ((LONG) handle < 0)
        printf(": no Handle -%ld", -1*(LONG)handle);
      else
      {
        if (ret > 0)
        {
          printf(": Error $%x ", ret);
          /* Sense-Daten ausgeben */
          if (SenseMsg((REQSENSE *) &ReqBuff, Msg))
          {
            printf(Msg);
          }
        }
        else
        {
          printf(": no Device (-$%x) ", -1*ret);
        }
      }
    }

    printf("\n");

    if ((LONG) handle > 0)
    {
#if DUMPBLOCKS
      /* Wenn es eines Festplatte ist, lesen wir mal den ersten Block
       * und zeigen ihn an */
      if ((InqData.Device & 0x1F) == 0)
      {
        dumpblocks();
      }
#endif
      /* und das handle freigeben */
      SuperOn();
      scsicall->Close(handle);
      SuperOff();
    }
    SuperOn();
    ret = scsicall->InquireBus(cInqNext, Bus.BusNo, &Dev);
    SuperOff();

    } /* while */

}}}

void search_drives(void)
{{{
  LONG          ret;
  tBusInfo      Info;

  printf("\nsearching drives...\n");

  SuperOn();
  ret = scsicall->InquireSCSI(cInqFirst, &Info);
  SuperOff();
  while (ret == 0)
  {

    printf("\n Bus %s, No %d\n", Info.BusName, Info.BusNo);
    scan_bus(Info);

    SuperOn();
    ret = scsicall->InquireSCSI(cInqNext, &Info);
    SuperOff();
  }
}}}

WORD main(void)
{{{

  printf("Demo-Programm fÅr Benutzung der SCSI-Calls");
  printf("  Ω Steffen Engel 1995");

  if (init_scsiio() && init_scsi())
    search_drives();
  else
    printf("SCSI-Lib nicht benutzbar");

  printf("\n Taste drÅcken");
  do
  {
  } while (Cconis());
  Cconin();
/*
*/
  return (0);

}}}
        
        
        
