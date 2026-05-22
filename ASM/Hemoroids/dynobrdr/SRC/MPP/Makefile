# @see http://www.imagemagick.org/Usage/quantize/
# Dither : None | FloydSteinberg | Riemersma
mpp:
	convert pics/$(ARGV).png -colors 256 -dither Riemersma /tmp/$(ARGV)256.png
	convert pics/$(ARGV).png -colors  15 -dither Riemersma /tmp/$(ARGV)16.png
	php mpp.php $(ARGV)
