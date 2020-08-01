*
* Definition of Headers
*
.DATA
*.INCLUDE HEADER.M

last_forth:     DC.L (lastword-datas)
* in former times, there was a further pointer
* back to the runtime code of a vocabulary
* into the code segment 


HEADER first, 		''      * 			$0
HEADER forth_wordlist,'FORTH-WORDLIST'      *$0308
HEADER lcaccept, 	'accept'      * 	$0
HEADER lctype,		'type'      * 		$0
HEADER bye, 		'BYE'      * 			$0
HEADER b_cold, 		'(cold)'      * 		$0
HEADER systop, 		'systop'      * 		$0208
HEADER sysbot, 		'sysbot'      * 		$0208
HEADER datatop, 	'datatop'      * 		$0208
HEADER databot, 	'databot'      * 		$0208
HEADER forthparas, 	'forthparas'      * 	$0
HEADER b_front_opt, '(front_opt)'      * 	$0
HEADER b_end_opt, 	'(end_opt)'      * 	$0
HEADER noop, 		'NOOP'      * 		$0
HEADER ver, 		'ver'      * 			$0
HEADER codeheadsize, 'codeheadsize'
HEADER blankbits,	'blankbits'
HEADER nextuser, 	'nextuser'      * 	$0408
HEADER r_null, 		'r0'      * 			$0408
HEADER s_null, 		's0'      * 			$0408
HEADER f_null, 		'f0'      * 			$0408
HEADER state, 		'STATE'      * 		$0408
HEADER b_number_quest,'(number?)'      *	$0408
HEADER base, 		'BASE'      * 		$0408
HEADER cp,			'cp'      *			$0408
HEADER dp,			'dp'      *			$0408
HEADER totib,		'>TIB'      *			$0408
HEADER _tib,		'#TIB'      *			$0408
HEADER toin,		'>IN'      *			$0408
HEADER toevaluateib,'>evaluate-ib'
HEADER _evaluateib,	'#evaluate-ib'
HEADER tofileib,	'>file-ib'
HEADER _fileib,		'#file-ib'
HEADER p_blocksource,'(block-source)'
HEADER tosourceid,	'>source-id'
HEADER current,		'current'      *		$0408
HEADER vocpa,		'vocpa'      *		$0408
HEADER last,		'last'      *			$0408
HEADER abortqmess,	'abort"msg'
HEADER abortqcnt,	'abort"cnt'
HEADER errorqmess,	'error"msg'
HEADER p_errorhandler, '(errorhandler)'
HEADER b_key,		'(key)'      *		$0408
HEADER b_emit,		'(emit)'      *		$0408
HEADER b_key_quest,	'(key?)'      *		$0408
HEADER t_key,		'^key'      *			$0408
HEADER t_emit,		'^emit'      *		$0408
HEADER t_key_quest,	'^key?'      *		$0408
HEADER t_emit_quest, '^emit?'      *		$0408
HEADER b_accept,	'(accept)'      *		$0408
HEADER b_type,		'(type)'      *		$0408
HEADER p_find,		'(find)'      *		$0408
HEADER p_parser,	'(parser)'      *		$0408
HEADER b_fliteral,	'(fliteral)'      *	$0408
HEADER macro,		'macro'      *		$0408
HEADER is_macro,	'is_macro'      *		$0408
HEADER warning,		'warning'      *		$0408
HEADER out,			'out'      *			$0408
HEADER fwidth,		'fwidth'      *		$0408
HEADER blk,			'BLK'      *			$0408
HEADER userbufs,	'userbufs'      *		$0408
HEADER echo,		'echo'      *			$0408
HEADER udp,			'udp'      *			$0408
HEADER pad,			'PAD'      *			$0
HEADER here,		'HERE'      *			$0
HEADER number_quest,'number?'      *		$0
HEADER loaderkey,	'loaderkey'      *	$0
HEADER loaderemit,	'loaderemit'      *	$0
HEADER loaderkey_quest,'loaderkey?'      *$0
HEADER key,			'KEY'      *			$0
HEADER emit,		'EMIT'      *			$0
HEADER key_quest,	'KEY?'      *			$0
HEADER accept,		'ACCEPT'
HEADER type,		'TYPE'      *			$0
HEADER komma,		','      *			$0
HEADER jsr_komma,	'jsr,'      *			$0
HEADER com_komma,	'COMPILE,'      *			$0
HEADER code_komma,	'code,'      *		$0
HEADER code_wkomma,	'codew,'      *		$0
HEADER jsrSB_komma,	'jsrsb,'      *		$0
HEADER wkomma,		'w,'      *			$0
HEADER ckomma,		'C,'      *			$0
HEADER fkomma,		'F,'      *			$0
HEADER plus_store,	'+!'      *			$0
HEADER plus,		'+'      *			$0208
HEADER m_plus,		'M+'
HEADER minus,		'-'      *			$0208
HEADER mult,		'*'      *			$0
HEADER um_mult,		'UM*'
HEADER m_mult,		'M*'
HEADER um_divmod,	'UM/MOD'
HEADER fm_divmod,	'FM/MOD'
HEADER sm_divrem,	'SM/REM'
HEADER udivmod,		'U/MOD'      *		$0
HEADER and,			'AND'      *			$0208
HEADER or,			'OR'      *			$0208
HEADER exor,		'XOR'      *			$0208
HEADER invert,		'INVERT'      *			$0108
HEADER negate,		'NEGATE'      *		$0108
HEADER dnegate,		'DNEGATE'      *		$0108
HEADER abs,			'ABS'      *			$0408
HEADER lshift,		'LSHIFT'
HEADER rshift,		'RSHIFT'
HEADER allot,		'ALLOT'      *		$0
HEADER exit,		'EXIT'      *			$06
HEADER execute,		'EXECUTE'      *		$0
HEADER sp_fetch,	'sp@'      *			$0
HEADER sp_store,	'sp!'      *			$0
HEADER rp_fetch,	'rp@'
HEADER rp_store,	'rp!'
HEADER to_r,		'>R'      *			$04
HEADER r_from,		'R>'      *			$04
HEADER r_fetch,		'R@'      *			$04
HEADER b_abs,		'(abs)'
HEADER toabs,		'>abs'
HEADER code2data,	'code>data'
HEADER data2code,	'data>code'
HEADER cr,			'CR'      *			$0
HEADER space,		'SPACE'      *		$0
HEADER literal,		'LITERAL'      *		$02
HEADER twoliteral,	'2LITERAL'
HEADER fliteral,	'FLITERAL'      *		$0		; ?? not immediate ??
HEADER count,		'COUNT'      *		$0
HEADER b_str_quote,	'(s")'      *			$04
HEADER b_string_emit,'(.")'      *		$04
HEADER catch,		'CATCH'
HEADER throw,		'THROW'
HEADER b_error_quote,'(error"'      *		$04
HEADER b_abort_quote,'(abort"'      *		$04
HEADER sourceid,	'SOURCE-ID'	
HEADER tib,			'TIB'      *			$0
HEADER query,		'QUERY'      *		$0
HEADER skip,		'skip'      *			$0
HEADER scan,		'scan'      *			$0
HEADER source,		'SOURCE'      *		$0
HEADER parse,		'PARSE'
HEADER word,		'WORD'      *			$0

whitespace:		DC.L $00060000, $01000000, 0, 0, 0, 0, 0, 0, 0
* delimiters are:
*		TAB
*		NL
*		BL


HEADER name,		'name'      *			$0
HEADER char,		'CHAR'      *			$0
HEADER b_char,		'[CHAR]'      *		$02
HEADER vocsearch,	'vocsearch'      *	$0
HEADER lcfind,		'find'      *		$0
HEADER find,		'FIND'      *			$0
HEADER nulst_quest,	'nullstr?'      *		$0
HEADER notfound,	'notfound'      *		$0
HEADER tick,		"'",			$0
HEADER b_tick,		"[']",			$02
HEADER quest_stack,	'?stack'      *		$0
HEADER compiler,	'compiler'      *		$0
HEADER interpreter,	'interpreter'      *	$0
HEADER parser,		'parser'      *		$0
HEADER interpret,	'interpret'      *	$0
HEADER prompt,		'prompt'      *		$0
HEADER left_brack,	'['      *			$02
HEADER right_brack,	']'      *			$0
HEADER align,		'ALIGN'      *		$0
HEADER quit,		'QUIT'      *			$0
HEADER errorhandler,'errorhandler'
HEADER cold,		'cold'      *			$0
HEADER digit_quest,	'digit?'      *		$0
HEADER to_number,	'>NUMBER'
HEADER n_number_quest,'nnumber?'      *	$0
HEADER fetch,		'@'      *			$0308
HEADER cfetch,		'C@'      *			$0508
HEADER wfetch,		'w@'      *			$0508
HEADER store,		'!'      *			$0308
HEADER cstore,		'C!'      *			$0408
HEADER wstore,		'w!'      *			$0408
HEADER header,		'header'
HEADER header_colon,'header:'      *		$0
HEADER colon,		':'      *			$0
HEADER m_colon,		'm:'      *			$0
HEADER reveal,		'reveal'      *		$0
HEADER semi_colon,	';'      *			$02
HEADER dup,			'DUP'      *			$0108
HEADER drop,		'DROP'      *			$0108
HEADER swap,		'SWAP'      *			$0408
HEADER rot,			'ROT'      *			$0608
HEADER tuck,		'TUCK'
HEADER quest_dup,	'?DUP'      *			$0
HEADER over,		'OVER'      *			$0208
HEADER nip,			'NIP'
HEADER _2drop,		'2DROP'      *		$0108
HEADER _2dup,		'2DUP'      *			$0208
HEADER _2over,		'2OVER'      *		$0
HEADER _2swap,		'2SWAP'      *		$0
HEADER cmove,		'CMOVE'      *		$0
HEADER cmove_up,	'CMOVE>'      *		$0
HEADER create,		'CREATE'      *		$0
HEADER does,		'DOES>'      *		$06
HEADER semcl_code,	';code)'      *		$0
HEADER variable,	'VARIABLE'      *		$0
HEADER constant,	'CONSTANT'      *		$0
HEADER bl,			'BL'      *			$0308
HEADER to,			'TO'      *			$02
HEADER value,		'VALUE'      *		$0

* variables used by LOCAL
was_local:      DC.L 0
save_cur:       DC.L 0
save_dp:        DC.L 0
HEADER b_local,		'(LOCAL)'
HEADER b_do,		'(do'      *			$04
HEADER b_quest_do,	'(?do'      *			$04
HEADER b_loop,		'(loop'      *		$04
HEADER b_plus_loop,	'(+loop'      *		$04
HEADER i,			'I'      *			$020C
HEADER j,			'J'      *			$04
HEADER unloop,		'UNLOOP'      *		$04
HEADER leave,		'LEAVE'      *		$04
HEADER quest_branch,'?branch'      *		$06
HEADER branch,		'branch'      *		$06
HEADER null_gleich,	'0='      *			$0
HEADER null_less,	'0<'      *			$0
HEADER gleich,		'='      *			$0
HEADER uless,		'U<'      *			$0
HEADER less,		'<'      *			$0
HEADER greater,		'>'      *			$0
HEADER min,			'MIN'      *			$0
HEADER max,			'MAX'      *			$0
HEADER string_komma,',"'      *			$0
HEADER string_emit,	'."'      *			$06
HEADER dot_brack,	'.('      *			$02
HEADER comment_brack,'('      *			$02
HEADER error_quote,	'error"'      *		$06
HEADER abort,		'ABORT'      *		$0
HEADER abort_quote,	'ABORT"'      *		$06
HEADER quote,		'S"'      *			$02
HEADER postpone,	'POSTPONE'      *		$06
HEADER immediate,	'IMMEDIATE'      *	$0
HEADER restrict,	'restrict'      *		$0
HEADER fill,		'FILL'      *			$0
HEADER erase,		'ERASE'      *		$0
HEADER one_plus,	'1+'      *			$0108
HEADER one_minus,	'1-'      *			$0108
HEADER two_mult,	'2*'      *			$0308
HEADER two_div,		'2/'      *			$0308
HEADER cell_plus,	'CELL+'      *		$0108
HEADER cells,		'CELLS'      *		$0308
HEADER char_plus,	'CHAR+'      *		$0108
lasthead:
HEADER chars,		'CHARS'      *		$0008

lastword 	EQU		__chars

*****************************************************************
dataHERE:
  


*HEADER ,		''      *		$0



