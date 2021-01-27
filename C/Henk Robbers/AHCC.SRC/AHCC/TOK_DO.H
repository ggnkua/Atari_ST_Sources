/* Copyright (c) 2000 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * tok_do.h
 */
#define TEEEEST 0

static
bool is_1lh(LEX_RECORD *r)
{
	short i = 0;
	char *s = r->text + 2;		/* we know it is 0x */
	while (ishexa(*s) >= 0) s++, i++;
	return i > 8;
}

static
bool is_1ld(LEX_RECORD *r)
{
	short i = 0;
	char *s = r->text + 2;		/* we know it is 0x */
	while (*s >= DIGITNAUGHT and *s <= DIGITSEVEN) s++, i++;
	return i > 10;
}

static
bool is_1lo(LEX_RECORD *r)
{
	short i = 0;
	char *s = r->text + 2;		/* we know it is 0x */
	while (*s >= DIGITNAUGHT and *s <= DIGITNINE) s++, i++;
	return i > 12;
}

static
bool have_ws = true;

static
DO_TOKEN do_eof
{
	have_ws = false;
	if (G.save_LEX)
		tok_NL();
	elif (end_L0_file())
		tok_EOF();
	else
	{
		n = cur_LEX;
		G.tk_flags &= TK_KEEP|TK_SAWNL;
	}
	return n;
}

static
DO_TOKEN do_bad
{
	have_ws = false;
	if (*r->text eq PCEOT)
		return do_eof(r, n, tokcur);

	tok_BAD();

	G.tk_flags &= TK_KEEP;

	if (tokcur->nflgs.f.nheap)
		save_name(tokcur, r->rl-size_LEX, r->text);

	return n;
}

static
DO_TOKEN do_nl
{
	char *ln = r->text;

	have_ws = false;

	if ((long)ln & 1)
		ln++;
	n_line_no = *(long *)ln;
	G.tk_flags &= TK_KEEP;
	/* only used for -D, retokenize(##) macros, assembler and preprocessor directives */
#if BIP_ASM
	if (G.tk_flags&TK_SEENL)
	{
		tok_NL();
		if (n->cat eq ws)				/* 10'10 HR: white space after newline: for labels */
			curtok->nflgs.f.p1ws = 1;
	}
#endif
	G.tk_flags |= TK_SAWNL;		/* 03'09 */
	return n;
}

static
DO_TOKEN do_ws
{
	if ((G.tk_flags & TK_SEEWS) ne 0 and !have_ws)		/* 03'09 bad, bad omission of () */
	{							/*	else  NOTOK and go on */
		tokcur->token = WS;
		save_name(tokcur, r->rl-size_LEX, r->text);
		have_ws = true;
	}

	G.tk_flags &= (TK_KEEP|TK_SAWNL);		/* 03'09 keep SAWNL */
	return n;
}

static
DO_TOKEN do_op
{
	LEX_RECORD *this = r;
	char toktext[512], *tok = nil;

	have_ws = false;

	if (    !G.in_def
	    and (G.tk_flags&TK_LTSTR)			/* #include <....> */
	    and *r->text eq LSTRINGTOK
	   )
	{
		tok = toktext;
		strcpy(toktext, r->text);
		do
		{
			if (n->cat eq nl or n->cat eq eof)
			{
				error("unterminated include string\n");
				break;
			}
			strcat(toktext, n->text);
			r = n;
			LEX_next(n);
		}
		while(*r->text ne RSTRINGTOK);

		tokcur->token = SCON2;
		tokcur->val.i = strlen(toktext);
	}
#if FLOAT
	else
			/* check before matching '.' or '...' */
	if (    is_point(r)
	    and (n->cat eq dig or n->cat eq eof)
	   )
	{
		static char z[6] = {4, dig, '0', 0};
		tok = toktext;
		n = tok_real((LEX_RECORD *)z, r, toktext);
	#if TEEEEST
		console("(2)tok_real %s\n", toktext);
	#endif
	}
#endif
	else
		tok_op(r);

	G.tk_flags &= (TK_KEEP|TK_SAWNL);	 /* 03'09 keep SAWNL */

	if (tok)
		save_name(tokcur, strlen(tok), tok);
	elif (tokcur->nflgs.f.nheap)
		save_name(tokcur, r->rl-size_LEX, this->text);

	return n;
}

static
DO_TOKEN do_op2
{
	have_ws = false;
	tok_op2(r);

	G.tk_flags &= TK_KEEP;

	if (tokcur->nflgs.f.nheap)
		save_name(tokcur, r->rl-size_LEX, r->text);

	return n;
}

static
DO_TOKEN do_op3
{
	have_ws = false;
	tok_op3(r);

	G.tk_flags &= TK_KEEP;

	if (tokcur->nflgs.f.nheap)
		save_name(tokcur, r->rl-size_LEX, r->text);

	return n;
}

static
DO_TOKEN do_quo
{
	have_ws = false;
	tokcur->token = (G.tk_flags & TK_LTSTR) ? SCON1 : SCON;
	tokcur->val.i = r->rl-size_LEX-1;

	G.tk_flags &= TK_KEEP;

	if (tokcur->nflgs.f.nheap)
		save_name(tokcur, r->rl-size_LEX-1, r->text);

	return n;
}

static
DO_TOKEN do_apo
{
	tokcur->token = ASCON;
	tokcur->val.i = r->rl-size_LEX-1;

	G.tk_flags &= TK_KEEP;

	if (tokcur->nflgs.f.nheap)
		save_name(tokcur, r->rl-size_LEX-1, r->text);

	return n;
}

static
DO_TOKEN do_ide
{
	have_ws = false;
	tokcur->token = ID;
	tokcur->nflgs.f.nheap = 0;
	if (r->rl-size_LEX > G.l_identifier_max_length)
		*(r->text + G.l_identifier_max_length) = 0;
	tokcur->name = to_dictionary(r->text);
#if FOR_A
	ow_tok(tokcur);			/* find ID's that are in fact operators */
#endif
#if NODESTATS
	G.ids++;
#endif
	G.tk_flags &= TK_KEEP;

	return n;
}

static
DO_TOKEN do_dig		/* (LEX_RECORD *r, LEX_RECORD *n, XP tokcur); */
{
	long l;

#if BIP_ASM || FLOAT
	bool okp = is_point(n);
#endif

	LEX_RECORD *this = r;
	char toktext[512], *tok = nil;

	have_ws = false;

#if BIP_ASM
	if (okp)
	{
		LEX_RECORD *rn = next_LEX(n);
		if (    *(rn->text + 1) eq 0)
		{
			short c = tolower(*rn->text);		/* 10'14 HR v5.2 : tolower! */
		   	if (   c eq 'l'
		   	    or c eq 'w'
		   	    or c eq 'b'
		   	    or c eq 's'
		   	    or c eq 'x'
		   	    or c eq 'k'
		   	   )
				okp = false;
		}
	}
#endif

#if FLOAT
	if (okp or is_exp(n))
	{
		n = tok_real(r, n, toktext);
		tok = toktext;
		l = strlen(toktext);
	#if TEEEEST
		console("(3)tok_real %s\n", toktext);
	#endif
	}
	else
#endif
	{
		char *s = n->text;
#if LL
		__ll ll = {0,0};
		bool have_ll = false;
#endif
		tokcur->token = ICON;

		if (n->cat eq ide)
		{
			short ls = 0;
			do{
				char c = tolower(*s);
				if   (c eq LONGTOK)
				{
					ls++;
#if LL
					if (ls eq 2)
						tokcur->zflgs.f.see_ll = 1;
#endif
					tokcur->zflgs.f.see_l = 1;
				}
				elif (c eq  UNSTOK) tokcur->zflgs.f.see_u = 1;
				elif (c eq REALTOK) tokcur->zflgs.f.see_f = 1;
				else break;
				s++;
			}od
		}

		if (r->cat eq dig)
		{
#if BIP_ASM
			if (*r->text eq '0' and G.xlang ne 's')		/* 05'11 HR: Only in C files is digit zero the octal prefix. */
#else
			if (*r->text eq '0')
#endif
			{
#if LL
				if (    is_1lo(r)
				    or (r->rl - size_LEX -1 eq 12 and strcmp(r->text + 1, "37777777777") > 0)
				    or tokcur->zflgs.f.see_ll
				   )
				{
					ll = tok_octll(r);
					have_ll = true;
				}
				else
#endif
					tokcur->val.i = tok_oct(r);
			othw
#if LL
				if (    is_1ld(r)
				    or (r->rl - size_LEX  eq 10 and strcmp(r->text, "4294967295") > 0)
				    or tokcur->zflgs.f.see_ll
				   )
				{
					ll = tok_digll(r);
					have_ll = true;
				}
				else
#endif
					tokcur->val.i = tok_dig(r);
			}
		}
		elif (r->cat eq hex)
		{
#if LL
			if (   is_1lh(r)
			    or tokcur->zflgs.f.see_ll
			   )
			{
				ll = tok_hexll(r);
				if (tokcur->zflgs.f.see_ll)
					if (ll.hi)
						have_ll = true;
			}
			else
#endif
				tokcur->val.i = tok_hex(r);
		}

		if (tokcur->zflgs.i)		/* seen something */
		{
			tok = toktext;
			l = r->rl-size_LEX;
			strcpy(toktext, r->text);
			if (*s ne 0)		/* something left */
				error("syntax at '%s'", s);
			strcat(toktext, n->text);
			l += n->rl-size_LEX;
			LEX_next(n);
		}

#if LL
		if (have_ll)
		{
			tokcur->zflgs.f.see_u = 0;
			tokcur->token = LCON;
			curdbl = allocVn(LLNODE);
			curdbl->llval = ll;
			tokcur->val.dbl = curdbl;
		}
		else
#endif
#if FLOAT
		if (tokcur->zflgs.f.see_f)
		{
			tokcur->zflgs.f.see_u = 0;
			tokcur->token = RCON;
			curdbl = allocVn(RLNODE);
			curdbl->rval = tokcur->val.i;
			tokcur->val.dbl = curdbl;
		}
#endif
	}

	G.tk_flags &= TK_KEEP;

	if (tok)
		save_name(tokcur, l, tok);
	elif (tokcur->nflgs.f.nheap)
		save_name(tokcur, this->rl-size_LEX, this->text);

	return n;
}
