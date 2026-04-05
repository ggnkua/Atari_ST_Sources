#include <ctype.h>
#include "ctypeint.h"

int (toupper)(int c)
{
	return islower(c) ? ((c) - 'a' + 'A') : (c);
}
