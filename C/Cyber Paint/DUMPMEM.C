#include <ctype.h>
#include <osbind.h>

char 
hex(val)
unsigned val;
{
if (val <= 9)
	return( val + '0');
else
	return( val - 10 + 'A');
}

one_hex(buf, val)
char *buf;
unsigned val;
{
*buf++ = hex( val>>4);
*buf++ = hex( val&15);
*buf++ = 0;
}

print_hex(pt)
unsigned char *pt;
{
int count;
char buf[4];

count = 4;
while (--count >= 0)
	{
	one_hex(buf, *pt++);
	Cconws(buf);
	one_hex(buf, *pt++);
	Cconws(buf);
	Cconws(" ");
	}
}

print_ascii(pt)
unsigned char *pt;
{
int count;

count = 8;
while (--count >= 0)
	{
	if (isprint(*pt) )
		Cconout(*pt);
	else
		Cconout('.');
	pt++;
	}
}

dump_mem(pt, count)
unsigned char *pt;
int count;
{
int i;
int line_ct;
char buf[24];

line_ct = count>>3;

for (i=0; i<line_ct; i++)
	{
	sprintf(buf, "%6lx - ", pt);
	Cconws(buf);
	print_hex(pt);
	Cconout('\t');
	print_ascii(pt);
	Cconout('\r');
	Cconout('\n');
	pt += 8;
	}
}


