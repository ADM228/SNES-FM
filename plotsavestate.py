import math
import numpy as np
import matplotlib.pyplot as plt

array = np.fromfile("SNESFM-1.bst", dtype=np.int16, offset=147996+0, count=512)
array2 = np.fromfile("SNESFM-2.bst", dtype=np.int16, offset=147996+0, count=128)
array3 = np.zeros(512)

for i in range (len(array2)):
    array3[i*4] = array2[i]
    array3[i*4+1] = array2[i]
    array3[i*4+2] = array2[i]
    array3[i*4+3] = array2[i]



x = np.arange(0, 512) 
y = np.arange(12, 17)

# PLot

plt.plot(x,array,linestyle="--") 
plt.plot(x,array3,linestyle="-")

# Add Title

plt.title("A sine modulating (a sine modulating a sine with strength 16/32); strength 16/32") 

# Add Axes Labels

plt.xlabel("x axis") 
plt.ylabel("y axis") 

# Display

plt.show()