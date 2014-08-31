

#include <aes.h>
#include <tos.h>
#include <stdio.h>

#include "ind.h"
#include "window.h"
#include "module.h"


void  set_api_struct (void);
void cdecl  api_ext_objects   (int index, int rsc_tree);
void cdecl  api_set_trees     (int index, long array[], int global[], int len);
int  cdecl  api_open_window   (int index, int rsc_tree, int edit);
int  cdecl  api_close_window  (int index, int rsc_tree);
void cdecl  api_callback      (int index, int rsc_tree, CB_FUNC click, CB_FUNC key);
void cdecl  api_change_flags  (int index, int rsc, int obj, int what, int flags, int state);
void cdecl  api_do_popup      (int index, int pu, int *sel, int par, int obj, int len);
void cdecl  api_int_editing   (int index, int rsc, int what, int edit);
int  cdecl  api_top_window    (int index, int rsc);
void cdecl  api_rsc_size      (int index, int rsc, int width, int height, int parent);
void cdecl  api_free_string   (int index, int rsc, int obj, int par, char txt[], int len);
void cdecl  api_tedinfo       (int index, int rsc, int obj, int par, int w, char txt[], int len);
void cdecl  api_finish_user   (int index);
void cdecl  api_finish_server (int index);


extern ISM_PARA    parameter;
extern ISM_INTERN  *ism_data;
extern OBJECT      **my_tree_index;
extern USERBLK     my_user_block;

ISM_API  my_api;



void  set_api_struct()

{
   int  dummy;

   my_api.ext_objects   = api_ext_objects;
   my_api.set_trees     = api_set_trees;
   my_api.open_window   = api_open_window;
   my_api.close_window  = api_close_window;
   my_api.callback      = api_callback;
   my_api.change_flags  = api_change_flags;
   my_api.do_popup      = api_do_popup;
   my_api.editing       = api_int_editing;
   my_api.top_window    = api_top_window;
   my_api.rsc_size      = api_rsc_size;
   my_api.free_string   = api_free_string;
   my_api.tedinfo       = api_tedinfo;
   my_api.finish_user   = api_finish_user;
   my_api.finish_server = api_finish_server;

   parameter.server_api = &my_api;
   graf_handle (&parameter.char_width, &parameter.char_height, &dummy, &dummy);
 }


void cdecl  api_ext_objects (index, rsc_tree)

int  index, rsc_tree;

{
   ISM_INTERN  *ism = &ism_data[index];
   OBJECT      *tree;

   rsrc_gaddr (R_TREE, rsc_tree + ism->rsc_offset, &tree);

   do {
        if ((tree->ob_type & 0x7f00) && (tree->ob_state & (CROSSED | CHECKED))) {
             tree->ob_state &= ~ (CROSSED | CHECKED);
             tree->ob_type = G_USERDEF;
             tree->ob_spec.userblk = &my_user_block;
           }
      } while ((tree++->ob_flags & LASTOB) == 0);
 }


void cdecl  api_set_trees (index, tree_array, global, length)

int   index, global[], length;
long  tree_array[];

{
   ISM_INTERN  *ism = &ism_data[index];
   int         count;

   for (count = 0; count < ism->rsc_num; count++)
        my_tree_index[ism->rsc_offset + count] = (OBJECT *) tree_array[count];

   for (count = 0; count < length; count++)
        global[count] = _GemParBlk.global[count];
 }


int cdecl  api_open_window (index, rsc_tree, edit)

int  index, rsc_tree, edit;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   return (open_rsc_window (rsc_tree, edit, ism->ism_name, "ISM", START));
 }


int cdecl  api_close_window (index, rsc_tree)

int  index, rsc_tree;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   return (close_rsc_window (rsc_tree, -1));
 }


void cdecl  api_callback (index, rsc_tree, click_func, key_func)

int      index, rsc_tree;
CB_FUNC  click_func, key_func;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   set_callbacks (rsc_tree, click_func, key_func);
 }


void cdecl  api_change_flags  (index, rsc_tree, object, to_do, flags, state)

int  index, rsc_tree, object, to_do, flags, state;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   change_flags (rsc_tree, object, to_do, flags, state);
 }


void cdecl  api_do_popup (index, pu_tree, selection, par_tree, par_object, length)

int  index, pu_tree, *selection, par_tree, par_object, length;

{
   ISM_INTERN  *ism = &ism_data[index];

   pu_tree  += ism->rsc_offset;
   par_tree += ism->rsc_offset;

   pop_up (pu_tree, selection, par_tree, par_object, length);
 }


void cdecl  api_int_editing (index, rsc_tree, what, new_edit)

int  index, rsc_tree, what, new_edit;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   interupt_editing (rsc_tree, what, new_edit);
 }


int cdecl  api_top_window (index, rsc_tree)

int  index, rsc_tree;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   return (top_rsc_window (rsc_tree));
 }


void cdecl  api_rsc_size (index, rsc_tree, width, height, parent)

int  index, rsc_tree, width, height, parent;

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   change_rsc_size (rsc_tree, width, height, parent);
 }


void cdecl  api_free_string (index, rsc_tree, object, parent, text, length)

int   index, rsc_tree, object, parent, length;
char  text[];

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   change_freestring (rsc_tree, object, parent, text, length);
 }


void cdecl  api_tedinfo (index, rsc_tree, object, parent, which, text, length)

int   index, rsc_tree, object, parent, which, length;
char  text[];

{
   ISM_INTERN  *ism = &ism_data[index];

   rsc_tree += ism->rsc_offset;

   change_tedinfo (rsc_tree, object, parent, which, text, length);
 }


void cdecl  api_finish_user (index)

int  index;

{
   ism_data[index].action &= ~ACT_USER;
 }


void cdecl  api_finish_server (index)

int  index;

{
   ism_data[index].action &= ~ACT_SERVER;
 }
