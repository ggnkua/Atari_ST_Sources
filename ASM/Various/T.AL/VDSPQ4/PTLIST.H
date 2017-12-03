/*
	ptlist.h
	list management	
*/

#ifndef _PTLIST_H
#define _PTLIST_H

typedef struct _ptlist
{
	int x;
	int y;
	unsigned int label;
	struct _ptlist *next;
} PTLIST;

typedef struct _edlist
{
	unsigned int label;
	PTLIST *points;
	struct _edlist *next;
} EDLIST;

typedef struct _hseglist
{
	int beg;
	int end;
	EDLIST *edge;
	struct _hseglist *next;
} HSEGLIST;
 
extern HSEGLIST *new_hseg(void);
extern HSEGLIST *create_hseg(int beg, int end, EDLIST *edge);
extern void free_hseg(HSEGLIST *list);
extern HSEGLIST *add_hseg(HSEGLIST **list, HSEGLIST *hseg);

extern PTLIST *new_pt(void);
extern PTLIST *create_pt(int x, int y, int label);
extern void free_pt(PTLIST *list);
extern PTLIST *add_pt(PTLIST **list, PTLIST *point);
extern PTLIST *add_sort_pt(PTLIST **list, PTLIST *point);
extern PTLIST *add_ptlist(PTLIST **dlist, PTLIST *list);

extern PTLIST *hseg_2_pt(HSEGLIST *hseg, int y, unsigned int label);

extern EDLIST *new_ed(void);
extern EDLIST *create_ed(PTLIST *ptlist, int label);
extern void free_ed(EDLIST *list);
extern EDLIST *add_ed(EDLIST **list, EDLIST *new);

extern void edge_equiv(HSEGLIST *new, HSEGLIST *old, HSEGLIST *oldhseg, HSEGLIST *hseg);

extern void disp_chain(EDLIST *list);
extern void disp_edge(PTLIST *old, PTLIST *add);
extern void disp_hseg(HSEGLIST *seg, int y);



#endif
