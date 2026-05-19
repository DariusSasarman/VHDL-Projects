library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SSMIPS_InstructionFetch is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           branch : in STD_LOGIC;
           branch_addr : in std_logic_vector(15 downto 0);
           jump : in std_logic;
           jump_addr : in std_logic_vector(15 downto 0);  
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           inc_pc_addr : out std_logic_vector (15 downto 0)
         );
end SSMIPS_InstructionFetch;

--  R-type
--      ADD     : 000_SSS_TTT_DDD_X_000 : R[D] <- R[S] + R[T]
--      SUB     : 000_SSS_TTT_DDD_X_001 : R[D] <- R[S] - R[T]
--      AND     : 000_SSS_TTT_DDD_X_010 : R[D] <- R[S] & R[T]
--      OR      : 000_SSS_TTT_DDD_X_011 : R[D] <- R[S] | R[T]
--      XOR     : 000_SSS_TTT_DDD_X_100 : R[D] <- R[S] ^ R[T]
--      SLT     : 000_SSS_TTT_DDD_X_101 : R[D] <- x"0001" when R[S] < R[T] else x"0000"
--      SLL0    : 000_SSS_TTT_DDD_0_110 : R[D] <- R[S] << 0
--     SLl1     : 000_SSS_TTT_DDD_1_110 : R[D] <- R[S] << 1
--      SRL0    : 000_SSS_TTT_DDD_0_111 : R[D] <- R[S] >> 0
--     SRL1     : 000_SSS_TTT_DDD_1_111 : R[D] <- R[S] >> 1
--  I-type
--      LOADI   : 001_SSS_TTT_IIIIIII : R[T] <- S_ext(III_IIII)
--      ADDI    : 010_SSS_TTT_IIIIIII : R[T] <- R[S] + S_ext(III_IIII) 
--      LW      ; 011_SSS_TTT_AAAAAAA : R[T] <- M[ R[S] + S_Ext(AAA_AAAA)]
--      SW      : 100_SSS_TTT_AAAAAAA : M[ R[S] + S_Ext(AAA_AAAA) ] <- R[T]
--      BEQ     : 101_SSS_TTT_IIIIIII : If(R[S] == R[T]) then PC <- PC + 1 + S_ext(III_IIII)
--      BLT     : 110_SSS_TTT_IIIIIII : If(R[S] < R[T])  then PC <- PC + 1 + S_ext(III_IIII)
-- J-Type
--      JUMP    : 111_AAAAAAAAAAAAA   : PC <- PC + 1 + S_Ext(A_AAAA_AAAA_AAAA)


architecture Behavioral of SSMIPS_InstructionFetch is

signal next_addr : std_logic_vector(15 downto 0);
signal current_addr : std_logic_vector(15 downto 0);
signal current_addr_inc : std_logic_vector(15 downto 0);
signal branch_mux_res : std_logic_vector(15 downto 0);
signal jump_mux_res : std_logic_vector(15 downto 0);

type rom_type is array ( 31 downto 0) of std_logic_vector (15 downto 0);

signal rom : rom_type :=(
    0 => b"001_000_001_0001001"  , -- R[1] <= "1001"        instr== x"2089" // R[1] <= 9 
    1 => b"001_000_010_0000111"  , -- R[2] <= "0111"        instr== x"2107" // R[2] <= 7 
    2 => b"000_001_010_011_0_000", -- R[3] <= R[1] + R[2]   instr== x"0530" // R[3] <= 16
    3 => b"000_001_010_011_0_001", -- R[3] <= R[1] - R[2]   instr== x"0531" // R[3] <= 2
    4 => b"000_001_010_011_0_010", -- R[3] <= R[1] & R[2]   instr== x"0532" // R[3] <= 1
    5 => b"000_001_010_011_0_011", -- R[3] <= R[1] | R[2]   instr== x"0533" // R[3] <= 15
    6 => b"000_001_010_011_0_100", -- R[3] <= R[1] ^ R[2]   instr== x"0534" // R[3] <= 14
    7 => b"000_010_001_011_0_101", -- R[3] <= 1 if(R[2] < R[1]) else 0  instr== x"08b5" // R[3] <= 1
    8 => b"000_010_001_011_1_110", -- R[3] <= S[2] << 1     instr== x"08BE" // R[3] <= 14
    9 => b"000_010_001_011_1_111", -- R[3] <= S[2] >> 1     instr== x"08BF" // R[3] <= 3
    10=> b"100_010_001_0000011"  , -- M[R[2] + 3] <= R[1]   instr== x"8883" // M[10] <= 9
    11=> b"011_010_001_0000011"  , -- R[1] <= M[R[2] + 3]   instr== x"6883" // R[1] <= 9 (M[10])
    12=> b"101_001_001_0000001"  , -- If(R[1]==R[1]) ...    instr== x"A481" // PC <= 14
    13=> b"000_000_000_000_0_000", -- No op ( cause we jump duh )           // Nothing
    14=> b"110_010_001_0000001"  , -- If(R[2] < R[1])...    instr== x"C881" // PC <= 16
    15=> b"000_000_000_000_0_000", -- No op cause we jump, again            // Nothing
    16=> b"010_001_001_0001001"  , -- R[1] <= R[1] + 9      instr== x"4489" // R[1] <= 18
    17=> b"111_0000000000000"    , -- PC <= 0               instr== x"E000" // PC <= 0
    others => x"0000"
);

begin

SCMIPS_PC : process(clk,rst)
begin
    if(rst = '1') then 
        current_addr<= x"0000";
    elsif(rising_edge(clk)) then
        current_addr <= Next_addr;
    end if;
end process;

SCMIPS_IM : instruction <= rom(to_integer(unsigned(current_addr)));

ADD_INC: process(current_addr)
begin
    current_addr_inc <= std_logic_vector(unsigned(current_addr) + 1); 
end process;

inc_pc_addr <= current_addr_inc;

BRANCH_MUX : branch_mux_res <= current_addr_inc when branch = '0' else branch_addr;

JUMP_MUX : jump_mux_res <= branch_mux_res when jump ='0' else jump_addr;

next_addr <= jump_mux_res;

end Behavioral;
