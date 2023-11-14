# Universal_NPU-CNN_Accelerator
### hardware design of universal NPU (CNN accelerator) for various convolution neural networks

It can perform various cnns by calculating convolution for multiple clock cycles.

see here [https://velog.io/@hyal/%EB%B2%94%EC%9A%A9%EC%A0%81%EC%9D%B8-NPU-%EA%B0%9C%EB%B0%9C%EA%B8%B00-%EB%93%A4%EC%96%B4%EA%B0%80%EA%B8%B0-%EC%95%9E%EC%84%9C](https://velog.io/@hyal/series/%EB%B2%94%EC%9A%A9%EC%A0%81%EC%9D%B8-NPU-%EA%B0%9C%EB%B0%9C%EA%B8%B0) (korean)


There are many modules for same function. This is because, I don't have any synthesis tool(vivado is not useful for asic design), so, I can't determine which is most efficient.

If you have suitable tools, such as design compiler or else, please give me timing, area and power reports of modules. It will be very helpful.

<br/>

---
# Usage
1. Install required pakages (tensorflow, keras, numpy, pillow, matplotlib)
2. run generate_par.py (I use pycharm)
3. Compile all verilog files
4. Simulate run_npu_simple.v
5. Run predict.py

If you want to use this module for other cnn model, you have to edit generate_par.py, run_npu_simple.v and predict.py for it.

<br/>

---
# Descripton

## Overall Structure

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/0976a968-a228-4b66-be5e-5a5e66285adb)

<br/>

## Control Part

Control Part_simple version has only essential functions. (That's why its name is "simple version")

This is because I can't determine which level of control part is efficient.

Many functions are useful, but it requires more area and reduces flexibility.

So, I decided to design the simple control part first and upgrade it later.

<br/>

## Memory Part

Memory Part is neceessary to reduce power consumption and bottleneck effect.

It decreases the number of communications with ram by saving required datas in its Flip Flop.

There are various ways to use the memory part, but I will introduce the way of run_npu_simple.v.

<br/>

### Structure

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/f4866bc5-d84a-49ac-a1ea-86f3683ee15e)

|Field|Description|
|:---|:---|
|Input Feture Map|This area is used to store input feture map. The data in this field is often edited.|
|Additional Weight & Weight|This area is used to store weights. The data in this field is rarely edited.|
|bias|This area is used to store biases. The data in this field is rarely edited.|

<br/>

### Desciption

To make it easier to understand, some of the details in the description differ from the method that I actually used.

Let's take the example of 128\*128\*1 input feature map and 3\*3\*1 filter.

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/52bbe410-9c86-4dc8-ba7a-92ecfecb3163)

First, data in this area is stored in the memory part.

<br/>

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/130baaec-9055-44af-89d9-46f537f23bf1)

The left image shows the data stored in the memory part (red) and used in the arithmetic part for convoltion (blue) on the input feature map.

The right image shows the data in the memory part.

<br/>

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/ed757519-78cb-4567-b323-0dfa9fbbb43f)

After several convolutions, line 1 is no longer needed, so the memory part replaces it with line 9.

<br/>

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/e05b2a5d-aaa4-4b67-a731-14d8ca60284c)
![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/fc632287-4dc2-4fe6-b5d1-ee5afe144355)


When there is no more next line, the memory part starts to store the data on the right side of the input feature map.

By these steps, the arithmetic part can perform convolution continuously, because there is no need to stop reading data from the memory part to store the required data.

<br/>

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/04b00f73-6b3e-4095-af54-d14b9021ed8f)

As a result, all pixels in the input feature map are loaded from RAM almost once.

Not exactly once, because some pixels in the specific columns have to be loaded twice. (Roughly 1.016 times on average)

<br/>

## Arithmetic Part

### Mechanism

The whole process is Modified Booth Algorithm -> Wallace Tree -> Relu -> Maxpooling.

Since you can already find plenty of information on the Internet and elsewhere about each step, I won't explain them.

Mechanism for calculating a variety of CNN is so simple. The processing_element module can store its output in a flip-flop, so it can be used in the next clock.

Wallace tree (adder tree) receives previous output from flip-flop and adds it with current multiplication output.

As a result, the output becomes previous weight * previous input + current weight * current input + bias. It's a result of convolution has over 9 weights.

 <br/> 

### Input

|Input|Description|
|:---|:---|
|in|Port for input feature map. Each input data is 8bit, and this port receives 9 input datas every clock cycle.|
|weight|Port for weights of filters. Each weight is 8bit, and this port receives 9*8 weights every clock cycle. <br/> But it can only receive 9 weights per filter in a clock cycle.|
|bias|Port for biases of filters. Each bias is 16bit, and this port receives 8 biases every clock cycle.|
|bound_level|Port for setting a maximum value and step size of data. <br/> output (bound_level=n) = output (bound_level=0) * 2^n = original value * 2^(n-11)|
|step|Port for setting the period for convolution. <br/> If you set step=2, processing_element module will compute the convolution for 3 clock cycles, <br/>  so it can be used to compute a filter with 27 weights. |
|en|Input data validation port|
|en_relu|Port for enabling relu function|
|en_mp|Port for enabling max pooling function|

 <br/> 
 
### Module

|Module|Description|
|:---|:---|
|tb_ap|testbench for ap module.|
|AP|Arithmetic part module. It's a top module of arithmetic part and contains 8 arithmetic_core modules.|
|arithmetic_core|arithmetic_core module contains PE(processing_element), relu and maxpooling module. Whole computation is done in this module.|
|arithmetic_core_mod|It's almost same with arithmetic_core, but it uses PE_m instead of PE.|
|PE|processing element module. It performs convoulution and contains many modules.|
|PE_m| It's almost same witn PE, but it can accept more unstable sigals.|
|relu|It performs relu function.|
|maxpooling|It performs maxpooling.|
|multiplier|It generates partial products from multiplicands and multipliers.|
|PPG|It generates 1 partial product from 1 multiplicand and 1 multiplier.|
|MBE_enc|It transforms a multiplier using modified booth algorithm|
|addertree_stage1|First step of the wallce tree.|
|addertree_stage2|Second step of the wallce tree.|
|addertree_stage3|Third and fourth step of the wallce tree.|
|adder_final|Last step of the wallce tree. It contains half adder, full adder and carry look ahead adders.|
|Many types of adders|There are so many adders. <br/>  <br/> **IMPORTANT** <br/> There are various adders for same function but have different structure. You have to choose from them to enhance efficiency. <br/> For example, adder_15to4, adder_15to4_mod and adder_15to4_mod2 are all adders for computing 15 inputs addition, but their architectures are quite different.|








### CNN Model

<br/>

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/05f26167-7597-460d-a69e-af20b8461e77)


<br/>
layer0~4 are calculated by the accelerator.



---
# Architecture

### NPU & Arithmetic_part

![npu](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/ae880dd7-c8e4-4abe-a55a-8ab0d594dfb2)

&nbsp;
<br/>
<br/>

### arithmetic_core

<img width="627" alt="ac" src="https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/f8caeed0-95ff-4824-aa35-fe35c83ffef8">

&nbsp;
<br/>
<br/>

### processing_element

<img width="588" alt="pe0" src="https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/425ce009-53be-417a-90cd-fa29df127c4a">

&nbsp;
<br/>
<br/>

### processing_element_mod

<img width="588" alt="pe1" src="https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/6258036d-11b6-40ce-88cd-592609f57fd4">

&nbsp;
<br/>
<br/>

### multiplier

![multiplier](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/61ab435a-f7a7-4598-a08d-5bc963d8a909)

&nbsp;
<br/>
<br/>

### adder_final

![adder_final](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/a8f3cbea-325c-4a4d-b6f3-fdb58b64a3b9)

&nbsp;
<br/>
<br/>

### Relu

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/d0748433-32b7-4fa2-b8cb-4f1216470b67)

&nbsp;
<br/>
<br/>

### maxpooling

![image](https://github.com/thousrm/universal_NPU-CNN_accelerator/assets/101848060/b0c27dd5-766b-4336-b7a8-0523e284bb66)

&nbsp;
<br/>
<br/>


















