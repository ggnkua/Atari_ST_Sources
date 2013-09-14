#include	"defs.h"

/*
	This module is a good candidate to be rewritten
	in assembly language.
*/
/*
	Following Block move routines support a long data count.
	The 64K ones are written in assembly code in file "stuffptr.s".
*/
/*
	Function to forward move a block.
*/
/*
Lf_move(source, target, count)
unsigned char	*source, *target;
unsigned long	count;
{
	while (count--) *target++ = *source++;
}
*/
/*
	Function to reverse move a block.
*/
Lr_move(source, target, count)
unsigned char	*source, *target;
unsigned long	count;
{
	while (count--) *target-- = *source--;
}

/*
	Function to copy a block.
*/
memcpy(target, source, count)
unsigned char	*target, *source;
unsigned	count;
{
	f_move(source, target, count);
}

/*
	Function to fill a block with a byte value.
*/
memset(target, value, count)
unsigned char	*target, value;
unsigned	count;
{
	while (count--) *target++ = value;
}

/*
	Function to compare two blocks.
*/
memcmp(target, source, count)
unsigned char	*target, *source;
unsigned	count;
{
	while (count--) if (*target++ != *source++)
		return(1);
	return(0);
}

/*
	Routine to truncate source string "s" at '.' by looking backward.
	Process is stopped if a '\' is found.
*/
strunc(s)
unsigned char	s[];
{
	unsigned	i;
	unsigned char	c;

	i = strlen(s);
	while (i && (c = s[i-1]) != '\\' && c != '.')
		--i;
	if (c == '.') s[i-1] = 0;
}

/*
	Function to change a lower case alpha character to upper case.
	Returns new or old character.
*/
char	toupper(c)
char	c;
{
	if (c >= 'a' && c <= 'z') c -= 0x20;
	return(c);
}

/*
	Routine to check if character "c" is an alphabet.
	True returns 1 else 0.
*/
calpha(c)
char	c;
{
	return((c >= 'A' && c <= 'Z')||(c >= 'a' && c <= 'z'));
}

/*
	Routine to check if character "c" is a digit.
	True returns 1 else 0.
*/
cdigit(c)
char	c;
{
	return(c >= '0' && c <= '9');
}

/*
	Routine to check if character "c" is a Start or End CP TAG.
	True returns 1 else 0.
*/
ctagc(c)
char	c;
{
	return(c == STAG || c == ETAG);
}

/*
	Routine to check if character "c" is a PI TAG.
	True returns 1 else 0.
*/
ptagc(c)
char	c;
{
	return(c == PTAG);
}

/*
	Routine to check if character "c" is a PI or CP TAG.
	True returns 1 else 0.
*/
tagc(c)
char	c;
{
	return(ptagc(c) || ctagc(c));
}

/*
	Function to check if char c is a non compose one.
	True returns 1 else 0.
*/
nocp(c)
char	c;
{
	return( c == DH || c == cr || c == lf || c == Rf ||
		c == QL || c == QR || c == QC );
}

/*
	Function to check if char c is any line ending one.
	True returns 1 else 0.
*/
allend(c)
char	c;
{
	return(c == srt || c == hrt || c == Rf);
}

/*
	Function to check if char at "ptr" is any cursor line ending one.
	True returns 1 else 0.
*/
lpend(ptr)
char	*ptr;
{
	return(*ptr == cr || allend(*ptr));
}

/*
	Function to setup Long char format.
*/
start(arr,i,c)
unsigned char	*arr;
unsigned	i;
unsigned char	c;
{
	union {
		unsigned char	byt[2];
		unsigned	val;
	} w;
	w.val	= i | (c << 8);
	*(++arr)= w.byt[0];
	*(++arr)= w.byt[1];
}
