/* This file is part of the AHCC GEM Library.

   The AHCC GEM Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC GEM Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.

   Copyright (c) 2008 by Henk Robbers @ Amsterdam.
*/

#include "aespb.h"

typedef struct /* Special type for EventMulti */
{
	/* input parameters */
	short flags, bclicks, bmask, bstate,
	      m1flags, m1x, m1y, m1width, m1height,
	      m2flags, m2x, m2y, m2width, m2height,
	      tlocount, thicount;
	/* output parameters */
	short which,
	      mox, moy,
	      mobutton, mokstate,
	      kreturn, breturn;
	/* message buffer */
	short msgpbuf[8];
} EVENT;

short G_decl evnt_keybd(void)
{
	short io;
	SETACTL(20,0,1,0,0);

	G_trap(c,pglob,0L,&io,0L,0L);
	return io;
}

short G_decl evnt_button(short clks,short mask,short state,
                short *omx,short *omy,short *but,short *ostate)
{
	short ii[3], io[5];
	SETACTL(21,3,5,0,0);

	ii[0] = clks, ii[1] = mask, ii[2] = state;
	G_trap(c,pglob,ii,io,0L,0L);
	if (omx)    *omx=io[1];
	if (omy)    *omy=io[2];
	if (but)    *but=io[3];
	if (ostate) *ostate=io[4];
	return io[0];
}

short G_decl evnt_mouse(short flags,short mx,short my,short mw,short mh,
               short *omx,short *omy,short *but,short *ostate)
{
	short ii[5],io[5];
	SETACTL(22,5,5,0,0);

	ii[0] = flags, ii[1] = mx, ii[2] = my, ii[3] = mw, ii[4] = mh;

	G_trap(c,pglob,ii,io,0L,0L);
	if (omx)    *omx=io[1];
	if (omy)    *omy=io[2];
	if (but)    *but=io[3];
	if (ostate) *ostate=io[4];
	return io[0];
}

short G_decl evnt_mesag(short *msgpipe)
{
	short io;
	SETACTL(23,0,1,1,0);
	G_trap(c,pglob,0L,&io,&msgpipe,0L);
	return io;
}

short G_decl evnt_timer(short loc, short hic)
{
	short ii[2], io;
	SETACTL(24,2,1,0,0);

	ii[0] = loc, ii[1] = hic;
	G_trap(c,pglob,ii,&io,0L,0L);
	return io;
}

short G_decl evnt_multi
			  (short flags,short clks,short mask,short state,
               short m1flags,short m1x,short m1y,short m1w,short m1h,
               short m2flags,short m2x,short m2y,short m2w,short m2h,
               short *msgpipe,
               short loc,short hic,
               short *omx,short *omy,short *but,short *ostate,
               short *toets,short *oclks)
{
	short ii[16],io[7];
	SETACTL(25,16,7,1,0);

	ii[0]=flags;
	ii[1]=clks;
	ii[2]=mask;
	ii[3]=state;
	ii[4]=m1flags;
	ii[5]=m1x;
	ii[6]=m1y;
	ii[7]=m1w;
	ii[8]=m1h;
	ii[9]=m2flags;
	ii[10]=m2x;
	ii[11]=m2y;
	ii[12]=m2w;
	ii[13]=m2h;
	ii[14]=loc;
	ii[15]=hic;

	G_trap(c,pglob,ii,io,&msgpipe,0L);

	if (omx)    *omx=io[1];
	if (omy)    *omy=io[2];
	if (but)    *but=io[3];
	if (ostate) *ostate=io[4];
	if (toets)  *toets=io[5];
	if (oclks)  *oclks=io[6];
	return io[0];
}

short G_decl EvntMulti(EVENT *event)
{
	short *ai = event->msgpbuf;
	SETACTL(25,16,7,1,0);
	G_trap(c,pglob, &event->flags, &event->which, &ai, 0L);
	return event->which;
}

short G_decl evnt_dclick(short new,short getset)
{
	short ii[2], io;
	SETACTL(26,2,1,0,0);
	ii[0] = new, ii[1] = getset;

	G_trap(c,pglob,ii,&io,0L,0L);
	return io;
}
