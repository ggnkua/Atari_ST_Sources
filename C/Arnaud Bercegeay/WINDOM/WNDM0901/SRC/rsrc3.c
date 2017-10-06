/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: rsrc2.c
 *	description: ressource 
 */

#include <stddef.h>
#include <stdlib.h>
#ifdef __PUREC__
#include <tos.h>
#endif
#include <string.h>
#include "globals.h"
#include "cicon.h"

#ifndef FO_READ
#define FO_READ 0
#endif

/*******************************************************************************
	RSC header and support struct
*******************************************************************************/

typedef struct {		/* fichier ressource ‚tendu */
  UWORD rsh_vrsn;			/* should be 3														     */
  UWORD rsh_extvrsn;		/* not used, initialised to 'IN' for Interface */
  ULONG rsh_object;
  ULONG rsh_tedinfo;
  ULONG rsh_iconblk; 		/* list of ICONBLKS			  				 	*/
  ULONG rsh_bitblk;
  ULONG rsh_frstr;
  ULONG rsh_string;
  ULONG rsh_imdata;			/* image data					  					*/
  ULONG rsh_frimg;
  ULONG rsh_trindex;
  ULONG rsh_nobs; 			/* counts of various structs 					*/
  ULONG rsh_ntree;
  ULONG rsh_nted;
  ULONG rsh_nib;
  ULONG rsh_nbb;
  ULONG rsh_nstring;
  ULONG rsh_nimages;
  ULONG rsh_rssize;			/* total bytes in resource   */
} RSXHDR;

typedef struct {
	unsigned long	rlen;
	unsigned long	cicon_offset;
} NRSHDR;

#define	NRSC_CIBK			0x0004
#define	NRSC_LONG			0x0003

typedef struct {
	int			type;
	USERBLK		blk;
	long		spec;
	unsigned	user1;
	unsigned	user2;
	unsigned	user3;
	unsigned	user4;
	long		userl;
}	UBLK;

typedef struct _rsc {
	rscHDR	head;			/*	RSC Header			*/
	long	adr;			/*	Adr of memory bloc	*/
	long	len;			/*	Len of memory bloc	*/
	UBLK	*ublk;			/*	userdef array		*/
	CICON	*cicon;			/*	color icon array	*/
	XRSRCFIX fix;			/*  icone couleurs 		*/
} RSC;


/* Fonctions externes
 */


/*
 *	Chargement d'un ressource. Routines adapt‚ de EG_LIB
 *	(de Christophe Boyanique). On ne teste pas la validit‚
 *	du fichier ressource (num‚ro magique).
 */

/*
 *	rellocation en m‚moire du ressource
 */

static
void _relocRSC( void *_rsc) {
	RSC 		*rsc = _rsc;
	RSHDR		*head;
	RSXHDR		*xhead;
	NRSHDR		*nhead;
	CICONBLK	*table;
	CICON		*cicon,*cold;
	long		*lp,iclen,num_cicon;
	long		len;
	int		i,j,type;
	char		*p;

	head = (RSHDR *)rsc->adr;
	if( head->rsh_vrsn==NRSC_LONG) {
		xhead=(RSXHDR *)rsc->adr;
		/*************************************************************************
			Les nombres de structures
		*************************************************************************/
		rsc->head.nobs		=	xhead->rsh_nobs;
		rsc->head.ntree		=	xhead->rsh_ntree;
		rsc->head.nted		=	xhead->rsh_nted;
		rsc->head.nib		=	xhead->rsh_nib;
		rsc->head.ncib		=	0;
		rsc->head.nbb		=	xhead->rsh_nbb;
		rsc->head.nfstr		=	xhead->rsh_nstring;
		rsc->head.nfimg		=	xhead->rsh_nimages;
		/*************************************************************************
			Les pointeurs de structures
		*************************************************************************/
		rsc->head.trindex	=	(OBJECT **)(rsc->adr+xhead->rsh_trindex);
		rsc->head.object	=	(OBJECT *)(rsc->adr+xhead->rsh_object);
		rsc->head.tedinfo	=	(TEDINFO *)(rsc->adr+xhead->rsh_tedinfo);
		rsc->head.iconblk	=	(ICONBLK *)(rsc->adr+xhead->rsh_iconblk);
		rsc->head.bitblk	=	(BITBLK *)(rsc->adr+xhead->rsh_bitblk);
		rsc->head.frstr		=	(char **)(rsc->adr+xhead->rsh_frstr);
		rsc->head.frimg		=	(BITBLK **)(rsc->adr+xhead->rsh_frimg);
		len=xhead->rsh_rssize;
	} else {
		/*************************************************************************
			Les nombres de structures
		*************************************************************************/
		rsc->head.nobs		=	head->rsh_nobs;
		rsc->head.ntree		=	head->rsh_ntree;
		rsc->head.nted		=	head->rsh_nted;
		rsc->head.nib		=	head->rsh_nib;
		rsc->head.ncib		=	0;
		rsc->head.nbb		=	head->rsh_nbb;
		rsc->head.nfstr		=	head->rsh_nstring;
		rsc->head.nfimg		=	head->rsh_nimages;
		/*************************************************************************
			Les pointeurs de structures
		*************************************************************************/
		rsc->head.trindex	=	(OBJECT **)(rsc->adr+head->rsh_trindex);
		rsc->head.object	=	(OBJECT *)(rsc->adr+head->rsh_object);
		rsc->head.tedinfo	=	(TEDINFO *)(rsc->adr+head->rsh_tedinfo);
		rsc->head.iconblk	=	(ICONBLK *)(rsc->adr+head->rsh_iconblk);
		rsc->head.bitblk	=	(BITBLK *)(rsc->adr+head->rsh_bitblk);
		rsc->head.frstr		=	(char **)(rsc->adr+head->rsh_frstr);
		rsc->head.frimg		=	(BITBLK **)(rsc->adr+head->rsh_frimg);
		len=head->rsh_rssize;
	}

	/****************************************************************************
		rs_trindex
	****************************************************************************/
	lp = (long *)rsc->head.trindex;
	for( i=0;i<rsc->head.ntree;i++) {
		*lp=*lp+rsc->adr;
		lp++;
	}
	/****************************************************************************
		TEDINFO
	****************************************************************************/
	for( i=0; i<rsc->head.nted; i++) {
		rsc->head.tedinfo[i].te_ptext+=rsc->adr;
		rsc->head.tedinfo[i].te_ptmplt+=rsc->adr;
		rsc->head.tedinfo[i].te_pvalid+=rsc->adr;
	}
	/****************************************************************************
		ICONBLK
	****************************************************************************/
	for( i=0; i<rsc->head.nib; i++) {
		lp=(long *)&rsc->head.iconblk[i].ib_pmask;	*lp=*lp+rsc->adr;
		lp=(long *)&rsc->head.iconblk[i].ib_pdata;	*lp=*lp+rsc->adr;
		rsc->head.iconblk[i].ib_ptext+=rsc->adr;
	}
	/****************************************************************************
		BITBLK
	****************************************************************************/
	for( i=0; i<rsc->head.nbb; i++) {
		lp=(long *)&rsc->head.bitblk[i].bi_pdata;
		*lp=*lp+rsc->adr;
	}
	/****************************************************************************
		free STRING
	****************************************************************************/
	for( i=0; i<rsc->head.nfstr; i++)
		rsc->head.frstr[i]+=rsc->adr;
	/****************************************************************************
		free IMAGE
	****************************************************************************/
	for( i=0; i<rsc->head.nfimg; i++) {
		lp=(long *)&rsc->head.frimg[i]; 
		*lp=*lp+rsc->adr;
	}
	/****************************************************************************
		CICONBLK
	****************************************************************************/
	if( head->rsh_vrsn>1 && rsc->len>len) {
		if (head->rsh_vrsn==NRSC_CIBK)
			nhead=(NRSHDR *)(rsc->adr+(long)head->rsh_rssize);
		else
			nhead=(NRSHDR *)(rsc->adr+(long)xhead->rsh_rssize);
		rsc->head.ciconblk=(CICONBLK *)(rsc->adr+nhead->cicon_offset);
		lp=(long *)rsc->head.ciconblk;
		while (!lp[rsc->head.ncib])
			rsc->head.ncib+=1;

		if (lp[rsc->head.ncib]!=-1L)
			rsc->head.ncib=0;
		else {
			table=(CICONBLK *)&lp[rsc->head.ncib+1];
			for( i=0; i<rsc->head.ncib; i++) {
				lp[i]=(long)table;
				p=(char *)&table[1];
				table->monoblk.ib_pdata = (INT16 *)p;
				iclen=table->monoblk.ib_wicon/8*table->monoblk.ib_hicon;
				p+=iclen;
				table->monoblk.ib_pmask = (INT16 *)p;
				p+=iclen;
				table->monoblk.ib_ptext=(char *)p;
				cicon=(CICON *)&p[12];
				p+=12L;
				cold=cicon;
				if( (num_cicon=(long)table->mainlist) > 0 ) {
					table->mainlist=cicon;
					for( j=0; j<num_cicon; j++) {
						p=(char *)&cicon[1];
						cicon->col_data=(INT16 *)p;
						p+=iclen*cicon->num_planes;
						cicon->col_mask=(INT16 *)p;
						p+=iclen;
						if( cicon->sel_data!=NULL) {
							cicon->sel_data=(INT16 *)p;
							p+=iclen*cicon->num_planes;
							cicon->sel_mask=(INT16 *)p;
							p+=iclen;
						}
						cicon->next_res=(CICON *)p;
						cold=cicon;
						cicon=(CICON *)p;
					}
					cold->next_res=NULL;
				}
				table=(CICONBLK *)p;
			}
		}
	} else {
		rsc->head.cicon=NULL;
		rsc->head.ciconblk=NULL;
	}

	/****************************************************************************
		OBJECT:	Il faut faire pointer l'OB_SPEC au bon endroit
	****************************************************************************/
	for( i=0; i<rsc->head.nobs; i++) {
		type=rsc->head.object[i].ob_type&0xFF;
		if (type==G_CICON)
			rsc->head.object[i].ob_spec.index=lp[rsc->head.object[i].ob_spec.index];
		else if ( (type!=G_BOX) && (type!=G_IBOX) && (type!=G_BOXCHAR) )
			rsc->head.object[i].ob_spec.index+=rsc->adr;
		rsrc_obfix(&rsc->head.object[i],0);
	}
	
	/* Ic“nes couleurs */
	
	RsrcFixCicon( rsc->head.object, (int)rsc->head.nobs, (int)rsc->head.ncib, NULL, &rsc -> fix);
}

int _windomerr;

/*
 *	Charger un ressource
 */

void *RsrcXload( const char *name) {
	int	ha;
	RSC *rsc;
	char realname[255];
	
	rsc = (RSC *)malloc( sizeof(RSC));
	if( !rsc) return NULL;
	
	rsc->adr	=	0;
	rsc->ublk	=	0;
	rsc->cicon	=	0;

	strcpy( realname, name);
	shel_find( realname);
	ha=(int)Fopen( realname,FO_READ);

	if( ha<0) {
		_windomerr = -33;
		return NULL;
	}
	
	rsc->len=Fseek(0L,ha,2);
	Fseek(0L,ha,0);

#ifdef __SOZOBONX__
	rsc->adr = (long)lalloc( rsc->len * (long)sizeof(char));
#else
	rsc->adr = (long)malloc( rsc->len*sizeof(char));
#endif
	if( rsc->adr == 0L) {
		Fclose(ha);
		_windomerr = -39;
		return NULL;
	}
	
	if( Fread(ha,rsc->len,(void *)rsc->adr) != rsc->len ) {
		Fclose(ha);
		free((void*)rsc->adr);
		_windomerr = -1;
		return NULL;
	}
	Fclose(ha);
	_relocRSC(rsc);
	return rsc;
}

/*
 *	Lib‚rer de la m‚moire un ressource
 */

void RsrcXfree( void *rsc) {
	RsrcFreeCicon( &((RSC *)rsc)->fix);
	free( (void *)((RSC *)rsc)->adr);
}

/* Retourne le tableaux des donn‚es du ressource */
  
rscHDR *RsrcGhdr( void *rsc) {
	return &((RSC *)rsc)->head;
}

/* utilisation avec RsrcXtype:
	RsrcXtype( mode, RsrcHdr(rsc)->trindex, RsrcHdr(rsc)->ntree);
 rem :  Les icones couleurs sont fix‚ avec RsrcXload()
 */


/*
 *	Lire un objet
 */
#ifndef __GEMLIB__
#define R_IBPTEXT	R_IPBTEXT
#endif

int RsrcGaddr( void *_rsc, int type, int index, void *addr) {
	RSC *rsc = _rsc;
	if( rsc) {
		switch( type) {
		case R_TREE:
			*(long*)addr = (long) (rsc->head.trindex[index]);
			break;
		case R_OBJECT:
			*(long*)addr = (long) (&rsc->head.object [index]);
			break;
		case R_TEDINFO:
			*(long*)addr = (long) (&rsc->head.tedinfo[index]);
			break;
		case R_ICONBLK:
			*(long*)addr = (long) (&rsc->head.iconblk[index]);
			break;
		case R_BITBLK:
			*(long*)addr = (long) (&rsc->head.bitblk[index]);
			break;
		case R_STRING:
		case R_FRSTR:
			*(long*)addr = (long) (rsc->head.frstr[index]);			
			break;
		case R_IMAGEDATA:
		case R_FRIMG:
			*(long*)addr = (long) (rsc->head.frimg[index]);
			break;
		case R_OBSPEC:
			*(long*)addr = (long) (&rsc->head.object[index].ob_spec);
			break;
		case R_TEPTEXT:
			*(long*)addr = (long) (rsc->head.tedinfo[index].te_ptext);
			break;
		case R_TEPTMPLT:
			*(long*)addr = (long) (rsc->head.tedinfo[index].te_ptmplt);
			break;
		case R_TEPVALID:
			*(long*)addr = (long) (rsc->head.tedinfo[index].te_pvalid);
			break;
		case R_IBPMASK:
			*(long*)addr = (long) (rsc->head.iconblk[index].ib_pmask);
			break;
		case R_IBPDATA:
			*(long*)addr = (long) (rsc->head.iconblk[index].ib_pdata);
			break;
		case R_IBPTEXT:
			*(long*)addr = (long) (rsc->head.iconblk[index].ib_ptext);
			break;
		case R_BIPDATA:
			*(long*)addr = (long) (rsc->head.bitblk[index].bi_pdata);
			break;
		default:
			return -1;
		}
		return 0;
	} else
		return rsrc_gaddr( type, index, addr);
}

