06601030301800
1Tim Oren- Professional GEM -AES HOOKS & HACKS
2Appendix A- PROGEM11.C -Page A#
F0110030
9[...............................................]001
€/************* Sample code for initializing User Objects **************/

GLOBAL USERBLK extobjs[MAX_OBJS];      /* APPLBLK defined in OBDEFS.H */
GLOBAL WORD    n_extobjs;                 /* Set MAX_OBJS to total    */
                                          /* user objects in resource */

   VOID                                 /* Scan whole resource for    */
obj_init()                              /* user objects; uses         */
   {                                    /* map_tree() from PROGEM05.C */
   LONG  tree, obspec;
   WORD  itree, i, obj;

   n_extobjs = 0;                    /* Replace TREE0 with your first */
                                     /* tree, TREEN with the last     */
   for (itree = TREE0; itree <= TREEN; itree++)
      {
      rsrc_gaddr(R_TREE, itree, &tree);
      map_tree(tree, ROOT, NIL, fix_obj);
      }
   }

   WORD                                   /* Code to check and fix up */
fix_obj(tree, obj)                        /* a user-defined object    */
   LONG  tree;
   WORD  obj;
   {
   WORD  hibyte;

   hibyte = LWGET(OB_TYPE(obj)) & 0xff00;    /* Check extended type - */
   if (!hibyte)                              /* if none ...           */
      return (TRUE);                         /*         ignore object */
   extobjs[n_extobjs].ub_code = dr_code;              /* Set drawcode */
   extobjs[n_extobjs].ub_parm = LLGET(OB_SPEC(obj));  /* Copy obspec  */
   LLSET(OB_SPEC(obj), ADDR(&extobjs[n_extobjs]));    /* Point obspec */
   LWSET(OB_TYPE(obj), G_USERDEF | hibyte);           /* to userblk   */
   n_extobjs++;                                       /* & patch type */
   return (TRUE);
   }
   
€/****************** Sample User Object Drawing Code *******************/
/************ (Implements Rounded Box based on G_BOX type) ************/

   WORD                            /* Sample user object drawing code */
dr_code(pb)                        /* Caution: NOT portable to Intel  */
   PARMBLK *pb;                    /*          small data models      */
   {
   LONG  tree, obspec;
   WORD  slct, flip, type, ext_type, flags;
   WORD  pxy[4];
   WORD  bgc, interior, style, bdc, width, chc;
   
   tree = pb->pb_tree;
   obspec = LLGET(pb->pb_parm);       /* Original obspec from USERBLK */
   ext_type = LHIBT(LWGET(OB_TYPE(pb->pb_obj)));
   slct = SELECTED & pb->pb_currstate;
   flip = SELECTED & (pb->pb_currstate ^ pb->pb_prevstate);
   set_clip(TRUE, &pb->pb_xc);    /* These two routines in PROGEM09.C */
   grect_to_array(&pb->pb_x, pxy); 

   switch (ext_type) {
      case 1:                                          /* Rounded box */
         get_colrwd(obspec, &bgc, &style,         /* Crack color word */
                    &interior, &bdc, &width, &chc);
         if(slct)            /* For select effect ...                 */
            bgc = chc;       /* use char color in place of background */
                             /* Fill in background                    */
         rr_fill(MD_REPLACE, (width? 0: 1), bgc, interior, style, pxy);
         if (width && !flip) /* Do perimeter if needed ...            */
            {
            pxy[0] -= width; pxy[2] += width; 
            rr_perim(MD_REPLACE, bdc, FIS_SOLID, width, pxy);
            }                /* using rr_perim from PROGEM09.C        */
         break;
      default:                                 /* Add more types here */
         break;
      }
   return (0);
   }

€   VOID                               /* Cracks the obspec color word */
get_colrwd(obspec, bgc, style, interior, bdc, width, chc)
   LONG  obspec;
   WORD  *bgc, *style, *interior, *bdc, *width, *chc, *chmode;
   {
   WORD  colorwd;

   colorwd = LLOWD(obspec);
   *bgc = colorwd & 0xf;
   *style = (colorwd & 0x70) >> 4;
   if (!(*style))
      *interior = 0;
   else if (*style == 7)
      *interior = 1;
   else if (colorwd & 0x80)  /* HACK: Uses character writing mode bit */
      *interior = 3;         /* to select alternate interior styles!  */
   else
      *interior = 2;
   *bdc = (colorwd & 0xf000) >> 12;

   *width = LHIWD(obspec) & 0xff;
   if (*width > 127)
      *width = 256 - *width;

   if (*width && !(*width & 0x1))     /* VDI only renders odd widths! */
      (*width)--;

   *chc = (colorwd & 0x0f00) >> 8;          /* Used for select effect */
   }

   VOID                                   /* Fill a rounded rectangle */
rr_fill(mode, perim, color, interior, style, pxy)
   WORD  mode, perim, color, style, interior, *pxy;
   {
   vswr_mode(vdi_handle, mode);
   vsf_color(vdi_handle, color);
   vsf_style(vdi_handle, style);
   vsf_interior(vdi_handle, interior);
   vsf_perimeter(vdi_handle, perim);
   v_rfbox(vdi_handle, pxy);
   }

