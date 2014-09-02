

The purpose of this document is to describe how to use the capabilities
 of the STE to achieve bit-wise fine-scrolling and vertical split screens. Horizontal and vertical scrolling are discussed and an example program is provided. Split screen effects
are discussed and an example program with multiple independent
 scrolling regions is provided. 

Three new registers are provided to implement fine-scrolling and split
 screen displays:
	1) HSCROLL - This register contains the pixel scroll offset.
 If it is zero, this is the same as an ordinary ST.
 If it is non-zero, it indicates which data bits constitute the first 
pixel from the first word of data. That is, the leftmost displayed p
xel is selected from the first data word(s) of a given line by this
 register.
	2) LINEWID - This register indicates the number of extra words 
of data (beyond that required by an ordinary ST at the same resolution) 
which represent a single display line. If it is zero, this is the same 
as an ordinary ST. If it is non-zero, that 
any additonal words of data will constitute a single video line 
(thus allowing virtual screens wider than the displayed screen). 
CAUTION - In fact, this register contains the word offset which the 
display processor will add to the  video display address
to point to the next line. If you are actively scrolling (HSCROLL <> 0)
 this register should contain the additional width of a display line 
minus one data fetch (in low resolution one data fetch would be four 
words, one word for monochrome, etc.)

	3) VBASELO - This register contains the low-order byte of the 
video display base address. It can be altered at any time and will 
affect the next display processor data fetch. It is recommended that 
the video display address be altered only during ve
tical and horizontal blanking or display garbage may result.
	These registers, when used in combination, can provide several 
video effects. In this document we will discuss only fine-scrolling 
and split-screen displays.

Fine Scrolling: 
Many games use horizontal and vertical scrolling techniques to provide 
virtual playfields which are larger than a single screen. 
We will first discuss vertical scrolling (line-wise), 
then horizontal scrolling (pixel-wise) and finally the example prog
am "neowall.s" which combines both.
Vertical Scrolling: To scroll line-wise, we simply alter the video 
display address by one line each time we wish to scroll one line. 
This is done at vertical blank interrupt time by writing to the three 
eight-bit video display address registers to d
fine a twenty-four-bit pointer into memory. Naturally, additional 
data must be available to be displayed. We might imagine this as a tall,
 skinny screen which we are opening a window onto for the user. The video 
display address registers define where
this window will start.
Horizontal Scrolling: To scroll horizontally we might also adjust the 
video display address. If that was all we did, we would find that the 
screen would jump sideways in sixteen pixel increments. To achieve smooth
 pixel-wise scrolling we must use th
 HSCROLL register to select where within each sixteen pixel block we wish
 to start displaying data to the screen. Finally, we must adjust the 
LINEWID register to reflect both the fact that each line of video data
 is wider than a single display line a
d any display processor fetch incurred by a non-zero value of HSCROLL.
 All this is done at vertical blank interrupt time. Naturally, additional 
data must be available to be displayed. We might imagine this as an 
extremely wide screen which we are ope
ing a window onto for the user. These registers define where this window 
will start. 
For Example: The program "neowall.s" reads in nine NEOchrome¿ picture 
files, organizes them into a three by three grid and allows the user to 
scroll both horizontally and vertically over the images. The heart of this 
program (the only interesting th
ng about it actually) is the vertical blank interrupt server. 
This routine first determines the pixel offset and loads it into HSCROLL. 
The LINEWID register is now set to indicate that each virtual line is three 
times longer than the actual display width
If we are actively scrolling, this amount is reduced to reflect the 
additional four-plane data fetch which will be caused by the scrolling. 
Finally the video display address is computed to designate a window 
onto the grid of pictures. This twent
-four-bit address determines where the upper-left corner of the displayed 
region begins in memory. Thus, every frame an arbitrary portion of the 
total image is selected for display. The speed and resolution of this 
scrolling technique is limited only
by the dexterity of the user.

Split Screen: 
In many applications it is desirable to subdivide the screen into 
several independent regions. On the STE you may reload some video 
registers on a line-by-line basis (using horizontal blanking interrupts) to 
split the screen vertically into multiple 
ndependent regions. A single screen no longer need be a contiguous block of 
storage, but could be composed of dozens of strips which might reside in 
memory in any order. The same data could be repeated on one or more display 
lines. Individual regions
might each have their own individual data and scrolling directions.
For Example: The program "hscroll.s" reads in a NEOchrome¿ picture file 
and duplicates each line of the image. This, combined with the proper use 
of LINEWID, effectively places two copies of the same picture side-by-side. 
Next, both vertical and hor
zontal blanking interrupt vectors are captured and the horizontal blanking 
interrupt is enabled in counter mode. To prevent flicker caused by keyboard 
input, the IKBD/MIDI interrupt priority is lowered below that of the HBL 
interrupt. Note that the p
ogram 'main loop' doesn't even call the BIOS to check the keyboard, since 
the BIOS sets the IPL up and causes flicker by locking out horizontal 
interrupts - this may cause trouble for programs in the real world. 
The screen is effectively divided into
ten regions which scroll independently of one another. There are two 
ten-element arrays which contain the base address of each region and its 
current scroll offset. At vertical blank interrupt time we compute the 
final display values for each region 
n advance and store them into a third array. We then initialize the display 
processor for the first region and request an interrupt every twenty lines 
(actually every twenty horizontal blankings). During each horizontal 
interrupt service, we quickly 
eload the video display address registers and the HSCROLL register. 
This must be done immediately - before the display processor has time to 
start the current line or garbage may result. Note that horizontal blank 
interrupts are triggered by the disp
ay processor having finished reading the previous data line. You have 
approximately 144 machine cycles to reload the HSCROLL and video display 
registers before they will be used again by the display processor. 
Finally, the LINEWID register is set, th
s need only be done before the processor finishes reading the data for 
the current display line. We then pre-compute the data we will need for 
the next horizontal interrupt to shave few more cycles off the critical 
path and exit.
ne immediately - before the display processor has time to start the 
current line or garbage
