from flask import Flask

app = Flask(__name__)

user_dict = {
    "login" : "user1",
    "passw" : "1111",
    "user_role" : "student",
    "user_name" : "Ivan",
    "surname" : "Sydorov",
    "fathername" : "Ivanovich"
    }

record_book_dict = {
    "university_name" : "KPI",
    "faculty_name" : "Applied Mathemetics",
    "group_number" : "1",
    "login" : "user1",
    "book_num" : "AB111"
    }

@app.route('/server/api/<action>', methods = ['POST', 'GET'])
def processing(action):
    if (action == 'record_book'):
        return render_template('record_book_temp.html')
    elif(action == 'user'):
        return render_template('user_temp.html')
    elif (action == 'all'):
        if request.method == 'POST':
            result = request.form
            return render_template("all.html", result = result)
    else:
        # Eror 404.
        Flask.abort(404)

app.run(debug=True, port= 8085)

