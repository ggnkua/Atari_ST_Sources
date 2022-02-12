/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

					　ＸＳＰシステム使用例　サンプルプログラム３

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<doslib.h>
#include	<iocslib.h>
#include	"XSP2lib.H"

FILE	*chk_open( char *fname , char *mode ) ;

#define		PCG_MAX		2048		/* スプライトＰＣＧパターン最大使用数 */
#define		REF_MAX		4096		/* 複合スプライトリファレンスデータ最大使用数 */
#define		FRM_MAX		16384		/* 複合スプライトフレームデータ最大使用数 */


/*□■□■□■□■□■□■□■　ＸＳＰシステム作業用領域　□■□■□■□■□■□■□■*/

char	pcg_alt[ PCG_MAX+1 ] ;		/* ＰＣＧ配置管理テーブル　　　　            　　 */
									/* スプライトＰＣＧパターン最大使用数＋１バイトの */
									/* サイズが必要です　　　　　　　                 */


/*■□■□■□■□■□■□■□■□■　ＰＣＧデータ　□■□■□■□■□■□■□■□■□*/

char	pcg_dat[ PCG_MAX*128 ] ;	/* ＰＣＧデータファイル読み込みバッファ */


/*■□■□■□■□■□■□■　複合スプライトの形状データ　□■□■□■□■□■□■□■*/

XOBJ_FRM_DAT	frm_dat[ FRM_MAX ] ;	/* フレームデータ */
XOBJ_REF_DAT	ref_dat[ REF_MAX ] ;	/* リファレンスデータ */



/*
□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□

									ＭＡＩＮ

□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□
*/
void	main( int argc , unsigned char* argv[] )
{
	int		i ;
	int		sizeof_ref ;	/* 複合スプライトリファレンスデータ読み込み数 */
	FILE	*fp ;

	struct {
		short	x,y ;		/* 座標 */
		short	pt ;		/* スプライトパターンＮｏ．*/
		short	info ;		/* 反転コード・色・優先度を表わすデータ */
	} MYCHARA ;


/*----------[ コマンドライン解析〜ファイル読み込み ]----------*/

	if( argc<=1 )
	{
		/* ヘルプを表示して終了 */
		printf("使用法：SAMPLE3 [形状データファイル名（拡張子省略）]¥n") ;
		exit( 0 ) ;
	} else {
		char	str_tmp[ 256 ] ;

		/* ファイル読み込み */
		strmfe( str_tmp , argv[1] , "xsp" ) ;		/* 拡張子置換 */
		fp = chk_open( str_tmp , "rb" ) ;
		fread( pcg_dat , sizeof(char) , 128*PCG_MAX , fp ) ;

		strmfe( str_tmp , argv[1] , "frm" ) ;		/* 拡張子置換 */
		fp = chk_open( str_tmp , "rb" ) ;
		fread( frm_dat , sizeof(XOBJ_FRM_DAT) , FRM_MAX , fp ) ;

		strmfe( str_tmp , argv[1] , "ref" ) ;		/* 拡張子置換 */
		fp = chk_open( str_tmp , "rb" ) ;
		sizeof_ref = fread( ref_dat , sizeof(XOBJ_REF_DAT) , REF_MAX , fp ) ;

		fcloseall() ;

		/* REF_DAT[].ptr 補正 */
		for( i=0 ; i<sizeof_ref ; i++ )
		{
			(int)ref_dat[i].ptr += (int)(&frm_dat[0]) ;
		}
	}


/*---------------------[ 画面を初期化 ]---------------------*/

	CRTMOD( 6 ) ;				/* 256*256dot 31kHz */
	SP_ON() ;					/* スプライト表示をＯＮ */
	BGCTRLST(0 , 0 , 0) ;		/* ＢＧ０表示ＯＦＦ */
	BGCTRLST(1 , 1 , 0) ;		/* ＢＧ１表示ＯＦＦ */


/*----------------[ ＸＳＰシステムを初期化 ]----------------*/

	xsp_on() ;						/* ＸＳＰシステムを組み込む */

	xsp_pcgdat_set( pcg_dat			/* ＰＣＧデータを指定 */
				  , pcg_alt			/* ＰＣＧ配置管理テーブルを指定 */
				  , sizeof(pcg_alt)	/* ＰＣＧ配置管理テーブルのサイズを指定 */
				  ) ;

	xsp_objdat_set( ref_dat ) ;		/* 複合スプライト形状データを指定 */


/*==========================[ スティックで操作するデモ ]============================*/

	/* 初期化 */
	MYCHARA.x		= 0x88 ;	/* Ｘ座標初期値 */
	MYCHARA.y		= 0x88 ;	/* Ｙ座標初期値 */
	MYCHARA.pt		= 0 ;		/* スプライトパターンＮｏ．*/
	MYCHARA.info	= 0x013F ;	/* 反転コード・色・優先度を表わすデータ */


	/* 何かキーを押すまでループ */
	while ( INPOUT(0xFF)==0 )
	{
		static int	pre_stk = 0 ;
		static int	stk = 0 ;
		static int	timer = 0 ;

		xsp_vsync( 1 ) ;

		/* スティックの入力に合せて移動 */
		pre_stk = stk ;		/* 前回のスティックの内容 */
		stk = JOYGET(0) ;	/* 今回のスティックの内容 */
		if( (stk & 0b0001)==0 ) MYCHARA.y-=1 ;		/* 上に移動 */
		if( (stk & 0b0010)==0 ) MYCHARA.y+=1 ;		/* 下に移動 */
		if( (stk & 0b0100)==0 ) MYCHARA.x-=1 ;		/* 左に移動 */
		if( (stk & 0b1000)==0 ) MYCHARA.x+=1 ;		/* 右に移動 */

		/* トリガー押しっぱなし期間測定 */
		if( (stk & 0b1100000)==(pre_stk & 0b1100000) )
		{
			timer++ ;		/* タイマー加算 */
		} else {
			timer = 0 ;		/* タイマークリア */
		}

		/* トリガー２が押されたらパターン変更 */
		if( (stk & 0b0100000)==0  &&  ((pre_stk & 0b0100000)  ||  timer > 32) )
		{
			MYCHARA.pt++ ;
			if( MYCHARA.pt >= sizeof_ref ) MYCHARA.pt=0 ;
		}

		/* トリガー１が押されたら色変更 */
		if( (stk & 0b1000000)==0  &&  ((pre_stk & 0b1000000)  ||  timer > 32) )
		{
			if( (MYCHARA.info & 0x0F00)==0x0F00 )
			{
				MYCHARA.info &= 0xF0FF ;	/* カラーコードを０に戻す */
			} else {
				MYCHARA.info += 0x100 ;		/* カラーコードを１加算 */
			}
		}

		/* pt info を画面に表示 */
		B_LOCATE( 0 , 0 ) ;
		printf( "  pt = %3X ¥n" , MYCHARA.pt ) ;
		printf( "info = %3X ¥n" , MYCHARA.info ) ;

		/* スプライト登録 */
		xobj_set( MYCHARA.x , MYCHARA.y , MYCHARA.pt , MYCHARA.info ) ;
		/*
			↑ここは、
			xobj_set_st( &MYCHARA ) ;
			と記述すれば、より高速に処理できます。
		*/

		/*　スプライトを表示する　*/
		xsp_out() ;
	}



/*==================================================================================*/

	xsp_off() ;
	CRTMOD( 0x10 ) ;

}	/* end of func */




/*
■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■

	ｃｈｋ＿ｏｐｅｎ（ "ファイル名" , "モード" ) ;

		機能：ファイル名エラー検出機能付きの fopen() 関数です。

		戻値：fopen() 関数と同じ。

■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■□■
*/
FILE	*chk_open( char *fname , char *mode )
{
	FILE	*fp ;

	fp = fopen( fname , mode ) ;
	if( fp == (FILE*)0 ){
		fcloseall() ;
		printf( "¥n" ) ;
		printf( "	%s が、ＯＰＥＮできませんでした。¥n" , fname ) ;
		printf( "	強制終了します。¥n¥n" ) ;
		printf( "	（何かキーを押して下さい。）¥n" ) ;
		while( INPOUT( 0xFF )==0 ){}
		exit( 0 ) ;
	}

	return( fp ) ;

}




