/*	memory.c	/	10.7.91	/	MATRIX	/	WA	*/

# include <tos.h>
# include <stdio.h>
# include <ext.h>
# include <ctype.h>
# include <string.h>


# include <global.h>
# include <error.h>

# include "traps.h"
# include "memory.h"


# define ERR_PTR ((byte *)0xa50000L)

# define MAX_RANGE	(2L*1024L*1024L-1024L)

long and_pattern  = 0xffffffffL ;
long or_pattern	  = 0x00000000L ;
long memtest_mask = 0xffffffffL ;

long	adrmsk = 0 ;	/* always true	*/
long	adrpat = 0 ;


uword *osc_trig = NULL ;
word flip_on  = 0x80 ;
word flip_off = 0x00 ;

# define TRIG_R	0x0001
# define TRIG_W	0x0002
unsigned berr_access = 0 ;

# define BANK_0 0x0001
# define BANK_1 0x0002
unsigned bank = BANK_0 | BANK_1 ;

unsigned  bank0h_errors, bank0l_errors,
     	  bank1h_errors, bank1l_errors;

bool	abort ;
long	errors ;

# if 0
# define test_pattern(i,j,a) \
	(((((TEST_TYPE)a+(TEST_TYPE)i))&(TEST_TYPE)and_pattern)|(TEST_TYPE)or_pattern)
# endif


# define TEST_SIZE	1
# include "bwl_test.h"
# define TEST_SIZE	2
# include "bwl_test.h"
# define TEST_SIZE	4
# include "bwl_test.h"

# include "memory.h"

/*------------------------------------------- memory_test ----------*/
int memory_test ( int itemsize, byte *address, ulong range, ulong amask,
				  int rw_loops, int rd_loops  )
{
	switch ( itemsize )
	{
 case 1 :	byte_test ( address, range, amask, rw_loops, rd_loops ) ;
 			break ;
 case 2 :	word_test ( address, range, amask, rw_loops, rd_loops ) ;
 			break ;
 case 4 :	long_test ( address, range, amask, rw_loops, rd_loops ) ;
 			break ;
 default :	printf ( "* illegal item size = %d, must be 1,2 or 4\n",
 							itemsize ) ;
 			return ( NotOK ) ;
	}
	return ( OK ) ;
}


/*-------------------------------------- set_fail_trigger ----------*/
void set_fail_trigger ( uword *triga, word val0, word val1 )
{
	osc_trig = triga ;
	flip_on  = val0 ;
	flip_off = val1 ;
}