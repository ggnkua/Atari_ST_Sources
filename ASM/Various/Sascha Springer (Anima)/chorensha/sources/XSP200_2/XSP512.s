*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	５１２枚モード・ソーティングルーチン（優先度保護機能なし）
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	マクロ定義
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*--------------------------------------------------------------------------------------

SORT_512_An	.macro	An
		.local	end_mark

	*=======[ ラスター分割バッファに登録 ]
		tst.w	(An)		*[12]	バッファチェック
		bmi.b	end_mark	*[8,10]	負なら終点なので飛ばす
		move.l	d0,(An)+	*[12]	x,y 転送
		move.l	(a0)+,(An)+	*[20]	cd,pr 転送
		dbra	d7,SORT_512_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* 次のＰＲ鎖アドレス
		move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
		bpl	SORT_512_LOOP		* 連鎖数≧０なら続行
	*-------[ ＰＲ変更 ]
		move.l	(a7)+,a0		* 次のＰＲの先頭アドレス
		move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
		bpl	SORT_512_LOOP		* 連鎖数≧０なら続行
		bra	SORT_512_END		* 終了

	*-------[ 終点に達した ]
end_mark:	addq.w	#4,a0			* ポインタ補正（cd,prを飛ばす）
		dbra	d7,SORT_512_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------------------

SORT_512_Dn	.macro	Dn
		.local	end_mark

	*=======[ ラスター分割バッファに登録 ]
		movea.l	Dn,a2		*[ 4]	a2.l = Dn.l
		tst.w	(a2)		*[12]	バッファチェック
		bmi.b	end_mark	*[8,10]	負なら終点なので飛ばす
		move.l	d0,(a2)+	*[12]	x,y 転送
		move.l	(a0)+,(a2)+	*[20]	cd,pr 転送
		move.l	a2,Dn		*[ 4]	Dn.l に戻す
		dbra	d7,SORT_512_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* 次のＰＲ鎖アドレス
		move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
		bpl	SORT_512_LOOP		* 連鎖数≧０なら続行
	*-------[ ＰＲ変更 ]
		move.l	(a7)+,a0		* 次のＰＲの先頭アドレス
		move.w	CHAIN_OFS(a0),d7	* 連鎖数（そのままdbccカウンターとして使える）
		bpl	SORT_512_LOOP		* 連鎖数≧０なら続行
		bra	SORT_512_END		* 終了

	*-------[ 終点に達した ]
end_mark:	addq.w	#4,a0			* ポインタ補正（cd,prを飛ばす）
		dbra	d7,SORT_512_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------------------




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


*-------[ 初期化２ ]
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
	bmi	SORT_512_END		* いきなり連鎖数が負（終点）なら終了

*=======[ ソーティング処理ループ ]
SORT_512_LOOP:
	move.l	(a0)+,d0			*[12]	d0.l = x,y
	move.w	d0,d1				*[ 4]	d1.w = y
	and.w	d2,d1				*[ 4]	d1.w = y & $1FC
	movea.l	SORT_512_JPTBL(pc,d1.w),a2	*[18]	a2.l = ブランチ先アドレス
	jmp	(a2)				*[ 8]	ブランチ


*=======[ Ｙ座標別ジャンプテーブル ]
SORT_512_JPTBL:
	dcb.l	9,SORT_512_A		* 36dot
	dcb.l	8,SORT_512_B		* 32dot
	dcb.l	9,SORT_512_C		* 36dot
	dcb.l	8,SORT_512_D		* 32dot
	dcb.l	9,SORT_512_E		* 36dot
	dcb.l	8,SORT_512_F		* 32dot
	dcb.l	9,SORT_512_G		* 36dot
	dcb.l	8,SORT_512_H		* 32dot

	dcb.l	128-(8+9)*4,SORT_512_H	* ダミー


*=======[ ラスター分割バッファに登録 ]
SORT_512_A:	SORT_512_An	a3
SORT_512_B:	SORT_512_Dn	d3
SORT_512_C:	SORT_512_An	a4
SORT_512_D:	SORT_512_Dn	d4
SORT_512_E:	SORT_512_An	a5
SORT_512_F:	SORT_512_Dn	d5
SORT_512_G:	SORT_512_An	a6
SORT_512_H:	SORT_512_Dn	d6


SORT_512_END:



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


*-------[ チェイン情報先頭に 転送数*8 書き込み ]

	move.l	write_struct(pc),a0	* a0.l = 書換用バッファ管理構造体
	movea.l	div_buff(a0),a1		* a1.l = バッファＡ 先頭アドレス
	move.l	#8*65,d0		* d0.l = 分割バッファ１個分のサイズ

					* a1.l = バッファＡ 先頭アドレス
	suba.l	a1,a3			* a3.l = バッファＡ 使用数*8
	move.l	a3,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＢ 先頭アドレス
	sub.l	a1,d3			* d3.l = バッファＢ 使用数*8
	move.l	d3,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＣ 先頭アドレス
	suba.l	a1,a4			* a4.l = バッファＣ 使用数*8
	move.l	a4,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＤ 先頭アドレス
	sub.l	a1,d4			* d4.l = バッファＤ 使用数*8
	move.l	d4,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＥ 先頭アドレス
	suba.l	a1,a5			* a5.l = バッファＥ 使用数*8
	move.l	a5,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＦ 先頭アドレス
	sub.l	a1,d5			* d5.l = バッファＦ 使用数*8
	move.l	d5,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＧ 先頭アドレス
	suba.l	a1,a6			* a6.l = バッファＧ 使用数*8
	move.l	a6,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア

	adda.l	d0,a1			* a1.l = バッファＨ 先頭アドレス
	sub.l	a1,d6			* d6.l = バッファＨ 使用数*8
	move.l	d6,CHAIN_OFS_div(a1)	* チェイン情報（使用数*8）書き込み
					* かつ、スキップ数*8 を ０クリア




