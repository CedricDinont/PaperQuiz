<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

        $quiz = Quiz::getQuizById($_GET['quiz-id']);

function generateQuestionsTable($minQuestion, $maxQuestion) {
  echo "<table border>
   <tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th></tr>";
  for ($question = $minQuestion; $question <= $maxQuestion; $question++) {
    echo "<tr><td>Q".$question."</td>";
    $offset_line = 5;
    if ($question > 40) {
      $offset_column = 5;
    } else {
      $offset_column = 0;
    }
    for ($j = 0; $j < 5; $j++) {
      generateCheckBoxCell((($question % 40) + $offset_line - 1) * 10 + $offset_column + $j);
    }
    echo"</tr>";
 }
 echo "</table>";
}

function generateLoginTable($minDigit, $maxDigit) {
  echo "<table border><tr><th>&nbsp;</th>";
  for ($digit = $minDigit; $digit <= $maxDigit; $digit++) {
    echo "<th>".$digit."</th>";
  }
  echo "</tr>";
  for ($i = 1; $i <= 5; $i++) {
    echo "<tr><td>C".$i."</td>";
    for ($j = 0; $j < 5; $j++) {
      generateCheckBoxCell(($i - 1) * 10 + $minDigit + $j);
    }
    echo "</tr>";
  }
  echo "</table>";
}

function generateCheckBoxCell($mr_data_nb) {
  global $mr_data;
 
  echo "<td><input type=\"checkbox\" name=\"mr_data[".$mr_data_nb."]\" ";
  if (isset($mr_data[$mr_data_nb]) && (strcmp($mr_data[$mr_data_nb], "1") == 0)) {
    echo "checked";
  }
  echo " onchange=\"changed = true;\"></td>";
}

function loadMrFile($filename) {
  global $mr_data;

  $lines = file($filename);
  $n = 0;
  foreach ($lines as $line_nb => $line) {
    $line_data = explode(" ", $line);
    // echo count($line_data);
    unset($line_data[count($line_data) - 1]);
    //echo count($line_data);
    foreach ($line_data as $key => $value) {
      if (isset($value))
	$mr_data[$n++] = $value;
    }
  }
}

function saveMrFile($filename) {
   global $_POST;

  $f = fopen($filename, "w");
  for ($i = 0; $i < 450; $i++) {
    if (isset($_POST['mr_data'][$i]))
      fprintf($f, "1 ");
    else 
      fprintf($f, "0 ");
    if (($i % 10) == 9) {
      fprintf($f, "\n");
    }
  }
  fclose($f);
}

function endsWith( $str, $sub ) {
  return (strcmp(substr( $str, strlen( $str ) - strlen( $sub ) ), $sub ) == 0);
}

function isScannedImage($image_name) {
  return (strpos($image_name, ".jpg") == (strlen($image_name) - 4));
}

function getImagesFromDir($dir) {
  global $images;

  $images = array();
  $d = dir($dir);
  $n = 0;
  while (false !== ($entry = $d->read())) {
    if (endsWith($entry, ".jpg")) {
      if (isScannedImage($entry)) {
	$images[$n++] = $entry;
      }
    }
  }
  sort($images);
}

if (isset($_POST['action'])) {
  $action = $_POST['action'];
} else {
  $action = "";
}

if (isset($_POST['directory'])) {
  $current_dir = $_POST['directory']."/";
} else {
  $current_dir = "omr_errors/";
}

if ($action == "apply_changes") {
  saveMrFile($quiz->getDir().$current_dir.$_POST['image_file'].".mmr_data");
  exec($quiz_bin_dir."omr_errors_resolved.sh ".$quiz->getName());
}

getImagesFromDir($quiz->getDir().$current_dir);

if (isset($_POST['image_file']) && ($action != "change_directory") && ($action != "apply_changes")) {
   $current_image = $_POST['image_file'];
} else {
  if (isset($images[0])) {
    $current_image = $images[0];
  } else {
    $current_image = "";
  }
}

if (file_exists($quiz->getDir().$current_dir.$current_image.".mmr_data")) {
  $mr_file_ext=".mmr_data";
} else {
  $mr_file_ext=".omr1_data";
}

if ($current_image != "") {
  loadMrFile($quiz->getDir().$current_dir.$current_image.$mr_file_ext);
}

?><html>
<head>
	<title>Correction des erreurs de reconnaissance des marques</title>
        <link rel="stylesheet" type="text/css" href="style/quiz.css" />
	<script>
          changed = false;
          zoomFactor = 0.1

	  function fitWidth() {
	   document.image.height = (document.body.clientHeight - 50) / imageRatio;
	   document.image.width = (document.body.clientHeight - 50);
	  }

	  function fitHeight() {
	   document.image.height = (document.body.clientWidth * 0.5 - 50) / imageRatio;
	   document.image.width = (document.body.clientWidth * 0.5 - 50);
	  }

	  function normalZoom() {
	   document.image.width = imageWidth;
	   document.image.height = imageHeight;
	  }

	  function zoomIn() {
	    document.image.width *= 1 + zoomFactor;
	    document.image.height *= 1 + zoomFactor;
	  }

	  function zoomOut() {
	    document.image.width *= 1 - zoomFactor;
	    document.image.height *= 1 - zoomFactor;
	  }

function applyChanges() {
  document.main_form.action.value="apply_changes";
  document.main_form.submit();
}

function discardChanges() {
  document.main_form.action.value="discard_changes";
  document.main_form.submit();
}

function nextImage() {

}

function previousImage() {

}

function goToQuizMenu() {
  if (changed) {
    alert("Vous avez fait des modifications sur les marques reconnues. Vous devez appliquer ou annuler les modifications avant de continuer.");
  } else {
    window.location.href="quiz_workflow.php?quiz-id=<?php echo $quiz->getId(); ?>";
  }
}

	  function init() {
	    imageWidth = document.image.width;
	    imageHeight = document.image.height;
	    imageRatio = imageWidth / imageHeight;

	    image_div.onscroll = function(){
	      scrollRatio = table_div.scrollHeight / table_div.clientHeight;
	      table_div.scrollTop = Math.round(image_div.scrollTop * scrollRatio);
	    }
	  }
	</script>
</head>
<body style="border:Opx;margin:0px;" onload="init();fitWidth();">
<form name="main_form" method="POST" action="correct_omr_errors.php?quiz-id=<?php echo $quiz->getId(); ?>" style="border:Opx;margin:0px;">
	    <input type="hidden" name="action" value="">
  <button onclick="normalZoom(); return false;" class="form_elem">100%</button>
  <button onclick="fitHeight(); return false;" class="form_elem" >Fit height</button>
  <button onclick="fitWidth(); return false;" class="form_elem">Fit width</button>
  <button onclick="zoomIn(); return false;" class="form_elem">Zoom in</button>
  <button onclick="zoomOut(); return false;" class="form_elem">Zoom out</button>
  <select name="data_file" class="form_elem">
     <option value="">Manuel</option>
     <option value="">OMR1</option>
    <option value="">OMR2</option>
  </select>
  <button onclick="applyChanges(); return false;" class="form_elem">Apply</button>
 <button onclick="discardChanges(); return false;" class="form_elem">Discard</button>
  <button onclick="nextImage(); return false;" class="form_elem">Next image</button>
  <button onclick="previousImage(); return false;" class="form_elem">Previous image</button>
  <select name="image_file" class="form_elem" onchange="document.main_form.submit();">
<?php 
	    foreach ($images as $nb => $image) {
	    echo "<option value=\"".$image."\" ";
	    if ($image == $current_image) {
	      echo "selected";
	    }
	    echo ">".$image."</option>";
	  }
	    
?>
  </select>
  <select name="directory" class="form_elem" onchange="document.main_form.action.value='change_directory'; document.main_form.submit();">
	    <option value="omr_errors" <?php if ($current_dir == "omr_errors/") echo "selected"; ?>>Erreurs</option>
     <option value="omr_output" <?php if ($current_dir != "omr_errors/") echo "selected"; ?>>Sortie</option>
  </select>
  <button onclick="goToQuizMenu(); return false;" class="form_elem">Quiz menu</button>
<div id="image_div" name="image_div" style="border:Opx;margin:0px;width:65%; height:95%;background-color: #CCCCCC;
	   display:block; overflow:auto;position:absolute; left:0px;top:25px;">
	    <?php if ($current_image != "") { ?>
<img id="image" name="image" src="view_file.php?quiz-id=<?php echo $quiz->getId(); ?>&filename=<?php echo $current_dir.$current_image."_corrected.jpg"; ?>">
					      <?php } else { echo "Aucune image dans ce répertoire."; }?>
</div>

<div id="table_div" style="border:Opx;margin:0px;width:35%; height:95%;background-color: #CCCCCC;
	   display:block; overflow:auto;position:absolute;
	   left:65%;top:25px;">

<div >
<span style="position:absolute; left:0px; top:0px;">
	    <?php generateLoginTable(0, 4); ?>
</span>

<span style="position:absolute; left:50%; top:0px;">
<table border>
	    <?php generateLoginTable(5, 9); ?>
</span>

<span style="position:absolute; left:0px; top:200px;">
<?php generateQuestionsTable(1, 40); ?>
</span>
<span style="position:absolute; left:50%; top:200px;">
<?php generateQuestionsTable(41, 80); ?>
</span>
</div>
</div>
</form>
</body>
</html>
