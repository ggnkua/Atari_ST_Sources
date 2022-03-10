/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*				 This module was written by Vince Perriello 				*/
/*																			*/
/*																			*/
/*				   BinkleyTerm Nodelist processing module					*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>
#include <errno.h>

#ifdef __TOS__
#include <time.h>
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#include <dos.h>
#endif

#ifndef LATTICE
#include <io.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "nodeproc.h"
#include "sbuf.h"

#if defined(__TURBOC__) /* || defined(LATTICE) */
typedef size_t off_t;
#endif


/*
 * Global variables
 */


NODELISTTYPE nodeListType = VERSION6;

char *node_prefix = NULL;			/* Dial Prefix for this node */
int autobaud = 0;					/* Use highest baudrate when calling out */
int found_zone = 0; 				/* What zone found node is in*/
int found_net = 0;					/* What net found node is in */
struct _newnode newnodedes; 		/* structure in new list	 */


/*
 * Local Variables
 */

static const char nodelist_name[] = "NODELIST";		/* Default Nodelist name */
static int last_zone = -1;

static const char btnc_idx[] = "INDEX.BNL";
static const char btnc_dat[] = "NODEINFO.BNL";
static const char btnc_dmn[] = "DOMAINS.BNL";

/*--------------------------------------------------------
 * NodeList cache
 */

typedef enum { MODE_DEFAULT, MODE_KNOWN, MODE_PROTECTED } PROTMODE;

/* An entry in the cache */

typedef struct {
	ADDR ad;
	int next;		/* Index to next item in cache */
	int prev;		/* Index to previous item */
	struct _newnode des;
	char *nodePrefix;
	PROTMODE mode;
	int assumed;	/* Node to assume */
} NODECACHE;

unsigned int cacheSize = 16;		/* Size of cache */
NODECACHE *nodeCache = NULL;		/* The actual cache */
int firstCache = -1;				/* Entry point to used slots */
int lastCache = -1;					/* Last used slot */
int freeCache = -1;					/* Entry to unused slots */


BOOLEAN checkNodeCache(ADDR *ad)
{
	int i;

	/* Initialise the cache if not already done so */

	if(nodeCache == NULL)
	{
		int i;
		NODECACHE *cache;

		if(cacheSize == 0)		/* Cache not active */
			return FALSE;

		nodeCache = calloc(sizeof(NODECACHE), cacheSize);
		if(nodeCache == NULL)
			return FALSE;

		/* Initialise linked list of free slots */

		for(cache = nodeCache, i = 0; i < cacheSize; i++, cache++)
		{
			cache->next = i - 1;
		}

		freeCache = cacheSize - 1;

	}

	/* Search used spaces for address */

	i = firstCache;
	while(i >= 0)
	{
#ifdef DEBUG
		if(debugging_log)
			status_line(">nodeCache: %d <- %d -> %d",
				nodeCache[i].prev, i, nodeCache[i].next);
#endif
		if(memcmp(&nodeCache[i].ad, ad, sizeof(ADDR)) == 0)		/* Structure compare */
		{
#ifdef DEBUG
			if(debugging_log)
				status_line(">%s found in cache (slot %d)!", Pretty_Addr_Str(ad), i);
#endif

			/* Copy the data and return success */

			newnodedes = nodeCache[i].des;		/* Structure copy */
			switch(nodeCache[i].mode)
			{
			case MODE_PROTECTED:
				CurrentOKFile = PROT.rq_OKFile;
				CurrentFILES = PROT.rq_FILES;
				CurrentAbout = PROT.rq_About;
				CurrentReqTemplate = PROT.rq_Template;
				CurrentNetFiles = PROT.sc_Inbound;
				CurrentReqLim = PROT.rq_Limit;
				CurrentByteLim = PROT.byte_Limit;
				CurrentTimeLim = PROT.time_Limit;
				break;
			case MODE_KNOWN:
				CurrentOKFile = KNOWN.rq_OKFile;
				CurrentFILES = KNOWN.rq_FILES;
				CurrentAbout = KNOWN.rq_About;
				CurrentReqTemplate = KNOWN.rq_Template;
				CurrentNetFiles = KNOWN.sc_Inbound;
				CurrentReqLim = KNOWN.rq_Limit;
				CurrentByteLim = KNOWN.byte_Limit;
				CurrentTimeLim = KNOWN.time_Limit;
				break;
			case MODE_DEFAULT:
				CurrentOKFile = DEFAULT.rq_OKFile;	 /* Set the default f.req paths */
				CurrentFILES = DEFAULT.rq_FILES;
				CurrentAbout = DEFAULT.rq_About;
				CurrentReqTemplate = DEFAULT.rq_Template;
				CurrentNetFiles = DEFAULT.sc_Inbound;
				CurrentReqLim = DEFAULT.rq_Limit;
				CurrentByteLim = DEFAULT.byte_Limit;
				CurrentTimeLim = DEFAULT.time_Limit;
				break;
			}
			found_zone = ad->Zone;
			found_net = ad->Net;
			node_prefix = nodeCache[i].nodePrefix;
			assumed = nodeCache[i].assumed;

			/*
			 * Move to front of list
			 */

			if(firstCache != i)	/* Not already at front! */
			{
				int next;
				int prev;

				/* unlink */

				next = nodeCache[i].next;
				prev = nodeCache[i].prev;
				if(next >= 0)
					nodeCache[next].prev = prev;
				else
					lastCache = prev;
				if(prev >= 0)
					nodeCache[prev].next = next;

				nodeCache[i].prev = -1;
				nodeCache[i].next = firstCache;
				if(firstCache >= 0)
					nodeCache[firstCache].prev = i;
				firstCache = i;

			}

#ifdef DEBUG
			if(debugging_log)
				status_line(">NodeCache: free=%d, first=%d, last=%d",
					freeCache, firstCache, lastCache);
#endif
			return TRUE;
		}
		i = nodeCache[i].next;
	}

#ifdef DEBUG
	if(debugging_log)
		status_line(">NodeCache: %s not found", Pretty_Addr_Str(ad));
#endif
	return FALSE;
}

/*
 * Add an address to the node cache
 */

void addNodeCache(ADDR *ad, PROTMODE mode)
{
	int i;

	/* Quit if cache not active */

	if(cacheSize == 0)
		return;

	/* 1st check it isn't already in! */

	if(checkNodeCache(ad))
		return;

#ifdef DEBUG
	if(debugging_log)
		status_line(">%s added to cache!", Pretty_Addr_Str(ad));
#endif

	/* Find a free slot */

	if(freeCache >= 0)
	{
		i = freeCache;					/* Remove a free slot */
		freeCache = nodeCache[i].next;
		if(lastCache < 0)
			lastCache = i;
#ifdef DEBUG
		if(debugging_log)
			status_line(">NodeCache: Free slot %d", i);
#endif
	}
	else	/* Need to free an old one */
	{
		i = lastCache;
		lastCache = nodeCache[i].prev;
		nodeCache[lastCache].next = -1;
#ifdef DEBUG
		if(debugging_log)
			status_line(">NodeCache: reused slot %d (%s)",
					i, Pretty_Addr_Str(&nodeCache[i].ad));
#endif
	}

	/* We got a free slot */

	/* Fill in the info */

	nodeCache[i].ad = *ad;					/* Structure copy */
	nodeCache[i].des = newnodedes;			/* structure copy */
	nodeCache[i].nodePrefix = node_prefix;	/* Dialling prefix */
	nodeCache[i].mode = mode;
	nodeCache[i].assumed = assumed;

	/* Link it to front of list */

	nodeCache[i].prev = -1;
	nodeCache[i].next = firstCache;
	if(firstCache >= 0)
		nodeCache[firstCache].prev = i;
	firstCache = i;

#ifdef DEBUG
	if(debugging_log)
		status_line(">NodeCache: free=%d, first=%d, last=%d",
			freeCache, firstCache, lastCache);
#endif
}

/*-----------------------------------------------------------
 * Nodelist locking
 *
 * This keeps the nodelist open during nodelist intensive processing
 *
 * It should only be used when accessing a single domain
 *
 * Also it currently only works for opus newnodelist
 *
 * TRUE enables locking, FALSE disables it
 *
 * Calls may be nested, but there must always be an equal number of each.
 */

#ifdef __TOS__
static int fp_nodelist = -1;			/* GEMDOS handle */
#else
static FILE *fp_nodelist = NULL;		/* File handle for nodelist when locked */
#endif

static int nodelock = 0;

void lock_nodelist(BOOLEAN flag)
{
	if(flag)	/* Lock the nodelist */
		nodelock++;
	else		/* Unlock it */
		if(!--nodelock)
#ifdef __TOS__
			if(fp_nodelist >= 0)
			{
				Fclose(fp_nodelist);
				fp_nodelist = -1;
			}
#else
			if(fp_nodelist)
			{
				fclose(fp_nodelist);
				fp_nodelist = NULL;
			}
#endif
}



/*
 * STeVeN's fast nodelist lookup
 *
 * Index file is made into 3 sorted lists
 */

typedef struct {
	int zone;			/* Zone */
	long netIndex;		/* For Zone... index to net linked list */
	long netCount;		/* Number of nets in this zone */
} ZONESLIST;

typedef struct {
	int net;			/* Our net */
	long nodeIndex;		/* Index to nodes list */
	long nodeCount;		/* Number of nodes in this net */
} NETSLIST;

typedef struct {
	long node;
} NODESLIST;

/*
 * Point lists
 * If consecutive nodes have the same address then it is assumed that
 * they are points and a search should be made in here
 *
 * One of these is maintained for each domain
 *
 * It is assumed that there are not very many point bosses
 * If this assumtion is wrong then a hierarchy similar to the
 * nodes can be done... in fact the same structures could be
 * used except the nodeIndex would point to a POINTBOSSLIST, which
 * would contain node, pointCount, pointIndex
 */

typedef struct {
	long zone;
	long net;
	long node;
	long pointCount;
	long pointIndex;
} POINTBOSSLIST;

typedef struct {
	int point;		/* The point number.. the position in this table	 */
					/* is added to the bosses index to obtain the record */
} POINTLIST;

/*
 * Information for a Domain's nodelist
 */

typedef struct s_domainList DOMAINLIST;

struct s_domainList {
	DOMAINLIST *next;					/* Linked list */

	char	   *domain;					/* Domain name */
	char	   *nodelist_base;			/* Nodelist basename, e.g. "NODELIST", "NESTLIST" */

	size_t		record_size;			/* Size of a record in the DAT file */

	off_t		index_filesize;			/* Size and time of IDX file used */
	time_t		index_filetime;			/*	to see if a refresh is needed */
	char	   *index_filename;			/* Name of IDX file */

	NODESLIST  *nodesList;				/* List of nodes in nets */
	NETSLIST   *netsList;				/* List of nets in zones */
	ZONESLIST  *zoneList;				/* List of zones */
	long 		nZones;					/* Number of zones in domain */
	POINTBOSSLIST *pointBossList;		/* List of systems with points */
	long 		nPoints;				/* Number of entries in pointBossList */
	POINTLIST  *pointsList;				/* List of point numbers */

	long		recordOffset;			/* Offset in dat file */
};


static DOMAINLIST *domainLists = NULL;	/* Entry to domain linked lists */
static DOMAINLIST *cdl = NULL;			/* Current Domain list */


/*
 * Function used by QuickSort
 */

#ifdef LATTICE
int compareNet(const void *net1, const void *net2)
{
	return ((NETSLIST *)net1)->net - ((NETSLIST *)net2)->net;
}

int compareZone(const void *z1, const void *z2)
{
	return ((ZONESLIST *)z1)->zone - ((ZONESLIST *)z2)->zone;
}
#else
int compareNet(const NETSLIST *net1, const NETSLIST *net2)
{
	return net1->net - net2->net;
}

int compareZone(const ZONESLIST *z1, const ZONESLIST *z2)
{
	return z1->zone - z2->zone;
}
#endif

typedef struct {
	long zoneCount;
	long netCount;
	long bossCount;
	long pointCount;
} BUILDCOUNTS;

static void opusCount(BUILDCOUNTS *b, struct _ndi *idx, size_t i)
{
	long lastNet = -1;

	idx++;		/* Lose first record */
	i--;
	while(i--)
	{
		if(idx->node == -2)			/* New zone */
		{
			b->zoneCount++;
			b->netCount++;				/* Independent nodes in a zone need a net */
			lastNet = idx->net;
		}
		else if(idx->net != lastNet)
		{
			b->netCount++;
			lastNet = idx->net;
		}
		idx++;
	}
}


static void countBTNC(BUILDCOUNTS *b, INDEX_BNL *idx, size_t i)
{
	BOOLEAN doingPoint = FALSE;

#if 0
	idx++;		/* Lose first record */
	i--;
#endif
	while(i--)
	{
		switch(idx->type)
		{
		case BNL_ZONECOORD:				/* The lack of break's are deliberate */
			b->zoneCount++;
		case BNL_REGCOORD:
		case BNL_NETCOORD:
			b->netCount++;
		case BNL_NODE:
		case BNL_HUB:
			doingPoint = FALSE;
			break;
		case BNL_POINT:
			b->pointCount++;
			if(!doingPoint)
			{
				b->bossCount++;
				doingPoint = TRUE;
			}
			break;
		}
		idx++;
	}
}

void buildOpus(DOMAINLIST *dlist, struct _ndi *idx, size_t idxCount)
{
	long i = 1;
	long nextZone = 0;
	long nextNet = 0;
	long nextNode = 0;
	long lastNet = -1;

	idx++;				/* Lose 1st entry */
	while(i < idxCount)
	{
		if(idx->node == -2)		/* Going to a new zone */
		{
			dlist->zoneList[nextZone].zone = idx->net;
			dlist->zoneList[nextZone].netIndex = (long)nextNet;
			dlist->zoneList[nextZone].netCount = 0;
			nextZone++;
		}

		if(idx->net != lastNet)	/* Going to a new net */
		{
			lastNet = idx->net;
			dlist->netsList[nextNet].net = idx->net;
			dlist->netsList[nextNet].nodeIndex = nextNode;
			dlist->netsList[nextNet].nodeCount = 0;
			dlist->zoneList[nextZone-1].netCount++;
			nextNet++;
			idx->node = 0;
		}
		dlist->nodesList[nextNode].node = idx->node;
		dlist->netsList[nextNet-1].nodeCount++;
		nextNode++;

		idx++;
		i++;
	}
}

void buildBTNC(DOMAINLIST *dlist, INDEX_BNL *idx, size_t idxCount)
{
	long i = 0;
	long nextZone = 0;
	long nextNet = 0;
	long nextNode = 0;
	long nextBoss = 0;
	long nextPoint = 0;

	long lastNode = -1;
	long lastNet = -1;
	long lastZone = -1;
	BOOLEAN doingPoint = FALSE;

#ifdef DEBUG
	if(debugging_log)
		status_line(">buildBTNC: %s %ld", strToAscii(dlist->domain), (long)idxCount);
#endif

#if 0
	idx++;				/* Lose 1st entry */
	i = 1;
#endif
	while(i < idxCount)
	{
		switch(idx->type)
		{
		case BNL_ZONECOORD:				/* The lack of break's are deliberate */
			lastZone = idx->value;
			dlist->zoneList[nextZone].zone = idx->value;
			dlist->zoneList[nextZone].netIndex = (long)nextNet;
			dlist->zoneList[nextZone].netCount = 0;
			nextZone++;
		case BNL_REGCOORD:
		case BNL_NETCOORD:
			lastNet = idx->value;
			dlist->netsList[nextNet].net = idx->value;
			dlist->netsList[nextNet].nodeIndex = nextNode;
			dlist->netsList[nextNet].nodeCount = 0;
			dlist->zoneList[nextZone-1].netCount++;
			nextNet++;
			idx->value = 0;
		case BNL_NODE:
		case BNL_HUB:
			lastNode = idx->value;
			dlist->nodesList[nextNode].node = idx->value;
			dlist->netsList[nextNet-1].nodeCount++;
			nextNode++;
			doingPoint = FALSE;
			break;
		case BNL_POINT:
			dlist->nodesList[nextNode].node = lastNode;
			dlist->netsList[nextNet-1].nodeCount++;
			nextNode++;

			if(doingPoint)
			{
				dlist->pointBossList[nextBoss-1].pointCount++;
			}
			else	/* A boss */
			{
				dlist->pointBossList[nextBoss].zone = lastZone;
				dlist->pointBossList[nextBoss].net	= lastNet;
				dlist->pointBossList[nextBoss].node = lastNode;
				dlist->pointBossList[nextBoss].pointCount = 1;
				dlist->pointBossList[nextBoss].pointIndex = nextPoint;
				doingPoint = TRUE;
				nextBoss++;
			}
			dlist->pointsList[nextPoint].point = idx->value;
			nextPoint++;
			break;
		}

		idx++;
		i++;
	}
}


/*
 * Construct the sorted lists from the index file
 */

static int buildIndex(DOMAINLIST *dlist, void *idxmem, size_t idxCount)
{
	BUILDCOUNTS bc;

	/*
	 * Count the zones and nets
	 */

	if(fullscreen)
	{
		sb_fillc (holdwin, ' ');
		sb_move(holdwin, 3, 10);
		sb_puts(holdwin, "Counting Nodes");
		sb_show();
	}

	bc.zoneCount = 0;
	bc.netCount = 0;
	bc.bossCount = 0;
	bc.pointCount = 0;
	if(nodeListType == BTNC)
		countBTNC(&bc, idxmem, idxCount);
	else
		opusCount(&bc, idxmem, idxCount);

#ifdef DEBUG
	if(debugging_log)
		status_line(">There are %d zones, %d nets, %ld nodes, %d pointnets, %d points",
			bc.zoneCount, bc.netCount, (long)idxCount, bc.bossCount, bc.pointCount);
#endif

	if(fullscreen)
	{
		sb_fillc (holdwin, ' ');
		sb_move(holdwin, 3, 10);
		sb_puts(holdwin, "Building lists");
		sb_show();
	}

	/*
	 * Create memory
	 */

	if(dlist->zoneList)
	{
		free(dlist->zoneList);
		dlist->zoneList = NULL;
		dlist->netsList = NULL;
		dlist->nodesList = NULL;
		dlist->pointsList = NULL;
		dlist->pointBossList = NULL;
	}

	dlist->zoneList = malloc(bc.zoneCount  * sizeof(ZONESLIST)	   +
							 bc.netCount   * sizeof(NETSLIST)	   +
							 bc.bossCount  * sizeof(POINTBOSSLIST) +
							 bc.pointCount * sizeof(POINTLIST) );

	if(dlist->zoneList)
	{
		dlist->netsList 	 =		(NETSLIST *)(dlist->zoneList	  + bc.zoneCount);
		dlist->pointBossList = (POINTBOSSLIST *)(dlist->netsList	  + bc.netCount );
		dlist->pointsList	 =	   (POINTLIST *)(dlist->pointBossList + bc.bossCount);

		dlist->nodesList = (NODESLIST *)idxmem;

		dlist->nZones = bc.zoneCount;
		dlist->nPoints = bc.bossCount;

		if(nodeListType == BTNC)
			buildBTNC(dlist, idxmem, idxCount);
		else
			buildOpus(dlist, idxmem, idxCount);


		if(fullscreen)
		{
			sb_fillc (holdwin, ' ');
			sb_move(holdwin, 3, 10);
			sb_puts(holdwin, "Sorting Nets");
			sb_show();
		}

		/* Sort the Zone list */

		qsort(dlist->zoneList, dlist->nZones, sizeof(ZONESLIST), compareZone);

		/* Sort Nets */

		{
			int z = 0;
			while(z < dlist->nZones)
			{
				long net;
				long count;


				net = dlist->zoneList[z].netIndex;
				count = dlist->zoneList[z].netCount;

				qsort(&dlist->netsList[net], count, sizeof(NETSLIST), compareNet);

#ifdef DEBUG
				if(debugging_log)
				{
					/* Display information */

					status_line(">Zone %d, %d nets at %d",
						dlist->zoneList[z].zone, count, net);

					while(count--)
					{
						status_line(">Net %d, %d nodes at %ld",
							dlist->netsList[net].net,
							dlist->netsList[net].nodeCount,
							(long) dlist->netsList[net].nodeIndex);


						net++;
					}
				}
#endif

				z++;
			}
#ifdef DEBUG
			if(debugging_log)
			{
				POINTBOSSLIST *pb;
				long count;

				count = dlist->nPoints;
				status_line(">%d Point systems", count);
				pb = dlist->pointBossList;
				while(count--)
				{
					status_line(">%d:%d/%d has %d points at %d",
						pb->zone, pb->net, pb->node, pb->pointCount, pb->pointIndex);
				}
			}
#endif
		}
		realloc(idxmem, idxCount * sizeof(NODESLIST));
		return 0;
	}
	else
		status_line(msgtxt[M_NODELIST_MEM]);

	return -1;
}

/*
 * read the index file in
 */

static int makeVersion6Index(DOMAINLIST *dlist)
{
	struct stat idxstat;
	int error = -1;

#ifdef DEBUG
	if(debugging_log)
		status_line(">Reading index file %s", strToAscii(dlist->index_filename));
#endif
	if(fullscreen)
	{
		sb_fillc (holdwin, ' ');
		sb_move(holdwin, 3, 2);
		sb_puts(holdwin, "Reading:");
		sb_move(holdwin, 4, 2);
		sb_puts(holdwin, dlist->index_filename);
		sb_show();
	}

	errno = 0;
	if(!stat(dlist->index_filename, &idxstat))
	{
		struct _ndi *idxmem;

		idxmem = malloc(idxstat.st_size);
		if(idxmem)
		{
#if defined(USEBUFFEREDFILE)
			FILE *fd = fopen(dlist->index_filename, "rb");
			if(fd)
			{
				fread(idxmem, idxstat.st_size, 1, fd);
				fclose(fd);
#elif defined(__TOS__)
			int fp = (int) Fopen(dlist->index_filename, FO_READ);
			if(fp >= 0)
			{
				if(Fread(fp, idxstat.st_size, idxmem) != idxstat.st_size)
					errno = -1;
				Fclose(fp);
#else
			int fp = open(dlist->index_filename, O_RDONLY|O_BINARY);
			if(fp >= 0)
			{
				read(fp, idxmem, idxstat.st_size);
				close(fp);
#endif
				if(errno == 0)
				{
					error = buildIndex(dlist, idxmem, idxstat.st_size / sizeof(struct _ndi));
					if(!error)
					{
						dlist->index_filesize = idxstat.st_size;
						dlist->index_filetime = idxstat.st_mtime;
					}
				}
			}
			if(error)	/* Otherwise buildIndex has used it */
				free(idxmem);
		}
		else
			status_line(msgtxt[M_NODELIST_MEM]);
	}

	if(fullscreen)
	{
		sb_fillc (holdwin, ' ');
		sb_show();
	}

	return error;
}

/*
 * Find a BTNC Domain structure
 */

DOMAINS_BNL *findBTNCDomain(DOMAINLIST *dlist, DOMAINS_BNL *dest)
{
	FILE *fd;
	char buffer[FMSIZE];

	sprintf(buffer, "%s%s", net_info, btnc_dmn);

#ifdef DEBUG
	if(debugging_log)
		status_line(">Reading %s", buffer);
#endif

	fd = fopen(buffer, "rb");
	if(fd)
	{
		while(fread(dest, sizeof(DOMAINS_BNL), 1, fd) == 1)
		{
#ifdef DEBUG
			if(debugging_log)
				status_line(">domain.bnl: %s %s %d %ld %ld",
					dest->name, dest->listfile, dest->zone,
					dest->startoffset, dest->length);
#endif
			if((dlist->domain == NULL) || (stricmp(dlist->domain, dest->name) == 0))
			{
#ifdef DEBUG
				if(debugging_log)
					status_line(">found Domain: %s", strToAscii(dlist->domain));
#endif
				fclose(fd);
				return dest;
			}
		}
		
		fclose(fd);
	}
	else
		status_line (msgtxt[M_UNABLE_TO_OPEN], buffer);

	return NULL;
}

static int makeBTNCIndex(DOMAINLIST *dlist)
{
	struct stat idxstat;
	int error = -1;
	DOMAINS_BNL domain;

#ifdef DEBUG
	if(debugging_log)
		status_line(">Reading index file %s, domain %s",
			strToAscii(dlist->index_filename), strToAscii(dlist->domain));
#endif

	/*
	 * First look in the domain file to find where to load
	 */

	if(findBTNCDomain(dlist, &domain) == NULL)
		return -1;

	dlist->recordOffset = (long) (domain.startoffset / sizeof(INDEX_BNL));

	if(fullscreen)
	{
		sb_fillc (holdwin, ' ');
		sb_move(holdwin, 3, 2);
		sb_puts(holdwin, "Scanning:");
		sb_move(holdwin, 4, 2);
		sb_puts(holdwin, dlist->index_filename);
		sb_move(holdwin, 5, 2);
		sb_puts(holdwin, dlist->domain);
		sb_show();
	}

	errno = 0;
	if(!stat(dlist->index_filename, &idxstat))
	{
		INDEX_BNL *idxmem;
		size_t size = domain.length * sizeof(INDEX_BNL);

		idxmem = malloc(size);
		if(idxmem)
		{
#if defined(USEBUFFEREDFILE)
			FILE *fd = fopen(dlist->index_filename, "rb");
			if(fd)
			{
				fseek(fd, domain.startoffset, SEEK_SET);
				fread(idxmem, size, 1, fd);
				fclose(fd);
#elif defined(__TOS__)
			int fp = (int) Fopen(dlist->index_filename, FO_READ);
			if(fp >= 0)
			{
				if(Fseek(domain.startoffset, fp, SEEK_SET) != domain.startoffset)
					errno = -1;
				else
				if(Fread(fp, size, idxmem) != size)
					errno = -1;
				Fclose(fp);
#else
			int fp = open(dlist->index_filename, O_RDONLY|O_BINARY);
			if(fp >= 0)
			{
				lseek(fp, domain.startoffset, SEEK_SET);
				read(fp, idxmem, size);
				close(fp);
#endif
				if(errno == 0)
				{
					error = buildIndex(dlist, idxmem, domain.length);
					if(!error)
					{
						dlist->index_filesize = idxstat.st_size;
						dlist->index_filetime = idxstat.st_mtime;
					}
				}
			}
			if(error)	/* Otherwise buildIndex has used it */
				free(idxmem);
		}
		else
			status_line(msgtxt[M_NODELIST_MEM]);
	}

	if(fullscreen)
	{
		sb_fillc (holdwin, ' ');
		sb_show();
	}

	return error;
}

static int makeIndex(DOMAINLIST *dlist)
{
	if(nodeListType == VERSION6)
		return makeVersion6Index(dlist);
	else
		return makeBTNCIndex(dlist);
}


/*-------------------------------------------------
 * Actually get bytes from NODELIST.DAT
 */

static BOOLEAN opusGetInfo (DOMAINLIST *dlist, size_t recno)
{
	long nodeoff;								 /* Offset into NODELIST.DAT  */
	char temp[80];								 /* where we build filenames  */
#ifdef __TOS__
	int stream;

	/* actual file offset */
	nodeoff = (long) recno * dlist->record_size;

	if(!nodelock || (fp_nodelist < 0))
	{
		strcpy (temp, net_info);					/* take nodelist path		 */
		strcat (temp, dlist->nodelist_base);		/* add in the file name		*/
		strcat (temp, ".DAT");						/* add in the file name 	 */
		if ((stream = (int) Fopen (temp, FO_READ)) < 0)	/* OK, let's open the file	 */
		{
			status_line (msgtxt[M_UNABLE_TO_OPEN], temp);
			return FALSE;
		}
		if(nodelock)
			fp_nodelist = stream;
	}
	else
		stream = fp_nodelist;

	if(Fseek (nodeoff, stream, SEEK_SET) != nodeoff)	/* try to point at record	  */
	{
		status_line (msgtxt[M_NODELIST_SEEK_ERR], temp);
		if(!nodelock)
			Fclose (stream);
		return FALSE;
	}

	if(Fread (stream, sizeof(newnodedes), &newnodedes) != sizeof(newnodedes))
	{
		status_line (msgtxt[M_NODELIST_REC_ERR], temp);
		if(!nodelock)
			Fclose (stream);
		return FALSE;
	}
	if(!nodelock)
		Fclose (stream);
#else
	FILE *stream;

	/* actual file offset */
	nodeoff = (long) recno * dlist->record_size;

	if(!nodelock || (fp_nodelist == NULL))
	{
		strcpy (temp, net_info);						/* take nodelist path		 */
		strcat (temp, dlist->nodelist_base);			/* add in the file name		*/
		strcat (temp, ".DAT");							/* add in the file name 	 */
		if ((stream = fopen (temp, read_binary)) == NULL)	 /* OK, let's open the file   */
		{
			status_line (msgtxt[M_UNABLE_TO_OPEN], temp);
			return FALSE;
		}
		if(nodelock)
			fp_nodelist = stream;
	}
	else
		stream = fp_nodelist;

	if (fseek (stream, nodeoff, SEEK_SET))		 /* try to point at record	  */
	{
		status_line (msgtxt[M_NODELIST_SEEK_ERR], temp);
		if(!nodelock)
			fclose (stream);
		return FALSE;
	}

	if (!fread (&newnodedes, sizeof (newnodedes), 1, stream))
	{
		status_line (msgtxt[M_NODELIST_REC_ERR], temp);
		if(!nodelock)
			fclose (stream);
		return FALSE;
	}
	if(!nodelock)
		fclose (stream);
#endif

	/* Do any conversion */

	if(newnodedes.NodeFlags & B_CrashM)
		newnodedes.NodeFlags = B_CM;
	else
		newnodedes.NodeFlags = 0;

	return TRUE;
}

static BOOLEAN BTNCGetInfo (DOMAINLIST *dlist, size_t recno, ADDR *addr)
{
	long nodeoff;								 /* Offset into NODELIST.DAT  */
	char temp[80];								 /* where we build filenames  */
	NODEINFO_BNL info;

#ifdef __TOS__
	int stream;

	/* actual file offset */

	recno += dlist->recordOffset;
	nodeoff = (long) recno * dlist->record_size;

	if(!nodelock || (fp_nodelist < 0))
	{
		strcpy (temp, net_info);					/* take nodelist path		 */
		strcat (temp, btnc_dat);			/* add in the file name		*/
		if ((stream = (int) Fopen (temp, FO_READ)) < 0)	/* OK, let's open the file	 */
		{
			status_line (msgtxt[M_UNABLE_TO_OPEN], temp);
			return FALSE;
		}
		if(nodelock)
			fp_nodelist = stream;
	}
	else
		stream = fp_nodelist;

	if(Fseek (nodeoff, stream, SEEK_SET) != nodeoff)	/* try to point at record	  */
	{
		status_line (msgtxt[M_NODELIST_SEEK_ERR], temp);
		if(!nodelock)
			Fclose (stream);
		return FALSE;
	}

	if(Fread (stream, sizeof(info), &info) != sizeof(info))
	{
		status_line (msgtxt[M_NODELIST_REC_ERR], temp);
		if(!nodelock)
			Fclose (stream);
		return FALSE;
	}
	if(!nodelock)
		Fclose (stream);
#else
	FILE *stream;

	/* actual file offset */

	recno += dlist->recordOffset;
	nodeoff = (long) recno * dlist->record_size;

	if(!nodelock || (fp_nodelist == NULL))
	{
		strcpy (temp, net_info);				/* take nodelist path		 */
		strcat (temp, btnc_dat);			/* add in the file name		*/
		if ((stream = fopen (temp, read_binary)) == NULL)	 /* OK, let's open the file   */
		{
			status_line (msgtxt[M_UNABLE_TO_OPEN], temp);
			return FALSE;
		}
		if(nodelock)
			fp_nodelist = stream;
	}
	else
		stream = fp_nodelist;

	if (fseek (stream, nodeoff, SEEK_SET))		 /* try to point at record	  */
	{
		status_line (msgtxt[M_NODELIST_SEEK_ERR], temp);
		if(!nodelock)
			fclose (stream);
		return FALSE;
	}

	if (!fread (&info, sizeof(info), 1, stream))
	{
		status_line (msgtxt[M_NODELIST_REC_ERR], temp);
		if(!nodelock)
			fclose (stream);
		return FALSE;
	}
	if(!nodelock)
		fclose (stream);
#endif

	/* Convert information into newnodedes */

	newnodedes.NetNumber = addr->Net;
	newnodedes.NodeNumber = addr->Node;
	newnodedes.Cost = 0;
	strncpy(newnodedes.SystemName, info.sysname, 34);
	strncpy(newnodedes.PhoneNumber, info.phone, 40);
	strncpy(newnodedes.MiscInfo, info.location, 30);
	newnodedes.Password[0] = 0;
	newnodedes.RealCost = 0;
	newnodedes.HubNode = info.hubnode;
	newnodedes.BaudRate = info.maxbaud;
	newnodedes.ModemType = info.modemtype;
	newnodedes.NodeFlags = info.flags;
	newnodedes.NodeFiller = 0;

	return TRUE;
}

static BOOLEAN getNodeListInfo(DOMAINLIST *dlist, size_t recno, ADDR *addr)
{
#ifdef DEBUG
	if(debugging_log)
		status_line(">getNodeListInfo(%s,%ld,%s)",
			strToAscii(dlist->domain), (long)recno, Pretty_Addr_Str(addr));
#endif
	switch(nodeListType)
	{
	case BTNC:
		return BTNCGetInfo(dlist, recno, addr);
	case VERSION6:
		return opusGetInfo(dlist, recno+1);
	}
	return FALSE;
}


static char *get_nodelist_name(char *domain)
{
	int i;

	for (i = 0; domain_name[i] != NULL; i++)
	{
		if (domain_name[i] == domain)
		{
			if(domain_nodelist[i] == NULL)
				return nodelist_name;
			else
				return domain_nodelist[i];
		}
	}

	return nodelist_name;
}



BOOLEAN checkIDX(DOMAINLIST *dlist)
{
	struct stat idxstat;

	if(dlist->index_filesize == 0L)
		return TRUE;

	if(stat(dlist->index_filename, &idxstat))
	{	/* Doesn't exist! */
		return TRUE;
	}
	else
	{
		if( (dlist->index_filesize != idxstat.st_size) ||	/* It has changed */
			(dlist->index_filetime != idxstat.st_mtime) )
		{
			status_line (msgtxt[M_REFRESH_NODELIST]);
			return TRUE;
		}
	}

	return FALSE;	/* Doesn't need reading */
}


/*------------------------------------------------------
 * Nodelist lookup functions
 */

static int nextZone(DOMAINLIST *dlist)
{
	static int zonePos = 0;

	if(no_zones)
		return -1;

	if (!dlist->zoneList)
		return -1;
		
	if(last_zone == -1)					/* reset to 1st zone */
		zonePos = 0;
	else if(zonePos >= dlist->nZones)		/* We've finished */
	{
		zonePos = 0;
		return -1;
	}

	last_zone = dlist->zoneList[zonePos++].zone;	/* Get the value and increment pointer */
	return last_zone;
}

static BOOLEAN nodeLookup(ADDR *opus_addr, int have_boss_data)
{
	int zoneCount;
	DOMAINLIST *dlist = domainLists;

	newnodedes.NetNumber = newnodedes.NodeNumber = 0;

	/* Don't even TRY looking for points! */

	if((nodeListType == VERSION6) && opus_addr->Point && ((int)opus_addr->Zone != -1))
		return 0;

	/*
	 * Find our domainList and/or read it in
	 */

	/*
	 * Look for existing list
	 */

	while(dlist)
	{
		if(opus_addr->Domain == NULL)	/* Not using domains */
			break;
		if(dlist->domain == opus_addr->Domain)
			break;

		dlist = dlist->next;
	}

	/*
	 * Create a new domainList
	 */

	if(dlist == NULL)
	{
		char buffer[FMSIZE];

		dlist = calloc(sizeof(DOMAINLIST), 1);
		if(dlist == NULL)
		{
			status_line(msgtxt[M_NODELIST_MEM]);
			return 0;
		}

		/* fill in the values */

		dlist->domain = opus_addr->Domain;

		strcpy (buffer, net_info);				/* take nodelist path		  */

		if(nodeListType == BTNC)
		{
			strcat(buffer, btnc_idx);
		}
		else	/* Assume version 6 */
		{
			dlist->nodelist_base = get_nodelist_name(opus_addr->Domain);

			strcat (buffer, dlist->nodelist_base);	/* add in the file name  */
			strcat (buffer, ".IDX");				/* add in the file ext	  */
		}
		dlist->index_filename = strdup(buffer);

		/* All other values are 0 or NULL from calloc() */

		/* Link to start of list */

		dlist->next = domainLists;
		domainLists = dlist;
#ifdef DEBUG
		if(debugging_log)
			status_line(">Made DOMAINLIST %s %s %s",
				strToAscii(dlist->domain),
				strToAscii(dlist->nodelist_base),
				strToAscii(dlist->index_filename));
#endif
	}

	cdl = dlist;		/* Make domainList current */

	/*
	 * see if the Index needs to be re-read
	 */


	if(checkIDX(dlist))
	{
		int error = makeIndex(dlist);

		if(error
		  && (have_boss_data != 2)
		  && ((int)opus_addr->Zone != -1)
		  )
		  if (dlist->zoneList)
			{
					status_line (msgtxt[M_UNABLE_TO_OPEN], dlist->index_filename);
					return (0);							/* no file, no work to do	  */
			}
		else
			return(0);

		/*
		 * Now take into account that the .DAT file can be bigger than we
		 * really expect it to be.	Just take the number of records, and
		 * divide into the size of the .DAT file to find the true record size
		 */

		{
			struct stat f;
			char temp[FMSIZE];

			strcpy (temp, net_info);		 /* take nodelist path		  */
			if(nodeListType == VERSION6)
			{
				strcat (temp, dlist->nodelist_base);	 /* add in the file name	  */
				strcat (temp, ".DAT");			 /* add in the file name	  */
				if (!stat(temp, &f))
					dlist->record_size = f.st_size /
							(dlist->index_filesize / sizeof(struct _ndi));
				else
					dlist->record_size = 0;
			}
			else	/* BTNC */
			{
				strcat(temp, btnc_dat);
				if(!stat(temp, &f))
					dlist->record_size = f.st_size /
							(dlist->index_filesize / sizeof(INDEX_BNL));
				else
					dlist->record_size = 0;
			}
		}
	}

	if ((int)opus_addr->Zone == -1)
		return (nextZone (dlist));
	else if ((alias[0].ad.Zone == 0) || no_zones)
		opus_addr->Zone = 0;

	/*
	 * Notes: This can be changed to binary searches once the nodelists
	 *		  are sorted
	 */

	/* Search for our Zone... assumes zones are sorted */

	zoneCount = 0;
	while( (zoneCount < dlist->nZones) && (dlist->zoneList[zoneCount].zone <= opus_addr->Zone))
	{
		if( (opus_addr->Zone == 0) || (dlist->zoneList[zoneCount].zone == opus_addr->Zone))
		{
			/* Search for our Net */
			/* The nets are sorted so we can do a binary search */

			/* Binary search */

			size_t first = dlist->zoneList[zoneCount].netIndex;
			size_t last = first + dlist->zoneList[zoneCount].netCount;

			while(first != last)
			{
				size_t netIndex = (first + last) / 2;
				int diff = dlist->netsList[netIndex].net - opus_addr->Net;
#ifdef DEBUG
				if(debugging_log)
					status_line(">Binary Search: first=%d,mid=%d,last=%d,diff=%d",
						(int)first,(int)netIndex,(int)last,diff);
#endif
				if(diff == 0)
				{
					/*
					 * Handle the unusual case of there being more than
					 * one entry for a net.
					 *
					 * Backtrack to 1st occurence of this net
					 */
#ifdef DEBUG
					if(debugging_log)
						status_line(">Binary Search: found net %d", opus_addr->Net);
#endif

					while(netIndex && (dlist->netsList[netIndex-1].net == opus_addr->Net))
						netIndex--;
					while(dlist->netsList[netIndex].net == opus_addr->Net)
					{

						/* Search for our node */

						size_t nodeIndex = dlist->netsList[netIndex].nodeIndex;
						size_t nodeCount = dlist->netsList[netIndex].nodeCount;

						while(nodeCount--)
						{
							if(dlist->nodesList[nodeIndex].node == opus_addr->Node)
							{

#ifdef DEBUG
								if(debugging_log)
									status_line(">Binary Search: found node %d.%d", opus_addr->Node, opus_addr->Point);
#endif
							/* We found the node... check for points */

#ifndef NOPOINTS
								if(opus_addr->Point)
								{
#ifdef DEBUG
									if(debugging_log)
										status_line(">Searching point %d", opus_addr->Point);
#endif
									if(dlist->pointBossList &&
									   (dlist->nodesList[++nodeIndex].node == opus_addr->Node))
									{
										POINTBOSSLIST *pblist = dlist->pointBossList;
										long i;

#ifdef DEBUG
										if(debugging_log)
											status_line(">nPoints = %d", dlist->nPoints);
#endif
										i = dlist->nPoints;
										while(i--)
										{
											if( (pblist->zone == opus_addr->Zone)
											 && (pblist->net  == opus_addr->Net)
											 && (pblist->node == opus_addr->Node) )
											{
												POINTLIST *plist = &dlist->pointsList[pblist->pointIndex];
												long count = pblist->pointCount;

#ifdef DEBUG
												if(debugging_log)
													status_line(">Found boss with %d points", count);
#endif
												while(count--)
												{
													if(plist->point == opus_addr->Point)
													{
#ifdef DEBUG
														if(debugging_log)
															status_line(">Found point %d", opus_addr->Point);
#endif
														found_zone = opus_addr->Zone;	 /* Keep track of found zone */
														found_net  = opus_addr->Net;	 /* Keep track of found net  */

														return getNodeListInfo(dlist, nodeIndex, opus_addr);
													}
													nodeIndex++;
													plist++;
												}

												break;
											}
											pblist++;
										}
									}

									/* There are no points, or point was not found */

									return 0;
								}
#endif

								/* A straight node... return the info */

								found_zone = opus_addr->Zone;	 /* Keep track of found zone */
								found_net  = opus_addr->Net;	 /* Keep track of found net  */

								return getNodeListInfo(dlist, nodeIndex, opus_addr);
							}

							nodeIndex++;
						}
						netIndex++;
					}
					break;	/* Node not found in this net/zone */
				}
				else if(diff < 0)
					first = netIndex + 1;
				else /* if(diff > 0) */
					last = netIndex;
			}
#if 0
			if(opus_addr->Zone != 0)
				break;
#endif
		}
		zoneCount++;
	}

	/* Node was not in nodelist! */

	return FALSE;
}


/*----------------------------------------------------
 * I moved this here from misc.c
 */

long cost_of_call (long s, long e)
{
	long a;

	if (usecallslots)
		return (0L);
		
	a = e - s;
	a = (a + 59) / 60;
   
   return (a * newnodedes.RealCost);
}

/*---------------------------------------------------------------------------*/
/* NODEPROC 																 */
/* Find nodelist entry and set baud to nodelist baud for dialing out		 */
/*---------------------------------------------------------------------------*/

int nodeproc (char *nodeaddr)
{
   ADDR opus_addr;
   char *c;

   c = skip_blanks (nodeaddr);					 /* get rid of the blanks	  */
   if (!find_address (c, &opus_addr))
	  {
	  return (0);
	  }
   if (!nodefind (&opus_addr, 1))  /* if we can't find the node */
	  return (0);								 /* go away now 			  */
   status_line (msgtxt[M_PROCESSING_NODE], Pretty_Addr_Str (&opus_addr), newnodedes.SystemName);
   if (!CARRIER)								 /* if no carrier yet,		  */
	  {
	  if (autobaud)
		 (void) set_baud (max_baud.rate_value, 1);
												 /* Set to our highest baud rate */
	  else
		 (void) set_baud ((300 * newnodedes.BaudRate), 1);		 /* set baud to nodelist
																 * baud */
	  }
   return (1);									 /* return success to caller  */
}


/*---------------------------------------------------------------------------*/
/* NODEFIND 																 */
/* Find nodelist entry for use by other routines (password, nodeproc)		 */
/* If found, result will be in "newnodedes".								 */
/*																			 */
/* If the passed zone is -1 then the next zone is returned					 */
/*																			 */
/* This is now passed a 4D address and thus must fiddle about with fakenets  */
/*---------------------------------------------------------------------------*/

int nodefind (ADDR *bink_addr, int prtflag)
{
	int i, j, k;
	int have_boss_data = 0;
	int need_boss_data = 0;
	ADDRESS *ad;
	ADDR newad;		/* Address of converting for fakenet */
	PROTMODE mode;

	char *bestPassword = NULL;
	char *bestPrefix = NULL;
	char *bestPhone = NULL;
	char bestCallSlot = '\0';
	ADDRESS *bestAlias = NULL;


#ifdef DEBUG
	if(debugging_log)
		status_line(">nodefind(%s)", Pretty_Addr_Str(bink_addr));
#endif

	if((int)bink_addr->Zone == -1)
		return nodeLookup(bink_addr, FALSE);

	if(checkNodeCache(bink_addr))
		return TRUE;


	newnodedes.NetNumber = newnodedes.NodeNumber = found_zone = found_net = 0;
	
	strcpy (newnodedes.SystemName, "Unknown BinkleyTerm System");	/* System Name defaults */
	strcpy (newnodedes.MiscInfo, "Somewhere out There"); 			/* As does City */
	strcpy (newnodedes.PhoneNumber, "");

	mode = MODE_DEFAULT;

	CurrentOKFile = DEFAULT.rq_OKFile;	 /* Set the default f.req paths */
	CurrentFILES = DEFAULT.rq_FILES;
	CurrentAbout = DEFAULT.rq_About;
	CurrentReqTemplate = DEFAULT.rq_Template;
	CurrentNetFiles = DEFAULT.sc_Inbound;
	CurrentReqLim = DEFAULT.rq_Limit;
	CurrentByteLim = DEFAULT.byte_Limit;
	CurrentTimeLim = DEFAULT.time_Limit;

	/* Set up the assumed address based on curr_domain/found_zone/found_net */

	assumed = k = 0;						  /* Default to zone of first */
	for (j = 0; j < num_addrs; j++)
	{

	/*
	 * If this alias's domain is the curr_domain
	 *	  OR
	 * Curr_domain is NULL and this domain is the default
	 *	  OR
	 * If this alias doesnt have a domain and curr_domain is default
	 *
	 * This can be simplified by setting all domains to default in initialisation!
	 */

		if((alias[j].ad.Domain == bink_addr->Domain) ||
			  (!bink_addr->Domain && (alias[j].ad.Domain == alias[0].ad.Domain)) ||
			  (!alias[j].ad.Domain && (bink_addr->Domain == alias[0].ad.Domain)))
		{
			if (k == 0)				/* Matched Domain */
			{
				assumed = j;
				++k;
			}

			if(alias[j].ad.Zone == bink_addr->Zone)
			{
				if (k == 1)
				{
				   assumed = j;
				   ++k;
				}

				if(alias[j].ad.Net == bink_addr->Net)
				{
					if(k == 2)
					{
						assumed = j;
						++k;
					}
					if(alias[j].ad.Node == bink_addr->Node)
					{
					   assumed = j;
					   break;
					} /* node */
				} /* net */
			} /* zone */
		} /* domain */
	} /* alias */

	/* Search the adkeys for a password and force assumed node! */

	{
	  ADKEY *key = adkeys;

	  while(key)
	  {
		if( (key->wild.net || (key->ad.Net == bink_addr->Net)) &&
			(key->wild.node || (key->ad.Node == bink_addr->Node)) &&
			(key->wild.zone || (key->ad.Zone == bink_addr->Zone)) &&
			(key->wild.domain || !key->ad.Domain || !bink_addr->Domain || (key->ad.Domain == bink_addr->Domain)) &&
			(key->wild.point || (key->ad.Point == bink_addr->Point)) )
		{
			if(key->password)
				have_boss_data = 1;

			/*
			 * Remember password/phone/prefix for later
			 */

			if(bestPassword == NULL)
				bestPassword = key->password;
			if(bestPhone == NULL)
				bestPhone = key->phone;
			if(bestPrefix == NULL)
				bestPrefix = key->prefix;
			if(bestAlias == NULL)
				bestAlias = key->alias;
			bestCallSlot = key->call_slot;
		}
		key = key->next;
 	  }
 	}

	/* Convert alias to assumed */

	if(bestAlias != NULL)
	{
		j = 0;
		ad = alias;
		while(j < num_addrs)
		{
			if(bestAlias == ad)
			{
				assumed = j;
				break;
			}
			j++;
			ad++;
		}
	}
	ad = &alias[assumed];

	if(ad->phone || bestPhone)
		++have_boss_data;

	/* Are we the boss or are we wanting the boss? and do we have enough info? */

	newad = *bink_addr;			/* Prepare the 3D address */

	if(!newad.Zone)
		newad.Zone = ad->ad.Zone;

	/* Look it up in the nodelist */

	i = nodeLookup(&newad, have_boss_data);

	/* If we're a point and this is our boss, use the fakenet */

	if(
		(bink_addr->Net == ad->ad.Net) &&
		(bink_addr->Node == ad->ad.Node) &&
		(bink_addr->Zone == ad->ad.Zone) &&
		(bink_addr->Domain == ad->ad.Domain))
	{
		/* If this is our boss */

		if(!bink_addr->Point)
			++need_boss_data;
		else
		/* Patch up the address for fakenet if we're accessing a point not our own */
		{
			if(!i)	/* couldn't find point address.. try fakenet */
			{
				newad.Net = ad->fakenet;
				newad.Node = bink_addr->Point;
				newad.Point = 0;
				i = nodeLookup(&newad, have_boss_data);
			}
		}
	}

	if(bestPhone)
	{
		strncpy(newnodedes.PhoneNumber, bestPhone, 40);
		newnodedes.PhoneNumber[39] = '\0';
	}
	else if(need_boss_data && ad->phone)	/* Update phone number if set and calling boss */
	{
		strncpy(newnodedes.PhoneNumber, ad->phone, 40);
		newnodedes.PhoneNumber[39] = '\0';
	}

	if(bestPrefix)
		node_prefix = bestPrefix;
	else
		node_prefix = NULL;

	/* Overwrite the password */

	if(bestPassword)
	{
		memset(newnodedes.Password, 0, sizeof(newnodedes.Password));
		strncpy(newnodedes.Password, bestPassword, sizeof(newnodedes.Password));
	}

	if (usecallslots)
		newnodedes.RealCost = (word)bestCallSlot;

	if(!i && (have_boss_data != 2) && !bestPhone && !bestPassword)
	{
	  if (prtflag)
		 status_line (msgtxt[M_NO_ADDRESS], Pretty_Addr_Str (bink_addr));

	  if (curmudgeon && CARRIER && ((int)bink_addr->Net != -1) && ((int)bink_addr->Node != -1) && (bink_addr->Node != 9999))
	  {
		 status_line (msgtxt[M_NUISANCE_CALLER]);
		  hang_up ();
		 DTR_ON (); 							/* OK, turn modem back on */
	  }

	}


   /* If we found the entry, then we promote the file request
	* to the "KNOWN" class. If the password field is non-zero,
	* then promote to "PROT". It's OK to do that since the higher
	* level code will hang up before f.req's if the password does
	* not match.
	*
	*/

	if (i || bestPhone || bestPassword)
	{
#ifdef DEBUG
		if(debugging_log)
			status_line(">nodefind(%s) password='%s'",
				Pretty_Addr_Str(bink_addr), newnodedes.Password);
#endif
		if (newnodedes.Password[0])
		{
			mode = MODE_PROTECTED;
			CurrentOKFile = PROT.rq_OKFile;
			CurrentFILES = PROT.rq_FILES;
			CurrentAbout = PROT.rq_About;
			CurrentReqTemplate = PROT.rq_Template;
			CurrentNetFiles = PROT.sc_Inbound;
			CurrentReqLim = PROT.rq_Limit;
			CurrentByteLim = PROT.byte_Limit;
			CurrentTimeLim = PROT.time_Limit;
		}
		else if(i)
		{
			mode = MODE_KNOWN;
			CurrentOKFile = KNOWN.rq_OKFile;
			CurrentFILES = KNOWN.rq_FILES;
			CurrentAbout = KNOWN.rq_About;
			CurrentReqTemplate = KNOWN.rq_Template;
			CurrentNetFiles = KNOWN.sc_Inbound;
			CurrentReqLim = KNOWN.rq_Limit;
			CurrentByteLim = KNOWN.byte_Limit;
			CurrentTimeLim = KNOWN.time_Limit;
		}
		addNodeCache(bink_addr, mode);

	}

	if(i || !need_boss_data)	/* && !key) */
	  return (i);

	/* No BOSS in the nodelist */

	if(have_boss_data != 2)
	{
	  status_line (msgtxt[M_NO_BOSS]);
	  return (0);
	}

	/* Fill in the information for our boss */

	newnodedes.NodeNumber = bink_addr->Node;	  /* Node Number */
	newnodedes.NetNumber = bink_addr->Net;		  /* Net Number  */
	newnodedes.Cost = newnodedes.RealCost = 0;	 /* Assume boss is free */
	strcpy (newnodedes.SystemName, "Binkley's Boss");	 /* System Name defaults */
	strcpy (newnodedes.MiscInfo, "Somewhere out There"); /* As does City */
	newnodedes.HubNode = 0;						 /* Don't know who is HUB */
	newnodedes.BaudRate = (char) (max_baud.rate_value / 300);
												 /* Assume boss speed = ours */
	newnodedes.ModemType = 0;					 /* Or modem type */
	newnodedes.NodeFlags = B_CM;				 /* Assume boss is CM */
	newnodedes.NodeFiller = 0;					 /* Zero out filler */

	addNodeCache(bink_addr, mode);
	return (1);
}


