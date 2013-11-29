/* import.c  1994 may 19  [gh]
+-----------------------------------------------------------------------------
| Abstract:
|    Functions to parse MIME headers and decode MIME messages.
|
| History:
|    2.2 94 nov  1 [gh] Added Content-Type: Application/octet-stream
|    2.1 94 jun 14 [gh] Made lint happier
|    2.0 94 may 19 [gh] Release of version 2.0
|    1.1 94 feb 01 [gh] Improved documentation and MIME support.
|    1.0 94 jan 03 [gh] Wrote first version.
|
| Design:
|    * Assumes tolower(3) works for all characters per ANSI spec.
|
| Authorship:
|    Copyright (c) 1994 Gisle Hannemyr.
|    Permission is granted to hack, make and distribute copies of this program
|    as long as this copyright notice is not removed.
|    Flames, bug reports, comments and improvements to:
|       snail: Gisle Hannemyr, Hegermannsgt. 13-3, 0478 Oslo, Norway
|       email: Inet: gisle@oslonett.no
+---------------------------------------------------------------------------*/

/* #include "config.h" */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "mimelite.h"

/*---( globals )------------------------------------------------------------*/

static int BPos;	/* Postition in BASE64 o/p buffer.		    */
static unsigned char BBuf[4];

static int   InHeadP;	/* T if state is parsing header.	*/
static int   DecodeP;	/* T if decoding			*/
static int   FoldChP;	/* T if folding character sets		*/
static int   EndP;	/* T if state is end of BASE64.		*/
static int   ActMask;	/* Mask of what services to activate	*/
static int   TempEncd;	/* Temporary encoding state.		*/
static FILE *AttFile;	/* Output file for named attachements.	*/

/*---( import )-------------------------------------------------------------*/

static int parsecharset(unsigned char *token)
{
    if (!strncmp(token, "us-ascii",     8)) return(CS_ASCII);
    if (!strncmp(token, "iso-8859-1",  10)) return(CS_ISOL1);
    if (!strncmp(token, "ns_4551-1",    9)) return(CS_IR060);
    return(CS_UNKWN);
} /* parsecharset */


/*
| Abs: Copy a token into a buffer.
| Des: Don't bother about delimiters, etc.  It is up to whoever uses the token
|      to make sense of the syntax.
| Par: dd  = buffer to copy token into
|      ss  = token  to copy
|      max = max size of buffer (or zero if are to malloc)
*/
static unsigned char *copytoken(unsigned char *dd, unsigned char *ss, int max)
{
    unsigned char *oo;
    int ii;

    if (!max) {
        max = strlen(ss) + 1;
	dd  = (unsigned char *)malloc(max);
    } /* if (no buffer) */

    ii =  0;
    oo = dd;
    while ((*ss) && (!isspace(*ss)) && (*ss != ';') && (++ii <= max)) {
        *dd++ = *ss++;
    } /* while */
    *dd = '\0';
    oo[max-1] = '\0';
    return(oo);
} /* copytoken */


/*
| Abs: Flush base64 encoded buffer.
| Ret: Pointer to decoded buffer.
*/
static unsigned char *decodebase64(void)
{
    static unsigned char outbuf[3];

    outbuf[0] =  (BBuf[0]         << 2) | ((BBuf[1] & 0x30) >> 4);
    outbuf[1] = ((BBuf[1] & 0x0F) << 4) | ((BBuf[2] & 0x3C) >> 2);
    outbuf[2] = ((BBuf[2] & 0x03) << 6) |  (BBuf[3] & 0x3F);
    BPos = 0;
    return(outbuf);
} /* decodebase64 */



/*
| Abs: Decode header line with BASE64 or QUOTED-PRINTABLE codes.
| Par: dest     = destination
|      src      = where to start decoding from
|      endbuf   = where to stop decoding (or NULL if end of buffer).
|      encoding = content-transfer-encoding
| Ret: Pointer to new destination.
*/
static unsigned char *decodehed(unsigned char *dest, unsigned char *src,
	unsigned char *endbuf, int encoding)
{
    int cc, show;
    unsigned char *ss;

    if (encoding == CE_UNCODED) return(endbuf);

    /* else */

    if (encoding == CE_QUOTEDP) {
	while (*src && (src != endbuf)) {
	    if (*src == '=') {
		src++; if (!*src) break;
		if (('\n' == *src) || ('\r' == *src)) break;
		cc  = isdigit(*src) ? (*src - '0') : (*src - 55);
		cc *= 0x10;
		src++; if (!*src) break;
		cc += isdigit(*src) ? (*src - '0') : (*src - 55);
		*dest = cc;
	    } else if (*src == '_') {
		*dest = '\040';
	    } else *dest = *src;
	    dest++; src++;
	} /* while */
	*dest = '\0';
	return(dest);
    } /* if (quoted printable) */

    /* else */

    if (encoding == CE_BASE064) {
        if (EndP) {
	    return(dest);
        } /* if */
        BPos = 0;
	while (*src && (src != endbuf)) {
	    cc = *src++;
	    if	    ((cc >= 'A') && (cc <= 'Z')) cc = cc - 'A';
	    else if ((cc >= 'a') && (cc <= 'z')) cc = cc - 'a' + 26;
	    else if ((cc >= '0') && (cc <= '9')) cc = cc - '0' + 52;
	    else if  (cc == '/')		 cc = 63;
	    else if  (cc == '+')		 cc = 62;
	    else if  (cc == '=') { EndP = 1;	 cc = -1; }
	    else if  (cc == '-') break;			/* end    */
	    else cc = -1;				/* ignore */

	    if (cc >= 0) {
		BBuf[BPos++] = cc;
		if (BPos == 4) {
		    ss = decodebase64();
		    for (cc = 0; cc < 3; cc++) *dest++ = ss[cc];
		} /* if (got buffer) */
	    } /* if (significant) */
	} /* while */

        show = BPos;
        if (show) show--;
        ss = decodebase64();
        for (cc = 0; cc < show; cc++) *dest++ = ss[cc];

	*dest = '\0';
	return(dest);
    } /* if (base64) */

    return(endbuf);

} /* decodehed */


/*
| Abs: Remove MIME codes in heading fields.
| Cby: ml_unmimeline
| Des: RFC 1522
*/
static void decodhead(unsigned char *buf)
{
    int encoding;
    /* int charset; */
    unsigned char cc;
    unsigned char *ss, *dd, *zz;

    if (!buf) return;

    dd = ss = buf;
    /* printf("[%s", buf); ** DB */
    while (*ss) {
	if ((ss[0] == '=') && (ss[1] == '?')) {
	    if (ss[3] == '\0') {
	        dd[0] = '=';
	        dd[1] = '?';
	        dd[2] = '\0';
	        break;
	    } /* if (bogus) give up */

	    ss += 2; /* position source at first char. after lead in	    */
	    /* charset = parsecharset(ss); * UNUSED coz assuming ISO works  */
	    ss = (unsigned char *)strchr(ss, '?'); /* ss at encoding '?'    */
	    if (!ss) break;			   /* if (bogus) give up    */
	    ss++;				   /* ss at cte char	    */
	    if (!*ss) break;			   /* if (no cte) give up   */
	    cc = tolower(*ss);
	    if      (cc == 'b') encoding = CE_BASE064;
	    else if (cc == 'q') encoding = CE_QUOTEDP;
	    else		encoding = CE_NOTIMPL;
	    ss = (unsigned char *)strchr(ss, '?'); /* ss at body '?'	    */
	    if (!ss) break;			   /* if (bogus) give up    */
	    ss++;				   /* ss at first body char */
	    if (!*ss) break;			   /* if (no body) give up  */
	    zz = (unsigned char *)strchr(ss, '?'); /* where to stop scan    */
	    if (!zz) return;			   /* if (bogus) give up    */
	    dd = decodehed(dd,ss,zz,encoding);	   /* dd is new dest	    */
	    zz++;				   /* zz is at final '='    */
	    if (*zz != '=') break;		   /* if (bogus) give up    */
	    ss = zz;				   /* ss is at final '='    */
	    /* printf("\ndd:[%s]<-ss:[%s]\n", dd, ss);  ** DB */
	} else {
	    *dd++ = *ss;
	}  /* if (encoded) decode; else copy; */
	ss++;					   /* advance to next char  */
    } /* while */
    *dd++ = '\0';				   /* terminate ASCIZ	    */
} /* decodhead */


/*
| Abs: Decode a line with BASE64 or QUOTED-PRINTABLE codes.
| Par: src      = where to start decoding from
|      encoding = content-transfer-encoding
|      junkp    = scanning junk (reference)
| Ret: Decoded characters in buffer.
*/
static int decodebuf(unsigned char *src, int encoding, int *junkp)
{
    int cc, show, bsiz;
    unsigned char *ss, *dest;

    if (encoding == CE_UNCODED) return(strlen(src));

    /* else */
    bsiz = 0;
    dest = src;

    if (encoding == CE_QUOTEDP) {
	while (*src) {
	    if (*src == '=') {
		src++;
		if (!*src) break;
		if (('\n' == *src) || ('\r' == *src)) break;
		cc  = isdigit(*src) ? (*src - '0') : (*src - 55);
		cc *= 0x10;
		src++; if (!*src) break;
		cc += isdigit(*src) ? (*src - '0') : (*src - 55);
		*dest = cc;
	    } else *dest = *src;
	    dest++; src++; bsiz++;
	} /* while */
	*dest = '\0';
	return(bsiz);
    } /* if (quoted printable) */

    /* else */

    if (encoding == CE_BASE064) {
        if (EndP) {
            *junkp = 1;
	    return(bsiz);
        } /* if */
        BPos = 0;
	while (*src) {
	    cc = *src++;
	    if	    ((cc >= 'A') && (cc <= 'Z')) cc = cc - 'A';
	    else if ((cc >= 'a') && (cc <= 'z')) cc = cc - 'a' + 26;
	    else if ((cc >= '0') && (cc <= '9')) cc = cc - '0' + 52;
	    else if  (cc == '/')		 cc = 63;
	    else if  (cc == '+')		 cc = 62;
	    else if  (cc == '=') { EndP = 1;	 cc = -1; }
	    else if  (cc == '-') {			/* end    */
		*junkp = 1;				/* junk?  */
		break;
	    } else cc = -1;				/* ignore */

	    if (cc >= 0) {
		BBuf[BPos++] = cc;
		if (BPos == 4) {
		    ss = decodebase64();
		    for (cc = 0; cc < 3; cc++) *dest++ = ss[cc];
		    bsiz += 3;
		} /* if (got buffer) */
	    } /* if (significant) */
	} /* while */

        show = BPos;
        if (show) show--;
        ss = decodebase64();
        for (cc = 0; cc < show; cc++) *dest++ = ss[cc];
        bsiz += show;

	*dest = '\0';
	return(bsiz);
    } /* if (base64) */

    return(bsiz);

} /* decodebuf */


/*
| Abs: Parse Content-type subtype.
| Sef: Sets the following: CSubType and Charset.
| Par: hline = line to parse
*/
static void parsctsub(unsigned char *hline)
{
    unsigned char *tt;

    if (!hline) return;
    tt = (unsigned char *)strchr(hline, '/');

    if (tt) {
	tt++;
	if (*tt == 'x') {
	    CSubType = ST_PRIVATE;
	    copytoken(PrivSTyp, tt, PRIVSIZ);
	} else {
	    switch (ContType) {
	      case CT_UNKNOWN:
		break;
	      case CT_ASCTEXT:
		if (!strncmp(tt, "plain", 5)) CSubType = ST_PLAINTX;
		else			      CSubType = ST_NOTIMPL;
		break;
	      case CT_MULTIPT:
		break;
	      case CT_MESSAGE:
		break;
	      case CT_APPLCTN:
		if (!strncmp(tt, "octet-stream", 12)) CSubType = ST_APOCTET;
		else				      CSubType = ST_NOTIMPL;
		break;
	      case CT_IMAGECT:
		break;
	      case CT_AUDIOCT:
		break;
	      case CT_VIDEOCT:
		break;
	      case CT_NOTIMPL: /* fallthrough */
	      case CT_PRIVATE: /* fallthrough */
	      default:
		CSubType = ST_UNKNOWN;
	    } /* switch */
	} /* if (private subtype) else ... */
    } /* if (subtype) */


    while ((tt = (unsigned char *)strchr(hline, ';'))) {
        tt++;
	while (isspace(*tt)) tt++;
	hline = tt;

	/* fprintf(stderr, "DB: %s", tt); */
	if (!strncmp(tt, "charset=", 8)) {
	    tt += 8;
	    if (*tt == 'x') {
		Charset = CS_PRIVT;
		copytoken(PrivCSet, tt, PRIVSIZ);
	    } else {
		Charset = parsecharset(tt);
	    }
	    /* fputs(tt, stdout); fputc('\n', stdout); ** DB */
	    continue;
	} /* if (charset) */
	/* else */

	if (!strncmp(tt, "name=", 5)) {
	    tt += 5;
	    NamePar = copytoken(NamePar, tt, 0);
	    /* fputs(tt, stdout); fputc('\n', stdout); ** DB */
	    continue;
	} /* if (charset) */
	/* else */

	copytoken(PrivPara, tt, PRIVSIZ);
    } /* while parameters */

} /* parsctsub */


/*
| Abs: Parse headers to determine MIME version, etc.
| Imp: Variable hline is used to hold one line from the header. This is
|      canonized by folding it to lower case and stripping away quotes.
| Sef: Sets the following: MimeVers, ContType and Encoding.
| Par: hline = the  line from the message header to parse
*/
static void parsehead(unsigned char *hline)
{
    int majv, minv;
    unsigned char *ss, *dd, cc;

    cc = tolower(hline[0]);
    if ((cc != 'c') && (cc != 'm')) return; /* This line is boring */

    dd = ss = hline;
    while (*ss) {
	if (*ss != '"') *dd++ = tolower(*ss);
	ss++;
    } /* canonize line */
    *dd++ = '\0';

    /* printf("HEADER: %s", hline); ** DB */

    if (!strncmp(hline, "mime-version:", 13)) {
	sscanf(hline+13, "%d.%d", &majv, &minv);
	MimeVers = majv*100 + minv;
	return;
    } /* if (mime-version) */

    /* else */
    if (!strncmp(hline, "content-transfer-encoding:", 26)) {
	dd = hline+26;
	while (isspace(*dd)) dd++;
	if (!strncmp(dd, "quoted-printable", 16)) Encoding = CE_QUOTEDP;
	else if (!strncmp(dd, "base64", 6))       Encoding = CE_BASE064;
	else if (!strncmp(dd, "binary", 6))       Encoding = CE_BINCODE;
	else if ((*dd == '7') || (*dd == '8'))    Encoding = CE_UNCODED;
	else					  Encoding = CE_NOTIMPL;
	/* fputs(dd, stdout); fputc('\n', stdout); DB */
	return;
    } /* if (content-transfer-encoding) */
    /* else */

    if (!strncmp(hline, "content-type:", 13)) {
	dd = hline+13;
	while (isspace(*dd)) dd++;
	/* printf("[%s]\n", dd); ** DB */
	if      (!strncmp(dd, "text", 4))	  ContType = CT_ASCTEXT;
	else if (!strncmp(dd, "application", 11)) ContType = CT_APPLCTN;
	else if (*dd == 'x') {			  ContType = CT_PRIVATE; copytoken(PrivCTyp, dd, PRIVSIZ); }
	else					  ContType = CT_NOTIMPL;
	parsctsub(dd);
    } /* if (content-type) */

} /* parsehead */


/*
| Abs: Reset state machine for new message.
|      cset  = default character set to assume for messages w/o MIME header.
|              The value CS_ASCII is RFC-822 conformant, but the value CS_ISOL1
|              will do no harm an will give much more robust behaviour in most
|              western european locations (some news articles uses CS_ISOL1,
|              and omits MIME headers).
|      encod = CE_PRSHEAD if message has a header, so we should determine the
|              content-transfer-encoding, etc. by parsing the header.
|              Otherwise, we are decoding a message body witout the header,
|              so this parameter is used to etablish default encoding.
|      activ = mask of what services to activate. AC_DOITALL is all services.
| Des: ContType is set to CT_UNKNOWN so we can detect RFC-1049 content-type
|      headers.
*/
void ml_unmimsetup(int cset, int encod, int activ)
{
    DecodeP	 = 1;
    FoldChP	 = 1;
    ActMask	 = activ;
    EndP         = 0;
    NamePar      = NULL;
    PrivPara[0]  = '\0';
    AttFile	 = NULL;
    if (encod == CE_PRSHEAD) {
        InHeadP  = 1;
	MimeVers = MV_R0822;
	ContType = CT_UNKNOWN;
	CSubType = ST_UNKNOWN;
	Charset  = CS_UNKWN;
	Encoding = CE_UNCODED;
    } else {
        InHeadP  = 0;
	MimeVers = 100;
	ContType = CT_ASCTEXT;
	CSubType = ST_PLAINTX;
	Charset  = cset;
	TempEncd = Encoding = encod;
	ml_foldinit(Charset, CS_IGNOR);
    }
} /* ml_unmimsetup */


/*
| Abs: Clean up.
*/
void ml_unmimedone(void)
{
    if (AttFile) {
	fclose(AttFile);
	AttFile = NULL;
    } /* if (AttFile) */
} /* ml_unmimedone */


/*
| Abs: End of header predicate.
| Ret: TRUE if detected a null line, else false.
*/
static int eohp(unsigned char *buf)
{
    if ((buf[0] == '\r') && (buf[1] == '\n')) return(1);
    if  (buf[0] == '\n')		      return(1);
    return(0);
} /* eohp */



/*
| Abs: Do all sort of processing at the end of header.
*/
static void donehead(void)
{
    int ctypemask;

    InHeadP = 0;
    if (MimeVers  < 0) {			/* NOT MIME     */
	if (ContType != CT_UNKNOWN)	{	/* RFC1049	*/
	    MimeVers = MV_R1049;
	} else				{	/* no head	*/
	 /* MimeVers = MV_R0822;	default (ml_unmimsetup) */
	    ContType = CT_ASCTEXT;
	    CSubType = ST_PLAINTX;
	 /* Encoding = CE_UNCODED;	default (ml_unmimsetup) */
	 /* Charset  = CS_ISOL1;	default (ml_unmimsetup) */
	} /* if (RFC1049) set up; else assume no header */
    } /* if (NOT MIME) */
    TempEncd = Encoding;

    if ((Charset == CS_UNKWN)
	&& ((ContType != CT_ASCTEXT) || (CSubType != ST_PLAINTX))) {
	ml_foldinit(CS_UNKWN, CS_UNKWN);
	FoldChP = 0;
    } else {
	ml_foldinit(Charset,  CS_IGNOR);
    } /* if */

    if ((ActMask & AC_APPLCTN) && (NamePar)) {
	AttFile = fopen(NamePar, "wb");
    } /* if (NamePar) */

    ctypemask = 0; /* default */
    switch (ContType) {
      case CT_ASCTEXT: ctypemask = AC_ASCTEXT;	break;
      case CT_MULTIPT: ctypemask = AC_MULTIPT;	break;
      case CT_MESSAGE: ctypemask = AC_MESSAGE;	break;
      case CT_APPLCTN: ctypemask = AC_APPLCTN;	break;
    } /* switch */
    DecodeP = ctypemask & ActMask;

} /* donehead */


/*
| Abs: Process one line of the buffer.
| Par: buf  = buffer containing line, also used to return decoded buffer.
|      bsiz = ref. parameter, used to return size of buffer.
| Ret: 0: nothing special
|      1: line is null line separating header from body
|      2: found junk trailing BASE64 encoding
|      3: dumping attachement to named file
| Des: The mimelite library doesn't really handle RFC-1049 content types, but
|      it assumes that somthing _with_ a content-type header, but _without_ a
|      mime-version header must be RFC-1049 and sets MimeVers accordingly.
|      The rest is up to you.
*/
int ml_unmimeline(unsigned char *buf, int *bsiz)
{
    int junkp;

    junkp = 0;
    *bsiz = strlen(buf); /* Just in case */
    if (!InHeadP) {
        if (DecodeP) *bsiz = decodebuf(buf, TempEncd, &junkp);
	if (FoldChP) ml_foldbuff(buf);
	if (AttFile) { fwrite(buf, *bsiz, 1, AttFile); return(3); }
	if (junkp)   { TempEncd = CE_UNCODED;	       return(2); }
	/* else */				       return(0);
    } /* if (body) */

    /* else we are processing header: */

    if (eohp(buf)) {				/* end of head  */
	donehead();
	return(1);
    } /* if (empty line) ... */

    /* else */

    parsehead(buf);
    decodhead(buf);
    ml_foldbuff(buf);
    *bsiz = strlen(buf); /* Just in case */
    return(0);

} /* ml_unmimeline */

/* EOF */

