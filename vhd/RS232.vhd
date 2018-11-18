library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity RS232 is
	port (
		clock, reset  : in std_logic;
		uart_line     : in std_logic;
		data_out_ready: out std_logic;
		data_out      : out std_logic_vector(9 downto 0);
		data_out_x    : out std_logic_vector(15 downto 0);
		data_out_y    : out std_logic_vector(15 downto 0);
		data_out_z    : out std_logic_vector(15 downto 0);
		uart_clock_out: out std_logic;
		status        : out std_logic
);
end entity RS232;

architecture struct of RS232 is

component uart_clock_gen is
	port (
		clock, reset: in std_logic;
		clear       : in std_logic;
		end_val     : in std_logic_vector(15 downto 0);
		uart_clock  : out std_logic
);
end component;

component counter4 is
	port (
		clock, reset: in std_logic;
		clear       : in std_logic;
		end_val     : in std_logic_vector(3 downto 0);
		tc          : out std_logic
);
end component;

component uart_fsm is
	port (
		clock, reset : in std_logic;
		uart_line    : in std_logic;
		tc_char      : in std_logic;
		clear        : out std_logic;
		shift_enable : out std_logic;
		waiting      : out std_logic
);
end component;

component shift_reg10 is
	port (
		uart_clock, reset : in std_logic;
		clear             : in std_logic;
		shift_enable      : in std_logic;
		rx_line           : in std_logic;
		data_out          : out std_logic_vector(9 downto 0)
);
end component;

component buff_xyz is
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
end component;

signal uart_clock, clock_mem, clear, tc_char, shift_enable: std_logic;
signal data_in_ready : std_logic;
signal data_out_aux : std_logic_vector(9 downto 0);
signal data_ready_buff : std_logic;
signal stato : integer := 0;

constant divisor : std_logic_vector(15 downto 0) := "0000101000101011"; -- 2603, baudrate 9600
constant divisor2 : std_logic_vector(15 downto 0) := "0000010100010101"; --1301, baudrate 9600*2
constant bits_per_data : std_logic_vector(3 downto 0) := "1001"; -- 10-1 bits expected

	begin
	
		uart_clock_out <= uart_clock;
		
		c16 : uart_clock_gen 
		  port map(clock, reset, clear, divisor, uart_clock);
		 
		c16bis : uart_clock_gen 
		  port map(clock, reset, clear, divisor2, clock_mem);
		
		c4 : counter4 
		  port map(uart_clock, reset, clear, bits_per_data, tc_char);
		  
		s10 : shift_reg10 
		  port map(uart_clock, reset, clear, shift_enable, uart_line, data_out_aux);
		  
		fsm : uart_fsm 
		  port map(clock, reset, uart_line, tc_char, clear, shift_enable, status);
		  
		buff : buff_xyz
		  port map (
		    clock         => clock_mem,
			 reset         => reset,
			 data_in_buff  => data_out_aux(8 downto 1),
		    data_in_ready => tc_char,
			 data_out_ready=> data_ready_buff,
			 data_out_x    => data_out_x,
			 data_out_y    => data_out_y,
			 data_out_z    => data_out_z
		  );

--@Description:
--		  
PULSE_GEN_PROC : process (clock, reset, data_ready_buff)
begin
  if (reset = '0') then
    data_out_ready <= '0';
	 stato <= 0;
  elsif (clock'event and clock = '1') then
	 case stato is
	   when 0 =>
		  if data_ready_buff = '1' then
		    data_out_ready <= '1';
			 stato <= stato + 1;
		  else
		    data_out_ready <= '0';
		  end if;
		when 1 =>
		  data_out_ready <= '0';
		  stato <= stato + 1;
		when 2 =>
		  if data_ready_buff = '0' then
		    stato <= 0;
		  end if;
		when others =>
		  null;
    end case;
  end if; -- reset
end process PULSE_GEN_PROC;
		  
data_out <= data_out_aux;
 
end architecture struct;