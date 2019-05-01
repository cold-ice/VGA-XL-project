library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_DECODER is

  generic (ROWS    : integer;
           COLUMNS : integer);
  port(ROW    : in  integer range 0 to 525;
       COLUMN : in  integer range 0 to 797;
       EN     : in  std_logic;
       -- I tre dati seguenti rappresentano lo spostamento del quadrato dalla posizione iniziale
       -- rispetto ai 3 assi.
       XPOS   : in  std_logic_vector(15 downto 0);  -- RANGE -315 to 315;
       YPOS   : in  std_logic_vector(15 downto 0);  -- RANGE -235 to 235;
       ZPOS   : in  std_logic_vector(15 downto 0);  -- RANGE 0 to 195;
       R      : out std_logic_vector(9 downto 0);
       G      : out std_logic_vector(9 downto 0);
       B      : out std_logic_vector(9 downto 0)
       );

end VGA_DECODER;

architecture behavioural of VGA_DECODER is

  constant H_S           : natural := 95;
  constant H_BACK_PORCH  : natural := 47;  -- Dalle specifiche dovrebbe essere 47.5
  constant H_VIDEO_OUT   : natural := 640;  -- Dalle specifiche dovrebbe essere 635
  constant H_FRONT_PORCH : natural := 15;
  constant H_BEGIN       : natural := H_S+H_BACK_PORCH;  -- Inizio schermo lungo asse x
  constant H_END         : natural := H_S+H_BACK_PORCH+H_VIDEO_OUT;  -- Fine schermo lungo asse x

  constant V_S           : natural := 2;
  constant V_BACK_PORCH  : natural := 33;
  constant V_VIDEO_OUT   : natural := 480;
  constant V_FRONT_PORCH : natural := 10;
  constant V_BEGIN       : natural := V_S+V_BACK_PORCH;  -- Inizio schermo lungo asse z
  constant V_END         : natural := V_S+V_BACK_PORCH+V_VIDEO_OUT;  -- Fine schermo lungo asse z

begin

-- Il seguente processo controlla se ci troviamo a delle coordinate occupate dal quadrato.
-- In tale caso, il segnale R viene acceso al massimo dell'intensita'.
-- Da notare che in mancanza del segnale di enable, asserito quando entrambe le unita' di controllo si trovano nello
-- stato VIDEO_ON, tale componente non e' abilitato e i segnali R, G e B sono tutti a 0.
-- Da notare infine che i contatori tengono conto anche delle tempistiche di sincronismo verticale e orizzontale,
-- dunque l'area utile per visualizzare il quadrato e' sempre limitata da H_BEGIN, H_END, V_BEGIN e V_END.
  RGB_output : process(EN, ROW, COLUMN, XPOS, YPOS, ZPOS)
  begin
    if (COLUMN >= H_BEGIN+315+to_integer(signed(XPOS))+to_integer(signed(YPOS)) and COLUMN < H_END-315+to_integer(signed(XPOS))-to_integer(signed(YPOS)) and ROW >= V_BEGIN+235+to_integer(signed(ZPOS))+to_integer(signed(YPOS)) and ROW < V_END-235+to_integer(signed(ZPOS))-to_integer(signed(YPOS)) and EN = '1') then
      R <= "1111111111";
      G <= (others => '0');
      B <= (others => '0');
    else
      R <= (others => '0');
      G <= (others => '0');
      B <= (others => '0');
    end if;
  end process;

end behavioural;
