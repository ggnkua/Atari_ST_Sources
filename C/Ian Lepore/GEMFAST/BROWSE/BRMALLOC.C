/*****************************************************************************
 * BRMALLOC - Default memory alloc/free routines.
 *
 *	If for some reason you don't want to use your compiler's malloc/free,
 *	you can supply your own br_malloc and br_free and all browser memory
 *	management will use the routines you supply.
 ****************************************************************************/
#include <stdlib.h>
#include "browser.h"

#if __SOZOBONC__ < 0x0140
  typedef short size_t;
  extern  void	*malloc();
  extern  void	free();
#endif

void *br_malloc(amount)
	size_t amount;
{
	return malloc(amount);
}

void br_free(block)
	void *block;
{
	if (block)
		free(block);
}
