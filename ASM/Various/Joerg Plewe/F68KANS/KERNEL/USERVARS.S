.DATA
.EVEN

*****************************************************************
*       USER variables                                          *
*****************************************************************
DS.L (16+24+10) ;room to save registers in multitasking

usertable:
USERVAR nextuser, 	(usertable-datas) ;points to usertable of next task
USERVAR	rnull,		0          ;r0 -- returnstackbase
USERVAR snull,		0          ;s0 -- datastackbase
USERVAR fnull,		0          ;f0 -- floatstackbase
USERVAR state,		0          ;compiler on/off
USERVAR number_quest,(n_number_quest-sys-of) ;numberconversion
USERVAR base,		10         ;base
USERVAR dp,			(HERE-sys-of) ;dictionary pointer (code)
USERVAR data,		(dataHERE-datas) ;dictionary pointer (data)

USERVAR totib, 		0          ;>tib, maybe as s0
USERVAR _tib,		0          ;number of characters in tib
USERVAR toin,		0          ;>in
USERVAR toevaluateib, 0
USERVAR _evaluateib, 0
USERVAR tofileib,	0
USERVAR	_fileib,	0
USERVAR p_blocksource, (noop-sys-of)
USERVAR tosourceid,	0

USERVAR current,	(last_forth-datas) ;current (pfa)
USERVAR vocpa, 		(VOCPA-datas) ;points to vocabularystack
USERVAR last,		(lasthead-datas) ;address of last header
USERVAR	catchhandler,	0				; handler for CATCH/THROW
USERVAR	abortqmess,	0					; message pointer for ABORT"
USERVAR abortqcnt,	0					; count for the message
USERVAR	errorqmess,	0
USERVAR	p_errorhandler, (errorhandler-sys-of)
USERVAR key,		(loaderkey-sys-of)
USERVAR emit,		(loaderemit-sys-of)
USERVAR key_quest,	(loaderkey_quest-sys-of)
USERVAR lkey,		0
USERVAR lemit,		0
USERVAR lkey_quest,	0
USERVAR lemit_quest, 0
USERVAR accept,		(lcaccept-sys-of)
USERVAR type,		(lctype-sys-of)
USERVAR find,		(lcfind-sys-of)
USERVAR parser,		(interpreter-sys-of)
USERVAR macro,		-1         ;should macros be used?
USERVAR is_macro,	0          ;shall the new word be a macro?
USERVAR warning,	0          ;give out warnings?
USERVAR out,		0          ;counts characters emitted
USERVAR fwidth,		8          ;bytes per float
USERVAR fliteral,	(noop-sys-of) ;(flit-sys-of) ;routine for floatcompilation
USERVAR blk,		0          ;number of actual block
USERVAR userbufs,	(VOCPA-datas-8) ;pointer to list of buffers
USERVAR echo,		-1         ;echo characters during input with expect?
USERVAR udp,		oudp+4

                DS.B ($0800-oudp+4) ;room for the rest
                EVEN


