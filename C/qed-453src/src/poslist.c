/*
 * poslist.c
 * Liste, die Dateinamen mit Cursorposition speichert.
*/
#include <support.h>

#include "global.h"
#include "comm.h"
#include "edit.h"
#include "find.h"
#include "icon.h"
#include "projekt.h"
#include "window.h"
#include "poslist.h"


void insert_poslist(POSENTRY **list, char *n1, int x, long y)
{
	POSENTRY	*new, *p;
	PATH		name;
	
	if (strchr(n1, '/') != NULL)				/* UNIX-Pfad -> nach TOS wandeln */
		unx2dos(n1, name);
	else
		strcpy(name, n1);

	p = find_poslist(*list, name, NULL, NULL);
	if (p != NULL)					/* schon 'drin -> nur Position updaten */
	{
		p->zeile = y;
		p->spalte = x;
/*
debug("insert_poslist: %s, x= %d, y= %ld: update\n", p->filename, p->spalte, p->zeile);
*/
	}
	else								/* neuer Eintrag */
	{	
		new = (POSENTRY*) malloc(sizeof(POSENTRY));
		new->next = NULL;
		if (*list == NULL)
			*list = new;
		else
		{
			p = *list;
			while (p->next != NULL)
				p = p->next;
			p->next = new;
		}
		new->next = NULL;
		strcpy(new->filename, name);
		make_normalpath(new->filename);
		new->spalte = x;
		new->zeile = y;
/*
debug("insert_poslist: %s, x= %d, y= %ld: new\n", new->filename, new->spalte, new->zeile);
*/
	}
}


void open_poslist(POSENTRY *list)
{
	int		icon;
	POSENTRY	*p;
	
	p = list;
	while (p != NULL)
	{
/*
debug("open_poslist: %s, x= %d, y= %ld\n", p->filename, p->spalte, p->zeile);
*/
		if (!shift_pressed() && filematch(p->filename, "*.QPJ", -1))
			icon = load_projekt(p->filename);
		else
		{
			icon = load_edit(p->filename, FALSE);
			if (icon >= 0)
			{
				desire_x = 0;
				if (p->spalte > 0)
					desire_x = p->spalte;
				desire_y = 0;
				if (p->zeile > 0)
					desire_y = p->zeile;
				if (desire_x || desire_y)
					icon_edit(icon, DO_GOTO);
			}
		}
		if (icon > 0)
			send_dhst(p->filename);
		p = p->next;
	}
}


void delete_poslist(POSENTRY **list)
{
	POSENTRY	*p1, *p2;
	
	p1 = *list;
	while (p1 != NULL)
	{
		p2 = p1->next;
		free(p1);
		p1 = p2;
	}
	*list = NULL;
}


POSENTRY *find_poslist(POSENTRY *list, char *name, int *x, long *y)
{
	POSENTRY	*p;

	p = list;
	while ((p != NULL) && (strcmp(p->filename, name) != 0))
		p = p->next;
	if (p)
	{
		if (x != NULL)
			*x = p->spalte;
		if (y != NULL)
			*y = p->zeile;
	}
	return p;
}
