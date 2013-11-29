/*
 * protocol.h	external variables
 */

#include "module.h"
#include "transprt.h"
#include "http.h"
#include "drivers.h"

extern int ncn,mcn,pcn,fpi,fdtp;
extern int max_to,char_to;
extern char header[2048];
extern url_methods_t out;
extern URL_info info; 
extern browser_info_t in; 
extern char log_data,log_cmd,log_resp,log_mask_pswds;
extern char ftp_send_help,ftp_send_alloc,ftp_use_port;