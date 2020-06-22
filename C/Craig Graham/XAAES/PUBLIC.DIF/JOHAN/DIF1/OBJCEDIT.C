/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "OBJECTS.H"

#if 0
#define CLIP(tree,obj,x,y,w,h) 				\
	object_abs_coords(tree, obj, &x, &y);	\
	w = tree[obj].ob_width;					\
	h = tree[obj].ob_height;				\
	set_clip(x, y, w, h);
#endif

#define CLIP(tree,obj,x,y,w,h)	clear_clip()
#define set_clip(x,y,w,h)		/* We don't want this now! */

#if 0
#undef CLIP            /* Those set_clip(..) can't be useful */
#endif


short XA_objc_edit(short clnt_pid, AESPB *pb)
{
	OBJECT *form = pb->addrin[0];
	short ed_obj = pb->intin[0];
	short keycode = pb->intin[1];
	TEDINFO *ed_txt;
	char *txt;
	short cursor_pos, o, x, y, w, h;
	int key, tmask, n, chg, update = 0;

	ed_txt = (TEDINFO*)form[ed_obj].ob_spec;
	txt = ed_txt->te_ptext;
	cursor_pos = ed_txt->te_tmplen;

	pb->intout[0] = 1;

	switch(pb->intin[3])
	{
	case 0:
		break;
			
	case 1:			/* ED_INIT - set current edit field */
		o = 0;
		do {
			form[o].ob_state &= ~IS_EDIT;
		} while(!(form[++o].ob_flags & LASTOB));
			
		form[ed_obj].ob_state |= IS_EDIT;
		ed_txt->te_tmplen = strlen(txt);
		update = 1;

		break;

	case 2:			/* ED_CHAR - process a character */
		switch(keycode)
		{
		case 0x011b:		/* ESCAPE clears the field */
			txt[0] = '\0';
			ed_txt->te_tmplen = 0;
			update = 1;
			break;
	
		case 0x537f:		/* DEL deletes character under cursor */
			if (txt[cursor_pos])
			{
				for(x = cursor_pos; x < ed_txt->te_txtlen - 1; x++)
					txt[x] = txt[x + 1];
				
				update = 1;
			}
					
			break;
				
		case 0x0e08:		/* BACKSPACE deletes character behind cursor (if any) */
			if (cursor_pos)
			{
				for(x = cursor_pos; x < ed_txt->te_txtlen; x++)
					txt[x - 1] = txt[x];
						
				ed_txt->te_tmplen--;
		
				update = 1;
			}
			break;
					
		case 0x4d00:	/* RIGHT ARROW moves cursor right */
			if ((txt[cursor_pos]) && (cursor_pos < ed_txt->te_txtlen - 1))
			{
				ed_txt->te_tmplen++;
				update = 1;
			}
			break;
	
		case 0x4d36:	/* SHIFT+RIGHT ARROW move cursor to far right of current text */
			for(x = 0; txt[x]; x++) ;

			if (x != cursor_pos)
			{
				ed_txt->te_tmplen = x;
				update = 1;
			}
			break;
				
		case 0x4b00:	/* LEFT ARROW moves cursor left */
			if (cursor_pos)
			{
				ed_txt->te_tmplen--;
				update = 1;
			}
			break;
				
		case 0x4b34:	/* SHIFT+LEFT ARROW move cursor to start of field */
		case 0x4700:	/* CLR/HOME also moves to far left */
			if (cursor_pos)
			{
				ed_txt->te_tmplen = 0;
				update = 1;
			}
			break;

		default:		/* Just a plain key - insert character */
			chg = 0;		/* Ugly hack! */
			if (cursor_pos == ed_txt->te_txtlen - 1) {
				cursor_pos--;
				ed_txt->te_tmplen--;
				chg = 1;
			}
					
			key = keycode & 0xff;
			tmask  = isdigit(key) ? 0x01 : 0;
			tmask |= isalpha(key) ? 0x02 : 0;
			tmask |= isspace(key) ? 0x04 : 0;
			tmask |= isupper(key) ? 0x08 : 0;
			tmask |= ((key == ':') || (key == '\\')) ? 0x10 : 0;
			tmask |= (key == '.') ? 0x20 : 0;
			tmask |= ((key == '?') || (key == '*')) ? 0x40 : 0;

			n = strlen(ed_txt->te_pvalid) - 1;
			if (cursor_pos < n)
				n = cursor_pos;

			switch(ed_txt->te_pvalid[n]) {
			case '9':
				tmask &= 0x01;
				break;
			case 'a':
				tmask &= 0x06;
				break;
			case 'n':
				tmask &= 0x07;
				break;
			case 'p':
				tmask &= 0x17;
				key = toupper((char)key);
				break;
			case 'A':
				tmask &= 0x0c;
				key = toupper((char)key);
				break;
			case 'N':
				tmask &= 0x0d;
				key = toupper((char)key);
				break;
			case 'F':
				tmask &= 0x57;
				key = toupper((char)key);
				break;
			case 'P':
				tmask &= 0x77;
				key = toupper((char)key);
				break;
			case 'X':
				tmask = 1;
				break;
			case 'x':
				tmask = 1;
				key = toupper((char)key);
				break;
			default:
				tmask = 0;
				break;			
			}
			
			if (!tmask) {
				for(n = x = 0; ed_txt->te_ptmplt[n]; n++) {
			   		if (ed_txt->te_ptmplt[n] == '_')
						x++;
					else if ((ed_txt->te_ptmplt[n] == key)
						&& (x >= cursor_pos))
						break;
				}
				if (key && (ed_txt->te_ptmplt[n] == key)) {
					for(n = cursor_pos; n < x; n++)
							txt[n] = ' ';
					txt[x] = '\0';
					ed_txt->te_tmplen = x;
				} else {
					ed_txt->te_tmplen += chg;		/* Ugly hack! */
					return(TRUE);
				}
			} else {
				txt[ed_txt->te_txtlen - 2] = '\0';	/* Needed! */
				for(x = ed_txt->te_txtlen - 1; x > cursor_pos; x--)
					txt[x] = txt[x - 1];

				txt[cursor_pos] = (char)key;
	
				ed_txt->te_tmplen++;
			}
	
			update = 1;
			break;
		}
		pb->intout[1] = ed_txt->te_tmplen;
		break;
			
	case 3:		/* ED_END - turn off the cursor */
		form[ed_obj].ob_state &= ~IS_EDIT;
		update = 1;
		break;
	}
	if (update) {		/* Moved from a number of places above. */
		CLIP(form, ed_obj, x, y, w, h);
		v_hide_c(V_handle);
		draw_object_tree(form, ed_obj, MAX_DEPTH);
		v_show_c(V_handle, 1);

		pb->intout[1] = ed_txt->te_tmplen;
	}
	
	return TRUE;
}
