/*
 *	OSBIND.H	Mnemonic names for operating system calls
 *
 * Adapted from Dale Schumacher's version to Mark Johnson C by Eric Gisin.
 */

/* hacked by jrd for GNU */

/*	
 *	GEMDOS	(trap1)
 */
#define	Pterm0()			trap_1_wlww(0x00)
#define	Cconin()			trap_1_wlww(0x01)
#define	Cconout(c)			trap_1_wwlll(0x02,c)
#define	Cauxin()			trap_1_wlww(0x03)
#define	Cauxout(c)			trap_1_wwlll(0x04,c)
#define	Cprnout(c)			trap_1_wwlll(0x05,c)
#define	Crawio(data)			trap_1_wwlll(0x06,data)
#define	Crawcin()			trap_1_wlww(0x07)
#define	Cnecin()			trap_1_wlww(0x08)
#define	Cconws(s)			trap_1_wlww(0x09,s)
#define	Cconrs(buf)			trap_1_wlww(0x0A,buf)
#define	Cconis()			(int)trap_1_wlww(0x0B)
#define	Dsetdrv(d)			trap_1_wlww(0x0E,d)
#define	Cconos()			trap_1_wlww(0x10)
#define	Cprnos()			trap_1_wlww(0x11)
#define	Cauxis()			trap_1_wlww(0x12)
#define	Cauxos()			trap_1_wlww(0x13)
#define	Dgetdrv()			(int)trap_1_wlww(0x19)
#define	Fsetdta(dta)			trap_1_wlww(0x1A,dta)
#define	Super(ptr)			trap_1_wlww(0x20,ptr)
#define	Tgetdate()			(int)trap_1_wlww(0x2A)
#define	Tsetdate(date)			trap_1_wlww(0x2B,date)
#define	Tgettime()			(int)trap_1_wlww(0x2C)
#define	Tsettime(time)			trap_1_wlww(0x2D,time)
#define	Fgetdta()			trap_1_wlww(0x2F)
#define	Sversion()			(int)trap_1_wlww(0x30)
#define	Ptermres(save,rv)		trap_1_wlww(0x31,save,rv)
#define	Dfree(buf,d)			trap_1_wlww(0x36,buf,d)
#define	Dcreate(path)			trap_1_wlww(0x39,path)
#define	Ddelete(path)			trap_1_wlww(0x3A,path)
#define	Dsetpath(path)			trap_1_wlww(0x3B,path)
#define	Fcreate(fn,mode)		trap_1_wlww(0x3C,fn,mode)
#define	Fopen(fn,mode)			trap_1_wlww(0x3D,fn,mode)
#define	Fclose(H)			trap_1_wwlll(0x3E,H)
#define	Fread(H,cnt,buf)		trap_1_wwlll(0x3F,H,cnt,buf)
#define	Fwrite(H,cnt,buf)		trap_1_wwlll(0x40,H,cnt,buf)
#define	Fdelete(fn)			trap_1_wlww(0x41,fn)
#define	Fseek(where,H,how)		trap_1_wlww(0x42,where,H,how)
#define	Fattrib(fn,rwflag,attr)		trap_1_wlww(0x43,fn,rwflag,attr)
#define	Fdup(H)				trap_1_wwlll(0x45,H)
#define	Fforce(Hstd,Hnew)		trap_1_wlww(0x46,Hstd,Hnew)
#define	Dgetpath(buf,d)			trap_1_wlww(0x47,buf,d)
#define	Malloc(size)			trap_1_wlww(0x48,size)
#define	Mfree(ptr)			trap_1_wlww(0x49,ptr)
#define	Mshrink(ptr,size)		trap_1_wwlll(0x4A,0,ptr,size)
#define	Pexec(mode,prog,tail,env)	trap_1_wwlll(0x4B,mode,prog,tail,env)
#define	Pterm(rv)			trap_1_wlww(0x4C,rv)
#define	Fsfirst(filespec,attr)		(int)trap_1_wlww(0x4E,filespec,attr)
#define	Fsnext()			(int)trap_1_wlww(0x4F)
#define	Frename(zero,old,new)		trap_1_wwlll(0x56,zero,old,new)
#define	Fdatime(timeptr,H,rwflag)	trap_1_wlww(0x57,timeptr,H,rwflag)

/* codes for Pexec */

#define	PE_LOADGO		0		/* load & go */
#define	PE_LOAD			1		/* just load */
#define	PE_CBASEPAGE		2		/* just create basepage */
#define	PE_GO			3		/* just go */

/* zzz do the rest later */

/*
 *	BIOS	(trap13)
 */
#define	Bconstat(DEV)			trap_13_www(1,DEV)
#define	Bconin(DEV)			trap_13_www(2,DEV)
#define	Bconout(DEV,c)			trap_13_www(3,DEV,((c) & 0xFF))
/* this one's busted */
#define	Rwabs(rwflag,buf,n,sector,d)	trap_13_wwl(4,rwflag,buf,n,sector,d)
#define	Setexc(vnum,vptr)		trap_13_wwl(5,vnum,vptr)
#define	Tickcal()			trap_13_www(6)
#define	Getbpb(d)			trap_13_www(7,d)
#define	Bcostat(DEV)			trap_13_www(8,DEV)
#define	Mediach(d)			trap_13_www(9,a)
#define	Drvmap()			trap_13_www(10)
#define	Getshift()			trap_13_www(11,-1)
#define	Kbshift(data)			trap_13_www(11,data)

/*
 *	XBIOS	(trap14)
 */
#define	Initmous(type,param,vptr)	trap_14_wwll(0,type,param,vptr)
#define	Physbase()			trap_14_wwll(2)
#define	Logbase()			trap_14_wwll(3)
#define	Getrez()			(int)trap_14_wwll(4)
#define	Setscreen(lscrn,pscrn,rez)	trap_14_wllw(5,lscrn,pscrn,rez)
#define	Setpallete(palptr)		trap_14_wllw(6,palptr)
#define	Setcolor(colornum,mixture)	trap_14_wwll(7,colornum,mixture)
#define	Floprd(buf,x,d,sect,trk,side,n)	trap(14,8,buf,x,d,sect,trk,side,n)
#define	Flopwr(buf,x,d,sect,trk,side,n)	trap(14,9,buf,x,d,sect,trk,side,n)
#define	Flopfmt(b,x,d,spt,trk,sd,i,m,v)	trap(14,10,b,x,d,spt,trk,sd,i,m,v)
#define	Midiws(cnt,ptr)			trap(14,12,cnt,ptr)
#define	Mfpint(vnum,vptr)		trap(14,13,vnum,vptr)
#define	Iorec(ioDEV)			trap_14_wwll(14,ioDEV)
#define	Rsconf(baud,flow,uc,rs,ts,sc)	trap(14,15,baud,flow,uc,rs,ts,sc)
#define	Keytbl(nrml,shft,caps)		trap_14_wlll(16,nrml,shft,caps)
#define	Random()			trap_14_wwll(14,17)
#define	Protobt(buf,serial,dsktyp,exec)	trap(14,18,buf,serial,dsktyp,exec)
#define	Flopver(buf,x,d,sect,trk,sd,n)	trap(14,19,buf,x,d,sect,trk,sd,n)
#define	Scrdmp()			trap_14_wwll(20)
#define	Cursconf(func,rate)		trap_14_www(21,func,rate)
#define	Settime(time)			trap_14_wllw(22,time)
#define	Gettime()			trap_14_www(23)
#define	Bioskeys()			trap_14_www(24)
#define	Ikbdws(len_minus1,ptr)		trap_14_wwll(25,len_minus1,ptr)
#define	Jdisint(vnum)			trap_14_www(26,vnum)
#define	Jenabint(vnum)			trap_14_www(27,vnum)
#define	Giaccess(data,reg)		trap(14,28,data,reg)
#define	Offgibit(ormask)		trap(14,29,ormask)
#define	Ongibit(andmask)		trap(14,30,andmask)
#define	Xbtimer(timer,ctrl,data,vnum)	trap(14,31,timer,ctrl,data,vnum)
#define	Dosound(ptr)			trap(14,32,ptr)
#define	Setprt(config)			trap(14,33,config)
#define	Kbdvbase()			trap_14_www(34)
#define	Kbrate(delay,reprate)		trap_14_www(35,delay,reprate)
#define	Prtblk(pblkptr)			trap(14,36,pblkptr)
#define	Vsync()				trap_14_www(37)
#define	Supexec(funcptr)		trap_14_wllw(38,funcptr)
