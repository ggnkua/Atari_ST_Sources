/* Structures needed for FidoNet compatible packets */

struct _pkthdr
{  short  ph_onode,               /* originating node */
          ph_dnode,               /* destination node */
          ph_yr, ph_mo, ph_dy,    /* date packet was assembled */
          ph_hr, ph_mn, ph_sc,    /* time packet was assembled */
          ph_rate,                /* packet baud rate */
          ph_ver,                 /* packet version */
          ph_onet,                /* originating net */
          ph_dnet;                /* destination net */
   short  ph_prod;                /* product code */
   char   ph_pwd[8];              /* password */
   short  ph_ozone,               /* originating zone */
          ph_dzone,               /* destination zone */
          ph_rsvd[10];            /* reserved for future use */
};

struct _pktmsgs
{  short pm_ver,                 /* message version */
         pm_onode,               /* originating node */
         pm_dnode,               /* destination node */
         pm_onet,                /* originating net */
         pm_dnet,                /* destination net */
         pm_attr,                /* message attributes */
         pm_cost;                /* message cost, in cents */
};
