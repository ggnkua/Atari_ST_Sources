# define X 0
# define Y 1
# define Z 2
# define D 3

typedef unsigned bool ;
# define FALSE 0
# define TRUE  1

typedef float Value ;

typedef Value Tmatrix[Z+1][D+1] ;
typedef Value Point[3] ;

typedef struct { Point translate,scale,rotate ; } Transform ;

# define theta	rotate[Z]
# define omega	rotate[X]
# define phi	rotate[Y]

# define sx		scale[X]
# define sy		scale[Y]
# define sz		scale[Z]

# define dx		translate[X]
# define dy		translate[Y]
# define dz		translate[Z]

# define MAX_2D_X  32767.49
# define MIN_2D_X -32767.49
# define UNDEF_XY (int)0x8000

typedef struct { int x, y ; } Ipoint2 ;
typedef struct { int x, y, z ; } POINT3 ;
typedef struct { Value x, y, z ; } POINT3f ;

typedef struct { int x, y, z, w, h, d ; } RECTangle3 ;
typedef struct { POINT3 pos,dim ; } RECT3 ;


extern void transform ( Tmatrix *m, Point *in, Point *out ) ;

extern void calc_tmat ( Transform *t, Tmatrix *m ) ;

