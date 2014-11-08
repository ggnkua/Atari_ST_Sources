#include "fireicq.h"
/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern short	screenx , screeny , screenw , screenh;
extern short	work_in[ 11 ] , work_out[ 57 ] , ap_id, graf_id, xy[ 4 ];

char			system_dir[ MAXSTRING ] , avserver[ 9 ];
CONFIG			config , t_config;
VARIABLES		tempvar;
LOGG			log;
USERINFO		user , t_user;

WIN_DIALOG		info_win , register_win , main_win , url_win , message_win , chat_win , file_win;
OBJECT			*menu_tree , *icons;
char			*alerts[ MAX_ALERTS ];


