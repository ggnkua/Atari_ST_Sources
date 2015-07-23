/***************************
 * manager.h               *
 ***************************
 ***************************
 * [1998-06-02, tm]        *
 * - first C version       *
 ***************************/

#ifndef MANAGER_H
#define MANAGER_H

#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <tos.h>
#include <olga.h>

#ifdef DEBUG
#include <stdio.h>
#endif


#define FALSE        0
#define TRUE         1

#define OLGAVERSION  0x0150
#define OLGAPROTOCOL 0
#define OLGAFLAGS    (OL_MANAGER | OL_START | OL_IDLE | OL_CONF)
#define OLGATIMER    1500

#define CMDMAX       9


typedef struct _Object
{
	int             ext4,
	                ext5;
	char           *descr;
	struct _Object *next;
} Object;


typedef struct _App
{
	int          apID,
	             Protocol,
	             ipaProtocol,
	             Flags,
	             XAccType,
	             cmdCount,
	             alive;
	char        *startCmd[CMDMAX+1],
	             apName[10];
	Object      *enumOLE;
	struct _App *Prev,
	            *Next;
} App;


typedef struct _Link
{
	int           apID,
	              Group;
	char         *Path;
	struct _Link *Prev,
	             *Next;
} Link;


typedef struct _Document
{
	int               apID,
	                  Group;
	struct _Document *Prev,
	                 *Next;
} Document;


typedef struct _Note
{
	int           apID,
	              ext4,
	              ext5;
	struct _Note *Prev,
	             *Next;
} Note;


typedef struct _Client
{
	int             srvID,
	                clID,
	                runFlag;
	struct _Client *Prev,
	               *Next;
} Client;


typedef struct _Server
{
	int             clID,
	                srvID,
	                ext4,
	                ext5;
	struct _Server *Prev,
	               *Next;
} Server;


typedef struct _Type
{
	int           typ;
	char         *path;
	struct _Type *next;
} Type;


typedef struct _Extension
{
	int                ext4,
	                   ext5;
	char              *path;
	struct _Extension *next;
} Extension;	


typedef struct _Alias
{
	char          *alias,
	              *path;
	struct _Alias *next;
} Alias;



extern int        ap_id;
extern int        menu_id;
extern int        magix;
extern int        mbar;
extern int        search;
extern int        memprot;
extern int        multitask;
extern int        multitos;
extern int        allocmode;
extern int        termflag;
extern int        crashtest;
extern int        linkCount;
extern int        appCount;
extern int        docCount;

extern char      *apName;

extern App       *apps;
extern Link      *links;
extern Document  *docs;
extern Type      *types;
extern Extension *extensions;
extern Alias     *aliases;
extern Object    *objects;
extern Note      *notes;
extern Server    *server;
extern Client    *clients;


void *globalAlloc(long size);
void globalFree(void *p);
void expand_path(char *p);

#endif
