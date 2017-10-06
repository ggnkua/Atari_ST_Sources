/*{{{}}}*/
/*********************************************************************
 *
 * SCSI-Aufrufe fÅr alle GerÑte
 *
 * $Source: f:\kleister.ii\cbhd\rcs\scsi.h,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:33:52 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: scsi.h,v $
 * Revision 1.2  1996/02/14  11:33:52  Steffen_Engel
 * keine globalen Kommandostrukturen mehr
 *
 * Revision 1.1  1995/11/28  19:14:14  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#ifndef __SCSI_H
#define __SCSI_H

#include <portab.h>
#include "scsidefs.h"                                 /* Typen fÅr SCSI-Lib */


/*****************************************************************************
 * Konstanten
 *****************************************************************************/

#define DIRECTACCESSDEV  0       /* GerÑt mit Direktzugriff (Festplatte) */
#define SEQACCESSDEV     1       /*   "    "  seq. Zugriff  (Streamer)   */
#define PRINTERDEV       2       /* Drucker                              */
#define PROCESSORDEV     3       /* Hostadapter                          */
#define WORMDEV          4       /* WORM-Laufwerk                        */
#define ROMDEV           5       /* nur-lese Laufwerk (CD-ROM)           */
#define SCANNERDEF       6       /* Scanner                              */
#define OPTICALMEMDEV    7       /* optical memory device                */
#define MEDIUMCHNGDEV    8       /* medium changer device (zB JukeBox)   */
#define COMMDEV          9       /* Communicationdevice                  */
#define GRAPHDEV1       10
#define GRAPHDEV2       11
#define UNKNOWNDEV      31


/*****************************************************************************
 * Typen
 *****************************************************************************/

/* Inquiry-Struktur */
typedef struct
{
  UCHAR Device;
  UCHAR Qualifier;
  UCHAR Version;
  UCHAR Format;
  UCHAR AddLen;
  UCHAR Res1;
  UWORD Res2;
  char  Vendor[8];
  char  Product[16];
  char  Revision[4];
}tInqData;

/* Modesense/select-Typen */

/* Pages fÅr CD-ROMS */
/* {{{ */
typedef struct{
  BYTE CDP0DRes2;
  BYTE InactTMul;      /* unteres Nibble */
  UWORD SperMSF;
  UWORD FperMSF;
}tCDPage0D;

typedef struct {
  UBYTE ImmedFlags;
  BYTE CD0ERes3;
  BYTE CD0ERes4;
  UBYTE LBAFlags;
  UWORD BlocksPerSecond;
    /* Genau:
     *   LBAFlags MOD 10H = 0 -> BlocksPerSecond
     *   LBAFlags MOD 10H = 8 -> 256 * BlocksPerSecond
     */
  UBYTE Port0Channel;
  UBYTE Port0Volume;
  UBYTE Port1Channel;
  UBYTE Port1Volume;
  UBYTE Port2Channel;
  UBYTE Port2Volume;
  UBYTE Port3Channel;
  UBYTE Port3Volume;
}tCDPage0E;
/* }}} */

/* allgmeine Struktur fÅr ModeSense/Select */
typedef struct{
  BYTE ModeLength;
  BYTE MediumType;
  UBYTE DeviceSpecs;  /* GerÑteabhÑngig */
  BYTE BlockDescLen;
} tParmHead;

typedef struct{
  ULONG Blocks;                  /* Byte HH = DensityCode */
  ULONG BlockLen;                /* Byte HH = Reserved    */
} tBlockDesc;

/* die Varianten fÅr die Pages */
typedef union{
  tCDPage0D CDP0D;
  tCDPage0E CDP0E;
} tPage;

typedef struct{
  tParmHead ParmHead;
  tBlockDesc BlockDesc;
  tPage Page;
} tModePage;


/*****************************************************************************
 * Variablen
 *****************************************************************************/
GLOBAL long ScsiFlags;   /* Wert fÅr tScsiCmd.Flags */


/*****************************************************************************
 * Funktionen
 *****************************************************************************/

LONG TestUnitReady(void);


LONG Inquiry(void  *data, BOOLEAN Vital, UWORD VitalPage, WORD length);
  /* Inquiry von einem GerÑt abholen */

#define MODESEL_SMP 0x01            /* Save Mode Parameters */
#define MODESEL_PF  0x10            /* Page Format          */

LONG ModeSelect(UWORD        SelectFlags,
                void        *Buffer,
                UWORD        ParmLen);

#define MODESENSE_CURVAL 0          /* current values     */
#define MODESENSE_CHANGVAL 1        /* changeable values  */
#define MODESENSE_DEFVAL 2          /* default values     */
#define MODESENSE_SAVEDVAL 3        /* save values        */

LONG ModeSense(UWORD     PageCode,
               UWORD     PageControl,
               void     *Buffer,
               UWORD     ParmLen);


LONG PreventMediaRemoval(BOOLEAN Prevent);


BOOLEAN init_scsi (void);
  /* Initialisierung des Moduls */



/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Allgemeine Tools                                                      -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
void SuperOn(void);

void SuperOff(void);

void Wait(ULONG Ticks);

void SetBlockSize(ULONG NewLen);
  /*
   * SetBlockLen legt die BlocklÑnge fÅr das SCSI-GerÑt fest
   * (normalerweise 512 Bytes).
   */

ULONG GetBlockSize();
  /*
   * GetBlockLen gibt die aktuell eingestellte BlocklÑnge zurÅck.
   */


void SetScsiUnit(tHandle handle, WORD Lun, ULONG MaxLen);
  /*
   * SetScsiUnit legt das GerÑt fest an das die nachfolgenden Kommandos
   * gesendet werden und wie lang die Transfers maximal sein dÅrfen.
   */


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Zugriff fÅr Submodule (ScsiStreamer, ScsiCD, ScsiDisk...)             -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/

typedef struct
{
  UBYTE     Command;
  BYTE      LunAdr;
  UWORD     Adr;
  UBYTE     Len;
  BYTE      Flags;
}tCmd6;

typedef struct
{
  UBYTE     Command;
  BYTE      Lun;
  ULONG     Adr;
  BYTE      Reserved;
  UBYTE     LenHigh;
  UBYTE     LenLow;
  BYTE      Flags;
}tCmd10;

typedef struct
{
  UBYTE     Command;
  BYTE      Lun;
  ULONG     Adr;
  ULONG     Len;
  BYTE      Reserved;
  BYTE      Flags;
}tCmd12;


GLOBAL ULONG    BlockLen;
GLOBAL ULONG    MaxDmaLen;
GLOBAL UWORD    LogicalUnit;

void SetCmd6(tCmd6 *Cmd,
             UWORD Opcode,
             ULONG BlockAdr,
             UWORD TransferLen);

void SetCmd10(tCmd10 *Cmd,
              UWORD Opcode,
              ULONG BlockAdr,
              UWORD TransferLen);
         
void SetCmd12(tCmd12 *Cmd,
              UWORD Opcode,
              ULONG BlockAdr,
              ULONG TransferLen);

tpSCSICmd SetCmd(BYTE    *Cmd,
                 WORD     CmdLen,
                 void    *Buffer,
                 ULONG    Len,
                 ULONG   TimeOut);


#endif

