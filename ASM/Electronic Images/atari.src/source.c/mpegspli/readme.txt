This program splits an ISO 11172-1 System layer stream into its
component elemental streams.

Usage splitmpeg [-qv] system_layer_file_name
Options are:
	-q  process quietly. Nothing should be written to stdout.
    -v  Print Pack SCR and mux rate info for each pack.

Elemental stream files
stm188.mpg is a reserved stream.
stm189.mpg is private stream 1.
stm190.mpg is the padding stream.
stm191.mpg is private stream 2.
stm192.mpg to stm223.mpg are audio streams.
stm224.mpg to stm239.mpg are video streams. 

Some parts of this source has been derived from the Berkeley MPEG Video
player. Last time I looked this could be obtained from toe.cs.berkeley.edu

Comments and suggestions are welcome.
For the present (22 of June 1994) I can be contacted via 
Email: michael@ecel.uwa.edu.au
Post: P.O. Box 506, NEDLANDS WA 6009, AUSTRALIA

Updates to this source will first appear on
decel.ecel.uwa.edu.au in the /users/michael directory
This machine may change name within the next 6 months.

