/*	include file for cxx_test

	the following cpp id should be defined :
		TEST_SIZE		: 1,2,4 for byte, word or long
*/

# if TEST_SIZE == 1

# define TEST_TYPE byte
# define TYPE_NAME "byte"
# define test_pattern byte_pattern
# define item_test byte_test
# define item_loop byte_loop
# define item_print byte_print
# define TYPE_FORM "%02x"

# elif TEST_SIZE == 2

# define TEST_TYPE uword
# define TYPE_NAME "word"
# define item_test word_test
# define test_pattern word_pattern
# define item_loop word_loop
# define item_print word_print
# define TYPE_FORM "%04x"

# elif TEST_SIZE == 4

# define TEST_TYPE unsigned long
# define TYPE_NAME "long"
# define item_test long_test
# define test_pattern long_pattern
# define item_loop long_loop
# define item_print long_print
# define TYPE_FORM "%08lx"

# endif

# include "testfast.h"

/*----------------------------------------------- item_print ----------*/
char *item_print ( TEST_TYPE correct, TEST_TYPE value, char *s )
{
	char *ss,*sd ;
	char s0[9] ;
	TEST_TYPE mask, differ ;

	sprintf ( s, TYPE_FORM, value ) ;

	differ = value ^ correct ;
	if ( differ != 0 )
	{
# if 0
		break_point();
# endif
		ss = strcpy ( s0, s ) ;
		sd = s ;
		for ( mask = (TEST_TYPE)0xf0 << ( (TEST_SIZE-1)*8 ) ; mask != 0 && *ss != 0 ; mask >>= 4 )
		{
			if ( mask & differ )
			{
				*sd++ = '\033' ;	/*	invers video	*/
				*sd++ = 'p' ;
				*sd++ = *ss++ ;
				*sd++ = '\033' ;	/*	normal video	*/
				*sd++ = 'q' ;
			}
			else
			{
				*sd++ = *ss++ ;
			}
		}
		*sd++ = 0 ;
	}
	return ( s ) ;
}

/*----------------------------------------------- item_loop ----------*/
long item_loop ( byte *address, ulong amask, int loop,
				 unsigned long items, bool write )
{
	TEST_TYPE	*pa ;
	ulong		j ;
	char		s1[80], s2[80] ;
	ulong		abit, tested_items ;
	
	TEST_TYPE	val1,val2,pat ;
	unsigned	accerr_type ;
	
	bool higherror, lowerror ;

	tested_items = 0 ;
	berr_flag = FALSE ;
	inst_buserr();

	errors = 0 ;

	for( pa = (TEST_TYPE*)address, j=0;  j<items && !abort && !berr_flag ;  j++, pa++ )
	{
		abit = 	( (ulong)pa & 31 ) ;
		if ( ( (1L<<abit) & amask ) == 0 )
			continue ;

		tested_items++ ;

		pat = test_pattern(loop,j,pa) & (TEST_TYPE)memtest_mask ;
		if ( write )
		{
			*pa = pat ;

			if ( berr_flag )
			{
				remove_buserr();
				printf ( "* bus error at $%8.8lx, write\n", (long)pa ) ;
				errors++ ;
				abort = TRUE ;
				return tested_items ;
			}
		}

		val1 = *pa & (TEST_TYPE)memtest_mask ;
		if ( berr_flag )
		{
			remove_buserr();
			printf ( "* bus error at $%8.8lx, read # 1\n", (long)pa ) ;
			abort = TRUE ;
			errors++ ;
			return tested_items ;
		}
		val2 = *pa & (TEST_TYPE)memtest_mask ;
		if ( berr_flag )
		{
			remove_buserr();
			printf ( "* bus error at $%8.8lx, read # 2\n", (long)pa ) ;
			abort = TRUE ;
			errors++ ;
			return tested_items ;
		}

		
		if ( val1 != val2 )
			accerr_type = TRIG_R ;
		else if ( val1 != pat )
			accerr_type = TRIG_W ;
		else
			accerr_type = 0 ;
		if ( accerr_type != 0 )
		{
			if ( osc_trig != NULL )
			{
				*osc_trig = flip_on ;
				*osc_trig = flip_off ;
			}
			errors++ ;
			if ( berr_access & accerr_type )
			   *ERR_PTR = 0x55 ;
				/* berr access only */ ;

	        higherror = 0;
	        lowerror  = 0;
# if sizeof(TEST_TYPE) == 1
	        higherror = (unsigned)((long)pa & 000001L);
	        lowerror  = !higherror;
# elif sizeof(TEST_TYPE) == 2
	        lowerror  = ( ((val1 & 0xff00) != (pat & 0xff00)) || ((val1 & 0xff00) != (val2 & 0xff00)) );
	        higherror = ( ((val1 & 0x00ff) != (pat & 0x00ff)) || ((val1 & 0x00ff) != (val2 & 0x00ff)) );
# endif
			printf ( "\n$%8.8lx - w : "TYPE_FORM"  r : %s %s %c?   B%c  %c%c",
						 (long)pa, pat, item_print ( pat, val1, s1 ),
						 			    item_print ( pat, val2, s2 ),
						 			    val1 == val2 ? 'W' : 'R' ,
						 			    (long)pa & 000002L ? '1' : '0',
						 			    (higherror) ? 'H' : ' ',
						 			    (lowerror)  ? 'L' : ' ') ;
			if (higherror)							 			    
	        	(long)pa & 000002L ? bank1h_errors++ : bank0h_errors++;
			if (lowerror)							 			    
	        	(long)pa & 000002L ? bank1l_errors++ : bank0l_errors++;
			if(kbhit())
			{
				getch();	/* eat stop char	*/
				printf ( "\n quit loop / [ Go on ] ? >" ) ;
				abort = tolower(getch()) == 'q' ;
				printf ( "\n" ) ;
			}
			else
				abort = 0 ;
# if 0
			printf ( "    " TYPE_NAME "s testing, loop : 0000  " ) ;
# endif
			if ( berr_access & accerr_type )
				getch() ;
		}
	}

	remove_buserr();
	
	return tested_items ;
}

/*----------------------------------------------- item_test ----------*/
void item_test ( byte *address, ulong range, ulong amask,
				 int rw_loops, int rd_loops  )
{
	unsigned long items ;
	int rwloop, rloop;
	long loop_errors, tested_items ;

# if 0	
	printf ( TYPE_NAME "s testing, loop : 0000" ) ;
# endif
	printf ( "= test "TYPE_NAME"s at %8.8lx, range = %lu\n",
							 address, range ) ;
						
	errors = 0 ;
	bank0h_errors = 0 ;
	bank0l_errors = 0 ;
	bank1h_errors = 0 ;
	bank1l_errors = 0 ;
	
	abort = FALSE ;
	items = range / sizeof ( TEST_TYPE ) ;

	loop_errors = errors = 0 ;

	while ( kbhit() )
		getch() ;
	
	for ( rwloop=1; rwloop<=rw_loops && !abort; rwloop++)
	{
		if( kbhit() ) { abort = TRUE ; break ; }
		
# if 0
		printf ( "\b\b  \b\b\b\b\b\b%4d", rwloop ) ;
# else
		if ( loop_errors != errors ) printf ( "\n" ) ;
							    else printf ( "\r" ) ;
			printf ( "loop %4d", rwloop ) ;
# endif		
		printf ( "w" ) ;
		tested_items = item_loop ( address, amask, rwloop, items, TRUE ) ;
		for ( rloop = 1; rloop <= rd_loops; rloop++ )
		{
			if ( loop_errors != errors ) printf ( "\n" ) ;
			printf ( "r(%d)", rloop ) ;
			loop_errors += errors ;
			tested_items += item_loop ( address, amask, rwloop, items, FALSE ) ;
		}
	}
# if 0
	printf ( "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bed : %8ld, errors : %ld\n",
									 rw_loops*items, loop_errors ) ;
# else
	printf ( "\ntested : %8ld, errors : %ld\n",
									 rw_loops*items, loop_errors ) ;
# if 0
    printf ( "Bank0:   ges: %d     high: %d     low %d\n", bank0h_errors + bank0l_errors, bank0h_errors, bank0l_errors);								 
    printf ( "Bank1:   ges: %d     high: %d     low %d\n", bank1h_errors + bank1l_errors, bank1h_errors, bank1l_errors);
# endif
# endif
}

# undef TEST_SIZE
# undef TEST_TYPE
# undef TYPE_NAME
# undef TYPE_FORM
# undef item_test
# undef item_loop
# undef test_pattern
# undef item_print
