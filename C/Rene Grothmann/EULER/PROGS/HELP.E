.. Help texts.

comment

  *** Builtin functions:
abs acos any arg argn args asin atan band bandmult bin cd ceil char
charpoly chidis color complex conj contour cos count ctext cumprod
cumsum diag diag dup epsilon error errorlevel eval exp extrema fak
fdis fft find flipx flipy floor format framecolor free hb holding
holding ifft im index input interp interpret interpval invnormaldis
invtdis iscomplex isreal jacobi key lineinput linestyle log lu lusolve
mark markerstyle matrix max max mesh meshfactor min min mod mouse name
nonzeros normal normaldis ones pi plot plot polyadd polycons polydiv
polymult polyroot polysolve polytrans polytrunc polyval printf prod
project random re round scale scaling searchfile searchfile setdiag
setepsilon setkey setplot shrink sign sin size solid sort sqrt
stringcompare style sum symmult tan tdis text textcolor textsize time
triangles twosides view view wait window window wire wirecolor zeros 
  *** Commands:
break clear clg cls comment do dump else end endif exec for forget
function global help hexdump hold if list load loop memorydump meta
output quit remove repeat return shg type 
  *** Your functions:
dir window view matrix zeros ones random normal format diag text ctext
splineval spline iterate map broyden gauss gauss10 romberg simpson
secant bisect heun arcosh arsinh cosh sinh totalsum field polyfit hilb
eigennewton eigen1 eigenremove eigenspace1 eigen eigenspace
eigenvalues det image kernel fit inv id framedwire framedsolid
scaleframe frame2 frame1 framexmym framexmyp framexpym framexpyp
framez1 framez0 getframe plotwindow cplot mark plot ygrid xgrid
printscale fplot xmark xplot ticks setplot shrinkwindow fullwindow
textwidth textheight title write writeform polydif length equispace
linspace shortformat longformat reset 

endcomment

function abs
## abs(x) returns the absolute value of x, |x|.
	error("Illegal argument number!"),
endfunction

function acos
## acos(x) returns the arcus cosine of x.
## Works for complex arguments also.
	error("Illegal argument number!"),
endfunction

function argn
## argn() returns the number of arguments of the active function.
	error("Illegal argument number!"),
endfunction

function args
## args(n) returns all arguments of a function from the n-th on.
	error("Illegal argument number!"),
endfunction

function asin
## asin(x) returns the arcus sine of x.
## Works for complex arguments also.
	error("Illegal argument number!"),
endfunction

function atan
## atan(x) returns the arcus tangens of x.
## Works for complex arguments also.
	error("Illegal argument number!"),
endfunction

function band
## band(A,c1,c2) sets all elements a(i,j) of A, for which
## c1 <= j-i <= c2 is not true, to 0.
	error("Illegal argument number!"),
endfunction

function bandmult
## bandmult(A,B) multiplies A with B, but is faster than A.B, if A or B 
## contain many zeros.
	error("Illegal argument number!"),
endfunction

function sin
## sin(x) returns the sine of x.
## Works for complex arguments also.
	error("Illegal argument number!"),
endfunction

function cos
## cos(x) returns the cosine of x.
## Works for complex arguments also.
	error("Illegal argument number!"),
endfunction

function tan
## tan(x) returns the tangens of x.
## Works for complex arguments also.
	error("Illegal argument number!"),
endfunction

function bin
## bin(n,m) returns the "n over m", i.e., n!/(m!*(n-m)!).
	error("Illegal argument number!"),
endfunction

function cd
## cd("") shows the active directory.
## cd("Path") sets the active directory to Path.
	error("Illegal argument number!"),
endfunction

function ceil
## ceil(x) returns the smallest integer n>=x.
	error("Illegal argument number!"),
endfunction

function floor
## floor(x) returns the greatest integer n<=x.
	error("Illegal argument number!"),
endfunction

function char
## char(x) returns a string with a single character with ASCII code x.
	error("Illegal argument number!"),
endfunction

function chidis
## chidis(x,n) returns the chi^2 distribution of x with n degrees of
## freedom, i.e., the probability, that the sum of n normal distributed
## squared random variables is smaller than x.
	error("Illegal argument number!"),
endfunction

function color
## color(n) sets the plotting color to n, returns old color.
	error("Illegal argument number!"),
endfunction

function complex
## complex(a) returns 1, if a is complex.
	error("Illegal argument number!"),
endfunction

function conj
## conj(a) returns the complex conjugate of a.
	error("Illegal argument number!"),
endfunction

function contour
## contour(A,v) plots a contour plot of A at heights equal to the
## elements of v.
	error("Illegal argument number!"),
endfunction

function count
## count(v,n) counts the elements of the vector v in the intervals
## [0,1),[1,2),...,[n-1,n]. Thus a 1xn vector is returned.
	error("Illegal argument number!"),
endfunction

function cumprod
## cumprod(A) returns a matrix of the same size as A, containing
## the cumulative product of the rows of A, i.e.,
## b(i,j) = prod(k=1 to j) a(i,k).
	error("Illegal argument number!"),
endfunction

function cumsum
## cumsum(A) returns a matrix of the same size as A, containing
## the cumulative sum of the rows of A, i.e.,
## b(i,j) = sum(k=1 to j) a(i,k).
	error("Illegal argument number!"),
endfunction

function dup
## dup(v,n) returns a Matrix with n rows, each equal to v.
	error("Illegal argument number!"),
endfunction

function epsilon
## epsilon() returns the internally used epsilon.
## epsilon()=1e-8 is a correct assignment.
## The variable Epsilon is set in "util" to epsilon().
	error("Illegal argument number!"),
endfunction

function pi
## pi() returns pi. The variable Pi is set in "util".
	error("Illegal argument number!"),
endfunction

function error
## error("s") aborts a function and prints the error text s.
	error("Illegal argument number!"),
endfunction

function errorlevel
## errorlevel("s") interprets "s" and returns the error code.
## The error is set to 0. This is a test function.
	error("Illegal argument number!"),
endfunction

function eval
## eval("f",...) evaluates the function f at the points ...
## f must be a user defined function!
	error("Illegal argument number!"),
endfunction

function exp
## exp(x) returns the exponential of x, i.e., e^x.
	error("Illegal argument number!"),
endfunction

function framecolor
## framecolor(n) sets the frame color to n, returns old color.
	error("Illegal argument number!"),
endfunction

function log
## log(x) return the natural logarithm of x.
	error("Illegal argument number!"),
endfunction

function sqrt
## sqrt(x) return the square root of x.
	error("Illegal argument number!"),
endfunction

function extrema
## extrema(A) returns a matrix, containing the rows [min imin max imax].
## min and max are the minima and the maxima of the rows of A.
## imin and imax are the columns where these are obtained.
	error("Illegal argument number!"),
endfunction

function fak
## fak(n) returns n!.
	error("Illegal argument number!"),
endfunction

function fdis
## fdis(x,n,m) returns the F-distribution with n and m degrees of freedom.
	error("Illegal argument number!"),
endfunction

function fft
## fft(v) return the Fourier transform of v, obtained the fast way.
	error("Illegal argument number!"),
endfunction

function find
## find([v1,...,vn],x) finds the index i, such that v(i)<=x<v(i+1).
## Returns 0 if x<v(1) and n if x>v(n).
	error("Illegal argument number!"),
endfunction

function flipx
## flipx(A) flips the matrix such that the last column becomes the first.
	error("Illegal argument nubmer!"),
endfunction

function flipy
## flipy(A) flips the matrix such that the last row becomes the first.
	error("Illegal argument nubmer!"),
endfunction

function free
## free() returns the number of free bytes.
	error("Illegal argument number!"),
endfunction

function ifft
## ifft(v) returns the inverse Fourier transform of v.
	error("Illegal argument number!"),
endfunction

function im
## im(z) returns the imaginary part of z.
	error("Illegal argument number!"),
endfunction

function re
## re(z) returns the real part of z.
	error("Illegal argument number!"),
endfunction

function index
## index() returns the looping index in loops.
	error("Illegal argument number!"),
endfunction

function input
## input("s") prints s and a prompt, than evaluates the user input.
## The input can be any EULER expression, and may contain variables.
	error("Illegal argument number!"),
endfunction

function interp
## interp(x,y,n) computes the polynomial interpolation of degree n
## at the points x with values y. The polynomial is returned in
## the form of divided differences.
	error("Illegal argument number!"),
endfunction

function interpval
## interpval(x,d,t) evaluates the divided differences d at the points t.
## E.g., interpval(x,interp(x,y),x) returns y.
	error("Illegal argument number!"),
endfunction

function invnormaldis
## invnormaldis(y) returns the inverse normal distribution.
## See normaldis.
	error("Illegal argument number!"),
endfunction

function normaldis
## normaldis(x) returns the normal distribution at x; i.e., 
## the probability that a normal distributed unit random variable is
## less than x.
	error("Illegal argument number!"),
endfunction

function invtdis
## invtdis(x,n) returns the invers T-distribution with n degrees of
## freedom. See tdis.
	error("Illegal argument number!"),
endfunction

function tdis
## tdis(x,n) returns the T-distribution with n degrees of freedom,
## i.e. the probability, that a sample of n normal distributed 
## unit random variables scaled with mean value and standard deviation
## of the sample is less than x.
	error("Illegal argument number!"),
endfunction

function isreal
## isreal(x) return 1 if x is real.
	error("Illegal argument number!"),
endfunction

function iscomplex
## iscomplex(x) return 1 if x is not real.
	error("Illegal argument number!"),
endfunction

function jacobi
## jacobi(A) uses the Jacobi algorithm to determine the eigenvalues
## of A. A must be symmetric and real. Returns the vector of eigenvalues.
	error("Illegal argument number!"),
endfunction

function lu
## lu(A) returns a LU-decomposition of A obtained by the Gauss method.
## The result is {lu,ri,ci,det}, where det is the determinant.
## lu contains the lu decomposition in a single matrix.
## ri contains the indices of the rows of lu, since these may have
## been swept.
## ci contains 1 or 0, where 1 marks the linar undependent rows of lu.
## See lusolve also.
	error("Illegal argument number!"),
endfunction

function lusolve
## lusolve(LU,b) solves A.x=b, if LU is a LU-decomposition of A.
	error("Illegal argument number!"),
endfunction

function max
## max(A) contains a column vector with the maxima of the rows of A.
## max(x,y) returns the maximum of x and y.
	error("Illegal argument number!"),
endfunction

function min
## min(A) contains a column vector with the minima of the rows of A.
## max(x,y) returns the maximum of x and y.
	error("Illegal argument number!"),
endfunction

function mesh
## mesh(A) plots a 3-D plot of the the matrix A.
	error("Illegal argument number!"),
endfunction

function mod
## mod(n,m) returns n modulo m.
	error("Illegal argument number!"),
endfunction

function mouse
## mouse() switches to graphics and shows a mouse cursor.
## When the user clicks with the left mouse button the (x,y)-coordinates
## at this point according to the last plot are returned.
	error("Illegal argument number!"),
endfunction

function nonzeros
## nonzeros(v) contains a vector, containing the indices of the nonzero
## elements of v.
	error("Illegal argument number!"),
endfunction

function hb
## hb(A) computes the Hessenberg form of A. Returns {B,r} such that
## band(B(r,r),-1,n) is the Hessenberg form.
	error("Illegal argument number!"),
endfunction

function polyadd
## polyadd(p,q) adds two polynomials p and q.
	error("Illegal argument number!"),
endfunction

function polycons
## polycons([z1,z2,...]) computes a polynomials with zeros in zi.
	error("Illegal argument number!"),
endfunction

function polydiv
## polydiv(p,q) divides two polynomials with remainder. Returns
## {result,remainder}.
	error("Illegal argument number!"),
endfunction 

function polymult
## polymult(p,q) multiplies two polynomials.
	error("Illegal argument number!"),
endfunction

function polyroot
## polyroot(p,z) returns a zero of the polynomial p close to z.
	error("Illegal argument number!"),
endfunction

function polysolve
## polysolve(p) returns a vector with the zeros of p.
	error("Illegal argument number!"),
endfunction

function polytrans
## polytrans(x,d) transforms the divided differences form, return by
## interp to the usual polynomial form.
	error("Illegal argument number!"),
endfunction

function polytrunc
## polytrunc(p) truncates a polynomial to its smallest representation,
## i.e., its length is then the true degree plus 1.
	error("Illegal argument number!"),
endfunction

function polyval(p,x)
## polyval(p,x) returns the value of the polynomial p at x, i.e.
## p(1)+p(2)*x+...+p(n)*x^(n-1).
	error("Illegal argument number!"),
endfunction

function printf
## printf("format",value) returns a string, displaying the value
## with respect to the format in C syntax, e.g.,
## "Zahl = "|printf("%16.10f",x), outputs x in a nice way.
	error("Illegal argument number!"),
endfunction

function project
## project(x,y,z) returns {x1,y1}, which is the projection of the
## coordinates x,y,z to the screen coordinates.
	error("Illegal argument number!"),
endfunction

function prod
## prod(A) returns a vector containing the products of the rows of A.
	error("Illegal argument number!"),
endfunction

function sum
## sum(A) returns a vector containing the sums of the rows of A.
	error("Illegal argument number!"),
endfunction

function symmult
## symmult(A,B) multiplies A with B, and returns a symmetric result.
## I.e., only the upper half of A.B is computed.
	error("Illegal argument number!"),
endfunction

function round
## round(x,n) rounds x to n digits.
	error("Illegal argument number!"),
endfunction

function searchfile
## searchfile("Pattern") searches for a file, matching the pattern.
## searchfile() searches another file matching this pattern.
## Returns "", if there is no (more) such file.
	error("Illegal argument number!"),
endfunction

function scale
## scale(s) scales the gaphic output so that it appears in a
## horizontal/vertical ratio of about s. If s is 0, then the full
## screen is used.
	error("Illegal argument number!"),
endfunction

function setdiag
## setdiag(A,k,v) sets the k-th diagonal of A to v (see diag).
	error("Illegal argument number!"),
endfunction

function setkey
## setkey(n,"text") sets the function key n to produce "text".
	error("Illegal argument number!"),
endfunction

function shrink
## shrink(n) shrinks the memory by n bytes to make space for editors etc.
	error("Illegal argument number!"),
endfunction

function sign
## sign(x) returns the sign of x.
	error("Illegal argument number!"),
endfunction

function size
## size(A) returns the size of the matrix A in form [rows,columns].
## size(A,B,x,C,y,...) returns the size of A,B,C,.. which must agree.
	error("Illegal argument number!"),
endfunction

function solid
## solid(X,Y,Z) plots a solid three dimensional hyperplane with
## coordinates X,Y and Z. All these must be matrizes of the same
## dimensions.
	error("Illegal argument number!"),
endfunction

function sort
## sort(v) sorts the vector v. Returns {vs,i}, such that v(i)=vs;
	error("Illegal argument number!"),
endfunction

function style
## style("s") sets the style of plots and markers.
## For plots, there are ".", "-", "--", "i" (invisible).
## For markers, there are "mx", "m<>", "m.", "m+", "m[]", "m*".
## All other strings reset the default values.
	error("Illegal argument number!"),
endfunction

function markerstyle
## markerstyle("s") sets the style of markers.
## For markers, there are "mx", "m<>", "m.", "m+", "m[]", "m*".
## Return the old setting.
	error("Illegal argument number!"),
endfunction

function linestyle
## linestyle("s") sets the style of plots.
## For plots, there are ".", "-", "--", "i" (invisible).
## Return the old setting.
	error("Illegal argument number!"),
endfunction

function linewidth
## linewidth(n) sets the line width unless n==0.
## Returns the old line width.
	error("Illegal argument number!"),
endfunction

function stringcompare
## stringcompare("string1","string2") compares the two strings.
## Returns 0 if both are equal, 1 if string1 is bigger than string2,
## -1 else.
	error("Illegal argument number!"),
endfunction

function text
## text("string",[c,r]) displays the string at column c and row r
	error("Illegal argument number!"),
endfunction

function textcolor
## textcolor(n) sets the text color to n, returns old color.
	error("Illegal argument number!"),
endfunction

function textsize
## textsize() returns [width,height] of a single character in screen
## coordinates (0..1023,0..1023).
	error("Illegal argument number!"),
endfunction

function time
## time() returns a timer, running in seconds.
	error("Illegal argument number!"),
endfunction

function triangles
## triangles(flag) turns triangle meshing on and off.
	error("Illegal argument number!"),
endfunction

function twosides
## twosides(flag) turns shading in mesh and solid on and off.
	error("Illegal argument number!"),
endfunction

function wait
## wait(n) waits for n seconds, or until a key was pressed.
	error("Illegal argument number!"),
endfunction

function wire
## wire(X,Y,Z) works like solid, exept the plot is a wire frame.
	error("Illegal argument number!"),
endfunction

function wirecolor
## color(n) sets the wire color to n, returns old color.
	error("Illegal argument number!"),
endfunction

.. commands

function break
## break -> breaks a current loop, for, or repeat.
	error("Illegal argument number!"),
endfunction

function clg
## clg -> clears the graphics screen.
	error("Illegal argument number!"),
endfunction

function cls
## cls -> clears the text screen.
	error("Illegal argument number!"),
endfunction

function clear
## clear -> clears the local variables.
## clear variable -> clears the variable.
	error("Illegal argument number!"),
endfunction

function comment
## comment -> searches for a line starting with "endcomment".
	error("Illegal argument number!"),
endfunction

function do
## do function -> does the commands of the function without parameters.
## return returns from do.
	error("Illegal argument number!"),
endfunction

function dump
## dump "file" -> dumps screen output also to a file.
## dump -> stops dumping to file.
	error("Illegal argument number!"),
endfunction

function if
## if ..; ..; else, ..; endif; -> EULER's if construction.
	error("Illegal argument number!"),
endfunction

function global
## global x -> allows the global variable x to be accessed in a function.
	error("Illegal argument number!"),
endfunction

function exec
## exec "file.prg strings" -> executes file.prg (may also be file.tos)
## with parameters in strings.
	error("Illegal argument number!"),
endfunction

function forget
## forget function -> kills the function from memory.
	error("Illegal argument number!"),
endfunction

function for
## for i=0 to 10 step 2; ..; end; -> EULER's for loop.
	error("Illegal argument number!"),
endfunction

function repeat
## repeat; ..; end; -> eternal loop. Abort with break!
	error("Illegal argument number!"),
endfunction

function help
## help function -> prints the help lines of a function.
	error("Illegal argument number!"),
endfunction

function type
## type function -> types the lines of a function.
	error("Illegal argument number!"),
endfunction

function hexdump
## hexdump variable -> prints the hexadecimal content of a variable, i.e.
## the internal representation.
	error("Illegal argument number!"),
endfunction

function hold
## hold on -> holds the current plot.
## hold off -> the next plot will delete the current plot.
## hold -> hold on and notices old holding state; next hold restores it.
	error("Illegal argument number!"),
endfunction

function list
## list -> list the functions.
	error("Illegal argument number!"),
endfunction

function memorydump
## memorydump -> displays all internal objects and their sizes.
	error("Illegal argument number!"),
endfunction

function meta
## meta "filename" -> aktiviert ein Metafile.
## meta; -> deaktiviert das Metafile.
	error("Illegal argument number!"),
endfunction

function output
## output on -> switches output of results on.
## output off -> switches it off. Useful in connection with dump.
## output -> toggles.
	error("Illegal argument number!"),
endfunction

function  quit
## quit -> exits EULER (no verification!)
	error("Illegal argument number!"),
endfunction

function remove
## remove "file" -> kills the file from disk!
	error("Illegal argument number!"),
endfunction

function return
## return x -> exits a function with value x.
	error("Illegal argument number!"),
endfunction

function load
## load "filename" -> loads the commands in the file, as if they were
## input from the console.
	error("Illegal argument number!"),
endfunction

"Online help for builtin functions loading."
"Enter"
">help sin"
"for help on sin."


