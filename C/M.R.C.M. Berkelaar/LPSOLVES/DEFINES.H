#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define HASH_SIZE  10000 
#define ETA_START_SIZE 10000 /* start size of array Eta. Realloced if needed */
#define FNAMLEN 64
#define NAMELEN 25
#define MAXSTRL (NAMELEN-1)
#define STD_ROW_NAME_PREFIX "r_"

#define	FALSE	0
#define	TRUE	1

#define LE      0
#define EQ      1
#define GE      2
#define OF      3

#define	abs(x)	((x) < 0 ? -(x) : (x))

#define CALLOC(ptr, nr, type) if(!(ptr = calloc((size_t)(nr),\
  sizeof(type)))) { fprintf(stderr, "calloc failed\n"); exit(1); }

#define MALLOC(ptr, nr, type) if(!(ptr = malloc((size_t)((nr) * \
  sizeof(type))))) { fprintf(stderr, "malloc failed\n"); exit(1); }

#define FREE(ptr) free(ptr);ptr=NULL;

#define INFINITE  1.0e12
#define EPSB      0.0001
#define EPSEL     1.0e-8
#define EPSD      0.0001
#define EPSILON   0.01 /* to determine if float is an int */

typedef char    nstring[NAMELEN];

typedef struct _column
{
  int row;
  float value;
  struct _column *next ;
} column;

typedef struct _bound
{
  double        upbo;
  double        lowbo;
} bound;

typedef struct _hashelem
{
  nstring          colname;
  struct _hashelem *next;
  struct _column   *col;
  struct _bound    *bnd;
  int              must_be_int;
} hashelem;

typedef struct _rside /* contains relational operator and rhs value */
{
  double        value;
  struct _rside *next;
  short         relat;
} rside;

/* structure or final data-storage */

typedef struct  _matrec 
{
  int    rownr;
  double  value;
} matrec;

typedef struct _tmp_store_struct
{
  nstring name;
  int     row;
  double  value;
  double  rhs_value;
  short   relat;
} tmp_store_struct;

typedef struct _intrec
{
  int             varnr;
  struct _intrec  *next;
}
intrec;
