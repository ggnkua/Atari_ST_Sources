
/* ply_io.c */


Boolean put_text( int x, int y, int col, int mode, char *text );
void put_stat( char *lng, char *shrt );
void ext_display( char *lng, char *shrt );
Boolean	get_action(void);
Boolean	joystick_cmd(void);
Boolean	midi_thru(void);
Boolean light( unsigned short new_stat );
void light_midi( int key, int vel );
Boolean man_light( long key );
void unhang( void);
Boolean	get_kybd(void);
void	clr_line(void);
