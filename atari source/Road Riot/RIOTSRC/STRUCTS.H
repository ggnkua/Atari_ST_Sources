typedef struct {
    struct links flnk;
    U16 *colptr;
    U8	opcode,count,ctimer,pad;
    S16	di,dr,dg,db;
    U16 original;
} FLASH_BLOCK;

typedef struct {
    struct links rlnk;
    U16 *colptr;
    U8	opcode,count,ctimer,num_cols;
    S8	first_col,pad;
    U16 orig[64];
} ROTATE_BLOCK;

typedef struct {
    struct links alnk;
    U16 *colptr;
    U8	opcode,count,ctimer,first_time;
    U16 *dest;
} FADE_BLOCK;

typedef union {
    ROTATE_BLOCK	r;
    FLASH_BLOCK		f;
    FADE_BLOCK		a;
} CANIM_BLOCK;


