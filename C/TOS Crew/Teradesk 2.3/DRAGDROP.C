/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *                                     2003 H. Robbers
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

static char pipename[] = "U:\\PIPE\\DRAGDROP.AA";
static void  *oldpipesig;

#include <np_aes.h>
#include <tos.h>
#include <string.h>
#include <mint.h>
#include <error.h>

/*
 * create a pipe for doing the drag & drop,
 * and send an AES message to the receipient
 * application telling it about the drag & drop
 * operation.
 *
 * Input Parameters:
 * apid:	AES id of the window owner
 * winid:	target window (0 for background)
 * msx, msy:	mouse X and Y position
 *		(or -1, -1 if a fake drag & drop)
 * kstate:	shift key state at time of event
 *
 * Output Parameters:
 * exts:	A 32 byte buffer into which the
 *		receipient's 8 favorite
 *		extensions will be copied.
 *
 * Returns:
 * A positive file descriptor (of the opened
 * drag & drop pipe) on success.
 * -1 if the receipient doesn't respond or
 *    returns DD_NAK
 * -2 if appl_write fails
 */

int
ddcreate(
	int dpid, int spid, int winid, int msx, int msy, int kstate,
	char exts[] )
{
	int fd, i;
	int msg[8];
	long fd_mask;
	char c;

	pipename[17] = pipename[18] = 'A';
	fd = -1;
	do
	{
		pipename[18]++;
		if (pipename[18] > 'Z')
		{
			pipename[17]++;
			if (pipename[17] > 'Z')
				break;
		}
/* mode 2 means "get EOF if nobody has pipe open for reading" */
		fd = Fcreate(pipename, 2);
	} while (fd eq EACCDN);

	if (fd < 0)
	{
	/*	v_gtext(v_hl,736,1,"Fcreate error"); */
		return fd;
	}

/* construct and send the AES message */
	msg[0] = AP_DRAGDROP;
	msg[1] = spid;
	msg[2] = 0;
	msg[3] = winid;
	msg[4] = msx;
	msg[5] = msy;
	msg[6] = kstate;
	msg[7] = (pipename[18] << 8) | (pipename[17]&0xff);
	i = appl_write(dpid, 16, msg);
	if (i eq 0)
	{
	/*	v_gtext(v_hl,736,1,"appl_write error"); */
		Fclose(fd);
		return -2;
	}

/* now wait for a response */
	fd_mask = 1L << fd;
	i = Fselect(DD_TIMEOUT, &fd_mask, 0L, 0L);
	if (!i or !fd_mask)
	{	/* timeout happened */
	/*	v_gtext(v_hl,736,1,"ddcreate: Fselect timeout"); */
		Fclose(fd);
		return -1;
	}

/* read the 1 byte response */
	i = Fread(fd, 1L, &c);
	if (i ne 1 or c ne DD_OK)
	{
	/*	if (i ne 1)
			v_gtext(v_hl,736,1,"ddcreate: read error");
		else
			v_gtext(v_hl,736,1,"ddcreate: DD_NAK");
	*/	Fclose(fd);
		return -1;
	}

/* now read the "preferred extensions" */
	i = Fread(fd, DD_EXTSIZE, exts);
	if (i ne DD_EXTSIZE)
	{
	/*	v_gtext(v_hl,736,1,"Error reading extensions");	*/
		Fclose(fd);
		return -1;
	}

	oldpipesig = Psignal(SIGPIPE, (void *)SIG_IGN);
	return fd;
}


/*
 * see if the receipient is willing to accept a certain
 * type of data (as indicated by "ext")
 *
 * Input parameters:
 * fd		file descriptor returned from ddcreate()
 * ext		pointer to the 4 byte file type
 * name		pointer to the name of the data
 * size		number of bytes of data that will be sent
 *
 * Output parameters: none
 *
 * Returns:	 see above DD_...	*/

int
ddstry(int fd, char *ext, char *name, long size)
{
	int hdrlen, i;
	char c;

/* 4 bytes for extension, 4 bytes for size, 1 byte for
 * trailing 0
 */
	hdrlen = 9 + strlen(name);
	i = Fwrite(fd, 2L, &hdrlen);

/* now send the header */
	if (i ne 2) return DD_NAK;
	i = Fwrite(fd, 4L, ext);
	i += Fwrite(fd, 4L, &size);
	i += Fwrite(fd, (long)strlen(name)+1, name);
	if (i ne hdrlen) return DD_NAK;

/* wait for a reply */
	i = Fread(fd, 1L, &c);
	if (i ne 1) return DD_NAK;
	return c;
}

/*
 * close a drag & drop operation
 */

void
ddclose(int fd)
{
	Psignal(SIGPIPE, oldpipesig);
	Fclose(fd);
}
