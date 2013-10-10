/* wind.c */
void	do_window( int message[] );
void	untopped( int message[] );
void	cycle_window( void );
void	H_slide_window( int message[] );
void	V_slide_window( int message[] );
void	slide_window( int message[] );
void	scroll_left( windowptr thewin, int delta );
void	scroll_right( windowptr thewin, int delta );
void	scroll_up( windowptr thewin, int delta );
void	scroll_down( windowptr thewin, int delta );
void	do_resize( int message[] );
void	do_fullsize( int handle );
windowptr	findwindowptr( int handle );
t_win_coord	*get_info( int no, windowptr thewin, GRECT *rect );
windowptr	new_window( int thekind, char *title, char *info , void (*redraw_proc)(int ,WIN *, GRECT *), int type, int no );
void	dispose_window( windowptr thewin );
void	make_frontwin( windowptr thewin );
