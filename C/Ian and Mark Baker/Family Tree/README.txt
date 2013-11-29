Family Tree source
------------------
Here is the source code for Family Tree.

We developed it using Lattice C 5. I don't think there's anything in it
that's specific to Lattice C, and any compiler with reasonably
complete GEM libraries should work.

The Lattice C project file genph.prj is I think the one you
want. gen.prj didn't use precompiled headers and appears to be very
out of date, with many of the files not listed. I'm not sure what the
other .prj files are for. The makefile fam_tree.mak has never been
used in anger and is even more out of date. If you want to use another
compiler, all the .c files in here shoudl be included in the build.

I think fam_tree.ref is the index output from the ST Guide help
compiler. I don't have the input (or the actual text output) to it 
available at the moment, I'll put them here at some point in future.

gen.rsc is the main resource file of course. gen_8x8.rsc is an
alternative one that's used where the system font is 8x8, e.g. ST
Medium res.

Sorry about the poor choice of file names; in retrospect having GEN on
the front of all of them was a silly idea, but we didn't think there
would be nearly so many when we started out!

I don't currently have access to an Atari, let alone a copy of Lattice
C, so most of the above is from memory.

 - Mark Baker, 1 April 2008
