<?php

	$orBucketSizes = array(-64,-88,-104,-112,-120,-120,-128,-136,-136,-136,-134,-128,-128,-118,-110,-90);
	$orBucketTimes = array(20,25,25,23,26,26,24,24,28,24,23,25,28,25,25,24);



	$moveBucketSizes = array(-64,-88,-104,-112,-120,-120,-128,-128,-128,-128,-128,-122,-122,-114,-106,-90);
	$moveBucketTimes = array(10,9,8,8,8,9,8,9,9,10,8,11,7,7,9,8);


	$bannedLines = array();

	$maxMoveList = array();
	$maxOrList = array();
	for($a=0;$a<16;$a++)
	{	
		$maxMoveList[$a] = 0;
		$maxOrList[$a] = 0;
	}

	for($i=0;$i<360;$i++){
		echo "moveframe" . $i . "\n";
		$fileIndex = $i;
		// open file handle
		$frameNumber = str_pad(($fileIndex%360), 3, '0', STR_PAD_LEFT);
		$fileName= "results_". $frameNumber . ".json";
		$curFile = json_decode(file_get_contents($fileName),true);	
		$resultList = array();
		for($b=0; $b<16; $b++){
			$resultList[$b] = array();
		}
		$count = 0;
		foreach($curFile['masks'] as $key => $entry){
			$x = $entry['x'];
			$y = $entry['y'];
//			echo ";" . $entry['id'] . ":" . $x . "," . $y . "\n";
			$spriteIndex = $x%16;
			$xOff = (($x-$spriteIndex)/16)*8;
			$yOff = $y*160;
			$offset = $xOff + $yOff;
			$resultList[$spriteIndex][] = $offset;
			$bannedLines[] = $entry['lif'];				
		}
		for($b=0; $b<16; $b++){
			sort($resultList[$b]);
		}

		$prevVal = 0;
		for($b=0; $b<16; $b++){
			if(count($resultList[$b])>$maxMoveList[$b]){
				$maxMoveList[$b] = count($resultList[$b]);
			}
//			echo ";moves" . $b ."\n" ;
//			echo "\tdc.l\tsprite" .$b. "move-" . -count($resultList[$b])*$moveBucketSizes[$b] . "\t;\t" . count($resultList[$b]) . "\n";

			$iteration_size= -$moveBucketSizes[$b];									// whats the size of 1 iteration
			$iteration_times = $moveBucketTimes[$b];
			$complete_size = ($iteration_size*$moveBucketTimes[$b]);

			$draw_times = count($resultList[$b]);
			$iterations_skipped = ($iteration_times - $draw_times);

			$skipSize = ($iterations_skipped * $iteration_size);

			$off = $skipSize;
			// bucketsize - currentsize
			// 

			echo "\tdc.w\t" . $off . "\t;\t" . count($resultList[$b]) . "\n";
			foreach($resultList[$b] as $offset){
				echo "\tdc.w\t" . ($offset-$prevVal). "\n";
				$prevVal = $offset;
			}
		}
	}

//	echo "---\n";
	$resultList2 = array();
	$lines = file("wave268.txt");
	for($i=2;$i<362;$i++){
		echo "orframe" . ($i-2) . "\n";
		$f=($i%360)*269;					// frame 0 = 0..268	= 269 entries, so 269 is next
		$f++;

		$resultList = array();
		for($b=0; $b<16; $b++){
			$resultList2[$b] = array();
		}

		for($c=0;$c<268;$c++){
			$ln = $c+$f;			// currentline number
			if(!in_array($ln,$bannedLines)){
				$curLine = $lines[$ln];
				$lineArray = explode(";",$curLine);
				$x = $lineArray[2];
				$y = $lineArray[3];
//				echo ";" . $c . ":" . $x . "," . $y . "\n";
				$spriteIndex = $x%16;
				$xOff = (($x-$spriteIndex)/16)*8;
				$yOff = $y*160;
				$offset = $xOff + $yOff;
				if($offset==0){
//					echo "!!!!!!!!!!!!!!\n";
//					echo $curLine;
				}
				$resultList2[$spriteIndex][] = $offset;
			}
		}
		for($b=0; $b<16; $b++){
			sort($resultList2[$b]);
		}
		$prevVal = 0;
		for($b=0; $b<16; $b++){
			if(count($resultList2[$b])>$maxOrList[$b]){
				$maxOrList[$b] = count($resultList2[$b]);
			}
//			echo ";ors" . $b ."\n" ;
//			echo "\tdc.l\tsprite" . $b ."-". -count($resultList2[$b])*$orBucketSizes[$b] . "\t;\t" . count($resultList2[$b]) . " + move: " . count($resultList2) . "\n";


			$iteration_size= -$orBucketSizes[$b];									// whats the size of 1 iteration
			$iteration_times = $orBucketTimes[$b];
			$complete_size = ($iteration_size*$orBucketTimes[$b]);

			$draw_times = count($resultList2[$b]);
			$iterations_skipped = ($iteration_times - $draw_times);

			$skipSize = ($iterations_skipped * $iteration_size);

			$off = $skipSize;


			echo "\tdc.w\t" . $off . "\t;\t" . count($resultList2[$b]) . " + move: " . count($resultList2) . "\n";
			foreach($resultList2[$b] as $offset){
				echo "\tdc.w\t" . ($offset-$prevVal). "\n";
				$prevVal = $offset;
			}
		}		
	}

//	print_r($maxMoveList);
//	print_r($maxOrList);

?>