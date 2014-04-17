head	1.3;
access;
symbols;
locks
	ersmith:1.3;
comment	@# @;


1.3
date	93.03.10.20.12.42;	author ersmith;	state Exp;
branches;
next	1.2;

1.2
date	93.03.10.19.57.50;	author ersmith;	state Exp;
branches;
next	;


desc
@Shell script for doing RCS checkin.
@


1.3
log
@Lattice port
@
text
@#
# script to check in a new version
# NOTE: this script works only under MultiTOS
#
echo "Last RCS version number was:" `cat lastvers`
echo -n "Enter version number: "
set vers=$<
echo -n "Enter version message: "
set descr=$<
set files=`cat ci.lis`
ci "-l$vers" -f "-m$descr" $files
#
# binary files must be copied verbatim
#
echo "Copying binary files..."
mkdir rcs.bin\$vers
set files=`cat cp.lis`
cp $files rcs.bin\$vers
#
# all done
#
echo $vers >lastvers
unset vers descr files
@


1.2
log
@MultiTOS 1.01 release
@
text
@d5 1
d22 1
@
