"""

get optimized process of wallace tree

"""

import numpy as np
import copy

original = np.array([0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1])

list_num = []
types = [5, 4, 3]
area = [300, 200, 1]
delay = [3, 2, 1]
best_cost = 1000000
best_series = []
step = 0


def getopt(line, cost, wa, wd):
    global best_cost, best_series, list_num, step

    step = step + 1
    print("getopt{}".format(step))

    for i in [0, 1, 2]:
        temp = copy.deepcopy(line)
        list_num.append(types[i])
        rate = temp // types[i]
        remain = temp % types[i]
        cost_temp = cost + max(sum(rate), 1) * area[i] * wa + delay[i] * wd

        temp = rate + remain
        rate = np.delete(rate, 0)
        rate = np.append(rate, 0)
        temp = temp + rate

        if i == 0 or i == 1:
            rate = np.delete(rate, 0)
            rate = np.append(rate, 0)
            temp = temp + rate

        print("cost_temp: {}".format(cost_temp))
        print("list: {}".format(list_num))
        print("temp: {}".format(temp))
        print("best_cost: {}".format(best_cost))
        print("best_series: {}".format(best_series))

        temp_true = temp < types[i]

        if all(temp_true):
            print("true\n")
            [cost_temp, time] = getopt3(temp, cost_temp, wa, wd)
            if cost_temp < best_cost:
                best_cost = cost_temp
                best_series = copy.deepcopy(list_num)
                j = 0
                while j <= time:
                    list_num.pop()
                    j = j + 1
                    ##print("list: {}".format(list_num))
                print("best_cost: {}".format(best_cost))
                print("best_series: {}\n".format(best_series))
            else:
                j = 0
                while j <= time:
                    list_num.pop()
                    j = j + 1
        else:
            print("false\n")
            if cost_temp < best_cost:
                getopt(temp, cost_temp, wa, wd)
                list_num.pop()
            else:
                list_num.pop()


def getopt3(line, cost, wa, wd):
    global list_num

    temp = copy.deepcopy(line)
    temp_true = temp < 3
    cost_temp = cost
    time = 0

    while not all(temp_true):
        rate = temp // 3
        remain = temp % 3
        cost_temp = cost_temp + sum(rate) * area[2] * wa + delay[2] * wd
        temp = rate + remain
        rate = np.delete(rate, 0)
        rate = np.append(rate, 0)
        temp = temp + rate
        list_num.append(3)
        time = time + 1
        temp_true = temp < 3
        ##print("temp: {}".format(temp))
        ##print("time: {}".format(time))

    return [cost_temp, time]


getopt(original, 0, 1, 0)
print("{}, {}".format(best_cost, best_series))

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
