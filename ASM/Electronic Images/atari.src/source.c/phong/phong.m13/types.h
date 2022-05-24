
typedef short INT16;
typedef int   INT32;
typedef enum bool {FALSE=0,TRUE=1} Bool;


#define MAX_X 320
#define MAX_Y 200

#define BITS (14)
#define SCALE (1<<BITS)

#define LBITS (12)
#define LSCALE (1<<LBITS)

#define DIST  512                       /* perspective 'DISTANCE' */
#define MAX_CRDS 2048

typedef enum polytype { NORMAL=0,LAMBERT,GOURAUD,PHONG } PolyType;
