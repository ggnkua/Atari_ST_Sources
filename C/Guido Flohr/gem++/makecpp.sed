# Quick sed-hack to make automake handle C++.
# Author: Guido Flohr <gufl0000@stud.uni-sb.de>.
# $Revision: 1.3 $

# First change the extender for the deps.
s/%\.c/%\.cc/g

# Then the rest.  Take care not to change ``config.cache'' and so on.
# First followed by a blank ...
s/\.c /\.cc /g
# ... and at the end of line.
s/\.c$/\.cc/g
# Finally the Suffix rule.
s/\.c\.o/\.cc\.o/

# This one's necessary to build dependencies correctly.
s/MKDEP = gcc/MKDEP = g++/g

# Use the right compiler.
s/\$(CC)/\$(CXX)/g

# We don't change the flags.
# s/\$(CFLAGS)/\$(CXXFLAGS)/g

# Other stuff:
s,^\$(srcdir)/Makefile\.in,\$(srcdir)/Makefile\.in\.in,
s,Makefile\.am,Makefile\.in\.am,
s,automake \$(subdir)/Makefile,automake \$(subdir)/Makefile.in,
s,^Makefile: \$(top_builddir),Makefile\.in: \$(top_builddir),
s,config\.status Makefile\.in,config\.status Makefile\.in\.in,

# We need to insert two lines.  Note that we cannot let automake
# do this because it ignores the target completely.
/default: all/ {
a\

a\
Makefile: Makefile.in
a\
\	sed -f makecpp.sed Makefile.in > Makefile
}
