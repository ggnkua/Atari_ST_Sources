/*----------------------------------------------------------------------------------------
	gscript.h, part of TOS Linker for CodeWarrior

	GEMScript protocol messages and defines
	
	19.4.1999 by Manfred Lippert

	last change: 31.1.2000

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __GEMSCRIPT_MSGS_H__
#define __GEMSCRIPT_MSGS_H__

#include <Types2B.h>

#define GS_REQUEST		0x1350
#define GS_REPLY			0x1351
#define GS_COMMAND		0x1352
#define GS_ACK				0x1353
#define GS_QUIT			0x1354
#define GS_OPENMACRO		0x1355
#define GS_MACRO			0x1356
#define GS_WRITE			0x1357
#define GS_CLOSEMACRO	0x1358

#define GSM_COMMAND		0x0001  /* kann GS_COMMAND empfangen */
#define GSM_MACRO			0x0002  /* kann GS_OPENMACRO, GS_WRITE und GS_CLOSEMACRO empfangen, GS_MACRO verschicken (Interpreter) */
#define GSM_WRITE			0x0004  /* kann GS_OPENMACRO, GS_WRITE und GS_CLOSEMACRO verschicken, GS_MACRO empfangen (aufnahmefähige Applikation) */
#define GSM_HEXCODING	0x0008  /* Hex-Codierung wird verstanden */

#define GSACK_OK			0
#define GSACK_UNKNOWN	1
#define GSACK_ERROR		2

/* GS_INFO-Struktur: */

#pragma	PRAGMA_PACKED_ALIGN

typedef struct {
	int32 len;			/* Länge der Struktur in Bytes                      */
	int16  version;	/* Versionsnummer des Protokolles beim Sender       */
	int16  msgs;		/* Bitmap der unterstützten Nachrichten (GSM_xxx)   */
	int32 ext;			/* benutzte Endung, etwa '.SIC'                     */
} GS_INFO;

#pragma	PRAGMA_RESET_ALIGN

#endif
