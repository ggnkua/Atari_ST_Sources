#include "c_includes.h"
#ifdef LATTICE
#include "compat.h"
#endif
#ifdef ATARI
extern char triple_ping[];
#endif
/*
 * cbzone_move.c
 *  -- Todd W Mummert, December 1990, CMU
 *
 * ATARI Mods - Roland Givan Summer/Autumn 1993
 *
 * RCS Info
 *  $Header: c_move.c,v 1.1 91/01/12 02:03:35 mummert Locked $
 *
 * This file is largely based on the Fortran source by
 * Justin S Revenaugh.  I've added the necessary information
 * to handle multiple objects in placeobjects, but that's
 * about it.  Moved any variables that were controlling
 * an object that had to be static into the Generic structure.
 */

void placeobjects(o, missilerun, score)
     Genericp o;
     Bool missilerun;
     int score;
{
  static int lander = 1000;
  static int landercount = 0;
  static struct timeval clock = {0, 40000};
  float odds, scale, r, dazm, ca, sa;
  Genericp g;
  Genericp pl = o;
  int nta = 0;
  int nsu = 0;
  int nmi = 0;
  int nco = 0;
  int nla = 0;

  landercount++;
  for (g=o; g<o+opt->mobjects; g++)
    if (g->attr & STILL_THERE)
      switch (g->type) {
      case IS_TANK:
        nta++; break;
      case IS_SUPER:
        nsu++; break;
      case IS_MISSILE:
        nmi++; break;
      case IS_COPTER:
        nco++; break;
      case IS_LANDER:
        nla++; break;
      }

  if (pl->attr & IS_ALIVE &&
      (missilerun && nta + nsu == 0 && nmi + nco < opt->mmissiles ||
       !missilerun && nmi + nco == 0 && nta + nsu < opt->mtanks)) {
    for (g=o+opt->estart; g<o+opt->lstart; g++)
      if (!(g->attr & STILL_THERE))
        break;
    if (g == o+opt->lstart) {
      printf("Help! Did not have space available for enemy!\n");
      printf("Should not have been possible.\n");
#ifdef ATARI
      gem_close_down();
#endif
      exit(1);
    }

    if (missilerun) {
      /* reset clock usec just in case they change select to return the
         amount of time remaining after the select finishes.   The
         man page mentions this might occur in future releases.
       */
#ifdef ATARI
	  sound(triple_ping);	/* Do the pings in the background instead of
							busy waiting between them (can't do select()
							in non MiNT/MTOS mode)*/
#else
      tonetime();
      clock.tv_usec = 40000;
      select(0, 0, 0, 0, &clock);
      tonetime();
      clock.tv_usec = 40000;
      select(0, 0, 0, 0, &clock);
      tonetime();
#endif
      odds = score / 500000.0;
      if (score < 75000)
        odds = 0.0;
      if (odds > 0.333)
        odds = 0.333;
      if (opt->copters || frand() < odds) {
        g->type = IS_COPTER;
        g->lntype = LN_COPTER;
        scale = 0.2;
        g->z = 150.0;
        r = 1900;
      }
      else {
        g->type = IS_MISSILE;
        g->lntype = LN_MISSILE;
        scale = 0.1;
        g->z = 250.0;
        r = 1750;     
      }
      dazm = frand() * scale;
      if (frand() > 0.5)
        dazm = - dazm;
      dazm += pl->azm;
      ca = cos(dazm);
      sa = sin(dazm);
      g->x = pl->x - r * sa;
      g->y = pl->y + r * ca;
      g->attr = START_LIVING;
      dazm = frand() * 0.015 / scale;
      if (frand() > 0.5)
        dazm = - dazm;
      g->azm = pl->azm - PI + dazm;
    }
    else {
      odds = (60000.0 - score) / 30000.0;
      if (odds < 0.10)
        odds = 0.10;
      if (frand() < odds) {
        g->type = IS_TANK;
        g->lntype = LN_TANK;
      }
      else {
        g->type = IS_SUPER;
        g->lntype = LN_SUPER;
      }
      r = 800.0 + 1200.0 * frand();
      dazm = frand() * PI2;
      g->x = pl->x + r * cos(dazm);
      g->y = pl->y + r * sin(dazm);
      g->z = 0.0;
      g->azm = frand() * PI2;
      g->attr = START_LIVING;
    }
    g->criticalx = 45.0;
    g->criticaly = 70.0;
  }

  if (landercount > lander && nla < opt->mlanders) {
    for (g=o+opt->lstart; g<o+opt->sstart; g++)
      if (!(g->attr & STILL_THERE))
        break;
    if (g == o+opt->sstart) {
      printf("Help! Did not have space available for lander!\n");
      printf("Should not have been possible.\n");
#ifdef ATARI
      gem_close_down();
#endif
      exit(1);
    }

    r = 1500.0 + 500.0 * frand();
    dazm = frand() * PI2;
    g->x = pl->x + r * cos(dazm);
    g->y = pl->y + r * sin(dazm);
    g->z = 0.0;
    g->azm = frand() * PI2;
    g->speed = frand() * 10.0;
    g->criticalx = g->criticaly = 6400.0;
    g->type = IS_LANDER;
    g->lntype = LN_LANDER;
    g->attr = START_LIVING;
  }

  for (g=o+opt->bstart; g<o+opt->mobjects; g++)
    if (!(g->attr & IS_ALIVE)) {
      if (frand() > 0.5) {
        g->type = IS_CUBE;
        g->lntype = LN_CUBE;
        g->criticalx = g->criticaly = 50.0;
      }
      else {
        g->type = IS_PYRAMID;
        g->lntype = LN_PYRAMID;
        g->criticalx = g->criticaly = 35.0;
      }
      g->attr = START_LIVING;
      if (pl->attr & IS_NEW)
        r = 400 + frand() * 1800.0;
      else
        r = 2000.0;
      dazm = frand() * PI2;
      g->x = pl->x + r * cos(dazm);
      g->y = pl->y + r * sin(dazm);
      g->z = 0.0;
    }
}

void movesuper(g, pl)
     Genericp g;
     Genericp pl;
{
  int i;
  float dx, dy, tazm, t1, t3, scrot, sctot, scale, cp, sp, dcp;
  float dsp, cm, sm, xmt, ymt, xpt, ypt, rate, temp, dist;
  Genericp s;

  g->pcount++;
  g->fcount++;
  if (g->attr & IS_NEW) {
    g->attr &=  ~(IS_NEW | IS_PRESET);
    g->bcount = 0;
    g->ecount = 0;
    g->pcount = 10;
    g->fcount = 15;
    g->orientation = 1.0;
  }
  if (g->attr & IS_BLOCKED && g->attr & LAST_BLOCKED)
    g->orientation = -g->orientation;
  g->attr &= ~LAST_BLOCKED;
  
  if (g->attr & IS_BLOCKED) {
    if (g->attr & BLOCKED_BY_ENEMY)
      g->attr |= IS_EVADING;
    else 
      g->attr &= ~IS_EVADING;
    g->attr |= IS_PRESET | LAST_BLOCKED;
    g->bcount  = 0;
  }
  if (g->attr & IS_PRESET) {
    g->bcount++;
    if (!(g->attr & IS_EVADING)) {
      if (g->bcount == 1) {
        g->speed = -12.0 * g->orientation;
        g->rotate = 0.045;
        if (frand() > 0.5)
          g->rotate = -g->rotate;
      }
      else if (g->bcount == 30) {
        g->speed  = 12.0 * g->orientation;
        g->rotate = 0.0;
      }
      else if (g->bcount > 60)
        g->attr &= ~IS_PRESET;
    }
    else {
      if (g->bcount == 1) {
        g->speed  = -12.0 * g->orientation;
        g->rotate = 0.0;
      }
      else if (g->bcount == 10 || g->bcount == 15 ||
               g->bcount == 20 || g->bcount == 25) {
        dx = pl->x - g->x;
        dy = pl->y - g->y;
        if (fabs(dy) < 1.e-7)
          dy = sign(1.e-7, dy);
        if (dy <= 0.0)
          tazm = - atan(dx / dy) + ra (180.0);
        else
          tazm = - atan(dx / dy) ;
        if (g->azm > PI2)
          g->azm -= PI2;
        if (g->azm < 0.0)
          g->azm += PI2;
        t1 = (tazm - g->azm) / 5.0;
        t3 = (tazm - (g->azm - PI2)) / 5.0;
        if (fabs(t3) < fabs(t1))
          t1 = t3;
        if (fabs(t1) > 0.045)
          t1 = sign (.045, t1);
        g->rotate = t1;
        g->speed = 0.0;
      }
      else if (g->bcount > 30)
        g->attr &= ~IS_PRESET;
    }
  }
  else if (g->pcount >= 5) {
    g->orientation = 1.0;
    g->pcount = 0;
    dx = pl->x - g->x;
    dy = pl->y - g->y;
    if (fabs(dy) < 1.e-7) dy =
      sign(1.e-7, dy);
    if (dy <= 0.0) 
      tazm = - atan(dx / dy) + ra (180.0);
    else
      tazm = - atan(dx / dy);
    if (g->azm > PI2)
      g->azm -= PI2;
    if (g->azm < 0.0)
      g->azm += PI2;
    t1 = (tazm - g->azm) / 5.0;
    t3 = (tazm - (g->azm - PI2)) / 5.0;
    if (fabs(t3) < fabs(t1))
      t1 = t3;
    g->speed = 12.0 * (PI - fabs(t1) * 5.0) / PI;
    if (fabs(t1) > 0.045)
      t1 = sign (0.045, t1);
    g->rotate = t1;
  }

  scrot = g->rotate / 0.045 * 12.0;
  sctot = sqrt (g->speed*g->speed + scrot*scrot);
  if (sctot > 12.0) {
    scale = 12.0 / sctot;
    g->speed *= scale;
    g->rotate *= scale;
  }

  s = g->salvo;
  if (pl->attr & IS_ALIVE && g->fcount>10 && g->ecount>50 &&
      !(s->attr & STILL_THERE)) { 
    g->fcount = 0;
    cp = pl->ca;
    sp = pl->sa;
    dcp = cos(pl->rotate);
    dsp = sin(pl->rotate);
    cm = cos(g->azm);
    sm = sin(g->azm);
    i = 0;
    xmt = g->x;
    ymt = g->y;
    xpt = pl->x;
    ypt = pl->y;
    rate = 40.0;

    for (i=0; i<50; i++) {
      temp = cp;
      cp = cp * dcp - sp * dsp;
      sp = sp * dcp + dsp * temp;
      xmt -= sm * rate;
      ymt += cm * rate;
      xpt -= sp * pl->speed;
      ypt += cp * pl->speed;
      dist = (xpt-xmt)*(xpt-xmt) + (ymt-ypt)*(ymt-ypt);
      if (dist <= BMS_TOL) {
        s->attr = START_LIVING;
        s->x = g->x;
        s->y = g->y;
        s->z = 0.0;
        s->prox = g->prox;
        s->proy = g->proy;
        s->azm = g->azm;
        s->speed = 40.0;       
        s->ecount = 0;                  
        message(3, True);
        break;
      }
    }
  }
}

void movemissile(g, pl, first)
     Genericp g;
     Genericp pl;
     Bool first;
{
  float dx, dy, tazm, t1, t3, dt1, t2;

  if (g->attr & IS_NEW) {
    g->ecount = 0;
    g->pcount = 0;
    g->attr &= ~IS_NEW;
  }
    
  g->rotate = 0.0;
  g->pcount++;
  g->z -= 25.0;
  if (g->z <= 0.0)
    g->z = 0.0;
  if (g->attr & IS_BLOCKED)
    g->z = 90.0;
  g->speed = 35.0;
  if (g->z > 91.0)
    g->speed = 0.0;
  if (g->pcount >= 12) {
    g->pcount = 0;
    if (g->proy > 60.0) {
      dx = pl->x - g->x;
      dy = pl->y - g->y;
      if (fabs(dy) < 1.e-7)
        dy = sign(1.e-7, dy);
      if (dy <= 0.0) 
        tazm = - atan(dx / dy) + ra (180.0);
      else
        tazm = - atan(dx / dy);
      if (g->azm > PI2)
        g->azm -= PI2;
      if (g->azm < 0.0)
        g->azm += PI2;
      t1 = (tazm - g->azm);
      t3 = (tazm - (g->azm - PI2));
      if (fabs(t3) < fabs(t1))
        t1 = t3;
      if (!first) {
        dt1 = frand() * 0.5;
        dt1 = sign (dt1, t1);
        if (frand() > 0.8)
          dt1 = - dt1;
        t1 += dt1;
      }
      if (fabs(t1) > 0.90)
        t1 = sign (0.90, t1);
      g->rotate = t1;
    }
    else {
      tazm = pl->azm - PI;
      if (tazm < 0.0)
        tazm += PI2;
      if (tazm > PI2)
        tazm -= PI2;
      if (g->azm < 0.0)
        g->azm += PI2;
      if (g->azm > PI2)
        g->azm -= PI2;
      t1 = (tazm - g->azm);
      t2 = (tazm - (g->azm - PI2));
      if (fabs(t2) < fabs(t1))
        t1 = t2;
      if (fabs(t1) > 0.90)
        t1 = sign (0.90, t1);
      g->rotate = t1;  
    }
  }
}

void movecopter(g, pl)
     Genericp g;
     Genericp pl;
{
  float dx, dy, tazm, t1, t2, t3, cp, sp, dcp, dsp, cm, sm;
  float xmt, ymt, xpt, ypt, rate, temp, dist;
  int i;
  Genericp s;

  g->pcount++;
  if (!(pl->attr & IS_ALIVE)) {
    g->pcount = 0;
    g->attr &= ~CAN_SHOOT;
  }
  
  if (g->attr & IS_NEW) {
    g->pcount = 10;
    g->ecount = 0;
    g->attr |= CAN_SHOOT;
    g->attr &= ~IS_NEW;
    if (frand() > 0.5) 
      g->orientation = PI / 2.0;
    else
      g->orientation = -PI / 2.0;
  }

  s = g->salvo;
  if (g->ecount < 150 && g->range > 400.0)
    if (!(s->attr & STILL_THERE))
      g->z -= 5.0;
    else
      g->z += 5.0;
  else
    g->z += 5.0;

  if (g->z <= 40.0)
    g->z = 40.0;
  if (g->z > 150.0)
    g->z = 150.0;
  if (g->attr & IS_BLOCKED && g->z < 90.0) {
    g->z = 90.0;
    g->attr &= ~IS_BLOCKED;
  }

  g->speed = 20.0;
  if (g->pcount >= 10) {
    g->pcount = 0;
    if (g->range > 400.0 && g->ecount < 150) {
      dx = pl->x - g->x;
      dy = pl->y - g->y;
      if (fabs(dy) < 1.e-7)
        dy = sign(1.e-7, dy);
      if (dy <= 0.0) 
        tazm = - atan(dx / dy) + ra (180.0);
      else
        tazm = - atan(dx / dy);
      if (g->azm > PI2)
        g->azm -= PI2;
      if (g->azm < 0.0)
        g->azm += PI2;
      t1 = (tazm - g->azm) / 10.0;
      t3 = (tazm - (g->azm - PI2)) /10.0;
      if (fabs(t3) < fabs(t1))
        t1 = t3;
      if (fabs(t1) > 0.06)
        t1 = sign (0.06, t1);
      g->rotate = t1;
    }
    else { 
      tazm = g->orientation;
      if (tazm < 0.0)
        tazm += PI2;
      if (tazm > PI2)
        tazm -= PI2;
      if (g->azm < 0.0)
        g->azm += PI2;
      if (g->azm > PI2)
        g->azm -= PI2;
      t1 = (tazm - g->azm) / 10.0;
      t2 = (tazm - (g->azm - PI2)) / 10.0;
      if (fabs(t2) < fabs(t1))
        t1 = t2;
      if (fabs(t1) > 0.06)
        t1 = sign (0.06, t1);
      g->rotate = t1;
      g->speed = 30.0;
    }
  }
  
  if (g->attr & CAN_SHOOT && g->z < 50.0 &&
      !(s->attr & STILL_THERE)) {
    /*
     * the original Fortran had the following
     *    sp = pl->sa     and    cp = pl->ca
     *
     * however, sa and ca were undefined...fortran was really good
     * about making these 0, C doesn't guarantee this will occur.
     * the two choices to fix this are to make sp and cp
     * 0 initially or to make them the sin/cos of azm.
     * the first method makes the copter fire as it hits
     * the ground, the second method the copter won't fire
     * until it is very close unless you are moving straight
     * toward it or straight away from it.
     */
    cp = sp = 0;
    dcp = cos(pl->rotate);
    dsp = sin(pl->rotate);
    cm = cos(g->azm);
    sm = sin(g->azm);
    xmt = g->x;
    ymt = g->y;
    xpt = pl->x;
    ypt = pl->y;
    rate = 40.0;
    
    for (i=0; i<50; i++) {
      temp = cp;
      cp = cp * dcp - sp * dsp;
      sp = sp * dcp + dsp * temp;
      xmt -= sm * rate;
      ymt += cm * rate;
      xpt -= sp * pl->speed;
      ypt += cp * pl->speed;
      dist = (xpt-xmt)*(xpt-xmt) + (ymt-ypt)*(ymt-ypt);
      if (dist <= BMC_TOL) {
        s->attr = START_LIVING;
        s->x = g->x;
        s->y = g->y;
        s->z = 0.0;
        s->prox = g->prox;
        s->proy = g->proy;
        s->azm = g->azm;
        s->speed = 40.0;
        s->ecount = 0;
        message(3, True);
        break;
      }
    }
  }
}

void movetank(g, pl)
     Genericp g;
     Genericp pl;
{
  int i;
  float dx, dy, tazm, t1, t3, scrot, sctot, scale, cp, sp, dcp;
  float dsp, cm, sm, xmt, ymt, xpt, ypt, rate, temp, dist;
  Genericp s;
  
  g->pcount++;
  g->fcount++;
  if (g->attr & IS_NEW) {
    g->attr &= ~(IS_NEW | IS_PRESET);
    g->bcount = 0;
    g->ecount = 0;
    g->pcount = 5;
    g->fcount = 5;
    g->orientation = 1.0;
  }
  if (g->attr & IS_BLOCKED && g->attr & LAST_BLOCKED)
    g->orientation = -g->orientation;
  g->attr &= ~LAST_BLOCKED;
  
  if (g->attr & IS_BLOCKED) {
    if (g->attr & BLOCKED_BY_ENEMY)
      g->attr |= IS_EVADING;
    else 
      g->attr &= ~IS_EVADING;
    g->attr |= IS_PRESET | LAST_BLOCKED;
    g->bcount  = 0;
  }

  if (g->attr & IS_PRESET) {
    g->bcount++;
    if (!(g->attr & IS_EVADING)) {
      if (g->bcount == 1) {
        g->speed = -8.0 * g->orientation;
        g->rotate = 0.030;
        if (frand() > 0.5)
          g->rotate = -g->rotate;
      }
      else if (g->bcount == 45) {
        g->speed  = 8.0 * g->orientation;
        g->rotate = 0.0;
      }
      else if (g->bcount > 90)
        g->attr &= ~IS_PRESET;
    }
    else {
      if (g->bcount == 1) {
        g->speed  = -8.0 * g->orientation;
        g->rotate = 0.0;
      }
      else if (g->bcount == 10 || g->bcount == 15 ||
               g->bcount == 20 || g->bcount == 25) {
        dx = pl->x - g->x;
        dy = pl->y - g->y;
        if (fabs(dy) < 1.e-7)
          dy = sign(1.e-7, dy);
        if (dy <= 0.0)
          tazm = - atan(dx / dy) + ra (180.0);
        else
          tazm = - atan(dx / dy) ;
        if (g->azm > PI2)
          g->azm -= PI2;
        if (g->azm < 0.0)
          g->azm += PI2;
        t1 = (tazm - g->azm) / 5.0;
        t3 = (tazm - (g->azm - PI2)) / 5.0;
        if (fabs(t3) < fabs(t1))
          t1 = t3;
        if (fabs(t1) > 0.030)
          t1 = sign (.030, t1);
        g->rotate = t1;
        g->speed = 0.0;
      }
      else if (g->bcount > 30)
        g->attr &= ~IS_PRESET;
    }
  }
  else if (g->pcount >= 10) {
    g->orientation = 1.0;
    g->pcount = 0;
    dx = pl->x - g->x;
    dy = pl->y - g->y;
    if (fabs(dy) < 1.e-7)
      dy = sign(1.e-7, dy);
    if (dy <= 0.0) 
      tazm = - atan(dx / dy) + ra (180.0);
    else
      tazm = - atan(dx / dy);
    if (g->azm > PI2)
      g->azm -= PI2;
    if (g->azm < 0.0)
      g->azm += PI2;
    t1 = (tazm - g->azm) / 10.0;
    t3 = (tazm - (g->azm - PI2)) / 10.0;
    if (fabs(t3) < fabs(t1))
      t1 = t3;
    g->speed = 8.0 * (PI - fabs(t1) * 10.0) / PI;
    if (fabs(t1) > 0.030)
      t1 = sign (0.030, t1);
    g->rotate = t1;
  }

  scrot = g->rotate / 0.030 * 8.0;
  sctot = sqrt (g->speed*g->speed + scrot*scrot);
  if (sctot > 8.0) {
    scale = 8.0 / sctot;
    g->speed *= scale;
    g->rotate *= scale;
  }

  s = g->salvo;
  if (pl->attr & IS_ALIVE && g->fcount>10 && g->ecount>100 &&
      !(s->attr & STILL_THERE)) {
    g->fcount = 0;
    cp = pl->ca;
    sp = pl->sa;
    dcp = cos(pl->rotate);
    dsp = sin(pl->rotate);
    cm = cos(g->azm);
    sm = sin(g->azm);
    i = 0;
    xmt = g->x;
    ymt = g->y;
    xpt = pl->x;
    ypt = pl->y;
    rate = 40.0;

    for (i=0; i<50; i++) {
      temp = cp;
      cp = cp * dcp - sp * dsp;
      sp = sp * dcp + dsp * temp;
      xmt -= sm * rate;
      ymt += cm * rate;
      xpt -= sp * pl->speed;
      ypt += cp * pl->speed;
      dist = (xpt-xmt)*(xpt-xmt) + (ymt-ypt)*(ymt-ypt);
      if (dist <= BMT_TOL) {
        s->attr = START_LIVING;
        s->x = g->x;
        s->y = g->y;
        s->z = 0.0;
        s->prox = g->prox;
        s->proy = g->proy;
        s->azm = g->azm;
        s->speed = 40.0;       
        s->ecount = 0;                  
        message(3, True);
        break;
      }
    }
  }
}

void movelander(g, pl)
     Genericp g;
     Genericp pl;
{
  float dx, dy, theta;
  
  if (++g->pcount > 20) {
    g->pcount = 0;
 
    if (g->range <= 750.0) {
      dx = g->x - pl->x;
      dy = g->y - pl->y;
      theta = atan (dy / (fabs(dx) + 1.0));
      if (dx <= 0.0)
        theta = PI - theta;
      /* the original fortran went to all the trouble of calculating
       * theta above, but never used it.  perhaps the following
       * statement was left out.
       */
      g->azm = theta;
    }
    
    if (frand() >= 0.5) {
      g->azm += frand() * PI / 4.0;
    }
    else {
      g->azm -= frand() * PI / 4.0;
    }
    g->speed = frand() * 20.0;
  }
}
