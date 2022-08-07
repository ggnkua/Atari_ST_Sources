
#include "..\\include\\lists.h"

jblit0(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = ~(*image++);
		*dest++ &= data;
		*dest++ &= data;
		*dest++ &= data;
		*dest++ &= data;
		}
	dest += mod;
	}		
}

jblit1(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = ~(*image++);
		*dest++ |= ~data;
		*dest++ &= data;
		*dest++ &= data;
		*dest++ &= data;
		}
	dest += mod;
	}		
}

jblit2(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = ~(*image++);
		*dest++ &= data;
		*dest++ |= ~data;
		*dest++ &= data;
		*dest++ &= data;
		}
	dest += mod;
	}		
}

jblit3(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ |= data;
		*dest++ |= data;
		*dest++ &= ~data;
		*dest++ &= ~data;
		}
	dest += mod;
	}		
}

jblit4(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = ~(*image++);
		*dest++ &= data;
		*dest++ &= data;
		*dest++ |= ~data;
		*dest++ &= data;
		}
	dest += mod;
	}		
}

jblit5(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ |= data;
		*dest++ &= ~data;
		*dest++ |= data;
		*dest++ &= ~data;
		}
	dest += mod;
	}		
}

jblit6(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ &= ~data;
		*dest++ |= data;
		*dest++ |= data;
		*dest++ &= ~data;
		}
	dest += mod;
	}		
}

jblit7(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ |= data;
		*dest++ |= data;
		*dest++ |= data;
		*dest++ &= ~data;
		}
	dest += mod;
	}		
}

jblit8(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = ~(*image++);
		*dest++ &= data;
		*dest++ &= data;
		*dest++ &= data;
		*dest++ |= ~data;
		}
	dest += mod;
	}		
}

jblit9(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ |= data;
		*dest++ &= ~data;
		*dest++ &= ~data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}

jblita(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ &= ~data;
		*dest++ |= data;
		*dest++ &= ~data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}

jblitb(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ |= data;
		*dest++ |= data;
		*dest++ &= ~data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}

jblitc(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = ~(*image++);
		*dest++ &= data;
		*dest++ &= data;
		data = ~data;
		*dest++ |= data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}

jblitd(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = (*image++);
		*dest++ |= data;
		*dest++ &= ~data;
		*dest++ |= data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}


jblite(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = *image++;
		*dest++ &= ~data;
		*dest++ |= data;
		*dest++ |= data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}

jblitf(wwidth, height, image, dest)
WORD wwidth, height;
register WORD *image, *dest;
{
register WORD mod, i, data;

mod = 80 - (wwidth<<2);
while (--height >= 0)
	{
	i = wwidth;
	while (--i >= 0)
		{
		data = *image++;
		*dest++ |= data;
		*dest++ |= data;
		*dest++ |= data;
		*dest++ |= data;
		}
	dest += mod;
	}		
}

(*jblit_table[])() = 
	{
	jblit0, jblit1, jblit2, jblit3,
	jblit4, jblit5, jblit6, jblit7,
	jblit8, jblit9, jblita, jblitb,
	jblitc, jblitd, jblite, jblitf,
	};
