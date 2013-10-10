/* adjust object colors if it is invalid */

adjdcol(color)
unsigned int color;
{
    OBJECT  *obj;

    if (gl_ws[13] > LWHITE)
	return;

    obj = get_tree(ADFILEIN);
    obj[FILEFT].ob_spec = (obj[FILEFT].ob_spec & 0xfffffff0) | color;
    obj[FIRIGHT].ob_spec = (obj[FIRIGHT].ob_spec & 0xfffffff0) | color;

    obj = get_tree(ADINSDIS);
    obj[IUP].ob_spec = (obj[IUP].ob_spec & 0xfffffff0) | color;
    obj[IDOWN].ob_spec = (obj[IDOWN].ob_spec & 0xfffffff0) | color;

    obj = get_tree(ADFORMAT);
    obj[SRCDRA].ob_spec = (obj[SRCDRA].ob_spec & 0xfffffff0) | color;
    obj[SRCDRB].ob_spec = (obj[SRCDRB].ob_spec & 0xfffffff0) | color;
    obj[ADRIVE].ob_spec = (obj[ADRIVE].ob_spec & 0xfffffff0) | color;
    obj[BDRIVE].ob_spec = (obj[BDRIVE].ob_spec & 0xfffffff0) | color;

    obj = get_tree(INWICON);
    obj[WUP].ob_spec = (obj[WUP].ob_spec & 0xfffffff0) | color;
    obj[WDOWN].ob_spec = (obj[WDOWN].ob_spec & 0xfffffff0) | color;

    obj = get_tree(SSYSTEM);
    obj[SDLEFT].ob_spec = (obj[SDLEFT].ob_spec & 0xfffffff0) | color;
    obj[SDRIGHT].ob_spec = (obj[SDRIGHT].ob_spec & 0xfffffff0) | color;
    obj[SDUP].ob_spec = (obj[SDUP].ob_spec & 0xfffffff0) | color;
    obj[SDDOWN].ob_spec = (obj[SDDOWN].ob_spec & 0xfffffff0) | color;
    obj[MKUP].ob_spec = (obj[MKUP].ob_spec & 0xfffffff0) | color;
    obj[MKDOWN].ob_spec = (obj[MKDOWN].ob_spec & 0xfffffff0) | color;
}


adjgcol(color)
unsigned int color;
{
    OBJECT  *obj;
    int	    i;

    if (gl_ws.ws_ncolors > LWHITE)
	return;

    rs_gaddr(ad_sysglo, R_TREE, SELECTOR, &obj);
    obj[FCLSBOX].ob_spec = (obj[FCLSBOX].ob_spec & 0xfffffff0) | color;
    obj[FUPAROW].ob_spec = (obj[FUPAROW].ob_spec & 0xfffffff0) | color;
    obj[FDNAROW].ob_spec = (obj[FDNAROW].ob_spec & 0xfffffff0) | color;
    obj[FSVELEV].ob_spec = (obj[FSVELEV].ob_spec & 0xfffffff0) | color;

    for (i = DRIVEA; i <= DRIVEP; i++)
	obj[i].ob_spec = (obj[i].ob_spec & 0xfffffff0) | color;
}

