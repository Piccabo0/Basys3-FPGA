//7段数码管 共阳极
module seg_decoder(
        input [3:0] val,//选择哪个数码管显示？
        output [7:0] out//显示的数字是几？此脚引至数码管      
);
reg [7:0] code;
assign out=code;//输出就是八位的二进制01数组

always@(val)
begin
        case(val)
        4'd0:code=8'b0111_1110
        4'd1:code=8'b0011_0000
        4'd2:code=8'b0110_1101
        4'd3:code=8'b0111_1001
        4'd4:code=8'b0011_0011
        4'd5:code=8'b0101_1011
        4'd6:code=8'b0101_1111
        4'd7:code=8'b0111_0000
        4'd8:code=8'b0111_1111
        4'd9:code=8'b0111_1011
        default:code=8'b01111111;
        endcase
end
endmodule
