<?php

require("../includes/config.php");

$DBTable = "game_2048";

date_default_timezone_set("Europe/Paris");

$avant = array ("'");
$apres = array (" ");

$score = intval($_POST['score']);
$key = intval($_POST['key']);
$nickname = str_replace($avant, $apres, $_POST['nickname']); if (strlen($nickname) > 56) { $nickname = substr($nickname, 0, 56); }
$location = str_replace($avant, $apres, $_POST['location']); if (strlen($location) > 56) { $location = substr($location, 0, 56); }
$version = str_replace($avant, $apres, $_POST['version']); if (strlen($version) > 56) { $version = substr($version, 0, 56); }
$magic = $_POST['magic'];

if (($magic === "atari2048") && (strlen($nickname) > 0) && ($score > 0))
{
  $link = mysqli_connect($DBHost, $DBUser, $DBPass, $DBName); mysqli_set_charset($link, "utf8");

	$res = mysqli_query($link, "SELECT clef FROM $DBTable WHERE nickname = '$nickname' AND clef = $key ") or die (mysqli_error($link));

  $nombre = mysqli_num_rows($res);

	mysqli_free_result($res);

  if ($nombre == 1)
  {
    $exe = mysqli_query($link, "UPDATE $DBTable SET score = $score, location = '$location', version = '$version' WHERE nickname = '$nickname' AND clef = $key AND score < $score ") or die (mysqli_error($link));
  }
  else if ($nombre == 0)
  {
    $exe = mysqli_query($link, "INSERT INTO $DBTable (score, nickname, location, version, clef) VALUES ($score, '$nickname', '$location', '$version', $key) ") or die (mysqli_error($link));
	}

	if ($exe) { echo "OK"; } else { echo "UNCHANGED"; }

	$res = mysqli_query($link, "SELECT * FROM $DBTable ORDER BY score DESC ") or die (mysqli_error($link));

  $nombre = mysqli_num_rows($res);

	if ($nombre > 100)
	{
		$rank = 1;
		$keep = 0;
		while(($col = mysqli_fetch_array($res)) && ($keep == 0))
		{
			if ($rank == 100) { $keep = $col["score"]; }

			$rank +=1;
		}
		if ($keep > 0)
		{
    	$exe = mysqli_query($link, "DELETE FROM $DBTable WHERE score < $keep ") or die (mysqli_error($link));
		}
	}

	mysqli_free_result($res);

	mysqli_close($link);
}
else
{
	echo "FAILED";
}
echo "\r\n";
?>
