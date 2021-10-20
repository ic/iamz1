import time
import Board


#change, if needed to use pl2303
def read_all_servo_pos():
    res=[]
    for x in range(1,19):
        p=Board.getBusServoPulse(x)
        res.append(p)
    return res

def unload_all(id):
    for x in range(1,19):
        Board.unloadBusServo(x)
