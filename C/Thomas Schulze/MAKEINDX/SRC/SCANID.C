
/*
 *
 * Copyright (C) 1987 	Pehong Chen	(phc@renoir.berkeley.edu)
 * Computer Science Division
 * University of California, Berkeley
 *
 */

#include		"mkind.h"
#include		"scanid.h"


int			idx_lc;		/* line count */
int			idx_tc;		/* total entry count */
int			idx_ec;		/* erroneous entry count */
int			idx_dc;		/* number of dots printed so far */

static	int		first_entry = TRUE;
static	int		comp_len;
static	char		key[ARGUMENT_MAX];
static	char		no[NUMBER_MAX];

NODE_PTR		head;
NODE_PTR		tail;


void
scan_idx()
{
    	char 		keyword[STRING_MAX];
	int		c;
	int		i = 0;
	int		not_eof = TRUE;
	int		arg_count = -1;

	MESSAGE("Scanning input file %s...", idx_fn);
	idx_lc = idx_tc = idx_ec = idx_dc = 0;
	comp_len = strlen(page_comp);
	while (not_eof) {
		switch (c = GET_CHAR(idx_fp)) {
		case EOF:
			if (arg_count == 2) {
				idx_lc++;
				if (make_key())
					IDX_DOT(DOT_MAX);
				arg_count = -1;
			} else
				not_eof = FALSE;
			break;

		case LFD:
			idx_lc++;
			if (arg_count == 2) {
				if (make_key())
					IDX_DOT(DOT_MAX);
				arg_count = -1;
			} else if (arg_count > -1) {
			    	IDX_ERROR("Missing arguments -- need two (premature LFD).\n", NULL);
				arg_count = -1;
			}
		case TAB:
		case SPC:
			break;

		default:
			switch (arg_count) {
			case -1:
				i = 0;
				keyword[i++] = (char)c;
				arg_count++;
				idx_tc++;
				break;
			case 0:
				if (c == idx_aopen) {
					arg_count++;
				    	keyword[i] = NULL;
					if (STREQ(keyword, idx_keyword)) {
						if (! scan_arg1()) {
							arg_count = -1;
						}
					} else {
						IDX_SKIPLINE;
						IDX_ERROR("Unknown index keyword %s.\n", keyword);
					}
				} else {
					if (i < STRING_MAX)
						keyword[i++] = (char)c;
					else {
						IDX_SKIPLINE;
						IDX_ERROR2("Index keyword %s too long (max %d).\n",
						      	  keyword, STRING_MAX);
					}
				}
				break;
			case 1:
				if (c == idx_aopen) {
					arg_count++;
					if (! scan_arg2()) {
						arg_count = -1;
					}
				} else {
					IDX_SKIPLINE;
					IDX_ERROR("No opening delimiter for second argument (illegal char `%c').\n", c);
				}
				break;
			case 2:
				IDX_SKIPLINE;
				IDX_ERROR("No closing delimiter for second argument (illegal character `%c').\n", c);
				break;
			}
			break;
		}
	}

	/* fixup the total counts */
	idx_tt += idx_tc;
	idx_et += idx_ec;

	DONE(idx_tc - idx_ec, "entries accepted", idx_ec, "rejected");
	CLOSE(idx_fp);
}

static int
make_key()
{
	NODE_PTR	ptr;
	int		i;

	/* allocate and initialize a node */
	if ((ptr = (NODE_PTR) malloc(sizeof(NODE))) == NULL)
		FATAL("Not enough core...abort.\n", "");

	for (i = 0; i < FIELD_MAX; i++) {
	    ptr->data.sf[i][0] = NULL;
	    ptr->data.af[i][0] = NULL;
	}
	ptr->data.lpg[0] = ptr->data.encap[0] = NULL;
	ptr->data.count = 0;
	ptr->data.type = EMPTY;

	/* process index key */
	if (! scan_key(&(ptr->data)))
	    	return (FALSE);

	/* determine group type */
	ptr->data.group = group_type(ptr->data.sf[0]);

	/* process page number */
	strcpy(ptr->data.lpg, no);
	if (! scan_no(no, ptr->data.npg, &(ptr->data.count), &(ptr->data.type)))
		return (FALSE);

	if (first_entry) {
		head = tail = ptr;
		first_entry = FALSE;
	} else {
		tail->next = ptr;
		tail = ptr;
	}
	ptr->data.lc = idx_lc;
	ptr->data.fn = idx_fn;
	tail->next = NULL;

	return (TRUE);
}


static int
scan_key(data)
	FIELD_PTR	data;
{
	int		i = 0;		/* current level */
	int		n = 0;		/* index to the key[] array */
	int		second_round = FALSE;
	int		last = FIELD_MAX - 1;

	while (TRUE) {
		if (key[n] == NULL)
		    	break;
		if (key[n] == idx_encap) {
			n++;
			if (scan_field(&n, data->encap, FALSE, FALSE, FALSE))
			    	break;
			else
				return (FALSE);
		}
		if (key[n] == idx_actual) {
			n++;
			if (! scan_field(&n, data->af[i], TRUE, TRUE, FALSE))
				return (FALSE);
		} else {
			/* Next nesting level */
			if (second_round) {
				i++;
				n++;
			}
			if (i == last) {
				if (! scan_field(&n, data->sf[i], FALSE, TRUE, TRUE))
					return (FALSE);
			} else {
				if (! scan_field(&n, data->sf[i], TRUE, TRUE, TRUE))
					return (FALSE);
			}
			second_round = TRUE;
		}
	}

	/* check for empty fields which shouldn't be empty */
	if (*data->sf[0] == NULL) {
		NULL_RTN;
	}
	for (i = 1; i < FIELD_MAX-1; i++)
		if ((*data->sf[i] == NULL) &&
		    ((*data->af[i] != NULL) || (*data->sf[i+1] != NULL))) {
			NULL_RTN;
		}

	/* i == FIELD_MAX-1 */
	if ((*data->sf[i] == NULL) && (*data->af[i] != NULL)) {
		NULL_RTN;
	}
	return (TRUE);
}


static int
scan_field(n, field, ck_level, ck_encap, ck_actual)
	int		*n;
	char		field[];
	int		ck_level;
	int		ck_encap;
	int		ck_actual;
{
	int		i = 0;
	int		nbsh;		/* backslash count */

	while (TRUE) {
		if (compress_blanks && (key[*n] == SPC))
			++*n;

		nbsh = 0;
		while (key[*n] == idx_escape) {
			nbsh++;
			field[i++] = key[*n];
			++*n;
		}

		if (key[*n] == idx_quote) {
			if (nbsh%2 == 0)
				field[i++] = key[++*n];
			else
				field[i++] = key[*n];
		} else if ((ck_level && (key[*n] == idx_level)) ||
			   (ck_encap && (key[*n] == idx_encap)) ||
			   (ck_actual && (key[*n] == idx_actual)) ||
			   (key[*n] == NULL)) {
			if ((i > 0) && compress_blanks && (field[i-1] == SPC))
				field[i-1] = NULL;
			else
				field[i] = NULL;
		    	return (TRUE);
		} else {
		    	field[i++] = key[*n];
			if ((! ck_level) && (key[*n] == idx_level)) {
				IDX_ERROR2("Extra `%c' at position %d of first argument.\n", idx_level, *n+1);
				return (FALSE);
			} else if ((! ck_encap) && (key[*n] == idx_encap)) {
				IDX_ERROR2("Extra `%c' at position %d of first argument.\n", idx_encap, *n+1);
				return (FALSE);
			} else if ((! ck_actual) && (key[*n] == idx_actual)) {
				IDX_ERROR2("Extra `%c' at position %d of first argument.\n", idx_actual, *n+1);
				return (FALSE);
			}
		}
		++*n;
	}
}

int
group_type(str)
	char		*str;
{
	int		i = 0;

	while ((str[i] != NULL) && ISDIGIT(str[i]))
		i++;

	if (str[i] == NULL) {
		sscanf(str, "%d", &i);
		return (i);
	} else
		if (ISSYMBOL(str[0]))
			return (SYMBOL);
		 else
			return (ALPHA);
}

static int
scan_no(no, npg, count, type)
	char		no[];
	short		npg[];
	short		*count;
	short		*type;
{
	int		i = 1;

	if (isdigit(no[0])) {
		*type = ARAB;
		if (! scan_arabic(no, npg, count))
			return (FALSE);
	/* simple heuristic to determine if a letter is Roman or Alpha */
	} else if (IS_ROMAN_LOWER(no[0]) && (! IS_COMPOSITOR)) {
		*type = ROML;
		if (! scan_roman_lower(no, npg, count))
			return (FALSE);
	/* simple heuristic to determine if a letter is Roman or Alpha */
	} else if (IS_ROMAN_UPPER(no[0]) && ((no[0] == ROMAN_I) || (! IS_COMPOSITOR))) {
		*type = ROMU;
		if (! scan_roman_upper(no, npg, count))
			return (FALSE);
	} else if (IS_ALPHA_LOWER(no[0])) {
		*type = ALPL;
		if (! scan_alpha_lower(no, npg, count))
			return (FALSE);
	} else if (IS_ALPHA_UPPER(no[0])) {
		*type = ALPU;
		if (! scan_alpha_upper(no, npg, count))
			return (FALSE);
	} else {
		IDX_ERROR("Illegal page number %s.\n", no);
		return (FALSE);
	}
	return (TRUE);
}


static int
scan_arabic(no, npg, count)
	char		no[];
	short		npg[];
	short		*count;
{
	short		i = 0;
	char		str[ARABIC_MAX];

	while ((no[i] != NULL) && (i < ARABIC_MAX) && (! IS_COMPOSITOR)) {
		if (isdigit(no[i])) {
			str[i] = no[i];
			i++;
		} else {
			IDX_ERROR2("Illegal Arabic digit: position %d in %s.\n", i+1, no);
			return (FALSE);
		}
	}
	if (i >= ARABIC_MAX) {
		IDX_ERROR2("Arabic page number %s too big (max %d digits).\n",
			   no, ARABIC_MAX);
		return (FALSE);
	}
	str[i] = NULL;

	ENTER(strtoint(str) + page_offset[ARAB]);

	if (IS_COMPOSITOR)
		return (scan_no(&no[i+comp_len], npg, count, &i));
	else
		return (TRUE);
}


static int
scan_roman_lower(no, npg, count)
	char		no[];
	short		npg[];
	short		*count;
{
	short		i = 0;
	int		inp = 0;
	int		prev = 0;
	int		new;

	while ((no[i] != NULL) && (i < ROMAN_MAX) && (! IS_COMPOSITOR)) {
		if ((IS_ROMAN_LOWER(no[i])) && (new = ROMAN_LOWER_VAL(no[i]))) {
			if (prev == 0)
				prev = new;
			else {
				if (prev < new) {
					prev = new - prev;
					new = 0;
				}
				inp += prev;
				prev = new;
			}
		} else {
			IDX_ERROR2("Illegal Roman number: position %d in %s.\n", i+1, no);
			return (FALSE);
		}
		i++;
	}
	if (i == ROMAN_MAX) {
		IDX_ERROR2("Roman page number %s too big (max %d digits).\n",
			   no, ROMAN_MAX);
		return(FALSE);
	}
	inp += prev;

	ENTER(inp + page_offset[ROML]);

	if (IS_COMPOSITOR)
		return (scan_no(&no[i+comp_len], npg, count, &i));
	else
		return (TRUE);
}


static int
scan_roman_upper(no, npg, count)
	char		no[];
	short		npg[];
	short		*count;
{
	short		i = 0;
	int		inp = 0;
	int		prev = 0;

	int		new;

	while ((no[i] != NULL) && (i < ROMAN_MAX) && (! IS_COMPOSITOR)) {
		if ((IS_ROMAN_UPPER(no[i])) && (new = ROMAN_UPPER_VAL(no[i]))) {
			if (prev == 0)
				prev = new;
			else {
				if (prev < new) {
					prev = new - prev;
					new = 0;
				}
				inp += prev;
				prev = new;
			}
		} else {
			IDX_ERROR2("Illegal Roman number: position %d in %s.\n", i+1, no);
			return (FALSE);
		}
		i++;
	}
	if (i == ROMAN_MAX) {
		IDX_ERROR2("Roman page number %s too big (max %d digits).\n",
			   no, ROMAN_MAX);
		return(FALSE);
	}
	inp += prev;

	ENTER(inp + page_offset[ROMU]);

	if (IS_COMPOSITOR)
		return (scan_no(&no[i+comp_len], npg, count, &i));
	else
		return (TRUE);
}


static int
scan_alpha_lower(no, npg, count)
	char		no[];
	short		npg[];
	short		*count;
{
	short		i;

	ENTER(ALPHA_VAL(no[0]) + page_offset[ALPL]);

	i = 1;
	if (IS_COMPOSITOR)
		return (scan_no(&no[comp_len+1], npg, count, &i));
	else
		return (TRUE);
}


static int
scan_alpha_upper(no, npg, count)
	char		no[];
	short		npg[];
	short		*count;
{
	short		i;

	ENTER(ALPHA_VAL(no[0]) + page_offset[ALPU]);

	i = 1;
	if (IS_COMPOSITOR)
		return (scan_no(&no[comp_len+1], npg, count, &i));
	else
		return (TRUE);
}


static int
scan_arg1()
{
	int		i = 0;
	int		n = 0;		/* delimiter count */
	int		a;

	if (compress_blanks)
		while (((a = GET_CHAR(idx_fp)) == SPC) || (a == TAB));
	else
		a = GET_CHAR(idx_fp);

	while (i < ARGUMENT_MAX) {
		if (a == idx_aopen) {
			/* opening delimiters within the argument list */
			key[i++] = (char)a;
			n++;
		} else if (a == idx_aclose) {
			if (n == 0) {
				if (compress_blanks && key[i-1] == SPC)
					key[i-1] = NULL;
				else
					key[i] = NULL;
				return (TRUE);
			} else {
				key[i++] = (char)a;
				n--;
			}
		} else switch (a) {
			case LFD:
				idx_lc++;
				IDX_ERROR("Incomplete first argument (premature LFD).\n", "");
				return (FALSE);
			case TAB:
			case SPC:
				/* compress successive SPC's to one SPC */
				if (compress_blanks && (i > 0) &&
				    (key[i-1] != SPC) && (key[i-1] != TAB)) {
					key[i++] = SPC;
					break;
				}
			default:
				key[i++] = (char)a;
				break;
			}
		a = GET_CHAR(idx_fp);
	}
	/* Skip to end of line */
	while (GET_CHAR(idx_fp) != LFD);
	idx_lc++;
	IDX_ERROR("First argument too long (max %d).\n", ARGUMENT_MAX);
	return (FALSE);
}


static int
scan_arg2()
{
	int		i = 0;
	int		a;
	int		hit_blank = FALSE;

	while (((a = GET_CHAR(idx_fp)) == SPC) || (a == TAB));

	while (i < NUMBER_MAX) {
		if (a == idx_aclose) {
			no[i] = NULL;
			return (TRUE);
		} else switch (a) {
			case LFD:
				idx_lc++;
				IDX_ERROR("Incomplete second argument (premature LFD).\n", "");
				return (FALSE);
			case TAB:
			case SPC:
				hit_blank = TRUE;
				break;
			default:
				if (hit_blank) {
					while (GET_CHAR(idx_fp) != LFD);
					idx_lc++;
					IDX_ERROR("Illegal space within numerals in second argument.\n", "");
					return (FALSE);
				}
				no[i++] = (char)a;
				break;
			}
		a = GET_CHAR(idx_fp);
	}
	/* Skip to end of line */
	while (GET_CHAR(idx_fp) != LFD);
	idx_lc++;
	IDX_ERROR("Second argument too long (max %d).\n", NUMBER_MAX);
	return (FALSE);
}

