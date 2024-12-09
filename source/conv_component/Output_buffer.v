/*
    created by  : <Xidian University>
    created date: 2024-09-24
    author      : <zhiquan huang>
*/
`timescale 1ns/100fs

`include "../../parameters.v"

module Output_buffer #(
    parameter MAC_OUTPUT_WIDTH = `MAC_OUTPUT_WIDTH
)
(
    input                                  system_clk   ,
    input                                  rst_n        ,
    // refresh buffer   
    input                                  refresh_req  ,
    input                                  pull_out_req ,
    output                                 pull_finish  ,
    input                                  pull_where   ,   // 1: To activate, 0: To adder_feature

    input                                  pull_ready   ,
    output[MAC_OUTPUT_WIDTH*8-1:0]         data_for_act ,
    output                                 data_for_act_valid,

    input                                  adder_pulse  ,
    output[MAC_OUTPUT_WIDTH*8-1:0]         adder_feature,

    input [MAC_OUTPUT_WIDTH*8-1:0]         feature_in   ,
    input                                  feature_valid
);

reg [14:0]  uram_write_addr;
reg [14:0]  uram_read_addr;
wire[71:0]  uram_read_data[3:0]; 
reg         pull_flag;
reg [2:0]   pull_flag_reg;

genvar i;
generate
    for (i=0; i<4; i=i+1) begin: output_buffer
        xpm_memory_sdpram #(
            .ADDR_WIDTH_A           (15),               // DECIMAL
            .ADDR_WIDTH_B           (15),               // DECIMAL
            .AUTO_SLEEP_TIME        (0),                // DECIMAL
            .BYTE_WRITE_WIDTH_A     (72),               // DECIMAL
            .CASCADE_HEIGHT         (0),                // DECIMAL
            .CLOCKING_MODE          ("common_clock"),   // String
            .ECC_MODE               ("no_ecc"),         // String
            .MEMORY_INIT_FILE       ("none"),           // String
            .MEMORY_INIT_PARAM      ("0"),              // String
            .MEMORY_OPTIMIZATION    ("true"),           // String
            .MEMORY_PRIMITIVE       ("ultra"),          // String
            .MEMORY_SIZE            (32768*72),         // DECIMAL
            .MESSAGE_CONTROL        (0),                // DECIMAL
            .READ_DATA_WIDTH_B      (72),               // DECIMAL
            .READ_LATENCY_B         (3),                // DECIMAL
            .READ_RESET_VALUE_B     ("0"),              // String
            .RST_MODE_A             ("SYNC"),           // String
            .RST_MODE_B             ("SYNC"),           // String
            .SIM_ASSERT_CHK         (1),                // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            .USE_EMBEDDED_CONSTRAINT(0),                // DECIMAL
            .USE_MEM_INIT           (1),                // DECIMAL
            .USE_MEM_INIT_MMI       (0),                // DECIMAL
            .WAKEUP_TIME            ("disable_sleep"),  // String
            .WRITE_DATA_WIDTH_A     (72),               // DECIMAL
            .WRITE_MODE_B           ("read-first"),     // String
            .WRITE_PROTECT          (1)                 // DECIMAL
        )
        xpm_memory_sdpram_inst (
            .dbiterrb       (),
            .sbiterrb       (),
            .clka           (system_clk),                     
            .clkb           (system_clk),     
            .dina           (feature_in[i*MAC_OUTPUT_WIDTH*2+:MAC_OUTPUT_WIDTH*2]),  
            .addra          (uram_write_addr),               
            .doutb          (uram_read_data[i]),           
            .addrb          (uram_read_addr),          
            .ena            (1'b1),                       
            .enb            (1'b1),                       
            .injectdbiterra (1'b0), 
            .injectsbiterra (1'b0), 
            .regceb         (1'b1),                
            .rstb           (1'b0),                   
            .sleep          (1'b0),                 
            .wea            (feature_valid)                        
        );
    end
endgenerate

always @(posedge system_clk or negedge rst_n) begin
    if(~rst_n) begin
        uram_write_addr <= 0;
    end
    else if (refresh_req) begin
        uram_write_addr <= 0;
    end
    else if (feature_valid) begin
        uram_write_addr <= uram_write_addr + 1;
    end
end

always @(posedge system_clk or negedge rst_n) begin
    if(~rst_n) begin
        uram_read_addr <= 0;
    end
    else if (refresh_req | pull_out_req) begin
        uram_read_addr <= 0;
    end
    else if (pull_flag & pull_ready) begin
        uram_read_addr <= uram_read_addr + 1;
    end
    else if (adder_pulse) begin
        uram_read_addr <= uram_read_addr + 1;
    end
end

always @(posedge system_clk or negedge rst_n) begin
    if (~rst_n) begin
        pull_flag <= 0;
    end
    else if (pull_out_req) begin
        pull_flag <= 1;
    end
    else if (uram_read_addr == uram_write_addr - 1) begin
        pull_flag <= 0;
    end
end

always @(posedge system_clk or negedge rst_n) begin
    pull_flag_reg <= {pull_flag_reg[1:0], pull_flag};
end

assign pull_finish = ~pull_flag;
assign data_for_act = {uram_read_data[3], uram_read_data[2], uram_read_data[1], uram_read_data[0]};
assign adder_feature = {uram_read_data[3], uram_read_data[2], uram_read_data[1], uram_read_data[0]};
assign data_for_act_valid = (pull_where) ? pull_flag_reg[2] & pull_ready : 1'b0;

endmodule