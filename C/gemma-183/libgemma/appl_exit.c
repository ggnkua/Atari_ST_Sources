# include "extdef.h"

long
appl_exit(void)
{
# ifdef GEMMA_MULTIPROC
	gem = gem_control();
# endif
	return call_aes(gem, 19);
}

/* EOF */
