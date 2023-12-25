module topLevel(
    //input resetn,
    input [9:0] SW, 
    input CLOCK_50, 
	 input PS2_CLK,
	 input [3:0] KEY,
	 input PS2_DAT,
	 output [9:0] LEDR,
    //input wflag, 
    //input aflag,
    //input dflag,
    //input sflag,
    output VGA_CLK,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output [0:6] HEX0,
    output [0:6] HEX1,
    output [0:6] HEX2,
    output [0:6] HEX4,
	 output [0:6] HEX5
);

wire [6:0] speedVert;
wire [1:0] speedHoriz;
wire SpeedEnable;
wire wFlag, aFlag, sFlag, dFlag;
wire driveEnable;
wire parkEnable;
wire [7:0] keyPressed;
wire [5:0] randomX;
wire [5:0] collisionCount;
wire restart;
//
//assign wFlag = SW[1];
//assign aFlag = SW[2];
//assign sFlag = SW[3];
//assign dFlag = SW[4];

assign LEDR[5] = driveEnable;
assign LEDR[6] = parkEnable;
assign LEDR[1] = wFlag;
assign LEDR[2] = aFlag;
assign LEDR[3] = sFlag;
assign LEDR[4] = dFlag;
assign restart = SW[8];


fill u1(
    .CLOCK_50(CLOCK_50), 
    .ySpeed(speedVert), 
    .xSpeed(speedHoriz),
	 .randomX(randomX),
    .resetn(~SW[0]), 
    .VGA_CLK(VGA_CLK),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
	 .collision(collisionCount),
	 .restart(restart)
);

randomGen #(.N(6)) s4(.clock(SpeedEnable),.resetn(~SW[0]), .num(randomX));

speedToHex u2(
    .speed(speedVert),
    .Clock(Clock_50),
    .DisplayEnable(SW[9]),
    .Digit1(HEX2),
    .Digit2(HEX1),
    .Digit3(HEX0)
);

collisionToHex u20(
    .collision(collisionCount),
    .Clock(Clock_50),
    .DisplayEnable(SW[6]),
    .Digit1(HEX5),
    .Digit2(HEX4)
);





speedIncrement u3(
		.clock(CLOCK_50),
    .Enable(SpeedEnable),
	 .driveEnable(driveEnable),
    .resetn(~SW[0]),
    .wFlag(wFlag),
    .aFlag(aFlag),
    .sFlag(sFlag),
    .dFlag(dFlag),
    .ySpeed(speedVert),
    .xSpeed(speedHoriz)
);

//HEX_decoder s1(keyPressed[3:0], HEX4);
//HEX_decoder s2(keyPressed[7:4], HEX5);

clockToHalfHZ u8(
    .clock(CLOCK_50), 
    .resetn(~SW[0]), 
    .enableCount(1), 
    .Enable(SpeedEnable)
);


keyboardWithFlags u11(
	.PS2_CLOCK(PS2_CLK),
	.PS2_DATA(PS2_DAT),
	.RESET(SW[0]),
	.CLOCK_50(CLOCK_50),
	.flag_W(wFlag),
	.flag_A(aFlag),
	.flag_S(sFlag),
	.flag_D(dFlag)
);


BIGFSM u12(
	.reset(SW[0]),
	.driveButton(~KEY[0]),
	.parkButton(~KEY[1]),
	.x_speed(speedHoriz),
	.y_speed(speedVert),
	.clock_50(CLOCK_50),
	.parkEnable(parkEnable),
	.driveEnable(driveEnable)

);

endmodule