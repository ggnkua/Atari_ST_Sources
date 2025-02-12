/* $Id: proto.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
#ifndef PROTO
#if defined (USE_PROTOTYPES) ? USE_PROTOTYPES : defined (__STDC__)
#define PROTO(ARGS) ARGS
#else
#define PROTO(ARGS) ()
#endif
#ifndef __STDC__
#define const
#endif
#ifndef __GNUC__
#define inline
#endif
#endif

