`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:30:47 11/22/2015 
// Design Name: 
// Module Name:    lcd 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// -use_new_parser yes
//////////////////////////////////////////////////////////////////////////////////
module lab9(
    input clk,
    input reset,
    input  button,
    output LCD_E,
    output LCD_RS,
    output LCD_RW,
    output [3:0]LCD_D
    );
     localparam [1:0] S_INIT = 2'b00, S_FIND = 2'b01, S_ANS = 2'b10, S_STOP = 2'b11;
     reg [2:0] Q, Q_next;	
	  /////
	 reg [25:0] counter;
	 reg [25:0] counter1;
	 reg [5:0] count,clock;
	 integer c,d;
	 reg [7:0] ans;
	 reg [2:0] r;
	 /////
    reg primes[1023:0];
	 reg data_out;
	 wire       we, en;
    reg [7:0] e;
	 assign en=1;
    assign we=1;
	 ////
    wire btn_level, btn_pressed;
    reg prev_btn_level;
    reg [127:0] row_A, row_B, row;
	 reg [25:0] display;
	 reg [10:0] answer[1023:0];
    LCD_module lcd0( 
      .clk(clk),
      .reset(reset),
      .row_A(row_A),
      .row_B(row_B),
      .LCD_E(LCD_E),
      .LCD_RS(LCD_RS),
      .LCD_RW(LCD_RW),
      .LCD_D(LCD_D)
    );
    
    debounce btn_db0(
      .clk(clk),
      .btn_input(button),
      .btn_output(btn_level)
   );
    
    always @(posedge clk) begin
      if (reset)
        prev_btn_level <= 1;
      else
        prev_btn_level <= btn_level;
    end

    assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;

    always @(posedge clk or posedge reset) begin

      if (reset) begin
        row_A <= 128'h2248656C6C6F2C20576F726C64212220; // "Hello, World!"
        row_B <= 128'h44656D6F206F6620746865204C43442E; // Demo of the LCD.
		  row <=   128'h5072696D652023000020697320000000;
		  clock<=4;
		  display <=0;
		  e<=1;
		  r<=1;
      end
      else if(btn_pressed==1)
		begin
		if(r==1)
		r<=2;
		else
		r<=1;
		clock<=4;
		if(r==2)
				 begin
				 if(e+1==d-1)
				 e<=1;
				 else
				 e<=e+2;
				 end
				 else
				 begin
				 if(e-1==1)
				 e<=d-1;
				 else
				 e<=e-2;
				 end
		end
		else if(Q== S_STOP)
		begin
		   if(r==1)
			begin
			if(clock==3)
			begin
			 if(display==0)
			 begin
			 row_B<=row;
			 row_A<=row_B;
			 display<=display+1;
			 end
			 else if(display<=35000000)
			 begin
			 display<=display+1;
			 end
			 else
			 begin
			 clock<=4;
			 display<=0;
			 end
			end
			end
			else
			begin
			if(clock==3)
			begin
			 if(display==0)
			 begin
			 row_A<=row;
			 row_B<=row_A;
			 display<=display+1;
			 end
			 else if(display<=35000000)
			 begin
			 display<=display+1;
			 end
			 else
			 begin
			 clock<=4;
			 display<=0;
			 end
			end
			end
			
			
			
			if(clock==4)
			begin
			    if(r==1)
				 begin
				 if(e==d-1)
				 e<=1;
				 else
				 e<=e+1;
				 end
				 else
				 begin
				 if(e==1)
				 e<=d-1;
				 else
				 e<=e-1;
				 end
            if(e[3:0]<10)           
               row[63:56]<=8'd48+e[3:0];   
            else
               row[63:56]<=8'd55+e[3:0];
            if(e[7:4]<10)
               row[71:64]<=8'd48+e[7:4];
            else
               row[71:64]<=8'd55+e[7:4];
				if(answer[e][3:0]<10)           
               row[7:0]<=8'd48+answer[e][3:0];   
            else
               row[7:0]<=8'd55+answer[e][3:0];
            if(answer[e][7:4]<10)
               row[15:8]<=8'd48+answer[e][7:4];
            else
               row[15:8]<=8'd55+answer[e][7:4];
            if(answer[e][10:8]<10)
               row[23:16]<=8'd48+answer[e][10:8];
            else
               row[23:16]<=8'd55+answer[e][10:8];							
            clock<=3;					
			end
		end
    end

	 
	 always @(posedge clk) begin
    if (reset) Q <= S_INIT;
    else Q <= Q_next;
    end

    always @(*) begin
     case (Q)
    S_INIT:
	   begin
		if(c==2)
		Q_next<=S_FIND;
		end
    S_FIND:
      begin
		 if(count!=4)
	    Q_next <= S_FIND;
		 else Q_next <= S_ANS;
		end
    S_ANS: 
       begin
       if(c==1024)
        Q_next <= S_STOP;  
		 else 
		  Q_next <= S_ANS; 
      end	
    S_STOP:
      Q_next <= S_STOP;
		default
		Q_next <=S_INIT; 
  endcase
end
 always@(posedge clk)
  begin
   if(Q==S_INIT)
	begin
	   counter<=2;
	   counter1<=4;
	   count<=3;
	   d<=1;
		c<=2;
		data_out<=1;
	end
	else if(Q==S_FIND)
	begin
	  if(counter!=1024)
	    begin	  
	     if(counter1>1023)
		  begin
		   counter1<=(counter+1)*2;
		   counter<=counter+1;
		  end
	     else
		  begin
		   primes[counter1]<=1;
			counter1<=counter1+counter;
		  end 
		  end
		  else
		  count<=4;
	end
	else if(Q==S_ANS)
	begin
	if(c<1024)
		 begin
		  data_out<=primes[c];
		  
		  if(data_out==0)
		  begin
		  answer[d]<=c-1;
		  d<=d+1;
		  end
		  c<=c+1;
		 end
	end
  end
endmodule
