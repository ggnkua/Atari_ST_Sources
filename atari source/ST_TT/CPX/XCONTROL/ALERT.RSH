/* XCONTROL.RSH
 *==========================================================================
 * DATE: April 3, 1990
 * DESCRIPTION: RSH file from RESOURCE
 */
 
#pragma warn -apt	/* 1 Non-portable pointer assignment */
#pragma warn -rpt	/* 1 Non-portable pointer conversion */
#pragma warn -sig       /* 2 Conversion may lose significant digits */
 
#if USA | UK
 #include "alert\usa\usa.rsh" 
#endif

#if ITALY
 #include "alert\italy\italy.rsh" 
#endif

#if GERMAN
 #include "alert\german\german.rsh" 
#endif

#if FRENCH
 #include "alert\french\french.rsh" 
#endif

#if SPAIN
 #include "alert\spain\spain.rsh" 
#endif

#if SWEDEN
 #include "alert\sweden\sweden.rsh" 
#endif

#pragma warn .sig
#pragma warn .apt
#pragma wanr .rpt



