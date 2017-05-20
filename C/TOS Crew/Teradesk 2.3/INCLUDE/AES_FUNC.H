/*	AES.H
	
	GEM AES Function Definitions
	optionally invoked by np_aeas.h
	
	mrt 1992 & apr 2002 H. Robbers Amsterdam
 */

#ifndef AES_FUNC_H
#define AES_FUNC_H

/****** Application definitions ************************************************/

G_w G_decl G_nv(appl_init);
G_w G_decl G_n(appl_read)( G_w ap_rid, G_w ap_rlength, void *ap_rpbuff dglob);
G_w G_decl G_n(appl_write)( G_w ap_wid, G_w ap_wlength, void *ap_wpbuff  dglob);
G_w G_decl G_n(appl_find)( const char *ap_fpname  dglob);
G_w G_decl G_n(appl_tplay)( void *ap_tpmem, G_w ap_tpnum, G_w ap_tpscale  dglob);
G_w G_decl G_n(appl_trecord)( void *ap_trmem, G_w ap_trcount  dglob);
G_w G_decl G_nv(appl_exit);
G_w G_decl G_n(appl_search)( G_w ap_smode, char *ap_sname, G_w *ap_stype,
						G_w *ap_sid  dglob);
G_w G_decl G_n(appl_getinfo)( G_w ap_gtype, G_w *ap_gout1, G_w *ap_gout2,
						 G_w *ap_gout3, G_w *ap_gout4  dglob);

#define	appl_bvset( disks, harddisks ) /* Funktion ignorieren (GEM fr Dose): void appl_bvset( G_w disks, G_w harddisks ); */

#define	vq_aes()	( appl_init() >= 0 )	/* WORD	vq_aes( void ); */


/****** Event definitions ************************************************/

#if !G_MODIFIED
G_w G_decl G_nv(evnt_keybd);
G_w G_decl G_n(evnt_button)(	G_w ev_bclicks, G_w ev_bmask, G_w ev_bstate,
					G_w *ev_bmx, G_w *ev_bmy, G_w *ev_bbutton,
					G_w *ev_bkstate dglob);
G_w G_decl G_n(evnt_mouse)( G_w ev_moflags, G_w ev_mox, G_w ev_moy,
				G_w ev_mowidth, G_w ev_moheight, G_w *ev_momx,
				G_w *ev_momy, G_w *ev_mobutton,
				G_w *ev_mokstate dglob);
G_w G_decl G_n(evnt_mesag)( G_w *ev_mgpbuff dglob );
G_w G_decl G_n(evnt_timer)( G_i ev_tlocount, G_i ev_thicount dglob );
G_w G_decl G_n(evnt_multi)( G_w ev_mflags, G_w ev_mbclicks, G_w ev_mbmask,
				G_w ev_mbstate, G_w ev_mm1flags, G_w ev_mm1x,
				G_w ev_mm1y, G_w ev_mm1width, G_w ev_mm1height,
				G_w ev_mm2flags, G_w ev_mm2x, G_w ev_mm2y,
				G_w ev_mm2width, G_w ev_mm2height,
				G_w *ev_mmgpbuff, G_i ev_mtlocount,
				G_i ev_mthicount, G_w *ev_mmox, G_w *ev_mmoy,
				G_w *ev_mmbutton, G_w *ev_mmokstate,
				G_w *ev_mkreturn, G_w *ev_mbreturn dglob );
G_w G_decl G_n(evnt_dclick)( G_w ev_dnew, G_w ev_dgetset dglob );
#else
G_w G_decl G_nv(evnt_keybd);
G_w G_decl G_n(evnt_button)(G_w clks,G_w mask,G_w state,
                EVNTDATA *ev dglob);
G_w G_decl G_n(evnt_mouse)(G_w flags, GRECT *g, EVNTDATA *ev dglob);
G_w G_decl G_n(evnt_mesag)( G_w *ev_mgpbuff dglob );
G_w G_decl G_n(evnt_timer)(unsigned long ms dglob);
G_w G_decl G_n(evnt_multi)(G_w flags,G_w clks,G_w mask,G_w state,
               G_w m1flags,GRECT *g1,
               G_w m2flags,GRECT *g2,
               G_w *msgpipe,
               unsigned long ms,
               EVNTDATA *ev,
               G_w *toets,G_w *oclks dglob);
G_w G_decl G_n(evnt_dclicks)(G_w new,G_w getset dglob);
#endif
#if G_EXT
void G_n(EVNT_multi)( G_w evtypes, G_w nclicks, G_w bmask, G_w bstate,
							MOBLK *m1, MOBLK *m2, G_ul ms,
							EVNT *event dglob );
#endif

/****** Menu definitions ************************************************/

G_w G_decl G_n(menu_bar)( OBJECT *me_btree, MBAR_DO me_bshow dglob);
G_w G_decl G_n(menu_icheck)( OBJECT *me_ctree, G_w me_citem, G_w me_ccheck dglob);
G_w G_decl G_n(menu_ienable)( OBJECT *me_etree, G_w me_eitem, G_w me_eenable dglob);
G_w G_decl G_n(menu_tnormal)( OBJECT *me_ntree, G_w me_ntitle, G_w me_nnormal dglob);
G_w G_decl G_n(menu_text)( OBJECT *me_ttree, G_w me_titem, const char *me_ttext dglob);
G_w G_decl G_n(menu_register)( G_w me_rapid, const char *me_rpstring dglob);
G_w G_decl G_n(menu_popup)( MENU *me_menu, G_w me_xpos, G_w me_ypos, MENU *me_mdata dglob);
G_w G_decl G_n(form_popup)( OBJECT *tree, G_w x, G_w y dglob);
#if G_EXT
G_w G_decl G_n(menu_click)(G_w val, G_w setflag dglob);
G_w G_decl G_n(menu_attach)( G_w me_flag, OBJECT *me_tree, G_w me_item, MENU *me_mdata dglob);
G_w G_decl G_n(menu_istart)( G_w me_flag, OBJECT *me_tree, G_w me_imenu, G_w me_item dglob);
G_w G_decl G_n(menu_settings)( G_w me_flag, MN_SET *me_values dglob);
#endif

/****** Object definitions ************************************************/

G_w G_decl G_n(objc_add)( OBJECT *ob_atree, G_w ob_aparent, G_w ob_achild dglob);
G_w G_decl G_n(objc_delete)( OBJECT *ob_dltree, G_w ob_dlobject dglob);
G_w G_decl G_n(objc_draw)( OBJECT *ob_drtree, G_w ob_drstartob,
               G_w ob_drdepth, G_w ob_drxclip, G_w ob_dryclip,
               G_w ob_drwclip, G_w ob_drhclip dglob);
G_w G_decl G_n(objc_find)( OBJECT *ob_ftree, G_w ob_fstartob, G_w ob_fdepth,
               G_w ob_fmx, G_w ob_fmy dglob);
G_w G_decl G_n(objc_offset)( OBJECT *ob_oftree, G_w ob_ofobject,
                 G_w *ob_ofxoff, G_w *ob_ofyoff dglob);
G_w G_decl G_n(objc_order)( OBJECT *ob_ortree, G_w ob_orobject,
                G_w ob_ornewpos dglob);
G_w G_decl G_n(objc_edit)( OBJECT *ob_edtree, G_w ob_edobject,
               G_w ob_edchar, G_w *ob_edidx, G_w ob_edkind dglob);
#if G_EXT
G_w G_decl G_n(objc_xedit)(void *tree,G_w item,G_w edchar,G_w *idx,G_w kind,
			GRECT *r dglob);
#endif
#if !G_MODIFIED
G_w G_decl G_n(objc_change)( OBJECT *ob_ctree, G_w ob_cobject,
                 G_w ob_cresvd, G_w ob_cxclip, G_w ob_cyclip,
                 G_w ob_cwclip, G_w ob_chclip,
                 G_w ob_cnewstate, G_w ob_credraw dglob);
#else
G_w G_decl G_n(objc_change)(void *tree,
	G_w item,G_w resvd,GRECT *r,G_w newst,G_w redraw dglob);
#endif
G_w G_decl G_n(objc_sysvar)
			   (G_w mo, G_w which, G_w ival1,
				G_w ival2, G_w *oval1, G_w *oval2 dglob);


/****** Form definitions ************************************************/

G_w G_decl G_n(form_do)( OBJECT *fo_dotree, G_w fo_dostartob dglob);
#if G_EXT
G_w G_decl G_n(form_xdo)(OBJECT *tree, G_w item, G_w *curob, XDO_INF *scantab, void *flyinf dglob);
G_w	G_decl G_n(form_xdial)(G_w subfn, GRECT *lg, GRECT *bg, void **flyinf dglob);
#endif
#if !G_MODIFIED
G_w G_decl G_n(form_dial)(G_w flag,G_w lx,G_w ly,G_w lw,G_w lh,
                                   G_w bx,G_w by,G_w bw,G_w bh dglob);
#else
G_w	G_decl G_n(form_dial)(G_w subfn, GRECT *lg, GRECT *bg dglob);
#endif
#if G_EXT
G_w	G_decl G_n(form_xdial)(G_w subfn, GRECT *lg,
				GRECT *bg, void **flyinf dglob);
#endif
G_w G_decl G_n(form_alert)( G_w fo_adefbttn, const char *fo_astring dglob);
G_w G_decl G_n(form_error)( G_w fo_enum dglob);
G_w G_decl G_n(form_center)( OBJECT *fo_ctree, G_w *fo_cx, G_w *fo_cy,
                 G_w *fo_cw, G_w *fo_ch dglob);
G_w G_decl G_n(form_keybd)( OBJECT *fo_ktree, G_w fo_kobject, G_w fo_kobnext,
                G_w fo_kchar, G_w *fo_knxtobject, G_w *fo_knxtchar dglob);
G_w G_decl G_n(form_button)( OBJECT *fo_btree, G_w fo_bobject, G_w fo_bclicks,
                G_w *fo_bnxtobj dglob);


/****** Graph definitions ************************************************/

G_w G_decl G_n(graf_rubberbox)( G_w gr_rx, G_w gr_ry, G_w gr_minwidth,
                    G_w gr_minheight, G_w *gr_rlastwidth,
                    G_w *gr_rlastheight dglob);
G_w G_decl G_n(graf_rubbox)( G_w gr_rx, G_w gr_ry, G_w gr_minwidth,
                    G_w gr_minheight, G_w *gr_rlastwidth,
                    G_w *gr_rlastheight dglob);
#if !G_MODIFIED
G_w G_decl G_n(graf_dragbox)( G_w gr_dwidth, G_w gr_dheight,
                  G_w gr_dstartx, G_w gr_dstarty,
                  G_w gr_dboundx, G_w gr_dboundy,
                  G_w gr_dboundw, G_w gr_dboundh,
                  G_w *gr_dfinishx, G_w *gr_dfinishy dglob);
#else
G_w G_decl G_n(graf_dragbox)(G_w dw,G_w dh,G_w dx,G_w dy,
                 GRECT *g,
                 G_w *ex,G_w *ey dglob);
#endif
G_w G_decl G_n(graf_movebox)( G_w gr_mwidth, G_w gr_mheight,
                  G_w gr_msourcex, G_w gr_msourcey,
                  G_w gr_mdestx, G_w gr_mdesty dglob);
G_w G_decl G_n(graf_mbox)( G_w gr_mwidth, G_w gr_mheight,
                  G_w gr_msourcex, G_w gr_msourcey,
                  G_w gr_mdestx, G_w gr_mdesty dglob);
#if !G_MODIFIED
G_w G_decl G_n(graf_growbox)( G_w gr_gstx, G_w gr_gsty,
                  G_w gr_gstwidth, G_w gr_gstheight,
                  G_w gr_gfinx, G_w gr_gfiny,
                  G_w gr_gfinwidth, G_w gr_gfinheight dglob);
G_w G_decl G_n(graf_shrinkbox)( G_w gr_sfinx, G_w gr_sfiny,
                    G_w gr_sfinwidth, G_w gr_sfinheight,
                    G_w gr_sstx, G_w gr_ssty,
                    G_w gr_sstwidth, G_w gr_sstheight dglob);
#else
G_w G_decl G_n(graf_growbox)(GRECT *sr, GRECT *er dglob);
G_w G_decl G_n(graf_shrinkbox)(GRECT *sr, GRECT *er dglob);
#endif
G_w G_decl G_n(graf_watchbox)( OBJECT *gr_wptree, G_w gr_wobject,
                   G_w gr_winstate, G_w gr_woutstate dglob);
G_w G_decl G_n(graf_slidebox)( OBJECT *gr_slptree, G_w gr_slparent,
                   G_w gr_slobject, G_w gr_slvh dglob);
G_w G_decl G_n(graf_handle)( G_w *gr_hwchar, G_w *gr_hhchar,
                 G_w *gr_hwbox, G_w *gr_hhbox dglob);
#if G_EXT
G_w G_decl G_n(graf_xhandle)(G_w *wchar,G_w *hchar,G_w *wbox,G_w *hbox,G_w *device dglob);
#endif
G_w G_decl G_n(graf_mouse)( G_w gr_monumber, MFORM *gr_mofaddr dglob);
#if !G_MODIFIED
G_w G_decl G_n(graf_mkstate)( G_w *gr_mkmx, G_w *gr_mkmy,
                  G_w *gr_mkmstate, G_w *gr_mkkstate dglob);
#else
G_w G_decl G_n(graf_mkstate)(EVNTDATA *ev dglob);
#endif

/****** Scrap definitions ***********************************************/

G_w G_decl scrp_read( char *sc_rpscrap );
G_w G_decl scrp_write( char *sc_wpscrap );


/****** File selector definitions ***************************************/

G_w G_decl G_n(fsel_input)( char *fs_iinpath, char *fs_iinsel,
                G_w *fs_iexbutton dglob);
G_w G_decl G_n(fsel_exinput)( char *fs_einpath, char *fs_einsel,
                G_w *fs_eexbutton, char *fs_elabel dglob);


/****** Window definitions **********************************************/

#if !G_MODIFIED
G_w G_decl G_n(wind_create)( G_w wi_crkind, G_w wi_crwx, G_w wi_crwy,
                 G_w wi_crww, G_w wi_crwh dglob);
G_w G_decl G_n(wind_open)( G_w wi_ohandle, G_w wi_owx, G_w wi_owy,
               G_w wi_oww, G_w wi_owh dglob);
G_w G_decl G_n(wind_calc)( G_w wi_ctype, G_w wi_ckind, G_w wi_cinx,
               G_w wi_ciny, G_w wi_cinw, G_w wi_cinh,
               G_w *coutx, G_w *couty, G_w *coutw,
               G_w *couth dglob);
#else
G_w G_decl G_n(wind_create)(G_w kind, GRECT *r dglob);
G_w G_decl G_n(wind_open  )(G_w whl,  GRECT *r dglob);
G_w G_decl G_n(wind_calc)(G_w ty,G_w srt, GRECT *ri, GRECT *ro dglob);
#endif
G_w G_decl G_n(wind_close)( G_w wi_clhandle dglob);
G_w G_decl G_n(wind_delete)( G_w wi_dhandle dglob);
#if __WGS_ELLIPSISD__
G_w wind_get( G_w wi_ghandle, G_w wi_gfield, ... );
G_w wind_set( G_w wi_shandle, G_w wi_sfield, ... );
#else
G_w G_decl G_n(wind_get)( G_w wi_ghandle, G_w wi_gfield, G_w, G_w, G_w, G_w dglob);
G_w G_decl G_n(wind_set)( G_w wi_shandle, G_w wi_sfield, G_w *, G_w *, G_w *, G_w * dglob);
#endif
#if G_EXT
G_w G_decl G_n(wind_get_grect) (G_w whl, G_w srt, GRECT *g dglob);
G_w G_decl G_n(wind_get_int)   (G_w whl, G_w srt, G_w *g1 dglob);
G_w G_decl G_n(wind_get_ptr)   (G_w whl, G_w srt, void **v dglob);
G_w G_decl G_n(wind_set_string)(G_w whl, G_w srt, char *s dglob);
G_w G_decl G_n(wind_set_grect) (G_w whl, G_w srt, GRECT *r dglob);
G_w G_decl G_n(wind_set_int)   (G_w whl, G_w srt, G_w i dglob);
G_w G_decl G_n(wind_set_ptr_int)(G_w whl,G_w srt, void *s, G_w g dglob);
#endif
G_w G_decl G_n(wind_find)( G_w wi_fmx, G_w wi_fmy dglob);
G_w G_decl G_n(wind_update)( G_w wi_ubegend dglob);
void G_decl G_nv(wind_new);


/****** Resource definitions ********************************************/

G_w G_decl G_n(rsrc_load)( const char *re_lpfname dglob);
G_w G_decl G_nv(rsrc_free);
G_w G_decl G_n(rsrc_gaddr)( G_w re_gtype, G_w re_gindex, void *gaddr dglob);
G_w G_decl G_n(rsrc_saddr)( G_w re_stype, G_w re_sindex, void *saddr dglob);
G_w G_decl G_n(rsrc_obfix)( OBJECT *re_otree, G_w re_oobject dglob);
G_w G_decl G_n(rsrc_rcfix)( RSHDR *rc_header dglob);


/****** Shell definitions ***********************************************/

G_w G_decl G_n(shel_read)( char *sh_rpcmd, char *sh_rptail dglob);
G_w G_decl G_n(shel_write)( G_w sh_wdoex, G_w sh_wisgr, G_w sh_wiscr,
                char *sh_wpcmd, char *sh_wptail dglob);
G_w G_decl G_n(shel_get)( char *sh_gaddr, G_u sh_glen dglob);
G_w G_decl G_n(shel_put)( char *sh_paddr, G_u sh_plen dglob);
G_w G_decl G_n(shel_find)( char *sh_fpbuff dglob);
G_w G_decl G_n(shel_envrn)( char **sh_epvalue, char *sh_eparm dglob);
#if G_EXT
G_w G_decl G_n(shel_rdef)( char *fname, char *dir dglob);
G_w G_decl G_n(shel_wdef)( char *fname, char *dir dglob);
#endif

/****** Miscellaneous definitions ***********************************************/

void adapt3d_rsrc( OBJECT *objs, G_w no_objs, G_w hor_3d, G_w ver_3d );
void    no3d_rsrc( OBJECT *objs, G_w no_objs, G_w ftext_to_fboxtext );
G_b *is_userdef_title( OBJECT *obj );
G_w	get_aes_info( G_w version, G_w *font_id, G_w *font_height, G_w *hor_3d, G_w *ver_3d );
void substitute_objects( OBJECT *objs, G_w no_objs, G_w aes_flags, OBJECT *rslct, OBJECT *rdeslct );
void substitute_free(void);


#endif /* AES_FUNC_H */