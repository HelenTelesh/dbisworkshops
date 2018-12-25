from flask import Flask, render_template, request, redirect, url_for
import numpy as np
from forms.user import UserForm

from my_dao.userhelper import *
app = Flask(__name__)
app.secret_key = 'development key'

@app.route('/<user>', methods=['GET', 'POST'])
def view(user):
    s0 = getDisc(user)
    s = ''
    s_list = []
    for i in range (len(s0)):
        s1 = []
        for j in range (len(s0[0])):
            s1.append(s0[i][j])
        s_list.append(s1)
    
#    for i in range(len(s0)):
#        x = RecBook_line(s0[i][0],s0[i][1],s0[i][2],s0[i][3],s0[i][4],s0[i][5],s0[i][6])
#        s_list.append(x)
        
##    for i in range (len(s_list)):
##        s = s + str(s_list[i].subject) + str(s_list[i].semester) + str(s_list[i].hours) + str(s_list[i].credits) + str(s_list[i].mark) + str(s_list[i].tutor) + str(s_list[i].date) + '<br>'
#    return s
    return render_template("rb_temp.html", lines = s_list, credit = '100', medium = '60')

if __name__ == '__main__':

    class RecBook_line:
        def __init__(self, n_subject, n_semester, n_hours, n_credits, n_mark, n_tutor, n_date):
            self.subject = n_subject
            self.semester = n_semester 
            self.hours = n_hours 
            self.credits = n_credits
            self.mark = n_mark
            self.tutor = n_tutor
            self.date = n_date
    app.run(debug=True)
