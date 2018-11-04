<?php
	$nr_files = 50;														// nr of files
	$basename = "9/out.gif";													// relpath + filename base

	$width = 64;
	$height = 40*$nr_files;


//	for($i=0; $i<$nr_files; $i++){
//		$fileName = $basename . str_pad($i,5,0,STR_PAD_LEFT) . ".gif";		// determine name
		$image = imagecreatefromgif($basename);
//		$uniques = array();

		for($y=0;$y<$height;$y++){
//			echo "\tdc.b\t0,0,0,0,";
			echo "\tdc.b\t";

			for($x=0;$x<$width;$x++){
				if($x!=0){
					echo ",";
				}
				$col = imagecolorat($image, $x , $y);
				if($col==""){
					echo "0";
				}
				else{
					echo $col*4;
				}
			}
			echo ",0,0,0,0\n";
		}
//		echo "\n\n";
//	}

//	print_r($uniques);


?>
