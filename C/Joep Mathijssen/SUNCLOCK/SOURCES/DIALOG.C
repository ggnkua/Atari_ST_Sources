#include <tos.h>
#include <vdi.h>
#include <aes.h>

#include "gem.h"
#include "dialog.h"

/*-------------------------------------------------------------------------*/
/* DialogInit:                                                             */
/*-------------------------------------------------------------------------*/
OBJECT* DialogInit( id )
int id;
{
    OBJECT *addr;

    graf_mouse(2, 0);
    if (!rsrc_gaddr(R_TREE, id, &addr))
        GemAbort("Can't GADDR on .RCS");
    return addr;
}

/*-------------------------------------------------------------------------*/
/* DialogDo:                                                               */
/*-------------------------------------------------------------------------*/
int DialogDo( addr )
OBJECT *addr;
{
   int cx, cy, cw, ch, res;

   graf_mouse(0, 0);
   v_show_c(handle, 1);
   form_center(addr, &cx, &cy, &cw, &ch);
   form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
   objc_draw(addr, 0, MAX_DEPTH, 0, 0, 0, 0);
   res = form_do(addr, 0);
   form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
   objc_change(addr, (res&0x7f), 0,0,0,0,0, NORMAL, 0); 
						/* reset selected object */
   v_hide_c(handle);
   return (res);                                 /* return selected object */
}

/*-------------------------------------------------------------------------*/
/* DialogSetItem:                                                          */
/*-------------------------------------------------------------------------*/
void DialogSetItem( addr, field, value )
OBJECT *addr;
int    field;
bool   value;
{
   if (value)
       objc_change(addr, field, 0,0,0,0,0, SELECTED, 0);
   else
       objc_change(addr, field, 0,0,0,0,0, NORMAL, 0);
}

/*-------------------------------------------------------------------------*/
/* DialogGetItem:                                                          */
/*-------------------------------------------------------------------------*/
bool DialogGetItem( addr, field )
OBJECT *addr;
int    field;
{
    return (addr[field].ob_state & SELECTED);
}
