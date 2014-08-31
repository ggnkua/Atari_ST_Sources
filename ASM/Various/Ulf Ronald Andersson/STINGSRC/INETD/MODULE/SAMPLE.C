

#include <aes.h>
#include <tos.h>
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "module.h"

#include "sample.h"
#include "sample.rsh"


#define  CNTRL_Q      0x1011


ISM_SPECS * cdecl  module_init (ISM_PARA *data);
void  cdecl module_term (ISM_PARA *data),  cdecl module_user (ISM_PARA *data);
void  cdecl module_server (ISM_PARA *data),  convert_resource (void);
int   cdecl click_function (int object),  cdecl key_function (int scancode);
void  set_data (void),  get_data (void);


typedef  struct our_data {
           char  *our_memory;
           int   port, continent, beverage;
      } OUR_DATA;


OUR_DATA  *my_data_ptr;
int       errno, continent;
int       radios[] = { COKE, FANTA, SPRITE  };

ISM_SPECS  my_specs = {  (IND_FUNC) module_init,  (IND_FUNC) module_term,
                         (IND_FUNC) module_user,  (IND_FUNC) module_server,
                          NULL,  NUM_TREE,  ISM_UDP | ISM_TCP,  0,
                         "Sample Server"
              };
int       ism_index;
ISM_API   *api;
ISM_PARA  my_parameters;



/* This initializes everything. Resident memory can be ordered, etc. */

ISM_SPECS * cdecl  module_init (module_data)

ISM_PARA  *module_data;

{
   OBJECT  *tree;

   my_data_ptr = (OUR_DATA *) module_data->module_resident;

   /* We'd just like a little more memory, so we grab it. As the 'module_data'        */
   /* structure is the only part which is resident, the pointer must be saved there ! */
   my_data_ptr->our_memory = (char *) Malloc (1024L);

   /* Set the default values for all the variables here !                             */
   my_data_ptr->port      = 123;
   my_data_ptr->continent = 6;
   my_data_ptr->beverage  = 0;

   /* We wanna return the icon, thus resource structure must be alright.              */
   my_parameters = *module_data;
   convert_resource();

   /* Put icon into structure to be passed to the INetD.                              */
   tree = (OBJECT *) rs_trindex[ICON];
   my_specs.ism_icon = tree[MY_ICON].ob_spec.iconblk;

   return (&my_specs);
 }


/* This should prepare everything for leaving. Malloc'ed memory must be freed, etc. */

void cdecl  module_term (module_data)

ISM_PARA  *module_data;

{
   my_data_ptr = (OUR_DATA *) module_data->module_resident;

   /* The memory we grabbed earlier must be freed now !                               */
   if (my_data_ptr->our_memory)
        Mfree (my_data_ptr->our_memory);
 }


/* This is all the interaction with the user, only place to use resource trees ! */

void cdecl  module_user (module_data)

ISM_PARA  *module_data;

{
   api         = module_data->server_api;
   ism_index   = module_data->index;
   my_data_ptr = (OUR_DATA *) module_data->module_resident;

   /* We wanna use the resource structures, must be initialized now.                  */
   my_parameters = *module_data;
   convert_resource();

   /* Tell the INetD the addresses of our resource trees.                             */
   set_trees (rs_trindex, _GemParBlk.global, 80);

   /* We do use extended objects in our resource trees.                               */
   ext_objects (MAIN);

   /* Set all input fields and buttons to default values.                             */
   set_data();

   /* Open main window and let INetD operate clicks and keys.                         */
   open_window (MAIN, PORT);
   callback (MAIN, click_function, key_function);
 }


void  set_data()

{
   OBJECT  *tree, *popup;
   char    temp[10];

   tree  = (OBJECT *) rs_trindex[MAIN];
   popup = (OBJECT *) rs_trindex[PU_TEST];

   sprintf (temp, "%3d", my_data_ptr->port);
   strncpy (tree[PORT].ob_spec.tedinfo->te_ptext, temp, 3);

   continent = my_data_ptr->continent;
   strcpy (tree[CONTIN].ob_spec.free_string, popup[continent].ob_spec.free_string + 2);

   tree[COKE].ob_state &= ~SELECTED;
   tree[FANTA].ob_state &= ~SELECTED;
   tree[SPRITE].ob_state &= ~SELECTED;
   tree[radios[my_data_ptr->beverage]].ob_state |= SELECTED;
 }


void  get_data()

{
   OBJECT  *tree;
   int     count;

   tree = (OBJECT *) rs_trindex[MAIN];

   my_data_ptr->port = atoi (tree[PORT].ob_spec.tedinfo->te_ptext);
   my_data_ptr->continent = continent;

   for (count = 0; count < 2; count++)
        if (tree[radios[count]].ob_state & SELECTED)   break;
   my_data_ptr->beverage = count;
 }


int cdecl  click_function (object)

int  object;

{
   evnt_timer (60, 0);
   change_flags (MAIN, object & 0x7fff, 0, 0, SELECTED);

   switch (object & 0x7fff) {
      case CLOSER_CLICKED :
        finish_user();
        break;
      case CONTIN :
        do_popup (PU_TEST, &continent, MAIN, CONTIN, 14);
        break;
      case SAVE :
        form_alert (1, "[3][  |  Can't save, we're just a   | |     sample module !][ Ok ]");
        break;
      case ACCEPT :
        get_data();
        break;
      case CANCEL :
        finish_user();
        return (-1);
      }

   return (0);
 }


int cdecl  key_function (scancode)

int  scancode;

{
   return ((scancode == CNTRL_Q) ? -1 : 1);
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
