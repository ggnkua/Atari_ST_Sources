/* objc_gcl.c - AES 3.3 objc_gclip() function
 *=======================================================================
 * 920805 kbad
 */
#include <aes4.h>
#include "_aes.h"

void
objc_gclip(const OBJECT *tree, int obj, WORD *px, WORD *py, GRECT *clip)
{
    if (!isAES33()) return;

    addr_in[0] = (void *)tree;
    int_in[0] = obj;
    aes(OBJC_OFFSET);
    if (px) *px = int_out[1];
    if (py) *py = int_out[2];
    if (clip) *clip = *(GRECT *)&int_out[3];
}
