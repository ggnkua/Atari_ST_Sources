
/*
 *
 * Copyright (C) 1987 	Pehong Chen	(phc@renoir.berkeley.edu)
 * Computer Science Division
 * University of California, Berkeley
 *
 */

#if    KCC_20
/* KCC preprocessor bug collapses multiple blanks to single blank */
#define IND_ERROR(F, D)	{ \
	if (idx_dot) { \
		fprintf(ilg_fp, "\n"); \
		idx_dot = FALSE; \
	} \
	fprintf(ilg_fp, "## Warning (input = %s, line = %d; output = %s, line = %d):\n\040\040 -- ", \
			curr->fn, curr->lc, ind_fn, ind_lc+1); \
	fprintf(ilg_fp, F, D); \
	ind_ec++; \
}
#else
#define IND_ERROR(F, D)	{ \
	if (idx_dot) { \
		fprintf(ilg_fp, "\n"); \
		idx_dot = FALSE; \
	} \
	fprintf(ilg_fp, "## Warning (input = %s, line = %d; output = %s, line = %d):\n   -- ", \
			curr->fn, curr->lc, ind_fn, ind_lc+1); \
	fprintf(ilg_fp, F, D); \
	ind_ec++; \
}
#endif


#define	PUTC(C) { \
	fprintf(ind_fp, "%c", C); \
}

#define	PUT(S) { \
	fprintf(ind_fp, S); \
}

#define PUTLN(S) { \
	fprintf(ind_fp, "%s\n", S); \
	ind_lc++; \
}

#define	SAVE { \
	begin = end = curr; \
	prev_encap = encap; \
}

#define LETTERHEAD { \
	if (lethead_flag) { \
		PUT(lethead_pre); \
		ind_lc += headprelen; \
		switch (curr->group) { \
		case SYMBOL: \
			if (lethead_flag > 0) { \
				PUT("Symbols"); \
			} else { \
				PUT("symbols"); \
			} \
			break; \
		case ALPHA: \
			if (lethead_flag > 0) { \
				let = TOUPPER(let);  \
				PUTC(let); \
			} else { \
				let = TOLOWER(let);  \
				PUTC(let); \
			} \
			break; \
		default: \
			if (lethead_flag > 0) { \
				PUT("Numbers"); \
			} else { \
				PUT("numbers"); \
			} \
			break; \
		} \
		PUT(lethead_suf); \
		ind_lc += headsuflen; \
	} \
}

