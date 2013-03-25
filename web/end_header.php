</head>
<body>
    <div class="navbar navbar-inverse navbar-static-top" data-toggle="collapse" data-target=".nav-collapse">
      <div class="navbar-inner">
	  <ul class="nav">
	    <li class="brand"><i class="icon-book 2x-scale"></i>QuizApp</li>
	    <li<?php if ($active_page==='home') echo ' class="active"'; ?>><a href="index.php"><i class="icon-home"></i>Menu principal</a></li>
	    <li<?php if ($active_page==='new') echo ' class="active"'; ?>><a href="create_quiz.php"><i class="icon-file-alt"></i>Nouveau quiz</a></li>
	    <?php if (isset($quiz)) { ?>
	    <li<?php if ($active_page==='workflow') echo ' class="active"'; ?>><a href="quiz_workflow.php?quiz-id=<?php echo $quiz->getId(); ?>"><i class="icon-tasks"></i>Quiz courant</a></li>
	    <?php } ?>
	  </ul>
	  <ul class="nav pull-right">
	    <li<?php if ($active_page==='help') echo ' class="active"'; ?>><a href="help.php<?php
	      if (isset($quiz)) echo "?quiz-id=".$quiz->getId();
	    ?>"><i class="icon-question-sign"></i>Aide</a></li>
	  </ul>
      </div>
    </div>
    
    <!-- content -->
    <div class="container">
      <h2><?php echo $page_title ?></h2> 