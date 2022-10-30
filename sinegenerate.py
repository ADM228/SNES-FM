import math
import numpy as np
import matplotlib

length = 512
sinIncrement = 2/length
type = np.int16
maximum = (np.iinfo(type).max+1)

a = np.zeros(length, type)

for i in range (length):
    a[i] = math.sin(i*sinIncrement*math.pi)*maximum-0.5

b = (a[:int(length/4+1)]).tobytes('C')
a = a.tobytes('C')

file = open("sinetable.bin", 'wb')
file.write(a)
file.close()

file = open("quartersinetable.bin", 'wb')
file.write(b)
file.close()