library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SSMIPS is
    Port ( clk : in STD_LOGIC;
           rst : in STD_Logic;
           
           instruction_out : out std_logic_vector(15 downto 0);
           next_branch_addr_out : out std_logic_vector(15 downto 0);
           RD1_out : out std_logic_vector(15 downto 0);
           RD2_out : out std_logic_vector(15 downto 0);
           extImm_out : out std_logic_vector(15 downto 0);
           aluRes_out : out std_logic_vector(15 downto 0);
           memData_out : out std_logic_vector(15 downto 0);
           WD_out : out std_logic_vector(15 downto 0);
           
           cu_aluop_out : out std_logic_vector(1 downto 0); 
           cu_regdst_out : out std_logic;
           cu_extop_out : out std_logic;
           cu_regWrite_out : out std_logic;
           
           cu_branch_out : out std_logic;
           cu_branch_type_out : out std_logic;
           
           cu_jump_out : out std_logic ;
           cu_aluSrcB_out : out std_logic ;
           cu_memWrite_out : out std_logic;
           cu_memToReg_out : out std_logic 
         );
end SSMIPS;
    
architecture Behavioral of SSMIPS is

-- Instruction Fetch
signal instruction : STD_LOGIC_VECTOR (15 downto 0) := x"0000";

-- Instruction decode 
signal RD1 : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal RD2 : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal WD : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal extImm : STD_LOGIC_VECTOR (15 downto 0) := x"0000";
signal func : std_Logic_vector (2 downto 0) := "000";
signal sa : std_logic := '0';

-- Branch
signal branch_addr : std_logic_vector(15 downto 0) := x"0000";
signal jump_addr : std_logic_vector(15 downto 0) := x"0000";
signal should_branch : std_logic;

-- Instruction Execute
signal increased_pc_addr : std_logic_vector ( 15 downto 0):=x"0000";
signal aluRes : std_logic_vector ( 15 downto 0):=x"0000";
signal zero : std_logic := '0';
signal negative : std_Logic := '0';

-- Memory Unit
signal MemAluRes : std_logic_vector ( 15 downto 0):=x"0000";
signal MemData : std_logic_vector ( 15 downto 0):=x"0000";


-- CU Signals 
signal cu_aluop : std_logic_vector(1 downto 0) := "00";

signal cu_regdst : std_logic := '0';
signal cu_extop : std_logic := '0';
signal cu_regWrite : std_logic := '0';
signal cu_branch : std_logic := '0';
signal cu_branch_type : std_logic := '0';
signal cu_jump : std_logic := '0';
signal cu_aluSrcB : std_logic := '0';
signal cu_memWrite : std_logic := '0';
signal cu_memToReg : std_logic :='0';


component SSMIPS_CU is
    Port ( instruction : in STD_LOGIC_VECTOR (15 downto 13);
           AluOp : out STD_LOGIC_VECTOR(1 downto 0);
           RegDst : out STD_LOGIC;
           ExtOP : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Branch_type : out std_logic;
           Jump : out STD_LOGIC;
           AluSrcB : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           MemToReg : out STD_LOGIC);
end component;

component SSMIPS_InstructionFetch is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           branch : in STD_LOGIC;
           branch_addr : in std_logic_vector(15 downto 0);
           jump : in std_logic;
           jump_addr : in std_logic_vector(15 downto 0);  
           instruction : out STD_LOGIC_VECTOR (15 downto 0);
           inc_pc_addr : out std_logic_vector (15 downto 0)
         );
end component;

component SSMIPS_Decode is
    Port ( regWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           clk : in std_logic ;
           rst : in std_logic;
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
           immExt : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out std_logic);
end component;

component SSMIPS_InstructionExecute is
    Port ( PC_INC : in STD_LOGIC_VECTOR (15 downto 0);
    
           RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           EXT_IMM : in STD_LOGIC_VECTOR (15 downto 0);
           AluSrc : in std_logic;
           
           sa : in STD_LOGIC;
           Func : in STD_LOGIC_VECTOR (2 downto 0);
           ALUOP : in STD_LOGIC_VECTOR (1 downto 0);
           
           BranchAddress : out STD_LOGIC_VECTOR (15 downto 0);
           AluRes : out STD_LOGIC_VECTOR (15 downto 0);

           zero : out STD_LOGIC;
           negative : out STD_LOGIC);
end component;

component SSMIPS_MemoryUnit is
    Port ( memWrite : in STD_LOGIC;
           rst : in std_logic;
           clk : in STD_LOGIC;
           AluResIn : in STD_LOGIC_VECTOR (15 downto 0);
           WDMem : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           AluResOut : out STD_LOGIC_VECTOR (15 downto 0)
         );
end component;

begin
SCMIPS_CU : SSMIPS_CU port map ( instruction => instruction (15 downto 13),
                                 aluop => cu_aluop, regdst => cu_regdst,
                                 extop => cu_extop, regwrite => cu_regwrite,
                                 branch => cu_branch, branch_type => cu_branch_type,
                                 jump => cu_jump, alusrcb => cu_alusrcb,
                                 memwrite => cu_memwrite, memtoreg => cu_memtoreg);


SCMIPS_InstructionFetch : SSMIPS_InstructionFetch port map ( 
                                clk => clk, rst => rst, 
                                branch => should_branch,
                                branch_addr => branch_addr,
                                jump => cu_jump,
                                jump_addr => jump_addr,
                                instruction => instruction,
                                inc_pc_addr => increased_pc_addr);
                                
should_branch <= '1' when ( cu_branch = '1' and 
                          (( zero = '1' and cu_branch_type = '0') or 
                          (negative ='1' and cu_branch_type ='1')))
                  else '0';

ADDR_EXT : process(instruction)
begin
    jump_addr <= std_logic_vector("000" & signed( instruction(12 downto 0)));                    
end process;

SCMIPS_Dec : SSMIPS_Decode port map ( 
                RegWrite => cu_regWrite, RegDst => cu_regdst,
                Extop => cu_ExtOp, clk => clk, rst => rst, WD => WD,
                Instr => instruction, RD1 => RD1, RD2 => RD2,
                immExt => extImm, func => func, sa => sa);
                
SCMIPS_InstrExec : SSMIPS_InstructionExecute port map(
                PC_INC => increased_pc_addr,
                RD1 => RD1, RD2 => RD2, EXT_IMM => extImm,
                aluSrc => cu_aluSrcB,Func => func,
                aluOp => cu_aluop, sa => sa,
                BranchAddress => branch_addr,
                AluRes => aluRes,
                zero => zero,
                negative => negative);
                
SCMIPS_MemUnit : SSMIPS_MemoryUnit port map(
                    memWrite => cu_memWrite,
                    clk => clk,
                    rst => rst,
                    AluResIn => AluRes,
                    WDMem => RD2,
                    MemData => MemData,
                    AluResOut => MemAluRes);

WD <= MemAluRes when cu_memtoreg = '0' else MemData;


instruction_out <= instruction;
next_branch_addr_out <= increased_pc_addr;
RD1_out <= RD1;
RD2_out <= RD2;
extImm_out <= extImm;
aluRes_out <= aluRes;
memData_out <= memData;
WD_out <= WD;
cu_aluop_out <= cu_aluop; 
cu_regdst_out <= cu_regdst;
cu_extop_out <= cu_extop;
cu_regWrite_out <= cu_regWrite;
cu_branch_out <= cu_branch;
cu_branch_type_out <= cu_branch_type;
cu_jump_out <= cu_jump;
cu_aluSrcB_out <= cu_aluSrcB;
cu_memWrite_out <= cu_memWrite;
cu_memToReg_out <= cu_memToReg;

end Behavioral;
