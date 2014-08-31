/*
 *      trantab.h            (w) Peter Rottengatter  1996
 *                               perot@pallas.amp.uni-hannover.de
 *
 *      Included into the SERIAL.STX source code files
 */

#define  EMPTY        NULL, NULL, NULL, 2
#define  NOACTION     NULL, NULL, NULL

/*
 * State machine transition table.
 */

static TRANSITION trantab[PPP_SNUM][PPP_ENUM] = {

  /* State : PPP_INITIAL   */  {
        {  NOACTION, 2  }, {  EMPTY  }, {  this_layer_start, NULL, NULL, 1  }, {  NOACTION, 0  },
        {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  },
        {  EMPTY  }, {  EMPTY  }, {  EMPTY  }
     },

  /* State : PPP_STARTING  */  {
        {  init_restart_cnt, send_conf_req, NULL, 6  }, {  EMPTY  }, {  NOACTION, 1  },
        {  this_layer_fin, NULL, NULL, 0  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  },
        {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }, {  EMPTY  }
     },

  /* State : PPP_CLOSED    */  {
        {  EMPTY  }, {  NOACTION, 0  }, {  init_restart_cnt, send_conf_req, NULL, 6  },
        {  NOACTION, 2  }, {  EMPTY  }, {  EMPTY  }, {  send_term_ack, NULL, NULL, 2  },
        {  send_term_ack, NULL, NULL, 2  }, {  send_term_ack, NULL, NULL, 2  },
        {  send_term_ack, NULL, NULL, 2  }, {  send_term_ack, NULL, NULL, 2  },
        {  NOACTION, 2  }, {  NOACTION, 2  }, {  this_layer_fin, NULL, NULL, 2  }
     },

  /* State : PPP_STOPPED   */  {
        {  EMPTY  }, {  this_layer_start, NULL, NULL, 1  }, {  NOACTION, 3  }, {  NOACTION, 2  },
        {  EMPTY  }, {  EMPTY  }, {  init_restart_cnt, send_conf_req, send_conf_ack, 8  },
        {  init_restart_cnt, send_conf_req, send_conf_nack, 6  }, {  send_term_ack, NULL, NULL, 3  },
        {  send_term_ack, NULL, NULL, 3  }, {  send_term_ack, NULL, NULL, 3  }, {  NOACTION, 3  },
        {  NOACTION, 3  }, {  this_layer_fin, NULL, NULL, 3  }
     },

  /* State : PPP_CLOSING   */  {
        {  EMPTY  }, {  NOACTION, 0  }, {  NOACTION, 5  }, {  NOACTION, 4  },
        {  send_term_req, NULL, NULL, 4  }, {  this_layer_fin, NULL, NULL, 2  }, {  NOACTION, 4  },
        {  NOACTION, 4  }, {  NOACTION, 4  }, {  NOACTION, 4  }, {  send_term_ack, NULL, NULL, 4  },
        {  this_layer_fin, NULL, NULL, 2  }, {  NOACTION, 4  }, {  this_layer_fin, NULL, NULL, 2  }
     },

  /* State : PPP_STOPPING  */  {
        {  EMPTY  }, {  NOACTION, 1  }, {  NOACTION, 5  }, {  NOACTION, 4  },
        {  send_term_req, NULL, NULL, 5  }, {  this_layer_fin, NULL, NULL, 3  }, {  NOACTION, 5  },
        {  NOACTION, 5  }, {  NOACTION, 5  }, {  NOACTION, 5  }, {  send_term_ack, NULL, NULL, 5  },
        {  this_layer_fin, NULL, NULL, 3  }, {  NOACTION, 5  }, {  this_layer_fin, NULL, NULL, 3  }
     },

  /* State : PPP_REQ_SENT  */  {
        {  EMPTY  }, {  NOACTION, 1  }, {  NOACTION, 6  },
        {  init_restart_cnt, send_term_req, NULL, 4  }, {  send_conf_req, NULL, NULL, 6  },
        {  this_layer_fin, NULL, NULL, 3  }, {  send_conf_ack, NULL, NULL, 8  },
        {  send_conf_nack, NULL, NULL, 6  }, {  init_restart_cnt, NULL, NULL, 7  },
        {  init_restart_cnt, send_conf_req, NULL, 6  }, {  send_term_ack, NULL, NULL, 6  },
        {  NOACTION, 6  }, {  NOACTION, 6  }, {  this_layer_fin, NULL, NULL, 3  }
     },

  /* State : PPP_ACK_RECVD */  {
        {  EMPTY  }, {  NOACTION, 1  }, {  NOACTION, 7  },
        {  init_restart_cnt, send_term_req, NULL, 4  }, {  send_conf_req, NULL, NULL, 6  },
        {  this_layer_fin, NULL, NULL, 3  }, {  send_conf_ack, this_layer_up, NULL, 9  },
        {  send_conf_nack, NULL, NULL, 7  }, {  send_conf_req, NULL, NULL, 6  },
        {  send_conf_req, NULL, NULL, 6  }, {  send_term_ack, NULL, NULL, 6  },
        {  NOACTION, 6  }, {  NOACTION, 6  }, {  this_layer_fin, NULL, NULL, 3  }
     },

  /* State : PPP_ACK_SENT  */  {
        {  EMPTY  }, {  NOACTION, 1  }, {  NOACTION, 8  },
        {  init_restart_cnt, send_term_req, NULL, 4  }, {  send_conf_req, NULL, NULL, 8  },
        {  this_layer_fin, NULL, NULL, 3  }, {  send_conf_ack, NULL, NULL, 8  },
        {  send_conf_nack, NULL, NULL, 6  }, {  init_restart_cnt, this_layer_up, NULL, 9  },
        {  init_restart_cnt, send_conf_req, NULL, 8  }, {  send_term_ack, NULL, NULL, 6  },
        {  NOACTION, 8  }, {  NOACTION, 8  }, {  this_layer_fin, NULL, NULL, 3  }
     },

  /* State : PPP_OPENED    */  {
        {  EMPTY  }, {  this_layer_down, NULL, NULL, 1  }, {  NOACTION, 9  },
        {  this_layer_down, init_restart_cnt, send_term_req, 4  }, {  EMPTY  }, {  EMPTY  },
        {  this_layer_down, send_conf_req, send_conf_ack, 8  },
        {  this_layer_down, send_conf_req, send_conf_nack, 6  },
        {  this_layer_down, send_conf_req, NULL, 6  },
        {  this_layer_down, send_conf_req, NULL, 6  },
        {  this_layer_down, zero_restart_cnt, send_term_ack, 5  },
        {  this_layer_down, send_conf_req, NULL, 6  }, {  NOACTION, 9  },
        {  this_layer_down, init_restart_cnt, send_term_req, 5  }
     }
   };
