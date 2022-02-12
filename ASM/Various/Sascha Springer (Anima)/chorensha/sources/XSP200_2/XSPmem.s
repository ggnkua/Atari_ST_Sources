
	.text
	.even

vektor_118_bak:	dc.l	0		* 変更前の V-disp ベクタ
vektor_138_bak:	dc.l	0		* 変更前の CRT-IRQ ベクタ
raster_No_bak:	dc.w	0		* 変更前の CRT-IRQ ラスターNo.
MFP_bak:	dcb.b	$18,0		* 変更前の MFP

	.even


*--------------[ スプライト仮バッファのポインター ]
buff_pointer:
		dc.l	buff_top_adr

*--------------[ ユーザー指定帰線期間割り込み ]
vsyncint_sub:	dc.l	dummy_proc	* 割り込み処理サブルーチンアドレス（初期値はダミー）

*--------------[ ラスター割り込み関係 ]
hsyncint_sub:	dc.l	dummy_proc	* 割り込み処理サブルーチンアドレス（初期値はダミー）
xsp_chart_ptr:	dc.l	dummy_chart	* XSP側チャートへのポインター（初期値はダミー）
usr_chart_ptr:	dc.l	dummy_chart	* USR側チャートへのポインター（初期値はダミー）
usr_chart:	dc.l	dummy_chart	* USR側チャートへのポインター初期値（USR指定可能）

*--------------[ その他 ]
sp_mode:	dc.w	2		* ＸＳＰのモード（１〜３）

R65535:		dc.w	0		* システム内部カウンター

write_struct:	dc.l	XSP_STRUCT	* 書換用バッファ管理構造体アドレス
disp_struct:	dc.l	XSP_STRUCT	* 表示用バッファ管理構造体アドレス

vsync_count:	dc.w	0		* 帰線期間が来たらインクリする

sp_ref_adr:	dc.l	0		* 複合スプライトのリファレンスデータへのポインター

pcg_alt_adr:	dc.l	0		* pcg_altへのポインター（ユーザー指定）

pcg_dat_adr:	dc.l	0		* PCGデータへのポインター（ユーザー指定）

OX_level:	dc.b	0		* OX_tbl水位
	.even
OX_mask_renew:	dc.w	0		* OX_mask 更新があったことを示すフラグ（非０で更新）
OX_chk_top:	dc.l	0		* OX_tbl 検索開始アドレス
OX_chk_ptr:	dc.l	0		* OX_tbl 検索ポインター
OX_chk_size:	dc.w	0		* OX_tbl 検索サイズ-1（dbraカウンターとする）

a7_bak1:	dc.l	0		* Ａ７レジスタを保存（レジスタ退避直後）

usp_bak:	dc.l	0		* usp 保存

XSP_flg:	dc.b	0		* ＸＳＰ初期化状態のフラグ（８ビット）
					* bit0 = 組込み状態か？
					* bit1 = PCG_DAT,PCG_ALT 指定済か？
	.even

vertical_flg:	dc.w	0		* 縦画面モードフラグ（非０＝縦画面モード）


*==============================================================

	.bss
	.even


*--------------[ ＸＳＰ管理構造体（バッファＮｏ．別）]
XSP_STRUCT:
		ds.b	STRUCT_SIZE*3
endof_XSP_STRUCT:


*----------------[ スプライト仮バッファ ＆ 優先度ソート関係のバッファ ]

		ds.b	8		* end_mark（pr=0）
buff_top_adr:	ds.b	8*SP_MAX	* push可能枚数＊８バイト
buff_end_adr:	ds.b	8		* end_mark（８バイトの -1）兼 終点ダミーＰＲブロック
		ds.b	8*SP_MAX	* ソートチェイン作成バッファ
		ds.b	8		* 終点ダミーチェイン

pr_top_tbl:	ds.l	64		* ＰＲ別先頭テーブル
		ds.l	1		* end_mark用


*----------------[ ラスター別分割ソート済みスプライト保存バッファ ]

*	バッファは表示用・書換用・予備用の合計３本（Ｎｏ．０〜２）
*	それぞれ分割ラスター別に４つに細分されます。


*	[ + $0000 ＝ バッファNo.0 ]
div_buff_0A:	ds.b	8*64		* ラスター分割バッファＡ
		ds.b	8		* end_mark
div_buff_0B:	ds.b	8*64		* ラスター分割バッファＢ
		ds.b	8		* end_mark
div_buff_0C:	ds.b	8*64		* ラスター分割バッファＣ
		ds.b	8		* end_mark
div_buff_0D:	ds.b	8*64		* ラスター分割バッファＤ
		ds.b	8		* end_mark
div_buff_0E:	ds.b	8*64		* ラスター分割バッファＥ
		ds.b	8		* end_mark
div_buff_0F:	ds.b	8*64		* ラスター分割バッファＦ
		ds.b	8		* end_mark
div_buff_0G:	ds.b	8*64		* ラスター分割バッファＧ
		ds.b	8		* end_mark
div_buff_0H:	ds.b	8*64		* ラスター分割バッファＨ
		ds.b	8		* end_mark


*	[ + $1040 ＝ バッファNo.1 ]
div_buff_1A:	ds.b	8*64		* ラスター分割バッファＡ
		ds.b	8		* end_mark
div_buff_1B:	ds.b	8*64		* ラスター分割バッファＢ
		ds.b	8		* end_mark
div_buff_1C:	ds.b	8*64		* ラスター分割バッファＣ
		ds.b	8		* end_mark
div_buff_1D:	ds.b	8*64		* ラスター分割バッファＤ
		ds.b	8		* end_mark
div_buff_1E:	ds.b	8*64		* ラスター分割バッファＥ
		ds.b	8		* end_mark
div_buff_1F:	ds.b	8*64		* ラスター分割バッファＦ
		ds.b	8		* end_mark
div_buff_1G:	ds.b	8*64		* ラスター分割バッファＧ
		ds.b	8		* end_mark
div_buff_1H:	ds.b	8*64		* ラスター分割バッファＨ
		ds.b	8		* end_mark


*	[ + $2080 ＝ バッファNo.2 ]
div_buff_2A:	ds.b	8*64		* ラスター分割バッファＡ
		ds.b	8		* end_mark
div_buff_2B:	ds.b	8*64		* ラスター分割バッファＢ
		ds.b	8		* end_mark
div_buff_2C:	ds.b	8*64		* ラスター分割バッファＣ
		ds.b	8		* end_mark
div_buff_2D:	ds.b	8*64		* ラスター分割バッファＤ
		ds.b	8		* end_mark
div_buff_2E:	ds.b	8*64		* ラスター分割バッファＥ
		ds.b	8		* end_mark
div_buff_2F:	ds.b	8*64		* ラスター分割バッファＦ
		ds.b	8		* end_mark
div_buff_2G:	ds.b	8*64		* ラスター分割バッファＧ
		ds.b	8		* end_mark
div_buff_2H:	ds.b	8*64		* ラスター分割バッファＨ
		ds.b	8		* end_mark

*	[ + $30C0 ＝ 転送チェイン情報 ]
div_buff_chain:	ds.b	(8*64+8)*8*3


*----------------[ ＰＣＧ配置管理（逆参照）テーブル ]

*	PCG_No.→パターンNo. 変換テーブルです。

pcg_rev_alt:	ds.w	256		* 逆参照 alt　初期値(-1)を書き込むこと


*----------------[ ＯＸテーブル ]

*	各ＰＣＧが使用されているかどうかを表すテーブルです。

OX_tbl:
		ds.b	256		* 水位情報
		ds.w	1		* end_mark(0)を書き込むこと
OX_mask:
		ds.b	256		* マスク情報（0:off  255:on）


