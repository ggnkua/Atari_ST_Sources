/*--------------------------------------------------------------------------*/
/* File name:			i_net.c					Revision date:	2000.03.24	*/
/* Revision author:		Ronald Andersson		Revision basis:	0.24		*/
/* Main author:			Patrice Mandin			Project:		PMDoom		*/
/*--------------------------------------------------------------------------*/
/* Revision purpose:	Add compatibility to STinG networking API			*/
/*--------------------------------------------------------------------------*/
/* This text was updated with a tab setting of four characters.				*/
/*--------------------------------------------------------------------------*/
// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// $Log:$
//
// DESCRIPTION:
//
//-----------------------------------------------------------------------------

#ifdef __MINT__

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <ctype.h>
#include <mint/osbind.h>

#include <errno.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include <support.h>
#include <fcntl.h>

#include "sting/transprt.h"

#include "i_system.h"
#include "i_net.h"
#include "d_event.h"
#include "d_net.h"
#include "m_argv.h"

#include "doomstat.h"

void	NetSend (void);
boolean NetListen (void);

/*--------------------------------------------------------------------------*/
/*  NETWORKING */
/*--------------------------------------------------------------------------*/
DRV_LIST	*stik_drivers;
TPL			*tpl;

static int16	DOOMPORT = 5000 +0x1d;
int16	conn_handle[MAXNETNODES];
CAB		conn_address[MAXNETNODES];
int16	conn_count = -1;

/*--------------------------------------------------------------------------*/
/*		UDPsocket		one version each for STinG and Mintnet				*/
/*--------------------------------------------------------------------------*/
static int	UDPsocket(void)		/* For STinG we just reserve an array entry here */
{	int16	i;

	if	(conn_count < 0)		/* Does the array need (re)initialization ? */
	{	for	(i = 0; i < MAXNETNODES; i++)
			conn_handle[i] = -2;	/* Mark each array entry as undefined */
		conn_count = 0;				/* Array is now initialized */
	}

	if	(conn_count >= MAXNETNODES)
	{	I_Error ("can't create socket: MAXNETNODES exceeded");
		return -1;
	}
	conn_handle[conn_count] = -1;	/* Mark entry defined, but not opened */
	return (int) conn_count++;
}

/*--------------------------------------------------------------------------*/
/*		BindToLocalPort for Mintnet, but BindToConn for STinG				*/
/*--------------------------------------------------------------------------*/
static void	BindToConn (int s, int16 l_port, int16 r_port, int32 r_host)
{	int16	conn;

	if	( conn_handle[s] != -1 )
		conn = E_BADHANDLE;			/* Array entry was not reserved right */
	else
	{	conn_address[s].lhost = 0;
		conn_address[s].lport = l_port;
		conn_address[s].rport = r_port;
		conn_address[s].rhost = r_host;
		conn = UDP_open( (uint32) &conn_address[s], UDP_EXTEND);
		if	(conn >= 0)
			conn_handle[s] = conn;
	}

    if	(conn < 0)
		I_Error ("BindToConn: bind: %s", get_err_text(conn));
}

/*--------------------------------------------------------------------------*/
/*		PacketSend		has internal diffs for STinG/Mintnet				*/
/*--------------------------------------------------------------------------*/
static void PacketSend (void)
{
	int			c;
	doomdata_t	sw;
				
	/*  byte swap */
	sw.checksum = htonl(netbuffer->checksum);
	sw.player = netbuffer->player;
	sw.retransmitfrom = netbuffer->retransmitfrom;
	sw.starttic = netbuffer->starttic;
	sw.numtics = netbuffer->numtics;
	for (c=0 ; c< netbuffer->numtics ; c++)
	{
		sw.cmds[c].forwardmove = netbuffer->cmds[c].forwardmove;
		sw.cmds[c].sidemove = netbuffer->cmds[c].sidemove;
		sw.cmds[c].angleturn = htons(netbuffer->cmds[c].angleturn);
		sw.cmds[c].consistancy = htons(netbuffer->cmds[c].consistancy);
		sw.cmds[c].chatchar = netbuffer->cmds[c].chatchar;
		sw.cmds[c].buttons = netbuffer->cmds[c].buttons;
	}
		
	/* printf ("sending %i\n",gametic);		 */

	if	(conn_handle[doomcom->remotenode] >= 0)
		c = UDP_send(conn_handle[doomcom->remotenode]
					,(char *) &sw, (int16) doomcom->datalength);

	/* 	if (c < 0) */
	/* 		I_Error ("SendPacket error: %s", get_err_text(c)); */
}

/*--------------------------------------------------------------------------*/
/*		PacketGet		large internal diffs for STinG/Mintnet				*/
/*--------------------------------------------------------------------------*/
static void PacketGet (void)
{
	int			i;
	int			c=0;
	doomdata_t	sw;

	NDB	*rx_ndb;

	for	(i=0; i < doomcom->numnodes; i++)
	{	if	(conn_handle[i] >= 0)
		{	c = (int) CNbyte_count(conn_handle[i]);
			if	(c  &&  c != E_LISTEN)
				break;
		}
	}
	if	( c <= 0 )
	{	if	( c  &&  c != E_LISTEN )
			I_Error ("GetPacket: %s", get_err_text(c));
		doomcom->remotenode = -1;		/*  no packet */
		return;
	}

	{	static int first=1;
		if (first)
			printf("len=%d:p=[0x%x 0x%x] \n", c, *(int*)&sw, *((int*)&sw+1));
		first = 0;
	}

	/* NB: We only come here when a packet NDB with data is available, */
	/*     so no more testing of that is needed, just data extraction. */

	rx_ndb = CNget_NDB(conn_handle[i]);
	memcpy( &sw, rx_ndb->ndata, sizeof(sw));
	KRfree( rx_ndb->ptr );
	KRfree( rx_ndb );

	/* At this point the index 'i' from 'for' above is still valid, */
	/* and it will be used by some code further down in the text.	*/

	doomcom->remotenode = i;			/*  good packet from a game player */
	doomcom->datalength = c;
	
	/*  byte swap */
	netbuffer->checksum = ntohl(sw.checksum);
	netbuffer->player = sw.player;
	netbuffer->retransmitfrom = sw.retransmitfrom;
	netbuffer->starttic = sw.starttic;
	netbuffer->numtics = sw.numtics;

	for (c=0 ; c< netbuffer->numtics ; c++)
	{
		netbuffer->cmds[c].forwardmove = sw.cmds[c].forwardmove;
		netbuffer->cmds[c].sidemove = sw.cmds[c].sidemove;
		netbuffer->cmds[c].angleturn = ntohs(sw.cmds[c].angleturn);
		netbuffer->cmds[c].consistancy = ntohs(sw.cmds[c].consistancy);
		netbuffer->cmds[c].chatchar = sw.cmds[c].chatchar;
		netbuffer->cmds[c].buttons = sw.cmds[c].buttons;
	}
}

/*--------------------------------------------------------------------------*/
static uint32	dip_to_bip( char *dip )
{	uint32	bip = 0;
	int16	i, j, part, done;
	char	ch;

	for	( done = i = 0; i < 4; i++ )
	{	for	( part = j = 0; !done && j < 3; j++ )
		{	ch = *dip++;
			if  ( isascii(ch)  &&  isdigit(ch) )
			{	part *= 10;
				part += ch - '0';
			}
			else
			{	if	( ch != '.'  ||  part > 255 )
					done = 1;
				break;
			}
		}
		bip <<= 8;
		if	( !done )
			bip |= part;
	}
	return	bip;
}

/*--------------------------------------------------------------------------*/
/*	I_ShutdownSting needs to be called before program exit, after network	*/
/*  games, and also before a new such game can be restarted.  STinG does	*/
/*  not have 'sockets', but connections, so they must be closed sometime.	*/
/*--------------------------------------------------------------------------*/
static void	I_ShutdownSting(void)
{	int16	i;

	for	(i = 0; i < conn_count; i++)	/* for each open connection	*/
		UDP_close(conn_handle[i]);		/* close the global handle	*/
	conn_count = -1;					/* mark local array invalid	*/
}

/*--------------------------------------------------------------------------*/
static int32	eval_cookie( uint32 name)
{	uint32	*work;
	void	*old_ssp;

	old_ssp = (void *) Super(0);
	for	(	work = *((uint32 **) 0x5a0);
			*work && *work != name;
			work += 2
		);
		/* NB: the above is a bodiless search loop */
	Super(old_ssp);
	if	(!work ||  !*work)
		return	0;
	return	work[1];	
}

/*--------------------------------------------------------------------------*/
/*  Init_STinG																*/
/*--------------------------------------------------------------------------*/
static int16	Init_STinG ()
{	stik_drivers = (DRV_LIST *) eval_cookie((uint32) 0x5354694bUL);

	if	(stik_drivers == NULL)
		return (-3);
	if	(strcmp (stik_drivers->magic, MAGIC) != 0)
		return (-2);

	tpl = (TPL *) (*stik_drivers->get_dftab) (TRANSPORT_DRIVER);

	if	(tpl == (TPL *) NULL)
		return (-1);

	return (0);			/* Now we can call STinG API functions */
}

/*--------------------------------------------------------------------------*/
/*		I_InitNetwork		this now has major preprocessor hacks...		*/
/*--------------------------------------------------------------------------*/
void I_InitNetwork_sting (void)
{
	int			i;
	int			p;
	
	doomcom = malloc (sizeof (*doomcom) );
	memset (doomcom, 0, sizeof(*doomcom) );
    
	/*  set up for network */
	i = M_CheckParm ("-dup");
	if	(i && i< myargc-1)
	{
		doomcom->ticdup = myargv[i+1][0]-'0';
		if	(doomcom->ticdup < 1)
			doomcom->ticdup = 1;
		if	(doomcom->ticdup > 9)
			doomcom->ticdup = 9;
	}
	else
		doomcom-> ticdup = 1;
	
	if	(M_CheckParm ("-extratic"))
		doomcom-> extratics = 1;
	else
		doomcom-> extratics = 0;
		
	p = M_CheckParm ("-port");
	if (p && p<myargc-1)
	{
		DOOMPORT = atoi (myargv[p+1]);
		printf ("using alternate port %i\n",DOOMPORT);
	}

	/*  parse network game options, */
	/*   -net <consoleplayer> <host> <host> ... */
	i = M_CheckParm ("-net");
	if (!i)
	{
		/*  single player game */
		netgame = false;
		doomcom->id = DOOMCOM_ID;
		doomcom->numplayers = doomcom->numnodes = 1;
		doomcom->deathmatch = false;
		doomcom->consoleplayer = 0;
		return;
	}

	if	(Init_STinG() < 0)
		I_Error ("I_InitNetwork failed in Init_STinG.");

/*RA_bugfix:	netsend = PacketSend;	*/
/*RA_bugfix:	netget = PacketGet;	*/
/*RA_bugfix:	netgame = true;		*/

/* Those variables should not be set now, as we don't have valid nodes yet. */
/* They should be set further below, if at least 2 valid nodes are found.	*/
/* If none are found we still need to abort to single player mode...		*/

	/*  parse player number and host list */
	doomcom->consoleplayer = myargv[i+1][0]-'1';

/*RA_bugfix:	doomcom->numnodes = 1;	*/	/*  this node for sure */

/* That node is not 'for sure' until we have a valid address.  */
/* Taking that address, like any other such address, will add  */
/* 1 to doomcom->numnodes, so it will be too high at the end.  */

	doomcom->numnodes = 0;	/* correct for now, incremented later */
	i++;

	while (++i < myargc && myargv[i][0] != '-')
	{
		uint32	bip;
		int16	temp;

		if	(myargv[i][0] == '.')
			bip = dip_to_bip( myargv[i]+1 );
		else
		{	temp = resolve(myargv[i], NULL, &bip, 1);
			if	(temp < 1)
				I_Error ("resolve: %s failed with: %s",
						myargv[i], get_err_text(temp));
		}
		if	( (temp = UDPsocket()) >= 0 )
			BindToConn( temp, DOOMPORT, DOOMPORT, bip );
		doomcom->numnodes++;
	}
	if	(doomcom->numnodes < 2)		/* if insufficient net nodes	*/
	{	doomcom->numnodes = 1;		/* back to single player mode	*/
		I_ShutdownSting();			/* close any open connections	*/
	}
	else
	{	netsend = PacketSend;		/* else activate network mode	*/
		netget = PacketGet;
		netgame = true;
	}

	doomcom->id = DOOMCOM_ID;
	doomcom->numplayers = doomcom->numnodes;

	/*  build message to receive */

	/* STinG's connections were completed above */
}

void I_ShutdownNetwork_sting(void)
{
	I_ShutdownSting();

	if (doomcom) {
		free(doomcom);
		doomcom = NULL;
	}
}

#endif	/* __MINT__ */
