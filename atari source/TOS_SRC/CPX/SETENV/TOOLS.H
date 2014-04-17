


typedef struct _node
{
  char estring[ 128 ];
  char actual[128];
  struct _node *next;
  int  used_flag;
} NODE, *NODE_PTR;


#define ACTUAL(ptr)    ptr->actual
#define ESTRING( ptr ) ptr->estring
#define NEXT( ptr )    ptr->next
#define USED( ptr )    ptr->used_flag


/* DEFINES */
#define MAX_SLOTS   7
#define MAX_NODES   50
#define TEXT_LENGTH 27
#define EDIT_LENGTH 40
#define UNDO	    0x6100
