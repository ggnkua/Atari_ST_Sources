/********************************************************************************/
/*                              *************                                   */
/*                              *  Y 4 . H  *                                   */
/*                              *************                                   */
/*                                                                              */
/*  This file contains the external declarations needed to hook Yacc modules    */
/* which were originally in Y4.C to their impure data in Y4IMP.4C. Also does    */
/* the include of the original data/external file DTXTRN.H.                     */
/*                                                                              */
/********************************************************************************/

# include "dtxtrn.h" 

# define yyact  amem
# define pa     indgo
# define yypact temp1
# define greed  tystate

# define NOMORE - 1000

extern int * ggreed;
extern int * pgo;
extern int * yypgo;

extern int   maxspr; /* maximum spread of any entry */
extern int   maxoff; /* maximum offset into a array */
extern int * pmem;
extern int * maxa;
extern int   nxdb;
extern int   adb;
