*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_out();
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_out:

A7ID	=	4+14*4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 14*4 byte ]

*=======[ XSP 初期化チェック ]
	cmpi.b	#%0000_0011,XSP_flg
	beq.b	@F			* XSP が正しく初期化されているなら bra

	*-------[ 正しく初期化されていない ]
		moveq.l	#-1,d0		* 戻り値 = ｰ1
		rts			* 何もせず rts

@@:

*=======[ レジスタ退避など ]
	movem.l	d1-d7/a0-a6,-(sp)	* レジスタ退避

	move.l	a7,a7_bak1		* まずＡ７を保存。本関数内では、
					* 書換要求以外のスタックpushは
					* 禁止されている。

*=======[ スーパーバイザーモードへ ]
	suba.l	a1,a1
	iocs	_B_SUPER		* スーパーバイザーモードへ
	move.l	d0,usp_bak		* 元々スーパーバイザーモードなら、d0.l=-1



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	初期化
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆


*=======[ OX_mask更新手続き ]
	tst.w	OX_mask_renew
	beq.b	EXIT_OX_mask_renew

		clr.w	OX_mask_renew		* 更新フラグをクリア

	*-------[ OX_mask更新 ]
		moveq.l	#0,d0			* d0.l = 0
		move.b	OX_level(pc),d1
		sub.b	#1,d1			* d1.b = OX_tbl水位-1
		moveq.l	#-1,d2			* d2.l = -1（d2.b = 255）

		move.w	#255,d7			* d7.w = dbraカウンター 兼 PCGナンバー
		move.w	#255*2,d6		* d6.w = d7.w * 2

		moveq.l	#0,d4			* d4.l = 0（マスクoffのＰＣＧの 最小ナンバー）
		moveq.l	#0,d5			* d5.l = 0（マスクoffのＰＣＧの 最大ナンバー）

		lea.l	OX_tbl,a0		* a0.l = OX_tbl
		lea.l	OX_mask,a1		* a1.l = OX_mask
		lea.l	pcg_rev_alt,a2		* a2.l = pcg_rev_alt
		movea.l	pcg_alt_adr(pc),a3	* a3.l = pcg_alt

OX_mask_renew_LOOP:
		tst.b	(a1,d7.w)		* OX_mask onか？
		beq.b	OX_mask_off		* NO なら bra
		*-------[ OX_mask on ]
OX_mask_on:		move.b	d2,(a0,d7.w)	* 水位＝255 とする
			move.w	(a2,d6.w),d3	* d3.w = マスクされたPCGに定義されていたpt
			move.b	d0,(a3,d3.w)	* pcg_alt クリア（定義破棄）
			move.w	d2,(a2,d6.w)	* pcg_rev_alt クリア（定義破棄の重複を回避）
			bra.b	OX_mask_NEXT

		*-------[ OX_mask off ]		* 水位==255 の場合のみ、水位＝1 とする
OX_mask_off:		cmp.b	(a0,d7.w),d2	* 水位==255 か？
			bne.b	@f
				move.b	d1,(a0,d7.w)	* 現在の水位-1 を書き込む
							*(つまり最低１ターン待たないと
							* 使用不可。さもないと書き換えが
							* 見えてしまうのである。)
@@:
			move.w	d7,d4		* d4.w = マスクoffのＰＣＧの 最小ナンバー
			tst.w	d5
			bne.b	@f		* d5.w が非０なら bra
						*(つまり d5.w 設定は最初の１回きりである)
				move.w	d7,d5	* d5.w = マスクoffのＰＣＧの 最大ナンバー
@@:
OX_mask_NEXT:
		sub.w	#2,d6
		dbra	d7,OX_mask_renew_LOOP

	*-------[ 検索開始アドレスと検索サイズ-1 を求める ]

		* マスクoffのPCGが１枚も存在しなかった時、d4.w d5.w ともに０である。
		* よって、検索サイズ-1＝０となり、１枚限りの検索となる。
		* また、検索開始PCGのナンバーは０となる。０番PCGは必ず「使用」である
		* から、つまりPCG定義は実質実行されないことになる。

						* a0.l = OX_tbl
		add.w	d4,a0			* a0.l = OX_tbl 検索開始アドレス
		move.l	a0,OX_chk_top		* OX_tbl 検索開始アドレスに保存
		move.l	a0,OX_chk_ptr		* OX_tbl 検索ポインターに保存
		sub.w	d4,d5			* d5.w = 検索サイズ-1
		move.w	d5,OX_chk_size		* OX_tbl 検索サイズ-1 に保存

EXIT_OX_mask_renew:



*=======[ OX_tbl水位調整 ]
OX_level_INC:
	lea.l	OX_level(pc),a0		* (a0).b = OX_level.b
	addq.b	#1,(a0)			* OX_level.b++
	cmpi.b	#255,(a0)
	bne	OX_level_INC_END	* (#255 != OX_level) なら bra

	*-------[ 水位の引き下げ処理 ]
		move.b	#4,(a0)		* OX_level.b = 4

		lea.l	OX_tbl,a0	* a0.l = OX_tbl
		moveq.l	#0,d0		* d0.l = 0
		moveq.l	#31,d1		* d1.l = 31（dbraカウンター）
@@:
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		dbra	d1,@B

		bra	OX_level_INC_END


OX_tbl_INIT_TBL:
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01

	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01

	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01

	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$02,$03,$FF


OX_level_INC_END:



*=======[ 使用スプライト数などを求める ]
	lea	buff_top_adr,a0		* a0.l = #buff_top_adr
	move.l	buff_pointer(pc),d0
	sub.l	a0,d0			* d0.w =（仮バッファ上の）スプライト数＊８

	move.w	sp_mode(pc),d1		* d1.w = sp_mode
	cmpi.w	#1,d1			* １２８枚モードか？
	bne.b	@F			* NO なら bra
		cmpi.w	#384*8,d0
		ble.b	EXIT_GET_TOTAL_SP	* #384*8≧d0 なら bra
			move.w	#384*8,d0	* ３８４枚以下に修正
			move.l	#buff_top_adr+384*8,buff_pointer
			bra.b	EXIT_GET_TOTAL_SP
@@:
	cmpi.w	#128*8,d0
	bgt.b	@F			* #128*8＜d0 なら bra
		moveq	#1,d1		* １２８枚以下の場合は一時的に１２８枚モード
		bra.b	EXIT_GET_TOTAL_SP
@@:
	move.w	sp_mode(pc),d1		* ５１２枚モードにする

EXIT_GET_TOTAL_SP:
					* d0.w = 加工済使用スプライト数＊８
					* d1.w = 加工済sp_mode


*=======[ その他 ]
	move.l	write_struct(pc),a1	* a1.l = 書換用バッファ管理構造体
	move.w	d1,buff_sp_mode(a1)	* バッファナンバー別 sp_mode保存
	move.w	d0,buff_sp_total(a1)	* バッファナンバー別 スプライト数＊８ 保存

					*--------------------------
					* d0.w = スプライト数＊８
					* a0.l = #buff_top_adr
					*--------------------------



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	スプライト加工 ＆ チェイン作成
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

					* d0.w = スプライト数＊８
					* a0.l = #buff_top_adr

	clr.w	-2(a0)			* 仮バッファ end_mark（ＰＲが０）

*-------[ レジスタ初期化 ]
					*---------------------------------------------
	adda.w	d0,a0			* a0.l = 仮バッファスキャン（末端より）
	lea.l	pr_top_tbl,a1		* a1.l = ＰＲ別先頭テーブル
					* a2.l = 
	movea.l	pcg_alt_adr(pc),a3	* a3.l = pcg_alt
					* a4.l = 
					* a5.l = 
	lea.l	OX_tbl,a6		* a6.l = OX_tbl
					* a7.l = PCG定義要求バッファ
					*---------------------------------------------

*-------[ PCG定義要求バッファに end_mark ]
	move.w	#-1,-(a7)		* ptに負
	subq.w	#4,a7			* ポインター補正

*-------[ ＰＲ別先頭テーブル[32].l の初期化 ]
	move.l	#buff_end_adr,d0	* d0.l = 終点ダミーＰＲブロックのアドレス
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7

					* a1.l = ＰＲ別先頭テーブル
	movem.l	d0-d7,$00*4(a1)
	movem.l	d0-d7,$08*4(a1)
	movem.l	d0-d7,$10*4(a1)
	movem.l	d0-d7,$18*4(a1)
	movem.l	d0-d7,$20*4(a1)
	movem.l	d0-d7,$28*4(a1)
	movem.l	d0-d7,$30*4(a1)
	movem.l	d0-d7,$38*4(a1)		* 合計 64.l 初期化


*=======[ スプライト加工 ＆ チェイン作成（非縦画面モード）]
					*---------------------------------------------
					* d0.w = tmp（pt 読み取り＆加工）
	moveq.l	#0,d1			* d1.w = PCG_No.w（bit8〜が０）
					* d2.w = 現info（同一ＰＲチェック用）
	moveq.l	#0,d3			* d3.w = 現pr/16（bit8〜が０）
	moveq.l	#0,d4			* d4.w =(現pr & 63)*4（bit8〜が０）
					* d5.w = tmp（info 読み取り＆加工）
	move.b	OX_level(pc),d6		* d6.b = OX_tbl水位
					* d7.w = 同一ＰＲ連鎖数
					*---------------------------------------------

	tst.w	vertical_flg		* 縦画面モードか？
	bne	VERTICAL_MODE		* YES なら bra


	move.w	-4(a0),d0		*[12]	最初の pt
	move.w	-2(a0),d5		*[12]	最初の info

	bra.b	START_MK_CHAIN		*[10]


*-------[ ＰＣＧ定義要求 ]
REQ_PCGDEF:
	move.w	d3,-(a0)		* 現pr/16 転送
	move.w	d5,-(a0)		* [反:色:ＰＲ].w を未加工cdとして転送
	move.w	d0,-(a7)		* 定義したいptを保存
	move.l	a0,-(a7)		* ptアドレスを保存

	addq.w	#1,d7			* 連鎖数加算
	subq.w	#8,a0			* スキャンポインター移動

	move.w	(a0)+,d0		* d0.w = pt
	move.w	(a0)+,d5		* d5.w = info
	cmp.b	d2,d5			* 同一ＰＲか？
	bne.b	NOT_SAME_PR		* NO なら bra

*-------[ ループ ]
MK_CHAIN_LOOP:
	move.b	(a3,d0.w),d1		* d1.w = PCG_No.
	beq.b	REQ_PCGDEF
	move.b	d6,(a6,d1.w)		* OX_tblに「使用」を書込み

	move.w	d3,-(a0)		* 現pr/16を転送
	move.b	d1,d5			* d5.w = [反:色:PCG_No].w（＝cd）
	move.w	d5,-(a0)		* 加工済cd 転送

	addq.w	#1,d7			* 連鎖数加算
	subq.w	#8,a0			* スキャンポインター移動

	move.w	(a0)+,d0		* d0.w = pt
	move.w	(a0)+,d5		* d5.w = info
	cmp.b	d2,d5			* 同一ＰＲか？
	beq.b	MK_CHAIN_LOOP		* YES なら bra

*-------[ ＰＲ変更 ]
NOT_SAME_PR:
					* a0.l = 変更前ＰＲ鎖の先頭アドレス（SP_x の位置）
					* d4.w =(変更前ＰＲ & 63)*4
	move.l	a0,(a1,d4.w)		* ＰＲ別先頭テーブルへ保存
	move.w	d7,CHAIN_OFS(a0)	* 連鎖数保存

START_MK_CHAIN:
	move.w	d5,d2			* d2.w = 変更後info（同一ＰＲチェック用）
	move.b	d5,d4
	add.b	d4,d4
	add.b	d4,d4			* d4.w = (変更後ＰＲ*4)&255 = (変更後ＰＲ & 63)*4
	move.l	(a1,d4.w),CHAIN_OFS-4(a0)	* NEXTポインターにＰＲ別先頭アドレスを書き込む

	moveq.l	#-1,d7			* 連鎖数クリア
	move.b	d5,d3
	asr.w	#4,d3			* d3.w = 次pr/16
	bne.b	MK_CHAIN_LOOP		* 非０なら繰り返し

*-------[ ０なので end_mark の可能性有り ]
	move.b	#$10,d2			* pr=0 が連鎖するとend_markを取りこぼすので無理やり補正

	cmpa.l	#buff_top_adr,a0	* 本当に終点までスキャンしたか？
	bne.b	MK_CHAIN_LOOP		* NO なら繰り返し

	bra	PCG_DEF_1



*=======[ スプライト加工 ＆ チェイン作成（縦画面モード）]
VERTICAL_MODE:

	move.w	#XY_MAX,a2		*[ 8]	a2.l = XY_MAX（縦画面 x,y 加工用）

	subq.w	#8,a0
	move.l	(a0),d0			*[12]	d0.l = 最初の x , y
	neg.w	d0			*[ 4]	d0.w =- d0.w
	add.w	a2,d0			*[ 4]	d0.w += XY_MAX
	swap	d0			*[ 4]	x,y 交換
	move.l	d0,(a0)+		*[12]	加工済み x,y 転送

	move.w	(a0)+,d0		*[ 8]	d0.w = 最初の pt
	move.w	(a0)+,d5		*[ 8]	d5.w = 最初の info

	bra.b	START_MK_CHAIN_v	*[10]


*-------[ ＰＣＧ定義要求 ]
REQ_PCGDEF_v:
	move.w	d0,-(a7)		*[ 8]	定義したいptを保存

	move.w	d5,d0			*[ 4]	d0.w 上位２ビット＝反転コード
	add.w	d0,d0			*[ 4]	上位２ビットが 01 又は 10 の時、V=1
	bvc.b	@f			*[8,10]	V=0 なら bra
		eor.w	#$C000,d5	*[ 8]	反転コード加工
@@:
	move.w	d3,-(a0)		*[ 8]	現pr/16 転送
	move.w	d5,-(a0)		*[ 8]	[反:色:ＰＲ].w を未加工cdとして転送
	move.l	a0,-(a7)		*[12]	ptアドレスを保存

	addq.w	#1,d7			*[ 4]	連鎖数加算
	lea.l	-12(a0),a0		*[ 8]	スキャンポインター移動

	move.l	(a0),d0			*[12]	d0.l = x , y
	neg.w	d0			*[ 4]	d0.w = -d0.w
	add.w	a2,d0			*[ 4]	d0.w += XY_MAX
	swap	d0			*[ 4]	x,y 交換
	move.l	d0,(a0)+		*[12]	加工済み x,y 転送

	move.w	(a0)+,d0		*[ 8]	d0.w = pt
	move.w	(a0)+,d5		*[ 8]	d5.w = info
	cmp.b	d2,d5			*[ 4]	同一ＰＲか？
	bne.b	NOT_SAME_PR_v		*[8,10]	NO なら bra

*-------[ ループ ]
MK_CHAIN_LOOP_v:
	move.b	(a3,d0.w),d1		*[14]	d1.w = PCG_No.
	beq.b	REQ_PCGDEF_v		*[8,10]
	move.b	d6,(a6,d1.w)		*[14]	OX_tblに「使用」を書込み

	move.w	d3,-(a0)		*[ 8]	現pr/16を転送
	move.b	d1,d5			*[ 4]	d5.w = [反:色:PCG_No].w（＝cd）

	move.w	d5,d0			*[ 4]	d0.w 上位２ビット＝反転コード
	add.w	d0,d0			*[ 4]	上位２ビットが 01 又は 10 の時、V=1
	bvc.b	@f			*[8,10]	V=0 なら bra
		eor.w	#$C000,d5	*[ 8]	反転コード加工
@@:
	move.w	d5,-(a0)		*[ 8]	加工済cd 転送

	addq.w	#1,d7			*[ 4]	連鎖数加算
	lea.l	-12(a0),a0		*[ 8]	スキャンポインター移動

	move.l	(a0),d0			*[12]	d0.l = x , y
	neg.w	d0			*[ 4]	d0.w = -d0.w
	add.w	a2,d0			*[ 4]	d0.w += XY_MAX
	swap	d0			*[ 4]	x,y 交換
	move.l	d0,(a0)+		*[12]	加工済み x,y 転送

	move.w	(a0)+,d0		*[ 8]	d0.w = pt
	move.w	(a0)+,d5		*[ 8]	d5.w = info
	cmp.b	d2,d5			*[ 4]	同一ＰＲか？
	beq.b	MK_CHAIN_LOOP_v		*[8,10]	YES なら bra

*-------[ ＰＲ変更 ]
NOT_SAME_PR_v:
					* a0.l = 変更前ＰＲ鎖の先頭アドレス（SP_x の位置）
					* d4.w =(変更前ＰＲ & 63)*4
	move.l	a0,(a1,d4.w)		* ＰＲ別先頭テーブルへ保存
	move.w	d7,CHAIN_OFS(a0)	* 連鎖数保存

START_MK_CHAIN_v:
	move.w	d5,d2			* d2.w = 変更後info（同一ＰＲチェック用）
	move.b	d5,d4
	add.b	d4,d4
	add.b	d4,d4			* d4.w = (変更後ＰＲ*4)&255 = (変更後ＰＲ & 63)*4
	move.l	(a1,d4.w),CHAIN_OFS-4(a0)	* NEXTポインターにＰＲ別先頭アドレスを書き込む

	moveq.l	#-1,d7			* 連鎖数クリア
	move.b	d5,d3
	asr.w	#4,d3			* d3.w = 次pr/16
	bne.b	MK_CHAIN_LOOP_v		* 非０なら繰り返し

*-------[ ０なので end_mark の可能性有り ]
	move.b	#$10,d2			* pr=0 が連鎖するとend_markを取りこぼすので無理やり補正

	cmpa.l	#buff_top_adr,a0	* 本当に終点までスキャンしたか？
	bne.b	MK_CHAIN_LOOP_v		* NO なら繰り返し




*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	ＰＣＧ定義処理１
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

PCG_DEF_1:
	move.l	write_struct(pc),a2	* a2.l = 書換用バッファ管理構造体
	lea.l	vsync_def(a2),a2	* a2.l = 帰線期間ＰＣＧ定義要求バッファ
					* a3.l = pcg_alt
					* a6.l = OX_tbl
					* a7.l = PCG定義要求バッファポインター

*-------[ 初期化 ]
					*----------------------------------------------
					* a0.l = temp
					* a1.l = temp
					* a2.l = 帰線期間ＰＣＧ定義要求バッファ
					* a3.l = pcg_alt
	lea.l	pcg_rev_alt,a4		* a4.l = pcg_rev_alt
	movea.l	OX_chk_ptr(pc),a5	* a5.l = OX_tbl 検索ポインター
					* a6.l = OX_tbl
					* a7.l = PCG定義要求バッファポインター
					*----------------------------------------------
					* d0.w = temp（pt 読みだし）
					* d1.w = PCG_No.w（bit8〜の事前の０クリア必要なし）
					* d2.l = temp
					* d3.l = temp
	move.l	#$EB8000,d4		* d4.l = #$EB8000（下位１バイトは 0 のかわり）
	move.l	pcg_dat_adr(pc),d5	* d5.l = PCGデータアドレス
					* d6.b = OX_tbl水位
	move.w	OX_chk_size(pc),d7	* d7.w = PCG検索のdbccカウンター
					*----------------------------------------------

	move.b	d6,d2			* d2.b = OX_tbl水位
	subq.b	#2,d2			* d2.b = OX_tbl水位 - 2

	bra.b	PCG_DEF_1_START


*=======[ ＰＣＧ定義処理１ 完全終了 ]
PCG_DEF_1_END:
	bra	PCG_DEF_COMPLETE	* ブランチ中継


*-------[ 未処理 cd の修正ループ ]
@@:
	move.b	d1,1(a0)		* 未処理 cd 修正
PCG_DEF_1_START:
	movea.l	(a7)+,a0		* a0.l = 修正が必要な cd アドレス
	move.w	(a7)+,d0		* d0.w = 定義する pt
	bmi.b	PCG_DEF_1_END		* 負なら完全終了
PCG_DEF_1_L0:
	move.b	(a3,d0.w),d1		* d1.b = PCG_No.
	bne.b	@B			* 定義されているなら bra

	*-------[ 空きＰＣＧ検索 ]
@@:		cmp.b	(a5)+,d2	* ＜d2.b なら３フレーム未使用
		dbhi	d7,@B		* 注：cc成立でループを抜ける時、d7.w はデクリされない
					* (cc成立 && d7≧0) || (cc不成立 && d7＜0)
		bls	PCG_DEF_2	* cc不成立なら (この時必ず d7＜0 && 非終点) 不完全終了

		tst.b	-(a5)		* end_mark(0) か？
		bne.b	FOUND_PCG_1	* No なら bra
		*-------[ 未使用ＰＣＧでなく、end_mark だった ]
			move.l	OX_chk_top(pc),a5	* OX_tbl 検索ポインターを先頭に戻す
			bra.b	@B			* ループ
							* d7.w++ 補正は不用（上記注意参照）

	*-------[ 未使用ＰＣＧ発見 ]
FOUND_PCG_1:
		move.w	a5,d1
		sub.w	a6,d1			* d1.w = a5.w - OX_tbl.w = PCG_No.
		move.b	d1,1(a0)		* 未処理 cd 修正
		move.b	d6,(a5)+		* OX_tblに現在の水位を書込み

	*-------[ ＰＣＧ配置管理テーブル処理 ]
						*[d0.w = 定義するpt (0〜0x7FFF)]
						*[d1.w = 定義先PCG_No.(0〜255)]
		move.b	d1,(a3,d0.w)		* pcg_alt 書込み
		add.w	d1,d1			* d1.w = 定義先 PCG No.*2
						*[a4.l = pcg_rev_alt アドレス]
		move.w	(a4,d1.w),d3		* d3.w = 描き潰されるpt
		move.b	d4,(a3,d3.w)		* 描き潰されるptを未定義にする
		move.w	d0,(a4,d1.w)		* 新たに pcg_rev_alt 書込み

	*-------[ ＰＣＧ定義実行 ]
		ext.l	d0			* d0.l = 定義するpt
		lsl.l	#7,d0			* d0.l = 定義するpt * 128
		add.l	d5,d0			* d0.l = PCGデータアドレス + pt * 128
						*      = 転送元

		ext.l	d1			* d1.l = 定義先 PCG_No.* 2
		lsl.w	#6,d1			* d1.l = 定義先 PCG_No.* 128（.w で破綻しない）
		add.l	d4,d1			* d1.l = #$EB8000 + PCG_No.* 128
						*      = 転送先

		movea.l	d0,a0
		movea.l	d1,a1

		.rept	32
			move.l	(a0)+,(a1)+	* 1PCG 転送
		.endm

	*-------[ 次のスプライトへ ]
		dbra	d7,PCG_DEF_1_START

						* 不完全終了
		movea.l	(a7)+,a0		* つじつま合せ
		move.w	(a7)+,d0		* つじつま合せ
		bmi	PCG_DEF_COMPLETE	* d0.wが負なら完全終了




*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	ＰＣＧ定義処理２（ＰＣＧが足りず帰線期間ＰＣＧ定義要求）
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

PCG_DEF_2:
					*----------------------------------------------
					* a0.l = temp
					* a1.l = temp
					* a2.l = 帰線期間ＰＣＧ定義要求バッファ
					* a3.l = pcg_alt アドレス
					* a4.l = pcg_rev_alt アドレス
					* a5.l = OX_tbl 検索ポインター
					* a6.l = OX_tbl
					* a7.l = PCG定義要求バッファポインター
					*----------------------------------------------
					* d0.w = temp（pt 読みだし）
					* d1.w = PCG_No.w（bit8〜の事前の０クリア必要なし）
	moveq.l	#30,d2			* d2.w = 31PCG まで検索するためのdbccカウンター
					* d3.l = temp
					* d4.l = #$EB8000（下位１バイトは 0 のかわり）
					* d5.l = PCGデータアドレス
					* d6.b = OX_tbl水位
	move.w	OX_chk_size(pc),d7	* d7.w = PCG検索のdbccカウンター
					*----------------------------------------------
					* a0.l = PCG_DEF_1 で未処理の 修正先アドレス
					* d0.w = PCG_DEF_1 で未処理の pt

	bra.b	PCG_DEF_2_L0		* a0.l d0.w の読み出し部分は飛ばす


*=======[ ＰＣＧ定義処理１ 完全終了 ]
PCG_DEF_2_END:
	bra	PCG_DEF_COMPLETE	* ブランチ中継


*-------[ 未処理 cd の修正ループ ]
@@:
	move.b	d1,1(a0)		* 未処理 cd 修正
PCG_DEF_2_START:
	movea.l	(a7)+,a0		* a0.l = 修正が必要な cd アドレス
	move.w	(a7)+,d0		* d0.w = 定義する pt
	bmi.b	PCG_DEF_2_END		* 負なら完全終了
PCG_DEF_2_L0:
	move.b	(a3,d0.w),d1		* d1.b = PCG_No.
	bne.b	@B			* 定義されているなら bra

	*-------[ 空きＰＣＧ検索 ]
@@:		cmp.b	(a5)+,d6	* ＜d6.b なら今回のフレームにおいて未使用
		dbhi	d7,@B		* 注：cc成立でループを抜ける時、d7.w はデクリされない
					* (cc成立 && d7≧0) || (cc不成立 && d7＜0)
		bls.b	PCG_DEF_3	* cc不成立なら (この時必ず d7＜0 && 非終点) 不完全終了

		tst.b	-(a5)		* end_mark(0) か？
		bne.b	FOUND_PCG_2	* No なら bra
		*-------[ 未使用ＰＣＧでなく、end_mark だった ]
			move.l	OX_chk_top(pc),a5	* OX_tbl 検索ポインターを先頭に戻す
			bra.b	@B			* ループ
							* d7.w++ 補正は不用（上記注意参照）

	*-------[ 未使用ＰＣＧ発見 ]
FOUND_PCG_2:
		move.w	a5,d1
		sub.w	a6,d1			* d1.w = a5.w - OX_tbl.w = PCG_No.
		move.b	d1,1(a0)		* 未処理 cd 修正
		move.b	d6,(a5)+		* OX_tblに現在の水位を書込み

	*-------[ ＰＣＧ配置管理テーブル処理 ]
						*[d0.w = 定義するpt (0〜0x7FFF)]
						*[d1.w = 定義先PCG_No.(0〜255)]
		move.b	d1,(a3,d0.w)		* pcg_alt 書込み
		add.w	d1,d1			* d1.w = 定義先 PCG No.*2
						*[a4.l = pcg_rev_alt アドレス]
		move.w	(a4,d1.w),d3		* d3.w = 描き潰されるpt
		move.b	d4,(a3,d3.w)		* 描き潰されるptを未定義にする
		move.w	d0,(a4,d1.w)		* 新たに pcg_rev_alt 書込み

	*-------[ ＰＣＧ定義実行 ]
		ext.l	d0			* d0.l = 定義するpt
		lsl.l	#7,d0			* d0.l = 定義するpt * 128
		add.l	d5,d0			* d0.l = PCGデータアドレス + pt * 128
						*      = 転送元

		ext.l	d1			* d1.l = 定義先 PCG_No.* 2
		lsl.w	#6,d1			* d1.l = 定義先 PCG_No.* 128（.w で破綻しない）
		add.l	d4,d1			* d1.l = #$EB8000 + PCG_No.* 128
						*      = 転送先

		move.l	d1,(a2)+		* 帰線期間ＰＣＧ定義要求バッファへ（転送先）
		move.l	d0,(a2)+		* 帰線期間ＰＣＧ定義要求バッファへ（転送元）

	*-------[ 次のスプライトへ ]
		dbra	d2,@f
		bra.b	PCG_DEF_2_L1		* 帰線期間ＰＣＧ定義要求バッファが足りない
@@:
		dbra	d7,PCG_DEF_2_START


PCG_DEF_2_L1:
						* 不完全終了
		movea.l	(a7)+,a0		* つじつま合せ
		move.w	(a7)+,d0		* つじつま合せ
		bmi.b	PCG_DEF_COMPLETE	* d0.wが負なら完全終了




*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	ＰＣＧ定義処理３（ＰＣＧが足りず定義要求取り下げ）
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

PCG_DEF_3:
	moveq.l	#0,d2			* d2.l = 0

	bra.b	PCG_DEF_3_L0		* a0.l d0.w の読み出し部分は飛ばす


*-------[ 未処理 cd の修正ループ ]
@@:
	move.b	d1,1(a0)		* 未処理 cd 修正
PCG_DEF_3_START:
	movea.l	(a7)+,a0		* a0.l = 修正が必要な cd アドレス
	move.w	(a7)+,d0		* d0.w = 定義する pt
	bmi.b	PCG_DEF_COMPLETE	* 負なら終了
PCG_DEF_3_L0:
	move.b	(a3,d0.w),d1		* d1.b = PCG_No.
	bne.b	@B			* 定義されているなら bra
	*-------[ 消去してしまう ]
		move.w	d2,2(a0)	* prに０（表示ＯＦＦ）

		movea.l	(a7)+,a0	* a0.l = 修正が必要な cd アドレス
		move.w	(a7)+,d0	* d0.w = 定義する pt
		bpl.b	PCG_DEF_3_L0	* end_mark でないなら bra


PCG_DEF_COMPLETE:
	move.l	#-1,(a2)		* 帰線期間ＰＣＧ定義要求バッファへ end_mark 書込み
	move.l	a5,OX_chk_ptr		* OX_tbl 検索ポインター保存




*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	ＰＲ別先頭アドレスの必要なものをスタックに転送
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

LINK_CHAIN:

*-------[ 初期化 ]
	lea.l	buff_end_adr,a0		* a0.l = 終点ダミーＰＲブロック
	move.w	#-1,CHAIN_OFS(a0)	* 終点ダミーチェインに、end_mark（連鎖数-1）書き込み
	move.l	a0,-(a7)		* スタックに end_mark として書き込む

	lea.l	pr_top_tbl,a1		* a1.l = ＰＲ別先頭テーブル
	move.l	#-1,64*4(a1)		* ＰＲ別先頭テーブル末端に end_mark(-1)書込み
	lea.l	$10*4(a1),a1		* pr≧$10 に強制補正しているので、pr=$10よりスキャン

*-------[ ＰＲ別先頭検索 ]
SEARCH_PR_TOP:
	move.l	(a1)+,d0		* d0.l = ＰＲ別先頭アドレス
	bmi.b	LINK_CHAIN_END		* end_mark(-1)なら終了
SEARCH_PR_TOP_:
	cmp.l	a0,d0			* 終点ダミーＰＲブロックを指しているか？
	beq.b	SEARCH_PR_TOP		* YES ならスキップ
	move.l	d0,-(a7)		* ＰＲ別先頭アドレスをスタックへ転送

	move.l	(a1)+,d0		* d0.l = ＰＲ別先頭アドレス
	bpl.b	SEARCH_PR_TOP_		* end_mark(-1)でないなら繰り返し

LINK_CHAIN_END:



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	sp_mode 別スプライト処理（ラスター分割等）
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆

SP_RAS_SORT:

	move.l	write_struct(pc),a0	* a0.l = 書換用バッファ管理構造体
	move.w	buff_sp_mode(a0),d0	* d0.w = 加工済sp_mode
	cmpi.w	#2,d0			* 最大５１２枚モードか？
	beq.b	SP_RAS_SORT_mode2	* YES なら bra
	cmpi.w	#3,d0			* 最大５１２枚（優先度保護）モードか？
	beq	SP_RAS_SORT_mode3	* YES なら bra

*=======[ 最大１２８枚モード ]
SP_RAS_SORT_mode1:
	.include	XSP128.s
	bra	SP_RAS_SORT_END

*=======[ 最大５１２枚モード ]
SP_RAS_SORT_mode2:
	.include	XSP512.s
	bra	SP_RAS_SORT_END

*=======[ 最大５１２枚（優先度保護）モード ]
SP_RAS_SORT_mode3:
	.include	XSP512b.s

SP_RAS_SORT_END:



*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆
*
*	書換用バッファをチェンジ
*
*◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆


*=======[ 書換用バッファをチェンジ ]
	movea.l	write_struct(pc),a0	* a0.l = 書換用バッファ管理構造体アドレス
	lea.l	STRUCT_SIZE(a0),a0

	cmpa.l	#endof_XSP_STRUCT,a0	* 終点まで達したか？
	bne.b	@F			* No なら bra
	lea.l	XSP_STRUCT,a0
@@:
	cmpa.l	disp_struct(pc),a0	* 表示用バッファ管理構造体と重なっているか？
	beq.b	@B			* 重なっているなら表示用バッファが変更されるまで待つ。
	move.l	a0,write_struct		* 書換用バッファ管理構造体アドレス 書換え


*=======[ ユーザーモードへ ]
	move.l	usp_bak(pc),d0
	bmi.b	@F			* スーパーバイザーモードより実行されていたら戻す必要無し
		movea.l	d0,a1
		iocs	_B_SUPER	* ユーザーモードへ
@@:

*-------[ 戻り値 ]
	move.l	buff_pointer(pc),d0
	sub.l	#buff_top_adr,d0
	asr.l	#3,d0				* 戻り値＝仮バッファ上のスプライト数

	move.l	#buff_top_adr,buff_pointer	* 仮バッファのポインターを初期化

	movea.l	a7_bak1(pc),a7			* Ａ７復活
	movem.l	(sp)+,d1-d7/a0-a6		* レジスタ復活
						* d0.l は戻り値

	rts




