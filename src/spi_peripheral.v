`default_nettype none
module spi_peripheral(
    input wire clk,
    input wire rst_n,
    input wire sclk,
    input wire copi,
    input wire ncs,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);
    reg sclk_ff1, sclk_ff2;
    reg copi_ff1, copi_ff2;
    reg ncs_ff1, ncs_ff2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_ff1 <= 1'b0; sclk_ff2 <= 1'b0;
            copi_ff1 <= 1'b0; copi_ff2 <= 1'b0;
            ncs_ff1 <= 1'b1; ncs_ff2 <= 1'b1;
        end else begin
            sclk_ff1 <= sclk; sclk_ff2 <= sclk_ff1;
            copi_ff1 <= copi; copi_ff2 <= copi_ff1;
            ncs_ff1 <= ncs; ncs_ff2 <= ncs_ff1;
        end
    end 

    wire sclk_sync = sclk_ff2;
    wire copi_sync = copi_ff2;
    wire ncs_sync = ncs_ff2;
    reg sclk_prev;
    reg ncs_prev;

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_prev <= 1'b0;
            ncs_prev <= 1'b1;
        end else begin
            sclk_prev <= sclk_sync;
            ncs_prev <= ncs_sync;
        end
    end 

    wire sclk_rising = (sclk_sync == 1'b1) && (sclk_prev == 1'b0);    
    wire ncs_falling = (ncs_sync == 1'b0) && (ncs_prev == 1'b1);
    wire ncs_rising = (ncs_sync == 1'b1) && (ncs_prev == 1'b0);

    reg rw_bit;
    reg [6:0] address_shift;
    reg [7:0] data_shift;
    reg [3:0] bit_count;
    reg transaction_valid;
    localparam MAX_ADDRESS = 7'h04;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            en_reg_out_7_0 <= 8'h00;
            en_reg_out_15_8 <= 8'h00;
            en_reg_pwm_7_0 <= 8'h00;
            en_reg_pwm_15_8 <= 8'h00;
            pwm_duty_cycle <= 8'h00;
            rw_bit <= 1'b0;
            address_shift <= 7'h00;
            data_shift <= 8'h00;
            bit_count <= 4'd0;
            transaction_valid <= 1'b0;
        end else if (ncs_falling) begin
            bit_count <= 4'd0;
            rw_bit <= 1'b0;
            address_shift <= 7'h00;
            data_shift <= 8'h00;
            transaction_valid <= 1'b0;
        end else if (sclk_rising && !ncs_sync) begin
            if (bit_count == 4'd0) begin
                rw_bit <= copi_sync;
            end else if (bit_count <= 4'd7) begin
                address_shift <= {address_shift[5:0], copi_sync};
            end else begin 
                data_shift <= {data_shift[6:0], copi_sync};
            end
            bit_count <= bit_count + 4'd1;
        end else if (ncs_rising) begin
                if (rw_bit == 1'b1 && address_shift <= MAX_ADDRESS) begin
                    case (address_shift)
                    7'h00: en_reg_out_7_0 <= data_shift;
                    7'h01: en_reg_out_15_8 <= data_shift;
                    7'h02: en_reg_pwm_7_0 <= data_shift;
                    7'h03: en_reg_pwm_15_8 <= data_shift;
                    7'h04: pwm_duty_cycle <= data_shift;
                    default: ;
                    endcase
                end
            end
        end        
endmodule


