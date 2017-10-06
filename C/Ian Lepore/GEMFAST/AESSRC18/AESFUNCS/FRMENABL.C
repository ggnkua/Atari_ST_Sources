/**************************************************************************
 * FRMENABL.C - Set the blit function vector.
 *************************************************************************/

#include <osbind.h>
#include "gemfast.h"

extern  long (*_FrBltVector)();

void frm_enableblit()
{
    _FrBltVector = grf_blit;
}
