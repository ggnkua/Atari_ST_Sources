BloufGate 0.8.1 (!BETA!)
========================


TODO

- Batch the batch SMTP?
- Import batchsmtp
- remove getopt dependency
- what happens with bounced bounces?

BUGS

- Check memorized dupe checker
- batchsmtp '.'
- Msgid generator improvable (fix time_t==long assumption)?
- RFC>FTN address buggy (netmails), remove debug code once debugged
- Check header completeness ?
- Mail with "newsgroup" line goes newsgroup
- news won't work on crlf files?
- write manual

MAKE

- edit first part of blouf.h for your system
- compile misc.c fug.c main.c pkt.c ufg.c config.c global.c 
  address.c killdupe.c and link to blouf 
- if you want to use nodelist, compile nlist.c 
- MSC7: /Oi optimisation bugs! remove optimisation if you have problems
- UNIX: all files are DOS cr/lf-ed, unzip with -a to avoid problems
 

CONTACT	with original author(s)

Internet: franck.arnaud@linn.fidonet.org
BBS: +33-1-49650542 V32bis
Fidonet: 2:320/100

---------------------------------------------------------------
HISTORY

----- 0.1-6
Alpha Internal releases for the Atari ST (1991)

----- 0.7b1-4
First alpha of the portable rewrite, old history deleted
 
----- 0.7.5
Fixed little problems for compilation under Unix
Fixed problem with unix version of fputs()

----- 0.7.6
.pkt upgrade to .PKT for compatibility with Bermuda/Unix
atoi promoted to atol in ufg.c
fixed bug in incoming news text convertion (lf->cr)

----- 0.7.7
Bug that made a few char missing at the beginning of converted 
news batches on DOS and DOS-like platforms fixed.
added if <label>/end in config and -s <label> in command line
added configurable domain
usage() now reflect reality
removed extra \0 at the end pkt
empty lines no more removed
header at the end of mail messages with \r

----- 0.7.8
REALLY remove the \0 at the end of pkt instead of end of message (1993)
Removed DOS support
Added mailbox files support (-mbox option).
Added To: field overloading (for address in enveloppe files or mailboxes)		
Primary domains list now complete
Improved msgid generation (serial # dupes unlikely to happen now)
Added tempdir
Added subject field lenght checking in fido pkts
FINALLY fixed end of packet
Fixed bug with standard fgets (caused crash)

----- 0.7.9
Now support unregistered (xx.fidonet.org) sites, add the 
registered keyword in your config if you're registered
		
----- 0.8.0	
Now accepts origins with '(' in the origin text (rep. by S. Przyswa)
Checkdomain/uucpwarning/bitnetwarning now works
Added -d command line option to display parsed config file
Pointer fixes, BLOUFRC env var added, various other fixes (by T. Bousch)
Malloc fix in ufg.c process_news (rep. by T. Bousch)
REALLY fixed the bug with fgets
Added dupekiller (contributed by T. Bousch)

----- 0.8.1	
Upgraded licence from GNU GPL to plain Public Domain
More & more bugs fixed <sigh>
Dupechecker now remembers ID, new dupefile config statement
#ifdef BATCHSMTP, mail output is batchsmtp
Improved blouf.txt, not a full doc but now +/- synched with the code
Added FSC-0054 minimal support in rfc>ftn way, default to Latin1
Removed bproto.h (in blouf.h) and getopt dependency