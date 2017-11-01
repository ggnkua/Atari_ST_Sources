# GULAM-Script for processing the ISO modules
# NOTE: The order shown is a valid order for compiling too.
#
# Parameters:
#  $1: name that identifies the compiler, e.g. LPRM2, HM2,...-- see PORTAB.M2H
#      for valid names
#  $2: destination directory
#  $3: extension for definition modules, e.g. def, d,...
#  $4: extension for implementation modules, e.g. mod, m,...
#
# Sample call (in gulam): iso_m2 LPRM2 m: def mod
#

#
# Miscellaneous
#
m2ppx $1 misc\exceptio.dpp $2\exceptio.$3
m2ppx $1 misc\exceptio.ipp $2\exceptio.$4
m2ppx $1 misc\isostora.dpp $2\isostora.$3
m2ppx $1 misc\isostora.ipp $2\isostora.$4
m2ppx $1 misc\lowreal.dpp $2\lowreal.$3
m2ppx $1 misc\lowreal.ipp $2\lowreal.$4
m2ppx $1 misc\lowlong.dpp $2\lowlong.$3
m2ppx $1 misc\lowlong.ipp $2\lowlong.$4
m2ppx $1 misc\charclas.dpp $2\charclas.$3
m2ppx $1 misc\charclas.ipp $2\charclas.$4
m2ppx $1 misc\sysclock.dpp $2\sysclock.$3
m2ppx $1 misc\sysclock.ipp $2\sysclock.$4
#
# Conversion
#
m2ppx $1 conv\convtype.dpp $2\convtype.$3
m2ppx $1 conv\convtype.ipp $2\convtype.$4
m2ppx $1 support\wconvbas.dpp $2\wconvbas.$3
m2ppx $1 support\wconvbas.ipp $2\wconvbas.$4
m2ppx $1 support\fconvbas.dpp $2\fconvbas.$3
m2ppx $1 support\fconvbas.ipp $2\fconvbas.$4
m2ppx $1 conv\wholestr.dpp $2\wholestr.$3
m2ppx $1 conv\wholestr.ipp $2\wholestr.$4
m2ppx $1 conv\wholecon.dpp $2\wholecon.$3
m2ppx $1 conv\wholecon.ipp $2\wholecon.$4
m2ppx $1 conv\longstr.dpp $2\longstr.$3
m2ppx $1 conv\longstr.ipp $2\longstr.$4
m2ppx $1 conv\realstr.dpp $2\realstr.$3
m2ppx $1 conv\realstr.ipp $2\realstr.$4
m2ppx $1 conv\longconv.dpp $2\longconv.$3
m2ppx $1 conv\longconv.ipp $2\longconv.$4
m2ppx $1 conv\realconv.dpp $2\realconv.$3
m2ppx $1 conv\realconv.ipp $2\realconv.$4
#
# I/O
#
m2ppx $1 support\ioshare.dpp $2\ioshare.$3
m2ppx $1 support\ioshare.ipp $2\ioshare.$4
m2ppx $1 device\chancons.dpp $2\chancons.$3
m2ppx $1 device\chancons.ipp $2\chancons.$4
m2ppx $1 io\ioconsts.dpp $2\ioconsts.$3
m2ppx $1 io\ioconsts.ipp $2\ioconsts.$4
m2ppx $1 io\iochan.dpp $2\iochan.$3
m2ppx $1 device\iolink.dpp $2\iolink.$3
m2ppx $1 io\iochan.ipp $2\iochan.$4
m2ppx $1 device\iolink.ipp $2\iolink.$4
m2ppx $1 io\rawio.dpp $2\rawio.$3
m2ppx $1 io\rawio.ipp $2\rawio.$4
m2ppx $1 io\textio.dpp $2\textio.$3
m2ppx $1 io\textio.ipp $2\textio.$4
m2ppx $1 io\wholeio.dpp $2\wholeio.$3
m2ppx $1 io\wholeio.ipp $2\wholeio.$4
m2ppx $1 support\fiobase.dpp $2\fiobase.$3
m2ppx $1 support\fiobase.ipp $2\fiobase.$4
m2ppx $1 io\longio.dpp $2\longio.$3
m2ppx $1 io\longio.ipp $2\longio.$4
m2ppx $1 io\realio.dpp $2\realio.$3
m2ppx $1 io\realio.ipp $2\realio.$4
m2ppx $1 io\ioresult.dpp $2\ioresult.$3
m2ppx $1 io\ioresult.ipp $2\ioresult.$4
m2ppx $1 support\stdchanb.dpp $2\stdchanb.$3
m2ppx $1 support\stdchanb.ipp $2\stdchanb.$4
m2ppx $1 support\stdinout.dpp $2\stdinout.$3
m2ppx $1 support\stdinout.ipp $2\stdinout.$4
m2ppx $1 device\stdchans.dpp $2\stdchans.$3
m2ppx $1 device\stdchans.ipp $2\stdchans.$4
m2ppx $1 io\srawio.dpp $2\srawio.$3
m2ppx $1 io\srawio.ipp $2\srawio.$4
m2ppx $1 io\stextio.dpp $2\stextio.$3
m2ppx $1 io\stextio.ipp $2\stextio.$4
m2ppx $1 io\swholeio.dpp $2\swholeio.$3
m2ppx $1 io\swholeio.ipp $2\swholeio.$4
m2ppx $1 io\slongio.dpp $2\slongio.$3
m2ppx $1 io\slongio.ipp $2\slongio.$4
m2ppx $1 io\srealio.dpp $2\srealio.$3
m2ppx $1 io\srealio.ipp $2\srealio.$4
m2ppx $1 io\sioresul.dpp $2\sioresul.$3
m2ppx $1 io\sioresul.ipp $2\sioresul.$4
#
# Device driver
#
m2ppx $1 device\programa.dpp $2\programa.$3
m2ppx $1 device\programa.ipp $2\programa.$4
m2ppx $1 device\rndfile.dpp $2\rndfile.$3
m2ppx $1 device\rndfile.ipp $2\rndfile.$4
m2ppx $1 device\seqfile.dpp $2\seqfile.$3
m2ppx $1 device\seqfile.ipp $2\seqfile.$4
m2ppx $1 device\streamfi.dpp $2\streamfi.$3
m2ppx $1 device\streamfi.ipp $2\streamfi.$4
#
# Math
#
m2ppx $1 math\realsupp.dpp $2\realsupp.$3
m2ppx $1 math\realsupp.ipp $2\realsupp.$4
m2ppx $1 math\realmath.dpp $2\realmath.$3
m2ppx $1 math\realmath.ipp $2\realmath.$4
m2ppx $1 math\realxmat.dpp $2\realxmat.$3
m2ppx $1 math\realxmat.ipp $2\realxmat.$4
m2ppx $1 math\complexm.dpp $2\complexm.$3
m2ppx $1 math\complexm.ipp $2\complexm.$4
m2ppx $1 math\cxmath.dpp $2\cxmath.$3
m2ppx $1 math\cxmath.ipp $2\cxmath.$4
#
m2ppx $1 math\longsupp.dpp $2\longsupp.$3
m2ppx $1 math\longsupp.ipp $2\longsupp.$4
m2ppx $1 math\longmath.dpp $2\longmath.$3
m2ppx $1 math\longmath.ipp $2\longmath.$4
m2ppx $1 math\longxmat.dpp $2\longxmat.$3
m2ppx $1 math\longxmat.ipp $2\longxmat.$4
m2ppx $1 math\longcomp.dpp $2\longcomp.$3
m2ppx $1 math\longcomp.ipp $2\longcomp.$4
m2ppx $1 math\lcxmath.dpp $2\lcxmath.$3
m2ppx $1 math\lcxmath.ipp $2\lcxmath.$4
#
# Test support
#
m2ppx $1 support\tmathuti.dpp $2\tmathuti.$3
m2ppx $1 support\tmathuti.ipp $2\tmathuti.$4
m2ppx $1 support\tlmathut.dpp $2\tlmathut.$3
m2ppx $1 support\tlmathut.ipp $2\tlmathut.$4
m2ppx $1 support\tconvuti.dpp $2\tconvuti.$3
m2ppx $1 support\tconvuti.ipp $2\tconvuti.$4
