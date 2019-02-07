echo cpp %1 fr %2...
cpp %1 -D%2 -P -imacros D:\USR\INCLUDE\CRYSTAL.M2H > temp
rem x2d1 <temp >%1
copy temp %1
rm temp
