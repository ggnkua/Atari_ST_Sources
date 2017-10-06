/* Header file for use with programs that use the popup menu system
   (c) 1991 Andrew Brown, copying and distribution are subject to the
   conditions set out in the main manual */


#define MSELECTABLE 0x1L      /* These flags are OR'ed together in the */
#define MSELECTED   0x2L      /* 'flags' element of the MITEM structure */
#define MCHECKED    0x4L
#define MDISABLED   0x8L
#define MCENTRE     0x40L


typedef struct mnu_element_st   /* The menu item structure */
{
  int next;                 /* next object number (-1=last_ob) */
  int root;                 /* root object number */
  int sub;                  /* sub menu root number (-1=no sub) */
  int parent;               /* parent's root number */
  int x,y,w,h;              /* only relevant to root object */
  unsigned long flags;      /* flags for this object */
  char *backdrop;           /* backdrop storage space (malloc'ed) */
  char *text;               /* item string */
  char *help;               /* help string */
} MITEM;


void PopupInit(int,int,int);
void PopupRegister(char *);
int PopupMenu(MITEM *,int,int);

