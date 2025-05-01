library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.riscv_core_pkg.all;

entity instruction_decoder is
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
end instruction_decoder;

architecture Behavioral of instruction_decoder is
begin
    decode_process: process(instruction)
    begin
        -- Extract common fields
        opcode <= instruction(6 downto 0);
        rd     <= instruction(11 downto 7);
        rs1    <= instruction(19 downto 15);
        rs2    <= instruction(24 downto 20);
        funct3 <= instruction(14 downto 12);
        funct7 <= instruction(31 downto 25);

        -- I-type immediate (sign-extended)
        imm_i <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);

        -- S-type immediate (store instructions)
        imm_s <= (31 downto 12 => instruction(31)) & 
                 instruction(31 downto 25) & 
                 instruction(11 downto 7);

        -- B-type immediate (branch instructions)
        imm_b <= (31 downto 13 => instruction(31)) & 
                 instruction(31) & 
                 instruction(7) & 
                 instruction(30 downto 25) & 
                 instruction(11 downto 8) & 
                 '0';

        -- U-type immediate (upper immediate)
        imm_u <= instruction(31 downto 12) & (11 downto 0 => '0');

        -- J-type immediate (jump instructions)
        imm_j <= (31 downto 21 => instruction(31)) & 
                 instruction(31) & 
                 instruction(19 downto 12) & 
                 instruction(20) & 
                 instruction(30 downto 21) & 
                 '0';
    end process;
end Behavioral;
