/* WinCom-Message def's */
/* 
	pbuf[0]=WINCOM_MSG 
	pbuf[1]=ap_id
	pbuf[2]=0
	pbuf[3]=<Kommando>
	pbuf[4]=<id, Option>
	pbuf[5]=<id>
*/

#define WINCOM_MSG 0x999

#define	WI_CLS	0				/* AufrÑumen */

#define	WI_CALL_APP 1		/* Applikation toppen */

#define WI_CALL_ACC 2		/* Accessory îffnen */

#define WI_HIDE 3				/* App. ausblenden */
	#define WIH_THIS 0				/* ap_id wird noch angegeben */
	#define	WIH_ACT	1					/* Aktuelle */
	#define	WIH_OTHER 2				/* Alle auûer aktuelle */
	#define WIH_ALL 3					/* alle */

#define WI_SHOW	4				/* App. einblenden */
	#define WIS_THIS	0			/* ap_id wird angegeben */
	#define	WIS_ALL		1			/* alle einblenden */

#define	WI_TOPWIN	5			/* Fenster (+MenÅ) aktivieren */

#define	WI_SOFF 998		/* Standard-ScreenwÑchter abschalten */
#define	WI_SON	999		/* Standard-ScreenwÑchter anschalten */
