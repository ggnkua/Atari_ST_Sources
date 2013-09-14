/* XCONTROL.RSH
 *==========================================================================
 * DATE: April 3, 1990
 * DESCRIPTION: RSH file from RESOURCE
 */
 
#pragma warn -apt	/* 1 Non-portable pointer assignment */
#pragma warn -rpt	/* 1 Non-portable pointer conversion */
#pragma warn -sig       /* 2 Conversion may lose significant digits */
 
#if USA
 #include "resource\usa.rsc\usa.rsh" 
#endif

#if UK
 #include "resource\usa.rsc\usa.rsh" 
#endif

#if ITALY
 #include "resource\italy.rsc\italy.rsh" 
#endif

#if GERMAN
 #include "resource\german.rsc\german.rsh" 
#endif

#if FRENCH
 #include "resource\french.rsc\french.rsh" 
#endif

#if SPAIN
 #include "resource\spain.rsc\spain.rsh" 
#endif

#if SWEDEN
 #include "resource\sweden.rsc\sweden.rsh" 
#endif

#pragma warn .sig
#pragma warn .apt
#pragma wanr .rpt



