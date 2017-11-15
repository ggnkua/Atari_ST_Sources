// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// $Log:$
//
// DESCRIPTION:
//
//-----------------------------------------------------------------------------

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <stdarg.h>
#include <sys/time.h>
#include <unistd.h>

#include <SDL.h>
#ifdef __MINT__
#include <mint/osbind.h>
#endif

#include "doomdef.h"
#include "m_misc.h"
#include "i_video.h"
#include "i_audio.h"
#include "i_net.h"

#include "d_net.h"
#include "g_game.h"

#include "i_system.h"

#ifdef __MINT__
enum {
	MX_STRAM=0,
	MX_TTRAM,
	MX_PREFSTRAM,
	MX_PREFTTRAM
};
#endif

sysheap_t	sysheap={DEFAULT_HEAP_SIZE,NULL};

void
I_Tactile
( int	on,
  int	off,
  int	total )
{
  // UNUSED.
  on = off = total = 0;
}

ticcmd_t	emptycmd;
ticcmd_t*	I_BaseTiccmd(void)
{
    return &emptycmd;
}

byte* I_ZoneBase (int*	size)
{
#ifdef __MINT__
	int mxalloc_present;
	long maximal_heap_size=0;

	mxalloc_present = ((Sversion()&0xFF)>=0x01)|(Sversion()>=0x1900);
	if (mxalloc_present) {
		maximal_heap_size = Mxalloc(-1,MX_PREFTTRAM);
	} else {
		maximal_heap_size = Malloc(-1);
	}
	maximal_heap_size >>= 10;
	maximal_heap_size -= 128;	/* Keep 128 KB */
	if (sysheap.kb_used>maximal_heap_size)
		sysheap.kb_used=maximal_heap_size;
#endif

    *size = sysheap.kb_used<<10;

	printf(" %d Kbytes allocated for zone\n",sysheap.kb_used);

#ifdef __MINT__
	if (mxalloc_present)
		sysheap.zone = (void *)Mxalloc(*size, MX_PREFTTRAM);
	else
#endif
		sysheap.zone = malloc (*size);

    return (byte *) sysheap.zone;
}



//
// I_GetTime
// returns time in 1/70th second tics
//
int  I_GetTime (void)
{
    int			newtics;
    static int		basetime=0;
  
    if (!basetime)
	basetime = SDL_GetTicks();
    newtics = ((SDL_GetTicks()-basetime)*TICRATE)/1000;
    return newtics;
}



//
// I_Init
//
void I_Init (void)
{
	if (SDL_Init(SDL_INIT_VIDEO|SDL_INIT_JOYSTICK|SDL_INIT_AUDIO)<0) {
		fprintf(stderr, "Can not initialize SDL: %s\n", SDL_GetError());
		exit(1);
	}
	atexit(SDL_Quit);

#ifdef __MINT__
	if (sysnetwork.layer==NETWORK_STING) {
		I_InitNetwork = I_InitNetwork_sting;
		I_ShutdownNetwork = I_ShutdownNetwork_sting;
	}
#endif

   I_InitAudio();
    //  I_InitGraphics();
}

//
// I_Quit
//
void I_Quit (void)
{
    D_QuitNetGame ();
    M_SaveDefaults ();
	I_ShutdownNetwork();
    I_ShutdownAudio();
    I_ShutdownGraphics();

	if (sysheap.zone) {
		free(sysheap.zone);
		sysheap.zone=NULL;
	}
	SDL_Quit();
    exit(0);
}

void I_WaitVBL(int count)
{
	SDL_Delay((count*1000)/(TICRATE<<1));
}


//
// I_Error
//
extern boolean demorecording;

void I_Error (char *error, ...)
{
    va_list	argptr;

    // Message first.
    va_start (argptr,error);
    fprintf (stderr, "Error: ");
    vfprintf (stderr,error,argptr);
    fprintf (stderr, "\n");
    va_end (argptr);

    fflush( stderr );

    // Shutdown. Here might be other errors.
	if (demorecording)
		G_CheckDemoStatus();

	D_QuitNetGame ();
	I_ShutdownNetwork();
	I_ShutdownAudio();
	I_ShutdownGraphics();
	if (sysheap.zone) {
		free(sysheap.zone);
		sysheap.zone=NULL;
	}
	SDL_Quit();
    exit(-1);
}
