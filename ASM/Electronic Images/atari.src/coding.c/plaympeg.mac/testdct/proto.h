#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif


/* fastdct.c */
void init_fastdct _P((void));
void fastdct _P((INT16 *blk));

/* idct.c */
void idct _P((INT16 *block));

/* idct2.c */
void idct2 _P((short *block));

/* idct3.c */
void idct3 _P((short *block));

/* jidctfst.c */
void jpeg_idct_ifast _P((int *coef_block, int *output_buf));

/* main.c */
void print_time _P((clock_t s, clock_t e));
void main _P((void));

#undef _P
