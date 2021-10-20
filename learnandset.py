#command line: learnandset csvfilename r/a [servos list] import subprocess
import sys
import math
import os
import servo_util
import time
import csv

header=["Index","Time","Servo1","Servo2","Servo3","Servo4","Servo5","Servo6","Servo7","Servo8","Servo9","Servo10","Servo11","Servo12","Servo13","Servo14","Servo15","Servo16","Servo17","Servo18"]

l=len(sys.argv)
if l<3:
    print("usage: learnandset csvfilename r/a [servos list])
    sys.exit()

outfile=sys.argv[1]
if not sys.argv[2] in ['r','a','R','A']:
    print("usage: learnandset csvfilename r/a [servos list])
    sys.exit()
absolute=True if sys.argv[2] in ['a','A'] else False
servolist=sys.argv[3:]
for idx,x in enumerate(servolist):
    if int(x)>18 or int(x)<1 or not float(x).is_integer():
        print("servo numbers must be whole numbers between 1 and 18")
        sys.exit()
    servolist[idx]=int(x)

lines=[]

#unloads 
servo_util.unload_all()
    input('''press enter when ready to start.
for relative mode, place servos in a baseline position
in use:
x will ignore the last entered position
s will save the file and exit
enter will prompt for the next position
number followed by enter will use that number for the entered position, the default is 1000
''')
if not absolute:
    lines.append((servo_util.read_all_servo_pos(),0)) #time is meaningless and marked as zero

while True:
    inp=input('''reposition rover servos and press:
x to cancel last entry
s to save (current position is ignored)
number followed by enter to set this number (1...30000) as time for movement
no number - defaults to 1000
''')
    if len(inp)==0:
        t=1000
    elif inp[0] in 'sS':
        break
    elif inp[0] in 'xX':
        if absolute or len(lines)>1:
            lines.pop()
    if inp.isidigit():
        t=int(inp)
    t=min(t,30000)
    t=max(0,t)
    lines.append((servo_util.read_all_servo_pos(),t))
    print('position read')

with open(outfile,"w") as csvfile:
    writer=csv.writer(csvfile)
    writer.writerow(header)
    for idx,x in enumerate(lines):
        if absolute:
            act=x[0]
            if len(servolist)>0:
                for i,val in enumerate(act):
                    if i not in servolist:
                        act[i-1]='NOP'
            act=[idx]+[x[1]]+act
            writer.writerow([idx]+[x[1]]+x[0])
        else:
            if idx>0:
                for a,b in zip(x[0],lines[idx-1][0]):
                    act.append(a-b)
                if len(servolist)>0:
                    for i,val in enumerate(act):
                        if i not in servolist:
                            act[i-1]='NOP'
                act=[idx]+[x[1]]+act
                writer.writerow(act)


#all servos not on list get NOP


