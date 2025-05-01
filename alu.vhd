library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.riscv_core_pkg.all;

entity alu is
    Port ( 
        a           : in STD_LOGIC_VECTOR(31 downto 0);
        b           : in STD_LOGIC_VECTOR(31 downto 0);
        alu_op      : in STD_LOGIC_VECTOR(3 downto 0);
        result      : out STD_LOGIC_VECTOR(31 downto 0);
        zero        : out STD_LOGIC;
        carry       : out STD_LOGIC;
        overflow    : out STD_LOGIC
    );
end alu;

architecture Behavioral of alu is
    signal add_result    : STD_LOGIC_VECTOR(32 downto 0);
    signal sub_result    : STD_LOGIC_VECTOR(32 downto 0);
    signal a_signed      : signed(31 downto 0);
    signal b_signed      : signed(31 downto 0);
    signal a_unsigned    : unsigned(31 downto 0);
    signal b_unsigned    : unsigned(31 downto 0);
begin
    -- Convert inputs to signed/unsigned for operations
    a_signed <= signed(a);
    b_signed <= signed(b);
    a_unsigned <= unsigned(a);
    b_unsigned <= unsigned(b);

    -- ALU Operations
    alu_process: process(a, b, alu_op, a_signed, b_signed, a_unsigned, b_unsigned)
        variable shift_amount : integer range 0 to 31;
    begin
        -- Default outputs
        result <= (others => '0');
        zero <= '0';
        carry <= '0';
        overflow <= '0';
        
        -- Prepare shift amount
        shift_amount := to_integer(unsigned(b(4 downto 0)));
        
        -- Perform ALU operation based on alu_op
        case alu_op is
            when ALU_ADD =>
                add_result <= std_logic_vector(resize(a_signed, 33) + resize(b_signed, 33));
                result <= add_result(31 downto 0);
                carry <= add_result(32);
            
            when ALU_SUB =>
                sub_result <= std_logic_vector(resize(a_signed, 33) - resize(b_signed, 33));
                result <= sub_result(31 downto 0);
            if sub_result(31 downto 0) = x"00000000" then
                zero <= '1';
            else
                zero <= '0';
            end if;                carry <= sub_result(32);
            
            when ALU_AND =>
                result <= a and b;
            
            when ALU_OR =>
                result <= a or b;
            
            when ALU_XOR =>
                result <= a xor b;
            
            when ALU_SLL =>
                result <= std_logic_vector(SHIFT_LEFT(a_unsigned, shift_amount));
            
            when ALU_SRL =>
                result <= std_logic_vector(SHIFT_RIGHT(a_unsigned, shift_amount));
            
            when ALU_SRA =>
                result <= std_logic_vector(SHIFT_RIGHT(a_signed, shift_amount));
            
            when ALU_SLT =>
                if a_signed < b_signed then
                    result <= x"00000001";
                else
                    result <= (others => '0');
                end if;
            
            when ALU_SLTU =>
                if a_unsigned < b_unsigned then
                    result <= x"00000001";
                else
                    result <= (others => '0');
                end if;
            
            when others =>
                result <= (others => '0');
        end case;
    end process;
end Behavioral;
