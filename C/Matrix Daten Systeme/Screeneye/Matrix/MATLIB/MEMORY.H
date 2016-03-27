/*	memory.h	/	10.7.91	/	MATRIX	/	WA	*/

extern long and_pattern, or_pattern, memtest_mask ;

# define test_def(name) \
extern void name ( byte *address, ulong range, ulong amask, int rw_loops, int rd_loops  )

test_def ( byte_test ) ;
test_def ( word_test ) ;
test_def ( long_test ) ;

extern int  memory_test ( int itemsize, byte *address, ulong range, ulong amask,
						 int rw_loops, int rd_loops  ) ;
extern void set_fail_trigger ( uword *triga, word val0, word val1 ) ;