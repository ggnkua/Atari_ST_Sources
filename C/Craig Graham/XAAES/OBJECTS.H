#ifndef _OBJECTS_H_
#define _OBJECTS_H_

void display_object(OBJECT *tree, short object, short parent_x,short parent_y);
short draw_object_tree(OBJECT *tree, short object, short depth);
short object_abs_coords(OBJECT *tree, short object, short *obx, short *oby);
short find_object(OBJECT *tree, short object, short depth, short obx, short oby);
void draw_2d_box(short x, short y, short w, short h, short border_thick, short colour);
void fix_menu(OBJECT *root);

void set_clip(short x, short y, short w, short h);
void clear_clip(void);


#endif