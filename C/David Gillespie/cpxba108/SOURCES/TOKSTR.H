#ifndef TOK_STR_IN
#define TOK_STR_IN

enum{
      toklp, tokrp, toklps, tokrps
    , tokeq, toklt, tokgt, tokle, tokge, tokne
    , tokcomma, toksemi, tokcolon
	, tokprints, tokinputs

	, REAL_TOKS
    , tokplus=REAL_TOKS, tokminus, toktimes, tokdiv, tokup

	, TOK_ALPHA
    , toksqu=TOK_ALPHA, toksqr, toksqrt
    , toksin, tokcos, toktan, tokasin,tokacos, tokatan, tokarctan
    , toksinh, tokcosh, toktanh, tokasinh,tokacosh,tokatanh
    , toklog, tokln, tokld, toklg, tokexp, tokten, tokpow2
    , tokabs, toksgn, tokstr_, tokrcp, tokint
    , tokdms_
    , tokfahren, tokcelsius, tokceil, tokfloor
    , END_REAL

    , INT_TOKS=END_REAL
    ,  toklabel=INT_TOKS, toknot, tokfact
    , tokhex_,tokoct_,tokbin_, tokchr_
    , tokpeekl, tokpeekw, tokpeek, tokpokel, tokpokew, tokpoke
	, tokplot, tokline, tokcircle, tokellipse
	, END_INT

	, STRING_TOKS=END_INT
    , tokval=STRING_TOKS, tokasc, toklen, tokdeg, tokfsel_
	, tokinbyte, tokoutbyte
	, END_STRING

	, ARG_TOKS=END_STRING
    , tokrem=ARG_TOKS, toklet, tokprint, tokinput
    , tokif, tokend, tokstop, tokcont, tokfor, toknext
    , tokwhile, tokwend
    , tokgosub, tokreturn, tokread, tokdata, tokrestore
    , tokgotoxy, tokon, tokdim
    , toklist, tokrun, toknew, tokload, tokmerge
    , toksave, tokbye, tokdel, tokrenum
    , tokfopen, tokfclose, tokfinput, tokfprint,tokerrno
	, END_ARG

    , OTHER_TOKS=END_ARG
    , tokdegree=OTHER_TOKS,tokgrad,tokrad,tokcls, tokclear
    , tokusing_,tokusing
    , tokrand, tokpi
    , tokinkey_, tokmid_
    , tokand, tokor, tokxor, tokmod
    , tokthen, tokelse, tokto, tokstep, tokgoto
	, toktron, toktroff
    , NUM_TOKS
};

enum{tokvar=NUM_TOKS, tokbin, tokoct, tokdec, tokhex, tokstr, toksnerr};

#ifndef TOK_STR
extern char *tok_strings[];
#endif

#endif
