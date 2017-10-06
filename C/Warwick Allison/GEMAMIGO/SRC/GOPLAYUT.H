#ifndef goplayutil_h
#define goplayutil_h

#define iNil 32767 /* a distinguished value like nil */
#define  maxGroup 512
#define  maxSPoint 16
#define tryLimit 300

typedef short intBoard[19][19];  /* these were -2 to maxPoint + 2 */

typedef short boolBoard[19][19];

typedef struct
{
   short px, py;
} point;

typedef struct
{
   point p[401];
   short indx;
} pointList;

typedef struct
{
  point p[maxSPoint+1];
  short indx;
} sPointList;

typedef struct
{
   short indx,
   v[401];
} intList;
   
typedef struct { short w, s, sm; } sgRec;

typedef struct
{
   short groupMark,
         atLevel,
	 isLive,
	 isDead,
	 libC,
	 numEyes,
	 size,
	 lx, ly;
} groupRec;

typedef enum {rem, add, chLib, reMap} playType;

typedef struct { short who, xl, yl, nextGID, sNumber; } remAddRec;
typedef struct { short oldLC, oldLevel; } chLibRec;
typedef struct { short oldGID; } reMapRec;
typedef struct
{
   short gID;
   playType kind;
   union {
      remAddRec rem, add;
      chLibRec chLib;
      reMapRec reMap;
   } uval;
} playRec;


#endif
