
overlay "reader"

#include <osbind.h>
#include "..\\include\\lists.h"

extern WORD *s1, *s2, *cscreen;


set_d2_front()
{
cscreen = s1;
Setscreen(s1, (long)-1, -1);
}

set_d2_back()
{
cscreen = s2;
Setscreen(s2, (long)-1, -1);
}
