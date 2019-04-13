library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Controller_sim is

end VGA_Controller_sim;


architecture behavioural of VGA_Controller_sim is

  component VGA_Controller
    generic (ROWS    : integer := 525;  --525 2+33+480+10
             COLUMNS : integer := 797);                      --797 95+47+640+15
    port(CLOCK_50       : in  std_logic;
         SW             : in  std_logic_vector(4 downto 0);
         VGA_R          : out std_logic_vector(9 downto 0);
         VGA_G          : out std_logic_vector(9 downto 0);
         VGA_B          : out std_logic_vector(9 downto 0);
         VGA_CLK        : out std_logic;
         VGA_BLANK      : out std_logic;
         VGA_VS         : out std_logic;
         VGA_HS         : out std_logic;
         LEDR           : out std_logic_vector(0 downto 0);  -- AVVISA SE C'E' TRASMISSIONE SERIALE
         LEDG           : out std_logic_vector(0 downto 0);  -- AVVISA SE C'E' AGGIORNAMENTO POSIZIONE
         -- INGRESSI SERIALE
         UART_RXD       : in  std_logic;
         GPIO_1         : in  std_logic_vector(35 downto 0);
         -- SEGNALI DI DEBUG
         GPIO_0         : out std_logic_vector(35 downto 0);
         KEY            : in  std_logic_vector(3 downto 0);
         -- commenta righe seguenti per modalita' release
         X_UPDATE       : in  std_logic_vector(15 downto 0);
         Y_UPDATE       : in  std_logic_vector(15 downto 0);
         Z_UPDATE       : in  std_logic_vector(15 downto 0);
         data_out_ready : in  std_logic
         );

  end component;

  signal CLOCK_50                     : std_logic;
  signal SW                           : std_logic_vector(4 downto 0);
  signal data_out_ready               : std_logic;
  signal X_UPDATE, Y_UPDATE, Z_UPDATE : std_logic_vector(15 downto 0);
  signal KEY                          : std_logic_vector(3 downto 0);

begin

  VGA_ctrl : VGA_CONTROLLER generic map(ROWS => 797, COLUMNS => 525)
    port map(CLOCK_50 => CLOCK_50, SW => SW, UART_RXD => '0', GPIO_1 => (others => '0'), KEY => KEY, data_out_ready => data_out_ready, X_UPDATE => X_UPDATE, Y_UPDATE => Y_UPDATE, Z_UPDATE => Z_UPDATE);

-- Clock a 50 MHz
  CLK : process
  begin
    CLOCK_50 <= '0';
    wait for 10 ns;
    CLOCK_50 <= '1';
    wait for 10 ns;
  end process;

  SIGNALS : process
  begin
    data_out_ready <= '0';
    SW             <= "00001";          -- RESET
    wait for 20 ns;
    SW             <= "00000";
    wait for 20 ns;
-- Lasciare non comentata solo UNA tra le due sezioni seguenti per testare il modulo pulsanti
-- o per testare la sezione di aggiornamento posizione del modulo di controllo seriale.

-- SEGNALI DI DEBUG
-- Le posizioni
-- Dati i seguenti segnali mi aspetto un aggiornamento della posizione a schermo con uno spostamento
-- a destra di uno, un allargamento del quadrato di un fattore 4 x 4 e un innalzamento del quadrato verso
-- l'alto di un pixel
    data_out_ready <= '1';
    X_UPDATE       <= "0000000000000001";
    Y_UPDATE       <= "0000000000000010";
    Z_UPDATE       <= "1111111111111111";
    wait for 20 ns;
    data_out_ready <= '0';
    wait for 20 ns;
---- Data_out_ready non asserito, dunque mi aspetto che la posizione del quadrato NON venga modificata
    data_out_ready <= '0';
    X_UPDATE       <= "1111111111111000";
    Y_UPDATE       <= "1111111111111000";
    Z_UPDATE       <= "1111111111111000";
    wait for 20 ns;
---- Data_out_ready asserito, ora tutte le posizioni devono cambiare
    data_out_ready <= '1';
    X_UPDATE       <= "0000000000000100";
    Y_UPDATE       <= "1111111111111011";
    Z_UPDATE       <= "0000000000000100";
    wait for 20 ns;
    data_out_ready <= '0';
    wait;

-- TEST CON PULSANTI
--SW<="00100"; -- Attiva modalita' di spostamento con pulsanti
--KEY<="0001";
--wait for 50 ns;
--KEY<="0000";
--wait for 20 ns;
--KEY<="0010";
--wait for 20 ns;
--KEY<="0000";
--wait for 20 ns;
--KEY<="0100";
--wait for 20 ns;
--KEY<="0000";
--wait for 20 ns;
--KEY<="1000";
--wait for 20 ns;
--KEY<="0000";
--SW<="1100";
--wait for 20 ns;
--KEY<="0100";
--wait for 20 ns;
--KEY<="0000";
--wait for 20 ns;
--KEY<="1000";
--wait;
  end process;

end behavioural;
