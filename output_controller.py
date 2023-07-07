import flask
from flask import render_template,redirect,url_for,request
from output_model import db, Admin

@app.route('/')
def index():
	return render_template('home')

@app.route('/home')
def create():
	if request.method=='POST':
		_ex = Admin(request.form['__ex'])
		db.session.add(_ex)
		db.session.commit()
	return redirect(url_for(read_banco))

@app.route('/home/asd/<int:id>')
def read_banco(ler_cliente):
	_ex = Admin.query.all(id)
	return render_template('read_banco.html')

@app.route('/home/pagina1/pagina2')
def index(*args, **kwargs):
	pass

@app.route('/delete/banco_banco/<int:id>')
def delete_banco(id):
	_ex = Admin.query.get(id)
	db.session.delete(_ex)
	db.session.commit()
	return redirect(url_for(index))

@app.route('/atualiza/credito/<int:id>')
def update_item(id):
	_ex = Admin.query.get(id)
	if request.method == 'POST':
		_ex._ex2 = request.form['__ex2']
		db.session()
	return render_template('read_item.html',_ex=_ex)

@app.route('/generica')
def test(*args, **kwargs):
	pass
# comentário agora no controller
""" comentário em bloco 
no controller """