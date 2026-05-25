#include "zgl.h"
void gl_draw_line(GLContext *c,GLVertex *p0,GLVertex *p1)
{
  p0->zp.r=p0->zp.g=p0->zp.b=0xffff;
  p1->zp.r=p1->zp.g=p1->zp.b=0xffff;
  if (p0->clip_code == 0 && p1->clip_code == 0) {
    ZB_line(c->zb,&p0->zp,&p1->zp);
  }
}
void gl_draw_triangle(GLContext *c,GLVertex *p0,GLVertex *p1,GLVertex *p2)
{
  gl_draw_line(c,p0,p1);
  gl_draw_line(c,p1,p2);
  gl_draw_line(c,p2,p0);
}
