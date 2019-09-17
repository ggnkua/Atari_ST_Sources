>>>>>>>>>>>>>>>> Routines to set clip to a GRECT <<<<<<<<<<<<<<<<

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

        VOID
set_clip(clip_flag, s_area)     /* set clip to specified area           */
        WORD    clip_flag;
        GRECT   *s_area;
        {
        WORD    pxy[4];

        grect_to_array(s_area, pxy);
        vs_clip(vdi_handle, clip_flag, pxy);
        }

>>>>>>>>>> Routines to set attributes before output <<<<<<<<<<<<

        VOID
rr_perim(mode, color, type, width, pxy)      /* Draw a rounded    */
        WORD    mode, color, width, *pxy;    /* rectangle outline */
        {
        vswr_mode(vdi_handle, mode);
        vsl_color(vdi_handle, color);
        vsl_type(vdi_handle, type);
        vsl_width(vdi_handle, width);
        v_rbox(vdi_handle, pxy);
        vswr_mode(vdi_handle, MD_REPLACE);
        }

        VOID
pl_perim(mode, type, color, width, npts, pxy)     /* Draw a polygonal */
                                                  /* figure           */
        WORD    mode, type, color, width, npts, *pxy;
        {
        vswr_mode(vdi_handle, mode);
        vsl_type(vdi_handle, type);
        vsl_color(vdi_handle, color);
        vsl_width(vdi_handle, width);
        v_pline(vdi_handle, npts, pxy);
        }

        VOID                  /* Draw a filled polygonal area */
pl_fill(mode, perim, color, interior, style, npts, pxy)
        WORD    mode, perim, color, interior, style, npts, *pxy;
        {
        vswr_mode(vdi_handle, mode);
        vsf_color(vdi_handle, color);
        vsf_style(vdi_handle, style);
        vsf_interior(vdi_handle, interior);
        vsf_perimeter(vdi_handle, perim);
        v_fillarea(vdi_handle, npts, pxy);
        }

        VOID                  /* Draw a filled rectangle    */
rect_fill(mode, perim, color, interior, style, pxy)
        WORD    mode, perim, color, style, interior, *pxy;
        {
        vswr_mode(vdi_handle, mode);
        vsf_color(vdi_handle, color);
        vsf_style(vdi_handle, style);
        vsf_interior(vdi_handle, interior);
        vsf_perimeter(vdi_handle, perim);
        vr_recfl(vdi_handle, pxy);
        }

