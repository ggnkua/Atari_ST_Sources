/* 
 *	BBS Level Zero - System Dependant header file
 *	(LazyBBS Project)
 *
 *	Public Domain: may be copied and sold freely
 */

/* internal pseudo funcs for portability */
#define timenix(a) time(a)	/* return nb of seconds since 1/1/70 */
#define timet2nix(a) (a)	/* convert local time_t to nb of sec since 1/1/70 */
#define logerror(a) { logline(1,a); return BBSFAIL; }

/* prototypes from sysdep.c */
int sysdep_carrier(void ); /* 0 == lost */
void sysdep_hangup(void );
int sysdep_getchar(unsigned char *);
void sysdep_flushin(void);
void sysdep_putchar(unsigned char);
int z_download(char *s);
int z_upload(char *s);
int sysdep_dupeio(char *s);
/* end of sysdep.h */