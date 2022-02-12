*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ｘｓｐ＿ｓｅｔ
*
*	書式：	short	xsp_set( short X , short Y , short PT , short INFO ) ;
*
*	引数：	short  X  ：スプライトＸ座標
*		short  Y  ：スプライトＹ座標
*		short  PT ：スプライトパターンＮｏ．（０〜０ｘ７ＦＦＦ）
*		short INFO：反転コード・色・優先度
*
*	戻値：そのスプライト座標（X,Y）が画面外だったなら０。それ以外は非０。
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_set:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	lea	buff_pointer(pc),a2	*[ 8]	a2.l = 仮バッファポインターへのポインター
	movea.l	(a2),a0			*[12]	a0.l = 仮バッファポインター
	tst.w	(a0)			*[ 8]	符号チェック
	bmi.b	XSP_SET_RETURN		*[8,10]	負ならバッファ終点と見なし終了

	*-------[ PUSH ]
		move.w	A7ID+par1_w(sp),d0	*[12]	d0.w = SP_x
		move.w	A7ID+par2_w(sp),d1	*[12]	d1.w = SP_y

		cmpi.w	#(XY_MAX<<SHIFT),d0	*[ 8]	Ｘ座標画面外チェック
		bcc.b	XSP_SET_CANCEL		*[8,10]	XY_MAX ≦ SP_x ならキャンセル
		cmpi.w	#(XY_MAX<<SHIFT),d1	*[ 8]	Ｙ座標画面外チェック
		bcc.b	XSP_SET_CANCEL		*[8,10]	YY_MAX ≦ SP_y ならキャンセル

		.if	SHIFT<>0
			asr.w	#SHIFT,d0	*[6+2n]	固定小数ビット数分のシフト
			asr.w	#SHIFT,d1	*[6+2n]	固定小数ビット数分のシフト
		.endif

		move.w	d0,(a0)+		*[ 8]	SP_x を転送
		move.w	d1,(a0)+		*[ 8]	SP_y を転送

		move.w	A7ID+par3_w(sp),(a0)+	*[16]	SP_pt を転送
		move.w	A7ID+par4_w(sp),(a0)+	*[16]	SP_info を転送

		move.l	a0,(a2)			*[12]	仮バッファポインターの保存

XSP_SET_RETURN:
	rts

XSP_SET_CANCEL:
	moveq	#0,d0			*[ 4]	画面外なので、戻り値＝０
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ｘｓｐ＿ｓｅｔ＿ｓｔ
*
*	書式：	short	xsp_set_st( void *STRUCT ) ;
*
*	引数：	void *STRUCT：パラメーター構造体へのポインター。
*
*		(STRUCT+0).w : short  X  ：スプライトＸ座標
*		(STRUCT+2).w : short  Y  ：スプライトＹ座標
*		(STRUCT+4).w : short  PT ：スプライトパターンＮｏ．（０〜０ｘ７ＦＦＦ）
*		(STRUCT+6).w : short INFO：反転コード・色・優先度
*
*	戻値：そのスプライト座標（X,Y）が画面外だったなら０。それ以外は非０。
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■


_xsp_set_st:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	lea	buff_pointer(pc),a2	*[ 8]	a2.l = 仮バッファポインターへのポインター
	movea.l	(a2),a0			*[12]	a0.l = 仮バッファポインター
	tst.w	(a0)			*[ 8]	符号チェック
	bmi.b	XSP_SET_RETURN		*[8,10]	負ならバッファ終点と見なし終了

	move.l	A7ID+par1_l(sp),a1	*[16]	a1.l = 構造体アドレス

	*-------[ PUSH ]
		move.w	(a1)+,d0		*[ 8]	d0.w = SP_x
		move.w	(a1)+,d1		*[ 8]	d0.w = SP_y

		cmpi.w	#(XY_MAX<<SHIFT),d0	*[ 8]	Ｘ座標画面外チェック
		bcc.b	XSP_SET_CANCEL		*[8,10]	XY_MAX ≦ SP_x ならキャンセル
		cmpi.w	#(XY_MAX<<SHIFT),d1	*[ 8]	Ｙ座標画面外チェック
		bcc.b	XSP_SET_CANCEL		*[8,10]	XY_MAX ≦ SP_y ならキャンセル

		.if	SHIFT<>0
			asr.w	#SHIFT,d0	*[6+2n]	固定小数ビット数分のシフト
			asr.w	#SHIFT,d1	*[6+2n]	固定小数ビット数分のシフト
		.endif

		move.w	d0,(a0)+		*[ 8]	SP_x を転送
		move.w	d1,(a0)+		*[ 8]	SP_y を転送
		move.l	(a1)+,(a0)+		*[20]	SP_pt,info を転送

		move.l	a0,(a2)			*[12]	仮バッファポインターの保存
		rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ｘｏｂｊ＿ｓｅｔ
*
*	書式：	void	xobj_set( short X , short Y , short PT , short INFO ) ;
*
*	引数：	short  X  ：複合スプライトＸ座標
*		short  Y  ：複合スプライトＹ座標
*		short  PT ：複合スプライトパターンＮｏ．（０〜０ｘ７ＦＦＦ）
*		short INFO：反転コード・色・優先度
*
*	戻値：なし
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■


*-------[ マクロの定義 ]

OBJ_WRITE:	.macro	RV10,RV01
		.local	OBJ_LOOP
		.local	NEXT_OBJ
		.local	EXIT_OBJ_LOOP
		.local	SKIP_OBJ_PUSH_1
		.local	SKIP_OBJ_PUSH_2

					* さり気なくループ２倍展開
		lsr.w	#1,d0
		bcc.b	NEXT_OBJ

OBJ_LOOP:
		.if	RV01=0
			add.w	(a1)+,d3	* SP_x += vx
		.else
			sub.w	(a1)+,d3	* SP_x -= vx
		.endif

		.if	RV10=0
			add.w	(a1)+,d4	* SP_y += vy
		.else
			sub.w	(a1)+,d4	* SP_y -= vy
		.endif

		cmp.w	a2,d3
		bcc.b	SKIP_OBJ_PUSH_1		* MAX座標 ≦ SP_x なら pushせず
		cmp.w	a2,d4
		bcc.b	SKIP_OBJ_PUSH_1		* MAX座標 ≦ SP_y なら pushせず

		move.w	d3,(a0)+		* x を転送
		move.w	d4,(a0)+		* y を転送

		move.l	(a1)+,d1		*[12] d1.l = PT RV
		eor.w	d2,d1			*[ 4] d1.w = 反転加工済 info
		move.l	d1,(a0)+		*[12] PT RV を転送

	NEXT_OBJ:

		.if	RV01=0
			add.w	(a1)+,d3	* SP_x += vx
		.else
			sub.w	(a1)+,d3	* SP_x -= vx
		.endif

		.if	RV10=0
			add.w	(a1)+,d4	* SP_y += vy
		.else
			sub.w	(a1)+,d4	* SP_y -= vy
		.endif

		cmp.w	a2,d3
		bcc.b	SKIP_OBJ_PUSH_2		* MAX座標 ≦ SP_x なら pushせず
		cmp.w	a2,d4
		bcc.b	SKIP_OBJ_PUSH_2		* MAX座標 ≦ SP_y なら pushせず

		move.w	d3,(a0)+		* x を転送
		move.w	d4,(a0)+		* y を転送

		move.l	(a1)+,d1		*[12] d1.l = PT RV
		eor.w	d2,d1			*[ 4] d1.w = 反転加工済 info
		move.l	d1,(a0)+		*[12] PT RV を転送

		dbra.w	d0,OBJ_LOOP

EXIT_OBJ_LOOP:
	*-------[ 終了 ]
		move.w	(sp)+,d4		* d4.w 復活
		move.w	(sp)+,d3		* d3.w 復活
		move.l	a0,buff_pointer		* バッファポインター保存
		rts


SKIP_OBJ_PUSH_1:
	addq.w	#4,a1
	bra.b	NEXT_OBJ

SKIP_OBJ_PUSH_2:
	addq.w	#4,a1
	dbra.w	d0,OBJ_LOOP
	bra.b	EXIT_OBJ_LOOP

		.endm

*------------------------



OBJ_SET_RETURN:
	move.w	(sp)+,d4		* d4.w 復活
	move.w	(sp)+,d3		* d3.w 復活
	rts


_xobj_set:

A7ID	=	4+2*2			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 2*2 byte ]

	move.w	d3,-(sp)		* d3.w 退避
	move.w	d4,-(sp)		* d4.w 退避

	move.w	A7ID+par3_w(sp),d1	*[12] d1.w = 複合スプライトpt
	move.w	A7ID+par4_w(sp),d2	*[12] d2.w = SP_info
	move.w	A7ID+par1_w(sp),d3	*[12] d3.w = SP_x
	move.w	A7ID+par2_w(sp),d4	*[12] d4.w = SP_y


*-------[ 参照すべき sp_ref のアドレスを求める ]
OBJ_SET_INIT_STEP1:

	lsl.w	#3,d1			* d1.w *= 8
	movea.l	sp_ref_adr(pc),a1	* a1.l = sp_ref_adr
	adda.w	d1,a1			* a1.w += pt*8
					* a1.l = 参照すべき sp_ref のアドレス
					* d1.w は 用済み


*-------[ 必要合成スプライト数を求める ]
OBJ_SET_INIT_STEP2:

	movea.l	buff_pointer(pc),a0
	move.l	#buff_end_adr,d0
	sub.l	a0,d0			* d0.l -= a0.l
	asr.w	#3,d0			* d0.w /= 8
					* d0.w = push可能スプライト数(1〜)
	cmp.w	(a1)+,d0		* 
	ble.b	@F			* 必要合成スプライト数≧d0 なら bra
		move.w	-2(a1),d0	* d0.w = 必要合成スプライト数
@@:
	sub.w	#1,d0			* d0.w を dbraカウンターとするため -1 する。
	bmi.b	OBJ_SET_RETURN		* 必要合成スプライト数≦0 なら強制終了する


*-------[ その他の初期化 ]
OBJ_SET_INIT_STEP3:

	.if	SHIFT<>0
		asr.w	#SHIFT,d3
		asr.w	#SHIFT,d4
	.endif
					*------------------------------------------------------
					* d0.w = 必要合成スプライト数-1（dbraカウンターとする）
					* d1.l = temp
					* d2.w = SP_info
					* d3.w = SP_x
					* d4.w = SP_y
					*------------------------------------------------------
					* a0.l = push 先
	movea.l	(a1),a1			* a1.l = sp_frm 読み出し開始アドレス
	move.w	#XY_MAX,a2		* a2.l = ＸＹ座標上限値
					*------------------------------------------------------


*=======[ スプライト合成 ]

	move.w	d2,d1
	bmi	RV_1x			* 上下反転：１ なので bra

	*=======[ 上下反転：０　左右反転：？ ]
RV_0x:		add.w	d1,d1
		bmi.b	RV_01			* 左右反転：１ なので bra

		*-------[ 上下反転：０　左右反転：０ ]
	RV_00:		OBJ_WRITE	0,0

		*-------[ 上下反転：０　左右反転：１ ]
	RV_01:		OBJ_WRITE	0,1

	*=======[ 上下反転：１　左右反転：？ ]
RV_1x:		add.w	d1,d1
		bmi.b	RV_11			* 左右反転：１ なので bra

		*-------[ 上下反転：１　左右反転：０ ]
	RV_10:		OBJ_WRITE	1,0

		*-------[ 上下反転：１　左右反転：１ ]
	RV_11:		OBJ_WRITE	1,1




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	ｘｏｂｊ＿ｓｅｔ＿ｓｔ
*
*	書式：	void	xobj_set_st( void *STRUCT ) ;
*
*	引数：	void *STRUCT：パラメーター構造体へのポインター。
*
*		(STRUCT+0).w : short  X  ：複合スプライトＸ座標
*		(STRUCT+2).w : short  Y  ：複合スプライトＹ座標
*		(STRUCT+4).w : short  PT ：複合スプライトパターンＮｏ．（０〜０ｘ７ＦＦＦ）
*		(STRUCT+6).w : short INFO：反転コード・色・優先度
*
*	戻値：なし
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xobj_set_st:

A7ID	=	4+2*2			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 2*2 byte ]

	move.w	d3,-(sp)		* d3.w 退避
	move.w	d4,-(sp)		* d4.w 退避

*-------[ パラメーター受取 ]
	movea.l	A7ID+par1_l(sp),a0	* a0.l = 構造体アドレス

	move.w	(a0)+,d3		*[8]	d3.w = SP_x
	move.w	(a0)+,d4		*[8]	d4.w = SP_y
	move.w	(a0)+,d1		*[8]	d1.w = 複合スプライトpt
	move.w	(a0)+,d2		*[8]	d2.w = SP_info
					*	a0.l は用済み

	bra	OBJ_SET_INIT_STEP1	* obj_set()関数へ




