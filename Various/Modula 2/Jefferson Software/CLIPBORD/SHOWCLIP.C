/****************************************************************************\
|*		SHOWCLIP.ACC														*|
|*--------------------------------------------------------------------------*|
|*	by Russ Wetmore															*|
|*		Last revision:	11/04/86 15:02:20									*|
\****************************************************************************/
/*------------------------------*\
|*	includes					*|
\*------------------------------*/
#include <define.h>
#include <gem.h>						/* GEMDEFS.H & OBDEFS.H				*/
#include <tos.h>						/* TOSDEFS.H & OSBIND.H				*/
#include <string.h>						/* for string copies

#define MEGAMAX							/* We're using Megamax C			*/
#include "clip.h"						/* Clipboard equates & portability	*/

/*------------------------------*\
|*	local defines				*|
\*------------------------------*/
#define STRSIZE 25						/* Max string length in alert		*/
#define STRTOTAL (5*STRSIZE)			/* Whole alert is five lines long	*/
#define RASPBERRY() Bconout(2,7)		/* Shortcut							*/

/*------------------------------*\
|*	imports						*|
\*------------------------------*/
IMPORT	WORD	gl_apid;				/* To fix someone else's bug		*/

/*------------------------------*\
|*	exports						*|
\*------------------------------*/
GLOBAL	WORD	contrl[12],				/* Idiotic GEM bindings				*/
				intin[128],
				ptsin[128],
				intout[128],
				ptsout[128];

/*------------------------------*\
|*	locals						*|
\*------------------------------*/
LOCAL	BYTE	NODATA[] = "[1][ |Nothing in clipboard| ][ OK ]",
				yesstr[] =Yes",
				nossstr[] = "No",
				dunnostr[] = "On CLIP.SYS",
				inmemstr[] = "In memory",
				NoClipTrap[] = "[3][Clipboard TRAP routines are not|installed. Be sure the CLIP.PRG|file is in the \\AUTO folder on|your boot disk.][ OK ]",
				FileNotFound[] = "[1][ |No clipboard file on disk| ][ OK ]",
				ReadError[] = "[3][ |Some kind of read error!| ][ OK ]";


/*------------------------------*\
|*	HandleError					*|
\*------------------------------*/
	LOCAL
	VOID
HandleError(err)
	WORD err;
{
	BYTE tempstr[256], *alertstr = tempstr;

	switch (err) {
		case EFILNF:
			alertstr = FileNotFound;
			break;
		case EREADF:
			alertstr = ReadError;
			break;
		default:
			sprintf(tempstr, "[3][ |Unknown error: %d| ][ OK ]", err);
			break;
	}
	RASPBERRY();
	form_alert(1, alertstr);
}

/*------------------------------*\
|*	DoInformation				*|
\*------------------------------*/
	LOCAL
	VOID
DoInformation(infoPtr)
	clipInfo *infoPtr;
{
	BYTE alertstr[256];

	sprintf(alertstr,
	  "[1][Size: %ld|Loc: %lx|Dirty: %s|Where: %s|Fname: %s][ OK ]",
	  infoPtr->size, infoPtr->location,
	  infoPtr->dirty ? yesstr : nostr,
	  infoPtr->where ? inmemstr : dunnostr,
	  infoPtr->filename);

	form_alert(1, alertstr);
}

/*------------------------------*\
|*	main						*|
\*------------------------------*/
	GLOBAL
	WORD
main()
{
	BYTE *dataPtr, alertstr[256], lines[5][STRSIZE+1];
	WORD msgbuff[8];
	WORD myMenu, i, j;
	LONG length;
	clipInfo *infoPtr;

	/*----------------------------------------------------------------------*\
	|*	We're a GEM application.  Register at front desk.					*|
	\*----------------------------------------------------------------------*/
	appl_init();
	myMenu = menu_register(gl_apid, "  Show clipboard");

	for (;;) {
		/*------------------------------------------------------------------*\
		|*	Ask AES what's up and respond if Butch is opening us up			*|
		\*------------------------------------------------------------------*/
		evnt_mesag(msgbuff);
		if ( msgbuff[0] == AC_OPEN && msgbuff[4] == myMenu ) {

			/*--------------------------------------------------------------*\
			|*	First, we check to see if the clipboard is around			*|
			\*--------------------------------------------------------------*/
			if ( !InfoClip(&infoPtr) ) {	/* FALSE result means no clip	*/
				RASPBERRY();
				form_alert(1, NoClipTrap);
				continue;
			}

			/*--------------------------------------------------------------*\
			|*	It is, so show information about it							*|
			\*--------------------------------------------------------------*/
			DoInformation(infoPtr);

			/*--------------------------------------------------------------*\
			|*	Bring clipboard into memory									*|
			\*--------------------------------------------------------------*/
			i = GetClip(&dataPtr, &length, TRUE);
			if ( i < 0 ) {					/* Negative result means error!	*/
				HandleError(i);
				continue;
			}

			/*--------------------------------------------------------------*\
			|*	Inform Butch of special case of clipboard but no contents	*|
			\*--------------------------------------------------------------*/
			if ( !length ) {				/* Nothing there				*/
				form_alert(1, NODATA);
				continue;
			}

			/*--------------------------------------------------------------*\
			|*	For purposes of this demo, truncate string to fit alert		*|
			\*--------------------------------------------------------------*/
			if ( length > STRTOTAL )
				dataPtr[STRTOTAL] = '\0';

			/*--------------------------------------------------------------*\
			|*	Initialize strings and fill them a line at a time			*|
			\*--------------------------------------------------------------*/
			for (j=0; j<5; ++j)
				*lines[j] = lines[j][STRSIZE] = '\0';

			for (j=0; length>0 && j<5; ++j, length-=STRSIZE)
				strncpy(lines[j], dataPtr + j * STRSIZE, STRSIZE);

			/*--------------------------------------------------------------*\
			|*	Cheap way of creating alert string							*|
			\*--------------------------------------------------------------*/
			sprintf(alertstr,
			  "[1][>%-25s<|>%-25s<|>%-25s<|>%-25s<|>%-25s<][OK| Flush clip ]",
			  lines[0], lines[1], lines[2], lines[3], lines[4]);

			/*--------------------------------------------------------------*\
			|*	If Butch tells us to flush, then flush						*|
			\*--------------------------------------------------------------*/
			if ( form_alert(1, alertstr) == 2 )
				ZeroClip();
		}
	}
}
