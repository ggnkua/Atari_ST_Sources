#ifndef __FIDO_MSG_H__
#define __FIDO_MSG_H__

/*********************************************************************************/
/*
   FIDO_MSG.H

   header-module for special messages for FIDO software

   -----------------------------------------------------------------------------

   It's possible to send some fido programs messages, so they will
   do certain things as soon as possible. Just send a message via 
   appl_write():

   WORD message[8], id;
   id = appl_find( PROGRAMNAME );
   if (id>=0)
   {   message[0] = FIDO_MSG                // MAGIC value
       message[1] = ap_id;                  // appl_init ID of the sender
       message[2] = 0;                      // just a 16 byte message
       *((LONG *) &message[3]) = FROM;      // sender verification
       *((LONG *) &message[5]) = TODO;      // what's to be done
       message[7] = 0;                      // reserved
       appl_write( id, 16, message );
   }
  
   PROGRAMNAME: "SEMPER  "
                "AVALON  "
                "OCTOPUS "
                "LED     "

   -----------------------------------------------------------------------------

   It is possible to request a small information block. This feature
   is *not* supported by all software. Only AVALON and LED support 
   this message yet.
  
   When sending a FidoMessage (FIDO_MSG 'FM' with command AVAL_INFO)
   to AVALON, it returns following message (FIDO_INFO 'FI'):

    message[0] = FIDO_INFO               // MAGIC value
    message[1] = ap_id;                  // appl_init ID of the sender (AVALON)
    message[2] = 0;                      // just a 16 byte message
    *((LONG *) &message[3]) = FM_AVALON; // sender verification
    message[5] = version;                // version (see later)
    message[6] = commandrev;             // command rev. (see later)
    message[7] = 0;                      // reserved
    appl_write( id, 16, message );

       version: program version (e.g. AVALON returns 0x0360 for V3.60)
    commandrev: command subset (fullversion of AVALON returns 0x10,
                                AVALON for SEMPER returns 0x00)
                The command rev. is stored in the lower byte, the higher
                byte is reserved and zero!

   -----------------------------------------------------------------------------

   Make sure that _all_ applications with the same name are getting
   the needed information!! Within a multitasking environment check
   for the appl_search() function and use this one instead of appl_find()!
  
   Code to check this is available here if necessary.
*/


/*********************************************************************************/
/*
   ID's for the 'FROM'-field:
*/

#define FM_SEMPER       'SEMP'    /* Semper                                      */
#define FM_AVALON       'AVAL'    /* Avalon shell                                */
#define FM_MSGREADER    'MSGR'    /* e.g. LED                                    */
#define FM_TOSSER       'TOSS'    /* e.g. JetMail                                */
#define FM_REQCOMPILER  'REQC'    /* RequestCompiler                             */
#define FM_NLCOMPILER   'NLST'    /* NodelistCompiler                            */
#define FM_OCTOPUS      'OCTP'    /* Octopus BBS                                 */
#define FM_LED					'LED '		/* LED MsgReader															 */

/*********************************************************************************/
/*
   Magic value for recognizing *INCOMING* messages:
*/
#define FIDO_MSG        'FM'      /* Magic value for identifying FidoMessage     */
#define FIDO_INFO       'FI'      /* Magic value for identifying FidoInfo        */
                                  /* 'FI' is *not* supported by all software yet */

/*********************************************************************************/
/*
   Currently supported SEMPER-TODO values:
*/
#define SEMP_RESCAN     (1UL << 0)    /* Rescan outbound                         */
#define SEMP_READ_NLIST (1UL << 1)    /* Reread nodelist                         */
#define SEMP_READ_RQST  (1UL << 2)    /* Reread request index                    */
#define SEMP_EXPORTER   (1UL << 3)    /* Executes Export                         */

/*********************************************************************************/
/*
   Currently supported AVALON-TODO values (command rev.0x00 and higher):
*/
#define AVAL_INFO       0x00000000UL  /* Request FIDO_INFO-Message ('FI')        */
#define AVAL_REQ        0x00000001UL  /* FileRequest                             */
#define AVAL_HATCH      0x00000002UL  /* FileHatch                               */
#define AVAL_FIX        0x00000003UL  /* Areafix/Filefix                         */
#define AVAL_AREAS      0x00000004UL  /* Edit areas                              */
/*
   Currently supported AVALON-TODO values (command rev.0x10 and higher):
*/
#define AVAL_POLL       0x00000005UL  /* Start all selected pollsessions         */
#define AVAL_POLL1      0x00010005UL  /* Start pollsession #1                    */
#define AVAL_POLL2      0x00020005UL  /* Start pollsession #2                    */
#define AVAL_POLL3      0x00030005UL  /* Start pollsession #3                    */
#define AVAL_POLL4      0x00040005UL  /* Start pollsession #4                    */
#define AVAL_POLL5      0x00050005UL  /* Start pollsession #5                    */
#define AVAL_POLL6      0x00060005UL  /* Start pollsession #6                    */

/*********************************************************************************/
/*
   Currently supported OCTOPUS-TODO values:
*/
#define OCTO_M_LOCAL    0x0001UL  /* Begin a local logon                         */
#define OCTO_M_WATCH    0x0002UL  /* Open a View window when a connection exist  */
#define OCTO_M_MAILER   0x0004UL  /* End Octopus after a connection (not needed) */
#define OCTO_M_NOHANGUP 0x0008UL  /* Don't raise the DTR signal for hangup       */
#define OCTO_M_STATUS   0x0010UL  /* Request of Octopus Status                   */

/*
   Return values for Octopus->Semper:
*/
#define OCTO_M_OK       0x0010UL  /* Ok, ACK handshake message                   */
#define OCTO_M_BUSY     0x0020UL  /* Octopus is busy yet                         */
#define OCTO_M_READY    0x0040UL  /* Octopus is waiting (ready) now...           */
#define OCTO_M_HELLO    0x0080UL  /* Say Hello to Semper... :-)                  */

/*********************************************************************************/
/*
   Currently supported LED-TODO values (command rev.0x00 and higher):
*/
#define LED_INFO				0x00000000UL	/* Request FIDO_INFO-Message ('FI')				 */

/*********************************************************************************/
/* --- End of fido_msg.h module	---                                              */

#endif
