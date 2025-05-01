library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.riscv_core_pkg.all;

entity register_file is
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
end register_file;

architecture Behavioral of register_file is
    signal registers : reg_file := (others => (others => '0'));
begin
    -- Read operation (asynchronous)
    read_process: process(rs1_addr, rs2_addr, registers)
    begin
        -- Handle x0 register (always zero)
        if rs1_addr = "00000" then
            rs1_data <= (others => '0');
        else
            rs1_data <= registers(to_integer(unsigned(rs1_addr)));
        end if;

        if rs2_addr = "00000" then
            rs2_data <= (others => '0');
        else
            rs2_data <= registers(to_integer(unsigned(rs2_addr)));
        end if;
    end process;

    -- Write operation (synchronous)
    write_process: process(clk, reset)
    begin
        if reset = '1' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if write_en = '1' and rd_addr /= "00000" then
                registers(to_integer(unsigned(rd_addr))) <= rd_data;
            end if;
        end if;
    end process;
end Behavioral;
