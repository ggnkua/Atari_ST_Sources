#include "lh5.h"
#include <stdlib.h>
#include <string.h>  /* memmove() */

#define NP (DICBIT + 1)
#define NT (CODE_BIT + 3)
#define PBIT 4  /* smallest integer such that (1U << PBIT) > NP */
#define TBIT 5  /* smallest integer such that (1U << TBIT) > NT */
#if NT > NP
	#define NPT NT
#else
	#define NPT NP
#endif
ushort left[2 * NC - 1], right[2 * NC - 1];
uchar *buf, c_len[NC], pt_len[NPT];
ushort c_freq[2 * NC - 1], c_code[NC],
			  p_freq[2 * NP - 1], pt_table[256], pt_code[NPT],
			  t_freq[2 * NT - 1];

#define PERCOLATE  1
#define NIL        0
#define MAX_HASH_VAL (3 * DICSIZ + (DICSIZ / 512 + 1) * UCHAR_MAX)

typedef short node;

/* uchar *text, *childcount;
 node pos, matchpos, avail, *position, *parent, *prev, *next = NULL;
 int remainder, matchlen; */

#if MAXMATCH <= (UCHAR_MAX + 1)
	 uchar *level;
#else
	 ushort *level;
#endif

