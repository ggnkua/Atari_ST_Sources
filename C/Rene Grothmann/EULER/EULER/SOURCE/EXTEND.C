#include <stdio.h>

#include "header.h"

void mindex (header *hd);
void mpi (header *hd);
void mtime (header *hd);
void mepsilon (header *hd);
void msin (header *hd);
void mcos (header *hd);
void mtan (header *hd);
void matan (header *hd);
void macos (header *hd);
void masin (header *hd);
void mexp (header *hd);
void mlog (header *hd);
void msqrt (header *hd);
void mre (header *hd);
void mim (header *hd);
void mcomplex (header *hd);
void miscomplex (header *hd);
void misreal (header *hd);
void mround (header *hd);
void marg (header *hd);
void mabs (header *hd);
void msum (header *hd);
void mprod (header *hd);
void mconj (header *hd);
void msize (header *hd);
void mrows (header *hd);
void mcols (header *hd);
void mmatrix (header *hd);
void mones (header *hd);
void mdiag (header *hd);
void mdiag2 (header *hd);
void mband (header *hd);
void mextrema (header *hd);
void mmesh (header *hd);
void mview (header *hd);
void mview0 (header *hd);
void mwait (header *hd);
void mrandom (header *hd);
void mnormal (header *hd);
void mtext (header *hd);
void mctext (header *hd);
void mrtext (header *hd);
void mtextsize (header *hd);
void mwire (header *hd);
void msolid (header *hd);
void msolidh (header *hd);
void msolid1 (header *hd);
void mplot (header *hd);
void mplotarea (header *hd);
void mplot1 (header *hd);
void mpixel (header *hd);
void mmark (header *hd);
void mcontour (header *hd);
void mdup (header *hd);
void mmod (header *hd);
void mformat (header *hd);
void mcolor (header *hd);
void mfcolor (header *hd);
void mwcolor (header *hd);
void mtcolor (header *hd);
void mstyle (header *hd);
void mmstyle (header *hd);
void mlstyle (header *hd);
void mlinew (header *hd);
void mwindow (header *hd);
void mwindow0 (header *hd);
void mgauss (header *hd);
void minvgauss (header *hd);
void mfak (header *hd);
void mbin (header *hd);
void mtd (header *hd);
void minvtd (header *hd);
void mchi (header *hd);
void mfdis (header *hd);
void mmax (header *hd);
void mmin (header *hd);
void mscale (header *hd);
void msort (header *hd);
void mnonzeros (header *hd);
void mstatistics (header *hd);
void mfloor (header *hd);
void mceil (header *hd);
void mcumsum (header *hd);
void mcumprod (header *hd);
void mfree (header *hd);
void mshrink (header *hd);
void minput (header *hd);
void mmax1 (header *hd);
void mmin1 (header *hd);
void mdo (header *hd);
void polyval (header *hd);
void polyadd (header *hd);
void polymult (header *hd);
void polydiv (header *hd);
void dd (header *hd);
void ddval (header *hd);
void polydd (header *hd);
void polyzeros (header *hd);
void polytrunc (header *hd);
void mchar (header *hd);
void mlu (header *hd);
void mlusolve (header *hd);
void mfft (header *hd);
void mifft (header *hd);
void mzeros (header *hd);
void merror (header *hd);
void mprintf (header *hd);
void msign (header *hd);
void mmouse (header *hd);
void mtridiag (header *hd);
void mcharpoly (header *hd);
void mscompare (header *hd);
void mfind (header *hd);
void msetdiag (header *hd);
void mzeros1 (header *hd);
void margn (header *hd);
void msetkey (header *hd);
void many (header *hd);
void mcd (header *hd);
void mdir (header *hd);
void mdir0 (header *hd);
void wmultiply (header *hd);
void smultiply (header *hd);
void mproject (header *hd);
void margs (header *hd);
void msetplot (header *hd);
void mscaling (header *hd);
void mholding (header *hd);
void mholding0 (header *hd);
void mlineinput (header *hd);
void minterpret (header *hd);
void mname (header *hd);
void mtwosides (header *hd);
void mtriangles (header *hd);
void mmeshfactor (header *hd);
void msetepsilon (header *hd);
void mflipx (header *hd);
void mflipy (header *hd);
void mzerosmat (header *hd);
void mjacobi (header *hd);
void mframe (header *hd);
#ifndef SPLIT_MEM
void mstore (header *hd);
void mrestore (header *hd);
#endif
void mkey (header *hd);
void merrlevel (header *hd);
void mdensity (header *hd);
void mdcolor (header *hd);
void mdgrid (header *hd);

builtintyp builtin_list[] =
	{{"index",0,mindex},
	 {"pi",0,mpi},
	 {"time",0,mtime},
	 {"epsilon",0,mepsilon},
	 {"sin",1,msin},
	 {"cos",1,mcos},
	 {"tan",1,mtan},
	 {"atan",1,matan},
	 {"acos",1,macos},
	 {"asin",1,masin},
	 {"exp",1,mexp},
	 {"log",1,mlog},
	 {"sqrt",1,msqrt},
	 {"re",1,mre},
	 {"im",1,mim},
	 {"complex",1,mcomplex},
	 {"iscomplex",1,miscomplex},
	 {"isreal",1,misreal},
	 {"round",2,mround},
	 {"arg",1,marg},
	 {"abs",1,mabs},
	 {"sum",1,msum},
	 {"prod",1,mprod},
	 {"conj",1,mconj},
	 {"size",-1,msize},
	 {"rows",1,mrows},
	 {"cols",1,mcols},
	 {"zeros",1,mzerosmat},
	 {"ones",1,mones},
	 {"diag",3,mdiag},
	 {"diag",2,mdiag2},
	 {"band",3,mband},
	 {"extrema",1,mextrema},
	 {"mesh",1,mmesh},
	 {"view",1,mview},
	 {"view",0,mview0},
	 {"wait",1,mwait},
	 {"random",1,mrandom},
	 {"normal",1,mnormal},
	 {"text",2,mtext},
	 {"ctext",2,mctext},
	 {"rtext",2,mrtext},
	 {"textsize",0,mtextsize},
	 {"wire",3,mwire},
	 {"solid",3,msolid},
	 {"solid",4,msolid1},
	 {"plot",2,mplot},
	 {"plotarea",2,mplotarea},
	 {"plot",0,mplot1},
	 {"pixel",0,mpixel},
	 {"mark",2,mmark},
	 {"contour",2,mcontour},
	 {"dup",2,mdup},
	 {"mod",2,mmod},
	 {"format",1,mformat},
	 {"color",1,mcolor},
	 {"framecolor",1,mfcolor},
	 {"wirecolor",1,mwcolor},
	 {"textcolor",1,mtcolor},
	 {"style",1,mstyle},
	 {"markerstyle",1,mmstyle},
	 {"linestyle",1,mlstyle},
	 {"linewidth",1,mlinew},
	 {"window",1,mwindow},
	 {"window",0,mwindow0},
	 {"normaldis",1,mgauss},
	 {"invnormaldis",1,minvgauss},
	 {"fak",1,mfak},
	 {"bin",2,mbin},
	 {"tdis",2,mtd},
	 {"invtdis",2,minvtd},
	 {"chidis",2,mchi},
	 {"fdis",3,mfdis},
	 {"max",2,mmax},
	 {"min",2,mmin},
	 {"scale",1,mscale},
	 {"sort",1,msort},
	 {"nonzeros",1,mnonzeros},
	 {"count",2,mstatistics},
	 {"floor",1,mfloor},
	 {"ceil",1,mceil},
	 {"cumsum",1,mcumsum},
	 {"cumprod",1,mcumprod},
	 {"free",0,mfree},
	 {"shrink",1,mshrink},
	 {"input",1,minput},
	 {"max",1,mmax1},
	 {"min",1,mmin1},
	 {"eval",-1,mdo},
	 {"polyval",2,polyval},
	 {"polyadd",2,polyadd},
	 {"polymult",2,polymult},
	 {"polydiv",2,polydiv},
	 {"interp",2,dd},
	 {"interpval",3,ddval},
	 {"polytrans",2,polydd},
	 {"polycons",1,polyzeros},
	 {"polytrunc",1,polytrunc},
	 {"char",1,mchar},
	 {"lu",1,mlu},
	 {"lusolve",2,mlusolve},
	 {"fft",1,mfft},
	 {"ifft",1,mifft},
	 {"polysolve",1,mzeros},
	 {"error",1,merror},
	 {"printf",2,mprintf},
	 {"sign",1,msign},
	 {"mouse",0,mmouse},
	 {"hb",1,mtridiag},
	 {"charpoly",1,mcharpoly},
	 {"stringcompare",2,mscompare},
	 {"find",2,mfind},
	 {"setdiag",3,msetdiag},
	 {"polyroot",2,mzeros1},
	 {"argn",0,margn},
	 {"setkey",2,msetkey},
	 {"any",1,many},
	 {"cd",1,mcd},
	 {"searchfile",1,mdir},
	 {"searchfile",0,mdir0},
	 {"bandmult",2,wmultiply},
	 {"symmult",2,smultiply},
	 {"project",3,mproject},
	 {"args",1,margs},
	 {"setplot",1,msetplot},
	 {"scaling",1,mscaling},
	 {"holding",1,mholding},
	 {"holding",0,mholding0},
	 {"lineinput",1,mlineinput},
	 {"interpret",1,minterpret},
	 {"name",1,mname},
	 {"twosides",1,mtwosides},
	 {"triangles",1,mtriangles},
	 {"meshfactor",1,mmeshfactor},
	 {"setepsilon",1,msetepsilon},
	 {"flipx",1,mflipx},
	 {"flipy",1,mflipy},
	 {"matrix",2,mmatrix},
	 {"jacobi",1,mjacobi},
	 {"frame",0,mframe},
#ifndef SPLIT_MEM
	 {"store",1,mstore},
	 {"restore",1,mrestore},
#endif
	 {"key",0,mkey},
	 {"errorlevel",1,merrlevel},
	 {"density",1,mdensity},
	 {"huecolor",1,mdcolor},
	 {"huegrid",1,mdgrid},
	 {"solidhue",4,msolidh},
	 {(char *)0,0,0} };
