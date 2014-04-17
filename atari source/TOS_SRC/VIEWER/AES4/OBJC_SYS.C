/* objc_sys.c - AES 3.3 objc_sysvar() function
 *=======================================================================
 * 920805 kbad
 */
#include <aes4.h>
#include "_aes.h"

/* objc_sysvar(): set/inquire object-related system variables
 *-----------------------------------------------------------------------
 */
int
objc_sysvar(int set, int which, int ani_col, int chcolor,
	    short *oani_col, short *ochcolor)
{
    int ret;
    if (!isAES33()) return AESERR;

    int_in[0] = set;
    int_in[1] = which;
    int_in[2] = ani_col;
    int_in[3] = chcolor;
    ret = aes(OBJC_SYSVAR);
    if (oani_col) *oani_col = int_out[1];
    if (ochcolor) *ochcolor = int_out[2];
    return ret;
}


