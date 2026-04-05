/*
 *	SNDH player lib for AHCC
 *	(c) 2010 by Simon Sunnyboy / Paradize <marndt@asmsoftware.de>
 *	http://paradize.atari.org/
 *
 *	header for SNDH player lib
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

#ifndef __SNDH_H
#define __SNDH_H

typedef struct
{
	void *tuneadr;		/* pointer to SNDH in memory      */
	char *title;		/* pointer to TITL in SNDH header */
	char *composer;		/* pointer to COMM in SNDH header */
	char *ripper;		/* pointer to RIPP in SNDH header */
	char *conv;		/* pointer to CONV in SNDH header */
	unsigned short freq;	/* parsed replay frequency        */
} SNDHTune;

/* function prototypes */
void SNDH_GetTuneInfo(void *tuneptr, SNDHTune *tune);
void SNDH_PlayTune(SNDHTune *tune, unsigned short subtunenr);
void SNDH_StopTune(void);

#endif

