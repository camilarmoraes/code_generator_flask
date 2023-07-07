#model
import sqlalchemy as sa
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Admin (db.Model):
	id = sa.Column(sa.Integer, sa.ForeignKey(Pessoa.id), primary_key=True)
	nome = sa.Column(sa.String(200), sa.ForeignKey(Pessoa.id), primary_key=True, nullable = False)
	dataNascimento = sa.Column(sa.Date, nullable = False)
	idade = sa.Column(sa.Integer,sa.ForeignKey(Admin.id), nullable = False)
	areaAtuacao = sa.Column(sa.Text, nullable = False, unique=True)
	areaAtuacao = sa.Column(sa.Text, nullable = False, primary_key=True, unique=True)
	endereco = db.relanshionship('Endereco')
"""este e um comentário em bloco
no caso ele esta sendo escrito no model"""
def __init__(*args, **kwargs):
	pass

def outra_funcao(*args, **kwargs):
	pass
