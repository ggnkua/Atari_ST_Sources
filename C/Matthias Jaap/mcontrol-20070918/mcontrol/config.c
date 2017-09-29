/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>
#include	<types2b.h>
#include	<mgx_dos.h>
#include <cflib.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"rsrc.h"
#include	"config.h"
#include	"dynrsrc.h"
#include	"mcontrol.h"
#include	"shared\file.h"
#include	"shared\path.h"
#include	"shared\alert.h"
#include	"shared\strcmd.h"

/*----------------------------------------------------------------------------------------*/
/* defines																											*/
/*----------------------------------------------------------------------------------------*/

#define	STAT_ROOT		0
#define	STAT_MCONTROL	1
#define	STAT_TITLE		2
#define	STAT_FOLDER		3

#ifndef	NIL
#define	NIL	-1
#endif

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

boolean	parse;
boolean	xml_ok;
boolean	doc_ok;
uint8		cnf_path[256];

uint8		*cnf_text;
uint8		*tptr;

int16		pstat;
int16		gl_tos;
int16		gl_depth;

NODE		*gl_nodeptr;
FOLDER	*gl_folderptr;
ITEM		*gl_itemptr;
HR			*gl_hrptr;
OBJECT	*gl_obptr;

NODE		*ac_parentnode;

NODE		*ac_nodeptr;
FOLDER	*ac_folderptr;
ITEM		*ac_itemptr;
HR			*ac_hrptr;
OBJECT	*ac_obptr;

int16		no_object;
int16		no_nodes;
int16		no_folder;
int16		no_item;
int16		no_hr;

/*----------------------------------------------------------------------------------------*/
/* functions																										*/
/*----------------------------------------------------------------------------------------*/

void	print_node( NODE *node );
void	parse_tag( NODE *tag, uint8 *attr );

/*----------------------------------------------------------------------------------------*/
/* load configuration file (cnf_path)																		*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
int16	cnf_load( uint8 *filename )
{
	uint32	fsize;
	int16		ret = 0;

	if( home_search( filename, cnf_path ) )
	{
		fsize = file_size( cnf_path );
		
		if( fsize > 0 )
		{
			cnf_text = Malloc( (int32)fsize+1 );
			
			if( cnf_text != NULL )
			{
				int32	fh;
				int32	fs;
				int32	rd;
				
				fh = Fopen( cnf_path, FO_READ );
				fs = (int32)fsize;
				
				if( fh > 0 )
				{
					int16	handle = (int16) fh;
					
					Fseek( 0l, handle, SEEK_SET );
					
					rd = Fread( handle, fs, cnf_text );
					Fclose( handle );
					
					if( rd == fs )
					{
						cnf_text[fs] = EOS;
						tab2space( cnf_text );
						ret = 1;
					}
				}
			}
		}
	}

	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* init function for allocated memory																		*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
int16	var_init( void )
{
	int16	i;

	ac_nodeptr = gl_nodeptr;
	ac_folderptr = gl_folderptr;
	ac_itemptr = gl_itemptr;
	ac_hrptr = gl_hrptr;

	for(i = 0; i < no_nodes; i++)
	{
		ac_nodeptr->parent = NULL;
 		ac_nodeptr->prev = NULL;
		ac_nodeptr->next = NULL;
		ac_nodeptr->type = RootNode;
		ac_nodeptr->attr.folder = NULL;
		ac_nodeptr->object = NIL;
		ac_nodeptr->content = NULL;
		
		ac_nodeptr++;
	}

	for(i = 0; i < no_folder; i++)
	{
		ac_folderptr->open = FALSE;
		ac_folderptr->icon_ob = NIL;
		ac_folderptr->text_ob = NIL;
		ac_folderptr->open_ob = NIL;
		ac_folderptr->cntn_ob = NIL;
		
		strcpy( ac_folderptr->bhlp, "" );
		strcpy( ac_folderptr->name, "" );
		strcpy( ac_folderptr->icon, "" );
		
		ac_folderptr++;
	}

	for(i = 0; i < no_item; i++)
	{
		ac_itemptr->icon_ob = NIL;
		ac_itemptr->text_ob = NIL;
		ac_itemptr->type = 0;

		strcpy( ac_itemptr->path, "" );
		strcpy( ac_itemptr->args, "" );
		strcpy( ac_itemptr->bhlp, "" );
		strcpy( ac_itemptr->name, "" );
		strcpy( ac_itemptr->icon, "" );
	
		ac_itemptr++;
	}

	for(i = 0; i < no_hr; i++)
	{
		ac_hrptr->flags = 0;
	
		ac_hrptr++;
	}

	ac_nodeptr = gl_nodeptr;
	ac_folderptr = gl_folderptr;
	ac_itemptr = gl_itemptr;
	ac_hrptr = gl_hrptr;

	return 0;
}

/*----------------------------------------------------------------------------------------*/
/* get tag																											*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
int16	tag_get( uint8 *tag, uint8 *buffer )
{
	boolean	ins = FALSE;

	tptr = strchr( tptr, '<' );
	
	if( !tptr )
		return 0;
		
	tptr++;
	
	while( (*tptr != ' ') && (*tptr != '>') && (*tptr != '\r') && (*tptr != '\n') && (*tptr != EOS) )
	{
		*tag++ = *tptr++;
	}
	
	*tag = EOS;
	
	tptr += voidchars( tptr );
	
	for(;;)
	{
		while( (*tptr == '\r') || (*tptr == '\n') )
			tptr++;
	
		if( *tptr == EOS || (*tptr == '>' && !ins) )
			break;
		 	
		if( *tptr == '\"' )
			ins = !ins;
		 
		 *buffer++ = *tptr++;
	}
	
	*buffer = EOS;
	
	if( *tptr == EOS )
		return 2;
	else
		return 1;
}


/*----------------------------------------------------------------------------------------*/
/* attribute check																								*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
boolean	attr_find( uint8 *attr, uint8 *buf )
{
	uint8 *p = strstri( buf, attr );
	boolean ret = FALSE;

	if( p )
	{
		uint8 ch = p[strlen(attr)];
	
		if( (ch == ' ') || (ch == '>') || (ch == EOS) )
		{
			if( p == buf )
				ret = TRUE;
			else
			{
				ch = p[-1];
				
				if( ch == ' ' )
					ret = TRUE;
			}
		
		}
	}
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* doctype check																									*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	check_root( uint8 *tag, uint8 *buf )
{
	uint8	tmp[64];

	if( strcmpi( tag, "?xml" ) == 0 )
	{
		parse_items( buf, "version", tmp );
		if( strcmpi( tmp, "1.0" ) == 0 )
			xml_ok = TRUE;
	}
	else if( strcmpi( tag, "!DOCTYPE" ) == 0 )
	{
		if( get_posval( 1, buf, tmp ) )
			if( strcmpi( tmp, "mcontrol" ) == 0 )
				doc_ok = TRUE;
	}
	else if( strcmpi( tag, "MCONTROL" ) == 0 )
	{
		if( xml_ok && doc_ok )
			pstat = STAT_MCONTROL;
		else
			i2note( 1, 0, DOCTYPE_ERROR, (int16)xml_ok, (int16)doc_ok );
	}
}


/*----------------------------------------------------------------------------------------*/
/* root parsing																									*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	parse_root( uint8 *tag, uint8 *buf )
{
	uint8	tmp[64];

	if( strcmpi( tag, "MCONTROL" ) == 0 )
	{
		if( xml_ok && doc_ok )
			pstat = STAT_MCONTROL;
	}
}


/*----------------------------------------------------------------------------------------*/
/* count root tags																								*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	count_mcontrol( uint8 *tag )
{
	if( strcmpi( tag, "FOLDER" ) == 0 )
	{
		no_folder++;
		pstat = STAT_FOLDER;
	}
	else if( strcmpi( tag, "HR" ) == 0 )
		no_hr++;
	else if( strcmpi( tag, "/MCONTROL" ) == 0 )
	{
		pstat = STAT_ROOT;
	}
}


/*----------------------------------------------------------------------------------------*/
/* count folder tags																								*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	count_folder( uint8 *tag )
{
	if( strcmpi( tag, "ITEM" ) == 0 )
		no_item++;
	else if( strcmpi( tag, "HR" ) == 0 )
		no_hr++;
	else if( strcmpi( tag, "/FOLDER" ) == 0 )
		pstat = STAT_MCONTROL;
}


void	print_node( NODE *node )
{
	NODE	*step;
	int16	i;
	
	step = node;
	
	while( step )
	{
		for( i = 0; i < gl_depth; i++ )
			Cconws(" ");
	
		switch( step->type )
		{
			case RootNode:		puts("RootNode");		break;
			case FolderTag:	puts("FolderTag");	break;
			case DocTypeTag:	puts("DocTypeTag");	break;
			case CommentTag:	puts("CommentTag");	break;
			case ItemTag: 		puts("ItemTag"); 		break;
			case HrTag: 		puts("HrTag");			break;
			default:				puts("Unknown");		break;
		}

		if( step->content )
		{
			gl_depth++;
			print_node( step->content );
			gl_depth--;
		}
		step = step->next;
	}
}


/*----------------------------------------------------------------------------------------*/
/* add node into tree																							*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	node_add( NODE *parent, NODE *ac, int16 type )
{
	NODE	*step = parent->content;
	ac->parent = parent;
	ac->type = type;
	
/*	debug("node_add() >> parent: 0x%p, ac: 0x%p\n", parent, ac); */

	if( step )
	{
		while( step->next != NULL )
			step = step->next;
			
		step->next = ac;
		ac->prev = step;
	}
	else
	{
		parent->content = ac;
	}
}


/*----------------------------------------------------------------------------------------*/
/* tag parsing	(2nd level)																						*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	parse_tag( NODE *tag, uint8 *attr )
{
	switch( tag->type )
	{
		case FolderTag:	tag->attr.folder = ac_folderptr;
								ac_folderptr++;
								parse_items( attr, "bhlp", tag->attr.folder->bhlp );
								parse_items( attr, "name", tag->attr.folder->name );
								parse_items( attr, "icn", tag->attr.folder->icon );
								break;
		case ItemTag: 		tag->attr.item = ac_itemptr;
								ac_itemptr++;
								parse_items( attr, "bhlp", tag->attr.item->bhlp );
								parse_items( attr, "name", tag->attr.item->name );
								parse_items( attr, "path", tag->attr.item->path );
								parse_items( attr, "args", tag->attr.item->args );
								parse_items( attr, "icn", tag->attr.item->icon );
								break;
		case HrTag:			tag->attr.hr = ac_hrptr;
								ac_hrptr++;
								break;
		default:				break;
	}
}


/*----------------------------------------------------------------------------------------*/
/* mcontrol parsing																								*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	parse_mcontrol( uint8 *tag, uint8 *buf )
{
	if( strcmpi( tag, "TITLE" ) == 0 )
	{
	/*	debug("Title\n"); */
	}
	else if( strcmpi( tag, "FOLDER" ) == 0 )
	{
	/*	debug("Folder\n"); */
		node_add( ac_parentnode, ac_nodeptr, FolderTag );
		parse_tag( ac_nodeptr, buf );

		pstat = STAT_FOLDER;

		ac_parentnode = ac_nodeptr;
		ac_nodeptr++;
	}
	else if( strcmpi( tag, "HR" ) == 0 )
	{
	/*	debug("hr (root)\n"); */
		node_add( ac_parentnode, ac_nodeptr, HrTag );
		parse_tag( ac_nodeptr, buf );
		ac_nodeptr++;
	}
	else if( strcmpi( tag, "/MCONTROL" ) == 0 )
	{
		pstat = STAT_ROOT;
	}
}


/*----------------------------------------------------------------------------------------*/
/* folder parsing																									*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	parse_folder( uint8 *tag, uint8 *buf )
{
	if( strcmpi( tag, "ITEM" ) == 0 )
	{
	/*	debug("\tItem\n"); */
		node_add( ac_parentnode, ac_nodeptr, ItemTag );
		parse_tag( ac_nodeptr, buf );
		ac_nodeptr++;
	}
	else if( strcmpi( tag, "HR" ) == 0 )
	{
	/*	debug("hr\n"); */
		node_add( ac_parentnode, ac_nodeptr, HrTag );
		parse_tag( ac_nodeptr, buf );
		ac_nodeptr++;
	}
	else if( strcmpi( tag, "/FOLDER" ) == 0 )
	{
	/*	debug("/Folder\n"); */
	
		pstat = STAT_MCONTROL;
		
		ac_parentnode = ac_parentnode->parent;
	}
}


/*----------------------------------------------------------------------------------------*/
/* parse configuration file (cnf_path)																		*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	cnf_parse( void )
{
	int16 mobnr = 0;
	no_nodes = 0;
	no_folder = 0;
	no_item = 0;
	no_hr = 0;
	parse = TRUE;
	xml_ok = FALSE;
	doc_ok = FALSE;
	
	debug("cnf_parse()\n");

	tptr = cnf_text;
	pstat = STAT_ROOT;

	while( parse > 0 )
	{
		uint8	tag[512] = "";
		uint8 buf[512] = "";
	
		parse = tag_get( tag, buf );
	
		switch( pstat )
		{
			case STAT_ROOT :		check_root( tag, buf );	break;
			case STAT_MCONTROL :	count_mcontrol( tag );	break;
			case STAT_FOLDER :	count_folder( tag );		break;
			default : alert( 1, 0, "[1][Wrong parser state][Damn]" );	break;
		}
	}
	
	debug("<FOLDER>: %d  <ITEM>: %d <HR> %d\n", no_folder, no_item, no_hr);
	no_nodes = 2 + no_folder + no_item + no_hr;
	mobnr = objc_count( maindial );

	gl_nodeptr = Malloc( no_nodes * sizeof( NODE ) );
	gl_folderptr = Malloc( no_folder * sizeof( FOLDER ) );
	gl_itemptr = Malloc( no_item * sizeof( ITEM ) );
	gl_hrptr = Malloc( no_hr * sizeof( HR ) );
	gl_obptr = Malloc( (2 + mobnr + no_folder * 5 + no_item * 3 + no_hr) * sizeof( OBJECT ) );
	
	if( gl_nodeptr && gl_folderptr && gl_itemptr && gl_hrptr && gl_obptr )
	{
		var_init();
	}
	else
	{
		debug("Not enough memory!\n");
		return;
	}
	
	tptr = cnf_text;
	pstat = STAT_ROOT;
	parse = TRUE;

	ac_nodeptr->type = RootNode;
	ac_parentnode = ac_nodeptr;
	ac_nodeptr++;
	
	while( parse > 0 )
	{
		uint8	tag[512] = "";
		uint8 buf[512] = "";

		parse = tag_get( tag, buf );

		switch( pstat )
		{
			case STAT_ROOT :		parse_root( tag, buf );			break;
			case STAT_MCONTROL :	parse_mcontrol( tag, buf );	break;
			case STAT_FOLDER :	parse_folder( tag, buf );		break;
			default : alert( 1, 0, "[1][Falscher Parser-Status][Mist]" );	break;
		}
	}
	
	gl_depth = 0;
	build_obtree( gl_nodeptr );
}


/*----------------------------------------------------------------------------------------*/
/* get TOS version (has to be called in supervisor mode)												*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
static int32 __init_osdata(void)
{
	OSHEADER	*os_header;

	os_header = (OSHEADER	*)*((int32 **)0x4f2L);

	gl_tos    = os_header->os_version;

	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* module init																										*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
void	init_conf( void )
{
	Supexec(__init_osdata);

	if( cnf_load( "mcontrol.xml" ) == 1 )
	{
		cnf_parse();
	}
	else
	{
		note( 1, 0, NO_CONFIGFILE );
		gl_obptr = maindial;
	}
}