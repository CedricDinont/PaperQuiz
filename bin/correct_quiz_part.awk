 # normal usage: awk -f ../correct_quiz_part.awk brut.txt

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

function abs(a) {
    if(a<0)
	return(-a);
    else
	return(a);
}

BEGIN {
    FS=";";
    if(students=="")
	# file with students names
	# format: LASTNAME firstname code
	students="../students.txt";

    if(corrige=="")
	# correction file
	# format: question_number;number_of_possible_answers;expected_answers;bonif;malus;coefficient;bonus
	# example: 1;4;R2\R4;1;-.5;1;0
	# comments are possible with the "#" character
	# "bonus" are used for ill-posed questions
	corrige="corrige.txt";

    if(nr_students!="")
	# If externally fixed, flag the situation by setting nr_students to its opposite
	nr_students=-nr_students;

    if(ooffile=="")
	# OpenOffice output file
	ooffile="results.csv"

    if(binlength=="")
	# bining length for marks statistics
	binlength=2;

    if(cornersfile=="")
	cornersfile="corners.txt";

    if(OOFS=="")
	# OpenOffice separator
	# Do not use ";" since this sign is needed in OpenOffice functions (IF and so on)
	OOFS=",";

#-------------------------------------------------------------------------------------------------------------
#   import student names
    while(getline<students>0) {
	
	nfields=split($0,a,";");
	if(nfields!=3)
	    printf "WARNING - wrong number of fields in student file %s (found %d instead of 3). See line:\n\t%s\n", students,nfields,$0 > "/dev/stderr";

	absent[a[3]]=1; # a priori absent...
	stutab[a[3]]=sprintf("%s%c%s",a[1],OOFS,a[2]);
	# a[3] might be a string like "P45079"
	if(nr_students>=0)
	    # if externally fixed, nr_students is negative
	    nr_students++;
    }
    close(students);
    if(nr_students==0)
	printf "WARNING - no students loaded from file %s\n",students > "/dev/stderr";

#-------------------------------------------------------------------------------------------------------------
#   import correction
    max_found_questions=0;
    min_found_questions=999999;
#   there should be 7 fields in file corrige, but additional fields may be found...
#   the first optional field is a bottom limit for the mark of each question
    expected_nr_fields=7; 
    inputline=0; # trace inputline for warning outputs...
#   format: question_nr;nb_possible_answers;correct_answers(eg.R1\R5);bonif;malus;coef;bonus
    while(getline<corrige>0) {
	inputline++;
	if($1!=0) {
	    # There are now 3 mandatory fields required
	    # Missing fields are filled with default values

	    if($1!~"#" && NF>=3) {
		
		gsub(" ","",$0);  # remove spaces
		gsub("\t","",$0); # remove tabs
		if($1 in nr_answers) {
		    # already seen!!!
		    printf "WARNING - in \"%s\" line %d:\n\tquestion %d already defined --> use bonus!!\n",corrige,inputline,$1 > "/dev/stderr";
		    bonus[$1]=1;
		    corr[$1,0]=1;
		} else {
		    # normal way
		    if($1>max_found_questions)
			max_found_questions=$1;
		    if($1<min_found_questions)
			min_found_questions=$1;
		    
		    nr_answers[$1]=$2; # number of possible responses for question $1
		    if($2>max_nr_answers)
			max_nr_answers=$2;
		    
		    expected_ans[$1]=$3;
		    nr_correct[$1]=split($3,a,"\\");
		    # nr_correct[q] (nr of correct answers at question "q") is used to compute mark
		    if(nr_correct[$1]==0) {
			printf "WARNING - in \"%s\" line %d question %d:\n\t no correct response!!\n",corrige,inputline,$1 > "/dev/stderr";
			nr_correct[$1]=1; # prevent division by 0
		    } else {
			for(r in a) {
			    if(a[r]~"X") {
				# Allowed "X" symbol represents forbidden answer
				nr_correct[$1]--;
				gsub("X","",a[r]);
				forbidden[$1,a[r]]=1;
			    } else {
				if(a[r]~"O") {
				    gsub("O","",a[r]);
				    onlyone[$1]=1;
				}

				gsub("R","",a[r]);
				corr[$1,a[r]]=1;
				# by default corr[x,y] is initialized at 0
				if(a[r]>nr_answers[$1]) {
				    printf "WARNING - in \"%s\" line %d question %d:\n\t response R%-2d out of range --> use bonus!!\n",corrige,inputline,$1,a[r] > "/dev/stderr";
				    bonus[$1]=1;
				}
			    }
			}
		    }
		    if(NF>=4)
			good[$1]=$4;
		    else
			good[$1]=+1;
		    
		    if(NF>=5)
			bad[$1]=$5;
		    else
			bad[$1]=-0.5;

		    if(NF>=6)
			coeff[$1]=$6;
		    else
			coeff[$1]=1;
		    
		    if(bonus[$1]==0 && NF>=7)
			bonus[$1]=$7;

		    if(NF<expected_nr_fields) {
			printf "WARNING: line %3d of file %s - Set default values for question %d\n",inputline,corrige,$0 > "/dev/stderr";
		    }
		}
		
		if(NF>max_nr_fields)
		    max_nr_fields=NF;

		# Additional fields
		af=expected_nr_fields+1;
		if(af<=NF) {
		    bottom_limit[$1,1]=$af;
		    bottom_limit[$1,2]=1;
		}
		for(af=expected_nr_fields+2;af<=NF;af++) {
		    add_fields[$1,af]=$af;
		}
	    }
	    #else if($1!~"#" && NF!=expected_nr_fields && NF>0)
	    # Not enough fields!!!
	    #printf "WARNING - in \"%s\" line %d:\n\tWrong number of fields (found %d, at least %d expected) --> question ignored!!\n",corrige,inputline,NF,expected_nr_fields > "/dev/stderr";
	} else {
	    # If $1==0 (free text question): insert it at end of OpenOffice file
	    free_text_q++;

	    if($1!~"#" && NF>=2) {
		
		gsub(" ","",$0);  # remove spaces
		gsub("\t","",$0); # remove tabs

		ft_nr_answers[free_text_q]=$2;
		if(ft_nr_answers[free_text_q]==0)
		    ft_nr_answers[free_text_q]=1; # prevent division by 0

		if(NF>=4)
		    ft_good[free_text_q]=$4;
		else
		    ft_good[free_text_q]=+1;
		    
		if(NF>=5)
		    ft_bad[free_text_q]=$5;
		else
		    ft_bad[free_text_q]=0;
		
		if(NF>=6)
		    ft_coeff[free_text_q]=$6;
		else
		    ft_coeff[free_text_q]=1;
		    
		if(ft_bonus[free_text_q]==0 && NF>=7)
		    ft_bonus[free_text_q]=$7;
		
		if(NF<expected_nr_fields) {
		    printf "WARNING: line %3d of file %s - Set default values for question %d\n",inputline,corrige,$0 > "/dev/stderr";
		}
		if(NF>max_nr_fields)
		    max_nr_fields=NF;

		# Additional fields
		# Be careful expected_nr_fields+1 means bottom_limit but is not taken into account in free text q
		for(af=expected_nr_fields+2;af<=NF;af++) {
		    ft_add_fields[free_text_q,af]=$af;
		}
	    }
	}
    }
    close(corrige);
    if(inputline==0)
	printf "WARNING - No question loaded from correction file %s\n",corrige > "/dev/stderr";


#-------------------------------------------------------------------------------------------------------------
#   check consistency of corrige: nr of questions should be equal to max_found_questions-min_found_questions+1
    if(min_question=="")
	min_question=min_found_questions;
    else {
	if(min_question<min_found_questions) {
	    printf "WARNING - in \"%s\":\n\tquestions from %d to %d undefined --> use bonus!!\n",corrige,min_question,min_found_questions > "/dev/stderr";
	    for(q=min_question;q<min_found_questions;q++) {
		# Set parameters that influence the marks
		bonus[q]=1;
		coeff[q]=1;
		good[q]=1;
		bad[q]=-.5;
		nr_answers[q]=999999;
		nr_correct[q]=1;
		corr[q,0]=1;
	    }
	} else if(min_question>min_found_questions)
	    printf "WARNING - in \"%s\":\n\tToo many questions (from %d to %d) --> ignore questions!!\n",corrige,min_found_questions,min_question > "/dev/stderr";
    }

    if(max_question=="")
	max_question=max_found_questions;
    else {
	if(max_question>max_found_questions) {
	    printf "WARNING - in \"%s\":\n\tquestions from %d to %d undefined --> use bonus!!\n",corrige,max_found_questions,max_question > "/dev/stderr";
	    for(q=max_question;q<max_found_questions;q++) {
		# Set default parameters
		bonus[q]=1;
		coeff[q]=1;
		good[q]=1;
		bad[q]=-.5;
		nr_answers[q]=999999;
		nr_correct[q]=1; # prevent division by 0
		corr[q,0]=1;
	    }
	} else if(max_question<max_found_questions)
	    printf "WARNING - in \"%s\":\n\tToo many questions (from %d to %d) --> ignore questions!!\n",corrige,max_question,max_found_questions > "/dev/stderr";
    }

    for(q=min_question;q<=max_question;q++) {
	if( ! (q in nr_answers) ) {
	    printf "WARNING - in \"%s\":\n\tquestion %d undefined --> use bonus!!\n",corrige,q > "/dev/stderr";
	    bonus[q]=1;
	    coeff[q]=1;
	    good[q]=1;
	    bad[q]=-.5;
	    nr_answers[q]=0;
	    nr_correct[q]=1; # prevent division by 0
	    corr[q,0]=1;
	}
    }
    printf "%d questions loaded\n",max_question-min_question+1 > "/dev/stdout";

#-------------------------------------------------------------------------------------------------------------
    # OpenOffice output
    # at this point, we suppose everything above correct
    colstart=5;
    nr_questions=max_question-min_question+1;
    colname1=int2letter(colstart);
    colname2=int2letter(nr_questions+colstart-1+free_text_q);
    coltot  =int2letter(nr_questions+colstart+free_text_q);
    coltotrounded=int2letter(nr_questions+colstart+1+free_text_q);

    first_stuline=12;  # first student line!
    if(max_nr_fields>expected_nr_fields+1)
	first_stuline=first_stuline+max_nr_fields-expected_nr_fields-1;

    line=first_stuline-1;

#   printf "student_name%cstudent_first_name%cstudent_id%cRounded TOTAL",OOFS,OOFS,OOFS > ooffile;
    printf "%c%c%c",OOFS,OOFS,OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c Q%3d",OOFS,q > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c QT%3d",OOFS,q > ooffile;
    printf "%cTOTAL%crounding%c%c%cdetail",OOFS,OOFS,OOFS,OOFS,OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c=%s1",OOFS,int2letter(colstart+q-min_question) > ooffile;
    printf "\n" > ooffile;
    ###### NEWLINE

    printf "coefficients" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c %f",OOFS,coeff[q] > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c %f",OOFS,ft_coeff[q] > ooffile;
    printf "%c=SUM($%s$2:$%s$2)%c0.1\n",OOFS,colname1,colname2,OOFS > ooffile;
    ###### NEWLINE

    printf "max_points_per_question" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c %f",OOFS,good[q] > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c %f",OOFS,ft_good[q] > ooffile;
    printf "%c=SUMPRODUCT($%s$2:$%s$2;$%s$3:$%s$3)",OOFS,colname1,colname2,colname1,colname2 > ooffile;
    printf "%cmax mark (without bonus)\n",OOFS > ooffile;
    ###### NEWLINE

    printf "relative_min_points_per_question" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c %f",OOFS,bad[q] > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c %f",OOFS,ft_bad[q] > ooffile;
    printf "%c=SUMPRODUCT($%s$2:$%s$2;$%s$4:$%s$4;$%s$7:$%s$7;1/$%s$6:$%s$6)-SUMPRODUCT($%s$2:$%s$2;$%s$4:$%s$4;$%s$6:$%s$6;1/$%s$6:$%s$6)",OOFS,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2 > ooffile;
    printf "%cmin mark (without bonus)\n",OOFS > ooffile;
    ###### NEWLINE

    printf "bonus (gift)" > ooffile
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c %4d",OOFS,bonus[q] > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c %4d",OOFS,ft_bonus[q] > ooffile;
    printf "%c=SUM($%s$5:$%s$5)\n",OOFS,colname1,colname2 > ooffile;
    ###### NEWLINE

    printf "nr_expected_answers" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c %4d",OOFS,nr_correct[q] > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c %4d",OOFS,ft_nr_answers[q] > ooffile;
    printf "%c=SUM(%s6:%s6)\n",OOFS,colname1,colname2 > ooffile;
    ###### NEWLINE

    printf "nr_max_answers" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	if(nr_answers[q]==999999 || nr_answers[q]==0)
	    printf "%c=NA()",OOFS > ooffile;
	else
	    printf "%c %4d",OOFS,nr_answers[q] > ooffile;
    for(q=1;q<=free_text_q;q++)
	# Write nr_expected_answers again...
	printf "%c %4d",OOFS,ft_nr_answers[q] > ooffile;
    printf "%c=SUM(%s7:%s7)\n",OOFS,colname1,colname2 > ooffile;
    ###### NEWLINE

    printf "bottom_limit_mark_per_question" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++) {
	if(bottom_limit[q,2]!=1)
	    printf "%c-100",OOFS > ooffile;
	else
	    printf "%c%f",OOFS,bottom_limit[q,1] > ooffile;
    }
    for(q=1;q<=free_text_q;q++)
	printf "%c0",OOFS > ooffile;
    printf "\n" > ooffile;
    ###### NEWLINE

    printf "question_real_weight_over_20" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=colstart;q<=nr_questions+colstart-1;q++) {
	colname=int2letter(q);
	printf "%c=%s$3*%s$2*$%s$%d/$%s$3",OOFS,colname,colname,coltot,first_stuline-1,coltot > ooffile;
    }
    for(q=1;q<=free_text_q;q++) {
	colname=int2letter(colstart+nr_questions+q-1);
	printf "%c=%s$3*%s$2*$%s$%d/$%s$3",OOFS,colname,colname,coltot,first_stuline-1,coltot > ooffile;
    }
    printf "%c=SUM($%s$9:$%s$9)\n",OOFS,colname1,colname2 > ooffile;
    ###### NEWLINE

    # Other additional fields
    for(af=expected_nr_fields+2;af<=max_nr_fields;af++) {
	printf "additional_field_%d",af-expected_nr_fields-1 > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=min_question;q<=max_question;q++)
	    printf "%c%s",OOFS,add_fields[q,af] > ooffile;
	for(q=1;q<=free_text_q;q++)
	    printf "%c%s",OOFS,ft_add_fields[q,af] > ooffile;
	printf "\n" > ooffile;
    }
    printf "\n" > ooffile;
    ###### NEWLINE - NEWLINE - NEWLINE

    printf "student_name%cstudent_first_name%cstudent_id%cRounded TOTAL",OOFS,OOFS,OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c",OOFS > ooffile;
    for(q=1;q<=free_text_q;q++)
	printf "%c",OOFS > ooffile;
    printf "%cTOTAL%cRounded TOTAL%crank\n",OOFS,OOFS,OOFS > ooffile;


    # output CORRECTION line
    printf "%s%c%s%c%s%c=$%s%d","CORRECTION",OOFS,"CORRECTION",OOFS,"00000",OOFS,coltot,line > ooffile;
    for(q=min_question;q<=max_question;q++) {
	currentcol=int2letter(colstart+q-min_question);
	printf "%c=IF(%s$5=0;MAX((%s$3*%d+%s$4*%d)/%s$6;%s$8);%s$5)",OOFS,currentcol,currentcol,nr_correct[q],currentcol,0,currentcol,currentcol,currentcol > ooffile;
    }
    for(q=1;q<=free_text_q;q++) {
	currentcol=int2letter(colstart+nr_questions+q-1);
	printf "%c=IF(%s$5=0;MAX((%s$3*%d+%s$4*%d)/%s$6;%s$8);%s$5)",OOFS,currentcol,currentcol,ft_nr_answers[q],currentcol,0,currentcol,currentcol,currentcol > ooffile;
    }

    printf "%c=20*SUMPRODUCT($%s$2:$%s$2;$%s%d:$%s%d)/$%s$3",OOFS,colname1,colname2,colname1,line,colname2,line,coltot > ooffile;
    printf "%c=MAX(0;ROUNDUP($%s%d/$%s$2)*$%s$2)",OOFS,coltot,line,coltotrounded,coltotrounded > ooffile;
    printf "%c%c%c",OOFS,OOFS,OOFS > ooffile;

    printf "expected_answers",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c%s",OOFS,expected_ans[q] > ooffile;
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE
}

#-------------------------------------------------------------------------------------------------------------
$1!~"Code" && $1!~"#" {

    # ticks[q,r] counts number of ticks for answer "r" at question "q";
    # r=0  stands for "no answer"
    # r=-1 stands for "perfect match"

    absent[$1]=0;
    if( !($1 in stutab) ) {
	stutab[$1]=sprintf("%s%c%s","_UNKNOWN",OOFS,"_UNKNOWN");
	printf "WARNING - unknown student ID %d in student file %s\n",$1,students > "/dev/stderr";
	if(nr_students>0) {
	    unknown=1; # FLAG this situation to warn about ranking errors
	    printf "\t\"RANK\" column has no more meaning\n" > "/dev/stderr";
	}
    }
    printf "%s%c%s%c=$%s%d",stutab[$1],OOFS,$1,OOFS,coltot,line > ooffile;   # remember that stutab[s] has two fields

    for(q=min_question;q<=max_question;q++) {

	corresponding_field=q-min_question+2;
	strg[q]=$corresponding_field;
	gsub("R","",$corresponding_field);
	
	nans=split($corresponding_field,tab,"\\");

	if(nans==0)
	    ticks[q,0]++;
	if(nans>1 && onlyone[q]==1)
	    printf "WARNING - %s (%s) has unexpectedly answered multiple times at question %d\n",stutab[$1],$1,q > "/dev/stderr";

	questugood=0;
	questubad=0;

	for(r in tab) {
	    # Count tick for points only if it has sense:
	    if(tab[r]>nr_answers[q])
		printf "WARNING - student %s (%s) answered out of expected range [1,%d] at question %d\n",stutab[$1],$1,nr_answers[q],q > "/dev/stderr";
	    else if(forbidden[q,tab[r]]==1)
		printf "WARNING - student %s (%s) answered a forbidden answer (%d) at question %d\n",stutab[$1],$1,tab[r],q > "/dev/stderr";

	    else
		if(corr[q,tab[r]]==1) # match!
		    questugood++;
		else if(corr[q,tab[r]]==0) # mismatch!
		    questubad++;

	    # Count tick anyhow for statistics
	    ticks[q,tab[r]]++;
	}
	if(questugood==nr_correct[q] && questubad==0)
	    # Perfect!
	    ticks[q,-1]++;
	
	# OpenOffice output
	currentcol=int2letter(colstart+q-min_question);
	# special mode: not-less-than bottom limit mark
	printf "%c=IF(%s$5=0;MAX((%s$3*%d+%s$4*%d)/%s$6;%s$8);%s$5)",OOFS,currentcol,currentcol,questugood,currentcol,questubad,currentcol,currentcol,currentcol > ooffile;
    }
    for(q=1;q<=free_text_q;q++)
	printf "%c",OOFS > ooffile;

    printf "%c=%s$%d*SUMPRODUCT($%s$2:$%s$2;$%s%d:$%s%d)/$%s$3",OOFS,coltot,first_stuline-1,colname1,colname2,colname1,line,colname2,line,coltot > ooffile;
    printf "%c=MAX(0;ROUNDUP($%s%d/$%s$2)*$%s$2)",OOFS,coltot,line,coltotrounded,coltotrounded > ooffile;
    if(unknown==1)
	printf "%c=NA()",OOFS > ooffile;
    else
	printf "%c=RANK(%s%d;%s$%d:%s$%d)",OOFS,coltotrounded,line,coltotrounded,first_stuline,coltotrounded,first_stuline+abs(nr_students)-1 > ooffile;

    printf "%c%c",OOFS,OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c%s",OOFS,strg[q] > ooffile;
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE
}

#-------------------------------------------------------------------------------------------------------------
END {
    # OpenOffice output
    # output ABSENTS
    for(s in stutab)
	if(absent[s]==1) {
	    printf "%s%c%s%c=$%s%d",stutab[s],OOFS,s,OOFS,coltot,line > ooffile;   # stutab[s] has two fields!!
	    for(q=min_question;q<=max_question;q++)
		printf "%c\"ABS\"",OOFS > ooffile;
	    for(q=1;q<=free_text_q;q++)
		printf "%c\"ABS\"",OOFS > ooffile;
	    printf "%cABS%cABS\n",OOFS,OOFS > ooffile;
	    line++;
	    nr_absents++;
	}
    printf "%d absent student(s)\n",nr_absents > "/dev/stdout";
    last_stuline=line-1;
    ###### NEWLINE

    printf "\n" > ooffile;
    line++;
    ###### NEWLINE

    # average over class for each question and global marks
    printf "avg" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    printf "=$%s%d",coltot,line > ooffile;
    for(q=1;q<=nr_questions+free_text_q+2;q++) { # +2 for "TOTAL" statistics
	colname=int2letter(colstart-1+q);
	printf "%c=AVERAGE(%s$%d:%s$%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
    }
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE

    # standart deviation over class for each question and global marks
    printf "rms" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    printf "=$%s%d",coltot,line > ooffile;
    for(q=1;q<=nr_questions+free_text_q+2;q++) { # +2 for "TOTAL" statistics
	colname=int2letter(colstart-1+q);
	printf "%c=STDEV(%s$%d:%s$%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
    }
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE

    # max mark for each question and global marks
    printf "max" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    printf "=$%s%d",coltot,line > ooffile;
    for(q=1;q<=nr_questions+free_text_q+2;q++) { # +2 for "TOTAL" statistics
	colname=int2letter(colstart-1+q);
	printf "%c=MAX(%s$%d:%s$%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
    }
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE

    # min mark for each question and global marks
    printf "min" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    printf "=$%s%d",coltot,line > ooffile;
    for(q=1;q<=nr_questions+free_text_q+2;q++) { # +2 for "TOTAL" statistics
	colname=int2letter(colstart-1+q);
	printf "%c=MIN(%s$%d:%s$%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
    }
    printf "\n\n" > ooffile;
    line+=2;
    ###### NEWLINE - NEWLINE

    # now output statistics per question per response over class
    printf "perfects" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c%d",OOFS,ticks[q,-1] > ooffile;
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE
    printf "no answer" > ooffile;
    for(q=2;q<=colstart-1;q++)
	printf "%c",OOFS > ooffile;
    for(q=min_question;q<=max_question;q++)
	printf "%c%d",OOFS,ticks[q,0] > ooffile;
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE

    for(r=1;r<=max_nr_answers;r++) {
	printf "answer %d",r > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=min_question;q<=max_question;q++)
	    if(r<=nr_answers[q])
		printf "%c%d",OOFS,ticks[q,r] > ooffile;
	    else
		printf "%c",OOFS > ooffile;
	printf "\n" > ooffile;
	line++;
	###### NEWLINE
    }
    printf "\n" > ooffile;
    line++;
    ###### NEWLINE

    # compute nr of present students and repartition of marks
    printf "presents%c=%s%d\n",OOFS,int2letter(2+1000-int(1000-20/binlength)),line+4 > ooffile;
    # 1000-int(1000-x) rounds "x" towards +infty (well... towards +1000)
    line++;
    ###### NEWLINE
	
    printf "absents%c=COUNTIF($%s$%d:$%s$%d;\"ABS\")\n\n",OOFS,colname1,first_stuline,colname1,last_stuline > ooffile;
    line+=2;
    ###### NEWLINE - NEWLINE

    # repartition...
    printf "marks" > ooffile;
    for(n=binlength;n<20;n+=binlength)
	printf "%c]%d;%d]",OOFS,n-binlength,n > ooffile;
    printf "%c>%d\n",OOFS,n-binlength > ooffile;
    line++;
    ###### NEWLINE

    printf "repartition" > ooffile;
    printf "%c=B%d",OOFS,line+1 > ooffile;
    for(n=binlength;n<20-binlength;n+=binlength)
	printf "%c=%s%d-%s%d",OOFS,int2letter(2+n/binlength),line+1,int2letter(1+n/binlength),line+1 > ooffile;
    printf "%c=COUNTIF($%s$%d:$%s$%d;\">%d\")",OOFS,coltot,first_stuline,coltot,last_stuline,n > ooffile;
    printf "%c=SUM(B%d:%s%d)\n",OOFS,line,int2letter(1+1000-int(1000-20/binlength)),line > ooffile;
    # 1000-int(1000-x) rounds "x" towards +infty (well... towards +1000)
    line++;
    ###### NEWLINE

    printf "cumulative" > ooffile;
    for(n=binlength;n<20;n+=binlength)
	printf "%c=COUNTIF($%s$%d:$%s$%d;\"<=%d\")",OOFS,coltot,first_stuline,coltot,last_stuline,n > ooffile;
    printf "%c=%s%d+%s%d\n",OOFS,int2letter(1000-int(1000-20/binlength)),line,int2letter(1+1000-int(1000-20/binlength)),line-1 > ooffile;
    line++;
    ###### NEWLINE

#-------------------------------------------------------------------------------------------------------------
#   Output particular corners in particular file
    printf "$A$%d:$%s$%d chartcorners\n",line-3,int2letter(1+1000-int(1000-20/binlength)),line-2 > cornersfile;
    printf "$%s$%d:$%s$%d lastcolumn\n",coltotrounded,first_stuline,coltotrounded,last_stuline+5 > cornersfile;
    printf "$%s$%d average\n",coltotrounded,last_stuline+2 > cornersfile;
    printf "$A$%d firstfreeline\n",line+1 > cornersfile;
    printf "$A$%d:$%s$%d studentsdata\n",first_stuline,int2letter(colstart+2*nr_questions+4+free_text_q),last_stuline > cornersfile;

}
