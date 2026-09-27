`timescale 1ns / 1ps

// =========================================================================
// TOP-LEVEL WRAPPER MODULE FOR SPARTAN-6 HARDWARE TARGETING (LED ONLY)
// =========================================================================
module misp(
    input clk,
    output [7:0] led
);
    reg [19:0] counter = 0;
    reg slow_en = 0;

    // Clock divider to slow execution down for visible LED transitions
    always @(posedge clk) begin
        counter <= counter + 1;
        slow_en <= (counter == 0); // Pulse for slow execution
    end

    // Core CPU instantiation
    pipe_mips32 cpu (
        .clk(clk), 
        .slow_en(slow_en), 
        .led(led)
    );
endmodule

// =========================================================================
// 5-STAGE PIPELINE CORE (IF, ID, EX, MEM, WB) WITHOUT FORWARDING
// =========================================================================
module pipe_mips32(
    input clk,
    input slow_en,
    output [7:0] led
);
    //================ REGISTERS =================//
    reg [31:0] PC = 0;
    reg [31:0] IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR;
    reg [31:0] ID_EX_A, ID_EX_B;
    reg [31:0] ID_EX_Imm, ID_EX_NPC;
    reg [31:0] EX_MEM_IR;
    reg [31:0] EX_MEM_ALUOut;
    reg [31:0] MEM_WB_IR;
    reg [31:0] MEM_WB_ALUOut;
    reg [31:0] MEM_WB_LMD;

    (* ram_style = "distributed" *)
    reg [31:0] RegFile [0:31];
    reg [31:0] Mem [0:255];

    //================ OPCODES =================//
    parameter
        ADD   = 6'b000000,
        SUB   = 6'b000001,
        SLT   = 6'b000100,
        MOVI  = 6'b000110,
        LW    = 6'b001000,
        ADDI  = 6'b001010,
        SRTI  = 6'b001111,
        BNEQZ = 6'b001101,
        BEQZ  = 6'b001110,
        HLT   = 6'b111111;

    reg HALTED = 0;
    reg branch_taken;
    reg [31:0] branch_target;
    integer i;

    //================ INITIALIZATION & PROGRAM MEMORY =================//
    initial begin
        // 1. Reset all Pipeline Registers
        PC = 0;
        IF_ID_IR   = 0;
        IF_ID_NPC  = 0;
        ID_EX_IR   = 0;
        ID_EX_A    = 0;
        ID_EX_B    = 0;
        ID_EX_Imm  = 0;
        ID_EX_NPC  = 0;
        EX_MEM_IR  = 0;
        EX_MEM_ALUOut = 0;
        MEM_WB_IR  = 0;
        MEM_WB_ALUOut = 0;
        MEM_WB_LMD = 0;
        HALTED = 0;

        // 2. Clear Arrays
        for(i=0; i<32; i=i+1)  RegFile[i] = 0;
        for(i=0; i<256; i=i+1) Mem[i] = 0;

        // 3. Fibonacci Sequence Iterative Program Assembly Compilation
        // Initialization Core Variables
        Mem[0] = {MOVI,  5'd0, 5'd1,  16'd0};    // R1 = F(0) = 0
        Mem[1] = {MOVI,  5'd0, 5'd2,  16'd1};    // R2 = F(1) = 1
        Mem[2] = {MOVI,  5'd0, 5'd4,  16'd0};    // R4 = Loop counter (i = 0)
        Mem[3] = {MOVI,  5'd0, 5'd5,  16'd11};   // R5 = Limit (N = 10 elements)
        Mem[4] = {MOVI,  5'd0, 5'd7,  16'd0};    // R7 = 0 (Initial LED output state)

        // Initialization RAW Delay NOPs
        Mem[5] = 32'b0; Mem[6] = 32'b0; Mem[7] = 32'b0; Mem[8] = 32'b0; Mem[9] = 32'b0;

        // --- LOOP START (Address 10) ---
        // Evaluation Check: R6 = (i < N)
        Mem[10] = {SLT,   5'd4, 5'd5,  5'd6, 11'b0}; 

        // RAW Delay NOPs for R6 Evaluation Writeback
        Mem[11] = 32'b0; Mem[12] = 32'b0; Mem[13] = 32'b0; Mem[14] = 32'b0; Mem[15] = 32'b0;

        // Branch Out on Termination: If R6 == 0, go to HLT (Address 58). Offset = 58 - (16 + 1) = 41
        Mem[16] = {BEQZ,  5'd6, 5'd0,  16'd41};   

        // Control Branch Delay NOPs
        Mem[17] = 32'b0; Mem[18] = 32'b0; Mem[19] = 32'b0; Mem[20] = 32'b0; Mem[21] = 32'b0;

        // --- ITERATION PROCESSING BLOCKS ---
        // Update Board LEDs: R7 = R1 + 0
        Mem[22] = {ADDI,  5'd1, 5'd7,  16'd0};    
        Mem[23] = 32'b0; Mem[24] = 32'b0; Mem[25] = 32'b0; Mem[26] = 32'b0; Mem[27] = 32'b0;

        // Calculate next element: R3 = R1 + R2
        Mem[28] = {ADD,   5'd1, 5'd2,  5'd3, 11'b0}; 
        Mem[29] = 32'b0; Mem[30] = 32'b0; Mem[31] = 32'b0; Mem[32] = 32'b0; Mem[33] = 32'b0;

        // Structural Shifting Step 1: R1 = R2 + 0
        Mem[34] = {ADDI,  5'd2, 5'd1,  16'd0};    
        Mem[35] = 32'b0; Mem[36] = 32'b0; Mem[37] = 32'b0; Mem[38] = 32'b0; Mem[39] = 32'b0;

        // Structural Shifting Step 2: R2 = R3 + 0
        Mem[40] = {ADDI,  5'd3, 5'd2,  16'd0};    
        Mem[41] = 32'b0; Mem[42] = 32'b0; Mem[43] = 32'b0; Mem[44] = 32'b0; Mem[45] = 32'b0;

        // Loop Counter Increment: i = i + 1
        Mem[46] = {ADDI,  5'd4, 5'd4,  16'd1};    
        Mem[47] = 32'b0; Mem[48] = 32'b0; Mem[49] = 32'b0; Mem[50] = 32'b0; Mem[51] = 32'b0;

        // Unconditional Jump Back: Return to Loop Start (Address 10). Offset = 10 - (52 + 1) = -43
        Mem[52] = {BEQZ,  5'd0, 5'd0,  -16'd43};  

        // Loop Jump Control Delay NOPs
        Mem[53] = 32'b0; Mem[54] = 32'b0; Mem[55] = 32'b0; Mem[56] = 32'b0; Mem[57] = 32'b0;

        // --- PROGRAM EXIT ---
        Mem[58] = {HLT,   26'b0};                 
    end

    //================ PIPELINE CLOCK SEQUENCER =================//
    always @(posedge clk) begin
        if(slow_en && !HALTED) begin
            // -----------------------------------------------------
            // STAGE 5: WRITE BACK (WB)
            // -----------------------------------------------------
            case(MEM_WB_IR[31:26])
                ADD, SUB, SLT:
                    RegFile[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;
                ADDI, MOVI, SRTI:
                    RegFile[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;
                LW:
                    RegFile[MEM_WB_IR[20:16]] <= MEM_WB_LMD;
                HLT:
                    HALTED <= 1;
            endcase

            // -----------------------------------------------------
            // STAGE 4: MEMORY ACCESS (MEM)
            // -----------------------------------------------------
            MEM_WB_IR <= EX_MEM_IR;
            if(EX_MEM_IR[31:26] == LW)
                MEM_WB_LMD <= Mem[EX_MEM_ALUOut];
            else
                MEM_WB_ALUOut <= EX_MEM_ALUOut;

            // -----------------------------------------------------
            // STAGE 3: EXECUTE (EX)
            // -----------------------------------------------------
            EX_MEM_IR <= ID_EX_IR;
            branch_taken <= 0;

            case(ID_EX_IR[31:26])
                ADD:   EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
                SUB:   EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
                SLT:   EX_MEM_ALUOut <= (ID_EX_A < ID_EX_B);
                ADDI:  EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
                SRTI:  EX_MEM_ALUOut <= ID_EX_A >> ID_EX_Imm;
                MOVI:  EX_MEM_ALUOut <= ID_EX_Imm;
                LW:    EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
                BEQZ: begin
                    if(ID_EX_A == 0) begin
                        branch_taken  <= 1;
                        branch_target <= ID_EX_NPC + ID_EX_Imm;
                    end
                end
                BNEQZ: begin
                    if(ID_EX_A != 0) begin
                        branch_taken  <= 1;
                        branch_target <= ID_EX_NPC + ID_EX_Imm;
                    end
                end
                default: EX_MEM_ALUOut <= 0;
            endcase

            // -----------------------------------------------------
            // STAGE 2: INSTRUCTION DECODE (ID)
            // -----------------------------------------------------
            if(branch_taken) begin
                ID_EX_IR  <= 0;
                IF_ID_IR  <= 0;
            end else begin
                ID_EX_IR  <= IF_ID_IR;
            end

            ID_EX_NPC <= IF_ID_NPC;
            ID_EX_A   <= RegFile[IF_ID_IR[25:21]];
            ID_EX_B   <= RegFile[IF_ID_IR[20:16]];
            ID_EX_Imm <= {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};

            // -----------------------------------------------------
            // STAGE 1: INSTRUCTION FETCH (IF)
            // -----------------------------------------------------
            if(branch_taken) begin
                PC <= branch_target;
            end else begin
                IF_ID_IR  <= Mem[PC];
                IF_ID_NPC <= PC + 1;
                PC        <= PC + 1;
            end
        end
    end

    //================ PHYSICAL PIN CONNECTIONS =================//
    assign led = RegFile[7][7:0];   // Maps target register 7 directly to LEDs
endmodule
