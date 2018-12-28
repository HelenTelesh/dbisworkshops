from flask import Flask, render_template, request, redirect, url_for

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
    else:
        return 'Error!'


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
    total_credit = getCredits(user);
    med_mark = getMedium(user);
    s0 = getDisc(user)
    keys = ["discipline", "semester", "hours", "credits", "mark", "tutor", "date" ]
    s_list = []
    for i in range (len(s0)):        
        for j in range (len(keys)):
            recbook_line[keys[j]] = s0[i][j]
        s_list.append(recbook_line.copy())

    return render_template("recbook_temp.html", lines = s_list, credit = total_credit, medium = med_mark)

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
       recbook_line = {    
            "discipline" : None,
            "semester" : None,
            "hours" : None,
            "credits" : None,
            "mark" : None,
            "tutor" : None,
            "date" : None
            }
       app.run(debug=True)
