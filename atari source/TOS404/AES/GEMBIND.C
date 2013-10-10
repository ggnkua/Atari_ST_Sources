/*	GEMBIND.C		5/30/90 - 5/31/90	Derek Mui	*/
/*	Translate back from assembly code dated 4/26/90			*/
/*	O.K			6/25/90			D.Mui		*/
/*	Release acc wait at appl_exit	7/13/90		D.Mui		*/
/*	Remove appl_init and appl_exit	4/3/91		D.Mui		*/
/*	Add mouse restore	5/8/91			D.Mui		*/
/*	Remove mouse restore	6/14/91			D.Mui		*/
/*	Add objc_xtend		7/7/92			D.Mui		*/
/*	Change binding for wm_get	7/8/92		D.Mui		*/
/*	Add sub menu functions		7/8/92		D.Mui		*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <taddr.h>
#include <gemlib.h>
#include <crysbind.h>
#include <gemusa.h>


MLOCAL WORD	gl_dspcnt;
MLOCAL LONG	ad_rso;
MFORM		gl_cmform;	/* current aes mouse form	*/
MFORM		gl_omform;	/* old aes mouse form		*/

#define CONTROL LLGET(pcrys_blk)
#define GLOBAL LLGET(pcrys_blk+4)
#define INT_IN LLGET(pcrys_blk+8)
#define INT_OUT LLGET(pcrys_blk+12)
#define ADDR_IN LLGET(pcrys_blk+16)
#define ADDR_OUT LLGET(pcrys_blk+20)
						/* in GSXIF.C		*/
EXTERN	WORD	gl_wchar;
EXTERN 	WORD	gl_hchar;
EXTERN 	WORD	gl_wbox;
EXTERN 	WORD	gl_hbox;
EXTERN 	WORD	gl_handle;
EXTERN 	LONG	ad_sysglo;

EXTERN 	GRECT	gl_rfull;
EXTERN 	LONG	ad_fsel;
EXTERN 	THEGLO	D;
EXTERN	BYTE	*maddr;
EXTERN	WORD	gl_apid;
EXTERN	WORD	pglobal[];


	UWORD
crysbind(opcode, pglobal, int_in, int_out, addr_in)
	WORD		opcode;
	REG LONG		pglobal;
	REG UWORD		int_in[];
	REG UWORD		int_out[];
	REG LONG		addr_in[];
{
	LONG		tmparm;
	LONG		buparm;
	LONG		lmaddr;
	LONG		tree;
	REG WORD	ret;
	MFORM		*mform;
	WORD		i,offset;

	ret = TRUE;

	switch(opcode)
	{	
	  case APPL_INIT:			/* Application Manager	*/
		ret = ap_init( pglobal );
		break;
	  case APPL_READ:
		ap_rdwr(AQRD, AP_RWID, AP_LENGTH, AP_PBUFF);
		break;
	  case APPL_WRITE:
		ap_rdwr(AQWRT, AP_RWID, AP_LENGTH, AP_PBUFF);
		break;
	  case APPL_FIND:
		ret = ap_find( AP_PNAME );
		break;
	  case APPL_TPLAY:
		ap_tplay(AP_TBUFFER, AP_TLENGTH, AP_TSCALE);
		break;
	  case APPL_TRECORD:
		ret = ap_trecd(AP_TBUFFER, AP_TLENGTH);
		break;
	  case APPL_EXIT:
		ap_exit();
		break;
	  case EVNT_KEYBD:		/* Event Manager*/
		ret = ev_keybd();
		break;
	  case EVNT_BUTTON:
		ret = ev_button(B_CLICKS, B_MASK, B_STATE, &EV_MX);
		break;
	  case EVNT_MOUSE:
		ret = ev_mouse(&MO_FLAGS, &EV_MX);
		break;
	  case EVNT_MESAG:
		ret = ev_mesag(ME_PBUFF);
		break;
	  case EVNT_TIMER:
		ret = ev_timer(T_HICOUNT, T_LOCOUNT);
		break;
	  case EVNT_MULTI:
		if (MU_FLAGS & MU_TIMER)
		  tmparm = HW(MT_HICOUNT) + LW(MT_LOCOUNT);
		buparm = HW(MB_CLICKS) | LW((MB_MASK << 8) | MB_STATE);
		ret = ev_multi(MU_FLAGS, &MMO1_FLAGS, &MMO2_FLAGS, tmparm,
			buparm, MME_PBUFF, &EV_MX);
		break;
	  case EVNT_DCLICK:
		ret = ev_dclick(EV_DCRATE, EV_DCSETIT);
		break;
				
	  case MENU_BAR:		/* Menu Manager	*/
		mn_bar(MM_ITREE, SHOW_IT);
		break;

	  case MENU_ICHECK:
		do_chg(MM_ITREE, ITEM_NUM, CHECKED, CHECK_IT, FALSE, FALSE);
		break;

	  case MENU_IENABLE:
		do_chg(MM_ITREE, (ITEM_NUM & 0x7FFF), DISABLED,
			!ENABLE_IT, ((ITEM_NUM & 0x8000) != 0x0), FALSE);
		break;
	  case MENU_TNORMAL:
		do_chg(MM_ITREE, TITLE_NUM, SELECTED, !NORMAL_IT, TRUE, TRUE);
		break;
	  case MENU_TEXT:
		tree = MM_ITREE;
		LSTCPY(LLGET(OB_SPEC(ITEM_NUM)), MM_PTEXT);
		break;
	  case MENU_REGISTER:
		ret = mn_register(MM_PID, MM_PSTR);
		break;
					/* 5/14/92	*/
	  case MN_POPUP:
		ret = mn_popup( rlr->p_pid, M_MENU, M_XPOS, M_YPOS, M_MDATA );
		break;
	  case MN_ATTACH:
		ret = mn_attach( rlr->p_pid, M_FLAG, M_TREE, M_ITEM, M_MDATA );
		break;
	  case MN_ISTART:
		ret = mn_istart( rlr->p_pid, M_FLAG, M_TREE, M_MENU2, M_ITEM2 );
		break;
	  case MN_SETTING:
		mn_settings( M_FLAG, M_MENU );
		break;
	
	  case OBJC_ADD:		/* Object Manager	*/
		ob_add(OB_TREE, OB_PARENT, OB_CHILD);
		break;
	  case OBJC_DELETE:
		ob_delete(OB_TREE, OB_DELOB);
		break;
	  case OBJC_DRAW:
		gsx_sclip(&OB_XCLIP);
		ob_draw(OB_TREE, OB_DRAWOB, OB_DEPTH);
		break;
	  case OBJC_FIND:
		ret = ob_find(OB_TREE, OB_STARTOB, OB_DEPTH, OB_MX, OB_MY);
		break;
	  case OBJC_OFFSET:
/*		ob_offset(OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF);	*/
		ob_gclip(OB_TREE, OB_OBJ, &OB_XOFF, &OB_YOFF, &OB_GX, 
			 &OB_GY, &OB_GW, &OB_GH);
		break;
	  case OBJC_ORDER:
		ob_order(OB_TREE, OB_OBJ, OB_NEWPOS);
		break;
	  case OBJC_EDIT:
		OB_ODX = OB_IDX;
		ret = ob_edit(OB_TREE, OB_OBJ, OB_CHAR, &OB_ODX, OB_KIND);
		break;
	  case OBJC_CHANGE:
		gsx_sclip(&OB_XCLIP);
		ob_change(OB_TREE, OB_DRAWOB, OB_NEWSTATE, OB_REDRAW);
		break;

/* June 26 1992 - ml.   New call for new object extensions */
/* 8/1/92	*/	
	  case OBJC_SYSVAR:
		ret = ob_sysvar( OB_MODE, OB_WHICH, OB_I1, OB_I2, 
				&OB_O1, &OB_O2 );
		break;
/**/
				
	  case FORM_DO:			/* Form Manager	*/
		ret = fm_do(FM_FORM, FM_START);
		break;
	  case FORM_DIAL:
		fm_dial(FM_TYPE, &FM_IX, &FM_X);
		break;
	  case FORM_ALERT:
		ret = fm_alert(FM_DEFBUT, FM_ASTRING);
		break;
	  case FORM_ERROR:
		ret = fm_error(FM_ERRNUM);
		break;
	  case FORM_CENTER:
		ob_center(FM_FORM, &FM_XC);
		break;
	  case FORM_KEYBD:
		gsx_sclip(&gl_rfull);
		FM_OCHAR = FM_ICHAR;
		FM_ONXTOB = FM_INXTOB;
		ret = fm_keybd(FM_FORM, FM_OBJ, &FM_OCHAR, &FM_ONXTOB);
		break;
	  case FORM_BUTTON:
		gsx_sclip(&gl_rfull);
		ret = fm_button(FM_FORM, FM_OBJ, FM_CLKS, &FM_ONXTOB);
		break;
				/* Graphics Manager			*/
	  case GRAF_RUBBOX:
		gr_rubbox(GR_I1, GR_I2, GR_I3, GR_I4, &GR_O1, &GR_O2);
		break;
	  case GRAF_DRAGBOX:
		gr_dragbox(GR_I1, GR_I2, GR_I3, GR_I4, &GR_I5, &GR_O1, &GR_O2);
		break;
	  case GRAF_MBOX:
		gr_movebox(GR_I1, GR_I2, GR_I3, GR_I4, GR_I5, GR_I6);
		break;
	  case GRAF_GROWBOX:
		gr_growbox(&GR_I1, &GR_I5);
		break;
	  case GRAF_SHRINKBOX:
		gr_shrinkbox(&GR_I1, &GR_I5);
		break;
	  case GRAF_WATCHBOX:
		ret = gr_watchbox(GR_TREE, GR_OBJ, GR_INSTATE, GR_OUTSTATE);
		break;
	  case GRAF_SLIDEBOX:
		ret = gr_slidebox(GR_TREE, GR_PARENT, GR_OBJ, GR_ISVERT);
		break;
	  case GRAF_HANDLE:
		GR_WCHAR = gl_wchar;
		GR_HCHAR = gl_hchar;
		GR_WBOX = gl_wbox;
		GR_HBOX = gl_hbox;
		ret = gl_handle;
		break;
	  case GRAF_MOUSE:
		if ( maddr )
		{
		  ctlmouse( 0 );
		  maddr = 1;
		}

		gr_mouse( GR_MNUMBER, GR_MADDR );

		if ( maddr )
		  ctlmouse( 1 );

		break;
		
	  case GRAF_MKSTATE:
		ret = gr_mkstate(&GR_MX, &GR_MY, &GR_MSTATE, &GR_KSTATE);
		break;
				/* Scrap Manager	*/

	  case SCRP_READ:
		sc_read(SC_PATH);
		break;
	  case SCRP_WRITE:
		sc_write(SC_PATH);
		break;
				/* File Selector Manager	*/
	  case FSEL_INPUT:
		ret = fs_input(FS_IPATH, FS_ISEL, &FS_BUTTON, ad_fsel);
		break;
	  case FSEL_EXINPUT:
		ret = fs_input(FS_IPATH, FS_ISEL, &FS_BUTTON, FS_LABEL);
		break;

				/* Window Manager		*/
	  case WIND_CREATE:
		ret = wm_create(WM_KIND, &WM_WX);
		break;
	  case WIND_OPEN:
		wm_open(WM_HANDLE, &WM_WX);
		break;
	  case WIND_CLOSE:
		wm_close(WM_HANDLE);
		break;
	  case WIND_DELETE:
		wm_delete(WM_HANDLE);
		break;
	  case WIND_GET:
		ret = wm_get(WM_HANDLE, WM_WFIELD, &WM_OX, &WM_IX);
		break;
	  case WIND_SET:
		wm_set(WM_HANDLE, WM_WFIELD, &WM_IX);
		break;
	  case WIND_FIND:
		ret = wm_find(WM_MX, WM_MY);
		break;
	  case WIND_UPDATE:
		ret = wm_update(WM_BEGUP);
		break;
	  case WIND_CALC:
		wm_calc(WM_WCTYPE, WM_WCKIND, WM_WCIX, WM_WCIY, WM_WCIW, 
			WM_WCIH, &WM_WCOX, &WM_WCOY, &WM_WCOW, &WM_WCOH);
		break;
	  case WIND_NEW:
	  	ret = wm_new( );
		break;
				
	  case RSRC_LOAD:	/* Resource Manager	*/
		ret = rs_load(pglobal, RS_PFNAME);
		break;
	  case RSRC_FREE:
		ret = rs_free(pglobal);
		break;
	  case RSRC_GADDR:
		ret = rs_gaddr(pglobal, RS_TYPE, RS_INDEX, &ad_rso);
		break;
	  case RSRC_SADDR:
		ret = rs_saddr(pglobal, RS_TYPE, RS_INDEX, RS_INADDR);
		break;
	  case RSRC_OBFIX:
		ret = rs_obfix(RS_TREE, RS_OBJ);
		break;
				/* Shell Manager	*/
	  case SHEL_READ:
		ret = sh_read(SH_PCMD, SH_PTAIL);
		break;
	  case SHEL_WRITE:
		ret = sh_write(SH_DOEX, SH_ISGR, SH_ISCR, SH_PCMD, SH_PTAIL);
		break;
	  case SHEL_GET:
		ret = sh_get(SH_PBUFFER, SH_LEN);
		break;
 	  case SHEL_PUT:
		ret = sh_put(SH_PDATA, SH_LEN);
		break;
	  case SHEL_FIND:
		ret = sh_find(SH_PATH, NULLPTR);
		break;
	  case SHEL_ENVRN:
		ret = sh_envrn(SH_PATH, SH_SRCH);
		break;
	  default:
		fm_show(ALRTNOFUNC, NULLPTR, 1);
		ret = -1;
		break;
	}
	return(ret);
}


/*
*	Routine that copies input parameters into local buffers,
*	calls the appropriate routine via a case statement, copies
*	return parameters from local buffers, and returns to the
*	routine.
*/

	VOID
xif(pcrys_blk)
	LONG		pcrys_blk;
{
	UWORD		control[C_SIZE];
	UWORD		int_in[I_SIZE];
	UWORD		int_out[O_SIZE];
	LONG		addr_in[AI_SIZE];

	LWCOPY(ADDR(&control[0]), CONTROL, C_SIZE);

	if (IN_LEN)
	  LWCOPY(ADDR(&int_in[0]), INT_IN, IN_LEN);

	if (AIN_LEN)
	  LWCOPY(ADDR(&addr_in[0]), ADDR_IN, AIN_LEN*2);

	int_out[0] = crysbind(OP_CODE, GLOBAL, &int_in[0], &int_out[0], 
				&addr_in[0]);
	if ( OUT_LEN )
	  LWCOPY( INT_OUT, &int_out[0], OUT_LEN );

	if (OP_CODE == RSRC_GADDR)
	  LLSET(ADDR_OUT, ad_rso);
}

