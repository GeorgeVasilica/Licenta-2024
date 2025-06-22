library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_snake is
    port(
        clk       : in  STD_LOGIC;            -- 100 MHz
        paddle_y  : in  STD_LOGIC_VECTOR(9 downto 0);
        paddle_x  : in  STD_LOGIC_VECTOR(9 downto 0);
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        rgb       : out STD_LOGIC_VECTOR(2 downto 0)
    );
end vga_snake;

architecture rtl of vga_snake is
    ----------------------------------------------------------------
    -- 640 × 480 @ 60 Hz timing
    constant HD  : integer := 640;  constant HFP : integer := 16;
    constant HSP : integer := 96;   constant HBP : integer := 48;
    constant HT  : integer := HD + HFP + HSP + HBP;             -- 800
    constant VD  : integer := 480;  constant VFP : integer := 10;
    constant VSP : integer := 2;    constant VBP : integer := 33;
    constant VT  : integer := VD + VFP + VSP + VBP;             -- 525
    ----------------------------------------------------------------
    constant BORDER : integer := 8;
    constant P_SIZE : integer := 40;

    signal hc   : integer range 0 to HT-1 := 0;
    signal vc   : integer range 0 to VT-1 := 0;

    -- 25 MHz pixel-clock (100 MHz ÷ 4)
    signal div  : unsigned(1 downto 0) := (others => '0');
    signal pclk : std_logic := '0';
begin
    ----------------------------------------------------------------
    -- Pixel-clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            div  <= div + 1;         -- 00→01→10→11
            pclk <= div(1);          -- MSB = clk/4 = 25 MHz
        end if;
    end process;

    ----------------------------------------------------------------
    -- Video counters
    process(pclk)
    begin
        if rising_edge(pclk) then
            if hc = HT-1 then
                hc <= 0;
                vc <= (vc + 1) mod VT;
            else
                hc <= hc + 1;
            end if;
        end if;
    end process;

    -- Sync pulses (active low)
    hsync <= '0' when (hc >= HD+HFP and hc < HD+HFP+HSP) else '1';
    vsync <= '0' when (vc >= VD+VFP and vc < VD+VFP+VSP) else '1';

    ----------------------------------------------------------------
    -- Pixel colouring
    process(hc, vc, paddle_x, paddle_y)
        variable px : integer;   -- ► FIX: declar fara init
        variable py : integer;
    begin
        px := to_integer(unsigned(paddle_x));   -- ► FIX: reevaluez la fiecare activare
        py := to_integer(unsigned(paddle_y));

        if (hc < HD) and (vc < VD) then
            -- white border
            if (hc < BORDER) or (hc >= HD-BORDER) or
               (vc < BORDER) or (vc >= VD-BORDER) then
                rgb <= "111";
            -- white paddle
            elsif (hc >= px and hc < px+P_SIZE) and
                  (vc >= py and vc < py+P_SIZE) then
                rgb <= "111";
            else
                rgb <= "000";         -- black background
            end if;
        else
            rgb <= "000";
        end if;
    end process;
end rtl;
