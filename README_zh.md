# 神经网络加速器
**其他语言: [English](README.md), [中文](README_zh.md).**

该项目旨在实现卷积神经网络的加速电路。项目以yolov8为实现对象，目标是完成一个包含卷积、残差和、上采样、池化、concat等算子操作的加速电路。由于整体电路设计思想是高效复用和指令化调用，因此除了部署yolov8网络外，由上述算子操作组成的其他神经网络也可以编译到加速器上。

## 可实现的算子操作
- **卷积**
  
  3*3的卷积操作，步幅为1或2， 和padding为任意。可以选择是否激活（由参数指令动态控制）。
  
  **// todo: add more details**
- **残差和**

  两个特征块的残差和 
  
  **// todo: add more details**
- **Upsampling**

  对特征图进行2倍上采样。（很难受的是，目前仅支持2倍上采样，并且模式是最简单的nearest）
  
  **// todo: add more details**
- **池化**

  对特征图做最大值池化，支持步幅为1或者2。
  
  **// todo: add more details**
- **拼接**
  
  拼接操作（concat）不通过硬件电路实现，而是在内存分配的过程中实现。 
  
  **// todo: add more details**

## 模型编译
  我写了很多脚本来帮助调试这个加速器。现在我希望将它们融入到编译相关的工作中。也就是说，我希望任何能够提供一个由支持的算子及其相应的量化参数组成的网络的人都可以通过这些脚本编译成可以在我的加速器上运行的指令。 
  
  （我不知道我是否有能力将这一堆脚本整合成一个通用的编译工具包，但我会努力的。）

  **// todo: add more details**

## 目前情况
- **2024-12-18**
  
  我已经完成了上述运算器的硬件电路设计。并在modelsim上模拟了yolov8n的计算，得到了正确的结果。在100M时钟的驱动下，计算完成需要120ms。加速器的接口只有一组内存读写的AXI接口，以及几个参数接口。在后续工作中，参数接口将集成为AXI-lite接口，用于传输命令参数。

**Pytorch推理结果** 

![image](./script/torch_result.jpg)

**Modelsim仿真结果** 

![image](./script/after_nms.png)

- **todo**
  
  完成在xilinx 19EG上的部署，并完成ddr中静态图片的推理。我将尝试完善电路设计，使其能达到300M时钟的速度。

## 引用
- [yolov8-prune-network](https://github.com/ybai789/yolov8-prune-network-slimming)