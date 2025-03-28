import time
from compile_utils import ReshapeData
import numpy as np


def back_double(strs, byte_num):
    hex_values = [int(strs[i:i + byte_num], 16) for i in range(0, len(strs), byte_num)]
    hex_values = hex_values[::-1]
    return np.array(hex_values).astype(np.int16)


def read_hex_file():
    with open('memory_patch.txt', 'r') as file:
        lines = file.readlines()
        memory = []
        for line in lines:
            # 去除换行符，分割每行的两个十六进制数，并转换为整数
            if line[0] == "/":
                continue
            else:
                hex_values = line.strip()
                memory.append(back_double(hex_values, 4))
        return memory


def read_output_file(file):
    with open(file, 'r') as file:
        lines = file.readlines()
        output = []
        memory = []
        id_list = []
        for line in lines:
            # 去除换行符，分割每行的两个十六进制数，并转换为整数
            if line[0] == "#":
                try:
                    id_list.append(int(line[1:]))
                except ValueError:
                    id_list.append(line[1:])
                output.append(np.array(memory).reshape(-1))
                memory = []
            else:
                hex_values = line.strip()
                memory.append(back_double(hex_values, 4))
        return id_list, output


if __name__ == '__main__':
    t = time.time_ns()
    # data = read_hex_file()
    output_id_list, output_data = read_output_file("output.txt")
    # np.save('memory.npy', np.array(data).reshape(-1))
    print((time.time_ns() - t) / 1000000)
