module keyboardWithFlags(
	input PS2_CLOCK,
	input PS2_DATA,
	input RESET,
	input CLOCK_50,
	output reg flag_W,
	output reg flag_A,
	output reg flag_S,
	output reg flag_D
	);
	
	reg isBreak;
	wire [7:0] keyPressed;
	wire begin_test;
	wire idle_test;
	wire clear_test;
	wire parity_test;
	wire output_test;
	wire timeoutTest;
	wire [10:0] fullTransmission;

	keyboard u3(
		.clock_50(CLOCK_50),
		.RESET(RESET),
		.PS2_DATA(PS2_DATA),
		.PS2_CLOCK(PS2_CLOCK),
		.validKey(output_test),
		.outputKey(keyPressed),
		.beginTest(begin_test),
		.idleTest(idle_test),
		.fullTransmission(fullTransmission),
		.parityTest(parity_test),
		.clearTest(clear_test),
		.timeoutTest(timeoutTest)
		
	);
		
	always@ (posedge RESET, posedge output_test)
	begin
		if(RESET == 1)
		begin
			flag_W = 1'b0;
			flag_A = 1'b0;
			flag_S = 1'b0;
			flag_D = 1'b0;
			isBreak = 1'b0;
		end 
		
		else
		begin
		
			if(isBreak == 1)
			begin
				//Check what outputReg corresponds to, turn off corresponding flag
				//turn off isBreak
				isBreak = 1'b0;
				
				// First condition is a precaui
				if (keyPressed == 8'hF0)
					isBreak = 1'b1;
				else if(keyPressed == 8'h1C)
					flag_A = 1'b0;
				else if(keyPressed == 8'h1D)
					flag_W = 1'b0;
				else if(keyPressed == 8'h1B)
					flag_S = 1'b0;
				else if(keyPressed == 8'h23)
					flag_D = 1'b0;
			end
			
			else if (keyPressed == 8'hF0)
				isBreak = 1'b1;
			else if(keyPressed == 8'h1C)
				flag_A = 1'b1;
			else if(keyPressed == 8'h1D)
				flag_W = 1'b1;
			else if(keyPressed == 8'h1B)
				flag_S = 1'b1;
			else if(keyPressed == 8'h23)
				flag_D = 1'b1;
		end		
	end
endmodule

module keyboard(
//	input [6:0] hex0,
//	input [6:0] hex1,
	input PS2_CLOCK,
	input PS2_DATA,
	input RESET,
	input clock_50,
	output validKey,
	output [7:0] outputKey,
	output idleTest,
	output beginTest,
	output parityTest,
	output clearTest,
	output timeoutTest,
	output [10:0] fullTransmission
	);
	
//	wire [7:0] outputKey;
	wire resetEnableSREG;
	wire [10:0] output_Wire_SREG;
	wire [7:0] characterFound;
	wire timeOutEn;
	assign fullTransmission = output_Wire_SREG;
	assign clearTest = resetEnableSREG;
	
	
	controlPath cpath(
		.reset(RESET),
		.lastBit(output_Wire_SREG[0]),
		.resetEnable(resetEnableSREG),
		.keyFound(validKey),
		.clock_50(clock_50),
		.idleTest(idleTest),
		.beginTest(beginTest),
		.full_data(output_Wire_SREG[10:0]),
		.parityTest(parityTest),
		.timeoutTest(timeoutTest),
		.timeOut(timeOutEn) 
	);
	
	leftShift u1(
		.clk(PS2_CLOCK),
		.Data(PS2_DATA),
		.reset(resetEnableSREG),
		.dataOut(output_Wire_SREG),
		.characterSeen(outputKey),
		.timeoutEn(timeOutEn)
	);
	

endmodule
	


module controlPath(
	input reset,
	input lastBit,
	input clock_50,
	input [10:0] full_data, 
	input timeOut,
	output reg resetEnable,
	output reg keyFound,
	output reg idleTest,
	output reg beginTest,
	output reg parityTest,
	output reg timeoutTest
	);
	
		 
	reg [2:0] current_state, next_state;
					
	localparam S_BEGIN = 3'd0,
				  S_IDLE = 3'd1,
				  S_TIMEOUT = 3'd2,
				  S_PARITY = 3'd3,
				  S_OUTPUT = 3'd4,
				  S_CLEAR = 3'd5;
				  
				  
		
		
	always@(*)
	begin: state_table
		case (current_state) 
			S_IDLE : next_state = (lastBit == 0)? S_PARITY : (timeOut? S_TIMEOUT : S_IDLE); 
			S_TIMEOUT : next_state = S_BEGIN;
			S_PARITY : next_state = (^full_data)? S_CLEAR : S_OUTPUT;
			S_OUTPUT : next_state = S_CLEAR; // Load key into a reg and clear reg for next key? REVISIT THIS ****
			S_CLEAR : next_state = S_BEGIN;// Go back to checking for last bit
		
		default : next_state = S_IDLE;
		
		endcase
	end //state_table
	
	
	
	always@(*) 
	begin: enable_signals
		
		resetEnable = 1'b0;
		keyFound = 1'b0;
		idleTest = 1'b0;
		beginTest = 1'b0;
		parityTest = 1'b0;
		timeoutTest = 1'b0;
	//Data signals from control path to datapath 
	
	case (current_state)
	
	  S_BEGIN : begin
		 resetEnable = 1'b1;
		 beginTest = 1'b1;
		 end
	
	  S_IDLE : begin
		 idleTest = 1'b1;
		 end
		
	  S_TIMEOUT : begin
		timeoutTest = 1'b1;
	   end
		
	  S_PARITY : begin
		 parityTest = 1'b1;
		 end 
		 
	  S_OUTPUT : begin
		 keyFound = 1'b1;
	  	 end
	  
	  S_CLEAR : begin
		 resetEnable = 1'b1;
		 end
		 
		default: resetEnable = 1'b1;
		
	  endcase
	end // enable_signals
	
	//curent_state registers
	always@(posedge clock_50)
	begin: state_FFS
		if(reset)
			current_state <= S_BEGIN;
		else current_state <= next_state;
	end //state_FFS
endmodule 



module leftShift(
	input clk,
	input Data,
	input reset,
	input clock_50,
	output reg [10:0] dataOut,
	output reg timeoutEn,
	output [7:0]  characterSeen
	);

	parameter timeOutTimer = 500000;				// 10 millisecond Rx timeout
	assign characterSeen = dataOut[8:1];
	reg [20:0] timeOutCounter;
	reg countEn;
	
	always @ (negedge clk, posedge reset)
	begin
		if(reset == 1)
			dataOut = 11'b11111111111;
		else begin
			dataOut = dataOut >> 1;
			dataOut[10] = Data;
		end
	end

	always @ (posedge clock_50, posedge reset)
	begin
		if(reset == 1)
		begin
			timeOutCounter = 21'd0;
			timeoutEn = 1'b0;
			countEn = 1'b0;
		end
		
		else 
		begin
			if(clk == 0)
				countEn = 1'b1;
				
			if(countEn == 1)
				timeOutCounter = timeOutCounter + 1;
			
			if(timeOutCounter == timeOutTimer - 1);
				timeoutEn = 1'b1;
		end
	end
	
endmodule