/*
	This module handles the Text Window commands
*/
/************************************************************************/
/* HISTORY								*/
/* 									*/
/* 11/07/89  -  Replace all scale_iv() with scaler()			*/
/*		TWslider_chk()  -   "      "           "                */
/*		TWsliderH()	-   "      "           " 		*/
/*		TWhslide()	-   "      "	       "		*/
/************************************************************************/
#include	"gemdefs.h"
#include	<obdefs.h>
#include	"defs.h"
#include	"keys.h"
#include	"dbase.h"
#include	"deskset2.h"

#define		MIN_LEFT	10	/* minimum edit space left	*/
#define		MIN_FREE	80L	/* minimum editing space	*/
#define		BLTAG		17	/* beginning Local Tag number	*/
#define		NUMTAG		200	/* total number of Tags...	*/

extern	int		txt_handle;		/* TWindow handle	*/
extern	GRECT		twork;			/* TWindow work area	*/
extern	int		gl_hchar;		/* Text char height	*/
extern	int		gl_wchar;		/* Text char width	*/
extern	int		*gcurx;			/* Ptr to mouse x	*/
extern	int		*gcury;			/* Ptr to mouse y	*/
extern	int		msg_buff[];		/* evnt_multi buffer	*/
extern	int		gl_apid;		/* ID for appl_write	*/
extern	REGION		*gl_region_ptr;		/* current Region Ptr	*/
extern	int		force_draw_flag;	/* Force redraw on Prev	*/
extern	OBJECT		*ad_menu;		/* OBJECT for menu bar	*/
extern	int		BSTATE;			/* Button State...	*/
extern	char		*get_edit();

extern	char		nuls[];			/* null string (GOG)	*/
extern	unsigned char	*setwptr(), *skiptag(), *malloc(), *toeofline();
extern	unsigned char	mapkbd(), getfp(), toupper(), getLch();
extern	int		rewrite_line(), wdw_eol();
extern	unsigned	cb_size;		/* Copy buffer size	*/
extern	int		TWhclip;		/* TWindow horiz. clip	*/
extern	unsigned char	*prvp1(), *prvp2();

static	unsigned char	*last_one;		/* last match pointer	*/
static	unsigned char	lkey;			/* last		cmd key	*/
static	unsigned char	ckey;			/* current	cmd key	*/
static	unsigned char	last_again	= 0;	/* Last Again command	*/
static	unsigned char	search_stg [52]	= {0};	/* Search	String	*/
static	unsigned char	replace_stg[52] = {0};	/* Replace	String	*/
static	char		Ins_Tag		= 0;	/* in Insert Tag mode	*/
static	int		inIOm		= 1;	/* Editor Ins/OvW flag	*/
static	unsigned char	mrkfbrk;		/* Mark fctN break char */

ARTICLE		*TWart_ptr	= (ARTICLE *)0;	/* TW current article	*/
char		TWaltered	= 0;		/* TWindow altered flag	*/
unsigned char	**upd_ptr	= (char **)0;	/* region ptr tag array	*/
int		upd_tags;			/* # of ptrs in array	*/
int		mrkfctN		= 0;		/* current Mark functN	*/
int		last_tag	= BLTAG;	/* Last used Local Tag	*/
int		TWVSLpos	= 0;		/* TW VSlider position	*/
int		TWVSLsize	= 1000;		/* TW VSlider size	*/

/*
	Text Window arrow function handler
*/
TW_arrow(action)
int	action;
{
	int	hmove;

	if (!TWart_ptr)
		return;
	switch(action) {
	case WA_UPPAGE:  
		pageup_cmd();
		break;
	case WA_DNPAGE: 
		pagedown_cmd();
		break;
	case WA_UPLINE:
		up_cmd(current.row + 1);
		break;
	case WA_DNLINE:
		down_cmd(current.mrow - current.row);
		break;
	case WA_LFPAGE:
		hmove = (TWhclip > current.mcol) ? current.mcol:TWhclip;
		goto toL;
	case WA_RTPAGE:
		hmove = current.mcol;
		goto toR;
	case WA_LFLINE:
		hmove = 1;
toL:		if (TWhclip)
			left_cmd(current.col + hmove);
		break;
	case WA_RTLINE:
		hmove = 1;
toR:		if (current.mcol < wdw_cols)
			TWmoveRight(TWhclip + hmove,hmove);
		break;
	}
}

/*
	Text Window mouse button handler
*/
TW_button()
{
	int	xcur, ycur, maxcol;
	int	xdiff, ydiff;
	unsigned tagn;

	if (!TWart_ptr || !xyinTW(*gcurx,*gcury))
		return(0);
	xcur	= *gcurx - (twork.g_x + gl_wchar);
	if (xcur < 0)
		return(0);
	xcur	/= gl_wchar;
	ycur	= *gcury - twork.g_y;
	ycur	/= gl_hchar;
	if (ydiff = abs(current.row - ycur)) {	/* check move y first	*/
		if (current.row > ycur) {
			if (free_start != buf_start)
				backup(ydiff);
			else	ydiff = 0;
		}
		else {
			if (current_char != buf_end)
				forup(ydiff);
			else	ydiff = 0;
		}
	}
	maxcol = nchartoEline();		/* ultimate line column	*/
	if (ydiff) {				/* if y been moved...	*/
		if (maxcol) {
			xdiff	= TWhclip + xcur;
			right_cmd(xdiff > maxcol ? maxcol:xdiff);
		}
		else	nscr(0);
	}
	else
	if (xdiff = abs(current.col - xcur)) {	/* move x only on line	*/
		if (current.col > xcur)
			left_cmd(xdiff);
		else	right_cmd(xdiff > maxcol ? maxcol:xdiff);
	}
	if (mrkfctN) {
		if (BSTATE == 2) {
			ckey = mrkfbrk;
			return(1);
		}
	}
	else
	if (!Ins_Tag) {
	  if (ptagc(*current_char))		/* if cursor at Pi TAG	*/
		PiTag_cmd(*(current_char + 1));
	  else
	  if (ctagc(*current_char)) {		/* or cursor at Cp TAG	*/
		tagn = *(current_char + 1) + 1;
/*		if (tagn >= BLTAG)
			last_tag = tagn;	*/
		do_tag(tagn,0);
	  }
	}
	return(0);
}

/*
	Text Window Top menu handler
*/
TW_menu(item)
int	item;
{
	menu_tnormal(ad_menu,TEXT,1);
	switch(item) {
	case SELART:	ckey = ATS;	break;
	case GETXT:	ckey = ATG;	break;
	case DELTXT:	ckey = ATD;	break;
	case BUFTXT:	ckey = ATB;	break;
	case CPYTXT:	ckey = ATC;	break;
	case FORFIND:	ckey = ATF;	break;
	case REVFIND:	ckey = ATV;	break;
	case RPLC:	ckey = ATR;	break;
	case SETMARK:	ckey = ATM;	break;
	case JPMARK:	ckey = ATJ;	break;
	case INSTAG:	ckey = ATT;	break;
	case INSLTAG:	ckey = ATL;	break;
	case DELTAG:	ckey = ATX;	break;
	}
	return(TW_Cmds());
}

/*
	Function to process Text window Keyboard commands
	for Cursor/Text/File scrolling and single character
	deletion.
*/
TW_Keys()
{
	int	found = true;

	if (!TWart_ptr)
		return(0);
	switch(ckey) {
	case bol_char:		bol_cmd();		break;
	case eol_char:		eol_cmd();		break;
	case NextWord_char:	skip_word(1);		break;
	case PrevWord_char:	skip_word(0);		break;
	case left_char:		left_cmd(1);		break;
	case right_char:	right_cmd(1);		break;
	case up_char:		up_cmd(1);		break;
	case down_char:		down_cmd(1);		break;
	case pageup_char:	pageup_cmd();		break;
	case pagedown_char:	pagedown_cmd();		break;
	case bs:		rubout_char();		break;
	case Del_char:		kill_char();		break;
	case bof_char:		bof_cmd();		break;
	case eof_char:		eof_cmd();		break;
	default :		found = false;		break;
	}
	lkey = ckey;
	if (found) flush_kbd();
	return(found);
}

/*
	Function to process Text window Alpha commands
*/
TW_Cmds()
{
	int	found = true;

	if (!TWart_ptr && ckey != ATS)		/* if no article then	*/
		return(0);			/* can select it...	*/
	switch(ckey) {
	case ATA:
		Again_cmd();			/* from keyboard only	*/
		break;
	case ATF: case ATR: case ATV:
		if (FindReplace_cmd(1L,ckey == ATF ? 1:ckey == ATR ? 2:3))
			last_again = ckey;
		else	last_again = 0;
		break;
	case ATJ: case ATM:
		JumpMrk_cmd(ckey == ATM);
		break;
	default :
		if (mrkfctN)
			found = false;
		else
		switch(ckey) {
		case ATD:
			Delete_cmd();	break;
		case ATB:
			Buffer_cmd();	break;
		case ATT:
		case ATL:
			InsTag_cmd(ckey);break;
		case Ins_char:
			inIOm = !inIOm;		/* from keyboard only	*/
			TW_state();	break;
		case ATS:
			SelArt_cmd();	break;
		case ATG:
			Get_cmd();	break;
		case ATC:
			Copy_cmd();	break;
		case ATX:
			DelTag_cmd();	break;
		case ATP:
			PiTag_cmd(1);	break;
		default :
			found = false;	break;
		}
		break;
	}
	return(found);
}

/*
	Input routine when in Ins/Ovw mode or Block functions
	Returns 0 for Abort or 1 for valid character.
*/
Ikey()
{
	int	ret;			/* dummy variable	*/
	int	event;			/* which event returned	*/
	int	check;			/* check mark mode flag	*/
	unsigned kstat;			/* Kbd shift state	*/
	unsigned kcode;			/* Kbd return code	*/

	if (check_TWtop()) while (1) {
	  wind_update(check = false);
	  event = evnt_multi(MU_MESAG | MU_KEYBD | MU_BUTTON,
		1,1,1,
		0,0,0,0,0,
		0,0,0,0,0,
		msg_buff,0,0,&ret,&ret,&ret,&kstat,&kcode,&ret);
	  wind_update(true);
	  if (event & MU_MESAG) {
		if (msg_buff[0] == MN_SELECTED) {
		  if (msg_buff[3] == TEXT) {	/* check for TW menu	*/
			if (!TW_menu(msg_buff[4]) &&
			     TWart_ptr && mrkfctN)
				check = true;

		  }
		  else	menu_handler(msg_buff[3],msg_buff[4]);
		}
		else	mesag_handle(msg_buff);	/* else go to handler	*/
	  }
	  if (!check_TWtop() && !TWart_ptr)
		return(0);
	  if (event & MU_KEYBD) {
		ckey = mapkbd(kstat,kcode);
		if (!TW_Keys() && !TW_Cmds() && TWart_ptr) {
			if (mrkfctN)
				check = true;
			else
			if (dscck())
				return(1);
		}
	  }
	  if (event & MU_BUTTON)
		check = TW_button();
	  if (check && (ret = mark_Key()))
		return(ret - 1);
	}
	else	return(0);
}

/*
	Routine to scan for valid DeskSet character codes
*/
dscck()
{
	return( (ckey >= 0x20 && ckey <= 0xbf)	||
		(ckey >= 0xf0 && ckey <= 0xfe)	||
		nocp(ckey) );
}

/*
	Routine to check for abort or close command in mark block mode
*/
mark_Key()
{
	if (ckey == esc || ckey == ctl_C)
		return(1);
	else
	if (ckey == mrkfbrk)
		return(2);
	else	return(0);
}

/*
	Function to move forward in the text buffer.
	Returns updated pointer.
*/
unsigned char *mvfwd(ptr)
unsigned char *ptr;
{
	switch(*ptr) {
	case hrt: case srt: case Rf:
		ptr += 3;
		break;
	default:
		ptr = skiptag(ptr);
		if (*ptr != cr)
			break;
	case cr:
		ptr += 2;
		break;
	}
	return(ptr);
}

/*
	Function to move backward in the text buffer.
	Returns updated pointer.
*/
unsigned char *mvbwd(ptr)
unsigned char *ptr;
{
	if (tagc(*(ptr-2)))
		ptr -= 2;
	else
	if (*(--ptr) == lf) {
		ptr -= 2;
		if (tagc(*(ptr-1)))
			--ptr;
	}
	return(ptr);
}

/*
	Function to delete from current char to tag
*/
delete_chars(tag)
int	tag;
{
	if (current_char > wdw_ptr[tag])		/* for first buffer  */
		free_start	= wdw_ptr[tag];
	else	current_char	= wdw_ptr[tag];
	if (wdw_ptr[top_line] >= free_start &&		/* if deleting line1 */
	    wdw_ptr[top_line] < current_char)
		setwptr(top_line);
	TWrewindow(current_char);
	nsline();
	if (tag == HMRK)
		ckTWsliderV();
	TWaltered = true;
}

/*
	Function to check edit buffer limit. Returns true/false
*/
Infsp()
{
	if (nofsp()) {
		beep();
		do_alert(BFERR1);
		return(0);
	}
	return(1);
}

/*
	Function to change an alpha character to the other case.
	Returns new or old character.
*/
static	char unc(c)
char	c;
{
	if (c >= 'a' && c <= 'z') c -= 0x20;
	else
	if (c >= 'A' && c <= 'Z') c += 0x20;
	return(c);
}

/*
	Function to forward find a string.
	Returns last search pointer.
*/
unsigned char	*f_find(chr, target, count)
unsigned char	chr, *target;
unsigned long	count;
{
	unsigned char	cchr;
	++count;
	cchr = setp.cign ? unc(chr):chr;
	while (count-- && *target != chr && *target != cchr) ++target;
	return(target);
}

/*
	Function to reverse find a string.
	Returns last search pointer.
*/
unsigned char	*r_find(chr, target, count)
unsigned char	chr, *target;
unsigned long	count;
{
	unsigned char	cchr;
	++count;
	cchr = setp.cign ? unc(chr):chr;
	while (count-- && *target != chr && *target != cchr) --target;
	return(target);
}

/*
	Function to match a text string in search_stg to the data from ptr.
	Direction denotes forward if true or backward if false.
*/
match_string(ptr,direction)
unsigned char	*ptr;
int		direction;
{
	unsigned char	*target, *source;
	int		len;

	if (direction) {
	  target = &search_stg[0];
	  source = ptr;
	  while (*target) {
	    if (setp.cign) {
		if (toupper(*target) != toupper(*source)) break;
	    }
	    else if (*target != *source) break;
	    ++target; ++source;
	    if (source > buf_end) break;
	  }
	  if (!*target) {
		last_one = source;
		return(true);
	  }
	  else	return(false);
	}
	else {
	  if ((len = strlen(search_stg)) == 1) {
		last_one = ptr;
		return(true);
	  }
	  target = &search_stg[len-1];
	  source = ptr;
	  while (target >= search_stg) {
	    if (setp.cign) {
		if (toupper(*target) != toupper(*source)) break;
	    }
	    else if (*target != *source) break;
	    --target; --source;
	    if (source < buf_start) break;
	  }
	  if (target == search_stg - 1) {
		last_one = source + 1;
		return(true);
	  }
	  else	return(false);
	}
}

/*
	Function to perform a Cursor-Up command
*/
up_cmd(count)
int	count;
{
	if (free_start == buf_start)
		return;
	if (backup(count) == count)
		movetoCcol();
	nscr(0);
}

/*
	Function to perform a Cursor-Down command
*/
down_cmd(count)
int	count;
{
	if (current_char == buf_end)
		return;
	if (forup(count) == count)
		movetoCcol();
	nscr(0);
}

/*
	Function to perform a Cursor-Left command
*/
left_cmd(count)
int	count;
{
	unsigned char *ptr = free_start;
	if (ptr == buf_start)
		return;
	while (count-- && ptr > buf_start)
		ptr = mvbwd(ptr);
	rwnscr(ptr,0);
}

/*
	Function to perform a Cursor-Right command
*/
right_cmd(count)
int	count;
{
	unsigned char *ptr = current_char;
	if (ptr == buf_end)
		return;
	while (count-- && ptr < buf_end)
		ptr = mvfwd(ptr);
	rwnscr(ptr,0);
}

/*
	Function to perform a Beginning of Line command by Shift Left
*/
bol_cmd()
{
	if (lkey == bol_char) {
		ckey = 0;
		if (wdw_ptr[top_line] == current_char)
			return;
		TWrewindow(wdw_ptr[top_line]);	/* to top of screen instead  */
	}
	else {
		if (wdw_ptr[cur_line()] == current_char)
			return;
		backup(0);			/* beginning of current line */
	}
	nscr(0);
}

/*
	Function to perform a End of Line command by Shift Right
*/
eol_cmd()
{
	if (lkey == eol_char) {
		ckey = 0;
		if (current.row == current.mrow - 1)
			return;
		TWrewindow(wdw_ptr[bot_line()]);	/* to the last line  */
	}
	else {
		if (lpend(current_char))
			return;
		forup(0);			/* to end of current line    */
	}
	nscr(0);
}

/*
	Function to perform a Page-Up command by Shift Up
*/
pageup_cmd()
{
	if (current_char == buf_start)
		return;
	TWrewindow(wdw_ptr[top_line]);
	backup(current.mrow - 3);
	nscr(1);
}

/*
	Function to perform a Page-Down command by Shift Down
*/
pagedown_cmd()
{
	if (current_char == buf_end)
		return;
	TWrewindow(wdw_ptr[bot_line()]);
	forup(3);
	nscr(1);
}

/*
	Function to perform a Beginning of File command by Ctl Up
*/
bof_cmd()
{
	if (current_char == buf_start)
		return;
	rwnscr(buf_start,1);
}

/*
	Function to perform an End of File command by Ctl Down
*/
eof_cmd()
{
	if (current_char == buf_end)
		return;
	rwnscr(buf_end,1);
}

/*
	Function to find forward or backward the next word
	by Ctl Right or Left
*/
skip_word(direction)
int	direction;
{
	unsigned char	*ptr;
	
	if (direction) {			/* either forwards	*/
		if (current_char == buf_end)
			return;
		ptr = current_char;
		while ( ptr < buf_end &&	/* skip current word	*/
			(calpha(*ptr) || cdigit(*ptr)) )
			++ptr;
		while ( ptr < buf_end &&	/* skip to next word	*/
			!calpha(*ptr) && !cdigit(*ptr) )
			ptr = skiptag(ptr);
	}
	else {					/* or backwards		*/
		if (free_start == buf_start)
			return;
		ptr = free_start;
		while ( ptr > buf_start &&	/* skip current word	*/
			!tagc(*(ptr-2)) &&
			(calpha(*(ptr-1)) || cdigit(*(ptr-1))) )
			--ptr;
		while ( ptr > buf_start ) {	/* scan for prev word	*/
			if (tagc(*(ptr-2)))
				ptr -= 2;
			else
			if (!calpha(*(ptr-1)) && !cdigit(*(ptr-1)))
				--ptr;
			else	break;
		}
		if (ptr > buf_start) --ptr;	/* set to end of word	*/
	}
	rwnscr(ptr,0);
}

/*
	Function to delete a character at cursor
*/
kill_char()
{
	int		nline;
	unsigned char	*ptr = current_char;
	if (ptr < buf_end) {
		if (ctagc(*ptr))
			return(right_cmd(1));
		else
		if (nline = allend(*ptr))
			ptr += 3;
		else
		if (ptagc(*ptr) ||
		   (nline = (*(++ptr) == cr)))
			ptr += 2;
		if (ptr <= buf_end) {
			wdw_ptr[TMP1] = ptr;
			delete_chars(TMP1);
			if (nline) ckTWsliderV();
		}
	}
}

/*
	Function to delete a character prior to the cursor
*/
rubout_char()
{
	int		nline = 0;
	unsigned char	*ptr = free_start;
	if (ptr > buf_start) {
		if (ctagc(*(ptr-2)))
			return(left_cmd(1));
		else
		if (ptagc(*(ptr-2)))
			ptr -= 2;
		else
		if (nline = (*(--ptr) == lf)) {
			ptr -= 2;
			if (tagc(*(ptr-1)))
				++ptr;
		}
		if (ptr >= buf_start) {
			setwptr(TMP1);
			TWrewindow(ptr);
			delete_chars(TMP1);
			if (nline) ckTWsliderV();
		}
	}
}

/*
	Command to perform global search (forward or backward)
	then optionally replace with user string after match.
	Can be repeated by user specified number of times.
*/
FindReplace_cmd(repeat,direction)
unsigned long	repeat;
int		direction;
{
	OBJECT		*dialog;
	int		bxobj, stobj, exobj, abobj, ulobj;
	int		i, status, mod, slen, rlen;
	unsigned long	begcnt;
	unsigned char	*ptr;

	mod = abs(direction);
	if (direction < 0) goto FR_ag;			/* detect Again mode */
	if (mod == 1)					/* for 1, Find	     */
	  bxobj = FIND, stobj = FFST,
	  ulobj = FDUL, abobj = FDNOK;
	else
	if (mod == 2)					/* for 2, Replace    */
	  bxobj = RPLACE, stobj = RFST,
	  ulobj = RPUL,   abobj = RPNOK;
	else						/* for 3, Rev. find  */
	  bxobj = RFIND, stobj = RVST,
	  ulobj = RVFUL, abobj = RVFNOK;

	rsrc_gaddr(0,bxobj,&dialog);
	dialog[ulobj].ob_state = setp.cign ? SELECTED:NORMAL;
	set_tedit(dialog,stobj,search_stg);
	if (mod == 2)					/* for Replace only  */
		set_tedit(dialog,RRST,replace_stg);

	exobj = execform(dialog,0);
	dialog[exobj].ob_state = NORMAL;
	if (exobj == abobj)
		return(false);
	BWredraw();					/* redraw T/P Window */
	setp.cign = (dialog[ulobj].ob_state == SELECTED);
	strcpy(search_stg,get_edit(dialog,stobj));
	if (mod == 2) {					/* for Replace only  */
		strcpy(replace_stg,get_edit(dialog,RRST));
		if (exobj == RPALL)
			repeat = -1L;
	}

FR_ag:	if (!*search_stg)
		return(false);				/* nothing to find   */
	slen = strlen(search_stg);			/* use search length */
	last_one = current_char;
	ptr = mod < 3 ? current_char:free_start-1;
	status = true;
	begcnt = repeat - 1;

	while (repeat--) {
	  if (mod < 3) while (1) {			/* forward search... */
	    if ( ptr >= buf_end ||
		(ptr = f_find(search_stg[0],ptr,(long)(buf_end - ptr) + 1))
			>= buf_end ) {
FR_nf:		if (repeat == begcnt)
			do_alert(FRNFD);
		status = false;
		goto FR_ex;
	    }
	    else if (match_string(ptr,1)) {
		if (mod == 1) {			/* for fwd search only done  */
			if (repeat) ++ptr; break;
		}				/* else do string replace... */
		TWrewindow(ptr);		/* string is at current char */
		rlen = strlen(replace_stg);
		if (free_start + rlen >= current_char + slen - MIN_LEFT) {
			do_alert(FRBFE);
			status = false;
			goto FR_ex;
		}
		i = cur_line();
		if (wdw_ptr[i] == current_char)
			wdw_ptr[i] = free_start;
		current_char += slen;			/* delete old one... */
		strcpy(free_start,replace_stg);
		free_start += rlen;			/* & insert new one. */
		ptr = current_char;
		TWaltered = true;			/* mark text altered */
		break;
	    }
	    else ++ptr;
	  }
	  else while (1) {				/* reverse search... */
	    if (ptr <= buf_start ||
		(ptr = r_find(search_stg[slen-1],ptr,(long)(ptr - buf_start)))
			<= buf_start )
			goto FR_nf;
	    else if (match_string(ptr,0)) {
		if (repeat) --ptr; break;
	    }
	    else --ptr;
	  }
	}
FR_ex:	TWrewindow(last_one);
	if (mod == 1 || mod == 3)		/* for Forward/Reverse Find  */
		Creview(0);
	else {					/* else for Replace only...  */
		for (i = bot_line();i > top_line;--i)
			if (wdw_ptr[i]) break;		/* ensure new screen */
		Creview(last_one < wdw_ptr[i] ? 3:2);
	}
	cursor();
	return(status);
}

/*
	Function to repeat the last Search/Replace command
*/
Again_cmd()
{
	int	mod;

	if (!last_again)
		return;
	if (last_again == ATF) mod = -1;
	else
	if (last_again == ATR) mod = -2;
	else
	if (last_again == ATV) mod = -3;
	if (!FindReplace_cmd(1L,mod))
		last_again = 0;
}

/*
	Function to set either Insert/Overwrite mode state
	or current Mark command on Info line.
*/
TW_state()
{
	int	msgno;

	if (mrkfctN)
		msgno = mrkfctN;
	else
	if (inIOm) {
		msgno = INMS;	wdw_crsnm();
	}
	else {
		msgno = OVMS;	wdw_crsbx();
	}
	TW_info(msgno);
}

/*
	Editor handler
*/
Editor()
{
	while (1) {
	  if (!Ikey())					/* time to quit mode */
		return;
	  else {					/* or stay in mode.. */
	    if ((ckey == ' '		&&		/* check 2 spaces    */
		getLch(free_start-1) == ' ')
			||
		(ckey != ' '		&&		/* check flash pos.  */
		!nocp(ckey)		&&
		getfp(ckey) == 0xff)) {
		beep(); continue;			/* error skip input  */
	    }
	    if (!Infsp()) continue;			/* no room continue  */
	    if (ckey == cr) ckey = hrt;			/* swap cr to hrt... */
	    if (allend(ckey)) {				/* user line endings */
		TWclipdraw(wdw_eol,ckey);		/* update wdow line  */
		*free_start++ = ckey;			/* insert hrt/cr/lf  */
		ckcrlf();
		if (wdw_ptr[cur_line()] == current_char)
			wdw_ptr[cur_line()] = free_start - 3;
		nsline();
	    }
	    else {					/* or user reg input */
		if (	inIOm			||	/* if in Insert mode */
			tagc(*current_char)	||	/* or cursor at TAG  */
			allend(*current_char)	||	/* or at line ending */
			current_char >= buf_end ) {	/* or at end buffer  */
			*(--current_char) = ckey;	/* do Insert mode... */
			if (!TWhclip && !current.col)
				setwptr(cur_line());
		}
		else	*current_char = ckey;		/* else do Overwrite */
		wdw_ptr[HMRK] = skiptag(current_char);
		if (*wdw_ptr[HMRK] == cr)
			wdw_ptr[HMRK] += 2;
		cursor();
		TWclipdraw(rewrite_line,0);		/* now refresh line  */
		TWrewindow(wdw_ptr[HMRK]);
		cursor();
	    }
	    TWaltered = true;				/* set file altered  */
	  }						/* end of stayinmode */
	}						/* end of while (1)  */
}

/*
	Command to jump and set cursor to an user specified marker.
*/
JumpMrk_cmd(which)
int	which;
{
	OBJECT	*dialog;
	int	bxobj, exobj, abobj, bn;

	if (which)				/* for Set Marker cmd	*/
	  bxobj = SETAG, abobj = STGNOK;
	else					/* for Jump Marker cmd	*/
	  bxobj = JPTAG, abobj = JTGNOK;
	rsrc_gaddr(0,bxobj,&dialog);
	exobj = execform(dialog,0);
	dialog[exobj].ob_state = NORMAL;
	if (exobj == abobj)
		return;
	BWredraw();				/* redraw T/P Windows	*/
	switch(exobj) {
	case STGA:/* case JTGA: same */
		bn = mrk_base;
		break;
	case STGB:/* case JTGB: same */
		bn = mrk_base + 1;
		break;
	case STGC:/* case JTGC: same */
		bn = mrk_base + 2;
		break;
	case STGD:/* case JTGD: same */
		bn = mrk_base + 3;
		break;
	}
	if (which)
		setwptr(bn);
	else
	if (current_char != wdw_ptr[bn]) {
		TWrewindow(wdw_ptr[bn]);
		nscr(0);
	}
}

/*
	Routine to (un)check a mark function in Text menu
	and (en)disable inappropriate functions in mark mode.
*/
mrkfcheck(mode)
int	mode;
{
	int	markf, disf1, disf2, disf3;

	switch(mrkfbrk) {
	case ATD:	markf = DELTXT;
			disf1 = BUFTXT;
			disf2 = INSTAG;
			disf3 = INSLTAG;
			break;
	case ATB:	markf = BUFTXT;
			disf1 = DELTXT;
			disf2 = INSTAG;
			disf3 = INSLTAG;
			break;
	case ATT:	markf = INSTAG;
			disf1 = DELTXT;
			disf2 = BUFTXT;
			disf3 = INSLTAG;
			break;
	case ATL:	markf = INSLTAG;
			disf1 = DELTXT;
			disf2 = BUFTXT;
			disf3 = INSTAG;
			break;
	}
	menu_icheck (ad_menu,markf,mode);
	menu_ienable(ad_menu,disf1,!mode);
	menu_ienable(ad_menu,disf2,!mode);
	menu_ienable(ad_menu,disf3,!mode);
	menu_ienable(ad_menu,SELART,!mode);
	menu_ienable(ad_menu,GETXT,!mode);
	menu_ienable(ad_menu,CPYTXT,!mode);
	menu_ienable(ad_menu,DELTAG,!mode);
}

/*
	Function to mark a block
*/
mark_blk(fctN,fbrk)
int	fctN;
char	fbrk;
{
	mrkfctN = fctN;
	mrkfbrk = fbrk;
	mrkfcheck(true);
	TW_state();
	cursor();
	setwptr(HMRK);
	wdw_mark();
	fctN = Ikey();
	mrkfcheck(false);
	mrkfctN = false;
	return(fctN);
}

/*
	Function to find matching start or end Tag
*/
unsigned char	*match_tag(fdir,tagn,sptr,eptr)
int		fdir;
unsigned char	tagn, *sptr, *eptr;
{
	if (fdir) {				/* test find ETAG	*/
	  if (sptr >= eptr)
		goto quit;
	  while (sptr < eptr) {			/* scan forward...	*/
		if (*sptr == ETAG && *(sptr+1) == tagn)
			return(sptr);
		sptr = mvfwd(sptr);
	  }
	}
	else {					/* or	find STAG	*/
	  if (sptr == eptr)
		goto quit;
	  while (sptr > eptr) {			/* scan backward...	*/
		sptr = mvbwd(sptr);
		if (*sptr == STAG && *(sptr+1) == tagn)
			return(sptr);
	  }
	}
quit:	return((char *)0);			/* search fails...	*/
}

/*
	Function to check for unmatched start and end Tag
	within a block delimited by HMRK(start) and TMP1(end)
*/
UnmatchTag()
{
	unsigned char	*sp, *ep;
	int		err = 0;

	if (wdw_ptr[HMRK] > current_char)	/* if start tag	ptr	*/
	{					/* in 2nd partition	*/
		wdw_ptr[TMP1] = wdw_ptr[HMRK];
		setwptr(HMRK);			/* swap begin/end ptr	*/
	}
	else	setwptr(TMP1);			/* else set end tag ptr	*/
	TWrewindow(wdw_ptr[HMRK]);		/* to begin tag mark to	*/
	for (	sp = current_char,		/* check unclosed STAG	*/
		ep = wdw_ptr[TMP1];
		!err && sp < ep;
		sp = mvfwd(sp)	)
	  if (*sp == STAG &&				/* if hit STAG	*/
		!match_tag(1,*(sp+1),sp+2,ep))		/* find   ETAG	*/
	  {	do_alert(TAGERR2);		/* no match error quit	*/
		err = 1;	}
	TWrewindow(wdw_ptr[TMP1]);		/* to end tag mark to	*/
	if (!err)
	for (	sp = free_start,		/* check unclosed ETAG	*/
		ep = wdw_ptr[HMRK];
		!err && sp > ep;  ) {
	  sp = mvbwd(sp);
	  if (*sp == ETAG &&				/* if hit ETAG	*/
		!match_tag(0,*(sp+1),sp,ep))		/* find   STAG	*/
	  {	do_alert(TAGERR2);		/* no match error quit	*/
		err = 1;	}
	}
	return(err);
}

/*
	Command to perform block deletion from cursor
*/
Delete_cmd()
{
	int	no_fit;
	
	if (!mark_blk(DMENU,ATD)) {
		if (!check_TWtop())
			return;
		else	goto del_q;
	}
	if (!wdw_ptr[HMRK] || wdw_ptr[HMRK] == current_char)
		goto del_q;
	if (wdw_ptr[HMRK] < current_char) {	/* in 1st partition	*/
/*?*/		if (*current_char == cr)
			TWrewindow(current_char + 2);
		else
		if (*current_char == srt)
			TWrewindow(current_char + 3);
	}
	else
	if (wdw_ptr[HMRK] > current_char) {	/* in 2nd partition	*/
/*?*/		if (*wdw_ptr[HMRK] == cr)
			wdw_ptr[HMRK] += 2;
		else
		if (*wdw_ptr[HMRK] == srt)
			wdw_ptr[HMRK] += 3;
	}
	if (UnmatchTag())			/* check unmatched tag	*/
		goto del_q;
	no_fit = cb_bufin(wdw_ptr[HMRK],(long)(free_start - wdw_ptr[HMRK]));
	if (no_fit) {		/* if deleted data cannot be saved...	*/
		if (do_alert(DELOK) == 2)	/* check with user...	*/
del_q:			nscr(3);
		else	delete_chars(HMRK);	/* ok..do the deletion	*/
	}
	else	delete_chars(HMRK);		/* else do the deletion	*/
	TW_state();
}

/*
	Command to perform data buffering by saving it into the copy
	buffer for later use... like block move...
*/
Buffer_cmd()
{
	if (!mark_blk(BMENU,ATB)) {
		if (!check_TWtop())
			return;
		else	goto buf_q;
	}
	if (!wdw_ptr[HMRK] || wdw_ptr[HMRK] == current_char)
		goto buf_q;
	if (UnmatchTag())			/* check unmatched tag	*/
		goto buf_q;
	if (cb_bufin(wdw_ptr[HMRK],(long)(free_start - wdw_ptr[HMRK])))
		do_alert(TBMS);
buf_q:	nscr(3);
	TW_state();
}
	
/*
	Command to perform Tag insertion
	mode :	ATT -- Global
		ATL -- Local
*/
InsTag_cmd(mode)
unsigned char	mode;
{
	unsigned	tagnum, Local;

	Ins_Tag = true;
	Local	= (mode == ATL);
	if (!mark_blk(Local ? ILTAG:IGTAG,mode)) {
		if (!check_TWtop())
			return(Ins_Tag = false);
		else	goto inT_q;
	}
	if (!wdw_ptr[HMRK] || wdw_ptr[HMRK] == current_char)
		goto inT_q;
	if (Infsp() && !UnmatchTag()) {		/* check insert space	*/
						/* and unmatched tag	*/
		if (Local)			/* if Local Tag mode	*/
			tagnum = last_tag;	/* use last tag number	*/
		else	tagnum = 1;
		tagnum = do_tag(tagnum,1);	/* call Tag dialog box	*/
		BWredraw();			/* redraw T/P Windows	*/
		if (tagnum) {			/* valid tag selected ?	*/
		  if (Local) {			/* if Local Tag mode	*/
			if (last_tag == tagnum &&
			  ++last_tag > NUMTAG)
				last_tag = BLTAG;
/*			last_tag = tagnum;	** update last tag #	*/
		  }
		  --tagnum;			/* tag start from 0	*/
		  TWrewindow(wdw_ptr[HMRK]);	/* to begin tag mark	*/
		  if (wdw_ptr[cur_line()] == current_char)
			wdw_ptr[cur_line()] = free_start;
		  *free_start++ = STAG;		/* insert STAG+tagnum	*/
		  *free_start++ = (char)tagnum;
		  TWrewindow(wdw_ptr[TMP1]);	/* to end tag mark	*/
		  *free_start++ = ETAG;		/* insert ETAG+tagnum	*/
		  *free_start++ = (char)tagnum;
		  TWrewindow(current_char);
		  TWaltered = true;
		}
	}
inT_q:	nscr(3);
	Ins_Tag = false;
	TW_state();
}

/*
	Command to perform Tag deletion
*/
DelTag_cmd()
{
	int		fdir;			/* 1: fwd, 0: bwd mode	*/
	unsigned char	*sp, *ep, tagn;

	if (!ctagc(*current_char))		/* if no TAG do exit...	*/
		return;
	tagn	= *(current_char + 1);
	fdir	= (*current_char == STAG);	/* check search mode	*/
	if (fdir) {				/* HMRK:start, TMP1:end	*/
		setwptr(HMRK);			/* set HMRK find TMP1	*/
		sp = current_char + 2;
		ep = buf_end;
	}
	else {
		setwptr(TMP1);			/* set TMP1 find HMRK	*/
		sp = free_start;
		ep = buf_start;
	}
	if (!(ep = match_tag(fdir,tagn,sp,ep)))	/* find S or E TAG	*/
		return(do_alert(TAGERR1));	/* no match error quit	*/
	if (do_alert(KILLTAG) == 2)		/* recheck with user...	*/
		return;				/* (s)he aborts, quit..	*/
	wdw_ptr[fdir ? TMP1:HMRK] = ep;		/* save S or E	tag ptr	*/
	wdw_ptr[TMP4] = current_char + 2;	/* save after	tag ptr	*/
	TWrewindow(wdw_ptr[HMRK]);		/* to begin tag mark	*/
	current_char += 2;
	TWrewindow(wdw_ptr[TMP1]);		/* to end   tag mark	*/
	current_char += 2;
	TWrewindow(wdw_ptr[TMP4]);		/* to after tag mark	*/
	nscr(3);
	TWaltered = true;
}

/*
	Command to perform data (created by the Delete or Buffer command)
	copy by restoring it from the copy buffer and inserting it at
	present cursor position.
*/
Copy_cmd()
{
	unsigned char	*optr;
	unsigned long	fsp;
	
	if (!cb_size) return;
	TW_info(CMENU);
	fsp = free_space();
	if (fsp <= MIN_FREE || (unsigned long)cb_size > fsp - MIN_LEFT)
		do_alert(CPBFE);
	else {
		cb_bufout(optr = free_start);
		free_start += cb_size;
		TWrewindow(optr);
		nsline();
		ckTWsliderV();
		TWaltered = true;
	}
	TW_state();
}

/*
	Command to read in another file into the present edited article
*/
Get_cmd()
{
	char	fname[100];

	TW_info(GMENU);
	if (gdosfname(fname,4,1)) {
		switch(read_file(fname)) {
		case -1:
			setnfd(fname,2);
			break;
		case 2:
			do_alert(BFERR2);
			break;
		case 1:
			do_alert(BFERR3);
		case 0:
			TWaltered = true;	/* set file altered  */
			break;
		}
		nsline();
		ckTWsliderV();
	}
	TW_state();
}

/*
	Command to select article from dialog box
*/
extern	ARTICLE	*do_artobj();
SelArt_cmd()
{
	ARTICLE	*art_ptr;

	if (!(art_ptr = do_artobj()))		/* to selection dialog box  */
		return;
	if (TWart_ptr) saveTWptrs();		/* update old article ptrs  */
	TWart_ptr = art_ptr;
	setTWArt();				/* set current TW article   */
	TWrewindow(buf_start);			/* to beginning of article  */
	TWslider_chk();				/* reset TW H/Vsliders      */
}

/*
	Function to set article from region pointer
*/
setTWArticle(rptr,txtptr)
REGION	*rptr;
char	*txtptr;
{
	TWart_ptr = rptr->artptr;		/* get article from region  */
	if (!TWart_ptr)				/* if no article associated */
		return(TW_name(nuls));		/* with region return...    */
	setTWArt();				/* set current TW article   */
	if (!txtptr)
		TWrewindow(rptr->txtstart);	/* to beginning of region   */
	else	TWrewindow(txtptr);
	TWslider_chk();				/* reset TW H/Vsliders      */
}

/*
	Function to set article from current TW article pointer
*/
setTWArt()
{
	REGION	*rptr, *tptr;
	char	**bptr;
	int	i;

	get_abuffvars(TWart_ptr);		/* get article buffer ptrs  */
	rptr = TWart_ptr->regptr;		/* get first region	    */
	if (rptr && (rptr = rptr->alink)) {
		upd_tags = 1;
		tptr = rptr;
		while (tptr = tptr->alink)
			++upd_tags;
		if (upd_ptr = (char **)malloc(4 * upd_tags)) {
			bptr = upd_ptr;
			do *(bptr++) = rptr->txtstart;
			while (rptr = rptr->alink);
		}
	}
	for (i = 0;i < 4;) setwptr(i++);	/* reset all text markers   */
	TWaltered = 0;				/* reset buffer dirty flag  */
	TW_name(TWart_ptr->filename);		/* set TWname to art. name  */
	inIOm = 1;				/* start in Insert mode     */
	TW_state();
}

saveTWptrs()
{
	ARTICLE	*art_ptr;
	REGION	*rptr;
	char	**bptr;

	TWrewindow(buf_end);			/* to end of article	*/
	put_abuffvars(art_ptr = TWart_ptr);	/* save art. buf. ptrs	*/
	TWart_ptr = (ARTICLE *)0;		/* null TW article ptr	*/
	TW_name(nuls);				/* clear window name	*/
	TW_info(-1);
	if (TWaltered) {
		art_ptr->dirty = 1;		/* Set modified flag	*/
		if (rptr = art_ptr->regptr) {
		  if ((rptr = rptr->alink) && upd_ptr) {
			bptr = upd_ptr;
			do rptr->txtstart = *(bptr++);
			while (rptr = rptr->alink);
		  }
		  gl_region_ptr = art_ptr->regptr;
		  recalc_rtext();
		  force_draw_flag = 1;		/* Force redraw on Prev	*/
		}
	}
	if (upd_ptr) {
		free(upd_ptr);
		upd_ptr = (char **)0;
	}
}

TWslider_chk()
{
	TWsliderH();				/* set Hslider position	*/
	wind_set(txt_handle,WF_HSLSIZE,		/* set Hslider size	*/
		scaler(1000,current.mcol,wdw_cols),0,0,0);
	TWsliderV();				/* set Vslider position	*/
}

TWsliderV()
{
	if (TWart_ptr) currentVpos();
						/* set Vslider position	*/
	wind_set(txt_handle,WF_VSLIDE,TWVSLpos,0,0,0);
						/* set Vslider size	*/
	wind_set(txt_handle,WF_VSLSIZE,TWVSLsize,0,0,0);
}

TWsliderH()
{
	wind_set(txt_handle,WF_HSLIDE,
		scaler(1000,TWhclip,wdw_cols - current.mcol),0,0,0); 
}

TWvslide(position)
int	position;
{
	char	*txtptr;
	long	fsize;

	if (!TWart_ptr || position == TWVSLpos)
		return;
	if (position <= 1)
		bof_cmd();
	else
	if ((position + TWVSLsize) >= 1000)
		eof_cmd();
	else {
		fsize	= (long)(free_start - buf_start) +
			  (long)(buf_end - current_char);
		txtptr	= buf_start + (((long)position * fsize) / 1000L);
		if (txtptr < free_start) {	/* if in 1st partition	*/
		  txtptr = prvp1(txtptr);
		  if (*txtptr == cr)
			txtptr += 2;
		}
		if (txtptr >= free_start) {	/* if in 2nd partition	*/
		  txtptr = current_char + (long)(txtptr - free_start);
		  if (txtptr == current_char)
			return;
		  txtptr = prvp2(txtptr);
		  if (*txtptr == cr)
			txtptr += 2;
		  if (txtptr > buf_end)
			txtptr = buf_end;
		}
		TWrewindow(txtptr);
		backup(0);			/* to beginning of line	*/
		nscr(1);
	}
}

TWhslide(position)
int	position;
{
	int	xdiff;
	int	curspos;

	if (!TWart_ptr)
		return;
	position = scaler(position,wdw_cols - current.mcol,1000);
	if (abs(TWhclip - position)) {
	  curspos = TWhclip + current.col;
	  xdiff	  = abs(curspos - position);
	  if (TWhclip > position)
		left_cmd(xdiff);
	  else {
		if (position <= curspos)
			TWsetHclip(position);
		else	TWmoveRight(position,xdiff);
	  }
	}
}

TWsetHclip(position)
int	position;
{
	TWhclip = position;
	TWsliderH();
	nscr(3);
}

TWmoveRight(position,moveR)
int	position, moveR;
{
	int	xdiff;

	if ((TWhclip + current.mcol) >= wdw_cols)
		return;
	xdiff = nchartoEline();			/* # of chars to eoline */
	if (xdiff > 0)				/* move cursor first	*/
		right_cmd(xdiff > moveR ? moveR:xdiff);
	if (position != TWhclip) {		/* if hclip not correct	*/
	  if (position > (wdw_cols - current.mcol))
		position = wdw_cols - current.mcol;
	  if (position > (TWhclip + current.col))
		position = TWhclip + current.col;
	  TWsetHclip(position);			/* force rescreen...	*/
	}
}

currentVpos()
{
	long	fsize, temp;

	temp	= (long)(free_start - buf_start);
	fsize	= temp + (long)(buf_end - current_char);
	TWVSLpos = (int)((1000L * temp) / fsize);

	temp	= (long)current.mrow * (long)current.mcol;
	if (temp > fsize)
		temp = fsize;
	TWVSLsize = (int)((1000L * temp) / fsize);
}

PiTag_cmd(fpos)
int	fpos;
{
	if (!pi_tag(&fpos))
		return;
	if (ptagc(*current_char))		/* if cursor at Pi TAG	*/
		*(current_char+1) = (char)fpos;	/* overwrite old one	*/
	else
	if (Infsp()) {				/* check insert space	*/
		if (wdw_ptr[cur_line()] == current_char)
			wdw_ptr[cur_line()] = free_start;
		*free_start++ = PTAG;		/* insert PTAG + fpos	*/
		*free_start++ = (char)fpos;
		TWrewindow(current_char);
	}
	else	return;
	TWaltered = true;
	nscr(3);
}
