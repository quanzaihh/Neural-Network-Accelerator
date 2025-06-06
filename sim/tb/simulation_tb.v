/*
    created by  : <Xidian University>
    created date: 2024-09-24
    author      : <zhiquan huang>
*/
`timescale 1ns/100fs

`include "../../parameters.v"

module conv_control_tb ();

reg system_clk, rst_n;
reg m_axi_aclk, m_axi_aresetn;
initial begin
    m_axi_aclk = 0;
    forever #10 m_axi_aclk = ~m_axi_aclk;
end
initial begin
    m_axi_aresetn = 0;
    #20 m_axi_aresetn = 1;
end
initial begin
    system_clk = 0;
    forever #5 system_clk = ~system_clk;
end
initial begin
    rst_n = 0;
    #10 rst_n = 1;
end       

// outports wire
wire [31:0]  s_axi_awaddr;
wire [7:0]   s_axi_awlen;
wire [2:0]   s_axi_awsize;
wire [1:0]   s_axi_awburst;
wire         s_axi_awlock;
wire [3:0]   s_axi_awcache;
wire [2:0]   s_axi_awprot;
wire         s_axi_awvalid;
wire         s_axi_awready;
wire [511:0] s_axi_wdata;
wire [63:0]  s_axi_wstrb;
wire         s_axi_wlast;
wire         s_axi_wvalid;
wire         s_axi_wready;
wire [1:0]   s_axi_bresp;
wire         s_axi_bvalid;
wire         s_axi_bready;
wire [7:0]   s_axi_arid;
wire [31:0]  s_axi_araddr;
wire [7:0]   s_axi_arlen;
wire [2:0]   s_axi_arsize;
wire [1:0]   s_axi_arburst;
wire         s_axi_arlock;
wire [3:0]   s_axi_arcache;
wire [2:0]   s_axi_arprot;
wire         s_axi_arvalid;
wire         s_axi_arready;
wire [7:0]   s_axi_rid;
wire [511:0] s_axi_rdata;
wire [1:0]   s_axi_rresp;
wire         s_axi_rlast;
wire         s_axi_rvalid;
wire         s_axi_rready;

wire         s_axi_rvalid_copy;
wire         s_axi_rlast_copy;
wire [511:0] s_axi_rdata_copy;
reg          s_axi_rvalid_reg;
reg          s_axi_rlast_reg;
reg  [511:0] s_axi_rdata_reg;
reg          rden;

wire [7:0]        m_axi_awaddr ;
wire [2:0]        m_axi_awprot ;
wire              m_axi_awvalid;
wire              m_axi_awready;
wire [31:0]       m_axi_wdata  ;
wire [(32/8)-1:0] m_axi_wstrb  ;
wire              m_axi_wvalid ;
wire              m_axi_wready ;
wire [1:0]        m_axi_bresp  ;    
wire              m_axi_bvalid ;
wire              m_axi_bready ;
wire [7:0]        m_axi_araddr ;
wire [2:0]        m_axi_arprot ;
wire              m_axi_arvalid;
wire              m_axi_arready;
wire [31:0]       m_axi_rdata  ;
wire [1:0]        m_axi_rresp  ;
wire              m_axi_rvalid ;
wire              m_axi_rready ;

axi_ram u_axi_ram(
    .clk               ( system_clk     ),    
    .rst               ( ~rst_n         ),
    .s_axi_awid        ( 8'd0           ),  
    .s_axi_awaddr      ( s_axi_awaddr   ),
    .s_axi_awlen       ( s_axi_awlen    ),
    .s_axi_awsize      ( s_axi_awsize   ),
    .s_axi_awburst     ( s_axi_awburst  ),
    .s_axi_awlock      ( s_axi_awlock   ),
    .s_axi_awcache     ( s_axi_awcache  ),
    .s_axi_awprot      ( s_axi_awprot   ),
    .s_axi_awvalid     ( s_axi_awvalid  ),
    .s_axi_awready     ( s_axi_awready  ),
    .s_axi_wdata       ( s_axi_wdata    ),
    .s_axi_wstrb       ( s_axi_wstrb    ),
    .s_axi_wlast       ( s_axi_wlast    ),
    .s_axi_wvalid      ( s_axi_wvalid   ),
    .s_axi_wready      ( s_axi_wready   ),
    .s_axi_bid         (                ),
    .s_axi_bresp       ( s_axi_bresp    ),
    .s_axi_bvalid      ( s_axi_bvalid   ),
    .s_axi_bready      ( s_axi_bready   ),
    .s_axi_arid        ( 8'd0           ),
    .s_axi_araddr      ( s_axi_araddr   ),
    .s_axi_arlen       ( s_axi_arlen    ),
    .s_axi_arsize      ( s_axi_arsize   ),
    .s_axi_arburst     ( s_axi_arburst  ),
    .s_axi_arlock      ( s_axi_arlock   ),
    .s_axi_arcache     ( s_axi_arcache  ),
    .s_axi_arprot      ( s_axi_arprot   ),
    .s_axi_arvalid     ( s_axi_arvalid  ),
    .s_axi_arready     ( s_axi_arready  ),
    .s_axi_rid         (                ),
    .s_axi_rdata       ( s_axi_rdata    ),
    .s_axi_rresp       ( s_axi_rresp    ),
    .s_axi_rlast       ( s_axi_rlast    ),
    .s_axi_rvalid      ( s_axi_rvalid   ),
    .s_axi_rready      ( s_axi_rready   )
);

// outports wire
wire            task_start;
wire            task_finish;
wire            calculate_start;
wire            calculate_finish;
wire            axi_stream_tvalid;
wire  [31:0]    axi_stream_tdata ;
wire  [3:0]     axi_stream_tkeep ;
wire            axi_stream_tlast ;
reg             axi_stream_tready;
wire            axi_stream_tuser ;

accelerator_control u_accelerator_control(
    .system_clk                   ( system_clk      ),
    .system_rst_n                 ( rst_n           ),
    .m00_axi_araddr               ( s_axi_araddr    ),
    .m00_axi_arlen                ( s_axi_arlen     ),
    .m00_axi_arsize               ( s_axi_arsize    ),
    .m00_axi_arburst              ( s_axi_arburst   ),
    .m00_axi_arlock               ( s_axi_arlock    ),
    .m00_axi_arcache              ( s_axi_arcache   ),
    .m00_axi_arprot               ( s_axi_arprot    ),
    .m00_axi_arqos                (                 ),
    .m00_axi_arvalid              ( s_axi_arvalid   ),
    .m00_axi_arready              ( s_axi_arready   ),
    .m00_axi_rdata                ( s_axi_rdata     ),
    .m00_axi_rresp                ( s_axi_rresp     ),
    .m00_axi_rlast                ( s_axi_rlast     ),
    .m00_axi_rvalid               ( s_axi_rvalid    ),
    .m00_axi_rready               ( s_axi_rready    ),
    .m00_axi_awaddr               ( s_axi_awaddr    ),
    .m00_axi_awlen                ( s_axi_awlen     ),
    .m00_axi_awsize               ( s_axi_awsize    ),
    .m00_axi_awburst              ( s_axi_awburst   ),
    .m00_axi_awlock               ( s_axi_awlock    ),
    .m00_axi_awcache              ( s_axi_awcache   ),
    .m00_axi_awprot               ( s_axi_awprot    ),
    .m00_axi_awqos                (                 ),
    .m00_axi_awvalid              ( s_axi_awvalid   ),
    .m00_axi_awready              ( s_axi_awready   ),
    .m00_axi_wdata                ( s_axi_wdata     ),
    .m00_axi_wstrb                ( s_axi_wstrb     ),
    .m00_axi_wlast                ( s_axi_wlast     ),
    .m00_axi_wvalid               ( s_axi_wvalid    ),
    .m00_axi_wready               ( s_axi_wready    ),
    .m00_axi_bresp                ( s_axi_bresp     ),
    .m00_axi_bvalid               ( s_axi_bvalid    ),
    .m00_axi_bready               ( s_axi_bready    ),
    .s00_axi_aclk                 ( m_axi_aclk      ),
    .s00_axi_aresetn              ( m_axi_aresetn   ),
    .s00_axi_awaddr               ( m_axi_awaddr    ),
    .s00_axi_awprot               ( m_axi_awprot    ),
    .s00_axi_awvalid              ( m_axi_awvalid   ),
    .s00_axi_awready              ( m_axi_awready   ),
    .s00_axi_wdata                ( m_axi_wdata     ),
    .s00_axi_wstrb                ( m_axi_wstrb     ),
    .s00_axi_wvalid               ( m_axi_wvalid    ),
    .s00_axi_wready               ( m_axi_wready    ),
    .s00_axi_bresp                ( m_axi_bresp     ),
    .s00_axi_bvalid               ( m_axi_bvalid    ),
    .s00_axi_bready               ( m_axi_bready    ),
    .s00_axi_araddr               ( m_axi_araddr    ),
    .s00_axi_arprot               ( m_axi_arprot    ),
    .s00_axi_arvalid              ( m_axi_arvalid   ),
    .s00_axi_arready              ( m_axi_arready   ),
    .s00_axi_rdata                ( m_axi_rdata     ),
    .s00_axi_rresp                ( m_axi_rresp     ),
    .s00_axi_rvalid               ( m_axi_rvalid    ),
    .s00_axi_rready               ( m_axi_rready    ),

    .axi_stream_tvalid            ( axi_stream_tvalid ), 
    .axi_stream_tdata             ( axi_stream_tdata  ),
    .axi_stream_tkeep             ( axi_stream_tkeep  ),
    .axi_stream_tlast             ( axi_stream_tlast  ),
    .axi_stream_tready            (axi_stream_tready  ),
    .axi_stream_tuser             ( axi_stream_tuser  )
);

always @(posedge system_clk) begin
    // if ($random % (100 + 1) < 50) begin
        axi_stream_tready <= 1;
    // end
    // else begin
    //     axi_stream_tready <= 0;
    // end
end

make_order make_order_inst(
    .m00_axi_aclk       ( m_axi_aclk    ),
    .m00_axi_aresetn    ( m_axi_aresetn ),
    .m00_axi_awaddr     ( m_axi_awaddr  ),
    .m00_axi_awprot     ( m_axi_awprot  ),
    .m00_axi_awvalid    ( m_axi_awvalid ),
    .m00_axi_awready    ( m_axi_awready ),
    .m00_axi_wdata      ( m_axi_wdata   ),
    .m00_axi_wstrb      ( m_axi_wstrb   ),
    .m00_axi_wvalid     ( m_axi_wvalid  ),
    .m00_axi_wready     ( m_axi_wready  ),
    .m00_axi_bresp      ( m_axi_bresp   ),
    .m00_axi_bvalid     ( m_axi_bvalid  ),
    .m00_axi_bready     ( m_axi_bready  ),
    .m00_axi_araddr     ( m_axi_araddr  ),
    .m00_axi_arprot     ( m_axi_arprot  ),
    .m00_axi_arvalid    ( m_axi_arvalid ),
    .m00_axi_arready    ( m_axi_arready ),
    .m00_axi_rdata      ( m_axi_rdata   ),
    .m00_axi_rresp      ( m_axi_rresp   ),
    .m00_axi_rvalid     ( m_axi_rvalid  ),
    .m00_axi_rready     ( m_axi_rready  )
);

integer i, d, times;

initial begin
	d = 0;
end

always @(posedge system_clk) begin
    if (u_accelerator_control.get_order_inst.next_calculate_application)begin
        for (i=0;i<u_accelerator_control.return_patch_num*u_accelerator_control.feature_output_patch_num*64;i=i+1)begin
            $fwrite(u_axi_ram.out_file, "%h\n", u_axi_ram.mem[(u_accelerator_control.return_addr/64)+i]);
        end
        $fwrite(u_axi_ram.out_file, "#%d\n", u_accelerator_control.get_order_inst.id);

        $display("the %d layer simulation is finish", u_accelerator_control.get_order_inst.id);
        $display("Using time: %d us", (($time - times) / 10000000));
        times = $time;
    end
    else if (u_accelerator_control.get_order_inst.calculate_start & d == 0) begin
        for (i=0;i<u_accelerator_control.feature_input_patch_num*u_accelerator_control.feature_patch_num*64;i=i+1)begin
            $fwrite(u_axi_ram.out_file, "%h\n", u_axi_ram.mem[(u_accelerator_control.feature_input_base_addr/64)+i]);
        end
        $fwrite(u_axi_ram.out_file, "#%d\n", u_accelerator_control.get_order_inst.id);
        d = 1;
    end 

    if (u_accelerator_control.get_order_inst.Cache_order_inst.order==5) begin
        if (u_axi_ram.file != 0) begin
            $writememh(u_axi_ram.memory_patch, u_axi_ram.mem);
            $fclose(u_axi_ram.file);
            $fclose(u_axi_ram.out_file);
            $fclose(video_file);
            u_axi_ram.file = 0;
            $stop;
        end
    end
end


integer video_file;
initial begin
    video_file = $fopen("../compile/simulation_data/video.txt", "w");
end

always@(posedge system_clk) begin
    if (axi_stream_tvalid & axi_stream_tready & axi_stream_tlast) begin
        $fwrite(video_file, "%h\n", axi_stream_tdata);
        $fwrite(video_file, "enter\n");
    end
    else if (axi_stream_tvalid & axi_stream_tready) begin
        $fwrite(video_file, "%h\n", axi_stream_tdata);
    end
end


endmodule