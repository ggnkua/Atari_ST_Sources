#include "bm.h"
#include "Extern.h"
int Search(Pattern,PatLen,EndBuff, Skip1, Skip2, Desc)
char Pattern[];
int PatLen;
char *EndBuff;
register unsigned short int Skip1[], Skip2[];
struct PattDesc *Desc;
{
	register char *k, /* indexes text */
		*j; /* indexes Pattern */
	register unsigned short Skip; /* skip distance */
	char *PatEnd,
	*BuffEnd; /* pointers to last char in Pattern and Buffer */
	register char c;
        register unsigned short DefSkip;

	BuffEnd = EndBuff;
	PatEnd = Pattern + PatLen - 1;

	k = Desc->Start;
	Skip = PatLen-1;
        c = *PatEnd;
        DefSkip = Skip2[PatLen-1];
	while ((k += Skip) <= BuffEnd) {
                if (*k == c) {
     		        j = PatEnd;
			do {
				if (j == Pattern) {
					/* found it. Start next search
					* just after the pattern */
					Desc -> Start = k + Desc->PatLen;
					return(1);
				} /* if */
			} while (*--j == *--k);
                        Skip = Skip2[j-Pattern];
		        if (Skip < Skip1[*(unsigned char *)k]) {
        		        Skip = Skip1[*(unsigned char *)k];
                        }
                } else {
		        Skip = Skip1[*(unsigned char *)k];
                        if (Skip < DefSkip) {
        		        Skip = DefSkip;
                        }
                }
	} /* while */
	Desc->Start = k-(PatLen-1);
	return(0);
} /* Search */
