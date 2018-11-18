LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY DATAPATH IS

GENERIC (ROWS			: INTEGER;
			COLUMNS		: INTEGER);
PORT(		CLOCK_50  	: IN  STD_LOGIC;
			HC_EN			: IN STD_LOGIC;
			VC_EN			: IN STD_LOGIC;
			STR_EN		: IN STD_LOGIC;
			RGB_EN		: IN STD_LOGIC;
			HS_CTRL		: IN STD_LOGIC;
			VS_CTRL		: IN STD_LOGIC;
			HC_CL			: IN STD_LOGIC;
			VC_CL			: IN STD_LOGIC;
			ROW			: OUT INTEGER RANGE 0 to 525;
			COLUMN		: OUT INTEGER RANGE 0 to 797;
			R				: OUT STD_LOGIC_VECTOR(9 downto 0);
			G				: OUT STD_LOGIC_VECTOR(9 downto 0);
			B				: OUT STD_LOGIC_VECTOR(9 downto 0);
			VS				: OUT STD_LOGIC;
			HS				: OUT STD_LOGIC;
			VGA_CLK		: OUT STD_LOGIC;
			X_UPDATE 	: IN SIGNED(15 downto 0);
			Y_UPDATE 	: IN SIGNED(15 downto 0);
			Z_UPDATE		: IN SIGNED(15 downto 0);
			data_out_ready	: IN STD_LOGIC
);

END DATAPATH;

ARCHITECTURE behavioural OF DATAPATH IS

COMPONENT COUNTER_COLUMN
PORT(		STROBE  			: IN STD_LOGIC;
			EN					: IN STD_LOGIC;
			CL					: IN STD_LOGIC;
			COUNT_X			: OUT INTEGER RANGE 0 TO 797
);
END COMPONENT;

COMPONENT COUNTER_ROW
PORT(		STROBE  			: IN STD_LOGIC;
			EN					: IN STD_LOGIC;
			CL					: IN STD_LOGIC;
			COUNT_Y			: OUT INTEGER RANGE 0 TO 525
);
END COMPONENT;

COMPONENT STROBE_GEN
GENERIC (DIVIDER			: INTEGER);
PORT(		CLOCK_50  		: IN STD_LOGIC;
			EN					: IN STD_LOGIC;
			STROBE			: OUT STD_LOGIC
);
END COMPONENT;

COMPONENT VGA_DECODER
GENERIC (ROWS			: INTEGER;
			COLUMNS		: INTEGER);
PORT(		ROW  			: IN INTEGER RANGE 0 to 525;
			COLUMN  		: IN INTEGER RANGE 0 to 797;
			EN				: IN STD_LOGIC;
			XPOS			: IN STD_LOGIC_VECTOR(15 downto 0);-- RANGE -315 to 315;
			YPOS			: IN STD_LOGIC_VECTOR(15 downto 0);-- RANGE -235 to 235;
			ZPOS			: IN STD_LOGIC_VECTOR(15 downto 0);-- RANGE 0 to 195;
			R				: OUT STD_LOGIC_VECTOR(9 downto 0);
			G				: OUT STD_LOGIC_VECTOR(9 downto 0);
			B				: OUT STD_LOGIC_VECTOR(9 downto 0)
);
END COMPONENT;

COMPONENT REG_16bit
PORT(		DATA_IN  		: IN STD_LOGIC_VECTOR(15 downto 0);
			CLOCK_50			: IN STD_LOGIC;
			EN					: IN STD_LOGIC;
			CL					: IN STD_LOGIC;
			DATA_OUT			: OUT STD_LOGIC_VECTOR(15 downto 0)
);
END COMPONENT;

COMPONENT ADDER
PORT(		DATA_IN0  		: IN SIGNED(15 downto 0);
			DATA_IN1  		: IN SIGNED(15 downto 0);
			C0					: IN STD_LOGIC;
			DATA_OUT			: OUT SIGNED(15 downto 0)
);
END COMPONENT;

SIGNAL STROBE_25 		: STD_LOGIC :='0';
SIGNAL PIXEL_Y			: INTEGER;-- RANGE 0 to 525;
SIGNAL PIXEL_X			: INTEGER;-- RANGE 0 to 797;
SIGNAL X_RESULT, Y_RESULT, Z_RESULT	: SIGNED(15 downto 0);
SIGNAL XPOS, YPOS, ZPOS			: STD_LOGIC_VECTOR(15 downto 0);

BEGIN

VGA_CLK <= STROBE_25;
VS<=VS_CTRL;
HS<=HS_CTRL;
-- I segnali dei contatori vengono inviati alle unita' di controllo
ROW<=PIXEL_Y;
COLUMN<=PIXEL_X;

-- Genera uno strobe con frequenza 25 MHz partendo dal segnale di clock
Strobe_25MHz: STROBE_GEN 		GENERIC MAP(DIVIDER => 1)
										PORT MAP(CLOCK_50, STR_EN, STROBE_25);

-- Contatore di colonna
col_count: COUNTER_COLUMN		PORT MAP(STROBE_25, HC_EN, HC_CL, PIXEL_X);

-- Contatore di riga
row_count: COUNTER_ROW 			PORT MAP(STROBE_25, VC_EN, VC_CL, PIXEL_Y);

-- Componente per gestire i segnali RGB a partire dalle coordinate correnti (PIXEL_X, PIXEL_Y)
-- e dallo spostamento dalla posizione iniziale (XPOS, YPOS, ZPOS, contenuti dentro 3 registri).										
VGA_SIGNALS: VGA_DECODER		GENERIC MAP(ROWS => ROWS, COLUMNS => COLUMNS)
										PORT MAP(PIXEL_Y, PIXEL_X, RGB_EN, XPOS, YPOS, ZPOS, R, G, B);

-- Sommatori usati per aggiornare i dati di posizione XPOS, YPOS, ZPOS con nuovi dati di spostamento.										
xadder: ADDER 				PORT MAP(signed(XPOS), X_UPDATE,'0',X_RESULT);
yadder: ADDER	 			PORT MAP(signed(YPOS), Y_UPDATE,'0',Y_RESULT);
zadder: ADDER		 		PORT MAP(signed(ZPOS), Z_UPDATE,'0',Z_RESULT);								

-- Registri usati per conservare il dato di posizione. Il segnale di load e' alto per un solo colpo di clock,
-- cosicche' le posizioni vengano aggiornate una volta sola quando arrivano nuovi dati.
-- Tale segnale proviene dal componente di controllo RS232_BUFF_STRUCT, che lo asserisce quando ha acquisito le nuove
-- posizioni. 										
xreg: REG_16bit 			PORT MAP(STD_LOGIC_VECTOR(X_RESULT), CLOCK_50, data_out_ready, HC_CL, XPOS);
yreg: REG_16bit 			PORT MAP(STD_LOGIC_VECTOR(Y_RESULT), CLOCK_50, data_out_ready, HC_CL, YPOS);
zreg: REG_16bit 			PORT MAP(STD_LOGIC_VECTOR(Z_RESULT), CLOCK_50, data_out_ready, HC_CL, ZPOS);																

-- Processo per saturare i valori di posizione in modo da evitare che il quadrato esca dallo schermo - progettazione
-- abbandonata per mancanza di tempo:

--SATURATORS
--PROCESS(X_RESULT_BUFFER, HC_CL)
--BEGIN
--IF(HC_CL='1') THEN
--	X_RESULT <= others =>'0';
--ELSIF(to_integer(X_RESULT_BUFFER)<-315+to_integer(SIGNED(ZPOS))) THEN
--	X_RESULT <= -315+to_integer(SIGNED(ZPOS));
--ELSIF(to_integer(X_RESULT_BUFFER)>315-to_integer(SIGNED(ZPOS))) THEN
--	X_RESULT <= "0000000011000011";
--ELSE
--	X_RESULT <= X_RESULT_BUFFER;
--END IF;
--END PROCESS;
--
--PROCESS(Y_RESULT_BUFFER, HC_CL)
--BEGIN
--IF(HC_CL='1') THEN
--	Y_RESULT <= others =>'0';
--ELSIF(to_integer(Y_RESULT_BUFFER)<0) THEN
--	Y_RESULT <= others =>'0';
--ELSIF(to_integer(Y_RESULT_BUFFER)>195) THEN
--	Y_RESULT <= "0000000011000011";
--ELSE
--	Y_RESULT <= Y_RESULT_BUFFER;
--END IF;
--END PROCESS;
--
--PROCESS(Z_RESULT_BUFFER, HC_CL)
--BEGIN
--IF(HC_CL='1') THEN
--	Z_RESULT <= others =>'0';
--ELSIF(to_integer(Z_RESULT_BUFFER)<0) THEN
--	Z_RESULT <= others =>'0';
--ELSIF(to_integer(Z_RESULT_BUFFER)>195) THEN
--	Z_RESULT <= "0000000011000011";
--ELSE
--	Z_RESULT <= Z_RESULT_BUFFER;
--END IF;
--END PROCESS;

END behavioural;