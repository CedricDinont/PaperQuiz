</head>
<body>
    <div class="navbar navbar-inverse navbar-static-top">
      <div class="navbar-inner">
	  <ul class="nav">
	    <li class="brand"><i class="icon-book"></i>QuizApp</li>
	    <li><a href="index.php"><i class="icon-home"></i>Menu principal</a></li>
	    <?php if (isset($quiz) { ?>
	    <li><a href="quiz_workflow.php?quiz-id="<?php echo $quiz->getId() ?>"><i class="icon-tasks"></i>Quiz courant</a></li>
	    <?php } ?>
	    <li><a href="create_quiz.php"><i class="icon-file-alt"></i>Nouveau</a></li>
	  </ul>
	  <ul class="nav pull-right">
	    <li><a href="help.php<?php
		if (isset($quiz)) {
		  echo "?quiz-id=".$quiz->getId();
	    } ?>"><i class="icon-question-sign"></i>Aide</a></li>
	  </ul>
      </div>
    </div>
    
    <!-- content -->
    <div class="container">
      <h2><?php echo $page_title ?></h2> 