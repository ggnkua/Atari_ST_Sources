/* allocate arrays at starup */

/*
some significant changes in GLOBAL.H
change following #defines to int xxx=nnn;

#define GROUP_SIZE 100
#define OVERVIEW_SIZE 400
	remember threads[ ][2]
#define NEWGROUPS_SIZE 80
#define FULLGROUPS_SIZE 80
#define FULLINDEX_SIZE 150
#define FONT_SIZE 50
#define MAILBOX_SIZE 100
#define NICKNAME_SIZE 100
#define FTP_CACHE_SIZE 30
#define FTP_FILELIST_SIZE 200
#define SERVER_SIZE 30
#define FKEY_SIZE 20	(do not modify)

after things compile with GLOBAL.HN, rename GLOBAL.H to GLOBAL.HO, etc.
*/

#include <stdio.h>
#include <stdlib.h>
#include "global.hn"

void allocate_failure(char *type)
{
	char temp[80];

	sprintf( temp,"[1][Insufficient Memory for %s][ Quit ]", type );
	form_alert( 1, temp );
	exit(EXIT_FAILURE);
}

void allocate_startup(void)
{
	group = calloc( GROUP_SIZE, sizeof( struct newsgroups ) );
	if (!group) { allocate_failure( "Groups" ); }

	overview = calloc( OVERVIEW_SIZE, sizeof( struct xoverview ) );
	if (!overview) { allocate_failure( "Overview" ); }

	threads = calloc( GROUP_SIZE, sizeof( struct athread ) );
	if (!threads) { allocate_failure( "Threads" ); }

	newgroups = calloc( NEWGROUPS_SIZE, sizeof( struct agroup ) );
	if (!newgroups) { allocate_failure( "Newgroups" ); }

	fullgroups = calloc( FULLGROUPS_SIZE, sizeof( struct agroup ) );
	if (!fullgroups) { allocate_failure( "Fullgroups" ); }

	fullgroup_index = calloc( FULLINDEX_SIZE, sizeof( size_t ) );
	if (!fullgroup_index) { allocate_failure( "Fullgroup index" ); }

	font = calloc( FONT_SIZE, sizeof( struct fontinfo ) );
	if (!font) { allocate_failure( "Fonts" ); }

	mailbox = calloc( MAILBOX_SIZE, sizeof( struct mbox ) );
	if (!mailbox) { allocate_failure( "Mailbox" ); }

	nickname = calloc( NICKNAME_SIZE, sizeof( struct nick ) );
	if (!nickname) { allocate_failure( "Nicknames" ); }

	ftp_cache = calloc( FTP_CACHE_SIZE, sizeof( struct fpath ) );
	if (!ftp_cache) { allocate_failure( "FTP cache" ); }

	filelist = calloc( FTP_FILELIST_SIZE, sizeof( struct flist ) );
	if (!filelist) { allocate_failure( "FTP directory" ); }

	servers = calloc( SERVER_SIZE, sizeof( struct servers ) );
	if (!servers) { allocate_failure( "FTP servers" ); }
}