/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

#ifndef _config_h_
#define _config_h_

#include	<types2b.h>

/*----------------------------------------------------------------------------------------*/
/* struct definitions																							*/
/*----------------------------------------------------------------------------------------*/

#define	RootNode        0
#define	DocTypeTag      1
#define	CommentTag      2
#define	FolderTag       3
#define	ItemTag         4
#define	HrTag				 5

typedef	struct _folder
{
	int16		icon_ob;
	int16		text_ob;
	int16		open_ob;
	int16		cntn_ob;

	boolean	open;

	uint8 	bhlp[256];
	uint8 	name[64];
	uint8 	icon[64];
} FOLDER;

typedef	struct _item
{
	int16		icon_ob;
	int16		text_ob;
	int16		type;

	uint8		path[256];
	uint8		args[256];
	uint8 	bhlp[256];
	uint8 	name[64];
	uint8 	icon[64];
} ITEM;

typedef	struct _hr
{
	int16		flags;
} HR;

typedef union nodeattrptr
{
	FOLDER	*folder;
	ITEM		*item;
	HR			*hr;
	uint8		*free_string;
} NDATTR;

typedef	struct _node
{
    struct _node *parent;
    struct _node *prev;
    struct _node *next;
    int16	object;
    uint16	type;              /* TextNode, StartTag, EndTag etc. */
    NDATTR	attr;
    struct _node *content;
} NODE;


typedef struct
{
	int32		gm_magic;
	void		*gm_end;
	void		*gm_init;
} GEM_MUBP;

typedef struct _osheader
{
	UWORD		os_entry;
	UWORD		os_version;
	void		*reseth;
	struct	_osheader	*os_beg;
	void						*os_end;
	int32		os_rsv1;
	GEM_MUBP	*os_magic;
	int32		os_date;
	UWORD		os_conf;
	UWORD		os_dosdate;
} OSHEADER;

extern	int16		gl_tos;

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

int16		cnf_load( uint8 *filename );
int16		var_init( void );
int16		tag_get( uint8 *tag, uint8 *buffer );
boolean	attr_find( uint8 *attr, uint8 *buf );
void		count_mcontrol( uint8 *tag );
void		count_folder( uint8 *tag );
void		check_root( uint8 *tag, uint8 *buf );

void		node_add( NODE *parent, NODE *ac, int16 type );
void		parse_mcontrol( uint8 *tag, uint8 *buf );
void		parse_folder( uint8 *tag, uint8 *buf );
void		parse_root( uint8 *tag, uint8 *buf );
void		cnf_parse( void );
void		init_conf( void );

#endif