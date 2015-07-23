#include "dsp_bine.h" /* binary for external clock */
#include "dsp_bini.h" /* binary for internal clock */

long get_bin_len(int ext)
{
	if(ext)
		return (long)sizeof(dsp_binext);
	else
		return (long)sizeof(dsp_binint);
}
