/**************************************************************************
 *                                                                        *
 *                             FLDLIB DEMO 2                              *
 *                  Demonstrates multiple form management                 *
 *                                                                        *
 **************************************************************************/

#include <stdlib.h>
#include <aes.h>
#include "fldlib.h"
#include "demo.h"

OBJECT *form1, *form2;
short form1handle, form2handle;

void object_handle(short, short);
int  main(void);

void object_handle(short object, short type)  {
	switch(type)  {
	case FORM1:

		switch (object)  {
		case FM1_EXIT1:
			form_alert(1, "[1][ Exit 1 | selected ][ OK ]");
			fld_exit();
			rsrc_free();
			appl_exit();
			exit(0);
			break;
		case FM1_EXIT2:
			form_alert(1, "[1][ Exit 2 | selected ][ OK ]");
			fld_exit();
			rsrc_free();
			appl_exit();
			exit(0);
			break;
		case FM_DL2:
			form2handle = fld_open(form2, FLDC_MOUSE, "FLDLIB Demo", FORM2);
			form1[FM_DL2].ob_state &= ~SELECTED;
			fld_draw(form1handle, FM_DL2, 0);
			break;
		}

		break;
	case FORM2:

		switch (object)  {
		case FM2_OK:
			fld_close(form2handle);
			form2[FM2_OK].ob_state &= ~SELECTED;
			break;
		}

		break;
	}
}


int main(void)  {
	short ret, type, handle;

	appl_init();

	if (!rsrc_load("DEMO.RSC"))  {
		form_alert(1,"[3][ Could not find | DEMO.RSC ][ Exit ]");
		appl_exit();
		return 0;
	}

	rsrc_gaddr(R_TREE, FORM1, &form1);
	rsrc_gaddr(R_TREE, FORM2, &form2);

	form1handle = fld_open(form1, FLDC_SCREEN, "FLDLIB Demo", FORM1);

	graf_mouse(ARROW, NULL);

	while (1)  {
		if ( (ret = fld_domulti(&type, &handle)) != -1)
			object_handle(ret, type);
	}

	return 0;
}