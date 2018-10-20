#ifndef __GEM_SCRIPT__
#define __GEM_SCRIPT__

#define GS_REQUEST 0x1350
#define GS_REPLY 0x1351
#define GS_COMMAND 0x1352
#define GS_ACK 0x1353
#define GS_QUIT 0x1354
#define GS_OPENMACRO 0x1355
#define GS_MACRO 0x1356
#define GS_WRITE 0x1357
#define GS_CLOSEMACRO 0x1358

#define GSACK_OK	0
#define	GSACK_UNKNOWN 1
#define GSACK_ERROR	2

typedef struct {
   long len;       /* LÑnge der Struktur in Bytes                      */
   int  version;   /* Versionsnummer des Protokolles beim Sender
                      (z.Z. 0x0100 = 1.0)                             */
   int  msgs;      /* Bitmap der unterstÅtzten Nachrichten (GSM_xxx)   */
   long ext;       /* benutzte Endung, etwa '.SIC'                     */
} GS_INFO;

#define GSM_COMMAND 0x0001  /* kann GS_COMMAND empfangen                     */
#define GSM_MACRO   0x0002  /* kann GS_OPENMACRO, GS_WRITE und GS_CLOSEMACRO
                    			     empfangen, GS_MACRO verschicken
			                         (Interpreter)                                 */
#define GSM_WRITE   0x0004  /* kann GS_OPENMACRO, GS_WRITE und GS_CLOSEMACRO
        	  	  	             verschicken, GS_MACRO empfangen
          	  	  	           (aufnahmefÑhige Applikation)                  */


#endif