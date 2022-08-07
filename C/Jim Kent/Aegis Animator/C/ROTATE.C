
overlay "find"

#include "..\\include\\lists.h"
#include  "..\\include\\poly.h"


rotate_point(s,d,xcen,ycen,theta)
struct point *s, *d;
WORD xcen,ycen;
WORD theta;
{
WORD x,y;
WORD si,co;

x = s->x - xcen;
y = s->y - ycen;

si = isin(theta);
co = icos(theta);
d->x = itmult(x,co) + itmult(y,si) + xcen;
d->y = itmult(y,co) + itmult(x,-si) + ycen;
d->z = s->z;
d->level = s->level;
}


rotate_poly(s,d,xcen,ycen,theta)
struct poly *s, *d;
WORD xcen,ycen;
WORD theta;
{
struct point *sp, *dp;
WORD i;

sp = s->pt_list;
dp = d->pt_list;
i = s->pt_count;
while(i--)
	{
	rotate_point(sp, dp,xcen,ycen, theta);
	sp++;
	dp++;
	}
}

