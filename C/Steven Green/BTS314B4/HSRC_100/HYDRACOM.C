/*=============================================================================

                              HydraCom Version 1.00

                         A sample implementation of the
                   HYDRA Bi-Directional File Transfer Protocol

                             HydraCom was written by
                   Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED

                       The HYDRA protocol was designed by
                 Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
                             Joaquim H. Homrighausen
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED


  Revision history:
  06 Sep 1991 - (AGL) First tryout
  .. ... .... - Internal development
  11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)


  DISCLAIMER

  This program is provided "as is" and comes with no warranties of any
  kind, either expressed or implied. In no event shall the authors be
  liable to you or anyone else for any damages, including any lost
  profits, lost savings or other incidental or consequential damages
  arising out of the use or inability to use this software.


  HYDRACOM / SOURCE LICENSE

  HydraCom, its associated utilities (HydraCfg) and the HydraCom
  sourcecode may be freely distributed, copied and used, no fee charged.
  All files, executables and sourcecode remain the copyrighted property
  of Arjen G. Lentz and LENTZ SOFTWARE-DEVELOPMENT.
  The distribution archives should remain intact with no files removed
  or modified. For special purposes, it is allowed to repack the
  archives using a different compression system.

  HydraCom may be bundled up with for instance terminal or BBS packages,
  even commercial ones, provided the buyer/user is clearly informed
  about the fact that Hydra and HydraCom are free, not owned by the
  distributor/retailer in question, and is not included in any possible
  charge regarding the rest of the package. This documentation must also
  be present so the user can inform himself about Hydra and HydraCom.
  The same rules apply to inclusion in shareware and CD-ROM libraries.
  In all cases, the author of HydraCom must be given credit in any
  informational screens and literature that contain such information.

  The Hydra/HydraCom sourcecode may also be freely used and integrated
  into other software or library, provided this is clearly stated in any
  informational screens and literature pertaining to this program, and
  credit is given to the original author. If the sourcecode of that
  program or library is released or otherwise published, the notices
  present at the top of every Hydra/HydraCom source file must be
  retained in their original unmodified form.

  In addition to the above license, everyone using any part of the
  sourcecode, programs or files is fully bound by the general license of
  the Hydra protocol as present in the Hydra protocol description
  document. For easy reference, the paragraph in question is reprinted
  below.

  Any use of, or operation on (including copying/distributing) any of
  the above mentioned files implies full and unconditional acceptance of
  this license and disclaimer.


  HYDRA PROTOCOL LICENSE 

  You are granted a license to implement the HYDRA file transfer
  protocol, HYDRA hereafter, in your own programs and/or use the sample
  source code and adapt these to your particular situation and needs;
  subject to the following conditions:

   -  You must refer to it as the HYDRA file transfer protocol, and you
      must give credit to the authors of HYDRA in any information
      screens or literature pertaining to your programs that contains
      other such information (credits, your own copyrights, etc.).

   -  HYDRA will always remain backwards compatible with previous
      revisions. HYDRA allows for expansion of its features without
      interfering with previous revisions. It is, however, important
      that different people do not expand the protocol in different
      directions. We therefore ask you to contact us if you have any
      needs/ideas regarding HYDRA, so development can be synchronized
      and beneficial to all.

   -  If your implementation cannot converse with past or future
      revisions as supplied by us, then you must refer to it as "HYDRA
      derived", or as "a variation of HYDRA", or words to that effect.


  Hydra protocol design and HydraCom driver:         Hydra protocol design:
  Arjen G. Lentz                                     Joaquim H. Homrighausen
  LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
  Langegracht 7B                                     L-8011 Strassen
  3811 BT  Amersfoort                                Luxembourg
  The Netherlands
  FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
  arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu

  Please feel free to contact us at any time to share your comments about our
  software and/or licensing policies.

=============================================================================*/

#define MAIN
#include "hydracom.h"


void main (int argc, char *argv[])
{
        FILE    *ctl;
        char     ctlname[PATHLEN];
        int      err = 0;              /* assume all went well: errorlevel 0 */
        int      ac;
        char    *p;
        register int i, res;

        av = (char **) malloc(MAXARGS * ((int) sizeof (char *)));
        port = 0;                                   /* default configuration */
        cur_speed = com_speed = 0U;
        parity = false;
        noinit = nocarrier = dropdtr = false;
        nobell = false;
        mailer = false;
        hdxsession = nooriginator = false;
        hydra_txwindow = hydra_rxwindow = 0L;
        flowflags = 0;
        dcdmask = 0x80;
        noresume = nostamp = false;
        hydra_options = 0x0L;
        result = opuslog = NULL;
        download = "";
        single_file[0] = '\0';
        single_done = false;
        logfp = NULL;
        loglevel = 2;
        opustask = -1;
        didsome = false;
#if !WIN_AGL
        file_x = 0;
#endif

        signal(SIGINT,SIG_IGN);                            /* disable Ctrl-C */
        if (!getenv("TZ"))
           putenv("TZ=GMT0");
        tzset();
        dos_sharecheck();

#if !WIN_AGL
/* HJW The Topspeed gettext and puttext window procedures do have a
   bug in non video mode, at least in version 3.02. The only thing we
   can do is to enable direct viodeo. Also: The clipping window
   module reports always 25 x 80 as the screen dimensions. The bugs
   are reported to JPI
*/

#ifdef _JPI_
        directvideo = 1;
#else
        directvideo = 0;
#endif
#endif

        cprint("%s %s %s; Sample implementation of Hydra revision %03u (%s)\n",
              PRGNAME, VERSION, HC_OS, H_REVISION, h_revdate(H_REVSTAMP));
        cprint("COPYRIGHT (C) 1991-1993 by Arjen G. Lentz; ALL RIGHTS RESERVED\n");
        cprint("HYDRA was designed by Arjen G. Lentz & Joaquim H. Homrighausen\n");
        cprint("\n");
        cprint("Full specifications of the Hydra file transfer protocol are freely available.\n");
        cprint("The sources of this driver have also been released, to which the same license\n");
        cprint("applies as for this executable. See the documentation for further information.\n");
        cprint("\n");

        if (_osmajor < 3) {
           cprint("Sorry, %s requires DOS 3.0 or higher!\n",PRGNAME);
           exit (2);
        }

        if (argc < 2) {
           cprint("Usage: %s [port N] [speed N] [<options> ...] <command> [<parms> ...]\n",PRGNAME);
           any_key();
           cprint("options:  port N          Comport [1..16] (default COM1)\n");
           cprint("          speed N         Com-speed [300..57600] (default current speed)\n");
           cprint("          line N          Actual line speed (use 'speed' to set comport)\n");
           cprint("          parity          Set 7E1 instead of 8N1 (forces option highbit)\n");
           cprint("          dropdtr         Drop DTR if carrier is lost\n");
           cprint("          nocarrier       Disable carrier detection\n");
           cprint("          noinit          Don't init/deinit FOSSIL driver\n");
           cprint("          handshake <flg> Enable soft (XON/XOFF), hard (RTS/CTS) or both\n");
           cprint("          log <file>      Logfile to log the goings on\n");
           cprint("          level N         Level of logging, 0=max, 6=min (default=2)\n");
           cprint("          result <file>   Log transfer info to DSZ compatible logfile\n");
           cprint("          noresume        Disable receive bad-transfer recovery\n");
           cprint("          nostamp         Don't stamp with original but current filetime\n");
           cprint("          receive <path>  Path to store any received files\n");
           cprint("          nobell          Disable bell noise in Hydra session chat feature\n");
           any_key();
           cprint("link opt: mailer          Mailer mode, used by Dutchie (see documentation)\n");
           cprint("          nooriginator    Not originator, fallback to one-way transfer allowed\n");
           cprint("          hdxlink         Force one-way transfer mode (only with nooriginator)\n");
           cprint("          txwindow N      Transmitter window size (default 0=full streaming)\n");
           cprint("          rxwindow N      Receiver window size (default 0=full streaming)\n");
           cprint("          option xonxoff  HYDRA link option: Escape/strip XON/XOFF characters\n");
           cprint("          option telenet  HYDRA link option: Escape/strip Telenet escape\n");
           cprint("          option ctlchrs  HYDRA link option: Escape/strip ASCII 0-31 and 127\n");
           cprint("          option highctl  HYDRA link option: Apply above three also for 8th bit\n");
           cprint("          option highbit  HYDRA link option: Encode for 7 bit, strip 8th bit\n");
           cprint("commands: send [<fspec> ...]    Send <filespec>/@<ctlfile>/nothing + receive\n");
           cprint("          get [<path>[<name>]]  Only get file(s), if filename is specified, get\n");
           cprint("                                first file (name override) and skip all others\n");
           cprint("          term                  Small terminal + send & AutoStart capability\n");
           cprint("notes:    Options may be abbrev. to 3 chars; Use <exename>.CFG for defaults!\n");
           cprint("          File <exename>.CTL or option -t<n> triggers Opus-external interface\n");
           cprint("          Exit codes: transfer completed = 0, aborted = 1, runtime error = 2\n");
           exit (0);
        }

        strcpy(ourname,argv[0]);
        ourname[((int) strlen(ourname)) - 3] = '\0';   /* chop off extension */

        if (getenv("DSZLOG"))
           result = strdup(getenv("DSZLOG"));

        strcpy(work,ourname); strcat(work,"CFG");    /* extra configuration? */
        if ((ctl=sfopen(work,"rt",DENY_WRITE)) != NULL) {
           while (fgets(buffer,200,ctl)) {
                 ac = parse(buffer);
                 if (ac && !config(ac,av))
                    message(1,"-Unknown configurationfile option '%s'",av[0]);
           }
           fclose(ctl);
        }

        strcpy(ctlname,ourname); strcat(ctlname,"CTL");    /* Opus ext <1.10 */
        if ((ctl=sfopen(ctlname,"rt",DENY_WRITE)) != NULL) {
           strcpy(buffer,ourname); strcat(buffer,"LOG");
           opuslog = strdup(buffer);
           goto opusctl;
        }

        for (i = 1; i < argc; i++)
            strupr(argv[i]);
        i = 1;
        while (i < argc) {
              res = config(argc - i,&argv[i]);
              if (res) {
                 i += res;

                 if (opustask >= 0) {/* Opus External Interface Version 1.10 */
                    strcpy(ctlname,ourname);
                    sprintf(&ctlname[((int) strlen(ctlname)) - 3],"%02x.CTL",opustask);
                    if ((ctl=sfopen(ctlname,"rt",DENY_WRITE)) == NULL) {
                       message(1,"-Can't open Opus ext file '%s'",ctlname);
                       break;
                    }

                    strcpy(buffer,ourname);
                    sprintf(&buffer[((int) strlen(buffer)) - 3],"%02x.LOG",opustask);
                    opuslog = strdup(buffer);

opusctl:            if (ffirst(opuslog))           /* delete any old logfile */
                       unlink(opuslog);
                    while (fgets(buffer,200,ctl)) {
                          ac = parse(buffer);
                          if (!ac) continue;
                          if (!strcmp(av[0],"SEND")) {
                             if (!didsome) {
                                init();
                                hydra_init(hydra_options);
                             }
                             didsome = true;
                             err = batch_hydra(av[1],ac > 2 ? av[2] : NULL);
                          }
                          else
                             config(ac,av);

                          /* quit on errors during zsend or zrecv */
                          if (err) break;
                    }/*while(fgets(ctl))*/

                    fclose(ctl);
                    unlink(ctlname);

                    if (!err) {
                       if (!didsome) {
                          init();
                          hydra_init(hydra_options);
                       }
                       didsome = true;
                       hydra(NULL,NULL);
                    }
                    hydra_deinit();
                    break;
                 }/*if(opustask>=0)*/

              }/*if(res)*/

              else {
                 if (!strncmp(argv[i],"TER",3)) {
                    init();
                    didsome = true;
                    hydracom();
                    break;
                 }

                 if (!strncmp(argv[i],"SEN",3)) {
                    init();
                    didsome = true;
                    hydra_init(hydra_options);
                    while (!err && ++i < argc) {
                          if (*argv[i]=='@') {
                             argv[i]++;
                             if ((ctl=sfopen(argv[i],"rt",DENY_WRITE))==NULL) {
                                message(3,"!Couldn't open batch-ctlfile %s",argv[i]);
                                continue;
                             }
                             while (!err && fgets(buffer,200,ctl)) {
                                   if (parse(buffer))
                                      err = batch_hydra(av[0],ac > 1 ? av[1] : NULL);
                             }
                             fclose(ctl);
                          }
                          else
                             err = batch_hydra(argv[i],NULL);
                    }

                    if (!err)
                       hydra(NULL,NULL);               /* end of batch stuff */
                    hydra_deinit();
                    break;
                 }

                 if (!strncmp(argv[i],"GET",3)) {
                    init();
                    didsome = true;
                    hydra_init(hydra_options);
                    if (++i < argc) {
                       splitpath(argv[i],work,single_file);
                       if (work[0]) {
                          p = &work[((int) strlen(work)) - 1];
                          if (*p != '\\' && *p != '/' && *p != ':')
                             strcat(work,"\\");
                          download = strdup(work);
                       }
                    }
                    hydra(NULL,NULL);
                    hydra_deinit();
                    break;
                 }

                 message(1,"-Unknown commandline parameter '%s'",argv[i]);
                 i++;
              }
        }

        if (didsome) {
           if (!carrier() && dropdtr)
              dtr_out(0);
           sys_reset();
           endprog(err);
        }
        else
           cprint("Run %s without any options for usage screen\n",PRGNAME);

        if (logfp) fclose(logfp);

        exit (err);
}


void endprog (int errcode)
{
#if WIN_AGL
        if (didsome) win_deinit();
#endif
        message(1,"+%s v%s %s : end (exitcode=%d)",
                  PRGNAME,VERSION,HC_OS,errcode);
        resultlog(false,NULL,0L,0L);
        if (logfp) fclose(logfp);
        exit (errcode);
}


int config (int argc, char *argv[])
{
        register int opt = 0;
        register word temp;

        if (!strncmp(argv[0],"-P",2)) {  /* -p<port>  */
           port = atoi(&argv[0][2]);
           opt++;
        }
        else if (!strnicmp(argv[0],"-B",2)) {  /* -b<speed> */
           com_speed = (word) atol(&argv[0][2]);
           opt++;
        }
        else if (!strnicmp(argv[0],"-T",2)) {  /* -t<task> */
           opustask = atoi(&argv[0][2]);
           opt++;
        }
        else if (!strncmp(argv[0],"POR",3) && argc>=2) {  /* port */
           port = atoi(argv[1]) - 1;
           opt += 2;
        }
        else if ((!strncmp(argv[0],"SPE",3) || !strncmp(argv[0],"BAU",3)) && argc>=2) {
           com_speed = (word) atol(argv[1]);
           opt += 2;
        }
        else if (!strnicmp(argv[0],"LIN",3)) {  /* line */
           cur_speed = (word) atol(argv[1]);
           opt += 2;
        }
        else if (!strnicmp(argv[0],"MOD",3) && argc >= 6) {  /* modem */
           sscanf(argv[1],"%x",&port);
           port--;
           sscanf(argv[2],"%x",&com_speed);
           sscanf(argv[3],"%x",&flowflags);
           sscanf(argv[4],"%x",&dcdmask);
           sscanf(argv[5],"%x",&cur_speed);
           if (flowflags & 0x09)
              hydra_options |= HOPT_XONXOFF;
           opt += 6;
        }
        else if (!strncmp(argv[0],"PAR",3)) {   /* parity */
           parity = true;
           hydra_options |= HOPT_HIGHBIT;
           opt++;
        }
        else if (!strncmp(argv[0],"HAN",3) && argc >= 2) {   /* handshake */
           if      (!strncmp(argv[1],"SOF",3)) flowflags |= 0x09;
           else if (!strncmp(argv[1],"HAR",3)) flowflags |= 0x02;
           else if (!strncmp(argv[1],"BOT",3)) flowflags |= 0x0b;
           else if (!strncmp(argv[1],"NON",3)) flowflags = 0;
           if (flowflags & 0x09)
              hydra_options |= HOPT_XONXOFF;
           opt += 2;
        }
        else if (!strncmp(argv[0],"NOI",3)) {   /* noinit */
           noinit = true;
           opt++;
        }
        else if (!strncmp(argv[0],"DRO",3)) {   /* dropdtr */
           dropdtr = true;
           opt++;
        }
        else if (!strncmp(argv[0],"NOB",3)) {   /* nobell */
           nobell = true;
           opt++;
        }
        else if (!strncmp(argv[0],"MAI",3)) {   /* mailer */
           mailer = true;
           opt++;
        }
        else if (!strncmp(argv[0],"NOO",3)) {   /* nooriginator */
           nooriginator = true;
           opt++;
        }
        else if (!strncmp(argv[0],"HDX",3)) {   /* hdxlink */
           hdxsession = true;
           opt++;
        }
        else if (!strnicmp(argv[0],"TXW",3) && argc >= 2) {  /* txwindow */
           hydra_txwindow = atol(argv[1]);
           if (hydra_txwindow < 0L)
              hydra_txwindow = 0L;
           opt += 2;
        }
        else if (!strnicmp(argv[0],"RXW",3) && argc >= 2) {  /* rxwindow */
           hydra_rxwindow = atol(argv[1]);
           if (hydra_rxwindow < 0L)
              hydra_rxwindow = 0L;
           opt += 2;
        }
        else if (!strncmp(argv[0],"NOC",3)) {   /* nocarrier */
           nocarrier = true;
           opt++;
        }
        else if (!strcmp(argv[0],"LOG") && argc >= 2) {   /* log */
           if (logfp) fclose(logfp);
           logfp = sfopen(argv[1],"at",DENY_WRITE);
           if (logfp == NULL)
              message(3,"-Couldn't open log-file %s",argv[1]);
           opt += 2;
        }
        else if (!strncmp(argv[0],"LEV",3) && argc>=2) {  /* level */
           temp = atoi(argv[1]);
           if (temp >=0 && temp <= 6)
              loglevel = temp;
           else
              message(6,"-Invalid log-level %d",temp);
           opt +=2;
        }
        else if (!strncmp(argv[0],"RES",3) && argc>=2) {  /* DSZ-format log */
           if (result) free(result);
           result = strdup(argv[1]);
           opt += 2;
        }
        else if ((!strncmp(argv[0],"REC",3) || !strncmp(argv[0],"UPL",3)) && argc>=2) {
           char *p;

           strcpy(work,argv[1]);
           p = &work[((int) strlen(work)) - 1];
           if (*p != '\\' && *p != '/' && *p != ':')
              strcat(work,"\\");
           download = strdup(work);
           opt += 2;
        }
        else if (!strncmp(argv[0],"NOR",3)) {             /* noresume */
           noresume = true;
           opt++;
        }
        else if (!strncmp(argv[0],"NOS",3)) {             /* nostamp */
           nostamp = true;
           opt++;
        }
        else if (!strncmp(argv[0],"OPT",3) && argc>=2) {  /* option  */
           if      (!strcmp(argv[1],"XONXOFF")) hydra_options |= HOPT_XONXOFF;
           else if (!strcmp(argv[1],"TELENET")) hydra_options |= HOPT_TELENET;
           else if (!strcmp(argv[1],"CTLCHRS")) hydra_options |= HOPT_CTLCHRS;
           else if (!strcmp(argv[1],"HIGHCTL")) hydra_options |= HOPT_HIGHCTL;
           else if (!strcmp(argv[1],"HIGHBIT")) hydra_options |= HOPT_HIGHBIT;
           else message(6,"-Invalid link option '%s'\n",argv[1]);
           opt += 2;
        }

        return (opt);
}


void init(void)
{
        /*if (logfp) fputs("\n",logfp);*/
        message(1,"+%s v%s %s : begin",PRGNAME,VERSION,HC_OS);

        sys_init();

#if WIN_AGL
        if (!win_init(10,CUR_NORMAL,CON_ANSI|CON_WRAP|CON_SCROLL|CON_UNBLANK,
                      CHR_NORMAL,KEY_ANSI)) {
           cprint("Can't initialize window system!\n");
           exit (1);
        }
#endif

        dtr_out(1);

        if (com_speed)
           com_setspeed(com_speed);
        if (!com_speed)
           com_speed = 2400U;
        if (!cur_speed)
           cur_speed = com_speed;
}/*init()*/


int batch_hydra (char *filespec, char *alias)
{
        char  path[PATHLEN];
        char *p;
        char  doafter;
        int   fd;

        switch (*filespec) {
               case '^':
               case '#': doafter = *filespec++;
                         break;
               default:  doafter = 0;
                         break;
        }

        splitpath(filespec,path,work);
        for (p = ffirst(filespec); p; p = fnext()) {
            mergepath(work,path,p);
            switch (hydra(work,alias)) {
                   case XFER_ABORT:
                        return (1);

                   case XFER_SKIP:
                        break;

                   case XFER_OK:
                        switch (doafter) {
                               case '^':  /* Delete */
                                    if (unlink(work))
                                       message(6,"!HSEND: Could not delete %s",work);
                                    else
                                       message(1,"+Sent-H deleted %s",work);
                                    break;

                               case '#':  /* Truncate */
                                    if ((fd = dos_sopen(work,2)) < 0) {
                                       message(6,"!HSEND: Error truncating %s",work);
                                       break;
                                    }
                                    dos_close(fd);
                                    message(1,"+Sent-H truncated %s",work);
                                    break;

                               default:
                                    message(1,"+Sent-H %s",work);
                                    break;
                        }
                        break;
            }
        }

        return (0);
}/*batch_hydra()*/


void hydracom (void)
{
        static   char *hauto = "\030cA\\f5\\a3\030a";
        register char *hseek = hauto;
        register int   c, i;
        boolean  echo;
        int      mask;
        char     queue[80];
        long t;

        message(0,"+Entering terminal mode");
        queue[0] =  '\0';
        echo = false;
        mask = parity ? 0x7f : 0xff;

        do {
#if WIN_AGL
           while (!win_keyscan()) {
#else
           while (!kbhit()) {
#endif
                 if (!carrier()) {
                    cprint("\007\n");
                    message(1,"-Carrier lost, exiting (should use 'NOCarrier'?)");
                    return;
                 }

                 if ((c = com_getbyte()) != EOF) {
                    c &= mask;
                    if (c == 12)
                       cprint("\033[2J");
                    else
                       cprint("%c",c);

                    if ((c & 0x7f) == *hseek) {
                       if (!*++hseek) {
                          hseek = hauto;
                          goto autostart;
                       }
                    }
                    else hseek = hauto;
                 }
                 else
                    sys_idle();
           }/*while*/

           switch (c = get_key()) {
                  case Alt_X: break;
                  case Alt_C: cprint("\033[2J");
                              break;
                  case Alt_B: if (parity)
                                 cprint("\r**Can't toggle 8th bit strip with parity 7E1\n");
                              else {
                                 mask ^= 0x80;
                                 cprint("\r**Strip 8th bit %s\n",
                                        (mask & 0x80) ? "Off" : "On");
                              }
                              break;
                  case Alt_E: echo = !echo;
                              cprint("\r**Local echo %s\n",
                                     echo ? "On" : "Off");
                              break;
                  case Alt_H: dtr_out(0);
                              for (t = time(NULL) + 1; time(NULL) < t; );
                              dtr_out(1);
                              cprint("\r**Dropped dtr\n");
                              break;
                  case PgUp:  switch (get_str("**Send",queue,70)) {
                                     case -1: cprint("\r**Send queue cleared\n");
                                              break;
                                     case  0: cprint("\r**Send queue empty\n");
                                              break;
                                     default: cprint("\r**Queue will be sent during next session\n");
                                              break;
                              }
                              break;
                  case PgDn:
autostart:                    hydra_init(hydra_options);
                              c = 0;
                              if (parse(queue))
                                 for (i = 0; av[i] && ((c = batch_hydra(av[i],NULL)) == 0); i++);
                              if (!c) hydra(NULL,NULL);
                              hydra_deinit();
                              queue[0] = '\0';
                              cprint("\r**Finished\n");
                              break;
                  default:    if (c < 0x100) {
                                 com_putbyte((byte) c);
                                 if (echo) {
                                    cprint("%c",c);
                                    if (c == '\r') cprint("\n");
                                 }
                              }
                              break;
           }
        } while (c != Alt_X);

        cprint("\n");
        message(0,"+Exiting terminal mode");
}/*hydracom()*/

/* end of hydracom.c */
