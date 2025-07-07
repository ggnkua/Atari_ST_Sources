#include "c_includes.h"
/*
 * c_draw.c
 * Todd W Mummert, CMU, January 1991
 *
 * ATARI Mods - Roland Givan Summer/Autumn 1993
 *
 * This is an attempt at cleaning up the drawing routines.
 */

/*
 * this routine is for points which cannot change their bearing and have
 * no moving parts; i.e., blocks.
 */
void calcpointsI(dc, method, index, g, pl)
     DCp dc;
     Methodp method;
     int index;
     Genericp g, pl;
{
  int i;
  float xpoff, ypoff, prx, pry, prz, dx, dy;
  Coord2dp new;
  Coord3dp old;

  old = dc->s->object+index;
  new = dc->points+index;
  dx = pl->x - dc->pos.x;
  dy = pl->y - dc->pos.y;
  for (i=0; i<method->num; i++, old++, new++) {
      xpoff = old->x - dx;
      ypoff = old->y - dy;
      prx =  xpoff * pl->ca + ypoff * pl->sa;
      pry = -xpoff * pl->sa + ypoff * pl->ca;
      if (pry < 10.0)
        pry = 10.0;
      prz = old->z + dc->pos.z;
      new->x = 500 + prx / pry * 450;
      new->y = 260 - prz / pry * 450;
    }
}

/*
 * this routine is for points which may change their bearing, but do not
 * have moving parts.
 */
void calcpointsII(dc, method, index, g, pl)
     DCp dc;
     Methodp method;
     int index;
     Genericp g, pl;
{
  int i;
  float csa, ssa, dx, dy, xn, yn, cn, sn, prx, pry, prz, rx, ry;
  Coord2dp new;
  Coord3dp old;

  old = dc->s->object+index;
  new = dc->points+index;

  csa = cos(g->azm);
  ssa = sin(g->azm);
  dx = pl->x - dc->pos.x;
  dy = pl->y - dc->pos.y;
  xn =  dx * csa + dy * ssa;
  yn = -dx * ssa + dy * csa;
  cn = pl->ca * csa + pl->sa * ssa;
  sn = pl->sa * csa - ssa * pl->ca;
  for (i=0; i<method->num; i++, old++, new++) {
    rx =  old->x - xn;
    ry =  old->y - yn;
    prx =  rx * cn + ry * sn;
    pry = -rx * sn + ry * cn;
    if (pry < 10.0)
      pry = 10.0;
    prz = old->z + dc->pos.z;
    new->x = 500 + prx / pry * 450;
    new->y = 260 - prz / pry * 450;
  }
}

/*
 * this routine is for points which do not change their bearing,
 * but have moving parts which rotate around the center of the
 * object.
 */
void calcpointsIII(dc, method, index, g, pl)
     DCp dc;
     Methodp method;
     int index;
     Genericp g, pl;
{
  int i;
  float temp, dx, dy, xn, yn, cn, sn, prx, pry, prz, rx, ry;
  Coord2dp new;
  Coord3dp old;

  old = dc->s->object+index;
  new = dc->points+index;
  temp = dc->cta;
  dc->cta = dc->cta * method->vars[0] - dc->sta * method->vars[1];
  dc->sta = dc->sta * method->vars[0] + temp * method->vars[1];
  dx = pl->x - dc->pos.x;
  dy = pl->y - dc->pos.y;
  xn =  dx * dc->cta + dy * dc->sta;
  yn = -dx * dc->sta + dy * dc->cta;
  cn = pl->ca * dc->cta + pl->sa * dc->sta;
  sn = pl->sa * dc->cta - pl->ca * dc->sta;
  for (i=0; i<method->num; i++, old++, new++) {
    rx =  old->x - xn;
    ry =  old->y - yn;
    prx =  rx * cn + ry * sn;
    pry = -rx * sn + ry * cn;
    if (pry < 10.0)
      pry = 10.0;
    prz = old->z + dc->pos.z;
    new->x = 500 + prx / pry * 450;
    new->y = 260 - prz / pry * 450;
  }
}

/*
 * this routine is for points which do change their bearing,
 * and have moving parts which do not rotate around the center of the
 * object.  an example is the offset radar dish of the normal tanks.
 */
void calcpointsIV(dc, method, index, g, pl)
     DCp dc;
     Methodp method;
     int index;
     Genericp g, pl;
{
  int i;
  float temp, dx, dy, xn, yn, cn, sn, prx, pry, prz, rx, ry, csa, ssa;
  Coord2dp new;
  Coord3dp old;
  Float2d pivot;

  old = dc->s->object+index;
  new = dc->points+index;
  temp = dc->cta;
  dc->cta = dc->cta * method->vars[0] - dc->sta * method->vars[1];
  dc->sta = dc->sta * method->vars[0] + temp * method->vars[1];
  csa = cos(g->azm);
  ssa = sin(g->azm);
  dx = pl->x - dc->pos.x;
  dy = pl->y - dc->pos.y;
  xn =  dx * csa + dy * ssa;
  yn = -dx * ssa + dy * csa;
  cn = pl->ca * csa + pl->sa * ssa;
  sn = pl->sa * csa - ssa * pl->ca;
  pivot.x = method->vars[2] - xn;
  pivot.y = method->vars[3] - yn;
  for (i=0; i<method->num; i++, old++, new++) {
    rx = old->x * dc->cta - old->y * dc->sta + pivot.x;
    ry = old->x * dc->sta + old->y * dc->cta + pivot.y;
    prx =  rx * cn + ry * sn;
    pry = -rx * sn + ry * cn;
    if (pry < 10.0)
      pry = 10.0;
    prz = old->z + dc->pos.z;
    new->x = 500 + prx / pry * 450;
    new->y = 260 - prz / pry * 450;
  }
}

/*
 * draw plines and mlines
 *
 */
void displayobject(dc)
     DCp dc;
{
  Coord2dp point;
  int *i;

  point=dc->points;
  for (i=dc->s->pnum; *i; i++) {
    polyline(point, *i);
    point += *i;
  }
  for (i=dc->s->mnum; *i; i++) {
    multiline(point, *i>>1);
    point += *i;
  }
}

void drawobject(g, pl)
     Genericp g, pl;
{
  static Coord3d cube[] = {
    -40,  40, -40,   -40,  40,  40,    40,  40,  40,    40,  40, -40,
    -40,  40, -40,   -40, -40, -40,    40, -40, -40,    40, -40,  40,
    -40, -40,  40,   -40, -40, -40,   -40, -40,  40,   -40,  40,  40,
     40, -40,  40,    40,  40,  40,    40, -40, -40,    40,  40, -40};
  static int cubepnum[] = {10, 0};
  static int cubemnum[] = {6, 0};
  static Method cubemethods[] = {16, calcpointsI, NULL,
                                   0, NULL, NULL};

  static Coord3d pyramid[] = {
    -40,  40, -40,    40,  40, -40,     40, -40, -40,     40,  40, -40,
      0,   0,  40,   -40,  40, -40,    -40, -40, -40,      0,   0,  40,
     40, -40, -40,   -40, -40, -40};
  static int pyramidpnum[] = {10, 0};
  static int pyramidmnum[] = {0};
  static Method pyramidmethods[] = {10, calcpointsI, NULL,
                                      0, NULL, NULL};

  static Coord3d salvo[] = {
      0, -10,  -8,     8, -10,   0,      0, -10,   8,      8, -10,   0,
      0,  10,   0,     0, -10,   8,     -8, -10,   0,      0,  10,   0,
      0, -10,  -8,    -8, -10,   0};
  static int salvopnum[] = {10, 0};
  static int salvomnum[] = {0};
  static Method salvomethods[] = {10, calcpointsII, NULL,
                                    0, NULL, NULL};

  static Coord3d lander[] = {
      0,   0,  20,     80,   0, -20,     40,   0, -40,    -40,   0, -40,
    -80,   0, -20,      0,   0,  20,      0,  80, -20,      0,  40, -40,
      0, -40, -40,      0, -80, -20,      0,   0,  20,    -57, -57, -20,
    -28, -28, -40,     28,  28, -40,     57,  57, -20,      0,   0,  20,
     57, -57, -20,     28, -28, -40,    -28,  28, -40,    -57,  57, -20,
      0,   0,  20};
  static int landerpnum[] = {21, 0};
  static int landermnum[] = {0};
  static float landervars[] =  {0.996195, 0.087156};
  static Method landermethods[] = {21, calcpointsIII, landervars,
                                    0, NULL, NULL};

  static Coord3d missile[] = {
     15, -30, -25,     25, -30,   0,      0, -45,   0,     15, -30, -25,
    -15, -30, -25,      0, -45,   0,     15, -30,  25,    -15, -30,  25,
      0, -45,   0,    -25, -30,   0,    -15, -30,  25,     15, -30, -25,
      0,  50,   0,     25, -30,   0,     15, -30,  25,      0,  50,   0,
    -15, -30, -25,    -25, -30,   0,      0,  50,   0,    -15, -30,  25,
     13, -17, -21,     15, -30, -25,     23, -38, -40,     23,   0, -40,
     13, -17, -21,    -13, -17, -21,    -15, -30, -25,    -23, -38, -40,
    -23,   0, -40,    -13, -17, -21};
  static int missilepnum[] = {11, 9, 5, 5, 0};
  static int missilemnum[] = {0};
  static Method missilemethods[] = {30, calcpointsII, NULL,
                                    0, NULL, NULL};

  static Coord3d copter[] = {
       6,  100,   30,     -6, -100,   30,      6, -100,   30,
      -6,  100,   30,      6,  100,   30,      0, -114,  -10,
       7,  -30,  -34,     10,  -34,  -14,      0, -116,    0,
       0, -134,   28,      0, -144,   28,      0, -130,  -10,
       0, -114,  -10,     -7,  -30,  -34,    -10,  -34,  -14,
       0, -116,    0,    -14,   34,  -34,     14,   34,  -34,
       0,   60,  -14,    -14,   34,  -34,     -7,  -30,  -34,
       7,  -30,  -34,     14,   34,  -34,     26,   34,  -14,
       0,   60,  -14,    -26,   34,  -14,    -10,  -34,  -14,
      10,  -34,  -14,     26,   34,  -14,      4,   20,   16,
       0,   22,   16,     -4,   20,   16,     -4,  -22,   16,
       4,  -22,   16,      4,   20,   16,      0,    0,   16,
       0,    0,   36,    -14,  -30,  -40,    -14,   40,  -40,
     -14,   40,  -40,    -14,   44,  -36,     14,  -30,  -40,
      14,   40,  -40,     14,   40,  -40,     14,   44,  -36,
     -10,  -34,  -14,     -4,  -22,   16,     10,  -34,  -14,
       4,  -22,   16,      0,   22,   16,      0,   60,  -14,
     -14,   34,  -34,    -26,   34,  -14,    -26,   34,  -14,
      -4,   20,   16};
  static int copterpnum[] = {5, 11, 19, 0};
  static int coptermnum[] = {10, 10, 0};
  static float coptervars[] = {0.819152, 0.573576};
  static Method coptermethods[] = {5, calcpointsIII, coptervars,
                                     50, calcpointsII, NULL,
                                     0, NULL, NULL};

  static Coord3d super[] = {
      3,  55,  -6,     3,  55,   0,    -3,  55,   0,    -3,  55,  -6,
      3,  55,  -6,     0,  35, -33,    13, -60,  -6,    11, -60,   4,
     11, -25,   4,     0,  35, -33,   -13, -60,  -6,   -11, -60,   4,
    -11, -25,   4,     0,  35, -33,    15,  60, -40,    30, -60, -40,
     30, -60,  -6,    15,  60, -40,   -15,  60, -40,   -30, -60, -40,
    -30, -60,  -6,   -15,  60, -40,    22, -52,  -8,    22, -52,  28,
      3, -17,   0,     3,  55,   0,    -3, -17,   0,    -3,  55,   0,
      3,  -8,  -6,     3,  55,  -6,    -3,  -8,  -6,    -3,  55,  -6,
     11, -60,   4,   -11, -60,   4,    11, -25,   4,   -11, -25,   4,
    -30, -60,  -6,    30, -60,  -6,   -30, -60, -40,    30, -60, -40};
  static int superpnum[] = {5, 9, 8, 0};
  static int supermnum[] = {2, 8, 4, 4, 0};
  static Method supermethods[] = {40, calcpointsII, NULL,
                                    0, NULL, NULL};

  static Coord3d tank[] = {
      3,   0,  13,     5,   3,  15,     5,   3,  19,     3,   0,  21,
     -3,   0,  21,    -5,   3,  19,    -5,   3,  15,    -3,   0,  13,
      3,   0,  13,    -3,  60,  -3,     3,  60,  -3,     3,  60,   3,
     -3,  60,   3,    -3,  60,  -3,   -10, -45,  10,   -10, -13,  10,
     10, -13,  10,    10, -45,  10,    25, -50, -11,    25,  60, -20,
     10, -13,  10,   -10, -13,  10,   -25,  60, -20,   -25, -50, -11,
    -10, -45,  10,    10, -45,  10,    30, -53, -40,    35, -60, -10,
     35,  60, -20,    30,  37, -40,   -30,  37, -40,   -35,  60, -20,
    -35, -60, -10,   -30, -53, -40,    30, -53, -40,    30,  37, -40,
      5, -40,  10,     5, -40,  13,     3,   4,   3,     3,  60,   3,
     -3,   4,   3,    -3,  60,   3,    -3,  19,  -3,    -3,  60,  -3,
      3,  19,  -3,     3,  60,  -3,    35, -60, -10,   -35, -60, -10,
     35,  60, -20,   -35,  60, -20,   -30, -53, -40,   -30, 37, -40};
  static int tankpnum[] = {9, 5, 12, 10, 0};
  static int tankmnum[] = {2, 8, 6, 0};
  static float tankvars[] = {0.996195, 0.087156, 5, -40};
  static Method tankmethods[] = {9, calcpointsIV, tankvars,
                                   43, calcpointsII, NULL,
                                   0, NULL, NULL};

  static StaticDC staticdcs[] = {
    pyramid, pyramidpnum, pyramidmnum, pyramidmethods, COLOR_PYRAMID,
    cube, cubepnum, cubemnum, cubemethods, COLOR_CUBE,
    tank, tankpnum, tankmnum, tankmethods, COLOR_TANK,
    super, superpnum, supermnum, supermethods, COLOR_SUPER,
    missile, missilepnum, missilemnum, missilemethods, COLOR_MISSILE,
    copter, copterpnum, coptermnum, coptermethods, COLOR_COPTER,
    lander, landerpnum, landermnum, landermethods, COLOR_LANDER,
    salvo, salvopnum, salvomnum, salvomethods, COLOR_ESALVO };
  
  int color, i;
  DCp dc;
  Methodp methods;

  dc = &g->dc[0];

#ifndef ATARI
  if (dc->last) {
    gprsetdrawvalue(opt->cpi[COLOR_BG]);
    displayobject(dc);
  }
#endif

  if (g->attr & ERASE) return;

  if (!(g->attr & HAS_DC)) {
    g->attr |= HAS_DC;
    dc->s = staticdcs+g->lntype;

    switch (g->type) {
    case IS_CUBE:
    case IS_PYRAMID:
    case IS_LANDER:
    case IS_MISSILE:
    case IS_COPTER:
    case IS_SUPER:
    case IS_TANK:
      dc->fades = opt->fading_colors - 1;
      dc->basecolor = dc->s->basecolor;
      break;
    case IS_SALVO:
      dc->fades = False;
      if (g->salvo == pl)
        dc->basecolor = COLOR_PSALVO;
      else
        dc->basecolor = COLOR_ESALVO;
      break;
    }
  }

  if (dc->seen) {
    if (dc->fades) {
      color = g->range/OUT_OF_DRAWING_RANGE * opt->fading_colors;
      if (color >= opt->fading_colors)
        color = opt->fading_colors-1;
    }
    else
      color = 0;
#ifndef ATARI
    gprsetdrawvalue(color + opt->cpi[dc->basecolor]);
#endif
    dc->pos.x = g->x;
    dc->pos.y = g->y;
    dc->pos.z = g->z;

    methods = dc->s->methods;
    for (i=0; methods->num; methods++) {
      methods->calc(dc, methods, i, g, pl);
      i += methods->num;
    }
    
    displayobject(dc);
    dc->last = True;
  }
  else
    dc->last = False;
}
