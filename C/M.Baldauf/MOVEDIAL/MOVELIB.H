/**************************************/
/*  MOVEDIAL-Library fÅr Dialogboxen  */
/*  written in Turbo C 2.0            */
/*------------------------------------*/
/*  Include-File: MOVELIB.H           */
/*------------------------------------*/
/*  by M.Baldauf 6/1990               */
/*  (c) by MAB                        */
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

