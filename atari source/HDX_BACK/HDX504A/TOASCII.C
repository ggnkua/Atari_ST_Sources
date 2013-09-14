/*
 *	01/05/88	From Derek Mui.
 */
 
/*  This routine convert numeric integer to ascii integer */

#include	"mydefs.h"

itoa(inword, numbuf)			
UWORD inword;
char numbuf[];
{	
    UWORD temp1, value;
    register int i, j;
    char tmpbuf[10];
    register char *ascbuf;
	
    ascbuf = numbuf;
    i = 0;				/* if the value is non zero  */

    if (!inword)	
	*ascbuf++ = '0';
    else {
	value = inword;
	while(value) {
	    temp1 = value % 10;		/*  find the remainder	*/
	    temp1 += 0x0030;		/*  convert to ASCII	*/
	    tmpbuf[i++] = temp1;	/*  buffer is reverse	*/
	    value = value / 10;
	}

	for (j = i-1; j >= 0; j--) 	/* reverse it back	*/
	    *ascbuf++ = tmpbuf[j];
    }

    *ascbuf = 0;			/* end of string mark	*/
    return;
}


ltoa(inword, numbuf)			
long inword;
char numbuf[];
{	
    long temp1, value;
    register int i, j;
    char tmpbuf[10];
    register char *ascbuf;
	
    ascbuf = numbuf;
    i = 0;				/* if the value is non zero  */

    if (!inword)	
	*ascbuf++ = '0';
    else {
	value = inword;
	while(value) {
	    temp1 = value % 10;		/*  find the remainder	*/
	    temp1 += 0x0030;		/*  convert to ASCII	*/
	    tmpbuf[i++] = temp1;	/*  buffer is reverse	*/
	    value = value / 10;
	}

	for (j = i-1; j >= 0; j--) 	/* reverse it back	*/
	    *ascbuf++ = tmpbuf[j];
    }

    *ascbuf = 0;			/* end of string mark	*/
    return;
}


/* Convert numeric hex to ascii hex 			*/
/*	This routine convert binary number to hex value	*/
/*	The input buffer must have a zero at the end	*/
/*	size = 0 is LONG else WORD			*/

htoa(invalue, ascbuf, size)			
long	invalue;
char	ascbuf[];
int	size;		
{
    long mask, value;
    int	i,j;			

    size = (size) ? 4 : 8;

    for(i = 0; i < size; i++)	/* clean up the buffer	*/
	ascbuf[i] = '0';

    ascbuf[size] = 0;
	
    j = size;

    if (invalue) {
	mask = 0x0000000FL;
	for (i = 0; i < size; i++) {
	    value = invalue & mask;
	    invalue = invalue >> 4;
	    if (value >= 0xA)
		ascbuf[--j] = 'A' + (char)(value - 0xa);
	    else
		ascbuf[--j] = '0' + (char)value;
  	}
    }
    return;
}

