
/******************************************************************************
 *                                                                            *
 *                          C O N S T A N T S                                 *
 *                                                                            *
 ******************************************************************************/

#define fsm_ADVANCE_HORIZONTAL 1
#define fsm_ADVANCE_VERTICAL   2


/*
 * Structure sizes
 */
#define fsm_CLIENTBYTES     5000

/******************************************************************************
 *                                                                            *
 *                      D A T A   S T R U C T U R E S                         *
 *                                                                            *
 ******************************************************************************/

#ifndef bool
#define	bool    short
#define false   0
#define true    1
#endif

/*
 * fsm_FontType:    contains font specific information.
 */
typedef struct {
    char                  reserved1[6];
    short             denom;
    char                  reserved2[16];
    short             boundingBox[4];         /* divide by denom  */
    char                  reserved3[1];
    char              advanceDir;
    char                  reserved4[1];
    char              isFixedPitch;
    char                  reserved5[4];
    short             underlinePosition;      /* divide by denom => percentage of em */
    short             underlineTickness;      /* divide by denom => percentage of em */
    long              uniqueID;
    char                  reserved6[ 22 ];    
    fsm_PointerRef_t  fullName,
                      familyName;
    char                  reserved7[ 16 + fsm_MAXFILENAMELEN ];    
} fsm_FontType;

/*
 * fsm_ClientType:  contains system inteface routines and state information.
 */
typedef struct {
    char    moreSpace[ fsm_CLIENTBYTES ];
} fsm_ClientType;


/*****************************************************************
 *
 * definition of types used for output arguments from FSM
 *
 *****************************************************************/

/*
 * fsm_HeightType:  structure containing the height constraints of a font.
 */
typedef struct {
    short   cap,        /* all values in pixels */
            x,
            ascender,
            descender,
            figure,
            baseline;   /* generally 0  */
} fsm_HeightType;

/*
 * fsm_BitmapType:  header is followed by bitmap data.
 */
typedef struct {
            long           xOffset;       /* offset (in pixels) to apply to get      */
            long           yOffset;       /* to origin (upper left corner) of bitmap */
            unsigned short width;         /* size of bit array (pixels) */
            unsigned short height;
	    short          *data;
} fsm_BitmapType;

typedef struct fsm_ComponentType {
    char                reserved[4];
    fsm_PointerRef_t    nextComponent;  /* structure containing ptr to next component struct */
    fsm_BitmapType      bm;             /* bitmap header; bitmap follows at address bm.data */
} fsm_ComponentType;

typedef struct {
    long x, y;                       /* advance in (x, y) direction (in pixels) */
} fsm_advanceVecType;

typedef struct {
    fsm_advanceVecType  advance;         /* advance vector of the character      */
    fsm_PointerRef_t    firstComponent;  /* structure containing pointer to */
                                         /* linked list of components       */
} fsm_OutputType;

