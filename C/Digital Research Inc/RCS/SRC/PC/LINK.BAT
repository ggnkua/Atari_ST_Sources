erase rcs.app
erase *.lst
plink86 @rcs > link.err
type link.err
pmapsym < rcs.lst > rcs.sym
