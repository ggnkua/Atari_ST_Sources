/*
** GEM AES defines fuer Sozobon C
**
** V 1.0 21-Dec-88 Michael Vishchers ( michaelV%owl.ls5@unido.uucp )
**
** you may use this file as you wish, (i.e. redistribute it, copy it,
** include it, but not make money out of it !!!!!)
** as long as this header remains unchanged.
** please mark any changes in the definitions as such.
**
** many thanks to sybex and the "ATARI ST Profibuch" for their
** wonderful documentation 
*/


typedef struct {
	int		mf_xhot;
	int		mf_yhot;
	int		mf_nplanes;
	int		mf_fg;
	int		mf_bg;
	int		mf_mask[16];
	int		mf_data[16];
} MFORM;


#define K_RSHIFT	0x0001
#define K_LSHIFT	0x0002
#define K_CTRL		0x0004
#define K_ALTERNATE	0x0008


extern int aes();

/**
 **		applications
 **/

#define ap_version	global[0]
#define ap_count	global[1]
#define ap_id		global[2]
#define ap_pprivate	&(global[3])
#define ap_ptree	(* (OBJECT **) (&global[5])) /* i think .. */
#define ap_1resv	(* (void **) (&global[7]))
#define ap_2resv	(* (void **) (&global[9]))
#define ap_3resv	(* (void **) (&global[11]))
#define ap_4resv	(* (void **) (&global[13]))

#define appl_init()\
	aes(10)

#define appl_read(id,length,pbuff)\
	aes(11,id,length,pbuff)

#define appl_write(id,length,pbuff)\
	aes(12,id,length,pbuff)

#define appl_find(pname)\
	aes(13,pname)

#define appl_tplay(pmem,pnum,pscale)\
	aes(14,pnum,pscale,pmem)

#define appl_trecord(mem,count)\
	aes(15,count,mem)

#define appl_exit()\
	aes(19)

/**
 **		events
 **/

/*
 *	message-types
 */

#define	MN_SELECTED	10
#define WM_REDRAW	20
#define WM_TOPPED	21
#define WM_CLOSED	22
#define WM_FULLED	23
#define WM_ARROWED	24
#define WM_HSLID	25
#define WM_VSLID	26
#define WM_SIZED	27
#define WM_MOVED	28
#define WM_NEWTOP	29
#define AC_OPEN		40
#define AC_CLOSE	41

#define evnt_keybd()\
	aes (20)

#define evnt_button(clicks,mask,state,mx,my,button,kstate)\
	aes (21,clicks,mask,state,mx,my,button,kstate)

#define evnt_mouse(flags,x,y,width,height,\
		   mx,my,button,kstate)\
	aes (22,   flags,x,y,width,height,\
		   mx,my,button,kstate)

#define evnt_mesag(pbuff)\
	aes (23,pbuff)

#define evnt_timer(locount,hicount)\
	aes (24,locount,hicount)


#define evnt_multi(flags,bclicks,bmask,bstate,\
		m1flags,m1x,m1y,m1width,m1height,\
		m2flags,m2x,m2y,m2width,m2height,\
		mgpbuff,tlocount,thicount,\
		mox,moy,mobutton,mokstate,kreturn,breturn)\
	aes (25,flags,bclicks,bmask,bstate,\
		m1flags,m1x,m1y,m1width,m1height,\
		m2flags,m2x,m2y,m2width,m2height,\
		tlocount,thicount,mgpbuff,\
		mox,moy,mobutton,mokstate,kreturn,breturn)

#define MU_KEYBD	0x01
#define MU_BUTTON	0x02
#define MU_M1		0x04
#define MU_M2		0x08
#define MU_MESAG	0x10
#define MU_TIMER	0x20
			
#define evnt_dclick(new,getset)\
	aes (26,new,getset)

/**
 **		menues
 **/

#define menu_bar(tree,show)\
	aes (30,show,tree)

#define menu_icheck(tree,item,check)\
	aes (31,item,check,tree)

#define menu_ienable(tree,item,enable)\
	aes (32,item,enable,tree)

#define menu_tnormal(tree,title,normal)\
	aes (33,title,normal,tree)

#define menu_text(tree,item,text)\
	aes (34,item,tree,text)

#define menu_register(rapid,pstring)\
	aes (35,rapid,pstring)

/**
 **		objects
 **/

typedef struct {
	int		ob_next;
	int		ob_head;
	int		ob_tail;
	unsigned int	ob_type;
	unsigned int	ob_flags;
	unsigned int	ob_state;
	void *		ob_spec;
	int		ob_x;
	int		ob_y;
	int		ob_width;
	int		ob_height;
} OBJECT;

/*
 *	ob_type
 */

#define G_BOX		20
#define G_TEXT		21
#define G_BOXTEXT	22
#define G_IMAGE		23
#define G_USERDEF	24
#define G_IBOX		25
#define G_BUTTON	26
#define G_BOXCHAR	27
#define G_STRING	28
#define G_FTEXT		29
#define G_FBOXTEST	30
#define G_ICON		31
#define G_TITLE		32

/*
 *	ob_flags
 */

#define NONE		0x0000
#define SELECTABLE	0x0001
#define DEFAULT		0x0002
#define EXIT		0x0004
#define EDITABLE	0x0008
#define RBUTTON		0x0010
#define LASTOB		0x0020
#define TOUCHEXIT	0x0040
#define HIDETREE	0x0080
#define INDIRECT	0x0100

/*
 *	ob_state
 */

#define SELECTED	0x0001
#define CROSSED		0x0002
#define CHECKED		0x0004
#define DISABLED	0x0008
#define OUTLINED	0x0010
#define SHADOWED	0x0020

/*
 *	object colours
 */

#define WHITE		0
#define BLACK		1
#define RED		2
#define GREEN		3
#define BLUE		4
#define CYAN		5
#define YELLOW		6
#define MAGENTA		7
#define LWHITE		8
#define LBLACK		9
#define LRED		10
#define LGREEN		11
#define LBLUE		12
#define LCYAN		13
#define LYELLOW		14
#define LMAGENTA	15

typedef struct {
	char	*te_ptext;
	char	*te_ptmplt;
	char	*te_pvalid;
	int	te_font;
	int	te_resvd1;
	int	te_just;
	int	te_color;
	int	te_resvd2;
	int	te_thickness;
	int	te_txtlen;
	int	te_tmplen;
} TEDINFO;

typedef struct {
	int	*ib_pmask;
	int	*ib_pdata;
	char	*ib_ptext;
	int	ib_char;
	int	ib_xchar;
	int	ib_ychar;
	int	ib_xicon;
	int	ib_yicon;
	int	ib_wicon;
	int	ib_hicon;
	int	ib_xtext;
	int	ib_ytext;
	int	ib_wtext;
	int	ib_htext;
	int	ib_resvd;
} ICONBLK;

typedef struct {
	int	*bi_pdata;
	int	bi_wb;
	int	bi_hl;
	int	bi_x;
	int	bi_y;
	int	bi_color;
} BITBLK;

typedef struct {
	int	(*ub_code)();
	long	ub_parm;
} USERBLK;

typedef struct {
	OBJECT	*pb_tree;
	int	pb_obj;
	int	pb_prevstate;
	int	pb_prevstate;
	int	pb_x;
	int	pb_y;
	int	pb_w;
	int	pb_h;
	int	pb_xc;
	int	pb_yc;
	int	pb_wc;
	int	pb_hc;
	long	pb_parm;
} PARMBLK;

#define objc_add(tree,parent,child)\
	aes (40,parent,child,tree)

#define objc_delete(tree,object)\
	aes (41,object,tree)

#define objc_draw(tree,startob,depth,xclip,yclip,wclip,hclip)\
	aes (42,startob,depth,xclip,yclip,wclip,hclip,tree)

#define objc_find(tree,startob,depth,mx,mx)\
	aes (43,startob,depth,mx,my,tree)

#define objc_offset(tree,object,xoff,yoff)\
	aes (44,object,tree,xoff,yoff)

#define objc_order(tree,object,newpos)\
	aes (45,object,newpos,tree)

#define objc_edit(tree,object,char,idx,kind,newidx)/* may cause problems ?? */\
	aes (46,object,char,idx,kind,tree,newidx)
/*	aes (46,object,char,idx,kind,tree,&idx) */

#define ED_START	0
#define ED_INIT		1
#define ED_CHAR		2
#define ED_END		3

#define objc_change(tree,object,resvd,xclip,yclip,wclip,hclip,newstate,redraw)\
	aes (47,object,0/*resvd*/,xclip,yclip,wclip,hclip,newstate,redraw,tree)


/**
 **		forms
 **/

#define form_do(tree,startob)\
	aes (50,startob,tree)

#define form_dial(flag,littlx,littly,littlw,littlh,bigx,bigy,bigw,bigh)\
	aes (51,flag,littlx,littly,littlw,littlh,bigx,bigy,bigw,bigh)

#define FMD_START	0
#define FMD_GROW	1
#define FMD_SHRINK	2
#define FMD_FINISH	3

#define form_alert(defbttn,string)\
	aes (52,defbttn,string)

#define FO_NOTE 1
#define FO_WAIT 2
#define FO_STOP 3

#define form_error(enum)\
	aes (53,enum)

#define form_center(tree,x,y,w,h)\
	aes (54,tree,x,y,w,h)

#define form_keybd(tree,object,obnext,char,nxtobject,nxtchar)\
	aes (55,object,obnext,char,tree,nxtobject,nxtchar)

#define form_button(tree,object,clicks,nxtobj)\
	aes (56,object,clicks,tree,nxtobj)

/**
 **		graphics
 **/

#define graf_rubberbox(x,y,minwidth,minheight,lastwidth,lastheight)\
	aes (70,x,y,minwidth,minheight,lastwidth,lastheight)

#define graf_dragbox(width,height,startx,starty,\
		     boundx,boundy,boundw,boundh,\
		     finishx,finishy)\
	aes (71,width,height,startx,starty,\
		     boundx,boundy,boundw,boundh,\
		     finishx,finishy)

#define graf_mbox	graf_movebox

#define	graf_movebox(width,height,sourcex,sourcey,destx,desty)\
	aes(72,width,height,sourcex,sourcey,destx,desty)

#define graf_growbox(stx,sty,stwidth,stheight,\
		     finx,finy,finwidth,finheight)\
	aes (73,stx,sty,stwidth,stheight,\
		     finx,finy,finwidth,finheight)

#define graf_shrinkbox(finx,finy,finwidth,finheight,\
		       stx,sty,stwidth,stheight)\
	aes (74,finx,finy,finwidth,finheight,\
		       stx,sty,stwidth,stheight)

#define graf_watchbox(tree,object,instate,outstate)\
	aes (75,object,instate,outstate,tree)

#define graf_slidebox(ptree,parent,object,vh)\
	aes (76,parent,object,vh,ptree)

#define graf_handle(wchar,hchar,wbox,hbox)\
	aes (77,wchar,hchar,wbox,hbox)

#define graf_mouse(number,faddr)\
	aes (78,number,faddr)

#define	ARROW		0
#define TEXT_CRSR	1
#define HOURGLASS	2
#define POINT_HAND	3
#define FLAT_HAND	4
#define THIN_CROSS	5
#define THICK_CROSS	6
#define OUTL_CROSS	7
#define USER_DEF	255
#define M_OFF		256
#define M_ON		257

#define graf_mkstate(mx,my,mstate,kstate)\
	aes (79,mx,my,mstate,kstate)

/**
 **		scrap
 **/

#define scrp_read(pscrap)\
	aes (80,pscrap)

#define scrp_write(pscrap)\
	aes (81,pscrap)

/**
 **		file selector
 **/

#define fsel_input(inpath,insel,exbutton)\
	aes (90,inpath,insel,exbutton)

/**
 **		windows
 **/

#define wind_create(kind,wx,wy,ww,wh)\
	aes (100,kind,wx,wy,ww,wh)

#define NAME		0x0001
#define CLOSE		0x0002
#define FULL		0x0004
#define MOVER		0x0008
#define INFO		0x0010
#define SIZER		0x0020
#define UPARROW		0x0040
#define DNARROW		0x0080
#define VSLIDE		0x0100
#define	LFARROW		0x0200
#define RTARROW		0x0400
#define HSLIDE		0x0800

#define wind_open(handle,x,y,w,h)\
	aes (101,handle,x,y,w,h)

#define wind_close(handle)\
	aes (102,handle)

#define wind_delete(handle)\
	aes (103,handle)

#define wind_get(handle,field,w1,w2,w3,w4)\
	aes (104,handle,field,w1,w2,w3,w4)

#define WF_WORKXYWH	4
#define WF_CURRXYWH	5
#define WF_PREVXYWH	6
#define WF_FULLXYWH	7
#define WF_HSLIDE	8
#define WF_VSLIDE	9
#define WF_TOP		10
#define WF_FIRSTXYWH	11
#define WF_NEXTXYWH	12
#define WF_RESVD	13
#define WF_HSLSIZE	15
#define WF_VSLSIZE	16

#define wind_set(handle,field,w1,w2,w3,w4)\
	aes (105,handle,field,w1,w2,w3,w4)

#define WF_NEWDESK	14

#define wind_newdesk(handle,addr,object)\
	aes (105,handle,WF_NEWDESK,addr,object,0)

#define wind_find(mx,my)\
	aes (106,mx,my)

#define wind_update(begend)\
	aes (107,begend)

#define END_UPDATE	0
#define BEG_UPDATE	1
#define END_MCTRL	2
#define BEG_MCTRL	3

#define wind_calc(type,kind,inx,iny,inw,inh,outx,outy,outw,outh)\
	aes (108,type,kind,inx,iny,inw,inh,outx,outy,outw,outh)


/**
 **		resources
 **/

typedef struct {
	int	rsh_vrsn;
	int	rsh_object;
	int	rsh_tedinfo;
	int	rsh_iconblk;
	int	rsh_bitblk;
	int	rsh_frstr;
	int	rsh_string;
	int	rsh_imdata;
	int	rsh_frimg;
	int	rsh_trindex;
	int	rsh_nobs;
	int	rsh_ntree;
	int	rsh_nted;
	int	rsh_nib;
	int	rsh_nbb;
	int	rsh_nstring;
	int	rsh_nimages;
	int	rsh_rssize;
} RSHDR;

#define rsrc_load(pfname)\
	aes (110,pfname)

#define rsrc_free()\
	aes (111)

#define rsrc_gaddr(type,index,addr)\
	aes (112,type,index,addr)

#define rsrc_saddr(type,index,addr)\
	aes (113,type,index,addr)


#define rsrc_obfix(tree,object)\
	aes (114,object,tree)


/**		shell
 **
 **/

#define shel_read(pcmd,ptail)\
	aes (120,pcmd,ptail)

#define shel_write(doex,isgr,iscr,pcmd,ptail)\
	aes (121,doex,isgr,iscr,pcmd,ptail)

#define shel_get(addr,len)\
	aes (122,len,addr)

#define shel_put(addr,len)\
	aes (123,len,addr)

#define shel_find(pbuff)\
	aes (124,pbuff)

#define shel_envrn(pvalue,parm)\
	aes (125,pvalue,parm)

/* Done !!!!!! */
