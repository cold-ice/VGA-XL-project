library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_clock_gen is
  port (clock, reset : in  std_logic;
        clear        : in  std_logic;
        end_val      : in  std_logic_vector(15 downto 0);
        uart_clock   : out std_logic
        );
end entity uart_clock_gen;

architecture rtl of uart_clock_gen is

  signal tc, uart_ck_int : std_logic;

  component counter16 is
    port (
      clock, reset : in  std_logic;
      clear        : in  std_logic;
      end_val      : in  std_logic_vector(15 downto 0);
      tc           : out std_logic
      );
  end component counter16;
begin
  c16 : counter16 port map (clock, reset, clear, end_val, tc);
  uart_clock <= uart_ck_int;

  process (tc, clear, reset)
  begin
    if (clear = '0' or reset = '0') then
      uart_ck_int <= '0';
    elsif (rising_edge(tc)) then
      uart_ck_int <= not uart_ck_int;
    end if;
  end process;
end architecture rtl;
