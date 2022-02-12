*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_vsync(n);
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_vsync:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.w	A7ID+par1_w(sp),d0	* d0.w = n（帰線期間数）


*=======[ ＸＳＰシステム組込みチェック ]
	btst.b	#0,XSP_flg(pc)		* XSP は組み込まれているか？（bit0=1か？）
	bne.b	@F			* YES なら bra

	moveq	#-1,d0			* XSP が組み込まれていないので、戻り値＝−１
	bra.b	xsp_vsync_rts

*=======[ 指定ＶＳＹＮＣ単位の垂直同期 ]
@@:
	cmp.w	vsync_count(pc),d0
	bhi.b	@B			* vsync_count < par1（符号無視）ならループ

	move.w	vsync_count(pc),d0	* d0.w = 返り値
	clr.w	vsync_count


xsp_vsync_rts:
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_objdat_set( *sp_ref );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_objdat_set:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.l	A7ID+par1_l(sp),sp_ref_adr

	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_pcgdat_set( char *PCG_DAT , char *PCG_ALT , short PCG_ALT_ｻｲｽﾞ );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_pcgdat_set:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	movea.l	A7ID+par1_l(sp),a0	* a0.l = *PCG_DAT
	movea.l	A7ID+par2_l(sp),a1	* a1.l = *PCG_ALT
	move.w	A7ID+par3_w(sp),d0	* d0.w =  PCG_ALT ｻｲｽﾞ

*-------[ まず前回までの帰線期間ＰＣＧ定義が終了するまでＷＡＩＴ ]
	clr.w	vsync_count
	movem.l	d0-d2/a0-a2,-(sp)	* レジスタ退避
	move.l	#3,-(sp)		* 引数をＰＵＳＨ
	bsr	_xsp_vsync		* 3 vsync WAIT
	lea	4(sp),sp		* スタック補正
	movem.l	(sp)+,d0-d2/a0-a2	* レジスタ復活

*-------[ 各種ユーザー指定アドレス書込み ]
	move.l	a0,pcg_dat_adr
	addq.w	#1,a1			* 配置管理テーブルの先頭１バイトは飛ばす
	move.l	a1,pcg_alt_adr

*-------[ PCG_ALT 初期化 ]
					* a1.l = pcg_alt_adr
					* d0.w = クリア数 +1
	subq.w	#2,d0			* dbraカウンターとするため補正
@@:		clr.b	(a1)+
		dbra	d0,@B

*-------[ PCG_REV_ALT 初期化 ]
	lea	pcg_rev_alt,a1
	move.w	#255,d0			* 256.wクリアするための dbraカウンター
@@:		move.w	#-1,(a1)+
		dbra	d0,@B

*-------[ XSP内部フラグ処理 ]
	bset.b	#1,XSP_flg		* PCG_DAT , PCG_ALT が指定済を示すフラグをセット

	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_pcgmask_on( START_NO , END_NO );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_pcgmask_on:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.w	A7ID+par1_w(sp),d0	* d0.w = マスク設定 開始ナンバー
	move.w	A7ID+par2_w(sp),d1	* d1.w = マスク設定 終了ナンバー

*-------[ dbraカウンター初期値設定 ]
	cmpi.w	#256,d0
	bcc.b	xsp_mask_on_ERR		* #256 ≦ d1.w（符号無視）なら bra

	cmpi.w	#256,d1
	bcc.b	xsp_mask_on_ERR		* #256 ≦ d1.w（符号無視）なら bra

	tst.w	d0
	bne.b	@f
		addq.w	#1,d0		* マスク設定開始ナンバーが０なので、強制的に１にする。
@@:

	sub.w	d0,d1			* d1.w -= d0.w
	bmi.b	xsp_mask_on_ERR		* dbraカウンター ＜ 0 なら bra

	lea.l	OX_mask,a0		* a0.l = OX_mask トップアドレス
	adda.w	d0,a0			* a0.l = OX_mask 参照開始アドレス

*-------[ マスク加工 ]
	moveq.l	#255,d0			* d0.b = 255（マスクon）

@@:	move.b	d0,(a0)+		* マスク設定
	dbra	d1,@b			* 指定数処理するまでループ

	move.w	#1,OX_mask_renew	* OX_mask に更新があったことを伝える

*-------[ 正常終了 ]
	rts

*-------[ 引数が不正なので強制終了 ]
xsp_mask_on_ERR:
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_pcgmask_off( START_NO , END_NO );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_pcgmask_off:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.w	A7ID+par1_w(sp),d0	* d0.w = マスク設定 開始ナンバー
	move.w	A7ID+par2_w(sp),d1	* d1.w = マスク設定 終了ナンバー

*-------[ dbraカウンター初期値設定 ]
	cmpi.w	#256,d0
	bcc.b	xsp_mask_off_ERR	* #256 ≦ d1.w（符号無視）なら bra

	cmpi.w	#256,d1
	bcc.b	xsp_mask_off_ERR	* #256 ≦ d1.w（符号無視）なら bra

	tst.w	d0
	bne.b	@f
		addq.w	#1,d0		* マスク設定開始ナンバーが０なので、強制的に１にする。
@@:

	sub.w	d0,d1			* d1.w -= d0.w
	bmi.b	xsp_mask_off_ERR	* dbraカウンター ＜ 0 なら bra

	lea.l	OX_mask,a0		* a0.l = OX_mask トップアドレス
	adda.w	d0,a0			* a0.l = OX_mask 参照開始アドレス

*-------[ マスク加工 ]
	moveq.l	#0,d0			* d0.b = 0（マスクoff）

@@:	move.b	d0,(a0)+		* マスク設定
	dbra	d1,@b			* 指定数処理するまでループ

	move.w	#1,OX_mask_renew	* OX_mask に更新があったことを伝える

*-------[ 正常終了 ]
	rts

*-------[ 引数が不正なので強制終了 ]
xsp_mask_off_ERR:
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_mode( MODE_No.);
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_mode:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.w	A7ID+par1_w(sp),d0	* d0.w = MODE_No.

*-------[ 無効な値の場合、３が指定されたものとする ]
	tst.w	d0
	bne.b	@F
		moveq.l	#3,d0
@@:
	cmpi.w	#3,d0
	bls.b	@F			* 3≧d0.w なら bra
		moveq.l	#3,d0
@@:

	move.w	d0,sp_mode
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_vertical( flg );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_vertical:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.w	A7ID+par1_w(sp),vertical_flg
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_on();
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_on:

A7ID	=	4+15*4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 15*4 byte ]
	movem.l	d0-d7/a0-a6,-(sp)	* レジスタ退避


*=======[ ＸＳＰ組み込みチェック ]
	bset.b	#0,XSP_flg		* 組み込み状態か？（チェックと同時にフラグセット）
	beq.b	@F			* 0(=NO) なら組込み処理へ bra
		bra	xsp_on_rts	* 既に組み込まれているので、共通終了処理へ
@@:

*=======[ バッファ初期化 ]
	bsr	XSP_BUFF_INIT		* 全内部バッファ初期化（帰線期間転送バッファは除く）

*=======[ スーパーバイザーモードへ ]
	suba.l	a1,a1
	iocs	_B_SUPER		* スーパーバイザーモードへ
	move.l	d0,usp_bak		*（もともとスーパーバイザーモードなら d0.l=-1）


*=======[ ＸＳＰシステム組込み処理 ]
	ori.w	#$0700,sr		* 割り込みＯＦＦ
	bsr	WAIT			* ６８０３０対策

*-------[ MFPのバックアップを取る ]
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	lea.l	MFP_bak(pc),a1		* a1.l = MFP保存先アドレス

	move.b	AER(a0),AER(a1)		*  AER 保存
	move.b	IERA(a0),IERA(a1)	* IERA 保存
	move.b	IERB(a0),IERB(a1)	* IERB 保存
	move.b	IMRA(a0),IMRA(a1)	* IMRA 保存
	move.b	IMRB(a0),IMRB(a1)	* IMRB 保存

	move.l	$118,vektor_118_bak	* 変更前の V-disp ベクター
	move.l	$138,vektor_138_bak	* 変更前の CRT-IRQ ベクター
	move.w	$E80012,raster_No_bak	* 変更前の CRT-IRQ ラスターNo.

*-------[ V-DISP 割り込み設定 ]
	move.l	#VSYNC_INT,$118		* V-disp ベクター書換え
	bclr.b	#4,AER(a0)		* 帰線期間と同時に割り込む
	bset.b	#6,IMRB(a0)		* マスクをはがす
	bset.b	#6,IERB(a0)		* 割り込み許可

*-------[ H-SYNC 割り込み設定 ]
	move.w	#1023,$E80012		* 割り込みラスターナンバー（まだ割り込みＯＦＦ）
	move.l	#RAS_INT,$138		* CRT-IRQ ベクター書換え
	bclr.b	#6,AER(a0)		* 割り込み要求と同時に割り込む
	bset.b	#6,IMRA(a0)		* マスクをはがす
	bset.b	#6,IERA(a0)		* 割り込み許可

*------------------------------
	bsr	WAIT			* ６８０３０対策
	andi.w	#$f8ff,sr		* 割り込みＯＮ


*=======[ ユーザーモードへ ]
	move.l	usp_bak(pc),d0
	bmi.b	@F			* スーパーバイザーモードから実行されていたら戻す必要無し
		movea.l	d0,a1
		iocs	_B_SUPER	* ユーザーモードへ
@@:

*-------[ 終了 ]
xsp_on_rts:
	movem.l	(sp)+,d0-d7/a0-a6	* レジスタ復活
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_off();
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_off:

A7ID	=	4+15*4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 15*4 byte ]
	movem.l	d0-d7/a0-a6,-(sp)	* レジスタ退避


*=======[ ＸＳＰ組み込みチェック ]
	bclr.b	#0,XSP_flg		* 組み込み状態か？（チェックと同時にフラグクリア）
	bne.b	@F			* 1(=YES) なら組込み解除処理へ bra
		bra	xsp_off_rts	* もともと組み込まれていないので、共通終了処理へ
@@:


*=======[ スーパーバイザーモードへ ]
	suba.l	a1,a1
	iocs	_B_SUPER		* スーパーバイザーモードへ
	move.l	d0,usp_bak		*（もともとスーパーバイザーモードなら d0.l=-1）


*=======[ ＸＳＰシステム組込み解除処理 ]
	ori.w	#$0700,sr		* 割り込みＯＦＦ
	bsr	WAIT			* ６８０３０対策

*-------[ MFPの復活 ]
	movea.l	#$e88000,a0		* a0.l = MFPアドレス
	lea.l	MFP_bak(pc),a1		* a1.l = MFPを保存しておいたアドレス

	move.b	AER(a1),d0
	andi.b	#%0101_0000,d0
	andi.b	#%1010_1111,AER(a0)
	or.b	d0,AER(a0)		* AER bit4&6 復活

	move.b	IERA(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IERA(a0)
	or.b	d0,IERA(a0)		* IERA bit6 復活

	move.b	IERB(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IERB(a0)
	or.b	d0,IERB(a0)		* IERB bit6 復活

	move.b	IMRA(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IMRA(a0)
	or.b	d0,IMRA(a0)		* IMRA bit6 復活

	move.b	IMRB(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IMRB(a0)
	or.b	d0,IMRB(a0)		* IMRB bit6 復活

	move.l	vektor_118_bak,$118	* V-disp ベクター復活
	move.l	vektor_138_bak,$138	* CRT-IRQ ベクター復活
	move.w	raster_No_bak,$E80012	* CRT-IRQ ラスターNo. 復活

*------------------------------
	bsr	WAIT			* ６８０３０対策
	andi.w	#$f8ff,sr		* 割り込みＯＮ


*=======[ ユーザーモードへ ]
	move.l	usp_bak(pc),d0
	bmi.b	@F			* スーパーバイザーモードから実行されていたら戻す必要無し
		movea.l	d0,a1
		iocs	_B_SUPER	* ユーザーモードへ
@@:

*-------[ 終了 ]
xsp_off_rts:
	movem.l	(sp)+,d0-d7/a0-a6	* レジスタ復活
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_vsyncint_on( *PROC );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_vsyncint_on:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.l	A7ID+par1_l(sp),vsyncint_sub
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_vsyncint_off();
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_vsyncint_off:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.l	#dummy_proc,vsyncint_sub
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_hsyncint_on( *TIME_CHART );
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_hsyncint_on:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.l	A7ID+par1_l(sp),usr_chart
	rts




*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*
*	xsp_hsyncint_off();
*
*■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

_xsp_hsyncint_off:

A7ID	=	4			*   スタック上 return先アドレス  [ 4 byte ]
					* + 退避レジスタの全バイト数     [ 0 byte ]

	move.l	#dummy_chart,usr_chart
	rts




