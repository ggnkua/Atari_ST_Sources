# ===========================================================
#
# Project Description File
#
# ===========================================================
# First part (optional) : $REP specifies the directory (le
# r‚pertoire!) to load the files from. This $REP directive
# may occur several times in the file.
#
$REP A:\EXAMPLES\
#
# ===========================================================
# Second part (optional) :
# C source files to load for HiSoft C to load.
# No more than 8 C files may be loaded/
# The list of files must be entered after the $C directive
# one file per line.
$C
fill.c
#
# ===========================================================
# Third stage (optional) :
# Machine code files to load
# Note that their format is special and is not that of standard
# executable files.
# See the HiSoft C manual for details.
# No more than 200 (!) may be loaded
# The list of files must be entered after the $C directive
# one file per line.
#
# $32 indicates that the functions return a 32 bit value
# (char, short,int or long).
# $64 indicates that the functions return a 64 bit double
# value
#
$ASM
$32
fill.cod
