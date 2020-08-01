/* osptrs.h - table entries for machine specific functions */

#ifdef MACINTOSH
{	"HIDEPEN",				xhidepen	},
{	"SHOWPEN",				xshowpen	},
{	"GETPEN",				xgetpen		},
{	"PENSIZE",				xpensize	},
{	"PENMODE",				xpenmode	},
{	"PENPAT",				xpenpat		},
{	"PENNORMAL",				xpennormal	},
{	"MOVETO",				xmoveto		},
{	"MOVE",					xmove		},
{	"LINETO",				xlineto		},
{	"LINE",					xline		},
{	"SHOW-GRAPHICS",			xshowgraphics	},
{	"HIDE-GRAPHICS",			xhidegraphics	},
{	"CLEAR-GRAPHICS",			xcleargraphics	},
#endif

#ifdef MSDOS
{	"SYSTEM",				xsystem		},
{	"GET-KEY",				xgetkey		},
{	"TIME",					xtime		},
{	"DIFFTIME",				xdifftime	},
#ifdef NOTDEF
{	"INT86",				xint86		},
{	"INBYTE",				xinbyte		},
{	"OUTBYTE",				xoutbyte	},
#endif
#endif

#ifdef UNIX
{	"SYSTEM",				xsystem		},
#endif

