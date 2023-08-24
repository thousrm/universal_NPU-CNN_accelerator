import matplotlib.pyplot as plt
from keras.models import load_model
import keras
import numpy as np


img_rows = 28
img_cols = 28

model = load_model('model.h5')
weight_ori = model.get_weights()

images = keras.preprocessing.image.load_img("img/7.png", target_size=(28,28))
img_tensor = keras.preprocessing.image.img_to_array(images)


img_tensor = np.expand_dims(img_tensor, axis=0)

img_tensor.reshape(1, 28, 28, 3)

print(img_tensor.shape)
plt.imshow(img_tensor[0,:,:,:]/255)
plt.show()

img_tensor = img_tensor[:,:,:,0]






y_prob = model.predict(img_tensor)
predicted = y_prob.argmax(axis=-1)

print('The Answer by cpu is ', predicted)
print('and the possibility is ', y_prob)

layer3output0 = np.loadtxt('verilog/output layer20.txt')
layer3output1 = np.loadtxt('verilog/output layer21.txt')
layer3output2 = np.loadtxt('verilog/output layer22.txt')
layer3output3 = np.loadtxt('verilog/output layer23.txt')
layer3output4 = np.loadtxt('verilog/output layer24.txt')
layer3output5 = np.loadtxt('verilog/output layer25.txt')
layer3output6 = np.loadtxt('verilog/output layer26.txt')
layer3output7 = np.loadtxt('verilog/output layer27.txt')

layer3output = np.stack( (layer3output0, layer3output1, layer3output2, layer3output3, layer3output4, layer3output5, layer3output6, layer3output7), axis=1)
layer3output = layer3output/2
layer3output = layer3output.reshape(1,5,5,8)

model4 = keras.Model(inputs=model.get_layer(index = 4).input, outputs=model.get_layer(index = 8).output)
model4_output = model4.predict(layer3output)

predicted4 = model4_output.argmax(axis=-1)

print('The Answer by accelerator is ', predicted4)
print('and the possibility is ', model4_output)