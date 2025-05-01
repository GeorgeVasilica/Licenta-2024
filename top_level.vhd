library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port ( 
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;
        -- Add other system-level interfaces
        led     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end top_level;

architecture Behavioral of top_level is
    -- Component declarations
    component riscv_core is
        Port ( 
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            inst_addr       : out STD_LOGIC_VECTOR(31 downto 0);
            inst_data       : in STD_LOGIC_VECTOR(31 downto 0);
            data_addr       : out STD_LOGIC_VECTOR(31 downto 0);
            data_write      : out STD_LOGIC_VECTOR(31 downto 0);
            data_read       : in STD_LOGIC_VECTOR(31 downto 0);
            data_we         : out STD_LOGIC;
            irq             : in STD_LOGIC;
            exception       : out STD_LOGIC
        );
    end component;

    -- Signals for interconnection
    signal inst_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal inst_data    : STD_LOGIC_VECTOR(31 downto 0);
    signal data_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal data_write   : STD_LOGIC_VECTOR(31 downto 0);
    signal data_read    : STD_LOGIC_VECTOR(31 downto 0);
    signal data_we      : STD_LOGIC;
    signal exception    : STD_LOGIC;

begin
    -- RISC-V Core Instantiation
    riscv_core_inst : riscv_core
    port map (
        clk         => clk,
        reset       => reset,
        inst_addr   => inst_addr,
        inst_data   => inst_data,
        data_addr   => data_addr,
        data_write  => data_write,
        data_read   => data_read,
        data_we     => data_we,
        irq         => '0',
        exception   => exception
    );

    -- Simple LED output for debugging
    process(clk)
    begin
        if rising_edge(clk) then
            if exception = '1' then
                led <= "11111111";  -- All LEDs on if exception occurs
            else
                led <= "10101010";  -- Alternating LED pattern
            end if;
        end if;
    end process;
end Behavioral;
