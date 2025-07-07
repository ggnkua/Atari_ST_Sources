/*
 * cbzone_structs.h
 *  -- Todd W Mummert, December 1990, CMU
 *
 * This file contains the two major structures that we use in
 * the game.  Every object is of type Generic...while we have an
 * Option type in order to allow us to pass options easily and
 * quickly.
 *
 * The most hazardous piece of this code is assuming that
 * XSegments and XPoints continue to be made of shorts.  However,
 * I don't want to address the drawing elements by their
 * structure names, so I'm betting on them remaining shorts.
 */

#ifdef ATARI		/* RMG 11/08/93 */

#include "gem.h"
#include <osbind.h>

#define Bool int
#define TRUE -1
#define True TRUE
#define FALSE 0
#define False FALSE
#ifndef LATTICE
#define TANKDIR "./"
#else
#define TANKDIR ".\\"
#endif

/* These 2 typedefs help emulate some of the X-Windows code */
/* Not actually used much (if at all in the -fast version) */
typedef struct {
	short x;
	short y;
} XPoint;

typedef struct {
	short x1;
	short y1;
	short x2;
	short y2;
} XSegment;

extern GEM_SIZE handle;

#endif

typedef struct {
  int delay;                    /* the true delay will be delay * 0.012 */
  int mblocks;
  int mlanders;
  int mmissiles;
  int msalvos;
  int mtanks;
  int menemies;
  int mobjects;
  int estart;                   /* indices into the object array */
  int lstart;
  int sstart;
  int bstart;
  Bool copters;              /* just helicopters        */
  Bool loud;                 /* to beep, or not to beep */
  Bool practice;             /* valid score?            */
  Bool output;               /* print messages to tty?  */
  Bool scores;
  Bool version;
  Bool help;
  Bool original;
  Bool cursor;
#ifdef ATARI
  int fast;
#endif

  /* Now pick up the color options...pick up the color as a string first */
  /* This will later be a pixel value after we set up the colormap */
  char* cname[MAX_COLORS];
  int cpi[MAX_COLORS];

  Bool mono;
  Bool fullscreen;
  Bool defaultcolormap;
  int fading_colors;
  int max_colors;
} Option, *Optionp;

typedef struct {
  short x, y, z;
} Coord3d, *Coord3dp;

typedef struct {
  short x, y;
} Coord2d, *Coord2dp;

typedef struct {
  float x, y;
} Float2d, *Float2dp;

typedef struct {
  float x, y, z;
} Float3d, *Float3dp;

typedef struct {
  int num;
  void (*calc)();
  float* vars;
} Method, *Methodp;

typedef struct {                /* in the drawing contexts */
  Coord3dp object;              /* this information will   */
  int *pnum, *mnum;             /* not change, therefore   */
  Methodp methods;              /* we just need a pointer  */
  int basecolor;                /* to the correct info     */
} StaticDC, *StaticDCp;
  
typedef struct {                /* the information in this */
  StaticDCp s;                  /* block may change during */
  int basecolor;                /* a call to drawobject or */
  Bool fades;                /* explode object          */
  Coord2d points[60];
  Float3d pos;
  Float3d vel;
  float cta, sta, ctp, stp;
  Bool seen;
  Bool last;
} DC, *DCp;

typedef struct generic_s Generic;
typedef Generic* Genericp;
struct generic_s {
  int type;                    /* uses the defines in */
  int lntype;
  int attr;                    /* cbzone_defs.h       */

  float x;                      /* coordinates in 3 space */
  float y;
  float z;
  float prox;                   /* projection into player-centric */
  float proy;                   /* coordinates                    */
  float azm;                    /* direction we are pointing      */
  float ca;                     /* typically the sin and cos of   */
  float sa;                     /* the object's azm               */
  float speed;                  /* current speed                  */
  float rotate;                 /* current rotational speed       */
  float range;                  /* range from player */
  float criticalx;              /* critical distance */
  float criticaly;              /* critical distance */
  float orientation;

  int ecount;                   /* explosion or existance count   */
  int ccount;                   /* cycle count (lander explosion) */
  int pcount;                   /* plan count for movement plans  */
  int bcount;                   /* how long we've been blocked    */
  int fcount;                   /* how long since we've fired     */

  int pieces;                   /* # of pieces in the drawable    */
  DC dc[5];                     /* the drawing context            */
  
  /* now we need a method for associating a salvo with an object */
  /* since a salvo is another generic item, we just create a     */
  /* pointer to the first salvo owned by this object             */
  Genericp salvo;
  int nsalvos;                  /* how many salvos do he have */
};

typedef struct {
  int x, y;
} Position_t;

typedef struct {
  unsigned int x, y;
} Offset_t;

typedef struct {
  Position_t base;
  Offset_t size;
} Window_t;
                                      /* Now some useful globals */
