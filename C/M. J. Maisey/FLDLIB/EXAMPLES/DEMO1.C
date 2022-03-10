/**************************************************************************
 *                                                                        *
 *                             FLDLIB DEMO 2                              *
 *                  Demonstrates multiple form management                 *
 *                                                                        *
 **************************************************************************/
 
#include <aes.h>
#include "fldlib.h"
#include "demo.h"


int main(void)  {
	short ret;
	OBJECT *form1;

	appl_init();
	
	if (!rsrc_load("DEMO.RSC"))  {
		form_alert(1,"[3][ Could not find | DEMO.RSC ][ Exit ]");
		appl_exit();
		return 0;
	}
	
	rsrc_gaddr(R_TREE, FORM1, &form1);
	form1[FM_DL2].ob_state |= DISABLED;
	
	ret = fld_do(form1, "FLDLIB Demo");
	
	switch (ret)  {
	case FM1_EXIT1:
		form_alert(1, "[1][ Exit 1 | selected ][ OK ]");
		break;
	case FM1_EXIT2:
		form_alert(1, "[1][ Exit 2 | selected ][ OK ]");
		break;
	}
	
	rsrc_free();
	appl_exit();
	
	return 0;
}