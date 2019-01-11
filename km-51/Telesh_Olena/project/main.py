from flask import Flask, render_template, request, redirect, url_for

from my_dao.userhelper import *
app = Flask(__name__)
app.secret_key = 'development key'

@app.route('/', methods=['GET', 'POST'])
def index():
    return render_template("login_temp.html")

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
    user_dict["user_role"] = v[2]
    
    if user_dict["user_role"] == "student":
        for i in range (len(keys)):
            user_dict[keys[i]] = v[i]
    else:
        for i in range (len(keys) - 3):
            user_dict[keys[i]] = v[i]
        user_dict["book_num"] = None;
    return render_template("userpage_temp.html", user = user_dict);

@app.route('/<user>/disciplines', methods=['GET', 'POST'])
def view_recbook(user):
    permission = Acces(user, 'admin')
    if permission == 1:
        return "Acces denied!"
    elif user_dict["user_role"] == "teacher":
        keys = ["discipline", "hours", "credits"]
        s_list = []
        s0 = getDiscTeacher(user)
        for i in range (len(s0)):        
            for j in range (len(keys)):
                teacher_dict[keys[j]] = s0[i][j]
            s_list.append(teacher_dict.copy())
        return render_template("recbook.html", lines = s_list)
    else:
        semester = CurentSemester(user);
        return redirect(url_for('view_recbook_sem', user=user, sem = semester))
    
@app.route('/<user>/current', methods=['GET', 'POST'])
def view_current(user):
    semester = CurentSemester(user);
    return str(semester)

@app.route('/<user>/disciplines/all', methods=['GET', 'POST'])
def view_recbook_all(user):
    total_credit = getCredits(user);
    med_mark = getMedium(user);
    s0 = getDisc(user)
    keys = ["discipline", "semester", "hours", "credits", "mark", "tutor", "date" ]
    s_list = []
    for i in range (len(s0)):        
        for j in range (len(keys)):
            recbook_line[keys[j]] = s0[i][j]
        s_list.append(recbook_line.copy())
    return render_template("recbook_temp.html", lines = s_list, credit = total_credit, medium = med_mark, curr_sem = "")


@app.route('/<user>/disciplines/<sem>', methods=['GET', 'POST'])
def view_recbook_sem(user, sem):
    keys = ["discipline", "semester", "hours", "credits", "mark", "tutor", "date" ]
##    if sem == 'all':
##        semester = None;
##        s0 = getDisc(user);
##    else:
    semester = int(sem);
    s0 = getDisc(user, semester);
    total_credit = getCredits(user);
    med_mark = getMedium(user, semester);
    
    if s0 == []:
        s0 = [('', '', '', '', '', '', '')]
    s_list = []
    for i in range (len(s0)):        
        for j in range (len(keys)):
            recbook_line[keys[j]] = s0[i][j]
        s_list.append(recbook_line.copy())
        return render_template("recbook_temp.html", lines = s_list, credit = total_credit, medium = med_mark, curr_sem = semester)

@app.route('/<user>/add_discipline', methods=['GET', 'POST'])
def show_addDisc(user):
    permission = Acces(user, 'admin')
    if permission == 1:
        return render_template("add_disc_temp.html")
    else:
        return "Acces denied!"

@app.route('/add_disc', methods=['POST'])
def addDisc():
    subject = None;
    hours = None;
    credit = None;
    teacher = None;
    if request.form["action"] == "add_subject":
        subject = request.form["subject"];
        hours = request.form["hours"];
        credit = request.form["credits"];
        teacher = request.form["tutor"];
    
    Res = AddSubject(subject, hours, credit, teacher);
    if Res == 'OK':
        s = 'Предмет ' + subject + ' додано';
    else:
        s = Res;
    return s

@app.route('/<user>/add_student', methods=['GET', 'POST'])
def show_addStudent(user):
    permission = Acces(user, 'admin')
    if permission == 1:
        return render_template("add_user_temp.html")
    else:
        return "Acces denied!"

@app.route('/add_user', methods=['POST'])
def add_user():
    Name = None; 
    Surname = None; 
    University = None; 
    Faculty = None; 
    Group = None; 
    Book_num = None; 
    Login = None; 
    Password = None; 

    if request.form["action"] == "student":
        Name = request.form["user_name"]
        Surname = request.form["surname"]
        University = request.form["university"] 
        Faculty = request.form["faculty"]
        Group = request.form["group"]
        Book_num = request.form["rec_book"]
        Login = request.form["login"]
        Password = request.form["password"]

    Res = AddStudent(Login, Password, Name, Surname, University, Faculty, Group, Book_num);
    if Res == 'OK':
        s = 'User ' + Name + ' ' + Surname + ' додано';
    else:
        s = Res;
    return s
  

@app.route('/assign/<parameter>', methods=['GET', 'POST'])
def show_assign(parameter):
    rights = Acces(user_dict["login"], 'teacher')
    if rights == 1:
        return render_template("assign_temp.html", subject = parameter)
    else:
        return "Acces denied!"
    
@app.route('/assign_disc/<sbj>', methods=['POST'])
def assign(sbj):
    student = None;
    subject = sbj;
    sem = None;
    if request.form["action"] == "assign_discipline":
        student = request.form["student"];
        sem = int(request.form["semester"]);
    Res = SelectSubject(subject, student, sem);
    if Res == 'OK':
        s = 'You assigned subject' + subject + ' to student ' + student;
    else:
        s = Res;
    return s

@app.route('/put_mark/<parameter>', methods=['GET', 'POST'])
def mark(parameter):
    rights = Acces(user_dict["login"], 'teacher')
    if rights == 1:
        return render_template("put_mark_temp.html", subject = parameter)
    else:
        return "Acces denied!"

@app.route('/mark/<sbj>', methods=['POST'])
def put_mark(sbj):
    current_user = user_dict["login"];
    student = None;
    subject = sbj;
    mark = None;
    if request.form["action"] == "put_mark":
        student = request.form["student"];
        mark = int(request.form["mark"]);
    Res = PutMark(subject, student, current_user, mark);
    if Res == 'OK':
        s = 'You put mark ' + str(mark) + ' to student ' + student + ' on subject ' + subject;
    else:
        s = Res;
    return s
    
if __name__ == '__main__':
       teacher_dict = {
            "discipline" : None,
            "hours" : None,
            "credits" : None
            }
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
