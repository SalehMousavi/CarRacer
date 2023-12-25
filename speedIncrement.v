`timescale 1ns / 1ns

module speedIncrement(
    input clock,
	 input Enable,
	 input driveEnable,
    input resetn,
    input wFlag,
    input aFlag,
    input sFlag,
    input dFlag,
    output reg [6:0] ySpeed,
    output reg [1:0] xSpeed
);

always@(posedge clock, negedge resetn)
begin
    if(!resetn) 
    begin
        ySpeed = 7'd27;
        xSpeed = 2'd0;
    end
	 else if(!driveEnable) begin
		ySpeed = 7'd27;
      xSpeed = 2'd0;
	 end
	 else if(Enable) 
	 begin
		 if(wFlag && ySpeed < 7'd127) ySpeed = ySpeed + 1;
		 if(sFlag && ySpeed > 7'd0) ySpeed = ySpeed - 1;
		 
		 if(dFlag && ySpeed != 7'd27) xSpeed = 2'd2;
		 if(aFlag && ySpeed != 7'd27) xSpeed = 2'd1;
		 if(!dFlag && !aFlag) xSpeed = 2'd0;
		 if(ySpeed == 7'd27) xSpeed = 2'd0;
	 end
end
endmodule

