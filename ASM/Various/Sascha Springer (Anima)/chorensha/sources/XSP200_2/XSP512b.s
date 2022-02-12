*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	５１２枚モード・ソーティングルーチン（優先度保護機能付き）
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	マクロ定義
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*--------------------------------------------------------------------------------------

SORT_512b_An	.macro	An
		.local	end_mark

	*=======[ ラスター分割バッファに登録 ]
		tst.w	(An)			*[12]	バッファチェック
		bmi.b	end_mark		*[8,10]	負なら終点なので飛ばす
		move.l	d0,(An)+		*[12]	x,y 転送
		move.l	(a0)+,(An)+		*[20]	cd,pr 転送
		dbra	d7,SORT_512b_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* 次のＰＲ鎖アドレス
		move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
		bpl	SORT_512b_LOOP		* 連鎖数≧０なら続行
		bra	SORT_512b_PRchange	* ＰＲ変更

	*-------[ 終点に達した ]
end_mark:	addq.w	#4,a0			* ポインタ補正（cd,prを飛ばす）
		dbra	d7,SORT_512b_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------------------

SORT_512b_Dn	.macro	Dn
		.local	end_mark

	*=======[ ラスター分割バッファに登録 ]
		movea.l	Dn,a2			*[ 4]	a2.l = Dn.l
		tst.w	(a2)			*[12]	バッファチェック
		bmi.b	end_mark		*[8,10]	負なら終点なので飛ばす
		move.l	d0,(a2)+		*[12]	x,y 転送
		move.l	(a0)+,(a2)+		*[20]	cd,pr 転送
		move.l	a2,Dn			*[ 4]	Dn.l に戻す
		dbra	d7,SORT_512b_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* 次のＰＲ鎖アドレス
		move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
		bpl	SORT_512b_LOOP		* 連鎖数≧０なら続行
		bra	SORT_512b_PRchange	* ＰＲ変更

	*-------[ 終点に達した ]
end_mark:	addq.w	#4,a0			* ポインタ補正（cd,prを飛ばす）
		dbra	d7,SORT_512b_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------------------

PR_PROTECT:	.macro	buff_0_protect,buff_1_protect
		.local	PR_PROTECT_0,PR_PROTECT_1,PR_PROTECT_END
					* d0.w = buff_0_total
					* d1.w = buff_1_total
	cmp.w	d0,d1
	bge.b	PR_PROTECT_1		* 偶≦奇 なら bra
	*-------[ 偶＞奇 の時（奇buffに[X]作成）]
PR_PROTECT_0:	move.w	d0,d7
		subq.w	#8,d7			* d7.w = buff_0_total - 8
		cmp.w	buff_1_protect,d7
		ble.b	PR_PROTECT_END		* buff_1_protect≧d7 なら bra
			move.w	d7,buff_1_protect
			bra.b	PR_PROTECT_END

	*-------[ 偶≦奇 の時（偶buffに[X]作成）]
PR_PROTECT_1:					* d1.w = buff_1_total
		cmp.w	buff_0_protect,d1
		ble.b	PR_PROTECT_END		* buff_0_protect≧d1 なら bra
			move.w	d1,buff_0_protect

PR_PROTECT_END:

		.endm


*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	ソート・アルゴリズム
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

					* a0.l = 書換用バッファ管理構造体

*-------[ 初期化１ ]
	move.l	#8*65,d0		* d0.l = 分割バッファ１個分のサイズ

	movea.l	div_buff(a0),a3		* a3.l = #ラスター分割バッファＡ
	move.l	a3,d3
	add.l	d0,d3			* d3.l = #ラスター分割バッファＢ
	movea.l	d3,a4
	adda.l	d0,a4			* a4.l = #ラスター分割バッファＣ
	move.l	a4,d4
	add.l	d0,d4			* d4.l = #ラスター分割バッファＤ
	movea.l	d4,a5
	adda.l	d0,a5			* a5.l = #ラスター分割バッファＥ
	move.l	a5,d5
	add.l	d0,d5			* d5.l = #ラスター分割バッファＦ
	movea.l	d5,a6
	adda.l	d0,a6			* a6.l = #ラスター分割バッファＧ
	move.l	a6,d6
	add.l	d0,d6			* d6.l = #ラスター分割バッファＨ

	moveq.l	#-1,d0
	move.w	d0,8*65*0+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*1+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*2+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*3+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*4+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*5+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*6+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*7+8*64(a3)	* end_mark(SP_x = -1)


*-------[ 初期化２（優先度保護処理用 各種バッファの初期化）]
	lea.l	buff_A_bak(pc),a2
	move.w	a3,(a2)+
	move.w	d3,(a2)+
	move.w	a4,(a2)+
	move.w	d4,(a2)+
	move.w	a5,(a2)+
	move.w	d5,(a2)+
	move.w	a6,(a2)+
	move.w	d6,(a2)+

	moveq.l	#0,d0
	lea.l	buff_A_total(pc),a2
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+		* 以下、buff_X_protect の ０クリア
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+


*-------[ 初期化３ ]
					*---------------------------------------
					* a0.l = 仮バッファスキャンポインタ
					* a1.l = 
					* a2.l = temp
					* a3.l = #ラスター分割バッファＡ
					* a4.l = #ラスター分割バッファＣ
					* a5.l = #ラスター分割バッファＥ
					* a6.l = #ラスター分割バッファＧ
					* a7.l = ＰＲ鎖先頭情報読み出し用
					*---------------------------------------
					* d0.l = temp（SP_x,SP_y 読みだし）
					* d1.l = temp
	move.w	#$1FC,d2		* d2.w = SP_y 下位４ビット切り捨て用 and値
					* d3.l = #ラスター分割バッファＢ
					* d4.l = #ラスター分割バッファＤ
					* d5.l = #ラスター分割バッファＦ
					* d6.l = #ラスター分割バッファＨ
					* d7.w = 連鎖数 dbccカウンター
					*---------------------------------------


	move.l	(a7)+,a0		* ＰＲごとの先頭アドレス
	move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
	bmi	SORT_512b_END		* いきなり連鎖数が負（終点）なら終了
	bra	SORT_512b_LOOP


*=======[ 優先度保護処理 ]
SORT_512b_PRchange:


*-------[ Ａ〜Ｈ 各々について優先度保護処理 ]
					* a0.l は、次のＰＲ鎖先頭を読み出すまでfree
	lea.l	buff_A_bak(pc),a0
	lea.l	buff_A_used(pc),a1

	move.w	a3,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	a3,(a0)+		* buff_X_bak に ポインター保存

	move.w	d3,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	d3,(a0)+		* buff_X_bak に ポインター保存

	move.w	a4,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	a4,(a0)+		* buff_X_bak に ポインター保存

	move.w	d4,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	d4,(a0)+		* buff_X_bak に ポインター保存

	move.w	a5,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	a5,(a0)+		* buff_X_bak に ポインター保存

	move.w	d5,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	d5,(a0)+		* buff_X_bak に ポインター保存

	move.w	a6,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	a6,(a0)+		* buff_X_bak に ポインター保存

	move.w	d6,d0			* d0.w = buff_X ポインター
	sub.w	(a0),d0			* d0.w = 転送数*8
	move.w	d0,(a1)+		* 転送数*8 保存
	move.w	d6,(a0)+		* buff_X_bak に ポインター保存



	lea.l	buff_A_total(pc),a0
	lea.l	buff_A_used(pc),a1

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	a3,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_total に 転送数*8 加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	d3,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	a4,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	d4,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	a5,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	d5,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	a6,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算

	move.w	(a1)+,d0			* d0.w = 転送数*8
	beq.b	@f
		movea.l	d6,a2			* a2.l = buff_X ポインター
		sub.w	d0,a2			* a2.l = buff_X の 同一ＰＲブロックの先頭
		move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報の「転送数*8」に書込み
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total に スキップ数*8 加算
		add.w	d1,d1			* d1.w = スキップ数*16
		move.w	d1,CHAIN_OFS_div(a2)	* チェイン情報の「スキップ数*8」に書込み
@@:	add.w	d0,(a0)+			* buff_X_totalに加算



	lea.l	buff_A_protect(pc),a0
	lea.l	buff_A_total(pc),a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+



	lea.l	buff_A_protect(pc),a0
	lea.l	buff_A_total(pc),a1
						* バッファ高低差比較 ＆ スキップ情報の算出
						* PR_PROTECT	 buff_0_protect,buff_1_protect
	move.w	(a1)+,d0			* d0.w = buff_A_total
	move.w	(a1)+,d1			* d1.w = buff_B_total
	PR_PROTECT	00(a0),02(a0)

	move.w	(a1)+,d0			* d0.w = buff_C_total
						* d1.w = buff_B_total
	PR_PROTECT	04(a0),02(a0)

						* d0.w = buff_C_total
	move.w	(a1)+,d1			* d1.w = buff_D_total
	PR_PROTECT	04(a0),06(a0)

	move.w	(a1)+,d0			* d0.w = buff_E_total
						* d1.w = buff_D_total
	PR_PROTECT	08(a0),06(a0)

						* d0.w = buff_E_total
	move.w	(a1)+,d1			* d1.w = buff_F_total
	PR_PROTECT	08(a0),10(a0)

	move.w	(a1)+,d0			* d0.w = buff_G_total
						* d1.w = buff_F_total
	PR_PROTECT	12(a0),10(a0)

						* d0.w = buff_G_total
	move.w	(a1)+,d1			* d1.w = buff_H_total
	PR_PROTECT	12(a0),14(a0)



*=======[ ＰＲ変更 ]
	move.l	(a7)+,a0		* 次のＰＲの先頭アドレス
	move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
	bmi	SORT_512b_END		* 連鎖数＜０なら終了


*=======[ ソーティング処理ループ ]
SORT_512b_LOOP:
	move.l	(a0)+,d0			*[12]	d0.l = x,y
	move.w	d0,d1				*[ 4]	d1.w = y
	and.w	d2,d1				*[ 4]	d1.w = y & $1FC
	movea.l	SORT_512b_JPTBL(pc,d1.w),a2	*[18]	a2.l = ブランチ先アドレス
	jmp	(a2)				*[ 8]	ブランチ


*=======[ Ｙ座標別ジャンプテーブル ]
SORT_512b_JPTBL:
	dcb.l	9,SORT_512b_A		* 36dot
	dcb.l	8,SORT_512b_B		* 32dot
	dcb.l	9,SORT_512b_C		* 36dot
	dcb.l	8,SORT_512b_D		* 32dot
	dcb.l	9,SORT_512b_E		* 36dot
	dcb.l	8,SORT_512b_F		* 32dot
	dcb.l	9,SORT_512b_G		* 36dot
	dcb.l	8,SORT_512b_H		* 32dot

	dcb.l	128-(8+9)*4,SORT_512b_H	* ダミー


*=======[ ラスター分割バッファに登録 ]
SORT_512b_A:	SORT_512b_An	a3
SORT_512b_B:	SORT_512b_Dn	d3
SORT_512b_C:	SORT_512b_An	a4
SORT_512b_D:	SORT_512b_Dn	d4
SORT_512b_E:	SORT_512b_An	a5
SORT_512b_F:	SORT_512b_Dn	d5
SORT_512b_G:	SORT_512b_An	a6
SORT_512b_H:	SORT_512b_Dn	d6


*=======[ 優先度保護処理用 各種バッファ ]
buff_A_total:	dc.w	0
buff_B_total:	dc.w	0
buff_C_total:	dc.w	0
buff_D_total:	dc.w	0
buff_E_total:	dc.w	0
buff_F_total:	dc.w	0
buff_G_total:	dc.w	0
buff_H_total:	dc.w	0
*↑↓両者は、連続したメモリ空間に存在すること
buff_A_protect:	dc.w	0
buff_B_protect:	dc.w	0
buff_C_protect:	dc.w	0
buff_D_protect:	dc.w	0
buff_E_protect:	dc.w	0
buff_F_protect:	dc.w	0
buff_G_protect:	dc.w	0
buff_H_protect:	dc.w	0

buff_A_used:	dc.w	0
buff_B_used:	dc.w	0
buff_C_used:	dc.w	0
buff_D_used:	dc.w	0
buff_E_used:	dc.w	0
buff_F_used:	dc.w	0
buff_G_used:	dc.w	0
buff_H_used:	dc.w	0

buff_A_bak:	dc.w	0
buff_B_bak:	dc.w	0
buff_C_bak:	dc.w	0
buff_D_bak:	dc.w	0
buff_E_bak:	dc.w	0
buff_F_bak:	dc.w	0
buff_G_bak:	dc.w	0
buff_H_bak:	dc.w	0


SORT_512b_END:


*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	最大５１２枚モード 分割ラスター移動 その他
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

*-------[ チェイン情報末端に end_mark 書き込み ]

	moveq.l	#0,d0			* d0.l = 0

	move.w	d0,CHAIN_OFS_div+2(a3)	* チェイン情報に end_mark（転送数*8 = 0）書き込み
	movea.l	d3,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報に end_mark（転送数*8 = 0）書き込み

	move.w	d0,CHAIN_OFS_div+2(a4)	* チェイン情報に end_mark（転送数*8 = 0）書き込み
	movea.l	d4,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報に end_mark（転送数*8 = 0）書き込み

	move.w	d0,CHAIN_OFS_div+2(a5)	* チェイン情報に end_mark（転送数*8 = 0）書き込み
	movea.l	d5,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報に end_mark（転送数*8 = 0）書き込み

	move.w	d0,CHAIN_OFS_div+2(a6)	* チェイン情報に end_mark（転送数*8 = 0）書き込み
	movea.l	d6,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* チェイン情報に end_mark（転送数*8 = 0）書き込み


*-------[ 隙間詰め処理 ]
	move.l	write_struct(pc),a0	* a0.l = 書換用バッファ管理構造体
	movea.l	div_buff(a0),a1		* a1.l = バッファＡ 先頭アドレス
	move.l	#8*65,d0		* d0.l = 分割バッファ１個分のサイズ

					* a1.l = バッファＡ 先頭アドレス
	suba.l	a1,a3			* a3.l = バッファＡ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＢ 先頭アドレス
	sub.l	a1,d3			* d3.l = バッファＢ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＣ 先頭アドレス
	suba.l	a1,a4			* a4.l = バッファＣ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＤ 先頭アドレス
	sub.l	a1,d4			* d4.l = バッファＤ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＥ 先頭アドレス
	suba.l	a1,a5			* a5.l = バッファＥ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＦ 先頭アドレス
	sub.l	a1,d5			* d5.l = バッファＦ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＧ 先頭アドレス
	suba.l	a1,a6			* a6.l = バッファＧ 使用数*8
	adda.l	d0,a1			* a1.l = バッファＨ 先頭アドレス
	sub.l	a1,d6			* d6.l = バッファＨ 使用数*8

					*---------------------------------------
					* a0.l = 書換用バッファ管理構造体
					*---------------------------------------
					* a3.l = ラスター分割バッファＡ使用数*8
					* a4.l = ラスター分割バッファＣ使用数*8
					* a5.l = ラスター分割バッファＥ使用数*8
					* a6.l = ラスター分割バッファＧ使用数*8
					*---------------------------------------
					* d3.l = ラスター分割バッファＢ使用数*8
					* d4.l = ラスター分割バッファＤ使用数*8
					* d5.l = ラスター分割バッファＦ使用数*8
					* d6.l = ラスター分割バッファＨ使用数*8
					*---------------------------------------
	movea.l	div_buff(a0),a2		* a2.l = ラスター分割バッファＡ先頭アドレス

	lea.l	buff_A_total(pc),a1
	move.w	#64*8,d7		* d7.w = 64*8

	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*0(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	a3,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a3,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*1(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	d3,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d3,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*2(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	a4,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a4,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*3(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	d4,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d4,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*4(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	a5,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a5,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*5(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	d5,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d5,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*6(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	a6,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a6,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total ≦ 64*8 なら bra
		lea.l	CHAIN_OFS_div+65*8*7(a2),a0	* a0.l = div_buff_X チェイン先頭アドレス
		move.l	a0,d1
		add.l	d6,d1				* d1.l = div_buff_X チェイン末端アドレス
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d6,d0				* d0.w = 64*8 - (buff_X 使用数*8)
							*      = [X]許容数*8
		bsr	CLEAR_SKIP			* 隙間詰め
@@:




