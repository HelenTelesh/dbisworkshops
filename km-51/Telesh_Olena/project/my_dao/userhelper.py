import cx_Oracle
from dao.credentials import *

def getDisc(user_name):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    query = "Select subject, semester, hours, credits, mark, examenator, e_date from TABLE(recbook_func_package.view_disciplines_all('" + user_name + "'))"
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
        query = "select recbook_func_package.view_medium(" + user + "', '" + semestr + "') from dual" 
    cursor.execute(query)
    medium = cursor.fetchall()

    cursor.close()
    connection.close()

    return medium

def getCredits(user):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()
    query = "select recbook_func_package.view_credits('" + user + "') from dual"
    cursor.execute(query)
    total_credits = cursor.fetchall()

    cursor.close()
    connection.close()
    return total_credits

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

    query = "SELECT * FROM USERS INNER JOIN Record_book ON users.login = record_book.login WHERE (users.login = '" + user + "' AND record_book.is_expired is null)"
    cursor.execute(query)
    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result
