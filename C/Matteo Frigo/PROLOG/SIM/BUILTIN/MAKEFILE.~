# 
# /**********************************************************************
# *									*
# * The SB-Prolog System						*
# * Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
# *									*
# ***********************************************************************/
# 
# /*-----------------------------------------------------------------
# SB-Prolog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY.  No author or distributor
# accepts responsibility to anyone for the consequences of using it
# or for whether it serves any particular purpose or works at all,
# unless he says so in writing.  Refer to the SB-Prolog General Public
# License for full details.
# 
# Everyone is granted permission to copy, modify and redistribute
# SB-Prolog, but only under the conditions described in the
# SB-Prolog General Public License.   A copy of this license is
# supposed to have been given to you along with SB-Prolog so you
# can know your rights and responsibilities.  It should be in a
# file named COPYING.  Among other things, the copyright notice
# and this notice must be preserved on all copies. 
# ------------------------------------------------------------------ */
CFLAGS = -c -g
OBJ1   = arith.o buffer.o builtin.o compare.o file.o init_branch.o meta.o
OBJ2   = name.o other.o saverest.o structure.o substuff.o time.o tio.o token.o stlookup.o
OBJS   = $(OBJ1) $(OBJ2)
HS     = builtin.h ../aux.h ../sim.h

builtin : $(OBJS) 
	ld -o builtin -r $(OBJS) -lm
clean:
	rm $(OBJS)

arith.o : arith.c $(HS)
	cc $(CFLAGS) arith.c
buffer.o : buffer.c $(HS)
	cc $(CFLAGS) buffer.c
builtin.o : builtin.c $(HS) 
	cc $(CFLAGS) builtin.c
compare.o : compare.c $(HS)
	cc $(CFLAGS) compare.c
file.o  : file.c $(HS)
	cc $(CFLAGS) file.c
init_branch.o : init_branch.c $(HS) 
	cc $(CFLAGS) init_branch.c
meta.o  : meta.c $(HS)
	cc $(CFLAGS) meta.c
name.o  : name.c $(HS)
	cc $(CFLAGS) name.c
other.o : other.c $(HS)
	cc $(CFLAGS) other.c
saverest.o : saverest.c ../sim.h ../aux.h 
	cc $(CFLAGS) saverest.c
structure.o : structure.c $(HS)
	cc $(CFLAGS) structure.c
substuff.o : substuff.c ../sim.h
	cc $(CFLAGS) substuff.c
time.o  : time.c $(HS)
	cc $(CFLAGS) time.c
tio.o   : tio.c $(HS)
	cc $(CFLAGS) tio.c
token.o : token.c $(HS)
	cc $(CFLAGS) token.c
stlookup.o: $(HS) stlookup.c
	cc $(CFLAGS) stlookup.c
