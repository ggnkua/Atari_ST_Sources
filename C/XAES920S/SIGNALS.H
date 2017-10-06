#ifndef _SIGNALS_H_
#define _SIGNALS_H_

/* HR; always typedef handlers that are accessed via vectors. */
typedef void __saveds HandleSIG(long signo);
HandleSIG HandleSIGCHLD,
          HandleSIGINT,
          HandleSIGQUIT;

#endif