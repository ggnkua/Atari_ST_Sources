LazyBBS - Version 0.7

This is the lastest release, read lazybbs.txt for more info, this file
lists only bugs/history.

This software is free software, but please change the version number to 
something like "0.0joe" to avoid confusion if you compile/release your 
own version. Don't be afraid by the awful code (I said lazy! :-)).

WARNING FOR VERSION <0.7 USERS: Menu file syntax slightly changed at 
version 0.7, convert your old menu files. See history below for details. 

ATARI USERS: Atari users also note the atari binary is not distributed 
in the standard package anymore. See the atari binary distribution of 
lazy utilities.

You can contact me at:
    Fidonet Franck Arnaud @ 2:320/100 (freq latest version as LAZYBBS)
    Internet franck@altsoft.demon.co.uk
    Nonsupport BBS at +33-1-49650542

BUGS:
=====

- linedit.c: linedit displays too much lines when quoting long mails?


TODO:
=====

- Unify misc.c with other lazy utilities?
- Multiple external protocols?
- Doors?
- Echomail capture?

Note I don't need any of those features at the moment, so implementation 
is not planned in the near future.


HISTORY:
========

0.2beta FA  First public beta release
0.3beta FA  Old history deleted, nobody should have 0.2 anymore
0.4beta FA  Last name better checked, log of download file size correct
        FA  long message + one line message bug fixed
        FA  missing prompt on the users screen mail reader
        FA  replaced out_printf by out_string for user strings
        FA  Rcvd flag in netmail now updated
        FA  Display empty areas in echomail list
        FA  Display netmail (new) messages waiting
        FA  password now echo dots
        FA  add comm. line flag -g for sysop: read all pvt mail, show kludges
        FA  added quote mail in mail read
        FA  fixed linedit for writing several mails during 1 session
        FA  added node number display in netmail
        FA  openlog/closelog renamed to avoid unix libs conflict
        FA  new user lastlogin is "never" instead of "today"
0.5beta FA  fixed bug in close_login in case of error
        FA  added global download (gdown in menu files)
        FA  password change can be canceled
        FA  fixed stack space bug in new user questions (prevented
            new user from login).
        FA  .hdr -> .HDR for unix compatibility
        FA  fixed previous msg bug
        FA  added -d<device> flag for MegaSTE/TT ports, req. by B. Heinen
        VP  removed nice ISO date to old fashionned format 
        FA  fixed linedit bug with consecutive uses in the same session (buffer was not deleted)
        FA  added message number in message list
        FA  few cosmetic fixes
        FA  PID kludge have been made more joho-compatible
0.6beta FA  Fixed exit of chat (all control chars, del, cr used to exit)
        FA  Fixed download
        FA  Fixed node # display when quoting private mails
        FA  It's now possible to download a file whose size >limit 
            when user have not downloaded anything else
        FA  Multiple files in global download
        FA  Pattern matching (regular exp.) in global download
        FA  Added "Mail!" in all menus when unread new mail is there
        FA  MAJOR REORGANISATION: 
            edited and new source/headers to better "modulize" the 
            software, better now but still improvable.
0.7     FA  Foolproofing in mail: prevents long subjects
        FA  Cosmetic fix in more(), and from/from in netmail (rep. by S. Caple)
        FA  IMPORTANT: MENU SYNTAX CHANGE
            read/write commands syntax changed, internal command prefixed 
            with '_' to avoid confusion with group names. commands are 
            now read _private, write _sysop,_local,_uucp,_fido.
        FA  privacy fix in display message list
        FA  security fix: a new user can't read netmail to "him"
        FA  the_end go to miscio.c, echolist routines go to msg.c
        FA  linedit buffer now flushed on abort
        FA  added malloc check in postmsg.c
        FA  added extra 0 at the end of posted messages, rep. by Steve Caple
        FA  added \r after VT52+VT100 screen delete, looks nicer
        FA  added maxdown keyword in bbs.cfg to set max down KB/day
        FA  added maxtime keyword in bbs.cfg to set max session time
        VP  unix sysdep may eventually work now
        FA  removed dependencies to the strins() Lattice library function
