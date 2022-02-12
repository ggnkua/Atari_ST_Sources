/*■□■□■□■ 複合スプライトのフレームデータ構造体 ■□■□■□■*/

typedef	struct	{
	short	vx;				/* 相対座標データ */
	short	vy;				/* 相対座標データ */
	short	pt;				/* スプライトパターンＮｏ．*/
	short	rv;				/* 反転コード */
} XOBJ_FRM_DAT ;


/*□■□■□■ 複合スプライトのリファレンスデータ構造体 □■□■□■*/

typedef	struct	{
	short	num;			/* 合成スプライト数 */
	void	*ptr;			/* 開始位置へのポインター */
	short	unused;			/*（未使用）*/
} XOBJ_REF_DAT ;


/*□■□■□■□ ラスター割り込み処理のタイムチャート □■□■□■□*/

typedef	struct	{
	short	ras_no ;		/* 割り込みラスターナンバー */
	void	(* proc)() ;	/* 割り込み処理関数へのポインター */
} XSP_TIME_CHART ;



void	xsp_on() ;
void	xsp_off() ;
void	xsp_pcgdat_set(void *,char *,short) ;
void	xsp_pcgmask_on(short,short) ;
void	xsp_pcgmask_off(short,short) ;
void	xsp_mode(short) ;
void	xsp_objdat_set(void *) ;
short	xsp_vsync(short);
short	xsp_set(short,short,short,short) ;
void	xobj_set(short,short,short,short) ;
short	xsp_set_st(void *) ;
void	xobj_set_st(void *) ;
short	xsp_out() ;
void	xsp_vertical(short) ;

void	xsp_vsyncint_on(void *) ;
void	xsp_vsyncint_off() ;
void	xsp_hsyncint_on(void *) ;
void	xsp_hsyncint_off() ;

