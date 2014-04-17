/*	GEMBIND.C		5/30/90 - 5/31/90	Derek Mui	*/
/*	Translate back from assembly code dated 4/26/90			*/
/*	O.K			6/25/90			D.Mui		*/
/*	Release acc wait at appl_exit	7/13/90		D.Mui		*/
/*	Change at appl_exit		10/4/90		D.Mui		*/
/*	Change at mn_bar		12/20/90	D.Mui		*/
/*	Add scan library		4/26/91		D.Mui		*/
/*	Add shel_path			4/30/91		D.Mui		*/
/*	Add mouse reset			5/8/91		D.Mui		*/
/*	Remove mouse reset		6/14/91		D.Mui		*/
/*	Appl_exit will do rs_free too	8/14/91		D.Mui		*/
/*	Add rs_fixit			10/1/91		D.Mui		*/
/*	Modify for Lattice C 5.51	02/24/93	C.Gee		*/
/*	Force the use of prototypes					*/
/*	Fixed 'About' item to allow it to be enabled/disabled		*/
/*	and to allow text change	4/29/93		C.Gee		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "objaddr.h"
#include "windlib.h"
#ifdef MB_STATE
/* mn_tools has a definition, but we want the one from crysbind.h */
#undef MB_STATE
#endif
#include "crysbind.h"
#include "mintbind.h"
#include "gemusa.h"

#define GB_STATE 	int_in[3]

EXTERN	WORD	gl_multi;
EXTERN	BYTE	PATHEQUAL[];
EXTERN	GRECT	gl_rzero;
EXTERN	GRECT	gl_rscreen;
EXTERN	WORD	gl_wchar;
EXTERN 	WORD	gl_hchar;
EXTERN 	WORD	gl_wbox;
EXTERN 	WORD	gl_hbox;
EXTERN 	WORD	gl_handle;
EXTERN 	LONG	ad_sysglo;
EXTERN 	GRECT	gl_rfull;
EXTERN 	LONG	ad_fsel;
EXTERN 	THEGLO	D;
EXTERN	WORD	spdid;
EXTERN	WORD	gl_mnpid;
EXTERN	PD	*scr_pd;
EXTERN	OBJECT	*mn_addr;

/*
*	Routine to change the state of a particular object.  The
*	change in state will not occur if the object is disabled
*	and the chkdisabled parameter is set.  The object will
*	be drawn with its new state only if the dodraw parameter
*	is set.
*/

	UWORD
do_chg(tree, iitem, chgvalue, dochg, dodraw, chkdisabled)
	OBJECT		*tree;			/* tree that holds item	*/
	WORD		iitem;			/* item to affect	*/
	REG UWORD		chgvalue;	/* bit value to change	*/
	WORD		dochg;			/* set or reset value	*/
	WORD		dodraw;			/* draw resulting change*/
	WORD		chkdisabled;		/* only if item enabled	*/
{
	REG UWORD		curr_state;

	curr_state = tree[iitem].ob_state;

	if ( (chkdisabled) && (curr_state & DISABLED) )
	  return(FALSE);
	
	if ( dochg )
	  curr_state |= chgvalue;
	else
	  curr_state &= ~chgvalue;

	if ( dodraw )
	{			/* make sure it is the current menu */
	  if ( tree != (OBJECT *)(idtopd( gl_mnpid )->p_mnaddr) )
	    dodraw = FALSE;
	  else
	    gsx_sclip( &gl_rscreen );
	}

	ob_change( (LONG)tree, iitem, curr_state, dodraw );
	return( TRUE );
}


/*	AES binding	*/

	VOID
crysbind( pcrys_blk )
	REG CBLK	*pcrys_blk;
{
	LONG		*global_in;
	REG WORD	*int_in,*int_out;
	LONG		*addr_in,*addr_out;
	LONG		tmparm,buparm,tree;
	LONG		value,ad_rso;
	WORD		ret;
	UWORD		*control;
	LONG		temp;

	control = (UWORD *)(pcrys_blk->cb_pcontrol);
	global_in = (LONG *)(pcrys_blk->cb_pglobal);
	int_in = (WORD *)(pcrys_blk->cb_pintin);
	addr_in = (LONG *)(pcrys_blk->cb_padrin);
	int_out = (WORD *)(pcrys_blk->cb_pintout);
	addr_out = (LONG *)(pcrys_blk->cb_padrout);

	if ( currpd->p_state == PS_ZOMBIE )
	{
	  ret = FALSE;
	  goto c_1;
	}

	ret = TRUE;

	Debug7( currpd->p_name );
	Debug7( " calls " );

	switch( OP_CODE )
	{	
	  case APPL_INIT:		/* Application Manager	*/
		Debug7( "appl_init\r\n" ); 
	    	ret = ap_init( ( LONG )global_in );
		break;
	  case APPL_READ:
		Debug7( "appl_read\r\n" ); 
		ret = ap_rdwr(AQRD, AP_RWID, AP_LENGTH, ( BYTE *)AP_PBUFF);
		break;
	  case APPL_WRITE:
		Debug7( "appl_write\r\n" ); 
		ret = ap_rdwr(AQWRT, AP_RWID, AP_LENGTH, ( BYTE *)AP_PBUFF);
		break;
	  case APPL_FIND:
		Debug7( "appl_find\r\n" ); 
		ret = ap_find( ( BYTE *)AP_PNAME );
		break;
	  case APPL_TPLAY:
		Debug7( "appl_tplay\r\n" ); 
		ap_tplay(AP_TBUFFER, AP_TLENGTH, AP_TSCALE);
		break;
	  case APPL_TRECORD:
		Debug7( "appl_trecord\r\n" ); 
		ret = ap_trecd(AP_TBUFFER, AP_TLENGTH);
		break;
	  case APPL_EXIT:
		Debug7( "appl_exit\r\n" ); 
		ret = ap_exit( currpd, pcrys_blk );
		break;
	  case APPL_TERM:
		Debug7( "appl_term\r\n" ); 
		ret = ap_term( AP_PPID1 );
		break;
	  case APPL_SEARCH:
		Debug7( "appl_search\r\n" ); 
		ret = ap_search( AP_STYPE, ( BYTE *)AP_ONAME, &AP_PTYPE, &AP_PPID2 );	
		break;
	  case APPL_GETINFO:
	        ret = ap_getinfo( AI_TYPE, &AI_OUT1, &AI_OUT2, &AI_OUT3, &AI_OUT4 );
		break;
	  case EVNT_KEYBD:		/* Event Manager*/
		Debug7( "evnt_keybd\r\n" ); 
		ret = ev_keybd();
		break;
	  case EVNT_BUTTON:
		Debug7( "evnt_button\r\n" ); 
		ret = ev_button(B_CLICKS, B_MASK, B_STATE, &EV_MX);
		break;
	  case EVNT_MOUSE:
		Debug7( "evnt_mouse\r\n" ); 
		ret = ev_mouse( ( MOBLK *)&MO_FLAGS, &EV_MX);
		break;
	  case EVNT_MESAG:
		Debug7( "evnt_mesag\r\n" ); 
		ret = ev_mesag( ( BYTE *)ME_PBUFF);
		break;
	  case EVNT_TIMER:
		Debug7( "evnt_timer\r\n" ); 
		temp = ((LONG)T_HICOUNT << 16L) & 0xFFFF0000L;
		temp = temp | ((LONG) T_LOCOUNT & 0x0000FFFFL );
		ret = ev_timer(temp);
		break;
	  case EVNT_MULTI:
		Debug7( "evnt_multi\r\n" ); 
		if (MU_FLAGS & MU_TIMER)
		  tmparm = HW(MT_HICOUNT) + LW(MT_LOCOUNT);
		buparm = HW(MB_CLICKS) | LW((MB_MASK << 8) | GB_STATE );
		ret = ev_multi(MU_FLAGS, ( MOBLK *)&MMO1_FLAGS, ( MOBLK *)&MMO2_FLAGS, tmparm,
			buparm, MME_PBUFF, &EV_MX);
		break;
	  case EVNT_DCLICK:
		Debug7( "evnt_dclick\r\n" ); 
		ret = ev_dclick(EV_DCRATE, EV_DCSETIT);
		break;
				
	  case MENU_BAR:		/* Menu Manager	*/
		Debug7( "menu_bar\r\n" ); 
		ret = mn_bar(MM_ITREE, SHOW_IT);
		break;

	  case MENU_ICHECK:
		Debug7( "menu_icheck\r\n" ); 
		do_chg( ( OBJECT *)MM_ITREE, ITEM_NUM, CHECKED, CHECK_IT, FALSE, FALSE);
		break;

	  case MENU_IENABLE:
		Debug7( "menu_ienable\r\n" ); 
		do_chg( ( OBJECT *)MM_ITREE, (ITEM_NUM & 0x7FFF), DISABLED,
			!ENABLE_IT, ((ITEM_NUM & 0x8000) != 0x0), FALSE);
		/* if this is the About menu item, change the state of the AES
		   copy also */
		tree = MM_ITREE;
		if ( ( ITEM_NUM & 0x7FFF ) == (LWGET(OB_HEAD(THEMENUS))+1) )
		   do_chg( (OBJECT *)mn_addr, 1, DISABLED, !ENABLE_IT, 0, FALSE);
		break;
	  case MENU_TNORMAL:
		Debug7( "menu_tnormal\r\n" ); 
		do_chg( ( OBJECT *)MM_ITREE, TITLE_NUM, SELECTED, !NORMAL_IT, TRUE, TRUE);
		break;
	  case MENU_TEXT:
		Debug7( "menu_text\r\n" );
		tree = MM_ITREE;
		LSTCPY( ( BYTE *)LLGET(OB_SPEC(ITEM_NUM)), ( BYTE *)MM_PTEXT );
		/* if this is the About menu item, change the AES copy too */
		if ( ( ITEM_NUM & 0x7FFF ) == (LWGET(OB_HEAD(THEMENUS))+1) )
		{
		   tree = mn_addr;
		   LSTCPY( (BYTE *)LLGET(OB_SPEC(1)), (BYTE *)MM_PTEXT );
		}
		break;

	  case MENU_REGISTER:
		Debug7( "menu_register\r\n" ); 
		ret = mn_register(MM_PID, ( BYTE *)MM_PSTR);
		break;
					/* 5/14/92	*/
	  case MN_POPUP:
		Debug7( currpd->p_name );
		Debug7( " call mn_popup\r\n" );
		ret = mn_popup( ( currpd == scr_pd ) ? gl_mnpid : currpd->p_pid,
		  		( MENU *)M_MENU, M_XPOS, M_YPOS, ( MENU *)M_MDATA );
		break;
	  case MN_ATTACH:
		ret = mn_attach( currpd->p_pid, M_FLAG, ( OBJECT *)M_TREE, M_ITEM, ( MENU *)M_MDATA );
		break;
	  case MN_ISTART:
		ret = mn_istart( currpd->p_pid, M_FLAG, ( OBJECT *)M_TREE, M_MENU2, M_ITEM2 );
		break;
	  case MN_SETTING:
		mn_settings( M_FLAG, ( MN_SET *)M_MENU );
		break;

	  case OBJC_ADD:		/* Object Manager	*/
		Debug7( "objc_add\r\n" ); 
		ob_add(OB_TREE, OB_PARENT, OB_CHILD);
		break;

	  case OBJC_DELETE:
		Debug7( "objc_delete\r\n" ); 
		ob_delete(OB_TREE, OB_DELOB);
		break;

	  case OBJC_DRAW:
		Debug7( "objc_draw\r\n" ); 
		gsx_sclip( ( GRECT *)&OB_XCLIP);
		ob_draw(OB_TREE, OB_DRAWOB, OB_DEPTH);
		break;

	  case OBJC_FIND:
		Debug7( "objc_find\r\n" ); 
		ret = ob_find(OB_TREE, OB_STARTOB, OB_DEPTH, OB_MX, OB_MY);
		break;

	  case OBJC_XFIND:
		Debug7( "objc_xfind\r\n" );
		ret = ob_xfind(OB_TREE, OB_STARTOB, OB_DEPTH, OB_MX, OB_MY);
		break;

	  case OBJC_OFFSET:
		Debug7( "objc_offset\r\n" ); 
/*		ob_offset(OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF);	*/
		ob_gclip(OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF, &OB_GX, 
			 &OB_GY, &OB_GW, &OB_GH);
		break;

	  case OBJC_ORDER:
		Debug7( "objc_order\r\n" ); 
		ob_order(OB_TREE, OB_OBJ, OB_NEWPOS);
		break;

	  case OBJC_EDIT:
		Debug7( "objc_edit\r\n" ); 
		OB_ODX = OB_IDX;
		ret = ob_edit(OB_TREE, OB_OBJ, OB_CHAR, &OB_ODX, OB_KIND);
		break;

	  case OBJC_CHANGE:
		Debug7( "objc_change\r\n" ); 
		gsx_sclip( ( GRECT *)&OB_XCLIP);
		ob_change(OB_TREE, OB_DRAWOB, OB_NEWSTATE, OB_REDRAW);
		break;
				
/* June 26 1992 - ml.   New call for new object extensions */
	  case OBJC_SYSVAR:
		ret = ob_sysvar(OB_MODE, OB_WHICH, OB_I1, OB_I2, &OB_O1, &OB_O2 );
		break;

	  case FORM_DO:			/* Form Manager	*/
		Debug7( "form_do\r\n" ); 
		ret = fm_do(FM_FORM, FM_START);
		break;
	  case FORM_DIAL:
		Debug7( "form_dial\r\n" ); 
		ret = fm_dial(FM_TYPE, ( GRECT *)&FM_IX, ( GRECT *)&FM_X);
		break;
	  case FORM_ALERT:
		Debug7( "form_alert\r\n" ); 
		ret = fm_alert(FM_DEFBUT, FM_ASTRING);
		break;
	  case FORM_ERROR:
		Debug7( "form_error\r\n" ); 
		ret = fm_error(FM_ERRNUM);
		break;
	  case FORM_CENTER:
		Debug7( "form_center\r\n" ); 
		ob_center(FM_FORM, ( GRECT *)&FM_XC);
		break;
	  case FORM_KEYBD:
		Debug7( "form_keybd\r\n" ); 
		gsx_sclip(&gl_rfull);
		FM_OCHAR = FM_ICHAR;
		FM_ONXTOB = FM_INXTOB;
		ret = fm_keybd(FM_FORM, FM_OBJ, &FM_OCHAR, &FM_ONXTOB);
		break;
	  case FORM_BUTTON:
		Debug7( "form_button\r\n" ); 
		gsx_sclip(&gl_rfull);
		ret = fm_button(FM_FORM, FM_OBJ, FM_CLKS, &FM_ONXTOB);
		break;
				/* Graphics Manager			*/
	  case GRAF_RWIN:
		Debug7( "graf_rubbox\r\n" ); 
		gr_rubwin(GR_I1, GR_I2, GR_I3, GR_I4, (GRECT *)&GR_I5, &GR_O1, &GR_O2);
		break;
	  case GRAF_RUBBOX:
		Debug7( "graf_rubbox\r\n" ); 
		gr_rubbox(GR_I1, GR_I2, GR_I3, GR_I4, &GR_O1, &GR_O2);
		break;
	  case GRAF_DRAGBOX:
		Debug7( "graf_dragbox\r\n" ); 
		gr_dragbox(GR_I1, GR_I2, GR_I3, GR_I4, ( GRECT *)&GR_I5, &GR_O1, &GR_O2);
		break;
	  case GRAF_MBOX:
		Debug7( "graf_mbox\r\n" ); 
		gr_movebox(GR_I1, GR_I2, GR_I3, GR_I4, GR_I5, GR_I6);
		break;
	  case GRAF_GROWBOX:
		Debug7( "graf_growbox\r\n" ); 
		gr_growbox( ( GRECT *)&GR_I1, ( GRECT *)&GR_I5);
		break;
	  case GRAF_SHRINKBOX:
		Debug7( "graf_shrinkbox\r\n" ); 
		gr_shrinkbox( ( GRECT *)&GR_I1, ( GRECT *)&GR_I5);
		break;
	  case GRAF_WATCHBOX:
		Debug7( "graf_watchbox\r\n" ); 
		ret = gr_watchbox(GR_TREE, GR_OBJ, GR_INSTATE, GR_OUTSTATE);
		break;
	  case GRAF_SLIDEBOX:
		Debug7( "graf_slidebox\r\n" ); 
		ret = gr_slidebox(GR_TREE, GR_PARENT, GR_OBJ, GR_ISVERT);
		break;
	  case GRAF_HANDLE:
		Debug7( "graf_handle\r\n" ); 
		GR_WCHAR = gl_wchar;
		GR_HCHAR = gl_hchar;
		GR_WBOX = gl_wbox;
		GR_HBOX = gl_hbox;
		ret = gl_handle;
		break;
	  case GRAF_MOUSE:
		Debug7( "graf_mouse\r\n" ); 
		ret = gr_mouse( GR_MNUMBER, ( MFORM *)GR_MADDR );
		break;
		
	  case GRAF_MKSTATE:
		Debug7( "graf_mkstate\r\n" ); 
		gr_mkstate(&GR_MX, &GR_MY, &GR_MSTATE, &GR_KSTATE);
		ret = 1;
		break;
				/* Scrap Manager	*/

	  case SCRP_READ:
		Debug7( "scrp_read\r\n" ); 
		sc_read(SC_PATH);
		break;
	  case SCRP_WRITE:
		Debug7( "scrp_write\r\n" ); 
		sc_write(SC_PATH);
		break;
				/* File Selector Manager	*/
	  case FSEL_INPUT:
		Debug7( "fsel_input\r\n" ); 
		ret = fs_input( ( BYTE *)FS_IPATH, FS_ISEL, &FS_BUTTON, ( BYTE *)ad_fsel );
		break;

	  case FSEL_EXINPUT:
		Debug7( "fsel_exinput\r\n" ); 
		ret = fs_input( ( BYTE *)FS_IPATH, FS_ISEL, &FS_BUTTON, ( BYTE *)FS_LABEL);
		break;

				/* Window Manager		*/
	  case WIND_CREATE:
		Debug7( "wind_create\r\n" ); 
		ret = wm_create(WM_KIND, ( GRECT *)&WM_WX);
		break;

	  case WIND_OPEN:
		Debug7( "wind_open\r\n" ); 
		ret = wm_open(WM_HANDLE, ( GRECT *)&WM_WX);
		break;

	  case WIND_CLOSE:
		Debug7( "wind_close\r\n" ); 
		ret = wm_close(WM_HANDLE);
		break;

	  case WIND_DELETE:
		Debug7( "wind_delete\r\n" ); 
		ret = wm_delete(WM_HANDLE);
		break;

	  case WIND_GET:
		Debug7( "wind_get\r\n" ); 
		ret = wm_get(WM_HANDLE, WM_WFIELD, &WM_OX, &WM_IX);
		break;

	  case WIND_SET:
		Debug7( "wind_set\r\n" ); 
		ret = wm_set(WM_HANDLE, WM_WFIELD, &WM_IX);
		break;

	  case WIND_FIND:
		Debug7( "wind_find\r\n" ); 
		ret = wm_find(WM_MX, WM_MY);
		break;

	  case WIND_UPDATE:
		Debug7( "wind_update\r\n" ); 
		ret = wm_update(WM_BEGUP);
		break;

	  case WIND_CALC:
		Debug7( "wind_calc\r\n" ); 
		ret = wm_calc(WM_WCTYPE, WM_WCKIND, WM_WCIX, WM_WCIY, WM_WCIW, 
			WM_WCIH, &WM_WCOX, &WM_WCOY, &WM_WCOW, &WM_WCOH);
		break;

	  case WIND_NEW:
		Debug7( "wind_new\r\n" ); 
	  	ret = wm_new( );
		break;
				
	  case RSRC_LOAD:	/* Resource Manager	*/
		Debug7( "rsrc_load\r\n" ); 
		ret = rs_load( ( LONG )global_in, RS_PFNAME);
		break;

	  case RSRC_FREE:
		Debug7( "rsrc_free\r\n" ); 
		ret = rs_free( ( LONG )global_in );
		break;

	  case RSRC_GADDR:
		Debug7( "rsrc_gaddr\r\n" ); 
		ret = rs_gaddr( ( LONG )global_in, RS_TYPE, RS_INDEX, &ad_rso);
		addr_out[0] = ad_rso;
		break;
	  case RSRC_SADDR:
		Debug7( "rsrc_saddr\r\n" ); 
		ret = rs_saddr( ( LONG )global_in, RS_TYPE, RS_INDEX, RS_INADDR);
		break;
	  case RSRC_OBFIX:
		Debug7( "rsrc_obfix\r\n" ); 
		rs_obfix( RS_TREE, RS_OBJ );
		break;
	  case RSRC_RCFIX:
		Debug7( "rsrc_rcfix\r\n" ); 
		rs_rcfix( ( LONG )global_in, ( BYTE *)RC_HEADER );
		break;	
				/* Shell Manager	*/
	  case SHEL_READ:
		Debug7( "shel_read\r\n" ); 
		ret = sh_read(SH_PCMD, SH_PTAIL);
		break;
	  case SHEL_WRITE:
		Debug7( "shel_write\r\n" ); 
		ret = sh_write(SH_DOEX, SH_ISGR, SH_ISCR, ( BYTE *)SH_PCMD, ( BYTE *)SH_PTAIL);
		break;
	  case SHEL_GET:
		Debug7( "shel_get\r\n" ); 
		ret = sh_get( ( BYTE *)SH_PBUFFER, SH_LEN);
		break;
	  case SHEL_PUT:
		Debug7( "shel_put\r\n" ); 
		ret = sh_put( ( BYTE *)SH_PDATA, SH_LEN);
		break;
	  case SHEL_FIND:
		Debug7( "shel_find\r\n" ); 
		ret = sh_find(SH_PATH, ( WORD(*)())NULLPTR, PATHEQUAL, TRUE );
		break;
	  case SHEL_ENVRN:
		Debug7( "shel_envrn\r\n" ); 
		sh_envrn( ( LONG *)SH_PATH, ( BYTE *)SH_SRCH );
		ret = 1;
		break;
	  default:
	 	value = (LONG)OP_CODE;
		Debug1( "illegal function call: number " );
		Ndebug1( value );
		fm_show( ALRTNOFU, ( UWORD *)&value, 1 );
		ret = -1;
		break;
	}

c_1:
	int_out[0] = ret;

}



/*	Check the for non waiting AES call				   */
/*	When making the following function call, the current process still */
/*	belongs to the client not the AES. All the Malloc will be owned by */
/*	application. These function assumes that it won't cause the client */
/*	to be put on wait state						   */ 

	WORD
chkbind( pcrys_blk, what )
	REG CBLK	*pcrys_blk;
	LONG	what;
{
	LONG		*global_in;
	REG WORD	*int_in,*int_out;
	LONG		*addr_in,*addr_out;
	LONG		tree,tmparm,buparm,ad_rso;     
	WORD		ret,wait;
	UWORD		*control;

	if ( (currpd->p_state & PS_NEW) && !gl_multi )
	  return( TRUE );

	ret = TRUE;		/* set up correct return code	*/
	wait = FALSE;		/* assume no need to wait	*/

 	control = (UWORD *)(pcrys_blk->cb_pcontrol);
	global_in = (LONG *)(pcrys_blk->cb_pglobal);
	int_in = (WORD *)(pcrys_blk->cb_pintin);
	addr_in = (LONG *)(pcrys_blk->cb_padrin);
	int_out = (WORD *)(pcrys_blk->cb_pintout);
	addr_out = (LONG *)(pcrys_blk->cb_padrout);

	if ( currpd->p_state == PS_ZOMBIE )
	  goto c_out;

	if ( ( what & 0x0000FFFFL ) == 201 )	/* just dispatch	*/
	{
	  if (!gl_multi) wait = TRUE;
	  goto c_out; 
	}

	Debug7( currpd->p_name );
	Debug7( " calls chkbind " );

	switch( OP_CODE )
	{
#if 0	
	  case APPL_INIT:		/* Application Manager	*/
		Debug7( "chkbind appl_init\r\n" );
	    	ret = ap_init( global_in );
		break;

	  case APPL_FIND:
		ret = ap_find( AP_PNAME );
		break;
#endif
	  case APPL_SEARCH:
	  	Debug7( "appl_search\r\n" ); 
		ret = ap_search( AP_STYPE, ( BYTE *)AP_ONAME, &AP_PTYPE, &AP_PPID2 );	
		break;

	  case APPL_GETINFO:
	        ret = ap_getinfo( AI_TYPE, &AI_OUT1, &AI_OUT2, &AI_OUT3, &AI_OUT4 );
		break;

	  case EVNT_MULTI:
	  	Debug7( "evnt_multi\r\n" ); 
		if ( MU_FLAGS & MU_TIMER )
		  tmparm = HW(MT_HICOUNT) + LW(MT_LOCOUNT);
		buparm = HW(MB_CLICKS) | LW((MB_MASK << 8) | GB_STATE);
		if ( ! ( ret = check_event( MU_FLAGS, ( MOBLK *)&MMO1_FLAGS, ( MOBLK *)&MMO2_FLAGS, tmparm,
				   buparm, MME_PBUFF, &EV_MX ) ) )
		  wait = TRUE;

		break;

	  case GRAF_MOUSE:
	  	Debug7( "graf_mouse\r\n" ); 
		ret = gr_mouse( GR_MNUMBER, ( MFORM *)GR_MADDR );
		break;

	  case MENU_ICHECK:
	  	Debug7( "menu_icheck\r\n" ); 
		do_chg( ( OBJECT *)MM_ITREE, ITEM_NUM, CHECKED, CHECK_IT, FALSE, FALSE);
		break;
/*
	  case MENU_IENABLE:
	  	Debug7( "menu_ienable\r\n" ); 
		do_chg( ( OBJECT *)MM_ITREE, (ITEM_NUM & 0x7FFF), DISABLED,
			!ENABLE_IT, ((ITEM_NUM & 0x8000) != 0x0), FALSE);
		break;
*/
	  case MENU_TNORMAL:
		Debug7( currpd->p_name );
		Debug7( " call menu_tnormal\r\n" );  
		do_chg( ( OBJECT *)MM_ITREE, TITLE_NUM, SELECTED, !NORMAL_IT, TRUE, TRUE);
		break;
/*
	  case MENU_TEXT:
	  	Debug7( "menu_text\r\n" ); 
		tree = MM_ITREE;
		LSTCPY( ( BYTE *)LLGET(OB_SPEC(ITEM_NUM)), ( BYTE *)MM_PTEXT);
		break;
*/

/*
	  case MENU_REGISTER:		
	  	Debug7( "menu_register\r\n" ); 
		ret = mn_register(MM_PID, MM_PSTR);
		break;
*/
	  case OBJC_ADD:		/* Object Manager	*/
	  	Debug7( "objc_add\r\n" ); 
		ob_add(OB_TREE, OB_PARENT, OB_CHILD);
		break;

	  case OBJC_DELETE:
	  	Debug7( "objc_delete\r\n" ); 
		ob_delete(OB_TREE, OB_DELOB);
		break;

	  case OBJC_DRAW:		/* this function must be in the context of the 
					 * caller because of the user defined obj
					 */
	  	Debug7( "objc_draw\r\n" ); 
		gsx_sclip( ( GRECT *)&OB_XCLIP);
		ob_draw( OB_TREE, OB_DRAWOB, OB_DEPTH );
		break;

	  case OBJC_FIND:
	  	Debug7( "objc_find\r\n" ); 
		ret = ob_find(OB_TREE, OB_STARTOB, OB_DEPTH, OB_MX, OB_MY);
		break;

	  case OBJC_XFIND:
	  	Debug7( "objc_xfind\r\n" ); 
		ret = ob_xfind(OB_TREE, OB_STARTOB, OB_DEPTH, OB_MX, OB_MY);
		break;

	  case OBJC_OFFSET:
	  	Debug7( "objc_offset\r\n" ); 
/*		ob_offset(OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF); */

		ob_gclip(OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF, &OB_GX, 
			 &OB_GY, &OB_GW, &OB_GH);
		break;

	  case OBJC_ORDER:
	  	Debug7( "objc_order\r\n" ); 
		ob_order(OB_TREE, OB_OBJ, OB_NEWPOS);
		break;

	  case OBJC_EDIT:
	  	Debug7( "objc_edit\r\n" ); 
		OB_ODX = OB_IDX;
		ret = ob_edit(OB_TREE, OB_OBJ, OB_CHAR, &OB_ODX, OB_KIND);
		break;

/*
	  case OBJC_CHANGE:
	  	Debug7( "objc_change\r\n" ); 
		gsx_sclip(&OB_XCLIP);
		ob_change(OB_TREE, OB_DRAWOB, OB_NEWSTATE, OB_REDRAW);
		break;
*/
				
/* June 26 1992 - ml.   New call for new object extensions */
	  case OBJC_SYSVAR:
		ret = ob_sysvar(OB_MODE, OB_WHICH, OB_I1, OB_I2, &OB_O1, &OB_O2 );
		break;
/**/

	  case FORM_CENTER:
	  	Debug7( "form_center\r\n" ); 
		ob_center(FM_FORM, ( GRECT *)&FM_XC);
		break;

	  case FORM_KEYBD:
	  	Debug7( "form_keybd\r\n" ); 
		gsx_sclip(&gl_rfull);
		FM_OCHAR = FM_ICHAR;
		FM_ONXTOB = FM_INXTOB;
		ret = fm_keybd(FM_FORM, FM_OBJ, &FM_OCHAR, &FM_ONXTOB);
		break;		

	  case GRAF_GROWBOX:
	  	Debug7( "graf_growbox\r\n" ); 
		gr_growbox( ( GRECT *)&GR_I1, ( GRECT *)&GR_I5);
		break;

	  case GRAF_SHRINKBOX:
	  	Debug7( "graf_shrinkbox\r\n" ); 
		gr_shrinkbox( ( GRECT *)&GR_I1, ( GRECT *)&GR_I5);
		break;

	  case GRAF_HANDLE:
	  	Debug7( "graf_handle\r\n" ); 
		GR_WCHAR = gl_wchar;
		GR_HCHAR = gl_hchar;
		GR_WBOX = gl_wbox;
		GR_HBOX = gl_hbox;
		ret = gl_handle;
		break;
		
	  case GRAF_MKSTATE:
	  	Debug7( "graf_mkstate\r\n" ); 
		gr_mkstate(&GR_MX, &GR_MY, &GR_MSTATE, &GR_KSTATE);
		ret = 1;
		break;
				/* Scrap Manager	*/

	  case SCRP_READ:
	  	Debug7( "scrp_read\r\n" ); 
		sc_read(SC_PATH);
		break;
		
	  case SCRP_WRITE:
	  	Debug7( "scrp_write\r\n" ); 
		sc_write(SC_PATH);
		break;

	  case WIND_GET:
	  	Debug7( "wind_get\r\n" ); 
	        if ( WM_WFIELD != WF_FIRSTXYWH )
		  ret = wm_get( WM_HANDLE, WM_WFIELD, &WM_OX, &WM_IX );
	  	else
		  wait = TRUE;

		break;
		
	  case WIND_FIND:
	  	Debug7( "wind_find\r\n" ); 
		ret = wm_find(WM_MX, WM_MY);
		break;

	  case WIND_CALC:
	  	Debug7( "wind_calc\r\n" ); 
		ret = wm_calc(WM_WCTYPE, WM_WCKIND, WM_WCIX, WM_WCIY, WM_WCIW, 
			WM_WCIH, &WM_WCOX, &WM_WCOY, &WM_WCOW, &WM_WCOH);
		break;

	  case WIND_UPDATE:
	  	Debug7( "wind_update\r\n" ); 
		if ( !WM_BEGUP )
		  ret = wm_update( WM_BEGUP );
		else
		{
		  if ( ( WM_BEGUP & 0x00FF ) == 1 )
		  {
		    if ( ( !spdid ) || ( spdid == currpd->p_pid ) )
		    {
		      ret = wm_update( WM_BEGUP );
		      break;
		    }
		  }
		  wait = TRUE;
		}
		break;

	  case RSRC_LOAD:	/* Resource Manager	*/
	  	Debug7( "rsrc_load\r\n" ); 
		ret = rs_load( ( LONG )global_in, RS_PFNAME);
		break;
		
	  case RSRC_FREE:
	  	Debug7( "rsrc_free\r\n" ); 
		ret = rs_free( ( LONG )global_in );
		break;

	  case RSRC_GADDR:
	  	Debug7( "rsrc_gaddr\r\n" ); 
		ret = rs_gaddr( ( LONG )global_in, RS_TYPE, RS_INDEX, &ad_rso);
	        addr_out[0] = ad_rso;
		break;

	  case RSRC_SADDR:
	  	Debug7( "rsrc_saddr\r\n" ); 
		ret = rs_saddr( ( LONG )global_in, RS_TYPE, RS_INDEX, RS_INADDR);
		break;

	  case RSRC_OBFIX:
	  	Debug7( "rsrc_obfix\r\n" ); 
		rs_obfix( RS_TREE, RS_OBJ );
		break;

	  case RSRC_RCFIX:
	  	Debug7( "rsrc_rcfix\r\n" ); 
		rs_rcfix( ( LONG )global_in, ( BYTE *)RC_HEADER );
		break;	
				/* Shell Manager	*/
	  case SHEL_READ:
	  	Debug7( "shel_read\r\n" ); 
		ret = sh_read( ( LONG )SH_PCMD, SH_PTAIL);
		break;

	  case SHEL_GET:
	  	Debug7( "shel_get\r\n" ); 
		ret = sh_get( ( BYTE *)SH_PBUFFER, SH_LEN);
		break;
/*		
	  case SHEL_PUT:
	  	Debug7( "shel_put\r\n" ); 
		ret = sh_put(SH_PDATA, SH_LEN);
		break;
*/
	  case SHEL_FIND:
	  	Debug7( "shel_find\r\n" ); 
		ret = sh_find(SH_PATH, ( WORD(*)())NULLPTR, PATHEQUAL, TRUE );
		break;
		
	  case SHEL_ENVRN:
	  	Debug7( "shel_envrn\r\n" ); 
		sh_envrn( ( LONG *)SH_PATH, ( BYTE *)SH_SRCH);
		ret = 1;
		break;

	  default:
		wait = TRUE;
		break;
	}

c_out:
	if ( !wait )	/* If don't have to wait */
	{
	  int_out[0] = ret;
	  wake_up(0);
	} else if (gl_multi == 0) {	/* not multitasking, do the call anyway */
		yieldcpu();
		crysbind(pcrys_blk);
		wait = FALSE; /* pretend we didn't have to wait */
		wake_up(0);
	}

	forker();
	return( wait );
}
