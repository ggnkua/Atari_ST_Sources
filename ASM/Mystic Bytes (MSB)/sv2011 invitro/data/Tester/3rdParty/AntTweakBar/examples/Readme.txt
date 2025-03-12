Compiled versions of the examples for 32-bit and 64-bit systems can be found in 
the examples/bin32 and examples/bin64 directories.

Under GNU/Linux and OSX, you may need to rebuild the library and the examples. 
To do so, under GNU/Linux, open a terminal, go in the src directory and type 
make, then go in the examples directory and type make. Under OSX do the same
but type make -f Makefile.osx instead of make.

To recompile the examples you also need the following external libraries:

- GLFW : http://glfw.sourceforge.net - for convenience a Windows version is
         included in the examples directory
 
- GLUT : http://opengl.org/resources/libraries/glut 
         the windows version can be found at 
         http://www.xmission.com/~nate/glut.html
 
- SDL  : http://www.libsdl.org

- SFML : http://www.sfml-dev.org
 
- DirectX SDK if you want to recompile the Windows library & DX examples
  http://msdn.microsoft.com/directx

