#!make -f
# @(#)hello.mk, hello, SozobonX examples
#
# make file for 'hello' in SozobonX distribution
#

# run the optimizer:
#CFLAGS = -O
# and show everything any binary does
CFLAGS = -VO

# use a different startupcode
LDFLAGS = -s min_s.o

hello.tos: hello.c

#eof
