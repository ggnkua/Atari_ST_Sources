
overlay "player"

#include "..\\include\\lists.h"

abs(val)
int val;
{
if (val < 0)
	return(-val);
else
	return(val);
}

block_stuff(s, value, count)
register WORD *s, value;
int count;
{
#ifdef PARANOID
if (count & 1)
	lprintf("odd count in block_stuff\n");
#endif PARANOID
count >>= 1;
while (--count >= 0)
	*s++ = value;
}

#ifdef SLUFFED
block_zero(d, count)
register WORD *d;
int count;
{
#ifdef PARANOID
if (count & 1)
	lprintf("odd count in block_zero\n");
#endif PARANOID
count >>= 1;
while (--count >= 0)
	*d++ = 0;
}
#endif SLUFFED

block_same(b1, b2, count)
register WORD *b1, *b2;
int count;
{
if (b1 == b2)
	return(1);
else if ( b1==0 || b2==0)
	return(0);
count >>= 1;
while (--count >= 0)
	if ( *b1++ != *b2++)
	return(0);
return(1);
}


copy_structure(s,d,count)
register WORD *s,*d;
register int count;
{
#ifdef DEBUG
lprintf("copy_structure(%lx %lx %lx)\n",s,d,count);
#endif DEBUG
#ifdef PARANOID
if (count & 1)
	lprintf("odd count in copy_structure\n");
#endif PARANOID
count >>= 1;
while(--count>=0)
	*(d++) = *(s++);
}

#ifdef SLUFFED
or_structure(s, d, count)
register WORD *s,*d;
register int count;
{
#ifdef DEBUG
lprintf("or_structure(%lx %lx %lx)\n",s,d,count);
#endif DEBUG

#ifdef PARANOID
if (count & 1)
	lprintf("odd count in or_structure\n");
#endif PARANOID

count >>= 1;
while(--count>=0)
	*(d++) |= *(s++);
}
#endif SLUFFED

WORD *
clone_zero(count)
register int count;
{
register WORD *cloned;

cloned = (WORD *)alloc(count);
if (cloned)
	block_stuff(cloned, 0, count);
return(cloned);
}



int *
clone_structure(s,count)
register WORD *s;
register int count;
{
register WORD *c,*cloned;

#ifdef DEBUG
lprintf("clone_structure(->%lx count0x%lx)", s,count);
#endif DEBUG

if (s)
	{
	cloned = c = (WORD *)alloc(count);
	if (cloned)
	{

#ifdef PARANOID
	if (count & 1)
		lprintf("odd count in clone_structure\n");
#endif PARANOID
	count++;
	count >>= 1;

	while(--count>=0)
		*(c++) = *(s++);

#ifdef DEBUG
	lprintf(" = %lx\n", cloned);
#endif DEBUG
	}
	return((int *) cloned);
	}
else
	return(NULL);
}


unsigned WORD bit_masks[16] = {	0x8000, 0x4000, 0x2000, 0x1000,
					0x0800, 0x0400, 0x0200, 0x0100,
					0x0080, 0x0040, 0x0020, 0x0010,
					0x0008, 0x0004, 0x0002, 0x0001};

getbit(x, y, bitplane, words_a_line)
register WORD x;
WORD y;
register WORD *bitplane;
WORD words_a_line;
{
bitplane += y*words_a_line;
bitplane += (x>>4);
return( *bitplane & bit_masks[ x & 0x000f ] );
}

