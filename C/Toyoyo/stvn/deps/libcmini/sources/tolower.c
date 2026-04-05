#include <ctype.h>
#include "ctypeint.h"

int (tolower)(int c)
{
	return isupper(c) ? ((c) + 'a' - 'A') : (c);
}
