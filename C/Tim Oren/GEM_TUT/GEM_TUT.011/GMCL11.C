ode for initializing User Objects <<<<<<<<<<<<<<<<

GLOBAL  USERBLK extobjs[MAX_OBJS];      /* APPLBLK defined in OBDEFS.H  */
GLOBAL  WORD    n_extobjs;              /* Set MAX_OBJS to total user   */
                                        /* objects in resource          */

        VOID
obj_init()                              /* Scan whole resource for user   */
        {                               /* objects.  Uses map_tree()      */
        LONG    tree, obspec;           /* from GEMCL5.C                  */
        WORD    itree, i, obj;

        n_extobjs = 0;                  /* Replace TREE0 with your first  */
                                        /* tree, TREEN with the last      */
        for (itree = TREE0; itree <= TREEN; itree++)
                {
                rsrc_gaddr(R_TREE, itree, &tree);
                map_tree(tree, ROOT, NIL, fix_obj);
                }
        }

        WORD
fix_obj(tree, obj)                      /* Code to check and fix up     */
        LONG    tree;                   /* a user defined object        */
        WORD    obj;
        {
        WORD    hibyte;

        hibyte = LWGET(OB_TYPE(obj)) & 0xff00;          /* check extended */
        if (!hibyte)                                    /* type - if none */
                return (TRUE);                          /* ignore object  */
        extobjs[n_extobjs].ub_code = dr_code;           /* set drawcode   */
        extobjs[n_extobjs].ub_parm = LLGET(OB_SPEC(obj)); /* copy obspec  */
        LLSET(OB_SPEC(obj), ADDR(&extobjs[n_extobjs]));   /* point obspec */
        LWSET(OB_TYPE(obj), G_USERDEF | hibyte);        /* to userblk &   */
        n_extobjs++;                                    /* patch type     */
        return (TRUE);
        }
        
>>>>>>>>>>>>>>>>>>>>>> Sample User Object Drawing Code <<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>> Implements Rounded Box based    <<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>> on G_BOX type                   <<<<<<<<<<<<<<<<<<<<

        WORD
dr_code(pb)                             /* Sample user object drawing   */
        PARMBLK *pb;                    /* code.  Caution: NOT portable */
        {                               /* to Intel small data models   */
        LONG    tree, obspec;
        WORD    slct, flip, type, ext_type, flags;
        WORD    pxy[4];
        WORD    bgc, interior, style, bdc, width, chc;
        
        tree = pb->pb_tree;
        obspec = LLGET(pb->pb_parm);    /* original obspec from USERBLK  */
        ext_type = LHIBT(LWGET(OB_TYPE(pb->pb_obj)));
        slct = SELECTED & pb->pb_currstate;
        flip = SELECTED & (pb->pb_currstate ^ pb->pb_prevstate);
        set_clip(TRUE, &pb->pb_xc);     /* These two routines in GEMCL9.C */
        grect_to_array(&pb->pb_x, pxy); 

        switch (ext_type) {
                case 1:                 /* Rounded box       */
                                        /* Crack color word  */
                        get_colrwd(obspec, &bgc, &style, &interior,
                                &bdc, &width, &chc);
                                        /* For select effect, use char color */
                        if (slct)       /* In place of background            */
                                bgc = chc;
                                        /* Fill in background                */
                        rr_fill(MD_REPLACE, (width? 0: 1), bgc, interior, 
                                style, pxy);
                                        /* Do perimeter if needed            */
                                        /* rr_perim is in GEMCL9.C           */
                        if (width && !flip)
                                {
                                pxy[0] -= width; pxy[2] += width; 
                                rr_perim(MD_REPLACE, bdc, FIS_SOLID, width, pxy);
                                }
                        break;
                default:                /* Add more types here              */
                        break;
                }
        return (0);
        }

        VOID                            /* Cracks the obspec color word    */
get_colrwd(obspec, bgc, style, interior, bdc, width, chc)
        LONG    obspec;
        WORD    *bgc, *style, *interior, *bdc, *width, *chc, *chmode;
        {
        WORD    colorwd;

        colorwd = LLOWD(obspec);
        *bgc = colorwd & 0xf;
        *style = (colorwd & 0x70) >> 4;
        if ( !(*style) )
                *interior = 0;
        else if (*style == 7)
                *interior = 1;
        else if (colorwd & 0x80)        /* HACK: Uses character writing mode */
                *interior = 3;          /* bit to select alternate interior  */
        else                            /* styles!                           */
                *interior = 2;
        *bdc = (colorwd & 0xf000) >> 12;

        *width = LHIWD(obspec) & 0xff;
        if (*width > 127)
                *width = 256 - *width;

        if (*width && !(*width & 0x1))          /* VDI only renders odd */
                (*width)--;                     /* widths!              */

        *chc = (colorwd & 0x0f00) >> 8;         /* used for select effect */
        }

        VOID                            /* Fill a rounded rectangle     */
rr_fill(mode, perim, color, interior, style, pxy)
        WORD    mode, perim, color, style, interior, *pxy;
        {
        vswr_mode(vdi_handle, mode);
        vsf_color(vdi_handle, color);
        vsf_style(vdi_handle, style);
        vsf_interior(vdi_handle, interior);
        vsf_perimeter(vdi_handle, perim);
        v_rfbox(vdi_handle, pxy);
        }

Capture buffer closed.

[76703,1052]
GEMC11.C                  12-Mar-86 3970               69


(R D T): 

[72437,720]
CLOCKA.ACC                08-Mar-86 19200(8192)        207

    Keywords: DESK ACCESSORY - ANALOG CLOCK
    
    This is another clock, except this is an analog clock. I downloaded this
    from the ATARI BBS. And uploaded it as a test. Looks like 