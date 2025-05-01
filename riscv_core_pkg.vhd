library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package riscv_core_pkg is
    ----------------------------------------------------------------------------
    -- Instruction Opcodes (RV32I Base Instruction Set)
    ----------------------------------------------------------------------------
    constant OPCODE_LOAD       : std_logic_vector(6 downto 0) := "0000011";  -- I-type
    constant OPCODE_STORE      : std_logic_vector(6 downto 0) := "0100011";  -- S-type
    constant OPCODE_BRANCH     : std_logic_vector(6 downto 0) := "1100011";  -- B-type
    constant OPCODE_JALR       : std_logic_vector(6 downto 0) := "1100111";  -- I-type
    constant OPCODE_JAL        : std_logic_vector(6 downto 0) := "1101111";  -- J-type
    constant OPCODE_OP_IMM     : std_logic_vector(6 downto 0) := "0010011";  -- I-type
    constant OPCODE_OP         : std_logic_vector(6 downto 0) := "0110011";  -- R-type
    constant OPCODE_AUIPC      : std_logic_vector(6 downto 0) := "0010111";  -- U-type
    constant OPCODE_LUI        : std_logic_vector(6 downto 0) := "0110111";  -- U-type
    constant OPCODE_SYSTEM     : std_logic_vector(6 downto 0) := "1110011";  -- I-type

    -- Additional opcode aliases for clarity
    constant OPCODE_R_TYPE     : std_logic_vector(6 downto 0) := OPCODE_OP;
    constant OPCODE_I_TYPE     : std_logic_vector(6 downto 0) := OPCODE_OP_IMM;
    constant OPCODE_B_TYPE     : std_logic_vector(6 downto 0) := OPCODE_BRANCH;
    constant OPCODE_U_TYPE     : std_logic_vector(6 downto 0) := OPCODE_LUI;  -- or OPCODE_AUIPC

    ----------------------------------------------------------------------------
    -- Function Codes (funct3 fields)
    ----------------------------------------------------------------------------
    -- Arithmetic/Logical Operations
    constant FUNCT3_ADD_SUB    : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_SLL        : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_SLT        : std_logic_vector(2 downto 0) := "010";
    constant FUNCT3_SLTU       : std_logic_vector(2 downto 0) := "011";
    constant FUNCT3_XOR        : std_logic_vector(2 downto 0) := "100";
    constant FUNCT3_SRL_SRA    : std_logic_vector(2 downto 0) := "101";
    constant FUNCT3_OR         : std_logic_vector(2 downto 0) := "110";
    constant FUNCT3_AND        : std_logic_vector(2 downto 0) := "111";

    -- Branch Operations
    constant FUNCT3_BEQ        : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_BNE        : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_BLT        : std_logic_vector(2 downto 0) := "100";
    constant FUNCT3_BGE        : std_logic_vector(2 downto 0) := "101";
    constant FUNCT3_BLTU       : std_logic_vector(2 downto 0) := "110";
    constant FUNCT3_BGEU       : std_logic_vector(2 downto 0) := "111";

    -- Load/Store Operations
    constant FUNCT3_LB         : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_LH         : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_LW         : std_logic_vector(2 downto 0) := "010";
    constant FUNCT3_LBU        : std_logic_vector(2 downto 0) := "100";
    constant FUNCT3_LHU        : std_logic_vector(2 downto 0) := "101";
    constant FUNCT3_SB         : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_SH         : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_SW         : std_logic_vector(2 downto 0) := "010";

    ----------------------------------------------------------------------------
    -- ALU Operation Codes
    ----------------------------------------------------------------------------
    constant ALU_ADD       : std_logic_vector(3 downto 0) := "0000";
    constant ALU_SUB       : std_logic_vector(3 downto 0) := "0001";
    constant ALU_AND       : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OR        : std_logic_vector(3 downto 0) := "0011";
    constant ALU_XOR       : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SLL       : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRL       : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SRA       : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLT       : std_logic_vector(3 downto 0) := "1000";
    constant ALU_SLTU      : std_logic_vector(3 downto 0) := "1001";
    constant ALU_JALR      : std_logic_vector(3 downto 0) := "1010";
    constant ALU_PASS_A    : std_logic_vector(3 downto 0) := "1011";  -- For LUI/AUIPC

    ----------------------------------------------------------------------------
    -- Processor Control States
    ----------------------------------------------------------------------------
    type processor_state is (
        FETCH,          -- Instruction fetch
        DECODE,         -- Instruction decode
        EXECUTE,        -- Execute operation (includes branch resolution)
        MEMORY_ACCESS,  -- Memory load/store operations
        WRITE_BACK      -- Register write back
    );

    ----------------------------------------------------------------------------
    -- Register File Type
    ----------------------------------------------------------------------------
    type reg_file is array (0 to 31) of std_logic_vector(31 downto 0);

    ----------------------------------------------------------------------------
    -- Constants
    ----------------------------------------------------------------------------
    constant ZERO_WORD   : std_logic_vector(31 downto 0) := (others => '0');
    constant PC_START    : std_logic_vector(31 downto 0) := x"00000000";

end package riscv_core_pkg;
