#very primitive setup just to see it works. next step is to extract the rag, etc. commands from iamz1 and turn them into a stand-alone library. or better, a service

WHEREIRUNDIR="/home/pi/test/iamz1/"

import sys
sys.path.append(WHEREIRUNDIR)
import os
from flask import Flask, request, redirect, render_template
import subprocess
import talk
import rpcservices as rpc

app = Flask(__name__)
listofrag=os.listdir("/home/pi/SpiderPi/ActionGroups")
listofrag=[f[:-4] for f in listofrag if f[-4:] in [".csv",".d6a"]]
listofrag=list(set(listofrag))
listofrag.sort()

reps=1
insist=False

YAKROVER_NAME=os.environ.get("YAK_ROVER_NAME", "unknown")

@app.route('/')
def index():
    global listofrag, reps
    #buts=["movement commands:"]+[ragbutton(f,reps) for f in listofrag]+["<br>Save power(unload):"]+[unloadbut()]+["<br>How many repeats:"]+repbuts
    #return " ".join(buts)
    return render_template("home.html",
            twitch=twitchintegrate(),
            cam=cambut(),
            repeats=repbuts(),
            #talk=talkbut(), TODO
            #insist=insistbut(), TODO
            )

    
@app.route('/dorag',methods=["POST"])
def dorag():
    print("got to rag")
    global reps
    name=request.args.get('name')
    if name=='stand_flip':
        return
    #rep=request.args.get('repeat',default=1,type=int)
    if insist:
        name=name+"@I"
    print("dorag",name)
    rpc.rag(name,reps)
#    subprocess.Popen(['/usr/bin/python3', 'rag.py', name]+[str(reps)],
#           cwd=WHEREIRUNDIR,
#           stdout=subprocess.PIPE, 
#           stderr=subprocess.STDOUT)
    return "rag done"
    return "i would run a rag command here:rag {0} {1}".format(name,rep)

@app.route('/docam',methods=["POST"])
def docam():
    print("got to cam")
    name=request.args.get('name')
    param=request.args.get('param','')
    param='+' if param=='plus' else param
    param='-' if param=='minus' else param
    param='' if param=='none' else param
    
    #rep=request.args.get('repeat',default=1,type=int)
    print("docam",name,param)
    subprocess.Popen(['/usr/bin/python3', 'cam.py', name, param],
           cwd=WHEREIRUNDIR,
           stdout=subprocess.PIPE, 
           stderr=subprocess.STDOUT)
    return "cam done"

@app.route('/dosaythis',methods=["POST"])
def dosaythis():
    print("got to saythis")
    try:
        text=request.args.get('text',"silence is golden")
        talk.saythis(text)
    except:
        pass
    return "saythis done"

@app.route('/unload',methods=["POST"])
def dounload():
    subprocess.Popen(['/usr/bin/python3', 'testunload.py'],
           cwd=WHEREIRUNDIR,
           stdout=subprocess.PIPE, 
           stderr=subprocess.STDOUT)
    return "unload done"

@app.route('/setrep',methods=["POST"])
def dosetrep():
    global reps
    value=request.args.get('value', type=int)
    reps=value
    return "rep set"

@app.route('/setinsist',methods=["POST"])
def dosetinsist():
    global insist
    value=request.args.get('value', type=bool)
    insist=value
    return "rep set"


def repbuts():
    return {
            f"r{r}": f"fetch('/setrep?value={r}',{{method:'POST'}})"
            for r in [1, 2, 5, 10]
            }

def insistbut():
    s='''<button onclick="fetch('/setinsist?value='+document.getElementById('insist').checked,{method:'POST'})">Insist(move#1)</button><input type="checkbox" id="insist" name="insist">'''
    return s

    
def ragbutton(s,rep):
    s='''<button onclick="fetch('/dorag?name={0}&repeat={1}',{{method:'POST'}})">{0}</button>'''.format(s,rep) #later change to a form or something so we can also read the repeats setting. or simply reserve the page
    return s

#onclick="window.location.href='/dorag?name={0}&repeat={1}'">{0}</button>'''.

def unloadbut():
    return '''<button onclick="fetch('/unload',{method:'POST'})">unload</button>'''

def cambut():
    #
    # Missing tilt_to and pan_to (need to add the input text as shown in original code).
    #
    #s.append('''<button onclick="fetch('/docam?name=tilt&param='+document.getElementById('tiltval').value,{method:'POST'})">tilt to</button><input type="text" id="tiltval" name="tiltval">''')
    #s.append('''<button onclick="fetch('/docam?name=pan&param='+document.getElementById('panval').value,{method:'POST'})">pan to</button><input type="text" id="panval" name="panval">''')
    return {
            "cam_rest": "fetch('/docam?name=rest&param=none',{method:'POST'})",
            "pan_scan": "fetch('/docam?name=pan&param=go',{method:'POST'})",
            "pan_l": "fetch('/docam?name=pan&param=plus',{method:'POST'})",
            "pan_r": "fetch('/docam?name=pan&param=minus',{method:'POST'})",
            "tilt_scan": "fetch('/docam?name=tilt&param=go',{method:'POST'})",
            "tilt_u": "fetch('/docam?name=tilt&param=plus',{method:'POST'})",
            "tilt_d": "fetch('/docam?name=tilt&param=minus',{method:'POST'})",
            "tilt_to": "fetch('/docam?name=tilt&param='+document.getElementById('tiltval').value,{method:'POST'})",
            "pan_to": "fetch('/docam?name=pan&param='+document.getElementById('panval').value,{method:'POST'})",
            }

def talkbut():
    return ('''<button onclick="fetch('/dosaythis?text=%20'+document.getElementById('saythis').value,{method:'POST'})">say this</button><input type="text" id="saythis" name="saythis">''')


def twitchintegrate():
    return (f'''
<iframe
    src="https://player.twitch.tv/?channel=yakrovers_{YAKROVER_NAME.lower()}&parent={YAKROVER_NAME.lower()}.rovers.yakcollective.org"
    height="500"
    width="500"
    allowfullscreen="true">
</iframe>
''')
#was src="https://player.twitch.tv/?yakrovers&parent=wwg.rovers.yakcollective.org"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
