/*
 *	SNDH player lib for AHCC
 *	(c) 2010 by Simon Sunnyboy / Paradize <marndt@asmsoftware.de>
 *	http://paradize.atari.org/
 *
 *	SNDH player library routines
 *	some parsing algorithms are derived from GODLIB
 *
 *	This library is free software; you can redistribute it and/or
 *	modify it under the terms of the GNU Lesser General Public
 *	License as published by the Free Software Foundation; either
 *	version 2.1 of the License, or (at your option) any later version.
 *
 *	This library is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *	Lesser General Public License for more details.
 *
 *	You should have received a copy of the GNU Lesser General Public
 *	License along with this library; if not, write to the Free Software
 *	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 */

#include "sndh.h"

#if (!defined NULL)
#define NULL 0
#endif

/* internal variables */
SNDHTune *SNDH_ActiveTune;	/* this is not NULL if a tune has been hookedup for play */

/* prototype of internal functions */
void 		SNDH_PlayTuneISR(void *tuneptr, unsigned short freq, unsigned short subtune);
void		SNDH_StopTuneISR(void);
char*		SNDH_FindLongInHeader(char* chunk, char *tag);
char*		SNDH_FindWordInHeader(char* chunk, char *tag);
unsigned short	SNDH_ParseDecimal(char *chunk);
unsigned char	SNDH_IsTunePlaying(void);

/* functions */
void SNDH_GetTuneInfo(void *tuneptr, SNDHTune *tune)
{
	char *parser, *freqtag;

	/* assert valid SNDH tune */
	if(tuneptr == NULL)
	{
		tune = NULL;
		return;
	}

	parser = (char *)tuneptr;
	if(SNDH_FindLongInHeader(parser, "SNDH") != 0)
	{
		/* SNDH file is valid */
		tune->tuneadr  = tuneptr;
		/* get pointers to SNDH meta data */
		tune->title    = SNDH_FindLongInHeader(parser, "TITL");
		tune->composer = SNDH_FindLongInHeader(parser, "COMM");
		tune->ripper   = SNDH_FindLongInHeader(parser, "RIPP");
		tune->conv     = SNDH_FindLongInHeader(parser, "CONV");
		/* try to parse replay frequency */
		if( (freqtag = SNDH_FindWordInHeader(parser,"TC")))
		{
			/* Timer C tunes have priority in detection */
			tune->freq = SNDH_ParseDecimal(freqtag);
		}
		else if( (freqtag = SNDH_FindWordInHeader(parser,"TA")))
		{
			tune->freq = SNDH_ParseDecimal(freqtag);
		}
		else if( (freqtag = SNDH_FindWordInHeader(parser,"TB")))
		{
			tune->freq = SNDH_ParseDecimal(freqtag);
		}
		else if( (freqtag = SNDH_FindWordInHeader(parser,"TD")))
		{
			tune->freq = SNDH_ParseDecimal(freqtag);
		}
		else if( (freqtag = SNDH_FindWordInHeader(parser,"V!")))
		{
			tune->freq = SNDH_ParseDecimal(freqtag);
		}
		else
		{
			/* unknown replay speed - default to 50Hz */
			tune->freq = 50;
		}
	}
	else
	{
		tune = NULL;
	}
	return;
}

void SNDH_PlayTune(SNDHTune *tune, unsigned short subtune)
{
	if(tune == NULL)
	{
		/* tune is not valid */
		return;
	}

	if(SNDH_IsTunePlaying())
	{
		SNDH_StopTune();
	}
	if(tune->tuneadr != NULL)
	{
		SNDH_ActiveTune = tune;
		SNDH_PlayTuneISR(tune->tuneadr, tune->freq, subtune);
	}
	return;
}

void SNDH_StopTune(void)
{
	SNDH_ActiveTune = NULL;
	SNDH_StopTuneISR();
	return;
}

unsigned char SNDH_IsTunePlaying()
{
	return( ((SNDH_ActiveTune == NULL) ? 0 : 1 ));
}

char* SNDH_FindLongInHeader(char* chunk, char *tag)
{
	unsigned short i;

	for( i=0; i<1024; i++ )
	{
		if(  (chunk[i]   == tag[ 0 ] )
		   &&(chunk[i+1] == tag[ 1 ] )
		   &&(chunk[i+2] == tag[ 2 ] )
		   &&(chunk[i+3] == tag[ 3 ] )
		  )
		{
			return( &chunk[i+4] );
		}
	}
	return( NULL );
}

char* SNDH_FindWordInHeader(char* chunk, char *tag)
{
	unsigned short i;

	for( i=0; i<1024; i++ )
	{
		if(  (chunk[i]   == tag[ 0 ] )
				    &&(chunk[i+1] == tag[ 1 ] )
		  )
		{
			return( &chunk[i+2] );
		}
	}
	return( NULL );
}

unsigned short SNDH_ParseDecimal(char *chunk)
{
	unsigned short value = 0;

	while( *chunk )
	{
		value *= 10;
		value += *chunk++ - '0';
	}

	return( value );
}
