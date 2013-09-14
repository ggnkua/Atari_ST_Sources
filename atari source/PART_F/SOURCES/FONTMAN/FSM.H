
#ifdef ANSI
#define fsm_Args(x) x
#else
#define fsm_Args(x) ()
#endif

#define fsm_errNoChar       0  /* "No symbol %u found in the symbol file: %s" */

#define fsm_errFileRead         8
#define fsm_errFileOpen         9
#define fsm_errFileFormat       10
#define fsm_errNoMem            11
#define fsm_errNotImplemented   12
#define fsm_errMisc         -1

#define fsm_MAXFILENAMELEN       32      /* max length of file name */
#define fsm_MAXFULLFILENAMELEN   120     /* max length of full file name */
#define fsm_MAXPREFIXLEN         5
/*
 * Pointer Reference Type.
 */
typedef struct fsm_PointerRef_t {
    char    *ptr;
    long    hdl;
} fsm_PointerRef_t;

typedef enum {
    fsm_memBitmap, fsm_memTemp, fsm_memHeap
} fsm_MemKind_t;

typedef struct {
    float x, y;
} fsm_float_vec_t;

typedef struct {
    float a, b, c, d, x, y;
} fsm_xform_t;

typedef struct {
    float x, y;
} fsm_userMetrics_t;

typedef enum {
    fsm_charWidth, fsm_charArea, fsm_charPath, fsm_charBbox
} fsm_Option_t;

