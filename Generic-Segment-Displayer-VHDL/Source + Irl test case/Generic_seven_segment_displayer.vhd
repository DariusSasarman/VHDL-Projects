library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Generic_seven_segment_displayer is
generic (
    clk_frequency : integer := 100_000_000; -- Measured in HZ
    digit_count   : integer := 8;           -- How many digits are there? 
    refresh_cycle_hz : integer := 300;      -- Refresh cycle 
    segment_count : integer := 8;           -- How many segments are there
    active : std_logic := '0'               -- It can be either active high or active low logic
    );
Port (
    seven_seg_info: in std_logic_vector ( segment_count * digit_count - 1 downto 0);
    clk : in std_logic;
    rst : in std_logic;
    current_digit : out std_logic_vector( segment_count - 1 downto 0);
    digit_selection : out std_logic_vector ( digit_count - 1 downto 0)
 );
end Generic_seven_segment_displayer;

architecture Behavioral of Generic_seven_segment_displayer is

function log2 ( target : integer ) return integer is
    variable result : integer :=0;
    variable target_val : integer := target;
begin
    while target_val > 0 loop
        target_val := target_val / 2;
        result := result + 1;
    end loop;
    if result > 1 then
        return result;
    else 
        return 1;
    end if;
end function;

signal clk_division : integer := 0;
constant digit_bits : integer := log2(digit_count);
signal multiplex_state : std_logic_vector((digit_bits - 1) downto 0) := (others => '0');

begin

-------------------------------------------------------------------------------------------
-- Multiplexing process
-- How it works :
-- Clk_division does the clock frequency ( based on input generic values) 
-- Multiplex_state does the state chaning between ( 0 to digit_count -1)
-------------------------------------------------------------------------------------------
process(clk,rst)
begin
    if(rst = '1') then
        clk_division <= 0;
        multiplex_state <= (others => '0');
    elsif (rising_edge (clk)) then
        if clk_division = ((clk_frequency / ( refresh_cycle_hz * digit_count)) - 1) then
            clk_division <= 0;
            if unsigned(multiplex_state) = digit_count - 1 then
                multiplex_state <= (others => '0');
            else
                multiplex_state <= std_logic_vector(unsigned(multiplex_state) + 1);
            end if;
        else
            clk_division <= clk_division + 1;
        end if;
    end if;
end process;

-------------------------------------------------------------------------------------------
-- Value asigning process
-- How it works:
-- Thanks to making sure in the prevoius process that multiplex_state does not exceed digit_count -1
-- This process just asigns the output.
-- Current_digit is the multiplexed digit
-- Digit_selection is used for picking what digit is written to
-------------------------------------------------------------------------------------------
process(multiplex_state, seven_seg_info)
    variable index : integer := TO_INTEGER ( unsigned (multiplex_state)) ; 
    variable an : std_logic_vector ( digit_count -1 downto 0 ) := (others => '1');
begin
    current_digit <= seven_seg_info (segment_count * (index + 1) - 1 downto segment_count * index);
    an := (others => not active);
    an(index) := active;
    digit_selection <= an;
end process;

end Behavioral;
