import flask
from flask import render_template,redirect,url_for,request
from output_model import db, User

@app.route('/home/casa/dragao')
def criar_usuario():
	if request.method=='POST':
		exempĺo = User(request.form['nome'])
		db.session.add(exemplo)
		db.session.commit()
	return redirect(url_for())

@app.route('/novo')
	usuario = User.query.all(id)
	return render_template()
