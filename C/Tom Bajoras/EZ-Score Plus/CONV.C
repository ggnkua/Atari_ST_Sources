#include <ctype.h>

int toupper(c)
int c;
{
    if (c >= 'a' && c <= 'z')
	return _toupper(c);
    else
	return c;
}

int tolower(c)
int c;
{
    if (c >= 'A' && c <= 'Z')
	return _tolower(c);
    else
	return c;
}

int toascii(c)
int c;
{
    return c & 0x7f;
}
