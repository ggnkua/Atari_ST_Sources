#include <aes.h>


#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))


/* Calcule l'intersection de 2 rectangles
 * Retourne 1 si intersection non vide 0 sinon
 * r2 contient l'intersection */

int rc_intersect ( GRECT *r1, GRECT *r2) {
  int tx, ty, tw, th;

  tw = MIN(r2->g_x + r2->g_w, r1->g_x + r1->g_w);
  th = MIN(r2->g_y + r2->g_h, r1->g_y + r1->g_h);
  tx = MAX(r2->g_x, r1->g_x);
  ty = MAX(r2->g_y, r1->g_y);
  r2->g_x = tx;
  r2->g_y = ty;
  r2->g_w = tw - tx;
  r2->g_h = th - ty;
  return ((tw > tx) && (th > ty));
}

void grect_to_array( const GRECT *rect, int *array) {
  *array++ = rect->g_x;
  *array++ = rect->g_y;
  *array++ = rect->g_x + rect->g_w - 1;
  *array   = rect->g_y + rect->g_h - 1;
}

/*
int wind_set_grect( int handle, int mode, GRECT *g) {
	return wind_set( handle, mode, g->g_x, g->g_y, g->g_w, g->g_h);
}

int wind_get_grect( int handle, int mode, GRECT *g) {
	return wind_set( handle, mode, &g->g_x, &g->g_y, &g->g_w, &g->g_h);
}

*/