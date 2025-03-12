/*          GEM_INIT.C V1.0, 9.9.1990           */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */

#include <stdlib.h>
#include "gem_it.h"

int   work_in[12],
      work_out[57];

int   handle,
      phys_handle;

int   gl_hchar,
      gl_wchar,
      gl_hbox,
      gl_wbox;

int   gl_apid;

int   re_flag;

GRECT gl_desk;

OBJECT
*gem_init(const char *lr_name)
{
   int      i;
   OBJECT   *re_gaddr;

   if((gl_apid = appl_init()) != -1)
   {
      for(i = 1; i < 10; work_in[i++] = 1)
         ;

      work_in[10] = 2;
      phys_handle = graf_handle(&gl_wchar,
         &gl_hchar, &gl_wbox, &gl_hbox);

      work_in[0] = handle = phys_handle;
      v_opnvwk(work_in, &handle, work_out);
      wind_get(0, WF_WORKXYWH, &gl_desk.g_x,
         &gl_desk.g_y, &gl_desk.g_w,
         &gl_desk.g_h);

      if(lr_name != NULL)
      {
         if(rsrc_load(lr_name) == 0)
         {
            form_alert(1, err_box[NO_RSRC]);
            gem_exit(NO_RSRC);
         }
         rsrc_gaddr(R_TREE, ROOT, &re_gaddr);
         re_flag = TRUE;
         graf_mouse(ARROW, NULL);
         return(re_gaddr);
      }
      else
      {
         re_flag = FALSE;
         graf_mouse(ARROW, NULL);
         return(NULL);
      }
   }
   else
      exit(NO_APPL);
}

void
gem_exit(int term_code)
{
   if(re_flag == TRUE)
      rsrc_free();

   v_clsvwk(handle);
   appl_exit();
   exit(term_code);
}
