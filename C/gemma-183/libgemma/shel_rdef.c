# include "extdef.h"

long
shel_rdef(char *lpcmd, char *lpdir)
{
# ifdef GEMMA_MULTIPROC
	GEM_ARRAY *gem;

	gem = gem_control();
# endif
	gem->addr_in[0] = (long)lpcmd;
	gem->addr_in[1] = (long)lpdir;

	return call_aes(gem, 126);
}

/* EOF */
