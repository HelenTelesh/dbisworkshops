create or replace PACKAGE recbook_func_package IS

--тип даних рядка, що містить поля з імям пасажира(user_firstname) та його місцем у потягу(user_seat_of_train)

TYPE rowDiscInfo IS RECORD(
subject studentsubj.subj_name%TYPE, 
semester studentsubj.semestr%TYPE, 
hours discipline.hours%TYPE, 
credits discipline.credits%TYPE, 
Mark studentsubj.mark%TYPE, 
Examenator users.login%TYPE, 
e_date studentsubj.exam_date%TYPE);

-- таблиця з рядків типу rowGetTicket

TYPE Disc_info_tbl IS TABLE OF rowDiscInfo;

-- мои исключения
existance_err EXCEPTION;
PRAGMA EXCEPTION_INIT(existance_err, -00001);

not_null_err EXCEPTION;
PRAGMA EXCEPTION_INIT(not_null_err, -01400);

constraint_violated EXCEPTION;
PRAGMA EXCEPTION_INIT(constraint_violated, -02290);

parent_key_err EXCEPTION;
PRAGMA EXCEPTION_INIT(parent_key_err, -02291);

number_format_err EXCEPTION;
PRAGMA EXCEPTION_INIT(number_format_err, -01722);
-- 
FUNCTION add_Student(login_new IN users.login%TYPE, password_new IN users.passw%TYPE, name_new IN users.user_name%TYPE, surname_new IN users.surname%TYPE, fathername_new IN users.fathername%TYPE, university_in IN record_book.university_name%TYPE, faculty_in IN record_book.faculty_name%TYPE, group_in IN record_book.group_number%TYPE, new_record IN record_book.book_num%TYPE)
  RETURN varchar2;

FUNCTION add_subject(subj_NAME IN discipline.discname%TYPE, hours_in IN discipline.hours%TYPE, credits_in IN discipline.credits%TYPE, teacher_login IN users.login%TYPE)
  RETURN varchar2;

FUNCTION make_teacher(subj_NAME IN discipline.discname%TYPE, user_login IN users.login%TYPE)
  RETURN number;

FUNCTION put_mark(subject IN discipline.discname%TYPE, student_login IN users.login%TYPE, teacher_login IN users.login%TYPE, disc_mark IN studentsubj.mark%TYPE)
  RETURN varchar2;

FUNCTION select_subject(subj_NAME IN discipline.discname%TYPE, student_login IN users.login%TYPE, semestr_in IN studentsubj.semestr%TYPE)
  RETURN varchar2;

FUNCTION view_disciplines_semester (user_login IN users.login%TYPE, semester IN studentsubj.semestr%TYPE)
    RETURN Disc_info_tbl
    PIPELINED;

FUNCTION view_disciplines_ALL (user_login IN users.login%TYPE)
    RETURN Disc_info_tbl
    PIPELINED;

FUNCTION check_Permission( login_in IN users.login%TYPE, rights_level IN users.user_role%TYPE)
   RETURN number;

FUNCTION check_put_mark(teacher_login IN users.login%TYPE, student_login IN users.login%TYPE, sbj_name IN discipline.discname%TYPE)
   RETURN number;

FUNCTION current_sem(login_in IN users.login%TYPE)
   RETURN number;

FUNCTION view_credits(user_login IN users.login%TYPE)
   RETURN number;

FUNCTION view_medium_all(user_login IN users.login%TYPE)
   RETURN number;

FUNCTION view_medium(user_login IN users.login%TYPE, semester IN studentsubj.semestr%TYPE)
   RETURN number;

FUNCTION Authorisation( login_in IN users.login%TYPE, password_in IN users.passw%TYPE )
   RETURN varchar2;
END recbook_func_package;

/
create or replace PACKAGE BODY recbook_func_package IS

FUNCTION add_subject(subj_NAME IN discipline.discname%TYPE, hours_in IN discipline.hours%TYPE, credits_in IN discipline.credits%TYPE, teacher_login IN users.login%TYPE)
  RETURN varchar2
IS
  res varchar2(30);
  mid_res number;
  tutor_err EXCEPTION;
BEGIN
  insert into discipline (DISCNAME, HOURS, CREDITS) 
  values (subj_NAME, hours_in, credits_in); 
  mid_res := make_teacher(subj_NAME, teacher_login);
  if mid_res = 0 then 
    COMMIT;
    res :=  'OK';
    else
        raise tutor_err;
    end if;
  RETURN res;
EXCEPTION
   WHEN tutor_err THEN
   if mid_res = -1 
      then res:= 'OK';
   elsif mid_res = 1 
      then ROLLBACK; res:= 'user not exists';
   else 
      ROLLBACK; res:= mid_res;
    end if;
    Return res;
   WHEN not_null_err THEN
    ROLLBACK;
    RETURN 'Cannot be null';
  WHEN number_format_err THEN
    ROLLBACK;
    RETURN 'Incorect format';
  WHEN constraint_violated THEN
    ROLLBACK;
    RETURN 'Wrong data';
  WHEN existance_err THEN
    ROLLBACK;
    RETURN 'Already exists';
  WHEN OTHERS THEN
    RETURN 'Произошла ошибка: '||SQLCODE;
       END add_subject;

FUNCTION make_teacher(subj_NAME IN discipline.discname%TYPE, user_login IN users.login%TYPE)
  RETURN number
IS
    user_university varchar2(100);
    user_faculty varchar2(50);
    already number;
BEGIN
    insert into teacher_assign (teacher_fk, discipline_fk) 
    values (user_login, subj_NAME);
     select count(*)
     Into already
     FROM workplace_info
     WHERE workplace_info.login = user_login;

     if already = 0 
        then
            UPDATE Users
            SET user_role = 'teacher'
            WHERE users.login = user_login;
            select record_book.university_name
            Into user_university
            from Record_book
            where record_book.login = user_login;

            select record_book.faculty_name
            Into user_faculty
            from Record_book
            where record_book.login = user_login;
            insert into workplace_info (login, university, faculty) values (user_login, user_university, user_faculty);
        end if;
     RETURN 0;
EXCEPTION
  WHEN parent_key_err THEN
    ROLLBACK;
    RETURN 1;
  WHEN existance_err THEN
    ROLLBACK;
    RETURN -1;
  WHEN OTHERS THEN
    RETURN SQLCODE;
       END make_teacher;

FUNCTION put_mark(subject IN discipline.discname%TYPE, student_login IN users.login%TYPE, teacher_login IN users.login%TYPE, disc_mark IN studentsubj.mark%TYPE)
  RETURN varchar2
IS
  res varchar2(30);
  mid_res number;
  marked_err EXCEPTION;
  wrong_tutor_err EXCEPTION;
  wrong_mark_ex EXCEPTION;
  curr_mark number;
  amount number;
  user_count number;
  CURSOR student IS
            SELECT studentsubj.mark
            FROM Studentsubj
            WHERE studentsubj.subj_name = subject AND studentsubj.student = student_login;
BEGIN
  mid_res := check_put_mark(teacher_login, student_login, subject);
  if mid_res != '1'
  then raise wrong_tutor_err;
  end if;
  if disc_mark < 60 
    then raise wrong_mark_ex;
  end if;
  if (subject IS NULL OR student_login IS NULL OR teacher_login IS NULL OR disc_mark IS NULL)
    then raise not_null_err;
    end if;
  OPEN student;
   FETCH student INTO curr_mark;
  close student;
  select count(*)
  into user_count
  FROM Studentsubj
  WHERE studentsubj.subj_name = subject AND studentsubj.student = student_login;
  if user_count = 0 then raise parent_key_err; end if;

  select count(*)
  into user_count
  FROM users
  WHERE users.login = teacher_login AND users.user_role = 'teacher';
  if user_count = 0 then raise parent_key_err; end if;

  if (curr_mark IS NULL OR disc_mark > curr_mark)   then
     UPDATE studentsubj
     SET mark = disc_mark,
         examenator = teacher_login,                                                                                                                                                                                                                                                                                           
         exam_date = sysdate
     WHERE ((studentsubj.subj_name = subject) AND (studentsubj.student = student_login)) ; 
     res := 'OK'; COMMIT; 
  else
    raise marked_err;
  end if;
    RETURN res;
EXCEPTION
  WHEN wrong_tutor_err THEN
    RETURN 'No rights';
  WHEN wrong_mark_ex THEN
    RETURN 'Wrong mark';
  WHEN marked_err THEN
    ROLLBACK;
    RETURN 'Already has better mark';
  WHEN parent_key_err THEN
    ROLLBACK;
    RETURN 'References to nowhere';
  WHEN existance_err THEN
    ROLLBACK;
    RETURN 'Already exists';
  WHEN not_null_err THEN
    ROLLBACK;
    RETURN 'Cannot be null';
  WHEN constraint_violated THEN
    ROLLBACK;
    RETURN 'Wrong data';

  WHEN OTHERS THEN
    RETURN 'Произошла ошибка: '||SQLCODE;
       END put_mark;

FUNCTION select_subject(subj_NAME IN discipline.discname%TYPE, student_login IN users.login%TYPE, semestr_in IN studentsubj.semestr%TYPE)
  RETURN varchar2
IS
BEGIN
     insert into studentsubj (STUDENT, SUBJ_NAME, SEMESTR) 
       values (student_login, subj_NAME, semestr_in);
       COMMIT; RETURN 'OK'; 
EXCEPTION
  WHEN existance_err THEN
    ROLLBACK;
    RETURN 'Already assigned';
  WHEN parent_key_err THEN
    ROLLBACK;
    RETURN 'References to nowhere';
  WHEN not_null_err THEN
    ROLLBACK;
    RETURN 'Cannot be null';
  WHEN number_format_err THEN
    ROLLBACK;
    RETURN 'Incorect format';
  WHEN constraint_violated THEN
    ROLLBACK;
    RETURN 'Wrong data';

  WHEN OTHERS THEN
    ROLLBACK;
    RETURN 'Произошла ошибка: '||SQLCODE;    
       END select_subject;

FUNCTION add_Student(login_new IN users.login%TYPE, password_new IN users.passw%TYPE, name_new IN users.user_name%TYPE, surname_new IN users.surname%TYPE, fathername_new IN users.fathername%TYPE, university_in IN record_book.university_name%TYPE, faculty_in IN record_book.faculty_name%TYPE, group_in IN record_book.group_number%TYPE, new_record IN record_book.book_num%TYPE)
  RETURN varchar2
  IS
  result varchar2(30);
BEGIN
  insert into Users (login, passw, user_role, user_name, surname, fathername) 
          values (login_new, password_new, 'student', name_new, surname_new, fathername_new);
  insert into Record_book (login, UNIVERSITY_NAME, FACULTY_NAME, GROUP_NUMBER, BOOK_NUM) 
          values (login_new, university_in, faculty_in, group_in, new_record);
  result := 'OK';
  COMMIT;

 RETURN result;

EXCEPTION
  WHEN existance_err THEN
    ROLLBACK;
    RETURN 'Already exists';
  WHEN not_null_err THEN
    ROLLBACK;
    RETURN 'Cannot be null';
  WHEN constraint_violated THEN
    ROLLBACK;
    RETURN 'Wrong data';

  WHEN OTHERS THEN
    RETURN 'Произошла ошибка: '||SQLCODE;
END add_Student;

FUNCTION view_disciplines_semester (user_login IN users.login%TYPE, semester IN studentsubj.semestr%TYPE)
    RETURN Disc_info_tbl
    PIPELINED
    IS
        CURSOR DISCIPLINES IS
            SELECT studentsubj.subj_name, studentsubj.semestr, discipline.hours, discipline.credits, studentsubj.mark, studentsubj.examenator, studentsubj.exam_date
            FROM Studentsubj
            INNER JOIN Discipline
            ON StudentSubj.subj_name = discipline.discname
            WHERE (studentsubj.student = USER_LOGIN) AND (studentsubj.semestr = semester);

        BEGIN
            FOR curr IN DISCIPLINES
            LOOP
                PIPE ROW (curr);
            END LOOP;

    END view_disciplines_semester;

FUNCTION view_disciplines_ALL (user_login IN users.login%TYPE)
    RETURN Disc_info_tbl PIPELINED
    IS
/*        CURSOR DISCIPLINES IS
            SELECT studentsubj.subj_name, studentsubj.semestr, discipline.hours, discipline.credits, studentsubj.mark, studentsubj.examenator, studentsubj.exam_date
            FROM Studentsubj
            INNER JOIN Discipline
            ON StudentSubj.subj_name = discipline.discname
            WHERE (studentsubj.student = USER_LOGIN);
*/
        BEGIN
for curr in
    (
    SELECT studentsubj.subj_name, studentsubj.semestr, discipline.hours, discipline.credits, studentsubj.mark, studentsubj.examenator, studentsubj.exam_date
    FROM Studentsubj, Discipline
    WHERE (StudentSubj.subj_name = discipline.discname) AND (studentsubj.student = USER_LOGIN)
    ) 
    loop
    pipe row (curr);
    end loop; 
/*
            FOR curr IN DISCIPLINES
            LOOP
                PIPE ROW (curr);
            END LOOP;
*/
    END view_disciplines_ALL;

FUNCTION check_Permission( login_in IN users.login%TYPE, rights_level IN users.user_role%TYPE)
   RETURN number
IS
   result number;
   rights varchar2(10);

   cursor c1 is
   SELECT user_role
     FROM Users
     WHERE Users.login = login_in;

BEGIN
   open c1;
   fetch c1 into rights;
--      result := 'Error';
--  if c1%notfound then
--  result := 0;
--  end if;
   if rights = rights_level then
        result := 1;
    ELSE
        result := 0;
	end if;
   close c1;
RETURN result;   
       END check_Permission;

FUNCTION check_put_mark(teacher_login IN users.login%TYPE, student_login IN users.login%TYPE, sbj_name IN discipline.discname%TYPE)
   RETURN number
IS
   result number;
   is_teacher number;
   university_t varchar(100);
   faculty_t varchar(50);
   university_s varchar(100);
   faculty_s varchar(50);
   

BEGIN
    SELECT count(*)
    into is_teacher
    FROM teacher_assign
    WHERE teacher_assign.teacher_fk = teacher_login AND teacher_assign.discipline_fk = sbj_name;
   if is_teacher = 0 then
        result := 0;
    ELSE
        SELECT university
        into university_t
        FROM workplace_info
        WHERE login = teacher_login;
        SELECT faculty
        into faculty_t
        FROM workplace_info
        WHERE login = teacher_login;
        
        SELECT university_name
        into university_s
        FROM record_book
        WHERE login = student_login;
        SELECT faculty_name
        into faculty_s
        FROM record_book
        WHERE login = student_login;
        if (university_t = university_s AND faculty_t = faculty_s)
        then result:= 1;
        else
        result:= -1;
        end if;
	end if;
RETURN result;   
       END check_put_mark;

FUNCTION current_sem(login_in IN users.login%TYPE)
   RETURN number
IS
   sem number;

BEGIN
    sem:= 0;
    if login_in is null 
    then raise not_null_err;
    end if;
    SELECT MAX(studentsubj.semestr) 
    into sem
    FROM studentsubj 
    INNER JOIN Discipline 
    ON studentsubj.subj_name = discipline.discname
    WHERE (studentsubj.student = login_in) and studentsubj.mark IS null 
    ORDER BY studentsubj.semestr;

    if sem = 0 
    then SELECT MAX(studentsubj.semestr) 
         into sem
         FROM studentsubj 
         INNER JOIN Discipline 
         ON studentsubj.subj_name = discipline.discname
         WHERE (studentsubj.student = login_in) 
         ORDER BY studentsubj.semestr;
    end if;
RETURN sem;

EXCEPTION
  WHEN parent_key_err THEN
    RETURN -1;
  WHEN not_null_err THEN
    RETURN -2;
  WHEN OTHERS THEN
    RETURN SQLCODE;  
END current_sem;


FUNCTION view_credits(user_login IN users.login%TYPE)
   RETURN number
IS
   total_credits number;
   cursor t_credit is
    Select sum(CREDITS)
    From StudentSubj 
    INNER JOIN Discipline
    ON StudentSubj.subj_name = discipline.discname
    where (student = user_login) AND (mark IS NOT NULL);

BEGIN
OPEN t_credit;
   FETCH t_credit INTO total_credits;
   if t_credit%notfound then
      total_credits := 0;
    end if;
close t_credit;
RETURN total_credits;   
       END view_credits;

FUNCTION view_medium_all(user_login IN users.login%TYPE)
   RETURN number
IS
   medium_mark number;
   total number;
   amount number;
   cursor t_mark is
    Select sum(mark)
    From StudentSubj 
    where (student = user_login);
   cursor c_marks is
    Select count(studentsubj.subj_name)
    From StudentSubj 
    where (student = user_login) AND (mark IS NOT NULL);

BEGIN
OPEN t_mark;
OPEN c_marks;
   FETCH t_mark INTO total;
   if t_mark%notfound then
      total:= 0;
    end if;
   FETCH c_marks INTO amount;
   if c_marks%notfound then
      amount:= 1;
    end if;

medium_mark := total/amount;
CLOSE t_mark;
CLOSE c_marks;
RETURN medium_mark;   
       END view_medium_all;

FUNCTION view_medium(user_login IN users.login%TYPE, semester IN studentsubj.semestr%TYPE)
   RETURN number
IS
   medium_mark number;
   total number;
   amount number;
   cursor t_mark is
    Select sum(mark)
    From StudentSubj 
    where (student = user_login) AND (semestr = semester);
   cursor c_marks is
    Select count(studentsubj.subj_name)
    From StudentSubj 
    where (student = user_login) AND (semestr = semester) AND (mark IS NOT NULL);

BEGIN
OPEN t_mark;
OPEN c_marks;
   FETCH t_mark INTO total;
   if t_mark%notfound then
      total:= 0;
    end if;
   FETCH c_marks INTO amount;
   if c_marks%notfound then
      amount:= 1;
    end if;

medium_mark := total/amount;
CLOSE t_mark;
CLOSE c_marks;
RETURN medium_mark;   
       END view_medium;

FUNCTION Authorisation( login_in IN users.login%TYPE, password_in IN users.passw%TYPE )
   RETURN varchar2
  IS
   result varchar2(5);
correct_passw users.passw%TYPE;

   cursor c1 is
   SELECT passw
     FROM Users
     WHERE Users.login = login_in;

BEGIN
   open c1;
   fetch c1 into correct_passw;
   result := 'Error';
  if c1%notfound then
  result := '404';
  end if;
   if password_in = correct_passw then
        result := 'OK';
	end if;
   close c1;
RETURN result; 
       END Authorisation;
END;