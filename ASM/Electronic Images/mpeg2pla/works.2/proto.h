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

/* getbits.c */
void initbits _P((void));
void fillbfr _P((void));
UINT32 getbyte _P((void));
void nextpacket _P((void));
UINT32 showbits _P((INT32 n));
UINT32 getbits1 _P((void));
void flushbits _P((INT32 n));
UINT32 getbits _P((INT32 n));

/* getblk.c */
void getintrablock _P((INT32 comp, INT32 dc_dct_pred[]));
void getinterblock _P((int comp));

/* gethdr.c */
INT32 getheader _P((void));
void startcode _P((void));
INT32 getslicehdr _P((void));

/* getpic.c */
void getpicture _P((INT32 framenum));
void putlast _P((INT32 framenum));

/* getvlc.c */
INT32 getMBtype _P((void));
int getMV _P((void));
int getDMV _P((void));
int getCBP _P((void));
int getMBA _P((void));
int getDClum _P((void));
int getDCchrom _P((void));

/* idct.c */
void idct _P((INT16 *block));

/* idct4_4.c */
void idct _P((INT16 *block));
void init_idct _P((void));

/* motion.c */
void motion_vectors _P((INT32 PMV[2 ][2 ][2 ], INT32 dmvector[2 ], INT32 mv_field_sel[2 ][2 ], INT32 s, INT32 mv_count, INT32 mv_format, INT32 h_r_size, INT32 v_r_size, INT32 dmv, INT32 mvscale));
void motion_vector _P((INT32 *PMV, INT32 *dmvector, INT32 h_r_size, INT32 v_r_size, INT32 dmv, INT32 mvscale, INT32 full_pel_vector));
void calc_DMV _P((INT32 DMV[][2 ], INT32 *dmvector, INT32 mvx, INT32 mvy));

/* plaympeg.c */
void error _P((char *text));
int main _P((int argc, char *argv[]));

/* recon.c */
void reconstruct _P((INT32 bx, INT32 by, INT32 mb_type, INT32 motion_type, INT32 PMV[2 ][2 ][2 ], INT32 mv_field_sel[2 ][2 ], INT32 dmvector[2 ], INT32 stwtype));

#undef _P
