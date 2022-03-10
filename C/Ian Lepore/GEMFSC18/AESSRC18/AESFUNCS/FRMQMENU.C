/*************************************************************************
 * FRMQMENU.C - The frm_qmenu() routine.
 *************************************************************************/

#include "gemfast.h"

int frm_qmenu(title, strings)
	char *title;
	char *strings;
{
  return frm_nlmenu(FRM_NORMAL, title, strings);
}
