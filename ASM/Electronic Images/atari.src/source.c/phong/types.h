
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
#define MAX_CRDS 4096

typedef enum polytype { NORMAL=0,LAMBERT,GOURAUD,PHONG } PolyType;

#define AC_INDEX        0x3c0   /* Attribute controller index register */
#define MISC_OUTPUT     0x3c2   /* Miscellaneous Output register */
#define SC_INDEX        0x3c4   /* Sequence Controller Index */
#define GC_INDEX        0x3ce   /*  Graphics controller Index */
#define CRTC_INDEX      0x3d4   /* CRT Controller Index */
#define DAC_READ_INDEX  0x3c7   /* */
#define DAC_WRITE_INDEX 0x3c8   /* */
#define DAC_DATA        0x3c9   /* */
#define INPUT_STATUS_0  0x3da   /* Input status 0 register */

#define CLOCK       0xe3    /* dot clock */
#define REGCOUNT    10      /* Number of CRTC Registers to update */
