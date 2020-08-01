/********************************************************************
 *																0.01*
 *	XAES: Callback routine definitions								*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (C) 1994, Bitgate Software.							*
 *																	*
 ********************************************************************/

#include <stdlib.h>
#include "xaes.h"

INITS GlobInits;

/*
 *	Set GLOBAL (Yes, this means PROGRAM-WIDE) callback routines for
 *	initialization, and whatever the hell else I came up with
 */
GLOBAL void WSetCallback(int CBType, void *CallBackRout)
{
	switch(CBType) {
		case XC_INITIALIZE:
			GlobInits.Initialize = malloc(sizeof(CallBackRout));
			GlobInits.Initialize = CallBackRout;
			break;

		case XC_DEINITIALIZE:
			GlobInits.Deinitialize = malloc(sizeof(CallBackRout));
			GlobInits.Deinitialize = CallBackRout;
			break;

		case XC_STARTUP:
			GlobInits.Startup = malloc(sizeof(CallBackRout));
			GlobInits.Startup = CallBackRout;
			break;

		case XC_EXIT:
			GlobInits.Exit = malloc(sizeof(CallBackRout));
			GlobInits.Exit = CallBackRout;
			break;
	}
}

/*
 *	This actually CALLS the callback routine.  I thought that since
 *	I made everything lazy-and-painless, I'd make this one the same.
 */
GLOBAL void DoCallback(int CBType)
{
	switch(CBType) {
		case XC_INITIALIZE:
			if (GlobInits.Initialize != NULL)
				GlobInits.Initialize();
			break;

		case XC_DEINITIALIZE:
			if (GlobInits.Deinitialize != NULL)
				GlobInits.Deinitialize();
			break;

		case XC_STARTUP:
			if (GlobInits.Startup != NULL)
				GlobInits.Startup();
			break;

		case XC_EXIT:
			if (GlobInits.Exit != NULL)
				GlobInits.Exit();
			break;
	}
}

/*
 *	Gee, I wonder what this one does.
 */
GLOBAL void ClearCallbacks(void)
{
	if (GlobInits.Initialize != NULL)	free(GlobInits.Initialize);
	if (GlobInits.Deinitialize != NULL)	free(GlobInits.Deinitialize);
	if (GlobInits.Startup != NULL)		free(GlobInits.Startup);
	if (GlobInits.Exit != NULL)			free(GlobInits.Exit);
}