/* >>>>>>>>>>>>>>>>>>>>>>>>> Sample Redraw Code <<<<<<<<<<<<<<<<<<<<<<<<<<< */

VOID
do_redraw(wh, area)             /* wh = window handle from msg[3] */
WORD    wh;             /* area = pointer to redraw rect- */
GRECT   *area;          /*   tangle in msg[4] thru msg[7] */
{
        GRECT   box;
        
        graf_mouse(M_OFF, 0x0L);
        wind_update(BEG_UPDATE);
        
        wind_get(wh, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
        while ( box.g_w && box.g_h )
        {
                if (rc_intersect(full, &box))     /* Full is entire screen */
                    if (rc_intersect(area, &box))
                    {
                            if (wh == w1_handle)          /* Test for window 1 handle */
                            {             /* AES redraw example       */
                                    objc_draw(w1_tree, ROOT, MAX_DEPTH, box.g_x, 
                                              box.g_y, box.g_w, box.g_h);
                            }
                            else if (wh == w2_handle) /* Test for window 2 handle */
                            {             /* VDI redraw example       */
                                    set_clip(TRUE, &box);
                                    /*  Put VDI drawing calls here */
                            }
                            /* add more windows here */
                    }
                wind_get(wh, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, 
                         &box.g_h);
        }
        
        wind_update(END_UPDATE);
        graf_mouse(M_ON, 0x0L);
}


/* >>>>>>>>>>>>>>>>>>>>>>>> Utilities used in do_redraw <<<<<<<<<<<<<<<<<<<< */

VOID
set_clip(clip_flag, area)       /* set clip to specified area   */
WORD    clip_flag;
GRECT   *area;
{
        WORD    pxy[4];
        
        grect_to_array(area, pxy);
        vs_clip(vdi_handle, clip_flag, pxy);
}

VOID
grect_to_array(area, array)     /* convert x,y,w,h to upr lt x,y and    */
GRECT   *area;          /*                    lwr rt x,y        */
WORD    *array;
{
        *array++ = area->g_x;
        *array++ = area->g_y;
        *array++ = area->g_x + area->g_w - 1;
        *array = area->g_y + area->g_h - 1;
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

/* >>>>>>>>>>>>>>>>>>>>>>> "Self-redraw" Utility <<<<<<<<<<<<<<<<<<<<<<<<< */

VOID
send_redraw(wh, p)
WORD    wh;
GRECT   *p;
{
        WORD    msg[8];
        
        msg[0] = WM_REDRAW;             /* Defined in GEMBIND.H     */
        msg[1] = gl_apid;               /* As returned by appl_init */
        msg[2] = 0;
        msg[3] = wh;                    /* Handle of window to redraw */
        msg[4] = p->g_x;
        msg[5] = p->g_y;
        msg[6] = p->g_w;
        msg[7] = p->g_h;
        appl_write(gl_apid, 16, &msg);  /* Use ADDR(msg) for portability */
}

/* >>>>>>>>>>>>>>>>>>>> Utilities for Window Requests <<<<<<<<<<<<<<<<<< */

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

WORD
align(x,n)              /* Snap position x to an n-bit grid         */ 
WORD    x, n;   /* Use n = 16 for horizontal word alignment */
{
        x += (n >> 2) - 1;              /* Round and... */
        x = n * (x / n);                /* remove residue */
        return (x);
}       

/* >>>>>>>>>>>>>>>>>>>>>>> Window full utility <<<<<<<<<<<<<<<<<<<<<<< */

VOID
hndl_full(wh)           /* depending on current window state, make window    */
WORD    wh;     /*   full size -or- return to previous shrunken size */
{               /* graf_ calls are optional special effects.         */
        GRECT   prev;
        GRECT   curr;
        GRECT   full;
        
        wind_get(wh, WF_CXYWH, &curr.g_x, &curr.g_y, &curr.g_w, &curr.g_h);
        wind_get(wh, WF_PXYWH, &prev.g_x, &prev.g_y, &prev.g_w, &prev.g_h);
        wind_get(wh, WF_FXYWH, &full.g_x, &full.g_y, &full.g_w, &full.g_h);
        if ( rc_equal(&curr, &full) )
        {               /* Is full, change to previous          */
                graf_shrinkbox(prev.g_x, prev.g_y, prev.g_w, prev.g_h,
                               full.g_x, full.g_y, full.g_w, full.g_h);
                wind_set(wh, WF_CXYWH, prev.g_x, prev.g_y, prev.g_w, prev.g_h);
                /* put send_redraw here if you need it */
        }
        else
        {               /* is not full, so set to full          */
                graf_growbox(curr.g_x, curr.g_y, curr.g_w, curr.g_h,
                             full.g_x, full.g_y, full.g_w, full.g_h);
                wind_set(wh, WF_CXYWH, full.g_x, full.g_y, full.g_w, full.g_h);
        }
}

WORD
rc_equal(p1, p2)                /* tests for two rectangles equal       */
GRECT   *p1, *p2;
{
        if ((p1->g_x != p2->g_x) ||
            (p1->g_y != p2->g_y) ||
            (p1->g_w != p2->g_w) ||
            (p1->g_h != p2->g_h))
            return(FALSE);
        return(TRUE);
}
