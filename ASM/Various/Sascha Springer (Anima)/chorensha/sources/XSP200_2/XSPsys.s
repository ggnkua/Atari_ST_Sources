*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*□　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　□
*■　　　　 ｓｐｒｉｔｅ ５１２枚表示 ＆ ＰＣＧ定義管理 ｓｙｓｔｅｍ ’ＸＳＰ’　　　■
*□　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　□
*■　　　　 　　　　　　　　  Ｃ言語＆アセンブラ用ライブラリ 　　　　　　　　　　　　■
*□　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　□
*■　　　　　　　　　ＶＥＲ．２．００　　　ＢＹ　ファミベのよっしん　　　　　　　　　■
*□　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　□
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■


	.include	doscall.mac
	.include	iocscall.mac

	.globl	_xsp_vsync
	.globl	_xsp_objdat_set
	.globl	_xsp_pcgdat_set
	.globl	_xsp_pcgmask_on
	.globl	_xsp_pcgmask_off
	.globl	_xsp_mode
	.globl	_xsp_vertical

	.globl	_xsp_on
	.globl	_xsp_off

	.globl	_xsp_set
	.globl	_xsp_set_st
	.globl	_xobj_set
	.globl	_xobj_set_st
	.globl	_xsp_out

	.globl	_xsp_vsyncint_on
	.globl	_xsp_vsyncint_off
	.globl	_xsp_hsyncint_on
	.globl	_xsp_hsyncint_off




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	数値データ
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

SHIFT	=	0		* 座標 固定少数ビット数

SP_MAX	=	512		* スプライトpush可能枚数

XY_MAX	=	272		* スプライトＸ座標Ｙ座標上限値（共通です）

CHAIN_OFS	= SP_MAX*8+8	* 仮バッファ → チェイン情報 へのオフセット
CHAIN_OFS_div	= $30C0		* ラスター分割バッファ → チェイン情報 へのオフセット

AER	=	$003
IERA	=	$007
IERB	=	$009
ISRA	=	$00F
ISRB	=	$011
IMRA	=	$013
IMRB	=	$015



*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	スタックフレームの作成
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

	.offset 0

par1_l	ds.b	2
par1_w	ds.b	1
par1_b	ds.b	1

par2_l	ds.b	2
par2_w	ds.b	1
par2_b	ds.b	1

par3_l	ds.b	2
par3_w	ds.b	1
par3_b	ds.b	1

par4_l	ds.b	2
par4_w	ds.b	1
par4_b	ds.b	1

par5_l	ds.b	2
par5_w	ds.b	1
par5_b	ds.b	1

par6_l	ds.b	2
par6_w	ds.b	1
par6_b	ds.b	1




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	構造体フレームの作成
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

	.offset 0

struct_top:
*--------------[ 各バッファナンバー別スプライト総数＊８ ]
buff_sp_mode:	ds.w	1
buff_sp_total:	ds.w	1

*--------------[ ラスター別分割バッファの先頭アドレス ]
div_buff:	ds.l	1

*--------------[ 帰線期間 PCG定義要求バッファ ]
vsync_def:	ds.b	8*31
		ds.b	8	* end_mark(-1)

*--------------
struct_end:


STRUCT_SIZE	=	struct_end - struct_top




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

*	関数群のインクルード

*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

	.text
	.even

	.include	XSPset.s

	.include	XSPfnc.s

	.include	XSPout.s




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	割り込みによる スプライト表示
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	帰線期間割り込みサブルーチン
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

VSYNC_INT:

	movem.l	d0-d7/a0-a6,-(a7)	* レジスタ退避

	move.w	#1023,$E80012		* ラスター割り込みＯＦＦ
	addq.w	#1,vsync_count		* ＶＳＹＮＣカウンターインクリ
	addq.w	#1,R65535		* ＸＳＰ内部カウンターインクリ


*=======[ 割り込みマスクに小細工 ]	* 帰線期間割込み中にラスター割込みがかかるように小細工
	ori.w	#$0700,sr

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1011_0111,IMRB(a0)	* マスクに小細工
					*	ビットが０＝マスク状態
					*	1)水平同期割り込み
					*	2)タイマーＡ／Ｂ
					*	3)垂直同期割り込み
					*	4)ＦＭ音源ＩＣの割り込み
					*	以上をマスクした


*=======[ 表示用バッファをチェンジ ]
	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	lea.l	STRUCT_SIZE(a0),a0

	cmpa.l	#endof_XSP_STRUCT,a0	* 終点まで達したか？
	bne.b	@F			* No なら bra
		lea.l	XSP_STRUCT,a0
@@:
	cmpa.l	write_struct(pc),a0	* 書換用バッファ管理構造体と重なっているか？
	beq.b	@F			* 重なっているならbra
		move.l	a0,disp_struct	* 表示用バッファ管理構造体アドレス 書換え
@@:

*=======[ 768*512 dot mode か？ ]
	btst.b	#1,$E80029		* 768*512 mode なら bit1=1
	bne	VSYNC_RTE		* 768*512 mode なら 強制終了


*=======[ スプライト表示ＯＦＦ ]
	bclr.b	#1,$EB0808		* sp_disp(0)


*=======[ ラスター割り込みタイムチャートの指定 ＆ 初回の割り込みの指定 ]
	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス

	btst.b	#4,$E80029		* [inside68k p.233 ]
					* bit4 =( 15Khz時=0 / 31Khz時=1 )
	beq.b	_15khz

	*-------[ 31khz ]
_31khz:		cmpi.w	#1,buff_sp_mode(a0)	* buff_sp_mode==1 か？
		bne.b	@F			* NO なら bra
		*-------[ buff_sp_mode==1 ]
			lea.l	XSP_CHART_128sp_31k(pc),a0
			bra.b	RAS_INT_init
		*-------[ buff_sp_mode!=1 ]
@@:			lea.l	XSP_CHART_512sp_31k(pc),a0
			bra.b	RAS_INT_init

	*-------[ 15khz ]
_15khz:		cmpi.w	#1,buff_sp_mode(a0)	* buff_sp_mode==1 か？
		bne.b	@F			* NO なら bra
		*-------[ buff_sp_mode==1 ]
			lea.l	XSP_CHART_128sp_15k(pc),a0
			bra.b	RAS_INT_init
		*-------[ buff_sp_mode!=1 ]
@@:			lea.l	XSP_CHART_512sp_15k(pc),a0
		*!!	bra.b	RAS_INT_init


RAS_INT_init:
					* a0.l = XSP側チャートへのポインター
	movea.l	usr_chart(pc),a1	* a1.l = USR側チャートへのポインター
	move.l	a0,xsp_chart_ptr	*[20] ポインター保存
	move.l	a1,usr_chart_ptr	*[20] ポインター保存

	move.w	(a0)+,d0		*[ 8] d0.w = XSP側次回割り込みラスターナンバー
	move.w	(a1)+,d1		*[ 8] d1.w = USR側次回割り込みラスターナンバー

	cmp.w	d0,d1			*[ 4] 両ラスターナンバー比較
	bcs.b	_NEXT_USR		*[8,10] d0＞d1（符号無視）ばら bra
	beq.b	_XSP_equ_USR		*[8,10] 等しいなら、割り込み衝突or終点

	*-------[ d0＜d1 なので、次回はXSP側が割り込む ]
_NEXT_XSP:	move.l	(a0)+,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
		move.l	a0,xsp_chart_ptr	*[20] ポインター保存
		move.w	d0,$E80012		*[16] 次回割り込みラスターナンバー設定
		bra.b	RAS_INT_init_END

	*-------[ d0＞d1 なので、次回はUSR側が割り込む ]
_NEXT_USR:	move.l	(a1)+,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
		move.l	a1,usr_chart_ptr	*[20] ポインター保存
		move.w	d1,$E80012		*[16] 次回割り込みラスターナンバー設定
		bra.b	RAS_INT_init_END

	*-------[ d0==d1 なので、割り込み衝突or終点 ]
_XSP_equ_USR:	tst.w	d0
		bmi.b	_RAS_INT_endmark	*[8,10] 負なら bra
		*-------[ 割り込み衝突と見なす ]
			move.l	#RAS_INT_conflict,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
			addq.w	#4,a0				*[ 8] ポインター補正
			move.l	a0,xsp_chart_ptr		*[20] ポインター保存
			addq.w	#4,a1				*[ 8] ポインター補正
			move.l	a1,usr_chart_ptr		*[20] ポインター保存
			move.w	d0,$E80012			*[16] 次回割り込みラスターナンバー設定
			bra.b	RAS_INT_init_END

		*-------[ 終点と見なす ]
_RAS_INT_endmark:	move.l	#dummy_proc,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
			move.w	#1023,$E80012			*[16] 次回割り込みラスターナンバー設定


RAS_INT_init_END:
	andi.w	#$FDFF,sr		* 割込みマスクレベル５（割り込み許可）


*=======[ ユーザー指定帰線期間割り込みサブルーチンの実行 ]
	movea.l	vsyncint_sub(pc),a0
	jsr	(a0)


*=======[ スプライト表示 ]
DISP_buff_AB:
	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	cmpi.w	#1,buff_sp_mode(a0)	* buff_sp_mode==1 か？
	bne.b	@F			* NO なら bra
	*-------[ buff_sp_mode==1 の場合 ]
		movea.l	div_buff(a0),a5		* a5.l = 表示用 div_buff_A アドレス
						*      = スプライト転送元アドレス
		move.w	buff_sp_total(a0),d0	* d0.w = 転送数*8
		bsr	SP_TRANS
		bra.b	DISP_buff_AB_END

	*-------[ buff_sp_mode!=1 の場合 ]
@@:		move.w	#128*8,d7		* d7.w = スプライトクリア数*8
		movea.l	#$EB0000,a6		* a6.l = スプライトクリア開始アドレス
		bsr	SP_CLEAR		* まず全スプライトクリア
						* 破壊：d5-d7/a6

						* a0.l = 表示用バッファ管理構造体アドレス
		movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
		movea.l	a0,a6			* a0.l を a6.l に退避
						* a0.l = 転送元アドレス
		movea.l	#$EB0000,a1		* a1.l = 転送先アドレス（偶数番号スプライト）
		bsr	SP_TRANS_div		* チェイン転送実行
						* 破壊：a0.l a1.l a2.l d0.w

		lea.l	65*8(a6),a0		* a0.l = 表示用 div_buff_B アドレス
						* a0.l = 転送元アドレス
		movea.l	#$EB0008,a1		* a1.l = 転送先アドレス（奇数番号スプライト）
		bsr	SP_TRANS_div		* チェイン転送実行

DISP_buff_AB_END:


*=======[ 帰線期間ＰＣＧ定義実行 ]
	move.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体
	lea.l	vsync_def(a0),a0	* a0.l = 帰線期間ＰＣＧ定義要求バッファ

	move.l	(a0),d0			* d0.l = 転送先 PCGアドレス
	bmi.b	vsync_PCG_DEF_END	* いきなりend_mark(-)なら PCG定義実行せず
	move.l	#-1,(a0)+		* end_mark 書込み（よって定義は１回きり）
	movea.l	d0,a1			* a1.l = 転送先 PCGアドレス

@@:
	move.l	(a0)+,a2		* a2.l = PCGデータ転送元アドレス

	movem.l	(a2)+,d0-d7/a3-a5
	movem.l	d0-d7/a3-a5,(a1)	* 11.l

	movem.l	(a2)+,d0-d7/a3-a5
	movem.l	d0-d7/a3-a5,11*4(a1)	* 11.l

	movem.l	(a2)+,d0-d7/a3-a4
	movem.l	d0-d7/a3-a4,11*8(a1)	* 10.l
					* 合計 32.l = 1PCG

	move.l	(a0)+,a1		* a1.l = 定義先 PCGアドレス
	move.l	a1,d0
	bpl.b	@B			* end_mark でないなら繰り返し


vsync_PCG_DEF_END:


*=======[ RTE ]
VSYNC_RTE:
	ori.w	#$0700,sr		* 割り込みマスクレベル７（割り込み禁止）
	bsr	WAIT			* ６８０３０対策

	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活

	movem.l	(a7)+,d0-d7/a0-a6	* レジスタ復活
	rte




*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	ラスター割り込み監視ルーチン
*
*	機能：　ＸＳＰ側とＵＳＲ側の両タイムチャートを参照し、その内容に従って割り込み
*	　　　処理を実行する。両割り込みが衝突する場合、ＵＳＲ側の割り込みタイミングを
*	　　　優先する（ＸＳＰ側は遅れて実行される）。
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

RAS_INT:
	movem.l	d0-d2/a0-a2,-(a7)	*[8+8*6 = 56] レジスタ退避

	movea.l	xsp_chart_ptr(pc),a0	*[16] a0.l = XSP側チャートへのポインター
	movea.l	usr_chart_ptr(pc),a1	*[16] a1.l = USR側チャートへのポインター
	move.w	(a0)+,d0		*[ 8] d0.w = XSP側次回割り込みラスターナンバー
	move.w	(a1)+,d1		*[ 8] d1.w = USR側次回割り込みラスターナンバー

	cmp.w	d0,d1			*[ 4] 両ラスターナンバー比較
	bcs.b	NEXT_USR		*[8,10] d0＞d1（符号無視）ばら bra
	beq.b	XSP_equ_USR		*[8,10] 等しいなら、割り込み衝突or終点

	*-------[ d0＜d1 なので、次回はXSP側が割り込む ]
NEXT_XSP:	move.l	hsyncint_sub(pc),a2	*[16] a2.l = サブルーチンアドレス
		move.l	(a0)+,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
		move.l	a0,xsp_chart_ptr	*[20] ポインター保存
		move.w	d0,$E80012		*[16] 次回割り込みラスターナンバー設定
		jsr	(a2)			*[16] サブルーチン実行
		movem.l	(a7)+,d0-d2/a0-a2	*[12+8*6 = 60] レジスタ復活
		rte

	*-------[ d0＞d1 なので、次回はUSR側が割り込む ]
NEXT_USR:	move.l	hsyncint_sub(pc),a2	*[16] a2.l = サブルーチンアドレス
		move.l	(a1)+,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
		move.l	a1,usr_chart_ptr	*[20] ポインター保存
		move.w	d1,$E80012		*[16] 次回割り込みラスターナンバー設定
		jsr	(a2)			*[16] サブルーチン実行
		movem.l	(a7)+,d0-d2/a0-a2	*[12+8*6 = 60] レジスタ復活
		rte

	*-------[ d0==d1 なので、割り込み衝突or終点 ]
XSP_equ_USR:	tst.w	d0
		bmi.b	RAS_INT_endmark		*[8,10] 負なら bra
		*-------[ 割り込み衝突と見なす ]
			move.l	hsyncint_sub(pc),a2		*[16] a2.l = サブルーチンアドレス
			move.l	#RAS_INT_conflict,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
			addq.w	#4,a0				*[ 8] ポインター補正
			move.l	a0,xsp_chart_ptr		*[20] ポインター保存
			addq.w	#4,a1				*[ 8] ポインター補正
			move.l	a1,usr_chart_ptr		*[20] ポインター保存
			move.w	d0,$E80012			*[16] 次回割り込みラスターナンバー設定
			jsr	(a2)				*[16] サブルーチン実行
			movem.l	(a7)+,d0-d2/a0-a2		*[12+8*6 = 60] レジスタ復活
			rte

		*-------[ 終点と見なす ]
RAS_INT_endmark:	move.l	hsyncint_sub(pc),a2		*[16] a2.l = サブルーチンアドレス
			move.l	#dummy_proc,hsyncint_sub	*[28] 次回サブルーチンアドレス設定
			move.w	#1023,$E80012			*[16] 次回割り込みラスターナンバー設定
			jsr	(a2)				*[16] サブルーチン実行
			movem.l	(a7)+,d0-d2/a0-a2		*[12+8*6 = 60] レジスタ復活
			rte


*=======[ 割り込みラスターナンバー衝突の場合 ]
RAS_INT_conflict:
	movea.l	usr_chart_ptr(pc),a0	*[16] a0.l = USR側チャートへのポインター
	movea.l	-4(a0),a0		*[16] a0.l = サブルーチンアドレス
	jsr	(a0)			*[16] サブルーチン実行

	movea.l	xsp_chart_ptr(pc),a0	*[16] a0.l = XSP側チャートへのポインター
	movea.l	-4(a0),a0		*[16] a0.l = サブルーチンアドレス
	jsr	(a0)			*[16] サブルーチン実行

	rts


*===============[ ラスター割り込み管理タイムチャート ]
	.even
				* ３１Ｋ：割込みラスターNo.=(Ｙ座標)*2+32
				* １５Ｋ：割込みラスターNo.=(Ｙ座標)+12

XSP_CHART_128sp_31k:		* １２８枚　３１ＫＨｚ
	dc.w	34		* ラスターナンバー
	dc.l	sp_disp_on	* 割り込み先アドレス
	dc.w	-1		* end_mark
	dc.l	0		* ダミー


XSP_CHART_128sp_15k:		* １２８枚　１５ＫＨｚ
	dc.w	12		* ラスターナンバー
	dc.l	sp_disp_on	* 割り込み先アドレス
	dc.w	-1		* end_mark
	dc.l	0		* ダミー


XSP_CHART_512sp_31k:		* ５１２枚　３１ＫＨｚ
	dc.w	32		* ラスターナンバー
	dc.l	sp_disp_on	* 割り込み先アドレス
	dc.w	24+(36+16)*2
	dc.l	DISP_buff_C
	dc.w	24+(36+32+16)*2
	dc.l	DISP_buff_D
	dc.w	24+(36+32+36+16)*2
	dc.l	DISP_buff_E
	dc.w	24+(36+32+36+32+16)*2
	dc.l	DISP_buff_F
	dc.w	24+(36+32+36+32+36+16)*2
	dc.l	DISP_buff_G
	dc.w	24+(36+32+36+32+36+32+16)*2
	dc.l	DISP_buff_H
	dc.w	-1		* end_mark
	dc.l	0		* ダミー


XSP_CHART_512sp_15k:		* ５１２枚　１５ＫＨｚ
	dc.w	12		* ラスターナンバー
	dc.l	sp_disp_on	* 割り込み先アドレス
	dc.w	0+(36+16)
	dc.l	DISP_buff_C
	dc.w	0+(36+32+16)
	dc.l	DISP_buff_D
	dc.w	0+(36+32+36+16)
	dc.l	DISP_buff_E
	dc.w	0+(36+32+36+32+16)
	dc.l	DISP_buff_F
	dc.w	0+(36+32+36+32+36+16)
	dc.l	DISP_buff_G
	dc.w	0+(36+32+36+32+36+32+16)
	dc.l	DISP_buff_H
	dc.w	-1		* end_mark
	dc.l	0		* ダミー


dummy_chart:			* ラスター割り込みＯＦＦ
	dc.w	-1		* end_mark
	dc.l	0		* ダミー



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	各種ラスター割り込み実行サブルーチン
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

sp_disp_on:
	bset.b	#1,$EB0808		* sp_disp(1)
	rts

dummy_proc:
	rts


DISP_buff_C:
	ori.w	#$0700,sr		* 割込みマスクレベル７

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1111_0111,IMRB(a0)	* マスクに小細工

	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	andi.w	#$FDFF,sr		* 割込みマスクレベル５
	movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
	lea.l	65*8*2(a0),a0		* a0.l = 表示用 div_buff_C アドレス
	movea.l	#$EB0000,a1		* a1.l = 転送先アドレス（偶数番号スプライト）
	bsr	SP_TRANS_div		* チェイン転送実行

	ori.w	#$0700,sr		* 割込みマスクレベル７
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活
	rts


DISP_buff_D:
	ori.w	#$0700,sr		* 割込みマスクレベル７

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1111_0111,IMRB(a0)	* マスクに小細工

	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	andi.w	#$FDFF,sr		* 割込みマスクレベル５
	movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
	lea.l	65*8*3(a0),a0		* a0.l = 表示用 div_buff_D アドレス
	movea.l	#$EB0008,a1		* a1.l = 転送先アドレス（奇数番号スプライト）
	bsr	SP_TRANS_div		* チェイン転送実行

	ori.w	#$0700,sr		* 割込みマスクレベル７
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活
	rts


DISP_buff_E:
	ori.w	#$0700,sr		* 割込みマスクレベル７

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1111_0111,IMRB(a0)	* マスクに小細工

	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	andi.w	#$FDFF,sr		* 割込みマスクレベル５
	movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
	lea.l	65*8*4(a0),a0		* a0.l = 表示用 div_buff_E アドレス
	movea.l	#$EB0000,a1		* a1.l = 転送先アドレス（偶数番号スプライト）
	bsr	SP_TRANS_div		* チェイン転送実行

	ori.w	#$0700,sr		* 割込みマスクレベル７
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活
	rts


DISP_buff_F:
	ori.w	#$0700,sr		* 割込みマスクレベル７

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1111_0111,IMRB(a0)	* マスクに小細工

	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	andi.w	#$FDFF,sr		* 割込みマスクレベル５
	movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
	lea.l	65*8*5(a0),a0		* a0.l = 表示用 div_buff_F アドレス
	movea.l	#$EB0008,a1		* a1.l = 転送先アドレス（奇数番号スプライト）
	bsr	SP_TRANS_div		* チェイン転送実行

	ori.w	#$0700,sr		* 割込みマスクレベル７
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活
	rts


DISP_buff_G:
	ori.w	#$0700,sr		* 割込みマスクレベル７

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1111_0111,IMRB(a0)	* マスクに小細工

	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	andi.w	#$FDFF,sr		* 割込みマスクレベル５
	movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
	lea.l	65*8*6(a0),a0		* a0.l = 表示用 div_buff_G アドレス
	movea.l	#$EB0000,a1		* a1.l = 転送先アドレス（偶数番号スプライト）
	bsr	SP_TRANS_div		* チェイン転送実行

	ori.w	#$0700,sr		* 割込みマスクレベル７
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活
	rts


DISP_buff_H:
	ori.w	#$0700,sr		* 割込みマスクレベル７

	movea.l	#$e88000,a0		* a0.l = MFP アドレス
	move.b	IMRA(a0),-(a7)		* IMRA 保存
	move.b	IMRB(a0),-(a7)		* IMRB 保存
	andi.b	#%0101_1110,IMRA(a0)	* マスクに小細工
	andi.b	#%1111_0111,IMRB(a0)	* マスクに小細工

	movea.l	disp_struct(pc),a0	* a0.l = 表示用バッファ管理構造体アドレス
	andi.w	#$FDFF,sr		* 割込みマスクレベル５
	movea.l	div_buff(a0),a0		* a0.l = 表示用 div_buff_A アドレス
	lea.l	65*8*7(a0),a0		* a0.l = 表示用 div_buff_H アドレス
	movea.l	#$EB0008,a1		* a1.l = 転送先アドレス（奇数番号スプライト）
	bsr	SP_TRANS_div		* チェイン転送実行

	ori.w	#$0700,sr		* 割込みマスクレベル７
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	move.b	(a7)+,IMRB(a0)		* IMRB 復活
	move.b	(a7)+,IMRA(a0)		* IMRA 復活
	rts






*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ちらつかせ機能付 スプライト１２８枚転送 サブルーチン
*
*	SP_TRANS
*
*--------------------------------------------------------------------------------------
*
*	引数：	a0.l = 表示用バッファ管理構造体アドレス
*		a5.l = 転送元アドレス
*		d0.w = スプライト数＊８
*
*	破壊：	全レジスタ
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

SP_TRANS:
	movea.l	#$EB0000,a6		* a6.l = スプライト転送先アドレス

	cmpi.w	#129*8,d0		* １２９枚以上か？
	bge.b	@F			* YES なら bra

*=======[ １２８枚以下 ]
	cmpi.w	#1,buff_sp_mode(a0)	* １２８枚モードか？
	bne.b	SP_128_TRANS		* NO なら１２８スプライト一直線転送へ bra

	*-------[ 消去付き１２８枚一直線転送 ]
						*---------------------------------------
						* d0.w = 転送スプライト数＊８
						* a5.l = スプライト転送元アドレス
						* a6.l = スプライト転送先アドレス
						*---------------------------------------
		move.w	d0,-(sp)		* d0.w 退避
		move.w	d0,d7
		asr.w	#1,d7			* d7.w = 転送ワード数
		bsr	BLOCK_TRANS

		move.w	#128*8,d7
		sub.w	(sp)+,d7		* d7.w = 必要クリアスプライト数*8
						* a6.l = スプライトクリア開始アドレス
		bsr	SP_CLEAR		* 余分なスプライトのクリア

		bra.b	EXIT_SP_TRANS


@@:
*=======[ １２９枚以上 ]
	move.w	R65535(pc),d1		* d1.w = XSP内部カウンター
	btst	#0,d1			*（２ＶＳＹＮＣに１回 Ｚフラグ＝０）
	bne.b	SP_128_TRANS		* Z=0 なら１２８スプライト一直線転送へ bra

		asr.w	#1,d0			* d0.w = 表示用バッファ上 総ワード数
		cmpi.w	#256*4,d0
		ble.b	SP_256_TRANS		* 256*4≧d0 なら ちらつき２５６枚化転送へ bra

	*-------[ ちらつき３８４枚化転送 ]
SP_384_TRANS:
						*---------------------------------------
						* d0.w = 表示用バッファ上総pushワード数
						* d1.w = XSP内部カウンター（R65535）
						* a5.l = スプライト転送元アドレス
						* a6.l = スプライト転送先アドレス
						*---------------------------------------
		cmpi.w	#384*4,d0
		ble.b	@F			* #384*4≧d0 なら bra
			move.w	#384*4,d0	* １画面中３８４枚を超えないように修正
@@:
		lea	128*8(a5),a5		* 先頭１２８枚飛ばす
		subi.w	#128*4,d0		* 転送数を１２８枚減らす

		btst	#1,d1			*（４ＶＳＹＮＣに１回 Ｚフラグ＝０）
		bne.b	SP_128_TRANS		* Z=0 なら１２８スプライト一直線転送へ bra
						* Z=0 ならちらつき２５６枚化転送へ

	*-------[ ちらつき２５６枚化転送 ]
SP_256_TRANS:
						*---------------------------------------
						* d0.w = 表示用バッファ上総pushワード数
						* d1.w = XSP内部カウンター（R65535）
						* a5.l = スプライト転送元アドレス
						* a6.l = スプライト転送先アドレス
						*---------------------------------------
		move.w	#256*4,d7
		sub.w	d0,d7			* d7.w = グループ１ 転送ワード数

		lea	128*8(a5),a0		* a0.l = グループ２ スプライト転送元アドレス
		subi.w	#128*4,d0		* d0.w = グループ２ 転送ワード数
		move.w	d0,-(sp)		* d0.w 退避
		bsr	BLOCK_TRANS

		move.w	(sp)+,d7		* d0.w 復活、そのまま d7.w へ
		movea.l	a0,a5			* a5.l = グループ２ スプライト転送元アドレス
						* a6.l = グループ２ スプライト転送先アドレス
		bsr	BLOCK_TRANS

		bra.b	EXIT_SP_TRANS

*------[ １２８枚一直線転送 ]
SP_128_TRANS:
					*---------------------------------------
					* a5.l = スプライト転送元アドレス
					* a6.l = スプライト転送先アドレス
					*---------------------------------------
	bsr	SP_BLOCK_TRANS		* スプライト１２８枚ブロック転送


EXIT_SP_TRANS:
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	スプライト１２８枚 最大速度ブロック転送 サブルーチン
*
*	SP_BLOCK_TRANS
*
*--------------------------------------------------------------------------------------
*
*	引数：	a5.l = 転送元アドレス
*		a6.l = 転送先アドレス
*
*	破壊：	全レジスタ
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

SP_BLOCK_TRANS:

	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [0]
	movem.l	d0-d7/a0-a4,(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [1]
	movem.l	d0-d7/a0-a4,1*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [2]
	movem.l	d0-d7/a0-a4,2*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [3]
	movem.l	d0-d7/a0-a4,3*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [4]
	movem.l	d0-d7/a0-a4,4*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [5]
	movem.l	d0-d7/a0-a4,5*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [6]
	movem.l	d0-d7/a0-a4,6*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [7]
	movem.l	d0-d7/a0-a4,7*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [8]
	movem.l	d0-d7/a0-a4,8*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [9]
	movem.l	d0-d7/a0-a4,9*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [10]
	movem.l	d0-d7/a0-a4,10*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [11]
	movem.l	d0-d7/a0-a4,11*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [12]
	movem.l	d0-d7/a0-a4,12*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [13]
	movem.l	d0-d7/a0-a4,13*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [14]
	movem.l	d0-d7/a0-a4,14*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [15]
	movem.l	d0-d7/a0-a4,15*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [16]
	movem.l	d0-d7/a0-a4,16*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [17]
	movem.l	d0-d7/a0-a4,17*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [18]
	movem.l	d0-d7/a0-a4,18*13*4(a6)
						* 以上で合計 247.l
	movem.l	(a5)+,d0-d7/a0			* 9.l
	movem.l	d0-d7/a0,19*13*4(a6)
						* 以上で合計 256.l
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	チェインスキャン １枚飛ばし スプライト転送 サブルーチン
*
*	SP_TRANS_div
*
*--------------------------------------------------------------------------------------
*
*	引数：	a0.l = 転送元スキャン開始アドレス
*		a1.l = 転送先アドレス
*
*	破壊：	a0.l a1.l a2.l d0.w
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

SP_TRANS_div_LOOP:
	.rept	64
		move.l	(a0)+,(a1)+	*[20] 2byte
		move.l	(a0)+,(a1)+	*[20] 2byte
		addq.w	#8,a1		*[ 8] 2byte
	.endm


SP_TRANS_div:
	add.w	CHAIN_OFS_div(a0),a1	* 優先度保護のためのスキップ
	move.w	CHAIN_OFS_div+2(a0),d0	* d0.w = 転送数*8
	movea.l	@f(pc,d0.w),a2		* a2.l = 転送数*8 別ジャンプ先
	jmp	(a2)			* 転送ルーチンにジャンプ

SP_TRANS_div_END:
	rts


*-------[ 転送数別ジャンプテーブル ]
@@:
	dcb.l	2,SP_TRANS_div_END		* ０なら終了

	dcb.l	2,SP_TRANS_div_LOOP+$3F*6	* $01枚 転送
	dcb.l	2,SP_TRANS_div_LOOP+$3E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$39*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$38*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$37*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$36*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$35*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$34*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$33*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$32*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$31*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$30*6	* 

	dcb.l	2,SP_TRANS_div_LOOP+$2F*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$29*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$28*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$27*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$26*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$25*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$24*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$23*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$22*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$21*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$20*6	* 

	dcb.l	2,SP_TRANS_div_LOOP+$1F*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$19*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$18*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$17*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$16*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$15*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$14*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$13*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$12*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$11*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$10*6	* 

	dcb.l	2,SP_TRANS_div_LOOP+$0F*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$09*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$08*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$07*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$06*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$05*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$04*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$03*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$02*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$01*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$00*6	* $40枚 転送




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	汎用高速ブロック転送サブルーチン
*
*	BLOCK_TRANS
*
*--------------------------------------------------------------------------------------
*
*	引数：	a5.l = 転送元アドレス
*		a6.l = 転送先アドレス
*		d7.w = 転送ワード数
*
*	破壊：	a0.l 以外の全レジスタ
*		（a5.l a6.l はインクリされる）
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

BLOCK_TRANS:

*-------[ 転送ワード数 下位１ビットを処理 ]
					* d7.w = 転送ワード数
	btst.l	#0,d7
	beq.b	@F			* 偶数ワード数なら bra
		move.w	(a5)+,(a6)+	* 奇数ワード数の場合、まず１ワード転送
@@:

*-------[ 転送ワード数 下位６ビットを処理 ]
	move.w	d7,d0
	andi.w	#62,d0
	neg.w	d0			* d0.w = ジャンプ インデクス
	jmp	TRANS_64W(pc,d0.w)	* 展開ループ中に飛び込む

	.rept	31
		move.l	(a5)+,(a6)+	*[2byte]
	.endm

TRANS_64W:
	*-------[ ６４ワード一括転送ループ ]
		lsr.w	#6,d7
		beq.b	EXIT_BLOCK_TRANS
		subq.w	#1,d7			* d7.w = dbraカウンター

@@:
			movem.l	(a5)+,d0-d6/a1-a4
			movem.l	d0-d6/a1-a4,(a6)	* 11.l

			movem.l	(a5)+,d0-d6/a1-a4
			movem.l	d0-d6/a1-a4,11*4(a6)	* 11.l

			movem.l	(a5)+,d0-d6/a1-a3
			movem.l	d0-d6/a1-a3,22*4(a6)	* 10.l
							* 合計 32.l = 64.w

			lea	32*4(a6),a6
			dbra	d7,@B

EXIT_BLOCK_TRANS:
			rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	スプライトクリアサブルーチン
*
*	SP_CLEAR
*
*--------------------------------------------------------------------------------------
*
*	機能：	スプライトを消去します。
*
*	引数：	d7.w = クリア枚数 * 8
*		a6.l = クリア開始アドレス
*
*	破壊：	d5-d7/a6
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

SP_CLEAR:

	subq.w	#8,d7
	bmi.b	SP_CL_RTS		* クリア数≦０ ならキャンセル

	move.w	d7,d6
	andi.w	#$FF80,d6		* (16sprite STEP)
	lea.l	6(a6,d6.w),a6		* SP_pr.w の参照基準アドレス

	move.w	d7,d6
	andi.w	#$78,d6
	asr.w	#1,d6			* １命令４バイトなので２で割る
	neg.w	d6			* d6.w = ジャンプ インデクス

	asr.w	#7,d7			* d7.w = (クリア数 -1)*8/8/16
					*      = dbraカウンター

	moveq.l	#0,d5

	jmp	SP_CL_LOOP+15*4(pc,d6.w)	* 展開ループ中へ飛び込む


SP_CL_LOOP:
		move.l	d5,$0078(a6)		* 4byte
		move.l	d5,$0070(a6)
		move.l	d5,$0068(a6)
		move.l	d5,$0060(a6)
		move.l	d5,$0058(a6)
		move.l	d5,$0050(a6)
		move.l	d5,$0048(a6)
		move.l	d5,$0040(a6)
		move.l	d5,$0038(a6)
		move.l	d5,$0030(a6)
		move.l	d5,$0028(a6)
		move.l	d5,$0020(a6)
		move.l	d5,$0018(a6)
		move.l	d5,$0010(a6)
		move.l	d5,$0008(a6)
		move.l	d5,(a6)
		lea.l	-$0080(a6),a6
		dbra	d7,SP_CL_LOOP

SP_CL_RTS:

	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	隙間詰めサブルーチン
*
*	CLEAR_SKIP
*
*--------------------------------------------------------------------------------------
*
*	機能：	全内部バッファ初期化（帰線期間転送バッファは除く）
*
*	引数：	a0.l = チェイン先頭アドレス
*		d0.w = [X]許容数*8
*		d1.l = チェイン末端アドレス
*
*	破壊：a0.l d0.l d1.l
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■


CLEAR_SKIP:
	add.w	d0,d0			* d0.w = [X]許容数*16
	beq.b	ALL_CLEAR2		* [X]許容数*16 == 0 なら 全詰め処理２へ

	sub.w	(a0),d0			* [X]許容数*16 -= スキップ数*16
	ble.b	ALL_CLEAR		* [X]許容数*16 ≦ 0 なら 全詰め処理へ
@@:
	adda.w	2(a0),a0		* a0.l += 転送数*8
					* a0.l = 次のチェインアドレス
	sub.w	(a0),d0			* [X]許容数*16 -= スキップ数*16
	bgt.b	@b			* [X]許容数*16 ＞ 0 なら 繰り返し

ALL_CLEAR:
	add.w	d0,(a0)			* スキップ数*16 補正
	sub.w	a0,d1			* d1.w = 残り全部の 転送数*8
	move.w	d1,2(a0)		* 転送数*8 書き込み
	rts

ALL_CLEAR2:
	move.w	#0,(a0)			* スキップ数*16 = 0
	move.w	#64*8,2(a0)		* 転送数*8 = 64*8
	rts



*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ＸＳＰ全内部バッファ初期化　汎用サブルーチン
*
*	XSP_BUFF_INIT
*
*--------------------------------------------------------------------------------------
*
*	機能：	内部バッファ初期化（起動時１回きりの全初期化）
*
*	破壊：	無し
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

XSP_BUFF_INIT:

	movem.l	d0-d7/a0-a6,-(sp)	* レジスタ退避


*-------[ スプライト仮バッファクリア ]
	lea	buff_top_adr,a0
	move.l	a0,buff_pointer		* ポインタークリア

	moveq	#0,d0
	move.w	#SP_MAX*2-1,d1		* １ＳＰ当たり２ロングワード
@@:		move.l	d0,(a0)+
		dbra	d1,@B

	move.l	#-1,(a0)+		* end_mark
	move.l	#-1,(a0)+		* end_mark


*-------[ ラスター別分割バッファ初期化 ]
	lea	div_buff_0A,a0
	moveq.l	#0,d0			* d0.l = 0（クリア用）

	move.w	#65*8*3-1,d1		* d1.w = dbraカウンター初期値
@@:		move.l	d0,(a0)+	* ０クリア
		move.l	d0,(a0)+	* ０クリア
		dbra	d1,@B


*-------[ OX_tbl , OX_mask の初期化 ]
	lea	OX_tbl,a0
	move.b	#255,(a0)+		* PCG_No.0 は水位＝255

	lea	OX_mask,a1
	move.b	#255,(a1)+		* PCG_No.0 はマスク

	move.w	#254,d0			* 255.b 初期化するための dbraカウンター
@@:		move.b	#1,(a0)+	* OX_tbl 初期化（水位＝１）
		move.b	#0,(a1)+	* OX_mask 初期化（マスクoff）
	dbra	d0,@B

	move.b	#0,(a0)+		* OX_tbl に end_mark(0)

	move.b	#4,OX_level		* 現在の OX_tbl水位 は４とする
	move.w	#0,OX_mask_renew	* OX_mask 更新があったことを示すフラグをクリア
	move.l	#OX_tbl+1,OX_chk_top
	move.l	#OX_tbl+1,OX_chk_ptr
	move.w	#254,OX_chk_size


*-------[ ＸＳＰ管理構造体初期化 ]
	lea.l	XSP_STRUCT,a0
	lea.l	STRUCT_SIZE(a0),a1
	lea.l	STRUCT_SIZE(a1),a2

	moveq.l	#1,d0
	move.w	d0,buff_sp_mode(a0)
	move.w	d0,buff_sp_mode(a1)
	move.w	d0,buff_sp_mode(a2)

	moveq.l	#0,d0
	move.w	d0,buff_sp_total(a0)
	move.w	d0,buff_sp_total(a1)
	move.w	d0,buff_sp_total(a2)

	move.l	#div_buff_0A,div_buff(a0)
	move.l	#div_buff_1A,div_buff(a1)
	move.l	#div_buff_2A,div_buff(a2)

	moveq.l	#-1,d0
	move.l	d0,vsync_def(a0)
	move.l	d0,vsync_def(a1)
	move.l	d0,vsync_def(a2)


*-------[ 終了 ]
	movem.l	(sp)+,d0-d7/a0-a6	* レジスタ復活

	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	６８０３０対策　ＭＦＰ操作のＷＡＩＴサブルーチン
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

WAIT:
	rts				* 何もせず帰るだけです




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ワーク確保
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

	.include	XSPmem.s



