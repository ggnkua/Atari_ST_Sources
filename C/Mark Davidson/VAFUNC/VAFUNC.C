/* AV-Protokoll Call Functionen
*
* Stand: 16.4.91
*
* Definiert einige Funktionen fÅr die Kommunikation zwischen
* einem Accessorie und Venus bzw. Gemini bzw. einem Programm, welches
* das AV-Protokoll beherrscht.
*
* Copyright (c) 1990 by Stephan Gerle
*   additions   1994 by Mark Davidson
*/

#include <aes.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>

#include <vafunc.h>

#define GEMINI "GEMINI  "
#define AVSERVER "AVSERVER"

#define	VA_NORETURNMSG	0

static char	_sccs[] = "@(#)AV-Protokoll calling Functions (c) 1990 by Stephan Gerle "__DATE__;

#define	AVHasProto(word,bit)	(AVStatus[word]&(1<<bit))

static short	AVStatus[3],	/* Was kann die Hauptapplikation */
			AVActiveFlag=0,	/* Ist obiger Wert korrekt? */
			AVMyProtoStatus = 0,/* Protokollstatus des Acc's */
			AVMyApId=0;		/* ApId des Acc's */
static char	*AVMyName = "";/* AV-Name des Acc's */
char			AVName[9]="";/* AV-Name der Hauptapplikation */


static int GotAVServer = 0;
static short ap_id;
extern int _XMODE;

int
GetAVServer(void)
{
int Id;
char *VaPtr = NULL;
static char AVServer[9];
	GotAVServer = 1;
	
	if (_AESglobal[1] != -1)
	{
		return 0;
	}

	if ((Id = appl_find(GEMINI)) != -1)
	{
		return Id;
	}
	if ((Id = appl_find(AVSERVER)) != -1)
	{
		return Id;
	}
	shel_envrn(&VaPtr, "AVSERVER=");
	
	if (VaPtr != NULL)
	{
		sprintf(AVServer, "%8.8s", VaPtr);
		if ((Id = appl_find(AVServer)) != -1)
		{
			return Id;
		}
	}
	
	return 0;
}

int ApplWrite(int dummy, int length, void *message)
{
int RetVal;
	//Debug("ApplWrite");
	
	if (GotAVServer == 0)
	{
		ap_id = GetAVServer();
	}
	
	RetVal = appl_write(ap_id, length, message); 
	return (RetVal);
}

int	AVActive(void)
{
	short	msg[8];
	
	//Debug("AVActive");
	
	if ((_XMODE != 2) && (_AESglobal[0] < 0x340))			return 0;
	
	if (AVActiveFlag)	return AVStatus[0]|AVStatus[1]|AVStatus[2];
	
	msg[0] = AV_PROTOKOLL;
	msg[1] = AVMyApId;
	msg[2] = 0;
	AVSTR2MSG(msg,6,AVMyName);
	msg[3] = AVMyProtoStatus;
	msg[4] = msg[5] = 0;
	ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
	AVStatus[0] = AVStatus[1] = AVStatus[2] = 0;
	AVActiveFlag = 1;
	*AVName = 0;
	return 0;
}

void	AVInit(int myapid,char *myname,int myprotostatus)
{
	//Debug("AVInit");
	AVMyName = myname;
	AVMyProtoStatus = myprotostatus;
	AVMyApId=myapid;
	AVActive();
}

/* Sorgt dafÅr, das der AV-Protokoll-Status neu ermittelt wird. */
void	AVGetNewProtoStatus(void)
{
	//Debug("AVGetNewProtoStatus");
	AVActiveFlag = 0;
	*AVName = 0;
	AVStatus[0] = AVStatus[1] = AVStatus[2] = 0;
	AVActive();
}

int	AVProcessMsg(short *msg)
{
	int	ret;
	
	//Debug("AVProcessMsg");
	
	switch (msg[0])
	{
		case	AC_CLOSE:			AVGetNewProtoStatus();
							return 0;
							
		case VA_PROTOSTATUS:	if (	msg[3]==AVStatus[0] &&
								msg[4]==AVStatus[1] &&
								msg[5]==AVStatus[2])
								ret = 0;
							else
							{
								ret = 1; 
								AVStatus[0] = msg[3];
								AVStatus[1] = msg[4];
								AVStatus[2] = msg[5];
								AVActiveFlag = 1;
							}
							if (AVMSG2STR(msg,6))
								strcpy(AVName,AVMSG2STR(msg,6));
							else	*AVName = 0;
							return ret;
	}
	return 0;
}

/* Sendet den Status an die Hauptapplikation. */
int	AVSendStatus(char *status)
{
	short	msg[8];
	
	//Debug("AVSendStatus");
	
	if (AVActive() && AVHasProto(0,7))
	{
		msg[0] = AV_STATUS;
		msg[1] = AVMyApId;
		msg[2] = 0;
		AVSTR2MSG(msg,3,status);
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

void	AVReceiveStatus(void)
{
	short	msg[8];
	
	//Debug("AVReceiveStatus");
	
	if (AVActive() && AVHasProto(0,7))
	{
		msg[0] = AV_GETSTATUS;
		msg[1] = AVMyApId;
		msg[2] = 0;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg);
	}
}

/* Emittelt den fÅr Verzeichnisfenster eingestellten Font und die
   Fonthîhe */
int	AVAskFileFont(void)
{
	short	msg[8];
	
	//Debug("AVAskFileFont");
	
	if (AVActive() && AVHasProto(0,1))
	{
		msg[0] = AV_ASKFILEFONT;
		msg[1] = AVMyApId;
		msg[2] = 0;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg);
		return 1;
	}
	return 0;
}

/* Dasselbe wie AVAskFileFont, nur fÅr das Console-Fenster */
int	AVAskConsoleFont(void)
{
	short	msg[8];
	
	//Debug("AVAskConsoleFont");

	if (AVActive() && AVHasProto(0,2))
	{
		msg[0] = AV_ASKCONFONT;
		msg[1] = AVMyApId;
		msg[2] = 0;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

/* Liefert einen Pointer auf einen String, in dem die Namen der
   selektierten Objekte (getrennt durch ' ') stehen.
   Bei Fehler wird NULL zurÅckgeliefert */
void	AVAskSelectedObjects(void)
{
	short	msg[8];
	
	//Debug("AVAskSelectedObjects");

	if (AVActive() && AVHasProto(0,3))
	{
		msg[0] = AV_ASKOBJECT;
		msg[1] = AVMyApId;
		msg[2] = 0;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
	}
}

/* Sagt Gemini, daû das Console-Fenster geîffnet werden soll. */
int	AVOpenConsole(void)
{
	short	msg[8];
	
	//Debug("AVOpenConsole");

	if (AVActive() && AVHasProto(0,2))
	{
		msg[0] = AV_OPENCONSOLE;
		msg[1] = AVMyApId;
		msg[2] = 0;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

/* Sagt Venus bzw. Gemini, das ein Fenster mit dem Verzeichnis
   pfad und der Maske mask geîffnet werden soll. */
int	AVOpenWindow(char *pfad,char *mask)
{
	short	msg[8];
	
	//Debug("AVOpenWindow");
	
	if (AVActive() && AVHasProto(0,4))
	{
		msg[0] = AV_OPENWIND;
		msg[1] = AVMyApId;
		msg[2] = 0;
		strupr(pfad);
		if (pfad[strlen(pfad)-1] != '\\')
			strcat(pfad,"\\");
		AVSTR2MSG(msg,3,pfad);
		AVSTR2MSG(msg,5,mask);
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

/* Startet mittels Venus bzw. Gemini ein Programm. In pfad steht
   der komplette Pfad und der Programmname. cmdline enthÑlt
   die Kommandozeile fÅr das zu startende Programm. */
int	AVStartProgram(char *pfad,char *cmdline)
{
	short	msg[8];
	
	//Debug("AVStartProgram");
	if (AVActive() && AVHasProto(0,5))
	{
		msg[0] = AV_STARTPROG;
		msg[1] = AVMyApId;
		msg[2] = 0;
		strupr(pfad);
		AVSTR2MSG(msg,3,pfad);
		AVSTR2MSG(msg,5,cmdline);
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

/* Sagt dem Hauptprogramm, daû das Accessorie ein Fenster geîffnet hat. */
int	AVAccOpenedWindow(int winhandle)
{
	short	msg[8];
	
	//Debug("AVAccOpenedWindow");
	if (AVActive() && AVHasProto(0,6))
	{
		msg[0] = AV_ACCWINDOPEN;
		msg[1] = AVMyApId;
		msg[2] = 0;
		msg[3] = winhandle;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

/* Sagt VENUS, daû das Accessorie ein Fenster geschlossen hat.
   (ist nur bei nicht durch AC_CLOSE bedingtem Schlieûen notwendig) */
int	AVAccClosedWindow(int winhandle)
{
	short	msg[8];

	//Debug("AVAccClosedWindow");
	if (AVActive() && AVHasProto(0,6))
	{
		msg[0] = AV_ACCWINDCLOSED;
		msg[1] = AVMyApId;
		msg[2] = 0;
		msg[3] = winhandle;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

/* Schickt VENUS/GEMINI einen Tastaturevent. Ist dann anzuwenden,
   wenn ein ACC ein Fenster offen hat, und einen Tastendruck bekommt,
   den es selber nicht versteht. */
int	AVSendKeyEvent(int state,int key)
{
	short	msg[8];
	
	//Debug("AVSendKeyEvent");

	if (AVActive() && AVHasProto(0,0))
	{
		msg[0] = AV_SENDKEY;
		msg[1] = AVMyApId;
		msg[2] = 0;
		msg[3] = state;
		msg[4] = key;
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg); 
		return 1;
	}
	return 0;
}

int	AVCopyDragged(int kstate,char *dest)
{
	short	msg[8];
	
	//Debug("AVCopyDragged");

	if (AVActive() && AVHasProto(0,8))
	{
		msg[0] = AV_COPY_DRAGGED;
		msg[1] = AVMyApId;
		msg[2] = 0;
		msg[3] = kstate;
		AVSTR2MSG(msg,4,dest);
		ApplWrite(0,(int)sizeof(short [8])+msg[2],msg);
		return 1;
	}
	return 0;
}


/* The next two functions are not really part of the VA-Protocol
   but they may be useful */


char HelpString[200];

int  
CallSTGuide(char *help, char *pattern)  
{  
    short msg[8], i;
  
    if ((i=appl_find("ST-GUIDE"))>=0) 
    {  
        msg[0] = VA_START;
        msg[1] = AVMyApId;
        msg[2] = 0;
        sprintf(HelpString, "%s %s", help, pattern);
		strupr(HelpString);
		AVSTR2MSG(msg,3,HelpString);
        msg[5] = 0;
        msg[6] = 0;
        msg[7] = 0;
        appl_write(i, 16, msg);
        return 0;
    }
    return 1;  
}  

#define AC_HELP 1025
#define HELP_FILE_MAGIC  0x1993

/* This only supports calling 1STGuide as a file viewer */

int  
Call1STGuide(char *file)  
{  
    short msg[8], i;
    
    strcpy(HelpString, file);
  
    if ((i=appl_find("1STGUIDE"))>=0) 
    {  
        msg[0] = AC_HELP;
        msg[1] = AVMyApId;
        msg[2] = 0;
        msg[3] = 0;
        msg[4] = 0;
        msg[5] = HELP_FILE_MAGIC;
		AVSTR2MSG(msg,6, HelpString);
        appl_write(i, 16, msg);
        return 0;
    }
    return 1;  
}  


