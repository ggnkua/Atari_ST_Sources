# GULAM-Script for processing m2-files with preprocessor commands.
# Output is a file, which can be compiled by a m2-compiler
# 
# 
# Environment variables:
#  PATH:   must contain the directories, where the programs can be found
#  GNUINC: full path, where the GNU-C-preprocessor searches for include files
#  TEMP:   directory for temporary files (RAM-disk or so)
#
# Parameters:
#  $1: Name that identifies the compiler, e.g. LPRM2, HM2,...--see PORTAB.M2H
#      for valid names
#  $2: Inputfile, m2 source code with preprocessor commands
#  $3: Outputfile, m2 source code
#
# Programs: (all programs have to be in a directory mentioned in PATH)
#  cpp:  the preprocessor (gcc-cpp.ttp or gcc.ttp)
#  x2d1: removes multiple blank lines and does LF->CR/LF translation
#  rm:   removes the temporary file
#
# Switches:
#  -undef: no predefined (non-standard) macros
#  -P: removes sync lines (for the C-compiler) from cpp output
#  -D<name>: defines the M2-compiler
#  -imacros <file>: full path of file PORTAB.M2H.
#       NOTE: This was -i in versions 1.X of the GNU-C-preprocessor
#
# Sample call (in gulam): m2ppx LPRM2 file.ipp m:\file.mod
#
echo $2
cpp -undef -P -D$1 -imacros e:\m2\posix\include\portab.m2h $2 ${TEMP}\cpp_tmp.999
x2d1 <${TEMP}\cpp_tmp.999 >$3
rm ${TEMP}\cpp_tmp.999

