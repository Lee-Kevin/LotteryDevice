# LotteryDevice

## Intrduction
This is a Lottery Device for the Seeed Annual Meeting. This project include two parts, one is for the Arduino side. And the another side is the PC side, for the PC side the screen resolution must be 1920*1080, of course, you can do some job to fit yours by changing the code. The two sides are communicating with each other using wireless module.

## The Arduino Side

For the Arduino side there is a dagu for user to knock, and the PC side will count how many times is the dagu be knocked. AT the beginning, knock the dagu the number will start scrolling. When the knock times come to a fixed number, the lucky number will stop scrolling and you can view the result on the PC side.

![](https://raw.githubusercontent.com/Lee-Kevin/LotteryDevice/master/image/arduino1.png)

The arduino side use a Grove - Sound Sensor and a Grove - Accelermeter Sensor to judge if the dagu knocked. And there's a LED Strip on the dagu which can be lighted when the dagu be knocked. As well as using a UART - Wireless module to communicate with the PC side.

![](https://raw.githubusercontent.com/Lee-Kevin/LotteryDevice/master/image/arduino2.png)

## The PC Side

The PC side will show the lucky number and a progress bar and a flag to indicate if the lottery is finished. 

User can use the keyboard to switch the lottery name:

- 0 stands for Grand Prize. 
- 1 stands for First Prize. 
- 2 stands for Second Prize.
- 3 stands for Thrid Prize.
- 4 stands for Fourth Prize.

In order to prevent false triggering the lottery device, the PC side have a start switch, press the 'S' key then the PC side will recive the data from Arduino side.

![](https://raw.githubusercontent.com/Lee-Kevin/LotteryDevice/master/image/lottery1.png)


![](https://raw.githubusercontent.com/Lee-Kevin/LotteryDevice/master/image/lottery2.png)
