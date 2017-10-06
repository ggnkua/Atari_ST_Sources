/*  CPX DATA STRUCTURES
 *==========================================================================
 *  XCPB structure is passed TO the CPX
 *  CPXINFO structure pointer is returned FROM the CPX
 *
 *  xcpb structure is initialized in XCONTROL.C
 */

typedef struct {
     short   handle;
     short   booting;
     short   reserved;  
     short   SkipRshFix;

     BYTE    *reserve1;
     BYTE    *reserve2;
     
     void    (*rsh_fix)();
     void    (*rsh_obfix)();
     short   (*Popup)();
     void    (*Sl_size)();
     void    (*Sl_x)();
     void    (*Sl_y)();
     void    (*Sl_arrow)();
     void    (*Sl_dragx)();
     void    (*Sl_dragy)();
     WORD    (*Xform_do)();
     GRECT   *(*GetFirstRect)();
     GRECT   *(*GetNextRect)();
     void    (*Set_Evnt_Mask)();
     BOOLEAN (*XGen_Alert)();
     BOOLEAN (*CPX_Save)();
     BYTE    *(*Get_Buffer)();
     int     (*getcookie)();
     int     Country_Code; 
     void    (*MFsave)();        
} XCPB;



typedef struct {
     BOOLEAN	(*cpx_call)();
     void	(*cpx_draw)();
     void	(*cpx_wmove)();
     void	(*cpx_timer)();
     void	(*cpx_key)();
     void	(*cpx_button)();
     void	(*cpx_m1)();
     void	(*cpx_m2)();
     BOOLEAN	(*cpx_hook)();
     void  	(*cpx_close)();
}CPXINFO;



typedef struct {
	WORD x;
	WORD y;
	WORD buttons;
	WORD kstate;
}MRETS;




/* Object structure macros, useful in dealing with forms
 * ================================================================
 * `tree' must be an OBJECT *
 */
#define SPECIAL		0x40 /* user defined object state */

#define ObNext(obj)	( tree[(obj)].ob_next )
#define ObHead(obj)	( tree[(obj)].ob_head )
#define ObTail(obj)	( tree[(obj)].ob_tail )
#define ObFlags(obj)	( tree[(obj)].ob_flags )
#define ObState(obj)	( tree[(obj)].ob_state )
#define ObSpec(obj)	( tree[(obj)].ob_spec )
#define TedText(obj)	( tree[(obj)].ob_spec->te_ptext )
#define TedTemp(obj)	( tree[(obj)].ob_spec->te_ptmplt )
#define TedLen(obj)	( tree[(obj)].ob_spec->te_txtlen )
#define TedTempLen(obj)	( tree[(obj)].ob_spec->te_tmplen )

#define TedJust( obj )  ( tree[(obj)].ob_spec->te_just )
#define TedFont( obj )  ( tree[(obj)].ob_spec->te_font )
#define TedColor( obj ) ( tree[(obj)].ob_spec->te_color )

#define ObString(obj)	( tree[(obj)].ob_spec.free_string )
#define ObX(obj) 	( tree[(obj)].ob_x )
#define ObY(obj) 	( tree[(obj)].ob_y )
#define ObW(obj) 	( tree[(obj)].ob_width )
#define ObH(obj) 	( tree[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)(&(tree[(obj)].ob_x)) )


#define Set_tree(obj)		( rsrc_gaddr(R_TREE,(obj),&tree) )
#define Set_alert(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )
#define Set_button(num,s)	( rsrc_gaddr(R_STRING,(num),&((OBJECT *)(s)) )

#define IsSelected(obj)		( ObState(obj) & SELECTED )
#define IsEditable(obj)		( ObFlags(obj) & EDITABLE )
#define IsSpecial(obj)		( ObState(obj) & SPECIAL  )
#define ActiveTree( newtree )	( tree = newtree )
#define IsDisabled(obj)		( ObState(obj) & DISABLED )
#define IsActiveTree( newtree ) ( tree == newtree )

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
#define NULLFUNC	( void(*)())0L

#define SAVE_DEFAULTS	0
#define MEM_ERR		1
#define FILE_ERR	2
#define FILE_NOT_FOUND	3

#define MFSAVE 1
#define MFRESTORE 0


/* Additional define from XFORM_DO() */
#define CT_KEY		53
