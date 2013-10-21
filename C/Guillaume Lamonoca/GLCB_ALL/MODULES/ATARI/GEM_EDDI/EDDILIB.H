/* Funktionsprototypen */
void  v_opnbm( WORD *work_in, MFDB *bitmap, WORD *handle, WORD *work_out );
void  v_clsbm( WORD handle );
void  vq_scrninfo( WORD handle, WORD *work_out );
void	_v_bez( WORD handle, WORD count, WORD *xyarr,
				 BYTE *bezarr, WORD *extent, WORD *totpts,
				 WORD *totmoves );
void	_v_bez_fill( WORD handle, WORD count, WORD *xyarr,
				 BYTE *bezarr, WORD *extent, WORD *totpts,
				 WORD *totmoves );
