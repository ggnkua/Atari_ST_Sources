#include "global.h"
#include "set.h"

static char bits[] = {128, 64, 32, 16, 8, 4, 2, 1};

/*****************************************************************************/

int setfree(SET set)
{
	int	i;
	unsigned long help, h;

	h = 0xFFFFFFFFL;
	for (i = 0; i < SETMAX; i += 32)
		if ((help = *set++) != h)
		{
			h = 0x80000000L;
			while (help >= h)
			{
				i++; 
				help <<= 1;
			}
			break;
		}
	return i;
}

/*****************************************************************************/

int setmax(SET set)
{
	int	i;
	unsigned long help;

	for (i = SETSIZE; (--i) >= 0; )
		if ((help = set[i]) != 0L)
		{
			i *= 32;
			for (i+=31; (help&1L)==0; i--,help>>=1) ;
			return (i);
		}
	return -1;
}

/*****************************************************************************/

int setmin(SET set)
{
	int	i;
	unsigned long help, h;

	for (i=0; i<SETMAX; i+=32)
		if ((help=*set++)!=0L)
		{
			h = 0x80000000L;
			while (help<h)
			{
				i++; help<<=1;
			}
			break;
		}
	return i;
}

/*****************************************************************************/

void setcpy (SET set1, SET set2)
{
	memcpy(set1, set2, SETSIZE * (int) sizeof(unsigned long));
}

/*****************************************************************************/
#if (SETSIZE&1)!=0
	So gehts nicht
#endif

void setall (SET set)
{
	int i;

	i = SETSIZE/2;
	while ((--i)>=0)
	{
		*set++ = 0xFFFFFFFFL;
		*set++ = 0xFFFFFFFFL;
	}
}

/*****************************************************************************/

void setclr (SET set)
{
	int i;

	i = SETSIZE/2;
	while ((--i)>=0)
	{
		*set++ = 0L;
		*set++ = 0L;
	}
}

/*****************************************************************************/

void setnot (SET set)
{
	int i;

	i = SETSIZE/2;
	while ((--i)>=0)
	{
		*set++ ^= 0xFFFFFFFFL;
		*set++ ^= 0xFFFFFFFFL;
	}
}

/*****************************************************************************/

void setand (SET set1, SET set2)
{
	int i;

	i = SETSIZE/2;
	while ((--i)>=0)
	{
		*set1++ &= *set2++;
		*set1++ &= *set2++;
	}
}

/*****************************************************************************/

void setor (SET set1, SET set2)
{
	int i;

	i = SETSIZE/2;
	while ((--i)>=0)
	{
		*set1++ |= *set2++;
		*set1++ |= *set2++;
	}
}

/*****************************************************************************/

void setxor (SET set1, SET set2)
{
	int i;

	i = SETSIZE/2;
	while ((--i)>=0)
	{
		*set1++ ^= *set2++;
		*set1++ ^= *set2++;
	}
}

/*****************************************************************************/

void setincl (SET set, int elt)
{
	if (elt>=0 && elt<=SETMAX)
		*((char*)set+(elt>>3)) |= bits[elt&7];
}

/*****************************************************************************/

void setexcl (SET set, int elt)
{
	if (elt>=0 && elt<=SETMAX)
		*((char*)set+(elt>>3)) &= ~bits[elt&7];
}

/*****************************************************************************/

void setchg (SET set, int elt)
{
	if (elt>=0 && elt<=SETMAX)
		*((char*)set+(elt>>3)) ^= bits[elt&7];
}

/*****************************************************************************/

bool setin (SET set, int elt)
{
	if (elt>=0 && elt<=SETMAX)
		return ((*((char*)set+(elt>>3)) & bits[elt&7]) ? TRUE : FALSE);
	else
		return (FALSE);
}

/*****************************************************************************/

bool setcmp (SET set1, SET set2)
{
	int i;

	if (set2==NULL)
		for (i=0; i<SETSIZE && *set1++==0; i++);
	else
		for (i=0; i<SETSIZE && *set1++==*set2++; i++);
	return (i==SETSIZE);
} 

/*****************************************************************************/

int setcard (SET set)
{
	int i, card, max;

	max = setmax(set);
	for (i=setmin(set), card=0; i<=max; i++)
		if (setin (set, i)) card++;

	return (card);
}

/*****************************************************************************/

void str2set (char *str, SET set)
{
	int	i;

	setclr(set);
	i = 0;
	while(str[i])
	{
		if (str[i]=='-' && i>0)
		{
			char c;

			i++;
			for (c=str[i-2]; c<str[i]; c++)
				setincl(set,c);
		}
		else
			setincl(set,str[i++]);
	}
}
