import flask
from flask import render_template,redirect,url_for,request
from output_model import db, User

@app.route('/home/<int:id>')