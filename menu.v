module menu_select(
        input clk,
        input [31:0] lin,
        input [31:0] tim,
        input [31:0] tim_reg,
        input [15:0] distance,
        input select,
        output [31:0] selected,
        output [2:0] menu_show
    );
    
        reg [2:0] mu=3'b001;
        assign menu_show=mu;

        reg [31:0] current_show;
        assign selected=current_show;   

        always @(posedge select)
        begin
            mu<={mu[1:0],mu[2]};//{}位拼接运算符，实现了001，010，100三种模式的切换；
//四种模式的话
//mu<={mu[2:0],mu[3]};
        always @(posedge clk)
        begin
            case(mu)
                3'b001://第一种模式显示时间
                begin
                    //黑线数小于11显示实时时间，大于11显示全过程时间；
                    if(lin>=11)
                        current_show<=tim_reg;
                    else
                        current_show<=tim;
                end
                3'b010:current_show<=lin;//第二种模式显示线的数量
                3'b100:current_show<=distance;//第三种模式显示距离
                default:current_show<=tim;
            endcase
        end

endmodule
