//
// C Wrapper for MP2 Audio Player - by Orion_ [2013]
//
// DSP MPEG Audio Layer 2 player by Tomas Berndtsson, NoBrain/NoCrew
//
// Add these files to your compilation command: mp2.c mp2.s
//

#include <TOS.H>
#include "mp2.h"

extern	unsigned long	asm_mp2_player[];
LONG					asm_mp2_start(void);
LONG					asm_mp2_stop(void);

unsigned char	*DMAbuffer = 0;
int				DMAbuflen;

char	*MP2_Load(char *filename)
{
	unsigned short	mp2filehandle;
	int				handle, size;

	if (Dsp_Lock() != 0)
		return ("Dsp already in use !");

	if (Locksnd() != 1)
	{
		Dsp_Unlock();
		return ("Sound system already in use !");
	}

	handle = Fopen(filename, 1);
	if (handle < 0)
	{
		Unlocksnd();
		Dsp_Unlock();
		return ("Cannot open MP2 file.");
	}

	mp2filehandle = handle & 0xFFFF;
	size = Fseek(0, mp2filehandle, 2);
	Fseek(0, mp2filehandle, 0);

	// Sound buffer, always in ST Ram !
	DMAbuffer = Mxalloc(size, MX_STRAM);

	if (DMAbuffer)	// If enough memory
	{
		Fread(mp2filehandle, size, DMAbuffer);
		Fclose(mp2filehandle);
		DMAbuflen = size;
	}
	else
	{
		Fclose(mp2filehandle);
		Unlocksnd();
		Dsp_Unlock();
		return ("Not enough memory to load MP2 file.");
	}

	return (0);
}


void	MP2_Start(void)
{
	if (DMAbuffer)
	{
		unsigned long	*ptr = &asm_mp2_player[28/4];

		*ptr++ = (unsigned long)DMAbuffer;
		*ptr++ = (unsigned long)DMAbuflen;
		*ptr++ = MP2_INT_SPEED;
		*ptr++ = MP2_EXT_SPEED;
		*ptr++ = MP2_LOOP;

		Supexec(asm_mp2_start);
	}
}


void	MP2_Stop(void)
{
	if (DMAbuffer)
	{
		Supexec(asm_mp2_stop);
		Mfree(DMAbuffer);
		DMAbuffer = 0;
	}
	Unlocksnd();
	Dsp_Unlock();
}
