#include "firetext.h"
/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
char         system_dir[MAXSTRING], msgbuffer[MAXMSGSIZE],*arealist;
VARIABLES    tempvar;
HDRINFO      header;
AREADATA     *areasbbs=NULL,temp_area;
int          *areamnums;
CONFIG       *config=NULL,t_config;
TEXTCONFIG   *textconf,t_textconf;
FILE         *textfile,*msgfile,*hdrfile;

extern short screenx,screeny,screenw,screenh;
extern short work_in[11], work_out[57], ap_id, graf_id, xy[4];
WIN_DIALOG   info_win,register_win,path_win,infotext_win,write_win,convert_win;
WIN_DIALOG   autodate_win,autolist_win;
OBJECT       *menu_tree, *icons;
char         *alerts[MAX_ALERTS];


