/* parmode.c */

/*
 *  This file is included (twice) to
 *  parse two addressing modes, into
 *  slightly different variable names...
 *
 */

#ifdef NEVER_DEFINED
{				/* (this makes GNU emacs happy in c-mode) */
#endif
	/*
	 *  Dn
	 *  An
	 *  # expression
	 */
	if ((*tok >= KW_D0) && (*tok <= KW_D7))
	{
		AMn = DREG;
		AnREG = *tok++ & 7;
	}
	else if ((*tok >= KW_A0) && (*tok <= KW_A7))
	{
		AMn = AREG;
		AnREG = *tok++ & 7;
	}
	else if (*tok == '#')
	{
		++tok;
		if (expr(AnEXPR, &AnEXVAL, &AnEXATTR, &AnESYM) != OK)
			return ERROR;
		AMn = IMMED;
	}
	/*
	+*  (An)
	+*  (An)+
	+*  (An,Xn[.siz][*scale])
	+*  (PC,Xn[.siz][*scale])
	+*  (d16,An)
	+*  (d8,An,Xn[.siz][*scale])
	+*  (d16,PC)
	+*  (d8,PC,Xn[.siz][*scale])
	*  ([bd,An],Xn,od)
	*  ([bd,An,Xn],od)
	*  ([bd,PC],Xn,od)
	*  ([bd,PC,Xn],od)
	*/
	else if (*tok == '(')
	{
		++tok;
		if ((*tok >= KW_A0) && (*tok <= KW_A7))
		{
			AnREG = *tok++ & 7;
			if (*tok == ')')
			{
				++tok;
				if (*tok == '+')
				{
					++tok;
					AMn = APOSTINC;
				}
				else AMn = AIND;
				goto AnOK;
			}
			AMn = AINDEXED;
			goto AMn_IX0;		/* handle ",Xn[.siz][*scale])" */
		}
		else if (*tok == KW_PC)	/* (PC,Xn[.siz][*scale]) */
		{
			++tok;
			AMn = PCINDEXED;

			/*
			 *  Common index handler;
			 *  enter here with `tok' pointing at the comma.
			 *
			 */
AMn_IX0:		/* handle indexed with missing expr */
			AnEXVAL = 0;
			AnEXATTR = ABS | DEFINED;

AMn_IXN:		/* handle any indexed (tok -> a comma) */
			if (*tok++ != ',')
				goto badmode;
			if (*tok < KW_D0 || *tok > KW_A7)
				goto badmode;
			AnIXREG = *tok++ & 15;

			switch ((int)*tok)	/* index reg size: <empty> | .W | .L */
			{
				case DOTW:
					++tok;
				default:
					AnIXSIZ = 0;
					break;

				case DOTL:
					AnIXSIZ = 0x0800;
					++tok;
					break;

				case DOTB:		/* .B not allowed here... */
					goto badmode;
			}

			if (*tok == '*')	/* scale: *1, *2, *4, *8 */
			{
				++tok;
				if (*tok++ != CONST ||
					  *tok > 8)
					goto badmode;

				switch ((int)*tok++)
				{
					case 1:
						break;

					case 2:
						AnIXSIZ |= TIMES2;
						break;

					case 4:
						AnIXSIZ |= TIMES4;
						break;

					case 8:
						AnIXSIZ |= TIMES8;
						break;

					default:
						goto badmode;
				}
			}

			if (*tok++ != ')')	/* final ")" */
				goto badmode;
			goto AnOK;
		}
		else if (*tok == '[')	/* ([... */
		{
			goto unmode;
		}
		else
		{			/* (expr... */
			if (expr(AnEXPR, &AnEXVAL, &AnEXATTR, &AnESYM) != OK)
				return ERROR;
			if (*tok++ != ',')
				goto badmode;

			if ((*tok >= KW_A0) && (*tok <= KW_A7))
			{
				AnREG = *tok & 7;
				++tok;
				if (*tok == ',')
				{
					AMn = AINDEXED;
					goto AMn_IXN;
				}
				else if (*tok == ')')
				{
					AMn = ADISP;
					++tok;
					goto AnOK;
				}
				else goto badmode;
			}
			else if (*tok == KW_PC)
			{
				if (*++tok == ',')
				{		/* expr(PC,Xn...) */
					AMn = PCINDEXED;
					goto AMn_IXN;
				}
				else if (*tok == ')')
				{
					AMn = PCDISP;	/* expr(PC) */
					++tok;
					goto AnOK;
				}
				else goto badmode;
			}
			else goto badmode;
		}
	}
	else if (*tok == '-' &&
			 tok[1] == '(' &&
			 ((tok[2] >= KW_A0) && (tok[2] <= KW_A7)) &&
			 tok[3] == ')')
	{
		AMn = APREDEC;
		AnREG = tok[2] & 7;
		tok += 4;
	}
	else if (*tok == KW_CCR)
	{
		AMn = AM_CCR;
		++tok;
		goto AnOK;
	}
	else if (*tok == KW_SR)
	{
		AMn = AM_SR;
		++tok;
		goto AnOK;
	}
	else if (*tok == KW_USP)
	{
		AMn = AM_USP;
		++tok;
		goto AnOK;
	}
	/*
	 *  expr
	 *  expr.w
	 *  expr.l
	 *  d16(An)
	 *  d8(An,Xn[.siz])
	 *  d16(PC)
	 *  d8(PC,Xn[.siz])
	 */
	else
	{
		if (expr(AnEXPR, &AnEXVAL, &AnEXATTR, &AnESYM) != OK)
			return ERROR;

		if (*tok == DOTW)		/* expr.W */
		{
			++tok;
			AMn = ABSW;
			goto AnOK;
		}
		else if (*tok != '(')	/* expr[.L] */
		{
			AMn = ABSL;
			/*
			 *  Defined, absolute values from $FFFF8000..$00007FFF
			 *  get optimized to absolute short.  Wheee.
			 */
			if ((AnEXATTR & (TDB|DEFINED)) == DEFINED &&
				  (AnEXVAL + 0x8000) < 0x10000)
				AMn = ABSW;

			if (*tok == DOTL)	/* force .L */
			{
				++tok;
				AMn = ABSL;
			}
			goto AnOK;
		}

		++tok;
		if ((*tok >= KW_A0) && (*tok <= KW_A7))
		{
			AnREG = *tok++ & 7;
			if (*tok == ')')
			{
				AMn = ADISP;
				++tok;
				goto AnOK;
			}
			AMn = AINDEXED;
			goto AMn_IXN;
		}
		else if (*tok == KW_PC)
		{
			if (*++tok == ')')
			{
				AMn = PCDISP;
				++tok;
				goto AnOK;
			}
			AMn = PCINDEXED;
			goto AMn_IXN;
		}
		goto badmode;
	}

	/*
	 *  addressing mode OK;
	 */
AnOK:

#ifdef NEVER_DEFINED
}
#endif

/*
 *  Cleanup dirty little macros
 */
#undef	AnOK
#undef	AMn
#undef	AnREG
#undef	AnIXREG
#undef	AnIXSIZ
#undef	AnEXPR
#undef	AnEXVAL
#undef	AnEXATTR
#undef	AnOEXPR
#undef	AnOEXVAL
#undef	AnOEXATTR
#undef	AnESYM
#undef	AMn_IX0
#undef	AMn_IXN
