# Traffic-Lights-In-VHDL
Made this little project in Vivado using VHDL. Made it for the Nexys A7. 
## Here's how it works:
The "administrator" enters two 8-bit natural numbers using the switches available on the Nexys A7 (Left side bits are for pedestrians, right side are for cars).
Then pushes the N17 button to "Program" the Traffic-Lights ( or waits for the count-downt to start. It's just a reset).
The left side represents the displayed information for pedestrians:

1: Seven segment count down that shows how much time the pedestrian has to wait 

2: RGB LED that :

    a. is Red when the pedestrians shouldn't pass
    b. is Green when they should

The right side represents the displayed information for cars:

1: Seven segment count down that shows how much time the driver has to wait

2: RGB LED that :

    a. Is red when the cars shouldn't cross
    b. Is yellow when there are at least 10 seconds left before red shows up
    c. Is green when the cars should pass

## Here's a video I made of it, in action:

https://github.com/user-attachments/assets/e3c12ef3-f08c-4aaa-a616-2c8652ae5a9c

I apologise for the quality of the video. I made it in a school-break.

