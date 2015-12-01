# -*- coding: utf-8 -*-
import os, time
def application(environ, start_response):
    status = '200 OK'
    output = "Olá, Webhook em "+ os.uname()[1] +"! <br /><small>"+time.strftime("%d/%h/%Y %H:%M:%S")+"</small>"

    response_headers = [('Content-type', 'text/html; charset=utf-8'),
                        ('Content-Length', str(len(output)))]
    start_response(status, response_headers)

    return [output]
