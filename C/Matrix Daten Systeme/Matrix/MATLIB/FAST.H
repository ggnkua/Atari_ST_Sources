extern int ldl ( int n, int ldmax ) ;
extern long mul16x16 ( int a, int b ) ;
extern int iscale ( int a, int b, int c ) ;
extern unsigned uscale ( unsigned a, unsigned b, unsigned c ) ;
extern void midcolw ( int *dest, int factor, int *low, int *high, int unit ) ;

extern byte     swizzb  ( byte     b  ) ;
extern unsigned swizzw  ( unsigned w  ) ;
extern ulong    swizzl  ( ulong    l  ) ;
extern uword	swizzbb ( uword    bb ) ;	/* swizzle 2 bytes inside	*/
