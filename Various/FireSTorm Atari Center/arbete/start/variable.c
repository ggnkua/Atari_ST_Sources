#include "firemail.h"
/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
char         system_dir[MAXSTRING], msgbuffer[MAXMSGSIZE],*arealist;
VARIABLES    tempvar;
MIME         mime;
HDRINFO      header;
AREADATA     *routedata1=NULL,*routedata2=NULL,*areasbbs=NULL,temp_area;
USERDATA     *userdata=NULL,temp_user;
CONFIG       *config=NULL,t_config;
FILE         *internetfile,*msgfile,*hdrfile;

extern short screenx,screeny,screenw,screenh;
short        work_in[11], work_out[57], ap_id, graf_id, xy[4];
WIN_DIALOG   info_win,register_win,path_win,user_win,adduser_win,mailconv_win,route_win,listroute_win;
OBJECT       *menu_tree, *icons;
char         *alerts[MAX_ALERTS];


