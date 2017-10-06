# include "extdef.h"

# ifndef GEMMA_MULTIPROC

short
call_aes(GEM_ARRAY *gem, short fn)
{
	return (short)(gemma.exec)(gemma.handle, (long)CALL_AES, (short)2, gem, fn);
}

# else

short
call_aes(GEM_ARRAY *gem, short fn)
{
	return (short)(gemma[_pid].exec)(gemma[_pid].handle, (long)CALL_AES, (short)2, gem, fn);
}

# endif

/* EOF */
