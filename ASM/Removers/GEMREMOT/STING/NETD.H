/*--------------------------------------------------------------------------*/
/* File name:	NETD.H						Revision date:		1998.12.04	*/
/* Creator:		Ulf Ronald Andersson		Creation date:		1998.11.27	*/
/* (c)1998 by:	Ulf Ronald Andersson		All rights reserved				*/
/* Feedback to:	dlanor@oden.se				Released as FREEWARE			*/
/*--------------------------------------------------------------------------*/
/* Purpose:	Header file included in assembly sources to define				*/
/*			data structures needed for NETD programs under STinG.			*/
/*--------------------------------------------------------------------------*/

#ifndef STING_NETD_H
#define STING_NETD_H

#include	<TOS.H>		/* defines BASPAG used in structure further below	*/

/*--------------------------------------------------------------------------*/
/* NB: This text is optimized for 80-char width using 4-char tab spacing.	*/
/*--------------------------------------------------------------------------*/

#define	REF_IF_VER	0x0101				/* Current NetD interface version	*/

/*--------------------------------------------------------------------------*/
/*	The interface defined has its own version number, independent of the	*/
/*	version number of the NetD components (NetD STX, NetD APP, servers).	*/
/*	Components will only work together when they have the same interface	*/
/*	version, and that will usually not change with normal releases.			*/
/*	When (if) it does change, all components will need to be updated.		*/
/*--------------------------------------------------------------------------*/
/*	Note that it is not the responsibility of the servers to test this !	*/
/*	It will be done by the NetD STX, which will refuse servers with wrong	*/
/*	interface.  Servers just need to test for E_REFUSE after NetD_init_SRV.	*/
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/*	The NetD STX, the NetD APP (or ACC), and the separate NetD servers will	*/
/*	each have a structure based at their own basepage and used by the other	*/
/*	components in contacting it.  The structures used follow further below.	*/
/*--------------------------------------------------------------------------*/
/*	Note that the use of such structures, based at the basepage, enforces	*/
/*	the use of a special startup object module (NETD_SRV.O) instead of the	*/
/*	one used for linking normal applications.								*/
/*--------------------------------------------------------------------------*/

#define	ND_XB_ID	0x4E657444L	/* general NetD magic for structure headers	*/
#define	ND_STX_ID	0x5F535458L	/* NetD xmagic id for NetD_STX struct hdr	*/
#define	ND_APP_ID	0x5F415050L	/* NetD xmagic id for NetD_APP struct hdr	*/
#define	ND_SRV_ID	0x5F415050L	/* NetD xmagic id for NetD_SRV struct hdr	*/

typedef	struct	longjump_code	/* structure of long jump object code	*/
{	uint16	opcode;					/* opcode = 0x4EF9	*/
	uint32	address;				/* jump destination	*/
}	LONGJUMP_code;				/* used in structure defs further below	*/


/*--------------------------------------------------------------------------*/
/* NetD_APP	used as argument when NetD APP calls NetD STX functions through	*/
/* struct	the NetD_STX..._APP function pointers.  This is also passed to	*/
/*			servers as NetD STX calls NetD_SRV... functions in the servers	*/
/*			(So all can use GEM, but carefully !)							*/
/*--------------------------------------------------------------------------*/

typedef	struct	NetD_app					/* header structure of NetD APP	*/
{	BASPAG			base;					/* basepage of NetD APP/ACC		*/
	LONGJUMP_code	jump;					/* jump code to skip data below	*/
/*----*/
	uint32	magic;							/* NetD magic id  == ND_XB_ID	*/
	uint32	xmagic;							/* extra magic id == ND_APP_ID	*/
	uint32	if_ver;					/* NetD interface version == REF_IF_VER	*/
	uint16	date;					/* release date of NetD APP (TOS format)*/
	char	*version;					/* -> NetD APP version as "xx.yy"	*/
	char	*author;					/* -> NetD APP author name string	*/
/*----*/
	int16	*global;					/* -> AES global array of NetD APP	*/
}	NetD_APP;


/*--------------------------------------------------------------------------*/
/* NetD_CON used in three connection queues of each	NetD server, as shown	*/
/* struct	by the declaration of the NetD_SRV structure that follows even	*/
/*			further below.													*/
/*--------------------------------------------------------------------------*/

typedef	struct	NetD_con				/* substruct for connection queues	*/
{	struct	NetD_con	*next;			/* -> next entry in queue (or NULL)	*/
	void	*server;		/* NB: kludge definition, see explanation below	*/
	uint16	type_bsize;	/* 0==UDP port  nonzero==buffer_size of TCP port	*/
	uint16	port;							/* port number of connection	*/
	int16	handle;									/* handle of connection	*/
	CIB		*CIB_p;									/* -> CIB of connection	*/
	uint8	pad[16];					/* 16 bytes free for server usage	*/
}	NetD_CON;

/*--------------------------------------------------------------------------*/
/* NB:	The C language is unable to express the possibility that two data	*/
/*		structures with different declarations both contain elements that 	*/
/*		refer to the other one.  C is dependent on the declaration order,	*/
/*		so that there is no way to refer to the second declaration within	*/
/*		the first declaration. Therefore the first declaration must instead	*/
/*		refer to a 'void *' where it really needed to declare a pointer to	*/
/*		the other, as yet undefined structure.								*/
/*--------------------------------------------------------------------------*/
/* NB:	Here this means that when a server wants to access the ptr element	*/
/*		'NetD_CON.server', the value must be typecast to  '(NetD_SRV *)'	*/
/*		before comparisons etc can be made correctly. Altering the value is	*/
/*		always illegal. That should only be done by the NetD STX module.	*/
/*		(Automatically when it creates NetD_CON structs at server request.)	*/
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* NetD_SRV	installed by each NetD server into a queue of the NetD STX		*/
/* struct	by calling the ND_init_SRV function via that pointer in			*/
/*			NetD_STX.  It can be removed again by a similar call via		*/
/*			pointer ND_exit_SRV.  Both functions need a pointer to the		*/
/*			NetD_SRV struct of the server as single argument. A server can	*/
/*			only have a single NetD_SRV struct, but since each can handle	*/
/*			multiple ports this does not limit services.					*/
/*--------------------------------------------------------------------------*/

typedef	struct	NetD_srv					/* header structure for servers	*/
{	BASPAG			base;					/* basepage of the server		*/
	LONGJUMP_code	jump;					/* jump code to skip data below	*/
/*----*/
	uint32	magic;							/* NetD magic id  == ND_XB_ID	*/
	uint32	xmagic;							/* extra magic id == ND_SRV_ID	*/
	uint32	if_ver;					/* NetD interface version == REF_IF_VER	*/
	uint16	date;					/* release date of server (TOS format)	*/
	char	*version;						/* -> server version as "xx.yy"	*/
	char	*author;						/* -> server author name string	*/
/*----*/
	char	*name;								/* -> name of the server	*/
/*----*/
	struct	NetD_srv	*next;			/* -> next server struct (or NULL)	*/
/*----*/
	int16	cdecl	(* connect) (NetD_APP *ND_app_p, NetD_CON *ND_con_p);
	void	cdecl	(* traffic) (NetD_APP *ND_app_p);
	void 	cdecl	(* warning) (NetD_APP *ND_app_p);
/*----*/
	NetD_CON	*listen_q;		/* -> queue for listening connections		*/
	NetD_CON	*turnon_q;		/* -> queue for connections turning active	*/
	NetD_CON	*active_q;		/* -> queue for active connections			*/
	uint16		flags;			/* control flags (for internal NetD use)	*/
}	NetD_SRV;

/*--------------------------------------------------------------------------*/
/* NetD_STX	installed by NetD STX in cookie jar with cookie id ND_XB_ID		*/
/* struct	All cookie struct elements are controlled by the NetD STX,		*/
/*			although the other programs can affect some indirectly by using	*/
/*			the function pointers in the cookie struct to demand services.	*/
/*--------------------------------------------------------------------------*/

typedef	struct	NetD_stx					/* header structure of NetD STX	*/
{	BASPAG			base;					/* basepage of NetD STX module	*/
	LONGJUMP_code	jump;					/* jump code to skip data below	*/
/*----*/
	uint32	magic;							/* NetD magic id  == ND_XB_ID	*/
	uint32	xmagic;							/* extra magic id == ND_STX_ID	*/
	uint32	if_ver;					/* NetD interface version == REF_IF_VER	*/
	uint16	date;					/* release date of NetD STX (TOS format)*/
	char	*version;					/* -> NetD STX version as "xx.yy"	*/
	char	*author;					/* -> NetD STX author name string	*/
/*----*/
	int16 cdecl (* init_APP) (NetD_APP *app);
					/* -> func used by NetD APP to log in to NetD STX		*/
	int16 cdecl (* exit_APP) (NetD_APP *app);
					/* -> func used by NetD APP to log out from NetD STX	*/
	int16 cdecl (* exec_APP) (NetD_APP *app);
					/* -> func used by NetD APP at GEM timer events			*/
/*----*/
	int16 cdecl (* init_SRV) (NetD_SRV *srv);
					/* -> func used by servers to log in to NetD STX		*/
	int16 cdecl (* exit_SRV) (NetD_SRV *srv);
					/* -> func used by servers to log out from NetD STX		*/
/*----*/
	NetD_CON * cdecl (* init_CON) (NetD_SRV *srv, uint16 type_bsz, uint16 port);
					/* -> func used by servers to reserve NetD_CON service	*/
	int16 cdecl (* exit_CON) (NetD_SRV *srv, NetD_CON *con);
					/* -> func used by servers to release NetD_CON service	*/
	int16 cdecl (* kill_CON) (NetD_SRV *srv, NetD_CON *con);
					/* -> func used by servers to kill an active NetD_CON	*/
	int16 cdecl	(* send_CON) (NetD_CON *conn, char *buff, int16 len);
					/* -> func optionally used by servers to send data		*/
/*----*/
	NetD_SRV	*ND_server_q;			/* -> queue of servers logged in	*/
}	NetD_STX;

/*--------------------------------------------------------------------------*/

extern	NetD_STX	*NetD_STX_p;	/* init this ptr with NetD cookie value	*/

/*--------------------------------------------------------------------------*/
/* Once the pointer NetD_STX_p above has been initialized so that it does	*/
/* point to the NetD_STX structure (like the NetD cookie value does), then	*/
/* the function call macros defined below may be used by the server.		*/
/*--------------------------------------------------------------------------*/

#define NetD_init_SRV(x)		(*NetD_STX_p->init_SRV)(x)
#define NetD_exit_SRV(x)		(*NetD_STX_p->exit_SRV)(x)
#define NetD_init_CON(x,y,z)	(*NetD_STX_p->init_CON)(x,y,z)
#define NetD_exit_CON(x,y)		(*NetD_STX_p->exit_CON)(x,y)
#define NetD_kill_CON(x,y)		(*NetD_STX_p->kill_CON)(x,y)
#define NetD_send_CON(x,y,z)	(*NetD_STX_p->send_CON)(x,y,z)

/*--------------------------------------------------------------------------*/
/* Note that the other three functions in the NetD_STX structure are never	*/
/* legal for a server to call, so those functions are not defined above.	*/
/* Those will only be called by the NetD APP, which is not a C program...	*/
/*--------------------------------------------------------------------------*/

#endif /* STING_NETD_H */

/*--------------------------------------------------------------------------*/
/* End of file:	NETD.H														*/
/*--------------------------------------------------------------------------*/
