/************************************************************************/
/*									*/
/*	overrg.c is a overlay error message output routine for the	*/
/*	gem graphic envioroument.  When in use,  gembind.o should	*/
/*	be presented in the linker file list.				*/
/************************************************************************/
char msg[256];
char msgtail[] = "][ OK ]";
ov_err(errmsg, filname)
char *errmsg, *filname;
{
    register char *p, *q;

    p = errmsg;
	q = msg;
	*q++ = '['; *q++ = '3'; *q++ = ']'; *q++ = '[';
    while(*p)
    	*q++ = *p++;
    *q++ = '|';
    p = filname;
    while(*p)
    	*q++ = *p++;
    p = msgtail;
    while(*p)
    	*q++ = *p++;
	*q = '\0';
    form_alert(1, msg);
}    
