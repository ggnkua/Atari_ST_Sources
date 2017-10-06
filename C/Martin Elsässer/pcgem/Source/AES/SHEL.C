/******************************************************************************/
/*																										*/
/*		Eine handoptimierte Bibliothek fÅr Pure-C, Pure-Pascal und GNU-C			*/
/*																										*/
/* Die AES-Funktionen - SHEL-Bibliothek													*/
/*																										*/
/*	(c) 1998-2000 by Martin ElsÑsser															*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	#include <AES.H>
#else
	#include <ACSAES.H>
#endif
#include <String.H>
#include <StdArg.H>

/******************************************************************************/
/*																										*/
/* Lokale Datentypen																				*/
/*																										*/
/******************************************************************************/

typedef struct
{
	INT16 contrl[5];
	GLOBAL *globl;
	INT16 intin[17];
	INT16 intout[7];
	void *addrin[3];
	void *addrout[1];
} AESData;

/******************************************************************************/
/*																										*/
/* AES 120:	shel_read																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_read( char *cmd, char *tail )
#else
	INT16 shel_read( GLOBAL *globl, char *cmd, char *tail )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{120, 0, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=cmd;
	data.addrin[1]=tail;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 121:	shel_write																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_write( INT16 do_execute, INT16 is_graph,
					INT16 is_overlay, char *cmd, char *tail )
#else
	INT16 shel_write( GLOBAL *globl, INT16 do_execute, INT16 is_graph,
					INT16 is_overlay, char *cmd, char *tail )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{121, 3, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=do_execute;
	data.intin[1]=is_graph;
	data.intin[2]=is_overlay;
	
	data.addrin[0]=cmd;
	data.addrin[1]=tail;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 122:	shel_get																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_get( char *addr, INT16 len )
#else
	INT16 shel_get( GLOBAL *globl, char *addr, INT16 len )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{122, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=len;
	
	data.addrin[0]=addr;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 123:	shel_put																				*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_put( char *addr, INT16 len )
#else
	INT16 shel_put( GLOBAL *globl, char *addr, INT16 len )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{123, 1, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=len;
	
	data.addrin[0]=addr;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 124:	shel_find																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_find( char *path )
#else
	INT16 shel_find( GLOBAL *globl, char *path )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{124, 0, 1, 1, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=path;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 125:	shel_envrn																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_envrn( char *name, char **value )
#else
	INT16 shel_envrn( GLOBAL *globl, char *name, char **value )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{125, 0, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=name;
	data.addrin[1]=value;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_environ( char *name, char **value )
#else
	INT16 shel_environ( GLOBAL *globl, char *name, char **value )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{125, 0, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=name;
	data.addrin[1]=value;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 126:	shel_rdef																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_rdef( char *cmd, char *dir )
#else
	INT16 shel_rdef( GLOBAL *globl, char *cmd, char *dir )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{126, 0, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=cmd;
	data.addrin[1]=dir;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 127:	shel_wdef																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_wdef( char *cmd, char *dir )
#else
	INT16 shel_wdef( GLOBAL *globl, char *cmd, char *dir )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{127, 0, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.addrin[0]=cmd;
	data.addrin[1]=dir;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}

/******************************************************************************/
/*																										*/
/* AES 128:	shel_help																			*/
/*																										*/
/******************************************************************************/

#ifdef __COMPATIBLE__
	INT16 shel_help( INT16 sh_hmode, char *sh_hfile, char *sh_hkey )
#else
	INT16 shel_help( GLOBAL *globl, INT16 sh_hmode, char *sh_hfile, char *sh_hkey )
#endif
{
	/* AES-Datenblock anlegen */
	AESData data={{128, 1, 1, 2, 0}};
	
	/* Das globl-Array bestimmen */
	#ifdef __COMPATIBLE__
		data.globl=_globl;
	#else
		data.globl=(globl!=NULL ? globl : _globl);
	#endif
	
	/* Die Arrays fÅllen */
	data.intin[0]=sh_hmode;
	
	data.addrin[0]=sh_hfile;
	data.addrin[1]=sh_hkey;
	
	/* Ab in die AES... */
	aes(data.contrl, data.globl, data.intin, data.intout, data.addrin, data.addrout);
	
	return data.intout[0];
}
