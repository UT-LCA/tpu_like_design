import sys
import secrets
import numpy as np
from global_parameters import matmul_size

num_matrices = int(sys.argv[1])

file1 = open("MatrixA.txt", "w")
file2 = open("MatrixB.txt", "w")
# for i in range (num_matrices*matmul_size):
#     file1.write(secrets.token_hex(matmul_size))   
#     file1.write("\n")
# for i in range (num_matrices*matmul_size):
#     file2.write(secrets.token_hex(matmul_size))
#     file2.write("\n")

for i in range (num_matrices*matmul_size):
    x = ""
    for j in range(matmul_size):
        x = x + '0' + str(secrets.randbelow(10))
    file1.write(x)   
    file1.write("\n")
for i in range (num_matrices*matmul_size):
    x = ""
    for j in range(matmul_size):
        x = x + '0' + str(secrets.randbelow(10))
    file2.write(x)
    file2.write("\n")

file1 = open("MatrixA.txt", "r+")
file2 = open("MatrixB.txt", "r+")
file3 = open("MatrixC.txt","w")

for x in range(num_matrices):
    rows, cols = (matmul_size, matmul_size)
    arrA = [[0 for i in range(cols)] for j in range(rows)]
    arrnewA = [[0 for i in range(cols)] for j in range(rows)]
    for i in range(matmul_size):
        a = file1.readline()
        for j in range(matmul_size):
            arrA[i][j] = int((a[2*j]+a[2*j+1]),16)
            
    arrB = [[0 for i in range(cols)] for j in range(rows)]
    for i in range(matmul_size):
        b = file2.readline()
        k = matmul_size - 1
        for j in range(matmul_size):
            arrB[k][i] = int((b[2*j]+b[2*j+1]),16)
            k = k - 1

    arrCt = [[0 for i in range(cols)] for j in range(rows)]
    arrC = [[0 for i in range(cols)] for j in range(rows)]
    for i in range(matmul_size):
        for j in range(matmul_size):
            for k in range(matmul_size):
                arrCt[i][j] = int(bin(arrCt[i][j] + (int(bin(arrA[i][k]*arrB[j][k]),2) & 255)),2) & 255
                #print(int(bin(arrCt[i][j]),2), " ")
            #print("\n")

    for i in range(matmul_size):
        for j in range(matmul_size):
            arrC[j][i] = hex(arrCt[i][j])
            file3.write(arrC[j][i])
            file3.write(" ")
        file3.write("\n")

file1.close()
file2.close()