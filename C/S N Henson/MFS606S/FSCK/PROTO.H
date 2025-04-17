#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif


/* common.c */
int comma_parse P((char *str , llist **list ));
void read_zone P((long zone , void *buff ));
void write_zone P((long zone , void *buff ));
int chk_range P((long zone ));
void setbit P((long zone , unsigned *map ));
void clrbit P((long zone , unsigned *map ));
int isset P((long zone , unsigned *map ));
long findbit P((unsigned *map , long limit ));
long alloc_zone P((void ));
int mark_zone P((long zone ));
void unmark_zone P((long zone ));
int ask P((char *str , char *alt ));
void fatal P((char *str ));
void sfatal P((char *str ));
void usage P((void ));
void read_tables P((void ));
int do_trunc P((void ));
int chk_irange P((unsigned inum ));
void inerr P((char *name ));
int badname P((char *name ));
void cpdir P((dir_struct *dest , dir_struct *src ));
void showinfo P((void ));

/* io.c */
void read_blocks P((long start , unsigned count , void *buff ));
void write_blocks P((long start , unsigned count , void *buff ));
int init_device P((char *name , int rw ));
void close_device P((void ));
int set_size P((long nblocks ));

/* main.c */
void main P((int argc , char **argv ));

#undef P
