/*{{{}}}*/
/*********************************************************************
 *
 * Kommandos zum Zugriff auf CD-ROMs
 *
 * $Source: U:\USR\src\scsi\CBHD\include\scsidrv\RCS\scsicd.h,v $
 *
 * $Revision: 1.3 $
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
 * $Log: scsicd.h,v $
 * Revision 1.3  1996/02/14  11:33:52  Steffen_Engel
 * keine globalen Kommandostrukturen mehr
 *
 * Revision 1.2  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.1  1995/11/13  23:46:04  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#ifndef __SCSICD
#define __SCSICD

/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- PauseResume entspricht der Pause-Taste des CD-Players.                -*/
/*- SCSI-Opcode $4B                                                       -*/
/*-                                                                       -*/
/*- Pause                                                                 -*/
/*-   TRUE  : CD hÑlt an                                                  -*/
/*-   FALSE : CD spielt weiter                                            -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG PauseResume(BOOLEAN Pause);


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- PlayAudio spielt von einee CD ab BlockAdr TransLength Blîcke ab.      -*/
/*- SCSI-Opcode $A5                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG PlayAudio(LONG BlockAdr, LONG TransLength);


typedef union
{
  struct {
  BYTE Resrvd;
  BYTE M;
  BYTE S;
  BYTE F;
  } s;
  ULONG longval;
}tMSF;

/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- PlayAudioMSF startet die CD an der absoluten Position Start und lÑût  -*/
/*- sie bis Stop laufen.                                                  -*/
/*- SCSI-Opcode $47                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG PlayAudioMSF(tMSF Start, tMSF Stop);


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Spielt die StÅcke StarTrack.StartIndex bis EndTrack.EndIndex          -*/
/*- SCSI-Opcode $48                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG PlayAudioTrack(UWORD StartTrack, UWORD StartIndex, UWORD EndTrack, UWORD EndIndex);


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- PlayAudioRelative startet den CD-Player bei der Position RelAdr in    -*/
/*- dem Track StartTrack und spielt Len Blîcke ab.                        -*/
/*- SCSI-Opcode $49                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG PlayAudioRelative(UWORD StartTrack, ULONG RelAdr, ULONG Len);


/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- ReadHeader fragt den Header der angegebenen BlockAdr ab.              -*/
/*-                                                                       -*/
/*- SCSI-Opcode $44                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG ReadHeader(BOOLEAN  MSF, ULONG BlockAdr,
                BYTE    *Mode, tMSF *AbsoluteAdr);

/* Werte fÅr SubFormat */
#define SubQ      0
#define CDPos      1
#define MediaCatNo 2
#define TrackISRC  3
/* Audio-Status-Codes */
#define NotSupp    0
#define Playing    0x11
#define Paused     0x12
#define Complete   0x13
#define ErrStop    0x14
#define NoStatus   0x15
/* Werte fÅr Adr (in ADRControl) */
#define NoQInfo   0     /* Sub-channel Q mode information not supplied. */
#define QencPOS   1     /* Sub-channel Q encodes current position data. */
#define QencUPC   2     /* Sub-channel Q encodes media catalog number.  */
#define QencISRC  3     /* Sub-channel Q encodes ISRC.                  */


#define AUDIOEMPHASIS 1
#define COPYPERMIT    2
#define DATATRACK     4
#define FOURCHANNEL   8

#if 0
/* ControlBits:
 Bit          0                                 1
  0       Audio without pre-emphasis    Audio with pre-emphasis  
  1       Digital copy prohibited       Digital copy permitted   
  2       Audio track                   Data track               
  3       Two channel audio             Four channel audio       
 */

TYPE  tADRControl = (Ctrl0, Ctrl1, Ctrl2, Ctrl3,
                     Adr0, Adr1, Adr2, Adr3);
      tsADRControl = SET OF tADRControl;
      tSubData = RECORD
                  Res0        : BYTE;
                  AudioStatus : UChar;
                  SubLen      : SHORTCARD;  /* Header 4 Bytes */

                  SubFormat   : BYTE;
                  ADRControl  : tsADRControl;
                  TrackNo     : UChar;

                  CASE : SHORTCARD OF
                    SubQ      :
                                QIndex    : UChar;
                                QAbsAdr   : tMSF;       /* auf der CD */
                                QRelAdr   : tMSF;       /* im Track   */
                                QMCVal    : BYTE;       /* Bit 8 */
                                QUPC14    : BYTE;
                                QUPC      : ARRAY[0..13] OF BYTE;
                                QTCVal    : BYTE;       /* Bit 8 */
                                QISRC14   : BYTE;
                                QISRC     : ARRAY[0..13] OF BYTE;
                                /* SubQ : insgesamt 48 Bytes */

                   |CDPos     :
                                IndexNo   : UChar;
                                AbsAdr    : tMSF;       /* auf der CD */
                                RelAdr    : tMSF;       /* im Track   */
                                /* CDPos : insgesamt 16 Bytes */

                   |MediaCatNo:
                                upcRes7   : BYTE;
                                MCVal     : BYTE;       /* Bit 8 */
                                UPC14     : BYTE;
                                UPC       : ARRAY[0..13] OF BYTE;
                                /* MediaCatNo : insgesamt 24 Bytes */

                   |TrackISRC :
                                isrcRes7  : BYTE;
                                TCVal     : BYTE;       /* Bit 8 */
                                ISRC14    : BYTE;
                                ISRC      : ARRAY[0..13] OF BYTE;
                                /* TrackISR : insgesamt 24 Bytes */
                  END;
                END;
#endif

typedef struct{
  BYTE  Res0;
  UCHAR AudioStatus;
  UWORD SubLen;           /* Header 4 Bytes */

  BYTE  SubFormat;
  BYTE  ADRControl;
  UCHAR TrackNo;
  union{
    struct{
      UCHAR QIndex;
      tMSF QAbsAdr;         /* auf der CD */
      tMSF QRelAdr;         /* im Track   */
      BYTE QMCVal;          /* Bit 8 */
      BYTE QUPC14;
      BYTE QUPC[14];
      BYTE QTCVal;          /* Bit 8 */
      BYTE QISRC14;
      BYTE QISRC[14];
      /* SubQ : insgesamt 48 Bytes */
    } subq;
    struct {
      UCHAR   IndexNo;
      tMSF    AbsAdr;       /* auf der CD */
      tMSF    RelAdr;       /* im Track   */
      /* CDPos : insgesamt 16 Bytes */
    } cdpos;
  } data;
#if 0
                   |MediaCatNo:
                                upcRes7   : BYTE;
                                MCVal     : BYTE;       /* Bit 8 */
                                UPC14     : BYTE;
                                UPC       : ARRAY[0..13] OF BYTE;
                                /* MediaCatNo : insgesamt 24 Bytes */

                   |TrackISRC :
                                isrcRes7  : BYTE;
                                TCVal     : BYTE;       /* Bit 8 */
                                ISRC14    : BYTE;
                                ISRC      : ARRAY[0..13] OF BYTE;
                                /* TrackISR : insgesamt 24 Bytes */
                  END;
                END;
#endif
} tSubData;

/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Sub-Channel Daten abfragen                                            -*/
/*- Datenformat ist tSubData.                                             -*/
/*- SCSI-Opcode $42                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG ReadSubChannel(BOOLEAN MSF, BOOLEAN SUBQ,
                       UWORD SubFormat, UWORD Track,
                       void *Data, UWORD Len);



#define MAXTOC 100          /* Maximum laut SCSI-2 */
typedef struct{
  BYTE  Res0;
  UBYTE ADRControl;
  UCHAR TrackNo;
  BYTE  Res3;
  tMSF  AbsAddress;
}tTOCEntry;

typedef struct
{
  UWORD TOCLen;           /* ohne TOCLen-Feld */
  UCHAR FirstTrack;
  UCHAR LastTrack;
}tTOCHead;

typedef struct
{
  tTOCHead Head;
  tTOCEntry Entry[MAXTOC];
}tTOC;

/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- ReadTOC liest das Inhaltsverzeichnis einer CD ein.                    -*/
/*- Wenn StartTrack # 0 ist, so wird das Inhaltsverzeichnis ab dem ange-  -*/
/*- gebenen Track angegeben.                                              -*/
/*- SCSI-Opcode $43                                                       -*/
/*-                                                                       -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
LONG ReadTOC(BOOLEAN MSF, UWORD StartTrack,
                  void *Buffer, UWORD Len);


LONG ReadCDDA12(ULONG BlockAdr,
                UWORD TransferLen, void *buffer);


BOOLEAN init_scsicd(void);


#endif


