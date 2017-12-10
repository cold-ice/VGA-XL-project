LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY VGA_DECODER_tb IS

END VGA_DECODER_tb;


ARCHITECTURE behavioural OF VGA_DECODER_tb IS

COMPONENT VGA_DECODER
GENERIC (ROWS			: INTEGER;
			COLUMNS		: INTEGER);
PORT(		ROW  			: IN INTEGER RANGE 0 to 525;
			COLUMN  		: IN INTEGER RANGE 0 to 797;
			EN				: IN STD_LOGIC;
			-- I tre dati seguenti rappresentano lo spostamento del quadrato dalla posizione iniziale 
			-- rispetto ai 3 assi.
			XPOS			: IN STD_LOGIC_VECTOR(15 downto 0);-- RANGE -315 to 315;
			YPOS			: IN STD_LOGIC_VECTOR(15 downto 0);-- RANGE -235 to 235;
			ZPOS			: IN STD_LOGIC_VECTOR(15 downto 0);-- RANGE 0 to 195;
			R				: OUT STD_LOGIC_VECTOR(9 downto 0);
			G				: OUT STD_LOGIC_VECTOR(9 downto 0);
			B				: OUT STD_LOGIC_VECTOR(9 downto 0)
);

END COMPONENT;

constant H_S 				: natural := 95;
constant H_BACK_PORCH 	: natural := 47;  -- Dalle specifiche dovrebbe essere 47.5
constant H_VIDEO_OUT 	: natural := 640; -- Dalle specifiche dovrebbe essere 635
constant H_FRONT_PORCH 	: natural := 15;
constant H_BEGIN			: natural := H_S+H_BACK_PORCH; -- Inizio schermo lungo asse x
constant H_END				: natural := H_S+H_BACK_PORCH+H_VIDEO_OUT; -- Fine schermo lungo asse x

constant V_S 				: natural := 2;
constant V_BACK_PORCH 	: natural := 33;
constant V_VIDEO_OUT 	: natural := 480;
constant V_FRONT_PORCH 	: natural := 10;
constant V_BEGIN			: natural := V_S+V_BACK_PORCH; -- Inizio schermo lungo asse z
constant V_END				: natural := V_S+V_BACK_PORCH+V_VIDEO_OUT; -- Fine schermo lungo asse z

SIGNAL CLOCK_25, SYS0, SYS1, SYS2, SYS3, HCHECK, VCHECK, TOTCHECK	: STD_LOGIC:='0';
SIGNAL ROW, COLUMN, CHECKX, CHECKY, CHECKZ					: INTEGER:=0;
SIGNAL XPOS, YPOS, ZPOS : STD_LOGIC_VECTOR(15 downto 0)	:=(others=>'0');

BEGIN

VGA_ctrl: VGA_DECODER		GENERIC MAP(ROWS => 797, COLUMNS => 525)
									PORT MAP(ROW => ROW, COLUMN=> COLUMN, EN=>'1', XPOS=>XPOS, YPOS=>YPOS, ZPOS=>ZPOS);

CHECKX<=TO_INTEGER(SIGNED(XPOS));
CHECKY<=TO_INTEGER(SIGNED(YPOS));
CHECKZ<=TO_INTEGER(SIGNED(ZPOS));

HCHECK <= SYS0 AND SYS1;
VCHECK <= SYS2 AND SYS3;
TOTCHECK<= HCHECK AND VCHECK;
									
-- Clock a 25 MHz
CLK: PROCESS
BEGIN  
CLOCK_25<='0';
wait for 20 ns;
CLOCK_25<='1';
wait for 20 ns;
END PROCESS;

-- POSIZIONE X
POSX: PROCESS(CLOCK_25)
BEGIN
IF(FALLING_EDGE(CLOCK_25)) THEN
	IF(COLUMN<796) THEN
		COLUMN<=COLUMN+1;
	ELSE
		COLUMN<=0;
	END IF;
END IF;
END PROCESS;

-- POSIZIONE Y
POSY: PROCESS(COLUMN, CLOCK_25)
BEGIN
IF(FALLING_EDGE(CLOCK_25)) THEN
	IF(COLUMN=796) THEN
		IF(ROW<524) THEN
			ROW<=ROW+1;
		ELSE
			ROW<=0;
		END IF;	
	END IF;
END IF;
END PROCESS;

-- Segnali
XPOS<="0000000000001111";
YPOS<="1111111111110111";
ZPOS<="0000000000000011";

-- SYSTEM CHECK
PROCESS(COLUMN, ROW)
BEGIN
IF (COLUMN>=H_BEGIN+315+to_integer(SIGNED(XPOS))+to_integer(SIGNED(YPOS))) THEN
	SYS0<='1';
ELSE
	SYS0<='0';
END IF;

IF(COLUMN<H_END-315+to_integer(SIGNED(XPOS))-to_integer(SIGNED(YPOS))) THEN
	SYS1<='1';
ELSE
	SYS1<='0';
END IF;

IF(ROW>=V_BEGIN+235+to_integer(SIGNED(ZPOS))+to_integer(SIGNED(YPOS))) THEN
	SYS2<='1';
ELSE
	SYS2<='0';
END IF;

IF(ROW<V_END-235+to_integer(SIGNED(ZPOS))-to_integer(SIGNED(YPOS))) THEN
	SYS3<='1';
ELSE
	SYS3<='0';
END IF;

END PROCESS;
END behavioural;