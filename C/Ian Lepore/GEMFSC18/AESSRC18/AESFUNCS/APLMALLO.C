/**************************************************************************
 * APLMALLO.C - Internal service routines apl_malloc(), apl_free().
 *
 *  These are the default allocate/free routines, used by gemfast
 *  utilities that need memory for something.  They just call through
 *  to GEMDOS.  You can change the calls below to your library malloc()
 *  and free() instead of Malloc/Mfree if you want.  Or, you can do it
 *  on a per-application basis by coding apl_malloc() and apl_free() in
 *  your application so that they'll get used and the library default
 *  routines below will be ignored by the linker.
 *************************************************************************/

#include <osbind.h>
#include "gemfast.h"

typedef void *(VPFUNC)();
typedef void  (VFUNC)();

static void *default_allocator(size)
    long size;
{
    return (void *)Malloc(size);
}

static void default_releaser(block)
    void *block;
{
    Mfree(block);
}

static VPFUNC *allocator = default_allocator;
static VFUNC  *releaser  = default_releaser;

void *apl_malloc(size)
    long size;
{
    return (*allocator)(size);
}

void apl_free(block)
    void *block;
{
    if (block)
        (*releaser)(block);
}

void apl_mmvectors(newalloc, newrelease)
    VPFUNC *newalloc;
    VFUNC  *newrelease;
{
    if (newalloc && newrelease) {
        allocator = newalloc;
        releaser  = newrelease;
    }
}

