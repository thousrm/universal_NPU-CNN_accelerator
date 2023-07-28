import numpy as np
import copy

original = np.array([0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1])
list_num = []

types = [5, 4, 3]
area = [3, 2, 1]
delay = [3, 2, 1]
best_cost = 1000000
best_series = []


def getopt(line, cost, wa, wd):

    global best_cost, best_series

    for i in [0, 1, 2]:
        temp = copy.deepcopy(line)
        np.append(temp, types[i])
        rate = temp // types[i]
        remain = temp % types[i]
        cost_temp = cost + sum(rate) * area[i] * wa + delay[i] * wd

        temp = rate + remain
        rate = np.delete(rate, 0)
        rate = np.append(rate, 0)
        temp = temp + rate

        temp_true = temp < types[i]

        if all(temp_true):
            getopt3(temp, cost_temp, wa, wd)
            if cost_temp < best_cost:
                best_cost = cost_temp
                best_series = copy.deepcopy(temp)
                np.pop(temp)
        else:
            if cost_temp > best_cost:
                np.pop(temp)

            else:
                getopt(temp, cost_temp, wa, wd)


def getopt3(line, cost, wa, wd):
    temp = copy.deepcopy(line)
    temp_true = temp < 3
    cost_temp = cost

    while not all(temp_true):
        rate = temp // 3
        remain = temp % 3
        cost_temp = cost_temp + sum(rate) * area[2] * wa + delay[2] * wd
        temp = rate + remain
        rate = np.delete(rate, 0)
        rate = np.append(rate, 0)
        temp = temp + rate
        temp_true = temp < 3

    return [temp, cost_temp]

##A = getopt3(original, 0, 0, 1)
##print("{}".format(A))

"""

while not all(temp_true):
    print("{}".format(temp))
    rate = temp // 3
    remain = temp % 3
    area = area + sum(rate) * area3
    delay = delay + delay3
    temp = rate + remain
    rate = np.delete(rate, 0)
    rate = np.append(rate, 0)
    temp = temp + rate
    temp_true = temp < 3
print("area: {}   delay: {}".format(area, delay))
"""