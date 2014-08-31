

#include <aes.h>
#include <portab.h>
#include <stdio.h>

#include "module.h"

#include "sample.h"
#include "sample.rsh"


ISM_SPECS * cdecl  module_init (ISM_PARA *data);
void  cdecl module_term (ISM_PARA *data),  cdecl module_user (ISM_PARA *data);
void  cdecl module_server (ISM_PARA *data),  convert_resource (void);


extern ISM_SPECS  my_specs;

int       ism_index;
ISM_API   *api;
ISM_PARA  my_parameters;



ISM_SPECS * cdecl  module_init (module_data)

ISM_PARA  *module_data;

{
   OBJECT  *tree;

   my_parameters = *module_data;
   convert_resource();

   my_specs.ism_num_trees = NUM_TREE;

   tree = (OBJECT *) rs_trindex[ICON];
   my_specs.ism_icon = tree[MY_ICON].ob_spec.iconblk;

   return (&my_specs);
 }


void cdecl  module_term (module_data)

ISM_PARA  *module_data;

{
 }


void cdecl  module_user (module_data)

ISM_PARA  *module_data;

{
   api         = module_data->server_api;
   ism_index   = module_data->index;

   set_trees (rs_trindex, _GemParBlk.global, 80);

   form_alert (1, "[1][ |  Nothin' here, instead try the   | |     Sample Server !][ Ok ]");

   finish_user();
 }


void cdecl  module_server (module_data)

ISM_PARA  *module_data;

{
   api       = module_data->server_api;
   ism_index = module_data->index;

   finish_server();
 }


void  convert_resource()

{
   OBJECT   *obj;
   TEDINFO  *ted;
   ICONBLK  *icn;
   int      count;

   for (count = 0; count < NUM_TREE; count++)
        rs_trindex[count] = (long) &rs_object[rs_trindex[count]];

   for (count = 0; count < NUM_OBS; count++) {
        obj = &rs_object[count];
        switch (obj->ob_type) {
           case G_TEXT :
           case G_BOXTEXT :
           case G_FTEXT :
           case G_FBOXTEXT :
             obj->ob_spec.tedinfo = &rs_tedinfo[obj->ob_spec.index];
             break;
           case G_IMAGE :
             obj->ob_spec.bitblk  = &rs_bitblk[obj->ob_spec.index];
             break;
           case G_ICON :
             obj->ob_spec.iconblk = &rs_iconblk[obj->ob_spec.index];
             break;
           case G_USERDEF :
             obj->ob_spec.userblk = (USERBLK *) NULL;
             break;
           case G_BUTTON :
           case G_STRING :
           case G_TITLE :
             obj->ob_spec.free_string = rs_strings[obj->ob_spec.index];
             break;
           }
        obj->ob_x      = ((obj->ob_x      & 0xff) *  8 + (obj->ob_x      >> 8)) * 
                                 my_parameters.char_width  /  8;
        obj->ob_y      = ((obj->ob_y      & 0xff) * 16 + (obj->ob_y      >> 8)) * 
                                 my_parameters.char_height / 16;
        obj->ob_width  = ((obj->ob_width  & 0xff) *  8 + (obj->ob_width  >> 8)) * 
                                 my_parameters.char_width  /  8;
        obj->ob_height = ((obj->ob_height & 0xff) * 16 + (obj->ob_height >> 8)) * 
                                 my_parameters.char_height / 16;
      }

   for (count = 0; count < NUM_TI; count++) {
        ted = &rs_tedinfo[count];
        ted->te_ptmplt = rs_strings[ted->te_ptmplt];
        ted->te_pvalid = rs_strings[ted->te_pvalid];
        ted->te_ptext  = rs_strings[ted->te_ptext];
      }

   for (count = 0; count < NUM_IB; count++) {
        icn = &rs_iconblk[count];
        icn->ib_pmask = rs_imdope[icn->ib_pmask].image;
        icn->ib_pdata = rs_imdope[icn->ib_pdata].image;
        icn->ib_ptext = rs_strings[icn->ib_ptext];
      }

   for (count = 0; count < NUM_BB; count++)
        rs_bitblk[count].bi_pdata = rs_imdope[rs_bitblk[count].bi_pdata].image;
 }
