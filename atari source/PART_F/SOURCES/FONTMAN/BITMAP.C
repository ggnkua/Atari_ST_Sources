#include "fsm.h"		/* FSM includes */
#include "afsm.h"
#include "areal.h"

extern 	_MyAlloc(), _MyRelease(), MyNoop(), _MyError(), _MyFopen(), 
	_MyFclose(), _MyFseek(), _MyFread();
fsm_ClientType clientp;

int init_fsm()
{
	v_fsm_createclient(handle, _MyAlloc, _MyRelease, MyNoop, _MyError,
			   _MyFopen, _MyFclose, _MyFseek, _MyFread,
			   25L, 1L, 1L, &clientp);
}

int exit_fsm()
{
	v_fsm_kill_client(handle, &clientp);
}

void string_bitmap(string, font, ypos, type)
char *string;
char *font;
int ypos;
int type;
/* string_bitmap(string, font, ypos, type)
   Creates a single plane bitmap for a string.  
   Places that bitmap into the large bitmap for all fonts at the given pos.
   "type" determines the kind of operation -- 0 for create a syetm font
   version of the font, 1 to erase the system font and place the FSM
   font over it.
   Returns a pointer to an FDB that describes the bitmap.  
 */
{
	fsm_FontType fontp;
	fsm_OutputType fsmOutput;
	fsm_ComponentType *component;
	int i, len;
	int width, pos, xoff, yoff;
	long location;
	int blit[8];
	int colors[2] = {1, 0};
	int hz, vt;

	screen.fd_addr = 0L;		/* Just to be sure */

	if ((len = strlen(string)) < 0) return;
	else if (len > 29) string[29] = '\0';

	pos = 0;
	if (type == FSM_FONT_PREV) {
		v_fsm_readfont(handle, font, &clientp, &fontp);
		}
	else {
		location = all.fd_addr;
		location += (long )(ypos + 1) * 
			    (long )(all.fd_wdwidth) * 2L;

		if (type == FSM_FONT) vst_effects(handle, 1);
		text_to_bitmap(location, (all.fd_wdwidth * 2), 1);
		vst_alignment(handle, 0, 5, &hz, &vt);
		v_gtext(handle, 0, 0, string);
		text_to_screen();
		if (type == FSM_FONT) vst_effects(handle, 0);

		return;
		}

	for (i = 0; i < len; ++i) {
		v_fsm_char(handle, (int )string[i], 1,
		   ritor((long )line_h - 1L), ritor((long )line_h - 1L),
		   REAL_ZERO, REAL_ZERO, &fontp, &clientp,
		   1L, &fsmOutput);

		component = fsmOutput.firstComponent.ptr;
		width = component->bm.width;

		one.fd_w = width;
		one.fd_wdwidth = (width + 15) / 16;
		one.fd_h = component->bm.height;	
		one.fd_addr = (long ) component->bm.data;		

		xoff = rrou(component->bm.xOffset);
		yoff = rrou(component->bm.yOffset);

		blit[0] = 0;		/* Source rectangle */
		blit[1] = 0;
		blit[2] = one.fd_w - 1;	
		blit[3] = one.fd_h - 1;

		blit[4] = char_w + pos + xoff;
		blit[5] = ypos + line_h + yoff - 1;	/* Baseline of line_h - 1 */
		blit[6] = blit[4] + blit[2];
		blit[7] = blit[5] + blit[3];

		vs_clip(handle, 0, blit);	/* Clipping off */
		vrt_cpyfm(handle, 2, blit, &one, &all, colors);   /* Mem */

		pos += abs( (int )rrou(fsmOutput.advance.x) );
		}

	v_fsm_killfont(handle, &fontp, &clientp);

	return;
}

