/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* Win32 support routines for Jove Keyboard and Screen */

#include "jove.h"

#ifdef WIN32	/* the body is the rest of this file */

#include "fp.h"	/* scr_putchar */
#include "chars.h"
#include "screen.h"
#include "disp.h"	/* for redisplay() */

#include <windows.h>

INPUT_RECORD in_event[NCHARS], *eventp = in_event;	/* Input events e.g. keyboard, mouse-click */
int nevents;
private HANDLE conin, conout, conerr;	/* Console handles */
private COORD curpos;
private COORD maxpos;
private HANDLE old_stdout, old_stderr;
private WORD  old_attributes;

private BOOL WINAPI ctrlHandler proto((DWORD type));	/* Control handler */
#define CHECK(fn)	{ if (!(fn)) ConsoleFail(#fn); }
private void ConsoleFail(char *fdef);

void
getTERM()
{
}

void
ttysetattr(n)
bool	n;	/* also used as subscript! */
{
	CONSOLE_SCREEN_BUFFER_INFO info;
	COORD bufsize;
	DWORD version;

	if (n) {
		if (conout == NULL) {
			/* Create our own console buffer so we can easily restore
			 * the startup environment. This also allows us to resize
			 * it to eliminate the scroll bars, at least where the
			 * full Console API is implemented (i.e. on Windows NT).
			 * (Windows 95 seems to ignore whatever we do to the window).
			 */
			old_stdout = GetStdHandle(STD_OUTPUT_HANDLE);
			old_stderr = GetStdHandle(STD_ERROR_HANDLE);
			CHECK(GetConsoleScreenBufferInfo(old_stdout, &info));
			old_attributes = info.wAttributes;
			conout = CreateConsoleScreenBuffer(GENERIC_READ|GENERIC_WRITE,
				FILE_SHARE_READ|FILE_SHARE_WRITE,
				NULL, CONSOLE_TEXTMODE_BUFFER, NULL);
			CHECK(DuplicateHandle(GetCurrentProcess(), conout,
					GetCurrentProcess(), &conerr,
					0, TRUE, DUPLICATE_SAME_ACCESS));
			bufsize.X = info.srWindow.Right-info.srWindow.Left+1;
			bufsize.Y = info.srWindow.Bottom-info.srWindow.Top+1;
			CHECK(SetConsoleScreenBufferSize(conout, bufsize));
			version = GetVersion();
#ifdef DEBUG
			{
				char tracebuf[100];

				wsprintf(tracebuf, "%s Windows %d.%d Build %d\n",
					(version > 0 ? "MS-DOS" : "NT"),
					LOBYTE(LOWORD(version)), HIBYTE(LOWORD(version)),
					HIWORD(version)&0x7FFF);
				OutputDebugString(tracebuf);
				wsprintf(tracebuf, "Console Size=(%d,%d), Window=(%d,%d) to (%d,%d)\n",
							info.dwSize.X, info.dwSize.Y,
							info.srWindow.Left, info.srWindow.Top,
							info.srWindow.Right, info.srWindow.Bottom);
				OutputDebugString(tracebuf);
			}
#endif
			CHECK(SetStdHandle(STD_OUTPUT_HANDLE, conout));
			CHECK(SetStdHandle(STD_ERROR_HANDLE, conerr));
			CHECK(SetConsoleActiveScreenBuffer(conout));
		}
		CHECK(SetConsoleTitle("Jove for Win32"));
		conin = GetStdHandle(STD_INPUT_HANDLE);
		/* conout = GetStdHandle(STD_OUTPUT_HANDLE); */

# ifdef MOUSE
		SetConsoleMode(conin,
			ENABLE_MOUSE_INPUT | ENABLE_WINDOW_INPUT);
		MouseOn();
# else
		SetConsoleMode(conin, ENABLE_WINDOW_INPUT);
# endif /* !MOUSE */
		SetConsoleMode(conout,
			ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT);
		SetFileApisToOEM();
		SetConsoleCtrlHandler(ctrlHandler, TRUE);
	} else {
		CHECK(SetStdHandle(STD_OUTPUT_HANDLE, old_stdout));
		CHECK(SetStdHandle(STD_ERROR_HANDLE, old_stderr));
		CHECK(SetConsoleActiveScreenBuffer(old_stdout));
		CloseHandle(conout);
		CloseHandle(conerr);
		SetConsoleTextAttribute(old_stdout, old_attributes);
		conin = conout = conerr = NULL;
# ifdef MOUSE
		MouseOff();
# endif
		SetConsoleCtrlHandler(ctrlHandler, FALSE);
	}
}

void
ttsize()
{
	/* ??? We really ought to wait until the screen is big enough:
	 * at least three lines high (one line each for buffer, mode,
	 * and message) and at least twelve columns wide (eight for
	 * line number, one for content, two for overflow indicators,
	 * and one blank at end).
	 */
	CONSOLE_SCREEN_BUFFER_INFO info;
	GetConsoleScreenBufferInfo(conout, &info);
	maxpos.X = info.srWindow.Right-info.srWindow.Left+1;
	maxpos.Y = info.srWindow.Bottom-info.srWindow.Top+1;
	if (maxpos.X != info.dwSize.X || maxpos.Y != info.dwSize.Y) {
		CHECK(SetConsoleScreenBufferSize(conout, maxpos));
		curpos.X = curpos.Y = 0;
	} else {
		curpos = info.dwCursorPosition;
	}
	CO = maxpos.X;
	if (CO > MAXCOLS)
		CO = MAXCOLS;
	LI = maxpos.Y;
	ILI = LI - 1;
}

#ifdef DEBUG
private char *
formatChar(char c)
{
	static char cbuf[6];

	if (c >= ' ' && c <= '~')
		sprintf(cbuf, "%c", c);
	else
		sprintf(cbuf, "\\%03o", (unsigned char)c);
	return cbuf;
}

private char *
formatEvent(INPUT_RECORD* event)
{
	static char buffer[128];

	switch (event->EventType) {
	  case KEY_EVENT:
		sprintf(buffer, "KEY%s '%s%s%s%s'[%d times] Scan=%d Keycode=%d\n",
			event->Event.KeyEvent.bKeyDown?"DOWN":"UP",
			(event->Event.KeyEvent.dwControlKeyState &
				(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED) ? "ALT-" : ""),
			(event->Event.KeyEvent.dwControlKeyState &
				(RIGHT_CTRL_PRESSED|LEFT_CTRL_PRESSED) ? "CTRL-" : ""),
			(event->Event.KeyEvent.dwControlKeyState &
				(SHIFT_PRESSED) ? "SHIFT-" : ""),
			formatChar(event->Event.KeyEvent.uChar.AsciiChar),
			event->Event.KeyEvent.wRepeatCount,
			event->Event.KeyEvent.wVirtualScanCode,
			event->Event.KeyEvent.wVirtualKeyCode
			);
		break;
	  case MOUSE_EVENT:
		sprintf(buffer, "MOUSE%s%s %s%s%s%s%s%s (%d,%d)\n",
				(event->Event.MouseEvent.dwEventFlags&MOUSE_MOVED ?
						" MOVED" : ""),
				(event->Event.MouseEvent.dwEventFlags&DOUBLE_CLICK?
						" DOUBLE_CLICK" : ""),
				(event->Event.MouseEvent.dwButtonState&1 ? "LEFT" : ""),
				(event->Event.MouseEvent.dwButtonState&2 ? "RIGHT" : ""),
				(event->Event.MouseEvent.dwButtonState&4 ? "MIDDLE" : ""),
				(event->Event.MouseEvent.dwControlKeyState &
					(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED) ? "ALT-" : ""),
				(event->Event.MouseEvent.dwControlKeyState &
					(RIGHT_CTRL_PRESSED|LEFT_CTRL_PRESSED) ? "CTRL-" : ""),
				(event->Event.MouseEvent.dwControlKeyState &
					(SHIFT_PRESSED) ? "SHIFT-" : ""),
				event->Event.MouseEvent.dwMousePosition.X,
				event->Event.MouseEvent.dwMousePosition.Y
				);
		break;
	  case WINDOW_BUFFER_SIZE_EVENT:
		sprintf(buffer, "RESIZE (%d,%d)\n",
			eventp->Event.WindowBufferSizeEvent.dwSize.Y,
			eventp->Event.WindowBufferSizeEvent.dwSize.X);
		break;
	  case MENU_EVENT:
		sprintf(buffer, "MENU %d\n", eventp->Event.MenuEvent.dwCommandId);
		break;
	  case FOCUS_EVENT:
		sprintf(buffer, "FOCUS %d\n", eventp->Event.FocusEvent.bSetFocus);
		break;
	  default:
		sprintf(buffer, "UNKNOWN %d\n", eventp->EventType);
		break;
	}
	return buffer;
}
#endif /* DEBUG */

/* MapKeyEventToChars maps Console KEY_RECORDs into a string of characters.
 * The mapping rules are basically those of the IBM AT BIOS as modified for
 * use by JOVE (i.e. the result should agree with what a JOVE user would see
 * running the MS-DOS version of Jove).
 */
private int
MapKeyEventToChars(KEY_EVENT_RECORD* key, char *bptr)
{
	int cnt = 0;

	if (key->bKeyDown) {
		if (key->uChar.AsciiChar) {
			if ((key->dwControlKeyState &
				(RIGHT_CTRL_PRESSED|LEFT_CTRL_PRESSED))
			&& key->uChar.AsciiChar == ' ')
			{
				bptr[cnt++] = '\0';
			} else if (key->dwControlKeyState &
				(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED))
			{
				bptr[cnt++] = PCNONASCII;
				if (key->wVirtualScanCode >= 2
				&& key->wVirtualScanCode <= 13)
				{
					/* Top row (numeric keys) */
					bptr[cnt++] = key->wVirtualScanCode + 118;
				} else {
					bptr[cnt++] = key->wVirtualScanCode;
				}
			} else {
				bptr[cnt++] = key->uChar.AsciiChar;
			}
		} else {
#			define ShiftSelect(plain, shifted, ctrled, alted) ( \
				(key->dwControlKeyState & SHIFT_PRESSED) \
					? (shifted) \
				: (key->dwControlKeyState & (RIGHT_CTRL_PRESSED|LEFT_CTRL_PRESSED)) \
					? (ctrled) \
				: (key->dwControlKeyState & (RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED)) \
					? (alted) \
				: (plain))

			switch (key->wVirtualKeyCode) {
			  case VK_F1: case VK_F2: case VK_F3: case VK_F4: case VK_F5:
			  case VK_F6: case VK_F7: case VK_F8: case VK_F9: case VK_F10:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = key->wVirtualKeyCode - VK_F1
					+ ShiftSelect(59, 84, 94, 104);
				break;
			  case VK_F11: case VK_F12:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = key->wVirtualKeyCode - VK_F11
					+ ShiftSelect(133, 135, 137, 139);
				break;
			  case '1': case '2': case '3': case '4': case '5':
			  case '6': case '7': case '8': case '9': case '0':
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = key->wVirtualScanCode + 118;
				break;
			  case VK_HOME:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(71, 171, 119, 151);
				break;
			  case VK_UP:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(72, 171, 141, 152);
				break;
			  case VK_PRIOR:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(73, 172, 132, 153);
				break;
			  case VK_SUBTRACT:	/* KEYPAD- */
				bptr[cnt++] = PCNONASCII;
				if (key->dwControlKeyState &
						(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED))
				{
					if (key->dwControlKeyState & SHIFT_PRESSED) {
						bptr[cnt++] = 174;
					} else {
						bptr[cnt++] = 74;
					}
				} else {
					bptr[cnt++] = 142;
				}
				break;
			  case VK_LEFT:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(75, 175, 115, 155);
				break;
			  case VK_RIGHT:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(77, 177, 116, 157);
				break;
			  case VK_ADD:	/* KEYPAD+ */
				bptr[cnt++] = PCNONASCII;
				if (key->dwControlKeyState &
						(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED))
				{
					if (key->dwControlKeyState & SHIFT_PRESSED) {
						bptr[cnt++] = 178;
					} else {
						bptr[cnt++] = 78;
					}
				} else {
					bptr[cnt++] = 144;
				}
				break;
			  case VK_END:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(79, 179, 117, 159);
				break;
			  case VK_DOWN:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(80, 180, 145, 160);
				break;
			  case VK_NEXT:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(81, 181, 118, 161);
				break;
			  case VK_INSERT:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = ShiftSelect(82, 182, 146, 162);
				break;
			  case VK_DELETE:
				if (key->dwControlKeyState & SHIFT_PRESSED) {
					bptr[cnt++] = PCNONASCII;
					bptr[cnt++] = 183;
				} else if (key->dwControlKeyState &
					(RIGHT_CTRL_PRESSED|LEFT_CTRL_PRESSED))
				{
					bptr[cnt++] = PCNONASCII;
					bptr[cnt++] = 147;
				} else if (key->dwControlKeyState &
					(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED))
				{
					bptr[cnt++] = PCNONASCII;
					bptr[cnt++] = 163;
				} else {
					bptr[cnt++] = '\177';	/* Mapped to ASCII DEL */
				}
				break;
			  case VK_DIVIDE:	/* KEYPAD/ */
				bptr[cnt++] = PCNONASCII;
				if (key->dwControlKeyState &
						(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED))
				{
					bptr[cnt++] = 164;
				} else {
					bptr[cnt++] = 149;
				}
				break;
			  case VK_MULTIPLY:	/* KEYPAD* */
				bptr[cnt++] = PCNONASCII;
				if (key->dwControlKeyState &
						(RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED))
				{
					bptr[cnt++] = 55;
				} else {
					bptr[cnt++] = 150;
				}
				break;
			  case VK_NUMPAD5:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = 143;
				break;
			  case VK_PRINT:	/* PRINT SCREEN */
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = 113;
				break;
			  case VK_ESCAPE:
				if (key->dwControlKeyState & (RIGHT_ALT_PRESSED|LEFT_ALT_PRESSED)) {
					bptr[cnt++] = PCNONASCII;
					bptr[cnt++] = key->wVirtualScanCode;
				} else {
					bptr[cnt++] = '\033';	/* ASCII ESC */
				}
				break;
			  case 'C':	/* PRINT SCREEN */
				if (key->dwControlKeyState & (RIGHT_CTRL_PRESSED|LEFT_CTRL_PRESSED)) {
					bptr[cnt++] = '\003';	/* Ctrl-C : remapped in Windows 95 */
				} else {
					bptr[cnt++] = PCNONASCII;
					bptr[cnt++] = key->wVirtualScanCode;
				}
				break;
			  case VK_CAPITAL:
			  case VK_SHIFT:
			  case VK_CONTROL:
			  case VK_MENU:
			  case VK_NUMLOCK:
			  case VK_SCROLL:
				/* Modifiers - ignore them. */
				break;
			  default:
				bptr[cnt++] = PCNONASCII;
				bptr[cnt++] = key->wVirtualScanCode;
				break;
			}
#			undef ShiftSelect
		}
	}
	return cnt;
}

int
getInputEvents(char *bp, int size)
{
	int nchars = 0;

	if (eventp >= in_event+nevents) {
		if (!ReadConsoleInput(conin,
							  in_event, NCHARS, &nevents))
			complain("ReadConsole failed (shouldn't happen)");
		eventp = in_event;
	}
	while (eventp < in_event+nevents) {
		switch (eventp->EventType) {
		  case KEY_EVENT:
			nchars += MapKeyEventToChars(&eventp->Event.KeyEvent, bp+nchars);
			if (--eventp->Event.KeyEvent.wRepeatCount == 0)
				eventp += 1;
			break;
		  case MOUSE_EVENT:
#ifdef MOUSE
			/* We are only interested in hits */
			if (eventp->Event.MouseEvent.dwButtonState != 0) {
				bp[nchars++] = PCNONASCII;
				bp[nchars++] = '\xb0'+((char)eventp->Event.MouseEvent.dwButtonState&017);
				bp[nchars++] = (char)eventp->Event.MouseEvent.dwMousePosition.X;
				bp[nchars++] = (char)eventp->Event.MouseEvent.dwMousePosition.Y;
			}
#endif
			eventp += 1;
			break;

		  case WINDOW_BUFFER_SIZE_EVENT:
			maxpos = eventp->Event.WindowBufferSizeEvent.dwSize;
			eventp += 1;
			ResizePending = YES;
			break;
		  default:
			eventp += 1;
			break;
		}
		if (nchars >= size - 5)
			break;
	}
	return nchars;
}

BOOL
inputEventWaiting(int period)
{
#ifdef IPROCS
	return wait_for_any_input(period) == WAIT_OBJECT_0;
#else
	INPUT_RECORD evnt[10];
	PINPUT_RECORD pEvnt;
	DWORD cnt;
	static BOOL first=TRUE;

	if (first)
		return first=FALSE;	/* Force display on first call */
	if (eventp < in_event+nevents)
		return TRUE;	/* Already something in the queue */
	while (WaitForSingleObject(conin, period) == WAIT_OBJECT_0) {
		if (!PeekConsoleInput(conin, evnt
		, sizeof(evnt)/sizeof(evnt[0]), &cnt))
			break;
		/* Check if the waiting event is of interest. */
		for (pEvnt=evnt; pEvnt<evnt+cnt; ++pEvnt) {
			if ((pEvnt->EventType == KEY_EVENT
			  && pEvnt->Event.KeyEvent.bKeyDown)
			|| pEvnt->EventType == WINDOW_BUFFER_SIZE_EVENT
			|| pEvnt->EventType == MOUSE_EVENT)
				return TRUE;
		}
		/* If we reach here, the event(s) are uninteresting - chuck them. */
		if (!ReadConsoleInput(conin, evnt, cnt, &cnt))
			break;
	}
	return FALSE;
#endif
}

private void
SaveBufferFile(Buffer *b)
{
	Buffer *save_buf = curbuf;
	char title[80];

	if (b->b_fname) {
		wsprintf(title, "Save Jove buffer `%s'?", b->b_name);
		if (MessageBox(NULL, b->b_fname, title, MB_YESNO) != IDYES)
			return;
	} else {
		OPENFILENAME ofn;	/* common dialog box structure */
		char szFile[_MAX_PATH];	/* filename string */
		char szDirPath[_MAX_PATH];	/* filename string */

		/* Set the members of the OPENFILENAME structure. */
		memset(&ofn, 0, sizeof(ofn));
		ofn.lStructSize = sizeof(OPENFILENAME);
		szFile[0] = '\0';
		ofn.lpstrFile = szFile;
		ofn.nMaxFile = _MAX_PATH;;
		ofn.lpstrFilter =	"All (*.*)\0*.*\0"
							"C source (*.c;*.cpp;*.cxx)\0*.c;*.cpp;*,cxx\0"
							"C header (*.h;*.hpp;*.hxx)\0*.h;*.hpp;*.hxx\0";
		ofn.lpstrInitialDir = szDirPath;
		ofn.lpstrTitle = title;
		wsprintf(title, "Save Jove buffer `%s' as:", b->b_name);

		getcwd(szDirPath);
		ofn.Flags = OFN_SHOWHELP | OFN_OVERWRITEPROMPT |
			OFN_PATHMUSTEXIST;
		if (!GetSaveFileName(&ofn))
			return;
		setfname(b, ofn.lpstrFile);
	}

	/* Still here? Save the file, then. */
	SetBuf(b);
	SaveFile();
	SetBuf(save_buf);
}

private void
MessageCloseFiles()
{
	/* We use a static buffer pointer so that we can detect if we
	 * have been re-entered.  If so, we do nothing.  This can happen
	 * if the user takes too long to respond).
	 */
	static Buffer *b;

	if (b == NULL)
		for (b = world; b != NULL; b = b->b_next)
			if (b->b_type != B_SCRATCH
			&& b->b_type == B_FILE
			&& IsModified(b))
				SaveBufferFile(b);
}

/* Control interrupt handler deals with CTRL-BREAK and exit requests */
private BOOL WINAPI
ctrlHandler(DWORD type)
{
	switch(type) {
	  case CTRL_C_EVENT:
		return TRUE;	/* Ignore, keyboard handler will see it. */
		break;
	  case CTRL_BREAK_EVENT:
		return FALSE;
		break;
	  case CTRL_CLOSE_EVENT:
	  case CTRL_LOGOFF_EVENT:
	  case CTRL_SHUTDOWN_EVENT:
		MessageCloseFiles();
		break;
	}
	return FALSE;	/* Carry on */
}

private WORD
	c_attr = 0x07,	/* current attribute white on black */
	c_row = 0,	/* current row */
	c_col = 0;	/* current column */

int
	Txattr = 0x07,	/* VAR: text-attribute (white on black) */
	Mlattr = 0x70,	/* VAR: mode-line-attribute (black on white) */
	Hlattr = 0x10;	/* VAR: highlight-attribute */

#define c_row curpos.Y
#define c_col curpos.X

#define cur_mov(r, c)	{ \
		curpos.X = (c); curpos.Y = (r); \
		CHECK(SetConsoleCursorPosition(conout, curpos)); \
	}
#define setcolor(c)	{ \
		c_attr = (c); \
		CHECK(SetConsoleTextAttribute(conout, c_attr)); \
	}

/* WIN32 calls aren't cheap, so we buffer output */

private char displaybuf[1024];
private int bufpos = 0;

/* getLastErrorString is a WIN32 helper function that returns a description
 * of the error code that GetLastError() returns.
 * Implementation note: we use a mode of operation whereby FormatMessage allocates
 * a string large enough; the returned value will be valid until the function is
 * called again.
 */
private char *reason;

private void
freeReason(void)
{
	if (reason) {
		VirtualFree((PVOID)reason, 0, MEM_RELEASE);
		reason = NULL;
	}
}

char *
getLastErrorString()
{
	static BOOL cleanupRegistered;
	char *ptr;

	if (!cleanupRegistered) {
		atexit(freeReason);
		cleanupRegistered = TRUE;
	}
	freeReason();
	FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_ALLOCATE_BUFFER,
				NULL, GetLastError(), MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL),
				(char*)&reason, 0, NULL);
	if (((ptr = strchr(reason, '\r')) != NULL)
	|| ((ptr = strchr(reason, '\n')) != NULL))
		*ptr = '\0';	/* Trim off carriage control */
	return reason;
}

private void
ConsoleFail(char *fdef)
{
	char why[200];
	char *reason = getLastErrorString();

	sprintf(why, "Console function \"%s\" failed", fdef);
	if (MessageBox(NULL, getLastErrorString(), why, MB_OKCANCEL) == IDCANCEL)
		abort();
}

private void
scr_win(int no, int ulr, int ulc, int lrr, int lrc)
{
	SMALL_RECT r, clip;
	COORD whereto;
	CHAR_INFO charinfo;
	short height = lrr - ulr + 1;

	clip.Top = ulr;
	clip.Left = ulc;
	clip.Bottom = lrr;
	clip.Right = lrc;
	whereto.X = ulc;
	r.Left = ulc;
	r.Right = lrc;
	if (no > 0) {
		r.Top = ulr + no;
		r.Bottom = lrr;
		whereto.Y = ulr;
	} else {
		r.Top = ulr;
		r.Bottom = lrr + no;
		whereto.Y = ulr - no;
	}

	charinfo.Char.AsciiChar = ' ';
	charinfo.Attributes = c_attr;

	CHECK(ScrollConsoleScreenBuffer(conout, &r, &clip, whereto, &charinfo));

	/* If the scrolled region is less than half of the clip area, there will
	 * be an unscrolled area in the middle - it must be filled with space.
	 */
	if (no > 0) {
		whereto.Y += (r.Bottom - r.Top + 1);
		while (whereto.Y < r.Top) {
			DWORD written;

			CHECK(FillConsoleOutputCharacter(conout, ' ', lrc-ulc+1, whereto, &written));
			whereto.Y += 1;
		}
	} else {
		while (--whereto.Y > r.Bottom) {
			DWORD written;

			CHECK(FillConsoleOutputCharacter(conout, ' ', lrc-ulc+1, whereto, &written));
		}
	}
}

void
i_lines(top, bottom, num)
int top, bottom, num;
{
	scr_win(-num, top, 0, bottom, CO-1);
}

void
d_lines(top, bottom, num)
int top, bottom, num;
{
	scr_win(num, top, 0, bottom, CO-1);
}

void
clr_page()
{
	long written;

	SO_off();
	cur_mov(0, 0);
	CHECK(FillConsoleOutputCharacter(conout, ' ', maxpos.X*maxpos.Y, curpos, &written));
	CHECK(FillConsoleOutputAttribute(conout, c_attr, maxpos.X*maxpos.Y, curpos, &written));
}

void
flushscreen()
{
	if (bufpos != 0) {
		DWORD written;

		CHECK(WriteConsole(conout, displaybuf, bufpos, &written, NULL));
		bufpos = 0;
	}
}

void
clr_eoln()
{
	DWORD written;

	CHECK(FillConsoleOutputCharacter(conout, ' ', CO-c_col, curpos, &written));
	CHECK(FillConsoleOutputAttribute(conout, c_attr, CO-c_col, curpos, &written));
}

void
dobell(n)	/* declared in term.h */
int	n;
{
	MessageBeep(n);
}

void
ResizeWindow()
{
	/* Must update window size to eliminate those ugly scroll bars */
	SMALL_RECT newsize;

	newsize.Top = newsize.Left = 0;
	newsize.Right = maxpos.X-1;
	newsize.Bottom = maxpos.Y-1;
	/* Note: the following fails with "invalid address". If you can figure out why, please fix it. */
	SetConsoleWindowInfo(conout, TRUE, &newsize);
}

/* scr_putchar: put char on screen.  Declared in fp.h */

/* char is subject to default argument promotions */
void
scr_putchar(char c)
{
	if (bufpos >= sizeof(displaybuf))
		flushscreen();
	displaybuf[bufpos++] = c;
	switch (c) {
	case LF:
		c_row += 1;
		break;
	case CR:
		c_col = 0;
		break;
	case BS:
		if (c_col > 0)
			c_col -= 1;
		break;
	case CTL('G'):	/* ??? is this ever used? */
		dobell(1);
		break;
	default:
		if (++c_col > CO-1) {
			c_col = 0;
			c_row += 1;
		}
		break;
	}
}

/* No cursor optimization on an WIN32, this simplifies things a lot.
 * Think about it: it would be silly!
 */

void
Placur(line, col)
int	line,
	col;
{
	flushscreen();
	cur_mov(line, col);
	CapCol = col;
	CapLine = line;
}

private bool
	doing_so = NO,
	doing_us = NO;

private void
doattr()
{
	flushscreen();
	setcolor((doing_so? Mlattr : Txattr) ^ (doing_us? Hlattr : 0));
}

void
SO_effect(f)
bool f;
{
	doing_so = f;
	doattr();
}

void
US_effect(f)
bool	f;
{
	doing_us = f;
	doattr();
}

int
FatalErrorMessage(char* str)
{
	if (MessageBox(NULL, str, NULL, MB_YESNO) == IDYES) {
		return 'y';
	} else {
		return 'n';
	}
}

#endif /* WIN32 */
