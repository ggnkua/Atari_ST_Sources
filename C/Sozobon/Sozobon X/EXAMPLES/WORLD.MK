#!make -f
# @(#)world.mk, world, SozobonX examples
#
# make file for 'world', in SozobonX distribution
#

# run the optimizer:
CFLAGS = -O

# use the complete std library (including floating point support)
# and run the optimizer
#CFLAGS = -O -f

# use math library and the complete std library (including floating point support)
LDFLAGS = -lm

world: world.tos world2.tos

world.tos: world.c

world2.tos: world2.c


