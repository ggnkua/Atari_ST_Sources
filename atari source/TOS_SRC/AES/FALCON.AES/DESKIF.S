*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/deskif.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:10:36 $	$Locker: kbad $
* =======================================================================
*  $Log:	deskif.s,v $
* Revision 2.2  89/04/26  18:10:36  mui
* aes30
* 
* Revision 2.1  89/02/22  05:21:49  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:29:37  lozben
* Initial revision
* 
*************************************************************************
*	Fix bug at appl_init	3/13/87		Derek Mui
*	The bug originated from DRI, it's not Landon's fault
*	Deskif.s 				Landon Dyer
*	Use MAC to assemble	6/28/90		D.Mui
*	Release the acc wait at appl_exit	7/13/90	D.Mui
* assemble with MAS 900801 kbad
*	Removed far_call	4/8/91		D.Mui
*	Remove gr_mouse		6/13/91		D.Mui

	.globl _rlr
	.globl _drl
	.globl _nrl
	.globl _eul
	.globl _dlr
	.globl _zlr
	.globl _elinkoff
	.globl _indisp
	.globl _infork
	.globl _fpt
	.globl _fph
	.globl _fpcnt
	.globl _wind_spb
	.globl _cda
	.globl _curpid
	.globl _pglobal
	.comm _pglobal,30
	.globl _gl_apid
	.comm _gl_apid,2
	.globl _D
	.globl _gl_wchar
	.globl _gl_hchar
	.globl _gl_wbox
	.globl _gl_hbox
	.globl _gl_handl
	.globl _ad_sysgl
	.globl _gl_nplan
	.globl _gl_bvdis
	.globl _gl_bvhar


*  
*  WORD
*  appl_bvset( bvdisk, bvhard )
*       WORD	bvdisk;
*       WORD	bvhard;
*  {
*    gl_bvdisk = bvdisk;
*    gl_bvhard = bvhard;
*    return(TRUE);
*  }
*  			
	.globl _appl_bvs
	.text
_appl_bvs:
	move.w	8-4(sp),_gl_bvdis
	move.w	10-4(sp),_gl_bvhar
	moveq	#1,d0
	rts


*
*  WORD
*  appl_write(rwid, length, pbuff)
*       WORD		rwid;
*       WORD		length;
*       LONG		pbuff;
*  {
*    WORD		ret;
*    ret = ap_rdwr( AQWRT, rwid, length, pbuff);
*    dsptch();
*    return(ret);
*  }
*  
	.globl _appl_wri
	.text
_appl_wri:
	link	a6,#0
	move.l	8+4(sp),-(sp)		; ap_rdwr(AQWRT, rwid, length, pbuff)
	move.l	8+4(sp),-(sp)
	move.w	#2,-(sp)
	jsr	_ap_rdwr
dispit:	unlk	a6			; restore A6 and SP
disp1:	move.l	d0,-(sp)		; save return value
	jsr	_dsptch			; dispatch
	move.l	(sp)+,d0		; restore return value
	rts				; ... and return




*
*  WORD
*  evnt_multi(flags, bclk, bmsk, bst, m1flags, m1x, m1y, m1w, m1h, 
*  	   m2flags, m2x, m2y, m2w, m2h, mepbuff,
*  	   tlc, thc, pmx, pmy, pbut, pks, pkr, pbr )
*       UWORD		flags, bclk, bmsk, bst;
*       UWORD		m1flags, m1x, m1y, m1w, m1h;
*       UWORD		m2flags, m2x, m2y, m2w, m2h;
*       LONG		mepbuff;
*       UWORD		tlc, thc;
*       UWORD		*pmx, *pmy, *pbut, *pks, *pkr, *pbr;
*  {
*    LONG		buparm, tmcount;
*    WORD		rets[6];
*    WORD		which;
*    
*    buparm = ( (LONG)(bclk) << 16);
*    buparm += (bmsk << 8) + (bst);
*    tmcount = ( (LONG)(thc) << 16);
*    tmcount += tlc;
*    
*    which = ev_multi(flags, &m1flags, &m2flags,
*			tmcount, buparm, mepbuff, &rets[0]);
*    dsptch();
*    *pmx = rets[0];
*    *pmy = rets[1];
*    *pbut = rets[2];
*    *pks = rets[3];
*    *pkr = rets[4];
*    *pbr = rets[5];
*    return( which);
*  }
*  
	.globl _evnt_mul
	.text
_evnt_mul:
	link	a6,#-26

	moveq	#0,d0			; d0 = bclk<<16
	move.w	10(a6),d0
	swap	d0
	moveq	#0,d1			; d1 = bmsk<<8 + btst
	move.w	12(a6),d1
	lsl	#8,d1
	add	14(a6),d1
	add.l	d1,d0			; d0 = (bclk<<16) + (bmsk<<8) + btst

	moveq	#0,d1			; d1 = thc<<16
	move.w	42(a6),d1
	swap	d1
	moveq	#0,d2			; d2 = tlc
	move.w	40(a6),d2
	add.l	d2,d1			; d1 = (thc<<16) + tlc

	pea	-20(a6)			; &rets[?]
	move.l	36(a6),-(sp)		; mepbuff
	move.l	d0,-(sp)		; buparm (D0)
	move.l	d1,-(sp)		; tmcount (D1)
	pea	26(a6)			; &m2flags
	pea	16(a6)			; &m1flags
	move.w	8(a6),-(sp)		; flags
	jsr	_ev_multi		; ev_multi(...)
	lea	44(a6),a2		; array copy to ptrs in user space
	lea	-20(a6),a1
	moveq	#6-1,d1

cplp:	move.l	(a2)+,a0		; get pointer from pointer vector
	move.w	(a1)+,(a0)		; copy word to pointer's ref
	dbra	d1,cplp			; loop for more pointers
	bra	dispit			; dispatch, unlk, return D0 to caller


*
*  WORD
*  evnt_button(clicks, mask, state, pmx, pmy, pmw, pmh)
*       WORD		clicks;
*       UWORD		mask;
*       UWORD		state;
*       WORD		*pmx, *pmy, *pmh, *pmw;
*  {
*    WORD		mrect[4];
*    WORD		ret;
*    
*    ret = ev_button(clicks, mask, state, &mrect);
*    dsptch();
*    *pmx = mrect[0];
*    *pmy = mrect[1];
*    *pmw = mrect[2];
*    *pmh = mrect[3];
*    return(ret);
*  }
*  
	.globl _evnt_but
	.text
_evnt_but:
	link	a6,#-8
	pea	-8(a6)
	move.w	12(a6),-(sp)
	move.w	10(a6),-(sp)
	move.w	8(a6),-(sp)
	jsr	_ev_butto
	lea	14(a6),a2		; a2 -> vector of addrs to stuff
cplp4a:	lea	-8(a6),a1		; a1 -> vector of words
cplp4:	moveq	#4-1,d1			; d1 = count
	bra	cplp


*
*  WORD
*  evnt_dclick(rate, setit)
*       WORD		rate, setit;
*  {
*    WORD		ret;
*    ret = ev_dclick(rate,setit);
*    dsptch();
*    return(ret);
*  }
*
	.globl _evnt_dcl
	.text
_evnt_dcl:
	move.l	4(sp),-(sp)
	jsr	_ev_dclic
	addq.l	#4,sp
	bra	disp1


*
*  WORD
*  form_do(form, start)
*       LONG		form;
*       WORD		start;
*  {
*    WORD		ret;
*    
*    desk_wait( FALSE );
*    ret = fm_do(form,start);
*    dsptch();
*    return(ret);
*  }
*  
	.globl _form_do
	.text
_form_do:
	clr	-(sp)
	jsr	_desk_wai
	move.w	10(sp),(sp)			; CS from 8(sp)
	move.l	6(sp),-(sp)
	jsr	_fm_do
	addq.l	#6,sp
	bra	disp1


*
*  WORD
*  form_dial(dtype, ix, iy, iw, ih, x, y, w, h)
*       WORD		dtype;
*       WORD		ix, iy, iw, ih;
*       WORD		x, y, w, h;
*  {
*    WORD		ret;
*    ret = fm_dial(dtype, &ix, &x);
*    dsptch();
*    return(ret);
*  }
*
	.globl _form_dia
	.text
_form_dia:
	pea	14(sp)			; &x
	pea	6+4(sp)			; &ix
	move.w	4+8(sp),-(sp)		; dtype
	jsr	_fm_dial
	lea	10(sp),sp
	bra	disp1


*
*  WORD
*  form_alert(defbut, astring)
*       WORD		defbut;
*       LONG		astring;
*  {
*    WORD		ret;
*    ret = fm_alert(defbut, astring);
*    dsptch();
*    return(ret);
*  }
*
	.globl _form_ale
	.text
_form_ale:
	move.l	6(sp),-(sp)
	move.w	4+4(sp),-(sp)
	jsr	_fm_alert
	addq.l	#6,sp
	bra	disp1


*
*  WORD
*  form_error(errnum)
*       WORD		errnum;
*  {
*    WORD		ret;
*    ret = fm_error(errnum);
*    dsptch();
*    return(ret);
*  }
*
	.globl _form_err
	.text
_form_err:
	move.w	4(sp),-(sp)
	jsr	_fm_error
	addq.l	#2,sp
	bra	disp1


*
*  WORD
*  form_center(tree, pcx, pcy, pcw, pch)
*       LONG		tree;
*       WORD		*pcx, *pcy, *pcw, *pch;
*  {
*    WORD		ret;
*    GRECT		pt;
*    ret = ob_center(tree, &pt);
*    *pcx = pt.g_x;
*    *pcy = pt.g_y;
*    *pcw = pt.g_w;
*    *pch = pt.g_h;
*    dsptch();
*    return(ret);
*  }
*  
	.globl _form_cen
	.text
_form_cen:
	link	a6,#-8			; space for GRECT
	pea	-8(a6)			; &rect
	move.l	8(a6),-(sp)		; tree
	jsr	_ob_cente		; ob_center(tree, &rect)
	lea	12(a6),a2		; copy coords back
	lea	-8(a6),a1
	bra	cplp4


*
*  WORD
*  gr_handle(gwchar,ghchar,gwbox,ghbox)
*       WORD	*gwchar;
*       WORD	*ghchar;
*       WORD	*gwbox;
*       WORD	*ghbox;
*  {
*    *gwchar = gl_wchar;
*    *ghchar = gl_hchar;
*    *gwbox = gl_wbox;
*    *ghbox = gl_hbox;
*    return(gl_handle);
*  }
*
	.globl _gr_handl
	.text
_gr_handl:
	lea	4(sp),a1
	move.l	(a1)+,a0
	move.w	_gl_wchar,(a0)
	move.l	(a1)+,a0
	move.w	_gl_hchar,(a0)
	move.l	(a1)+,a0
	move.w	_gl_wbox,(a0)
	move.l	(a1)+,a0
	move.w	_gl_hbox,(a0)
	move.w	_gl_handl,d0
	rts


*
*  VOID
*  graf_rubbox(xorigin, yorigin, wmin, hmin, pwend, phend)
*       WORD		xorigin, yorigin;
*       WORD		wmin, hmin;
*       WORD		*pwend, *phend;
*  {
*    gr_rubbox(xorigin, yorigin, wmin, hmin, pwend, phend);
*    dsptch();
*  }
*
	.globl _graf_rub
	.text
_graf_rub:
	lea	_gr_rubbo,a0		; a0 -> routine to call
	bra.b	copy16			; use common code to copy args


*
*  WORD
*  graf_mkstate(pmx, pmy, pmstate, pkstate)
*       WORD		*pmx, *pmy, *pmstate, *pkstate;
*  {
*    WORD		ret;
*    ret = gr_mkstate(pmx, pmy, pmstate, pkstate);
*    dsptch();
*    return(ret);
*  }
*
	.globl _graf_mks
	.text
_graf_mks:
	lea	_gr_mksta,a0		; a0 -> routine to call

copy16:	moveq	#4-1,d0			; copy 16 bytes of args
mkslab:	move.l	16(sp),-(sp)
	dbra	d0,mkslab
	jsr	(a0)			; call routine
	add.w	#16,sp
	bra	disp1


*
*  VOID         4     6     8     10    12 14 16 18
*  graf_growbox(orgx, orgy, orgw, orgh, x, y, w, h)
*       WORD		orgx, orgy, orgw, orgh;
*       WORD		x, y, w, h;
*  {
*    gr_growbox(&orgx, &x);
*    dsptch();
*  }
*  
	.globl _graf_gro
	.text
_graf_gro:
	lea	_gr_growb,a0
grafx:	pea	12(sp)
	pea	4+4(sp)
	jsr	(a0)
	addq	#8,sp
	bra	disp1


*
*  VOID           4     6     8     10    12 14 16 18
*  graf_shrinkbox(orgx, orgy, orgw, orgh, x, y, w, h)
*       WORD		orgx, orgy, orgw, orgh;
*       WORD		x, y, w, h;
*  {
*    gr_shrinkbox(&orgx, &x);
*    dsptch();
*  }
*  
	.globl _graf_shr
	.text
_graf_shr:
	lea	_gr_shrin,a0
	bra	grafx


*
*  WORD
*  menu_tnormal(mlist, dlist, normal)
*       LONG		mlist;
*       WORD		dlist,normal;
*  {
*    WORD		ret;
*    ret = do_chg(mlist, dlist, SELECTED, !normal, TRUE, TRUE);
*    dsptch();
*    return(ret);
*  }
*  
	.globl _menu_tno
	.text
_menu_tno:
	move.l	#$00010001,-(sp)	; TRUE, TRUE
	moveq	#1,d1
	tst.w	10+4(sp)		; !normal
	seq	d0
	and.w	d1,d0
	move.w	d0,-(sp)
	move.w	d1,-(sp)		; SELECTED
menx1:	move.w	8+8(sp),-(sp)		; dlist
menx:	move.l	4+10(sp),-(sp)		; mlist *CS*
	jsr	_do_chg
	add.w	#14,sp
	bra	disp1


*
*  WORD     4     8
*  menu_bar(tree, showit)
*       LONG		tree;
*       WORD		showit;
*  {
*    WORD		ret;
*    ret = mn_bar(tree, showit);
*    dsptch();
*    return(ret);
*  }
*
	.globl _menu_bar
	.text
_menu_bar:
	move.w	8(sp),-(sp)		; showit
	move.l	4+2(sp),-(sp)		; tree
	jsr	_mn_bar
	addq	#6,sp
	bra	disp1


*
*  WORD	       4      8      10
*  menu_icheck(mlist, dlist, check)
*       LONG		mlist;
*       WORD		dlist,check;
*  {
*    WORD		ret;
*    ret = do_chg(mlist, dlist, CHECKED, check, FALSE, FALSE);
*    dsptch();
*    return(ret);
*  }
*
	.globl _menu_ich
	.text
_menu_ich:
	clr.l	-(sp)			; FALSE FALSE		0
	move.w	10+4(sp),-(sp)		; check			4
	move.w	#4,-(sp)		; CHECKED		6
	bra	menx1


*
*  WORD	
*  menu_ienable(mlist, dlist, enable) 
*       LONG		mlist;
*       WORD		dlist,enable;
*  {
*    WORD		ret;
*    ret = do_chg(mlist, (dlist & 0x7fff), DISABLED, !enable,
*  	       ((dlist & 0x8000) != 0x0), FALSE);
*    dsptch();
*    return(ret);
*  }
*
	.globl _menu_ien
	.text
_menu_ien:
	moveq	#1,d2			; (mask for bools)
	clr.w	-(sp)			; FALSE				+2
	move.w	8+2(sp),d0
	smi	d0
	and.w	d2,d0
	move.w	d0,-(sp)		; (bool)!(dlist & 0x8000)	+4
	tst.w	10+4(sp)
	seq	d0
	and.w	d2,d0
	move.w	d0,-(sp)		; !enable			+6
	move.w	#8,-(sp)		; DISABLED			+8
	move.w	8+8(sp),d0
	and.w	#$7fff,d0
	move.w	d0,-(sp)		; dlist & 0x7fff		+10
	bra	menx


*
*  WORD
*  objc_offset(tree, obj, poffx, poffy)
*       LONG		tree;
*       WORD		obj;
*       WORD		*poffx, *poffy;
*  {
*    WORD		ret;
*    ret = ob_offset(tree, obj, poffx, poffy);
*    dsptch();
*    return(ret);
*  }
*
	.globl _objc_off
	.text
_objc_off:
	lea	_ob_offse,a0
	bra	copy16


*
*  WORD
*  objc_order(tree, mov_obj, newpos)
*       LONG		tree;
*       WORD		mov_obj, newpos;
*  {
*    WORD		ret;
*    ret = ob_order(tree, mov_obj, newpos);
*    dsptch();
*    return(ret);
*  }
*
	.globl _objc_ord
	.text
_objc_ord:
	lea	_ob_order,a0
	bra	copy16


*
*  WORD
*  objc_find(tree, startob, depth, mx, my)
*       LONG		tree;
*       WORD		startob, depth, mx, my;
*  {
*    WORD		ret;
*    ret = ob_find(tree, startob, depth, mx, my);
*    dsptch();
*    return(ret);
*  }
*
	.globl _objc_fin
	.text
_objc_fin:
	lea	_ob_find,a0
	bra	copy16


*
*  WORD
*  objc_add(tree, parent, child)
*       LONG		tree;
*       WORD		parent, child;
*  {
*    WORD		ret;
*    ret = ob_add(tree, parent, child);
*    dsptch();
*    return(ret);
*  }
*
	.globl _objc_add
	.text
_objc_add:
	lea	_ob_add,a0
	bra	copy16


*
*  WORD	     4     8       10     12  14  16  18
*  objc_draw(tree, drawob, depth, xc, yc, wc, hc)
*       LONG		tree;
*       WORD		drawob, depth;
*       WORD		xc, yc, wc, hc;
*  {
*    WORD		ret;
*    gsx_sclip(&xc);
*    ret = ob_draw(tree, drawob, depth);
*    dsptch();
*    return(ret);
*  }
*
	.globl _objc_dra
	.text
_objc_dra:
	pea	12(sp)
	jsr	_gsx_scli
	addq	#4,sp
	lea	_ob_draw,a0
	bra	copy16


*
*  WORD		4    8       10     12  14  16  18  20		22
*  objc_change(tree, drawob, depth, xc, yc, wc, hc, newstate, redraw)
*       LONG		tree;
*       WORD		drawob, depth;
*       WORD		xc, yc, wc, hc;
*       WORD		newstate, redraw;
*  {
*    WORD		ret;
*    gsx_sclip(&xc);
*    ret = ob_change( tree, drawob, newstate, redraw);
*    dsptch();
*    return(ret);
*  }
*
	.globl _objc_cha
	.text
_objc_cha:
	pea	12(sp)			;				+4
	jsr	_gsx_scli
	move.l	20+4(sp),-(sp)		; newstate, redraw		+8
	move.w	8+8(sp),-(sp)		; drawob			+10
	move.l	4+10(sp),-(sp)		; tree				+14
	jsr	_ob_chang
	add.w	#14,sp
	bra	disp1


*
*  WORD
*  rsrc_free()
*  {
*    WORD		ret;
*    ret = rs_free( pglobal);
*    dsptch();
*    return(ret);
*  }
*
	.globl _rsrc_fre
	.text
_rsrc_fre:
	pea	_pglobal
	jsr	_rs_free
	addq	#4,sp
	bra	disp1


*
*  WORD		4     6     8
*  rsrc_gaddr(rstype, rsid, paddr)
*       WORD		rstype;
*       WORD		rsid;
*       LONG		*paddr;
*  {
*    WORD		ret;
*    ret = rs_gaddr( pglobal, rstype, rsid, paddr);
*    dsptch();
*    return(ret);
*  }
*  
	.globl _rsrc_gad
	.text
_rsrc_gad:
	move.l	8(sp),-(sp)		; paddr				+4
	move.l	4+4(sp),-(sp)		; rstype, rsid			+4
	pea	_pglobal		; &pglobal			+4
	jsr	_rs_gaddr
	add.w	#12,sp
	bra	disp1


*
*  WORD
*  shel_write(doex, isgr, iscr, pcmd, ptail)
*       WORD		doex, isgr, iscr;
*       LONG		pcmd, ptail;
*  {
*    WORD		ret;
*    ret = sh_write(doex, isgr, iscr, pcmd, ptail);
*    dsptch();
*    return(ret);
*  }
*
	.globl _shel_wri
	.text
_shel_wri:
	lea	_sh_write,a0
	bra	copy16


*
*  WORD
*  shel_get(pbuffer, len)
*       LONG		 pbuffer;
*       WORD		len;
*  {
*    WORD		ret;
*    ret = sh_get(pbuffer, len);
*    dsptch();
*    return(ret);
*  }
*
	.globl _shel_get
	.text
_shel_get:
	lea	_sh_get,a0
	bra	copy16


*
*  WORD
*  shel_put(pdata, len)
*       LONG		pdata;
*       WORD		len;
*  {
*    WORD		ret;
*    ret = sh_put(pdata, len);
*    dsptch();
*    return(ret);
*  }
*
	.globl _shel_put
	.text
_shel_put:
	lea	_sh_put,a0
	bra	copy16


*
*  WORD
*  wind_close(handle)
*       WORD		handle;
*  {
*    WORD		ret;
*    ret = wm_close(handle);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_clo
	.text
_wind_clo:
	lea	_wm_close,a0
	bra	copy16


*
*  WORD
*  wind_delete(handle)
*       WORD		handle;
*  {
*    WORD		ret;
*    ret = wm_delete(handle);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_del
	.text
_wind_del:
	lea	_wm_delet,a0
	bra	copy16


*
*  WORD
*  wind_find(mx, my)
*       WORD		mx, my;
*  {
*    WORD		ret;
*    ret = wm_find(mx,my);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_fin
	.text
_wind_fin:
	lea	_wm_find,a0
	bra	copy16


*
*  WORD
*  wind_update(beg_update)
*       WORD		beg_update;
*  {
*    WORD		ret;
*    ret = wm_update(beg_update);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_upd
	.text
_wind_upd:
	lea	_wm_updat,a0
	bra	copy16


*
*  WORD		4    6   8   10  12
*  wind_create(kind, wx, wy, ww, wh)
*       UWORD		kind;
*       WORD		wx, wy, ww, wh;
*  {
*    WORD		ret;
*    ret = wm_create(kind, &wx);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_cre
	.text
_wind_cre:
	lea	_wm_creat,a0
windx:	pea	6(sp)			; &wx				+4
	move.w	4+4(sp),-(sp)		; kind				+4
	jsr	(a0)
	addq	#6,sp
	bra	disp1


*
*  WORD
*  wind_open(handle, wx, wy, ww, wh)
*       WORD		handle;
*       WORD		wx, wy, ww, wh;
*  {
*    WORD		ret;
*    ret = wm_open( handle, &wx);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_ope
	.text
_wind_ope:
	lea	_wm_open,a0
	bra	windx


*
*  WORD
*  wind_get(w_handle, w_field, pw1, pw2, pw3, pw4)
*       WORD		w_handle;
*       WORD		w_field;
*       WORD		*pw1, *pw2, *pw3, *pw4;
*  {
*    WORD		wm_ox[4];
*    WORD		ret;
*    
*    ret = wm_get(w_handle, w_field, &wm_ox);
*    dsptch();
*    *pw1 = wm_ox[0];
*    *pw2 = wm_ox[1];
*    *pw3 = wm_ox[2];
*    *pw4 = wm_ox[3];
*    return(ret);
*  }
*
	.globl _wind_get
	.text
_wind_get:
	link	a6,#-8
	pea	-8(a6)
	move.l	8(a6),-(sp)		; w_handle, w_field
	jsr	_wm_get
	lea	12(a6),a2		; -> vector of ptrs
	bra	cplp4a			; go copy 4 integers


*
*  WORD	    4         6        8+
*  wind_set(w_handle, w_field, w2, w3, w4, w5)
*       WORD		w_handle;	
*       WORD		w_field;
*       WORD		w2, w3, w4, w5;
*  {
*    WORD		ret;
*    ret = wm_set( w_handle, w_field, &w2);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_set
	.text
_wind_set:
	pea	8(sp)			; &w2
	move.l	4+4(sp),-(sp)		; w_handle, w_field
	jsr	_wm_set
	addq.l	#8,sp
	bra	disp1


*
*  WORD
*  wind_calc(wctype, kind, x, y, w, h, px, py, pw, ph)
*       WORD		wctype;
*       UWORD		kind;
*       WORD		x, y, w, h;
*       WORD		*px, *py, *pw, *ph;
*  {
*    WORD		ret;
*    ret = wm_calc(wctype, kind, x, y, w, h, px, py, pw, ph);
*    dsptch();
*    return(ret);
*  }
*
	.globl _wind_cal
	.text
_wind_cal:
	moveq	#7-1,d0			; copy 7 longs of args
wndcp:	move.l	28(sp),-(sp)
	dbra	d0,wndcp
	jsr	_wm_calc
	adda.l	#28,sp
	bra	disp1


	.end
