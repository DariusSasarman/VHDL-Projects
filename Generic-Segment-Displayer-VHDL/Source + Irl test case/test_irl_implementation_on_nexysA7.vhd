library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- made by me, corrected by A.I.
entity test_irl is
Port (
    clk : in  STD_LOGIC;
    rst : in  STD_LOGIC;
    S   : out STD_LOGIC_VECTOR (7 downto 0);
    AN  : out STD_LOGIC_VECTOR (7 downto 0)
);
end test_irl;

architecture Behavioral of test_irl is

signal c_div           : integer := 0;
signal what_s_up_doc   : std_logic_vector(127 downto 0) := x"C3E1898887FD92FFE38CFFA1A3A72CFF"; 
signal start_display   : integer := 128;
signal stop_display    : integer := 64;
signal display         : std_logic_vector(63 downto 0) := (others => '1');

component Generic_seven_segment_displayer is
    generic (
        clk_frequency    : integer := 100_000_000; -- Measured in Hz
        digit_count      : integer := 8;           -- How many digits?
        refresh_cycle_hz : integer := 300;         -- Refresh cycle
        segment_count    : integer := 8;           -- How many segments?
        active           : std_logic := '0'        -- Active-low or active-high logic
    );
    Port (
        seven_seg_info  : in  std_logic_vector(segment_count * digit_count - 1 downto 0);
        clk             : in  std_logic;
        rst             : in  std_logic;
        current_digit   : out std_logic_vector(segment_count - 1 downto 0);
        digit_selection : out std_logic_vector(digit_count - 1 downto 0)
    );
end component;

begin

C0: Generic_seven_segment_displayer
    port map (
        seven_seg_info  => display,
        clk             => clk,
        rst             => rst,
        current_digit   => S,
        digit_selection => AN
    );

display <= what_s_up_doc(start_display - 1 downto start_display - 64);

process(clk, rst)
begin
    if rst = '1' then
        c_div         <= 0;
        what_s_up_doc <= x"C3E1898887FD92FFE38CFFA1A3A72CFF";
    elsif rising_edge(clk) then
        if c_div = 99999999 then
            c_div <= 0;
            -- Rotate left by 16 bits
            what_s_up_doc(127 downto 16) <= what_s_up_doc(111 downto 0);
            what_s_up_doc(15 downto 0)   <= what_s_up_doc(127 downto 112);
        else
            c_div <= c_div + 1;
        end if;
    end if;
end process;

end Behavioral;
