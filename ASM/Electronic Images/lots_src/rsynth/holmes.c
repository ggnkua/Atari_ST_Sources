/* $Id: holmes.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *holmes_id = "$Id: holmes.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "proto.h"
#include "h2pw.h"
#include "elements.h"
#include "darray.h"
#include "holmes.h"
#include "getargs.h"

FILE *par_file;
int speed = 1;

double frac = 1.0;

typedef struct
 {
  float v;              /* boundary value */
  int t;                  /* transition time */
 }
slope_t;

typedef struct
 {
  slope_t p[nEparm];
 } trans_t;

typedef struct
 {
  float a;
  float b;
  float v;
 }
filter_t, *filter_ptr;

static float filter PROTO((filter_ptr p, float v));

static float
filter(p, v)
filter_ptr p;
float v;
{
 return p->v = (p->a * v + p->b * p->v);
}

/* 'a' is dominant element, 'b' is dominated
   ext is flag to say to use external times from 'a' rather
   than internal i.e. ext != 0 if 'a' is NOT current element.

*/

static void set_trans PROTO((slope_t * t, Elm_ptr a, Elm_ptr b, int ext, char e));

static void
set_trans(t, a, b, ext, e)
slope_t *t;
Elm_ptr a;
Elm_ptr b;
int ext;
char e;
{
 int i;
 for (i = 0; i < nEparm; i++)
  {
   t[i].t = ((ext) ? a->p[i].ed : a->p[i].id) * speed;
   if (t[i].t)
    t[i].v = a->p[i].fixd + (a->p[i].prop * b->p[i].stdy) * 0.01;
   else
    t[i].v = b->p[i].stdy;
  }
}

static float linear PROTO((Elm_ptr em, char *p, float a, float b, int t, int d));

static float
linear(em, p, a, b, t, d)
Elm_ptr em;
char *p;
float a;
float b;
int t;
int d;
{
 float r = a;
 float f = 0.0;
 if (t > 0)
  {
   f = (float) t / (float) d;
   r += (b - a) * f;
  }
#ifdef DEBUG
 printf("%4s %s = %g %g\n", em->name, p, r, f);
#endif
 return r;
}

static float interpolate PROTO((Elm_ptr em, char *p, slope_t * s, slope_t * e, float mid, int t, int d));

static float
interpolate(em, p, s, e, mid, t, d)
Elm_ptr em;
char *p;
slope_t *s;
slope_t *e;
float mid;
int t;
int d;
{
 float steady = d - (s->t + e->t);
#ifdef DEBUG
 fprintf(stdout, "%4s %s s=%g,%d e=%g,%d m=%g,%g\n",
         em->name, p, s->v, s->t, e->v, e->t, mid, steady);
#endif
 if (steady >= 0)
  {
   /* Value reaches stready state somewhere ... */
   if (t < s->t)
    return linear(em, p, s->v, mid, t, s->t);
   /* initial transition */
   else
    {
     t -= s->t;
     if (t <= steady)
      return linear(em, p, mid, mid, 0, d);
     /* steady state */
     else
      return linear(em, p, mid, e->v, (int) (t - steady), e->t);
     /* final transition */
    }
  }
 else
  {
   /* Does not make it to steady state - do trajectories intersect ? */
   if (s->t == 0)
    steady = 0;      /* initial is vertical */
   else if (e->t == 0)
    steady = d;      /* final is vertical */
   else
    {
     float ms = (mid - s->v) / s->t;
     float me = (e->v - mid) / e->t;
     if (me == ms || (steady = (s->v - e->v + me * d) / (me - ms)) < 0 || steady > d)
      return linear(em, p, s->v, e->v, t, d);
     /* do not intersect in range */
    }
   if (t < steady)
    return linear(em, p, s->v, mid, t, s->t);
   /* initial transition */
   else
    return linear(em, p, e->v, mid, d - t, e->t);
   /* final transition */
  }
}

unsigned
holmes(nelm, elm, nsamp, samp_base)
unsigned nelm;
unsigned char *elm;
unsigned nsamp;
short *samp_base;
{
 filter_t flt[nEparm];
 klatt_frame_t pars;
 short *samp = samp_base;
 Elm_ptr le = &Elements[0];
 unsigned i = 0;
 int j;
 pars = def_pars;
 pars.B1phz = pars.B1hz = 60;
 pars.B2phz = pars.B2hz = 90;
 pars.B3phz = pars.B3hz = 150;
 pars.F0hz10 = def_pars.F0hz10;
 pars.FNPhz = le->p[fn].stdy;
#if 0
 pars.F4hz = 3500;
#endif
 pars.B4phz = def_pars.B4phz;

 /* flag new utterance */
 parwave_init(&klatt_global);

 for (j = 0; j < nEparm; j++)
  {
   flt[j].v = le->p[j].stdy;
   flt[j].a = frac;
   flt[j].b = 1.0 - frac;
  }
 while (i < nelm)
  {
   Elm_ptr ce = &Elements[elm[i++]];
   unsigned dur = ce->du * speed;
   /* Skip zero length elements which are only there to affect
      boundary values of adjacent elements
   */
   if (dur > 0)
    {
     Elm_ptr ne = (i < nelm) ? &Elements[elm[i]] : &Elements[0];
     slope_t start[nEparm];
     slope_t end[nEparm];
     unsigned t;

     if (ce->rk > le->rk)
      {
       if (par_file)
        fprintf(par_file, "# %s < %s\n", le->name, ce->name);
       set_trans(start, ce, le, 0, 's');
       /* we dominate last */
      }
     else
      {
       if (par_file)
        fprintf(par_file, "# %s >= %s\n", le->name, ce->name);
       set_trans(start, le, ce, 1, 's');
       /* last dominates us */
      }

     if (ne->rk > ce->rk)
      {
       if (par_file)
        fprintf(par_file, "# %s < %s\n", ce->name, ne->name);
       set_trans(end, ne, ce, 1, 'e');
       /* next dominates us */
      }
     else
      {
       if (par_file)
        fprintf(par_file, "# %s >= %s\n", ce->name, ne->name);
       set_trans(end, ce, ne, 0, 'e');
       /* we dominate next */
      }

     if (par_file)
      {
       int j;
       fprintf(par_file, "# %s\n", ce->name);
       for (j = 0; j < nEparm; j++)
        fprintf(par_file, "%c%6s", (j) ? ' ' : '#', Ep_name[j]);
       fprintf(par_file, "\n");
       for (j = 0; j < nEparm; j++)
        fprintf(par_file, "%c%6.4g", (j) ? ' ' : '#', start[j].v);
       fprintf(par_file, "\n");
       for (j = 0; j < nEparm; j++)
        fprintf(par_file, "%c%6d", (j) ? ' ' : '#', start[j].t);
       fprintf(par_file, "\n");
      }

     for (t = 0; t < dur; t++)
      {
       float tp[nEparm];
       int j;
       for (j = 0; j < nEparm; j++)
        tp[j] = filter(flt + j, interpolate(ce, Ep_name[j], &start[j], &end[j], (float) ce->p[j].stdy, t, dur));

       /* Now call the synth for each frame */
       pars.AVdb = pars.AVpdb = tp[av];
       pars.AF = tp[af];
/*
       pars.ANP  = 14 + tp[an];
*/
       pars.FNZhz = tp[fn];
       pars.ASP = tp[asp];
       pars.Aturb = tp[avc];
       pars.B1phz = pars.B1hz = tp[b1];
       pars.B2phz = pars.B2hz = tp[b2];
       pars.B3phz = pars.B3hz = tp[b3];
       pars.AB = 14 + tp[ab];
       pars.A5 = 14 + tp[a5];
       pars.A6 = 14 + tp[a6];
       pars.F1hz = tp[f1];
       pars.F2hz = tp[f2];
       pars.F3hz = tp[f3];
       /* 14 + is a bodge to get amplitudes up to klatt-compatible levels
          Needs to be fixed properly in tables
       */
       pars.A1 = 14 + tp[a1];
       pars.A2 = 14 + tp[a2];
       pars.A3 = 14 + tp[a3];
       pars.A4 = 14 + tp[a4];

       parwave(&klatt_global, &pars, samp);

       samp += klatt_global.nspfr;
       if (par_file)
        {
         for (j = 0; j < nEparm; j++)
          fprintf(par_file, " %6.4g", tp[j]);
         fprintf(par_file, "\n");
        }
      }
     if (par_file)
      {
       int j;
       for (j = 0; j < nEparm; j++)
        fprintf(par_file, "%c%6.4g", (j) ? ' ' : '#', end[j].v);
       fprintf(par_file, "\n");
       for (j = 0; j < nEparm; j++)
        fprintf(par_file, "%c%6d", (j) ? ' ' : '#', end[j].t);
       fprintf(par_file, "\n");
      }
    }
   le = ce;
  }
 return (samp - samp_base);
}

int
init_holmes(argc, argv)
int argc;
char *argv[];
{
 char *par_name = NULL;
 argc = getargs(argc, argv,
                "p", "", &par_name,
                "S", "%d", &speed,
                "K", "%lg", &frac,
                NULL);
 if (par_name)
  {
   par_file = fopen(par_name, "w");
   if (!par_file)
    perror(par_name);
  }
 return argc;
}

void
term_holmes()
{
 if (par_file)
  fclose(par_file);
}
