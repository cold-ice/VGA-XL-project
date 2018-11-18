LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY CU_VGA_H IS

GENERIC (COLUMNS			: INTEGER);
PORT(		CLOCK_50  		: IN  STD_LOGIC;
			RESET				: IN STD_LOGIC;
			COLUMN			: IN INTEGER RANGE 0 to 797; -- Colonna corrente
			HC_EN				: OUT STD_LOGIC; -- Enable del contatore orizzontale
			VC_EN				: OUT STD_LOGIC; -- Enable del contatore verticale
			STR_EN			: OUT STD_LOGIC; -- Enable del generatore di strobe a 25 MHz
			HC_CL				: OUT STD_LOGIC; -- Clear del contatore orizzontale
			RGB_CTRL			: OUT STD_LOGIC; -- Segnale di controllo per abilitare il componente VGA decoder
			HS_CTRL			: OUT STD_LOGIC  -- Segnale inviato ad HSYNC 
);

END CU_VGA_H;

ARCHITECTURE behavioural OF CU_VGA_H IS

constant H_S 				: natural := 95;
constant H_BACK_PORCH 	: natural := 47; 	--in teoria 47.5
constant H_VIDEO_OUT 	: natural := 640; --in teoria 635
constant H_FRONT_PORCH 	: natural := 15;
constant H_BEGIN			: natural := H_S+H_BACK_PORCH;
constant H_END				: natural := H_S+H_BACK_PORCH+H_VIDEO_OUT+H_FRONT_PORCH;

TYPE STATES IS (RES, HSYNC, BACK_PORCH, VIDEO_ON, FRONT_PORCH, UPDATE_ROW);
SIGNAL STATUS, NEXTSTATUS : STATES :=HSYNC;

BEGIN

Status_update: PROCESS(CLOCK_50, RESET)
BEGIN
IF(RESET='1') THEN
	STATUS<=RES;
ELSIF(RISING_EDGE(CLOCK_50)) THEN
	STATUS<=NEXTSTATUS;
END IF;
END PROCESS;

Status_check: PROCESS(STATUS, COLUMN)
BEGIN
HC_EN<='1';
VC_EN<='0';
STR_EN<='1';
RGB_CTRL<='0';

HC_CL<='0';

HS_CTRL<='1';
CASE STATUS IS

	WHEN RES =>
		HC_EN<='0';
		HC_CL<='1';
		HS_CTRL<='0';
		STR_EN<='0';
		NEXTSTATUS<=HSYNC;
	
	WHEN HSYNC =>
		HS_CTRL<='0';
		IF(column>=H_S) THEN
			NEXTSTATUS <=BACK_PORCH;
		ELSE
			NEXTSTATUS <= HSYNC;
		END IF;
		
	WHEN BACK_PORCH =>
		IF(column=H_S+H_BACK_PORCH) THEN
			NEXTSTATUS <= VIDEO_ON;
		ELSE
			NEXTSTATUS <= BACK_PORCH;
		END IF;
		
	WHEN VIDEO_ON =>
		RGB_CTRL<='1';
		IF(column=H_S+H_BACK_PORCH+H_VIDEO_OUT) THEN
			NEXTSTATUS <= FRONT_PORCH;
		ELSE
			NEXTSTATUS <= VIDEO_ON;
		END IF;
		
	WHEN FRONT_PORCH =>
		IF(column=H_S+H_BACK_PORCH+H_VIDEO_OUT+H_FRONT_PORCH-1) THEN
			NEXTSTATUS <= UPDATE_ROW;
		ELSE
			NEXTSTATUS <= FRONT_PORCH;
		END IF;
		
	WHEN UPDATE_ROW =>
		VC_EN<='1';
		IF(column=0) THEN
			NEXTSTATUS <= HSYNC;
		ELSE
			NEXTSTATUS<=UPDATE_ROW;
		END IF;
		
	WHEN OTHERS =>
		HC_EN<='0';
		HC_CL<='1';
		STR_EN<='0';
		HS_CTRL<='0';
		NEXTSTATUS<=HSYNC;	
END CASE;
END PROCESS;
END behavioural;