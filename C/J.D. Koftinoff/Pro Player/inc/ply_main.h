
#ifndef __PLY_MAIN_H
#define __PLY_MAIN_H

/* ply_main.c */


void	auto_play(void);
void	kill_songs(void);
void	init(void);
void	get_cfg(void);
Boolean exist( char *file );
Boolean set_exists( int set_num );
void	get_set( int set_num );
void	build_set(void);

Boolean	LoadSong( ushort i );
void KillSong( ushort i );

void	load_songs(void);
Boolean load_exclusive( SONG *song, SONG *excl, char *s );
void show_set( int stat );
void goto_mode0( unsigned int i);
void goto_mode1( unsigned int i);
void goto_mode2( unsigned int i);
void put_song( unsigned int i );
void	show_titles(void);
void	show_help(void);
Boolean	show_lyrics(void);
Boolean	play_song(void);
Boolean dispatch( SONG *song );
Boolean master( int mode );
Boolean disk_error( DiskErr type, char *file );
void	wait_for_play(void);
void	show_free_mem(void);
void	update_watch(void);
void	init_watch(void);
void	stop_watch(void);



void	select_next_page();
void	select_prev_page();
Boolean	select_new_page( int p );
static 	Boolean find_page();
Boolean draw_next_char();

#endif

