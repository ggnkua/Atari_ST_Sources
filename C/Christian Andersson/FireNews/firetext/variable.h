/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
extern char         system_dir[MAXSTRING], msgbuffer[MAXMSGSIZE],*arealist;
extern VARIABLES    tempvar;
extern HDRINFO      header;
extern AREADATA     *areasbbs,temp_area;
extern int          *areamnums;
extern CONFIG       *config,t_config;
extern TEXTCONFIG   t_textconf;
extern FILE         *textfile,*msgfile,*hdrfile;

extern short        screenx,screeny,screenw,screenh;
extern short        work_in[11], work_out[57], ap_id, graf_id, xy[4];
extern WIN_DIALOG   info_win,register_win,path_win,infotext_win,write_win,convert_win;
extern WIN_DIALOG   autodate_win,autolist_win;
extern OBJECT       *menu_tree, *icons;
extern char         *alerts[MAX_ALERTS];
