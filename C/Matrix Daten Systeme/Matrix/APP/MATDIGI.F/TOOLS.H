# define STATUSline	21
# define SetCrs(y)		printf ( "\033Y%c ", ' ' + (y) )
# define StatusLine()	printf ( "\033Y%c \033K", ' ' + STATUSline )

extern char dotline[] ;

extern unsigned get_cmdin_char ( void ) ;
extern bool get_cmdin_stat ( void ) ;
extern bool AnyShiftPressed ( void ) ;

extern bool GetLong ( char *name, long *var, long defval ) ;
extern bool GetInt ( char *name, int *var, int defval ) ;
extern bool GetUInt ( char *name, unsigned *var, unsigned defval ) ;
extern bool GetUChar ( char *name, unsigned char *var, unsigned char defval ) ;

extern int  GetString ( char *prompt, char *string ) ;
extern bool ToggleSwitch ( char *prompt, bool *b ) ;

extern void Help ( char **table ) ;
extern bool More ( void ) ;
extern bool Continue ( bool *continuous ) ;
extern bool SkipInput ( void ) ;
extern void DumpBuffer ( unsigned char *buffer, long size ) ;



