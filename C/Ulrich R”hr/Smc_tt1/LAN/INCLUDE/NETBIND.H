extern int (*n_reset)(void);
extern int (*n_open)(int,int (*)(int,char *));
extern int (*n_release)(int);
extern int (*n_send)(int,char *);
extern int (*n_getadr)(int,unsigned char *);
extern int (*n_info)(int,et_stat *);
extern char *(*n_pktalloc)(unsigned short);
extern int (*n_pktfree)(char *);
