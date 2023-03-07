module AXI4( input CLK,
             input RESET,
             
             input [15:0] W_DATA, //M --> S  Writing data into the slave/memory
             input W_VALID, // M --> S master generates this signal when write Data is valid   
                 
                    
             input [4:0] A_W_ADDR, // M --> S  master sends address to write data into the slave/memory
             input A_W_VALID, // M --> S  Master generates this signal when Write Address and control signals are valid
             
             input [4:0] A_R_ADDR, // M --> S  master sends address to get data(read data) from slave/memory
             input A_R_VALID, // M --> S  The address you gave is valid or not
            
             input R_READY, // M --> S Master generates this signal when it can accept the Read Data and response
             input B_READY,// M --> S Master generates this signal when it can accept a write response
                    
              
             output reg W_READY,//S --> M  Slave generates this signal when it can write .
             output reg A_W_READY, //S --> M Slave generates this signal when it can accept Write Address and control signals
             output reg B_VALID, //S --> MSlave generates this signal when the write response on the bus is valid.
             output reg[1:0] B_RESP, //S --> M This signal indicates the status of the write transaction
             output reg A_R_READY, //S --> M  Slave generates this signal when it can accept the read address& control signals 
             output reg [15:0] R_DATA, // S --> M  reading data from slave/memory 
             output reg R_VALID,  // S --> M  Slave generates this signal when Read Data is valid
             output reg RRSEP // S --> M This signal indicates the status of data transfer.
            );
      reg [15:0] memory [31:0];
      integer i;
      
      parameter [1:0] IDLE_State_read = 2'b00;
      parameter [1:0] IDLE_State_write = 2'b00; 
      parameter [1:0] WRITE_ADDRESS_AND_DATA_State = 2'b01;
      parameter [1:0] WRITE_RESPONSE_State = 2'b10;
      parameter [1:0] READ_ADDRESS_AND_DATA_State = 2'b11;
      
      reg [2:0] present_state_read;
      reg [2:0] next_state_read;
      reg [2:0] next_state_write;
      reg [2:0] present_state_write;
      
      reg [4:0] A_R_ADDR_copy; 
      reg [4:0] A_W_ADDR_copy;
      always @ (posedge CLK  or posedge RESET) // Read FSM
      begin 
          if(RESET == 1'b1) 
          begin
              A_R_READY     <= 1'b0;
              R_DATA        <= 16'b0;
              R_VALID       <= 1'b0;
              RRSEP         <= 1'b0;
              A_R_ADDR_copy <= 5'b0;
              for( i=0;i<32;i = i+1)
              begin
                  memory[i] <= {16{1'b0}}; 
              end
              
              present_state_read <= IDLE_State_read;
              next_state_read    <= IDLE_State_read;               
          end
          else // RESET == 1'b0 condition
          begin
              case(next_state_read)
              
              IDLE_State_read : begin
                             // R_VALID <= 1'b0;
                              if(A_R_VALID == 1'b1)
                              begin
                                  A_R_ADDR_copy   <= A_R_ADDR;
                                  next_state_read <= READ_ADDRESS_AND_DATA_State; 
                                  A_R_READY       <= 1'b1;
                              end
                              else
                              begin
                                  next_state_read <= IDLE_State_read;
                              end
                           end
             READ_ADDRESS_AND_DATA_State: begin
                                              A_R_READY  <= 1'b0;
                                              R_VALID    <= 1'b1;
                                              R_DATA          <=      memory[A_R_ADDR_copy];  
                                              if(R_READY == 1'b1)
                                                  begin
                                                      //R_DATA          <=      memory[A_R_ADDR_copy];   
                                                      next_state_read <= IDLE_State_read;
                                                      R_VALID <= 1'b0;
                                                  end
                                              else
                                                  begin
                                                      next_state_read <= READ_ADDRESS_AND_DATA_State;    
                                                  end
                                          end
                       
              endcase
          end
      end
      
      
      always @ (posedge CLK  or posedge RESET) // WRITE FSM
      begin
          if(RESET == 1'b1) 
          begin
              W_READY       <= 1'b0;
              A_W_READY     <= 1'b0;
              B_VALID       <= 1'b0;
              B_RESP        <= 2'b11;
              A_W_ADDR_copy <= 5'b0; 
              
             /*  for( i=0;i<32;i = i+1)
              begin
                  memory[i] <= {16{1'b0}}; 
              end
              */
              present_state_write <= IDLE_State_write;
              next_state_write    <= IDLE_State_write; 
          end    
          else //RESET == 1'b0 condition             
          begin
              case(next_state_write)
              
              IDLE_State_write : begin
                                 //B_VALID <= 1'b0;
                                 B_RESP  <= 2'b11;
                                 if(A_W_VALID == 1'b1)
                                 begin
                                   A_W_READY        <= 1'b1;
                                   A_W_ADDR_copy    <= A_W_ADDR;
                                   next_state_write <= WRITE_ADDRESS_AND_DATA_State;
                                end
                                else
                                begin
                                  next_state_write <= IDLE_State_write;
                                end
                               end
              WRITE_ADDRESS_AND_DATA_State : begin
                                         A_W_READY <= 1'b0;
                                         if(W_VALID == 1'b1)
                                         begin
                                              W_READY               <= 1'b1;
                                              memory[A_W_ADDR_copy] <= W_DATA;
                                              next_state_write      <= WRITE_RESPONSE_State;
                                         end
                                         else
                                         begin
                                              next_state_write <= WRITE_ADDRESS_AND_DATA_State;
                                         end
                                    end
              WRITE_RESPONSE_State : begin
                                          W_READY <= 1'b0;
                                          B_VALID <= 1'b1;
                                          B_RESP  <= 2'b00;
                                          if(B_READY == 1'b1)
                                          begin
                                             B_VALID          <= 1'b0;
                                             next_state_write <= IDLE_State_write;
                                          end 
                                          else
                                          begin
                                              next_state_write <= WRITE_RESPONSE_State;
                                          end
                                     end
              endcase   
          end
       end
endmodule