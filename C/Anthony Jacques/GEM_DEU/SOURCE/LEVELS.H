/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   LEVELS.H - Level data definitions.
*/

/* the includes */
#include "wstructs.h"
#include "things.h"

/* the external variables from levels.c */
extern MDirPtr Level;		/* master dictionary entry for the level */

extern short   NumThings;		/* number of things */
extern TPtr  Things;		/* things data */
extern short   NumLineDefs;	/* number of line defs */
extern LDPtr LineDefs;		/* line defs data */
extern short   NumSideDefs;	/* number of side defs */
extern SDPtr SideDefs;		/* side defs data */
extern short   NumVertexes;	/* number of vertexes */
extern VPtr  Vertexes;		/* vertex data */
extern short   NumSegs;		/* number of segments */
extern SEPtr Segs;		/* list of segments */
extern SEPtr LastSeg;		/* last segment in the list */
extern short   NumSSectors;	/* number of subsectors */
extern SSPtr SSectors;		/* list of subsectors */
extern SSPtr LastSSector;	/* last subsector in the list */
extern short   NumSectors;	/* number of sectors */
extern SPtr  Sectors;		/* sectors data */
extern short   NumWTexture;	/* number of wall textures */
extern char  **WTexture;	/* array of wall texture names */
extern short   NumFTexture;	/* number of floor/ceiling textures */
extern char  **FTexture;	/* array of texture names */

extern short   MapMaxX;		/* maximum X value of map */
extern short   MapMaxY;		/* maximum Y value of map */
extern short   MapMinX;		/* minimum X value of map */
extern short   MapMinY;		/* minimum Y value of map */

extern Bool  MadeChanges;	/* made changes? */
extern Bool  MadeMapChanges;	/* made changes that need rebuilding? */


/* from deu.c (config file options) */
extern char *DefaultWallTexture;	/* default normal wall texture */
extern char *DefaultLowerTexture;	/* default lower wall texture */
extern char *DefaultUpperTexture;	/* default upper wall texture */
extern char *DefaultFloorTexture;	/* default floor texture */
extern char *DefaultCeilingTexture;	/* default ceiling texture */
extern short  DefaultFloorHeight;		/* default floor height */
extern short  DefaultCeilingHeight;	/* default ceiling height */
