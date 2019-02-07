/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"

extern struct tlib *tlibrary;

char *about_lines[] =
	{
	"      Audio-Video Sequencer",
	"            by Jim Kent",
	"",
	"A program to mix Cyber .SEQ video",
	"files with ST Replay .SPL sound",
	"files. Developed for the November",
	"1988 issue of START.",
	"",
	"Copyright  1988 Antic Publishing",
	"",
	NULL,
	};

qabout()
{
continu_from(about_lines);
}

long bytes_used;
int tracks_used;
int libs_used;

find_mem()
{
int i;
register struct tlib *t;

tracks_used = 0;
for (i=0; i<TRACKS; i++)
	{
	if (tracks[i]->type != TR_NONE)
		tracks_used++;
	}
libs_used = 0;
bytes_used = 0;
t = tlibrary;
while (t != NULL)
	{
	libs_used++;
	bytes_used += sizeof(*t) + t->bytes;
	t = t->next;
	}
}

qmemory()
{
char buf1[60], buf2[60], buf3[60], *bufs[8];

bufs[0] = "AVS Memory and Track Usage";
bufs[1] = "";
bufs[2] = buf1;
bufs[3] = buf2;
bufs[4] = buf3;
bufs[5] = NULL;

find_mem();
sprintf(buf1, "%7ld bytes free memory", mem_free);
sprintf(buf2, "%7ld bytes used in %d files", bytes_used, libs_used);
sprintf(buf3, "%7d tracks used of %d", tracks_used, TRACKS);
continu_from(bufs);
}

