# bouga bouga humbilibili

import struct

pal = [ 0, 8, 1, 9, 2, 10, 3, 11, 4, 12, 5, 13, 6, 14, 7, 15 ]

f   = file("rasters.tga", "rb")
inp = f.read()
f.close()

dat = inp[18:]
print len(dat)

out = ''
idx = 0
for y in range (0, 200):
  for x in range(0, 20):
    b,g,r,a = struct.unpack('BBBB',dat[idx:(idx+4)])
    nb      = b >> 4
    ng      = g >> 4
    nr      = r >> 4
    if (x ^ y) & 1:
      if (b & 8) and nb < 15:
        nb   += 1
      if (g & 8) and ng < 15:
        ng   += 1
      if (r & 8) and nr < 15:
        nr   += 1
    rgb     = (pal[nr]<<8) | (pal[ng]<<4) | pal[nb]
    out    += struct.pack('>H',rgb)
    idx    += 4

f = file('RASTERS.INL', 'wb')
f.write(out)
f.close

print 'ok'
