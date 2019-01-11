import cx_Oracle
from my_dao.credentials import *

def Acces(user, rights):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    result = cursor.callfunc("recbook_func_package.check_Permission", cx_Oracle.NUMBER,( user, rights))
    cursor.close()
    connection.close()

    return result

def CurentSemester(user_name):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()
    query = "Select recbook_func_package.current_sem('" + user_name + "') from dual"
    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()
    connection.close()

    return result[0][0]

def getDisc(user_name, semestr = None):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    if (semestr == None):
        query = "Select subject, semester, hours, credits, mark, examenator, e_date from TABLE(recbook_func_package.view_disciplines_all('" + user_name + "'))"
    else:
        query = "Select subject, semester, hours, credits, mark, examenator, e_date from TABLE(recbook_func_package.view_disciplines_semester('" + user_name + "', " + str(semestr) + "))"
    cursor.execute(query)
    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result


def getDiscTeacher(user_name):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    query = "SELECT Discname, hours, credits FROM teacher_assign INNER JOIN discipline ON discipline.discname = teacher_assign.discipline_fk where teacher_fk = '" + user_name + "'";
    cursor.execute(query)
    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def getMedium(user, semestr = None):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()
    if semestr == None:
        query = "select recbook_func_package.view_medium_all('" + user + "') from dual"
    else:
        query = "select recbook_func_package.view_medium('" + user + "', " + str(semestr) + ") from dual" 
    cursor.execute(query)
    medium = cursor.fetchall()

    cursor.close()
    connection.close()
    med = medium[0][0]

    return med

def getCredits(user):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()
    query = "select recbook_func_package.view_credits('" + user + "') from dual"
    cursor.execute(query)
    total_credits = cursor.fetchall()

    cursor.close()
    connection.close()
    credit = total_credits[0][0]
    return credit

def checkPass(user_name, user_pass):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()
    query = "select recbook_func_package.Authorisation('" + user_name + "', '" + user_pass + "') from dual" 
    cursor.execute(query)
    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def getUser(user):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()
    query = "SELECT user_role FROM USERS WHERE (users.login = '" + user + "')";
    cursor.execute(query)
    result = cursor.fetchall()
    role = result[0][0]
    if role == 'student':
        query = "SELECT * FROM USERS INNER JOIN Record_book ON users.login = record_book.login WHERE (users.login = '" + user + "' AND record_book.is_expired is null)"
        cursor.execute(query)
        result = cursor.fetchall()
    else:
        query = "SELECT * FROM USERS INNER JOIN Workplace_info ON users.login = Workplace_info.login WHERE (users.login = '" + user + "' )"
        cursor.execute(query)
        result = cursor.fetchall()        

    cursor.close()
    connection.close()

    return result

def PutMark(subject, student, teacher, mark):

    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    result = cursor.callfunc("recbook_func_package.put_mark", cx_Oracle.STRING,(subject, student, teacher, mark))
    cursor.close()
    connection.close()

    return result

def SelectSubject(subject, student, semester):

    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    result = cursor.callfunc("recbook_func_package.select_subject", cx_Oracle.STRING,(subject, student, semester))
    cursor.close()
    connection.close()

    return result

def AddSubject (subj_NAME, hours_in, credits_in, teacher_login):

    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    result = cursor.callfunc("recbook_func_package.add_subject", cx_Oracle.STRING,(subj_NAME, hours_in, credits_in, teacher_login))
    cursor.close()
    connection.close()

    return result

def AddStudent(login, passw, Name, Surname, University, Faculty, Group, book_num):

    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    result = cursor.callfunc("recbook_func_package.add_Student", cx_Oracle.STRING,(login, passw, Name, Surname, 'Null', University, Faculty, Group, book_num))
    cursor.close()
    connection.close()

    return result
