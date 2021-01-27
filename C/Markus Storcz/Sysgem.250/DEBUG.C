/* ------------------------------------------------------------------- *
 * Module Version       : 2.03                                         *
 * Author               : Gerhard Stoll                                *
 * Programming Language : Pure-C                                       *
 * Copyright            : (c) 2000, Gerhard Stoll, 56727 Mayen         *
 * ------------------------------------------------------------------- */

#include        "kernel.h"
#include        <stdio.h>
#include        <string.h>

/* ------------------------------------------------------------------- */

LOCAL INT DebugOK;

static FILE			*debug_handle = NULL;
static DEBUGDEV	device;
static BYTE			progName[25];
LOCAL  BYTE			devicename[30] = "";
				

/* ------------------------------------------------------------------- */

VOID Debug(BYTE *FormatString, ...)
{
	va_list	arg_ptr;

	if (DebugOK)
	{
		fprintf(debug_handle, "%s: ", progName);
		va_start(arg_ptr, FormatString);
		vfprintf(debug_handle, FormatString, arg_ptr);
		va_end(arg_ptr);
		if (device == Datei)
		{
			fflush(debug_handle);
			fclose(debug_handle);
			debug_handle = fopen(devicename, "a");
		}
	}
}

/* ------------------------------------------------------------------- */

VOID DebugEnd(VOID)
{
	if (debug_handle != NULL && debug_handle != stdout)
		fclose(debug_handle);
	debug_handle = NULL;
	DebugOK = FALSE;
}

/* ------------------------------------------------------------------- */

VOID DebugStart(BYTE *prog, DEBUGDEV dev, BYTE *file)
{
	
	strcpy(progName, prog);
	device = dev;
	switch (dev)
	{
		case Con :
			debug_handle = stdout;
			break;
		case TCon :
			if (appl_find("T-CON   ") > 0)
				debug_handle = stdout;
			else
				device = null;
			break;
		case Datei:
			strcpy(devicename, file);
			break;
		case Terminal :
			strcpy(devicename, "u:\\dev\\modem1");
			break;
		case Modem1:
			strcpy(devicename, "u:\\dev\\modem1");
			break;
		case Modem2:
			strcpy(devicename, "u:\\dev\\modem2");
			break;
		case Seriell1:
			strcpy(devicename, "u:\\dev\\serial1");
			break;
		case Seriell2:
			strcpy(devicename, "u:\\dev\\serial2");
			break;
		case Prn:
			strcpy(devicename, "u:\\dev\\prn");
			break;
		default:
			device = null;
			break;
	}
	if (device != null)
		DebugOK = TRUE;
	if (device != null && device != Con && device != TCon)
	{
		if (device == Datei)
			debug_handle = fopen(devicename, "a");
		else
			debug_handle = fopen(devicename, "w");
		if (debug_handle != NULL)
			setvbuf(debug_handle, NULL, _IONBF, 0);
	}
	if (device == Terminal)
		Debug("\33[2J\33[0;0H");			/* VT100-Terminal an Modem 1 */
}

