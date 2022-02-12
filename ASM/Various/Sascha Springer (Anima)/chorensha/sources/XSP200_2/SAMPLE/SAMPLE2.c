/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

					　ＸＳＰシステム使用例　サンプルプログラム２

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/

#include	<stdio.h>
#include	<stdlib.h>
#include	<conio.h>
#include	<doslib.h>
#include	<iocslib.h>
#include	<graph.h>
#include	<math.h>
#include	"XSP2lib.H"
#include	"PCM8Afnc.H"

int		input2( char *mes , int def ) ;
void	ras_scroll() ;
void	ras_scroll_init() ;

#define		PCG_MAX		256			/* スプライトＰＣＧパターン最大使用数 */


/*□■□■□■□■□■□■□■　ＸＳＰシステム作業用領域　□■□■□■□■□■□■□■*/

char	pcg_alt[ PCG_MAX+1 ] ;		/* ＰＣＧ配置管理テーブル　　　　            　　 */
									/* スプライトＰＣＧパターン最大使用数＋１バイトの */
									/* サイズが必要です　　　　　　　                 */


/*■□■□■□■□■□■□■□■□■　ＰＣＧデータ　□■□■□■□■□■□■□■□■□*/

char	pcg_dat[ PCG_MAX*128 ] ;	/* ＰＣＧデータファイル読み込みバッファ */


/*■□■□■□■□■□■□■　複合スプライトの形状データ　□■□■□■□■□■□■□■*/

XOBJ_FRM_DAT	frm_dat[ 512 ] ;	/* フレームデータ */
XOBJ_REF_DAT	ref_dat[ 512 ] ;	/* リファレンスデータ */


/*■□■□■□■□■□　ユーザー側ラスター割り込みタイムチャート　□■□■□■□■□■*/

XSP_TIME_CHART	time_chart[512] ;


/*■□■□■□■□■□■□　ラスタースクロール用うねりデータ　□■□■□■□■□■□■*/

short	wave[ 256 ] ;		/* うねりデーター */
short	wave_ptr = 0 ;		/* うねりデーター読み出し位置のインデックス */
short	wave_ptr_00 = 0 ;	/* うねりデーター読み出し位置のインデックスの初期値 */


/*■□■□■□■□■□■□■□　キャラクター管理構造体　■□■□■□■□■□■□■□■*/

		/* ５１２個分のキャラクターを扱う構造体を用意します。*/

struct {
	short	x,y ;		/* 座標 */
	short	pt ;		/* スプライトパターンＮｏ．*/
	short	info ;		/* 反転コード・色・優先度を表わすデータ */
	short	vx,vy ;		/* 移動量 */
	int		dummy ;		/* 高速化のため構造体サイズを補正（深く考えないでね）*/
} SP[512] ;


/*■□■□■□■□■□■□■　スプライトのパレットデータ　□■□■□■□■□■□■□■*/

unsigned short	pal_dat[ 256 ] ;	/* パレットデータファイル読み込みバッファ */



/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

									ＭＡＩＮ

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/
void	main()
{
	int		i , j ;
	int		panel_max ;
	int		mode ;
	int		ras_int ;
	FILE	*fp ;


	mode		= input2("	ＸＳＰ＿ＭＯＤＥ " , 3) ;
	ras_int		= input2("	ラスタースクロール  [1]=ON : [2]=OFF " , 1) ;
	panel_max	= input2("	パネル枚数 " , 32) ;
	if( panel_max>512 ) panel_max = 512 ;


/*---------------------[ 画面を初期化 ]---------------------*/

	CRTMOD( 6 ) ;				/* 256*256dot 16色 グラフィックプレーン4枚 31kHz */
	G_CLR_ON() ;				/* グラフィック表示ＯＮ */
	SP_ON() ;					/* スプライト表示をＯＮ */
	BGCTRLST(0 , 0 , 0) ;		/* ＢＧ０表示ＯＦＦ */
	BGCTRLST(1 , 1 , 0) ;		/* ＢＧ１表示ＯＦＦ */
	GPALET( 1 , 0xFFFF ) ;		/* グラフィックパレット１番を真っ白にする */


/*-----------------[ ＰＣＧデータ読み込み ]-----------------*/

	fp = fopen( "PANEL.SP" , "rb" ) ;
	fread( pcg_dat
		,  128		/* 1PCG = 128byte */
		,  256		/* 256PCG */
		,  fp
		) ;
	fclose( fp ) ;


/*--------[ スプライトパレットデータ読み込みと定義 ]--------*/

	fp = fopen( "PANEL.PAL" , "rb" ) ;
	fread( pal_dat
		,  2		/* 1palet = 2byte */
		,  256		/* 16palet * 16block */
		,  fp
		) ;
	fclose( fp ) ;

	/* スプライトパレットに転送 */
	for( i=0 ; i<256 ; i++ )
	{
		SPALET( (i&15) | (1<<0x1F) , i/16 , pal_dat[i] ) ;
	}


/*----------[　複合スプライトの形状データを作成　]----------*/
	j = 0 ;

	for( i=0 ; i<16 ; i++ )
	{
		ref_dat[i].num	= 16 ;			/* 合成スプライト数 */
		ref_dat[i].ptr	= &frm_dat[j] ;	/* 参照するフレームデータへのポインター */

		frm_dat[j].vx	= -0x18 ;
		frm_dat[j].vy	= -0x18 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;


		frm_dat[j].vx	= -0x30 ;
		frm_dat[j].vy	=  0x10 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;


		frm_dat[j].vx	= -0x30 ;
		frm_dat[j].vy	=  0x10 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;


		frm_dat[j].vx	= -0x30 ;
		frm_dat[j].vy	=  0x10 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;

		frm_dat[j].vx	=  0x10 ;
		frm_dat[j].vy	=  0 ;
		frm_dat[j].pt	=  i ;
		frm_dat[j].rv	=  0 ;
		j++ ;
	}


/*----------------[ ＸＳＰシステムを初期化 ]----------------*/

	xsp_on() ;						/* ＸＳＰシステムを組み込む */

	xsp_mode( mode ) ;				/* 表示モード設定 */

	xsp_pcgdat_set( pcg_dat			/* ＰＣＧデータを指定 */
				  , pcg_alt			/* ＰＣＧ配置管理テーブルを指定 */
				  , sizeof(pcg_alt)	/* ＰＣＧ配置管理テーブルのサイズを指定 */
				  ) ;

	xsp_objdat_set( ref_dat ) ;		/* 複合スプライト形状データを指定 */

	pcm8a_vsyncint_on() ;			/* ＰＣＭ８Ａとの衝突を回避 */


/*-------------[ キャラクター５１２個分初期化 ]-------------*/

	for ( i=0 ; i<512 ; i++ )
	{
		SP[i].x		= ((rand()/16 & 255) + 8)*16 ;	/* Ｘ座標初期化 */
		SP[i].y		= ((rand()/16 & 255) + 8)*16 ;	/* Ｙ座標初期化 */
		SP[i].pt	= i & 7 ;						/* スプライトパターンNo.を初期化 */
		SP[i].info	= 0x138 + (i & 7)*0x101 ;		/* カラー１、優先度 0x38 〜 0x3F */
		SP[i].vx	= (rand()/16 & 31) - 16 ;		/* Ｘ方向移動量 */
		SP[i].vy	= (rand()/16 & 31) - 16 ;		/* Ｙ方向移動量 */
	}


/*-----[ ユーザー側ラスター割り込みタイムチャート作成 ]-----*/
	i=0 ;
	for ( j=0 ; j<256 ; j+=4 )
	{
		time_chart[i].ras_no	= j*2+32 ;
		time_chart[i].proc		= ras_scroll ;
		i++ ;
	}

	time_chart[i].ras_no	= -1 ;		/* エンドマーク */


/*--------[ ラスタースクロール用うねりデーター作成 ]--------*/
	for ( i=0 ; i<256 ; i++ )
	{
		wave[i] = sin( 3.1415926535898 * (double)i/128 ) * 64 ;
	}


/*-------------------[ 割り込み処理設定 ]-------------------*/
	if( ras_int==1 )
	{
		/* フォント表示 */
		symbol(0 , 0x10 , "ラスタースクロールも " , 1 , 4 , 2 , 1 , 0) ;
		symbol(0 , 0x90 , "　　　 ほら、この通り" , 1 , 4 , 2 , 1 , 0) ;

		xsp_vsyncint_on( ras_scroll_init ) ;	/* 帰線期間割り込み開始 */
		xsp_hsyncint_on( time_chart ) ;			/* ラスター割り込み開始 */
	}


/*============================[ キャラが跳ね回るデモ ]==============================*/

	while ( INPOUT(0xFF)==0 )
	{
		xsp_vsync( 1 ) ;

		/* 半分は単体スプライトで表示 */
		for ( i=0 ; i<panel_max/2 ; i++ )
		{
			SP[i].x += SP[i].vx ;
			SP[i].y += SP[i].vy ;
			xsp_set( SP[i].x>>4 , SP[i].y>>4 , SP[i].pt , SP[i].info ) ;
			if ( SP[i].x<=0 || 0x110*16<=SP[i].x ) SP[i].vx =- SP[i].vx ;
			if ( SP[i].y<=0 || 0x110*16<=SP[i].y ) SP[i].vy =- SP[i].vy ;
		}

		/* 半分は複合スプライトで表示 */
		for ( i=panel_max/2 ; i<panel_max ; i++ )
		{
			SP[i].x += SP[i].vx ;
			SP[i].y += SP[i].vy ;
			xobj_set( SP[i].x>>4 , SP[i].y>>4 , SP[i].pt , SP[i].info ) ;
			if ( SP[i].x<=0 || 0x110*16<=SP[i].x ) SP[i].vx =- SP[i].vx ;
			if ( SP[i].y<=0 || 0x110*16<=SP[i].y ) SP[i].vy =- SP[i].vy ;
		}

		xsp_out() ;				/*　スプライトを表示する　*/
	}



/*==================================================================================*/

	xsp_off() ;
	CRTMOD( 0x10 ) ;

}	/* end of func */




/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

	ｉｎｐｕｔ２（ "メッセージ" , デフォルト値 ）；

		機能：デフォルト値有りの input() 関数です。

		戻値：入力値

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/
int		input2( char *mes , int def )
{
	char	str[35] ;
	int		tmp ;

	printf( "%s[ 省略=%d ]=" , mes , def ) ;
	str[0] = 32;
	tmp = atoi( cgets( str ) ) ;
	printf( "¥n" ) ;
	if( tmp==0 ) tmp=def ;
	return( tmp ) ;
}




/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

	帰線期間割り込みサブルーチン

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/
void	ras_scroll_init()
{
	wave_ptr	= wave_ptr_00 ;
	wave_ptr_00	=(wave_ptr_00 + 1) & 255 ;
}


/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

	ラスター割り込みサブルーチン

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/
void	ras_scroll()
{
	*(short *)(0xE80018) = wave[ wave_ptr ] ;	/* グラフィックプレーン０ Ｘ座標 */
	wave_ptr = (wave_ptr + 1) & 255 ;
}




