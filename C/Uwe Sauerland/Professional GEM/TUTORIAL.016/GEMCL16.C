r

>>>>>>>>>>>>>>>>>>>>> Progress box setup and cleanup <<<<<<<<<<<<<<<<<<<<<

/*------------------------------*/
/*      beg_prog                */
/*------------------------------*/
        VOID
beg_prog(rect)
        GRECT   *rect;
        {
        OBJECT  *tree;
        WORD    xdial, ydial, wdial, hdial;

        rsrc_gaddr(R_TREE, PROGRESS, &tree);
        form_center(tree, &rect->g_x, &rect->g_y, &rect->g_w, &rect->g_h);
        form_dial(0, 0, 0, 0, 0, rect->g_x, rect->g_y, 
                rect->g_w, rect->g_h);
        objc_draw(tree, ROOT, MAX_DEPTH, rect->g_x, rect->g_y, 
                rect->g_w, rect->g_h);
        }

/*------------------------------*/
/*      end_prog                */
/*------------------------------*/
        VOID
end_prog(rect)
        GRECT   *rect;
        {
        form_dial(3, 0, 0, 0, 0, rect->g_x, rect->g_y, rect->g_w, rect->g_h);
        }

>>>>>>>>>>>>>>>>>>>> Text line progress indicator <<<<<<<<<<<<<<<<<<<<<<<

/*------------------------------*/
/*      set_prog                */
/*------------------------------*/
        VOID
set_prog(strno)
        UWORD   strno;
        {
        OBJECT  *tree;
        BYTE    *saddr;

        rsrc_gaddr(R_TREE, STRINGS, &tree);
        saddr = (BYTE *) (tree + strno)->ob_spec;
        rsrc_gaddr(R_TREE, PROGRESS, &tree);
        set_text(tree, PLINE, saddr);
        disp_obj(tree, PLINE);
        }


>>>>>>>>>>>>>>>>>>>> Moving bar progress indicator <<<<<<<<<<<<<<<<<<<<<<

/*------------------------------*/
/*      set_prog                */
/*------------------------------*/
        VOID
set_prog(value, maxc)
        WORD    value, maxc;
        {
        WORD    wnew, wold;
        OBJECT  *tree;
        GRECT   box;

        rsrc_gaddr(R_TREE, PROGRESS, &tree);
        wold = (tree + PROBOX)->ob_width - 1;   /* Take border into account */
        wnew = wold + 1;
        if (maxc)
                wnew = max(1, ((LONG) value * (LONG) wnew) / maxc); 
        (tree + PROBAR)->ob_width = wnew;
        if (value)
                {
                objc_xywh(tree, PROBAR, &box);
                box.g_x += wold; box.g_w -= wold;
                objc_draw(tree, ROOT, MAX_DEPTH, box.g_x, box.g_y, 
                        box.g_w, box.g_h);
                }
        }       

>>>>>>>>>>>>>>>>>>>> Progress indicator check for abort <<<<<<<<<<<<<<<<
        
/*------------------------------*/
/*      esc_prog                */
/*------------------------------*/
        WORD
esc_prog()
        {
        WORD    which, kr;
        WORD    mx, my, mb, ks, br;             /* Not used, but needed */

        FOREVER 
                {
                which = evnt_multi(MU_KEYBD | MU_TIMER,
                        0, 0, 0,
                        0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0,
                        0L, 
                        0, 0,           /* Zero timer delay */
                        &mx, &my, &mb, &ks, &kr, &br);

                if (which & MU_KEYBD)
                        {
                        if ((kr & 0xff) == 0x1B)        /* ESC?           */
                                return (TRUE);          /* else try again */
                        }
                else /* if (which & MU_TIMER) */
                        return (FALSE);
                }

        return (TRUE);          /* Keeps lint happy */ 
        }

>>>>>>>>>>>>>>>>>>>>>>> Progress subroutines  <<<<<<<<<<<<<<<<<<<<<<<

        VOID
set_text(tree, obj, str)
        OBJECT  *tree;
        BYTE    *str;
        WORD    obj;
        {
        TEDINFO *obspec;

        obspec = (TEDINFO *) (tree + obj)->ob_spec;     /* Get TEDINFO address  */
        obspec->te_ptext = str;                 /* Set new text pointer */
        obspec->te_txtlen = strlen(str);        /* Set new length       */
        }

        VOID
disp_obj(tree, obj)
        OBJECT  *tree;
        WORD    obj;
        {
        GRECT   box;

        objc_xywh(tree, obj, &box);
        objc_draw(tree, ROOT, MAX_DEPTH, box.g_x, box.g_y, 
                box.g_w, box.g_h);
        }

        VOID
objc_xywh(tree, obj, p)         /* get x,y,w,h for specified object     */
        OBJECT  *tree;
        WORD    obj;
        GRECT   *p;
        {
        objc_offset(tree, obj, &p->g_x, &p->g_y);
        p->g_w = (tree + obj)->ob_width;
        p->g_h = (tree + obj)->ob_height;
        }

>>>>>>>>>>>>>>>>>>>>>> Box mover examples <<<<<<<<<<<<<<<<<<<<<<<<<<

/*------------------------------*/
/*      fourway_box             */
/*------------------------------*/
        VOID
fourway_box(vdi_handle, rubber, limit)
        WORD    vdi_handle;
        GRECT   *rubber, *limit;
        {
        UWORD   ox, oy, mx, my, foo, down;

        vswr_mode(vdi_handle, MD_XOR);          /* Set VDI modes for box */
        vsl_color(vdi_handle, BLACK);
        wind_update(BEG_MCTRL);                 /* Capture mouse         */

        ox = rubber->g_x; oy = rubber->g_y;     /* Save off input corner */
        graf_mkstate(&mx, &my, &foo, &foo);     /* Initialize mouse posn */

        do {
                rubber->g_x = min(ox, mx);      /* Choose UL corner      */
                rubber->g_y = min(oy, my);
                rubber->g_w = max(ox, mx) - rubber->g_x + 1;
                rubber->g_h = max(oy, my) - rubber->g_y + 1;
                rc_intersect(limit, rubber);    /* Lock into limit rect  */
                down = rub_wait(vdi_handle, rubber, &mx, &my);
                } while (down);

        wind_update(END_MCTRL);                 /* Release mouse to GEM  */
        }

/*------------------------------*/
/*      hot_dragbox             */
/*------------------------------*/
        WORD
hot_dragbox(vdi_handle, box, limit, tree)
        WORD    vdi_handle;
        GRECT   *box, *limit;
        OBJECT  *tree;
        {
        UWORD   ox, oy, mx, my, foo, down;
        WORD    hover_obj, ret_obj;

        vswr_mode(vdi_handle, MD_XOR);          /* Set VDI modes for box */
        vsl_color(vdi_handle, BLACK);
        wind_update(BEG_MCTRL);                 /* Capture mouse         */

        graf_mkstate(&mx, &my, &foo, &foo);     /* Initialize mouse posn */
        ox = min(box->g_w, max(0, mx - box->g_x) );
        oy = min(box->g_h, max(0, my - box->g_y) );
        hover_obj = NIL;

        do {
                box->g_x = mx - ox;
                box->g_y = my - oy;
                rc_constrain(limit, box);       /* Lock into limit rect  */

                down = rub_wait(vdi_handle, box, &mx, &my);

                if (!inside(mx, my, limit))
                        ret_obj = NIL;
                else
                        {
                        ret_obj = objc_find(tree, ROOT, NIL, mx, my);
                        if (ret_obj != NIL)
                        if ( !(SELECTABLE & (tree + ret_obj)->ob_flags) )
                                ret_obj = NIL;
                        }

                if (ret_obj != hover_obj)
                        {
                        if (hover_obj != NIL)
                                objc_toggle(tree, hover_obj);
                        hover_obj = ret_obj;
                        if (hover_obj != NIL)
                                objc_toggle(tree, hover_obj);
                        }
                } while (down);


        wind_update(END_MCTRL);                 /* Release mouse to GEM  */
        if (hover_obj != NIL)
                objc_toggle(tree, hover_obj);
        return (hover_obj);
        }

/*------------------------------*/
/*      rub_wait                */
/*------------------------------*/
        WORD
rub_wait(vdi_handle, box, mx, my)
        WORD    vdi_handle;
        GRECT   *box;
        WORD    *mx, *my;
        {
        WORD    which, kr;
        WORD    mb, ks, br;                     /* Not used, but needed */

        graf_mouse(M_OFF, 0x0L);
        vdi_xbox(vdi_handle, box);              /* Draw waiting box */
        graf_mouse(M_ON, 0x0L);

        which = evnt_multi(MU_BUTTON | MU_M1,
                0x01, 0x01, 0x00,               /* Wait for button up */
                TRUE, *mx, *my, 1, 1,           /* or mouse move      */
                0, 0, 0, 0, 0,
                0L, 
                0, 0,
                mx, my, &mb, &ks, &kr, &br);

        graf_mouse(M_OFF, 0x0L);
        vdi_xbox(vdi_handle, box);              /* Take down waiting box */
        graf_mouse(M_ON, 0x0L);

        return (!(which & MU_BUTTON));          /* TRUE if still dragging */
        }

>>>>>>>>>>>>>>>>>>>>>>>> Box Mover Utilities <<<<<<<<<<<<<<<<<<<<<<<<<

        VOID
objc_toggle(tree, obj)
        OBJECT  *tree;
        WORD    obj;
        {
        WORD    state, newstate;
        GRECT   root, ob_rect;

        objc_xywh(tree, ROOT, &root);
        newstate = (tree + obj)->ob_state ^ SELECTED;
        objc_change(tree, obj, 0, root.g_x, root.g_y, 
                root.g_w, root.g_h, newstate, 1);
        }

        VOID
vdi_xbox(vdi_handle, pt)
        WORD    vdi_handle;
        GRECT   *pt;
        {
        WORD    pxy[10];

        vdi_bxpts(pt, pxy);
        vdi_xline(vdi_handle, 5, pxy);
        }

        VOID
vdi_bxpts(pt, pxy)
        GRECT   *pt;
        WORD    *pxy;
        {
        pxy[0] = pt->g_x;
        pxy[1] = pt->g_y;
        pxy[2] = pt->g_x + pt->g_w - 1;
        pxy[3] = pt->g_y;
        pxy[4] = pt->g_x + pt->g_w - 1;
        pxy[5] = pt->g_y + pt->g_h - 1;
        pxy[6] = pt->g_x;
        pxy[7] = pt->g_y + pt->g_h - 1;
        pxy[8] = pt->g_x;
        pxy[9] = pt->g_y;
        }

MLOCAL  WORD    hztltbl[2] = { 0x5555, 0xaaaa };
MLOCAL  WORD    verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };

        VOID
vdi_xline(vdi_handle, ptscount, ppoints)
        WORD    vdi_handle, ptscount, *ppoints;
        {
        WORD            *linexy,i;
        WORD            st;

        for ( i = 1; i < ptscount; i++ )
                {
                if ( *ppoints == *(ppoints + 2) )
                        {
                        st = verttbl[( (( *ppoints) & 1) | 
                                ((*(ppoints + 1) & 1 ) << 1))];
                        }       
                else
                        {
                        linexy = ( *ppoints < *( ppoints + 2 )) ? 
                                ppoints : ppoints + 2;
                        st = hztltbl[( *(linexy + 1) & 1)];
                        }

                vsl_udsty(vdi_handle, st);
                vsl_type(vdi_handle, 7);
                v_pline(vdi_handle, 2, ppoints);
                ppoints += 2;
                }

        vsl_type(vdi_handle, 1);
        }       

        WORD
rc_intersect(p1, p2)            /* compute intersect of two rectangles  */
        GRECT   *p1, *p2;
        {
        WORD    tx, ty, tw, th;

        tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
        th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
        tx = max(p2->g_x, p1->g_x);
        ty = max(p2->g_y, p1->g_y);
        p2->g_x = tx;
        p2->g_y = ty;
        p2->g_w = tw - tx;
        p2->g_h = th - ty;
        return( (tw > tx) && (th > ty) );
        }

        VOID
rc_union(p1, p2)
        GRECT           *p1, *p2;
        {
        WORD            tx, ty, tw, th;

        tw = max(p1->g_x + p1->g_w, p2->g_x + p2->g_w);
        th = max(p1->g_y + p1->g_h, p2->g_y + p2->g_h);
        tx = min(p1->g_x, p2->g_x);
        ty = min(p1->g_y, p2->g_y);
        p2->g_x = tx;
        p2->g_y = ty;
        p2->g_w = tw - tx;
        p2->g_h = th - ty;
        }

        VOID
rc_constrain(pc, pt)
        GRECT           *pc;
        GRECT           *pt;
        {
        if (pt->g_x < pc->g_x)
                pt->g_x = pc->g_x;
        if (pt->g_y < pc->g_y)
                pt->g_y = pc->g_y;
        if ((pt->g_x + pt->g_w) > (pc->g_x + pc->g_w))
                pt->g_x = (pc->g_x + pc->g_w) - pt->g_w;
        if ((pt->g_y + pt->g_h) > (pc->g_y + pc->g_h))
                pt->g_y = (pc->g_y + pc->g_h) - pt->g_h;
        }

        BOOLEAN
inside(x, y, pt)                /* determine if x,y is in rectangle     */
        UWORD           x, y;
        GRECT           *pt;
        {
        if ( (x >= pt->g_x) && (y >= pt->g_y) &&
            (x < pt->g_x + pt->g_w) && (y < pt->g_y + pt->g_h) )
                return(TRUE);
        else
                return(FALSE);
        } /* inside */



Press <CR> to continue !