/* shel_gro.c - AES 4.0 shel_grok() function
 *=======================================================================
 * 920630 kbad
 */
#include "aes4.h"
#include "_aes.h"

/* shel_grok(): tell the AES what messages you understand.
 *-----------------------------------------------------------------------
 * Does not actually call the AES on versions < 4.0.
 */
void
shel_grok(WORD bits)
{
    if (isAES4())
    {
	int_in[0] = 9;
	int_in[1] = bits;
	aes(SHEL_WRITE);
    }
}
