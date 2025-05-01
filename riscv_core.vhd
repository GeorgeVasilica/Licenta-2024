library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.riscv_core_pkg.all;

entity riscv_core is
    Port ( 
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;
        
        -- Instruction Memory Interface
        inst_addr       : out STD_LOGIC_VECTOR(31 downto 0);
        inst_data       : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Data Memory Interface
        data_addr       : out STD_LOGIC_VECTOR(31 downto 0);
        data_write      : out STD_LOGIC_VECTOR(31 downto 0);
        data_read       : in STD_LOGIC_VECTOR(31 downto 0);
        data_we         : out STD_LOGIC;
        
        -- Interrupt and Exception
        irq             : in STD_LOGIC;
        exception       : out STD_LOGIC
    );
end riscv_core;

architecture Behavioral of riscv_core is
    -- Internal Signals
    signal current_state    : processor_state := FETCH;
    
    -- Program Counter
    signal pc               : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal next_pc          : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Instruction Components
    signal current_inst     : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode           : STD_LOGIC_VECTOR(6 downto 0);
    signal rd               : STD_LOGIC_VECTOR(4 downto 0);
    signal rs1              : STD_LOGIC_VECTOR(4 downto 0);
    signal rs2              : STD_LOGIC_VECTOR(4 downto 0);
    signal funct3           : STD_LOGIC_VECTOR(2 downto 0);
    signal funct7           : STD_LOGIC_VECTOR(6 downto 0);
    
    -- Immediate Values
    signal imm_i            : STD_LOGIC_VECTOR(31 downto 0);
    signal imm_s            : STD_LOGIC_VECTOR(31 downto 0);
    signal imm_b            : STD_LOGIC_VECTOR(31 downto 0);
    signal imm_u            : STD_LOGIC_VECTOR(31 downto 0);
    signal imm_j            : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Register File Signals
    signal rs1_data         : STD_LOGIC_VECTOR(31 downto 0);
    signal rs2_data         : STD_LOGIC_VECTOR(31 downto 0);
    signal rd_data          : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_write_en     : STD_LOGIC := '0';
    
    -- ALU Signals
    signal alu_a            : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_b            : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_op           : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result       : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero         : STD_LOGIC;
    signal alu_carry        : STD_LOGIC;
    signal alu_overflow     : STD_LOGIC;
    
    -- Component Declarations
    component register_file is
        Port ( 
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            rs1_addr    : in STD_LOGIC_VECTOR(4 downto 0);
            rs2_addr    : in STD_LOGIC_VECTOR(4 downto 0);
            rd_addr     : in STD_LOGIC_VECTOR(4 downto 0);
            rd_data     : in STD_LOGIC_VECTOR(31 downto 0);
            write_en    : in STD_LOGIC;
            rs1_data    : out STD_LOGIC_VECTOR(31 downto 0);
            rs2_data    : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component alu is
        Port ( 
            a           : in STD_LOGIC_VECTOR(31 downto 0);
            b           : in STD_LOGIC_VECTOR(31 downto 0);
            alu_op      : in STD_LOGIC_VECTOR(3 downto 0);
            result      : out STD_LOGIC_VECTOR(31 downto 0);
            zero        : out STD_LOGIC;
            carry       : out STD_LOGIC;
            overflow    : out STD_LOGIC
        );
    end component;
    
    component instruction_decoder is
        Port ( 
            instruction : in STD_LOGIC_VECTOR(31 downto 0);
            opcode      : out STD_LOGIC_VECTOR(6 downto 0);
            rd          : out STD_LOGIC_VECTOR(4 downto 0);
            rs1         : out STD_LOGIC_VECTOR(4 downto 0);
            rs2         : out STD_LOGIC_VECTOR(4 downto 0);
            funct3      : out STD_LOGIC_VECTOR(2 downto 0);
            funct7      : out STD_LOGIC_VECTOR(6 downto 0);
            imm_i       : out STD_LOGIC_VECTOR(31 downto 0);
            imm_s       : out STD_LOGIC_VECTOR(31 downto 0);
            imm_b       : out STD_LOGIC_VECTOR(31 downto 0);
            imm_u       : out STD_LOGIC_VECTOR(31 downto 0);
            imm_j       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
begin
    -- Component Instantiations
    reg_file_inst : register_file 
    port map (
        clk         => clk,
        reset       => reset,
        rs1_addr    => rs1,
        rs2_addr    => rs2,
        rd_addr     => rd,
        rd_data     => rd_data,
        write_en    => reg_write_en,
        rs1_data    => rs1_data,
        rs2_data    => rs2_data
    );
    
    alu_inst : alu 
    port map (
        a           => alu_a,
        b           => alu_b,
        alu_op      => alu_op,
        result      => alu_result,
        zero        => alu_zero,
        carry       => alu_carry,
        overflow    => alu_overflow
    );
    
    decoder_inst : instruction_decoder 
    port map (
        instruction => current_inst,
        opcode      => opcode,
        rd          => rd,
        rs1         => rs1,
        rs2         => rs2,
        funct3      => funct3,
        funct7      => funct7,
        imm_i       => imm_i,
        imm_s       => imm_s,
        imm_b       => imm_b,
        imm_u       => imm_u,
        imm_j       => imm_j
    );
    
    -- Main Processor Logic
core_process: process(clk, reset)
begin
    if reset = '1' then
        -- Reset all states
        pc <= (others => '0');
        current_state <= FETCH;
        reg_write_en <= '0';
        data_we <= '0';
        exception <= '0';
    elsif rising_edge(clk) then
        case current_state is
            when FETCH =>
                inst_addr <= pc;
                current_inst <= inst_data;
                next_pc <= std_logic_vector(unsigned(pc) + 4);
                current_state <= DECODE;
            
            when DECODE =>
                -- Prepare ALU inputs based on instruction type
                case opcode is
                    when OPCODE_R_TYPE =>
                        alu_a <= rs1_data;
                        alu_b <= rs2_data;
                        
                        -- Determine ALU operation based on funct3 and funct7
                        case funct3 is
                            when "000" =>
                                if funct7 = "0000000" then
                                    alu_op <= ALU_ADD;  -- ADD
                                elsif funct7 = "0100000" then

                                    alu_op <= ALU_SUB;  -- SUB
                                end if;
                            when "001" => alu_op <= ALU_SLL;  -- SLL
                            when "010" => alu_op <= ALU_SLT;  -- SLT
                            when "011" => alu_op <= ALU_SLTU; -- SLTU
                            when "100" => alu_op <= ALU_XOR;  -- XOR
                            when "101" =>
                                if funct7 = "0000000" then
                                    alu_op <= ALU_SRL;  -- SRL
                                elsif funct7 = "0100000" then
                                    alu_op <= ALU_SRA;  -- SRA
                                end if;
                            when "110" => alu_op <= ALU_OR;   -- OR
                            when "111" => alu_op <= ALU_AND;  -- AND
                            when others => 
                                exception <= '1';
                        end case;
                    
                    when OPCODE_I_TYPE =>
                        alu_a <= rs1_data;
                        alu_b <= imm_i;
                        
                        case funct3 is
                            when "000" => alu_op <= ALU_ADD;  -- ADDI
                            when "010" => alu_op <= ALU_SLT;  -- SLTI
                            when "011" => alu_op <= ALU_SLTU; -- SLTIU
                            when "100" => alu_op <= ALU_XOR;  -- XORI
                            when "110" => alu_op <= ALU_OR;   -- ORI
                            when "111" => alu_op <= ALU_AND;  -- ANDI
                            when others => 
                                exception <= '1';
                        end case;
                    
                    when OPCODE_STORE =>
                        alu_a <= rs1_data;
                        alu_b <= imm_s;
                        alu_op <= ALU_ADD;
                    
                    when OPCODE_LOAD =>
                        alu_a <= rs1_data;
                        alu_b <= imm_i;
                        alu_op <= ALU_ADD;
                    
                    when OPCODE_B_TYPE =>
                        alu_a <= rs1_data;
                        alu_b <= rs2_data;
                        
                        case funct3 is
                            when "000" => alu_op <= ALU_SUB;   -- BEQ
                            when "001" => alu_op <= ALU_SUB;   -- BNE
                            when "100" => alu_op <= ALU_SLT;   -- BLT
                            when "101" => alu_op <= ALU_SLT;   -- BGE
                            when "110" => alu_op <= ALU_SLTU;  -- BLTU
                            when "111" => alu_op <= ALU_SLTU;  -- BGEU
                            when others => 
                                exception <= '1';
                        end case;
                    
                    when others =>
                        exception <= '1';
                end case;
                
                current_state <= EXECUTE;
            
            when EXECUTE =>
                case opcode is
                    when OPCODE_B_TYPE =>
                        -- Branch resolution
                        case funct3 is
                            when "000" =>  -- BEQ
                                if alu_zero = '1' then
                                    pc <= std_logic_vector(unsigned(pc) + unsigned(imm_b));
                                else
                                    pc <= next_pc;
                                end if;
                            
                            when "001" =>  -- BNE
                                if alu_zero = '0' then
                                    pc <= std_logic_vector(unsigned(pc) + unsigned(imm_b));
                                else
                                    pc <= next_pc;
                                end if;
                            
                            when "100" =>  -- BLT
                                if alu_result(31) = '1' then
                                    pc <= std_logic_vector(unsigned(pc) + unsigned(imm_b));
                                else
                                    pc <= next_pc;
                                end if;
                            
                            when "101" =>  -- BGE
                                if alu_result(31) = '0' then
                                    pc <= std_logic_vector(unsigned(pc) + unsigned(imm_b));
                                else
                                    pc <= next_pc;
                                end if;
                            
                            when "110" =>  -- BLTU
                                if alu_carry = '1' then
                                    pc <= std_logic_vector(unsigned(pc) + unsigned(imm_b));
                                else
                                    pc <= next_pc;
                                end if;
                            
                            when "111" =>  -- BGEU
                                if alu_carry = '0' then
                                    pc <= std_logic_vector(unsigned(pc) + unsigned(imm_b));
                                else
                                    pc <= next_pc;
                                end if;
                            
                            when others =>
                                exception <= '1';
                                pc <= next_pc;
                        end case;
                    
                    when OPCODE_JAL =>
                        -- Jump and Link
                        rd_data <= next_pc;  -- Store return address
                        pc <= std_logic_vector(unsigned(pc) + unsigned(imm_j));
                        reg_write_en <= '1';
                    
                    when OPCODE_JALR =>
                        -- Jump and Link Register
                        rd_data <= next_pc;  -- Store return address
                        pc <= std_logic_vector(unsigned(rs1_data) + unsigned(imm_i));
                        reg_write_en <= '1';
                    
                    when others =>
                        -- For other instruction types, use ALU result and prepare for writeback
                        rd_data <= alu_result;
                        pc <= next_pc;
                        reg_write_en <= '1';
                end case;
                
                current_state <= MEMORY_ACCESS;
            
            when MEMORY_ACCESS =>
                if opcode = OPCODE_STORE then
                    data_addr <= alu_result;
                    data_write <= rs2_data;
                    data_we <= '1';
                elsif opcode = OPCODE_LOAD then
                    data_addr <= alu_result;
                    data_we <= '0';
                    rd_data <= data_read;
                    reg_write_en <= '1';
                end if;
                
                current_state <= WRITE_BACK;
            
            when WRITE_BACK =>
                -- Reset control signals
                reg_write_en <= '0';
                data_we <= '0';
                
                current_state <= FETCH;
            
            when others =>
                exception <= '1';
                current_state <= FETCH;
        end case;
    end if;
end process;
end Behavioral;
