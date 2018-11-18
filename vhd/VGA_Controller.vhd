LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY VGA_Controller IS

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
			KEY			: IN STD_LOGIC_VECTOR(3 downto 0)--;
			-- commenta righe seguenti per modalita' release o decommentale per modalita' testbench
--			X_UPDATE		: IN STD_LOGIC_VECTOR(15 downto 0);
--			Y_UPDATE		: IN STD_LOGIC_VECTOR(15 downto 0);
--			Z_UPDATE		: IN STD_LOGIC_VECTOR(15 downto 0);
--			data_out_ready: IN STD_LOGIC
);

END VGA_Controller;

ARCHITECTURE behavioural OF VGA_Controller IS

COMPONENT RS232_BUFF_STRUCT
PORT (
		clk           : in std_logic;
		rst           : in std_logic;
		uart_line     : in std_logic;
		data_out_ready: out std_logic;
		data_out      : out std_logic_vector(9 downto 0);
		data_out_x    : out std_logic_vector(15 downto 0);
		data_out_y    : out std_logic_vector(15 downto 0);
		data_out_z    : out std_logic_vector(15 downto 0);
		uart_clock_out: out std_logic;
		status        : out std_logic
);
END COMPONENT;

COMPONENT CU_VGA_H
GENERIC (COLUMNS			: INTEGER);
PORT(		CLOCK_50  		: IN  STD_LOGIC;
			RESET				: IN STD_LOGIC;
			COLUMN			: IN INTEGER RANGE 0 to COLUMNS;
			HC_EN				: OUT STD_LOGIC;
			VC_EN				: OUT STD_LOGIC;
			STR_EN			: OUT STD_LOGIC;
			HC_CL				: OUT STD_LOGIC;
			RGB_CTRL			: OUT STD_LOGIC;
			HS_CTRL			: OUT STD_LOGIC
);
END COMPONENT;

COMPONENT CU_VGA_V
GENERIC (ROWS				: INTEGER);
PORT(		CLOCK_50  		: IN  STD_LOGIC;
			RESET				: IN STD_LOGIC;
			ROW				: IN INTEGER RANGE 0 to ROWS;
			VC_CL				: OUT STD_LOGIC;
			RGB_CTRL			: OUT STD_LOGIC;
			VS_CTRL			: OUT STD_LOGIC
);
END COMPONENT;

COMPONENT DATAPATH
GENERIC (ROWS				: INTEGER;
			COLUMNS			: INTEGER);
PORT(		CLOCK_50  		: IN  STD_LOGIC;
			HC_EN				: IN STD_LOGIC;
			VC_EN				: IN STD_LOGIC;
			STR_EN			: IN STD_LOGIC;
			RGB_EN			: IN STD_LOGIC;
			HS_CTRL			: IN STD_LOGIC;
			VS_CTRL			: IN STD_LOGIC;
			HC_CL				: IN STD_LOGIC;
			VC_CL				: IN STD_LOGIC;
			ROW				: OUT INTEGER RANGE 0 to ROWS;
			COLUMN			: OUT INTEGER RANGE 0 to COLUMNS;
			R					: OUT STD_LOGIC_VECTOR(9 downto 0);
			G					: OUT STD_LOGIC_VECTOR(9 downto 0);
			B					: OUT STD_LOGIC_VECTOR(9 downto 0);
			VS					: OUT STD_LOGIC;
			HS					: OUT STD_LOGIC;
			VGA_CLK			: OUT STD_LOGIC;
			X_UPDATE 		: IN SIGNED(15 downto 0);
			Y_UPDATE 		: IN SIGNED(15 downto 0);
			Z_UPDATE			: IN SIGNED(15 downto 0);
			data_out_ready	: IN STD_LOGIC
);
END COMPONENT;

SIGNAL HC_EN, VC_EN, STR_EN, HC_CL, VC_CL, RGB_EN, HS_CTRL, VS_CTRL	: STD_LOGIC;
SIGNAL X_UPDATE_S, Y_UPDATE_S, Z_UPDATE_S										: SIGNED(15 downto 0);
SIGNAL RGB_CTRL 																		: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL ROW 																				: INTEGER RANGE 0 to 525;
SIGNAL COLUMN 																			: INTEGER RANGE 0 TO 797;
SIGNAL NRES, uart_line																: STD_LOGIC;
--Segnali per spostare con bottoni
SIGNAL DATA_READY_KEY, FLAG, DATA_READY										: STD_LOGIC;
SIGNAL X_BUFF, Y_BUFF, Z_BUFF, X_KEY, Y_KEY, Z_KEY							: SIGNED(15 downto 0);
-- Commenta le due seguenti righe per modalita' testbench
SIGNAL X_UPDATE, Y_UPDATE, Z_UPDATE											: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL data_out_ready																: STD_LOGIC;

BEGIN

RGB_EN<=RGB_CTRL(0) AND RGB_CTRL(1); -- RGB_CTRL(0) e RGB_CTRL(1) sono inviati dalle due unita' di controllo per
												 -- avvisare che ci troviamo nella fase VIDEO ON e che il segnale video puo'
												 -- essere inviato.

VGA_BLANK <= '1'; -- Il VGA BLANK e' attivo basso

NRES <= NOT SW(0); -- Segnale di reset inviato al modulo RS232, che ha reset attivo basso

-- Da modulo RS232 a Datapath. Occorre convertire STD_LOGIC_VECTOR in SIGNED
X_UPDATE_S <= signed(X_UPDATE);
Y_UPDATE_S <= signed(Y_UPDATE);
Z_UPDATE_S <= signed(Z_UPDATE);

-- Segnale per vedere se sta avvenendo un aggiornamento della posizione del quadrato
LEDG(0) <= DATA_READY;

-- Commenta la riga seguente per modalita' testbench
serial: RS232_BUFF_STRUCT PORT MAP (CLOCK_50, NRES, uart_line, data_out_ready, open, X_UPDATE, Y_UPDATE, Z_UPDATE, open, LEDR(0));

-- Unita' di controllo della scansione orizzontale
CU_H: CU_VGA_H GENERIC MAP(COLUMNS => COLUMNS)
					PORT MAP(CLOCK_50, SW(0), COLUMN, HC_EN, VC_EN, STR_EN, HC_CL, RGB_CTRL(0), HS_CTRL);

-- Unita' di controllo della scansione verticale
CU_V: CU_VGA_V GENERIC MAP(ROWS => ROWS)
					PORT MAP(CLOCK_50, SW(0), ROW, VC_CL, RGB_CTRL(1), VS_CTRL);							

-- Datapath del componente di controllo VGA					
DP: DATAPATH 	GENERIC MAP(ROWS => ROWS, COLUMNS => COLUMNS)
					PORT MAP(CLOCK_50, HC_EN, VC_EN, STR_EN, RGB_EN, HS_CTRL, VS_CTRL, HC_CL, VC_CL, ROW, COLUMN, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, VGA_CLK, X_BUFF, Y_BUFF, Z_BUFF, DATA_READY);

--------------------------------------------SEZIONE DI TESTING------------------------------------------------------
					
-- Con SW(1) si seleziona la modalita': 0 ingresso seriale via UART_RXD, 1 ingresso seriale via GPIO_1(13)
-- Nota: ci siamo poi resi conto dell'inutilita' di poter selezionare l'ingresso UART_RXD come input seriale.
WITH SW(1) SELECT uart_line <= 	NOT(UART_RXD) when '0',
											GPIO_1(13) when '1',
											UART_RXD when others;
											
WITH SW(1) SELECT GPIO_0(0) <= 	UART_RXD when '0',
											GPIO_1(13) when '1',
											UART_RXD when others;					
					
-- Con SW(2) si seleziona la modalita': 0 spostamento via seriale, 1 spostamento via bottoni
WITH SW(2) SELECT X_BUFF <= 	X_UPDATE_S when '0',
										X_KEY when '1',
										X_UPDATE_S when others;

WITH SW(2) SELECT Y_BUFF <= 	Y_UPDATE_S when '0',
										Y_KEY when '1',
										Y_UPDATE_S when others;
										
WITH SW(2) SELECT Z_BUFF <=	Z_UPDATE_S when '0',
										Z_KEY when '1',
										Z_UPDATE_S when others;
										
WITH SW(2) SELECT DATA_READY <=	data_out_ready when '0',
											DATA_READY_KEY	when '1',
											data_out_ready when others;											
											
-- Process per spostare figura tramite bottoni.
--Con SW(3) si scegliere se spostare su/giu' o ingrandire/rimpicciolire.
--Dato che KEY(3) sembra difettoso, SW(4) si usa per scegliere se KEY(2) aumenta o diminuisce la coordinata.
POSupdate: PROCESS(CLOCK_50, SW)
BEGIN
IF(SW(0)='1') THEN
	X_KEY <= (others=>'0');
	Y_KEY <= (others=>'0');
	Z_KEY <= (others=>'0');
	DATA_READY_KEY<='0';
	FLAG<='1';
ELSIF(CLOCK_50='1' AND CLOCK_50'event) THEN
	IF(KEY(0)='0' AND FLAG='1') THEN -- Sposta a destra
		X_KEY<="0000000000000001";
		Y_KEY <= (others=>'0');
		Z_KEY <= (others=>'0');
		DATA_READY_KEY<='1';
	ELSIF(KEY(1)='0' AND FLAG='1') THEN -- Sposta a sinistra
		X_KEY<="1111111111111111";
		Y_KEY <= (others=>'0');
		Z_KEY <= (others=>'0');
		DATA_READY_KEY<='1';
	ELSIF(KEY(2)='0' AND FLAG='1' AND SW(3)='0' AND SW(4)='0') THEN -- Sposta in alto
		Z_KEY<="0000000000000001";
		X_KEY<=(others=>'0');
		Y_KEY<=(others=>'0');
		DATA_READY_KEY<='1';
	ELSIF(KEY(2)='0' AND FLAG='1' AND SW(3)='0' AND SW(4)='1') THEN -- Sposta in basso
		Z_KEY<="1111111111111111";
		X_KEY<=(others=>'0');
		Y_KEY<=(others=>'0');
		DATA_READY_KEY<='1';
	ELSIF(KEY(2)='0' AND FLAG='1' AND SW(3)='1' AND SW(4)='0') THEN -- Rimpicciolisce
		Y_KEY<="0000000000000001";
		X_KEY<=(others=>'0');
		Z_KEY<=(others=>'0');
		DATA_READY_KEY<='1';
	ELSIF(KEY(2)='0' AND FLAG='1' AND SW(3)='1' AND SW(4)='1') THEN -- Allarga
		Y_KEY<="1111111111111111";
		X_KEY<=(others=>'0');
		Z_KEY<=(others=>'0');
		DATA_READY_KEY<='1';
	ELSIF(FLAG='0') THEN
		X_KEY <= (others=>'0');
		Y_KEY <= (others=>'0');
		Z_KEY <= (others=>'0');
		DATA_READY_KEY<='0';
	END IF;
	FLAG<=KEY(0) AND KEY(1) AND KEY(2) AND KEY(3);
END IF;
END PROCESS;
END behavioural;