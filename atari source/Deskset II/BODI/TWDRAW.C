/*
	This module keeps the Text Window up-to-date
*/
#include	"gemdefs.h"
#include	<obdefs.h>
#include	"defs.h"

extern	int		txt_handle;		/* TWindow	handle	*/
extern	int		shandle;		/* System VDI	handle	*/
extern	GRECT		twork;			/* TWindow work area	*/
extern	GRECT		full;			/* Full-size of window	*/
extern	int		gl_hchar;		/* Text char height	*/
extern	int		msg_buff[];		/* evnt_multi buffer	*/
extern	char		*TWmesg[];		/* TWindow default Mesg	*/
extern	int		TWVSLpos;		/* TW VSlider position	*/
extern	int		TWVSLsize;		/* TW VSlider size	*/
extern	int		mrkfctN;		/* current Mark functN	*/
extern	unsigned char	ctvdc(), *malloc(), nuls[];

static	char		wwon;			/* local word wrap flag	*/
static	char		lrow;			/* local text row	*/
static	char		lcol;			/* local text column	*/
static	unsigned char	TWLnbuf[80];		/* TWindow Line buffer	*/
static	unsigned char	TWNmbuf[80];		/* TWindow Name buffer	*/
static	unsigned char	TWIfbuf[80];		/* TWindow Info buffer	*/
static	int		VSchk;			/* Vert. slider check	*/
static	unsigned char	*(*scanline)();		/* Scan line test fctN	*/
static	int		(*attrtest)();		/* Attribute test fctN	*/
static	int		cur_atr;		/* cur. text attribute	*/
static	int		cMrk;			/* cur. text marker	*/
	int		TWrfmod;		/* TWindow refresh mode	*/
	int		TWhclip;		/* TWindow horiz. clip	*/

/*
	Function to initialize Text Window text positions
*/
init_Tpos()
{
	int	dummy;

	current.row = top_row, current.col = 0;
	TWrfmod = 3, TWhclip = 0;
	vst_alignment(shandle,0,5,&dummy,&dummy);
	setupcurs();
	setupGreek();
}

/*
	Function to get the number of rows of a full size window to
	setup Text Window tag array
*/
set_TWrows()
{
	unsigned TWH, dummy;

	wind_set(txt_handle,WF_CURRXYWH,full.g_x,full.g_y,full.g_w,full.g_h);
	wind_get(txt_handle,WF_WORKXYWH,&dummy,&dummy,&dummy,&TWH);
	wdw_rows = TWH / gl_hchar;
	wdw_tags = top_line + wdw_rows;
	wdw_ptr = (char **)malloc(4 * wdw_tags);
}

cur_line()
{
	return(top_line + current.row);
}

bot_line()
{
	return(top_line + current.mrow - 1);
}

unsigned char	*skiptag(ptr)
unsigned char	*ptr;
{
	if (tagc(*ptr))
		ptr += 2;
	else	++ptr;
	return(ptr);				/* returns new pointer	*/
}

unsigned char	*toeofline(ptr)
unsigned char	*ptr;
{
	while (ptr < buf_end && *ptr != lf)
		ptr = skiptag(ptr);
	return(ptr);				/* ptr to end line lf	*/
}

unsigned char	*out_line(ptr)
unsigned char	*ptr;
{
	unsigned char	*tptr, scol;
	int		new_atr;

	tptr	= TWLnbuf;
	scol	= lcol;
	while (ptr < buf_end && *ptr != cr) {
		if (lcol >= TWhclip) {
			new_atr = (*attrtest)(ptr);
			if (new_atr != cur_atr) {
				if (*TWLnbuf) {
					*tptr	= 0;
					wdw_line(lrow,TWcol(scol));
					tptr	= TWLnbuf;
					scol	= lcol;
				}
				vst_effects(shandle,cur_atr = new_atr);
			}
			*tptr++ = ctvdc(*ptr);
		}
		ptr = skiptag(ptr);
		++lcol;
	}
	if (*ptr == cr) ++ptr;
	*tptr	= 0;
	wdw_line(lrow,TWcol(scol));
	return(ptr);				/* ptr to end line lf	*/
}

unsigned char	*next_line(ptr)
unsigned char	*ptr;
{
	wdw_ptr[TMP4] = buf_end;
	word_wrap(ptr,lcol,1);			/* word wrap one line	*/
	TWrewindow(wdw_ptr[WWRP]);		/* back to start point	*/
	ptr = out_line(current_char);		/* send to Window line	*/
	wdw_clrl(lrow,TWcol(lcol));		/* clear rest of line	*/
	return(ptr);				/* ptr to end line lf	*/
}

/*
	Function to rewrite the current line
*/
rewrite_line(whole_line)
int	whole_line;
{
	unsigned char	*ptr;
	int		botW;

	hilicheck(1);					/* set test function */
	setwptr(TMP1);					/* save current_char */
	if (!whole_line && lcol >= wdw_cols - 15)	/* at 60th column... */
		whole_line = true;			/* check word wrap   */
	if (whole_line)
		backup(lcol = 0);			/* to start of line  */
	wwon	= false;
	cur_atr = 0;
	lrow	= current.row;
	ptr	= next_line(current_char);
	if (cur_atr) vst_effects(shandle,0);
	if (wwon) {
		if (*ptr == lf) ++ptr;			/* never point to lf */
		TWrewindow(ptr);
		botW = (current.row >= (current.mrow - 1));
		if (current_char <= wdw_ptr[TMP1]) {
			TWhclip = 0;
			review(botW ? 1:3), endreview(1);
			TWsliderH();
		}
		else
		if (botW)
			review(0), endreview(1);
		else {
			setwptr(TMP3);
			rescreen(current_char,current.row + 1);
		}
	}
	TWrewindow(wdw_ptr[TMP1]);
}

/*
	Function to backup count lines, 0 => beginning of line
*/
backup(count)
unsigned count;
{
	unsigned char	*ptr;
	unsigned	how_many;

	how_many = 0;
	if (free_start > buf_start) {
	  ptr = free_start;
	  while (1) {
		while ( ptr > buf_start ) {		/* to start of line  */
			if (tagc(*(ptr-2)))
				ptr -= 2;
			else
			if (*(ptr-1) != lf)
				--ptr;
			else	break;
		}
		if (!count-- || ptr <= buf_start)
			break;
		++how_many; --ptr;
	  }
	  if (ptr != free_start) {
		if (*ptr == lf) ++ptr;			/* never point to lf */
		TWrewindow(ptr);
	  }
	}
	return(how_many);
}

/*
	Function to forward count lines, 0 => end of line
*/
forup(count)
unsigned count;
{
	unsigned char	*ptr;
	unsigned	how_many;

	how_many = 0;
	if (current_char < buf_end) {
	  ptr = current_char;
	  while (1) {
		while (!lpend(ptr) && ptr < buf_end)	/* to end of line... */
			ptr = skiptag(ptr);
		if (!count-- || ptr >= buf_end)
			break;
		while (*ptr++ != lf);			/* skip over CR/LF   */
		++how_many;				/* to next line..... */
		if (!count) break;
	  }
	  if (*ptr == cr) --ptr;			/* never point to cr */
	  TWrewindow(ptr);
	}
	return(how_many);
}

rescreen(where,start_row)
unsigned char	*where;
int		start_row;
{
	backup(cur_atr = 0);				/* to start of line  */
	for (lrow = start_row;lrow < current.mrow;++lrow) {
	  if (where >= free_start && where < current_char)
		where = current_char;
	  lcol = 0;
	  if (	wdw_ptr[lrow + top_line] != where  ) {
		wdw_ptr[lrow + top_line]  = where;
		where = next_line(where);
	  }
	  else	where = (*scanline)(where);
	  if (*where == lf) ++where;			/* never point to lf */
	}
	if (cur_atr) vst_effects(shandle,0);
	TWrewindow(wdw_ptr[bot_line()]);		/* reset all pters.. */
	TWrewindow(wdw_ptr[TMP3]);
}

new_screen()
{
	rescreen(wdw_ptr[TMP3],top_row);
}

/*
	Function to rewrite the entire screen
	new_one:	0: rescreen as necessary
			1: rescreen 3 line previous to the current position
			2: force complete rescreen
			3: rewrite the current window
*/
review(new_one)
int	new_one;
{
	int	i, last_line;
	char	*np;

	setwptr(TMP2);					/* save current_char */
	backup(VSchk = 0);				/* to start of line  */
	if (new_one) {					/* if forced mode... */
	  if (new_one == 3) {				/* current screen... */
		if (current.row < current.mrow)		/* cursor in screen  */
			TWrewindow(wdw_ptr[top_line]);	/* reset ptrs to top */
		else	new_one = 1;			/* else force mode 1 */
	  }
	  if (new_one == 1)				/* or up 3 lines...  */
		backup(3);				/* readjust all ptrs */
	  for (i = top_line;i < wdw_tags;)
		wdw_ptr[i++] = (char *)0;		/* insure rewrite... */
	  setwptr(TMP3);
	  if (new_one < 3) VSchk = 1;
	}
	else {						/* check what needed */
	  for (i = bot_line();i > top_line;--i)		/* find last line... */
		if (wdw_ptr[i]) break;
	  last_line = i;
	  if (current_char < wdw_ptr[top_line]) {	/* before top row... */
		np = toeofline(current_char);
		if ((np + 1) == wdw_ptr[top_line]) {
		  for (i = bot_line();i > top_line;--i)
			wdw_ptr[i] = wdw_ptr[i-1];
		  wdw_scroll(0);			/* scroll down...    */
		}
		else	backup(3);
		setwptr(TMP3);
		VSchk = 1;
	  }
	  else {					/* after last row... */
		np = toeofline(wdw_ptr[last_line]);
		if (current_char >= (np + 1)) {
		  setwptr(TMP3);
		  TWrewindow(wdw_ptr[top_line]);
		  np = toeofline(wdw_ptr[last_line]);
		  if ((np + 1) == wdw_ptr[TMP3]) {
		    for (i	   = top_line,
			 last_line = bot_line();
			 i < last_line;++i)
			wdw_ptr[i] = wdw_ptr[i+1];
		    wdw_scroll(1);			/* scroll up...      */
		    wdw_ptr[TMP3] = wdw_ptr[top_line];
		  }
		  else {
		    TWrewindow(wdw_ptr[TMP3]);
		    backup(3);
		    setwptr(TMP3);
		  }
		  VSchk = 1;
		}
		else wdw_ptr[TMP3] = wdw_ptr[top_line];	/* simply redisplay  */
	  }
	}
}

endreview(mode)
int	mode;
{
	if (mode) new_screen();
	TWrewindow(wdw_ptr[TMP2]);
	if (VSchk) TWsliderV();
}

/*
	Function to set the cursor positions
*/
cursor()
{
	int		i, hmove, line;
	unsigned char	*ptr, svlcol;

	setwptr(TMP2);					/* save current_char */
	line = cur_line();
	if (!wdw_ptr[line]		  ||
	    current_char <  wdw_ptr[line] ||
	    current_char >= wdw_ptr[line+1]) {		/* current ptr moved */
	  for (	i	= top_line,
		line	= bot_line();
		i <= line;++i )				/* find new row...   */
		if (wdw_ptr[i] >= current_char) break;
	  if (i != top_line) {
	    if (wdw_ptr[i] == current_char) {		/* ptr at start line */
		TWrewindow(wdw_ptr[i-1]);		/* backup one line.. */
		ptr = toeofline(current_char);
		if (ptr >= buf_end)			/* check end of file */
			current.row = i - (top_line+1);	/* yes set row here  */
		else	current.row = i - top_line;
		TWrewindow(wdw_ptr[TMP2]);		/* back to orig. ptr */
	    }
	    else current.row = i - (top_line+1);	/* at previous line  */
	  }
	  else	current.row = top_row;
	}
	TWrewindow(wdw_ptr[cur_line()]);	/* to start of current line  */
	ptr	= current_char;
	lcol	= 0;
	while (ptr < wdw_ptr[TMP2]) {
		ptr = skiptag(ptr);
		++lcol;
	}
	hmove = lcol - (current.mcol / 2);
	if (lcol < TWhclip) {
		TWhclip = (hmove > 0) ? hmove:0;
		hmove = 1;
	}
	else
	if (lcol > (TWhclip + current.mcol) && current.mcol < wdw_cols) {
		TWhclip = hmove;
		hmove = 1;
	}
	else	hmove = 0;
	TWrewindow(wdw_ptr[TMP2]);
	if (hmove) {
		svlcol = lcol;
		Creview(3);
		TWsliderH();
		lcol = svlcol;
	}
	current.col = lcol - TWhclip;
	TWcursor();
}

TWclipdraw(func,arg)
int	(*func)(), arg;
{
	gsx_moff();
	clrcursor();
	set_clip(1,&twork);
	(*func)(arg);
	set_clip(0,&twork);
	gsx_mon();
}

Creview(mode)
int	mode;
{
	hilicheck(0);
	TWclipdraw(review,mode), TWclipdraw(endreview,1);
}

/*
	Function to update if needed new window
*/
nscr(mode)
int	mode;
{
	Creview(mode); cursor();
}

rwnscr(ptr,mode)
char	*ptr;
int	mode;
{
	TWrewindow(ptr); nscr(mode);
}

/*
	Function to rewrite the current line and update
	the whole window if needed
*/
nsline()
{
	nscr(0);
	TWclipdraw(rewrite_line,1);
	cursor();
}

/*
	Function to add CR-LF to free_start area
*/
addcrlf()
{
	*free_start++ = cr; *free_start++ = lf;
}

/*
	Function to clear window line at row/column positions
*/
wdw_clrl(row,col)
{
	GRECT	box;
	long	scrmfdb = 0L;			/* screen MFDB address	*/

	box.g_x	= xcrs(col);
	if (box.g_x < twork.g_x || box.g_x >= (twork.g_x + twork.g_w))
		return;
	box.g_y	= ycrs(row);
	box.g_w	= (twork.g_x + twork.g_w) - box.g_x;
	box.g_h	= gl_hchar;
	rast_op(0,&box,&scrmfdb,&box,&scrmfdb);
}

/*
	Function to output a line to Text window
*/
wdw_line(row,col)
int	row, col;
{
	if (*TWLnbuf)
		v_gtext(shandle,xcrs(col),ycrs(row),TWLnbuf);
}

/*
	Function to output a line ending code to Text window
	and clear the rest of the line at current cursor positions.
*/
wdw_eol(eolc)
char	eolc;
{
	TWLnbuf[0] = ctvdc(eolc), TWLnbuf[1] = 0;
	wdw_line(current.row,current.col);
	wdw_clrl(current.row,current.col + 1);
}

/*
	Function to check if Text window is topped.
*/
check_TWtop()
{
	int	thandle, dummy;

	wind_get(0,WF_TOP,&thandle,&dummy,&dummy,&dummy);
	return(thandle == txt_handle);
}

/*
	Function to update Text window Name field
*/
TW_name(name)
char	*name;
{
	strcpy(TWNmbuf,TWmesg[0]);
	strcat(TWNmbuf,name);
	wind_set(txt_handle,WF_NAME,TWNmbuf,0,0);
	TWhclip = 0;
	if (name != nuls)
		TWrfmod = 2;
	else {	TWVSLpos  = 0;
		TWVSLsize = 1000;
		TWslider_chk();
	}
}

/*
	Function to update/clear Text window Info field
*/
TW_info(msgno)
int	msgno;
{
	char	*msgp;

	if (msgno == -1)				/* clear mode	*/
		msgp = nuls;
	else	rsrc_gaddr(R_STRING,msgno,&msgp);
	strcpy(TWIfbuf,TWmesg[1]);
	strcat(TWIfbuf,msgp);
	wind_set(txt_handle,WF_INFO,TWIfbuf,0,0);
}

/*
	Function to wait for one or both Window redraw
*/
BWredraw()
{
	int	ret;			/* dummy variable	*/
	int	event;			/* which event returned	*/
	int	rdw = 0;		/* window redrawn flag	*/

	do {
	  wind_update(false);
	  event = evnt_multi(MU_MESAG | MU_TIMER,
			0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			msg_buff,
			500,0,			/* timer = 0.5s	*/
			&ret,&ret,&ret,&ret,&ret,&ret);
	  wind_update(true);
	  if ((event & MU_TIMER) && rdw)	/* force out	*/
		break;
	  if ((event & MU_MESAG) && msg_buff[0] == WM_REDRAW) {
		do_redraw(msg_buff);
		++rdw;
	  }
	} while (rdw < 2);
}

word_wrap(ptr,wcol,oneline)
unsigned char	*ptr, wcol;
int		oneline;
{
	unsigned char	*lptr;

	wdw_ptr[WWRP] = ptr;
	while (ptr < wdw_ptr[TMP4]) {
	  if (wcol >= wdw_cols) {
		if (*ptr == cr)
			goto hitcr;
		else
		if (*ptr == ' ') {
		  if (*(ptr+1) == cr)
			goto nextc;
		  else	++ptr;
		}
		else {
		  TWrewindow(wdw_ptr[WWRP]);
		  for ( lptr = ptr-1;
			lptr > wdw_ptr[WWRP]	&&
			!tagc(*(lptr-1))	&&
			*lptr != ' ';
			--lptr );
		  if (lptr > wdw_ptr[WWRP])
			ptr = ++lptr;
		}
		TWrewindow(ptr);
		addcrlf();
		ptr	= current_char;
		wwon	= true;
		goto check;
	  }
	  while (*ptr == cr) {
		if (	ptr > current_char &&
			!tagc(*(ptr-2))    &&
			allend(*(ptr-1))    )
			goto hitcr;
		TWrewindow(ptr);
		ptr	= (current_char += 2);
		TWrewindow(ptr);
		wwon	= true;
	  }
	  if (*ptr != cr) {
nextc:		ptr = skiptag(ptr);
		++wcol;
	  }
	  else {
hitcr:		ptr += 2;
check:		if (oneline) return;
		wdw_ptr[WWRP] = ptr;
		wcol = 0;
	  }
	}
}

TWcursor()
{
	gsx_moff();
	setcursor(0);
	gsx_mon();
}

static	TWcol(col)
int	col;
{
	return((col >= TWhclip) ? (col - TWhclip):0);
}

/*
	mode 0 ... Normal (no hilight) mode
*/
static	tmod0(ptr)
char	*ptr;
{
	return(0);
}

/*
	mode 1 ... New position below marker
*/
static	tmod1(ptr)
char	*ptr;
{
	if (ptr >= wdw_ptr[HMRK] && ptr < wdw_ptr[cMrk])
		return(9);
	else	return(0);
}

/*
	mode 2 ... New position above marker
*/
static	tmod2(ptr)
char	*ptr;
{
	if (ptr == wdw_ptr[HMRK])
		return(10);
	else
	if (ptr >= wdw_ptr[cMrk] && ptr < wdw_ptr[HMRK])
		return(9);
	else	return(0);
}

/*
	Function to check high light defined text mode
	when in Delete/Buffer/Tag commands
*/
hilicheck(mode)
int	mode;
{
	if (!mrkfctN) {
		attrtest = tmod0;
		scanline = toeofline;
	}
	else {
	  cMrk = mode ? TMP1:TMP2;
	  if (current_char > wdw_ptr[HMRK])	/* down/right	*/
		attrtest = tmod1;
	  else	attrtest = tmod2;		/* up/left	*/
		scanline = out_line;
	}
}

static	hili_mark(curc)
char	curc;
{
	TWLnbuf[0] = ctvdc(curc), TWLnbuf[1] = 0;
	vst_effects(shandle,10);
	wdw_line(current.row,current.col);
	vst_effects(shandle,0);
}

wdw_mark()
{
	TWclipdraw(hili_mark,*current_char);
	TWcursor();
}

nchartoEline()
{
	int	nchar;				/* # of chars to eoline */
	char	*ptr;

	for (	ptr = current_char, nchar = 0;
		ptr < buf_end && *(ptr+1) != cr;
		ptr = skiptag(ptr), ++nchar	);
	return(nchar);
}

/*
	Routine to move the text pointer closest to the
	current cursor position
*/
movetoCcol()
{
	unsigned char	*ptr;

	ptr	= current_char;
	lcol	= 0;
	while (!lpend(ptr) && ptr < buf_end) {		/* to end of line... */
		if (lcol >= TWhclip && (lcol - TWhclip) >= current.col)
			break;
		ptr = skiptag(ptr);
		++lcol;
	}
	if (*ptr == cr) --ptr;				/* never point to cr */
	TWrewindow(ptr);
}

ckTWsliderV()
{
	if (!VSchk) TWsliderV();
}
