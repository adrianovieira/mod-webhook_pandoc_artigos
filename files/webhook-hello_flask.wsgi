# -*- coding: utf-8 -*-
import os, time
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello_world():
return "Hello World!"+ os.uname()[1] +"! <br /><small>"+time.strftime("%d/%h/%Y %H:%M:%S")+"</small>"
