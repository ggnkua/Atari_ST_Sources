/************************************************************************/
/*																		*/
/*	CPX main include file...											*/
/*																		*/
/************************************************************************/

struct foobar
{
	WORD	dummy;
	WORD	*image;
};

typedef struct
{
	WORD magic;
	struct
	{
		unsigned	reserved	:13;
		unsigned	resident	:1;
		unsigned	boot_init	:1;
		unsigned	set_only	:1;
	} flags;
	char cpx_id[4];
	WORD cpx_version;
	char icon_name[14];
	LONG icon_data[24];
	WORD icon_info;
	char cpx_name[14];
	WORD obj_state;
	BYTE reserve[370];
} CPX_HEADER;

typedef struct
{
	WORD flags;
	WORD x,y,w,h;
} MOUSE_EVENT;

typedef struct
{
	WORD x,y;
	WORD buttons;
	WORD kstate;
} MRETS;

typedef struct
{
	WORD cdecl (*cpx_call)	(GRECT *work);
	VOID cdecl (*cpx_draw)	(GRECT *clip);
	VOID cdecl (*cpx_wmove) (GRECT *work);
	VOID cdecl (*cpx_timer) (WORD *event);
	VOID cdecl (*cpx_key)	(WORD kbstate, WORD key, WORD *event);
	VOID cdecl (*cpx_button)(MRETS *mrets, WORD nclicks, WORD *event);
	VOID cdecl (*cpx_m1)	(MRETS *mtres, WORD *event);
	VOID cdecl (*cpx_m2)	(MRETS *mrets, WORD *event);
	VOID cdecl (*cpx_evhook)(WORD event, WORD *msbuff, MRETS *mrets,
							 WORD *key, WORD *nclicks);
	VOID cdecl (*cpx_close) (WORD app_term);
} CPX_INFO;

typedef struct
{
	VOID *text_start;
	LONG text_len;
	VOID *data_start;
	LONG data_len;
	VOID *bss_start;
	LONG bss_len;
} CPX_SEGMENTS;

typedef struct cpxblock
{
	char filename[14];
	WORD ok;
	WORD valid;
	CPX_SEGMENTS *segments;
	struct cpxblock *next;
	CPX_HEADER header;
} CPX_BLOCK;

typedef struct
{
	WORD handle;
	WORD booting;
	WORD reserved;
	WORD rsc_init;

	CPX_BLOCK	*cdecl (*get_rootblock)(VOID);
	WORD cdecl (*write_header)(CPX_BLOCK *header);

	VOID cdecl (*rsh_fix) (WORD num_obs, WORD num_frstr, WORD num_frimg,
		WORD num_tree, OBJECT *rs_object, TEDINFO *rs_tedinfo, BYTE *rs_strings[],
		ICONBLK *rs_iconblk, BITBLK *rs_bitblk, LONG *rs_frstr, LONG *rs_frimg,
		LONG *rs_trindex, struct foobar *rs_imdope);
	VOID cdecl (*rsh_obfix)(OBJECT *tree, WORD ob_index);
	WORD cdecl (*Popup) (char *entries[], WORD num_items,
		WORD checked_item, WORD font,GRECT *button_xywh,GRECT *window_wxwh);
	VOID cdecl (*Sl_size)(OBJECT *tree, WORD box_index, WORD slider_index,
		WORD total, WORD seen, WORD v_h_flag, WORD min_size);
	VOID cdecl (*Sl_x) (OBJECT *tree, WORD box_index, WORD slider_index,
		WORD slider_pos, WORD start, WORD total, VOID (*function)());
	VOID cdecl (*Sl_y) (OBJECT *tree, WORD box_index, WORD slider_index,
		WORD slider_pos, WORD start, WORD total, VOID (*function)());
	VOID cdecl (*Sl_arrow) (OBJECT *tree, WORD box_index, WORD slider_index,
		WORD button_index, WORD increment, WORD start, WORD total, WORD *slider_pos,
		WORD v_h_flag, VOID (*function)());
	VOID cdecl (*Sl_dragx) (OBJECT *tree, WORD box_index, WORD slider_index,
		WORD start, WORD total, WORD *slider_pos, VOID (*function)());
	VOID cdecl (*Sl_dragy) (OBJECT *tree, WORD box_index, WORD slider_index,
		WORD start, WORD total, WORD *slider_pos, VOID (*function)());
	WORD cdecl (*Xform_do)(OBJECT *tree, WORD start_obj, WORD *msg_buffer);
	GRECT *cdecl (*GetFirstRec)(GRECT *object_xywh);
	GRECT *cdecl (*GetNextRec)(VOID);
	VOID  *cdecl (*Set_Evnt_Mask)(WORD ev_flags,MOUSE_EVENT *mm1,MOUSE_EVENT *mm2,
		LONG timer);
	WORD cdecl (*XGen_Alert)(WORD number);
	WORD cdecl (*CPX_Save)(VOID *parameter, LONG length);
	BYTE *cdecl (*Get_Buffer)(VOID);
	WORD cdecl (*getcookie)(LONG cookie, LONG *version);
	WORD dummy;
	VOID cdecl (*MFsave)(WORD saveit, MFORM *mf);
} CPX_PARAMS;



/* Object structure macros, useful in dealing with forms
 * ================================================================
 * `tree' must be an OBJECT *
 */
#define SPECIAL 	0x40 /* user defined object state */

#define ObNext(obj) 	( tree[(obj)].ob_next )
#define ObHead(obj) 	( tree[(obj)].ob_head )
#define ObTail(obj) 	( tree[(obj)].ob_tail )
#define ObFlags(obj)	( tree[(obj)].ob_flags )
#define ObState(obj)	( tree[(obj)].ob_state )
#define ObSpec(obj) 	( tree[(obj)].ob_spec )
#define TedText(obj)	( tree[(obj)].ob_spec.tedinfo->te_ptext )
#define TedTemp(obj)	( tree[(obj)].ob_spec.tedinfo->te_ptmplt )
#define TedLen(obj) 	( tree[(obj)].ob_spec.tedinfo->te_txtlen )
#define TedTempLen(obj) ( tree[(obj)].tedinfo.ob_spec->te_tmplen )

#define TedJust( obj )	( tree[(obj)].ob_spec.tedinfo->te_just )
#define TedFont( obj )	( tree[(obj)].ob_spec.tedinfo->te_font )
#define TedColor( obj ) ( tree[(obj)].ob_spec.tedinfo->te_color )

#define ObString(obj)	( tree[(obj)].ob_spec.free_string )
#define ObX(obj)		( tree[(obj)].ob_x )
#define ObY(obj)		( tree[(obj)].ob_y )
#define ObW(obj)		( tree[(obj)].ob_width )
#define ObH(obj)		( tree[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)(&(tree[(obj)].ob_x)) )
#define ObRectP(obj) 	( (GRECT *)(&(tree[(obj)].ob_x)) )


#define Set_tree(obj)		( rsrc_gaddr(R_TREE,(obj),&tree) )
#define Set_alert(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )
#define Set_button(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )

#define IsSelected(obj) 		( ObState(obj) & SELECTED )
#define IsEditable(obj) 		( ObFlags(obj) & EDITABLE )
#define IsSpecial(obj)			( ObState(obj) & SPECIAL  )
#define ActiveTree( newtree )	( tree = newtree )
#define IsDisabled(obj) 		( ObState(obj) & DISABLED )
#define IsActiveTree( newtree ) ( tree == newtree )

/* macros ok when object is not on screen
 */
#define HideObj(obj)		( ObFlags(obj) |= HIDETREE )
#define ShowObj(obj)		( ObFlags(obj) &= ~HIDETREE )
#define MakeEditable(obj)	( ObFlags(obj) |= EDITABLE )
#define NoEdit(obj) 		( ObFlags(obj) &= ~EDITABLE )
#define Select(obj) 		( ObState(obj) |= SELECTED )
#define Deselect(obj)		( ObState(obj) &= ~SELECTED )
#define Disable(obj)		( ObState(obj) |= DISABLED )
#define Enable(obj) 		( ObState(obj) &= ~DISABLED )
#define MarkObj(obj)		( ObState(obj) |= SPECIAL  )
#define UnmarkObj(obj)		( ObState(obj) &= ~SPECIAL	)
#define SetNormal(obj)		( ObState(obj) = NORMAL    )
#define MakeDefault(obj)	( ObFlags(obj) |= DEFAULT )
#define NoDefault(obj)		( ObFlags(obj) &= ~DEFAULT )
#define MakeExit( obj ) 	( ObFlags(obj) |= EXIT )
#define NoExit( obj )		( ObFlags(obj) &= ~EXIT )

#define CrossObj(obj)		( ObState(obj) |= CROSSED )
#define UncrossObj(obj)		( ObState(obj) &= ~CROSSED )


/* Shorthand macro to pass parameters for objc_draw() */
#define PTRS(r) r->g_x, r->g_y, r->g_w, r->g_h
#define ELTS(r) r.g_x, r.g_y, r.g_w, r.g_h


#define VERTICAL	0
#define HORIZONTAL	1
#define NULLFUNC	( void(*)())0L

#define SAVE_DEFAULTS	0
#define MEM_ERR 	1
#define FILE_ERR	2
#define FILE_NOT_FOUND	3

#define MFSAVE 1
#define MFRESTORE 0

/* Additional define from XFORM_DO() */
#define CT_KEY		53


/**********************************************************************/
