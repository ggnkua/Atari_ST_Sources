#-----------------------------------------------------------
# Targa bitmap file loader
# Copyright (C) Tobe 2003
#-----------------------------------------------------------
# Load targa .tga bitmaps
#-----------------------------------------------------------
# tga2inl.py - Copyright (C) Tobe 2003
#-----------------------------------------------------------

import struct
from   array  import array




#-----------------------------------------------------------
class targa:
#-----------------------------------------------------------

   topdown  = 0x20
   bottomup = 0x00

   #--------------------------------------------------------
   def __init__ ( self, f =None ):
   #--------------------------------------------------------

      self.width   = 0
      self.height  = 0
      self.depth   = 0
      self.order   = 0

      self.data    = array('B')

      if f:
          self.load(f)

   #--------------------------------------------------------
   def load ( self, f ):
   #--------------------------------------------------------

      hdr         = f.read(18)
      width, height, depth, order = struct.unpack('<12xHHBB', hdr)
      self.width  = width
      self.height = height
      self.depth  = depth >> 3
      self.order  = order & 0x20

      size        = self.width * self.height * self.depth
      self.data.fromfile(f, size)

   #--------------------------------------------------------
   def getsize ( self ):
   #--------------------------------------------------------

      return (self.width, self.height)

   #--------------------------------------------------------
   def getdepth ( self ):
   #--------------------------------------------------------

      return self.depth

   #--------------------------------------------------------
   def getordering ( self ):
   #--------------------------------------------------------

      return self.order




#--------------------------------------------------------
if __name__ == '__main__':
#--------------------------------------------------------

   print 'read'
   f   = file('one.tga', 'rb')
   tga = targa(f)
   f.close()

   print 'convert & save'
   width, height = tga.getsize()
   print width, height
   idx = 0
   f   = file('one.inl', 'wb')
   for y in range(0, height):
      for x in range(0, width):
         f.write(struct.pack('B', tga.data[idx]))
         idx += 3
   f.close()

   print 'ok'
