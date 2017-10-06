# include "extdef.h"

long
evnt_keybd(void)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	return call_aes(gem, 20);
}

/* EOF */
