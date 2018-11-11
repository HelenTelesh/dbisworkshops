insert into Roles (user_role) 
values ('admin');
insert into Roles (user_role) 
values ('student');
insert into Roles (user_role) 
values ('teacher');

insert into Users (login, passw, user_role, user_name, surname, fathername) 
values ('user0', 'km43', 'admin', '����', 'Ivanov', 'Ivanovich');
insert into Users (login,passw, user_role, user_name, surname, fathername) 
values ('user1', '1111', 'student', 'Ivan', 'Sydorov', 'Ivanovich');
insert into Users (login,passw, user_role, user_name, surname) 
values ('user2', '2222', 'student', 'Daria', 'Ivanova');
insert into Users (login, passw, user_role, user_name, surname, fathername) 
values ('user3', '3333', 'student', 'Ivan', 'Ivanenko', 'Ivanovich');
insert into Users (login,passw, user_role, user_name, surname, fathername) 
values ('tutor1', 'abc1', 'teacher', 'Ivan', 'Petrenko', 'Yiriyovuch');
insert into Users (login,passw, user_role, user_name, surname) 
values ('tutor2', 'abc2', 'teacher', 'Taras', 'Schevchenko');

insert into Discipline (discName, hours, credits) 
values ('г������ ����������� ������', '60', '3');
insert into Discipline (discName, hours, credits)
values ('��������� �������', '150', '5');
insert into Discipline (discName, hours, credits)
values ('��������� ����-1', '168', '3');

insert into StudentSubj (student,subj_name, semestr, mark, examenator, exam_date) 
values ('user1', '��������� ����-1', '1', '75', 'tutor1', sysdate);
insert into StudentSubj (student,subj_name, semestr)  
values ('user2', '��������� ����-1', '1');
insert into StudentSubj (student,subj_name, semestr, mark, examenator, exam_date) 
values ('user3', '��������� ����-1', '1', '70', 'tutor2', sysdate);
insert into StudentSubj (student,subj_name, semestr)  
values ('user1', 'г������ ����������� ������', '6');
insert into StudentSubj (student,subj_name, semestr)  
values ('user3', 'г������ ����������� ������', '4');

insert into Teacher_Assign (teacher_fk,discipline_fk) 
values ('tutor2', '��������� ����-1');
insert into Teacher_Assign (teacher_fk,discipline_fk) 
values ('tutor1', '��������� ����-1');
insert into Teacher_Assign (teacher_fk,discipline_fk) 
values ('tutor2', 'г������ ����������� ������');
insert into Teacher_Assign (teacher_fk,discipline_fk) 
values ('tutor1', 'г������ ����������� ������');

insert into Record_book (university_name, faculty_name, group_number, login, book_num) 
values ('KPI', 'Applied Mathematics', '1', 'user1', 'AB111');
insert into Record_book (university_name, faculty_name, group_number, login, book_num) 
values ('KPI', 'Biotechnology', '1', 'user2', 'AB121');
insert into Record_book (university_name, faculty_name, group_number, login, book_num) 
values ('University of Schevchenko', 'Applied Mathematics', '12', 'user1', 'AB211');
