extern int make_dir ( char *path ) ;
extern int remove_dir ( char *path ) ;
extern int get_cd ( char *path ) ;
extern int pwd ( void ) ;
extern int cd ( char *path ) ;

# define SUB_DIR	0x0001	/* general flags : scan_dir_tree()	*/

# define HEX_LIST	0x0100	/* user flags	 : dir_list()		*/
# define NO_TEXT	0x0200

extern char *strlchr ( char *s, char c ) ;

typedef int DIR_PROC ( DTA *dta, int n, unsigned flags, void *par ) ;

extern int scan_dir_tree ( char *path, char *wild, unsigned flags,
					   DIR_PROC *dirproc, void *par ) ;
extern int dir_list ( char *path, unsigned flags ) ;
extern int disk_info ( int driveno, ulong *free, ulong *total ) ;
