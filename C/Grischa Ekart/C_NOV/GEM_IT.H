/*           GEM_IT.H V1.0, 9.9.1990            */
/*       Copyright (c) by Grischa Ekart         */

#include <vdi.h>
#include <aes.h>

#undef   NULL
#undef   TRUE
#undef   FALSE

#define  NULL  ((void *)0L)
#define  TRUE  1
#define  FALSE 0

/*                   Structures                 */

typedef  struct menu
{
   int   ob_index;
   int   (*do_menu)(void);
} MENU;

/*                External Definitions          */

extern   char *err_box[];

/*                Function Prototypes           */

OBJECT   *gem_init(const char *lr_name);
void     gem_exit(int term_code);
void     show_mouse(void);
void     hide_mouse(void);
void     desk_init(int ob_index);
void     menu_init(int ob_index, MENU *menu_tab);
void     menu_exit(void);
int      menu_event(int title, int entry);
void     menu_title(int title, GRECT *rect);
int      form_value(int def_button, char *string,
            ...);

/*                Error Enumerations            */

enum err_msg
{
   NO_ERR, NO_APPL, NO_RSRC
};
