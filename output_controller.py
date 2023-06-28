import flask
from flask import render_template,redirect,url_for,request

def criar_usuario():
	if request.method=='POST':
		exempĺo = User(request.form['nome'])
		db.session.add(exemplo)
		db.session.commit()
	return redirect(url_for())

def ler_cliente():
	
	usuario = User.query.all()
	return render_template()

def index(*args, **kwargs):
	pass
