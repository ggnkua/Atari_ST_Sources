/*
 * Listenverwaltung fr die Fenster.
 *
 * Es gibt zwei verschiedene Listen:
 *		used_list: - enth„lt alle offenen Fenster
 *					  - erstes Element ist das Top-Window
 *					  - einfach verkettet
 *
 *		free_list: - enth„lt die unbenutzten Fenster, deren Gr”že bekannt ist
 *					  - einfach verkettet mit Reihenfolge des w->init
 *
 * Wird ein neues Fenster ben”tigt, wird in der free_list nach dem mit dem
 * kleinsten init der entsprechenden Klasse gesucht. Wird keins gefunden,
 * wird in der free_list ein neues Element angeh„ngt.
 * Das Fenster aus der free_list wird dann in die used_list umgeh„ngt und in
 * der free_list gel”scht.
 * Wird ein Fenster nicht mehr ben”tigt, wird es in used_list gel”scht und in
 * free_list entsprechend seinem init einsortiert.
 * Das erste Fenster einer Klasse steht in free_list immer ganz vorne.
*/
#include "global.h"
#include "qed.h"
#include "winlist.h"

WINDOWP	used_list;

static WINDOWP	free_list;
static int		init_count;

#if 0
void dump_winlist(void)
{
	WINDOWP	p;

	p = used_list;
	Debug("used_list:\n");
	while (p)
	{
		Debug(" class= %d, init= %d, title= %s\n", p->class, p->init, p->title);
		p = p->next;
	}

	p = free_list;
	Debug("free_list:\n");
	while (p)
	{
		Debug(" class= %d, init= %d, title= %s\n", p->class, p->init, p->title);
		p = p->next;
	}
	Debug("\n");
}
#endif

/*
 * free_list: Neues Element in die Liste einh„ngen.
*/
static WINDOWP new_list_elem(int class)
{
	WINDOWP	new, p;

	new = (WINDOWP)calloc(1, sizeof(WINDOW));
	if (new != NULL)
	{
		new->next = NULL;

		if (free_list == NULL)				/* Erstes Element -> Wurzel */
			free_list = new;
		else
		{
			p = free_list;

			while (p->next != NULL)			/* Am Ende der Liste anh„ngen */
				p = p->next;
			p->next = new;
		}
		new->class = class;
		new->handle = UNUSED;
		new->init = init_count;
		init_count++;
		return new;
	}
	else
		note(1, 0, NOMEMORY);
	return NULL;
}

#if 0
/*
 * Ein Element l”schen.
*/
static void del_list_elem(WINDOWP w)
{
	if (w == win_list)					/* Wurzel? */
		win_list = win_list->next;
	else
	{
		WINDOWP	p = win_list;

		while (p->next != w)				/* Vorg„nger suchen */
			p = p->next;
		p->next = w->next;				/* und Aush„ngen */
	}
	free(w);
	w = NULL;
}

/*
 * Gesamte Listen l”schen
*/
static void kill_list(void)
{
	while (win_list != NULL)
		del_list_elem(win_list);
}
#endif

/*
 * Fenster aus einer Liste aush„nge, aber nicht l”schen!
*/
static void unlink_elem(WINDOWP *list, WINDOWP w)
{
	if (w == *list)						/* Wurzel? */
		*list = (*list)->next;
	else
	{
		WINDOWP	p = *list;

		while (p->next != w)				/* Vorg„nger suchen */
			p = p->next;
		p->next = w->next;				/* und Aush„ngen */
	}
}

/*
 * Fenster aus der free_list an den Anfang der used_list.
*/
static void free_to_used(WINDOWP w)
{
	unlink_elem(&free_list, w);

	if (used_list == NULL)
	{
		used_list = w;
		w->next = NULL;
	}
	else
	{
		w->next = used_list;
		used_list = w;
	}
}

/*
 * Fenster aus der used_list in die free_list einsortieren.
*/
static void used_to_free(WINDOWP w)
{
	WINDOWP	p, last;
	
	unlink_elem(&used_list, w);

	p = free_list;
	if (free_list == NULL)					/* kein Element */
	{
		free_list = w;
		w->next = NULL;
	}
	else if (w->init < free_list->init)	/* vor dem ersten einfgen */
	{
		w->next = free_list;
		free_list = w;
	}
	else
	{
		p = free_list;
		last = free_list;
		while ((p) && (p->init < w->init))
		{
			last = p;
			p = p->next;
		}
		w->next = last->next;
		last->next = w;
	}
}

/*
 * used_list: Listenelement ganz an Anfang bzw. Ende
*/
void move_to_top(WINDOWP w)
{
	WINDOWP p;

	if (used_list == NULL)
		return;

	if (w == used_list) 						/* ist schon oben */
		return;

	p = used_list;
	while (p->next != w)						/* Vorg„nger suchen */
		p = p->next;
	p->next = w->next;
	w->next = used_list;
	used_list = w;
}

void move_to_end (WINDOWP w)
{
	WINDOWP p;

	if (used_list == NULL)
		return;

	if (w->next == NULL)						/* ist schon letzter */
		return;

	if (w == used_list)						/* ist erster */
		used_list = w->next;
	else											/* mitten drin */
	{
		p = used_list;
		while (p->next != w)					/* Vorg„nger suchen */
			p = p->next;
		p->next = w->next;
	}
	p = used_list;
	while (p->next != NULL)					/* letzten suchen */
		p = p->next;
	p->next = w;
	w->next = NULL;
}

/*
 * Abmessungen eines Fensters aus der Konfig in die Liste einh„ngen
*/
void add_winlist(int class, GRECT *r)
{
	WINDOWP	w;

	w = new_list_elem(class);
	if (w)
		w->work = *r;
}

/*
 * Fensterparameter sichern.
*/
static WINDOWP search_init(WINDOWP list, int init)
{
	WINDOWP	p = list;
	
	while (p)
	{
		if (p->init == init)
			break;
		p = p->next;
	}	
	return p;
}

void save_winlist(FILE *fd)
{
	int		i;
	WINDOWP	p;
		
	i = 0;
	while (i < init_count)
	{
		p = search_init(used_list, i);
		if (!p)
			p = search_init(free_list, i);
		if (p)
			fprintf(fd, "Window=%d %d %d %d %d\n", p->class,  
							p->work.g_x, p->work.g_y, p->work.g_w, p->work.g_h);
		i++;
	}
}

/*
 * Freies Fenster einer Klasse suchen, ggf. neu anlegen.
*/
WINDOWP get_new_window(int class)
{
	WINDOWP	p;
	
	p = free_list;
	while (p)								/* zun„chst unbenutzes suchen */
	{
		if ((p->handle == UNUSED) && (p->class == class))
			break;
		p = p->next;
	}
	if (p == NULL)							/* kein unbenutztes gefunden */
		p = new_list_elem(class);
	free_to_used(p);
	return p;
}

/*
 * Fenster freigeben.
*/
void free_window(WINDOWP w)
{
	used_to_free(w);
	w->handle = UNUSED;
}


void init_winlist(void)
{
	used_list = NULL;
	free_list = NULL;
	init_count = 0;
}

void term_winlist(void)
{
}
