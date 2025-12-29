#include <ctype.h>   /* because of toupper() */

int SeqGCGCheckSum(char *, int);


int SeqGCGCheckSum(char *seq, int len)
{
	int  i;
        long check;
        
        for( i=0, check=0; i< len; i++,seq++)
                check += ((i % 57)+1) * toupper(*seq);

        return(check % 10000);
}

