/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   WSTRUCTS.H - WAD files data structures.
*/

/*
**
** NOTE: all SHORTs previously were INTs. These are, of course, 32-bit
**       instead of the 16-bit ints from Borland C...
*/


/*
   this data structure contains the information about the THINGS
*/

struct Thing
{
  short xpos;      /* x position */
  short ypos;      /* y position */
  short angle;     /* facing angle */
  short type;      /* thing type */
  short when;      /* appears when? */
};
typedef struct Thing huge *TPtr;



/*
   this data structure contains the information about the LINEDEFS
*/
struct LineDef
{
   short start;     /* from this vertex ... */
   short end;       /* ... to this vertex */
   short flags;     /* see NAMES.C for more info */
   short type;      /* see NAMES.C for more info */
   short tag;       /* crossing this linedef activates the sector with the same tag */
   short sidedef1;  /* sidedef */
   short sidedef2;  /* only if this line adjoins 2 sectors */
};
typedef struct LineDef huge *LDPtr;



/*
   this data structure contains the information about the SIDEDEFS
*/
struct SideDef
{
   short xoff;      /* X offset for texture */
   short yoff;      /* Y offset for texture */
   char tex1[8];  /* texture name for the part above */
   char tex2[8];  /* texture name for the part below */
   char tex3[8];  /* texture name for the regular part */
   short sector;    /* adjacent sector */
};
typedef struct SideDef huge *SDPtr;



/*
   this data structure contains the information about the VERTEXES
*/
struct Vertex
{
   short x;         /* X coordinate */
   short y;         /* Y coordinate */
};
typedef struct Vertex huge *VPtr;



/*
   this data structure contains the information about the SEGS
*/
typedef struct Seg huge *SEPtr;
struct Seg
{
   SEPtr next;    /* next Seg in list */
   short start;     /* from this vertex ... */
   short end;       /* ... to this vertex */
   unsigned short angle;/* angle (0 = east, 16384 = north, ...) */
   short linedef;   /* linedef that this seg goes along*/
   short flip;      /* true if not the same direction as linedef */
   unsigned short dist; /* distance from starting point */
};



/*
   this data structure contains the information about the SSECTORS
*/
typedef struct SSector huge *SSPtr;
struct SSector
{
   SSPtr next;	  /* next Sub-Sector in list */
   short num;       /* number of Segs in this Sub-Sector */
   short first;     /* first Seg */
};



/*
   this data structure contains the information about the NODES
*/
typedef struct Node *NPtr;
struct Node
{
   short x, y;                         /* starting point */
   short dx, dy;                       /* offset to ending point */
   short miny1, maxy1, minx1, maxx1;   /* bounding rectangle 1 */
   short miny2, maxy2, minx2, maxx2;   /* bounding rectangle 2 */
   short child1, child2;               /* Node or SSector (if high bit is set) */
   NPtr node1, node2;                  /* pointer if the child is a Node */
   short num;                          /* number given to this Node */
};



/*
   this data structure contains the information about the SECTORS
*/
struct Sector
{
   short floorh;    /* floor height */
   short ceilh;     /* ceiling height */
   char floort[8];  /* floor texture */
   char ceilt[8];   /* ceiling texture */
   short light;     /* light level (0-255) */
   short special;   /* special behaviour (0 = normal, 9 = secret, ...) */
   short tag;       /* sector activated by a linedef with the same tag */
};
typedef struct Sector huge *SPtr;



/* end of file */
