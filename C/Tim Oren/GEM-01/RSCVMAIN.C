06601030301800
1Tim Oren- Professional GEM -RESOURCE CONVERTER
2Appendix A- RSCVMAIN.C -Page A#
F0110030
9[...............................................]001
€/*----------------*/
/*    includes    */
/*----------------*/

#include "portab.h"                           /* Portable coding conv */
#include "machine.h"                        /* Machine dependent conv */
#include "obdefs.h"                             /* Object definitions */
#include "gembind.h"                           /* GEM binding structs */
#include "osbind.h"                               /* BDOS definitions */
#include "gemdefs.h"
#include "rsconv.h"


/*---------------*/
/*    defines    */
/*---------------*/

#define NIL -1
#define DESK 0
#define ARROW 0
#define HOUR_GLASS 2             
#define END_UPDATE 0
#define BEG_UPDATE 1

typedef struct memform
   {
   WORD  *mp;
   WORD  fwp;
   WORD  fh;
   WORD  fww;
   WORD  ff;
   WORD  np;
   WORD  r1;
   WORD  r2;
   WORD  r3;
   } MFDB;

/*--------------*/
/*    Global    */
/*--------------*/
GLOBAL WORD gl_apid;

GLOBAL WORD contrl[11];                             /* Control inputs */
GLOBAL WORD intin[80];                           /* Max string length */
GLOBAL WORD ptsin[256];                        /* Polygon fill points */
GLOBAL WORD intout[45];                    /* Open workstation output */
GLOBAL WORD ptsout[12];

GLOBAL WORD gl_wchar;                              /* Character width */
GLOBAL WORD gl_hchar;                             /* Character height */
GLOBAL WORD gl_wbox;                              /* Box (cell) width */
GLOBAL WORD gl_hbox;                             /* Box (cell) height */
GLOBAL WORD gem_handle;                                 /* GEM handle */
GLOBAL WORD vdi_handle;                                 /* VDI handle */
GLOBAL WORD work_out[57];          /* Open virtual workstation values */
GLOBAL GRECT   scrn_area;                                /* Scrn area */
GLOBAL MFDB scrn_mfdb;              /* Scrn memory definition for blt */
GLOBAL GRECT   full;                                  /* Desktop size */
€
/*----------------*/
/*    External    */
/*----------------*/

EXTERN WORD desel_obj();

/*-------------*/
/*    Local    */
/*-------------*/

MLOCAL WORD native_in = TRUE;         /* TRUE:  input .RSC is native  */
                                      /* FALSE: input .RSC is foreign */
MLOCAL WORD conv_def = TRUE;               /* TRUE: convert .DEF also */
MLOCAL WORD new_dfn = FALSE;           /* TRUE: use new symbol format */
MLOCAL BYTE old_rsc[4] = "RSC";           /* New resource file extent */
MLOCAL BYTE new_rsc[4] = "RS2";           /* New resource file extent */
MLOCAL BYTE old_def[4] = "DEF";         /* New definition file extent */
MLOCAL BYTE new_def[4] = "DF2";         /* New definition file extent */
MLOCAL BYTE r_file[81];                         /* Resource file name */
MLOCAL BYTE d_file[81];                       /* Definition file name */
MLOCAL BYTE r2_file[81];                      /* Output resource name */
MLOCAL BYTE d2_file[81];                    /* Output definition name */
MLOCAL WORD r_hndl = -1;                      /* Resource file handle */
MLOCAL WORD d_hndl = -1;                    /* Definition file handle */
MLOCAL WORD r2_hndl = -1;                   /* Output resource handle */
MLOCAL WORD d2_hndl = -1;                 /* Output definition handle */

MLOCAL LONG f_err;                                      /* File error */
MLOCAL BYTE *head;                              /* Location of buffer */
MLOCAL LONG buff_size;                              /* Size of buffer */
MLOCAL BYTE buff[20];                           /* Def file work area */
MLOCAL UWORD   img_offset, addr;                   /* For image fixup */
MLOCAL WORD img_odd;                           /* Image fixup needed? */
MLOCAL GRECT   prog_rect;             /* Rectangle for prog indicator */

/*------------------*/
/*    swap_bytes    */
/*------------------*/
   VOID
swap_bytes(where, len)
   BYTE  *where;
   WORD  len;
   {
   BYTE  swap;

   for ( ; len > 0; len -= 2)
      {
      swap = *where;
      *where = *(where + 1);
      *(where + 1) = swap;
      where += 2;
      }
   }

€/*------------------*/
/*    swap_words    */
/*------------------*/
   VOID
swap_words(where, len)
   WORD  *where;
   WORD  len;
   {
   UWORD swap;

   for ( ; len > 0; len -= 4)
      {
      swap = *where;
      *where = *(where + 1);
      *(where + 1) = swap;
      where += 2;
      }
   }

/*-------------------*/
/*    swap_images    */
/*-------------------*/
   VOID
swap_images()
   {
   BITBLK   *where;
   ICONBLK  *where2;
   BYTE  *taddr;
   WORD  num;
   WORD  wb, hl;

   where = (BITBLK *) (head + ((RSHDR *) head)->rsh_bitblk);
   num = ((RSHDR *) head)->rsh_nbb;
   for ( ; num--; where++)
      {
      taddr = where->bi_pdata;
      wb = where->bi_wb;
      hl = where->bi_hl;
      if ((LONG) taddr != -1L)
         {
         if (img_odd)
            where->bi_pdata = ++taddr;
         swap_bytes(head + taddr, wb * hl);
         }
      }

   where2 = (ICONBLK *) (head + ((RSHDR *) head)->rsh_iconblk);
   num = ((RSHDR *) head)->rsh_nib;
   for ( ; num--; where2++)
      {
      wb = (where2->ib_wicon + 7) >> 3;
      hl = where2->ib_hicon;
      taddr = where2->ib_pdata;
€      if ((LONG) taddr != -1L)
         {
         if (img_odd)
            where2->ib_pdata = ++taddr;
         swap_bytes(head + taddr, wb * hl);
         }
      taddr = where2->ib_pmask;
      if ((LONG) taddr != -1L)
         {
         if (img_odd)
            where2->ib_pmask = ++taddr;
         swap_bytes(head + taddr, wb * hl);
         }
      }
   }

/*------------------*/
/*    swap_trees    */
/*------------------*/
   VOID
swap_trees()
   {
   BYTE  *where;
   WORD  size;

   where = head + ((RSHDR *) head)->rsh_trindex;
   size = ((RSHDR *) head)->rsh_ntree * sizeof(LONG);
   swap_bytes(where, size);
   swap_words((WORD *) where, size);
   }

/*-----------------*/
/*    swap_objs    */
/*-----------------*/
   VOID
swap_objs()
   {
   OBJECT   *where;
   WORD  num;

   where = (OBJECT *) (head + ((RSHDR *) head)->rsh_object);
   num = ((RSHDR *) head)->rsh_nobs;
   swap_bytes((BYTE *) where, num * sizeof(OBJECT));
   for ( ; num--; where++)
      swap_words((WORD *) &where->ob_spec, sizeof(LONG));
   }

€/*-----------------*/
/*    swap_teds    */
/*-----------------*/
   VOID
swap_teds()
   {
   TEDINFO  *where;
   WORD  num;

   where = (TEDINFO *) (head + ((RSHDR *) head)->rsh_tedinfo);
   num = ((RSHDR *) head)->rsh_nted;
   swap_bytes((BYTE *) where, num * sizeof(TEDINFO));
   for ( ; num--; where++)
      {
      swap_words((WORD *) &where->te_ptext, sizeof(LONG));
      swap_words((WORD *) &where->te_ptmplt, sizeof(LONG));
      swap_words((WORD *) &where->te_pvalid, sizeof(LONG));
      }
   }

/*----------------*/
/*    swap_ibs    */
/*----------------*/
   VOID
swap_ibs()
   {
   ICONBLK  *where;
   WORD  num;

   where = (ICONBLK *) (head + ((RSHDR *) head)->rsh_iconblk);
   num = ((RSHDR *) head)->rsh_nib;
   swap_bytes((BYTE *) where, num * sizeof(ICONBLK));
   for ( ; num--; where++)
      {
      swap_words((WORD *) &where->ib_pdata, sizeof(LONG));
      swap_words((WORD *) &where->ib_pmask, sizeof(LONG));
      swap_words((WORD *) &where->ib_ptext, sizeof(LONG));
      }
   }

/*----------------*/
/*    swap_bbs    */
/*----------------*/
   VOID
swap_bbs()
   {
   BITBLK   *where;
   WORD  num;

   where = (BITBLK *) (head + ((RSHDR *) head)->rsh_bitblk);
   num = ((RSHDR *) head)->rsh_nbb;
   swap_bytes((BYTE *) where, num * sizeof(BITBLK));
   for ( ; num--; where++)
      swap_words((WORD *) &where->bi_pdata, sizeof(LONG));
   }

€/*-----------------*/
/*    swap_fstr    */
/*-----------------*/
   VOID
swap_fstr()
   {
   BYTE  *where;
   WORD  size;

   where = head + ((RSHDR *) head)->rsh_frstr;
   size = ((RSHDR *) head)->rsh_nstring * sizeof(LONG);
   swap_bytes(where, size);
   swap_words((WORD *) where, size);
   }

/*-----------------*/
/*    swap_fimg    */
/*-----------------*/
   VOID
swap_fimg()
   {
   LONG  where;
   WORD  size;

   where = head + ((RSHDR *) head)->rsh_frimg;
   size = ((RSHDR *) head)->rsh_nimages * sizeof(LONG);
   swap_bytes(where, size);
   swap_words((WORD *) where, size);
   }

/*-------------------*/
/*    close_files    */
/*-------------------*/
   VOID
close_files()
   {
   if (r_hndl != -1)
      Fclose(r_hndl);
   if (d_hndl != -1)
      Fclose(d_hndl);
   if (r2_hndl != -1)
      Fclose(r2_hndl);
   if (d2_hndl != -1)
      Fclose(d2_hndl);
   r_hndl = d_hndl = r2_hndl = d2_hndl = -1; 
   }

€/*---------------*/
/*    do_conv    */
/*---------------*/
   WORD
do_conv()
   {
   BYTE  *str; 
   LONG  size;
   WORD  reply, nsym;

   r_file[0] = '\0';

   if (!get_file(old_rsc, r_file))
      return;
   if ((r_hndl = open_file(r_file)) == -1)
      return;
   if (conv_def)
      {
      new_ext(r_file, d_file, old_def);
      FOREVER {
         d_hndl = (WORD) Fopen(d_file, 0);
         if (d_hndl >= 0)
            break;
         rsrc_gaddr(R_STRING, NODEF, &str);
         reply = form_alert(1, str);
         if (reply == 3)
            {
            close_files();
            return;
            }
         if (reply == 1)
            {
            conv_def = FALSE;
            break;
            }
         if (!get_file(old_def, d_file))           /* if (reply == 2) */
            break;
         }
      }

   graf_mouse(HOUR_GLASS, 0x0L);
   beg_prog(&prog_rect);
   set_prog(RSCREAD);

   f_err = Fread(r_hndl, (LONG) sizeof(RSHDR), head);
   if (f_err < 0)
      {
      dos_error((WORD) f_err);
      return;
      }

   if (!native_in)
      swap_bytes(head, sizeof(RSHDR));

   size = ((RSHDR *) head)->rsh_rssize;

€   if (buff_size < size)
      {
      graf_mouse(ARROW, 0x0L);                        /* Before alert */
      rsrc_gaddr(R_STRING, NOMEM, &str);
      form_alert(1, str);
      close_files();
      return;
      }

   f_err = Fread(r_hndl, size - sizeof(RSHDR), head + sizeof(RSHDR));
   if (f_err < 0)
      {
      dos_error((WORD) f_err);
      return;
      }

   img_offset = ((RSHDR *) head)->rsh_imdata;
   if ((img_odd = img_offset & 0x0001))
      {
      set_prog(IMGALIGN);
      ((RSHDR *) head)->rsh_rssize = img_offset + 1;
      for (addr = ((RSHDR *) head)->rsh_frstr; --addr > img_offset; 
           *(head + addr) = *(head + addr - 1));
      }

   set_prog(BYTESWAP);
   if (native_in)
      swap_images();

   swap_trees();
   swap_objs();
   swap_teds();
   swap_ibs();
   swap_bbs();
   swap_fstr();
   swap_fimg();

   if (native_in)
      swap_bytes(head, sizeof(RSHDR));
   else
      swap_images();

   set_prog(RSCWRITE);
   new_ext(r_file, r2_file, new_rsc);
   if ((r2_hndl = create_file(r2_file)) == -1)
      {
      close_files();
      return;
      }
   graf_mouse(HOUR_GLASS, 0x0L);           /* Create_file could reset */

   f_err = Fwrite(r2_hndl, size, head);
   if (f_err < 0)
      {
      dos_error((WORD) f_err);
      return;
      }

€   if (!conv_def)
      {
      close_files();
      end_prog(&prog_rect);
      return;
      }

   set_prog(DEFREAD);
   new_ext(r_file, d2_file, new_def);
   if ((d2_hndl = create_file(d2_file)) == -1)
      {
      close_files();
      return;
      }

   f_err = Fread(d_hndl, (LONG) sizeof(WORD), &nsym);
   if (f_err < 0)
      {
      dos_error((WORD) f_err);
      return;
      }

   set_prog(BYTESWAP);
   reply = nsym;
   swap_bytes(&reply, 2);

   f_err = Fwrite(d2_hndl, (LONG) sizeof(WORD), new_dfn? &nsym: &reply);
   if (f_err < 0)
      {
      dos_error((WORD) f_err);
      return;
      }

   if (!native_in || new_dfn)
      nsym = reply;

   for ( ; nsym--; )
      {
      if (!new_dfn)           /* Spare words only if using old format */
      if (!native_in)
         {                                       /* Insert spare word */
         reply = 0;
         f_err = Fwrite(d2_hndl, (LONG) sizeof(WORD), &reply);
         if (f_err < 0)
            {
            dos_error((WORD) f_err);
            return;
            }
         }
      else
         {                                       /* Delete extra word */
         f_err = Fread(d_hndl, (LONG) sizeof(WORD), buff);
         if (f_err < 0)
            {
            dos_error((WORD) f_err);
            return;
            }
         }
€
      f_err = Fread(d_hndl, (LONG) sizeof(WORD), buff);
      if (f_err < 0)
         {
         dos_error((WORD) f_err);
         return;
         }

      if (!new_dfn)                       /* Just copy for new format */
         swap_bytes(buff, 2);

      f_err = Fwrite(d2_hndl, (LONG) sizeof(WORD), buff);
      if (f_err < 0)
         {
         dos_error((WORD) f_err);
         return;
         }
      f_err = Fread(d_hndl, (LONG) (sizeof(WORD) + 10), buff);
      if (f_err < 0)
         {
         dos_error((WORD) f_err);
         return;
         }

      if (!new_dfn)
         swap_bytes(buff, 2);                      /* Only swap value */

      f_err = Fwrite(d2_hndl, (LONG) (sizeof(WORD) + 10), buff);
      if (f_err < 0)
         {
         dos_error((WORD) f_err);
         return;
         }
      }

   set_prog(DEFWRITE);
   close_files();
   end_prog(&prog_rect);
   }

/*---------------*/
/*    do_help    */
/*---------------*/
   VOID
do_help()
   {
   OBJECT   *tree;
   WORD  obj;

   rsrc_gaddr(R_TREE, HELP, &tree);
   obj = hndl_dial(tree, 0, 0, 0, 0, 0);
   desel_obj(tree, obj);
   }

€/*---------------*/
/*    do_mode    */
/*---------------*/
   WORD
do_mode()
   {
   OBJECT   *tree;
   WORD  obj;
   WORD  xdial, ydial, wdial, hdial;

   rsrc_gaddr(R_TREE, MODE, &tree);

   sel_obj(tree, native_in? N2F: F2N);
   if (!conv_def)
      sel_obj(tree, DEFNO);
   else if (!new_dfn)
      sel_obj(tree, DEFYES);
   else
      sel_obj(tree, DFNYES);
   set_text(tree, RSC1, old_rsc, 4);
   set_text(tree, RSC2, new_rsc, 4);
   set_text(tree, DEF1, old_def, 4);
   set_text(tree, DEF2, new_def, 4);

   form_center(tree, &xdial, &ydial, &wdial, &hdial);
   form_dial(0, 0, 0, 0, 0, xdial, ydial, wdial, hdial);
   form_dial(1, 0, 0, 0, 0, xdial, ydial, wdial, hdial);
   objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

   while (TRUE)
      {
      obj = form_do(tree, 0) & 0x7FFF;
      if (obj == DEFYES)
         {
         if (strcmp(old_def, "DFN") == 0)
            {
            strcpy(old_def, "DEF");
            disp_obj(tree, DEF1);
            }
         }
      else if (obj == DFNYES)
         {
         if (strcmp(old_def, "DEF") == 0)
            {
            strcpy(old_def, "DFN");
            disp_obj(tree, DEF1);
            }
         }
      else
         break;
      }

   form_dial(2, 0, 0, 0, 0, xdial, ydial, wdial, hdial);
   form_dial(3, 0, 0, 0, 0, xdial, ydial, wdial, hdial);

€   native_in = selected(tree, N2F);
   conv_def = !selected(tree, DEFNO);
   new_dfn = selected(tree, DFNYES);

   map_tree(tree, ROOT, NIL, desel_obj);
   return (obj);
   }

/*----------------*/
/*    rscv_run    */
/*----------------*/
   WORD
rscv_run()
   {
   WORD  obj;

   FOREVER {
      obj = do_mode();
      if (obj == HELPMODE)
         do_help();
      else if (obj == CONVMODE)
         {
         do_conv();
         graf_mouse(ARROW, 0x0L);
         }
      else 
         break;
      }
   }

/*-----------------*/
/*    rscv_term    */
/*-----------------*/
   VOID
rscv_term(term_type)
   WORD  term_type;
   {
   switch (term_type)                /* NOTE:  all cases fall through */
      {
      case (0):                                 /* Normal termination */
         Mfree(head);
      case (2):
         v_clsvwk(vdi_handle);
      case (3):
         rsrc_free();
      case (4):
         if (term_type)
            wind_update(END_UPDATE);
         appl_exit();
      case (5):
         break;
      }
   }

€/*-----------------*/
/*    rscv_init    */
/*-----------------*/
   WORD
rscv_init()
   {
   WORD  i;
   WORD  work_in[11];
   LONG  tree;

   appl_init();                               /* Initialize libraries */
   if (gl_apid == -1)
      return (5);                                      /* No handles! */
   graf_mouse(HOUR_GLASS, 0x0L);
   wind_update(BEG_UPDATE);
   if (!rsrc_load("RSCONV.RSC"))
      {
      graf_mouse(ARROW, 0x0L);
      form_alert(1, 
               "[3][Fatal Error !|RSCONV.RSC|File Not Found][ Abort ]");
      return(4);                               /* Can't find resource */
      }

   for (i=0; i<10; i++)
      {
      work_in[i]=1;
      }
   work_in[10]=2;
   gem_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
   vdi_handle = gem_handle;
   v_opnvwk(work_in,&vdi_handle,work_out);/* Open virtual workstation */
   if (vdi_handle == 0)
      return (3);

   vqt_attributes (vdi_handle, work_in);

   scrn_area.g_x = 0;
   scrn_area.g_y = 0;
   scrn_area.g_w = work_out[0] + 1;
   scrn_area.g_h = work_out[1] + 1;

   scrn_mfdb.np = work_out[4];
   scrn_mfdb.mp = 0x0L;

   wind_get(DESK, WF_WXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);

   vst_height(vdi_handle, work_in[7], &gl_wchar, 
              &gl_hchar, &gl_wbox, &gl_hbox);

   buff_size = Malloc(-1L);
   head = Malloc(buff_size - 4000L);

   graf_mouse(ARROW,0x0L);
   wind_update(END_UPDATE);
   return(0);
   }

€/*------------*/
/*    main    */
/*------------*/
main()
   {
   WORD  rscv_code;

   if (!(rscv_code = rscv_init()))                  /* Initialization */
      rscv_run();
   rscv_term(rscv_code);                               /* Termination */
   }

