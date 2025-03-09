/**************************************/
/*  MOVEDIAL-Library fÅr Dialogboxen  */
/*------------------------------------*/
/*  Include-File: MOVELIB.H           */
/*------------------------------------*/
/*  by M.Baldauf 				              */
/*  (c) 1992 MAXON Computer GmbH      */
/**************************************/ 

#include <aes.h>
#include <vdi.h>

int gem_init(void);

void gem_exit(int handle);

void vor_dial(OBJECT *dialbox, int dialtype);

void draw_dial(OBJECT *dialbox, int dialtype);

void nach_dial(OBJECT *dialbox, int dialtype);

void movedial(OBJECT *dialbox, int dialtype);

int do_dial(OBJECT *tree);

int do_movedial(OBJECT *tree, int DRAGGER);

int do_popup(OBJECT *tree);

