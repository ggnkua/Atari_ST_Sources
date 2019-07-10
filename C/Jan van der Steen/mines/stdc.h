#ifdef __STDC__
#	define	PROTO(s) s
#else
#	define	PROTO(s) ()
#endif


/* mines.c */
int		alert		PROTO(( int special , char *line1 , char *line2 , char *line3 , char *line4 , char *line5 , char *but1 , char *but2 , char *but3 , int defbut ));
void		mouse_on	PROTO(( void ));
void		mouse_off	PROTO(( void ));
void		RscWarning	PROTO(( char *resourcefile ));
void		RezWarning	PROTO(( void ));
void		glob_init	PROTO(( void ));
void		ObjPosition	PROTO(( void ));
void		ObjPut		PROTO(( int object ));
void		ObjGet		PROTO(( void ));
void		SetText		PROTO(( int object , char *s ));
void		GetText		PROTO(( int object , char *s ));
void		Settings	PROTO(( void ));
void		game_init	PROTO(( void ));
void		my_init		PROTO(( void ));
void		my_exit		PROTO(( int error ));
void		main		PROTO(( void ));
void		Message		PROTO(( char *s ));
void		message		PROTO(( char *s ));
void		highscore	PROTO(( void ));
void		howmany		PROTO(( int i , int j ));
int		Howmany		PROTO(( int i , int j ));
int		onboard		PROTO(( int *i , int *j ));
int		reachable	PROTO(( int i , int j ));
void		check		PROTO(( int i , int j , int but, int state ));
void		keyboard	PROTO(( int key ));
void		putshape	PROTO(( int i , int j , int which ));
void		putflash	PROTO(( int i , int j ));
void		puthow		PROTO(( void ));
long		permute		PROTO(( void ));
int		makepath	PROTO(( int i, int j));
void		drawboard	PROTO(( void ));
void		newboard	PROTO(( void ));
void		showpos		PROTO(( void ));

void		fix_objects	PROTO(( void ));
#undef PROTO
