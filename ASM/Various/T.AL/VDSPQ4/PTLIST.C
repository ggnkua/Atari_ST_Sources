/*
	ptlist.c

	list management
*/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>

#include "vector.h"
#include "ptlist.h"

HSEGLIST *new_hseg(void)
{
	HSEGLIST *new= (HSEGLIST *)malloc(sizeof(HSEGLIST));
	
	if(!new)
		alert("Not enough memory");
	
	new->next= NULL;
	new->beg= 0;
	new->end= 0;
	
	return new;
}

HSEGLIST *create_hseg(int beg, int end, EDLIST *edge)
{
	HSEGLIST *new= (HSEGLIST *)malloc(sizeof(HSEGLIST));
	
	if(!new)
		alert("Not enough memory");
	
	new->next= NULL;
	new->beg= beg;
	new->end= end;
	new->edge= edge;
	
	return new;
}

void free_hseg(HSEGLIST *list)
{
	HSEGLIST *tmp;

	while(list)
	{
		tmp= list->next;
		free(list);
		list= tmp;
	}
}

HSEGLIST *add_hseg(HSEGLIST **list, HSEGLIST *new)
{
	HSEGLIST *hseg= *list,
	         *old= NULL;
	
	while(hseg)
	{
		old= hseg;
		hseg= hseg->next;
	}
	
	if(old)
		old->next= new;
	else
		*list= new;
	
	return new;
}

PTLIST *new_pt(void)
{
	PTLIST *new= (PTLIST *)malloc(sizeof(PTLIST));
	
	if(!new)
		alert("Not enough memory");
	
	new->next= NULL;
	new->x= 0;
	new->y= 0;
	new->label= 0;
	
	return new;
}

PTLIST *create_pt(int x, int y, int label)
{
	PTLIST *new= (PTLIST *)malloc(sizeof(PTLIST));
	
	if(!new)
		alert("Not enough memory");
	
	new->next= NULL;
	new->x= x;
	new->y= y;
	new->label= label;

	return new;
}

void free_pt(PTLIST *list)
{
	PTLIST *tmp;

	while(list)
	{
		tmp= list->next;
		free(list);
		list= tmp;
	}
}

PTLIST *add_sort_pt(PTLIST **list, PTLIST *point)
{
	PTLIST *pt= *list,
	       *old= NULL;
	
	while(pt && pt->y < point->y)	/* insertion triee sur y */
	{
		old= pt;
		pt= pt->next;
	}
		
	while(pt && pt->y == point->y 
	         && pt->x < point->x) 	/* insertion triee sur x */
	{
		old= pt;
		pt= pt->next;
	}
	
	if(old)
	{
		point->next= old->next;
		old->next= point;
	}
	else
		*list= point;
	
	return point;
}

PTLIST *add_pt(PTLIST **list, PTLIST *point)
{
	point->next= *list;
	*list= point;

	return point;
}

PTLIST *add_ptlist(PTLIST **list, PTLIST *point)
{
	PTLIST *pt= point;

	if(!pt) return NULL;	
	while(pt->next)
		pt= pt->next;

	pt->next= *list;
	*list= point;
	
	return point;
}

PTLIST *hseg_2_pt(HSEGLIST *hseg, int y, unsigned int label)
{
	int x;
	PTLIST *new= NULL;
	
	for(x= hseg->beg; x <= hseg->end; x++)
		add_pt(&new, create_pt(x, y, label));
	
	return new;
}

EDLIST *new_ed(void)
{
	EDLIST *new= (EDLIST *)malloc(sizeof(EDLIST));
	
	if(!new)
		alert("Not enough memory");
	
	new->next= NULL;
	new->points= NULL;
	new->label= 0;
	
	return new;
}

EDLIST *create_ed(PTLIST *points, int label)
{
	EDLIST *new= (EDLIST *)malloc(sizeof(EDLIST));
	
	if(!new)
		alert("Not enough memory");
	
	new->next= NULL;
	new->points= points;
	new->label= label;
	
	return new;
}

void free_ed(EDLIST *list)
{
	EDLIST *tmp;

	while(list)
	{
		tmp= list->next;
		free_pt(list->points);
		free(list);
		list= tmp;
	}
}

EDLIST *add_ed(EDLIST **list, EDLIST *new)
{
/*
	EDLIST *edge= *list,
	       *old= NULL;
	
	while(edge)
	{
		old= edge;
		edge= edge->next;
	}
	
	if(old)
		old->next= new;
	else
		*list= new;
*/

	new->next= *list;
	*list= new;
	
	return new;
}

/*
EDLIST *ADD_ED(EDLIST **list, EDLIST *new)
{
	while(*list) list= &(*list)->next;
	new->next= *list;
	*list= new;
	
	return new;
}
*/


void disp_chain(EDLIST *list)
{
	unsigned int nb= 0, empty= 0;
	UWORD color;
	long c;
	PTLIST *pt;
	UWORD *screen;
	
	screen= Physbase();
	for(c= 320L*240L; c; c--)
		*screen++= 0;
	
	screen= Physbase();

	while(list)
	{
		pt= list->points;
		color= 16 + 32*list->label;
		if(!pt) empty++;
		while(pt)
		{
			screen[pt->x + (long)pt->y * 320L]= color;
			pt= pt->next;
		}

		list= list->next;
		nb++;
	}
	
	printf("%d chaines, %d chaines vides\n", nb, empty);
}

void disp_edge(PTLIST *old, PTLIST *add)
{
	PTLIST *pt1= old, *pt2= add;
	UWORD *screen= Physbase();

	while(pt1)
	{
		screen[pt1->x + (long)pt1->y * 320L]= (UWORD) 0x0fe0;
		pt1= pt1->next;
	}

	while(pt2)
	{
		screen[pt2->x + (long)pt2->y * 320L]= (UWORD) 0xf800;
		pt2= pt2->next;
	}
	
	getch();

	pt1= old; pt2= add;
	while(pt1)
	{
		screen[pt1->x + (long)pt1->y * 320L]= (UWORD) 0xffff;
		pt1= pt1->next;
	}

	while(pt2)
	{
		screen[pt2->x + (long)pt2->y * 320L]= (UWORD) 0xffff;
		pt2= pt2->next;
	}
}


void disp_hseg(HSEGLIST *seg, int y)
{
	int x;
	UWORD *screen;

	screen= Physbase();
	for(x= seg->beg, screen+= x + y*320L; x <= seg->end; x++)
		*screen++= (UWORD) 0x001f;
	
	getch();
	
	screen= Physbase();
	for(x= seg->beg, screen+= x + y*320L; x <= seg->end; x++)
	*screen++= (UWORD) 0xffff;

}

void edge_equiv(HSEGLIST *new, HSEGLIST *old, HSEGLIST *oldhseg, HSEGLIST *hseg)
{
	HSEGLIST *aux;
	EDLIST *new_edge= new->edge,
	       *old_edge= old->edge;
	
	aux= oldhseg;
	while(aux)
	{
		if(aux->edge==old_edge)
			aux->edge= new_edge;
		aux= aux->next;
	}

	aux= hseg;
	while(aux && aux!=new)
	{
		if(aux->edge==old_edge)
			aux->edge= new_edge;
		aux= aux->next;
	}
}
