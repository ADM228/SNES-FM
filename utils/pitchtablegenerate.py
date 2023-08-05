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
loTable = np.zeros(length, np.uint8)
hiTable = np.zeros(length, np.uint8)

for i in range (length):
    a[i] = round(initialFrequency*(2**((i-length+15)/12))/250*0x1000)
    loTable[i] = a[i] & 0xFF
    hiTable[i] = a[i] >> 8
    print("Value #"+str(i)+": "+hex(a[i])+"; frequency: "+str(a[i]*1000/0x1000))

file = open("tables/pitchLo.bin", 'wb')
file.write(loTable.tobytes('C'))
file.close()
file = open("tables/pitchHi.bin", 'wb')
file.write(hiTable.tobytes('C'))
file.close()

a = np.zeros(512, np.uint8)
for i in range (256):
    a[i] = round(i*0.875)
for i in range (256, 512):
    a[i] = round((i-256)*0.9375)
    print ((i-256)*0.9375, a[i])

a = a.tobytes('C')

file = open("tables/multTables.bin", 'wb')
file.write(a)
file.close()
