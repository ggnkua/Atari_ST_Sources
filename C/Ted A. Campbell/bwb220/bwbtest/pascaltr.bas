100   dim pascal(14,14)
110   pascal(1,1) = 1
120   for i = 2 to 14
130           pascal(i,1) = 1
140           for j = 2 to i
150                   pascal(i,j) = pascal(i-1,j)+pascal(i-1,j-1)
160           next j
170   next i
180   for i = 1 to 14
190           print i-1; ": ";
200           for j = 1 to i
210                   print pascal(i,j);
220           next j
230           print 
240   next i
250   end
