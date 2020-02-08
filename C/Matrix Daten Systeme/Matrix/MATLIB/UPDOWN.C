#include <vdi.h>
#include <aes.h>
#include <string.h>

#include "global.h"

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\dialog.h"

# include "updown.h"


/*----------------------------------------- set_updown ----------*/
void set_updown ( UP_DOWN_VALUE *updown )
{
	o_printf ( updown->tree, updown->box+UPDOWN_VALUE,
								updown->format, *(updown->value) ) ;
}

/*----------------------------------------- disp_updown ----------*/
void disp_updown ( UP_DOWN_VALUE *updown )
{
	set_updown ( updown ) ;
	ObjectDraw ( updown->tree, updown->box ) ;
}

/*----------------------------------------- update_updown -------*/
void update_updown ( UP_DOWN_VALUE *updown, int val )
{
	*(updown->value) = val ;
	disp_updown ( updown ) ;
}

/*----------------------------------------- init_updown ----------*/
void init_updown ( UP_DOWN_VALUE *updown, OBJECT *t, int b, int *pv, char *f )
{
	updown->tree  = t ;
	updown->box   = b ;
	updown->value = pv ;
	strncpy ( updown->format, f, FORMmaxLen - 1 ) ;
	set_updown ( updown ) ;
}


/*----------------------------------------- click_updown ----------*/
void click_updown ( UP_DOWN_VALUE *updown, int clickobj )
{
	switch ( clickobj - updown->box )
	{
  case UPDOWN_DOWN :	*(updown->value) -= 1 ;
  						break ;
  case UPDOWN_VALUE :	*(updown->value)  = 0 ;
  						break ;
  case UPDOWN_UP :		*(updown->value) += 1 ;
  						break ;
	}
	disp_updown ( updown ) ;
	wait_at_least ( 150, 0 ) ;
}


