#include <obdefs.h>
#include <define.h>
#include <gemdefs.h>
#include <osbind.h>
#include <portab.h>

WORD
min(a, b)
WORD a, b;
{
	return ((a < b)? a : b);
}

WORD
max(a, b)
{
	return ((a > b)? a : b);
}

WORD
rc_intersect(p1, p2)
GRECT *p1, *p2;
{
	WORD tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}
