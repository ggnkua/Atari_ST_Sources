
/**** this is where I put the massive global ifdef switches ****/
#define ATARI
#define EDITOR


#ifndef NULL
#define NULL 0L
#endif

#ifndef TRUE
#define TRUE 1
#endif TRUE

#ifndef FALSE
#define FALSE 0
#endif FALSE

#ifndef WORD
#define WORD int
#endif WORD

#ifndef void
#define void int
#endif void

typedef int (*Vector)();

extern WORD debug;
extern int null_funct();

extern int *alloc();
extern int *clone_structure();
extern int *clone_zero();

extern char *clone_string();
extern char *cat_strings();
extern char *str_num();
extern char *lsprintf();

struct name_list
    {
    struct name_list *next;
    char *name;
    };
typedef struct name_list Name_list;

extern Name_list *add_name_to_list();
extern Name_list *remove_name_from_list();
extern Name_list *in_name_list();
extern Name_list *reverse_list();
extern void free_name_list();

typedef int * POINTER;
struct item_list
    {
    struct item_list *next;
    POINTER item;
    };
typedef struct item_list Item_list;

extern Item_list *add_item();
extern Item_list *or_in_item();
extern Item_list *in_item_list();

#define Alloc_a(type) (type *)alloc(sizeof(type) )
#define Alloc_z(type) (type *)clone_zero(sizeof(type) );
#define Clone_a(pt, type) (type *)clone_structure(pt, sizeof(type) )
#define Free_a(pt)	mfree(pt, sizeof(*(pt) ) )
#define Copy_a(s, d) copy_structure( s, d, sizeof(*(s)))
