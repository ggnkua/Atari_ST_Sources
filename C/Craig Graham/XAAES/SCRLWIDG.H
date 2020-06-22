#ifndef _SCRLWIDG_H_
#define _SCRLWIDG_H_

short display_lscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short display_rscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short display_uscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short display_dscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short click_lscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short click_rscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short click_uscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short click_dscroll(XA_WINDOW *wind, XA_WIDGET *widg);
short display_vslide(XA_WINDOW *wind, XA_WIDGET *widg);
short display_hslide(XA_WINDOW *wind, XA_WIDGET *widg);
short drag_vslide(XA_WINDOW *wind, XA_WIDGET *widg);
short drag_hslide(XA_WINDOW *wind, XA_WIDGET *widg);

#endif