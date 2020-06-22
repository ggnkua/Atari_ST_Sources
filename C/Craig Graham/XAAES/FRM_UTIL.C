/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <stdio.h>
#include <stdlib.h>
#include "XA_TYPES.H"
#include "XA_DEFS.H"
#include "K_DEFS.H"

/*
	Create a copy of an object tree
	- intended for using the form templates in SYSTEM.RSC (we cann't use them
	directly as this would cause problems when (for example) two apps do a form_alert()
	at the same time.
*/
OBJECT *CloneForm(OBJECT *form)
{
	short num_objs,o;
	OBJECT *new_form;
	
	for(num_objs=0; !(form[num_objs].ob_flags&LASTOB); num_objs++);
	
	num_objs++;

	new_form=(OBJECT*)malloc(sizeof(OBJECT)*num_objs);
	
	for(o=0; o<num_objs; o++)
		new_form[o]=form[o];
	
	return new_form;
}

/*
	Free up a copy of a form template
*/
void DeleteClone(OBJECT *form)
{
	free((void*)form);
}
