#include <stdio.h>
#include "proff.h"
#include "debug.h"

#define brk brrk

/*
 * putwrd - put a word in outbuf; includes margin justification
 *
 */
putwrd(wrdbuf)
char wrdbuf[];
{
	int last, llval, extra, w;

dprintf("putwrd  ");
	w = width(wrdbuf);
	last = strlen(wrdbuf) + outp;         /* new end of outbuf */
#ifdef DEBUG
printf("strlen(wrdbuf) = %d\n",strlen(wrdbuf));
#endif
	llval = rmval - tival;
	if (outw + w > llval || last >= MAXOUT) {    /* too big */
		last -= outp;
		extra = llval - outw;
#ifdef DEBUG
printf("extra = %d\n",extra);
#endif
		for ( ; outp > 0; outp--)
			if (outbuf[outp-1] == ' ')
				extra++;
			else
				break;
		if (rjust == YES) {
			spread(outbuf, outp, extra, outwds);
			if (extra > 0 && outwds > 1)
				outp += extra;
		}
		brk();		/* flush previous line */
	}
#ifdef DEBUG
printf("putwrd: last=%d w=%d outp=%d llval=%d outw=%d extra=%d\n",
		last,w,outp,llval,outw,extra);
#endif
	strcpy(&outbuf[outp],wrdbuf);
	outp = last;
	outw += w;
	outwds++;
}
