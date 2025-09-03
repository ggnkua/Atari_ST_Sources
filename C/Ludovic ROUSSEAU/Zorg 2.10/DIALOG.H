/* dialog.c */
t_dialog	*find_dialog( windowptr thewin );
void	my_close_dialog( t_dialog *dialog );
int		my_open_dialog( t_dialog *dialog, int dial_mode, int edit);
void	paraminfo( char *string1, char *string2 );
void	error_msg( int err );
int		selecteur( char *nom, char *filtre, char *info );
int		choix_unit( void );
int		real_time_slide( windowptr thewin, OBJECT *arbre, int pere, int fils, int timer, boolean (*redraw)( windowptr thewin, int pos, int fast ), int sens );
int		rt_init( XEVENT *evt, int events_available );
int		rt_message( XEVENT *event );
int		my_alert( int b_default, int undo, int icon, char *texts, char *buttons );

/* liste des erreurs ZORG */
#define Z_READ_WRITE 1
#define Z_NOT_ENOUGH_MEMORY -39
#define Z_NO_BPB 2
#define Z_NO_MORE_WINDOW 3
#define Z_DMA_RW 4
#define Z_CANT_CREATE_SCRAP 5
#define Z_CLIPBOARD_NOT_INSTALLED 6
#define Z_CLIPBOARD_NOT_INSTALLABLE 7
#define Z_NO_CORRESPONDING_HANDLE 8
#define Z_VIEWER_NOT_LOADED 9
#define Z_HELP_VIEWER_NOT_LOADED 10
#define Z_ERROR_WITH_VIEWER 11
