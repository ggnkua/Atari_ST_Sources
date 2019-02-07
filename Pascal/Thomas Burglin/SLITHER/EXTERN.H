/*  header file  */

#include "ssedt.h"

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <linea.h>
#include <strings.h>

#define   LWORD     long
#define   WORD      int
#define   BUSYBEE   HOURGLASS   /* mousecursorform, unfortunately 
                                   various definitions             */
#define   NRSET     10

extern   int    contrl[12];
extern   int    intin[128], ptsin[128]; 
extern   int    intout[128], ptsout[128];
extern   WORD   handle;
extern   WORD   w_handle;
extern   char   defpath[64],workpath[80],filename[20],filepath[80];
extern   int    gdos;
extern   MFDB   screenbuffer;
extern   MFDB   screen;
extern   char   *scptr;
extern   LWORD  menupar, diasave, diainfo, diagoto, diasym;
extern   WORD   out[128];
extern   WORD   clip[4];
extern   WORD   wi_1,wi_2,wi_3,wi_4;
extern   WORD   slsizx, slsizy, slposx, slposy;   /* sliders   */
extern   char   *stlevel[];
extern   char   *nrlevel[];
extern   char   *atlevel[];
extern   char   *gotoset[];
extern   char   *gotolevel[];
typedef unsigned char FIDAR[30][5][38];
extern   FIDAR setbuffer;
extern   FIDAR *set[NRSET];

extern   int    level[NRSET];
extern   int    nrfields[NRSET];
extern   int    atfield[NRSET];
extern   int    maxsetindex;
extern   int    setindex;
extern   int    levelindex[NRSET];
extern   int    changeset[NRSET];
extern   char   setname[NRSET][20];
extern   int    screenfield, screenunit;
extern   int    xscreenfield, xscreenunit;
extern   int    screenxs, screenys;
extern   WORD   fic[4], foc[4];

extern   lineaport *myport;
