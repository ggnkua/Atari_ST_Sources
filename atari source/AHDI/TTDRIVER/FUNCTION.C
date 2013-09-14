/*	Function.c		11/2/88 - 2/23/89	D.Mui		*/
/*	Fix the scandisk	5/1/89	- 5/3/89	D.Mui		*/

#include "define.h"



/*
 * This routine convert binary number to ascii value
 */
itoa(inword, buffer)			
UWORD	inword;
BYTE	*buffer;
{	
	UWORD		temp1, value;
	REG WORD	i, j;
	BYTE		tmpbuf[10];
	REG BYTE	*ascbuf;
	
	ascbuf = buffer;
		
	i = 0;				/* if the value is non zero  */

	if (!inword) {
		*ascbuf++ = '0';
	} else {
		value = inword;
		while(value) {
			temp1 = value % 10;	/*  find the remainder	*/
			temp1 += 0x0030;	/*  convert to ASCII	*/
			tmpbuf[i++] = temp1;	/*  buffer is reverse	*/
	  		value = value / 10;
		}

		for (j = i-1; j >= 0; j--) 	/* reverse it back	*/
			*ascbuf++ = tmpbuf[j];
	}

	*ascbuf = 0;			/* end of string mark	*/
	return;
}



/*
 * This routine convert binary number to ASCII hex
 */
itoh(inword, buffer)			
UWORD		inword;
BYTE		*buffer;
{	
	UWORD		temp1, value;
	REG WORD	i, j;			
	BYTE		tmpbuf[12];
	REG BYTE	*ascbuf;
	
	ascbuf = buffer;
	i = 0;				/* if the value is non zero  */

	if (!inword) {
		*ascbuf++ = '0';
	} else {
		value = inword;
		while(value) {
			temp1 = value % 16;	/*  find the remainder	*/
			if (temp1 > 9)
				temp1 += 0x37;
			else
				temp1 += 0x30;	/*  convert to ASCII	*/
			tmpbuf[i++] = temp1;	/*  buffer is reverse	*/
			value = value / 16;
		}

		for (j = i-1; j >= 0; j--) 	/* reverse it back	*/
			*ascbuf++ = tmpbuf[j];
	}
	*ascbuf = 0;			/* end of string mark	*/
	return;
}



/*
 * This routine convert binary number to ascii value
 */
ltoa(longval, buffer) 
LONG	longval;
BYTE	buffer[];
{
	UWORD	digit;
	WORD	i, j, k;
	LONG	divten;
	BYTE	buf1[12];

	i = 0;
	k = 0;
	
	if (!longval) {
		buffer[k++] = '0';
	} else {
	  while(longval) {
		divten = longval / 10;
		digit = (int)(longval - (divten * 0x0AL));
		buf1[i++] = '0' + digit;
		longval = divten;
	  }

	  for (j = i-1; j >= 0; j--)
	  	buffer[k++] = buf1[j];
	}
	buffer[k] = 0;
}



/*
 * This routine convert long binary number to ASCII hex
 */
ltoh(longval, buffer) 
LONG	longval;
BYTE	buffer[];
{
	WORD	i, j, k;
	LONG	value;
	BYTE	digit;
	BYTE	buf1[12];

	for (i = 0, j = 0; j < 8; j++) {
		value = longval & 0x0000000FL;
		longval >>= 4;
		
		if ((value >= 0) && (value <= 9))
			digit = (BYTE)(value) + '0';
		else
			digit = (BYTE)(value) + 0x37;

		buf1[i++] = digit;
	    
		if (!longval)
			break;
	}

	k = 0;
	for (j = i - 1; j >= 0; j--)
		buffer[k++] = buf1[j];

	buffer[k] = 0;
}


/*
 * Change from ASCII to a binary word
 */
atoi(ptr)
char *ptr;
{
    REG WORD n;

    for (n = 0; (*ptr >= '0' && *ptr <= '9'); ptr++)
	n = (10 * n) + *ptr - '0'; 

    return (n);
}


/*
 * Change from ASCII hex to a binary word
 */
htoi(ptr)
BYTE *ptr;
{
	REG WORD n;
	BYTE t;

	for (n = 0; *ptr; ptr++) {
		t = toupper(*ptr);
		
    		if (t >= '0' && t <= '9')
			n = (16 * n) + t - '0'; 
    		else if (t >= 'A' && t <= 'F')
			n = (16 * n) + (t - 0x37); 
	}

	return (n);
}


/*
 * Change from ASCII to a binary long
 *	TRUE is OK otherwise it is FALSE
 */
atol(ptr, value)
BYTE	*ptr;
LONG	*value;
{
	LONG	n, n1;
	UWORD	i;

	for (n = 0L, i = 0, n1 = 0L; *ptr; ptr++) {
		if (*ptr >= '0' && *ptr <= '9') {
			n1 = (10 * n1) + (*ptr - '0');
			if (n1 >= n)
				n = n1;
			else
				return(FALSE);
		} else
			return(FALSE);
	}
	*value = n;
	return (TRUE);
}



/* 
 * Change from ASCII hex to a long binary value
 *	TRUE is OK , FALSE is overflow
 */
htol(ptr, value)
BYTE	*ptr;
LONG	*value;
{
	LONG	n;
	WORD	i;
	BYTE	t, toupper();

	for (n = 0L; *ptr; ptr++) {
		t = toupper(*ptr);

		if (t >= '0' && t <= '9') {
			n = (16 * n) + (t - '0');
		} else {
			if (t >= 'A' && t <= 'F')
				n = (16 * n) + (t - 0x37);
			else
				return(FALSE);
		}
	}
	*value = n;
	return (TRUE);
}



/*
 * Do a byte comparsion	
 */
bcmp(source, dest, size)
BYTE	*source;
BYTE	*dest;
UWORD	size;
{
	UWORD	i;

	for (i = 0; i < size; i++) {
		if (source[i] != dest[i])
		return(FALSE);
	}
	return(TRUE);
}


/*
 * Return uppercase of `c'
 *
 */
BYTE
toupper(c)
BYTE c;
{
    if(c >= 'a' && c <= 'z')
	c -= 0x20;
    return c;
}



bfill(source, input, size)
REG BYTE	*source;
REG BYTE	input;
REG UWORD	size;
{
	REG UWORD	i;

	for(i = 0; i < size; i++)
	  *source++ = input;
}



llfill(source, input, size)
REG LONG	*source;
REG LONG	input;
REG LONG	size;
{
	REG LONG	i;

	for(i = 0; i < size; i++)
	  *source++ = input;	
}



lbfill(source, input, size)
REG BYTE	*source;
REG BYTE	input;
REG LONG	size;
{
	REG LONG	i;

	for(i = 0; i < size; i++)
	  *source++ = input;
}




