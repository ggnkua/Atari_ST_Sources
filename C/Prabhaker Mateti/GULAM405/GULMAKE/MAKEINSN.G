# Makefile for GNU C compiler.    
#   Copyright (C) 1987 Free Software Foundation, Inc.

#This file is part of GNU CC.

#GNU CC is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY.  No author or distributor
#accepts responsibility to anyone for the consequences of using it
#or for whether it serves any particular purpose or works at all,
#unless he says so in writing.  Refer to the GNU CC General Public
#License for full details.

#Everyone is granted permission to copy, modify and redistribute
#GNU CC, but only under the conditions described in the
#GNU CC General Public License.   A copy of this license is
#supposed to have been given to you along with GNU CC so you
#can know your rights and responsibilities.  It should be in a
#file named COPYING.  Among other things, the copyright notice
#and this notice must be preserved on all copies.

# Run this file in gulam after 'make -f makegen' to generate the
#  various files from the machine description.

echo 'genconfi.ttp     md > insn-con.h'
genconfi.ttp     md > insn-con.h
echo 'genflags.ttp     md > insn-fla.h'
genflags.ttp     md > insn-fla.h
echo 'gencodes.ttp     md > insn-cod.h'
gencodes.ttp     md > insn-cod.h
echo 'genemit.ttp      md > insn-emi.c'
genemit.ttp      md > insn-emi.c
echo 'genrecog.ttp     md > insn-rec.c'
genrecog.ttp     md > insn-rec.c
echo 'genextra.ttp     md > insn-ext.c'
genextra.ttp     md > insn-ext.c
echo 'genpeep.ttp      md > insn-pee.c'
genpeep.ttp      md > insn-pee.c
echo 'genoutpu.ttp     md > insn-out.c'
genoutpu.ttp     md > insn-out.c
echo 'end of makeinsn.g'
