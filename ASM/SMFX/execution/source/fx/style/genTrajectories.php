<?php
	// we have a system to solve:
	//	origin = x_s,y_s
	//	x_s = 159
	//	y_s = 99

	// per 2x2 block, we get a destination (where its supposed to land):
	//	destination = x_d,y_d

	// block trajectory follows lineair x
	// and hyperbole y
	// 	so we have	y_velocity = y_impuls - y_accel * t
	//	y_position = y_s + y_impuls * t - y_accel * t^2
	//	y_position cannot be > 199

	// we generate random y_impuls and y_accel


	function checkValues($impuls, $acceleration, $start, $end){
		$cur = $start;
		while(true){
			$cur -= $impuls;			
			$impuls -= $acceleration;
			if($cur < -4*160){
				return false;
			}
			if($cur == $end){
				return true;
			}
			if($cur > $end){
				return false;
			}

		}
	}

	function getCounter($impuls,$acceleration,$start,$end){
		$counter = 2;
		$cur = $start;

		while(true){
			$cur -= $impuls;
			$impuls -= $acceleration;
			if($cur == $end){
				return $counter;
			}
			$counter++;
		}
	}


	function fractionToBit($value){
		if($value > 0 ){
			$fraction = $value - floor($value);
		}
		else{
			$value = -$value;
			$fraction = $value - floor($value);			
		}
		$divisor = 1;
		$bitstring = "";
		for($i=0;$i<16;$i++){
			$divisor /= 2;
			if($fraction >= $divisor){
				$fraction -= $divisor;
				$bitstring .= "1";
			}
			else{
				$bitstring .= "0";
			}
		}
		return $bitstring;
	}

	$done = false;
	$values = array();
	$myend = 198;
	$mystartx = 159;		
	$mystarty = 100;
	$dest_x = 0;

			$countvals = 0;

	while(!$done){
		$accel = rand(1,8);
		$imp = rand(5,31);
		if(checkValues($imp,$accel,$mystarty,$myend)){

			$result = array();
			$result['a'] = $accel;
			$result['i'] = $imp;
			$result['t'] = getCounter($imp,$accel,$mystarty,$myend);


			$values[] = $result;
			$countvals++;
			if($countvals%160 == 0){
				$myend -= 2;
			}
			if($countvals == 160*10)
			{
				$done = true;
			}
		}
	}

		$counter = 0;
	foreach($values as $entry){
		$steps = $entry['t'];
		$dx = $dest_x - $mystartx;
		$dxdy = $dx/$steps;
		$values[$counter]['x'] = $dxdy;

		$counter +=1;
		$dest_x += 2;
		if($counter%160 == 0){
			$dest_x = 0;
		}
	}

	foreach($values as $entry){
		$string = "\tdc.w\t";
		$string .= $entry['t'];
		$string .= "," . $entry['i'] . "*160";
		$string .= "," . $entry['a'] . "*160";
		if($entry['x'] > 0){
			$string .= "," . (int)($entry['x']) . ",%" .  fractionToBit($entry['x']);
		}
		else{
			$string .= "," . (int)($entry['x']) . ",%" .  fractionToBit($entry['x']);			
		}
		$string .= "\n";
		echo $string;
	}


?>