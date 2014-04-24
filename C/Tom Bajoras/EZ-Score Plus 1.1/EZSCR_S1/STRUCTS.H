/* structs.h - crd 880212 - ez-score plus - hybrid arts inc. */

typedef struct {
   long  fontptr;
   long  offptr;
   int   fontw;
   int   fonth;
   int   charw;
   int   lowchar;
   int   highchar;
} FONTFORM;

typedef struct {           /* printer font element */
   int   bt_width;         /* width of image in bytes             */
   int   height;           /* height of image in lines            */
   short *image;           /* bit image, bt_width * height bytes  */
} PSYM;

typedef struct {
   int   top;              /* left edge brace going down from here      */
   int   size;             /* left edge brace going up from here        */
   PSYM  *psym;            /* --> the brace of the appropriate size     */
} LBRACE;

typedef struct {
   int   top;              /* left edge bracket going down from here    */
   int   size;             /* left edge bracket going up from here      */
} LBRACK;

typedef struct {           /* system vertical domain including ledgers  */
   int   top;              /* (also used for title and copyright text)  */
   int   size;
} SYSDOM;

#define  textptr(a,b)  (((TEDINFO*)(((OBJECT*)(a))[b].ob_spec))->te_ptext)

/* EOF */
