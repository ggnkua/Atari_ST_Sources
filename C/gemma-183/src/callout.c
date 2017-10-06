/* The AES gateway.
 */

/*  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

# include <errno.h>

# include "gemma.h"
# include "dosproto.h"
# include "gemproto.h"
# include "emu.h"

/* Helper struct
 */

typedef struct
{
	uchar c1 : 8;
	uchar c2 : 8;
	uchar c3 : 8;
	uchar c4 : 8;
} CTRL;

/* The extreme border: this below traps to the AES
 */
static long
_aes(PROC_ARRAY *proc, short opcode)
{
	extern const ulong ctrl_list[];
	ushort c1 = 0, c2 = 0, c3 = 0, c4 = 0;
	union {
		CTRL bf;
		long nm;
	} ctrl;

	ctrl.nm = ctrl_list[opcode];

	c4 = ctrl.bf.c4;
	c3 = ctrl.bf.c3;
	c2 = ctrl.bf.c2;
	c1 = ctrl.bf.c1;

	proc->gem.control[4] = c4;
	proc->gem.control[3] = c3;
	proc->gem.control[2] = c2;
	proc->gem.control[1] = c1;
	proc->gem.control[0] = opcode;

	gemsys(AESSYS, proc->gem.aesparams);

	return (long)proc->gem.int_out[0];
}

/* This is the user AES calling routine. All user calls go this way
 * (also from within other library modules and functions).
 */
long
call_aes(BASEPAGE *bp, long fn, short nargs, PROC_ARRAY *proc, short opcode)
{
	long r;
	short x;

	if (nargs < 2) return -EINVAL;
	if (opcode > MAX_AES_OP) return -ENOSYS;
	if (!proc) proc = get_contrl(bp);

	TOUCH(proc);		/* make sure arrays are accessible */

	if (opcode != 10)	/* appl_init() */
		if (!proc->gem.global[0])
			return -EACCES;

	/* Fixes section */
	switch(opcode)
	{
		case 10:	/* appl_init() */
		{
			if (proc->gem.global[0])
				return -EACCES;
			for (x = 0; x < 16; x++)
				proc->gem.global[x] = 0;	/* safe sex */
			proc->gem.vwk_handle = -1;		/* even safer sex */
			break;
		}

		case 12:	/* appl_write(), round length up to 16 byte boundary */
		{
			short r;

			TOUCH(proc->gem.addr_in[0]);	/* access test */
			r = proc->gem.int_in[1];
			if (r & 0x000f)
			{
				r += 0xf;
				r &= ~0xf;
				proc->gem.int_in[1] = r;
			}
			TOUCH((proc->gem.addr_in[0] + r - 1));	/* also for the end of the buffer */
			break;
		}

# ifndef _HAVE_APPL_YIELD
		case 17:	/* appl_yield() */
		{
			proc->gem.int_out[0] = 1;
			_yield();

			return 1;
		}
# endif
		case 51:	/* form_dial() */
		{
			if ((proc->gem.int_in[0] == 0) || \
				(proc->gem.int_in[0] == 3))
				break;
			if (sflags.zoomboxes)
				break;
			proc->gem.int_out[0] = 1;

			return 1;
		}

		case 72:	/* graf_movebox() */
		case 73:	/* graf_growbox() */
		case 74:	/* graf_shrinkbox() */
		{
			if (sflags.zoomboxes)
				break;
			proc->gem.int_out[0] = 1;

			return 1;
		}

		case 91:	/* fsel_exinput() */
		{
# ifndef _HAVE_FSEL_EXINPUT
			if (proc->gem.global[0] < 0x0140)
			{
				TOUCH(proc->gem.addr_in[0]);
				TOUCH(proc->gem.addr_in[1]);

				return _aes(proc, 90);
			}
# endif
			TOUCH(proc->gem.addr_in[0]);
			TOUCH(proc->gem.addr_in[1]);
			TOUCH(proc->gem.addr_in[2]);

			break;
		}

		case 130:	/* appl_getinfo(), emulate on AES < 4.0 */
		{
			for (x = 0; x < 4; x++)
				proc->gem.int_out[x] = 0;
# ifndef _HAVE_APPL_GETINFO
			if (!aes40(proc))
				return emu_appl_getinfo(proc);
# endif
			break;
		}

		case 135:	/* form_popup() */
		{
# ifndef _HAVE_FORM_POPUP
			return emu_form_popup(proc);
# else
			TOUCH(proc->gem.addr_in[0]);
# endif
			break;
		}
	}

# ifndef _ROBUST_AES
	/* Access test section */
	switch(opcode)
	{
		case 13:	/* appl_find() */
		{
			unsigned long adr, r;

			adr = (unsigned long)proc->gem.addr_in[0];
			r = adr & 0xffff0000L;
			r >>= 16;
			if (!r || (r == 0xfffe) || (r == 0xffff))
			{
				short ap[4];

				_appl_getinfo(proc, 4, ap);	/* this will wrap back to this function :-) */
				if (ap[1])
					break;
			}
			TOUCH(adr);	/* access test */
			break;
		}

		case 14:	/* appl_tplay() */
		case 15:	/* appl_trecord() */
		{
			long adr;

			adr = proc->gem.addr_in[0];
			TOUCH(adr);
			adr += (long)((proc->gem.int_in[0] * 6) - 1);
			TOUCH(adr);
			break;
		}

		case 18:	/* appl_search() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 23:	/* evnt_mesag() */
		case 25:	/* evnt_multi() */
		{
			long adr;

			adr = proc->gem.addr_in[0];
			TOUCH(adr);
			adr += 15;
			TOUCH(adr);
			break;
		}

		case 30:	/* menu_bar() */
		case 31:	/* menu_icheck() */
		case 32:	/* menu_ienable() */
		case 33:	/* menu_tnormal() */
		case 35:	/* menu_register() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 34:	/* menu_text() */
		case 36:	/* menu_popup() */
		{
			TOUCH(proc->gem.addr_in[0]);
			TOUCH(proc->gem.addr_in[1]);
			break;
		}

		case 40:	/* objc_add() */
		case 41:	/* objc_delete() */
		case 42:	/* objc_draw() */
		case 43:	/* objc_find() */
		case 44:	/* objc_offset() */
		case 45:	/* objc_order() */
		case 46:	/* objc_edit() */
		case 47:	/* objc_change() */
		case 49:	/* objc_xfind() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 50:	/* form_do() */
		case 52:	/* form_alert() */
		case 54:	/* form_center() */
		case 55:	/* form_keybd() */
		case 56:	/* form_button() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 75:	/* graf_watchbox() */
		case 76:	/* graf_slidebox() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 78:	/* graf_mouse() */
		{
			if (proc->gem.int_in[0] == 255)
				TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 80:	/* scrp_read() */
		case 81:	/* scrp_write() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 105:	/* wind_set() */
		{
			long adr;
			short mode;

			mode = proc->gem.int_in[1];

			switch(mode)
			{
				case WF_NEWDESK:
				case WF_TOOLBAR:
				{
					adr = *(long *)&proc->gem.int_in[0];
					if (adr)
						TOUCH(adr);
					break;
				}

				case WF_NAME:
				case WF_INFO:
				{
					TOUCH(*(long *)&proc->gem.int_in[0]);
					break;
				}
			}
			break;
		}
				
		case 110:	/* rsrc_load() */
		case 113:	/* rsrc_sadr() */
		case 114:	/* rsrc_obfix() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 115:	/* rsrc_rcfix() */
		{
			short ap[4];

			_appl_getinfo(proc, 4, ap);
			if (ap[3])
				TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 120:	/* shel_read() */
		{
			TOUCH(proc->gem.addr_in[0]);
			TOUCH(proc->gem.addr_in[1]);
			break;
		}

		case 121:	/* shel_write(); FIXME: cover all the oddities */
		{
			switch(proc->gem.int_in[0])
			{
				case 4:		/* SWM_SHUTDOWN */
					if (proc->gem.addr_in[0])
						TOUCH(proc->gem.addr_in[0]);
					break;
				case 7:		/* SWM_BROADCAST */
					TOUCH(proc->gem.addr_in[0])
					break;
				case 8:		/* SWM_ENVIRON */
					if (proc->gem.int_in[1])
						TOUCH(proc->gem.addr_in[0]);
					break;
				case 10:	/* SWM_AESMSG */
					TOUCH(proc->gem.addr_in[0])
					break;
			}
			break;
		}

		case 122:	/* shel_get() */
		case 123:	/* shel_put() */
		case 124:	/* shel_find() */
		{
			TOUCH(proc->gem.addr_in[0]);
			break;
		}

		case 125:	/* shel_envrn() */
		case 126:	/* shel_rdef() */
		{
			TOUCH(proc->gem.addr_in[0]);
			TOUCH(proc->gem.addr_in[1]);
			break;
		}

		case 127:	/* shel_wdef() */
		{
			unsigned long adr;

			adr = proc->gem.addr_in[0];
			if (adr)
				TOUCH(adr);
			adr = proc->gem.addr_in[1];
			if (adr)
				TOUCH(adr);
			break;
		}

		case 128:	/* shel_help() */
		{
			unsigned long adr;

			TOUCH(proc->gem.addr_in[0]);
			adr = proc->gem.addr_in[1];
			if (adr)
				TOUCH(adr);
			break;
		}

		case 129:	/* appl_control() */
		{
			switch(proc->gem.int_in[1])
			{
				case 14:	/* APC_INFO */
				case 15:	/* APC_MENU */
				case 16:	/* APC_WIDGETS */
					TOUCH(proc->gem.addr_in[0]);
					break;
			}
			break;
		}
	}
# endif

	r = _aes(proc, opcode);

	/* Fixes continued */
	switch(opcode)
	{
		case 19:		/* appl_exit() */
		{
			proc->gem.global[0] = 0;
			break;
		}

		case 130:		/* appl_getinfo() */
		{
			if (!r)
				for (x = 0; x < 4; x++)
					proc->gem.int_out[x] = 0;
			break;
		}
	}

	return r;
}

/* EOF */
