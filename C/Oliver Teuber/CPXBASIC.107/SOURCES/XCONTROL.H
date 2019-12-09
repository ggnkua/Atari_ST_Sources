#ifndef ___XCONTROL_H___
#define ___XCONTROL_H___

typedef struct
{
	WORD x,y;
	WORD buttons;
	WORD kstate;
} MRETS;

typedef struct
{
	WORD		handle;			/* Aus graf_handle()-Aufruf							*/
	WORD		booting;		/* !=0 -> Initialisierung/Bootvorgang				*/
	WORD		reserved;
	WORD		SkipRshFix;		/* !=0 -> Resourcekoordinaten bereits transformiert	*/

	VOID		*reserved1;
	VOID		*reserved2;

	VOID	CDECL	(*rsh_fix)(	WORD num_objs,
	    WORD num_first,
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
	    VOID /*struct foobar*/ *rs_imdope);

	VOID	CDECL	(*rsh_obfix)( OBJECT *tree, WORD curob );

	WORD	CDECL	(*Popup)(	BYTE *items[],
	    WORD num_items,
	    WORD default_item,
	    WORD font_size,
	    GRECT *button,
	    GRECT *world);

	VOID	CDECL	(*Sl_size)(	OBJECT *tree,
	    WORD base,
	    WORD slider,
	    WORD num_items,
	    WORD visible,
	    WORD direction,
	    WORD min_size);

	VOID	CDECL	(*Sl_x)(	OBJECT *tree,
	    WORD base,
	    WORD slider,
	    WORD value,
	    WORD num_min,
	    WORD num_max,
	    VOID (*foo)(VOID));

	VOID	CDECL	(*Sl_y)(	OBJECT *tree,
	    WORD base,
	    WORD slider,
	    WORD value,
	    WORD num_min,
	    WORD num_max,
	    VOID (*foo)(VOID));

	VOID	CDECL	(*Sl_arrow)(OBJECT *tree,
	    WORD base,
	    WORD slider,
	    WORD obj,
	    WORD inc,
	    WORD min,
	    WORD max,
	    WORD *numvar,
	    WORD direction,
	    VOID (*foo)(VOID));

	VOID	CDECL	(*Sl_dragx)(OBJECT *tree,
	    WORD base,
	    WORD slider,
	    WORD min,
	    WORD max,
	    WORD *numvar,
	    VOID (*foo)(VOID));

	VOID	CDECL	(*Sl_dragy)(OBJECT *tree,
	    WORD base,
	    WORD slider,
	    WORD min,
	    WORD max,
	    WORD *numvar,
	    VOID (*foo)(VOID));

	VOID	CDECL	(*Xform_do)(OBJECT *tree,
	    WORD start_field,
	    WORD *puntmsg);

	GRECT	*CDECL	(*GetFirstRect)( GRECT *prect );
	GRECT	*CDECL	(*GetNextRect)( VOID );

	VOID	CDECL	(*Set_Evnt_Mask)(WORD mask,
	    MOBLK *m1,
	    MOBLK *m2,
	    LONG time);

	WORD	CDECL	(*XGen_Alert)(WORD id);
	WORD	CDECL	(*CPX_Save)(VOID *ptr, LONG num);
	VOID	*CDECL	(*Get_Buffer)(VOID);
	WORD	CDECL	(*getcookie)(LONG cookie, LONG *p_value);

	WORD	Country_Code;

	VOID	CDECL	(*MFsave)(WORD saveit, MFORM *mf);
} XCPB;


typedef struct
{
	WORD CDECL (*cpx_call)  (GRECT      *work);
	VOID CDECL (*cpx_draw)  (GRECT      *clip);
	VOID CDECL (*cpx_wmove) (GRECT      *work);
	VOID CDECL (*cpx_timer) (WORD       *event);
	VOID CDECL (*cpx_key)   (WORD        kbstate,
	    WORD        key,
	    WORD       *event);
	VOID CDECL (*cpx_button)(MRETS		*mrets,
	    WORD        nclicks,
	    WORD       *event);
	VOID CDECL (*cpx_m1)    (MRETS		*mrets,
	    WORD       *event);
	VOID CDECL (*cpx_m2)    (MRETS		*mrets,
	    WORD       *event);
	WORD CDECL (*cpx_hook)	(WORD        event,
	    WORD       *msgbuff,
	    MRETS		*mrets,
	    WORD       *key,
	    WORD       *nclicks);
	VOID CDECL (*cpx_close) (WORD        app_term);
} CPX_INFO;

typedef struct
{
	unsigned  magic;
	struct
	{
		unsigned reserved	:13;
		unsigned resident	:1;
		unsigned bootinit	:1;
		unsigned setonly	:1;
	} flags;
	long cpx_id;
	unsigned cpx_version;
	char i_text[14];
	unsigned sm_icon[48];
	unsigned i_color;
	char title_text[18];
	unsigned t_color;
	char buffer[64];
	char reserved[306];
}
	CPXHEAD;    

#define VERTICAL		0
#define HORIZONTAL		1

#define SAVE_DEFAULTS	0
#define MEM_ERR			1
#define FILE_ERR		2
#define FILE_NOT_FOUND	3

#define MFSAVE			1
#define MFRESTORE		0

#endifÿÿ