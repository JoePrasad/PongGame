// Note: This code is used for the VGA lab for ENGR 378 and is written to support monitor display resolutions of 1280 x 1024 at 60 fps


// (DETAILS OF THE MODULES)
// VGAInterface.v is the top most level module and asserts the red/green/blue signals to draw to the computer screen
// VGAController.v is a submodule within the top module used to generate the vertical and horizontal synch signals as well as X and Y pixel positions
// VGAFrequency.v is a submodule within the top module used to generate a 108Mhz pixel clock frequency from a 50Mhz pixel clock frequency using the PLL


// (USER/CODER Notes)
// Note: User should modify/write code in the VGAInterface.v file and not modify any code written in VGAController.v or VGAFrequency.v


module VGAInterface(


//////////// CLOCK //////////
CLOCK_50,
CLOCK2_50,
CLOCK3_50,


//////////// LED //////////
LEDG,
LEDR,


//////////// KEY //////////
KEY,


//////////// SW //////////
SW,


//////////// SEG7 //////////
HEX0,
HEX1,
HEX2,
HEX3,
HEX4,
HEX5,
HEX6,
HEX7,


//////////// VGA //////////
VGA_B,
VGA_BLANK_N,
VGA_CLK,
VGA_G,
VGA_HS,
VGA_R,
VGA_SYNC_N,
VGA_VS 
);


//=======================================================
//  PARAMETER declarations
//=======================================================
parameter blank = 7'b1111111;


//=======================================================
//  PORT declarations
//=======================================================


//////////// CLOCK //////////
input           CLOCK_50;
input           CLOCK2_50;
input           CLOCK3_50;


//////////// LED //////////
output     [8:0] LEDG;
output    [17:0] LEDR;


//////////// KEY //////////
input     [3:0] KEY;


//////////// SW //////////
input    [17:0] SW;


//////////// SEG7 //////////
output     [6:0] HEX0;
output     [6:0] HEX1;
output reg     [6:0] HEX2  = 7'b1111111;
output reg     [6:0] HEX3  = 7'b1111111;
output reg     [6:0] HEX4  = 7'b1111111;
output reg     [6:0] HEX5  = 7'b1111111;
output reg     [6:0] HEX6  = 7'b1111111;
output reg     [6:0] HEX7  = 7'b1111111;


//////////// VGA //////////
output     [7:0] VGA_B;
output           VGA_BLANK_N;
output           VGA_CLK;
output     [7:0] VGA_G;
output           VGA_HS;
output     [7:0] VGA_R;
output           VGA_SYNC_N;
output           VGA_VS;


//=======================================================
//  REG/WIRE declarations
//=======================================================
reg aresetPll = 0; // asynchrous reset for pll
wire pixelClock;
wire [10:0] XPixelPosition;
wire [10:0] YPixelPosition; 
reg [7:0] redValue;
reg [7:0] greenValue;
reg [7:0] blueValue;


// slow clock counter variables
reg [20:0] slowClockCounter = 0;
wire slowClock;


// variables for the dot 
reg [10:0] XDotPosition = 500;
reg [10:0] YDotPosition = 500; 
reg [10:0] XDotPosition1 = 500;
reg [10:0] YDotPosition1 = 500; 
reg   [10:0] BAR1, BAR4;
reg   [10:0] BAR3 = 560;
reg   [10:0] BAR2 = 560;
reg [10:0] YUpper = 490;
reg [10:0] YLower = 500;
reg [10:0] Xleft = 600;
reg [10:0] Xright = 610;
reg [4:0] Xbla = 10;
reg [4:0] Ybla = 10;
reg [2:0] score1=0, score2=0;
reg [2:0] a=2;


//=======================================================
//  Structural coding
//=======================================================


// output assignments
assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N = 1'b1; 
assign VGA_CLK = pixelClock;


// display the X or Y position of the dot on LEDS (Binary format)
// MSB is LEDR[10], LSB is LEDR[0]
assign LEDR[10:0] = SW[1] ? YDotPosition : XDotPosition; 




assign slowClock = slowClockCounter[20]; // take MSB from counter to use as a slow clock


initial
begin
Xbla = 10;
Ybla = 10;
a = 2;
end



always@ (posedge CLOCK_50) // generates a slow clock by selecting the MSB from a large counter
begin
slowClockCounter <= slowClockCounter + 1;
end


always@(posedge slowClock) // process moves the X position of the dot
begin
if (KEY[2] == 1'b0) 
begin
if (BAR4 < 910)
begin
YDotPosition <= YDotPosition + 10;
end
else
begin
YDotPosition <= YDotPosition;
end
BAR4 <= YDotPosition;
BAR3 <= YDotPosition - 140;
end
else if (KEY[3] == 1'b0) 
begin
if (BAR3 > 140)
begin
YDotPosition <= YDotPosition - 10;
end
else
begin
YDotPosition <= YDotPosition;
end
BAR4 <= YDotPosition;
BAR3 <= YDotPosition - 140;
end 
end


always@(posedge slowClock) // process moves the X position of the dot
begin
if (KEY[0] == 1'b0) 
begin
if (BAR2 < 910)
XDotPosition <= XDotPosition + 10;
else
XDotPosition <= XDotPosition;
BAR2 <= XDotPosition;
BAR1 <= XDotPosition - 140;
end
else if (KEY[1] == 1'b0) 
begin
if (BAR1 > 140)
XDotPosition <= XDotPosition - 10;
else
XDotPosition <= XDotPosition;


BAR2 <= XDotPosition;
BAR1 <= XDotPosition - 140;
end
end


always@(posedge slowClock) // process moves the X position of the dot
begin


if ((score1 >= 7) || (score2 >= 7) || (SW[2] == 1))
begin
score1 <= 0;
score2 <= 0;
YUpper <= 490;
YLower <= 500;
Xleft <= 600;
Xright <= 610;
a = 2;
end
else if (Xleft <= 160 && a == 1)
begin
a = 2;
score1 <= score1 + 1;
end
else if (Xleft <= 160 && a == 4)
begin
a = 3;
score1 <= score1 + 1;
end
else if (Xright >= 1100 && a == 2)
begin
a = 1;
score2 <= score2+ 1;
end
else if (Xright >= 1100 && a == 3)
begin
a = 4;
score2 <= score2+ 1;
end
else if (YLower >= 910 && a == 4)
begin
a = 1;
end
else if (YLower >= 910 && a == 3)
begin
a = 2;
end
else if (YUpper <= 140 && a == 2)
begin
a = 3;
end
else if (YUpper <= 140 && a == 1)
begin
a = 4;
end
else if (((Xright <= 1040 && Xright >= 1030))&&(YUpper >= BAR3 && YLower <= BAR4)&& a == 2)
begin
a = 1;
end
else if (((Xright <= 1040 && Xright >= 1030))&&(YUpper >= BAR3 && YLower <= BAR4) && a == 3)
begin
a = 4;
end
else if ((Xleft >= 220 && Xleft <= 230)&& ((YUpper >= BAR1 && YLower <= BAR2))&& a == 1)
begin
a = 2;
end
else if ((Xleft >= 220 && Xleft <= 230)&& ((YUpper >= BAR1 && YLower <= BAR2))&& a == 4)
begin
a = 3;
end


else
begin
case (a)
1: begin
YUpper <= YUpper - Ybla;
YLower <= YLower - Ybla;
Xright <= Xright - Xbla;
Xleft <= Xleft - Xbla;
end
2: begin
YUpper <= YUpper - Ybla;
YLower <= YLower - Ybla;
Xright <= Xright + Xbla;
Xleft <= Xleft + Xbla;
end
3: begin
YUpper <= YUpper + Ybla;
YLower <= YLower + Ybla;
Xright <= Xright + Xbla;
Xleft <= Xleft + Xbla;
end
4: begin
YUpper <= YUpper + Ybla;
YLower <= YLower + Ybla;
Xright <= Xright - Xbla;
Xleft <= Xleft - Xbla;
end
default:  begin
YUpper <= YUpper - Ybla;
YLower <= YLower - Ybla;
Xright <= Xright - Xbla;
Xleft <= Xleft - Xbla;
end


endcase


end
end
/*
always@(posedge slowClock) // process moves the Y position of the dot
begin


case (a)
1: begin
if (score1 >= 2 || score2 >= 2 || SW[2] > 0)
begin
YUpper <= 490;
YLower <= 500;
Xleft <= 600;
Xright <= 610;
end
else
begin
YUpper <= YUpper - Ybla;
YLower <= YLower - Ybla;
Xright <= Xright - Xbla;
Xleft <= Xleft - Xbla;
end
end
2: begin
if (score1 >= 2 || score2 >= 2 || SW[2] > 0)
begin
YUpper <= 490;
YLower <= 500;
Xleft <= 600;
Xright <= 610;
end
else
begin
YUpper <= YUpper - Ybla;
YLower <= YLower - Ybla;
Xright <= Xright + Xbla;
Xleft <= Xleft + Xbla;
end
end
3: begin
if (score1 >= 2 || score2 >= 2 || SW[2] > 0)
begin
YUpper <= 490;
YLower <= 500;
Xleft <= 600;
Xright <= 610;
end
else
begin
YUpper <= YUpper + Ybla;
YLower <= YLower + Ybla;
Xright <= Xright + Xbla;
Xleft <= Xleft + Xbla;
end
end
4: begin
if (score1 >= 2 || score2 >= 2 || SW[2] > 0)
begin
YUpper <= 490;
YLower <= 500;
Xleft <= 600;
Xright <= 610;
end
else
begin
YUpper <= YUpper + Ybla;
YLower <= YLower + Ybla;
Xright <= Xright - Xbla;
Xleft <= Xleft - Xbla;
end
end
default:  begin
YUpper <= YUpper - Ybla;
YLower <= YLower - Ybla;
Xright <= Xright - Xbla;
Xleft <= Xleft - Xbla;
end


endcase


end
*/



// PLL Module (Phase Locked Loop) used to convert a 50Mhz clock signal to a 108 MHz clock signal for the pixel clock
VGAFrequency VGAFreq (aresetPll, CLOCK_50, pixelClock);


// VGA Controller Module used to generate the vertial and horizontal synch signals for the monitor and the X and Y Pixel position of the monitor display
VGAController VGAControl (pixelClock, redValue, greenValue, blueValue, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, XPixelPosition, YPixelPosition);



// COLOR ASSIGNMENT PROCESS (USER WRITES CODE HERE TO DRAW TO SCREEN)
always@ (posedge pixelClock)
begin


if (XPixelPosition <= 150) //Right Border
begin
redValue <= 8'b00000000; 
blueValue <= 8'b00000000;
greenValue <= 8'b11111111;
end
else if (XPixelPosition >= 1100) //Left Border
begin
redValue <= 8'b00000000; 
blueValue <= 8'b00000000;
greenValue <= 8'b11111111;
end
else if ((XPixelPosition >= 220 && XPixelPosition <= 230)&&(YPixelPosition >= BAR1 && YPixelPosition <= BAR2)) //LBar
begin
redValue <= 8'b00000000; 
blueValue <= 8'b11111111;
greenValue <= 8'b11111111;
end
else if ((XPixelPosition <= 1040 && XPixelPosition >= 1030)&&(YPixelPosition >= BAR3 && YPixelPosition <= BAR4)) //RBar
begin
redValue <= 8'b00000000; 
blueValue <= 8'b11111111;
greenValue <= 8'b11111111;
end
else if (YPixelPosition <= 130) //Upper Border
begin
redValue <= 8'b11111111; 
blueValue <= 8'b11111111;
greenValue <= 8'b00000000;
end
else if (YPixelPosition >= 920) // Lower Border
begin
redValue <= 8'b11111111; 
blueValue <= 8'b11111111;
greenValue <= 8'b00000000;
end
else if ((((XPixelPosition <= Xright) && XPixelPosition >= Xleft))&&((YPixelPosition >= YUpper && YPixelPosition <= YLower))) //Ball
begin
redValue <= 8'b11111111; 
blueValue <= 8'b00000000;
greenValue <= 8'b00000000;
end
else //Backround
begin
redValue <= 8'b00000000; 
blueValue <= 8'b00000000;
greenValue <= 8'b00000000;
end


end




score_decoder he0(score1, HEX0);
score_decoder he1(score2, HEX1);


endmodule


module score_decoder(in, hex0);


input [2:0] in;


output reg [6:0] hex0;



parameter zero = 7'b1000000;
parameter one = 7'b1111001;
parameter two = 7'b0100100;
parameter three = 7'b0110000;
parameter four = 7'b0011001;
parameter five = 7'b0010010;
parameter six = 7'b0000010;
parameter seven = 7'b11111000;



always@(*)
begin


case (in)
0 : hex0 = zero;
1 : hex0 = one;
2 : hex0 = two;
3 : hex0 = three;
4 : hex0 = four;
5 : hex0 = five;
6 : hex0 = six;
7 : hex0 = seven;


endcase
end


endmodule
