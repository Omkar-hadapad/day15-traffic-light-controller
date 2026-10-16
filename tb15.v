`timescale 1ns/1ps 

//==============================================================
// DAY 15 - REALISTIC TRAFFIC LIGHT CONTROLLER
// SELF-CHECKING VERIFICATION TESTBENCH
//
// FSM:
//
// S0 -> NS GREEN  / EW RED
// S1 -> NS YELLOW / EW RED
// S2 -> NS RED    / EW RED
// S3 -> NS RED    / EW GREEN
// S4 -> NS RED    / EW YELLOW
// S5 -> NS RED    / EW RED
//
// TIMER:
//
// 0 -> 1 -> 2 -> 3 -> 0
//
// STATE TIME = 4 CLOCK CYCLES
//
// HIERARCHY:
//
// Gates
//   ↓
// Comparator
//   ↓
// DFF
//   ↓
// Timer Counter
//   ↓
// Timer DONE
//   ↓
// FSM Next-State
//   ↓
// Output Decoder
//   ↓
// Structural Controller
//   ↓
// RTL Controller
//   ↓
// Reference Model
//   ↓
// Safety / Reset / Invalid-State Verification
//
//==============================================================


module day15_tb;


    integer pass_count;
    integer fail_count;
    integer i;


    //==========================================================
    // CLOCK / RESET
    //==========================================================

    reg clk;
    reg reset;


    initial
    begin

        clk = 1'b0;

        forever
            #5 clk = ~clk;

    end


    //==========================================================
    // FSM STATE DEFINITIONS
    //==========================================================

    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    localparam S5 = 3'b101;


    //==========================================================
    // BASIC GATES
    //==========================================================

    reg A;
    reg B;

    wire not_y;
    wire and_y;
    wire or_y;
    wire xor_y;


    not_gate U_NOT
    (
        .A(A),
        .Y(not_y)
    );


    and_gate U_AND
    (
        .A(A),
        .B(B),
        .Y(and_y)
    );


    or_gate U_OR
    (
        .A(A),
        .B(B),
        .Y(or_y)
    );


    xor_gate U_XOR
    (
        .A(A),
        .B(B),
        .Y(xor_y)
    );


    //==========================================================
    // 3-BIT EQUALITY COMPARATOR
    //==========================================================

    reg [2:0] comp_A;
    reg [2:0] comp_B;

    wire comp_equal;


    equality_3bit COMP
    (
        .A(comp_A),
        .B(comp_B),
        .equal(comp_equal)
    );


    //==========================================================
    // DFF
    //==========================================================

    reg dff_D;
    wire dff_Q;


    dff_sync_reset DFF
    (
        .clk(clk),
        .reset(reset),
        .D(dff_D),
        .Q(dff_Q)
    );


    //==========================================================
    // TIMER COUNTER
    //==========================================================

    wire [2:0] timer_count;
    wire timer_done;


    timer_counter_3bit TIMER
    (
        .clk(clk),
        .reset(reset),
        .count(timer_count)
    );


    //==========================================================
    // TIMER DONE LOGIC
    //==========================================================

    timer_done_logic DONE
    (
        .count(timer_count),
        .done(timer_done)
    );


    //==========================================================
    // FSM NEXT-STATE LOGIC
    //
    // 3-BIT STATE
    //
    // S0 -> S1 -> S2 -> S3 -> S4 -> S5 -> S0
    //==========================================================

    reg [2:0] test_state;
    reg test_done;

    wire [2:0] test_next_state;


    traffic_next_state NEXT
    (
        .state(test_state),
        .done(test_done),
        .next_state(test_next_state)
    );


    //==========================================================
    // OUTPUT DECODER
    //==========================================================

    reg [2:0] output_state;

    wire ns_red;
    wire ns_yellow;
    wire ns_green;

    wire ew_red;
    wire ew_yellow;
    wire ew_green;


    //==========================================================
    // WAVEFORM TRAFFIC LIGHT LABELS
    //
    // NS_LIGHT / EW_LIGHT:
    //
    // 00 = RED
    // 01 = YELLOW
    // 10 = GREEN
    //==========================================================

    reg [1:0] NS_LIGHT;
    reg [1:0] EW_LIGHT;

    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;


    always @(*)
    begin

        //======================================================
        // NORTH-SOUTH LIGHT
        //======================================================

        if(ns_red)
            NS_LIGHT = RED;

        else if(ns_yellow)
            NS_LIGHT = YELLOW;

        else if(ns_green)
            NS_LIGHT = GREEN;

        else
            NS_LIGHT = RED;


        //======================================================
        // EAST-WEST LIGHT
        //======================================================

        if(ew_red)
            EW_LIGHT = RED;

        else if(ew_yellow)
            EW_LIGHT = YELLOW;

        else if(ew_green)
            EW_LIGHT = GREEN;

        else
            EW_LIGHT = RED;

    end


    traffic_output_decoder OUTPUT
    (
        .state(output_state),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );


    //==========================================================
    // COMPLETE STRUCTURAL DUT
    //==========================================================

    wire s_ns_red;
    wire s_ns_yellow;
    wire s_ns_green;

    wire s_ew_red;
    wire s_ew_yellow;
    wire s_ew_green;

    wire [2:0] s_timer_count;
    wire s_timer_done;

    wire [2:0] s_state;
    wire [2:0] s_next_state;


    traffic_light_controller_structural STRUCT_DUT
    (
        .clk(clk),
        .reset(reset),

        .ns_red(s_ns_red),
        .ns_yellow(s_ns_yellow),
        .ns_green(s_ns_green),

        .ew_red(s_ew_red),
        .ew_yellow(s_ew_yellow),
        .ew_green(s_ew_green),

        .timer_count(s_timer_count),
        .timer_done(s_timer_done),

        .state(s_state),
        .next_state(s_next_state)
    );


    //==========================================================
    // COMPLETE RTL DUT
    //==========================================================

    wire r_ns_red;
    wire r_ns_yellow;
    wire r_ns_green;

    wire r_ew_red;
    wire r_ew_yellow;
    wire r_ew_green;


    traffic_light_controller_rtl RTL_DUT
    (
        .clk(clk),
        .reset(reset),

        .ns_red(r_ns_red),
        .ns_yellow(r_ns_yellow),
        .ns_green(r_ns_green),

        .ew_red(r_ew_red),
        .ew_yellow(r_ew_yellow),
        .ew_green(r_ew_green)
    );


    //==========================================================
    // REFERENCE MODEL
    //==========================================================

    reg [2:0] ref_state;
    reg [2:0] ref_timer;

    reg [2:0] ref_next_state;
    reg [2:0] ref_next_timer;

    reg ref_done;


    //==========================================================
    // REFERENCE OUTPUTS
    //==========================================================

    reg ref_ns_red;
    reg ref_ns_yellow;
    reg ref_ns_green;

    reg ref_ew_red;
    reg ref_ew_yellow;
    reg ref_ew_green;


    //==========================================================
    // VCD
    //==========================================================

    initial
    begin

        $dumpfile("day15_traffic_light.vcd");

        $dumpvars(0, day15_tb);

    end


    //==========================================================
    // 1-BIT CHECK
    //==========================================================

    task check_1bit;

        input actual;
        input expected;
        input [200:0] message;

        begin

            if(actual === expected)
            begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %s | Expected=%b Actual=%b",
                    message,
                    expected,
                    actual
                );

            end

            else
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %s | Expected=%b Actual=%b",
                    message,
                    expected,
                    actual
                );

            end

        end

    endtask


    //==========================================================
    // 3-BIT CHECK
    //==========================================================

    task check_3bit;

        input [2:0] actual;
        input [2:0] expected;
        input [200:0] message;

        begin

            if(actual === expected)
            begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %s | Expected=%03b Actual=%03b",
                    message,
                    expected,
                    actual
                );

            end

            else
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %s | Expected=%03b Actual=%03b",
                    message,
                    expected,
                    actual
                );

            end

        end

    endtask


    //==========================================================
    // REFERENCE NEXT STATE
    //==========================================================

    function [2:0] reference_next_state;

        input [2:0] state;
        input done;

        begin

            case(state)

                S0:
                begin

                    if(done)
                        reference_next_state = S1;
                    else
                        reference_next_state = S0;

                end


                S1:
                begin

                    if(done)
                        reference_next_state = S2;
                    else
                        reference_next_state = S1;

                end


                S2:
                begin

                    if(done)
                        reference_next_state = S3;
                    else
                        reference_next_state = S2;

                end


                S3:
                begin

                    if(done)
                        reference_next_state = S4;
                    else
                        reference_next_state = S3;

                end


                S4:
                begin

                    if(done)
                        reference_next_state = S5;
                    else
                        reference_next_state = S4;

                end


                S5:
                begin

                    if(done)
                        reference_next_state = S0;
                    else
                        reference_next_state = S5;

                end


                default:
                begin

                    reference_next_state = S0;

                end

            endcase

        end

    endfunction


    //==========================================================
    // REFERENCE TIMER NEXT
    //==========================================================

    function [2:0] reference_timer_next;

        input [2:0] count;

        begin

            if(count == 3'd3)
                reference_timer_next = 3'd0;

            else
                reference_timer_next = count + 3'd1;

        end

    endfunction


    //==========================================================
    // REFERENCE OUTPUT DECODER
    //==========================================================

    task calculate_reference_outputs;

        input [2:0] state;

        begin

            // Safe defaults

            ref_ns_red    = 1'b0;
            ref_ns_yellow = 1'b0;
            ref_ns_green  = 1'b0;

            ref_ew_red    = 1'b0;
            ref_ew_yellow = 1'b0;
            ref_ew_green  = 1'b0;


            case(state)

                //================================================
                // S0
                // NS GREEN / EW RED
                //================================================

                S0:
                begin

                    ref_ns_green = 1'b1;
                    ref_ew_red   = 1'b1;

                end


                //================================================
                // S1
                // NS YELLOW / EW RED
                //================================================

                S1:
                begin

                    ref_ns_yellow = 1'b1;
                    ref_ew_red    = 1'b1;

                end


                //================================================
                // S2
                // ALL RED
                //================================================

                S2:
                begin

                    ref_ns_red = 1'b1;
                    ref_ew_red = 1'b1;

                end


                //================================================
                // S3
                // NS RED / EW GREEN
                //================================================

                S3:
                begin

                    ref_ns_red   = 1'b1;
                    ref_ew_green = 1'b1;

                end


                //================================================
                // S4
                // NS RED / EW YELLOW
                //================================================

                S4:
                begin

                    ref_ns_red    = 1'b1;
                    ref_ew_yellow = 1'b1;

                end


                //================================================
                // S5
                // ALL RED
                //================================================

                S5:
                begin

                    ref_ns_red = 1'b1;
                    ref_ew_red = 1'b1;

                end


                //================================================
                // INVALID STATE
                //================================================

                default:
                begin

                    ref_ns_red = 1'b1;
                    ref_ew_red = 1'b1;

                end

            endcase

        end

    endtask


    //==========================================================
    // RESET REFERENCE MODEL
    //==========================================================

    task reset_reference_model;

        begin

            ref_state = S0;

            ref_timer = 3'd0;

            ref_done = 1'b0;

            ref_next_state = S0;

            ref_next_timer = 3'd0;

            calculate_reference_outputs(S0);

        end

    endtask


    //==========================================================
    // UPDATE REFERENCE MODEL
    //==========================================================

    task update_reference_model;

        begin

            //==================================================
            // CURRENT TIMER DONE
            //==================================================

            if(ref_timer == 3'd3)
                ref_done = 1'b1;
            else
                ref_done = 1'b0;


            //==================================================
            // FSM NEXT STATE
            //==================================================

            ref_next_state =
                reference_next_state(
                    ref_state,
                    ref_done
                );


            //==================================================
            // TIMER NEXT
            //==================================================

            ref_next_timer =
                reference_timer_next(
                    ref_timer
                );


            //==================================================
            // UPDATE STATE
            //==================================================

            ref_state = ref_next_state;


            //==================================================
            // UPDATE TIMER
            //==================================================

            ref_timer = ref_next_timer;


            //==================================================
            // NEW TIMER DONE
            //==================================================

            if(ref_timer == 3'd3)
                ref_done = 1'b1;
            else
                ref_done = 1'b0;


            //==================================================
            // NEW NEXT STATE
            //==================================================

            ref_next_state =
                reference_next_state(
                    ref_state,
                    ref_done
                );


            //==================================================
            // REFERENCE OUTPUTS
            //==================================================

            calculate_reference_outputs(ref_state);

        end

    endtask


    //==========================================================
    // COMPLETE REFERENCE CHECK
    //==========================================================

    task check_complete_reference;

        begin

            check_3bit(
                s_state,
                ref_state,
                "Reference vs Structural STATE"
            );


            check_3bit(
                s_timer_count,
                ref_timer,
                "Reference vs Structural TIMER"
            );


            check_1bit(
                s_timer_done,
                ref_done,
                "Reference vs Structural DONE"
            );


            check_3bit(
                s_next_state,
                ref_next_state,
                "Reference vs Structural NEXT STATE"
            );


            check_1bit(
                s_ns_red,
                ref_ns_red,
                "Reference vs Structural NS RED"
            );


            check_1bit(
                s_ns_yellow,
                ref_ns_yellow,
                "Reference vs Structural NS YELLOW"
            );


            check_1bit(
                s_ns_green,
                ref_ns_green,
                "Reference vs Structural NS GREEN"
            );


            check_1bit(
                s_ew_red,
                ref_ew_red,
                "Reference vs Structural EW RED"
            );


            check_1bit(
                s_ew_yellow,
                ref_ew_yellow,
                "Reference vs Structural EW YELLOW"
            );


            check_1bit(
                s_ew_green,
                ref_ew_green,
                "Reference vs Structural EW GREEN"
            );

        end

    endtask


    //==========================================================
    // STRUCTURAL VS RTL
    //==========================================================

    task compare_structural_rtl;

        begin

            check_1bit(
                s_ns_red,
                r_ns_red,
                "Structural vs RTL NS RED"
            );

            check_1bit(
                s_ns_yellow,
                r_ns_yellow,
                "Structural vs RTL NS YELLOW"
            );

            check_1bit(
                s_ns_green,
                r_ns_green,
                "Structural vs RTL NS GREEN"
            );

            check_1bit(
                s_ew_red,
                r_ew_red,
                "Structural vs RTL EW RED"
            );

            check_1bit(
                s_ew_yellow,
                r_ew_yellow,
                "Structural vs RTL EW YELLOW"
            );

            check_1bit(
                s_ew_green,
                r_ew_green,
                "Structural vs RTL EW GREEN"
            );

        end

    endtask


    //==========================================================
    // SAFETY CHECK
    //==========================================================

    task safety_check;

        begin

            //==================================================
            // NS EXACTLY ONE LIGHT
            //==================================================

            if((s_ns_red +
                s_ns_yellow +
                s_ns_green) != 1)
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : NS invalid combination = %b%b%b",
                    s_ns_red,
                    s_ns_yellow,
                    s_ns_green
                );

            end

            else
            begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : NS one-hot safety"
                );

            end


            //==================================================
            // EW EXACTLY ONE LIGHT
            //==================================================

            if((s_ew_red +
                s_ew_yellow +
                s_ew_green) != 1)
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : EW invalid combination = %b%b%b",
                    s_ew_red,
                    s_ew_yellow,
                    s_ew_green
                );

            end

            else
            begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : EW one-hot safety"
                );

            end


            //==================================================
            // BOTH GREEN PROHIBITED
            //==================================================

            if(s_ns_green && s_ew_green)
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : BOTH NS AND EW GREEN"
                );

            end

            else
            begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : No simultaneous GREEN"
                );

            end


            //==================================================
            // NS RED + GREEN PROHIBITED
            //==================================================

            if(s_ns_red && s_ns_green)
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : NS RED + GREEN"
                );

            end

            else
            begin

                pass_count = pass_count + 1;

            end


            //==================================================
            // EW RED + GREEN PROHIBITED
            //==================================================

            if(s_ew_red && s_ew_green)
            begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : EW RED + GREEN"
                );

            end

            else
            begin

                pass_count = pass_count + 1;

            end

        end

    endtask


    //==========================================================
    // MAIN TEST
    //==========================================================

    initial
    begin

        //======================================================
        // INITIALIZATION
        //======================================================

        pass_count = 0;

        fail_count = 0;

        reset = 1'b0;

        A = 1'b0;
        B = 1'b0;

        comp_A = 3'b000;
        comp_B = 3'b000;

        dff_D = 1'b0;

        test_state = S0;

        test_done = 1'b0;

        output_state = S0;

        reset_reference_model;


        //======================================================
        // TEST 1 : BASIC GATES
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 1 : BASIC GATES");
        $display("==========================================");


        for(i = 0; i < 4; i = i + 1)
        begin

            A = i[1];

            B = i[0];

            #1;

            check_1bit(
                not_y,
                ~A,
                "NOT gate"
            );

            check_1bit(
                and_y,
                A & B,
                "AND gate"
            );

            check_1bit(
                or_y,
                A | B,
                "OR gate"
            );

            check_1bit(
                xor_y,
                A ^ B,
                "XOR gate"
            );

        end


        //======================================================
        // TEST 2 : COMPARATOR
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 2 : 3-BIT EQUALITY COMPARATOR");
        $display("==========================================");


        for(i = 0; i < 8; i = i + 1)
        begin

            comp_A = i[2:0];

            comp_B = i[2:0];

            #1;

            check_1bit(
                comp_equal,
                1'b1,
                "Comparator equal"
            );

        end


        comp_A = 3'b101;

        comp_B = 3'b100;

        #1;

        check_1bit(
            comp_equal,
            1'b0,
            "Comparator unequal"
        );


        //======================================================
        // TEST 3 : DFF
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 3 : D FLIP-FLOP");
        $display("==========================================");


        reset = 1'b1;

        dff_D = 1'b1;

        @(posedge clk);

        #1;

        check_1bit(
            dff_Q,
            1'b0,
            "DFF reset"
        );


        reset = 1'b0;

        dff_D = 1'b1;

        @(posedge clk);

        #1;

        check_1bit(
            dff_Q,
            1'b1,
            "DFF load 1"
        );


        dff_D = 1'b0;

        @(posedge clk);

        #1;

        check_1bit(
            dff_Q,
            1'b0,
            "DFF load 0"
        );


        //======================================================
        // TEST 4 : TIMER RESET
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 4 : TIMER RESET");
        $display("==========================================");


        reset = 1'b1;

        @(posedge clk);

        #1;

        check_3bit(
            timer_count,
            3'd0,
            "Timer reset"
        );


        check_1bit(
            timer_done,
            1'b0,
            "Timer done reset"
        );


        reset = 1'b0;


        //======================================================
        // TEST 5 : TIMER COUNTING
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 5 : TIMER COUNTING");
        $display("==========================================");


        @(posedge clk);

        #1;

        check_3bit(
            timer_count,
            3'd1,
            "Timer count 1"
        );


        @(posedge clk);

        #1;

        check_3bit(
            timer_count,
            3'd2,
            "Timer count 2"
        );


        @(posedge clk);

        #1;

        check_3bit(
            timer_count,
            3'd3,
            "Timer count 3"
        );


        check_1bit(
            timer_done,
            1'b1,
            "Timer DONE"
        );


        @(posedge clk);

        #1;

        check_3bit(
            timer_count,
            3'd0,
            "Timer rollover"
        );


        //======================================================
        // TEST 6 : FSM NEXT STATE
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 6 : FSM NEXT-STATE LOGIC");
        $display("==========================================");


        //======================================================
        // S0
        //======================================================

        test_state = S0;

        test_done = 1'b0;

        #1;

        check_3bit(
            test_next_state,
            S0,
            "S0 + done=0 -> S0"
        );


        test_done = 1'b1;

        #1;

        check_3bit(
            test_next_state,
            S1,
            "S0 + done=1 -> S1"
        );


        //======================================================
        // S1
        //======================================================

        test_state = S1;

        test_done = 1'b0;

        #1;

        check_3bit(
            test_next_state,
            S1,
            "S1 + done=0 -> S1"
        );


        test_done = 1'b1;

        #1;

        check_3bit(
            test_next_state,
            S2,
            "S1 + done=1 -> S2"
        );


        //======================================================
        // S2
        //======================================================

        test_state = S2;

        test_done = 1'b0;

        #1;

        check_3bit(
            test_next_state,
            S2,
            "S2 + done=0 -> S2"
        );


        test_done = 1'b1;

        #1;

        check_3bit(
            test_next_state,
            S3,
            "S2 + done=1 -> S3"
        );


        //======================================================
        // S3
        //======================================================

        test_state = S3;

        test_done = 1'b0;

        #1;

        check_3bit(
            test_next_state,
            S3,
            "S3 + done=0 -> S3"
        );


        test_done = 1'b1;

        #1;

        check_3bit(
            test_next_state,
            S4,
            "S3 + done=1 -> S4"
        );


        //======================================================
        // S4
        //======================================================

        test_state = S4;

        test_done = 1'b0;

        #1;

        check_3bit(
            test_next_state,
            S4,
            "S4 + done=0 -> S4"
        );


        test_done = 1'b1;

        #1;

        check_3bit(
            test_next_state,
            S5,
            "S4 + done=1 -> S5"
        );


        //======================================================
        // S5
        //======================================================

        test_state = S5;

        test_done = 1'b0;

        #1;

        check_3bit(
            test_next_state,
            S5,
            "S5 + done=0 -> S5"
        );


        test_done = 1'b1;

        #1;

        check_3bit(
            test_next_state,
            S0,
            "S5 + done=1 -> S0"
        );


        //======================================================
        // TEST 7 : OUTPUT DECODER
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 7 : OUTPUT DECODER");
        $display("==========================================");


        //======================================================
        // S0
        //======================================================

        output_state = S0;

        #1;

        check_1bit(ns_green,   1'b1, "S0 NS GREEN");
        check_1bit(ew_red,     1'b1, "S0 EW RED");
        check_1bit(ns_red,     1'b0, "S0 NS RED");
        check_1bit(ns_yellow,  1'b0, "S0 NS YELLOW");
        check_1bit(ew_yellow,  1'b0, "S0 EW YELLOW");
        check_1bit(ew_green,   1'b0, "S0 EW GREEN");


        //======================================================
        // S1
        //======================================================

        output_state = S1;

        #1;

        check_1bit(ns_yellow,  1'b1, "S1 NS YELLOW");
        check_1bit(ew_red,     1'b1, "S1 EW RED");
        check_1bit(ns_red,     1'b0, "S1 NS RED");
        check_1bit(ns_green,   1'b0, "S1 NS GREEN");
        check_1bit(ew_yellow,  1'b0, "S1 EW YELLOW");
        check_1bit(ew_green,   1'b0, "S1 EW GREEN");


        //======================================================
        // S2
        //======================================================

        output_state = S2;

        #1;

        check_1bit(ns_red,     1'b1, "S2 NS RED");
        check_1bit(ew_red,     1'b1, "S2 EW RED");
        check_1bit(ns_yellow,  1'b0, "S2 NS YELLOW");
        check_1bit(ns_green,   1'b0, "S2 NS GREEN");
        check_1bit(ew_yellow,  1'b0, "S2 EW YELLOW");
        check_1bit(ew_green,   1'b0, "S2 EW GREEN");


        //======================================================
        // S3
        //======================================================

        output_state = S3;

        #1;

        check_1bit(ns_red,     1'b1, "S3 NS RED");
        check_1bit(ew_green,   1'b1, "S3 EW GREEN");
        check_1bit(ns_yellow,  1'b0, "S3 NS YELLOW");
        check_1bit(ns_green,   1'b0, "S3 NS GREEN");
        check_1bit(ew_red,     1'b0, "S3 EW RED");
        check_1bit(ew_yellow,  1'b0, "S3 EW YELLOW");


        //======================================================
        // S4
        //======================================================

        output_state = S4;

        #1;

        check_1bit(ns_red,     1'b1, "S4 NS RED");
        check_1bit(ew_yellow,  1'b1, "S4 EW YELLOW");
        check_1bit(ns_yellow,  1'b0, "S4 NS YELLOW");
        check_1bit(ns_green,   1'b0, "S4 NS GREEN");
        check_1bit(ew_red,     1'b0, "S4 EW RED");
        check_1bit(ew_green,   1'b0, "S4 EW GREEN");


        //======================================================
        // S5
        //======================================================

        output_state = S5;

        #1;

        check_1bit(ns_red,     1'b1, "S5 NS RED");
        check_1bit(ew_red,     1'b1, "S5 EW RED");
        check_1bit(ns_yellow,  1'b0, "S5 NS YELLOW");
        check_1bit(ns_green,   1'b0, "S5 NS GREEN");
        check_1bit(ew_yellow,  1'b0, "S5 EW YELLOW");
        check_1bit(ew_green,   1'b0, "S5 EW GREEN");


        //======================================================
        // TEST 8 : COMPLETE DUT RESET
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 8 : COMPLETE DUT RESET");
        $display("==========================================");


        reset = 1'b1;

        reset_reference_model;

        @(posedge clk);

        #1;

        check_complete_reference;

        reset = 1'b0;


        //======================================================
        // TEST 9 : REFERENCE MODEL VERIFICATION
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 9 : REFERENCE MODEL VERIFICATION");
        $display("==========================================");


        for(i = 0; i < 72; i = i + 1)
        begin

            @(posedge clk);

            #1;

            update_reference_model;

            check_complete_reference;

            compare_structural_rtl;

            safety_check;

        end


        //======================================================
        // TEST 10 : STRUCTURAL VS RTL LONG RUN
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 10 : STRUCTURAL VS RTL");
        $display("==========================================");


        reset = 1'b1;

        @(posedge clk);

        #1;

        reset = 1'b0;


        for(i = 0; i < 100; i = i + 1)
        begin

            @(posedge clk);

            #1;

            compare_structural_rtl;

        end


        //======================================================
        // TEST 11 : SAFETY STRESS
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 11 : SAFETY STRESS TEST");
        $display("==========================================");


        reset = 1'b1;

        @(posedge clk);

        #1;

        reset = 1'b0;


        for(i = 0; i < 100; i = i + 1)
        begin

            #1;

            safety_check;

            @(posedge clk);

        end


        //======================================================
        // TEST 12 : RESET RECOVERY
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 12 : RESET RECOVERY");
        $display("==========================================");


        reset = 1'b0;


        repeat(10)
        begin

            @(posedge clk);

            #1;

        end


        // Apply reset

        reset = 1'b1;

        reset_reference_model;

        @(posedge clk);

        #1;


        check_3bit(
            s_state,
            S0,
            "Reset recovery STATE S0"
        );


        check_3bit(
            s_timer_count,
            3'd0,
            "Reset recovery TIMER 0"
        );


        check_1bit(
            s_timer_done,
            1'b0,
            "Reset recovery DONE 0"
        );


        check_1bit(
            s_ns_green,
            1'b1,
            "Reset recovery NS GREEN"
        );


        check_1bit(
            s_ew_red,
            1'b1,
            "Reset recovery EW RED"
        );


        reset = 1'b0;


        //======================================================
        // TEST 13 : INVALID STATE 110
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 13 : INVALID FSM STATE 110");
        $display("==========================================");


        test_state = 3'b110;

        test_done = 1'b0;

        #1;


        check_3bit(
            test_next_state,
            S0,
            "Invalid state 110 -> S0"
        );


        output_state = 3'b110;

        #1;


        check_1bit(
            ns_red,
            1'b1,
            "110 -> NS RED"
        );


        check_1bit(
            ew_red,
            1'b1,
            "110 -> EW RED"
        );


        check_1bit(
            ns_green,
            1'b0,
            "110 -> NS GREEN OFF"
        );


        check_1bit(
            ew_green,
            1'b0,
            "110 -> EW GREEN OFF"
        );


        //======================================================
        // TEST 14 : INVALID STATE 111
        //======================================================

        $display("");
        $display("==========================================");
        $display("TEST 14 : INVALID FSM STATE 111");
        $display("==========================================");


        test_state = 3'b111;

        test_done = 1'b0;

        #1;


        check_3bit(
            test_next_state,
            S0,
            "Invalid state 111 -> S0"
        );


        output_state = 3'b111;

        #1;


        check_1bit(
            ns_red,
            1'b1,
            "111 -> NS RED"
        );


        check_1bit(
            ew_red,
            1'b1,
            "111 -> EW RED"
        );


        //======================================================
        // FINAL RESULT
        //======================================================

        $display("");
        $display("================================================");
        $display("DAY 15 TRAFFIC LIGHT CONTROLLER");
        $display("VERIFICATION COMPLETE");
        $display("================================================");


        $display(
            "TOTAL PASS COUNT = %0d",
            pass_count
        );


        $display(
            "TOTAL FAIL COUNT = %0d",
            fail_count
        );


        if(fail_count == 0)
        begin

            $display("");
            $display("================================================");
            $display("ALL TESTS PASSED");
            $display("================================================");

            $display("BASIC GATES       : PASS");
            $display("COMPARATOR        : PASS");
            $display("DFF               : PASS");
            $display("TIMER             : PASS");
            $display("FSM               : PASS");
            $display("OUTPUT DECODER    : PASS");
            $display("STRUCTURAL DUT    : PASS");
            $display("RTL DUT           : PASS");
            $display("REFERENCE MODEL   : PASS");
            $display("STRUCTURAL vs RTL : PASS");
            $display("SAFETY            : PASS");
            $display("RESET RECOVERY    : PASS");
            $display("INVALID STATE     : PASS");

            $display("================================================");

        end

        else
        begin

            $display("");
            $display("================================================");
            $display("VERIFICATION FAILED");
            $display("CHECK FAIL MESSAGES AND WAVEFORM");
            $display("================================================");

        end


        #20;

        $finish;

    end


    //==========================================================
    // LIVE MONITOR
    //==========================================================

    initial
    begin

        $monitor(
            "TIME=%0t | RESET=%b | TIMER=%0d | DONE=%b | STATE=%03b | NEXT=%03b | NS(RYG)=%b%b%b | EW(RYG)=%b%b%b",

            $time,

            reset,

            s_timer_count,

            s_timer_done,

            s_state,

            s_next_state,

            s_ns_red,
            s_ns_yellow,
            s_ns_green,

            s_ew_red,
            s_ew_yellow,
            s_ew_green
        );

    end


endmodule