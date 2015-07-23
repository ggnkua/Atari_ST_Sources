#include <tos.h>

#include "snddefs.h"
#include "mp2audio.h"

/* Function in this module */
void mute(int mode);

void mute(int mode)
{
	static int ltatten, rtatten, ltgain, rtgain;

	if (mode) { /* mode==MUTE */
		/* Save old settings */
		ltatten = (int) soundcmd(LTATTEN, -1);
		rtatten = (int) soundcmd(RTATTEN, -1);
		ltgain = (int) soundcmd(LTGAIN, -1);
		rtgain = (int) soundcmd(RTGAIN, -1);
		soundcmd(LTATTEN, 0x00f0);
		soundcmd(RTATTEN, 0x00f0);
		soundcmd(RTGAIN, 0x0000);
		soundcmd(LTGAIN, 0x0000);
	} else { /* mode==MUTE_RESTORE */
		/* Restore old settings */
		soundcmd(LTATTEN, ltatten);
		soundcmd(RTATTEN, rtatten);
		soundcmd(LTGAIN, ltgain);
		soundcmd(RTGAIN, rtgain);
	}
}
