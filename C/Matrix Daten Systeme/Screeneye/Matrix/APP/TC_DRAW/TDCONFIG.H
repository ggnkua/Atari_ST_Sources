typedef struct
{
	char		in_window ;	/*	'0','1','?'	*/
	char		menu ;		/*	'0', '1'	*/
	char		picpath[STPATHLEN] ;
	RECTangle	work ;
	int			test ;
} CONFIGURATION ;

extern CONFIGURATION configuration ;

extern int load_config ( char *cfg_name ) ;
extern int save_config ( char *cfg_name ) ;
