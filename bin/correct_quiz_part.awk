# normal usage: awk -f ../correcteur.awk -v bad=-0.5 -v outputmode=ooffice brut.txt

function int2letter(a,   b) {
    if(a==0) 
	return "";
    else {
	b=a-26*int((a)/26);
	if(b==0)
	    b=26;
	a=int((a-b)/26);
	s=sprintf("%s%c",int2letter(a),65-1+b);
    }
    return s;
}

BEGIN {
    FS=";";
    if(students=="")
	# file with students names
	# format: LASTNAME firstname code
	students="../students.txt";
    if(corrige=="")
	# correction file
	# format: question_number;number_of_possible_answers;expected_answers;coefficient;bonus
	# example: 1;4;R2\R4;1;0
	# comments are possible with the "#" character
	corrige="corrige.txt";
    if(good=="")
	# number of points per right answer
	good=+1;
    if(bad=="")
	# number of points per wrong answer, Warning - "bad" should be negative
	bad=0;
    if(outputmode==openoffice)
	# OpenOffice output or stdout
	outputmode=ooffice
    if(ooffile=="")
	# OpenOffice output file
	ooffile="results.csv"
    if(statfile=="")
	# statistics per question
	statfile="/dev/stdout";
    if(binlength=="")
	# bining length for marks statistics
	binlength=2;
    if(OOFS=="")
	# OpenOffice separator
	# Do not use ";" since this sign is needed in OpenOffice functions (IF and so on)
	OOFS=",";

#   import student names
    while(getline<students>0) {
	split($0,a," ");
	absent[a[3]]=1; # a priori absent...
	if(outputmode=="ooffice")
	    stutab[a[3]]=sprintf("%s%c%s",a[1],OOFS,a[2]);
	else
	    stutab[a[3]]=sprintf("%-20s %-20s",a[1],a[2]);
    }
    close(students);

#   import correction
    nr_questions=0;
    nr_fields_corr=5; # there should be 5 fields in file corrige, but keep it as a parameter...
    inputline=0; # trace inputline for warning outputs...
#   format: question_nr;nb_possible_answers;correct_answers(eg.R1\R5);coef;bonus
    while(getline<corrige>0) {
	inputline++;
	if($1!~"#" && NF==nr_fields_corr) {
	    
	    if($1 in nr_answers) {
		# already seen!!!
		printf "WARNING - in \"%s\" line %d:\n\tquestion %d already defined --> use bonus!!\n",corrige,inputline,$1 > "/dev/stderr";
		bonus[$1]=1;
		corr[$1,0]=1;
	    } else {
		# normal way
		nr_answers[$1]=$2; # number of possible responses for question $1
		if($2>max_nr_answers)
		    max_nr_answers=$2;
		
		nr_correct[$1]=split($3,a,"\\");
		# nr_correct[q] (nr of correct answers at question "q") is used to compute mark
		if(nr_correct[$1]==0) {
		    printf "WARNING - in \"%s\" line %d question %d:\n\t no correct response!!\n",corrige,inputline,$1 > "/dev/stderr";
		    nr_correct[$1]=1; # prevent division by 0
		} else {
		    for(r in a) {
			gsub("R","",a[r]);
			corr[$1,a[r]]=1;
			# by default corr[x,y] is initialized at 0
			if(a[r]>nr_answers[$1]) {
			    printf "WARNING - in \"%s\" line %d question %d:\n\t response R%-2d out of range --> use bonus!!\n",corrige,inputline,$1,a[r] > "/dev/stderr";
			    bonus[$1]=1;
			}
		    }
		}
		coeff[$1]=$4;
		if(bonus[$1]==0)
		    bonus[$1]=$5;
		if($1>nr_questions)
		    nr_questions=$1;
		
		minmark+=bad*coeff[$1]/nr_correct[$1]*(nr_answers[$1]-nr_correct[$1]);
		maxmark+=coeff[$1];
	    }
	} else if($1!~"#" && NF!=nr_fields_corr && NF>0)
	    # Wrong number of fields!!!
	    printf "WARNING - in \"%s\" line %d:\n\tWrong number of fields (found %d instead of %d) --> question ignored!!\n",corrige,inputline,NF,nr_fields_corr > "/dev/stderr";
    }
    close(corrige);
    printf "%d questions\n",nr_questions > "/dev/stdout";
    printf "Mark between %6.3f and %6.3f\n",minmark,maxmark > "/dev/stdout";

#   check corrige consistency: nr of questions should be equal to max(question_nr)
    for(q=1;q<=nr_questions;q++) {
	if( ! (q in nr_answers) ) {
	    printf "WARNING - in \"%s\":\n\tquestion %d undefined --> use bonus!!\n",corrige,q > "/dev/stderr";
	    nr_answers[q]=0;
	    coeff[q]=1;
	    bonus[q]=1;
	    corr[q,0]=1;
	}
    }

    # OpenOffice output
    if(outputmode=="ooffice") {
	# at this point, we suppose everything above correct
	printf "student_name%cstudent_first_name%cstudent_id",OOFS,OOFS > ooffile;
	colstart=4;
	nr_void_col=2; # nr of void columns between marks and rubbish calculus
	for(q=1;q<=nr_questions;q++)
	    printf "%c Q%3d",OOFS,q > ooffile;
	printf "%c TOTAL",OOFS > ooffile;
	# add dummy columns
	for(i=0;i<nr_void_col;i++)
	    printf "%c",OOFS > ooffile;
	# then put calculus aside
	for(q=1;q<=nr_questions;q++)
	    printf "%c Q%3d",OOFS,q > ooffile;
	printf "\n" > ooffile;
	###### NEWLINE

	printf "coefficients" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %f",OOFS,coeff[q] > ooffile;
	printf "%c=SUM(%s2:%s2)",OOFS,int2letter(colstart),int2letter(nr_questions+colstart-1) > ooffile;
	for(q=0;q<nr_void_col;q++)
	    printf "%c",OOFS > ooffile;
	printf "%cmarks x coeffs\n",OOFS > ooffile;
	###### NEWLINE

	printf "bonus" > ooffile
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %4d",OOFS,bonus[q] > ooffile;
	printf "\n" > ooffile;
	###### NEWLINE

	printf "nr_expected_answers" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %4d",OOFS,nr_correct[q] > ooffile;
	printf "%c=SUM(%s4:%s4)\n",OOFS,int2letter(colstart),int2letter(nr_questions+colstart-1) > ooffile;
	###### NEWLINE

	line=5; # first student line !
	first_stuline=line;
    } else {
	printf "%-20s %-20s 0000    %6.3f  (min_mark=%6.3f)\n","#------","CORRIGE",maxmark,minmark;
    }

}

$1!~"Code" {
    absent[$1]=0;
    # globstudmark[$1] = global student "s" mark, set to 0 by default
    # questudmark[s,q] = student "s" mark at question "q", set to 0 by default
    # stugood[s] and stubad[s] stand for number of right and wrong ticks of student "s"

    for(q=2;q<=nr_questions+1;q++) {

	if($q=="") {
	    # class_responses[q,r] = nr of answers "r" at question "q" ("r=0" for no answer)
	    class_responses[q-1,0]++;
	    # studresp[s,q,r] = 1 iff student "s" has answered "r" at question "q"
	    studresp[$1,q-1,0]=1;

	} else {
	    # update student ($1) answers table for question q-1
	    split($q,tab,"\\");
	    for(r in tab) {
		gsub("R","",tab[r]);
		class_responses[q-1,tab[r]]++;
		studresp[$1,q-1,tab[r]]=1;
	    }

	    # compute mark
	    for(r=1;r<=nr_answers[q-1];r++) {
		if(corr[q-1,r]==1 && studresp[$1,q-1,r]==1) {
		    # match!
		    questudmark[$1,q-1]+=good/nr_correct[q-1];
		    globstudmark[$1]+=coeff[q-1]*good/nr_correct[q-1];
		    stugood[$1]++;
		} else if(corr[q-1,r]==0 && studresp[$1,q-1,r]==1) {
		    # mismatch!
#		    printf "\t\tquestudmark[%d,%d] from %f downto %f\n",$1,q-1,questudmark[$1],questudmark[$1]+bad/nr_correct[q-1] > "/dev/stderr";
		    questudmark[$1,q-1]+=bad/nr_correct[q-1];
		    globstudmark[$1]+=coeff[q-1]*bad/nr_correct[q-1];
		    stubad[$1]++;
		}
	    }
	}
    }

    # OpenOffice output
    if(outputmode=="ooffice") {
	printf "%s%c%d",stutab[$1],OOFS,$1 > ooffile;   # remind that stutab[s] has two fields
	for(q=1;q<=nr_questions;q++)
	    printf "%c%.3f",OOFS,questudmark[$1,q] > ooffile;
	printf "%c=IF(%s%d=\"ABS\";\"ABS\";20*SUM(%s%d:%s%d)/%s$2)",OOFS,int2letter(colstart),line,int2letter(colstart+nr_questions+nr_void_col+1),line,int2letter(colstart+2*nr_questions+nr_void_col),line,int2letter(colstart+nr_questions) > ooffile;
	# add dummy columns
	for(i=0;i<nr_void_col;i++)
	    printf "%c",OOFS > ooffile;
	# then put calculus aside
	for(q=1;q<=nr_questions;q++) {
	    colname=int2letter(colstart-1+q);
	    printf "%c=IF(NOT(%s$3=0);%s$2;%s%d*%s$2)",OOFS,colname,colname,colname,line,colname > ooffile;
	}
	printf "\n" > ooffile;
	line++;
	###### NEWLINE

    } else {
	printf "%s %5d    %6.3f \t (correct_ticks: %3d   wrong_ticks: %3d )\n",stutab[$1],$1,globstudmark[$1],stugood[$1],stubad[$1];
    }
}

END {
    # OpenOffice output
    if(outputmode=="ooffice") {

	# output ABSENTS
	for(s in stutab)
	    if(absent[s]==1) {
		printf "%s%c%d",stutab[s],OOFS,s > ooffile;   # stutab[s] has two fields!!
		for(q=1;q<=nr_questions;q++)
		    printf "%c\"ABS\"",OOFS,questudmark[$1,q] > ooffile;
		printf "%c=IF(%s%d=\"ABS\";\"ABS\";20*SUM(%s%d:%s%d)/%s$2)\n",OOFS,int2letter(colstart),line,int2letter(colstart+nr_questions+nr_void_col+1),line,int2letter(colstart+2*nr_questions+nr_void_col),line,int2letter(colstart+nr_questions) > ooffile;
		line++;
	    }
	last_stuline=line-1;
	###### NEWLINE

	printf "\n" > ooffile;
	line++;
	###### NEWLINE

	# average over class for each question and global marks
	printf "avg" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
 	for(q=1;q<=nr_questions+1;q++) { # +1 for "TOTAL" statistics
	    colname=int2letter(colstart-1+q);
 	    printf "%c=AVERAGE(%s%d:%s%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
	}
	printf "\n" > ooffile;
	line++;
	###### NEWLINE

	# standart deviation over class for each question and global marks
	printf "rms" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
 	for(q=1;q<=nr_questions+1;q++) { # +1 for "TOTAL" statistics
	    colname=int2letter(colstart-1+q);
 	    printf "%c=STDEV(%s%d:%s%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
	}
	printf "\n\n" > ooffile;
	line+=2;
	###### NEWLINE - NEWLINE

	# compute nr of present students and repartition of marks
	printf "presents%c=%s%d%c%cmarks%c",OOFS,int2letter(5+1000-int(1000-20/binlength)),line+1,OOFS,OOFS,OOFS > ooffile;
	for(n=binlength;n<20;n+=binlength)
	    printf "]%d;%d]%c",n-binlength,n,OOFS > ooffile;
	printf ">%d\n",n-binlength > ooffile;
	line++;
	###### NEWLINE

	printf "absents%c=COUNTIF($%s$%d:$%s$%d;\"ABS\")%c%crepartition%c",OOFS,int2letter(colstart),first_stuline,int2letter(colstart),last_stuline,OOFS,OOFS,OOFS > ooffile;
	printf "=%s%d%c",int2letter(5),line+1,OOFS > ooffile;
	for(n=binlength;n<20-binlength;n+=binlength)
	    printf "=%s%d-%s%d%c",int2letter(5+n/binlength),line+1,int2letter(4+n/binlength),line+1,OOFS > ooffile;
	printf "=COUNTIF($%s$%d:$%s$%d;\">%d\")%c=SUM(%s%d:%s%d)\n",int2letter(colstart+nr_questions),first_stuline,int2letter(colstart+nr_questions),last_stuline,n,OOFS,int2letter(5),line,int2letter(4+1000-int(1000-20/binlength)),line > ooffile; # 1000-int(1000-x) rounds "x" towards +infty (well... towards +1000)
	line++;
	###### NEWLINE

	for(n=1;n<4;n++)
	    printf "%c",OOFS > ooffile;
	printf "cumulative%c",OOFS > ooffile;
	for(n=binlength;n<20;n+=binlength)
	    printf "=COUNTIF($%s$%d:$%s$%d;\"<=%d\")%c",int2letter(colstart+nr_questions),first_stuline,int2letter(colstart+nr_questions),last_stuline,n,OOFS > ooffile;
	printf "=%s%d+%s%d\n",int2letter(3+20/binlength),line,int2letter(4+20/binlength),line-1 > ooffile;
	line++;
	###### NEWLINE

    } else {
	# output ABSENTS
	for(s in stutab)
	    if(absent[s]==1)
		printf "%s %5d      ABS\n",stutab[s],s;
    }

#   stats
    printf "#Ans:   coeff  VOID     " > statfile;
    for(r=1;r<=max_nr_answers;r++)
	printf "R%-4d  ",r > statfile;
    printf "(sutdents|correction)\n" > statfile;

    for(q=1;q<=nr_questions;q++) {
	printf "#Q%-2d    %5.2f ",q,coeff[q] > statfile;
	if(bonus[q]==1) {
	    for(r=0;r<=nr_answers[q];r++)
		printf "%3d%2s  ",class_responses[q,r],"|X" > statfile;
	    for(r=nr_answers[q]+1;r<=max_nr_answers;r++)
		printf "%5s  ","_" > statfile;
	} else {
	    for(r=0;r<=nr_answers[q];r++)
		printf "%3d|%1d  ",class_responses[q,r],corr[q,r] > statfile;
	    for(r=nr_answers[q]+1;r<=max_nr_answers;r++)
		printf "%5s  ","_" > statfile;
	}
	printf "\n" > statfile;
    }

}
