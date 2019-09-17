
/*			INPUT.C				*/
/*	     inputing keys including F1, F2, etc.	*/
 							
#include "portab.h"
#include "stdio.h"
#include "osbind.h" /* this header file contains definition of Bconin */
		    /*		extern long bios();		     */
		    /* 		#define Bconin(a) 	bios(2,a)    */

int contrl[12];			/* arrays for communication to */
int intin[128];			/* and from GEM                */
int ptsin[128];
int intout[128];
int ptsout[128];

main()				/* beginning of program */

{
int handle, gr_1, i, dumvar1;
int l_intin[11], l_intout[57];

int c;
long a;

appl_init();			/* initialization of application */
	
handle=graf_handle( &gr_1, &gr_1, &gr_1, &gr_1);  /* unique identifier */
v_hide_c( handle); 		/* hide mouse */
v_clrwk( handle);			/* clear screen */

l_intin[0] = 1;
for (i = 1; i < 10; i++)
    l_intin[i] =1;
l_intin[10] = 2;			/* RC coordinates */
v_opnvwk( l_intin, &handle, l_intout);  /* open virtual work station */

v_curhome( handle );
printf("\n\t		INPUT.PRG\n\n");
printf("\tThis program  is set  up so that you can see  the  return value ");
printf("\n\tof  Bconin(2) which  returns a  long value  contrary to  certain");
printf("\n\tspec sheets.  This  will  allow a program to look for input from");
printf("\n\tany key on the keyboard from the function keys F1 to F10 to many");
printf("\n\tdifferent combination of keys.  Press \"a\"  to return  to  TOS."); 
printf("\n\tThe setup is as follows:");
printf("\n\n		long a; ");
printf("\n	      	a = Bconin(2);\n\n");
printf("\n\tSee INPUT.DOC for specific implementation in C\n\n");
			
a=0;
while (a!=1966177) {
    a = Bconin(2);
    printf("\n  %10ld", a );
}


v_clsvwk(handle);  			/* close workstation */
appl_exit();				/* exit application */

}					/* end of program */

