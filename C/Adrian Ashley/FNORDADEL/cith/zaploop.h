/*
 * zaploop.h: structures used by the loop zapper
 *
 * 91Jan03 AA	Added lxname, lxlastid and lxgen.  Changed lxlast to time_t.
 */

#ifndef _ZAPLOOP_H
#define _ZAPLOOP_H

struct zaploop {
    LABEL  lxaddr;	/* node id for the offending system		*/
    LABEL  lxname;	/* node name (for convenience)			*/
    time_t lxlast;	/* date of newest message here			*/
    long   lxlastid;	/* message id of newest message here, if avail	*/
    short  lxroom;	/* room on our system for this message		*/
    unsigned short lxgen; /* gen # of room				*/
    short  lxchain;	/* hash chain for next room			*/
} ;

struct zaphash {
    short zhash;	/* hash of the node ID for the system		*/
    short zbucket;
} ;

extern struct zaphash *zap;

#endif
