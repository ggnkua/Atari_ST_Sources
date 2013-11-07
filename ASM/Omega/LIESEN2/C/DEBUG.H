/****************************************************** D E B U G */
int debug_obj(const OBJECT *obj)
{
	obj->ob_state^=1;
	printf("\x1BE");
	printf("\nNext      %d",obj->ob_next);
	printf("\nHead      %d",obj->ob_head);
	printf("\nTail      %d",obj->ob_tail);
	printf("\nType      %u",obj->ob_type);
	printf("\nFlags     %4lX",obj->ob_flags);
	printf("\nState     %4lX",obj->ob_state);

	printf("\nSpecific  %8lX",obj->ob_spec.index);

	printf("\nX         %d",obj->ob_x);
	printf("\nY         %d",obj->ob_y);
	printf("\nWhidth    %d",obj->ob_width);
	printf("\nHight     %d",obj->ob_height);

	evnt_keyb();
}

int debug_tedinfo(const TEDINFO *ted)
{
	printf("\x1bE");
	printf("\nPtext     %s",ted->te_ptext);
	printf("\nPtmplt    %s",ted->te_ptmplt);
	printf("\nPvalid    %s",ted->te_pvalid);
	printf("\nFont      %d",ted->te_font);
	printf("\nJunk1     %d",ted->te_junk1);
	printf("\nJustif.   %d",ted->te_just);
	printf("\nColor     %d",ted->te_color);
	printf("\nJunk2     %d",ted->te_junk2);
	printf("\nThickness %d",ted->te_thickness);
	printf("\nTxtlen    %d",ted->te_txtlen);
	printf("\nTmplen    %d",ted->te_tmplen);
	evnt_keyb();
}
