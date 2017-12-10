-- Buffer che prende in ingresso i caratteri che arrivano dalla seriale e salva ,
-- DOPO che sono arrivati sia x che y che z, solo i bit di dato in tre registri da 16 bit
-- (ossia scartando bit di start e bit di stop)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.RS232_CONSTANTS_PKG.all;

entity buff_xyz is
	port (
		clock          : in std_logic;
		reset          : in std_logic;
		data_in_buff   : in std_logic_vector(7 downto 0);
		data_in_ready  : in std_logic;
		data_out_ready : out std_logic;		
		data_out_x     : out std_logic_vector(15 downto 0);
		data_out_y     : out std_logic_vector(15 downto 0);
		data_out_z     : out std_logic_vector(15 downto 0)
);
end entity buff_xyz;

architecture struct of buff_xyz is

--###############################
--signal clear : std_logic;
signal load_reg1 : std_logic;
signal load_reg2 : std_logic;
signal load_reg_buff0 : std_logic;
signal load_reg_buff1 : std_logic;
signal load_reg_buff2 : std_logic;
signal load_reg_buff3 : std_logic;
signal load_reg_buff4 : std_logic;
signal load_reg_buff5 : std_logic;
signal load_out_regs : std_logic; 
--signal en_cnt3 : std_logic; 
--signal tc_cnt3 : std_logic;
signal to_start_stop1 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal to_start_stop2 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal start_byte : std_logic_vector(NBITS_REG_8-1 downto 0);
signal stop_byte : std_logic_vector(NBITS_REG_8-1 downto 0);
signal out_counter3 : std_logic_vector(NBITS_COUNTER-1 downto 0);
signal reg0 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg1 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg2 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg3 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg4 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg5 : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg0_out : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg1_out : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg2_out : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg3_out : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg4_out : std_logic_vector(NBITS_REG_8-1 downto 0);
signal reg5_out : std_logic_vector(NBITS_REG_8-1 downto 0);
signal in_reg_out1 : std_logic_vector(NBITS_REG_16-1 downto 0);
signal in_reg_out2 : std_logic_vector(NBITS_REG_16-1 downto 0);
signal in_reg_out3 : std_logic_vector(NBITS_REG_16-1 downto 0);
--###############################

--###############################
component d_reg is
generic(N : integer);
	port (
		clk : in std_logic;
		rst : in std_logic;
		load: in std_logic;
		d   : in std_logic_vector(N-1 downto 0);
		q   : out std_logic_vector(N-1 downto 0)
);
end component d_reg;



-- è la control unit del frame buffer
component control_unit is
	port (
	   clock      : in std_logic;
      reset		  : in std_logic;
		tc_char    : in std_logic;
		start_byte : in std_logic_vector(7 downto 0);
		stop_byte  : in std_logic_vector(7 downto 0);
		en_reg1    : out std_logic;
		en_reg2    : out std_logic;
		en_reg_buff0: out std_logic;
		en_reg_buff1: out std_logic;
		en_reg_buff2: out std_logic;
		en_reg_buff3: out std_logic;
		en_reg_buff4: out std_logic;
		en_reg_buff5: out std_logic;
		en_out_regs : out std_logic;
		data_out_ready : out std_logic
		
);
end component control_unit;

--###############################

begin

--###########################	
-- i registri IN_REG1 e IN_REG2 servono a salvare i byte di start e di stop
IN_REG1 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg1,
		d    => data_in_buff,
		q    => to_start_stop1
);

IN_REG2 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg2,
		d    => data_in_buff,
		q    => to_start_stop2
);

start_byte <= to_start_stop1 and to_start_stop2 and X"FF";
stop_byte <= not(to_start_stop1) and not(to_start_stop2) and X"FF";



reg0 <= data_in_buff;
reg1 <= data_in_buff;
reg2 <= data_in_buff;
reg3 <= data_in_buff;
reg4 <= data_in_buff;
reg5 <= data_in_buff;

-- registri che servono a salvare i dati in arrivo dalla seriale
REG_0 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg_buff0,
		d    => reg0,
		q    => reg0_out
);

REG_1 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg_buff1,
		d    => reg1,
		q    => reg1_out
);

REG_2 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg_buff2,
		d    => reg2,
		q    => reg2_out
);

REG_3 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg_buff3,
		d    => reg3,
		q    => reg3_out
);

REG_4 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg_buff4,
		d    => reg4,
		q    => reg4_out
);

REG_5 : d_reg	
	generic map (N => NBITS_REG_8)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_reg_buff5,
		d    => reg5,
		q    => reg5_out
);

in_reg_out1 <= reg0_out & reg1_out;

-- registri in cui salviamo i dati che verranno mandati al blocco di controllo della VGA
OUT_REG1 : d_reg	
	generic map (N => NBITS_REG_16)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_out_regs,
		d    => in_reg_out1,
		q    => data_out_x
);

in_reg_out2 <= reg2_out & reg3_out;

OUT_REG2 : d_reg	
	generic map (N => NBITS_REG_16)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_out_regs,
		d    => in_reg_out2,
		q    => data_out_y
);

in_reg_out3 <= reg4_out & reg5_out;

OUT_REG3 : d_reg	
	generic map (N => NBITS_REG_16)
	port map (
		clk  => clock,
		rst  => reset,
		load => load_out_regs,
		d    => in_reg_out3,
		q    => data_out_z
);


-- unità di controllo del frame buffer
CTR_UNIT : control_unit
	port map (
	   clock      => clock,
      reset		  => reset,
		tc_char    => data_in_ready,
		start_byte => start_byte,
		stop_byte  => stop_byte,
		en_reg1    => load_reg1,
		en_reg2    => load_reg2,
		en_reg_buff0 => load_reg_buff0,
		en_reg_buff1=> load_reg_buff1,
		en_reg_buff2=> load_reg_buff2,
		en_reg_buff3=> load_reg_buff3,
		en_reg_buff4=> load_reg_buff4,
		en_reg_buff5=> load_reg_buff5,
	   en_out_regs => load_out_regs,
		data_out_ready => data_out_ready
		
);

--###############################

end architecture struct;