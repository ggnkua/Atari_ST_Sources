/* PLAY_SEG.C is written by Klaus Pedersen (micro@imada.dk), and
 *	distributed, together with "NT_COMP" - the NoiseTracker Compiler
 *	for Atari [MEGA] ST, STe and TT computers.
 */

#include <tos.h>
#include "sam_play.h"
#include "mxalloc.h"

#define CHICKENFACTOR 32000l


typedef struct
	{	long magic;
		long freq;
		int  r_seg;
	}	SEGM_HEADER;
	
const long IdentFreq[]  = {'6.25', '12.5', '25.0', '50.0'};
int PlayFreq;


const char HEADTXT[] =
	"The \"SEGM Player\" is written by Klaus Pedersen (micro@imada.dk), and\n\r"
	"distributed with source, together with \"NT_COMP\"  - the NoiseTracker\n\r"
	"Compiler for Atari [MEGA] ST, STe and TT computers.\n\n\r";

const char ERROR[] =
	" is not a SEGM file!\n\n\r";

const char PLAY[] = 
	" now playing ";
	
const char STETXT[] = 
	"using the DMA sound chip.\n\r"
	"Press any key to stop.\n\r";

const char STTXT[] = 
	"on the GI-sound chip.\n\r"
	"Move the mouse to stop.\n\r";

const char USAGE[] =
	"Usage : SEGMPLAY segm_file\n\r"
	"Press any key to continue.\n\r";
	

int get_cookie(long cookie, long *p_value)
/* Returns zero if the 'cookie' is not found in the jar. 
 * if the cookie is found it returns non zero and places the
 * value in the longword pointed to by 'p_value'. If 'p_value'
 * is '0l' it does not put the value anywhere...
 */
{void *oldssp;
 long *cookiejar;
	if (Super((void *)1L) == 0l)
		oldssp = (void *)Super((void *)0l);
	else
		oldssp = 0;
	cookiejar = *(long **)0x5A0;
	if (cookiejar == 0l) goto NotFound;
	do
	{	if (*cookiejar == cookie)
		{	if (p_value != 0l) *p_value = *(cookiejar + 1);
			if (oldssp != 0) Super(oldssp);
			return 1;
		}
		cookiejar += 2;
	} while (*cookiejar != 0);
NotFound:
	if (oldssp != 0) Super(oldssp);
	return 0;
}



void *ChickenMalloc(long amount, int type)
{void *addr;
	if ((long)Mxalloc(-1l, type) < amount + CHICKENFACTOR)
		return 0l;
	addr = Mxalloc(amount, type);
	return addr;
}

	
int LoadSegm(int f, int *rep_segm, long length, long **segm)
{long *s, freq;
 char *image;
 SEGM_HEADER head;
 
 	Fread(f, sizeof(SEGM_HEADER), &head); /* read the header */
 	if (head.magic != 'SEGM')
 		return 3;

	s = IdentFreq;  /* get playback frequency from file */
	freq = 0;
	while(*s++ != head.freq)
		if (freq++ > 4)
		{	Mfree(*segm);
			return 2;
		}
	PlayFreq	= 128 + (int)freq;
	
	*rep_segm = head.r_seg; /* get repeat segment from file */

	if ((*segm = ChickenMalloc(length, MX_STON)) <= 0l)
		return 1;

	Fread(f, length, *segm); /* read file into memory */
	
/* find address of the sample image */
	s = *segm; 
	while (*s != -1)
		s += 2;
		
	image = (char *)(s + 2);
	
/* Now fixup the sequence table, (offsets -> abs. addreses) */
	s = *segm; 
	while (*s != -1)
	{	*s = (long)(image + *s);
		s += 2;
	}
	
	return 0;
}

	
main(int argc, const char *argv[])
{long snd, len;
 int f, repeat, err;
 long *samples;
 
	err = 1;
	if (argc > 1)
	{	Cconws(HEADTXT);
		if ( (f = Fopen(argv[1], 0)) <= 0 ) goto NoLoad;
		Cconws(argv[1]);
		len = Fseek(0, f, 2); Fseek(0, f, 0);

		if (!LoadSegm(f, &repeat, len, &samples))
		{	Cconws(PLAY);
			if (get_cookie('_SND', &snd) && (snd & 2)) /* DMA sound? */
			{	Cconws(STETXT);
				STe_sequence(samples, repeat, PlayFreq);
				Cnecin();
				STe_end();
			}
			else 	
			{	Cconws(STTXT);
				ST_sequence(samples, PlayFreq & 0xf, repeat);
			}
			Mfree(samples);
			err = 0;
		}
		else 
			Cconws(ERROR);
		Fclose(f);
	}
NoLoad:
	if (err)
	{	Cconws(USAGE);
		Cnecin();
	}
	return 0;
}