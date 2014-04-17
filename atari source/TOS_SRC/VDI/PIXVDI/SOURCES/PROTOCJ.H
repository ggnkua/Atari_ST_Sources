/* PROTOTYPES FOR ASSEMBLY ROUTINES */


/* ALLGEM.S */
VOID	INIT_G( VOID );
VOID	DINIT_G( VOID );
WORD	GCHC_KEY( VOID );
WORD	GCHR_KEY( VOID );

/* BLITINIT.S */
WORD	GETBLT( VOID );


/* COPYRFM.S */
VOID	COPY_RFM( VOID );


/* GSXASM1.S */
VOID	ABLINE( VOID );
VOID	CLC_FLIT( VOID );
WORD	SMUL_DIV( VOID );
WORD	vec_len( WORD, WORD );



/* GSXASM2 */
LONG	trap( WORD, ... );
LONG	trap14( WORD, ... );
LONG	trap14b( WORD, ... );
WORD	end_pts( WORD xstart, WORD ystart, LONG *lptr, LONG *rptr );
VOID	fill_line( WORD, WORD, WORD );
WORD	get_pix( VOID );
VOID	RECTFILL( VOID );
VOID	TRNSFONT( VOID );


/* HBTXTBLT.S */
VOID	hb_text( VOID );


/* LINE1010.S */
BOOLEAN	retfalse( VOID );


/* MONO.S */
VOID	MONO8XH( VOID );


/* MOUSE.S*/
VOID	DIS_CUR( VOID );
VOID	HIDE_CUR( VOID );
VOID	SET_CUR( WORD newx, WORD newy );

/* PXTFORM.S */
VOID	PX_AND_INT_TRAN_FM( VOID );

/* SPXTXTBL.S */
VOID	cheat_blit( VOID );


/* TEXTBLT.S */
VOID	TEXT_BL( VOID );
WORD	ACT_SIZ( WORD );
WORD	CLC_DDA( WORD, WORD );




/* XFRMFORM.S */
VOID	TRAN_FM( VOID );
