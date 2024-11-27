library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity symb_det is

    Port (  clk: in STD_LOGIC; -- input clock 96kHz
            clr: in STD_LOGIC; -- input synchronized reset
            adc_data: in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
            symbol_valid: out STD_LOGIC;
            symbol_out: out STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
            );

end symb_det;


architecture Behavioral of symb_det is

    TYPE state_type IS (start, check_negative, check_positive, timepassed,count_start);
    SIGNAL state, next_state: state_type;
    -- Declare variables here
    SIGNAL counter : unsigned(7 downto 0); -- counter for counting the number of zero crossing detection
    SIGNAL timecount: unsigned(12 downto 0); -- counter for counting if 1/16 second has passed(i.e when 1/16 second has passed then the count=6000)
    constant middle: STD_LOGIC_VECTOR(11 DOWNTO 0) := "100000000000"; --2048 in decimal
    constant top: STD_LOGIC_VECTOR(11 DOWNTO 0) := "110000000000"; --3072
    constant bottom: STD_LOGIC_VECTOR(11 DOWNTO 0) := "010000000000"; --1024
    SIGNAL decode_counter: unsigned(7 downto 0);
    
    signal r1 : std_logic_vector(14 downto 0);  -- 12 bits for ADC data
    signal r2 : std_logic_vector(14 downto 0);
    signal r3 : std_logic_vector(14 downto 0);
    signal r4 : std_logic_vector(14 downto 0);
    signal r5 : std_logic_vector(14 downto 0);
    signal r6 : std_logic_vector(14 downto 0);
    signal r7 : std_logic_vector(14 downto 0);
    signal r8 : std_logic_vector(14 downto 0);
    signal sum : std_logic_vector(14 downto 0);  -- Adjusted for sum of 8 registers
    signal avg : std_logic_vector(11 downto 0);
begin
    
    MA_PROC: process (clk, clr) begin     
        if clr ='1' then                  
            r1 <= (others => '0');       
            r2 <= (others => '0');       
            r3 <= (others => '0');       
            r4 <= (others => '0');       
            r5 <= (others => '0');       
            r6 <= (others => '0');       
            r7 <= (others => '0');       
            r8 <= (others => '0');       
            sum <= (others => '0');      
            avg <= (others => '0');        
        elsif rising_edge(clk) then       
            r1 (11 downto 0) <= adc_data;    
            r2 <= r1;                       
            r3 <= r2;                       
            r4 <= r3;                       
            r5 <= r4;                       
            r6 <= r5;                       
            r7 <= r6;                       
            r8 <= r7;                       
            sum <= (r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8);           
            avg <= sum(14 downto 3);     
        end if;                           
    end process;
    
    SYNC_PROC: process (clk, clr, avg)
    begin
        if clr ='1' then
            state <= start;
            counter <= to_unsigned(0, 8);
            symbol_out <= "000";
            symbol_valid <= '0';
            timecount <= to_unsigned(0,13);
        elsif rising_edge(clk) then
            state <= next_state;
            if state = start then
                timecount <= to_unsigned(1,13);
                counter <= to_unsigned(0, 8);
           elsif state = check_positive then
                symbol_valid <= '0';
                timecount <= timecount + 1;
                if next_state = check_negative then
                    counter <= counter + 1;
                end if;
                
           elsif state = check_negative then
                symbol_valid <= '0';
                timecount <= timecount + 1;
        elsif state = timepassed then
          if counter >= 130 then
             symbol_valid <= '1';
             symbol_out <= "000"; --0
          end if;

          if counter >=109 and counter < 130 then
             symbol_valid <= '1';
             symbol_out <= "001"; --1
          end if;

          if counter >= 87 and counter <109 then
             symbol_valid <= '1';
             symbol_out <= "010"; --2
          end if;

          if counter >=73 and counter <87 then
             symbol_valid <= '1';
             symbol_out <= "011"; --3
          end if;

          if counter >=61 and counter <73 then
             symbol_valid <= '1';
             symbol_out <= "100"; --4
          end if;

          if counter >=48 and counter <61 then
             symbol_valid <= '1';
             symbol_out <= "101"; --5
          end if;

          if counter >=41 and counter <48 then
             symbol_valid <= '1';
             symbol_out <= "110"; --6
          end if;

          if counter >=32 and counter <41 then
             symbol_valid <= '1';
             symbol_out <= "111"; --7
          end if;
          
          timecount <= to_unsigned(1, 13);
          counter <= to_unsigned(0, 8);
        end if;    
        end if;
    end process;

    NEXT_STATE_DECODE: PROCESS (state, adc_data,timecount)
    begin
        next_state <= state;
    case (state) is
        when start =>
            next_state <= check_negative;
            
        when check_negative =>
            if timecount >= 5999 then
                next_state <= timepassed;
            elsif avg >= top then
                next_state <= check_positive;
            else
                next_state <= check_negative;
            end if;
            
       when check_positive =>
            if timecount >= 5999 then
                next_state <= timepassed;
            elsif avg <= bottom then
                next_state <= check_negative;
            else
                next_state <= check_positive;
            end if;

       when timepassed =>
            next_state <= check_negative;
       when others =>
            next_state <= state;

    end case;
    end process;

    

    

--    OUTPUT_DECODE: process (state, next_state)
--    begin
--        if state = start then
--            symbol_valid <= '0';
        
--        elsif state = check_positive then
--            symbol_valid <= '0';

--        elsif state = check_negative then
--            symbol_valid <= '0';
--        end if;
--    end process;


end Behavioral;
