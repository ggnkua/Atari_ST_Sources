/* $Id: elements.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *elements_id = "$Id: elements.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
#include <stdio.h>
#include <math.h>
#include "elements.h"

Elm_t Elements[] =
{
#include "Elements.def"
};

unsigned num_Elements = (sizeof(Elements) / sizeof(Elm_t));

char *Ep_name[nEparm] =
{
 "fn", "f1", "f2", "f3",
 "b1", "b2", "b3", "an",
 "a1", "a2", "a3", "a4",
 "a5", "a6", "ab", "av",
 "avc", "asp", "af"
};
