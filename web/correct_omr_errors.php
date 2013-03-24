<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

        $quiz = Quiz::getQuizById($_GET['quiz-id']);

function generateQuestionsTable($minQuestion, $maxQuestion) {
  echo "<table border>
   <tr><th>&nbsp;</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th></tr>\n";
  for ($question = $minQuestion; $question <= $maxQuestion; $question++) {
    echo "<tr><td>Q".$question."</td>\n";
    $offset_line = 5;
    if ($question > 40) {
      $offset_column = 5;
    } else {
      $offset_column = 0;
    }
    if ($question > 40) {
      $offset_question = $question - 40;
    } else {
      $offset_question = $question;
    }
    for ($j = 0; $j < 5; $j++) {
      generateCheckBoxCell(($offset_question + $offset_line - 1) * 10 + $offset_column + $j);
    }
    echo"</tr>\n";
 }
 echo "</table>";
}

function generateLoginTable($minDigit, $maxDigit) {
  echo "<table border><tr><th>&nbsp;</th>";
  for ($digit = $minDigit; $digit <= $maxDigit; $digit++) {
    echo "<th>".$digit."</th>";
  }
  echo "</tr>\n";
  for ($i = 1; $i <= 5; $i++) {
    echo "<tr><td>C".$i."</td>\n";
    for ($j = 0; $j < 5; $j++) {
      generateCheckBoxCell(($i - 1) * 10 + $minDigit + $j);
    }
    echo "</tr>\n";
  }
  echo "</table>";
}

function generateCheckBoxCell($mr_data_nb) {
  global $mr_data;
 
  echo "<td><input type=\"checkbox\" name=\"mr_data[".$mr_data_nb."]\"";
  if (isset($mr_data[$mr_data_nb]) && (strcmp($mr_data[$mr_data_nb], "1") == 0)) {
    echo " checked";
  }
  echo " onchange=\"changed = true;\"></td>\n";
}

function loadMrFile($filename) {
  global $mr_data;

  if (! file_exists($filename)) {
    return;
  }

  $lines = file($filename);

  if ($lines == FALSE) {
    return;
  }

  $n = 0;
  foreach ($lines as $line_nb => $line) {
    $line_data = explode(" ", $line);
    unset($line_data[count($line_data) - 1]);
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

function findIndexOfImage($wantedImage) {
  global $images;

  foreach ($images as $index => $image) {
    if ($image == $wantedImage) {
      return $index;
    }
  }
  return -1;
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

if (isset($images[0])) {
  $current_image = $images[0];
} else {
  $current_image = "";
}

if (isset($_POST['image_file'])) {
  $lastImageIndex = findIndexOfImage($_POST['image_file']);
  if ($lastImageIndex != -1) {
    if ($action == "next_image") {
      if (isset($images[$lastImageIndex + 1])) {
	$current_image = $images[$lastImageIndex + 1];
      } else {
	$current_image = $_POST['image_file'];
      }
    } else if ($action == "previous_image") {
      if (isset($images[$lastImageIndex - 1])) {
	$current_image = $images[$lastImageIndex - 1];
      } else {
	$current_image = $_POST['image_file'];
      } 
    } else {
      $current_image = $_POST['image_file'];
    } 
  }
}

if ($action == "change_mr") {
  $mr_file_ext = $_POST['mr_file'];
} else {
  if (file_exists($quiz->getDir().$current_dir.$current_image.".mmr_data")) {
    $mr_file_ext=".mmr_data";
  } else if (file_exists($quiz->getDir().$current_dir.$current_image.".omr1_data")) {
    $mr_file_ext=".omr1_data";
  } else if (file_exists($quiz->getDir().$current_dir.$current_image.".omr2_data")) {
    $mr_file_ext=".omr2_data";
  } else if (file_exists($quiz->getDir().$current_dir.$current_image.".omr3_data")) {
    $mr_file_ext=".omr3_data";
  } else {
   $mr_file_ext=".omr1_data";
  }
}

if ($current_image != "") {
  loadMrFile($quiz->getDir().$current_dir.$current_image.$mr_file_ext);
}

?><?php $page_title='Correction des erreurs de reconnaissance des marques'; include 'simple_header.php' ?>
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
  if (changed) {
    alertChanged();
  } else {
    document.main_form.action.value="next_image";
    document.main_form.submit();
  }
}

function previousImage() {
  if (changed) {
    alertChanged();
  } else {
    document.main_form.action.value="previous_image";
    document.main_form.submit();
  }
}

function goToQuizMenu() {
  if (changed) {
    alertChanged();
  } else {
    window.location.href="quiz_workflow.php?quiz-id=<?php echo $quiz->getId(); ?>";
  }
}

function mrChanged() {
  if (changed) {
    alertChanged();
  } else {
    document.main_form.action.value='change_mr'; 
    document.main_form.submit();
  }
}

function imageChanged() {
  if (changed) {
    alertChanged();
    alert(document.main_form.current_image.value);
  } else {
    document.main_form.action.value='change_image'; 
    document.main_form.submit();
  }
}

function directoryChanged() {
  if (changed) {
    alertChanged();
  } else {
    document.main_form.action.value='change_directory'; 
    document.main_form.submit();
  }
}

function alertChanged() {
    alert("Vous avez fait des modifications sur les marques reconnues. Vous devez appliquer ou annuler les modifications avant de continuer.");
}

                function showFindLogin() {
                        findLogin = document.getElementById("findLogin");
                        findLogin.src="https://campus.isen.fr/calendars/find_calendar.php";
                        findLogin.style.display = "block";
                        document.getElementById("findLoginHideMenu").style.display = "block";
                }

                function hideFindLogin() {
                        findLogin = document.getElementById("findLogin");
                        findLogin.src="";
                        findLogin.style.display = "none";
                        document.getElementById("findLoginHideMenu").style.display = "none";
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
<div class="navbar navbar-static-top">
  <div class="navbar-inner">
<form name="main_form" method="POST" action="correct_omr_errors.php?quiz-id=<?php echo $quiz->getId(); ?>" style="border:Opx;margin:0px;">
  <input type="hidden" name="action" value="">
  <input type="hidden" name="current_image" value="<?php echo $current_image; ?>">
  <div class="btn-group">
    <button onclick="normalZoom(); return false;" class="btn btn-small"><i class="icon-screenshot"></i></button>
    <button onclick="fitHeight(); return false;" class="btn btn-small" ><i class="icon-resize-vertical"></i></button>
    <button onclick="fitWidth(); return false;" class="btn btn-small"><i class="icon-resize-horizontal"></i></button>
    <button onclick="zoomIn(); return false;" class="btn btn-small"><i class="icon-zoom-in"></i></button>
    <button onclick="zoomOut(); return false;" class="btn btn-small"><i class="icon-zoom-out"></i></button>
  </div>
  <select name="mr_file" class="btn btn-small" onchange="mrChanged();">
<?php 
  if (file_exists($quiz->getDir().$current_dir.$current_image.".mmr_data")) {
    echo "<option value=\".mmr_data\" ";
    if ($mr_file_ext == ".omr1_data") {
      echo "selected"; 
    }
    echo ">Manual</option>";
  }
?>
<option value=".omr1_data" <?php if ($mr_file_ext == ".omr1_data") { echo "selected"; } ?> >OMR1</option>
<option value=".omr2_data" <?php if ($mr_file_ext == ".omr2_data") { echo "selected"; } ?> >OMR2</option>
<option value=".omr3_data" <?php if ($mr_file_ext == ".omr3_data") { echo "selected"; } ?> >OMR3</option>
  </select>
  <div class="btn-group">
  <button onclick="applyChanges(); return false;" alt="Apply" class="btn btn-primary btn-small"><i class="icon-save"></i></button>
  <button onclick="discardChanges(); return false;" alt="Discard" class="btn btn-small"><i class="icon-undo"></i></button>
  </div>
  <div class="btn-group">
    <button onclick="previousImage(); return false;" class="btn btn-small"><i class="icon-chevron-left"></i></button>
    <button onclick="nextImage(); return false;" class="btn btn-small"><i class="icon-chevron-right"></i></button>
  </div>
  <select name="image_file" class="btn btn-small" onchange="imageChanged();">
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
  <select name="directory" class="btn btn-small" onchange="directoryChanged();">
	    <option value="omr_errors" <?php if ($current_dir == "omr_errors/") echo "selected"; ?>>Errors</option>
     <option value="omr_output" <?php if ($current_dir != "omr_errors/") echo "selected"; ?>>Output</option>
  </select>
  <div class="btn-group">
    <button onclick="showFindLogin(); return false;" class="btn btn-info btn-small disabled">Find login</button>
    <button onclick="goToQuizMenu(); return false;" class="btn btn-primary btn-small">Quiz menu</button>
  </div>
  </div></div>
  <div id="image_div" name="image_div" style="border:Opx;margin:0px;width:65%; height:95%;background-color: #CCCCCC;
	   display:block; overflow:auto;position:absolute; left:0px;top:40px;">
	    <?php if ($current_image != "") { ?>
					      <img onClick="zoomIn();" id="image" name="image" src="view_file.php?quiz-id=<?php echo $quiz->getId(); ?>&filename=<?php echo $current_dir.$current_image; if ($mr_file_ext == ".omr2_data") {echo "_corrected2.jpg";} else if ($mr_file_ext == ".omr3_data") {echo "_corrected3.jpg";} else { echo "_corrected.jpg"; } ?>">
					      <?php } else { echo "Aucune image dans ce répertoire."; }?>
</div>

<div id="table_div" style="border:Opx;margin:0px;width:35%; height:95%;background-color: #CCCCCC;
	   display:block; overflow:auto;position:absolute;
	   left:65%;top:40px;">

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
<!--
<iframe id="findLogin" style="display: none; position: absolute; left: 400px; top: 400px; width: 500px; height: 450px; background-color: grey;"></iframe>
<div id="findLoginHideMenu" style="display: none; position: absolute; left: 875px; top: 400px;"><button class="btn btn-primary" width="25px" onclick="hideFindLogin(); return false;">X</button></div>
<script type="application/javascript" src="js/bootstrap.min.js"/>
-->
</body>
</html>
