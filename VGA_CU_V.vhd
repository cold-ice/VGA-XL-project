LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY CU_VGA_V IS

GENERIC (ROWS				: INTEGER);
PORT(		CLOCK_50  		: IN  STD_LOGIC;
			RESET				: IN STD_LOGIC;
			ROW				: IN INTEGER RANGE 0 to 525; -- Riga corrente
			VC_CL				: OUT STD_LOGIC; -- Clear del contatore di riga
			RGB_CTRL			: OUT STD_LOGIC; -- Segnale di controllo per abilitare il componente VGA decoder
			VS_CTRL			: OUT STD_LOGIC  -- Segnale inviato a HSYNC 
);

END CU_VGA_V;

ARCHITECTURE behavioural OF CU_VGA_V IS

constant V_S			   : natural := 2;
constant V_BACK_PORCH 	: natural := 33;
constant V_VIDEO_OUT 	: natural := 480;
constant V_FRONT_PORCH 	: natural := 10;
constant V_BEGIN			: natural := V_S+V_BACK_PORCH;
constant V_END				: natural := V_S+V_BACK_PORCH+V_FRONT_PORCH;

TYPE STATES IS (RES, VSYNC, BACK_PORCH, VIDEO_ON, FRONT_PORCH);
SIGNAL STATUS, NEXTSTATUS : STATES :=VSYNC;

BEGIN

Status_update: PROCESS(CLOCK_50, RESET)
BEGIN
IF(RESET='1') THEN
	STATUS<=RES;
ELSIF(RISING_EDGE(CLOCK_50)) THEN
	STATUS<=NEXTSTATUS;
END IF;
END PROCESS;

Status_check: PROCESS(ROW, STATUS)
BEGIN

RGB_CTRL<='0';
VC_CL<='0';

VS_CTRL<='1';
CASE STATUS IS

	WHEN RES =>
		VC_CL<='1';
		VS_CTRL<='0';
		NEXTSTATUS<=VSYNC;
	
	WHEN VSYNC =>
		VS_CTRL<='0';
		IF(ROW=V_S) THEN
			NEXTSTATUS <=BACK_PORCH;
		ELSE
			NEXTSTATUS <= VSYNC;
		END IF;
		
	WHEN BACK_PORCH =>
		IF(ROW=V_S+V_BACK_PORCH) THEN
			NEXTSTATUS <= VIDEO_ON;
		ELSE
			NEXTSTATUS <= BACK_PORCH;
		END IF;
		
	WHEN VIDEO_ON =>
		RGB_CTRL<='1';
		IF(ROW=V_S+V_BACK_PORCH+V_VIDEO_OUT) THEN
			NEXTSTATUS <= FRONT_PORCH;
		ELSE
			NEXTSTATUS <= VIDEO_ON;
		END IF;
		
	WHEN FRONT_PORCH =>
		IF(ROW=0) THEN
			NEXTSTATUS <= VSYNC;
		ELSE
			NEXTSTATUS <= FRONT_PORCH;
		END IF;
		
	WHEN OTHERS =>
		VC_CL<='1';
		VS_CTRL<='0';
		NEXTSTATUS<=VSYNC;	
END CASE;
END PROCESS;
END behavioural;