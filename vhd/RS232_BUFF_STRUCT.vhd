library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.RS232_CONSTANTS_PKG.all;

entity RS232_BUFF_STRUCT is
  port (clk            : in  std_logic;
        rst            : in  std_logic;
        uart_line      : in  std_logic;
        data_out_ready : out std_logic;  -- Segnale che abilita l'aggiornamento della posizione a schermo
        data_out       : out std_logic_vector(9 downto 0);
        -- Segnali di aggiornamento posizione a schermo
        data_out_x     : out std_logic_vector(15 downto 0);
        data_out_y     : out std_logic_vector(15 downto 0);
        data_out_z     : out std_logic_vector(15 downto 0);
        uart_clock_out : out std_logic;
        status         : out std_logic  -- Segnale che avvisa che sta avvenendo una trasmissione seriale (attivo basso)
        );
end entity RS232_BUFF_STRUCT;

architecture struct of RS232_BUFF_STRUCT is


  component uart_clock_gen is
    port (
      clock, reset : in  std_logic;
      clear        : in  std_logic;
      end_val      : in  std_logic_vector(15 downto 0);
      uart_clock   : out std_logic
      );
  end component;

  component counter4 is
    port (
      clock, reset : in  std_logic;
      clear        : in  std_logic;
      end_val      : in  std_logic_vector(3 downto 0);
      tc           : out std_logic
      );
  end component;

  component uart_fsm is
    port (
      clock, reset : in  std_logic;
      uart_line    : in  std_logic;
      tc_char      : in  std_logic;
      clear        : out std_logic;
      shift_enable : out std_logic;
      waiting      : out std_logic
      );
  end component;

  component shift_reg10 is
    port (
      uart_clock, reset : in  std_logic;
      clear             : in  std_logic;
      shift_enable      : in  std_logic;
      rx_line           : in  std_logic;
      data_out          : out std_logic_vector(9 downto 0)
      );
  end component;

  component buff_xyz is
    port (
      clock          : in  std_logic;
      reset          : in  std_logic;
      data_in_buff   : in  std_logic_vector(7 downto 0);
      data_in_ready  : in  std_logic;
      data_out_ready : out std_logic;
      data_out_x     : out std_logic_vector(15 downto 0);
      data_out_y     : out std_logic_vector(15 downto 0);
      data_out_z     : out std_logic_vector(15 downto 0)
      );
  end component;

  signal uart_clock, clock_mem, clear, tc_char, shift_enable : std_logic;
  signal data_in_ready                                       : std_logic;
  signal data_out_aux                                        : std_logic_vector(9 downto 0);
  signal data_ready_buff                                     : std_logic;
  signal stato                                               : integer                       := 0;
-- end val del contatore su 16 bit che serve a generare il clock del blocco di ricezione della seriale
  constant divisor                                           : std_logic_vector(15 downto 0) := "0000101000101011";  -- (50*10^6/(9600*2))-1
--end val del contatore su 16 bit che serve a generare il clock del buffer frame
  constant divisor2                                          : std_logic_vector(15 downto 0) := "0000010100010101";  -- (50*10^6/(9600*4))-1
-- end val del contatore su 4 bit che serve a contare quanti bit sono arrivati dalla linea seriale
  constant bits_per_data                                     : std_logic_vector(3 downto 0)  := "1001";  -- 10-1 bits expected

begin


  uart_clock_out <= uart_clock;
  -- genera il clock (9600Hz) del blocco di ricezione dell'interfaccia seriale
  c16 : uart_clock_gen
    port map(clk, rst, clear, divisor, uart_clock);
  -- genera il clock (19200Hz) del blocco frame buffer riportato nella relazione alla sezione datapath
  c16bis : uart_clock_gen
    port map(clk, rst, clear, divisor2, clock_mem);
  -- Conta i bit in ingresso dalla linea seriale e quando ne sono arrivati 10 (con inclusi bit di start e stop)
  -- il terminal        counter va a '1' segnalando che � arrivato un carattere completo
  c4 : counter4
    port map(uart_clock, rst, clear, bits_per_data, tc_char);
  -- Effettua uno shift a destra in modo tale che alla fine della ricezione si abbia l'MSB in posizione di peso 2^8
  -- e LSB in posizione di peso 2^1
  s10 : shift_reg10
    port map(uart_clock, rst, clear, shift_enable, uart_line, data_out_aux);
  -- � la control unit del blocco di ricezione dell'interfaccia seriale (vedi report)
  fsm : uart_fsm
    port map(clk, rst, uart_line, tc_char, clear, shift_enable, status);
  -- � il component che fa il controllo sul frame e manda in uscita i dati x_update, y_update, z_update e
  --    asserisce il segnale data_out_ready, ma solo se se la ricezione � avvenuta correttamente e il protocollo
  -- � stato rispettato.
  buff : buff_xyz
    port map (
      clock          => clock_mem,
      reset          => rst,
      data_in_buff   => data_out_aux(8 downto 1),
      data_in_ready  => tc_char,
      data_out_ready => data_ready_buff,
      data_out_x     => data_out_x,
      data_out_y     => data_out_y,
      data_out_z     => data_out_z
      );

--@Description: processo che mantiene alto il segnala data_out_ready per un solo colpo di clock(50MHz) in modo tale che questo segnale
--              possa essere utilizzato come load dei registri di update della vga.

  PULSE_GEN_PROC : process (clk, rst, data_ready_buff)
  begin
    if (rst = '0') then
      data_out_ready <= '0';
      stato          <= 0;
    elsif (clk'event and clk = '1') then
      case stato is
        when 0 =>
          if data_ready_buff = '1' then
            data_out_ready <= '1';
            stato          <= stato + 1;
          else
            data_out_ready <= '0';
          end if;
        when 1 =>
          data_out_ready <= '0';
          stato          <= stato + 1;
        when 2 =>
          if data_ready_buff = '0' then
            stato <= 0;
          end if;
        when others =>
          null;
      end case;
    end if;  -- reset
  end process PULSE_GEN_PROC;

  data_out <= data_out_aux;

end architecture struct;
