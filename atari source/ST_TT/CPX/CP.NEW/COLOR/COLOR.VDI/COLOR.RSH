/* COLOR.RSH
 *==========================================================================
 * DATE: MAY 3, 1990	(from C. Gee)
 * DESCRIPTION: RSH file from RESOURCE
 */
 
#pragma warn -apt	/* 1 Non-portable pointer assignment */
#pragma warn -rpt	/* 1 Non-portable pointer conversion */
#pragma warn -sig       /* 2 Conversion may lose significant digits */
 
#if USA
 #include "resource\usa\usa.rsh" 
#endif

#if	UK
 #include "resource\uk\uk.rsh" 
#endif

#if FRANCE
 #include "resource\france\france.rsh" 
#endif

#if GERMANY
 #include "resource\germany\germany.rsh" 
#endif

#if ITALY
 #include "resource\italy\italy.rsh" 
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



