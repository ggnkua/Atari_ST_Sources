/* FSM INSTALL
 *==========================================================================
 * DATE: December 12, 1990
 * DESCRIPTION: RSH file from RESOURCE
 */
 
#pragma warn -apt	/* 1 Non-portable pointer assignment */
#pragma warn -rpt	/* 1 Non-portable pointer conversion */
#pragma warn -sig       /* 2 Conversion may lose significant digits */
 
#if USA | UK
 #include "resource\usa\usa.rsh" 
#endif

#if ITALY
 #include "resource\italy\italy.rsh" 
#endif

#if GERMAN
 #include "resource\german\german.rsh" 
#endif

#if FRENCH
 #include "resource\french\french.rsh" 
#endif

#if SPAIN
 #include "resource\spain\spain.rsh" 
#endif

#if SWEDEN
 #include "resource\sweden\sweden.rsh" 
#endif

#pragma warn .sig
#pragma warn .apt
#pragma wanr .rpt



