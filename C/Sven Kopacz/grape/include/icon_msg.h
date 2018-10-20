#ifndef __ICON_MSG__
#define __ICON_MSG__

/* pbuf[0] */
#define ICON_MSG	0x994
/* pbuf[1]=ap_id, pbuf[2]=0 */

/* Ask Iconnect for current state: */
/* pbuf[3]: */
/* Application->Iconnect */
#define ICM_STATUS_REQUEST 1
/* Iconnect->Application */
#define ICM_STATUS_REPLY 2
/* pbuf[4] in reply */
#define ICMS_OFFLINE 0
#define ICMS_CONNECTING 1
#define ICMS_ONLINE 2
#define ICMS_CLOSING 3

/* Start Default-Internet-Connection (shown in Iconnect-Popup): */
/* pbuf[3]: */
/* Application->Iconnect */
#define ICM_CONNECTION_REQUEST 3
/* Iconnect->Application */
#define ICM_CONNECTION_REPLY 4
/* pbuf[4] in reply */
#define ICMC_NOT_OFFLINE 0
#define ICMC_CONNECTING 1

/* Close Internet-Connection */
/* pbuf[3]: */
/* Application->Iconnect */
#define ICM_SHUTDOWN_REQUEST 5
/* Iconnect->Application */
#define ICM_SHUTDOWN_REPLY 6
/* pbuf[4] in reply */
#define ICMH_NOT_ONLINE 0
#define ICMH_DISCONNECTING 1

/* Anything else: */
/* pbuf[3]: */
/* Iconnect->Application */
#define ICM_UNKNOWN_REQUEST -1


/* pbuf[5/6] not used, MUST be 0 */
/* pbuf[7]=ID, always returned with reply */

#endif