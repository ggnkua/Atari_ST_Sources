/*	MESSAGE.H		9/21/92			Derek Mui		*/

#ifndef _MESSAGE_H_
#define _MESSAGE_H_

#define AP_MSG 			0
#define WM_USER	    	0
#define MN_SELECTED 	10

#define WM_REDRAW 	20
#define WM_TOPPED 	21
#define WM_CLOSE 	22
#define WM_FULLED 	23
#define WM_ARROWED 	24
#define WM_HSLID 	25
#define WM_VSLID 	26
#define WM_SIZED 	27
#define WM_MOVED 	28
#define WM_UNTOPPED	30
#define WM_ONTOP	31
/* what is 32 for? assume it is reserved */
#define WM_BOTTOMED	33
#define WM_ICONIFIED	34
#define WM_UNICONIFIED	35
#define WM_ICONIFYALL	36
#define WM_TOOLBAR	37

#define AC_OPEN 	40
#define AC_CLOSE 	41

#define AP_TERM		50	/* Request app to terminate	*/
#define AP_TFAIL	51	/* Fail to terminate or close	*/	
#define AP_TSUCCESS	52	/* Termination success		*/ 

#define CT_KEY		53	/* CPX */
#define CT_MULTI	55	/* CPX */

#define AP_RESCHG	57	/* resolution change		*/
#define AP_ACTIVE	58	/* application becomes active/not	*/

#define SHUT_COMPLETED	60	/* shutdown completed		*/
#define RESCH_COMPLETED 61	/* resolution changed completed */

#define	AP_DRAGNDROP	63	/* application drag and drop	*/

#define DK_INFLOAD	70	/* Load in INF again		*/
#define DK_ICNLOAD	71	/* Load in ICN file again	*/	
#define SH_WDRAW	72	/* redraw windows		*/

#define	CH_EXIT		90	/* child process exit		*/

#endif

