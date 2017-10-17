/*{{{}}}*/
/*********************************************************************
 *
 * SCSI-Aufrufe fÅr alle GerÑte
 *
 * $Source: U:\USR\src\scsi\CBHD\include\scsidrv\RCS\scsi.h,v $
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
#include "scsidrv/scsidefs.h"           /* Typen fÅr SCSI-Lib */


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


/*
        SCSI opcodes
*/

#define TEST_UNIT_READY         0x00
#define REZERO_UNIT             0x01
#define REQUEST_SENSE           0x03
#define FORMAT_UNIT             0x04
#define READ_BLOCK_LIMITS       0x05
#define REASSIGN_BLOCKS         0x07
#define READ_6                  0x08
#define WRITE_6                 0x0a
#define SEEK_6                  0x0b
#define READ_REVERSE            0x0f
#define WRITE_FILEMARKS         0x10
#define SPACE                   0x11
#define INQUIRY                 0x12
#define RECOVER_BUFFERED_DATA   0x14
#define MODE_SELECT             0x15
#define RESERVE                 0x16
#define RELEASE                 0x17
#define COPY                    0x18
#define ERASE                   0x19
#define MODE_SENSE              0x1a
#define START_STOP              0x1b
#define RECEIVE_DIAGNOSTIC      0x1c
#define SEND_DIAGNOSTIC         0x1d
#define ALLOW_MEDIUM_REMOVAL    0x1e

#define SET_WINDOW              0x24
#define READ_CAPACITY           0x25
#define READ_10                 0x28
#define WRITE_10                0x2a
#define SEEK_10                 0x2b
#define WRITE_VERIFY            0x2e
#define VERIFY                  0x2f
#define SEARCH_HIGH             0x30
#define SEARCH_EQUAL            0x31
#define SEARCH_LOW              0x32
#define SET_LIMITS              0x33
#define PRE_FETCH               0x34
#define READ_POSITION           0x34
#define SYNCHRONIZE_CACHE       0x35
#define LOCK_UNLOCK_CACHE       0x36
#define READ_DEFECT_DATA        0x37
#define MEDIUM_SCAN             0x38
#define COMPARE                 0x39
#define COPY_VERIFY             0x3a
#define WRITE_BUFFER            0x3b
#define READ_BUFFER             0x3c
#define UPDATE_BLOCK            0x3d
#define READ_LONG               0x3e
#define WRITE_LONG              0x3f
#define CHANGE_DEFINITION       0x40
#define WRITE_SAME             0x41
#define LOG_SELECT              0x4c
#define LOG_SENSE               0x4d
#define MODE_SELECT_10          0x55
#define MODE_SENSE_10           0x5a
#define WRITE_12                0xaa
#define WRITE_VERIFY_12         0xae
#define SEARCH_HIGH_12          0xb0
#define SEARCH_EQUAL_12         0xb1
#define SEARCH_LOW_12           0xb2
#define SEND_VOLUME_TAG         0xb6


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

