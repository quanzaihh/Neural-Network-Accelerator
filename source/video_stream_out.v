/*
    created by  : <Xidian University>
    created date: 2025-03-09
    author      : <zhiquan huang>
    description : 
*/
`timescale 1ns/100fs

`include "../parameters.v"

module video_stream_out(
    input           system_clk,
    input           rst_n,

    input           video_output_req,
    input  [3:0]    fea_out_quant_size,
    input  [9:0]    video_col_size,
    input           video_valid,
    input  [47:0]   video_data,
    output          video_ready,

    output reg      axi_stream_tvalid, 
    output [31:0]   axi_stream_tdata,
    output [3:0]    axi_stream_tkeep,
    output          axi_stream_tlast,
    input           axi_stream_tready,
    output          axi_stream_tuser
);

// depack input data
wire [15:0] depacked_data[2:0];
reg  [7:0]  pic_data[2:0];
assign depacked_data[0] = video_data[15] ? (~video_data[15:0] + 1) : video_data[15:0];
assign depacked_data[1] = video_data[31] ? (~video_data[31:16] + 1) : video_data[31:16];
assign depacked_data[2] = video_data[47] ? (~video_data[47:32] + 1) : video_data[47:32];

// dequant input data
wire [31:0] dequant_data;
reg         dequant_valid;

always@(posedge system_clk) begin
    case(fea_out_quant_size)
        4'd1: begin
            pic_data[2] <= (depacked_data[2][15:1] == 0) ? {depacked_data[2][0:0], 7'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:1] == 0) ? {depacked_data[1][0:0], 7'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:1] == 0) ? {depacked_data[0][0:0], 7'b0} : 255;
        end
        4'd2: begin
            pic_data[2] <= (depacked_data[2][15:2] == 0) ? {depacked_data[2][1:0], 6'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:2] == 0) ? {depacked_data[1][1:0], 6'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:2] == 0) ? {depacked_data[0][1:0], 6'b0} : 255;
        end
        4'd3: begin
            pic_data[2] <= (depacked_data[2][15:3] == 0) ? {depacked_data[2][2:0], 5'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:3] == 0) ? {depacked_data[1][2:0], 5'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:3] == 0) ? {depacked_data[0][2:0], 5'b0} : 255;
        end
        4'd4: begin
            pic_data[2] <= (depacked_data[2][15:4] == 0) ? {depacked_data[2][3:0], 4'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:4] == 0) ? {depacked_data[1][3:0], 4'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:4] == 0) ? {depacked_data[0][3:0], 4'b0} : 255;
        end
        4'd5: begin
            pic_data[2] <= (depacked_data[2][15:5] == 0) ? {depacked_data[2][4:0], 3'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:5] == 0) ? {depacked_data[1][4:0], 3'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:5] == 0) ? {depacked_data[0][4:0], 3'b0} : 255;
        end
        4'd6: begin
            pic_data[2] <= (depacked_data[2][15:6] == 0) ? {depacked_data[2][5:0], 2'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:6] == 0) ? {depacked_data[1][5:0], 2'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:6] == 0) ? {depacked_data[0][5:0], 2'b0} : 255;
        end
        4'd7: begin
            pic_data[2] <= (depacked_data[2][15:7] == 0) ? {depacked_data[2][6:0], 1'b0} : 255;
            pic_data[1] <= (depacked_data[1][15:7] == 0) ? {depacked_data[1][6:0], 1'b0} : 255;
            pic_data[0] <= (depacked_data[0][15:7] == 0) ? {depacked_data[0][6:0], 1'b0} : 255;
        end
        default: begin
            pic_data[2] <= 0;
            pic_data[1] <= 0;
            pic_data[0] <= 0;
        end
    endcase
    dequant_valid <= video_valid;
end

assign dequant_data = {8'hff, pic_data[0], pic_data[1], pic_data[2]};   // BGR TO RGB

wire video_last;
wire video_user;
wire buffer_almost_full;
wire buffer_empty;

generate
    if (`device == "xilinx") begin
        stream_buffer stream_buffer_inst(
            .clk            ( system_clk                                            ), 
            .srst           ( ~rst_n                                                ), 
            .din            ( {dequant_data, video_last, video_user}                ), 
            .wr_en          ( dequant_valid                                         ), 
            .rd_en          ( axi_stream_tvalid                     ), 
            .dout           ( {axi_stream_tdata, axi_stream_tlast, axi_stream_tuser}), 
            .prog_full      ( buffer_almost_full                                    ), 
            .almost_full    (                                                       ), 
            .empty          ( buffer_empty                                          )   
        );
    end
    else if (`device == "simulation") begin
        // sync_fifo #(
        //     .INPUT_WIDTH       	( 34        ),
        //     .OUTPUT_WIDTH      	( 34        ),
        //     .WR_DEPTH          	( 1024      ),
        //     .RD_DEPTH          	( 1024      ),
        //     .MODE              	( "FWFT"    ),
        //     .DIRECTION         	( "MSB"     ),
        //     .ECC_MODE          	( "no_ecc"  ),
        //     .PROG_EMPTY_THRESH 	( 2         ),
        //     .PROG_FULL_THRESH  	( 1000      ),
        //     .USE_ADV_FEATURES  	( 16'h1F1F  ))
        // u_sync_fifo(
        //     .clock         	( system_clk                                            ),
        //     .reset         	( ~rst_n                                                ),
        //     .wr_en         	( dequant_valid                                         ),
        //     .din           	( {dequant_data, video_last, video_user}                ),
        //     .rd_en         	( axi_stream_tready & ~buffer_empty                     ),
        //     .dout          	( {axi_stream_tdata, axi_stream_tlast, axi_stream_tuser}),
        //     .empty         	( buffer_empty                                          ),
        //     .prog_full     	( buffer_almost_full                                    )
        // );

        async_fifo #(
            .INPUT_WIDTH       	( 34        ),
            .OUTPUT_WIDTH      	( 34        ),
            .WR_DEPTH          	( 1024      ),
            .RD_DEPTH          	( 1024      ),
            .MODE              	( "FWFT"    ),
            .DIRECTION         	( "MSB"     ),
            .ECC_MODE          	( "no_ecc"  ),
            .PROG_EMPTY_THRESH 	( 2         ),
            .PROG_FULL_THRESH  	( 1000      ))
        u_async_fifo(
            .reset         	( ~rst_n                ),
            .wr_clock      	( system_clk            ),
            .wr_en         	( dequant_valid          ),
            .din           	( {dequant_data, video_last, video_user}            ),
            .rd_clock      	( system_clk       ),
            .rd_en         	( axi_stream_tvalid          ),
            .valid         	(                     ),
            .dout          	( {axi_stream_tdata, axi_stream_tlast, axi_stream_tuser}           ),
            .empty         	( buffer_empty          ),
            .prog_full     	( buffer_almost_full      )
        );
    end
endgenerate

reg output_req_reg;

always @(posedge system_clk or negedge rst_n) begin
    if(~rst_n) begin
        output_req_reg <= 0;
    end 
    else if (video_output_req) begin
        output_req_reg <= 1;
    end
    else if (dequant_valid) begin
        output_req_reg <= 0;
    end
end

assign video_user = output_req_reg;

// 维护一个列计数器产生last
reg [9:0] col_counter;

always @(posedge system_clk or negedge rst_n) begin
    if(~rst_n) begin
        col_counter <= 0;
    end
    else if (video_output_req) begin
        col_counter <= 0;
    end 
    else if (dequant_valid) begin
        if (col_counter == video_col_size-1) begin
            col_counter <= 0;
        end
        else begin
            col_counter <= col_counter + 1;
        end
    end
end

always@(posedge system_clk or negedge rst_n) begin
    axi_stream_tvalid <= (~buffer_empty) & axi_stream_tready;
end

assign video_last = (col_counter == video_col_size-1) & dequant_valid;
assign video_ready = ~buffer_almost_full;
assign axi_stream_tkeep = 4'b1111;

endmodule