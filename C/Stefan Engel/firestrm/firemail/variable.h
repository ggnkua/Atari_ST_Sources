/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
extern char         system_dir[MAXSTRING], msgbuffer[MAXMSGSIZE],*arealist;
extern VARIABLES    tempvar;
extern MIME         mime;
extern HDRINFO      header;
extern AREADATA     *routedata1,*routedata2,*areasbbs,temp_area;
extern int          *areamnums;
extern USERDATA     *userdata,temp_user;
extern CONFIG       config,t_config;
extern FILE         *internetfile,*msgfile,*hdrfile;

extern short screenx,screeny,screenw,screenh;
extern short        work_in[11], work_out[57], ap_id, graf_id, xy[4];
extern WIN_DIALOG   info_win,register_win,path_win,user_win,adduser_win,mailconv_win,route_win,listroute_win;
extern OBJECT       *menu_tree, *icons;
extern char         *alerts[MAX_ALERTS];
