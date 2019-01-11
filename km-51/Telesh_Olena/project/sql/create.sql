-- Creating tables

CREATE TABLE Record_book
(
university_name VARCHAR2(100) NOT NULL,
faculty_name VARCHAR2(50) NOT NULL,
group_number VARCHAR2(10) NOT NULL,
login VARCHAR2(50) NOT NULL,
book_num VARCHAR2(10) NOT NULL
);
CREATE TABLE Roles
(
user_role VARCHAR2(8) NOT NULL
);
CREATE TABLE Users
(
login VARCHAR2(50) NOT NULL,
passw VARCHAR2(50) NOT NULL,
user_role VARCHAR2(8) NOT NULL,
user_name VARCHAR2(25) NOT NULL,
surname VARCHAR2(25) NOT NULL,
fathername VARCHAR2(50) NULL
);
CREATE TABLE Discipline
(
discName VARCHAR2(100) NOT NULL,
hours INTEGER NOT NULL,
credits INTEGER NOT NULL
);
CREATE TABLE StudentSubj
(
student VARCHAR2(50) NOT NULL,
subj_name VARCHAR2(100) NOT NULL,
semestr INTEGER NOT NULL,
mark INTEGER NULL,
examenator VARCHAR2(50) NULL,
exam_date DATE NULL
);
CREATE TABLE Teacher_Assign 
(
teacher_fk VARCHAR2(50) NOT NULL,
discipline_fk VARCHAR2(100) NOT NULL
);

-- primary keys

ALTER TABLE Record_book 
ADD CONSTRAINT Recbook_pk PRIMARY KEY (login, book_num);

ALTER TABLE Roles 
ADD CONSTRAINT roles_pk PRIMARY KEY (user_role);

ALTER TABLE Users 
ADD CONSTRAINT users_pk PRIMARY KEY (login);

ALTER TABLE Teacher_Assign 
ADD CONSTRAINT teachers_pk PRIMARY KEY (teacher_fk, discipline_fk);

ALTER TABLE StudentSubj 
ADD CONSTRAINT subject_pk PRIMARY KEY (student, subj_name);

ALTER TABLE DISCIPLINE 
ADD CONSTRAINT disc_pk PRIMARY KEY (discname); 

-- foreign keys

ALTER TABLE Users 
ADD CONSTRAINT role_fk FOREIGN KEY (user_role)
   REFERENCES Roles (user_role);

ALTER TABLE Teacher_Assign 
ADD CONSTRAINT tutor_fk FOREIGN KEY (teacher_fk)
   REFERENCES Users (login);

ALTER TABLE Teacher_Assign 
ADD CONSTRAINT subj_fk FOREIGN KEY (discipline_fk)
   REFERENCES Discipline (discname);

ALTER TABLE Studentsubj 
ADD CONSTRAINT student_fk FOREIGN KEY (student)
   REFERENCES Users (login);

ALTER TABLE Studentsubj
ADD CONSTRAINT subject_fk FOREIGN KEY (subj_name)
   REFERENCES Discipline (discname);

ALTER TABLE Record_book 
ADD CONSTRAINT recbook_owner_fk FOREIGN KEY (login)
   REFERENCES Users (login);

-- other constraints
alter table Roles 
add constraint role_bool check (user_role = 'student' OR user_role = 'teacher' OR user_role = 'admin');

ALTER TABLE Users 
drop CONSTRAINT name_check;
ALTER TABLE Users 
ADD CONSTRAINT name_check CHECK (REGEXP_LIKE (user_name, '^[A-Z][a-z]{1,}|^[À-ß][à-ÿ]{1,}'));

ALTER TABLE Users 
drop CONSTRAINT surname_check;
ALTER TABLE Users 
ADD CONSTRAINT surname_check CHECK (REGEXP_LIKE (surname, '^[A-Z][a-z]{1,}|^[À-ß][à-ÿ]{1,}'));

ALTER TABLE Users 
drop CONSTRAINT fathername_check;
ALTER TABLE Users 
ADD CONSTRAINT fathername_check CHECK (REGEXP_LIKE (fathername, '^[A-Z][a-z]{1,}|^[À-ß][à-ÿ]{1,}'));

ALTER TABLE Users 
drop CONSTRAINT login_check;
ALTER TABLE Users 
ADD CONSTRAINT login_check CHECK (REGEXP_LIKE (login, '([A-z 0-9]){4,}?'));

ALTER TABLE Users 
drop CONSTRAINT passw_check;
ALTER TABLE Users 
ADD CONSTRAINT passw_check CHECK (REGEXP_LIKE (passw, '([A-z0-9]){4,}'));

ALTER TABLE Record_book
drop CONSTRAINT university_check;
ALTER TABLE Record_book
ADD CONSTRAINT university_check CHECK (REGEXP_LIKE (UNIVERSITY_NAME, '([A-z À-ÿ])'));

ALTER TABLE Record_book
drop CONSTRAINT faculty_check;
ALTER TABLE Record_book
ADD CONSTRAINT faculty_check CHECK (REGEXP_LIKE (faculty_NAME, '([A-z À-ÿ])'));

ALTER TABLE Record_book
drop CONSTRAINT group_check;
ALTER TABLE Record_book
ADD CONSTRAINT group_check CHECK (REGEXP_LIKE (group_number, '([A-Z 0-9 -])'));

ALTER TABLE Record_book
drop CONSTRAINT number_check;
ALTER TABLE Record_book
ADD CONSTRAINT number_check CHECK (REGEXP_LIKE (book_num , '([A-Z0-9])'));

alter table Users 
add constraint user_name_constr UNIQUE (user_name, surname, fathername);

alter table Record_book 
add constraint rec_book_unq UNIQUE (book_num);

alter table Record_book 
add constraint rec_book_place UNIQUE (university_name, faculty_name, group_number);

alter table StudentSubj 
add constraint mark_positive check (mark>=60);
alter table StudentSubj 
add constraint semester_check check (semestr>=1);

alter table DISCIPLINE 
add constraint hours_pos check (hours>0);
alter table DISCIPLINE 
add constraint credits_pos check (credits>0);
ALTER TABLE Discipline
drop CONSTRAINT discname_check;
ALTER TABLE Discipline
ADD CONSTRAINT discname_check CHECK (REGEXP_LIKE (discname, '([A-z À-ÿ ³¿é 0-9 -])'));


CREATE TABLE Workplace_info
(
university VARCHAR2(100) NOT NULL,
faculty VARCHAR2(50) NOT NULL,
login VARCHAR2(50) NOT NULL
);
ALTER TABLE Workplace_info 
ADD CONSTRAINT workplace_pk PRIMARY KEY (login);
ALTER TABLE Workplace_info 
ADD CONSTRAINT worker_fk FOREIGN KEY (login)
   REFERENCES Users (login);
ALTER TABLE Workplace_info
ADD CONSTRAINT university_name_check CHECK (REGEXP_LIKE (UNIVERSITY, '([A-z À-ÿ])'));
ALTER TABLE Workplace_info
ADD CONSTRAINT faculty_name_check CHECK (REGEXP_LIKE (faculty, '([A-z À-ÿ])'));
alter table Workplace_info
add constraint workplace_not_double UNIQUE (university, faculty, login);

/

insert into Workplace_info (login, university, faculty) 
values ('user0', 'KPI', 'Biotechnology');
insert into Workplace_info (login, university, faculty) 
values ('tutor1', 'KPI', 'Applied Mathematics');
insert into Workplace_info (login, university, faculty) 
values ('tutor2', 'University of Schevchenko', 'Applied Mathematics');