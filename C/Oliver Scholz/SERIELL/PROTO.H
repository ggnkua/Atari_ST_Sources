/*
 * PROTO.H
 * Prototyp-Header fÅr TT44TT
 * Copyright (c) 1991 by MAXON Computer
 * Autoren: Oliver Scholz & Uwe Hax
 */

VOID clipping(GRECT *rect,WORD mode);
VOID do_output(WORD wind_index);
VOID init_terminal(WORD wind_index);
VOID handle_escape(WORD wind_index,CHAR c);
VOID insert_char(WORD wind_index, CHAR c);
VOID print_char(WORD wind_index, CHAR c);
VOID term_lf(WORD wind_index);
VOID scroll(WORD wind_index, WORD direction);
VOID pos_slider(WORD wind_index, WORD vh_flag);
WORD rc_intersect(GRECT *r1,GRECT *r2);
VOID cursor(WORD wind_index, WORD flag);
VOID init_dial(VOID);
VOID into_dial(CONF_RS *port, OLDSET *indices);
VOID read_port(WORD index);
VOID get_baud_string(WORD rate_index, CHAR *buf);
VOID write_port(WORD index);
VOID main(VOID);
VOID open_vwork(WORD phys_handle);
VOID get_addresses(VOID);
WORD open_window(WORD i);
VOID wind_snap(WORD *x,WORD *y,WORD *w,WORD *h);
VOID events(VOID);
WORD mn_selected(WORD *mesg_buff);
VOID wm_topped(WORD whandle);
VOID wm_redraw(WORD whandle,
               WORD x,WORD y,WORD w,WORD h);
VOID wm_moved(WORD *mesg_buff);
VOID wm_fulled(WORD *mesg_buff);
VOID wm_arrowed(WORD *mesg_buff);
VOID wm_vslid(WORD *mesg_buff);
VOID wm_hslid(WORD *mesg_buff);
VOID wm_closed(WORD whandle);
VOID wm_sized(WORD *mesg_buff);
VOID wind_max(WORD *x,WORD *y,WORD *w,WORD *h);
VOID clipping(GRECT *rect,WORD mode);
WORD rc_intersect(GRECT *r1,GRECT *r2);
VOID show_info(VOID);
VOID ienable(WORD flag);
VOID draw_icon(WORD iconidx);
WORD fileselect (CHAR *inpath, CHAR *insel,
                 WORD *exbutton, CHAR *label);
VOID loadinf(CHAR *pfad,WORD init);
VOID saveinf(CHAR *pfad);
VOID get_tos_version(VOID);
VOID wind_info(WORD device);
VOID scroll(WORD wind_index,WORD direction);
VOID get_baud_string(WORD rate_index, CHAR *buf);
VOID size_slider(WORD wind_handle);
VOID init_ports(CONF_RS port[4]);
WORD conf_port(CONF_RS *port);
VOID pos_slider(WORD wind_index, WORD vh_flag);
VOID do_output(WORD wind_index);
VOID init_terminal(WORD wind_index);
VOID read_port(WORD device);
VOID write_port(WORD device);
WORD get_index(WORD whandle);
VOID adjust(WORD whandle);
VOID update_cursor(WORD wind_index);
VOID update_pos(WORD wind_index);
LONG _bconmap(WORD devno);
OBJECT *get_traddr(WORD tree_index);
