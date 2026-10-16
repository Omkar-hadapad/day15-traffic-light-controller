`timescale 1ns/1ps

//==============================================================
// DAY 15 - TRAFFIC LIGHT CONTROLLER
//
// FSM:
// S0 -> North-South GREEN
// S1 -> North-South YELLOW
// S2 -> ALL RED
// S3 -> East-West GREEN
// S4 -> East-West YELLOW
// S5 -> ALL RED 
//
// STATE_TIME = 4 clock cycles
//
// Hierarchy:
// Gates
//   ↓
// Comparator
//   ↓
// DFF
//   ↓
// Timer Counter
//   ↓
// FSM
//   ↓
// Output Decoder
//   ↓
// Structural Controller
//   ↓
// RTL Controller
//   ↓
// Top
//==============================================================


//==============================================================
// LEVEL 1 : BASIC GATES
//==============================================================

module not_gate(
    input A,
    output Y
);
    assign Y = ~A;
endmodule


module and_gate(
    input A,
    input B,
    output Y
);
    assign Y = A & B;
endmodule


module or_gate(
    input A,
    input B,
    output Y
);
    assign Y = A | B;
endmodule


module xor_gate(
    input A,
    input B,
    output Y
);
    assign Y = A ^ B;
endmodule


//==============================================================
// LEVEL 2 : 3-BIT EQUALITY COMPARATOR
//==============================================================

module equality_3bit(
    input [2:0] A,
    input [2:0] B,
    output equal
);

    wire X0;
    wire X1;
    wire X2;

    wire N0;
    wire N1;
    wire N2;

    wire E01;

    xor_gate XG0(
        .A(A[0]),
        .B(B[0]),
        .Y(X0)
    );

    xor_gate XG1(
        .A(A[1]),
        .B(B[1]),
        .Y(X1)
    );

    xor_gate XG2(
        .A(A[2]),
        .B(B[2]),
        .Y(X2)
    );

    not_gate NG0(
        .A(X0),
        .Y(N0)
    );

    not_gate NG1(
        .A(X1),
        .Y(N1)
    );

    not_gate NG2(
        .A(X2),
        .Y(N2)
    );

    and_gate AG0(
        .A(N0),
        .B(N1),
        .Y(E01)
    );

    and_gate AG1(
        .A(E01),
        .B(N2),
        .Y(equal)
    );

endmodule


//==============================================================
// LEVEL 3 : D FLIP-FLOP WITH SYNCHRONOUS RESET
//==============================================================

module dff_sync_reset(
    input clk,
    input reset,
    input D,
    output reg Q
);

    always @(posedge clk)
    begin
        if(reset)
            Q <= 1'b0;
        else
            Q <= D;
    end

endmodule


//==============================================================
// LEVEL 4 : 3-BIT TIMER COUNTER
//
// Counts:
//
// 0 -> 1 -> 2 -> 3 -> 0
//
// timer_done = 1 when count = 3
//==============================================================

module timer_counter_3bit(
    input clk,
    input reset,
    output [2:0] count
);

    wire [2:0] next_count;

    assign next_count =
        (count == 3'd3) ? 3'd0 :
                          count + 3'd1;

    dff_sync_reset FF0(
        .clk(clk),
        .reset(reset),
        .D(next_count[0]),
        .Q(count[0])
    );

    dff_sync_reset FF1(
        .clk(clk),
        .reset(reset),
        .D(next_count[1]),
        .Q(count[1])
    );

    dff_sync_reset FF2(
        .clk(clk),
        .reset(reset),
        .D(next_count[2]),
        .Q(count[2])
    );

endmodule


//==============================================================
// LEVEL 5 : TIMER DONE
//
// count:
// 0 -> not done
// 1 -> not done
// 2 -> not done
// 3 -> DONE
//==============================================================

module timer_done_logic(
    input [2:0] count,
    output done
);

    wire B0;
    wire B1;
    wire B2;

    wire E01;

    // Detect 3'b011

    not_gate N0(
        .A(count[2]),
        .Y(B2)
    );

    and_gate A0(
        .A(count[0]),
        .B(count[1]),
        .Y(E01)
    );

    and_gate A1(
        .A(E01),
        .B(B2),
        .Y(done)
    );

endmodule


//==============================================================
// LEVEL 6 : FSM NEXT-STATE LOGIC
//
// S0 = 000
// S1 = 001
// S2 = 010
// S3 = 011
// S4 = 100
// S5 = 101
//
// done = 0 -> stay
// done = 1 -> next state
//==============================================================

module traffic_next_state(
    input [2:0] state,
    input done,
    output reg [2:0] next_state
);

    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    localparam S5 = 3'b101;

    always @(*)
    begin

        next_state = S0;

        case(state)

            S0:
            begin
                if(done)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1:
            begin
                if(done)
                    next_state = S2;
                else
                    next_state = S1;
            end

            S2:
            begin
                if(done)
                    next_state = S3;
                else
                    next_state = S2;
            end

            S3:
            begin
                if(done)
                    next_state = S4;
                else
                    next_state = S3;
            end

            S4:
            begin
                if(done)
                    next_state = S5;
                else
                    next_state = S4;
            end

            S5:
            begin
                if(done)
                    next_state = S0;
                else
                    next_state = S5;
            end

            default:
                next_state = S0;

        endcase

    end

endmodule


//==============================================================
// LEVEL 7 : FSM STATE REGISTER
//==============================================================

module traffic_state_register(
    input clk,
    input reset,
    input [2:0] next_state,
    output [2:0] state
);

    dff_sync_reset FF0(
        .clk(clk),
        .reset(reset),
        .D(next_state[0]),
        .Q(state[0])
    );

    dff_sync_reset FF1(
        .clk(clk),
        .reset(reset),
        .D(next_state[1]),
        .Q(state[1])
    );

    dff_sync_reset FF2(
        .clk(clk),
        .reset(reset),
        .D(next_state[2]),
        .Q(state[2])
    );

endmodule


//==============================================================
// LEVEL 8 : TRAFFIC LIGHT OUTPUT DECODER
//
// S0 : NS GREEN  / EW RED
// S1 : NS YELLOW / EW RED
// S2 : ALL RED    / ALL RED
// S3 : NS RED    / EW GREEN
// S4 : NS RED    / EW YELLOW
// S5 : ALL RED    / ALL RED
//==============================================================

module traffic_output_decoder(
    input [2:0] state,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green
);

    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    localparam S5 = 3'b101;

    always @(*)
    begin

        // Default = ALL RED
        ns_red    = 1'b1;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;

        ew_red    = 1'b1;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;

        case(state)

            // NS GREEN / EW RED
            S0:
            begin
                ns_red   = 1'b0;
                ns_green = 1'b1;

                ew_red   = 1'b1;
            end

            // NS YELLOW / EW RED
            S1:
            begin
                ns_red    = 1'b0;
                ns_yellow = 1'b1;

                ew_red    = 1'b1;
            end

            // ALL RED
            S2:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            // NS RED / EW GREEN
            S3:
            begin
                ns_red   = 1'b1;

                ew_red   = 1'b0;
                ew_green = 1'b1;
            end

            // NS RED / EW YELLOW
            S4:
            begin
                ns_red    = 1'b1;

                ew_red    = 1'b0;
                ew_yellow = 1'b1;
            end

            // ALL RED
            S5:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            default:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

        endcase

    end

endmodule


//==============================================================
// LEVEL 9 : STRUCTURAL TRAFFIC CONTROLLER
//==============================================================

module traffic_light_controller_structural(
    input clk,
    input reset,

    output ns_red,
    output ns_yellow,
    output ns_green,

    output ew_red,
    output ew_yellow,
    output ew_green,

    output [2:0] timer_count,
    output timer_done,

    output [2:0] state,
    output [2:0] next_state
);

    //==========================================================
    // TIMER
    //==========================================================

    timer_counter_3bit TIMER(
        .clk(clk),
        .reset(reset),
        .count(timer_count)
    );


    timer_done_logic DONE(
        .count(timer_count),
        .done(timer_done)
    );


    //==========================================================
    // FSM NEXT STATE
    //==========================================================

    traffic_next_state NEXT(
        .state(state),
        .done(timer_done),
        .next_state(next_state)
    );


    //==========================================================
    // STATE REGISTER
    //==========================================================

    traffic_state_register STATE(
        .clk(clk),
        .reset(reset),
        .next_state(next_state),
        .state(state)
    );


    //==========================================================
    // OUTPUT DECODER
    //==========================================================

    traffic_output_decoder OUTPUT(
        .state(state),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );

endmodule


//==============================================================
// LEVEL 10 : BEHAVIORAL RTL TRAFFIC CONTROLLER
//==============================================================

module traffic_light_controller_rtl(
    input clk,
    input reset,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green
);

    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    localparam S5 = 3'b101;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [2:0] timer_count;
    wire timer_done;

    assign timer_done = (timer_count == 3'd3);


    //==========================================================
    // TIMER
    //==========================================================

    always @(posedge clk)
    begin
        if(reset)
            timer_count <= 3'd0;

        else if(timer_done)
            timer_count <= 3'd0;

        else
            timer_count <= timer_count + 3'd1;
    end


    //==========================================================
    // STATE REGISTER
    //==========================================================

    always @(posedge clk)
    begin
        if(reset)
            state <= S0;

        else
            state <= next_state;
    end


    //==========================================================
    // NEXT-STATE LOGIC
    //==========================================================

    always @(*)
    begin

        next_state = S0;

        case(state)

            S0:
            begin
                if(timer_done)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1:
            begin
                if(timer_done)
                    next_state = S2;
                else
                    next_state = S1;
            end

            S2:
            begin
                if(timer_done)
                    next_state = S3;
                else
                    next_state = S2;
            end

            S3:
            begin
                if(timer_done)
                    next_state = S4;
                else
                    next_state = S3;
            end

            S4:
            begin
                if(timer_done)
                    next_state = S5;
                else
                    next_state = S4;
            end

            S5:
            begin
                if(timer_done)
                    next_state = S0;
                else
                    next_state = S5;
            end

            default:
                next_state = S0;

        endcase

    end


    //==========================================================
    // OUTPUT LOGIC
    //==========================================================

    always @(*)
    begin

        // Default = ALL RED
        ns_red    = 1'b1;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;

        ew_red    = 1'b1;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;

        case(state)

            // NS GREEN / EW RED
            S0:
            begin
                ns_red   = 1'b0;
                ns_green = 1'b1;

                ew_red   = 1'b1;
            end

            // NS YELLOW / EW RED
            S1:
            begin
                ns_red    = 1'b0;
                ns_yellow = 1'b1;

                ew_red    = 1'b1;
            end

            // ALL RED
            S2:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            // NS RED / EW GREEN
            S3:
            begin
                ns_red   = 1'b1;

                ew_red   = 1'b0;
                ew_green = 1'b1;
            end

            // NS RED / EW YELLOW
            S4:
            begin
                ns_red    = 1'b1;

                ew_red    = 1'b0;
                ew_yellow = 1'b1;
            end

            // ALL RED
            S5:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            default:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

        endcase

    end

endmodule


//==============================================================
// LEVEL 11 : TOP MODULE
//==============================================================

module traffic_light_controller_top(
    input clk,
    input reset,

    output ns_red,
    output ns_yellow,
    output ns_green,

    output ew_red,
    output ew_yellow,
    output ew_green
);

    wire ns_red_struct;
    wire ns_yellow_struct;
    wire ns_green_struct;

    wire ew_red_struct;
    wire ew_yellow_struct;
    wire ew_green_struct;

    wire [2:0] timer_count;
    wire timer_done;

    wire [2:0] state;
    wire [2:0] next_state;


    traffic_light_controller_structural STRUCTURAL(
        .clk(clk),
        .reset(reset),

        .ns_red(ns_red_struct),
        .ns_yellow(ns_yellow_struct),
        .ns_green(ns_green_struct),

        .ew_red(ew_red_struct),
        .ew_yellow(ew_yellow_struct),
        .ew_green(ew_green_struct),

        .timer_count(timer_count),
        .timer_done(timer_done),

        .state(state),
        .next_state(next_state)
    );


    // Top outputs are driven by structural implementation.

    assign ns_red    = ns_red_struct;
    assign ns_yellow = ns_yellow_struct;
    assign ns_green  = ns_green_struct;

    assign ew_red    = ew_red_struct;
    assign ew_yellow = ew_yellow_struct;
    assign ew_green  = ew_green_struct;

endmodule