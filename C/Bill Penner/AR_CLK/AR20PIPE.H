/************************************************************************/
/* AR20PIPE.H               by Bill Penner             22 November 1987 */
/************************************************************************/
/* Pipe command list                                                    */
/************************************************************************/

#define  RPARAM  0x5101  /* Read clock parameters             */
#define  WPARAM  0x5102  /* Write new clock parameters        */
#define  RCFIG   0x5103  /* Make accessory read .INF file     */
#define  WCFIG   0x5104  /* Make accessory write .INF file    */
#define  ENCLKD  0x5105  /* Force clock enable                */
#define  DISCLKD 0x5106  /* Force clock disable               */
#define  SETFDEF 0x5107  /* Make clock load defaults          */
#define  RCLKEN  0x5108  /* Read clock_en flag status         */

#define  VERSION 0x2000  /* Version number -- used in .INF    */

#define  TIMEFG  0x01    /* Bit for time display flag         */
#define  DATEFG  0x02    /* Bit for date display flag         */
#define  TWELVE  0x04    /* Bit for 12 versus 24 hour format  */
#define  TWOLINE 0x08    /* Bit for two line display          */
#define  NOBELL  0x10    /* Bit for no bell on power up       */
#define  CKENAB  0x20    /* Bit for time display on power up  */

#define  BUSYBEE 2       /* Something Megamax forgot          */

#define  TRUE    1       /* Nothing like a bit of truth       */
#define  FALSE   0

