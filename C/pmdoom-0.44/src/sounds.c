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
//	Created by a sound utility.
//	Kept as a sample, DOOM2 sounds.
//
//-----------------------------------------------------------------------------

#include <stdlib.h>

#include "doomtype.h"
#include "sounds.h"

//
// Information about all the music
//

musicinfo_t S_music[] =
{
    { 0 },
    { "e1m1", 0 },
    { "e1m2", 0 },
    { "e1m3", 0 },
    { "e1m4", 0 },
    { "e1m5", 0 },
    { "e1m6", 0 },
    { "e1m7", 0 },
    { "e1m8", 0 },
    { "e1m9", 0 },
    { "e2m1", 0 },
    { "e2m2", 0 },
    { "e2m3", 0 },
    { "e2m4", 0 },
    { "e2m5", 0 },
    { "e2m6", 0 },
    { "e2m7", 0 },
    { "e2m8", 0 },
    { "e2m9", 0 },
    { "e3m1", 0 },
    { "e3m2", 0 },
    { "e3m3", 0 },
    { "e3m4", 0 },
    { "e3m5", 0 },
    { "e3m6", 0 },
    { "e3m7", 0 },
    { "e3m8", 0 },
    { "e3m9", 0 },
    { "inter", 0 },
    { "intro", 0 },
    { "bunny", 0 },
    { "victor", 0 },
    { "introa", 0 },
    { "runnin", 0 },
    { "stalks", 0 },
    { "countd", 0 },
    { "betwee", 0 },
    { "doom", 0 },
    { "the_da", 0 },
    { "shawn", 0 },
    { "ddtblu", 0 },
    { "in_cit", 0 },
    { "dead", 0 },
    { "stlks2", 0 },
    { "theda2", 0 },
    { "doom2", 0 },
    { "ddtbl2", 0 },
    { "runni2", 0 },
    { "dead2", 0 },
    { "stlks3", 0 },
    { "romero", 0 },
    { "shawn2", 0 },
    { "messag", 0 },
    { "count2", 0 },
    { "ddtbl3", 0 },
    { "ampie", 0 },
    { "theda3", 0 },
    { "adrian", 0 },
    { "messg2", 0 },
    { "romer2", 0 },
    { "tense", 0 },
    { "shawn3", 0 },
    { "openin", 0 },
    { "evil", 0 },
    { "ultima", 0 },
    { "read_m", 0 },
    { "dm2ttl", 0 },
    { "dm2int", 0 } 
};


//
// Information about all the sfx
//

#define SFX_NFP(name,priority)	\
	{ name, false, priority, NULL, -1, -1, NULL, 0, 0, 0}
#define SFX_NTP(name,priority)	\
	{ name, true, priority, NULL, -1, -1, NULL, 0, 0, 0}

sfxinfo_t S_sfx[] =
{
  // S_sfx[0] needs to be a dummy for odd reasons.
	SFX_NFP("none", 0),

	SFX_NFP("pistol",64),
	SFX_NFP("shotgn",64),
	SFX_NFP("sgcock",64),
	SFX_NFP("dshtgn",64),
	SFX_NFP("dbopn",64),
	SFX_NFP("dbcls",64),
	SFX_NFP("dbload",64),
	SFX_NFP("plasma",64),
	SFX_NFP("bfg",64),
	SFX_NFP("sawup",64),
	SFX_NFP("sawidl",118),
	SFX_NFP("sawful",64),
	SFX_NFP("sawhit",64),
	SFX_NFP("rlaunc",64),
	SFX_NFP("rxplod",70),
	SFX_NFP("firsht",70),
	SFX_NFP("firxpl",70),
	SFX_NFP("pstart",100),
	SFX_NFP("pstop",100),
	SFX_NFP("doropn",100),
	SFX_NFP("dorcls",100),
	SFX_NFP("stnmov",119),
	SFX_NFP("swtchn",78),
	SFX_NFP("swtchx",78),
	SFX_NFP("plpain",96),
	SFX_NFP("dmpain",96),
	SFX_NFP("popain",96),
	SFX_NFP("vipain",96),
	SFX_NFP("mnpain",96),
	SFX_NFP("pepain",96),
	SFX_NFP("slop",78),
	SFX_NTP("itemup",78),
	SFX_NTP("wpnup",78),
	SFX_NFP("oof",96),
	SFX_NFP("telept",32),
	SFX_NTP("posit1",98),
	SFX_NTP("posit2",98),
	SFX_NTP("posit3",98),
	SFX_NTP("bgsit1",98),
	SFX_NTP("bgsit2",98),
	SFX_NTP("sgtsit",98),
	SFX_NTP("cacsit",98),
	SFX_NTP("brssit",94),
	SFX_NTP("cybsit",92),
	SFX_NTP("spisit",90),
	SFX_NTP("bspsit",90),
	SFX_NTP("kntsit",90),
	SFX_NTP("vilsit",90),
	SFX_NTP("mansit",90),
	SFX_NTP("pesit",90),
	SFX_NFP("sklatk",70),
	SFX_NFP("sgtatk",70),
	SFX_NFP("skepch",70),
	SFX_NFP("vilatk", 70),
	SFX_NFP("claw",70),
	SFX_NFP("skeswg",70),
	SFX_NFP("pldeth",32),
	SFX_NFP("pdiehi",32),
	SFX_NFP("podth1",70),
	SFX_NFP("podth2",70),
	SFX_NFP("podth3",70),
	SFX_NFP("bgdth1",70),
	SFX_NFP("bgdth2",70),
	SFX_NFP("sgtdth",70),
	SFX_NFP("cacdth",70),
	SFX_NFP("skldth",70),
	SFX_NFP("brsdth",32),
	SFX_NFP("cybdth",32),
	SFX_NFP("spidth",32),
	SFX_NFP("bspdth",32),
	SFX_NFP("vildth",32),
	SFX_NFP("kntdth",32),
	SFX_NFP("pedth",32),
	SFX_NFP("skedth",32),
	SFX_NTP("posact",120),
	SFX_NTP("bgact",120),
	SFX_NTP("dmact",120),
	SFX_NTP("bspact",100),
	SFX_NTP("bspwlk",100),
	SFX_NTP("vilact",100),
	SFX_NFP("noway",78),
	SFX_NFP("barexp",60),
	SFX_NTP("punch",64),
	SFX_NFP("hoof",70),
	SFX_NFP("metal",70),
	{ "chgun", false, 64, &S_sfx[sfx_pistol], 150, 0, NULL, 0, 0 },
	SFX_NFP("tink",60),
	SFX_NFP("bdopn",100),
	SFX_NFP("bdcls",100),
	SFX_NFP("itmbk",100),
	SFX_NFP("flame",32),
	SFX_NFP("flamst",32),
	SFX_NFP("getpow",60),
	SFX_NFP("bospit",70),
	SFX_NFP("boscub",70),
	SFX_NFP("bossit",70),
	SFX_NFP("bospn",70),
	SFX_NFP("bosdth",70),
	SFX_NFP("manatk",70),
	SFX_NFP("mandth",70),
	SFX_NFP("sssit",70),
	SFX_NFP("ssdth",70),
	SFX_NFP("keenpn",70),
	SFX_NFP("keendt",70),
	SFX_NFP("skeact",70),
	SFX_NFP("skesit",70),
	SFX_NFP("skeatk",70),
	SFX_NFP("radio",60)
};
