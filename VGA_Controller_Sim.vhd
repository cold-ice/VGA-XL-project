LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY VGA_Controller_sim IS

END VGA_Controller_sim;


ARCHITECTURE behavioural OF VGA_Controller_sim IS

COMPONENT VGA_Controller
GENERIC (ROWS 			: INTEGER:=525;  --525 2+33+480+10
			COLUMNS		: INTEGER:=797); --797 95+47+640+15
PORT(		CLOCK_50 	: IN STD_LOGIC;
			SW			   : IN STD_LOGIC_VECTOR(4 downto 0);
			VGA_R			: OUT STD_LOGIC_VECTOR(9 downto 0);
			VGA_G			: OUT STD_LOGIC_VECTOR(9 downto 0);
			VGA_B			: OUT STD_LOGIC_VECTOR(9 downto 0);
			VGA_CLK		: OUT STD_LOGIC;
			VGA_BLANK	: OUT STD_LOGIC;
			VGA_VS		: OUT STD_LOGIC;
			VGA_HS		: OUT STD_LOGIC;
			LEDR			: OUT STD_LOGIC_VECTOR(0 downto 0); -- AVVISA SE C'E' TRASMISSIONE SERIALE
			LEDG			: OUT STD_LOGIC_VECTOR(0 downto 0); -- AVVISA SE C'E' AGGIORNAMENTO POSIZIONE
			-- INGRESSI SERIALE
			UART_RXD    : IN STD_LOGIC;
			GPIO_1		: IN STD_LOGIC_VECTOR(35 downto 0);
			-- SEGNALI DI DEBUG
			GPIO_0		: OUT STD_LOGIC_VECTOR(35 downto 0);
			KEY			: IN STD_LOGIC_VECTOR(3 downto 0);
			-- commenta righe seguenti per modalita' release
			X_UPDATE		: IN STD_LOGIC_VECTOR(15 downto 0);
			Y_UPDATE		: IN STD_LOGIC_VECTOR(15 downto 0);
			Z_UPDATE		: IN STD_LOGIC_VECTOR(15 downto 0);
			data_out_ready: IN STD_LOGIC
);

END COMPONENT;

SIGNAL CLOCK_50	: STD_LOGIC;
SIGNAL SW			: STD_LOGIC_VECTOR(4 downto 0);
SIGNAL data_out_ready				: STD_LOGIC;
SIGNAL X_UPDATE, Y_UPDATE, Z_UPDATE : STD_LOGIC_VECTOR(15 downto 0);
SIGNAL KEY			: STD_LOGIC_VECTOR(3 downto 0);

BEGIN

VGA_ctrl: VGA_CONTROLLER	GENERIC MAP(ROWS => 797, COLUMNS => 525)
									PORT MAP(CLOCK_50=>CLOCK_50, SW=>SW, UART_RXD=>'0', GPIO_1=>(others=>'0'), KEY=>KEY, data_out_ready=> data_out_ready, X_UPDATE => X_UPDATE, Y_UPDATE=>Y_UPDATE, Z_UPDATE=>Z_UPDATE);
									
-- Clock a 50 MHz
CLK: PROCESS
BEGIN  
CLOCK_50<='0';
wait for 10 ns;
CLOCK_50<='1';
wait for 10 ns;
END PROCESS;

SIGNALS: PROCESS
BEGIN
data_out_ready<='0';
SW<="00001"; -- RESET
wait for 20 ns;
SW<="00000";
wait for 20 ns;
-- Lasciare non comentata solo UNA tra le due sezioni seguenti per testare il modulo pulsanti
-- o per testare la sezione di aggiornamento posizione del modulo di controllo seriale.

-- SEGNALI DI DEBUG
-- Le posizioni
-- Dati i seguenti segnali mi aspetto un aggiornamento della posizione a schermo con uno spostamento
-- a destra di uno, un allargamento del quadrato di un fattore 4 x 4 e un innalzamento del quadrato verso
-- l'alto di un pixel
data_out_ready<='1';
X_UPDATE<="0000000000000001";
Y_UPDATE<="0000000000000010";
Z_UPDATE<="1111111111111111";
wait for 20 ns;
data_out_ready<='0';
wait for 20 ns;
---- Data_out_ready non asserito, dunque mi aspetto che la posizione del quadrato NON venga modificata
data_out_ready<='0';
X_UPDATE<="1111111111111000";
Y_UPDATE<="1111111111111000";
Z_UPDATE<="1111111111111000";
wait for 20 ns;
---- Data_out_ready asserito, ora tutte le posizioni devono cambiare
data_out_ready<='1';
X_UPDATE<="0000000000000100";
Y_UPDATE<="1111111111111011";
Z_UPDATE<="0000000000000100";
wait for 20 ns;
data_out_ready<='0';
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
END PROCESS;

END behavioural;