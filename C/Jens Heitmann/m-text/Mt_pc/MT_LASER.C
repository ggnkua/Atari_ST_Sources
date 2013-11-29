#include <aes.h>

int min(int a, int b)
{
return ((a < b) ? a : b);
}

int max(int a, int b)
{
return ((a > b) ? a : b);
}

int pt_inrect(int x, int y, int x1, int y1, int w1, int h1)
{
int xd, yd;

xd = max(x1, min(x, x1 + w1 -1));
yd = max(y1, min(y, y1 + h1 -1));

return ((xd == x) && (yd == y));
}

int rect_intersect(int wx, int wy, int ww, int wh, GRECT r_rec, GRECT *red_rc)
{
int tx, ty, tw, th;

tw = min(r_rec.g_x + r_rec.g_w, wx + ww);
th = min(r_rec.g_y + r_rec.g_h, wy + wh);
tx = max(r_rec.g_x, wx);
ty = max(r_rec.g_y, wy);
red_rc->g_x = tx;
red_rc->g_y = ty;
red_rc->g_w = tw - tx;
red_rc->g_h = th - ty;

return ((tw > tx) && (th > ty));
}
