global
short ed_char(TEDINFO *ed_txt, short keycode)
{
	char *txt = ed_txt->te_ptext;
	short cursor_pos = ed_txt->te_tmplen,
		  o, x, key, tmask, n, chg, update = 0;

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
			for (x = cursor_pos; x < ed_txt->te_txtlen - 1; x++)
				txt[x] = txt[x + 1];
			
			update = 1;
		}
		break;
			
	case 0x0e08:		/* BACKSPACE deletes character behind cursor (if any) */
		if (cursor_pos)
		{
			for (x = cursor_pos; x < ed_txt->te_txtlen; x++)
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
		for (x = 0; txt[x]; x++)
			;

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
		if (cursor_pos == ed_txt->te_txtlen - 1)
		{
			cursor_pos--;
			ed_txt->te_tmplen--;
			chg = 1;
		}
				
		key = keycode & 0xff;
		tmask = character_type[key];

		n = strlen(ed_txt->te_pvalid) - 1;
		if (cursor_pos < n)
			n = cursor_pos;

		switch(ed_txt->te_pvalid[n])
		{
		case '9':
			tmask &= CGd;
			break;
		case 'a':
			tmask &= CGa|CGs;
			break;
		case 'n':
			tmask &= CGa|CGd|CGs;
			break;
		case 'p':
			tmask &= CGa|CGd|CGp|CGxp;
			/*key = toupper((char)key);*/
			break;
		case 'A':
			tmask &= CGa|CGs;
			key = toupper((char)key);
			break;
		case 'N':
			tmask &= CGa|CGd|CGs;
			key = toupper((char)key);
			break;
		case 'F':
			tmask &= CGa|CGd|CGp|CGxp|CGw;
			/*key = toupper((char)key);*/
			break;
		case 'f':
			tmask &= CGa|CGd|CGp|CGxp|CGw;
			/*key = toupper((char)key);*/
			break;
		case 'P':
			tmask &= CGa|CGd|CGp|CGxp|CGw;
			/*key = toupper((char)key);*/
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
		
		if (!tmask)
		{
			for (n = x = 0; ed_txt->te_ptmplt[n]; n++)
			{
		   		if (ed_txt->te_ptmplt[n] == '_')
					x++;
				else if ((ed_txt->te_ptmplt[n] == key)
					&& (x >= cursor_pos))
					break;
			}
			if (key && (ed_txt->te_ptmplt[n] == key))
			{
				for (n = cursor_pos; n < x; n++)
					txt[n] = ' ';
				txt[x] = '\0';
				ed_txt->te_tmplen = x;
			} else
			{
				ed_txt->te_tmplen += chg;		/* Ugly hack! */
				return XAC_DONE;
			}
		} else
		{
			txt[ed_txt->te_txtlen - 2] = '\0';	/* Needed! */
			for (x = ed_txt->te_txtlen - 1; x > cursor_pos; x--)
				txt[x] = txt[x - 1];

			txt[cursor_pos] = (char)key;

			ed_txt->te_tmplen++;
		}

		update = 1;
		break;
	}

	return update;
}
