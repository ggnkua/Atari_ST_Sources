#include "c_includes.h"
/*
 * c_explode.c
 * Todd W Mummert, CMU, January 1991
 *
 * ATARI Mods - Roland Givan Summer/Autumn 1993
 *
 * This is an attempt at cleaning up the explosion routines.  Why is this
 * not the same as the drawing routines?  probably should be, but because
 * of the way pieces explode, the equations are more complex.  Rather
 * than slow down the draw routines, we just have a similiar, but
 * different, set of equations here.
 */

/*
 * the standard routine for exploding pieces, which will not take
 * into account rotating objects.
 */

void calcpointsV(dc, method, index, g, pl)
     DCp dc;
     Methodp method;
     int index;
     Genericp g, pl;
{
  int i;
  float dx, dy, dz, xn, yn, zn, cn, sn, cp, sp, rx, ry, rz, prx, pry, prz;
  Coord2dp new;
  Coord3dp old;

  old = dc->s->object+index;
  new = dc->points+index;

  dx = pl->x - g->x - dc->pos.x;
  dy = pl->y - g->y - dc->pos.y;
  dz = - dc->pos.z;
  xn =  dx*dc->cta + dy*dc->sta;
  yn =  -dx*dc->sta*dc->ctp + dy*dc->cta*dc->ctp + dz*dc->stp;
  zn =  dx*dc->sta*dc->stp - dy*dc->cta*dc->stp + dz*dc->ctp;
  cn = pl->ca*dc->cta + pl->sa*dc->sta;
  sn = pl->sa*dc->cta - pl->ca*dc->sta;
  cp = dc->ctp;
  sp = -dc->stp;
  for (i=0; i<method->num; i++, old++, new++) {
    rx =  old->x - xn;
    ry =  old->y - yn;
    rz =  old->z - zn;
    prx =  rx*cn + ry*sn*cp + rz*sn*sp;
    pry = -rx*sn + ry*cn*cp + rz*cn*sp;
    if (pry < 10.0)
      pry = 10.0;
    prz = -ry*sp + rz*cp;
    new->x = 500 + prx / pry * 450;
    new->y = 260 - prz / pry * 450;
  }
}

/*
 * the routine that is used for drawing the exploding
 * copter blade.
 */
void calcpointsVI(dc, method, index, g, pl)
     DCp dc;
     Methodp method;
     int index;
     Genericp g, pl;
{
  int i;
  float dx, dy, dz, xn, yn, zn, c1, s1, c2, s2, cp, sp;
  float t1, t2, t3, t4, t5, t6, t7, t8, t9, rx, ry, rz, prx, pry, prz;
  Coord2dp new;
  Coord3dp old;

  old = dc->s->object+index;
  new = dc->points+index;

  dx = pl->x - g->x - dc->pos.x;
  dy = pl->y - g->y - dc->pos.y;
  dz = - dc->pos.z;
  xn =  dx*dc->cta + dy*dc->sta*dc->ctp + dz*dc->sta*dc->stp;
  yn =  -dx*dc->sta + dy*dc->cta*dc->ctp + dz*dc->cta*dc->stp;
  zn =  -dy*dc->stp + dz*dc->ctp;
  c1 = pl->ca*dc->cta;
  s1 = pl->sa*dc->sta;
  c2 = pl->ca*dc->sta;
  s2 = pl->sa*dc->cta;
  cp = dc->ctp;
  sp = dc->stp;
  t1 = c1 + s1 * cp;
  t2 = -c2 + s2 * cp;
  t3 = -pl->sa * sp;
  t4 = -s2 + c2 * cp;
  t5 = s1 + c1 * cp;
  t6 = -pl->ca * sp;
  t7 = dc->sta * sp;
  t8 = dc->cta * sp;
  t9 = cp;
  for (i=0; i<method->num; i++, old++, new++) {
    rx = old->x - xn;
    ry = old->y - yn;
    rz = old->z - zn;
    prx = rx * t1 + ry * t2 + rz * t3;
    pry = rx * t4 + ry * t5 + rz * t6;
    prz = rx * t7 + ry * t8 + rz * t9;
    if (pry < 10.0)
      pry = 10.0;
    new->x = 500 + prx / pry * 450;
    new->y = 260 - prz / pry * 450;
  }
}

void explodeobject(g, pl)
     Genericp g, pl;
{
  static float vars0[] = { 0.996195,  0.087156,  0.996195,  0.087156}; 
  static float vars1[] = { 0.996195, -0.087156,  0.996195, -0.087156}; 
  static float vars2[] = { 0.819152,  0.573576,  0.996195,  0.087156}; 
  static Coord3d tank0[] = {
     30, -53, -15,    35, -60,  15,    35,  60,  -5,    30,  37, -15,
    -30,  37, -15,   -35,  60,  -5,   -35, -60,  15,   -30, -53, -15,
     30, -53, -15,    30,  37, -15,    35, -60,  15,   -35, -60,  15,
     35,  60,  -5,   -35,  60,  -5,   -30, -53, -15,   -30,  37, -15};
  static int tank0pnum[] = {10, 0};
  static int tank0mnum[] = {6, 0};
  static Method tank0methods[] = {16, calcpointsV, NULL,
                                    0, NULL, NULL};
  static Coord3d tank1[] = {
    -10, -50,  10,   -10, -18,  10,    10, -18,  10,    10, -50,  10,
     25, -55, -11,    25,  55, -20,    10, -18,  10,   -10, -18,  10,
    -25,  55, -20,   -25, -55, -11,   -10, -50,  10,    10, -50,  10};
  static int tank1pnum[] = {12, 0};
  static int tank1mnum[] = {0};
  static Method tank1methods[] = {12, calcpointsV, NULL,
                                    0, NULL, NULL};
  static Coord3d tank2[] = {
     -3,  28,  -3,     3,  28,  -3,     3,  28,   3,    -3,  28,   3,
     -3,  28,  -3,     3, -28,   3,     3,  28,   3,    -3, -28,   3,
     -3,  28,   3,    -3, -13,  -3,    -3,  28,  -3,     3, -13,  -3,
      3,  28,  -3};
  static int tank2pnum[] = {5, 0};
  static int tank2mnum[] = {8, 0};
  static Method tank2methods[] = {13, calcpointsV, NULL,
                                    0, NULL, NULL};
  static StaticDC tankstaticdcs[] = {
    tank0, tank0pnum, tank0mnum, tank0methods, COLOR_TANK,
    tank1, tank1pnum, tank1mnum, tank1methods, COLOR_TANK,
    tank2, tank2pnum, tank2mnum, tank2methods, COLOR_TANK};
  static float* tankvars[] = {vars0, vars0, vars1};
  static float tankyoffsets[] = {0.0, 5.0, 32.0};
  static float tankzoffsets[] = {-25.0, 0.0, 0.0};

  static Coord3d super0[] = {
     15,  60, -15,    30, -60, -15,    30, -60,  19,    15,  60, -15,
    -15,  60, -15,   -30, -60, -15,   -30, -60,  19,   -15,  60, -15,
    -30, -60,  19,    30, -60,  19,   -30, -60, -15,    30, -60, -15};
  static int super0pnum[] = {8, 0};
  static int super0mnum[] = {4, 0};
  static Method super0methods[] = {12, calcpointsV, NULL,
                                   0, NULL, NULL};
  static Coord3d super1[] = {
      0,  47, -18,    13, -48,   9,    11, -48,  19,    11, -13,  19,
      0,  47, -18,   -13, -48,   9,   -11, -48,  19,   -11, -13,  19,
      0,  47, -18,    11, -48,  19,   -11, -48,  19,    11, -13,  19,
    -11, -13,  19};
  static int super1pnum[] = {9, 0};
  static int super1mnum[] = {4, 0};
  static Method super1methods[] = {13, calcpointsV, NULL,
                                   0, NULL, NULL};
  static Coord3d super2[] = {
      3, -36,   0,     3,  36,   0,    -3, -36,   0,    -3,  36,   0,
      3, -27,  -6,     3,  36,  -6,    -3, -27,  -6,    -3,  36,  -6,
      3,  36,  -6,     3,  36,   0,    -3,  36,   0,    -3,  36,  -6,
      3,  36,  -6};
  static int super2pnum[] = {4, 0};
  static int super2mnum[] = {5, 0};
  static Method super2methods[] = {9, calcpointsV, NULL,
                                   0, NULL, NULL};

  static StaticDC superstaticdcs[] = {
    super0, super0pnum, super0mnum, super0methods, COLOR_SUPER,
    super1, super1pnum, super1mnum, super1methods, COLOR_SUPER,
    super2, super2pnum, super2mnum, super2methods, COLOR_SUPER};
  static float superyoffsets[] = {0.0, -12.0, 19.0};
  static float superzoffsets[] = {-25.0, -15.0, 0.0};

  static Coord3d missile0[] = {
     15, -30, -25,    25, -30,   0,     0, -45,   0,    15, -30, -25,
    -15, -30, -25,     0, -45,   0,    15, -30,  25,   -15, -30,  25,
      0, -45,   0,   -25, -30,   0,   -15, -30,  25};
  static int missile0pnum[] = {11, 0};
  static int missile0mnum[] = {0};
  static Method missile0methods[] = {11, calcpointsV, NULL,
                                     0, NULL, NULL};
  static Coord3d missile1[] = {
     15, -30, -25,     0,  50,   0,    25, -30,   0,    15, -30,  25,
      0,  50,   0,   -15, -30, -25,   -25, -30,   0,     0,  50,   0,
    -15, -30,  25};
  static int missile1pnum[] = {9, 0};
  static int missile1mnum[] = {0};
  static Method missile1methods[] = {9, calcpointsV, NULL,
                                     0, NULL, NULL};
  static Coord3d missile2[] = {
     13, -17, 11,    15, -30,   5,    23, -38, -10,    23,   0, -10,
     13, -17, 11};
  static int missile2pnum[] = {5, 0};
  static int missile2mnum[] = {0};
  static Method missile2methods[] = {5, calcpointsV, NULL,
                                     0, NULL, NULL};
  static Coord3d missile3[] = {
    -13, -17, 11,   -15, -30,   5,   -23, -38, -10,   -23,   0, -10,
    -13, -17, 11};
  static int missile3pnum[] = {5, 0};
  static int missile3mnum[] = {0};
  static Method missile3methods[] = {5, calcpointsV, NULL,
                                     0, NULL, NULL};

  static StaticDC missilestaticdcs[] = {
    missile0, missile0pnum, missile0mnum, missile0methods, COLOR_MISSILE,
    missile1, missile1pnum, missile1mnum, missile1methods, COLOR_MISSILE,
    missile2, missile2pnum, missile2mnum, missile2methods, COLOR_MISSILE,
    missile3, missile3pnum, missile3mnum, missile3methods, COLOR_MISSILE};
  static float* missilevars[] = {vars0, vars0, vars1, vars1};
  static float missileyoffsets[] = {0.0, 0.0, 0.0, 0.0};
  static float missilezoffsets[] = {0.0, 0.0, -30.0, -30.0};

  static Coord3d copter0[] = {
      6,  100,   0,     6,  100,   0,    -6, -100,   0,     6, -100,   0,
     -6,  100,   0,     6,  100,   0};
  static int copter0pnum[] = {6, 0};
  static int copter0mnum[] = {0};
  static Method copter0methods[] = {6, calcpointsVI, NULL,
                                    0, NULL, NULL};
  static Coord3d copter1[] = {
      0,  -32, -10,     7,   52, -34,    10,   48, -14,     0,  -34,   0,
      0,  -52,  28,     0,  -62,  28,     0,  -48, -10,     0,  -32, -10,
     -7,   52, -34,   -10,   48, -14,     0,  -34,   0};
  static int copter1pnum[] = {11, 0};
  static int copter1mnum[] = {0};
  static Method copter1methods[] = {11, calcpointsV, NULL,
                                    0, NULL, NULL};
  static Coord3d copter2[] = {
    -14,   34, -34,    14,   34, -34,     0,   60, -14,   -14,   34, -34,
     -7,  -30, -34,     7,  -30, -34,    14,   34, -34,    26,   34, -14,
      0,   60, -14,   -26,   34, -14,   -10,  -34, -14,    10,  -34, -14,
     26,   34, -14,     4,   20,  16,     0,   22,  16,    -4,   20,  16,
     -4,  -22,  16,     4,  -22,  16,     4,   20,  16,   -10,  -34, -14,
     -4,  -22,  16,    10,  -34, -14,     4,  -22,  16,     0,   22,  16,
      0,   60, -14,   -14,   34, -34,   -26,   34, -14,   -26,   34, -14,
     -4,   20,  16};
  static int copter2pnum[] = {19, 0};
  static int copter2mnum[] = {10, 0};
  static Method copter2methods[] = {29, calcpointsV, NULL,
                                    0, NULL, NULL};
  
  static StaticDC copterstaticdcs[] = {
    copter0, copter0pnum, copter0mnum, copter0methods, COLOR_COPTER,
    copter1, copter1pnum, copter1mnum, copter1methods, COLOR_COPTER,
    copter2, copter2pnum, copter2mnum, copter2methods, COLOR_COPTER};
  static float* coptervars[] = {vars2, vars0, vars1};
  static float copteryoffsets[] = {0.0, -82.0, 0.0};
  static float copterzoffsets[] = {30.0, 0.0, 0.0};

  static StaticDCp staticdcs[] = {
    NULL, NULL, tankstaticdcs, superstaticdcs,
    missilestaticdcs, copterstaticdcs};
  static float* yoffsets[] = {
    NULL, NULL, tankyoffsets, superyoffsets,
    missileyoffsets, copteryoffsets};
  static float* zoffsets[] = {
    NULL, NULL, tankzoffsets, superzoffsets,
    missilezoffsets, copterzoffsets};
  static float* *vars[] = {
    NULL, NULL, tankvars, tankvars,
    missilevars, coptervars};
  static int pieces[] = {0, 0, 3, 3, 4, 3};
  static float gravity = 1.0;
 
  int color, i, j, p;
  DCp dc;
  Methodp methods;
  float yoffset, dx, dy, temp;
  static int threshold = 0.8;
  Float2d pro;
  float* v;

  if (g->type == IS_LANDER) {
    if (g->attr & EXERASE || g->ecount >= 40) {
      g->dc[0].seen = False;
      drawobject(g, pl);
      g->attr = 0;
      return;
    }                                   /* lander just blinks on every */
    if (g->dc[0].seen && g->ccount%3)   /* 3rd cycle                   */
      g->dc[0].seen = False;
    else
      g->ccount = 0;
    drawobject(g, pl);
    g->ccount++;
    return;
  }

  p = pieces[g->lntype];
#ifndef ATARI
  gprsetdrawvalue(opt->cpi[COLOR_BG]);
  for (i=0; i<p; i++) {
    dc = &g->dc[i];
    if (dc->last) 
      displayobject(dc);
  }
#endif
  if (g->attr & EXERASE || g->ecount >= 40) {
    g->attr = 0;
    return;
  }

  if (!(g->attr & HAS_DC)) {
    g->attr |= HAS_DC;
    for (i=0; i<p; i++) {
      dc = &g->dc[i];
      dc->s = staticdcs[g->lntype]+i;

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

      dc->cta = g->ca;
      dc->sta = g->sa;
      dc->ctp = 1.0;
      dc->stp = 0.0;
      yoffset = *(yoffsets[g->lntype]+i);
      dc->pos.x = -yoffset * g->sa;
      dc->pos.y = yoffset * g->sa;
      dc->pos.z = g->z + *(zoffsets[g->lntype]+i);
      dc->vel.x = frand() * 20.0 - 10.0;
      dc->vel.y = frand() * 20.0 - 10.0;
      dc->vel.z = 12.5 + frand() * 7.5;
    }
    if (g->type == IS_COPTER)
      g->dc[0].vel.z += 6.0;
  }

  for (i=0; i<p; i++) {
    dc = &g->dc[i];
    dx = g->x + dc->pos.x - pl->x;
    dy = g->y + dc->pos.y - pl->y;
    if (sqrt(dx*dx + dy*dy) < 2000.0) {
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
      pro.x = dx * pl->ca + dy * pl->sa;
      pro.y = -dx * pl->sa + dy * pl->ca;

      if (pro.y/fabs(pro.x+1) > threshold) {
        methods = dc->s->methods;
        for (j=0; methods->num; methods++) {
          methods->calc(dc, methods, j, g, pl);
          j += methods->num;
        }
        
        displayobject(dc);
        dc->last = True;
      }
      else
        dc->last = False;
    }
    else
        dc->last = False;

    dc->pos.x += dc->vel.x;
    dc->pos.y += dc->vel.y;
    dc->vel.z -= gravity;
    dc->pos.z += dc->vel.z;
    if (dc->pos.z < -40.0) {
      dc->pos.z = -40.0;
      dc->vel.z *= -0.2;
    }

    v = vars[g->lntype][i];
    temp = dc->cta;
    dc->cta = dc->cta*v[0] - dc->sta*v[1];
    dc->sta = dc->sta*v[0] + temp*v[1];
    temp = dc->ctp;
    dc->ctp = dc->ctp*v[2] - dc->stp*v[3];
    dc->stp = dc->stp*v[2] + temp*v[3];
  }
}

void explodesalvo (g, pl)
     Genericp g;
     Genericp pl;
{
  float mrx[5], mry[5];
  float mrz[5], xmoff[5], ymoff[5], zmoff[5];
  static float gravity = 1.0;
  int i, j;
  Coord2dp point, first;

#ifdef ATARI
  if (opt->fast){
	g->attr=0;
    return;
  }
#else
  if (g->dc[0].last) {
    gprsetdrawvalue(opt->cpi[COLOR_BG]);
    multiline(g->dc[0].points, 5);
  }
#endif

  if (g->attr & EXERASE || g->ecount >= 20) {
    g->attr = 0;
    return;
  }

  if (g->attr & IS_NEW) {
    g->ccount = 0;
    g->attr &= ~IS_NEW;
    for (j=0; j<5; j++) {
      g->dc[j].vel.x = frand() * 20.0 - 10.0;
      g->dc[j].vel.y = frand() * 20.0 - 10.0;
      g->dc[j].vel.z = -7.5 - frand() * 5.0;
      g->dc[j].pos.x = 0.0;
      g->dc[j].pos.y = 0.0;
      g->dc[j].pos.z = 0.0;
    }
  }
  if (g->dc[0].seen) {
    if (g->salvo == pl)
      gprsetdrawvalue(opt->cpi[COLOR_PSALVO]);
    else
      gprsetdrawvalue(opt->cpi[COLOR_ESALVO]);
    for (i=0; i<5; i++) {
      g->dc[i].pos.x += g->dc[i].vel.x;
      g->dc[i].pos.y += g->dc[i].vel.y;
      g->dc[i].vel.z += gravity;
      g->dc[i].pos.z -= g->dc[i].vel.z;
    }
    point = g->dc[0].points;
    for (i=0; i<5; i++) {
      xmoff[i] = g->dc[i].pos.x + g->x - pl->x;
      ymoff[i] = g->dc[i].pos.y + g->y - pl->y;
      zmoff[i] = g->dc[i].pos.z;
      mrx[i] =  xmoff[i] * pl->ca + ymoff[i] * pl->sa;
      mry[i] = -xmoff[i] * pl->sa + ymoff[i] * pl->ca;
      mrz[i] =  zmoff[i];
      if (mry[i] < 10.0)
        mry[i] = 10.0;
      first = point++;
      point->x = first->x = 500 + mrx[i] / mry[i] * 450;
      first->y = 260 - mrz[i] / mry[i] * 450;
      point->y = first->y+2;
      point++;
    }
    multiline(g->dc[0].points, 5);
    g->dc[0].last = True;
  }
  else
    g->dc[0].last = False;
  g->ccount++;
}

