CREATE OR REPLACE PACKAGE recbook_func_package IS

--тип даних рядка, що містить поля

TYPE rowDiscInfo IS RECORD(
student users.login%TYPE, 
subject studentsubj.subj_name%TYPE, 
semester studentsubj.semestr%TYPE, 
hours discipline.hours%TYPE, 
credits discipline.credits%TYPE, 
Mark studentsubj.mark%TYPE, 
Examenator users.login%TYPE, 
e_date studentsubj.exam_date%TYPE);

-- таблиця з рядків типу 

TYPE Disc_info_tbl IS TABLE OF rowDiscInfo;

-- це 

PROCEDURE add_Student(login_new IN users.login%TYPE, password_new IN users.passw%TYPE, name_new IN users.user_name%TYPE, surname_new IN users.surname%TYPE, fathername_new IN users.fathername%TYPE, university_in IN record_book.university_name%TYPE, faculty_in IN record_book.faculty_name%TYPE, group_in IN record_book.group_number%TYPE, new_record IN record_book.book_num%TYPE);
PROCEDURE add_subject(subj_NAME IN discipline.discname%TYPE, hours_in IN discipline.hours%TYPE, credits_in IN discipline.credits%TYPE, teacher_login IN users.login%TYPE);
PROCEDURE make_teacher(subj_NAME IN discipline.discname%TYPE, user_login IN users.login%TYPE);
PROCEDURE put_mark(subj_NAME IN discipline.discname%TYPE, student_login IN users.login%TYPE, teacher_login IN users.login%TYPE, disc_mark IN studentsubj.mark%TYPE);
PROCEDURE select_subject(subj_NAME IN discipline.discname%TYPE, student_login IN users.login%TYPE, semestr_in IN studentsubj.semestr%TYPE);

FUNCTION view_disciplines_semester (user_login IN users.login%TYPE, semester IN studentsubj.semestr%TYPE)
    RETURN Disc_info_tbl
    PIPELINED;

FUNCTION view_disciplines_ALL (user_login IN users.login%TYPE)
    RETURN Disc_info_tbl
    PIPELINED;

FUNCTION check_Permission( login_in IN users.login%TYPE, rights_level IN users.user_role%TYPE)
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
CREATE OR REPLACE PACKAGE BODY recbook_func_package IS

PROCEDURE add_Student(login_new IN users.login%TYPE, password_new IN users.passw%TYPE, name_new IN users.user_name%TYPE, surname_new IN users.surname%TYPE, fathername_new IN users.fathername%TYPE, university_in IN record_book.university_name%TYPE, faculty_in IN record_book.faculty_name%TYPE, group_in IN record_book.group_number%TYPE, new_record IN record_book.book_num%TYPE)
IS
BEGIN
  insert into Users (login, passw, user_role, user_name, surname, fathername) 
  values (login_new, password_new, 'student', name_new, surname_new, fathername_new);

  insert into Record_book (login, UNIVERSITY_NAME, FACULTY_NAME, GROUP_NUMBER, BOOK_NUM) 
  values (login_new, university_in, faculty_in, group_in, new_record);

--  EXCEPTION
--   WHEN OTHERS THEN  result:= 1;
       END add_Student;
       
PROCEDURE add_subject(subj_NAME IN discipline.discname%TYPE, hours_in IN discipline.hours%TYPE, credits_in IN discipline.credits%TYPE, teacher_login IN users.login%TYPE)
IS
BEGIN
  insert into discipline (DISCNAME, HOURS, CREDITS) 
  values (subj_NAME, hours_in, credits_in);
  make_teacher(subj_NAME, teacher_login);
 -- EXCEPTION
--   WHEN OTHERS THEN  result:= 1; 
       END add_subject;

PROCEDURE make_teacher(subj_NAME IN discipline.discname%TYPE, user_login IN users.login%TYPE)
IS
BEGIN
     insert into teacher_assign (teacher_fk, discipline_fk) values (subj_name, user_login);
     UPDATE Users
     SET user_role = 'teacher'
     WHERE users.login = user_login;
--EXCEPTION
--   WHEN OTHERS THEN  result:= 1;
       END make_teacher;
       
PROCEDURE put_mark(subj_NAME IN discipline.discname%TYPE, student_login IN users.login%TYPE, teacher_login IN users.login%TYPE, disc_mark IN studentsubj.mark%TYPE)
IS
BEGIN
     UPDATE studentsubj
     SET mark = disc_mark,
         examenator = teacher_login,
         exam_date = sysdate
     WHERE studentsubj.subj_name = subj_name AND studentsubj.student = student_login ;

--EXCEPTION
--   WHEN OTHERS THEN  result:= 1;
       END put_mark;
       
PROCEDURE select_subject(subj_NAME IN discipline.discname%TYPE, student_login IN users.login%TYPE, semestr_in IN studentsubj.semestr%TYPE)
IS
BEGIN
     insert into studentsubj (STUDENT, SUBJ_NAME, SEMESTR) 
       values (student_login, subj_NAME, semestr_in);
--EXCEPTION
--   WHEN OTHERS THEN  result:= 1;    
       END select_subject;
       
FUNCTION view_disciplines_semester (user_login IN users.login%TYPE, semester IN studentsubj.semestr%TYPE)
    RETURN Disc_info_tbl
    PIPELINED
    IS
        CURSOR DISCIPLINES IS
            SELECT student, studentsubj.subj_name, studentsubj.semestr, discipline.hours, discipline.credits, studentsubj.mark, studentsubj.examenator, studentsubj.exam_date
            FROM Studentsubj
            INNER JOIN Discipline
            ON StudentSubj.subj_name = discipline.discname
            WHERE (studentsubj.student = USER_LOGIN) AND (studentsubj.semestr = semester);

        BEGIN

            FOR curr IN disciplines
            LOOP
                PIPE ROW (curr);
            END LOOP;

    END view_disciplines_semester;

FUNCTION view_disciplines_ALL (user_login IN users.login%TYPE)
    RETURN Disc_info_tbl
    PIPELINED
    IS
        CURSOR DISCIPLINES IS
            SELECT student, studentsubj.subj_name, studentsubj.semestr, discipline.hours, discipline.credits, studentsubj.mark, studentsubj.examenator, studentsubj.exam_date
            FROM Studentsubj
            INNER JOIN Discipline
            ON StudentSubj.subj_name = discipline.discname
            WHERE (studentsubj.student = USER_LOGIN);

        BEGIN

            FOR curr IN disciplines
            LOOP
                PIPE ROW (curr);
            END LOOP;

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