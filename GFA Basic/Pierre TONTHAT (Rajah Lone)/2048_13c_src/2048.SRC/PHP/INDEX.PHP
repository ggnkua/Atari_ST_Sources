<?php header('Content-type: text/html; charset=UTF-8'); ?>
<html>
<head>
<title>Atari ST 2048 online highscores</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>

<body bgcolor="#ffffff" text="#000000" link="#0040B0" vlink="#0040B0" alink="#8888B0">
<center><table cellpadding="5" cellspacing="1" border="1">
<tr>
<th>Rank</th>
<th>Score</th>
<th>Nickname</th>
<th>Location</th>
<th>Version</th>
<th>Date</th>
</tr>
<?php
require('../includes/config.php'); 

$DBTable = "game_2048";

date_default_timezone_set("Europe/Paris");

$link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

if ($link > 0)
{
	$res = mysqli_query($link, "SELECT * FROM $DBTable ORDER BY score DESC LIMIT 100 ") or die (mysqli_error($link));
	
	$rank = 1;
	
	while($col = mysqli_fetch_array($res))
	{    
		echo "<tr><td align=\"right\"><nobr>";
		echo $rank;
		echo "</nobr></td><td align=\"right\"><nobr>";
		echo $col["score"];
		echo "</nobr></td><td align=\"left\"><nobr>";
		echo $col["nickname"];
		echo "</nobr></td><td align=\"left\"><nobr>";
		echo $col["location"];
		echo "</nobr></td><td align=\"left\"><nobr>";
		echo $col["version"];
		echo "</nobr></td><td align=\"left\"><nobr>";
		echo date("m-d-Y H:i", strtotime($col["moment"]));
		echo "</nobr></td></tr>";
		
		$rank += 1;
  	}
  	
	mysqli_free_result($res);
	
	mysqli_close($link); 
}
else 
{
	echo "no database connection";
}
?></table></center></body>
</html>

