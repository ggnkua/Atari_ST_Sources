/*
 *	Prototypage des fonctions librairie object
 */

int obj_nb( register OBJECT *dial);
OBJECT *objc_dup( OBJECT *src);
void objc_free( OBJECT *cpy);
int obj_fd_flag( OBJETC *dial, int racine, int flag);
