;File name:	COPY.S			Revision date:	1992.02.19
;Ported by:	Ulf Ronald Andersson	Portation date:	1992.02.18
;Ported from:	C-source	Ported to:	Devpac 2 source
;Copyright:	(C)1986 Max B”hm
;
;Original file header, each line preceded by a semicolon, follows:
;/* 16.5.86  Max B”hm */
;
;/* Dieses Programm kopiert den Inhalt des "Source"-Directory    */
;/* in das "Dest"-Directory.                                     */
;/* Die beiden Directorys k”nnen als Parameter angegeben werden. */
;/* Defaultwerte sind A:\COPY und D:                             */
;
;#include <osbind.h>
;#include <string.h>
;Here ends the original file header.
;
;
	include	TOS\URAn_SYS.S
	include	TOS\URAn_DOS.S
;
;
	text
;
	opt	a+
	opt	o+
	opt	p+
;	
;
_max_args	= 2
;
;
_startup:
	move.l	4(sp),a5
	move.l	bp_bss_beg_p(a5),a0
	add.l	bp_bss_len(a5),a0
	move.l	a0,sp
	sub.l	a5,a0
	gemdos	Mshrink,!,(a5),a0
	lea	static,a4
	clr	_argc-static(a4)
	lea	_argv-static(a4),a2
	lea	_argcopy-static(a4),a1
	move.l	a1,(a2)+
	clr.b	(a1)+
	lea	bp_argstring(a5),a3
	move.b	bp_arglen(a5),d7
	and	#$7F,d7
	clr	d6
	subq	#1,d7
	bmi.s	.gotargs
.getarg_lp_1:
	cmpi.b	#' ',(a3)+
	dbgt	d7,.getarg_lp_1
	ble.s	.gotargs
	subq	#1,a3
	addq	#1,d6			;_argc += 1
	move.l	a1,(a2)+		;_argv[d6] = a1
.getarg_lp_2:
	move.b	(a3)+,(a1)+
	cmpi.b	#' ',(a3)
	dble	d7,.getarg_lp_2
	bgt.s	.gotargs
	clr.b	(a1)+
	cmpi	#_max_args,d6
	blt.s	.getarg_lp_1
.gotargs:
	pea	_argv-static(a4)
	move	d6,_argc-static(a4)
	move	d6,-(sp)
	bsr	main
	gemdos	Pterm,d0
;
;
	data
;
_argc:		ds.w	1
_argv:		ds.l	_max_args+1
_argcopy:	dcb.b	128,0
;
static:
;
source:		dc.b	'A:\COPY'
		dcb.b	(*-source)+100,NUL
dest:		dc.b	'D:'
		dcb.b	(*-source)+100,NUL
starpstar:	dc.b	'\*.*',NUL
slash:		dc.b	'\',NUL
crlf:		dc.b	CR,LF,NUL
		even
buffer:		dc.l	0
buf_size:	dc.l	0
files:		dc.w	0
folders:	dc.w	0
;
;
	bss
;
;
	ds.l	$100	;allow 256 longwords on minimum stack
;
;
	text
;
;
printi	macro	string
	bra.s	.skip\@
.string\@:	dc.b	\1,NUL
	even
.skip\@:
	gemdos	Cconws,.string\@(pc)
	endm	;printi
;
;
prints	macro	string
	gemdos	Cconws,\1
	endm	;prints
;
;
main:						;main(argc,argv)
	RSRESET
;NB: if locals were used they would be declared here, above .aut1
.aut1	rs.l	2
.argc	rs.w	1				;int argc;
.argv	rs.l	1				;char *argv[];
	link	a6,#-.aut1			;{
	printi	<CR,LF,'COPY: Folder copier now starting.',CR,LF,ESC,'w'>
	cmpi	#1,.argc-.aut1(a6)		; if (argc>=1)
	blt.s	.endif_1
	move.l	.argv-.aut1(a6),a0
	move.l	4(a0),-(sp)
	pea	source-static(a4)
	bsr	strcpy				;   strcpy(source,argv[1]);
	addq	#8,sp
.endif_1:
	cmpi	#2,.argc-.aut1(a6)		; if (argc>=2)
	blt.s	.endif_2
	move.l	.argv-.aut1(a6),a0
	move.l	8(a0),-(sp)
	pea	dest-static(a4)
	bsr	strcpy				;   strcpy(dest,argv[2]);
	addq	#8,sp
.endif_2:
	tst.b	2+dest-static(a4)		; if (dest[2])
	beq.s	.endif_3
	gemdos	Dcreate,dest-static(a4)		;   Dcreate(dest);
.endif_3:
	gemdos	Malloc,?			; buf_size=Malloc(-1l);
	move.l	d0,buf_size-static(a4)
	gemdos	Malloc,d0			; buffer=Malloc(buf_size);
	move.l	d0,buffer-static(a4)
	bsr	copy_dir			; if (copy_dir())
	move.l	d0,d3
	move	files-static(a4),-(sp)
	bsr	showint8
	addq	#2,sp
	printi	<ESC,'K',' Files   successfully copied.',CR,LF>
	move	folders-static(a4),-(sp)
	bsr	showint8
	addq	#2,sp
	printi	<' Folders successfully copied.',CR,LF>
	move.l	d3,d0
	bpl.s	.endif_4
	printi	CR,LF,'Press Return to continue.',CR,LF	; { printf("\nWeiter mit Return.\n");
	gemdos	Crawcin				;   Cconin();
.endif_4:					; }
	printi	<'COPY: Folder copier now exiting.',CR,LF>
	gemdos	Mfree!_IND,buffer-static(a4)	; Mfree(buffer);
	unlk	a6				;}
	rts
;
;
copy_dir:	;copy_dir ()       /* source und dest sind global; bei Fehler: return (1) */
	RSRESET
.source_len	rs.w	1
.dest_len	rs.w	1
.fd_source	rs.w	1
.fd_dest	rs.w	1
.error		rs.w	1
.dta		rs.b	44
.old_dta	rs.l	1
.fail		rs.l	1
.size		rs.l	1
.count		rs.l	1
.aut2		rs.l	2
;NB: if arguments were used they would be declared here, below .aut2
	link	a6,#-.aut2
	clr	.error-.aut2(a6)		; error=0;
	pea	source-static(a4)
	bsr	strlen
	addq	#4,sp
	move	d0,.source_len-.aut2(a6)	; source_len=strlen(source);
	subq	#1,d0
	cmpi.b	#'\',source-static(a4,d0)
	bne.s	.keep_source_len
	move	d0,.source_len-.aut2(a6)
	clr.b	source-static(a4,d0)
.keep_source_len:				;URA: Now ignores final source '\'
	pea	starpstar-static(a4)
	pea	source-static(a4)
	bsr	strcat				; strcat(source,"\\*.*");
	addq	#8,sp
	pea	dest-static(a4)
	bsr	strlen
	addq	#4,sp
	move	d0,.dest_len-.aut2(a6)		; dest_len=strlen(dest);
	subq	#1,d0
	cmpi.b	#'\',dest-static(a4,d0)
	bne.s	.keep_dest_len
	move	d0,.dest_len-.aut2(a6)
	clr.b	dest-static(a4,d0)
.keep_dest_len:				;URA: Now ignores final dest '\'
	gemdos	Fgetdta
	move.l	d0,.old_dta-.aut2(a6)		; old_dta=Fgetdta();
	gemdos	Fsetdta,.dta-.aut2(a6)		; Fsetdta(dta);
	gemdos	Fsfirst,source-static(a4),#$10
	move.l	d0,.fail-.aut2(a6)		; fail=Fsfirst(source,16);
	move	.source_len-.aut2(a6),a0
	clr.b	source-static(a4,a0)		; source[source_len]=0;
.while_beg_1:
	tst.l	.fail-.aut2(a6)			; while (!fail)
	bne	.while_end_1			; {
	pea	slash-static(a4)
	pea	source-static(a4)
	bsr	strcat				;   strcat(source,"\\");
	addq	#8,sp
	pea	30+.dta-.aut2(a6)
	pea	source-static(a4)
	bsr	strcat				;   strcat(source,dta+30);
	addq	#8,sp
	pea	slash-static(a4)
	pea	dest-static(a4)
	bsr	strcat				;   strcat(dest,"\\");
	addq	#8,sp
	pea	30+.dta-.aut2(a6)
	pea	dest-static(a4)
	bsr	strcat				;   strcat(dest,dta+30);
	addq	#8,sp
	btst	#4,21+.dta-.aut2(a6)		;   if (dta[21]==16)   /* Directory */
	beq.s	.else_1				;   {
.doif_1:
	move.l	30+.dta-.aut2(a6),d0
	clr.b	d0
	swap	d0
	cmpi	#'.'<<8,d0			;     if (strcmp(dta+30,".")
	beq.s	.endif_2
	cmpi.l	#'..',d0			;         && strcmp(dta+30,".."))
	beq.s	.endif_2			;     {
.doif_2:
	gemdos	Dcreate,dest-static(a4)		;       if (Dcreate(dest))
	tst.l	d0
	beq.s	.else_3				;       {
.doif_3:
	printi	<"Can't create folder: ">	;         printf("Ordner %s l„žt sich nicht"
	prints	dest-static(a4)			;                " anlegen.\n",dest);
	prints	crlf-static(a4)
	move	#-1,.error-.aut2(a6)		;         error=1;
	bra.s	.endif_3			;       }
.else_3:					;       else
	bsr	copy_dir			;       { error|=copy_dir(source,dest);
	or	d0,.error-.aut2(a6)
;NB: ERROR in original source, copy_dir has NO defined arguments  (but no harm done!)
	tst	d0
	bmi.s	.endif_3
	addq	#1,folders-static(a4)
.endif_3:					;       }
.endif_2:					;     }
	bra	.endif_1			;   }
.else_1:					;   else       /* File */
	printi	<ESC,'K'>
	prints	source-static(a4)		;   { printf("%s  nach  %s\n",source,dest);
	printi	<HT,'  ==>>',HT>
	prints	dest-static(a4)
	prints	crlf-static(a4)
	printi	<ESC,'A'>		;avoid filling screen
	gemdos	Fopen,source-static(a4),!
	move	d0,.fd_source-.aut2(a6)
	bpl.s	.else_4				;     if ((fd_source=Fopen(source,0))<0)
.doif_4:
	printi	<"Can't open file ">		;     { printf("Datei %s l„žt sich nicht"
	prints	source-static(a4)		;              " ”ffnen.\n",source);
	prints	crlf-static(a4)
	move	#-1,.error-.aut2(a6)		;       error=1;
	bra	.endif_4			;     }
.else_4:					;     else
	gemdos	Fcreate,dest-static(a4),!
	move	d0,.fd_dest-.aut2(a6)
	bpl.s	.else_5				;     { if ((fd_dest=Fcreate(dest,dta[21]&~1))<0)
.doif_5:
	printi	<"Can't create file ">		;       { printf("Datei %s l„žt sich nicht"
	prints	dest-static(a4)			;                " einrichten.\n",dest);
	prints	crlf-static(a4)
	move	#-1,.error-.aut2(a6)		;         error=1;
	bra	.endif_5			;       }
.else_5:					;       else
	move.l	dta_fsize+.dta-.aut2(a6),.size-.aut2(a6)
;						;       { size=*(long*)(dta+26);
.while_beg_2:
	tst.l	.size-.aut2(a6)			;         while (size)
	beq	.while_end_2
	move.l	.size-.aut2(a6),d0		;         {
	cmp.l	buf_size-static(a4),d0
	bls.s	.min_size
	move.l	buf_size-static(a4),d0
.min_size:
	move.l	d0,.count-.aut2(a6)		;           count=(size<buf_size)?size:buf_size;
	sub.l	d0,.size-.aut2(a6)		;           size-=count;
	gemdos	Fread!_IND,.fd_source-.aut2(a6),.count-.aut2(a6),buffer-static(a4)
	cmp.l	.count-.aut2(a6),d0		;           if (Fread(fd_source,count,buffer)!=count)
	beq.s	.endif_6
.doif_6:					;           {
	printi	<'Error while reading file '>	;             printf("Fehler beim Lesen von"
	prints	source-static(a4)		;                    " %s .\n",source);
	prints	crlf-static(a4)
	move	#-1,.error-.aut2(a6)		;             error=1;
	bra	.while_end_2			;             break;
.endif_6:					;           }
	gemdos	Fwrite!_IND,.fd_dest-.aut2(a6),.count-.aut2(a6),buffer-static(a4)
	cmp.l	.count-.aut2(a6),d0		;           if (Fwrite(fd_dest,count,buffer)!=count)
	beq.s	.endif_7
.doif_7:					;           {
	printi	<'Error while WRITING file '>	;             printf("Fehler beim Schreiben von"
	prints	dest-static(a4)		;                    " %s .\n",dest);
	prints	crlf-static(a4)
	move	#-1,.error-.aut2(a6)		;             error=1;
	bra	.while_end_2			;             break;
.endif_7:					;           }
	bra	.while_beg_2
.while_end_2:					;         }
	gemdos	Fclose,.fd_source-.aut2(a6)	;         Fclose(fd_source);
	gemdos	Fclose,.fd_dest-.aut2(a6)	;         Fclose(fd_dest);
	gemdos	Fopen,dest-static(a4),#1	;         fd_dest=Fopen(dest,1);
	move.l	d0,d3
	gemdos	Fdatime,22+.dta-.aut2(a6),d3,#1	;         Fdatime(fd_dest,dta+22,1);
	gemdos	Fclose,d3			;         Fclose(fd_dest);
	addq	#1,files-static(a4)
.endif_5:					;       }
.endif_4:					;     }
.endif_1:					;   }
	move	.source_len-.aut2(a6),d0
	clr.b	source-static(a4,d0)		;   source[source_len]=0;
	move	.dest_len-.aut2(a6),d0
	clr.b	dest-static(a4,d0)		;   dest[dest_len]=0;
	gemdos	Fsnext
	move.l	d0,.fail-.aut2(a6)		;   fail=Fsnext();
	bra	.while_beg_1
.while_end_1:					; }
	cmpi.l	#-49,.fail-.aut2(a6)		;   if (fail!=-49l)
	beq.s	.endif_8			;   {
.doif_8:
	printi	<"Can't find folder ">		;     printf("Ordner %s nicht gefunden.\n",source);
	prints	source-static(a4)
	prints	crlf-static(a4)
	move	#-1,.error-.aut2(a6)		;     error=1;
.endif_8:					;   }
	gemdos	Fsetdta!_IND,.old_dta-.aut2(a6)	;   Fsetdta(old_dta);
	move	.error-.aut2(a6),d0		;   return (error);
	ext.l	d0
.fnend_dir_copy:
	unlk	a6				;}
	rts
;
;
strlen:
	movea.l	4(sp),a0
	move	#256-1,d0		;limit test
.loop:
	tst.b	(a0)+
	dbeq	d0,.loop
	subq.l	#1,a0
	sub.l	4(sp),a0
	move.l	a0,d0
	rts
;
;
strcpy:
	movea.l	4(sp),a1
	movea.l	8(sp),a0
	move	#255-1,d0		;limit move
.loop:
	move.b	(a0)+,(a1)+
	dbeq	d0,.loop
	beq.s	.exit
	clr.b	(a1)
.exit:
	rts
;
;
strcat:
	movea.l	4(sp),a1
	movea.l	8(sp),a0
	move	#255-1,d0		;limit test & move
.loop_1:
	tst.b	(a1)+
	dbeq	d0,.loop_1
	bne.s	.exit
	subq	#1,a1
.loop:
	move.b	(a0)+,(a1)+
	dbeq	d0,.loop
	beq.s	.exit
	clr.b	(a1)
.exit:
	rts
;
;
showint8:
	link	a6,#-10
	clr.l	d2
	move.w	8(a6),d2
	lea	(a6),a0
	clr.b	-(a0)
.loop_1:
	divu	#10,d2
	swap	d2
	addi.b	#'0',d2
	move.b	d2,-(a0)
	clr	d2
	swap	d2
	bne.s	.loop_1
	lea	-9(a6),a1
.loop_2:
	move.b	#' ',-(a0)
	cmpa.l	a1,a0
	bgt.s	.loop_2
	gemdos	Cconws,(a0)
	unlk	a6
	rts
;
;
	end	;of file:	COPY.S