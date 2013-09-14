/*
 *	01/05/88	From Derek Mui.
 */
 
/*	This routine convert binary number to ascii value	*/

itoa(inword, numbuf)			
unsigned int inword;
char numbuf[];
{	
    unsigned int temp1, value;
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


atoi(ptr)
char *ptr;
{
    register int n;

    for (n = 0; (*ptr >= '0' && *ptr <= '9'); ptr++)
	n = (10 * n) + *ptr - '0'; 

    return (n);
}
