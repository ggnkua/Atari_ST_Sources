{ Bios }

Procedure Getmpb (p_mpb : Long_Integer);
Bios(0);

Function Bconstat (dev : Integer) : Integer;
Bios(1);

Function Bconin (dev : Integer) : Integer;
Bios(2);

Procedure Bconout (dev,c : Integer);
Bios(3);

Function Rwabs (rwflag : Integer;
                buf    : Long_Integer;
                count,
                recno,
                dev    : Integer) : Long_Integer;
Bios(4);

Function Setexc (vecnum : Integer;
                 vec    : Long_Integer) : Long_Integer;
Bios(5);

Function Tickcal : Long_Integer;
Bios(6);

Function Getbpb (dev : Integer) : Long_Integer;
Bios(7);

Function Bcostat (dev : Integer) : Long_Integer;
Bios(8);

Function Mediach (dev : Integer) : Long_Integer;
Bios(9);

Function Drvmap : Long_Integer;
Bios(10);

Function Kbshift (mode : Integer) : Long_Integer;
Bios(11);

{ XBios }

Procedure Initmous (atype      : Integer;
                    params,vec : Long_Integer);
XBios(0);

Function Ssbrk (amount : Integer) : Long_Integer;
XBios(1);

Function Physbase : Long_Integer;
XBios(2);

Function Logbase : Long_Integer;
XBios(3);

Function Getrez : Integer;
XBios(4);

Procedure Setscreen (logloc,physloc : Long_Integer;
                     rez            : Integer);
XBios(5);

Procedure Setpalette (paletteptr : Long_Integer);
XBios(6);

Function Setcolor (colornum,color : Integer) : Integer;
XBios(7);

Function Floprd (buf,filler     : Long_Integer;
                 devno,sectno,
                 trackno,sideno,
                 count          : Integer) : Integer;
XBios(8);

Function Flopwr (buf,filler     : Long_Integer;
                 devno,sectno,
                 trackno,sideno,
                 count          : Integer) : Integer;
XBios(9);

Function Flopfmt (buf,filler     : Long_Integer;
                  devno,spt,
                  trackno,sideno,
                  interlv        : Integer;
                  magic          : Long_Integer;
                  virgin         : Integer) : Integer;
XBios(10);

Procedure Midiws (cnt : Integer;
                  ptr : Long_Integer);
XBios(12);

Procedure Mfpint (interno : Integer;
                  vector  : Long_Integer);
Xbios(13);

Function Iorec (devno : Integer) : Long_Integer;
Xbios(14);

Procedure Rsconf (speed,flowctl,ucr,rsr,tsr,scr : Integer);
XBios(15);

Function Keytbl (unshift,shift,capslock : Long_Integer) : Long_Integer;
XBios(16);

Function Random : Long_Integer;
XBios(17);

Procedure Protobt (buf,serialno      : Long_Integer;
                   disktype,execflag : Integer);
Xbios(18);

Function Flopver (buf,filler     : Long_Integer;
                  devno,sectno,
                  trackno,sideno,
                  count          : Integer) : Integer;
XBios(19);

Procedure Scrdmp;
XBios(20);

Function Cursonf (function,operand : Integer) : Integer;
XBios(21);

Procedure Settime (datetime : Long_Integer);
XBios(22);

Function Gettime : Long_Integer;
XBios(23);

Procedure Bioskeys;
XBios(24);

Procedure Ikbdws (cnt : Integer;
                  ptr : Long_Integer);
XBios(25);

Procedure Jdisint (intno : Integer);
XBios(26);

Procedure Jenabint (intno : Integer);
XBios(27);

Function Giaccess (data : Byte; recno : Integer) : Byte;
XBios(28);

Procedure Offgibit (bitno : Integer);
XBios(29);

Procedure Ongibit (bitno : Integer);
XBios(30);

Procedure Xbtimer (timer,control,data : Integer;
                   vec                : Long_Integer);
XBios(31);

Procedure Dosound (ptr : Long_Integer);
XBios(32);

Function Setprt (config : Integer) : Integer;
XBios(33);

Function Kbdvbase : Long_Integer;
XBios(34);

Function Kbrate (initial,rep : Integer) : Integer;
XBios(35);

Procedure Prtblk;
XBios(36);

Procedure Vsync;
XBios(37);

Procedure Supexec (codeptr : Long_Integer);
XBios(38);

Procedure Punteas;
XBios(39);

{ Gemdos }
{ System and Program Control Function Calls }

Procedure Pterm0;
Gemdos(0);

Function Super(stack : Long_Integer) : Long_Integer;
Gemdos($20);

Procedure Ssetvec (vecnum  : Integer;
                   address : Long_Integer);
Gemdos($25);

Function Sversion : Integer;
Gemdos($30);

Procedure Ptermres (n_bytes : Long_Integer;
                    rc      : Integer);
Gemdos($31);

Function Sgetvec (vecnum : Integer) : Long_Integer;
Gemdos($35);

Function Pexec (    load    : Integer;
                VAR pcspec  : CString;
                VAR pcmdln  : Str255;
                VAR penvstr : CString) : Long_Integer;
Gemdos($4B);

Procedure Pterm (code : Integer);
Gemdos($4C);

{ Character Device I/O Functions }

Function Cconin : Long_Integer;
Gemdos(1);

Procedure Cconout (c : Integer);
Gemdos(2);

Function Cauxin : Long_Integer;
Gemdos(3);

Procedure Cauxout (c : Integer);
Gemdos(4);

Procedure Cprnout (c : Integer);
Gemdos(5);

Function Crawio (parm : Integer) : Long_Integer;
Gemdos(6);

Function Crawcin : Long_Integer;
Gemdos(7);

Function Cnecin : Long_Integer;
Gemdos(8);

Procedure Cconws (Var s : CString);
Gemdos(9);

Procedure Cconrs (Var s : CString);
Gemdos($A);

Function Cconis : Long_Integer;
Gemdos($B);

Function Cconos : Long_Integer;
Gemdos($10);

Function Cprnos : Long_Integer;
Gemdos($11);

Function Cauxis : Long_Integer;
Gemdos($12);

Function Cauxos : Long_Integer;
Gemdos($13);

{ File Access Function Calls }

Procedure Fsetdta (b : Long_Integer);
Gemdos($1A);

Function Fgetdta : Long_Integer;
Gemdos($2F);

Function Fcreate (Var name : CString;
                  attr : Integer) : Integer;
Gemdos($3C);

Function Fopen (Var name : CString;
                mode : Integer) : Integer;
Gemdos($3D);

Procedure Fclose (handle : Integer);
Gemdos($3E);

Function Fread (handle      : Integer;
                cnt,pbuffer : Long_Integer) : Long_Integer;
Gemdos($3F);

Function Fwrite (handle      : Integer;
                 cnt,pbuffer : Long_Integer) : Long_Integer;
Gemdos($40);

Function Fdelete (Var name : CString) : Long_Integer;
Gemdos($41);

Function Fseek (softs        : Long_Integer;
                handle,smode : Integer) : Long_Integer;
Gemdos($42);

Function Fattrib (Var name : CString;
                  wrt,mode : Integer) : Long_Integer;
Gemdos($43);

Function Fioctl (subfun,hndrv,cntval : Integer;
                 bufptr              : Long_Integer) : Long_Integer;
Gemdos($44);

Function Fdup(stdhnd : Integer) : Integer;
Gemdos($45);

Function Fforce (stdhnd,nsthnd : Integer) : Long_Integer;
Gemdos($46);

Function Fsfirst (Var pspec : CString;
                  attr : Integer) : Long_Integer;
Gemdos($4E);

Function Fsnext : Long_Integer;
Gemdos($4F);

Function Frename (res : Integer;
                  Var p1,p2 : CString) : Long_Integer;
Gemdos($56);

Procedure Fdatime (buf    : Long_Integer;
                   h,setp : Integer);
Gemdos($57);

{ Drive and Directory Management Functions }

Procedure Dsetdrv (newdrv : Integer);
Gemdos($0E);

Function Dgetdrv : Integer;
Gemdos($19);

Function Dfree (pbuffer : Long_Integer;
                dr      : Integer) : Long_Integer;
Gemdos($36);

Function Dcreate (Var path : CString) : Long_Integer;
Gemdos($39);

Function Ddelete (Var path : CString) : Long_Integer;
Gemdos($3A);

Function Dsetpath (Var path : CString) : Long_Integer;
Gemdos($3B);

Procedure Dgetpath (Var path : CString;
                    drive : Integer);
Gemdos($47);

{ Memory Management Functions }

Function Malloc (nbytes : Long_Integer) : Long_Integer;
Gemdos($48);

Procedure Mfree (maddr : Long_Integer);
Gemdos($49);

Function Mshrink (res,mp,size : Long_Integer) : Long_Integer;
Gemdos($4A);

{ Time Functions }

Function Tgetdate : Integer;
Gemdos($2A);

Function Tsetdate (date : Integer) : Long_Integer;
Gemdos($2B);

Function Tgettime : Integer;
Gemdos($2C);

Function Tsettime (time : Integer) : Long_Integer;
Gemdos($2D);

