/* gemma.slb library definitions */

# ifndef GEMMA_STRUCT_H
# define GEMMA_STRUCT_H

# define GEMMA_VERSION	0x0107L

# define GEM_CTRL	0x00
# define CALL_AES	0x01
# define WD_FIELD	0x02
# define WD_CREATE	0x03
# define WD_OPEN	0x04
# define WD_FORMDO	0x05
# define WD_CLOSE	0x06
# define WD_DELETE	0x07
# define WD_CENTER	0x08
# define RC_INTERSECT	0x09
# define RSRC_XLOAD	0x0a
# define RSRC_XALLOC	0x0b
# define RSRC_XFREE	0x0c
# define TFORK		0x0d
# define WD_ALERT	0x0e
# define OB_XCHANGE	0x0f
# define RSRC_XGADDR	0x10
# define AP_OPEN	0x11
# define WD_ERROR	0x12
# define WD_DUP		0x13
# define WD_LINK	0x14
# define ENV_GET	0x15
# define ENV_EVAL	0x16
# define ENV_GETARGC	0x17
# define ENV_GETARGV	0x18
# define AP_TOP		0x19
# define WD_HANDLER	0x1a
# define WD_UNLINK	0x1b
# define WD_RETURN	0x1c
# define FT_FIX		0x1d
# define AV_DIR_UPD	0x1e
# define AV_XVIEW	0x1f
# define AV_HELP	0x20
# define MN_XPOP	0x25
# define FSELINPUT	0x26
# define AP_CLOSE	0x27
# define NET_URL	0x28

typedef struct {
	long 	aesparams[6];
	short	control[16];
	short	global[16];
	short	int_in[16];
	short	int_out[16];
	long	addr_in[16];
	long	addr_out[16];
	long	vdiparams[5];
	short	contrl[12];
	short	intin[128];
	short	ptsin[128];
	short	intout[128];
	short	ptsout[128];
	short	vwk_handle;
	long	vwk_colors;
} GEM_ARRAY;

typedef struct windial WINDIAL;

struct windial {
	OBJECT 	*wb_treeptr;
	char	*wb_title;
	OBJECT	*wb_icontree;

	short	wb_box;
	short	wb_icon;
	short	wb_handle;
	short	wb_gadgets;
	short	wb_ontop;

	short	wb_desk_x;
	short	wb_desk_y;
	short	wb_desk_w;
	short	wb_desk_h;
	short	wb_work_x;
	short	wb_work_y;
	short	wb_work_w;
	short	wb_work_h;
	short	wb_border_x;
	short	wb_border_y;
	short	wb_border_w;
	short	wb_border_h;
	short	wb_center_x;
	short	wb_center_y;
	short	wb_rclist_x;
	short	wb_rclist_y;
	short	wb_rclist_w;
	short	wb_rclist_h;
	short	wb_rcdraw_x;
	short	wb_rcdraw_y;
	short	wb_rcdraw_w;
	short	wb_rcdraw_h;

	short	wb_start_x;
	short	wb_start_y;
	short	wb_mouse_x;
	short	wb_mouse_y;
	short	wb_object;
	short	wb_key;
	short	wb_startob;
	short	wb_edindex;
	short	wb_fieldinit;
	short	wb_aesmessage[8];

# define WD_MSGVEC	0
# define WD_KEYVEC	1
# define WD_BUTVEC	2
# define WD_RC1VEC	3
# define WD_RC2VEC	4
# define WD_TIMVEC	5

	long	wb_exthandler;
	long	wb_extstack;
	long	wb_keyhandler;
	long	wb_keystack;
	long	wb_buthandler;
	long	wb_butstack;
	long	wb_rc1handler;
	long	wb_rc1stack;
	long	wb_rc2handler;
	long	wb_rc2stack;
	long	wb_timhandler;
	long	wb_timstack;

	short	wb_eventmask;
	short	wb_bclicks;
	short	wb_bmask;
	short	wb_bstate;
	short	wb_m1flag;
	short	wb_m1x;
	short	wb_m1y;
	short	wb_m1w;
	short	wb_m1h;
	short	wb_m2flag;
	short	wb_m2x;
	short	wb_m2y;
	short	wb_m2w;
	short	wb_m2h;
	long	wb_timer;

	long	wb_magic;
	WINDIAL	*wb_prev;
	WINDIAL	*wb_next;
	short	wb_autofree;
	short	wb_iconified;

	long	scratch0[16];
	long	scratch1[16];
	long	scratch2[16];
	long	scratch3[16];
	long	scratch4[16];
	long	scratch5[16];
};

# endif

/* EOF */
