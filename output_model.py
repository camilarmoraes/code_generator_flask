import sqlalchemy as sa
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User (db.Model):
	id = sa.Column(sa.Integer, sa.ForeignKey(Admin.id), primary_key=True, nullable = False)
	nome = sa.Column(sa.String(200))
	idade = sa.Column(sa.Integer,sa.ForeignKey(Admin.id))
	endereco = db.relanshionship('Endereco')

def test(*args, **kwargs):
	pass
