-- Legal statement pending

-- File            : RS232_TB.vhd
-- Author       : Deborah Calabrese
-- Date            : 14/12/2016
-- Version      : 0.1
-- Abstract : UART Receiver with data buffer for VGA module
--            input data
--
-- Modification History:
-- Date                    By    Version        Change          Description
--================================================================
-- 14/12/2016   DC        0.1      Original
--================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RS232_TB is
end RS232_TB;

architecture behavior of RS232_TB is

  component RS232_BUFF_STRUCT
    port (
      clk            : in  std_logic;
      rst            : in  std_logic;
      uart_line      : in  std_logic;
      data_out_ready : out std_logic;
      data_out       : out std_logic_vector(9 downto 0);
      data_out_x     : out std_logic_vector(15 downto 0);
      data_out_y     : out std_logic_vector(15 downto 0);
      data_out_z     : out std_logic_vector(15 downto 0);
      uart_clock_out : out std_logic;
      status         : out std_logic
      );
  end component;

  signal clock          : std_logic;
  signal reset          : std_logic;
  signal uart_line      : std_logic;
  signal data_out       : std_logic_vector(9 downto 0);
  signal shift_reg      : std_logic_vector(7 downto 0);  --è un segnale di appoggio (è un PISO) per far enrare nella uart
  signal uart_clock_out : std_logic;  -- i miei vettori di test che sono paralleli come seriali
  signal status         : std_logic;
  signal data_out_ready : std_logic;
  -- aggiunti da me
  signal data_out_x     : std_logic_vector(15 downto 0);
  signal data_out_y     : std_logic_vector(15 downto 0);
  signal data_out_z     : std_logic_vector(15 downto 0);

  constant PERIOD    : time      := 20 ns;
  constant start_bit : std_logic := '0';
  constant stop_bit  : std_logic := '1';

  type TEST_TYPE is array (0 to 9) of std_logic_vector(7 downto 0);

  constant TEST_VECTOR : TEST_TYPE := (
    X"FF", X"FF", X"44", X"45", X"42",
    X"4F", X"52", X"41", X"00", X"00"
    );

begin

-- Please check and add your generic clause manually
  uut : RS232_BUFF_STRUCT
    port map(
      clk            => clock,
      rst            => reset,
      uart_line      => uart_line,
      data_out_ready => data_out_ready,
      data_out       => data_out,
      uart_clock_out => uart_clock_out,  --add data_out_x and so on to port mapping
      data_out_x     => data_out_x,
      data_out_y     => data_out_y,
      data_out_z     => data_out_z,
      status         => status
      );

-- STATUS DEVE ESSERE GENERATO UN CLK CYCLE PRIMA
-- *** Test Bench - User Defined Section ***
  tb : process
  begin
    uart_line <= '1';
    shift_reg <= TEST_VECTOR(0);
    wait until reset = '1';
    report "==== TEST 1: Send message with the proper sequence of start and stop bytes ====" severity note;
    wait until uart_clock_out'event and uart_clock_out = '0';
    --Send first start byte
    uart_line <= start_bit;
    wait until uart_clock_out'event and uart_clock_out = '0';
    for i in 0 to 7 loop
      uart_line             <= shift_reg(7);
      shift_reg(7 downto 1) <= shift_reg(6 downto 0);
      wait until uart_clock_out'event and uart_clock_out = '0';
    end loop;  -- i
    uart_line <= stop_bit;
    for j in 1 to 9 loop
      -- Load new value
      shift_reg <= TEST_VECTOR(j);
      wait until uart_clock_out'event and uart_clock_out = '0';
      --Send second start byte
      uart_line <= start_bit;
      wait until uart_clock_out'event and uart_clock_out = '0';
      for i in 0 to 7 loop
        uart_line             <= shift_reg(7);
        shift_reg(7 downto 1) <= shift_reg(6 downto 0);
        wait until uart_clock_out'event and uart_clock_out = '0';
      end loop;  -- i
      uart_line <= stop_bit;
    end loop;  -- j
--      -- Load new value
--      shift_reg <= TEST_VECTOR(2);
--      wait until uart_clock_out'event and uart_clock_out = '1';
--      --Send character D
--      uart_line <= start_bit;
--      wait until uart_clock_out'event and uart_clock_out = '1';
--      for i in 0 to 7 loop
--        uart_line <= shift_reg(7);
--        shift_reg(7 downto 1) <= shift_reg(6 downto 0);
--     wait until uart_clock_out'event and uart_clock_out = '1';
--   end loop;  -- i
--      uart_line <= stop_bit;
--      -- Load new value
--      shift_reg <= TEST_VECTOR(3);
--      wait until uart_clock_out'event and uart_clock_out = '1';
--      -- Send character E
--      uart_line <= start_bit;
--      wait until uart_clock_out'event and uart_clock_out = '1';
--      for i in 0 to 7 loop
--        uart_line <= shift_reg(7);
--        shift_reg(7 downto 1) <= shift_reg(6 downto 0);
--     wait until uart_clock_out'event and uart_clock_out = '1';
--   end loop;  -- i
--      uart_line <= stop_bit;
--      -- Load new value
--      shift_reg <= TEST_VECTOR(4);
--      wait until uart_clock_out'event and uart_clock_out = '1';
--      -- Send character B
--      uart_line <= start_bit;
--      wait until uart_clock_out'event and uart_clock_out = '1';
--      for i in 0 to 7 loop
--        uart_line <= shift_reg(7);
--        shift_reg(7 downto 1) <= shift_reg(6 downto 0);
--    wait until uart_clock_out'event and uart_clock_out = '1';
--   end loop;  -- i
--      uart_line <= stop_bit;
    wait;                               -- will wait forever
  end process;
-- *** End Test Bench - User Defined Section ***

--==========================
--Clock generation process
--==========================
  clock_PROC : process
  begin
    for i in 0 to 200000 loop
      clock <= '1';
      wait for PERIOD/2;
      clock <= '0';
      wait for PERIOD/2;
    end loop;
    wait;
  end process clock_PROC;

--======================
--Reset process
--======================
  RST_PROC : process
  begin
    reset <= '0';
    wait for PERIOD*2;
    reset <= '1';
    wait;
  end process RST_PROC;

end;
