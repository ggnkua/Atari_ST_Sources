#include <minimum.h>
#include <gemfast.h>
#include <stack.h>

extern int _isacc;

int appl_id, menu_id;
char *menu_entry = "  Hello";
int msg_buf[8];
char *form_string = "[1][Das erste C-Accessory][JUHU]";

void hello()
{
     form_alert(1, form_string);
}

main()
{
     new_stack();
     appl_id = appl_init();
     if(_isacc)
     {    menu_id = menu_register(appl_id,menu_entry);

          while (1)
          {    evnt_mesag(msg_buf);
               if (msg_buf[0]==AC_OPEN && msg_buf[4]==menu_id)
                    hello();
          }
     }
     else
     {    hello();
     }

     appl_exit();
     old_stack();
}
