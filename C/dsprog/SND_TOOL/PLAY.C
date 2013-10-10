#include "extern.h"

#define BLK_SIZE 32000

char *play_start;
long play_len;
char *play_buf1, *play_buf2;

/* ---------------
	 | Play sample |
	 --------------- */
void play_ondma(void)
{
long stack;
long i, c;
char *zw, *ob, zwn;

if (machine == 0x20000L)
	{
	play_buf1 = (char *)Mxalloc(BLK_SIZE, 0);
	play_buf2 = (char *)Mxalloc(BLK_SIZE, 0);
	}
else
	{
	play_buf1 = (char *)Malloc(BLK_SIZE);
	play_buf2 = (char *)Malloc(BLK_SIZE);
	}

stack = Super(0L);

c = BLK_SIZE;
i = play_len;
zw = play_buf1;
ob = play_start;
while (i)
	{
	*(zw++) = zwn = *(ob++);
	c--;

	if (ovsm_ply)
		{
		*(zw++) = (zwn + *ob) >> 1;
		c--;
		}

	i--;

	if (!c)
		{
		dma_play((char *)&play_buf1, (char *)&zw);

		c = BLK_SIZE;
		zw = play_buf2;
		play_buf2 = play_buf1;
		play_buf1 = zw;
		}
	}

dma_play((char *)&play_buf1, (char *)&zw);

Super((void *)stack);

Mfree(play_buf1);
Mfree(play_buf2);
}

/* ---------------
	 | Play sample |
	 --------------- */
void play_onpsg(void)
{
long stack;

stack = Super(0L);

Ikbdws(0, "\23");
start_psg((2457600L/4L) / spd_table[play_spd] / (ovsm_ply + 1));
Ikbdws(0, "\21");

Super((void *)stack);
}

/* --------------
   | Do playing |
   -------------- */
void play(char *play_mem, long len)
{
play_start = play_mem;
play_len = len;

switch(play_mode)
	{
	case PSG:
		play_onpsg();
		break;

	case DMA:
		play_ondma();
		break;
	}
}