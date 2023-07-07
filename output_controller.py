import flask
from flask import render_template,redirect,url_for,request
from output_model import db, Admin

@app.route('/home')
def criar_usuario():
	if request.method=='POST':
		_ex = Admin(request.form['__ex'])
		db.session.add(_ex)
		db.session.commit()
	return redirect(url_for(__))

@app.route('/home/asd/<int:id>')
def ler_cliente(id):
	_ex = Admin.query.all(id)
	return render_template()

@app.route('/home/pagina1/pagina2')
def index(*args, **kwargs):
	pass

@app.route('/delete/banco_banco/<int:id>')
def delete_usuario(id):
	_ex = Admin.query.get(id)
	db.session.delete(_ex)
	db.session.commit()
	return redirect(url_for(__))

@app.route('/atualiza/credito/<int:id>')
def update_banco(id):
	_ex = Admin.query.get(id)
	if request.method == 'POST':
		_ex._ex2 = request.form['__ex2']
		db.session()
	return render_template()

@app.route('/generica')
def test(*args, **kwargs):
	pass
