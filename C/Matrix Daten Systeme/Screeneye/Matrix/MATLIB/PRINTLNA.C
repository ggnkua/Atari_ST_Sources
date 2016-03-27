# include <stdio.h>
# include <linea.h>

# include "printlna.h"


/*----------------------------------------------------- print_font -------*/
void print_font( FONT_HDR *fbase )
{
	if ( fbase == NULL )
		printf ( "0\n" ) ;
	else
		printf ( "$%8.8lx : #%d, S=%2d, \"%s\", $%2.2x..$%2.2x, W<=%d, H=%d\n",
			 fbase, fbase->id, fbase->size, fbase->facename,
			 fbase->ade_lo, fbase->ade_hi, fbase->wchr_wdt, fbase->frm_hgt ) ;
}

/*----------------------------------------------------- print_fonts -------*/
void print_fonts ( FONTS *f )
{
	int i ;
	
	printf ( "- Line A fonts at $%8.8lx :\n\n",	f ) ;
	
	for(i=0;i<3;i++)
	{
		printf ( " %d : ", i ) ;
		print_font( f->font[i] ) ;
	}
}

# define pa(a) printf( "$%4.4lx = %4d(LA) : ", &(a), (int)((long)&(a) - (long)l) )

/*----------------------------------------------------- print_lina_fonts ----*/
void print_lina_fonts ( LINEA *l, VDIESC *v )
{
	pa ( v->def_font     ) ; printf ( "def_font     = " ) ;	print_font( v->def_font ) ;
	pa ( v->font_ring[0] ) ; printf ( "font_ring 1  = " ) ;	print_font( v->font_ring[0] ) ;
	pa ( v->font_ring[1] ) ; printf ( "          2  = " ) ;	print_font( v->font_ring[1] ) ;
	pa ( v->font_ring[2] ) ; printf ( "          3  = " ) ;	print_font( v->font_ring[2] ) ;
	pa ( v->font_ring[3] ) ; printf ( "          4  = " ) ;	print_font( v->font_ring[3] ) ;
	pa ( v->font_count ) ; printf ( "font_count   = %d\n", 		    v->font_count ) ;
}

/*----------------------------------------------------- print_vdi_esc -------*/
void print_vdi_esc ( LINEA *l, VDIESC *v )

{
	int i, j ;
	
	printf ( "- Line A ( VDI esc ) vars at $%8.8lx :\n\n",	v ) ;

	pa ( v->reserved6 ) ; printf ( "reserved6    = $%8.8lx\n", 		v->reserved6 ) ;
	pa ( v->cur_font ) ; printf ( "cur_font     = " ) ;	print_font( v->cur_font ) ;
	pa ( v->reserved5[0] ) ; printf ( "reserved5[0..] =" ) ;
	for(i=0;i<16;i++)
		printf ( " %4d",v->reserved5[i] ) ;
	printf ( "\n" ) ;
	pa ( v->reserved5[16] ) ; printf ( "reserved5[16..] =" ) ;
	for(i=16;i<23;i++)
		printf ( " %4d",v->reserved5[i] ) ;
	printf ( "\n" ) ;
	pa ( v->m_pos_hx ) ;	printf ( "m_pos_hx/y   = %d, %d\n", 		v->m_pos_hx, v->m_pos_hy ) ;
	pa ( v->m_planes ) ;	printf ( "m_planes     = %d\n", 		    v->m_planes ) ;
	pa ( v->m_cdb_bg ) ;	printf ( "m_cdb_b/fg   = %d, %d\n", 		v->m_cdb_bg, v->m_cdb_fg ) ;
	pa ( v->mask_form[0] );	printf ( "mask_form[]  = ...\n" ) ;
	pa ( v->inq_tab[0] ) ;	printf ( "inq_tab[]    = ...\n" ) ;
	pa ( v->dev_tab[0] ) ;	printf ( "dev_tab[]    = ..." ) ;
# define work_out	v->dev_tab
# if 1
/* v_opnwk 	*/
		printf ( "\n  max x/y           %6d,%6d",	work_out[0], work_out[1] ) ;
		printf ( "\n  Skalierungsflag   %6d", 		work_out[2] ) ;
		printf ( "\n  pixel w/h         %6d,%6d",	work_out[3], work_out[4] ) ;
		printf ( "\n  #-hts             %6d", 		work_out[5] ) ;
		printf ( "\n  #-ltyps           %6d", 		work_out[6] ) ;
		printf ( "\n  #-wdts            %6d", 		work_out[7] ) ;
		printf ( "\n  #-mtyps           %6d", 		work_out[8] ) ;
		printf ( "\n  #-msizs           %6d", 		work_out[9] ) ;
		printf ( "\n  #-fnts            %6d", 		work_out[10] ) ;
		printf ( "\n  #-fils            %6d", 		work_out[11] ) ;
		printf ( "\n  #-cols            %6d", 		work_out[13] ) ;
		printf ( "\n  #-fcts            %6d", 		work_out[14] ) ;
		printf ( "\n  GDPs             " ) ; for ( i=15; i<=24; i++ ) printf ( " %6d", work_out[i] ) ;
 		printf ( "\n  attr             " ) ; for ( i=25; i<=34; i++ ) printf ( " %6d", work_out[i] ) ;
		printf ( "\n  can-color         %6d", 		work_out[35] ) ;
		printf ( "\n  36..             " ) ; for ( i=36; i<=38; i++ ) printf ( " %6d", work_out[i] ) ;
		printf ( "\n  #colors           %6d", 		work_out[39] ) ;
		printf ( "\n  40..             " ) ; for ( i=40; i<=45; i++ ) printf ( " %6d", work_out[i] ) ;
# else
	for ( i=0; i<44; i++ )
	{
		if ( ( i % 5 ) == 0 )
			printf ( "\n            [%d] : ", i ) ;
		printf ( " %6d", v->dev_tab[i] ) ;
	}
# endif
	printf ( "\n" ) ;
	pa ( v->gcurx ) ;		printf ( "gcurx/y      = %d, %d\n", 		v->gcurx, v->gcury ) ;
	pa ( v->m_hid_ct ) ;	printf ( "m_hid_ct     = %d\n", 		    v->m_hid_ct ) ;
	pa ( v->mouse_bt ) ;	printf ( "mouse_bt     = %d\n", 		    v->mouse_bt ) ;
	for(j=0;j<3;j++)
	{
		pa ( v->req_col[j][0] ) ; printf ( "req_col[%d][] =", j ) ;
		for(i=0;i<16;i++)
			printf ( " %4d",v->req_col[j][i] ) ;
		printf ( "\n" ) ;
	}
	pa ( v->siz_tab[0] ) ; printf ( "siz_tab[]    =" ) ;
	for(i=0;i<15;i++)
		printf ( " %4d", v->siz_tab[i] ) ;
	printf ( "\n" ) ;
	pa ( v->reserved4 ) ; printf ( "reserved4[]  = %d, %d\n",
		 		v->reserved4[0], v->reserved4[1] ) ;
	pa ( v->cur_work ) ; printf ( "cur_work     = $%8.8lx\n", 		v->cur_work ) ;

	print_lina_fonts ( l, v ) ;

	pa ( v->reserved3[0] ) ; printf ( "reserved3[]  = ...\n" ) ;
	pa ( v->cur_ms_stat ) ; printf ( "cur_ms_stat  = %2.2x\n", 		    v->cur_ms_stat ) ;
	pa ( v->v_hid_cnt ) ; printf ( "v_hid_cnt    = %d\n", 		    v->v_hid_cnt ) ;
	pa ( v->cur_x ) ; printf ( "cur_x/y      = %d, %d\n", 		v->cur_x, v->cur_y ) ;
	pa ( v->cur_flag ) ; printf ( "cur_flag     = %d\n", 		    v->cur_flag ) ;
	pa ( v->mouse_flag ) ; printf ( "mouse_flag   = %d\n", 		    v->mouse_flag ) ;
	pa ( v->reserved1 ) ; printf ( "reserved1    = $%8.8lx\n", 		v->reserved1 ) ;
	pa ( v->v_sav_xy[0] ) ; printf ( "v_sav_xy[]   = %d, %d\n", 	v->v_sav_xy[0], v->v_sav_xy[1] ) ;
	pa ( v->save_len ) ; printf ( "save_len     = %d\n", 		    v->save_len ) ;
	pa ( v->save_addr ) ; printf ( "save_addr    = $%8.8lx\n", 		v->save_addr ) ;
	pa ( v->save_stat ) ; printf ( "save_stat    = %d\n", 		    v->save_stat ) ;
	pa ( v->save_area ) ; printf ( "save_addr    = ...\n" ) ;

	pa ( v->user_tim ) ; printf ( "user_tim     = $%8.8lx\n", 		v->user_tim ) ;
	pa ( v->next_tim ) ; printf ( "next_tim     = $%8.8lx\n", 		v->next_tim ) ;
	pa ( v->user_but ) ; printf ( "user_but     = $%8.8lx\n", 		v->user_but ) ;
	pa ( v->user_cur ) ; printf ( "user_cur     = $%8.8lx\n", 		v->user_cur ) ;
	pa ( v->user_mot ) ; printf ( "user_mot     = $%8.8lx\n", 		v->user_mot ) ;

	pa ( v->v_cel_ht ) ; printf ( "v_cel_ht     = %d\n", 		    v->v_cel_ht ) ;
	pa ( v->v_cel_mx ) ; printf ( "v_cel_mx/y   = %d, %d\n", 	    v->v_cel_mx, v->v_cel_my ) ;
	pa ( v->v_cel_wr ) ; printf ( "v_cel_wr     = %d\n", 		    v->v_cel_wr ) ;
	pa ( v->v_col_bg ) ; printf ( "v_col_bg/fg  = %d, %d\n", 		v->v_col_bg, v->v_col_fg ) ;

	pa ( v->v_cur_ad ) ; printf ( "v_cur_ad     = $%8.8lx\n", 		v->v_cur_ad ) ;
	pa ( v->v_cur_off ) ; printf ( "v_cur_off    = %d\n", 		    v->v_cur_off ) ;
	pa ( v->v_cur_xy[0] ) ; printf ( "v_cur_xy[]   = %d, %d\n", 	v->v_cur_xy[0], v->v_cur_xy[1] ) ;

	pa ( v->v_period ) ; printf ( "v_period     = %d\n", 		    v->v_period ) ;
	pa ( v->v_cur_ct ) ; printf ( "v_cur_ct     = %d\n", 		    v->v_cur_ct ) ;
	pa ( v->v_fnt_ad ) ; printf ( "v_fnt_ad     = " ) ;	print_font( v->v_fnt_ad ) ;

	pa ( v->v_fnt_nd ) ; printf ( "v_fnt_nd/st  = $%2.2x\n",	    v->v_fnt_nd, v->v_fnt_st ) ;
	pa ( v->v_fnt_wd ) ; printf ( "v_fnt_wd     = %d\n", 		    v->v_fnt_wd ) ;
	pa ( v->v_rez_hz ) ; printf ( "v_rez_hz     = %d\n", 		    v->v_rez_hz ) ;
	pa ( v->v_off_ad ) ; printf ( "v_off_ad     = $%8.8lx\n", 		v->v_off_ad ) ;
	pa ( v->reserved ) ; printf ( "reserved     = %d\n", 		    v->reserved ) ;
	pa ( v->v_rez_vt ) ; printf ( "v_rez_vt     = %d\n", 		    v->v_rez_vt ) ;
	pa ( v->bytes_lin ) ; printf ( "bytes_lin    = %d\n", 		    v->bytes_lin ) ;
}

/*----------------------------------------------------- print_line_a -------*/
void print_line_a ( LINEA *l )
{
	printf ( "Line A vars at $%8.8lx :\n\n",	l ) ;
	
	pa ( l->v_planes ) ; printf ( "v_planes     = %d\n", 		l->v_planes ) ;
	pa ( l->v_lin_wr ) ; printf ( "v_lin_wr     = %d\n", 		l->v_lin_wr ) ;
	pa ( l->contrl ) ; printf ( "contrl       = $%8.8lx\n",	l->contrl ) ;
	pa ( l->intin ) ; printf ( "intin        = $%8.8lx\n",	l->intin ) ;
	pa ( l->ptsin ) ; printf ( "ptsin        = $%8.8lx\n",	l->ptsin ) ;
	pa ( l->intout ) ; printf ( "intout       = $%8.8lx\n",	l->intout ) ;
	pa ( l->ptsout ) ; printf ( "ptsout       = $%8.8lx\n",	l->ptsout ) ;
	pa ( l->fg_bp_1 ) ; printf ( "fg_bp_1..4   = %d %d %d %d\n",
				 l->fg_bp_1, l->fg_bp_2,
				 l->fg_bp_3, l->fg_bp_4 ) ;
	pa ( l->lstlin ) ; printf ( "lstlin       = %d\n",			l->lstlin ) ;
	pa ( l->ln_mask ) ; printf ( "ln_mask      = $%4.4x\n", 	l->ln_mask ) ;
	pa ( l->wrt_mode ) ; printf ( "wrt_mode     = %d\n", 		l->wrt_mode ) ;
	pa ( l->x1 ) ; printf ( "x/y1, x/y2   = %d, %d, %d, %d\n",
				l->x1, l->y1, l->x2, l->y2 ) ;
	pa ( l->patptr ) ; printf ( "patptr       = $%8.8lx\n",	l->patptr ) ;
	pa ( l->patmsk ) ; printf ( "patmsk       = $%4.4x\n", 	l->patmsk ) ;
	pa ( l->multifill ) ; printf ( "multifill    = %d\n", 		l->multifill ) ;
	pa ( l->clip ) ; printf ( "clip         = %d\n", 		l->clip ) ;
	pa ( l->xmn_clip ) ; printf ( "x/ymn/x_clip = %d, %d, %d, %d\n",
				l->xmn_clip, l->ymn_clip,
				l->xmx_clip, l->ymx_clip ) ;
	pa ( l->xacc_dda ) ; printf ( "xacc_dda     = %d\n",			l->xacc_dda ) ;
	pa ( l->dda_inc ) ; printf ( "dda_inc      = %d\n",			l->dda_inc ) ;
	pa ( l->t_sclsts ) ; printf ( "t_sclsts     = %d\n",			l->t_sclsts ) ;
	pa ( l->mono_status ) ; printf ( "mono_status  = %d\n",			l->mono_status ) ;
	pa ( l->sourcex ) ; printf ( "sourcex/y    = %d, %d\n",
				l->sourcex, l->sourcey ) ;
	pa ( l->destx ) ; printf ( "destx/y      = %d, %d\n",
				l->destx, l->desty ) ;
	pa ( l->delx ) ; printf ( "delx/y       = %d, %d\n",
				l->delx, l->dely ) ;
	pa ( l->fbase ) ; printf ( "fbase        = " ) ;
	print_font( l->fbase ) ;
	pa ( l->fwidth ) ; printf ( "fwidth       = %d\n",			l->fwidth ) ;
	pa ( l->style ) ; printf ( "style        = %d\n",			l->style ) ;
	pa ( l->litemask ) ; printf ( "litemask     = $%4.4x\n",		l->litemask ) ;
	pa ( l->skewmask ) ; printf ( "skewmask     = $%4.4x\n",		l->skewmask ) ;
	pa ( l->weight ) ; printf ( "weight       = %d\n",			l->weight ) ;
	pa ( l->r_off ) ; printf ( "r_off, l_off = %d, %d\n",
				l->r_off, l->l_off ) ;
	pa ( l->scale ) ; printf ( "scale        = %d\n",			l->scale ) ;
	pa ( l->chup ) ; printf ( "chup         = %d\n",			l->chup ) ;
	pa ( l->text_fg ) ; printf ( "text_fg      = %d\n",			l->text_fg ) ;
	pa ( l->scrtchp ) ; printf ( "scrtchp      = $%8.8lx\n",	l->scrtchp ) ;
	pa ( l->scrpt2 ) ; printf ( "scrpt2       = %d\n",			l->scrpt2 ) ;
	pa ( l->text_bg ) ; printf ( "text_bg      = %d\n",			l->text_bg ) ;
	pa ( l->copy_tran ) ; printf ( "copy_tran    = %d\n",			l->copy_tran ) ;
	pa ( l->fill_abort ) ; printf ( "fill_abort   = $%8.8lx\n",	l->fill_abort ) ;
}

