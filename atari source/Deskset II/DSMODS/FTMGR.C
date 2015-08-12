#include	<stdio.h>
#include	<osbind.h>
#include	<obdefs.h>
#include	<gemdefs.h>
#include	"deskset2.h"
#include	"defs.h"		/* system definitions	*/
#include	"comp.h"

#define		FALSE		0
#define		TRUE		1

#define		SFTSIZ		1548	/* single Font size	*/
#define		KDSIZ		484	/* Kern data (121 * 4)	*/
#define		KPSIZ		768	/* Kern pair (256 * 3)	*/

#define		CFNOFS		2	/* Comp/Face # offset	*/
#define		TFNOFS		15	/* TpFace Name offset	*/
#define		ACCOFS		35	/* Avcc flag   offset	*/
#define		KRNOFS		36	/* Kern flag   offset	*/
#define		SKROFS		293	/* Std. Kern   offset	*/
#define		KPCOFS		777	/* Kpair count offset	*/
#define		DKROFS		1549	/* Des. Kern   offset	*/

#define		SKRset		2	/* Std. Kern bit (2)	*/
#define		DKRset		4	/* Des. Kern bit (3)	*/
#define		UKRset		8	/* User Kern bit (4)	*/

extern	char		*get_fp(), *malloc();
extern	unsigned char	ptsfpos[];
extern	int		grvint();
extern	char		fs_iinsel[];

struct	dll_type {		/* doubly linked list structure	*/
	struct dll_type *fptr;		/* forward pointer	*/
	struct dll_type *bptr;		/* backward pointer	*/
};
extern	struct	fnt_entry {	/* font index entry definition	*/
struct	dll_type link;		/* forward/backward linkages	*/
	int	fnt_id;		/* font id (1-9999)		*/ 
	char	fnt_name[100];	/* path\filename of font file	*/              
	int	rep_id;		/* representative font id	*/
	int	rep_pix;	/* pixel size for rep. font	*/
}	*fst_idx,		/* pointer to first	entry	*/
	*get_entry(),		/* get ptr to entry from UFID	*/
	*add_entry();		/* add new entry to index list	*/

char		nuls[] = "";		/* null string		*/
char		sccex[] = ".SCC";	/* font file  extension	*/
char		idxex[] = ".IDX";	/* font index extension	*/
char		fntdrs[100] = {0};	/* font dress filepath	*/
char		fntidx[100] = {0};	/* font index filepath	*/

char		widpath[100];		/* font WID path	*/
unsigned char	fpascii[118];		/* Fpos to Ascii table	*/
char		knbuf[64][10];		/* kern pair buffers	*/
unsigned	formval;		/* dialog form value	*/
char		*ysms, *noms, *kdms1, *kdms2;

/*
	Typeface/Font menu handler
*/
Fnt_cmd(ch,drsfile)
char	ch, *drsfile;
{
	char	fid[16][6], ukct[16][4];
	char	fidofs, *fidp, *fntp;
	int	dkx, dky, dkw, dkh;
	int	exobj, ftmod, fpmod, newdrs, ifid, err;
	struct	fnt_entry *idxp;
	OBJECT	*ftmenu, *dialog;

	rsrc_gaddr(R_STRING,YSMS,&ysms);
	rsrc_gaddr(R_STRING,NOMS,&noms);
	rsrc_gaddr(R_STRING,KDMS1,&kdms1);
	rsrc_gaddr(R_STRING,KDMS2,&kdms2);
	if (ch == 'D') {
	  if (!ftin)
		do_alert(NFONT);
	  else {
		rsrc_gaddr(0,FONTMAN,&ftmenu);
		ftmenu[FTADD].ob_state	= DISABLED;
		ftmenu[FTDEL].ob_state	= DISABLED;
		ftmenu[FTNPA].ob_state	= DISABLED;
		ftmenu[FTNID].ob_state	= DISABLED;
		ftmenu[FTKCOP].ob_state	= DISABLED;
		ftmenu[FTKMOD].ob_state	= DISABLED;
		ftmenu[FTKDEL].ob_state	= DISABLED;
		dsp_fnt(0,ftmenu,fid,ukct);
		ftmenu[execform(ftmenu,0)].ob_state = NORMAL;
	  }
	}
	else
	if (ch == 'L') {
		if (!ld_dress(drsfile,1)) {
			rsrc_gaddr(0,FTCREAT,&dialog);
			dialog[FTCFN].ob_spec	= (long)drsfile;
			exobj = execform(dialog,0);
			dialog[exobj].ob_state = NORMAL;
			if (exobj == FTCOK) {
			  memset(ftlib,0,FTSIZ);
			  strcpy(fntdrs,drsfile);
			  IF_close();
			  IF_open(1);
			  *fntidx = 0;
			  ftin	  = false;
			  newdrs  = true;
			  goto mdf;
			}
			else	return(0);
		}
		return(1);
	}
	else
	if (ch == 'M') {
		newdrs = false;
mdf:		ftmod = fpmod = false;
		rsrc_gaddr(R_TREE,FONTMAN,&ftmenu);
		ftmenu[FTDEL].ob_state	= !IFerr ? NORMAL:DISABLED;
		ftmenu[FTNPA].ob_state	= !IFerr ? NORMAL:DISABLED;
		ftmenu[FTNID].ob_state	= !IFerr ? NORMAL:DISABLED;
		ftmenu[FTKCOP].ob_state	= NORMAL;
		ftmenu[FTKMOD].ob_state	= NORMAL;
		ftmenu[FTKDEL].ob_state	= NORMAL;
		form_center(ftmenu,&dkx,&dky,&dkw,&dkh);
		form_dial(0,0,0,0,0,dkx,dky,dkw,dkh);
		form_dial(1,0,0,0,0,dkx,dky,dkw,dkh);
		do {
		  dsp_fnt(1,ftmenu,fid,ukct);
		  objc_draw(ftmenu,0,10,dkx,dky,dkw,dkh);
		  exobj = form_do(ftmenu,0);
		  if (exobj != FTOK && exobj != FTADD &&
		     !whichSEL(ftmenu,&fidofs,FID1,FID16))
			do_alert(SFNMS);
		  else {
		    fntp = ftlib + (fidofs * SFTSIZ);
		    fidp = fid[fidofs];
		    switch(exobj) {
		    case FTADD:
			form_dial(2,0,0,0,0,dkx,dky,dkw,dkh);
			form_dial(3,0,0,0,0,dkx,dky,dkw,dkh);
			BWredraw();			/* redraw TW/PW	*/
			if (addfont())
				ftmod = fpmod = true;
			break;
		    case FTDEL:
			if (idxp = get_entry(*(int *)fntp))
				del_entry(idxp);
			f_move(fntp+SFTSIZ,fntp,(15 - fidofs) * SFTSIZ);
			memset(ftlib+FTSIZ-SFTSIZ,0,SFTSIZ);
			ftmod = fpmod = true;
			break;
		    case FTNPA:
			if (npafont(fntp,fidp))
				fpmod = true;
			break;
		    case FTNID:
			if (nidfont(fntp,fidp))
				ftmod = fpmod = true;
			break;
		    case FTKCOP:
			if (copykrnpr(fntp,fidp))
				ftmod = true;
			break;
		    case FTKMOD:
			if (modkrnpr(	fntp,ftmenu[FTF1+fidofs].ob_spec,
					fidp,ftmenu[FKRN1+fidofs].ob_spec  ))
				ftmod = true;
			break;
		    case FTKDEL:
			*(fntp+KRNOFS) &= ~UKRset;	/* No user kern	*/
			memset(fntp+KPCOFS,0,KPSIZ+2);
			ftmod = true;
			break;
		    }
		  }
		  ftmenu[exobj].ob_state = NORMAL;
		} while (exobj != FTOK);
		form_dial(2,0,0,0,0,dkx,dky,dkw,dkh);
		form_dial(3,0,0,0,0,dkx,dky,dkw,dkh);
		BWredraw();				/* redraw TW/PW	*/
		if (ftmod) {
		  exobj = do_alert(FONTSAVE);
		  if (exobj == 3) {
			if (gdosfname(drsfile,0,0)) {
				strcpy(fntdrs,drsfile);
				fpmod = true;
				exobj = 1;
			}
			else	fpmod = false;
		  }
		  if (exobj == 1) {
			err = 0;
			if ((ifid = creat(drsfile,NWFIL)) < 0) ++err;
			else {
				if (write(ifid,ftlib,FTSIZ) < 0) ++err;
				close(ifid);
			}
			if (err) setnfd(fntdrs,3);
		  }
		  setftin();
		}
		if (fpmod) {
		  setidxf(drsfile);
		  if (newdrs || do_alert(FIDSAVE) == 1)
			writeftidx();
		}
		if (newdrs && !ftmod && !fpmod) {
			setp.ftdrs[0] = *fntdrs = 0;
			return(0);
		}
		return(1);
	}
}

/*
	Load Font Dress file
*/
ld_dress(drsfile,mod)
char *drsfile;
int mod;
{
	char	*drsbuf, fpath[100];
	int	fid;
	int	err = 0;

	if (mod)				/* setup Dress path	*/
		strcpy(fpath,drsfile);
	else	findfile(drsfile,fpath);
	if (!strcmp(fntdrs,fpath))		/* same as current...	*/
		goto done;
	if (!(drsbuf = malloc(FTSIZ))) {	/* get Dress buffer	*/
		do_alert(DRLDERR);
		err = 3;
	}
	else
	if ((fid = open(fpath,FREAD)) <= 0)
		setnfd(drsfile,err = 1);
	else
	if (read(fid,drsbuf,FTSIZ) != FTSIZ)
		setnfd(drsfile,err = 2);
	else {
		f_move(drsbuf,ftlib,FTSIZ);
		setftin();
		strcpy(fntdrs,fpath);
		setidxf(fpath);
		IF_close();
		IF_open(0);
	}
	if (fid > 0) close(fid);
	if (drsbuf) free(drsbuf);
done:	return(!err);
}

dsp_fnt(mod,ftbx,fid,ukct)
int	mod;
OBJECT	*ftbx;
char	fid[16][6], ukct[16][4];
{
	char	*ftp, krn;
	int	i, *ftn, free;

	free = false;
	for	(ftn = (int *)ftlib,ftp = ftlib,i = 0;
		i < 16;
		ftn += (SFTSIZ / 2),ftp += SFTSIZ,++i)
	if (*ftn) {
		ftbx[FID1+i].ob_state	= mod ? NORMAL:DISABLED;
		utoa(fid[i],*ftn,1000);
		ftbx[FID1+i].ob_spec	= (long)fid[i];
		ftbx[FCF1+i].ob_spec	= (long)(ftp+CFNOFS);
		ftbx[FTF1+i].ob_spec	= (long)(ftp+TFNOFS);
		ftbx[FCC1+i].ob_spec	= (long)((*(ftp+ACCOFS) & 1)
						? ysms:noms);
		krn = *(ftp+KRNOFS) & 14;
		if (krn & SKRset)
			ftbx[FKRN1+i].ob_spec	= (long)kdms1;
		else
		if (krn & DKRset)
			ftbx[FKRN1+i].ob_spec	= (long)kdms2;
		else	ftbx[FKRN1+i].ob_spec	= (long)noms;
		if (krn & UKRset) {
			utoa(ukct[i],get_argument(ftp+KPCOFS),100);
			ftbx[FUK1+i].ob_spec	= (long)ukct[i];
		}
		else	ftbx[FUK1+i].ob_spec	= (long)noms;
	}
	else {
		ftbx[FID1+i].ob_state	= DISABLED;
		ftbx[FID1+i].ob_spec	= (long)nuls;
		ftbx[FCF1+i].ob_spec	= (long)nuls;
		ftbx[FTF1+i].ob_spec	= (long)nuls;
		ftbx[FCC1+i].ob_spec	= (long)nuls;
		ftbx[FKRN1+i].ob_spec	= (long)nuls;
		ftbx[FUK1+i].ob_spec	= (long)nuls;
		free = true;
	}
	if (mod)
		ftbx[FTADD].ob_state	= (free && !IFerr) ? NORMAL:DISABLED;
}

addfont()
{
	char	npath[100], idbuf[6], fc[8], ff[8];
	int	ifid, ufid, done, exobj;
	char	*fbuf, krn, *nftp;
	struct	fnt_entry *idxp;
	OBJECT	*dialog;

	done = false;
	if (gdosfname(npath,3,1)) {
	  fbuf	= malloc(SFTSIZ+KDSIZ);		/* get Font buffer	*/
	  ifid	= -1;
	  if  (	!fbuf	||
		(ifid = open(npath,FREAD))	<= 0 ||
		read(ifid,fbuf,SFTSIZ+KDSIZ)	<= 0 )
		setnfd(fs_iinsel,2);
	  else {
		f_move(fbuf+CFNOFS  ,fc,6);	fc[6] = 0;
		f_move(fbuf+CFNOFS+6,ff,6);	ff[6] = 0;
		idbuf[0] = 0;
		strunc(npath);	strcat(npath,sccex);
		rsrc_gaddr(R_TREE,FONTADD,&dialog);
		((TEDINFO *)dialog[FTPATH2].ob_spec)->te_ptext	= npath;
		((TEDINFO *)dialog[FADDID].ob_spec)->te_ptext	= idbuf;
		dialog[FADDFC].ob_spec	= (long)fc;
		dialog[FADDFF].ob_spec	= (long)ff;
		dialog[FADDFN].ob_spec	= (long)(fbuf+TFNOFS);
		dialog[FADDCC].ob_spec	= (long)((*(fbuf+ACCOFS) & 1)
						? ysms:noms);
		krn = *(fbuf+KRNOFS) & 6;
		if (krn & SKRset) {
			dialog[FADDNK].ob_state = DISABLED;
			dialog[FADDSK].ob_state = SELECTED;
			dialog[FADDDK].ob_state = (krn & DKRset)
						? NORMAL:DISABLED;
		}
		else
		if (krn & DKRset) {
			dialog[FADDNK].ob_state = DISABLED;
			dialog[FADDSK].ob_state = DISABLED;
			dialog[FADDDK].ob_state = SELECTED;
		}
		else {
			dialog[FADDNK].ob_state = SELECTED;
			dialog[FADDSK].ob_state = DISABLED;
			dialog[FADDDK].ob_state = DISABLED;
		}
		formval = 0;
		dial1(dialog);
		do {
		  exobj = dial2(dialog);
		  if (exobj == FADDOK) {
			if (access(npath,0)) {
				formval = FTPATH2;
err:				do_alert(BADINP);
				continue;
			}
			ufid = *idbuf ? atoi(idbuf):0;
			if (ufid && !get_fp(ufid) && !get_entry(ufid)) {
			  if (!(idxp = add_entry(fst_idx))) {
				do_alert(NFNTERR);
				break;
			  }
			  strcpy(idxp->fnt_name,npath);
			  idxp->rep_id	= idxp->rep_pix = 0;
			  idxp->fnt_id	= ufid;
			  *(int *)fbuf	= ufid;
			  nftp = get_fp(0);
			  if (krn == 6) {
			    if (dialog[FADDDK].ob_state & SELECTED) {
				 f_move(fbuf+DKROFS,fbuf+SKROFS,KDSIZ);
				 *(fbuf+KRNOFS) &= ~SKRset;
			    }
			    else *(fbuf+KRNOFS) &= ~DKRset;
			  }
					/* swap Reverse Video values..	*/
			  sav_argument(fbuf+45,grvint(fbuf+45));
			  sav_argument(fbuf+47,grvint(fbuf+47));
			  sav_argument(fbuf+49,grvint(fbuf+49));
					/* save Font to dress buffer..	*/
			  f_move(fbuf,nftp,SFTSIZ);
			  done = true;
			}
			else {
				formval = FADDID;
				goto err;
			}
			break;
		  }
		} while (exobj != FADDNOK);
		dial3();
	  }
	  if (ifid > 0) close(ifid);
	  if (fbuf) free(fbuf);
	}
	return(done);
}

npafont(fntp,fidp)
char	*fntp, *fidp;
{
	struct	fnt_entry *idxp;
	int	done;
	char	npath[100];
	OBJECT	*dialog;
	int	exobj;

	if (!(idxp = get_entry(*(int *)fntp)))
		return(0);
	strcpy(npath,idxp->fnt_name);

	rsrc_gaddr(R_TREE,FNWPA,&dialog);
	dialog[FNPAID].ob_spec	= (long)fidp;
	((TEDINFO *)dialog[FTPATH1].ob_spec)->te_ptext = npath;
	done = false;
	formval = 0;
	dial1(dialog);
	if ((exobj = dial2(dialog)) == FNPAOK) {
		if (!access(npath,0)) {
			strcpy(idxp->fnt_name,npath);
			done = true;
		}
		else	do_alert(BADINP);
	}
	dial3();
	return(done);
}

nidfont(fntp,fidp)
char	*fntp, *fidp;
{
	struct	fnt_entry *idxp;
	char	idbuf[6];
	int	nfid, ofid, done;
	OBJECT	*dialog;
	int	exobj;

	ofid = *(int *)fntp;
	if (!(idxp = get_entry(ofid)))
		return(0);
	rsrc_gaddr(R_TREE,FNWID,&dialog);
	dialog[OFID].ob_spec	= (long)fidp;
	((TEDINFO *)dialog[NWID].ob_spec)->te_ptext = idbuf;
	idbuf[0] = 0;
	done = false;
	formval = 0;
	dial1(dialog);
	if ((exobj = dial2(dialog)) == FNIDOK &&
	     *idbuf && (nfid = atoi(idbuf)) != ofid) {
		if (nfid && !get_fp(nfid) && !get_entry(nfid)) {
			idxp->fnt_id	= nfid;
			*(int *)fntp	= nfid;
			done = true;
		}
		else	do_alert(BADINP);
	}
	dial3();
	return(done);
}

modkrnpr(krnp,fnmp,fidp,fktp)
char	*krnp, *fnmp, *fidp, *fktp;
{
	char	ctbuf[64][4];
	int	i, j, k, exit_val, cnt;
	int	kpmod;
	char	*kpsave, *knptr, *ptr, buf[4];
	OBJECT	*dialog;

	rsrc_gaddr(R_TREE,KERNPAIR,&dialog);
	dialog[KPFNM].ob_spec	= (long)fnmp;
	dialog[KPFID].ob_spec	= (long)fidp;
	dialog[KPFKT].ob_spec	= (long)fktp;
	for (i = 0,j = KPN1,k = KPR1;i < 64;++i,++j,++k) {
	  dialog[j].ob_spec	= (long)ctbuf[i];
	  ((TEDINFO *)dialog[k].ob_spec)->te_ptext = knbuf[i];
	}
	dialog[KPPRV].ob_state	= DISABLED;
	dialog[KPNXT].ob_state	= NORMAL;
	krnp	+= (KPCOFS+2);
	knptr	= krnp;
	cnt	= 1;			/* start at 1, go 65..129..193	*/
	kpmod	= false;
	if (!(kpsave = malloc(KPSIZ)))		/* get save Kp buffer	*/
		do_alert(MKRNERR);
	else {
	  f_move(krnp,kpsave,KPSIZ);
	  formval = 0;
	  dial1(dialog);
	  do {
		for (i = 0,k = cnt,ptr = knptr;i < 64;++i,++k) {
			utoa(ctbuf[i],k,100);
			if (*ptr) {
			  buf[3] = 0;
			  gkrn_ch(*(ptr++),buf);
			  strcpy(knbuf[i],buf);
			  gkrn_ch(*(ptr++),buf);
			  strcat(knbuf[i],buf);
			  gkrn_val(*(ptr++),buf);
			  strcat(knbuf[i],buf);
			}
			else {
			  knbuf[i][0] = 0;
			  ptr += 3;
			}
		}
di:		exit_val = dial2(dialog);
		switch (exit_val) {
		case KPNXT:
			if (save_knval(krnp,knptr)) goto di;
			if (cnt < 256) {
			  cnt   += 64;
			  knptr += 192;
			}
			break;
		case KPPRV:
			if (save_knval(krnp,knptr)) goto di;
			if (cnt > 64) {
			  cnt   -= 64;
			  knptr -= 192;
			}
			break;
		case KPOK:
			if (save_knval(krnp,knptr)) goto di;
			kpmod = memcmp(kpsave,krnp,KPSIZ);
			break;
		case KPNOK:
			f_move(kpsave,krnp,KPSIZ);
			break;
		}
		dialog[exit_val].ob_state &= ~SELECTED;
		if (cnt > 1)
			dialog[KPPRV].ob_state &= ~DISABLED;
		else	dialog[KPPRV].ob_state |= DISABLED;
		if (cnt < 193)
			dialog[KPNXT].ob_state &= ~DISABLED;
		else	dialog[KPNXT].ob_state |= DISABLED;
	  } while (exit_val != KPOK && exit_val != KPNOK);
	  dial3();
	  BWredraw();				/* redraw TW/PW	*/
	  free(kpsave);
	}
	return(kpmod);
}

copykrnpr(srcptr,fidp)
char	*srcptr, *fidp;
{
	char	destbuf[6], *destptr;
	int	destid, done;
	OBJECT	*dialog;
	int	exobj;

	rsrc_gaddr(R_TREE,FKCOPY,&dialog);
	dialog[FKCPOID].ob_spec	= (long)fidp;
	((TEDINFO *)dialog[FKCPNID].ob_spec)->te_ptext = destbuf;
	destbuf[0] = 0;
	done = false;
	formval = 0;
	dial1(dialog);
	if ((exobj = dial2(dialog)) == FKCPOK && *destbuf) {
		destid = atoi(destbuf);
		if (destid && (destptr = get_fp(destid))) {
		  f_move(srcptr+KPCOFS,destptr+KPCOFS,KPSIZ+2);
		  if (*(srcptr+KRNOFS) & UKRset)	/* Kpairs ?	*/
			*(destptr+KRNOFS) |=  UKRset;	/* ok bit 3 on	*/
		  else	*(destptr+KRNOFS) &= ~UKRset;	/* no bit 3 off	*/
		  done = true;
		}
		else	do_alert(BADINP);
	}
	dial3();
	return(done);
}

bld_flash()
{
	int	i;
	memset(fpascii,0xff,118);
	for (i = 0;i < 256;++i)
		if (ptsfpos[i] < 0xfe) fpascii[ ptsfpos[i]-1 ] = i;
}

char	*get_fp(ftid)
int	ftid;
{
	int	i, *ftn;

	for (ftn = (int *)ftlib,i = 0;i < 16;ftn += (SFTSIZ / 2),++i)
		if (*ftn == ftid) return((char *)ftn);
	return(0L);
}


gkrn_ch(fp,buf)
char	fp, *buf;
{
	unsigned char 	c;
	
	if ((c = fpascii[fp-1]) == 0xff)
		utoa(buf,fp,100);
	else {
		*buf++ = c;
		strcpy(buf,"  ");
	}
}

gkrn_val(val,buf)
char	val, *buf;
{
	if (val < 0) {
		buf[0] = '-';
		val = ~val + 1;
	}
	else	buf[0] = '+';
	utoa(buf+1,val,10);
}

save_knval(krnp,knptr)
char	*krnp, *knptr;
{
	int	i, j, krncnt;
	char	*ptr;

	for (i = 0;i < 64;++i) {
		if (form_krnbuf(knbuf[i],knptr)) {
			do_alert(BADINP);
			formval = KPR1 + i;
			return(1);
		}
		if (knbuf[i][0])
			knptr += 3;
		else	*knptr = *(knptr+1) = *(knptr+2) = 0;
	}
	krncnt = 0;
	for (i = 0,ptr = knptr = krnp;i < 256;++i) {
		if (*ptr && *(ptr+1)) {
			++krncnt;
			if (ptr != knptr)
			for (j = 0;j < 3;++j) {
				*knptr++ = *ptr;
				*ptr++	 = 0;
			}
			else {
				knptr	+= 3;
				ptr	+= 3;
			}
		}
		else	ptr += 3;
	}
	while (knptr <= ptr) *knptr++ = 0;
	sav_argument(krnp-2,krncnt);
	krnp	-= 743;
	if (krncnt)					/* Kpairs ?	*/
		*krnp |=  UKRset;			/* ok bit 3 on	*/
	else	*krnp &= ~UKRset;			/* no bit 3 off	*/
	return(0);
}

form_krnbuf(sbuf,kbuf)
char	*sbuf, *kbuf;
{
	char	buf[4];

	if (*sbuf) {
		buf[3] = 0;
		strncpy(buf,sbuf,3);
		if (form_knch(buf,kbuf)) return(1);
		strncpy(buf,sbuf+3,3);
		if (form_knch(buf,kbuf+1)) return(1);
		strncpy(buf,sbuf+6,3);
		if (form_knval(buf,kbuf+2)) return(1);
	}
	return(0);
}

form_knch(sbuf,kbuf)
char	*sbuf, *kbuf;
{
	char	fp, erf = 0;

	if (*(sbuf+1) == ' ' && *(sbuf+2) == ' ') {
		if ((*kbuf = ptsfpos[*sbuf]) == 0xff)
		   erf = 1;
	}
	else {
		if (digitbuf(sbuf) &&
		   (fp = atoi(sbuf)) < 122 &&
		    fp > 0)
			*kbuf = fp;
		else	erf = 1;
	}
	return(erf);
}

form_knval(sbuf,kbuf)
char	*sbuf, *kbuf;
{
	char val = 0, fg = 1, erf = 0;

	if (*sbuf) {
		if (*(sbuf) == '-') {
			fg = -1;
			++sbuf;
		}
		else
		if (*(sbuf) == '+')
			++sbuf;
		if (!digitbuf(sbuf) ||
		   (val = atoi(sbuf)) > 32)
			erf = 1;
		else	val *= fg;
	}
	*kbuf = val;
	return(erf);
}

sav_argument(valp,value)
unsigned char	*valp;
unsigned	value;
{
	union {
	unsigned char	byt[2];
	unsigned	val;
	} w;
	w.val	= value;
	*valp++	= w.byt[0],
	*valp	= w.byt[1];
}

digitbuf(buf)
char	*buf;
{
	while (*buf)
		if (!cdigit(*buf++)) return(0);
	return(1);
}

/*
	Write out new Font Dress index file
*/
writeftidx()
{
	struct	fnt_entry *idxp;
	FILE	*utf;

	setidxf(fntdrs);
	if (!(utf = fopen(fntidx,"w")))		/* Open font idx file	*/
		setnfd(fntidx,3);
	else
	if (fst_idx) for (idxp = fst_idx; ;) {
	  if (idxp->fnt_id)
	    fprintf(utf,"%04d %s %04d %d\n",	/* Write each entry...	*/
		idxp->fnt_id,			/* font id (1-9999)	*/
		idxp->fnt_name,			/* font path\filename	*/
		idxp->rep_id,			/* rep. font id		*/
		idxp->rep_pix);			/* pix. size for rep.	*/
	  if ((struct fnt_entry *)idxp->link.fptr == fst_idx)
		break;
	  else	idxp = (struct fnt_entry *)idxp->link.fptr;
	}
	if (utf) fclose(utf);			/* Close font idx file	*/
}

setidxf(drsfile)
char	*drsfile;
{
	strcpy(fntidx,drsfile);
	strunc(fntidx);
	strcat(fntidx,idxex);
}

setftin()
{
	ftin	= true;
	pftpt	= ftlib;		/* reset font pointer	*/
}

IF_close()
{
	if (!(IFerr & 4)) fm_close();
}

IF_open(mod)
int	mod;
{
	if (!(IFerr & 3)) {
	  if (initftsys(mod)) {		/* setup Intellifont	*/
		do_alert(PMS0);
		IFerr |= 4;
	  }
	  else {
		IFerr &= ~4;
		if (fst_idx) {
			strcpy(widpath,fst_idx->fnt_name);
			filetopath(widpath);
		}
	  }
	}
}

grvint(ptr)
unsigned char	*ptr;
{
	unsigned wrd;
	wrd	= *(ptr+1);
	wrd	<<= 8;
	wrd	&= 0xff00;
	wrd	|= *ptr;
	return(wrd);
}

ckfont(ID)
int	ID;
{
	unsigned char	*ftp;

	if (ftp = get_fp(ID)) {
		pftpt = ftp;
		loadavcc();
		ldacmp();
		if (avcval) avcval = acmp;
		return(1);
	}
	else	return(0);
}
