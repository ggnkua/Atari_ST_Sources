/******************************************************************************
 *                                                                            *
 *                     COPYRIGHT (C) 1988    L.J.M. de Wit                    *
 *                     ALL RIGHTS RESERVED                                    *
 *                                                                            *
 *                     life.c   version 1.0 of 11 Nov 1988                    *
 *                                                                            *
 * This software may be used and distributed freely if not used commercially  *
 * and the originator (me) is mentioned.                                      *
 *                                                                            *
 ******************************************************************************
 *
 * NAME
 *    life   - the game of life (graphics demo if you want)
 *
 * SYNTAX
 *    life.ttp [-d|-D] [-w wait] [01-pattern ...]
 *
 * DESCRIPTION
 *    This program barely needs comments. 'Generations' are created on a grid,
 *    on a step by step basis. The criterium used for a cell to survive
 *    (resp. die), is that it has between BOT (3) and TOP (4) neighbours
 *    (resp. has not).
 *
 *    The program runs only in high and medium resolution modes (so everyone
 *    should be able to run it); not supporting low res is entirely due to
 *    laziness on my part 8-), but since no colours are involved (yet) it
 *    seemed an unnecessary addition.
 *
 *    For both resolutions supported you can choose a coarse grid (25 x 40)
 *    and a fine one (50 x 80); default is coarse, and the -d or -D (double)
 *    option selects the fine grid.
 *
 *    The -w or -W option lets you specify an amount of time to wait between
 *    generations (default is nowait).
 *
 *    Any remaining arguments are taken to be the initial patterns to be placed
 *    on the grid, a '0' representing an empty cell, a '1' a filled one. These
 *    patterns are placed on subsequent rows, near the middle of the screen.
 *    Some pattern sets generate repetitive populations, other die away, still
 *    other generate nice ever-changing patterns. Experiment. Symmetric sets
 *    are (possibly) favorite; this means using symmetric patterns, with the
 *    first matching the last, the second the last but one, etc., and using an
 *    odd number of patterns in the coarse grid case and an even number of
 *    patterns in the fine grid case. You could alternative use point symmetry
 *    instead of line symmetry; figure out for yourself how to arrange this.
 *    If there are no remaining arguments after any flags, a random pattern is
 *    generated.
 *
 *    To finish the game, 'press any key ...'
 *
 * EXAMPLE
 *    life -d -w 20 011110 110011 101101 001100 101101 110011 011110
 *
 *    will have a fine grid, a wait pause of 20, and an initial pattern set
 *    that looks like:
 *                                  ****
 *                                 **  **
 *                                 * ** *
 *                                   **
 *                                 * ** *
 *                                 **  **
 *                                  ****
 * DECISIONS
 *    Screen access is done directly, for speed reasons (we must be able to
 *    print several hundreds of characters, several times per second, if we
 *    want screen updates to appear - almost - immediate).
 *    On the other hand, C proved to be quite fast enough, so there was no
 *    need to resort to assembler.
 *    Each resolution and each mode (coarse/fine) demands it own treatment,
 *    so four separate (functional identical) functions were written, one
 *    for each of them.
 *
 *    By using a private startup routine (not included) instead of the
 *    compiler supplied one, the size of the program could be kept
 *    considerably smaller (not using stdio).
 */

#include <osbind.h>

#define FALSE 0
#define TRUE  1

#define CPUTC(c) bios(3,2,c)              /* Write char c to console */
#define SC_24 0xffffff                    /* Mask 24 bits */
#define BOT 3                             /* Min. # of neighbours to survive */
#define TOP 4                             /* Max. # of neighbours to survive */

#define B_P_ROW  1280                     /* Bytes per screen row */
#define B_P_DROW  640                     /* Bytes per half screen row */
#define W_P_ROW   640                     /* Words per screen row */
#define W_P_DROW  320                     /* Words per half screen row */
#define L_P_ROW   320                     /* Longs per screen row */
#define L_P_DROW  160                     /* Longs per half screen row */

#define B_P_HLIN   80                     /* Bytes per hires line */
#define W_P_HLIN   40                     /* Words per hires line */
#define L_P_MLIN   40                     /* Longs per meres line */

#define STDROWS    25                     /* Default # of grid rows */
#define STDCOLS    40                     /* Default # of grid columns */
#define MAXARRSIZ (STDROWS*STDCOLS*4)     /* Max.gridsize for either gridtype */

#define BROW(bp,r) (*(bp) + Cols * (r))   /* Start of row r in block *bp   */

/* create some unsigned types */
typedef unsigned char  uchar;
typedef unsigned short ushort;
typedef unsigned long  ulong;

typedef uchar grid[MAXARRSIZ];            /* A 'grid of cells' type */

static grid *oldp, *newp;                 /* Pointers to old and new grid */

static short Rows;                        /* Actual # of rows in grid */
static short Cols;                        /* Actual # of columns in grid */

static ulong *start;                      /* Points to logical screen start */

int _mneed = 60000;                       /* For Lattice C: restricts the   */
                                          /* memory used by the program, so */
                                          /* that Mallocs will find enough  */
                                          /* memory left.                   */

static ushort dsized = FALSE;             /* Boolean: fine grid used? */

static void init_grid(),                  /* Initiate one grid        */
            calc_grid(),                  /* Calculate next grid      */
            show_s1grid(),                /* Show coarse grid med res */
            show_d1grid(),                /* Show fine grid med res   */
            show_s2grid(),                /* Show coarse grid hi res  */
            show_d2grid();                /* Show fine grid hi res    */

main(argc,argv)
int argc;
char **argv;
{
   short cntr = 0;                        /* # of generations                */
   grid *swap;                            /* Temporary to change grid ptrs   */
   register ulong *upn, *upo, uv;         /* For clearing grids initially    */
   register short cnt;                    /* Counting clear bytes            */
   long i, waittime = 0;                  /* Counting wait loop              */
   void (*showfunc)();                    /* The display function being used */
   static void (*sfuncs[])() = {          /* Possible display functions      */
      (void (*)())0,(void (*)())0,        /* Low res not implemented         */
      show_s1grid, show_d1grid,           /* Med res coarse and fine         */
      show_s2grid, show_d2grid            /* Hi res coarse and fine          */
   };

   start   = (ulong *)Logbase();          /* Cur. log. screen will be used   */
   for (--argc, argv++;
           argc > 0 && **argv == '-';
           --argc, argv++) {              /* Handle flag arguments           */
      if (argv[0][1] == 'd' || argv[0][1] == 'D') {   /* Double, i.e. fine   */
         dsized = TRUE;
      } else if (argv[0][1] == 'w' || argv[0][1] == 'W') {  /* Wait count    */
         if (--argc <= 0) {
            Cconws("life: usage: life.ttp [-d|-D] [-w|-W wait] [01-pattern...]\r\n");
            Crawcin();
            Pterm(1);
         }
         waittime = atoi(*++argv);
         if (waittime < 0 || waittime > 10000) {
            Cconws("life: wait must be between 0 and 10000\r\n");
            Crawcin();
            Pterm(1);
         }
      } else {                            /* Illegal flag                    */
         Cconws("life: usage: life.ttp [-d|-D] [-w|-W wait] [01-pattern...]\r\n");
         Crawcin();
         Pterm(1);
      }
   }

   showfunc = sfuncs[2 * Getrez() + dsized]; /* Select display function      */
   if (showfunc == (void (*)())0) {       /* Low resolution not provided for */
      Cconws("life: must be medium/high resolution, sorry ...\r\n");
      Crawcin();
      Pterm(1);
   }

   Cconws("\33E\33f\33Y,1created 1988       * LIFE *       by Leo de Wit");
   for (i = 1 << 18; --i >= 0; ) ;        /* Wait some time                  */
   CPUTC('\33'); CPUTC('l');              /* Clear current line              */

   if (dsized) {                          /* Fine grid chosen ...            */
      Rows = STDROWS * 2;                 /* Twice as many rows ...          */
      Cols = STDCOLS * 2;                 /* Twice as many cols ...          */
   } else {                               /* Coarse grid chosen              */
      Rows = STDROWS;                     /* Std. # of rows                  */
      Cols = STDCOLS;                     /* Std. # of cols                  */
   }

   newp = (grid *)Malloc(sizeof(grid));   /* Allocate one grid               */
   oldp = (grid *)Malloc(sizeof(grid));   /* And another                     */
   if (newp == (grid *)-1 || oldp == (grid *)-1) {
      Cconws("life: memory allocation failed\r\n");
      Crawcin();
      Pterm(1);
   }
   uv = 0;                                /* Now clear them both ...         */
   upn = (ulong *)newp;
   upo = (ulong *)oldp;
   for (cnt = sizeof(grid)/sizeof(ulong); --cnt >= 0; ) {
      *upn++ = *upo++ = uv;
   }

   init_grid(newp,argc,argv);             /* Initiate grid *newp             */
   waittime <<= 10;                       /* Scale waittime reasonably       */

   for (;;) {
      (*showfunc)(newp,oldp);             /* Write to logical screen         */
      if (((cntr++ & 0x7) == 0) && Bconstat(2)) { /* Test constat once in 8  */
         break;
      }
      swap = newp; newp = oldp; oldp = swap; /* Exchange grid pointers       */
      calc_grid(newp,oldp);               /* Calculate new grid from old     */
      for (i = waittime; --i >= 0; ) ;    /* This is the wait loop           */
   }

   Bconin(2);                             /* Read key pressed from queue     */
}

static void init_grid(bp,argc,argv)       /* Initiate grid *bp               */
grid *bp;
int argc;
char **argv;
{
   short len, maxlen = 0, j, i, r0, c0;

   if (argc == 0) {                       /* No parameters: random pattern   */
      short maxi = (Rows == STDROWS) ? 16 : 64; /* # of filled cells         */

      for (i = 0; i < maxi; i++) {
         short ranrow = Rows/3+((unsigned)Random())*Rows/(3*SC_24);
         short rancol = Cols/3+((unsigned)Random())*Cols/(3*SC_24);

         BROW(bp,ranrow)[rancol] = '\1';
      }
   } else {                               /* Pattern parameters              */
      for (i = 0; i < argc; i++) {        /* Find longest string length      */
         if ((len = strlen(argv[i])) > maxlen) {
            maxlen = len;
         }
      }
      r0 = (Rows - argc)/2;               /* Start row                       */
      c0 = (Cols - maxlen)/2;             /* Start column                    */
      for (i = 0; i < argc; i++) {        /* Handle each string              */
         len = strlen(argv[i]);
         for (j = 0; j < len; j++) {      /* Set each cell                   */
            BROW(bp,r0+i)[c0+j] = argv[i][j] & 1;
         }
      }
   }
}

static void calc_grid(newp,oldp)          /* Calculate new grid from old     */
grid *newp, *oldp;
{
   register short r, c;                   /* Current row, col                */
   register uchar *cp,                    /* Ptr into new grid               */
                  *ocp;                   /* Ptr into old grid               */

   for (r = Rows; --r >= 0; ) {           /* Zero each row of grid           */
      cp = BROW(newp,r+1);
      for (c = Cols; --c >= 0; ) {        /* Zero each cell of row           */
         *--cp = '\0';
      }
   }
   for (r = Rows - 1; --r >= 1; ) {       /* Handle each row of old          */
      ocp = BROW(oldp,r+1);
      --ocp;
      for (c = Cols - 1; --c >= 1; ) {    /* Handle each cell of old row     */
         if (*--ocp) {                    /* If it was filled ...            */
            cp = &BROW(newp,r-1)[c-1];    /* Incr. each neighbour's count    */
            (*cp++)++; (*cp++)++; (*cp++)++; /* Previous row in new grid     */
            cp += Cols - 3;
            (*cp++)++; (*cp++)++; (*cp++)++; /* Same row in new grid         */
            cp += Cols - 3;
            (*cp++)++; (*cp++)++; (*cp++)++; /* Next row in new grid         */
         }
      }
   }
   for (r = Rows; --r >= 0; ) {           /* Handle each row of new grid     */
      cp = BROW(newp,r+1);
      for (c = Cols; --cp, --c >= 0; ) {  /* Handle each cell of row         */
         *cp = (*cp >= BOT && *cp <= TOP);/* Set it according to accum. cnt  */
      }
   }
}

static void show_s1grid(newp,oldp)        /* Display coarse grid med res     */
grid *newp, *oldp;
{
   register short r, c;                   /* Current row & column            */
   register ulong val;                    /* Value to fill with              */
   register ulong step = L_P_MLIN;        /* Step to next screen line        */
   register uchar *cp,                    /* Ptr into new grid               */
                  *ocp;                   /* Ptr into old grid               */
   register ulong *sa,                    /* Current screen address          */
                  *basad;                 /* Screen address of end of row    */

   basad = start + (Rows * L_P_ROW);
   for (r = Rows; basad -= L_P_ROW, --r >= 0; ) {  /* Handle each row        */
      cp = BROW(newp,r+1);
      ocp = BROW(oldp,r+1);
      for (c = Cols; --c >= 0; ) {        /* Handle each column              */
         if (*--cp != *--ocp) {
            val = -*cp;                   /* 0xffffffff : 0                  */
            sa = basad + c;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val;
         }
      }
   }
}

static void show_d1grid(newp,oldp)        /* Display fine grid med res       */
grid *newp, *oldp;
{
   register short r, c;                   /* Current row & column            */
   register ulong val;                    /* Value to fill with              */
   register ulong step = L_P_MLIN;        /* Step to next screen line        */
   register ushort *sp,                   /* Ptr into new grid               */
                  *osp;                   /* Ptr into old grid               */
   register ulong *sa,                    /* Current screen address          */
                  *basad;                 /* Screen address of end of row    */

   basad = start + (Rows * L_P_DROW);
   for (r = Rows; basad -= L_P_DROW, --r >= 0; ) {  /* Handle each row      */
      sp = (ushort *)BROW(newp,r+1);
      osp = (ushort *)BROW(oldp,r+1);
      for (c = Cols/2; --c >= 0; ) {      /* Handle each column, two a time  */
         if (*--sp != *--osp) {
            static ulong values[] = {0, 0xff00ff, 0xff00ff00, 0xffffffff};

            val = values[(*sp & 1) + (*sp >> 7)];
            sa = basad + c;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val;
         }
      }
   }
}

static void show_s2grid(newp,oldp)        /* Display coarse grid hi res      */
grid *newp, *oldp;
{
   register short r, c;                   /* Current row & column            */
   register ushort val;                   /* Value to fill with              */
   register ulong step = W_P_HLIN;        /* Step to next screen line        */
   register uchar *cp,                    /* Ptr into new grid               */
                  *ocp;                   /* Ptr into old grid               */
   register ushort *sa,                   /* Current screen address          */
                   *basad;                /* Screen address of end of row    */

   basad = ((ushort *)start) + (Rows * W_P_ROW);
   for (r = Rows; basad -= W_P_ROW, --r >= 0; ) {  /* Handle each row        */
      cp = BROW(newp,r+1);
      ocp = BROW(oldp,r+1);
      for (c = Cols; --c >= 0; ) {        /* Handle each column              */
         if (*--cp != *--ocp) {
            val = -*cp;                   /* 0xffffffff : 0                  */
            sa = basad + c;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val;
         }
      }
   }
}

static void show_d2grid(newp,oldp)        /* Display fine grid hi res        */
grid *newp, *oldp;
{
   register short r, c;                   /* Current row & column            */
   register uchar val;                    /* Value to fill with              */
   register ulong step = B_P_HLIN;        /* Step to next screen line        */
   register uchar *cp,                    /* Ptr into new grid               */
                  *ocp;                   /* Ptr into old grid               */
   register uchar *sa,                    /* Current screen address          */
                  *basad;                 /* Screen address of end of row    */

   basad = ((uchar *)start) + (Rows * B_P_DROW);
   for (r = Rows; basad -= B_P_DROW, --r >= 0; ) {  /* Handle each row        */
      cp = BROW(newp,r+1);
      ocp = BROW(oldp,r+1);
      for (c = Cols; --c >= 0; ) {        /* Handle each column              */
         if (*--cp != *--ocp) {
            val = -*cp;                   /* 0xff : 0                        */
            sa = basad + c;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val; sa += step;
            *sa = val;
         }
      }
   }
}
