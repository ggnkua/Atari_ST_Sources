/***********************************************/
/* Datei: XCONTROL.H                           */
/* ------------------------------------------- */
/* (C) 1990 by MAXON Computer                  */
/* Autoren: Uwe Hax & Oliver Scholz            */
/* Header-Datei fÅr die Entwicklung eigener    */
/* CPX-Module                                  */
/***********************************************/


/* Header eines CPX-Moduls --------------------*/

typedef struct 
{
  WORD      magic;
  struct 
  {
    unsigned reserved:  13;
    unsigned resident:  1;
    unsigned boot_init: 1;
    unsigned set_only:  1;
  } flags;
  char      cpx_id[4];
  WORD      cpx_version;
  char      icon_name[14];
  LONG      icon_data[24];
  WORD      icon_info;
  char      cpx_name[18];
  WORD      obj_state;
  BYTE      reserved[370];
} CPX_HEADER;


/* öbergabestruktur fÅr Maus-Ereignisse -------*/

typedef struct 
{  
  WORD      flags;
  WORD      x,y,w,h;
} MOUSE_EVENT; 


/* Ergebnisstruktur fÅr Maus-Ereignisse -------*/

typedef struct
{
  WORD      mx,my;
  WORD      mbutton;
  WORD      kbstate;
} MOUSE_RET;


/* Definition der Funktionen zur Ereignis-
   Behandlung ---------------------------------*/

typedef struct
{
  WORD cdecl (*cpx_call)(GRECT *work);
  VOID cdecl (*cpx_draw)(GRECT *clip);
  VOID cdecl (*cpx_wmove)(GRECT *work);
  VOID cdecl (*cpx_timer)(WORD *event);
  VOID cdecl (*cpx_key)(WORD kbstate,
                        WORD key,
                        WORD *event);
  VOID cdecl (*cpx_button)(MOUSE_RET *mrets,
                        WORD nclicks,
                        WORD *event);
  VOID cdecl (*cpx_m1)(MOUSE_RET *mrets,
                        WORD *event);
  VOID cdecl (*cpx_m2)(MOUSE_RET *mrets,
                        WORD *event);
  WORD cdecl (*cpx_evhook)(WORD event,
                        WORD *msgbuff, 
                        MOUSE_RET *mrets,
                        WORD *key, 
                        WORD *nclicks);
  VOID cdecl (*cpx_close)(WORD app_term);
} CPX_INFO;


/* interne Struktur zur Verwaltung residenter
   CPX-Module ---------------------------------*/

typedef struct
{
  VOID *text_start;
  LONG text_len;
  VOID *data_start;
  LONG data_len;
  VOID *bss_start;
  LONG bss_len;
} CPX_SEGMENTS;


/* interne Struktur zum Speichern der Header --*/

typedef struct cpxblock
{ 
  char      filename[14];
  WORD      ok;
  WORD      valid;
  CPX_SEGMENTS  *segments;
  struct cpxblock *next; 
  CPX_HEADER header;
} CPX_BLOCK;


/* vom Kontrollfeld zur VerfÅgung gestellte 
   Funktionen ---------------------------------*/

typedef struct 
{ 
  WORD      vdi_handle;
  WORD      booting;
  WORD      reserved;
  WORD      rsc_init;
  CPX_BLOCK * cdecl (*get_rootblock)(VOID);
  WORD cdecl (*write_header)(CPX_BLOCK *header);
  VOID cdecl (*do_resource)(WORD num_obs, 
                            WORD num_frstr, 
                            WORD num_frimg, 
                            WORD num_tree, 
                            OBJECT *rs_object, 
                            TEDINFO *rs_tedinfo, 
                            BYTE *rs_strings[], 
                            ICONBLK *rs_iconblk, 
                            BITBLK *rs_bitblk, 
                            LONG *rs_frstr, 
                            LONG *rs_frimg, 
                            LONG *rs_trindex, 
                            struct foobar
                                   *rs_imdope);
  VOID cdecl (*objc_adjust)(OBJECT *tree, 
                            WORD ob_index);
  WORD cdecl (*do_pulldown)(char *entries[],
                            WORD num_items, 
                            WORD checked_item, 
                            WORD font, 
                            GRECT *button_xywh, 
                            GRECT *window_xywh);
  VOID cdecl (*size_slider)(OBJECT *tree,
                            WORD box_index, 
                            WORD slider_index, 
                            WORD total, 
                            WORD seen, 
                            WORD v_h_flag, 
                            WORD min_size);
  VOID cdecl (*pos_hslider)(OBJECT *tree,
                            WORD box_index, 
                            WORD slider_index, 
                            WORD slider_pos, 
                            WORD start, 
                            WORD total, 
                            VOID (*function)());
  VOID cdecl (*pos_vslider)(OBJECT *tree,
                            WORD box_index,
                            WORD slider_index, 
                            WORD slider_pos,
                            WORD start, 
                            WORD total, 
                            VOID (*function)());
  VOID cdecl (*inc_slider)(OBJECT *tree,
                            WORD box_index, 
                            WORD slider_index, 
                            WORD button_index, 
                            WORD increment, 
                            WORD start, 
                            WORD total,
                            WORD *slider_pos, 
                            WORD v_h_flag, 
                            VOID (*function)());
  VOID cdecl (*move_hslider)(OBJECT *tree, 
                            WORD box_index,
                            WORD slider_index, 
                            WORD start, 
                            WORD total,
                            WORD *slider_pos,
                            VOID (*function)());
  VOID cdecl (*move_vslider)(OBJECT *tree, 
                            WORD box_index, 
                            WORD slider_index, 
                            WORD start, 
                            WORD total, 
                            WORD *slider_pos, 
                            VOID (*function)());
  WORD cdecl (*do_form)(OBJECT *tree, 
                            WORD start_obj,
                            WORD *msg_buffer);
  GRECT * cdecl (*rci_first)(GRECT *object_xywh);
  GRECT * cdecl (*rci_next)(VOID);
  VOID cdecl (*multi)(WORD ev_flags, 
                            MOUSE_EVENT *mm1, 
                            MOUSE_EVENT *mm2, 
                            LONG timer);
  WORD cdecl (*alert)(WORD number);
  WORD cdecl (*write_config)(VOID *parameter, 
                            LONG length);
  BYTE * cdecl (*get_resarea)(VOID);
  WORD cdecl (*find_cookie)(LONG cookie, 
                            LONG *version);
  WORD dummy;
  VOID cdecl (*copy_bltparm)(WORD dir, 
                            VOID *buffer);
} CPX_PARAMS;



