#include "global.h"
#include "block.h"
#include "edit.h"
#include "memory.h"
#include "rsc.h"
#include "text.h"
#include "window.h"

#define	CMD_NONE	0
#define	CMD_KRIT	1
#define	CMD_SORT	2

static int		last_cmd = CMD_NONE,
					start_x = 0, end_x = 0;		/* Kriterium */
static long		start_z = 0, end_z = 0;		/* Bereich */
static ZEILEP	p1, p2;
static bool		sort_down = FALSE;			/* FLASE: a..z  TRUE: z..a */
static bool		sort_grkl = FALSE;			/* Groû vor Klein */

/*
 * Die nationalen Sonderzeichen werden auf die entsprechenden Vokale umgemappt
 * und somit direkt hinter sie sortiert.
 * Die Idee stammt aus dem Modul 'Strings' der MM2-Lib von Thomas Tempelmann.
*/
static char	sort_tab[] = 
{
	0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,
	0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,
	0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F,
	0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,
	0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,
	0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F,
	0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F,
	0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F,
	'C','u','e','a','a','a','a','c','e','e','e','i','i','i','A','A',
	'E','a','A','o','o','o','u','u','y','O','U',0x9B,0x9C,0x9D,'s',0x9F,
	'a','i','o','u','n','N','a','o',0xA8,0xA9,0xAA,0xAB,0xAC,0xAD,0xAE,0xAF,
	'a','o','O','o','o','O','A','A','O',0xB9,0xBA,0xBB,0xBC,0xBD,0xBE,0xBF,
	'i','I',0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,
	0xD0,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,0xDA,0xDB,0xDC,0xDD,0xDE,0xDF,
	0xE0,0xE1,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,
	0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF
};


static int qed_strncmp(char *s1, char *s2, int n, bool grkl)
{
	register char	c1, c2;
	register long	count;

	if (!s1)
		return s2 ? -1 : 0;
	
	if (!s2) 
		return 1;

	count = n;
	do 
	{
		c1 = *s1++; 
		c2 = *s2++; 
		if (!grkl)
		{
			c1 = nkc_toupper(c1);
			c2 = nkc_toupper(c2);
		}
	} 
	while (--count >= 0 && c1 && c1 == c2);

	if (count < 0)
		return(0);

	if (c1 == c2)
		return 0;
	else if (c1 == '\0')
		return -1;
	else if (c2 == '\0')
		return 1;
	else
		return (sort_tab[c1] - sort_tab[c2]);
}


static int laufcmp(ZEILEP l1, ZEILEP l2)
{
	int	n;
	
	if (start_x == 0 && end_x == 0)			/* ganze Zeilen vergleichen */
	{
		return qed_strncmp(TEXT(l1), TEXT(l2), l1->len, sort_grkl);
	}
	else												/* nur teilweise vergleichen */
	{
		/* Zeile kÅrzer als Kriterium-Start? */
		if (l2->len < start_x)
			return 1;

		/* Zeile kÅrzer als Kriterium-LÑnge? */
		if (l2->len < end_x)
			n = l2->len - start_x + 1;
		else
			n = end_x - start_x + 1;

		return qed_strncmp(TEXT(l1) + start_x, TEXT(l2) + start_x, n, sort_grkl);
	}
}


/*
 * Langsam, aber dafÅr optimal simpel: Insertion Sort.
*/
static void insert_sort(RINGP r, ZEILEP ins)
{
	ZEILEP	col, lauf;

	lauf = LAST(r);
	if (sort_down)
		while (!IS_FIRST(lauf) && (laufcmp(lauf, ins) < 0))
			VORG(lauf);
	else
		while (!IS_FIRST(lauf) && (laufcmp(lauf, ins) > 0))
			VORG(lauf);
	
	col = new_col(TEXT(ins), ins->len);
	col_insert(lauf, col);
	r->lines++;
}

static void do_sort(TEXTP t_ptr, RINGP r)
{
	ZEILEP	start, ende, lauf;

	start = get_line(&t_ptr->text, start_z);
	ende = get_line(&t_ptr->text, end_z);
	init_textring(r);
	lauf = start;
	while (lauf != ende)
	{
		insert_sort(r, lauf);
		NEXT(lauf);
	}
	/* erste, leere Zeile entfernen */
	col_delete(r, FIRST(r));

	/* leere Zeile am Ende anhÑngen */
	lauf = new_col("", 0);
	col_append(r, lauf);
}

static void clear_sort(void)
{
	last_cmd = CMD_NONE;
	start_z = 0;
	end_z = 0;
	start_x = 0;
	end_x = 0;
}

void sort_block(TEXTP t_ptr)
{
	/* halbe Zeile markiert -> aufrunden zur nÑchsten */
	if (!(last_cmd == CMD_KRIT) && (t_ptr->x2 > 0) && !(IS_LAST(t_ptr->p2)))
	{
		t_ptr->z2++;
		t_ptr->p2 = t_ptr->p2->nachf;
	}

	if ((t_ptr->z2 > t_ptr->z1 + 1) || (last_cmd == CMD_KRIT))
	{
		RING	r;
		int	antw;
		char	str[26];

		if (last_cmd == CMD_KRIT)
		{
			clear_info(t_ptr);
			start_x = t_ptr->x1;
			end_x = t_ptr->x2 - 1;
		}
		else
		{
			start_z = t_ptr->z1;
			end_z = t_ptr->z2;
			p1 = t_ptr->p1;
			p2 = t_ptr->p2;
		}
		
		set_state(sort, BSUP, SELECTED, !sort_down);
		set_state(sort, BSDOWN, SELECTED, sort_down);
		set_state(sort, BSGRKL, SELECTED, sort_grkl);

		sprintf(str, rsc_string(SZEILESTR), start_z, end_z);
		str[24] = EOS;
		set_string(sort, BSZEILEN, str);
		sprintf(str, rsc_string(SSPALTSTR), start_x, end_x);
		str[24] = EOS;
		set_string(sort, BSSPALTEN, str);
			
		antw = simple_mdial(sort, 0) & 0x7fff;
		switch (antw)
		{
			case BSKRIT :
				last_cmd = CMD_KRIT;
				set_info(t_ptr, rsc_string(SKRITSTR));
				make_chg(t_ptr->link, POS_CHANGE, 0);
				break;
			
			case BSORT :
				last_cmd = CMD_SORT;
				break;
			
			case BSABBRUCH :
				clear_sort();
				break;
		}
		set_state(sort, antw, SELECTED, FALSE);
		if (last_cmd == CMD_SORT)
		{
			sort_down = get_state(sort, BSDOWN, SELECTED);
			sort_grkl = get_state(sort, BSGRKL, SELECTED);

			do_sort(t_ptr, &r);
			
			/* ursprÅnglichen Block wieder herstellen und ersetzen */
			t_ptr->z1 = start_z;
			t_ptr->z2 = end_z;
			t_ptr->x1 = 0;
			t_ptr->x2 = 0;
			t_ptr->p1 = p1;
			t_ptr->p2 = p2;
			blk_paste(t_ptr, &r);
			kill_textring(&r);
			clear_sort();
		}
		restore_edit();
	}
	else
		note(1, 0, SORTERR);
}


/* --------------------------------------------------------------------------- */
#if 0
static int line_cmp(char *z1, int l1, char *z2, int l2)
{
	int 	l = -1;
	bool	quit = FALSE;
	
	if (l1 != l2)
		l = l1;
	else
	{
		l = 0;
		while (!quit)
		{
			if (l > l1)
			{
				l = l1;
				quit = TRUE;
			}
			if (l > l2)
			{
				l = l2;
				quit = TRUE;
			}
			if (!quit && z1[l] != z2[l])
				quit = TRUE;
			if (!quit)
				l++;
		}
	}
	/* normaler Durchlauf, kein Unterschied */
	if (l == l1 && l == l2)
		l = -1;
	return l;
}

static void mark_diff(TEXTP t_ptr, int z, int s)
{
	t_ptr->xpos = s;
	if (z >= t_ptr->text.lines - 1)
		t_ptr->ypos = t_ptr->text.lines - 2;
	else	
		t_ptr->ypos = z;
	
	blk_mark(t_ptr, 0);
	if (IS_LAST(t_ptr->cursor_line))
		t_ptr->xpos = t_ptr->cursor_line->len;
	else
	{
		t_ptr->xpos = 0;
		NEXT(t_ptr->cursor_line);
		t_ptr->ypos++;
	}
	blk_mark(t_ptr, 1);
	restore_edit();
}

void compare(TEXTP t1, TEXTP t2)
{
	if (t1 && t2)
	{
		ZEILEP	lauf1, lauf2;
		bool		quit = FALSE;
		int		l, z1, z2;

		blk_demark(t1);
		blk_demark(t2);
		restore_edit();
		lauf1 = FIRST(&t1->text);
		lauf2 = FIRST(&t2->text);
		quit = (!lauf1 || !lauf2);
		z1 = 0;
		z2 = 0;
		while (!quit)
		{
			l = line_cmp(TEXT(lauf1), lauf1->len, TEXT(lauf2), lauf2->len);
			if (l != -1)
			{
				debug("Zeile: %d, %d\n", z, l);
				t1->cursor_line = lauf1;
				mark_diff(t1, z1, l);
				t2->cursor_line = lauf2;
				mark_diff(t2, z2, l);
				pos_korr(get_window(t1->link), t1);
				pos_korr(get_window(t2->link), t2);
quit = (do_walert(1, 2, "[1][Unterschied gefunden!][Weiter|Ende]", " qed ") == 2);
			}
			NEXT(lauf1);
			z1++;
			NEXT(lauf2);
			z2++;
			if (IS_TAIL(lauf1) || IS_TAIL(lauf2))
			{
				Bconout(2, 7);
				quit = TRUE;
			}
		}
	}
}

#endif
