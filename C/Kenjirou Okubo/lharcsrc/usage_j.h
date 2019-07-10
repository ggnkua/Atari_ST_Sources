/*************************************************
	LHarc version 1.13b (c) Yoshi 1988-89.
	usage & message module : 1989/ 5/14

HTAB = 4
*************************************************/

char title[] = "\nLHarc 1.13b (c)Yoshi, 1988-89.\n";

char use[] =
"LHarc  version 1.13b            Copyright(c) H.Yoshizaki（吉崎栄泰）, 1988-89.\n"
"============================================================= 1989 - 5 - 14 ===\n"
"                     <<< 高圧縮書庫管理プログラム >>>\n"
"===============================================================================\n"
"  使用法：LHarc [<命令>] [{/|-}{<スイッチ>[-|+|2|<オプション>]}...] <書庫名>\n"
"                  [<ドライブ名>:|<基準ディレクトリ名>\\] [<パス名> ...]\n"
"-------------------------------------------------------------------------------\n"
"  《命令》\n"
"     a: 書庫にファイルを追加          u: 書庫にファイルを追加（日時照合付）\n"
"     f: 書庫のファイルを更新          m: 書庫にファイルを移動（日時照合付）\n"
"     d: 書庫内のファイルの削除      e,x: 書庫からファイルを取り出す\n"
"     p: 書庫内のファイルの閲覧      l,v: 書庫の一覧表示\n"
"     s: 自己解凍書庫の作成            t: 書庫内のファイルの CRC チェック\n"
"  《スイッチ》\n"
"     r: 再帰的収集を行う              w: ワークディレクトリの指定\n"
"     x: ディレクトリ名を有効にする    m: 問い合わせを行わない\n"
"     p: 名前の比較を厳密に行う        c: 日時照合を行わない\n"
"     a: 全属性を凍結の対象とする      v: 他のユーティリティでファイルを閲覧\n"
"     n: 経過表示をしない              k: 自動実行のキーワードの設定\n"
"     t: 書庫の時刻を最新のファイルに\n"
"===============================================================================\n"
"  転載・再配布などは自由です。                           Nifty-Serve  PFF00253\n"
"  （詳しくは使用の手引をご覧ください。）                 ASCII-pcs    pcs02846";

char M_UNKNOWNERR[]	=	"内部エラーです．動作状況をご報告ください";
char M_INVCMDERR[]	=	"このような命令はありません";
char M_MANYPATERR[]	=	"コマンドラインのファイル名が多過ぎます";
char M_NOARCNMERR[]	=	"書庫ファイル名を指定してください";
char M_NOFNERR[]	=	"ファイル名を指定してください";
char M_NOARCERR[]	=	"書庫ファイルが見つかりません";
char M_RENAMEERR[]	=	"書庫ファイルの名前を変更できません";
char M_MKTMPERR[]	=	"作業ファイルを作成できません";
char M_DUPFNERR[]	=	"異なるパスに同名のファイルがあります";
char M_TOOMANYERR[]	=	"パス名の指定が多過ぎます";
char M_TOOLONGERR[]	=	"パス名が長過ぎます";
char M_NOFILEERR[]	=	"ファイルが見つかりません";
char M_MKFILEERR[]	=	"ファイルを作成できません";
char M_RDERR[]		=	"ファイルが読めません";
char M_WTERR[]		=	"ファイルが書けません";
char M_MEMOVRERR[]	=	"メモリ不足です";
char M_INVSWERR[]	=	"無効なスイッチが指定されています";
char M_CTRLBRK[]	=	"強制終了します";
char M_NOMATCHERR[]	=	"一致するファイルがありません";
char M_COPYERR[]	=	"作業ファイルのコピーに失敗しました";
char M_NOTLZH[]		=	"書庫 '%s' の拡張子が '.LZH' と異なりますが、"
						"作業を続けますか [Y/N] ";
char M_OVERWT[]		=	"書き換えてもいいですか [Y/N] ";
char M_MKDIR[]		=	"ディレクトリを作成してもいいですか [Y/N] ";
char M_MKDIRERR[]	=	"ディレクトリを作成できません";
char M_CRCERR[]		=	"CRC Err\n";
char M_RDONLY[]		=	"書き込み禁止です";

char *errmes[] = {
	M_UNKNOWNERR, M_INVCMDERR, M_MANYPATERR, M_NOARCNMERR,
	M_NOFNERR, M_NOARCERR, M_RENAMEERR, M_MKTMPERR,
	M_DUPFNERR, M_TOOMANYERR, M_TOOLONGERR, M_NOFILEERR,
	M_MKFILEERR, M_RDERR, M_WTERR, M_MEMOVRERR, M_INVSWERR,
	M_CTRLBRK, M_NOMATCHERR, M_COPYERR,
	M_NOTLZH, M_OVERWT, M_MKDIR, M_MKDIRERR, M_CRCERR,
	M_RDONLY
};
