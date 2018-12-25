from flask import Flask, render_template, request, redirect, url_for
#import flask
import numpy as np
from forms.user import UserForm

from my_dao.userhelper import *
app = Flask(__name__)
app.secret_key = 'development key'

@app.route('/', methods=['GET', 'POST'])
def index():
    return render_template("login_temp.html")

@app.route('/<user>/view', methods=['GET', 'POST'])
def view(user):
    s0 = getDisc(user)
    s1 = s0[-1]
    s = ''
    for i in range (len(s0)):
        for j in range (len(s0[0])):
            if (s0[i][j] == None):
                s = s + '     ' + ' | ';
            else:
                s = s + str(s0[i][j]) + ' | ';
        s = s + '<br> ------------------------------- <br>'
    
    return s

@app.route('/api', methods=['POST'])
def entrance():
    if request.form["action"] == "user_update":
        user_login = request.form["login"]
        passw = request.form["password"]
        res = checkPass(user_login, passw)[0]
        result = res[0]
        if result == '404':
            return 'Извините, такой пользователь не зарегестрирован'
        elif result == 'OK':
            return redirect(url_for('user_page', user=user_login))        
    elif request.form["action"] == "to_disciplines":
        return 'He-he'
#        return 


@app.route('/<user>/userpage', methods=['GET', 'POST'])
def user_page(user):
    user = getUser(user)
    keys = ["login", "passw", "user_role", "user_name", "surname", "fathername", "university", "faculty", "group_number", "ops", "book_num"]
    v = list(user[0])
    for i in range (len(keys)):
        user_dict[keys[i]] = v[i]
    return render_template("userpage_temp.html", user = user_dict)

@app.route('/<user>/disciplines', methods=['GET', 'POST'])
def view_recbook(user):
    keys = ["discipline", "semester", "hours", "credits", "mark", "tutor", "date" ]
    #v = list(user[0])
    #for i in range (len(keys)):
    #    user_dict[keys[i]] = v[i]
    res = getMedium(user)[0]; med_mark = res[0]
    res = getCredits(user)[0]; total_credit = res[0] 
    return render_template("recbook_temp.html", record_book = record_book, credit = total_credit, medium = med_mark)

if __name__ == '__main__':
       user_dict = {
            "login" : None,
            "passw" : None,
            "user_role" : None,
            "user_name" : None,
            "surname" : None,
            "fathername" : None,
            "university" : None,
            "faculty" : None,
            "group_number" : None,
            "ops": None,
            "book_num" : None
            }
       record_book = {
            "discipline" : "ABC",
            "semester" : "3",
            "hours" : "78",
            "credits" : "3",
            "mark" : "65",
            "tutor" : "tutor1",
            "date" : "22.11"
            }
       app.run(debug=True)
