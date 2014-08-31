; ----------------------------------------------------------------------------
; File name:	TermWinG.I		Revision date:	1993.06.01
; Created by:	Ulf Ronald Andersson	Creation date:	1993.04.02
; ----------------------------------------------------------------------------
; Version:	0.9 (Beta)
; ----------------------------------------------------------------------------
; File purpose:	Devpac inclusion file for GST linking of TermWinG.Bin
;
; ----------------------------------------------------------------------------
; TermWin reference declarations:
;
	xref	tw_init		; tw_init(tw_lim&,wshandle&,glob_p%)
	xref	tw_exit		; tw_exit
	xref	tw_cell		; tw_cell(font%,satt&)
	xref	tw_menkey	; tw_menkey(code&)
	xref	tw_genkey	; tw_genkey(code%)
	xref	win_create	; win_create(gad&,tit_p%,inf_p%,x&,y&,w&,h&)
	xref	tw_open		; tw_open(windhand&,gad&,cols&,rows&)
	xref	tw_close	; tw_close(tw_hand&)
	xref	tw_update	; tw_update(mesag_p%)
	xref	gem2tw_		; gem2tw_(windhand&)
	xref	tw_2gem		; tw_2gem(tw_hand&)
	xref	tw_voff		; tw_voff(flag&)
	xref	tw_lock		; tw_lock(tw_hand&,lock&)
	xref	tw_escf		; tw_escf(tw_hand&)
	xref	tw_showc	; tw_showc(tw_hand&)
	xref	tw_hidec	; tw_hidec(tw_hand&)
	xref	tw_prot		; tw_prot(tw_hand&,prot&)
	xref	tw_font		; tw_font(tw_hand&,font%)
	xref	tw_satt		; tw_satt(tw_hand&,satt&)
	xref	tw_inv		; tw_inv(tw_hand&,inv&)
	xref	tw_wrap		; tw_wrap(tw_hand&,wrap&)
	xref	tw_colr		; tw_colr(tw_hand&,colr&)
	xref	tw_cdif		; tw_cdif(tw_hand&,cdif&)
	xref	tw_ibm_c	; tw_ibm_c(tw_hand&,ibmc&)
	xref	tw_setw		; tw_setw(tw_hand&,x&,y&,w&,h&)
	xref	tw_fixo		; tw_fixo(tw_hand&,x&,y&,w&,h&)
	xref	tw_find		; tw_find(x&,y&)
	xref	tw_pich		; tw_pich(tw_hand&,x&,y&)
	xref	tw_cich		; tw_cich(tw_hand&,col&,row&)
	xref	tw_seto		; tw_seto(tw_hand&)
	xref	tw_cout		; tw_cout(tw_hand&,data&)
	xref	tw_pout		; tw_pout(tw_hand&,V:data$)
	xref	tw_del		; tw_del(tw_hand&,cnt&)
	xref	tw_ins		; tw_ins(tw_hand&,cnt&)
	xref	tw_ldel		; tw_ldel(tw_hand&,cnt&)
	xref	tw_lins		; tw_lins(tw_hand&,cnt&)
	xref	tw_clrs		; tw_clrs(tw_hand&,code&)
	xref	tw_clrl		; tw_clrl(tw_hand&,code&)
	xref	tw_at		; tw_at(tw_hand&,column&,row&)
	xref	tw_rowx		; tw_rowx(tw_hand&)
	xref	tw_colx		; tw_colx(tw_hand&)
	xref	tw_caplk	; tw_caplk(tw_hand&,filehand&)
	xref	tw_capmd	; tw_capmd(tw_hand&,mode&)
;
;
; ----------------------------------------------------------------------------
; End of file:  TermWinG.I
; ----------------------------------------------------------------------------
