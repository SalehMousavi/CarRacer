module vgaDriver(restart, iResetn,iClock,iYSpeed, iXSpeed,oX,oY,oColour,oPlot, randomX, collisionCounter);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;
   input wire [1:0] iXSpeed;
   input wire [6:0] iYSpeed;
	input [5:0] randomX;
   input wire iResetn;
   input wire iClock;
	input restart;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;
   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
	output [5:0] collisionCounter;
    wire [5:0] frameCount;
    wire [6:0] yCount;
    wire [7:0] xCount;
    wire [2:0] yIndex;

    wire eraseEn, drawCarEn, drawStripeEn, incrX, incrY, incrXCar, decrXCar, incrYStripe, decrYStripe, resetXYCount, incrYindex, drawBoxEn, incrYBox, gameOver;

	 wire resetGameover;
	 
    control #(.X_SCREEN_PIXELS(X_SCREEN_PIXELS), .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)) u1(
        .clock(iClock),
        .resetn(iResetn),
        .ySpeed(iYSpeed),
        .xSpeed(iXSpeed),
        .frameCount(frameCount),
        .yCount(yCount),
        .xCount(xCount),
        .yIndex(yIndex),
        .eraseEn(eraseEn),
        .drawCarEn(drawCarEn),
        .drawStripeEn(drawStripeEn),
		  .drawBoxEn(drawBoxEn),
        .incrX(incrX),
        .incrY(incrY),
        .incrYindex(incrYindex),
        .incrXCar(incrXCar),
        .decrXCar(decrXCar),
		  .incrYBox(incrYBox),
        .incrYStripe(incrYStripe),
        .decrYStripe(decrYStripe),
        .oPlot(oPlot),
        .resetXYCount(resetXYCount),
		  .gameOver(gameOver),
		  .restart(restart),
		  .resetGameover(resetGameover)
    );

    datapath #(.X_SCREEN_PIXELS(X_SCREEN_PIXELS), .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)) u2(
        .clock(iClock),
        .resetn(iResetn),
        .frameCount(frameCount),
        .yCount(yCount),
        .xCount(xCount),
        .yIndex(yIndex),
        .eraseEn(eraseEn),
        .drawCarEn(drawCarEn),
        .drawStripeEn(drawStripeEn),
        .incrX(incrX),
        .incrY(incrY),
        .incrYindex(incrYindex),
        .incrXCar(incrXCar),
        .decrXCar(decrXCar),
		  .incrYBox(incrYBox),
        .incrYStripe(incrYStripe),
        .decrYStripe(decrYStripe),
        .resetXYCount(resetXYCount),
		  .drawBoxEn(drawBoxEn),
        .oX(oX),
        .oY(oY),
        .oColour(oColour),
		  .randomX(randomX),
		  .collision(collisionCounter),
		  .gameOver(gameOver),
		  .resetGameover(resetGameover)
    );
    
endmodule // part2

module control
#(parameter X_SCREEN_PIXELS = 8'd160, parameter Y_SCREEN_PIXELS = 7'd120)
(input clock,
input resetn,
input [6:0] ySpeed, //vertical speed of car, 0-27, 0 is -27km/hr, 27 is 0 km/hr, 28-127 is from 1 to 100km/hr
input [1:0] xSpeed, //horizontal speed of car
input [5:0] frameCount,
input [6:0] yCount, //counter to draw the stripes 
input [7:0] xCount, //counter to draw the stripes 
input [2:0] yIndex,
input gameOver,
input restart, 

output reg eraseEn,  //erases the screen to redraw
output reg drawCarEn, //draws the car
output reg drawStripeEn, //draws the stripes
output reg incrX,
output reg incrY,
output reg incrXCar,
output reg decrXCar,
output reg incrYStripe,
output reg decrYStripe,
output reg incrYindex,
output reg oPlot,
output reg resetXYCount,
output reg drawBoxEn,
output reg incrYBox,
output reg resetGameover
);

reg [5:0] lastFrameCarDrawn, lastFrameStripeDrawn, lastFrameErased;
reg [3:0] current_state, next_state;

localparam  S_RESET            = 4'd0,
            S_DRAW_STRIPES     = 4'd1,
				S_DRAW_BOX_WAIT	 = 4'd2,
				S_DRAW_BOX			 = 4'd3,
				S_DRAW_CAR_WAIT	 = 4'd4,
            S_DRAW_CAR         = 4'd5,
            S_ERASE_WAIT       = 4'd6,
            S_ERASE            = 4'd7,
            S_UPDATE_POS       = 4'd8,
				S_GAMEOVER         = 4'd9;

always@(*)
begin: state_table
   case(current_state)
      S_RESET: 
		begin
			resetGameover = 1'b0;
			next_state = S_DRAW_STRIPES;
		end
      S_DRAW_STRIPES: begin
        if(gameOver)
				next_state = S_GAMEOVER;
		  else if(yCount == 7'd25 && xCount == 8'd10 && yIndex == 3'd5) begin
            next_state = S_DRAW_BOX_WAIT;
        end
        else begin
            next_state = S_DRAW_STRIPES;
        end
      end
		S_DRAW_CAR_WAIT: begin
				next_state = S_DRAW_CAR;
		  end
      S_DRAW_CAR: begin
        if(yCount == 8'd18 && xCount == 8'd8) begin
            next_state = S_ERASE_WAIT;
        end
        else begin
            next_state = S_DRAW_CAR;
        end
      end
		S_DRAW_BOX_WAIT: begin
			next_state = S_DRAW_BOX;
		end
		S_DRAW_BOX: begin
			if(yCount == 8'd10 && xCount == 8'd10) begin
            next_state = S_DRAW_CAR_WAIT;
        end
        else begin
            next_state = S_DRAW_BOX;
        end
		end
      S_ERASE_WAIT: begin
        if((frameCount - lastFrameErased) == 6'd1) begin
            next_state = S_ERASE;
        end
        else 
            next_state = S_ERASE_WAIT;
      end
      S_ERASE: begin
        if ((yCount == Y_SCREEN_PIXELS)) begin
            next_state = S_UPDATE_POS;
        end
         else
            next_state = S_ERASE;
      end
      S_UPDATE_POS: next_state = S_DRAW_STRIPES;
		S_GAMEOVER: begin
			if(restart)
			begin
				next_state = S_RESET;
				resetGameover = 1;
			end
			else
				next_state = S_GAMEOVER;
		end
      default: next_state = S_DRAW_STRIPES;
   endcase
end

always @(*)
begin: enable_signals
   oPlot = 1'b0;
   incrX = 1'b0;
   incrY = 1'b0;
   incrYindex = 1'b0;
   incrXCar = 1'b0;
   decrXCar = 1'b0;
   incrYStripe = 1'b0;
   decrYStripe = 1'b0;
   drawStripeEn = 1'b0;
   drawCarEn = 1'b0;
	drawBoxEn = 1'b0;
	incrYBox = 1'b0;
   eraseEn = 1'b0;
   resetXYCount = 1'b0;
   case (current_state)
      S_RESET: begin
        lastFrameCarDrawn = 0;
        lastFrameStripeDrawn = 0;
        lastFrameErased = 0;
      end
      S_DRAW_STRIPES: begin
        oPlot = 1'b1;
        drawStripeEn = 1'b1;
        if(yIndex < 3'd5) begin //for a given x,y index through the differentstripes
            incrYindex = 1'b1;
        end
        else if(yIndex == 3'd5) begin //yIndex is done
            if(xCount < 8'd10) //check if there is more xvalues
                incrX = 1'b1;
            else if(xCount == 8'd10) begin //move down a row
                incrY = 1'b1;
                incrX = 1'b0;
            end
            incrYindex = 1'b0;
        end
      end
		S_DRAW_CAR_WAIT: resetXYCount = 1'b1;
      S_DRAW_CAR: begin
        oPlot = 1'b1;
        drawCarEn = 1'b1;
        if(xCount < 8'd8) //check if there is more xvalues
            incrX = 1'b1;
        else if(xCount == 8'd8) begin //move down a row
            incrY = 1'b1;
            incrX = 1'b0;
        end
      end
		S_DRAW_BOX_WAIT: begin
			resetXYCount = 1'b1;
		end
		S_DRAW_BOX: begin
		  oPlot = 1'b1;
        drawBoxEn = 1'b1;
        if(xCount < 8'd10) //check if there is more xvalues
            incrX = 1'b1;
        else if(xCount == 8'd10) begin //move down a row
            incrY = 1'b1;
            incrX = 1'b0;
        end
		end
		
		S_ERASE_WAIT: begin
			resetXYCount = 1'b1;
		end
		
      S_ERASE: begin 
         oPlot = 1'b1;
         eraseEn = 1'b1;
			if((frameCount - lastFrameErased) == 6'd1) begin
				lastFrameErased = frameCount;
			end
         if(xCount < (X_SCREEN_PIXELS-1))
            incrX = 1'b1;
         else if(xCount == (X_SCREEN_PIXELS-1))
         begin
            incrY = 1'b1;
            incrX = 1'b0;
         end
      end
		
      S_UPDATE_POS: begin
			resetXYCount = 1'b1;
        //logic to determine whether to update stripes y position
        if(ySpeed < 7'd7 || (ySpeed > 7'd47 && ySpeed < 7'd68)) begin //-27 to -21km/hr or 21 to 40km/hr 2bt/s
            if(frameCount % 5 == 0) begin
                if(ySpeed < 7'd7) decrYStripe = 1'b1;
                else begin
						incrYStripe = 1'b1;
						incrYBox = 1'b1;
					 end
                lastFrameStripeDrawn = frameCount;
            end
        end
        else if(ySpeed < 7'd27 || (ySpeed > 7'd27 && ySpeed < 7'd48)) begin //-20 to -1km/hr or 1 to 20 km/hr 1bt/s
            if(frameCount % 6 == 0) begin
                if(ySpeed < 7'd27) decrYStripe = 1'b1;
                else begin
						incrYStripe = 1'b1;
						incrYBox = 1'b1;
					 end
					 lastFrameStripeDrawn = frameCount;
            end
        end
        else if(ySpeed > 7'd67 && ySpeed < 7'd88) begin //41km/hr to 60km/hr 4bt/s
            if(frameCount % 4 == 0) begin
                incrYStripe = 1'b1;
                lastFrameStripeDrawn = frameCount;
					 incrYBox = 1'b1;
            end
        end
        else if(ySpeed > 7'd87 && ySpeed < 7'd108) begin //61km/hr to 80km/hr 6bt/s
            if(frameCount % 3 == 0) begin
                incrYStripe = 1'b1;
                lastFrameStripeDrawn = frameCount;
					 incrYBox = 1'b1;
            end
        end
        else if(ySpeed > 7'd107) begin //81km/hr to 100km/hr 8bt/s
            if(frameCount % 2 == 0) begin
                incrYStripe = 1'b1;
                lastFrameStripeDrawn = frameCount;
					 incrYBox = 1'b1;
            end
        end
        else if(ySpeed == 7'd27) incrYStripe = 0;

        if(frameCount % 1 == 0) begin
            if(xSpeed == 2'd2) incrXCar = 1'b1;
            else if(xSpeed == 2'd1) decrXCar = 1'b1;
            lastFrameCarDrawn = frameCount;
        end
      end
   // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
   endcase
end // enable_signals

always@(posedge clock, negedge resetn)
begin
   if(!resetn)
      current_state <= S_RESET;
   else 
      current_state <= next_state; 
end

endmodule

module datapath
#(parameter X_SCREEN_PIXELS = 8'd160, parameter Y_SCREEN_PIXELS = 7'd120) (
    input clock,
    input resetn,
    input resetXYCount,
    input incrX,
    input incrY,
    input incrXCar,
    input decrXCar,
    input incrYStripe,
    input decrYStripe,
    input incrYindex,
    input drawCarEn,
    input drawStripeEn,
    input eraseEn,
	 input [5:0] randomX,
	 input incrYBox,
	 input drawBoxEn,
	 input resetGameover,

    output reg [5:0] frameCount,
    output reg [7:0] xCount,
    output reg [6:0] yCount,
    output reg [2:0] yIndex,
    output reg [7:0] oX,
    output reg [6:0] oY,
    output reg [2:0] oColour,
	output reg [5:0] collision,
	output reg gameOver);

    reg [19:0] clockCount; //for rate divider to frameCount whenever it is 833,334 then increment frameCount
    reg [6:0] yStripe1, yStripe2, yStripe3, yStripe4, yStripe5, yStripe6, yCar;
    reg [7:0] xStripe1, xStripe2, xCar; //indexes 0 to 2, (left of car), indexes 3 to 5 (right of car)
    reg [7:0] boxX;
	 reg [6:0] boxY;
	 
	 
    always@(posedge clock, negedge resetn) begin
        if(!resetn) begin //ISSUE HERE, NEED TO Rely ON RESETN
            clockCount <= 20'b0;
            frameCount <= 6'b0;
            xCount <= 8'b0;
            yCount <= 8'b0;
            yIndex <= 3'b0;
            yStripe1 <= 7'b0;
            yStripe2 <= 7'd40;
            yStripe3 <= 7'd80;
            yStripe4 <= 7'b0;
            yStripe5 <= 7'd40;
            yStripe6 <= 7'd80;
            xStripe1 <= 8'd15;
            xStripe2 <= 8'd135;
				collision <= 4'b0;
				gameOver <= 0;
				if(randomX < 90)
					boxX <= randomX + 26;
				else 
					boxX <= randomX - 20;
				boxY <= 0;
            xCar <= 8'd75;
            yCar <= 8'd80;
        end
        else 
        begin
            clockCount <= clockCount + 1'b1;
            if(clockCount == 20'd833334) begin //MAKE SURE TO CHANGE BACK TO 833334
                frameCount <= frameCount + 1'b1;
                clockCount <= 20'b0;
            end
            if(frameCount == 6'd60) //MAKE SURE TO DOUBLE CHECK MIGHT BE WRONG
                frameCount <= 6'b0;
            if(incrYindex)
                yIndex <= yIndex + 1'b1;
            if(incrX) begin
               xCount <= xCount + 1'b1;
               yIndex <= 3'b0;
            end
            if(incrY) begin
               xCount <= 8'b0;
               yIndex <= 3'b0;
               yCount <= yCount + 1'b1;
            end
            if(resetXYCount) begin
               xCount <= 8'b0;
               yCount <= 8'b0;
               yIndex <= 3'b0;
            end
				if(resetGameover)
					gameOver <= 0;
            //add incrementation handling for xy coordinates of car and stripes
            if(incrYStripe) begin
                if(yStripe1 != (Y_SCREEN_PIXELS - 1))
                    yStripe1 <= yStripe1 + 3;
                else
                    yStripe1 <= 7'd0;
                if(yStripe2 != (Y_SCREEN_PIXELS - 1))
                    yStripe2 <= yStripe2 + 3;
                else
                    yStripe2 <= 7'd0;
                if(yStripe3 != (Y_SCREEN_PIXELS - 1))
                    yStripe3 <= yStripe3 + 3;
                else
                    yStripe3 <= 7'd0;
                if(yStripe4 != (Y_SCREEN_PIXELS - 1))
                    yStripe4 <= yStripe4 + 3;
                else
                    yStripe4 <= 7'd0;
                if(yStripe5 != (Y_SCREEN_PIXELS - 1))
                    yStripe5 <= yStripe5 + 3;
                else
                    yStripe5 <= 7'd0;
                if(yStripe6 != (Y_SCREEN_PIXELS - 1))
                    yStripe6 <= yStripe6 + 3;
                else
                    yStripe6 <= 7'd0;  
					 if((boxY + 10) >= yCar && (((boxX + 10) >= xCar || boxX >= xCar)  && boxX <= (xCar + 8)))
					 begin
						if(randomX < 90)
							boxX <= randomX + 25;
						else 
							boxX <= randomX - 20;
						boxY <= 0;
						collision <= collision + 1;
					 end
					 else if(boxY < (Y_SCREEN_PIXELS - 10))
                    boxY <= boxY + 1;
                else
                begin
						if(randomX < 90)
							boxX <= randomX + 26;
						else 
							boxX <= randomX - 20;
						boxY <= 0;
						gameOver <= 1;
					 end
            end
            else if(decrYStripe) begin
                if(yStripe1 != 0)
                    yStripe1 <= yStripe1 - 3;
                else begin
                    yStripe1 <= Y_SCREEN_PIXELS - 1'b1;
                end
                if(yStripe2 != 0)
                    yStripe2 <= yStripe2 - 3;
                else begin
                    yStripe2 <= Y_SCREEN_PIXELS - 1'b1;
                end
                if(yStripe3 != 0)
                    yStripe3 <= yStripe3 - 3;
                else begin
                    yStripe3 <= Y_SCREEN_PIXELS - 1'b1;
                end
                if(yStripe4 != 0)
                    yStripe4 <= yStripe4 - 3;
                else begin
                    yStripe4 <= Y_SCREEN_PIXELS - 1'b1;
                end
                if(yStripe5 != 0)
                    yStripe5 <= yStripe5 - 3;
                else begin
                    yStripe5 <= Y_SCREEN_PIXELS - 1'b1;
                end
                if(yStripe6 != 0)
                    yStripe6 <= yStripe6 - 3;
                else begin
                    yStripe6 <= Y_SCREEN_PIXELS - 1'b1;
                end
            end
            else if(incrXCar) begin
                if(xCar + 1 < 8'd127) begin
                    xCar <= xCar + 1;
                end
            end
            else if(decrXCar) begin
                if(xCar - 1 > 8'd25) begin
                    xCar <= xCar - 1;
                end
            end
        end
    end

    // Output result register
    always@(*) 
    begin
      if(!resetn) begin
         oX <= 8'b0;
         oY <= 7'b0;
         oColour <= 3'b0;
      end
      else begin
        if(drawStripeEn) begin
            if(yIndex == 3'd0) begin
                if((yStripe1 + yCount) < Y_SCREEN_PIXELS)
                    oY <= yStripe1 + yCount;
                else
                    oY <= yStripe1 + yCount - Y_SCREEN_PIXELS;
                oX <= xStripe1 + xCount;
            end
            else if(yIndex == 3'd1) begin
                if((yStripe2 + yCount) < Y_SCREEN_PIXELS)
                    oY <= yStripe2 + yCount;
                else
                    oY <= yStripe2 + yCount - Y_SCREEN_PIXELS;
                oX <= xStripe1 + xCount;
            end
            else if(yIndex == 3'd2) begin
                if((yStripe3 + yCount) < Y_SCREEN_PIXELS)
                    oY <= yStripe3 + yCount;
                else
                    oY <= yStripe3 + yCount - Y_SCREEN_PIXELS;
                oX <= xStripe1 + xCount;
            end
            else if(yIndex == 3'd3) begin
                if((yStripe4 + yCount) < Y_SCREEN_PIXELS)
                    oY <= yStripe4 + yCount;
                else
                    oY <= yStripe4 + yCount - Y_SCREEN_PIXELS;
                oX <= xStripe2 + xCount;
            end
            else if(yIndex == 3'd4) begin
                if((yStripe5 + yCount) < Y_SCREEN_PIXELS)
                    oY <= yStripe5 + yCount;
                else
                    oY <= yStripe5 + yCount - Y_SCREEN_PIXELS;
                oX <= xStripe2 + xCount;
            end
            else if(yIndex == 3'd5) begin
                if((yStripe6 + yCount) < Y_SCREEN_PIXELS)
                    oY <= yStripe6 + yCount;
                else
                    oY <= yStripe6 + yCount - Y_SCREEN_PIXELS;
                oX <= xStripe2 + xCount;
            end
            oColour <= 3'b111;
        end 
        else if(drawCarEn) begin
            oX <= xCar + xCount;
            oY <= yCar + yCount;
				
				if(yCount < 2 && (xCount < 2 || xCount > 6))
					oColour <= 3'b000;
				else if(yCount > 16 && (xCount < 3 || xCount > 5))
					oColour <= 3'b000;
				else if ((yCount > 4 && yCount < 14)&& (xCount == 0 || xCount == 8))
					oColour <= 3'b000;
				else if((yCount == 16 || yCount == 15 || yCount == 14) && (xCount == 0 || xCount == 8))
					oColour <= 3'b111;
				else if((yCount == 2 || yCount == 3 || yCount == 4) && (xCount == 0 || xCount == 8))
					oColour <= 3'b111;
				else if((yCount > 2 && yCount < 6) && (xCount > 2 && xCount < 6))
					oColour <= 3'b001;
				else
					oColour <= 3'b100;
        end
		  else if(drawBoxEn) begin
				oX <= boxX + xCount;
            oY <= boxY + yCount;
				if(yCount < 2 && (xCount < 2 || xCount > 8))
					oColour <= 3'b000;
				else if(yCount > 8 && (xCount < 2 || xCount > 8))
					oColour <= 3'b000;
				else if(yCount > 3 && yCount < 7 && xCount > 3 && xCount < 7)
					oColour <= 3'b101;
				else
					oColour <= 3'b001;
				
		  end
        else if(eraseEn) begin
            oX <= xCount;
            oY <= yCount;
            oColour <= 3'b000;
        end
      end
    end
endmodule