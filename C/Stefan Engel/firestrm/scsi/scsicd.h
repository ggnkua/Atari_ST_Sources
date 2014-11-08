/*{{{}}}*/
/*********************************************************************
 *
 * Kommandos zum Zugriff auf CD-ROMs
 *
 * $Source: /dev/f/kleister.ii/cbhd\RCS\SCSICD.H,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/11/13 23:46:04 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: SCSICD.H,v $
 * Revision 1.1  1995/11/13  23:46:04  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#ifndef __SCSICD
#define __SCSICD

/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- PauseResume entspricht der Pause-Taste des CD-Players.								-*/
/*- SCSI-Opcode $4B 																											-*/
/*- 																																			-*/
/*- Pause 																																-*/
/*- 	TRUE	: CD hÑlt an																									-*/
/*- 	FALSE : CD spielt weiter																						-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG PauseResume(BOOLEAN Pause);


/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- PlayAudio spielt von einee CD ab BlockAdr TransLength Blîcke ab.			-*/
/*- SCSI-Opcode $A5 																											-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG PlayAudio(LONG BlockAdr, LONG TransLength);


typedef struct
{
	UBYTE Resrvd;
	UBYTE M;
	UBYTE S;
	UBYTE F;
}tMSF;

/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- PlayAudioMSF startet die CD an der absoluten Position Start und lÑût	-*/
/*- sie bis Stop laufen.																									-*/
/*- SCSI-Opcode $47 																											-*/
/*- 																																			-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG PlayAudioMSF(tMSF Start, tMSF Stop);


/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- Spielt die StÅcke StarTrack.StartIndex bis EndTrack.EndIndex					-*/
/*- SCSI-Opcode $48 																											-*/
/*- 																																			-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG PlayAudioTrack(UWORD StartTrack, UWORD StartIndex, UWORD EndTrack, UWORD EndIndex);


/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- PlayAudioRelative startet den CD-Player bei der Position RelAdr in		-*/
/*- dem Track StartTrack und spielt Len Blîcke ab.												-*/
/*- SCSI-Opcode $49 																											-*/
/*- 																																			-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG PlayAudioRelative(UWORD StartTrack, ULONG RelAdr, ULONG Len);


/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- ReadHeader fragt den Header der angegebenen BlockAdr ab.							-*/
/*- 																																			-*/
/*- SCSI-Opcode $44 																											-*/
/*- 																																			-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG ReadHeader(BOOLEAN  MSF, ULONG BlockAdr, BYTE *Mode, tMSF *AbsoluteAdr);

/*
/* Werte fÅr SubFormat */
CONST SubQ			= 0;
			CDPos 		= 1;
			MediaCatNo= 2;
			TrackISRC = 3;
/* Audio-Status-Codes */
			NotSupp 	= 0;
			Playing 	= 0x11;
			Paused		= 0x12;
			Complete	= 0x13;
			ErrStop 	= 0x14;
			NoStatus	= 0x15\;
/* Werte fÅr Adr (in ADRControl) */
			NoQInfo = 0;			/* Sub-channel Q mode information not supplied. */
			QencPos = 1;			/* Sub-channel Q encodes current position data. */
			QencUPC = 2;			/* Sub-channel Q encodes media catalog number.	*/
			QencISRC = 3; 		/* Sub-channel Q encodes ISRC.									*/
/* ControlBits:
 Bit					0 																1
	0 			Audio without pre-emphasis		Audio with pre-emphasis  
	1 			Digital copy prohibited 			Digital copy permitted	 
	2 			Audio track 									Data track							 
	3 			Two channel audio 						Four channel audio			 
 */


TYPE	tADRControl = (Ctrl0, Ctrl1, Ctrl2, Ctrl3,
										 Adr0, Adr1, Adr2, Adr3);
			tsADRControl = SET OF tADRControl;
			tSubData = RECORD
									Res0				: BYTE;
									AudioStatus : UChar;
									SubLen			: SHORTCARD;	/* Header 4 Bytes */

									SubFormat 	: BYTE;
									ADRControl	: tsADRControl;
									TrackNo 		: UChar;

									CASE : SHORTCARD OF
										SubQ			:
																QIndex		: UChar;
																QAbsAdr 	: tMSF; 			/* auf der CD */
																QRelAdr 	: tMSF; 			/* im Track 	*/
																QMCVal		: BYTE; 			/* Bit 8 */
																QUPC14		: BYTE;
																QUPC			: ARRAY[0..13] OF BYTE;
																QTCVal		: BYTE; 			/* Bit 8 */
																QISRC14 	: BYTE;
																QISRC 		: ARRAY[0..13] OF BYTE;
																/* SubQ : insgesamt 48 Bytes */

									 |CDPos 		:
																IndexNo 	: UChar;
																AbsAdr		: tMSF; 			/* auf der CD */
																RelAdr		: tMSF; 			/* im Track 	*/
																/* CDPos : insgesamt 16 Bytes */

									 |MediaCatNo:
																upcRes7 	: BYTE;
																MCVal 		: BYTE; 			/* Bit 8 */
																UPC14 		: BYTE;
																UPC 			: ARRAY[0..13] OF BYTE;
																/* MediaCatNo : insgesamt 24 Bytes */

									 |TrackISRC :
																isrcRes7	: BYTE;
																TCVal 		: BYTE; 			/* Bit 8 */
																ISRC14		: BYTE;
																ISRC			: ARRAY[0..13] OF BYTE;
																/* TrackISR : insgesamt 24 Bytes */
									END;
								END;
*/


/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- Sub-Channel Daten abfragen																						-*/
/*- Datenformat ist tSubData. 																						-*/
/*- SCSI-Opcode $42 																											-*/
/*- 																																			-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG ReadSubChannel(BOOLEAN MSF, BOOLEAN SUBQ,
											 UWORD SubFormat, UWORD Track,
											 void *Data, UWORD Len);


/*
CONST MaxTOC = 100;  /* Maximum laut SCSI-2 */
TYPE	tTOCEntry = RECORD
										Res0				: BYTE;
										ADRControl	: tsADRControl;
										TrackNo 		: UChar;
										Res3				: BYTE;
										AbsAddress	: tMSF;
									END;

			tTOCHead =	RECORD
										TOCLen			: SHORTCARD;		/* ohne TOCLen-Feld*/
										FirstTrack	: UChar;
										LastTrack 	: UChar;
									END;

			tTOC		 =	RECORD
										Head		: tTOCHead;
										Entries : ARRAY[0..MaxTOC] OF tTOCEntry;
									END;
*/

/*-------------------------------------------------------------------------*/
/*- 																																			-*/
/*- ReadTOC liest das Inhaltsverzeichnis einer CD ein.										-*/
/*- Wenn StartTrack # 0 ist, so wird das Inhaltsverzeichnis ab dem ange-	-*/
/*- gebenen Track angegeben.																							-*/
/*- SCSI-Opcode $43 																											-*/
/*- 																																			-*/
/*- 																																			-*/
/*-------------------------------------------------------------------------*/
LONG ReadTOC(BOOLEAN MSF, UWORD StartTrack, void *Buffer, UWORD Len);

#endif
				