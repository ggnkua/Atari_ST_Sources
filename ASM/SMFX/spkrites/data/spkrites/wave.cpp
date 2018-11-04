/* file wave.cpp */ 

#include <stdlib.h> 
#include <math.h> 
#include <iostream>

int pxa1=0; 
int pxa2=0; 
int pya1=0; 
int pya2=0; 

#define RESX 320 
#define RESY 192 
#define PILEN (360*2) 

#define RX1 ((RESX-16)/4) //76 
#define RX2 ((RESX-16)/4) //76 
#define RY1 ((RESY-16)/4) //44 
#define RY2 ((RESY-16)/4) //44 

#define MNBSPRITE 250 

int	cosTab[PILEN]; 
int	sinTab[PILEN]; 

void	TrigoBuild(void) 
{ 
for (int i=0;i<PILEN;i++) 
{ 
float a = (i * 2.f * 3.1415926f) * (1.f / (float)PILEN); 
cosTab[i] = (int)(32767.f * (float)cos(a)); 
sinTab[i] = (int)(32767.f * (float)sin(a)); 
} 
} 

int	mod(int v,int m) 
{ 
while (v<0) 
v += m; 

return v % m; 
} 

void waveStep(void) 
{ 

int pxb1 = pxa1; 
int pxb2 = pxa2; 
int pyb1 = pya1; 
int pyb2 = pya2; 

for (int i=0;i<MNBSPRITE;i++) 
{ 
int x = (RX1 * cosTab[mod(pxb1,PILEN)] + RX2 * sinTab[mod(pxb2,PILEN)]) >> 15; 
int y = (RY1 * cosTab[mod(pyb1,PILEN)] + RY2 * sinTab[mod(pyb2,PILEN)]) >> 15; 

x += (RESX-16)/2; 
y += (RESY-16)/2; 

// Draw sprite at x,y !! 
	std::cout << (((int)(x/16))*8+y*160) << ";" << x%16 << ";" << x << ";" << y << ";\n";


// Inc angles (during the frame) 
pxb1 += 7*2; 
pxb2 -= 4*2; 
pyb1 += 6*2; 
pyb2 -= 3*2; 
} 

// inc global angles for the frame 
pxa1 += 3*2; 
pxa2 += 2*2; 
pya1 += -1*2; 
pya2 += 2*2; 

} 

int	main(void) 
{ 
TrigoBuild(); 
for (int i=0;i<360;i++) 
{ 
	std::cout << "; step " << i << "\n";
waveStep(); 
} 
} 
