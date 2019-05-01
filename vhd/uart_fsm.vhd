library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart_fsm is
  port (clock, reset : in  std_logic;
        uart_line    : in  std_logic;
        tc_char      : in  std_logic;
        clear        : out std_logic;
        shift_enable : out std_logic;
        waiting      : out std_logic
        );
end entity uart_fsm;

architecture rtl of uart_fsm is
  type state is (UART_IDLE, CLEAR_CLOCK, UART_DATA);
  signal current_state, next_state : state;
begin
  process (clock, reset)
  begin
    if (reset = '0') then
      current_state <= UART_IDLE;
    elsif (rising_edge(clock)) then
      current_state <= next_state;
    end if;
  end process;

  process (current_state, next_state, uart_line, tc_char)
  begin
    clear        <= '1';
    shift_enable <= '0';
    waiting      <= '1';

    case current_state is
      when UART_IDLE =>
        clear        <= '1';
        shift_enable <= '0';
        waiting      <= '1';

        if (uart_line = '0') then
          next_state <= CLEAR_CLOCK;
        else
          next_state <= UART_IDLE;
        end if;

      when CLEAR_CLOCK =>
        clear        <= '0';
        shift_enable <= '0';
        waiting      <= '0';
        next_state   <= UART_DATA;

      when UART_DATA =>
        clear        <= '1';
        shift_enable <= '1';
        waiting      <= '0';
        if (tc_char = '0') then
          next_state <= UART_DATA;
        else
          next_state <= UART_IDLE;
        end if;
      when others =>
        next_state <= UART_IDLE;
    end case;
  end process;
end architecture rtl;
