/* xcontrol.h	*/


/* Header eines CPX - Moduls -------------------------------------------- */

typedef struct
{
	WORD		magic;
	struct
	{
		unsigned reserved:	13;
		unsigned resident:	 1;
		unsigned boot_init:	 1;
		unsigned set_only:	 1;
	} flags;
	char		cpx_id[4];
	WORD		cpx_version;
	char		icon_name[14];
	LONG		icon_data[24];
	WORD		icon_info;
	char		cpx_name[18];
	WORD		obj_state;
	BYTE		reserved[370];

} CPX_HEADER;




/*	öbergabestruktur fÅr Maus-Ereignisse --------------------------------- */

typedef struct
{
	WORD		flags;
	WORD		x,y,w,h;
} MOUSE_EVENT;




/* Ergebnisstruktur fÅr Maus-Ereignisse --------------------------------- */

typedef struct
{
	WORD mx, my;
	WORD mbutton;
	WORD kstate;
} MOUSE_RET;




/* Definition der Funktionen zuer Ereignis-Behandlung ------------------- */

typedef struct
{
	WORD cdecl	(*cpx_call)		(GRECT *work);
	void cdecl	(*cpx_draw)		(GRECT *clip);
	void cdecl	(*cpx_wmove)	(GRECT *work);
	void cdecl	(*cpx_timer)	(WORD  *event);
	void cdecl	(*cpx_key)		(WORD  kstate, WORD key, WORD *event);
	void cdecl	(*cpx_button)	(MOUSE_RET *mrets, WORD nclicks, WORD *event);
	void cdecl	(*cpx_m1)		(MOUSE_RET *mrets, WORD *event);
	void cdecl	(*cpx_m2)		(MOUSE_RET *mrets, WORD *event);
	WORD cdecl	(*cpx_evhook)	(WORD  event, WORD *msgbuff, MOUSE_RET *mrest,
										 WORD  *key, WORD nclicks);
	void cdecl	(*cpx_close)	(WORD  app_term);
} CPX_INFO;




/* interne  Strucktur zur Verwaltung residenter CPX-Module -------------- */

typedef struct
{
	void *text_start;
	LONG text_len;
	void *data_start;
	LONG data_len;
	void *bss_start;
	LONG bss_len;
} CPX_SEGMENTS;




/* interne Struktur zum Speichern der Header ---------------------------- */

typedef struct cpxblock
{
	char		filename[14];
	WORD		ok;
	WORD		valid;
	CPX_SEGMENTS	*segments;
	struct cpxblock *next;
	CPX_HEADER header;
} CPX_BLOCK;




/* vom Kontrollfeld zur VerfÅgung gestellte Funktionen ------------------ */

typedef struct
{
	WORD	phys_handle;/* aus graf_handle()-Aufruf von XControl.	*/
							/* Wichtig fÅr v_opnvwk()!						*/
	WORD	booting;		/*	ungl. 0: Initialisierung/Bootvorgang	*/
	WORD	reserved;	/* reserviert										*/
	WORD	rsc_init;	/* ungleich: Resourcekoordinaten bereits	*/
							/*				 transformiert						*/

	CPX_BLOCK * cdecl (*get_rootblock)(void);
	WORD	cdecl (*write_header) (CPX_BLOCK *header);
	
	void	cdecl (*do_resource)
				(	WORD num_objs, WORD num_frstr, WORD num_frimg,
					WORD num_tree, OBJECT *rs_object, TEDINFO *rs_tedinfo,
					char *rs_strings[], ICONBLK *rs_iconblk, BITBLK *rs_bitblk,
					long *rs_frstr, long *rs_frimg, long *rs_trindex,
					struct foobar *rs_imdope);
	
	void	cdecl (*objc_adjust) (OBJECT *tree, WORD ob_index);
	WORD	cdecl	(*do_pulldown)
				(	char *entries[], WORD num_items, WORD checked_item,
					WORD font, GRECT *button_xywh, GRECT *window_xywh);
	
	void	cdecl	(*size_slider)
				(	OBJECT *tree, WORD box_index, WORD slider_index, WORD total,
					WORD seen, WORD v_h_flag, WORD min_size);
	
	void	cdecl (*pos_hslider)
				(	OBJECT *tree, WORD box_index, WORD slider_index,
					WORD slider_pos, WORD start, WORD total, void (*function)());
	
	void	cdecl (*pos_vslider)
				(	OBJECT *tree, WORD box_index, WORD slider_index,
					WORD slider_pos, WORD start, WORD total, void (*function)());

	void	cdecl (*inc_slider)
				(	OBJECT *tree, WORD box_index, WORD slider_index,
					WORD button_index, WORD increment, WORD start, WORD total,
					WORD *slider_pos, WORD v_h_flag,	void (*function)());
	
	void	cdecl (*move_hslider)
				(	OBJECT *tree, WORD box_index, WORD slider_index, WORD start,
					WORD total,	WORD *slider_pos, void (*function)());
	
	void	cdecl (*move_vslider)
				(	OBJECT *tree, WORD box_index, WORD slider_index, WORD start,
					WORD total,	WORD *slider_pos, void (*function)());

	WORD	cdecl	(*do_form)
				(	OBJECT *tree, WORD start_obj, WORD *msg_buffer);
	
	GRECT * cdecl	(*rci_first)	(GRECT *object_xywh);
	GRECT * cdecl	(*rci_next)		(void);

	void	cdecl	(*multi) (WORD ev_flags, MOUSE_EVENT *nm1, MOUSE_EVENT *nm2,
								 LONG timer);
	
	WORD	cdecl	(*alert)	(WORD number);
	WORD	cdecl	(*write_config)		(void *parameter, LONG length);
	BYTE	* cdecl	(*getresarea) (void);
	WORD	cdecl	(*find_cookie)	(LONG cookie, LONG *version);
	
	WORD			Country_Code;
						/* LÑnderkennung, analog zu der im OSHEADER - allerdings	*/
						/* in fester AbhÑnigkeit von der XControl-Version			*/

	void cdecl	(*save_mform) 	(WORD dir, MFORM *buffer);

} CPX_PARAMS;


#define	VERTICAL			0
#define	HORIZONTAL		1

#define	SAVE_DEFAULTS	0
#define	MEM_ERR			1
#define	FILE_ERR			2
#define	FILE_NOT_FOUND	3

#define	MFSAVE			1
#define	MFRESTORE		0

/* zusÑtzliche Definition fÅr Xform_do()	*/
#define	CT_KEY	53
