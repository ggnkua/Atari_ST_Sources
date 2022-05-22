# define _P(s) s


/* display.c */
void init_display _P((void));
void exit_display _P((void));
void display_image _P((unsigned char *image));
void dither _P((void));

/* getbits.c */
void initbits _P((void));
void fillbfr _P((void));
void flushbits _P((int n));
unsigned long getbits _P((int n));

/* getblk.c */
void getintrablock _P((int comp, int dc_dct_pred[]));

/* gethdr.c */
int getheader _P((void));
void startcode _P((void));
void getseqhdr _P((void));
void getgophdr _P((void));
void getpicturehdr _P((void));
int getslicehdr _P((void));
void ext_user_data _P((void));
void ext_bit_info _P((void));

/* getpic.c */
void getpicture _P((void));

/* getvlc.c */
void init_mb_addr_inc _P((void));
int getMBtype _P((void));
int getCBP _P((void));
int getMBA _P((void));
int getDClum _P((void));
int getDCchrom _P((void));

/* mpeg2dec.c */
void error _P((char *text));
void initdecoder _P((void));
void go _P((void));
int main _P((int argc, char *argv[]));

#undef _P
