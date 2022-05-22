#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif


/* display.c */
void save_palette _P((void));
void restore_palette _P((void));
void set_current_pal _P((void));
void init_display _P((void));
void exit_display _P((void));
void dither _P((unsigned char *src[]));

/* getblk.c */
void init_getblk _P((void));
void init_mb_addr_inc _P((void));
void getinterblock _P((int comp));

/* gethdr.c */
INT32 getheader _P((void));

/* getpic.c */
void getpicture _P((INT32 framenum));
void putlast _P((INT32 framenum));

/* getvlc.c */
INT32 getMBtype _P((void));
INT32 getMV _P((void));
INT32 getDMV _P((void));

/* motion.c */
void motion_vectors _P((INT32 PMV[2 ][2 ][2 ], INT32 dmvector[2 ], INT32 mv_field_sel[2 ][2 ], INT32 s, INT32 mv_count, INT32 mv_format, INT32 h_r_size, INT32 v_r_size, INT32 dmv, INT32 mvscale));
void motion_vector _P((INT32 *PMV, INT32 *dmvector, INT32 h_r_size, INT32 v_r_size, INT32 full_pel_vector));
void calc_DMVa _P((INT32 DMV[][2 ], INT32 *dmvector, INT32 mvx, INT32 mvy));

/* plaympeg.c */
void error _P((char *text));
int main _P((int argc, char *argv[]));

/* recon.c */
void reconstruct _P((INT32 bx, INT32 by, INT32 mb_type, INT32 motion_type, INT32 PMV[2 ][2 ][2 ], INT32 mv_field_sel[2 ][2 ], INT32 dmvector[2 ], INT32 stwtype));

#undef _P
