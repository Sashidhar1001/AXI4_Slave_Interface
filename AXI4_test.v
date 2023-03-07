module AXI4_TB();
      reg CLK;
      reg RESET;
             
      reg [15:0] W_DATA; //M --> S  Writing data into the slave/memory
      reg W_VALID; // M --> S master generates this signal when write Data is valid   
                 
                    
      reg [4:0] A_W_ADDR; // M --> S  master sends address to write data into the slave/memory
      reg A_W_VALID; // M --> S  Master generates this signal when Write Address and control signals are valid
             
      reg [4:0] A_R_ADDR; // M --> S  master sends address to get data(read data) from slave/memory
      reg A_R_VALID; // M --> S  The address you gave is valid or not
            
      reg R_READY; // M --> S Master generates this signal when it can accept the Read Data and response
      reg B_READY;// M --> S Master generates this signal when it can accept a write response
                    
              
      wire W_READY;//S --> M  Slave generates this signal when it can write .
      wire A_W_READY; //S --> M Slave generates this signal when it can accept Write Address and control signals
      wire B_VALID; //S --> MSlave generates this signal when the write response on the bus is valid.
      wire [1:0] B_RESP; //S --> M This signal indicates the status of the write transaction
      wire A_R_READY; //S --> M  Slave generates this signal when it can accept the read address& control signals 
      wire [15:0] R_DATA; // S --> M  reading data from slave/memory 
      wire R_VALID;  // S --> M  Slave generates this signal when Read Data is valid
      wire RRSEP; // S --> M This signal indicates the status of data transfer.
      AXI4 test( .CLK(CLK),
                 .RESET(RESET),
                 .W_DATA(W_DATA),
                 .W_VALID(W_VALID),
                 .A_W_ADDR(A_W_ADDR),
                 .A_W_VALID(A_W_VALID),
                 .A_R_ADDR(A_R_ADDR),
                 .A_R_VALID(A_R_VALID),
                 .R_READY(R_READY),
                 .B_READY(B_READY),
                 .W_READY(W_READY),
                 .A_W_READY(A_W_READY),
                 .B_VALID(B_VALID),
                 .B_RESP(B_RESP),
                 .A_R_READY(A_R_READY),
                 .R_DATA(R_DATA),
                 .R_VALID(R_VALID),
                 .RRSEP(RRSEP)
                );
                
 initial CLK <= 1'b0;
 always #5 CLK <= ~CLK;
 
 
 integer i;
 integer j; 
 integer fptrW;
 integer fptrR;
 
 initial
 begin
       RESET <= 1'b1;
       A_W_ADDR <= 5'd31;
       A_W_VALID <= 1'b0;
       W_DATA <= 16'd0;
       W_VALID <= 1'b0;
       B_READY <= 1'b0;
       
        A_R_ADDR <= 5'd0;
        A_R_VALID <= 1'b0;
        R_READY <= 1'b0;
        
       fptrW = $fopen(".txt file","w");
       fptrR = $fopen(".txt file","r");
       
       repeat(2) @(posedge CLK);
       RESET <= 1'b0;
       for(i=0; i<32; i=i+1'b1)
       begin
         //A_W_ADDR = A_W_ADDR + 1'b1;
         @(posedge CLK);
         $fscanf(fptrR,"%d\t",A_W_ADDR);
         A_W_VALID <= 1'b1;
         @(negedge A_W_READY);
         A_W_VALID <= 1'b0;
         
        // W_DATA <= W_DATA - 1'b1;
         $fscanf(fptrR,"%d\n",W_DATA); 
         W_VALID <= 1'b1;
         @(negedge W_READY);
         W_VALID <= 1'b0;
         
         B_READY <= 1'b1;
         @(negedge B_VALID );
         B_READY <= 1'b0;
         repeat (1) 
          begin
            @(posedge CLK);
          end
        end
         
         
        repeat(4)@(posedge CLK);
        //reading
        for(j=0; j<32; j = j+1)
        begin
          
          A_R_ADDR <= A_R_ADDR - 1'b1;    

          A_R_VALID <= 1'b1;
          @(negedge A_R_READY);
          A_R_VALID <= 1'b0;
          
          R_READY <= 1'b1;
          @(negedge R_VALID);
          R_READY <= 1'b0;  
          repeat (1) 
          begin
            @(posedge CLK);
          end     
       end
 end
 always @(posedge CLK)
 begin
     if(A_R_READY <= 1'b1 && R_VALID == 1'b1)
     begin    
         $fwrite(fptrW,"%d\t",R_DATA);
     end
     else
     begin
         $fwrite("slave is not ready to receive data and address");
     end
 end
endmodule

/*initial
    begin
          RESET <= 1'b1;
          A_W_ADDR <= 5'b00000;
          A_W_VALID <= 1'b0;
          W_DATA <= 16'b0;
          W_VALID <= 1'b0;
          B_READY <= 1'b0;
          
          A_R_ADDR <= 5'b00000;
          A_R_VALID <= 1'b0;
          R_READY <= 1'b0;
          
          repeat(2) @(posedge CLK);
          RESET <= 1'b0;
          A_W_ADDR <= 5'd31;
          A_W_VALID <= 1'b1;
          @(negedge A_W_READY);
          A_W_VALID <= 1'b0;
          
         
         @(posedge CLK);
          W_DATA <= 16'd182; 
          W_VALID <= 1'b1;
          @(negedge W_READY);
          W_VALID <= 1'b0;
          
          
          B_READY <= 1'b1;
          @(negedge B_VALID );
          B_READY <= 1'b0;
          
         
          
          //reading
          repeat(2) @(posedge CLK);
          A_R_ADDR <= 5'd31;       

          A_R_VALID <= 1'b1;
          @(negedge A_R_READY);
          A_R_VALID <= 1'b0;
          
          R_READY <= 1'b1;
          @(negedge R_VALID);
          R_READY <= 1'b0;
    end   
endmodule*/