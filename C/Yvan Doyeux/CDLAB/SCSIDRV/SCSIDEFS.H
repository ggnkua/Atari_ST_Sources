/****************************************************************************
 *
 * Typen für SCSI-Calls in C
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsidefs.h,v $
 *
 * $Revision: 1.8 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:33:52 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsidefs.h,v $
 * Revision 1.8  1996/02/14  11:33:52  Steffen_Engel
 * keine globalen Kommandostrukturen mehr
 *
 * Revision 1.7  1996/01/25  17:53:16  Steffen_Engel
 * Tippfehler bei PARITYERROR korrigiert
 *
 * Revision 1.6  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.5  1995/11/14  22:15:58  S_Engel
 * Kleine Korrekturen
 * aktualisiert auf aktuellen Stand
 *
 * Revision 1.4  1995/10/22  15:43:34  S_Engel
 * Kommentare leicht überarbeitet
 *
 * Revision 1.3  1995/10/13  22:30:54  S_Engel
 * GetMsg in Struktur eingefügt
 *
 * Revision 1.2  1995/10/11  10:21:34  S_Engel
 * Handle als LONG, Disconnect auf Bit4 verlegt
 *
 * Revision 1.1  1995/10/03  12:49:42  S_Engel
 * Initial revision
 *
 *
 ****************************************************************************/


#ifndef __SCSIDEFS_H
#define __SCSIDEFS_H

#include <scsidrv/portab.h>
#include <atarierr.h>

/*****************************************************************************
 * Konstanten
 *****************************************************************************/
#define SCSIRevision 0x0100                     /* Version 1.00 */

#define MAXBUSNO        31       /* maximal mögliche Busnummer */


/* SCSI-Fehlermeldungen für In und Out */

#define NOSCSIERROR      0L /* Kein Fehler                                   */
#define SELECTERROR     -1L /* Fehler beim Selektieren                       */
#define STATUSERROR     -2L /* Default-Fehler                                */
#define PHASEERROR      -3L /* ungültige Phase                               */
#define BSYERROR        -4L /* BSY verloren                                  */
#define BUSERROR        -5L /* Busfehler bei DMA-Übertragung                 */
#define TRANSERROR      -6L /* Fehler beim DMA-Transfer (nichts übertragen)  */
#define FREEERROR       -7L /* Bus wird nicht mehr freigegeben               */
#define TIMEOUTERROR    -8L /* Timeout                                       */
#define DATATOOLONG     -9L /* Daten für ACSI-Softtransfer zu lang           */
#define LINKERROR      -10L /* Fehler beim Senden des Linked-Command (ACSI)  */
#define TIMEOUTARBIT   -11L /* Timeout bei der Arbitrierung                  */
#define PENDINGERROR   -12L /* auf diesem handle ist ein Fehler vermerkt     */
#define PARITYERROR    -13L /* Transfer verursachte Parity-Fehler            */


/*****************************************************************************
 * Typen
 *****************************************************************************/

/*
  in portab.h zu definieren:

  BYTE      : 8 Bit signed (char)
  UBYTE     : 8 Bit unsigned (unsigned char)
  UWORD     : 16 Bit ganzzahlig positiv (unsigned word)
  ULONG     : 32 Bit ganzzahlig positiv (unsigned long)
  WORD      : 16 Bit ganzzahlig (word)
  LONG      : 32 Bit ganzzahlig (long)
  BOOLEAN   : WORD
              TRUE  : 1
              FALSE : 0
  DLONG     : 64 Bit unsigned
*/

typedef struct
{
  ULONG hi;
  ULONG lo;
} DLONG;

typedef struct{
  ULONG BusIds;
  BYTE  resrvd[28];
}tPrivate;

typedef WORD *tHandle;                /* Zeiger auf BusFeatures */

typedef struct
{
  tHandle Handle;                     /* Handle für Bus und Gerät             */
  BYTE  *Cmd;                         /* Zeiger auf CmdBlock                  */
  UWORD CmdLen;                       /* Länge des Cmd-Block (für ACSI nötig) */
  void  *Buffer;                      /* Datenpuffer                          */
  ULONG TransferLen;                  /* Übertragungslänge                    */
  BYTE  *SenseBuffer;                 /* Puffer für ReqSense (18 Bytes)       */
  ULONG Timeout;                      /* Timeout in 1/200 sec                 */
  UWORD Flags;                        /* Bitvektor für Ablaufwünsche          */
    #define Disconnect 0x10           /* versuche disconnect                  */

}tSCSICmd;
typedef tSCSICmd *tpSCSICmd;


typedef struct
{
  tPrivate Private;
   /* für den Treiber */
  char  BusName[20];
   /* zB 'SCSI', 'ACSI', 'PAK-SCSI' */
  UWORD BusNo;
   /* Nummer, unter der der Bus anzusprechen ist */
  UWORD Features;
      #define cArbit     0x01    /* auf dem Bus wird arbitriert                          */
      #define cAllCmds   0x02    /* hier können ale SCSI-Cmds abgesetzt werden           */
      #define cTargCtrl  0x04    /* Das Target steuert den Ablauf (so soll's sein!)      */
      #define cTarget    0x08    /* auf diesem Bus kann man sich als Target installieren */
      #define cCanDisconnect 0x10 /* Disconnect ist möglich                             */
      #define cScatterGather 0x20 /* scatter gather bei virtuellem RAM möglich */
  /* bis zu 16 Features, die der Bus kann, zB Arbit,
   * Full-SCSI (alle SCSI-Cmds im Gegensatz zu ACSI)
   * Target oder Initiator gesteuert
   * Ein SCSI-Handle ist auch ein Zeiger auf eine Kopie dieser Information!
   */
  ULONG MaxLen;
  /* maximale Transferlänge auf diesem Bus (in Bytes)
   * entspricht zB bei ACSI der Gröže des FRB
   */
}tBusInfo;

typedef struct
{
  BYTE Private[32];
  DLONG SCSIId;
}tDevInfo;


typedef struct ttargethandler
{
  struct  ttargethandler *next;
  BOOLEAN cdecl (*TSel)         (WORD     bus,
                                 UWORD    CSB,
                                 UWORD    CSD);
  BOOLEAN cdecl (*TCmd)         (WORD     bus,
                                 BYTE    *Cmd);
  UWORD   cdecl (*TCmdLen)      (WORD     bus,
                                 UWORD    Cmd);
  void    cdecl (*TReset)       (UWORD    bus);
  void    cdecl (*TEOP)         (UWORD    bus);
  void    cdecl (*TPErr)        (UWORD    bus);
  void    cdecl (*TPMism)       (UWORD    bus);
  void    cdecl (*TBLoss)       (UWORD    bus);
  void    cdecl (*TUnknownInt)  (UWORD    bus);
}tTargetHandler;

typedef tTargetHandler *tpTargetHandler;

typedef BYTE tReqData[18];

typedef struct
{
  UWORD Version;                /* Revision in BCD: $0100 = 1.00 */
  
  /* Routinen als Initiator */
  LONG  cdecl (*In)           (tpSCSICmd  Parms);
  LONG  cdecl (*Out)          (tpSCSICmd  Parms);
  
  LONG  cdecl (*InquireSCSI)  (WORD       what,
                               tBusInfo  *Info);
    #define cInqFirst  0
    #define cInqNext   1
  LONG  cdecl (*InquireBus)   (WORD       what,
                               WORD       BusNo,
                               tDevInfo  *Dev);

  LONG  cdecl (*CheckDev)     (WORD       BusNo,
                               const DLONG *SCSIId,
                               char      *Name,
                               UWORD     *Features);
  LONG  cdecl (*RescanBus)    (WORD       BusNo);


  LONG  cdecl (*Open)         (WORD       BusNo,
                               const DLONG *SCSIId,
                               ULONG     *MaxLen);
  LONG  cdecl (*Close)        (tHandle    handle);
  LONG  cdecl (*Error)        (tHandle    handle,
                               WORD       rwflag,
                               WORD       ErrNo);
        #define cErrRead   0
        #define cErrWrite  1
          #define cErrMediach  0
          #define cErrReset    1
  
  /* Routinen als Target (optional) */
  LONG  cdecl (*Install)    (WORD       bus,
                             tpTargetHandler Handler);
  LONG  cdecl (*Deinstall)  (WORD       bus,
                             tpTargetHandler Handler);
  LONG  cdecl (*GetCmd)     (WORD       bus,
                             BYTE      *Cmd);
  LONG  cdecl (*SendData)   (WORD       bus,
                             BYTE      *Buffer,
                             ULONG      Len);
  LONG  cdecl (*GetData)    (WORD       bus,
                             void      *Buffer,
                             ULONG      Len);
  LONG  cdecl (*SendStatus) (WORD       bus,
                             UWORD      Status);
  LONG  cdecl (*SendMsg)    (WORD       bus,
                             UWORD      Msg);
  LONG  cdecl (*GetMsg)     (WORD       bus,
                             UWORD     *Msg);
  
  /* globale Variablen (für Targetroutinen) */
  tReqData      *ReqData;
}tScsiCall;
typedef tScsiCall *tpScsiCall;

#endif