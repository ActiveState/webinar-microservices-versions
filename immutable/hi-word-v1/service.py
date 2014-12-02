import os
import sys
import random
from bottle import route, run

print("Running using: %s" % sys.executable)

@route('/v1/hi-word')
def index():
    return random.choice(['Bonjour', 'Hola', 'Hi', 'Hallo', 'Ciao'])

run(host='0.0.0.0', port=int(os.getenv("PORT", 8080)))
