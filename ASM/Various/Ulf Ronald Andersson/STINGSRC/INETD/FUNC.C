

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "ind.h"
#include "window.h"
#include "module.h"
#include "transprt.h"


#define  NUM_TREE   7


int   get_version (char stik[]),  init_modules (void);
long  get_stik_cookie (void);
void  terminate_modules (void),  call_module (int which);
void  load_overlay (int which),  remove_overlay (int which);
int   check_modules (void);
void  insert_modules (int draw_flag);


extern char  ism_path[];
extern int   disp_offset;

DRV_LIST    *stik_drivers;
TPL         *tpl;
ISM_PARA    parameter;
ISM_INTERN  *ism_data;
OBJECT      **my_tree_index, **old_tree_index = NULL;
char        version[] = "00.01", tcpip_version[6];
int         num_modules = 0;
int         mdle_box[]  = { ST_MBX1,  ST_MBX2,  ST_MBX3,  ST_MBX4   };
int         click_box[] = { ST_MCK1,  ST_MCK2,  ST_MCK3,  ST_MCK4   };
int         mdle_icon[] = { ST_MIC1,  ST_MIC2,  ST_MIC3,  ST_MIC4   };
int         mdle_name[] = { ST_MNAM1, ST_MNAM2, ST_MNAM3, ST_MNAM4  };



int  get_version (stik_version)

char  stik_version[];

{
   stik_drivers = (DRV_LIST *) Supexec (get_stik_cookie);

   if (stik_drivers == NULL)
        return (1);
   if (strcmp (stik_drivers->magic, MAGIC) != 0)
        return (1);

   tpl = (TPL *) (*stik_drivers->get_dftab) (TRANSPORT_DRIVER);

   if (tpl == (TPL *) NULL)
        return (1);

   strncpy (stik_version, tpl->version, 5);
   stik_version[5] = '\0';
   strcpy (tcpip_version, stik_version);

   return (0);
 }


long  get_stik_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


int  init_modules()

{
   ISM_SPECS   *values;
   ISM_INTERN  *ism;
   OBJECT      *tree;
   DTA         *my_dta;
   int         error, count, index;
   char        *ptr = ism_path, *search = "*.ISM";

   if (ism_path[1] == ':') {
        Dsetdrv (ism_path[0] - 'A');   ptr = &ism_path[2];
      }
   Dsetpath (ptr);

   my_dta = Fgetdta();

   error = Fsfirst (search, 0);

   while (! error)
        num_modules++,  error = Fsnext();

   if (num_modules == 0)   return (0);

   rsrc_gaddr (R_TREE, START, &tree);

   if (num_modules >= 5) {
        for (count = 0; count < 4; count++) {
             tree[ mdle_box[count]].ob_width -= tree[ST_SLIDE].ob_width + 2;
             tree[click_box[count]].ob_width -= tree[ST_SLIDE].ob_width + 2;
           }
        tree[ST_S_BTN].ob_y      = 0;
        tree[ST_S_BTN].ob_height = tree[ST_S_GND].ob_height * 4 / num_modules;
      }
     else {
        tree[ST_SLIDE].ob_flags |= HIDETREE;
        for (count = 0; count < 4; count++)
             if (count >= num_modules) {
                  tree[ mdle_box[count]].ob_flags |= HIDETREE;
                  tree[click_box[count]].ob_flags |= HIDETREE;
                }
        count = (4 - num_modules) * (tree[ST_MBX2].ob_y - tree[ST_MBX1].ob_y);
        tree[AUTHORS].ob_y -= count;
        tree[ST_CONF].ob_y -= count;
        tree[ST_MBOX].ob_height -= count;
        tree[ST_PBOX].ob_height -= count;
        tree[ROOT].ob_height    -= count;
      }

   ism_data = (ISM_INTERN *) Malloc (num_modules * sizeof (ISM_INTERN));
   if (ism_data == NULL)   return (0);

   index = NUM_TREE;
   count = 0;
   error = Fsfirst (search, 0);

   while (! error) {
        strncpy ((ism = &ism_data[count])->file, my_dta->d_fname, 12);
        parameter.module_resident = (void *) ism->resident;
        load_overlay (parameter.index = count);
        values = (ISM_SPECS *) (*ism->ism_init) (&parameter);
        strncpy (ism->ism_name,   values->ism_name, 16);
        strncpy (ism->ism_ictxt,  values->ism_icon->ib_ptext, 12);
        memcpy  (ism->ism_icon,   values->ism_icon->ib_pdata, 96);
        ism->protocol    = values->ism_protocol;
        ism->tos         = values->ism_tos;
        ism->ism_dterm   = (long) values->ism_term   - (long) ism->ism_init;
        ism->ism_duser   = (long) values->ism_user   - (long) ism->ism_init;
        ism->ism_dserver = (long) values->ism_server - (long) ism->ism_init;
        ism->rsc_offset  = index;
        index += (ism->rsc_num = values->ism_num_trees);
        remove_overlay (count++);
        error = Fsnext();
      }

   my_tree_index = (OBJECT **) Malloc (index * sizeof (OBJECT *));

   if (count != num_modules || my_tree_index == NULL) {
        terminate_modules();
        return (0);
      }

   old_tree_index = * (OBJECT ***) &_GemParBlk.global[5];
   * (OBJECT ***) &_GemParBlk.global[5] = my_tree_index;
   memcpy (my_tree_index, old_tree_index, NUM_TREE * sizeof (OBJECT *));

   insert_modules (FALSE);

   return (1);
 }


void  terminate_modules()

{
   ISM_INTERN  *ism;
   int  count;

   for (count = 0; count < num_modules; count++) {
        ism = &ism_data[count];
        if (ism->file) {
             if ((long) ism->basepage < 0) {
                  load_overlay (count);
                  if ((long) ism->basepage < 0)   continue;
                }
             parameter.module_resident = (void *) ism->resident;
             parameter.index = count;
             (*ism->ism_term) (&parameter);
             remove_overlay (count);
           }
      }

   Mfree (ism_data);

   if (my_tree_index)
        Mfree (my_tree_index);

   if (old_tree_index)
        * (OBJECT ***) &_GemParBlk.global[5] = old_tree_index;
 }


void  call_module (which)

int  which;

{
   ISM_INTERN  *ism;

   ism = &ism_data[which];

   if ((ism->action & ACT_USER) == 0) {
        if (ism->file) {
             if ((long) ism->basepage < 0) {
                  load_overlay (which);
                  if ((long) ism->basepage < 0)   return;
                }
             ism->action |= ACT_USER;
             parameter.module_resident = (void *) ism->resident;
             parameter.index = which;
             (*ism->ism_user) (&parameter);
           }
      }
 }


void  load_overlay (which)

int  which;

{
   ISM_INTERN  *ism;
   BASPAG      *basepage;
   long        length;

   basepage = (BASPAG *) Pexec (3, (ism = &ism_data[which])->file, "", "");
   if ((long) basepage < 0) {
        ism->basepage = (BASPAG *) -1L;   return;
      }

   length = 256L + basepage->p_tlen + basepage->p_dlen + basepage->p_blen;
   Mshrink (0, basepage, length);

   ism->ism_init   = (IND_FUNC) ((long) basepage->p_tbase);
   ism->ism_term   = (IND_FUNC) ((long) basepage->p_tbase + ism->ism_dterm);
   ism->ism_user   = (IND_FUNC) ((long) basepage->p_tbase + ism->ism_duser);
   ism->ism_server = (IND_FUNC) ((long) basepage->p_tbase + ism->ism_dserver);

   ism->basepage   = basepage;
 }


void  remove_overlay (which)

int  which;

{
   ISM_INTERN  *ism;

   if ((long) (ism = &ism_data[which])->basepage < 0)
        return;

   ism->action = 0;
   Mfree (ism->basepage->p_env);
   Mfree (ism->basepage);
   ism->basepage = (BASPAG *) -1L;
 }


int  check_modules()

{
   int  count;

   for (count = 0; count < num_modules; count++)
        if (ism_data[count].action == 0) {
             if ((long) ism_data[count].basepage > 0)
                  remove_overlay (count);
           }

   return (0);
 }


void  insert_modules (draw_it)

int  draw_it;

{
   ISM_INTERN  *ism;
   OBJECT      *tree;
   int         count;

   rsrc_gaddr (R_TREE, START, &tree);

   for (count = 0; count < num_modules && count < 4; count++) {
        ism = &ism_data[disp_offset + count];
        memcpy  (tree[mdle_icon[count]].ob_spec.iconblk->ib_pdata, ism->ism_icon, 96);
        strncpy (tree[mdle_icon[count]].ob_spec.iconblk->ib_ptext, ism->ism_ictxt, 12);
        strncpy (tree[mdle_name[count]].ob_spec.free_string, ism->ism_name, 16);
        if (draw_it)
             change_flags (START, mdle_box[count], 0, 0, 0);
      }
 }
