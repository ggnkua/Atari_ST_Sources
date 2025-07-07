/*
 * cbzone_defs.h
 *  -- Todd W Mummert, December 1990, CMU
 *
 * This file shouldn't need to be changed.
 */
/* Generally useful information */
#ifndef LATTICE		/* RMG 31/10/93 */
#define PI 3.14159265358
#endif
#define PI2 6.28318530716

/* some tolerances for certain objects */
#define BMT_TOL 14400           /* tank      */
#define BMC_TOL 6000            /* copter    */
#define BMS_TOL 14400           /* supertank */

/*
 * the following types and attributes are defined
 *
 * The attributes are pretty self explanatory.  The important
 * thing to remember is that an object should not be removed
 * if it is STILL_THERE.  The components of STILL_THERE are
 * IS_ALIVE, IS_EXPLODING, ERASE, EXERASE.   ERASE and EXERASE means
 * the object should be removed, but before reclaiming its space we
 * should check if we need to undraw it.  ERASE and EXERASE are
 * typically used when removing an object prematurely, as in the
 * case of a missile run, though ERASE is also used while an
 * object moves from the IS_ALIVE state to IS_EXPLODING.
 */
#define IS_PYRAMID       0x1
#define IS_CUBE          0x2
#define IS_ABLOCK        0x3
#define IS_TANK          0x4
#define IS_SUPER         0x8
#define IS_MISSILE       0x10
#define IS_COPTER        0x20
#define IS_LANDER        0x40
#define IS_SALVO         0x80
#define IS_PLAYER        0x100
#define IS_ENEMY         0x3c   /* derived */
#define IS_ANYTHING      0x1ff  /* derived */
#define IS_NOTBLOCK      0x1fc  /* derived */
  
#define LN_PYRAMID       0x0    /* the log base 2 of the above values  */
#define LN_CUBE          0x1    /* we use this number to index into an */
#define LN_TANK          0x2    /* array in the drawobject stage       */
#define LN_SUPER         0x3
#define LN_MISSILE       0x4
#define LN_COPTER        0x5
#define LN_LANDER        0x6
#define LN_SALVO         0x7

#define IS_ALIVE         0x1
#define IS_NEW           0x2
#define ERASE 		 0x8
#define EXERASE          0x10
#define CAN_SHOOT        0x20
#define IS_PRESET        0x40
#define IS_EVADING       0x80
#define IS_EXPLODING     0x100
#define BLOCKED_BY_ENEMY 0x200
#define BLOCKED_BY_BLOCK 0x400
#define LAST_BLOCKED     0x800
#define HAS_DC           0x1000
#define IS_BLOCKED       0x600  /* derived */
#define STILL_THERE      0x119  /* derived */  
#define START_LIVING     0x3    /* derived */
#define START_EXPLODING  0x10a  /* derived */

#define DIST(a,b) ((a->x-b->x)*(a->x-b->x)+(a->y-b->y)*(a->y-b->y))
#ifndef LATTICE
#define frand() ((random() & 0xffff) / 65535.0)
#else
#define frand() ((rand() & 0xffff) / 65535.0)
#endif
#define ra(x) (x)*PI/180.0
#define sign(v,c) ((c)<0.0?-(v):(v))
