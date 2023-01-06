#pitchtable
import math
import numpy as np
import matplotlib

length = 96
initialFrequency = 440
initialPitch = 0
type = np.int16
maximum = (np.iinfo(type).max+1)

a = np.zeros(length, type)

for i in range (length):
    a[i] = round(initialFrequency*(2**((i-length+15)/12))/250*0x1000)
    print("Value #"+str(i)+": "+hex(a[i])+"; frequency: "+str(a[i]*1000/0x1000))

b = (a[:int(length/4+1)]).tobytes('C')
a = a.tobytes('C')

file = open("pitchtable.bin", 'wb')
file.write(a)
file.close()

a = np.zeros(512, np.uint8)
for i in range (256):
    a[i] = round(i*0.875)
for i in range (256, 512):
    a[i] = round((i-256)*0.9375)
    print ((i-256)*0.9375, a[i])

a = a.tobytes('C')

file = open("lookuptables.bin", 'wb')
file.write(a)
file.close()
