/*
 * findmsg.c -- stuff for finding messages
 *
 * 90Aug27 AA	Split off from libmsg.c
 */

#include "ctdl.h"
#include "msg.h"
#include "config.h"
#include "citlib.h"

int
findMessage(short loc, long id)
{
    if (id >= cfg.oldest && id <= cfg.newest)
	for (msgseek(loc, 0); mboffset == loc; ) {
	    getmessage();
	    if (id == msgBuf.mbid)
		return YES;
	}
    return NO;
}
