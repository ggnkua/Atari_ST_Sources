/*  CPX DATA STRUCTURES
 *==========================================================================
 *  XCPB structure is passed TO the CPX
 *  CPXINFO structure pointer is returned FROM the CPX
 *
 *  xcpb structure is initialized in XCONTROL.C
 *
 *	 Angepažt auf TC/PC
 */

typedef struct {
	WORD x;
	WORD y;
	WORD buttons;
	WORD kstate;
}MRETS;

typedef struct foobar
{
	WORD	dummy;
	WORD	*image;
};

typedef struct
{
	WORD		handle;
	WORD		booting;		
	WORD		reserved;  
	WORD		SkipRshFix;
	
	BYTE		*reserve1;
	BYTE		*reserve2;
	
	void cdecl		(*rsh_fix)(WORD num_objs, WORD num_frstr,
							WORD num_frimg, WORD num_tree,
							OBJECT *rs_object, TEDINFO *rs_tedinfo,
							char *rs_strings[], ICONBLK *rs_iconblk,
							BITBLK *rs_bitblk, LONG *rs_frstr,
							LONG *rs_frimg, LONG *rs_index,
							struct foobar *rs_imdope);
	void cdecl		(*rsh_obfix)(OBJECT *tree, WORD curob);
	WORD cdecl		(*Popup)(BYTE *items[], WORD num_items,
							WORD default_item, WORD font_size,
							GRECT *button, GRECT *world);
	void cdecl		(*Sl_size)(OBJECT *tree, WORD base,
							WORD slider, WORD num_items, WORD visible,
							WORD direction, WORD min_size);
	void cdecl		(*Sl_x)(OBJECT *tree, WORD base, WORD slider,
							WORD value, WORD num_min, WORD num_max,
							void (*foo)(void));
	void cdecl		(*Sl_y)(OBJECT *tree, WORD base, WORD slider,
							WORD value, WORD num_min, WORD num_max,
							void (*foo)(void));
	void cdecl		(*Sl_arrow)(OBJECT *tree, WORD base,
							WORD slider, WORD obj, WORD inc, WORD min,
							WORD max, WORD *numvar, WORD direction,
							void (*foo)(void));
	void cdecl		(*Sl_dragx)(OBJECT *tree, WORD base,
							WORD slider, WORD min, WORD max,
							WORD *numvar, void (*foo)(void));
	void cdecl		(*Sl_dragy)(OBJECT *tree, WORD base,
							WORD slider, WORD min, WORD max,
							WORD *numvar, void (*foo)(void));
	WORD cdecl		(*Xform_do)(OBJECT *tree, WORD start_field,
							WORD *puntmsg);
	GRECT * cdecl	(*GetFirstRect)(GRECT *prect);
	GRECT * cdecl	(*GetNextRect)(void);
	void cdecl		(*Set_Evnt_Mask)(WORD mask, MOBLK *ml,
							MOBLK *m2, LONG time);
	WORD cdecl		(*XGen_Alert)(WORD id);
	WORD cdecl		(*CPX_Save)(void *ptr, LONG num);
	void * cdecl	(*Get_Buffer)(void);
	WORD cdecl		(*getcookie)(LONG cookie, LONG *p_value);
	WORD				Country_Code; 
	void cdecl		(*MFsave)(WORD saveit, MFORM *mf);        
} XCPB;



typedef struct
{
	WORD cdecl		(*cpx_call)(GRECT *work);
	void cdecl		(*cpx_draw)(GRECT *clip);
	void cdecl		(*cpx_wmove)(GRECT *work);
	void cdecl		(*cpx_timer)(WORD *event);
	void cdecl		(*cpx_key)(WORD k_state, WORD key, WORD *event);
	void cdecl		(*cpx_button)(MRETS *mrets, WORD *event);
	void cdecl		(*cpx_m1)(MRETS *mrets, WORD *event);
	void cdecl		(*cpx_m2)(MRETS *mrets, WORD *event);
	WORD cdecl		(*cpx_hook)(WORD event, WORD *msg, MRETS *mrets,
							WORD *key, WORD *nclicks);
	void cdecl		(*cpx_close)(WORD flag);
}CPXINFO;







/* Object structure macros, useful in dealing with forms
 * ================================================================
 * `rs_object' must be an OBJECT *
 */
#define SPECIAL		0x40 /* user defined object state */

#define ObNext(obj)	( rs_object[(obj)].ob_next )
#define ObHead(obj)	( rs_object[(obj)].ob_head )
#define ObTail(obj)	( rs_object[(obj)].ob_tail )
#define ObFlags(obj)	( rs_object[(obj)].ob_flags )
#define ObState(obj)	( rs_object[(obj)].ob_state )
#define ObSpec(obj)	( rs_object[(obj)].ob_spec )
#define TedText(obj)	( rs_object[(obj)].ob_spec->te_ptext )
#define TedTemp(obj)	( rs_object[(obj)].ob_spec->te_ptmplt )
#define TedLen(obj)	( rs_object[(obj)].ob_spec->te_txtlen )
#define TedTempLen(obj)	( rs_object[(obj)].ob_spec->te_tmplen )

#define TedJust( obj )  ( rs_object[(obj)].ob_spec->te_just )
#define TedFont( obj )  ( rs_object[(obj)].ob_spec->te_font )
#define TedColor( obj ) ( rs_object[(obj)].ob_spec->te_color )

#define ObString(obj)	( rs_object[(obj)].ob_spec.free_string )
#define ObX(obj) 	( rs_object[(obj)].ob_x )
#define ObY(obj) 	( rs_object[(obj)].ob_y )
#define ObW(obj) 	( rs_object[(obj)].ob_width )
#define ObH(obj) 	( rs_object[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)(&(rs_object[(obj)].ob_x)) )


#define Set_tree(obj)		( rsrc_gaddr(R_TREE,(obj),&rs_object) )
#define Set_alert(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )
#define Set_button(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )

#define IsSelected(obj)		( ObState(obj) & SELECTED )
#define IsEditable(obj)		( ObFlags(obj) & EDITABLE )
#define IsSpecial(obj)		( ObState(obj) & SPECIAL  )
#define ActiveTree( newtree )	( rs_object = newtree )
#define IsDisabled(obj)		( ObState(obj) & DISABLED )
#define IsActiveTree( newtree ) ( rs_object == newtree )

/* macros ok when object is not on screen
 */
#define HideObj(obj)		( ObFlags(obj) |= HIDETREE )
#define ShowObj(obj)		( ObFlags(obj) &= ~HIDETREE )
#define MakeEditable(obj)	( ObFlags(obj) |= EDITABLE )
#define NoEdit(obj)		( ObFlags(obj) &= ~EDITABLE )
#define Select(obj)		( ObState(obj) |= SELECTED )
#define Deselect(obj)		( ObState(obj) &= ~SELECTED )
#define Disable(obj)		( ObState(obj) |= DISABLED )
#define Enable(obj)		( ObState(obj) &= ~DISABLED )
#define MarkObj(obj)		( ObState(obj) |= SPECIAL  )
#define UnmarkObj(obj)		( ObState(obj) &= ~SPECIAL  )
#define SetNormal(obj)		( ObState(obj) = NORMAL	   )
#define MakeDefault(obj)	( ObFlags(obj) |= DEFAULT )
#define NoDefault(obj)		( ObFlags(obj) &= ~DEFAULT )
#define MakeExit( obj )		( ObFlags(obj) |= EXIT )
#define NoExit( obj )		( ObFlags(obj) &= ~EXIT )


/* Shorthand macro to pass parameters for objc_draw() */
#define PTRS(r) r->g_x, r->g_y, r->g_w, r->g_h
#define ELTS(r) r.g_x, r.g_y, r.g_w, r.g_h


#define VERTICAL	0
#define HORIZONTAL	1
#define SAVE_DEFAULTS	0
#define MEM_ERR		1
#define FILE_ERR	2
#define FILE_NOT_FOUND	3

#define MFSAVE 1
#define MFRESTORE 0


/* Additional define from XFORM_DO() */
#define CT_KEY		53
