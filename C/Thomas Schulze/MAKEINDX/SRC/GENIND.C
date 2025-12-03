

/*
 *
 * Copyright (C) 1987 	Pehong Chen	(phc@renoir.berkeley.edu)
 * Computer Science Division
 * University of California, Berkeley
 *
 */

#include		"mkind.h"
#include		"genind.h"

static	FIELD_PTR	curr = NULL;
static	FIELD_PTR	prev = NULL;
static	FIELD_PTR	begin = NULL;
static	FIELD_PTR	end = NULL;
static	FIELD_PTR	range_ptr;
static	int		level = 0;
static	int		prev_level = 0;
static	char		*encap = NULL;
static	char		*prev_encap = NULL;
static	int		in_range = FALSE;
static	int		encap_range = FALSE;
static	int		range_lc;
static	char		buff[2*LINE_MAX];
static	char		line[2*LINE_MAX];	/* output buffer */
static	int		ind_lc = 0;		/* overall line count */
static	int		ind_ec = 0;		/* erroneous line count */
static	int		ind_indent;


void
gen_ind()
{
	int		n;
	int		tmp_lc;

	MESSAGE("Generating output file %s...", ind_fn);
	PUT(preamble);
	ind_lc += prelen;
	if (init_page)
		insert_page();

	/* reset counters for putting out dots */
	idx_dc = 0;
	for (n = 0; n < idx_gt; n++) {
		if (idx_key[n]->type != DUPLICATE)
			if (make_entry(n)) {
				IDX_DOT(DOT_MAX);
			}
	}

	tmp_lc = ind_lc;
	if (in_range) {
		curr = range_ptr;
		IND_ERROR("Unmatched range opening operator %c.\n", idx_ropen);
	}

	prev = curr;
	flush_line(TRUE);
	PUT(postamble);
	tmp_lc = ind_lc + postlen;
	if (ind_ec == 1) {
		DONE(tmp_lc, "lines written", ind_ec, "warning");
	} else {
		DONE(tmp_lc, "lines written", ind_ec, "warnings");
	}
}


static int
make_entry(n)
	int    		n;
{
	int    		let;

	/* determine current and previous pointer */
	prev = curr;
	curr = idx_key[n];

	/* check if current entry is in range */
	if ((*curr->encap == idx_ropen) || (*curr->encap == idx_rclose))
		encap = &(curr->encap[1]);
	else
		encap = curr->encap;

	/* determine the current nesting level */
	if (n == 0) {
		prev_level = level = 0;
		make_item();
		let = *curr->sf[0];
		LETTERHEAD;
	} else {
		prev_level = level;
		for (level = 0; level < FIELD_MAX; level++)
		        if (STRNEQ(curr->sf[level], prev->sf[level]) ||
		    	    STRNEQ(curr->af[level], prev->af[level]))
				    break;
		if (level < FIELD_MAX)
			new_entry();
		else
			old_entry();
	}

	if (*curr->encap == idx_ropen)
		if (in_range) {
			IND_ERROR("Extra range opening operator %c.\n", idx_ropen);
		} else {
			in_range = TRUE;
			range_ptr = curr;
			range_lc = ind_lc;
		}
	else if (*curr->encap == idx_rclose)
		if (in_range) {
			in_range = FALSE;
			if (STRNEQ(&(curr->encap[1]), "") &&
			    STRNEQ(prev_encap, &(curr->encap[1]))) {
				IND_ERROR("Range closing operator has an inconsitent encapsulator %s.\n", &(curr->encap[1]));
			}
		} else {
			IND_ERROR("Unmatched range closing operator %c.\n", idx_rclose);
		}
	else if ((*curr->encap != NULL) &&
		 STRNEQ(curr->encap, prev_encap) && in_range)
		IND_ERROR("Inconsistent page encapsulator %s within range.\n", curr->encap);
	return (1);
}


static void
make_item()
{
	int 		i;

	if (level > prev_level) {
		/* ascending level */
		if (*curr->af[level] == NULL)
			sprintf(line, "%s%s", item_u[level], curr->sf[level]);
		else
			sprintf(line, "%s%s", item_u[level], curr->af[level]);
		ind_lc += ilen_u[level];
	} else {
		/* same or descending level */
		if (*curr->af[level] == NULL)
			sprintf(line, "%s%s", item_r[level], curr->sf[level]);
		else
			sprintf(line, "%s%s", item_r[level], curr->af[level]);
		ind_lc += ilen_r[level];
	}

	i = level + 1;
	while (i < FIELD_MAX && *curr->sf[i] != NULL) {
		PUT(line);
		if (*curr->af[i] == NULL)
			sprintf(line, "%s%s", item_x[i], curr->sf[i]);
		else
			sprintf(line, "%s%s", item_x[i], curr->af[i]);
		ind_lc += ilen_x[i];
		i++;
	}

	ind_indent = 0;
	strcat(line, delim_p[level]);
	SAVE;
}


static void
new_entry()
{
	char			let;
	FIELD_PTR		ptr;

	if (in_range) {
		ptr = curr;
		curr = range_ptr;
		IND_ERROR("Unmatched range opening operator %c.\n", idx_ropen);
		in_range = FALSE;
		curr = ptr;
	}

	flush_line(TRUE);

	/* beginning of a new group? */
	if (((curr->group != ALPHA) && (curr->group != prev->group)) ||
	    ((curr->group == ALPHA) &&
	     ((let = TOLOWER(curr->sf[0][0])) != (TOLOWER(prev->sf[0][0]))))) {
		PUT(group_skip);
		ind_lc += skiplen;
		/* beginning of a new letter? */
		LETTERHEAD;
	}
	make_item();
}


static void
old_entry()
{
	int		diff;

	/* current entry identical to previous one: append pages */
	diff = page_diff(end, curr);
	if ((prev->type == curr->type) && (diff != -1) &&
	    (((diff == 0) && (prev_encap != NULL) && STREQ(encap, prev_encap)) ||
	     (merge_page && (diff == 1) &&
	      (prev_encap != NULL) && STREQ(encap, prev_encap)) ||
	     in_range)) {
		end = curr;
		/* extract in-range encaps out */
		if (in_range &&
		    (*curr->encap != NULL) &&
		    (*curr->encap != idx_rclose) &&
		    STRNEQ(curr->encap, prev_encap)) {
			sprintf(buff, "%s%s%s%s%s", encap_p, curr->encap,
				encap_i, curr->lpg, encap_s);
			wrap_line(FALSE);
		}
		if (in_range)
			encap_range = TRUE;
	} else {
		flush_line(FALSE);
		if ((diff == 0) && (prev->type == curr->type)) {
			IND_ERROR("Conflicting entries: multiple encaps for the same page under same key.\n", "");
		} else if (in_range && (prev->type != curr->type)) {
			IND_ERROR("Illegal range formation: starting & ending pages are of different types.\n", "");
		} else if (in_range && (diff == -1)) {
			IND_ERROR("Illegal range formation: starting & ending pages cross chap/sec breaks.\n", "");
		}
		SAVE;
	}
}


static int
page_diff(a, b)
	FIELD_PTR	a;
	FIELD_PTR	b;
{
	short		i;

	if (a->count != b->count)
		return (-1);
	for (i = 0; i < a->count-1; i++)
		if (a->npg[i] != b->npg[i])
			return (-1);
	return (b->npg[b->count-1] - a->npg[a->count-1]);
}


static void
flush_line(print)
	int		print;
{
	char		tmp[LINE_MAX];

	if (page_diff(begin, end) != 0)
		if (encap_range || (page_diff(begin, prev) > 1)) {
			sprintf(buff, "%s%s%s", begin->lpg, delim_r, end->lpg);
			encap_range = FALSE;
		} else
			sprintf(buff, "%s%s%s", begin->lpg, delim_n, end->lpg);
	 else
		strcpy(buff, begin->lpg);

	if (*prev_encap != NULL) {
		strcpy(tmp, buff);
		sprintf(buff, "%s%s%s%s%s", encap_p, prev_encap, encap_i, tmp, encap_s);
	}

	wrap_line(print);
}


static void
wrap_line(print)
	int		print;
{
	int		len;

	len = strlen(line) + strlen(buff) + ind_indent;
	if (print) {
		if (len > linemax) {
			PUTLN(line);
			PUT(indent_space);
			ind_indent = indent_length;
		} else
			PUT(line);
		PUT(buff);
	} else {
		if (len > linemax) {
			PUTLN(line);
			sprintf(line, "%s%s%s", indent_space, buff, delim_n);
			ind_indent = indent_length;
		} else {
			strcat(buff, delim_n);
			strcat(line, buff);
		}
	}
}


static void
insert_page()
{
	int		i = 0;
	int		j = 0;
	int		page = 0;

	if (even_odd >= 0) {
		/* find the rightmost digit */
		while (pageno[i++] != NULL);
		j = --i;
		/* find the leftmost digit */
		while (isdigit(pageno[--i]) && i > 0);
		if (! isdigit(pageno[i]))
			i++;
		/* convert page from literal to numeric */
		page = strtoint(&pageno[i]) + 1;
		/* check even-odd numbering */
		if (((even_odd == 1) && (page%2 == 0)) || ((even_odd == 2) && (page%2 == 1)))
				page++;
		pageno[j+1] = NULL;
		/* convert page back to literal */
		while (page >= 10) {
			pageno[j--] = TOASCII(page%10);
			page = page / 10;
		}
		pageno[j] = TOASCII(page);
		if (i < j) {
			while (pageno[j] != NULL)
				pageno[i++] = pageno[j++];
			pageno[i] = NULL;
		}
	}

	PUT(setpage_open);
	PUT(pageno);
	PUT(setpage_close);
	ind_lc += setpagelen;
}


